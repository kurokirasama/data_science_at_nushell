#!/usr/bin/env python3
import json
import sys
import pandas as pd
import matplotlib
matplotlib.use("Agg")
import matplotlib.pyplot as plt

df = pd.read_csv("tips.csv")
fig, axes = plt.subplots(1, 2, figsize=(10, 4), dpi=120)

axes[0].hist(df["bill"], bins=20, color="#10b981", edgecolor="#064e3b", alpha=0.85)
axes[0].set_title("Distribucion de Factura (Python / Matplotlib)")
axes[0].set_xlabel("Monto de Factura (USD)")
axes[0].set_ylabel("Frecuencia")

for t, grp in df.groupby("time"):
    axes[1].scatter(grp["bill"], grp["tip"], label=t, alpha=0.75)
axes[1].set_title("Propina vs Factura por Horario")
axes[1].set_xlabel("Factura (USD)")
axes[1].set_ylabel("Propina (USD)")
axes[1].legend()

plt.tight_layout()
plt.savefig("tips_python_grid.png")
plt.savefig("tips_python.png")

summary = df.groupby("day")[["bill", "tip"]].mean().round(2).reset_index().to_dict(orient="records")
print(json.dumps(summary))
