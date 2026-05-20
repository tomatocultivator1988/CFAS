# Student Pass-Prediction Pipeline

A professional-grade, modular ML pipeline for predicting student exam pass probability.

---

## Architecture

```
ml_pipeline/
├── config.py       — All constants, hyperparameters, and thresholds in one place
├── types_.py       — Immutable typed dataclasses for inputs and outputs (no raw dicts)
├── utils.py        — Pure, stateless helper functions (fully unit-testable)
├── models.py       — Estimator construction, cross-validated training, ensemble
├── prediction.py   — Inference layer: ML and heuristic fallback
├── pipeline.py     — Orchestrator: parse → guard → train → predict → serialise
└── tests.py        — Unit + integration test suite (pytest)
```

---

## Key improvements over v1

| Area | v1 | This version |
|---|---|---|
| **Evaluation** | Single 75/25 split | Stratified k-fold CV — unbiased, no data leakage |
| **Model selection** | Compared on a shared test split (leakage) | CV OOF probabilities only |
| **Class imbalance** | Not addressed | `class_weight="balanced"` on LR; `balanced_subsample` on RF |
| **Probability calibration** | None | Isotonic regression on RF via `CalibratedClassifierCV` |
| **Type safety** | Raw dicts everywhere | Frozen dataclasses; `from_dict` factory methods |
| **Separation of concerns** | Single 200-line `main()` | Five single-responsibility modules |
| **Logging** | `print()` to stdout mixed with output | `logging` to stderr; stdout is JSON only |
| **Fallback transparency** | Metrics look like ML metrics | Clearly labelled `heuristic_fallback`; metrics are `None` |
| **Feature importances** | Not exposed | RF importances surfaced in response |
| **Tests** | None | 30+ unit and integration tests |
| **Input validation** | Minimal | `validate_payload` + label range check + typed constructors |

---

## Interface

### Input (stdin JSON)

```json
{
  "model": "ensemble",
  "training_samples": [
    {
      "student_id": 1,
      "label": 1,
      "features": {
        "attempt_count": 5,
        "avg_score": 74.2,
        "min_score": 58.0,
        "max_score": 89.0,
        "latest_score": 80.0,
        "recent_avg_score": 77.5,
        "score_trend": 8.0,
        "score_stddev": 9.1,
        "pass_rate": 80.0,
        "avg_passing_score": 78.3,
        "unique_exam_count": 3,
        "days_span": 45
      }
    }
  ],
  "prediction_samples": [
    {
      "student_id": 42,
      "features": { "...": "..." }
    }
  ]
}
```

`model` must be one of: `logistic_regression`, `random_forest`, `ensemble` (default).

### Output (stdout JSON)

```json
{
  "success": true,
  "model": "ensemble",
  "metrics": {
    "model_type": "ensemble",
    "evaluation_method": "stratified_k_fold_cross_validation",
    "best_model_by_f1": "random_forest",
    "training_samples": 80,
    "logistic_regression": { "accuracy": 78.5, "f1": 76.2, "auc": 83.1, "..." : "..." },
    "random_forest":        { "accuracy": 81.0, "f1": 79.5, "auc": 86.3, "..." : "..." },
    "ensemble":             { "accuracy": 82.5, "f1": 80.1, "auc": 87.0, "..." : "..." },
    "accuracy": 82.5,
    "f1": 80.1,
    "auc": 87.0,
    "feature_importances": { "avg_score": 0.2341, "pass_rate": 0.1987, "..." : "..." }
  },
  "predictions": [
    {
      "student_id": 42,
      "pass_probability": 73.4,
      "fail_probability": 26.6,
      "risk_level": "Medium",
      "model_used": "ensemble",
      "logistic_probability": 71.2,
      "random_forest_probability": 75.6
    }
  ]
}
```

---

## Running

```bash
# Inference
echo '{"model":"ensemble","training_samples":[...],"prediction_samples":[...]}' \
  | python pipeline.py

# Tests
pip install pytest scikit-learn numpy
pytest tests.py -v
```

---

## Fallback behaviour

The heuristic fallback activates when:
- Fewer than 12 training samples are provided, **or**
- All training labels belong to a single class.

Fallback responses are clearly marked with `"model_type": "heuristic_fallback"` and
`null` metric values so callers are never misled by spurious accuracy numbers.

---

## Feature reference

| Feature | Description |
|---|---|
| `attempt_count` | Total number of exam attempts |
| `avg_score` | Mean score across all attempts (0–100) |
| `min_score` | Lowest score recorded |
| `max_score` | Highest score recorded |
| `latest_score` | Most recent attempt score |
| `recent_avg_score` | Average of the last N attempts |
| `score_trend` | Linear slope of score over time (−100 to +100) |
| `score_stddev` | Standard deviation of scores |
| `pass_rate` | Fraction of attempts that were passing (0–100) |
| `avg_passing_score` | Mean score on passing attempts only |
| `unique_exam_count` | Number of distinct exams attempted |
| `days_span` | Days between first and most recent attempt |