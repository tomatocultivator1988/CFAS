"""
Unit and integration tests for the student pass-prediction pipeline.

Run with:
    pytest tests.py -v
"""
from __future__ import annotations

import json
import math
import sys
from pathlib import Path
from typing import Any
from unittest.mock import patch

import numpy as np
import pytest

# Make the package importable from this directory.
sys.path.insert(0, str(Path(__file__).parent))

from config import (
    HEURISTIC_WEIGHTS,
    LOW_RISK_THRESHOLD,
    MEDIUM_RISK_THRESHOLD,
    MINIMUM_TRAINING_SAMPLES,
)
from types_ import FeatureVector, PredictionSample, TrainingSample
from utils import (
    clamp_probability,
    classify_risk,
    complement_probability,
    compute_metrics,
    to_percentage,
    validate_payload,
)
from prediction import predict_from_heuristic
from pipeline import _class_prior, _resolve_model_key, run


# ===========================================================================
# Fixtures
# ===========================================================================

def _make_feature_dict(**overrides: float) -> dict[str, float]:
    defaults = {
        "attempt_count":     5.0,
        "avg_score":         70.0,
        "min_score":         55.0,
        "max_score":         88.0,
        "latest_score":      75.0,
        "recent_avg_score":  72.0,
        "score_trend":       5.0,
        "score_stddev":      8.0,
        "pass_rate":         80.0,
        "avg_passing_score": 76.0,
        "unique_exam_count": 3.0,
        "days_span":         30.0,
    }
    return {**defaults, **overrides}


def _make_training_sample(label: int, **feature_overrides: float) -> dict[str, Any]:
    return {
        "student_id": 1,
        "label": label,
        "features": _make_feature_dict(**feature_overrides),
    }


def _make_prediction_sample(**feature_overrides: float) -> dict[str, Any]:
    return {
        "student_id": 99,
        "features": _make_feature_dict(**feature_overrides),
    }


def _build_minimal_payload(
    n_pass: int = 20,
    n_fail: int = 20,
    model: str = "ensemble",
) -> dict[str, Any]:
    training = (
        [_make_training_sample(1, avg_score=80.0, pass_rate=90.0) for _ in range(n_pass)]
        + [_make_training_sample(0, avg_score=40.0, pass_rate=20.0) for _ in range(n_fail)]
    )
    prediction = [_make_prediction_sample()]
    return {
        "model": model,
        "training_samples": training,
        "prediction_samples": prediction,
    }


# ===========================================================================
# utils.py
# ===========================================================================

class TestClampProbability:
    def test_within_range(self):
        assert clamp_probability(50.0) == 50.0

    def test_below_zero(self):
        assert clamp_probability(-10.0) == 0.0

    def test_above_hundred(self):
        assert clamp_probability(110.0) == 100.0

    def test_rounding(self):
        assert clamp_probability(33.3333333) == 33.33


class TestComplementProbability:
    def test_basic(self):
        assert complement_probability(60.0) == 40.0

    def test_zero(self):
        assert complement_probability(0.0) == 100.0

    def test_hundred(self):
        assert complement_probability(100.0) == 0.0


class TestToPercentage:
    def test_conversion(self):
        assert to_percentage(0.75) == 75.0

    def test_clamp_on_overflow(self):
        assert to_percentage(1.5) == 100.0


class TestClassifyRisk:
    def test_low(self):
        assert classify_risk(LOW_RISK_THRESHOLD) == "Low"
        assert classify_risk(100.0) == "Low"

    def test_medium(self):
        assert classify_risk(MEDIUM_RISK_THRESHOLD) == "Medium"
        assert classify_risk(LOW_RISK_THRESHOLD - 0.1) == "Medium"

    def test_high(self):
        assert classify_risk(0.0) == "High"
        assert classify_risk(MEDIUM_RISK_THRESHOLD - 0.1) == "High"


class TestComputeMetrics:
    def _probs(self, preds: list[int]) -> list[float]:
        return [float(p) for p in preds]

    def test_perfect_classifier(self):
        y = [1, 1, 0, 0]
        p = self._probs([1, 1, 0, 0])
        m = compute_metrics(y, p)
        assert m.accuracy == 100.0
        assert m.f1 == 100.0

    def test_single_class_auc_defaults_to_50(self):
        y = [1, 1, 1, 1]
        p = [0.9, 0.8, 0.7, 0.6]
        m = compute_metrics(y, p)
        assert m.auc == 50.0

    def test_metric_range(self):
        y = [1, 0, 1, 0, 1, 0]
        p = [0.8, 0.3, 0.9, 0.2, 0.6, 0.55]
        m = compute_metrics(y, p)
        for value in (m.accuracy, m.precision, m.recall, m.f1, m.auc):
            assert 0.0 <= value <= 100.0


class TestValidatePayload:
    def test_valid(self):
        validate_payload({"training_samples": [], "prediction_samples": []})

    def test_not_a_dict(self):
        with pytest.raises(ValueError, match="JSON object"):
            validate_payload([])  # type: ignore[arg-type]

    def test_missing_training(self):
        with pytest.raises(ValueError, match="training_samples"):
            validate_payload({"prediction_samples": []})

    def test_missing_prediction(self):
        with pytest.raises(ValueError, match="prediction_samples"):
            validate_payload({"training_samples": []})


# ===========================================================================
# types_.py
# ===========================================================================

