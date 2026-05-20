"""
Model construction, training, cross-validation, and inference.

Responsibilities
----------------
* Build sklearn estimators with well-documented hyperparameters.
* Train on the full training set after cross-validated evaluation.
* Expose a clean :class:`TrainedEnsemble` object so the caller never touches
  raw sklearn internals.
"""
from __future__ import annotations

import logging
from dataclasses import dataclass
from typing import Optional

import numpy as np
from sklearn.calibration import CalibratedClassifierCV
from sklearn.ensemble import RandomForestClassifier
from sklearn.linear_model import LogisticRegression
from sklearn.model_selection import StratifiedKFold, cross_val_predict
from sklearn.pipeline import Pipeline
from sklearn.preprocessing import StandardScaler

from config import (
    LR_MAX_ITER,
    RANDOM_STATE,
    RF_MAX_DEPTH,
    RF_MIN_SAMPLES_LEAF,
    RF_N_ESTIMATORS,
    TEST_SET_FRACTION,
)
from types_ import ModelMetrics
from utils import compute_metrics

logger = logging.getLogger(__name__)

# Number of CV folds used for out-of-fold metric estimation.
CV_FOLDS: int = 5


# ---------------------------------------------------------------------------
# Estimator factories
# ---------------------------------------------------------------------------

def _build_logistic_regression() -> Pipeline:
    """
    Logistic regression wrapped in a standard scaler.

    The scaler is fitted inside the pipeline to prevent data leakage across
    cross-validation folds.
    """
    return Pipeline([
        ("scaler", StandardScaler()),
        ("classifier", LogisticRegression(
            max_iter=LR_MAX_ITER,
            random_state=RANDOM_STATE,
            class_weight="balanced",   # handles class imbalance
            solver="lbfgs",
        )),
    ])


def _build_random_forest() -> CalibratedClassifierCV:
    """
    Random forest wrapped in isotonic-regression probability calibration.

    Raw RF probabilities are often over-confident; calibration corrects the
    probability estimates without hurting discrimination.
    """
    base = RandomForestClassifier(
        n_estimators=RF_N_ESTIMATORS,
        max_depth=RF_MAX_DEPTH,
        min_samples_leaf=RF_MIN_SAMPLES_LEAF,
        class_weight="balanced_subsample",
        random_state=RANDOM_STATE,
        n_jobs=-1,
    )
    return CalibratedClassifierCV(base, method="isotonic", cv=3)


# ---------------------------------------------------------------------------
# Trained ensemble container
# ---------------------------------------------------------------------------

@dataclass
class TrainedEnsemble:
    """
    Holds fitted estimators and their cross-validated performance metrics.

    This object is the single output of :func:`train_ensemble` and is the
    only thing the prediction layer needs.
    """
    logistic_model: Pipeline
    random_forest_model: CalibratedClassifierCV

    # Out-of-fold metrics (unbiased estimates)
    logistic_metrics:      ModelMetrics
    random_forest_metrics: ModelMetrics
    ensemble_metrics:      ModelMetrics

    # Which model had the best F1 on the CV evaluation
    best_model_by_f1: str

    # Feature importances (RF only — LR uses coefficients)
    feature_importances: Optional[np.ndarray] = None

    def predict_proba_logistic(self, x: np.ndarray) -> np.ndarray:
        return self.logistic_model.predict_proba(x)[:, 1]

    def predict_proba_random_forest(self, x: np.ndarray) -> np.ndarray:
        return self.random_forest_model.predict_proba(x)[:, 1]

    def predict_proba_ensemble(self, x: np.ndarray) -> np.ndarray:
        lr  = self.predict_proba_logistic(x)
        rf  = self.predict_proba_random_forest(x)
        return (lr + rf) / 2.0


# ---------------------------------------------------------------------------
# Training entry-point
# ---------------------------------------------------------------------------

def train_ensemble(
    x: np.ndarray,
    y: np.ndarray,
) -> TrainedEnsemble:
    """
    Train logistic regression and random forest on *all* training data,
    using stratified k-fold cross-validation to produce unbiased metric
    estimates.

    Cross-validation is used for evaluation; the final models are then
    re-fitted on the complete training set so they benefit from all data
    at inference time.

    Args:
        x: Feature matrix of shape (n_samples, n_features).
        y: Binary label vector of shape (n_samples,).

    Returns:
        A :class:`TrainedEnsemble` ready for inference.
    """
    cv = StratifiedKFold(n_splits=CV_FOLDS, shuffle=True, random_state=RANDOM_STATE)

    lr_model = _build_logistic_regression()
    rf_model = _build_random_forest()

    logger.info("Running %d-fold cross-validation for logistic regression …", CV_FOLDS)
    lr_oof_probs = cross_val_predict(lr_model, x, y, cv=cv, method="predict_proba")[:, 1]

    logger.info("Running %d-fold cross-validation for random forest …", CV_FOLDS)
    rf_oof_probs = cross_val_predict(rf_model, x, y, cv=cv, method="predict_proba")[:, 1]

    ensemble_oof_probs = (lr_oof_probs + rf_oof_probs) / 2.0

    lr_metrics  = compute_metrics(y.tolist(), lr_oof_probs.tolist())
    rf_metrics  = compute_metrics(y.tolist(), rf_oof_probs.tolist())
    ens_metrics = compute_metrics(y.tolist(), ensemble_oof_probs.tolist())

    best = max(
        [("logistic_regression", lr_metrics), ("random_forest", rf_metrics), ("ensemble", ens_metrics)],
        key=lambda pair: pair[1].f1,
    )[0]
    logger.info("Best model by CV F1: %s", best)

    logger.info("Fitting final models on full training set …")
    lr_model.fit(x, y)
    rf_model.fit(x, y)

    # Extract feature importances from the underlying RF estimator inside
    # the calibrated wrapper.
    importances: Optional[np.ndarray] = None
    try:
        importances = rf_model.estimator.feature_importances_
    except AttributeError:
        logger.debug("Could not extract feature importances from calibrated RF.")

    return TrainedEnsemble(
        logistic_model=lr_model,
        random_forest_model=rf_model,
        logistic_metrics=lr_metrics,
        random_forest_metrics=rf_metrics,
        ensemble_metrics=ens_metrics,
        best_model_by_f1=best,
        feature_importances=importances,
    )