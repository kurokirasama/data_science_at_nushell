#!/usr/bin/env python3
import pandas as pd
import numpy as np
import warnings
warnings.filterwarnings("ignore")
from sklearn.model_selection import train_test_split
from sklearn.preprocessing import StandardScaler
from sklearn.neural_network import MLPClassifier
from sklearn.metrics import accuracy_score, precision_score, recall_score, f1_score
import sys

df = pd.read_csv("banco.csv")
features = ["edad", "ingreso", "familia", "gasto_tarjeta", "educacion", "hipoteca"]
X = df[features]
y = df["prestamo"]

X_train, X_test, y_train, y_test = train_test_split(X, y, test_size=0.2, random_state=42)
scaler = StandardScaler()
X_train_s = scaler.fit_transform(X_train)
X_test_s  = scaler.transform(X_test)

rows = []
for hidden in [(8,), (16, 8)]:
    clf = MLPClassifier(hidden_layer_sizes=hidden, max_iter=500, random_state=42)
    clf.fit(X_train_s, y_train)
    preds = clf.predict(X_test_s)
    rows.append({
        "model": f"Python_MLP_{hidden}",
        "accuracy": round(float(accuracy_score(y_test, preds)), 4),
        "precision": round(float(precision_score(y_test, preds, zero_division=0)), 4),
        "recall": round(float(recall_score(y_test, preds, zero_division=0)), 4),
        "f1_score": round(float(f1_score(y_test, preds, zero_division=0)), 4),
        "iterations": int(clf.n_iter_)
    })

out = pd.DataFrame(rows)
out.to_csv("banco_mlp_py.csv", index=False)
out.to_csv(sys.stdout, index=False)
