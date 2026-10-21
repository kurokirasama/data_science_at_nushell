#!/usr/bin/env python3
import pandas as pd
from sklearn.preprocessing import StandardScaler
from sklearn.cluster import DBSCAN
import sys

df = pd.read_csv("Fish.csv")
num_cols = ["Weight", "Length1", "Length2", "Length3", "Height", "Width"]
X = df[num_cols]
scaler = StandardScaler()
X_scaled = scaler.fit_transform(X)

db = DBSCAN(eps=0.9, min_samples=4)
df["cluster"] = db.fit_predict(X_scaled)

grouped = df.groupby("cluster").agg(
    n_samples=("Species", "count"),
    avg_weight=("Weight", lambda x: round(float(x.mean()), 1)),
    avg_length=("Length1", lambda x: round(float(x.mean()), 1)),
    avg_height=("Height", lambda x: round(float(x.mean()), 1)),
    avg_width=("Width", lambda x: round(float(x.mean()), 1))
).reset_index()

grouped["cluster_type"] = grouped["cluster"].apply(lambda c: "Ruido / Outliers" if c == -1 else f"Cluster {c}")
out = grouped[["cluster", "cluster_type", "n_samples", "avg_weight", "avg_length", "avg_height", "avg_width"]]
out.to_csv("fish_dbscan_py.csv", index=False)
out.to_csv(sys.stdout, index=False)
