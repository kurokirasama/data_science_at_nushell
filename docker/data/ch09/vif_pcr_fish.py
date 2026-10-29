#!/usr/bin/env python3
import sys
import numpy as np
import pandas as pd
from sklearn.decomposition import PCA
from sklearn.linear_model import LinearRegression
from sklearn.metrics import mean_squared_error, r2_score

df = pd.read_csv("Fish.csv")
pred_cols = ["Length1", "Length2", "Length3", "Height", "Width"]
X = df[pred_cols]
y = df["Weight"]

vif_rows = []
for col in pred_cols:
    X_other = X.drop(columns=[col])
    reg = LinearRegression().fit(X_other, X[col])
    r2_i = reg.score(X_other, X[col])
    vif = 1.0 / (1.0 - r2_i) if r2_i < 0.99999 else 9999.0
    vif_rows.append({"feature": col, "vif": round(float(vif), 2)})

pd.DataFrame(vif_rows).to_csv("fish_vif_py.csv", index=False)

ols = LinearRegression().fit(X, y)
ols_p = ols.predict(X)
ols_r2 = r2_score(y, ols_p)
ols_rmse = np.sqrt(mean_squared_error(y, ols_p))

X_pca = PCA(n_components=2).fit_transform(X)
pcr = LinearRegression().fit(X_pca, y)
pcr_p = pcr.predict(X_pca)
pcr_r2 = r2_score(y, pcr_p)
pcr_rmse = np.sqrt(mean_squared_error(y, pcr_p))

comp_df = pd.DataFrame([
    {
        "model": "Python_OLS_Multiple_Regression",
        "components": 5,
        "r2": round(float(ols_r2), 4),
        "rmse": round(float(ols_rmse), 2),
    },
    {
        "model": "Python_PCR_Principal_Components",
        "components": 2,
        "r2": round(float(pcr_r2), 4),
        "rmse": round(float(pcr_rmse), 2),
    },
])
comp_df.to_csv("fish_pcr_py.csv", index=False)
comp_df.to_csv(sys.stdout, index=False)
