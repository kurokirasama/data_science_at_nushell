#!/usr/bin/env python
"""Multi-model classification benchmark for Nushell pipelines."""
import argparse
import json
import os
import sys
import time
import warnings

os.environ.setdefault("OMP_NUM_THREADS", "4")
os.environ.setdefault("PYTHONWARNINGS", "ignore")
warnings.filterwarnings("ignore")

import lightgbm as lgb
import pandas as pd
from sklearn.compose import ColumnTransformer
from sklearn.ensemble import RandomForestClassifier
from sklearn.linear_model import LogisticRegression
from sklearn.metrics import (
    accuracy_score,
    f1_score,
    precision_score,
    recall_score,
)
from sklearn.model_selection import train_test_split
from sklearn.neural_network import MLPClassifier
from sklearn.pipeline import Pipeline
from sklearn.preprocessing import (
    LabelEncoder,
    OneHotEncoder,
    StandardScaler,
)
from sklearn.svm import LinearSVC


def build_registry(prep_scaled, prep_tree, seed):
    return {
        "logistic": Pipeline([
            ("prep", prep_scaled),
            ("clf", LogisticRegression(
                max_iter=1000, random_state=seed
            )),
        ]),
        "rf": Pipeline([
            ("prep", prep_tree),
            ("clf", RandomForestClassifier(
                n_estimators=100, random_state=seed, n_jobs=4
            )),
        ]),
        "lgbm": Pipeline([
            ("prep", prep_tree),
            ("clf", lgb.LGBMClassifier(
                n_estimators=100, learning_rate=0.05,
                num_leaves=31, random_state=seed,
                verbosity=-1, n_jobs=4,
            )),
        ]),
        "linear_svc": Pipeline([
            ("prep", prep_scaled),
            ("clf", LinearSVC(
                dual=False, max_iter=2000, random_state=seed
            )),
        ]),
        "mlp": Pipeline([
            ("prep", prep_scaled),
            ("clf", MLPClassifier(
                hidden_layer_sizes=(64, 32), max_iter=300,
                early_stopping=True, n_iter_no_change=10,
                random_state=seed,
            )),
        ]),
    }


def main():
    p = argparse.ArgumentParser(
        description="Multi-model classification benchmark."
    )
    p.add_argument("--input", "-i", type=str, default="-")
    p.add_argument("--target", "-t", type=str, default="type")
    p.add_argument(
        "--models", "-m", type=str,
        default="logistic,rf,lgbm,linear_svc,mlp",
    )
    p.add_argument("--test-size", type=float, default=0.25)
    p.add_argument("--seed", "-s", type=int, default=42)
    args = p.parse_args()

    src = sys.stdin if args.input == "-" else args.input
    df = pd.read_csv(src)
    if args.target not in df.columns:
        msg = f"Error: Target '{args.target}' not found.\n"
        sys.stderr.write(msg)
        sys.exit(1)

    X = df.drop(columns=[args.target])
    y = LabelEncoder().fit_transform(df[args.target].astype(str))
    num_c = [
        c for c in X.columns if pd.api.types.is_numeric_dtype(X[c])
    ]
    cat_c = [c for c in X.columns if c not in num_c]

    ohe_s = OneHotEncoder(handle_unknown="ignore")
    ohe_d = OneHotEncoder(
        handle_unknown="ignore", sparse_output=False
    )
    prep_scaled = ColumnTransformer(
        [("num", StandardScaler(), num_c), ("cat", ohe_s, cat_c)],
        remainder="drop",
    )
    prep_tree = ColumnTransformer(
        [("num", "passthrough", num_c), ("cat", ohe_d, cat_c)],
        remainder="drop",
    )

    X_tr, X_te, y_tr, y_te = train_test_split(
        X, y, test_size=args.test_size,
        random_state=args.seed, stratify=y,
    )
    parts = args.models.split(",")
    req = [m.strip().lower() for m in parts if m.strip()]
    reg = build_registry(prep_scaled, prep_tree, args.seed)

    rows = []
    for name in req:
        if name not in reg:
            continue
        pipe = reg[name]
        t0 = time.perf_counter()
        pipe.fit(X_tr, y_tr)
        fit_ms = round((time.perf_counter() - t0) * 1000.0, 2)
        preds = pipe.predict(X_te)
        kw = {"average": "weighted", "zero_division": 0}
        rows.append({
            "model": name,
            "accuracy": round(float(accuracy_score(y_te, preds)), 4),
            "precision": round(
                float(precision_score(y_te, preds, **kw)), 4
            ),
            "recall": round(
                float(recall_score(y_te, preds, **kw)), 4
            ),
            "f1_score": round(float(f1_score(y_te, preds, **kw)), 4),
            "train_time_ms": fit_ms,
        })

    rows.sort(key=lambda r: r["f1_score"], reverse=True)
    print(json.dumps(rows))


if __name__ == "__main__":
    main()
