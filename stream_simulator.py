"""Replay CSV measurements as a continuous sensor stream to the Flask API."""

from __future__ import annotations

import argparse
import time

import pandas as pd
import requests

from train_model import FEATURES


def parse_arguments() -> argparse.Namespace:
    parser = argparse.ArgumentParser(description="Simulate a continuous factory sensor stream.")
    parser.add_argument("--data", default="predictive_maintenance.csv", help="Path to the input CSV.")
    parser.add_argument("--url", default="http://127.0.0.1:5001/predict", help="Prediction endpoint URL.")
    parser.add_argument("--interval", type=float, default=1.0, help="Seconds between sensor measurements.")
    parser.add_argument("--limit", type=int, default=0, help="Maximum rows to send; 0 sends all rows.")
    return parser.parse_args()


def main() -> None:
    args = parse_arguments()
    if args.interval < 0:
        raise ValueError("--interval cannot be negative.")

    data = pd.read_csv(args.data)
    rows = data[FEATURES]
    if args.limit > 0:
        rows = rows.head(args.limit)

    for sequence, (_, row) in enumerate(rows.iterrows(), start=1):
        payload = {feature: float(row[feature]) for feature in FEATURES}
        try:
            response = requests.post(args.url, json=payload, timeout=5)
            response.raise_for_status()
            result = response.json()
            print(
                f"measurement={sequence} score={result['anomaly_score']:.4f} "
                f"anomaly={result['is_anomaly']}"
            )
        except requests.RequestException as error:
            print(f"measurement={sequence} request failed: {error}")
        time.sleep(args.interval)


if __name__ == "__main__":
    main()