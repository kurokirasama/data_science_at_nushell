#!/usr/bin/env python3
import sys
import pandas as pd
from sklearn.cluster import DBSCAN
from sklearn.preprocessing import StandardScaler

df = pd.read_csv("Fish.csv")
num_cols = [
    "Weight", "Length1", "Length2", "Length3", "Height", "Width"
]
X_scaled = StandardScaler().fit_transform(df[num_cols])

db = DBSCAN(eps=0.9, min_samples=4)
df["cluster"] = db.fit_predict(X_scaled)

grouped = df.groupby("cluster").agg(
    n_samples=("Species", "count"),
    avg_weight=("Weight", lambda x: round(float(x.mean()), 1)),
    avg_length=("Length1", lambda x: round(float(x.mean()), 1)),
    avg_height=("Height", lambda x: round(float(x.mean()), 1)),
    avg_width=("Width", lambda x: round(float(x.mean()), 1)),
).reset_index()

grouped["cluster_type"] = grouped["cluster"].apply(
    lambda c: "Noise / Outliers" if c == -1 else f"Cluster {c}"
)
cols_out = [
    "cluster", "cluster_type", "n_samples",
    "avg_weight", "avg_length", "avg_height", "avg_width",
]
out = grouped[cols_out]
out.to_csv("fish_dbscan_py.csv", index=False)
out.to_csv(sys.stdout, index=False)
