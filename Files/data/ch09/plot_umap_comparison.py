#!/opt/modern-ml/bin/python
"""Compare PCA, t-SNE, and UMAP projections on 800 wines."""
import os
import warnings

os.environ.setdefault("NUMBA_CACHE_DIR", "/tmp/numba_cache")
os.environ.setdefault("MPLCONFIGDIR", "/tmp/matplotlib_cache")
warnings.filterwarnings("ignore")

import matplotlib
matplotlib.use("Agg")
import matplotlib.pyplot as plt
import pandas as pd
from sklearn.decomposition import PCA
from sklearn.manifold import TSNE
from sklearn.preprocessing import StandardScaler
import umap

df = pd.read_csv("wine-both.csv")
red = df[df["type"] == "red"].sample(n=400, random_state=42)
white = df[df["type"] == "white"].sample(n=400, random_state=42)
sub = pd.concat([red, white], ignore_index=True)

feat_cols = [c for c in sub.columns if c not in ("type", "quality")]
X = StandardScaler().fit_transform(sub[feat_cols])

c_pca = PCA(n_components=2, random_state=42).fit_transform(X)
c_tsne = TSNE(
    n_components=2, perplexity=30, random_state=42, init="pca"
).fit_transform(X)
c_umap = umap.UMAP(
    n_neighbors=15, min_dist=0.1, n_components=2, random_state=42
).fit_transform(X)

fig, axes = plt.subplots(1, 3, figsize=(13.5, 4.2), dpi=130)
panels = [
    (c_pca, "PCA (Linear Variance)", "PC 1", "PC 2"),
    (c_tsne, "t-SNE (Local Neighborhoods)", "Dim 1", "Dim 2"),
    (c_umap, "UMAP (Local + Global Topology)", "UMAP 1", "UMAP 2"),
]
palette = {"red": "#be123c", "white": "#0284c7"}

for ax, (emb, title, xlabel, ylabel) in zip(axes, panels):
    for label, color in palette.items():
        mask = (sub["type"] == label).to_numpy()
        ax.scatter(
            emb[mask, 0], emb[mask, 1],
            c=color, label=label.capitalize(),
            s=14, alpha=0.72, edgecolors="none",
        )
    ax.set_title(title, fontsize=10.5, fontweight="bold")
    ax.set_xlabel(xlabel, fontsize=9)
    ax.set_ylabel(ylabel, fontsize=9)
    ax.grid(True, linestyle="--", linewidth=0.4, alpha=0.45)

axes[2].legend(
    title="Wine Type", loc="best", frameon=True, fontsize=8.5
)
fig.suptitle(
    "Manifold Projection Comparison on Wine Attributes (n = 800)",
    fontsize=12, fontweight="bold", y=1.01,
)
fig.tight_layout()
fig.savefig("umap_comparison.png", bbox_inches="tight", dpi=130)
print("Saved umap_comparison.png")
