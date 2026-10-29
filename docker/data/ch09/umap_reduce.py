#!/usr/bin/env python
"""UMAP manifold projection helper reading CSV from file or stdin."""
import argparse
import os
import sys
import warnings

os.environ.setdefault("NUMBA_CACHE_DIR", "/tmp/numba_cache")
warnings.filterwarnings("ignore")

import pandas as pd
from sklearn.preprocessing import StandardScaler
import umap


def main():
    p = argparse.ArgumentParser(
        description="UMAP reduction on CSV input."
    )
    p.add_argument("--input", "-i", type=str, default="-")
    p.add_argument("--neighbors", "-n", type=int, default=15)
    p.add_argument("--min-dist", "-m", type=float, default=0.1)
    p.add_argument("--target-dim", "-d", type=int, default=2)
    p.add_argument("--seed", "-s", type=int, default=42)
    p.add_argument("--label-col", "-l", type=str, default="type")
    p.add_argument("--cols", "-c", type=str, default="")
    args = p.parse_args()

    src = sys.stdin if args.input == "-" else args.input
    df = pd.read_csv(src)

    if args.cols:
        raw_c = [c.strip() for c in args.cols.split(",")]
        num_cols = [c for c in raw_c if c in df.columns]
    else:
        num_cols = [
            c for c in df.columns
            if c != args.label_col
            and pd.api.types.is_numeric_dtype(df[c])
        ]

    if not num_cols:
        sys.stderr.write("Error: No numeric columns found.\n")
        sys.exit(1)

    X = StandardScaler().fit_transform(df[num_cols])
    n_nb = min(args.neighbors, max(2, len(df) - 1))
    reducer = umap.UMAP(
        n_neighbors=n_nb,
        min_dist=args.min_dist,
        n_components=args.target_dim,
        random_state=args.seed,
    )
    emb = reducer.fit_transform(X)

    for idx in range(args.target_dim):
        df[f"umap_{idx + 1}"] = emb[:, idx].round(4)

    df.to_csv(sys.stdout, index=False)


if __name__ == "__main__":
    main()
