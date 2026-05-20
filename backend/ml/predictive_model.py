import json
import math
import sys
import traceback
from collections import Counter

import numpy as np
from sklearn.ensemble import RandomForestClassifier
from sklearn.linear_model import LogisticRegression
from sklearn.metrics import accuracy_score, f1_score, precision_score, recall_score, roc_auc_score
from sklearn.model_selection import train_test_split
from sklearn.pipeline import Pipeline
from sklearn.preprocessing import StandardScaler


FEATURE_KEYS = [
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


def clamp_probability(value: float) -> float:
    return max(0.0, min(100.0, round(value, 2)))


def risk_level(pass_probability: float) -> str:
    if pass_probability >= 75:
        return "Low"
    if pass_probability >= 45:
        return "Medium"
    return "High"


def vectorize(features: dict) -> list:
    return [float(features.get(key, 0.0)) for key in FEATURE_KEYS]


def compute_metrics(y_true, probabilities):
    predicted = [1 if value >= 0.5 else 0 for value in probabilities]
    metrics = {
        "accuracy": round(float(accuracy_score(y_true, predicted)) * 100, 2),
        "precision": round(float(precision_score(y_true, predicted, zero_division=0)) * 100, 2),
        "recall": round(float(recall_score(y_true, predicted, zero_division=0)) * 100, 2),
        "f1": round(float(f1_score(y_true, predicted, zero_division=0)) * 100, 2),
    }

    unique_labels = set(y_true)
    if len(unique_labels) > 1:
        metrics["auc"] = round(float(roc_auc_score(y_true, probabilities)) * 100, 2)
    else:
        metrics["auc"] = 50.0

    return metrics


def build_fallback(training_samples, prediction_samples, requested_model):
    labels = [int(sample.get("label", 0)) for sample in training_samples]
    positive = sum(labels)
    total = len(labels)
    baseline = (positive / total) if total > 0 else 0.5
    baseline_pct = clamp_probability(baseline * 100)

    predictions = []
    for sample in prediction_samples:
        student_id = int(sample.get("student_id", 0))
        features = sample.get("features", {})
        pass_rate = float(features.get("pass_rate", baseline_pct))
        avg_score = float(features.get("avg_score", baseline_pct))
        trend = float(features.get("score_trend", 0))
        heuristic = (0.5 * pass_rate) + (0.45 * avg_score) + (0.05 * (trend + 50))
        probability = clamp_probability(heuristic / 100.0 * 100.0)
        predictions.append({
            "student_id": student_id,
            "pass_probability": probability,
            "fail_probability": clamp_probability(100 - probability),
            "risk_level": risk_level(probability),
            "model_used": "heuristic",
            "logistic_probability": probability,
            "random_forest_probability": probability,
        })

    return {
        "success": True,
        "model": requested_model,
        "metrics": {
            "model_type": "heuristic_fallback",
            "training_samples": total,
            "class_balance_pass_rate": baseline_pct,
            "accuracy": baseline_pct,
            "precision": baseline_pct,
            "recall": baseline_pct,
            "f1": baseline_pct,
            "auc": 50.0,
        },
        "predictions": predictions,
    }


def main():
    payload = json.load(sys.stdin)
    requested_model = payload.get("model", "random_forest")
    training_samples = payload.get("training_samples", [])
    prediction_samples = payload.get("prediction_samples", [])

    if len(training_samples) < 12:
        print(json.dumps(build_fallback(training_samples, prediction_samples, requested_model)))
        return

    labels = [int(sample.get("label", 0)) for sample in training_samples]
    if len(set(labels)) < 2:
        print(json.dumps(build_fallback(training_samples, prediction_samples, requested_model)))
        return

    class_counts = Counter(labels)
    if min(class_counts.values()) < 2:
        print(json.dumps(build_fallback(training_samples, prediction_samples, requested_model)))
        return

    x_train_data = np.array([vectorize(sample.get("features", {})) for sample in training_samples], dtype=float)
    y_train_data = np.array(labels, dtype=int)
    x_predict_data = np.array([vectorize(sample.get("features", {})) for sample in prediction_samples], dtype=float) if prediction_samples else np.empty((0, len(FEATURE_KEYS)))

    stratify_target = y_train_data if len(set(y_train_data.tolist())) > 1 else None
    x_train, x_test, y_train, y_test = train_test_split(
        x_train_data,
        y_train_data,
        test_size=0.25,
        random_state=42,
        stratify=stratify_target,
    )

    logistic_model = Pipeline([
        ("scaler", StandardScaler()),
        ("model", LogisticRegression(max_iter=1200, random_state=42, class_weight="balanced")),
    ])

    random_forest_model = RandomForestClassifier(
        n_estimators=250,
        max_depth=8,
        min_samples_leaf=2,
        class_weight="balanced_subsample",
        random_state=42,
    )

    logistic_model.fit(x_train, y_train)
    random_forest_model.fit(x_train, y_train)

    logistic_probs_test = logistic_model.predict_proba(x_test)[:, 1]
    random_forest_probs_test = random_forest_model.predict_proba(x_test)[:, 1]
    ensemble_probs_test = (logistic_probs_test + random_forest_probs_test) / 2.0

    logistic_metrics = compute_metrics(y_test, logistic_probs_test)
    random_forest_metrics = compute_metrics(y_test, random_forest_probs_test)
    ensemble_metrics = compute_metrics(y_test, ensemble_probs_test)

    model_key = requested_model if requested_model in ["logistic_regression", "random_forest", "ensemble"] else "ensemble"
    model_lookup = {
        "logistic_regression": logistic_metrics,
        "random_forest": random_forest_metrics,
        "ensemble": ensemble_metrics,
    }

    best_model_by_f1 = max(model_lookup.items(), key=lambda pair: pair[1]["f1"])[0]

    predictions = []
    if len(prediction_samples) > 0:
        logistic_pred = logistic_model.predict_proba(x_predict_data)[:, 1]
        random_forest_pred = random_forest_model.predict_proba(x_predict_data)[:, 1]
        ensemble_pred = (logistic_pred + random_forest_pred) / 2.0

        for index, sample in enumerate(prediction_samples):
            logistic_probability = clamp_probability(float(logistic_pred[index]) * 100.0)
            random_forest_probability = clamp_probability(float(random_forest_pred[index]) * 100.0)
            ensemble_probability = clamp_probability(float(ensemble_pred[index]) * 100.0)

            if model_key == "logistic_regression":
                selected_probability = logistic_probability
            elif model_key == "random_forest":
                selected_probability = random_forest_probability
            else:
                selected_probability = ensemble_probability

            predictions.append({
                "student_id": int(sample.get("student_id", 0)),
                "pass_probability": selected_probability,
                "fail_probability": clamp_probability(100 - selected_probability),
                "risk_level": risk_level(selected_probability),
                "model_used": model_key,
                "logistic_probability": logistic_probability,
                "random_forest_probability": random_forest_probability,
            })

    output = {
        "success": True,
        "model": model_key,
        "metrics": {
            "model_type": model_key,
            "best_model_by_f1": best_model_by_f1,
            "training_samples": int(len(training_samples)),
            "test_samples": int(len(y_test)),
            "logistic_regression": logistic_metrics,
            "random_forest": random_forest_metrics,
            "ensemble": ensemble_metrics,
            "accuracy": model_lookup[model_key]["accuracy"],
            "precision": model_lookup[model_key]["precision"],
            "recall": model_lookup[model_key]["recall"],
            "f1": model_lookup[model_key]["f1"],
            "auc": model_lookup[model_key]["auc"],
        },
        "predictions": predictions,
    }
    print(json.dumps(output))


if __name__ == "__main__":
    try:
        main()
    except Exception as error:
        fallback = {
            "success": False,
            "message": str(error),
            "trace": traceback.format_exc(),
        }
        print(json.dumps(fallback))
        sys.exit(0)
