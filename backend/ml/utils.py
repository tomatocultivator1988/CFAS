"""
Pure utility functions with no side-effects.

All functions here are stateless, fully type-annotated, and independently testable.
"""
from __future__ import annotations

import logging
from typing import Sequence

import numpy as np
from sklearn.metrics import (
    accuracy_score,
    f1_score,
    precision_score,
    recall_score,
    roc_auc_score,
)

from config import (
    LOW_RISK_THRESHOLD,
    MEDIUM_RISK_THRESHOLD,
    PASS_PROBABILITY_THRESHOLD,
)
from types_ import ModelMetrics, RiskLevel

logger = logging.getLogger(__name__)


# ---------------------------------------------------------------------------
# Probability helpers
# ---------------------------------------------------------------------------

def clamp_probability(value: float) -> float:
    """Clamp a raw probability to [0.0, 100.0] and round to 2 d.p."""
    return round(max(0.0, min(100.0, value)), 2)


def complement_probability(value: float) -> float:
    """Return the complement of a clamped probability."""
    return clamp_probability(100.0 - value)


def to_percentage(raw_prob: float) -> float:
    """Convert a [0, 1] sklearn probability to a [0, 100] percentage."""
    return clamp_probability(raw_prob * 100.0)


# ---------------------------------------------------------------------------
# Risk classification
# ---------------------------------------------------------------------------

def classify_risk(pass_probability: float) -> RiskLevel:
    """Map a pass-probability percentage to a human-readable risk tier."""
    if pass_probability >= LOW_RISK_THRESHOLD:
        return "Low"
    if pass_probability >= MEDIUM_RISK_THRESHOLD:
        return "Medium"
    return "High"


# ---------------------------------------------------------------------------
# Metrics computation
# ---------------------------------------------------------------------------

def compute_metrics(
    y_true: Sequence[int],
    probabilities: Sequence[float],
) -> ModelMetrics:
    """
    Compute classification metrics from ground-truth labels and predicted probabilities.

    AUC is set to 50.0 when only one class is present in ``y_true`` (the
    metric is undefined in that case).

    Args:
        y_true:        Ground-truth binary labels (0 / 1).
        probabilities: Predicted positive-class probabilities in [0, 1].

    Returns:
        A :class:`ModelMetrics` instance with all scores expressed as
        percentages (0–100).
    """
    y_arr = np.asarray(y_true, dtype=int)
    p_arr = np.asarray(probabilities, dtype=float)
    predicted = (p_arr >= PASS_PROBABILITY_THRESHOLD).astype(int)

    def pct(value: float) -> float:
        return round(float(value) * 100.0, 2)

    auc: float
    if len(np.unique(y_arr)) > 1:
        auc = pct(roc_auc_score(y_arr, p_arr))
    else:
        logger.warning(
            "Only one class present in y_true — AUC is undefined, defaulting to 50.0"
        )
        auc = 50.0

    return ModelMetrics(
        accuracy=pct(accuracy_score(y_arr, predicted)),
        precision=pct(precision_score(y_arr, predicted, zero_division=0)),
        recall=pct(recall_score(y_arr, predicted, zero_division=0)),
        f1=pct(f1_score(y_arr, predicted, zero_division=0)),
        auc=auc,
    )


# ---------------------------------------------------------------------------
# Input parsing / validation
# ---------------------------------------------------------------------------

def validate_payload(payload: dict) -> None:
    """
    Raise :class:`ValueError` with a descriptive message for any structural
    problem in the incoming JSON payload.
    """
    if not isinstance(payload, dict):
        raise ValueError("Payload must be a JSON object.")

    training = payload.get("training_samples")
    if not isinstance(training, list):
        raise ValueError("'training_samples' must be a JSON array.")

    prediction = payload.get("prediction_samples")
    if not isinstance(prediction, list):
        raise ValueError("'prediction_samples' must be a JSON array.")
