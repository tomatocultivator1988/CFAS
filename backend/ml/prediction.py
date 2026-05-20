"""
Prediction layer: converts trained models or heuristics into
:class:`StudentPrediction` objects.
"""
from __future__ import annotations

import logging
from typing import Sequence

import numpy as np

from config import FEATURE_KEYS, HEURISTIC_WEIGHTS
from models import TrainedEnsemble
from types_ import ModelKey, PredictionSample, StudentPrediction
from utils import classify_risk, clamp_probability, complement_probability, to_percentage

logger = logging.getLogger(__name__)


# ---------------------------------------------------------------------------
# Feature extraction
# ---------------------------------------------------------------------------

def build_feature_matrix(samples: Sequence[PredictionSample]) -> np.ndarray:
    """
    Convert a sequence of :class:`PredictionSample` objects into a
    2-D numpy array ready for sklearn inference.
    """
    rows = [sample.features.to_list() for sample in samples]
    return np.array(rows, dtype=float)


# ---------------------------------------------------------------------------
# ML-based predictions
# ---------------------------------------------------------------------------

def predict_from_ensemble(
    ensemble: TrainedEnsemble,
    samples: Sequence[PredictionSample],
    model_key: ModelKey,
) -> list[StudentPrediction]:
    """
    Generate :class:`StudentPrediction` records using the trained ensemble.

    Args:
        ensemble:  A fully trained :class:`TrainedEnsemble`.
        samples:   Samples to run inference on.
        model_key: Which model's probability to use as the primary output.

    Returns:
        One :class:`StudentPrediction` per input sample, in input order.
    """
    if not samples:
        return []

    x = build_feature_matrix(samples)

    lr_probs  = ensemble.predict_proba_logistic(x)
    rf_probs  = ensemble.predict_proba_random_forest(x)
    ens_probs = ensemble.predict_proba_ensemble(x)

    selector = {
        "logistic_regression": lr_probs,
        "random_forest":       rf_probs,
        "ensemble":            ens_probs,
    }
    primary_probs = selector.get(model_key, ens_probs)

    predictions: list[StudentPrediction] = []
    for i, sample in enumerate(samples):
        lr_pct  = to_percentage(float(lr_probs[i]))
        rf_pct  = to_percentage(float(rf_probs[i]))
        pass_pct = to_percentage(float(primary_probs[i]))

        predictions.append(StudentPrediction(
            student_id=sample.student_id,
            pass_probability=pass_pct,
            fail_probability=complement_probability(pass_pct),
            risk_level=classify_risk(pass_pct),
            model_used=model_key,
            logistic_probability=lr_pct,
            random_forest_probability=rf_pct,
        ))

    return predictions


# ---------------------------------------------------------------------------
# Heuristic fallback predictions
# ---------------------------------------------------------------------------

def predict_from_heuristic(
    samples: Sequence[PredictionSample],
    baseline: float,
) -> list[StudentPrediction]:
    """
    Generate predictions using a transparent, weighted heuristic.

    Used when there is insufficient or non-diverse training data to fit
    a reliable ML model.  The heuristic is intentionally simple and
    interpretable so that its limitations are obvious to the caller.

    Args:
        samples:  Samples to generate predictions for.
        baseline: Class-prior pass rate expressed as a percentage (0–100).

    Returns:
        One :class:`StudentPrediction` per input sample.
    """
    w = HEURISTIC_WEIGHTS
    predictions: list[StudentPrediction] = []

    for sample in samples:
        f = sample.features
        pass_rate = f.pass_rate if f.pass_rate else baseline
        avg_score = f.avg_score if f.avg_score else baseline
        trend_component = (f.score_trend + 50.0)  # normalise −100..+100 → 0..100

        raw = (
            w.pass_rate * pass_rate
            + w.avg_score * avg_score
            + w.trend    * trend_component
        )
        pass_pct = clamp_probability(raw)

        predictions.append(StudentPrediction(
            student_id=sample.student_id,
            pass_probability=pass_pct,
            fail_probability=complement_probability(pass_pct),
            risk_level=classify_risk(pass_pct),
            model_used="heuristic",
            logistic_probability=pass_pct,
            random_forest_probability=pass_pct,
        ))

    return predictions