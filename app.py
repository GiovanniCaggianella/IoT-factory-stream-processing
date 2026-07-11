"""Flask REST API serving anomaly scores for factory sensor measurements."""

from __future__ import annotations

import os
from pathlib import Path
from typing import Any

import joblib
import pandas as pd
from flask import Flask, jsonify, request

DEFAULT_MODEL_PATH = "models/anomaly_model.joblib"


def load_model(model_path: str) -> dict[str, Any]:
    path = Path(model_path)
    if not path.exists():
        raise FileNotFoundError(f"Model not found at '{path}'. Run train_model.py first.")
    return joblib.load(path)


model_bundle = load_model(os.getenv("MODEL_PATH", DEFAULT_MODEL_PATH))
model = model_bundle["model"]
feature_names = model_bundle["features"]
threshold = float(os.getenv("ANOMALY_THRESHOLD", model_bundle["threshold"]))

app = Flask(__name__)


@app.get("/health")
def health() -> tuple[Any, int]:
    return jsonify(status="ok", model_features=feature_names, threshold=threshold), 200


@app.post("/predict")
def predict() -> tuple[Any, int]:
    payload = request.get_json(silent=True)
    if not isinstance(payload, dict):
        return jsonify(error="A JSON object is required."), 400

    missing_features = [feature for feature in feature_names if feature not in payload]
    if missing_features:
        return jsonify(error="Missing required features.", missing_features=missing_features), 400

    try:
        measurement = {feature: float(payload[feature]) for feature in feature_names}
    except (TypeError, ValueError):
        return jsonify(error="All feature values must be numeric."), 400

    score = float(model.predict_proba(pd.DataFrame([measurement]))[0, 1])
    return jsonify(
        anomaly_score=round(score, 6),
        is_anomaly=score >= threshold,
        threshold=threshold,
    ), 200


if __name__ == "__main__":
    app.run(host="0.0.0.0", port=int(os.getenv("PORT", "5001")), debug=False)