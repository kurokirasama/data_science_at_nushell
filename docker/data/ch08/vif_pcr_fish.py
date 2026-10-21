#!/usr/bin/env python3
import pandas as pd
import numpy as np
from sklearn.linear_model import LinearRegression
from sklearn.decomposition import PCA
from sklearn.metrics import r2_score, mean_squared_error
import sys

df = pd.read_csv("Fish.csv")
pred_cols = ["Length1", "Length2", "Length3", "Height", "Width"]
X = df[pred_cols]
y = df["Weight"]

# VIF calculation: VIF_i = 1 / (1 - R^2_i)
vif_data = []
for col in pred_cols:
    X_other = X.drop(columns=[col])
    y_target = X[col]
    reg = LinearRegression().fit(X_other, y_target)
    r2_val = reg.score(X_other, y_target)
    vif = 1.0 / (1.0 - r2_val) if r2_val < 0.99999 else 9999.0
    vif_data.append({"feature": col, "vif": round(float(vif), 2)})

vif_df = pd.DataFrame(vif_data)
vif_df.to_csv("fish_vif_py.csv", index=False)

# OLS Multiple Regression vs PCR (K=2)
ols = LinearRegression().fit(X, y)
ols_preds = ols.predict(X)
ols_r2 = r2_score(y, ols_preds)
ols_rmse = np.sqrt(mean_squared_error(y, ols_preds))

pca = PCA(n_components=2)
X_pca = pca.fit_transform(X)
pcr = LinearRegression().fit(X_pca, y)
pcr_preds = pcr.predict(X_pca)
pcr_r2 = r2_score(y, pcr_preds)
pcr_rmse = np.sqrt(mean_squared_error(y, pcr_preds))

comp_df = pd.DataFrame([
    {"model": "Python_OLS_Multiple_Regression", "components": 5, "r2": round(float(ols_r2), 4), "rmse": round(float(ols_rmse), 2)},
    {"model": "Python_PCR_Principal_Components", "components": 2, "r2": round(float(pcr_r2), 4), "rmse": round(float(pcr_rmse), 2)}
])
comp_df.to_csv("fish_pcr_py.csv", index=False)
comp_df.to_csv(sys.stdout, index=False)
