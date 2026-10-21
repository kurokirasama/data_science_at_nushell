#!/usr/bin/env python3
import pandas as pd
import sys

df = pd.read_csv("tips.csv")
df["pct_tip"] = df["tip"] / df["bill"] * 100.0
corr = df[["bill", "tip", "size", "pct_tip"]].corr().round(4)
corr.index.name = "variable"
corr.reset_index().to_csv(sys.stdout, index=False)
