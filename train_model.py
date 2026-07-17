"""Train the predictive-maintenance anomaly model."""

from __future__ import annotations

import argparse
from pathlib import Path

import joblib
import pandas as pd
from sklearn.compose import ColumnTransformer
from sklearn.linear_model import LogisticRegression
from sklearn.metrics import average_precision_score, f1_score, precision_score, recall_score, roc_auc_score
from sklearn.model_selection import train_test_split
from sklearn.pipeline import Pipeline
from sklearn.preprocessing import StandardScaler

FEATURES = [
    "Air temperature",
    "Process temperature",
    "Rotational speed",
    "Torque",
    "Tool wear",
]
TARGET = "Machine failure"


def parse_arguments() -> argparse.Namespace:
    parser = argparse.ArgumentParser(description="Train the anomaly detection model.")
    parser.add_argument("--data", default="predictive_maintenance.csv", help="Path to the training CSV file.")
    parser.add_argument("--model-path", default="models/anomaly_model.joblib", help="Output path for the trained model.")
    parser.add_argument("--threshold", type=float, default=0.30, help="Probability threshold for anomaly alerts.")
    return parser.parse_args()


def main() -> None:
    args = parse_arguments()
    if not 0 < args.threshold < 1:
        raise ValueError("--threshold must be between 0 and 1.")

    data = pd.read_csv(args.data)
    required_columns = set(FEATURES + [TARGET])
    missing_columns = required_columns.difference(data.columns)
    if missing_columns:
        raise ValueError(f"Dataset is missing required columns: {sorted(missing_columns)}")

    features = data[FEATURES]
    target = data[TARGET]
    x_train, x_test, y_train, y_test = train_test_split(
        features, target, test_size=0.20, random_state=42, stratify=target
    )

    model = Pipeline(
        steps=[
            ("scaler", ColumnTransformer([( "numeric", StandardScaler(), FEATURES)])),
            ("classifier", LogisticRegression(class_weight="balanced", max_iter=1000, random_state=42)),
        ]
    )
    model.fit(x_train, y_train)

    probabilities = model.predict_proba(x_test)[:, 1]
    predictions = (probabilities >= args.threshold).astype(int)
    metrics = {
        "roc_auc": roc_auc_score(y_test, probabilities),
        "average_precision": average_precision_score(y_test, probabilities),
        "precision": precision_score(y_test, predictions, zero_division=0),
        "recall": recall_score(y_test, predictions, zero_division=0),
        "f1": f1_score(y_test, predictions, zero_division=0),
    }

    model_path = Path(args.model_path)
    model_path.parent.mkdir(parents=True, exist_ok=True)
    joblib.dump({"model": model, "features": FEATURES, "threshold": args.threshold}, model_path)

    print(f"Model saved to: {model_path}")
    print("Metrics:")
    for metric_name, metric_value in metrics.items():
        print(f"  {metric_name}: {metric_value:.4f}")


if __name__ == "__main__":
    main()