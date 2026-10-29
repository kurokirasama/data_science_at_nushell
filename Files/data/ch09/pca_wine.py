#!/usr/bin/env python3
import sys
import pandas as pd
from sklearn.decomposition import PCA
from sklearn.preprocessing import StandardScaler

df = pd.read_csv("wine.csv")
feat_cols = [c for c in df.columns if c not in ("type", "quality")]
X = StandardScaler().fit_transform(df[feat_cols])

pca = PCA(n_components=5, random_state=42)
coords = pca.fit_transform(X)

proj = pd.DataFrame({
    "pc1": coords[:, 0].round(4),
    "pc2": coords[:, 1].round(4),
    "type": df["type"],
    "quality": df["quality"],
})
proj.to_csv("wine_pca_py.csv", index=False)

pct = pca.explained_variance_ratio_ * 100.0
summary = pd.DataFrame({
    "component": [f"PC{i + 1}" for i in range(5)],
    "explained_variance": pca.explained_variance_.round(4),
    "pct_variance": pct.round(2),
    "cum_variance": pct.cumsum().round(2),
})
summary.to_csv(sys.stdout, index=False)
