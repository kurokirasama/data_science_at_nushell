#!/usr/bin/env python3
import pandas as pd
from sklearn.preprocessing import StandardScaler
from sklearn.cluster import KMeans
from sklearn.metrics import silhouette_score, calinski_harabasz_score, davies_bouldin_score
import sys

df = pd.read_csv("banco.csv")
features = ["edad", "ingreso", "gasto_tarjeta", "hipoteca"]
X = StandardScaler().fit_transform(df[features])

rows = []
for k in range(2, 7):
    km = KMeans(n_clusters=k, n_init=10, random_state=42)
    labels = km.fit_predict(X)
    rows.append({
        "k": k,
        "inertia": round(float(km.inertia_), 2),
        "silhouette": round(float(silhouette_score(X, labels, sample_size=1000, random_state=42)), 4),
        "calinski_harabasz": round(float(calinski_harabasz_score(X, labels)), 2),
        "davies_bouldin": round(float(davies_bouldin_score(X, labels)), 4)
    })

pd.DataFrame(rows).to_csv(sys.stdout, index=False)
