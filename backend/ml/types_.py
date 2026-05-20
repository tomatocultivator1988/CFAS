"""
Compatibility exports for the modular ML pipeline.

The typed DTOs live in domain.py. Some pipeline modules still import the old
types_ module name, so this shim keeps direct test runs and future imports
working without duplicating the data model.
"""
from domain import (
    FeatureVector,
    ModelKey,
    ModelMetrics,
    PipelineResult,
    PredictionSample,
    RiskLevel,
    StudentPrediction,
    TrainingSample,
)

__all__ = [
    "FeatureVector",
    "ModelKey",
    "ModelMetrics",
    "PipelineResult",
    "PredictionSample",
    "RiskLevel",
    "StudentPrediction",
    "TrainingSample",
]
