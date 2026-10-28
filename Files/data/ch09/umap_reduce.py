#!/usr/bin/env python
"""
Dimensionality reduction helper using UMAP and scikit-learn.
Reads CSV from file or stdin and outputs transformed CSV with umap_1, umap_2.
"""
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
    parser = argparse.ArgumentParser(description="UMAP dimensionality reduction on CSV input.")
    parser.add_argument("--input", "-i", type=str, default="-", help="Input CSV file path or '-' for stdin")
    parser.add_argument("--neighbors", "-n", type=int, default=15, help="Size of local neighborhood")
    parser.add_argument("--min-dist", "-m", type=float, default=0.1, help="Minimum effective distance")
    parser.add_argument("--target-dim", "-d", type=int, default=2, help="Number of embedding dimensions")
    parser.add_argument("--seed", "-s", type=int, default=42, help="Random seed")
    parser.add_argument("--label-col", "-l", type=str, default="type", help="Label column to preserve")
    parser.add_argument("--cols", "-c", type=str, default="", help="Comma-separated feature columns")

    args = parser.parse_args()

    input_src = sys.stdin if args.input == "-" else args.input
    df = pd.read_csv(input_src)

    if args.cols:
        num_cols = [c.strip() for c in args.cols.split(",") if c.strip() in df.columns]
    else:
        num_cols = [c for c in df.columns if c != args.label_col and pd.api.types.is_numeric_dtype(df[c])]

    if not num_cols:
        sys.stderr.write("Error: No numeric columns found for UMAP reduction.\n")
        sys.exit(1)

    X = StandardScaler().fit_transform(df[num_cols])
    n_neighbors = min(args.neighbors, max(2, len(df) - 1))
    reducer = umap.UMAP(
        n_neighbors=n_neighbors,
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