class TestFeatureVector:
    def test_from_dict_defaults(self):
        fv = FeatureVector.from_dict({})
        assert fv.avg_score == 0.0

    def test_from_dict_values(self):
        fv = FeatureVector.from_dict({"avg_score": 77.5})
        assert fv.avg_score == 77.5

    def test_to_list_length(self):
        fv = FeatureVector.from_dict(_make_feature_dict())
        assert len(fv.to_list()) == len(FeatureVector.__dataclass_fields__)

    def test_immutable(self):
        fv = FeatureVector()
        with pytest.raises((AttributeError, TypeError)):
            fv.avg_score = 99.0  # type: ignore[misc]


class TestTrainingSample:
    def test_valid(self):
        raw = _make_training_sample(1)
        ts = TrainingSample.from_dict(raw)
        assert ts.label == 1

    def test_invalid_label(self):
        raw = _make_training_sample(2)
        with pytest.raises(ValueError, match="label must be 0 or 1"):
            TrainingSample.from_dict(raw)


# ===========================================================================
# pipeline.py — unit level
# ===========================================================================

class TestResolveModelKey:
    def test_valid_keys(self):
        for key in ("logistic_regression", "random_forest", "ensemble"):
            assert _resolve_model_key(key) == key

    def test_invalid_key_defaults(self):
        assert _resolve_model_key("xgboost") == "ensemble"


class TestClassPrior:
    def test_all_pass(self):
        assert _class_prior([1, 1, 1]) == 100.0

    def test_all_fail(self):
        assert _class_prior([0, 0, 0]) == 0.0

    def test_balanced(self):
        assert _class_prior([0, 1]) == 50.0

    def test_empty(self):
        assert _class_prior([]) == 50.0


# ===========================================================================
# prediction.py
# ===========================================================================

class TestHeuristicPredictions:
    def _sample(self, pass_rate: float, avg_score: float, trend: float) -> PredictionSample:
        raw = _make_prediction_sample(pass_rate=pass_rate, avg_score=avg_score, score_trend=trend)
        return PredictionSample.from_dict(raw)

    def test_high_performer_low_risk(self):
        sample = self._sample(pass_rate=95.0, avg_score=92.0, trend=10.0)
        [pred] = predict_from_heuristic([sample], baseline=75.0)
        assert pred.risk_level == "Low"
        assert pred.pass_probability > 80.0

    def test_low_performer_high_risk(self):
        sample = self._sample(pass_rate=10.0, avg_score=35.0, trend=-20.0)
        [pred] = predict_from_heuristic([sample], baseline=50.0)
        assert pred.risk_level == "High"
        assert pred.pass_probability < 45.0

    def test_pass_and_fail_sum_to_100(self):
        sample = self._sample(pass_rate=60.0, avg_score=65.0, trend=0.0)
        [pred] = predict_from_heuristic([sample], baseline=50.0)
        assert math.isclose(pred.pass_probability + pred.fail_probability, 100.0, abs_tol=0.1)

    def test_model_used_is_heuristic(self):
        sample = self._sample(pass_rate=50.0, avg_score=50.0, trend=0.0)
        [pred] = predict_from_heuristic([sample], baseline=50.0)
        assert pred.model_used == "heuristic"


# ===========================================================================
# pipeline.py — integration level
# ===========================================================================

class TestRunPipeline:
    def test_insufficient_data_triggers_fallback(self):
        payload = {
            "model": "ensemble",
            "training_samples": [_make_training_sample(1)] * 5,
            "prediction_samples": [_make_prediction_sample()],
        }
        result = run(payload)
        assert result.success
        assert result.metrics["model_type"] == "heuristic_fallback"

    def test_single_class_triggers_fallback(self):
        payload = {
            "model": "ensemble",
            "training_samples": [_make_training_sample(1)] * 20,
            "prediction_samples": [_make_prediction_sample()],
        }
        result = run(payload)
        assert result.success
        assert result.metrics["model_type"] == "heuristic_fallback"

    def test_ml_path_runs_successfully(self):
        payload = _build_minimal_payload()
        result = run(payload)
        assert result.success
        assert len(result.predictions) == 1
        pred = result.predictions[0]
        assert 0.0 <= pred.pass_probability <= 100.0
        assert pred.risk_level in ("Low", "Medium", "High")

    def test_each_supported_model_key(self):
        for model in ("logistic_regression", "random_forest", "ensemble"):
            payload = _build_minimal_payload(model=model)
            result = run(payload)
            assert result.success, f"Pipeline failed for model={model}"
            assert result.predictions[0].model_used == model

    def test_metrics_contain_cv_note(self):
        payload = _build_minimal_payload()
        result = run(payload)
        assert result.metrics.get("evaluation_method") == "stratified_k_fold_cross_validation"

    def test_invalid_payload_returns_failure(self):
        result = run({"bad_key": []})  # missing required keys
        assert not result.success

    def test_no_prediction_samples(self):
        payload = _build_minimal_payload()
        payload["prediction_samples"] = []
        result = run(payload)
        assert result.success
        assert result.predictions == []

    def test_prediction_probabilities_in_range(self):
        payload = _build_minimal_payload(n_pass=30, n_fail=30)
        result = run(payload)
        for pred in result.predictions:
            assert 0.0 <= pred.pass_probability <= 100.0
            assert 0.0 <= pred.fail_probability <= 100.0

    def test_serialisation_roundtrip(self):
        payload = _build_minimal_payload()
        result = run(payload)
        serialised = json.dumps(result.to_dict())
        deserialised = json.loads(serialised)
        assert deserialised["success"] is True
        assert isinstance(deserialised["predictions"], list)
