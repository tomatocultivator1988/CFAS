"""
Configuration constants and feature registry for the student pass-prediction pipeline.
"""
from __future__ import annotations

from dataclasses import dataclass, field
from typing import Final

# ---------------------------------------------------------------------------
# Feature registry
# ---------------------------------------------------------------------------

FEATURE_KEYS: Final[list[str]] = [
    "attempt_count",
    "avg_score",
    "min_score",
    "max_score",
    "latest_score",
    "recent_avg_score",
    "score_trend",
    "score_stddev",
    "pass_rate",
    "avg_passing_score",
    "unique_exam_count",
    "days_span",
]

FEATURE_DESCRIPTIONS: Final[dict[str, str]] = {
    "attempt_count":      "Total number of exam attempts",
    "avg_score":          "Mean score across all attempts (0–100)",
    "min_score":          "Lowest score recorded",
    "max_score":          "Highest score recorded",
    "latest_score":       "Most recent attempt score",
    "recent_avg_score":   "Average of the last N attempts",
    "score_trend":        "Linear slope of score over time (−100 to +100)",
    "score_stddev":       "Standard deviation of scores (consistency proxy)",
    "pass_rate":          "Fraction of attempts that were passing (0–100)",
    "avg_passing_score":  "Mean score on passing attempts only",
    "unique_exam_count":  "Number of distinct exams attempted",
    "days_span":          "Days between first and most recent attempt",
}

# ---------------------------------------------------------------------------
# Modelling constants
# ---------------------------------------------------------------------------

MINIMUM_TRAINING_SAMPLES: Final[int] = 12
MINIMUM_CLASS_COUNT: Final[int] = 2
TEST_SET_FRACTION: Final[float] = 0.25
RANDOM_STATE: Final[int] = 42

PASS_PROBABILITY_THRESHOLD: Final[float] = 0.50  # decision boundary
LOW_RISK_THRESHOLD: Final[float] = 75.0
MEDIUM_RISK_THRESHOLD: Final[float] = 45.0

SUPPORTED_MODELS: Final[frozenset[str]] = frozenset(
    {"logistic_regression", "random_forest", "ensemble"}
)
DEFAULT_MODEL: Final[str] = "ensemble"

# ---------------------------------------------------------------------------
# Random-forest hyperparameters
# ---------------------------------------------------------------------------

RF_N_ESTIMATORS: Final[int] = 250
RF_MAX_DEPTH: Final[int] = 8
RF_MIN_SAMPLES_LEAF: Final[int] = 2

# ---------------------------------------------------------------------------
# Logistic-regression hyperparameters
# ---------------------------------------------------------------------------

LR_MAX_ITER: Final[int] = 1_200


# ---------------------------------------------------------------------------
# Heuristic weights (fallback model)
# ---------------------------------------------------------------------------

@dataclass(frozen=True)
class HeuristicWeights:
    pass_rate: float = 0.50
    avg_score: float = 0.45
    trend:     float = 0.05

HEURISTIC_WEIGHTS: Final[HeuristicWeights] = HeuristicWeights()
