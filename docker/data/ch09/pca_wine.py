#!/usr/bin/env python3
import pandas as pd
from sklearn.preprocessing import StandardScaler
from sklearn.decomposition import PCA
import sys

df = pd.read_csv("wine.csv")
features = [c for c in df.columns if c not in ("type", "quality")]
X = StandardScaler().fit_transform(df[features])

pca = PCA(n_components=5, random_state=42)
coords = pca.fit_transform(X)

# Save 2D projection to wine_pca_py.csv
proj = pd.DataFrame({
    "pc1": coords[:, 0].round(4),
    "pc2": coords[:, 1].round(4),
    "type": df["type"],
    "quality": df["quality"]
})
proj.to_csv("wine_pca_py.csv", index=False)

# Output variance summary as CSV to stdout
summary = pd.DataFrame({
    "component": [f"PC{i+1}" for i in range(5)],
    "explained_variance": pca.explained_variance_.round(4),
    "pct_variance": (pca.explained_variance_ratio_ * 100).round(2),
    "cum_variance": (pca.explained_variance_ratio_.cumsum() * 100).round(2)
})
summary.to_csv(sys.stdout, index=False)
