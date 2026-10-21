#!/usr/bin/env python3
import pandas as pd
from sklearn.model_selection import train_test_split
from sklearn.preprocessing import StandardScaler
from sklearn.naive_bayes import GaussianNB
from sklearn.svm import SVC
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

models = {
    "GaussianNB": GaussianNB(),
    "SVC(kernel=rbf)": SVC(kernel="rbf", C=1.0, random_state=42)
}

rows = []
for name, clf in models.items():
    clf.fit(X_train_s, y_train)
    preds = clf.predict(X_test_s)
    rows.append({
        "model": name,
        "accuracy": round(float(accuracy_score(y_test, preds)), 4),
        "precision": round(float(precision_score(y_test, preds, zero_division=0)), 4),
        "recall": round(float(recall_score(y_test, preds, zero_division=0)), 4),
        "f1_score": round(float(f1_score(y_test, preds, zero_division=0)), 4)
    })

out_df = pd.DataFrame(rows)
out_df.to_csv("banco_nb_svm_py.csv", index=False)
out_df.to_csv(sys.stdout, index=False)
