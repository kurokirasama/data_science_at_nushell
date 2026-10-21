#!/usr/bin/env python3
import pandas as pd
from sklearn.preprocessing import StandardScaler
from sklearn.pipeline import make_pipeline
from sklearn.linear_model import LogisticRegression
from sklearn.ensemble import RandomForestClassifier
from sklearn.metrics import accuracy_score, precision_score, recall_score, f1_score
import sys

train = pd.read_csv("train/features.csv")
test  = pd.read_csv("test/features.csv")

features = [c for c in train.columns if c not in ("id", "type")]
X_train, y_train = train[features], (train["type"] == "red").astype(int)
X_test,  y_test  = test[features],  (test["type"] == "red").astype(int)

models = {
    "Python_LogisticRegression": make_pipeline(StandardScaler(), LogisticRegression(max_iter=500, random_state=42)),
    "Python_RandomForestClassifier": RandomForestClassifier(n_estimators=100, random_state=42, n_jobs=-1)
}

rows = []
for name, clf in models.items():
    clf.fit(X_train, y_train)
    preds = clf.predict(X_test)
    rows.append({
        "model": name,
        "accuracy": round(float(accuracy_score(y_test, preds)), 4),
        "precision_red": round(float(precision_score(y_test, preds)), 4),
        "recall_red": round(float(recall_score(y_test, preds)), 4),
        "f1_red": round(float(f1_score(y_test, preds)), 4)
    })

out_df = pd.DataFrame(rows)
out_df.to_csv("wine_clf_py.csv", index=False)
out_df.to_csv(sys.stdout, index=False)
