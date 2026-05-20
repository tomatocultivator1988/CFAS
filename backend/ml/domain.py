"""
Typed data-transfer objects for the student pass-prediction pipeline.

All public types are immutable dataclasses so downstream code can rely on
them being read-only without needing to defensive-copy.
"""
from __future__ import annotations

from dataclasses import dataclass, field
from typing import Any, Literal, Optional


# ---------------------------------------------------------------------------
# Input types
# ---------------------------------------------------------------------------

@dataclass(frozen=True)
class FeatureVector:
    """Raw feature dict extracted from a single student record."""
    attempt_count: float = 0.0
    avg_score: float = 0.0
    min_score: float = 0.0
    max_score: float = 0.0
    latest_score: float = 0.0
    recent_avg_score: float = 0.0
    score_trend: float = 0.0
    score_stddev: float = 0.0
    pass_rate: float = 0.0
    avg_passing_score: float = 0.0
    unique_exam_count: float = 0.0
    days_span: float = 0.0

    @classmethod
    def from_dict(cls, raw: dict[str, Any]) -> "FeatureVector":
        return cls(**{
            k: float(raw.get(k, 0.0))
            for k in cls.__dataclass_fields__
        })

    def to_list(self) -> list[float]:
        return [getattr(self, k) for k in self.__dataclass_fields__]


@dataclass(frozen=True)
class TrainingSample:
    student_id: int
    features: FeatureVector
    label: int  # 1 = pass, 0 = fail

    @classmethod
    def from_dict(cls, raw: dict[str, Any]) -> "TrainingSample":
        label = int(raw.get("label", 0))
        if label not in (0, 1):
            raise ValueError(
                f"student_id={raw.get('student_id')}: label must be 0 or 1, got {label!r}"
            )
        return cls(
            student_id=int(raw.get("student_id", 0)),
            features=FeatureVector.from_dict(raw.get("features", {})),
            label=label,
        )


@dataclass(frozen=True)
class PredictionSample:
    student_id: int
    features: FeatureVector

    @classmethod
    def from_dict(cls, raw: dict[str, Any]) -> "PredictionSample":
        return cls(
            student_id=int(raw.get("student_id", 0)),
            features=FeatureVector.from_dict(raw.get("features", {})),
        )


# ---------------------------------------------------------------------------
# Output types
# ---------------------------------------------------------------------------

RiskLevel = Literal["Low", "Medium", "High"]
ModelKey = Literal["logistic_regression", "random_forest", "ensemble", "heuristic"]


@dataclass(frozen=True)
class ModelMetrics:
    accuracy: float
    precision: float
    recall: float
    f1: float
    auc: float

    def to_dict(self) -> dict[str, float]:
        return {
            "accuracy":  self.accuracy,
            "precision": self.precision,
            "recall":    self.recall,
            "f1":        self.f1,
            "auc":       self.auc,
        }


@dataclass(frozen=True)
class StudentPrediction:
    student_id: int
    pass_probability: float
    fail_probability: float
    risk_level: RiskLevel
    model_used: ModelKey
    logistic_probability: float
    random_forest_probability: float

    def to_dict(self) -> dict[str, Any]:
        return {
            "student_id":                self.student_id,
            "pass_probability":          self.pass_probability,
            "fail_probability":          self.fail_probability,
            "risk_level":                self.risk_level,
            "model_used":                self.model_used,
            "logistic_probability":      self.logistic_probability,
            "random_forest_probability": self.random_forest_probability,
        }


@dataclass(frozen=True)
class PipelineResult:
    success: bool
    model: ModelKey
    metrics: dict[str, Any]
    predictions: list[StudentPrediction]
    error: Optional[str] = None

    def to_dict(self) -> dict[str, Any]:
        out: dict[str, Any] = {
            "success":     self.success,
            "model":       self.model,
            "metrics":     self.metrics,
            "predictions": [p.to_dict() for p in self.predictions],
        }
        if self.error:
            out["error"] = self.error
        return out
