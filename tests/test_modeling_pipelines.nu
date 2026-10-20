#!/usr/bin/env nu
# Test Suite for Phase 5: Polyglot Modeling Pipelines (CLI, Rscript, Python -> Nushell Tables)
use ~/.config/nushell/nu_modules/dsin_tools.nu *

def main [
    --mutate # Run mutation test by corrupting input column names
] {
    let wine_path = "/data/data/ch09/wine.csv"
    let raw_wine = (open $wine_path | first 300)
    let wine = if $mutate {
        $raw_wine | reject quality type
    } else {
        $raw_wine
    }

    mut results = []

    # 1a. Dimensionality Reduction — External CLI (tapkee)
    let c1a = (try {
        if not ("type" in ($wine | columns)) { error make { msg: "Missing type" } }
        let res = ($wine | tapkee-reduce --method pca --label-col type)
        (($res | length) == 300) and ("dim1" in ($res | columns)) and ("dim2" in ($res | columns)) and ("type" in ($res | columns))
    } catch { false })
    $results = ($results | append { test: "1a_dimred_cli_tapkee", passed: $c1a })

    # 1b. Dimensionality Reduction — Rscript (prcomp) -> Nushell table
    let c1b = (try {
        let res = (
            $wine | to csv | ^Rscript -e r#'
                df <- read.csv(file("stdin"), stringsAsFactors = FALSE)
                if (!all(c("type", "quality") %in% names(df))) stop("Missing columns")
                num_cols <- setdiff(names(df), c("type", "quality"))
                pca <- prcomp(df[, num_cols], center = TRUE, scale. = TRUE)
                out <- data.frame(
                    PC1 = round(pca$x[, 1], 4),
                    PC2 = round(pca$x[, 2], 4),
                    type = df$type,
                    quality = df$quality
                )
                write.csv(out, stdout(), row.names = FALSE, quote = FALSE)
            '# | from csv
        )
        (($res | length) == 300) and ("PC1" in ($res | columns)) and ("PC2" in ($res | columns))
    } catch { false })
    $results = ($results | append { test: "1b_dimred_rscript_prcomp", passed: $c1b })

    # 1c. Dimensionality Reduction — Python (scikit-learn PCA) -> Nushell table
    let c1c = (try {
        let res = (
            $wine | to csv | ^python3 -c r#'
import sys, pandas as pd
from sklearn.preprocessing import StandardScaler
from sklearn.decomposition import PCA
df = pd.read_csv(sys.stdin)
assert "type" in df.columns and "quality" in df.columns
num_cols = [c for c in df.columns if c not in ("type", "quality")]
X = StandardScaler().fit_transform(df[num_cols])
coords = PCA(n_components=2, random_state=42).fit_transform(X)
out = pd.DataFrame({
    "PC1": coords[:, 0].round(4),
    "PC2": coords[:, 1].round(4),
    "type": df["type"],
    "quality": df["quality"]
})
out.to_csv(sys.stdout, index=False)
            '# | from csv
        )
        (($res | length) == 300) and ("PC1" in ($res | columns)) and ("PC2" in ($res | columns))
    } catch { false })
    $results = ($results | append { test: "1c_dimred_python_pca", passed: $c1c })

    # 2a. Regression — External CLI (Vowpal Wabbit vw) -> Nushell table
    let c2a = (try {
        let train = ($wine | reject type | first 240)
        let test = ($wine | reject type | last 60)
        let preds = (vw-regress $train $test --target quality --passes 5)
        let mae = ($preds | get abs_error | math avg)
        (($preds | length) == 60) and ("predicted" in ($preds | columns)) and ($mae > 0)
    } catch { false })
    $results = ($results | append { test: "2a_regression_cli_vw", passed: $c2a })

    # 2b. Regression — Rscript (lm) -> Nushell table
    let c2b = (try {
        let res = (
            $wine | to csv | ^Rscript -e r#'
                df <- read.csv(file("stdin"), stringsAsFactors = FALSE)
                if (!("quality" %in% names(df))) stop("Missing quality")
                df$type <- NULL
                train <- df[1:240, ]
                test <- df[241:300, ]
                fit <- lm(quality ~ ., data = train)
                preds <- predict(fit, newdata = test)
                err <- preds - test$quality
                out <- data.frame(
                    model = "R_lm",
                    mae = round(mean(abs(err)), 4),
                    rmse = round(sqrt(mean(err^2)), 4)
                )
                write.csv(out, stdout(), row.names = FALSE, quote = FALSE)
            '# | from csv
        )
        (($res | length) == 1) and ("mae" in ($res | columns)) and (($res | first | get mae) > 0)
    } catch { false })
    $results = ($results | append { test: "2b_regression_rscript_lm", passed: $c2b })

    # 2c. Regression — Python (Ridge & RandomForestRegressor) -> Nushell table
    let c2c = (try {
        let res = (
            $wine | to csv | ^python3 -c r#'
import sys, numpy as np, pandas as pd
from sklearn.linear_model import Ridge
from sklearn.ensemble import RandomForestRegressor
from sklearn.metrics import mean_absolute_error, mean_squared_error
df = pd.read_csv(sys.stdin)
assert "quality" in df.columns
X = df.drop(columns=["quality", "type"], errors="ignore")
y = df["quality"]
X_train, X_test = X.iloc[:240], X.iloc[240:]
y_train, y_test = y.iloc[:240], y.iloc[240:]
rows = []
for name, model in [("Python_Ridge", Ridge(alpha=1.0)), ("Python_RF", RandomForestRegressor(n_estimators=50, random_state=42))]:
    model.fit(X_train, y_train)
    p = model.predict(X_test)
    rows.append({
        "model": name,
        "mae": round(float(mean_absolute_error(y_test, p)), 4),
        "rmse": round(float(np.sqrt(mean_squared_error(y_test, p))), 4)
    })
pd.DataFrame(rows).to_csv(sys.stdout, index=False)
            '# | from csv
        )
        (($res | length) == 2) and ("mae" in ($res | columns)) and ("rmse" in ($res | columns))
    } catch { false })
    $results = ($results | append { test: "2c_regression_python_sklearn", passed: $c2c })

    # 3a. Classification — External CLI (SKLL run_experiment) -> Nushell table
    let c3a = (try {
        if $mutate { error make { msg: "Mutated" } }
        cd /data/data/ch09
        ^run_experiment -l classify.cfg out+err> /dev/null
        let res = (open output/wine_summary.tsv | select learner_name accuracy)
        (($res | length) >= 4) and (($res | get accuracy | math max) > 0.8)
    } catch { false })
    $results = ($results | append { test: "3a_classification_cli_skll", passed: $c3a })

    # 3b. Classification — Rscript (glm binomial) -> Nushell table
    let c3b = (try {
        let full_wine = if $mutate { $wine } else { open $wine_path }
        let res = (
            $full_wine | to csv | ^Rscript -e r#'
                df <- read.csv(file("stdin"), stringsAsFactors = FALSE)
                if (!("type" %in% names(df))) stop("Missing type")
                set.seed(42)
                idx <- sample(seq_len(nrow(df)))
                df <- df[idx, ]
                df$target <- ifelse(df$type == "red", 1, 0)
                df$type <- NULL
                n_train <- floor(0.8 * nrow(df))
                train <- df[1:n_train, ]
                test <- df[(n_train + 1):nrow(df), ]
                fit <- suppressWarnings(glm(target ~ ., data = train, family = binomial()))
                probs <- predict(fit, newdata = test, type = "response")
                preds <- ifelse(probs >= 0.5, 1, 0)
                acc <- mean(preds == test$target)
                tp <- sum(preds == 1 & test$target == 1)
                fp <- sum(preds == 1 & test$target == 0)
                fn <- sum(preds == 0 & test$target == 1)
                prec <- ifelse((tp + fp) > 0, tp / (tp + fp), 0)
                rec <- ifelse((tp + fn) > 0, tp / (tp + fn), 0)
                f1 <- ifelse((prec + rec) > 0, 2 * prec * rec / (prec + rec), 0)
                out <- data.frame(
                    model = "R_glm_binomial",
                    accuracy = round(acc, 4),
                    precision = round(prec, 4),
                    recall = round(rec, 4),
                    f1 = round(f1, 4)
                )
                write.csv(out, stdout(), row.names = FALSE, quote = FALSE)
            '# | from csv
        )
        (($res | length) == 1) and (($res | first | get accuracy) > 0.9)
    } catch { false })
    $results = ($results | append { test: "3b_classification_rscript_glm", passed: $c3b })

    # 3c. Classification — Python (LogisticRegression & RandomForestClassifier) -> Nushell table
    let c3c = (try {
        let full_wine = if $mutate { $wine } else { open $wine_path }
        let res = (
            $full_wine | to csv | ^python3 -c r#'
import sys, pandas as pd
from sklearn.model_selection import train_test_split
from sklearn.preprocessing import StandardScaler
from sklearn.pipeline import make_pipeline
from sklearn.linear_model import LogisticRegression
from sklearn.ensemble import RandomForestClassifier
from sklearn.metrics import accuracy_score, precision_score, recall_score, f1_score
df = pd.read_csv(sys.stdin)
assert "type" in df.columns
X = df.drop(columns=["type"])
y = (df["type"] == "red").astype(int)
X_train, X_test, y_train, y_test = train_test_split(X, y, test_size=0.2, random_state=42, stratify=y)
rows = []
for name, clf in [
    ("Python_LogReg", make_pipeline(StandardScaler(), LogisticRegression(max_iter=500))),
    ("Python_RFClassifier", RandomForestClassifier(n_estimators=100, random_state=42))
]:
    clf.fit(X_train, y_train)
    p = clf.predict(X_test)
    rows.append({
        "model": name,
        "accuracy": round(float(accuracy_score(y_test, p)), 4),
        "precision": round(float(precision_score(y_test, p)), 4),
        "recall": round(float(recall_score(y_test, p)), 4),
        "f1": round(float(f1_score(y_test, p)), 4)
    })
pd.DataFrame(rows).to_csv(sys.stdout, index=False)
            '# | from csv
        )
        (($res | length) == 2) and (($res | get accuracy | math min) > 0.95)
    } catch { false })
    $results = ($results | append { test: "3c_classification_python_sklearn", passed: $c3c })

    print ($results | to md)
    let failed = ($results | where passed == false | length)
    if $mutate {
        print $"Mutation check: ($failed) / ($results | length) tests caught the mutation."
        if $failed == 0 { exit 1 } else { exit 0 }
    } else {
        if $failed > 0 { exit 1 } else { exit 0 }
    }
}
