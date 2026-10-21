#!/usr/bin/env python3
import pandas as pd
from sklearn.model_selection import train_test_split
from sklearn.tree import DecisionTreeClassifier
from sklearn.metrics import accuracy_score, precision_score, recall_score, f1_score
import sys

df = pd.read_csv("banco.csv")
features = ["edad", "ingreso", "familia", "gasto_tarjeta", "educacion", "hipoteca"]
X = df[features]
y = df["prestamo"]

X_train, X_test, y_train, y_test = train_test_split(X, y, test_size=0.2, random_state=42)

clf = DecisionTreeClassifier(max_depth=4, random_state=42)
clf.fit(X_train, y_train)
preds = clf.predict(X_test)

out = pd.DataFrame([{
    "model": "Python_DecisionTreeClassifier",
    "max_depth": 4,
    "accuracy": round(float(accuracy_score(y_test, preds)), 4),
    "precision": round(float(precision_score(y_test, preds, zero_division=0)), 4),
    "recall": round(float(recall_score(y_test, preds, zero_division=0)), 4),
    "f1_score": round(float(f1_score(y_test, preds, zero_division=0)), 4)
}])
out.to_csv("banco_dt_py.csv", index=False)
out.to_csv(sys.stdout, index=False)
