#!/opt/modern-ml/bin/python
"""Render K-Means inertia and silhouette curves (k = 2..10)."""
import os
import sys
import warnings

os.environ.setdefault("MPLCONFIGDIR", "/tmp/matplotlib_cache")
warnings.filterwarnings("ignore")

import matplotlib
matplotlib.use("Agg")
import matplotlib.pyplot as plt
import numpy as np
import pandas as pd
from sklearn.cluster import KMeans
from sklearn.metrics import silhouette_score
from sklearn.preprocessing import StandardScaler


def main():
    csv_in = sys.argv[1] if len(sys.argv) > 1 else "wine-both.csv"
    png_out = (
        sys.argv[2] if len(sys.argv) > 2 else "kmeans_elbow.png"
    )

    df = pd.read_csv(csv_in)
    drop_c = [c for c in ("type", "quality") if c in df.columns]
    num_df = df.drop(columns=drop_c).select_dtypes(
        include=[np.number]
    )
    X = StandardScaler().fit_transform(num_df)

    ks = list(range(2, 11))
    inertias, sils = [], []
    for k in ks:
        km = KMeans(n_clusters=k, n_init=10, random_state=42)
        labels = km.fit_predict(X)
        inertias.append(km.inertia_)
        sil = silhouette_score(
            X, labels, sample_size=1500, random_state=42
        )
        sils.append(sil)

    best_k = ks[int(np.argmax(sils))]
    fig, (ax1, ax2) = plt.subplots(
        1, 2, figsize=(10.5, 4.2), dpi=130
    )

    ax1.plot(ks, inertias, "o-", color="#0284c7", lw=2, ms=6)
    ax1.axvline(best_k, color="#be123c", ls="--", lw=1.2)
    ax1.set_title("Within-Cluster Inertia", fontweight="bold")
    ax1.set_xlabel("Number of Clusters (k)")
    ax1.set_ylabel("Inertia (WCSS)")
    ax1.set_xticks(ks)
    ax1.grid(True, ls="--", lw=0.4, alpha=0.5)

    ax2.plot(ks, sils, "s-", color="#0f766e", lw=2, ms=6)
    ax2.axvline(
        best_k, color="#be123c", ls="--", lw=1.2,
        label=f"Optimal k = {best_k}"
    )
    ax2.set_title("Mean Silhouette Score", fontweight="bold")
    ax2.set_xlabel("Number of Clusters (k)")
    ax2.set_ylabel("Silhouette Score")
    ax2.set_xticks(ks)
    ax2.legend(loc="best", frameon=True)
    ax2.grid(True, ls="--", lw=0.4, alpha=0.5)

    fig.suptitle(
        f"K-Means Cluster Validation ({csv_in})",
        fontsize=11.5, fontweight="bold", y=1.01
    )
    fig.tight_layout()
    fig.savefig(png_out, bbox_inches="tight", dpi=130)
    print(f"Saved {png_out} (optimal k={best_k})")


if __name__ == "__main__":
    main()
