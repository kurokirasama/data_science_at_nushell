#!/usr/bin/env python
"""
Multi-model classification benchmark for streaming Nushell tabular pipelines.
Evaluates LogisticRegression, RandomForest, LightGBM, LinearSVC, and MLPClassifier.
Outputs JSON records with accuracy, precision, recall, macro F1, and training time.
"""
import argparse
import json
import os
import sys
import time
import warnings

os.environ.setdefault("PYTHONWARNINGS", "ignore")
warnings.filterwarnings("ignore")

import numpy as np
import pandas as pd
from sklearn.compose import ColumnTransformer
from sklearn.ensemble import RandomForestClassifier
from sklearn.linear_model import LogisticRegression
from sklearn.metrics import accuracy_score, f1_score, precision_score, recall_score
from sklearn.model_selection import train_test_split
from sklearn.neural_network import MLPClassifier
from sklearn.pipeline import Pipeline
from sklearn.preprocessing import LabelEncoder, OneHotEncoder, StandardScaler
from sklearn.svm import LinearSVC
import lightgbm as lgb


def main():
    parser = argparse.ArgumentParser(description="Multi-model classification benchmark.")
    parser.add_argument("--input", "-i", type=str, default="-", help="Input CSV path or '-' for stdin")
    parser.add_argument("--target", "-t", type=str, default="type", help="Target column name")
    parser.add_argument("--models", "-m", type=str, default="logistic,rf,lgbm,linear_svc,mlp",
                        help="Comma-separated model names")
    parser.add_argument("--test-size", type=float, default=0.25, help="Test partition ratio")
    parser.add_argument("--seed", "-s", type=int, default=42, help="Random seed")

    args = parser.parse_args()

    input_src = sys.stdin if args.input == "-" else args.input
    df = pd.read_csv(input_src)

    if args.target not in df.columns:
        sys.stderr.write(f"Error: Target column '{args.target}' not found.\n")
        sys.exit(1)

    X = df.drop(columns=[args.target])
    le = LabelEncoder()
    y = le.fit_transform(df[args.target].astype(str))

    num_cols = [c for c in X.columns if pd.api.types.is_numeric_dtype(X[c])]
    cat_cols = [c for c in X.columns if c not in num_cols]

    prep_scaled = ColumnTransformer(
        transformers=[
            ("num", StandardScaler(), num_cols),
            ("cat", OneHotEncoder(handle_unknown="ignore"), cat_cols),
        ],
        remainder="drop",
    )
    prep_tree = ColumnTransformer(
        transformers=[
            ("num", "passthrough", num_cols),
            ("cat", OneHotEncoder(handle_unknown="ignore", sparse_output=False), cat_cols),
        ],
        remainder="drop",
    )

    X_train, X_test, y_train, y_test = train_test_split(
        X, y, test_size=args.test_size, random_state=args.seed, stratify=y
    )

    requested = [m.strip().lower() for m in args.models.split(",") if m.strip()]

    registry = {
        "logistic": Pipeline([
            ("prep", prep_scaled),
            ("clf", LogisticRegression(max_iter=1000, random_state=args.seed)),
        ]),
        "rf": Pipeline([
            ("prep", prep_tree),
            ("clf", RandomForestClassifier(n_estimators=100, random_state=args.seed, n_jobs=-1)),
        ]),
        "lgbm": Pipeline([
            ("prep", prep_tree),
            ("clf", lgb.LGBMClassifier(n_estimators=100, learning_rate=0.05, num_leaves=31,
                                       random_state=args.seed, verbosity=-1, n_jobs=-1)),
        ]),
        "linear_svc": Pipeline([
            ("prep", prep_scaled),
            ("clf", LinearSVC(dual=False, max_iter=2000, random_state=args.seed)),
        ]),
        "mlp": Pipeline([
            ("prep", prep_scaled),
            ("clf", MLPClassifier(hidden_layer_sizes=(64, 32), max_iter=300,
                                  early_stopping=True, n_iter_no_change=10, random_state=args.seed)),
        ]),
    }

    rows = []
    for model_name in requested:
        if model_name not in registry:
            continue
        pipe = registry[model_name]
        t0 = time.perf_counter()
        pipe.fit(X_train, y_train)
        fit_time_ms = round((time.perf_counter() - t0) * 1000.0, 2)

        t1 = time.perf_counter()
        preds = pipe.predict(X_test)
        infer_time_ms = round((time.perf_counter() - t1) * 1000.0, 2)

        acc = round(float(accuracy_score(y_test, preds)), 4)
        f1 = round(float(f1_score(y_test, preds, average="weighted", zero_division=0)), 4)
        prec = round(float(precision_score(y_test, preds, average="weighted", zero_division=0)), 4)
        rec = round(float(recall_score(y_test, preds, average="weighted", zero_division=0)), 4)

        results_row = {
            "model": model_name,
            "accuracy": acc,
            "precision": prec,
            "recall": rec,
            "f1_score": f1,
            "train_time_ms": fit_time_ms,
        }
        rows.append(results_row)

    rows.sort(key=lambda r: r["f1_score"], reverse=True)
    print(json.dumps(rows))


if __name__ == "__main__":
    main()
