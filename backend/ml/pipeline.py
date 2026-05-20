"""
Pipeline orchestrator.

This module owns the top-level control flow:
  1. Parse and validate the incoming payload.
  2. Decide whether to train an ML model or fall back to a heuristic.
  3. Delegate training and inference to specialised modules.
  4. Serialise the result as JSON.

It is deliberately thin — no business logic lives here.
"""
from __future__ import annotations

import json
import logging
import sys
import traceback
from typing import Any

import numpy as np

from config import (
    DEFAULT_MODEL,
    FEATURE_KEYS,
    MINIMUM_CLASS_COUNT,
    MINIMUM_TRAINING_SAMPLES,
    SUPPORTED_MODELS,
)
from models import train_ensemble
from prediction import predict_from_ensemble, predict_from_heuristic
from types_ import (
    ModelKey,
    PipelineResult,
    PredictionSample,
    TrainingSample,
)
from utils import clamp_probability, validate_payload

# ---------------------------------------------------------------------------
# Logging configuration
# ---------------------------------------------------------------------------

logging.basicConfig(
    level=logging.INFO,
    format="%(asctime)s  %(levelname)-8s  %(name)s  %(message)s",
    datefmt="%Y-%m-%dT%H:%M:%S",
    stream=sys.stderr,   # keep stdout clean for JSON output
)
logger = logging.getLogger(__name__)


# ---------------------------------------------------------------------------
# Helpers
# ---------------------------------------------------------------------------

def _resolve_model_key(requested: str) -> ModelKey:
    """Return a valid model key, defaulting gracefully on unknown values."""
    if requested in SUPPORTED_MODELS:
        return requested  # type: ignore[return-value]
    logger.warning(
        "Unknown model %r requested; falling back to %r.", requested, DEFAULT_MODEL
    )
    return DEFAULT_MODEL  # type: ignore[return-value]


def _class_prior(labels: list[int]) -> float:
    """Return the positive-class prior as a percentage."""
    if not labels:
        return 50.0
    return clamp_probability(sum(labels) / len(labels) * 100.0)


# ---------------------------------------------------------------------------
# Fallback path
# ---------------------------------------------------------------------------

def _run_fallback(
    training_samples: list[TrainingSample],
    prediction_samples: list[PredictionSample],
    model_key: ModelKey,
    reason: str,
) -> PipelineResult:
    logger.warning("Using heuristic fallback. Reason: %s", reason)
    labels = [s.label for s in training_samples]
    baseline = _class_prior(labels)

    predictions = predict_from_heuristic(prediction_samples, baseline)

    metrics: dict[str, Any] = {
        "model_type":              "heuristic_fallback",
        "fallback_reason":         reason,
        "training_samples":        len(training_samples),
        "class_balance_pass_rate": baseline,
        # Deliberately report None so the caller knows these are not ML metrics.
        "accuracy":  None,
        "precision": None,
        "recall":    None,
        "f1":        None,
        "auc":       None,
    }

    return PipelineResult(
        success=True,
        model=model_key,
        metrics=metrics,
        predictions=predictions,
    )


# ---------------------------------------------------------------------------
# ML training + inference path
# ---------------------------------------------------------------------------

def _run_ml_pipeline(
    training_samples: list[TrainingSample],
    prediction_samples: list[PredictionSample],
    model_key: ModelKey,
) -> PipelineResult:
    x = np.array(
        [s.features.to_list() for s in training_samples], dtype=float
    )
    y = np.array([s.label for s in training_samples], dtype=int)

    ensemble = train_ensemble(x, y)
    predictions = predict_from_ensemble(ensemble, prediction_samples, model_key)

    # Serialize feature importances if available
    importances_dict: dict[str, float] | None = None
    if ensemble.feature_importances is not None:
        importances_dict = {
            key: round(float(val), 4)
            for key, val in zip(FEATURE_KEYS, ensemble.feature_importances)
        }

    selected_metrics = {
        "logistic_regression": ensemble.logistic_metrics,
        "random_forest":       ensemble.random_forest_metrics,
        "ensemble":            ensemble.ensemble_metrics,
    }[model_key]

    metrics: dict[str, Any] = {
        "model_type":        model_key,
        "evaluation_method": "stratified_k_fold_cross_validation",
        "best_model_by_f1":  ensemble.best_model_by_f1,
        "training_samples":  len(training_samples),
        "logistic_regression": ensemble.logistic_metrics.to_dict(),
        "random_forest":       ensemble.random_forest_metrics.to_dict(),
        "ensemble":            ensemble.ensemble_metrics.to_dict(),
        # Top-level convenience fields for the selected model
        "accuracy":  selected_metrics.accuracy,
        "precision": selected_metrics.precision,
        "recall":    selected_metrics.recall,
        "f1":        selected_metrics.f1,
        "auc":       selected_metrics.auc,
    }
    if importances_dict:
        metrics["feature_importances"] = importances_dict

    return PipelineResult(
        success=True,
        model=model_key,
        metrics=metrics,
        predictions=predictions,
    )


# ---------------------------------------------------------------------------
# Main entry-point
# ---------------------------------------------------------------------------

def run(payload: dict[str, Any]) -> PipelineResult:
    """
    Execute the full prediction pipeline for one request.

    Args:
        payload: Deserialised JSON payload.

    Returns:
        A :class:`PipelineResult` describing outcomes and predictions.
    """
    validate_payload(payload)

    model_key = _resolve_model_key(payload.get("model", DEFAULT_MODEL))

    training_samples = [
        TrainingSample.from_dict(raw)
        for raw in payload.get("training_samples", [])
    ]
    prediction_samples = [
        PredictionSample.from_dict(raw)
        for raw in payload.get("prediction_samples", [])
    ]

    logger.info(
        "Request: model=%s  training_n=%d  prediction_n=%d",
        model_key, len(training_samples), len(prediction_samples),
    )

    # --- Fallback guard: insufficient data ---
    if len(training_samples) < MINIMUM_TRAINING_SAMPLES:
        return _run_fallback(
            training_samples, prediction_samples, model_key,
            reason=f"Only {len(training_samples)} training samples; minimum is {MINIMUM_TRAINING_SAMPLES}.",
        )

    # --- Fallback guard: single-class labels ---
    labels = [s.label for s in training_samples]
    if len(set(labels)) < MINIMUM_CLASS_COUNT:
        return _run_fallback(
            training_samples, prediction_samples, model_key,
            reason="All training labels belong to a single class; cannot train a discriminative model.",
        )

    return _run_ml_pipeline(training_samples, prediction_samples, model_key)


def main() -> None:
    try:
        payload = json.load(sys.stdin)
        result = run(payload)
    except Exception as exc:  # pylint: disable=broad-except
        logger.exception("Unhandled exception in pipeline.")
        result = PipelineResult(
            success=False,
            model=DEFAULT_MODEL,  # type: ignore[arg-type]
            metrics={},
            predictions=[],
            error=str(exc),
        )

    print(json.dumps(result.to_dict(), indent=2))


if __name__ == "__main__":
    main()