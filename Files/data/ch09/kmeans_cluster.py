#!/usr/bin/env python3
"""Partition numeric columns via standardized K-Means clustering."""
import argparse
import sys
import pandas as pd
from sklearn.cluster import KMeans
from sklearn.preprocessing import StandardScaler


def main():
    p = argparse.ArgumentParser(description="K-Means CLI helper.")
    p.add_argument("--input", "-i", default="-")
    p.add_argument("--k", "-k", type=int, default=2)
    p.add_argument("--exclude", "-e", default="type")
    p.add_argument("--cols", "-c", default="")
    args = p.parse_args()

    src = sys.stdin if args.input == "-" else args.input
    df = pd.read_csv(src)

    if args.cols:
        num_cols = [
            c for c in args.cols.split(",") if c in df.columns
        ]
    else:
        excl = set(
            x.strip() for x in args.exclude.split(",") if x.strip()
        )
        excl.add("type")
        num_cols = [
            c for c in df.columns
            if c not in excl and pd.api.types.is_numeric_dtype(df[c])
        ]

    X = StandardScaler().fit_transform(df[num_cols])
    km = KMeans(n_clusters=args.k, n_init=10, random_state=42)
    labels = km.fit_predict(X)
    df["cluster"] = [f"cluster_{c + 1}" for c in labels]
    df.to_csv(sys.stdout, index=False)


if __name__ == "__main__":
    main()
