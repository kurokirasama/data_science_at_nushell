#!/usr/bin/env python3
# Clustering Jerárquico con Scikit-Learn
import pandas as pd
from sklearn.preprocessing import StandardScaler
from sklearn.cluster import AgglomerativeClustering
from sklearn.metrics import silhouette_score
import sys

df = pd.read_csv("Fish.csv")
num_cols = ["Weight", "Length1", "Length2", "Length3", "Height", "Width"]
X = StandardScaler().fit_transform(df[num_cols])

rows = []
for k in [2, 3, 4, 5]:
    model = AgglomerativeClustering(n_clusters=k, linkage="ward")
    labels = model.fit_predict(X)
    sil = silhouette_score(X, labels)
    if k == 3:
        df_out = df[["Species", "Weight", "Height", "Width"]].copy()
        df_out["cluster"] = [f"cluster_{l+1}" for l in labels]
        df_out.to_csv("fish_hclust_py.csv", index=False)
    rows.append({
        "linkage": "ward",
        "n_clusters": k,
        "silhouette": round(float(sil), 4)
    })

pd.DataFrame(rows).to_csv(sys.stdout, index=False)
