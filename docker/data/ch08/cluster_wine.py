#!/usr/bin/env python3
import pandas as pd
from sklearn.preprocessing import StandardScaler
from sklearn.cluster import KMeans
from sklearn.metrics import silhouette_score
import sys

df = pd.read_csv("wine.csv")
features = [c for c in df.columns if c not in ("type", "quality")]
X = StandardScaler().fit_transform(df[features])

rows = []
for k in [2, 3, 4, 5]:
    km = KMeans(n_clusters=k, n_init=10, random_state=42)
    labels = km.fit_predict(X)
    sil = silhouette_score(X, labels, sample_size=1500, random_state=42)
    if k == 2:
        df_out = df[["type", "quality", "alcohol", "volatile_acidity"]].copy()
        df_out["cluster"] = [f"cluster_{l+1}" for l in labels]
        df_out.to_csv("wine_kmeans_py.csv", index=False)
    rows.append({
        "k_clusters": k,
        "inertia": round(float(km.inertia_), 2),
        "silhouette": round(float(sil), 4),
        "iterations": int(km.n_iter_)
    })

pd.DataFrame(rows).to_csv(sys.stdout, index=False)
