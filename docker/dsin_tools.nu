# =========================================================
# Data Science at Nushell (dsin) — Polyglot & Modeling Helpers
# =========================================================

# Convert a Nushell table into Vowpal Wabbit (VW) line format.
export def to-vw [
  --target(-t): string = "quality" # Name of target column
  --namespace(-n): string = "f"    # Feature namespace label
]: table -> list<string> {
  let tbl = $in
  let cols = $tbl | columns | where $it != $target
  $tbl | each { |row|
    let y = $row | get $target
    let feats = $cols | each { |c| $"($c):($row | get $c)" } | str join " "
    $"($y) |($namespace) ($feats)"
  }
}

# Train and evaluate a Vowpal Wabbit regression model and return predictions as a Nushell table.
export def vw-regress [
  train_tbl: table
  test_tbl: table
  --target(-t): string = "quality"
  --passes(-p): int = 10
  --learning-rate(-l): float = 0.5
]: nothing -> table {
  let tmp_dir = mktemp -d
  let train_vw = $"($tmp_dir)/train.vw"
  let test_vw = $"($tmp_dir)/test.vw"
  let model_file = $"($tmp_dir)/model.vw"
  let pred_file = $"($tmp_dir)/preds.txt"

  $train_tbl | to-vw --target $target | str join "\n" | save -f $train_vw
  $test_tbl | to-vw --target $target | str join "\n" | save -f $test_vw

  vw --data $train_vw --final_regressor $model_file --passes $passes -l $learning_rate --cache_file $"($tmp_dir)/train.cache" --quiet
  vw --data $test_vw -i $model_file -t -p $pred_file --quiet

  let preds = open --raw $pred_file | lines | where ($it | str trim | is-not-empty) | each { |x| $x | into float }
  let actuals = $test_tbl | get $target | each { |x| $x | into float }

  rm -rf $tmp_dir

  $actuals | zip $preds | each { |pair|
    let obs = $pair.0
    let pred = $pair.1 | math round -p 4
    let signed_err = ($pred - $obs) | math round -p 4
    let err = ($obs - $pred) | math abs | math round -p 4
    { actual: $obs, observed: $obs, predicted: $pred, error: $signed_err, abs_error: $err }
  }
}

# Run Tapkee dimensionality reduction on a numeric Nushell table and return a structured table.
export def tapkee-reduce [
  --method(-m): string = "pca" # Tapkee method: pca, ltsa, isomap, mds, tsne, t-sne, lle
  --target-dim(-d): int = 2    # Number of output dimensions
  --label-col(-l): string      # Optional label column to preserve alongside coordinates
  --cols(-c): list<string>     # Optional explicit list of feature columns
]: table -> table {
  let tbl = $in
  let norm_method = if $method == "tsne" { "t-sne" } else { $method }
  let num_tbl = if ($cols != null) and (($cols | length) > 0) {
    $tbl | select ...$cols
  } else if ($label_col != null) and ($label_col | is-not-empty) and ($label_col in ($tbl | columns)) {
    $tbl | reject $label_col
  } else {
    let non_num = ["type"] | where {|c| $c in ($tbl | columns)}
    if ($non_num | is-not-empty) { $tbl | reject ...$non_num } else { $tbl }
  }

  let tmp_in = mktemp --suffix ".csv"
  let tmp_out = mktemp --suffix ".tsv"
  $num_tbl | to csv --noheaders | save -f $tmp_in

  tapkee -i $tmp_in -o $tmp_out -m $norm_method -td $target_dim --delimiter ","
  let raw_coords = open --raw $tmp_out | lines | where ($it | str trim | is-not-empty)
  rm -f $tmp_in $tmp_out

  let coords_tbl = $raw_coords | each { |line|
    let parts = $line | split row "," | each { |v| $v | str trim | into float | math round -p 4 }
    mut rec = {}
    for idx in 0..<($parts | length) {
      let val = $parts | get $idx
      $rec = ($rec | insert $"dim($idx + 1)" $val | insert $"dim_($idx + 1)" $val)
    }
    $rec
  }

  $tbl | merge $coords_tbl
}

# Run K-Means clustering on a numeric Nushell table and return cluster assignments.
export def kmeans-cluster [
  --k(-k): int = 2             # Number of clusters K
  --clusters: int = 0          # Alias for --k
  --label-col(-l): string      # Optional label column to exclude from features
  --cols(-c): list<string>     # Optional explicit list of feature columns
]: table -> table {
  let tbl = $in
  let n_clusters = if $clusters > 0 { $clusters } else { $k }
  let tmp_in = mktemp --suffix ".csv"
  let tmp_py = mktemp --suffix ".py"
  $tbl | to csv | save -f $tmp_in

  let lbl = $label_col | default "type"
  let cols_csv = if ($cols != null) and (($cols | length) > 0) {
    $cols | str join ","
  } else { "" }

  'import sys, pandas as pd
from sklearn.preprocessing import StandardScaler
from sklearn.cluster import KMeans

df = pd.read_csv(sys.argv[1])
k = int(sys.argv[2])
lbl = sys.argv[3]
cols_arg = sys.argv[4]
if cols_arg:
    num_cols = [c for c in cols_arg.split(",") if c in df.columns]
else:
    num_cols = [c for c in df.columns if c not in (lbl, "type") and pd.api.types.is_numeric_dtype(df[c])]
X = StandardScaler().fit_transform(df[num_cols])
km = KMeans(n_clusters=k, n_init=10, random_state=42)
clusters = km.fit_predict(X)
df["cluster"] = [f"cluster_{c+1}" for c in clusters]
df.to_csv(sys.stdout, index=False)
' | save -f $tmp_py

  let res = python3 $tmp_py $tmp_in ($n_clusters | into string) $lbl $cols_csv | from csv
  rm -f $tmp_in $tmp_py
  $res
}

# Parse SKLL experiment summary TSV into a clean Nushell table.
export def skll-metrics [
  summary_tsv: path = "output/wine_summary.tsv"
]: nothing -> table {
  let target_path = if ($summary_tsv | path exists) {
    $summary_tsv
  } else if ("output/wine_summary.tsv" | path exists) {
    "output/wine_summary.tsv"
  } else {
    $summary_tsv
  }
  open $target_path | select learner_name accuracy
}

# =========================================================
# MODERN PIPELINE-NATIVE MODELING HELPERS
# =========================================================

# Compute UMAP manifold coordinates on a numeric Nushell table and return a structured table.
export def umap-reduce [
  --neighbors(-n): int = 15    # Size of local neighborhood
  --min-dist(-m): float = 0.1  # Minimum effective distance between embedded points
  --target-dim(-d): int = 2    # Number of embedding dimensions
  --seed(-s): int = 42         # Random state for reproducibility
  --label-col(-l): string      # Optional label column to exclude from features and preserve
  --cols(-c): list<string>     # Optional explicit list of numeric feature columns
]: table -> table {
  let tbl = $in
  let tmp_in = mktemp --suffix ".csv"
  let tmp_py = mktemp --suffix ".py"
  $tbl | to csv | save -f $tmp_in

  let lbl = $label_col | default "type"
  let cols_csv = if ($cols != null) and (($cols | length) > 0) {
    $cols | str join ","
  } else { "" }

  r#'import os, sys, warnings
os.environ.setdefault("NUMBA_CACHE_DIR", "/tmp/numba_cache")
warnings.filterwarnings("ignore")
import pandas as pd
from sklearn.preprocessing import StandardScaler
import umap

df = pd.read_csv(sys.argv[1])
n_neighbors = int(sys.argv[2])
min_dist = float(sys.argv[3])
n_components = int(sys.argv[4])
seed = int(sys.argv[5])
lbl = sys.argv[6]
cols_arg = sys.argv[7]

if cols_arg:
    num_cols = [c for c in cols_arg.split(",") if c in df.columns]
else:
    num_cols = [c for c in df.columns if c != lbl and pd.api.types.is_numeric_dtype(df[c])]

X = StandardScaler().fit_transform(df[num_cols])
reducer = umap.UMAP(
    n_neighbors=min(n_neighbors, max(2, len(df) - 1)),
    min_dist=min_dist,
    n_components=n_components,
    random_state=seed,
)
emb = reducer.fit_transform(X)
for idx in range(n_components):
    df[f"umap_{idx + 1}"] = emb[:, idx].round(4)
df.to_csv(sys.stdout, index=False)
'# | save -f $tmp_py

  let res = ^/opt/modern-ml/bin/python $tmp_py $tmp_in ($neighbors | into string) ($min_dist | into string) ($target_dim | into string) ($seed | into string) $lbl $cols_csv | from csv
  rm -f $tmp_in $tmp_py
  $res
}

# Train and evaluate standalone LightGBM C++ CLI regression on train/test Nushell tables.
export def lgbm-regress [
  train_tbl: table
  test_tbl: table
  --target(-t): string = "quality"
  --num-trees(-n): int = 100
  --learning-rate(-l): float = 0.05
  --num-leaves: int = 31
  --importance(-i)             # Return sorted feature-gain importance table instead of test predictions
]: nothing -> table {
  let tmp_dir = mktemp -d
  let train_csv = $"($tmp_dir)/train.csv"
  let test_csv = $"($tmp_dir)/test_features.csv"
  let model_file = $"($tmp_dir)/model.txt"
  let pred_file = $"($tmp_dir)/preds.txt"

  let feat_cols = $train_tbl | columns | where $it != $target
  $train_tbl | select ...($feat_cols | append $target) | to csv | save -f $train_csv
  $test_tbl | select ...$feat_cols | to csv | save -f $test_csv

  ^lightgbm task=train objective=regression $"data=($train_csv)" header=true $"label_column=name:($target)" $"num_trees=($num_trees)" $"learning_rate=($learning_rate)" $"num_leaves=($num_leaves)" seed=42 deterministic=true force_col_wise=true $"output_model=($model_file)" verbosity=-1 out+err> /dev/null

  if $importance {
    let imp_py = $"($tmp_dir)/imp.py"
    r#'import json, sys, lightgbm as lgb
booster = lgb.Booster(model_file=sys.argv[1])
names = booster.feature_name()
splits = booster.feature_importance(importance_type="split")
gains = booster.feature_importance(importance_type="gain")
total_gain = float(gains.sum()) if float(gains.sum()) > 0 else 1.0
rows = [
    {
        "feature": str(n),
        "splits": int(s),
        "gain": round(float(g), 4),
        "gain_pct": round(float(g) * 100.0 / total_gain, 2),
    }
    for n, s, g in zip(names, splits, gains)
]
rows.sort(key=lambda r: r["gain"], reverse=True)
print(json.dumps(rows))
'# | save -f $imp_py
    let imp_tbl = ^/opt/modern-ml/bin/python $imp_py $model_file | from json
    rm -rf $tmp_dir
    return $imp_tbl
  }

  ^lightgbm task=predict $"data=($test_csv)" header=true $"input_model=($model_file)" $"output_result=($pred_file)" verbosity=-1 out+err> /dev/null

  let preds = open --raw $pred_file | lines | where ($it | str trim | is-not-empty) | each { |x| $x | into float }
  let actuals = $test_tbl | get $target | each { |x| $x | into float }
  rm -rf $tmp_dir

  $actuals | zip $preds | each { |pair|
    let obs = $pair.0
    let pred = $pair.1 | math round -p 4
    let signed_err = ($pred - $obs) | math round -p 4
    let abs_err = ($obs - $pred) | math abs | math round -p 4
    { actual: $obs, observed: $obs, predicted: $pred, error: $signed_err, abs_error: $abs_err }
  }
}

# Compute vectorized Ordinary Least Squares regression diagnostics via DuckDB CLI.
export def duckdb-ols [
  --target(-y): string = "quality" # Dependent response column
  --predictor(-x): string = ""     # Optional single predictor column (omit to rank all numeric predictors)
]: table -> table {
  let tbl = $in
  let first_row = $tbl | first
  let candidate_cols = if ($predictor | is-not-empty) {
    [$predictor]
  } else {
    $tbl | columns | where { |c|
      ($c != $target) and ((($first_row | get $c | describe) == "int") or (($first_row | get $c | describe) == "float"))
    }
  }

  let tmp_csv = mktemp --suffix ".csv"
  $tbl | select ...($candidate_cols | append $target) | to csv | save -f $tmp_csv

  let unions = $candidate_cols | each { |col|
    $"SELECT '($col)' AS predictor, ROUND\(regr_slope\(\"($target)\", \"($col)\"\), 4\) AS slope, ROUND\(regr_intercept\(\"($target)\", \"($col)\"\), 4\) AS intercept, ROUND\(corr\(\"($target)\", \"($col)\"\), 4\) AS pearson_r, ROUND\(regr_r2\(\"($target)\", \"($col)\"\), 4\) AS r_squared, CAST\(regr_count\(\"($target)\", \"($col)\"\) AS BIGINT\) AS n FROM tbl"
  } | str join " UNION ALL "

  let sql = $"CREATE TEMP TABLE tbl AS SELECT * FROM read_csv_auto\('($tmp_csv)'\); SELECT * FROM \(($unions)\) ORDER BY r_squared DESC;"
  let res = ^duckdb -json -c $sql | from json
  rm -f $tmp_csv
  $res
}

# Benchmark multiple classification architectures (including MLP) on a Nushell table in one streaming pipeline.
export def ml-benchmark [
  --target(-t): string = "type"
  --models(-m): list<string> = ["logistic", "rf", "lgbm", "linear_svc", "mlp"]
  --test-size: float = 0.25
  --seed(-s): int = 42
]: table -> table {
  let tbl = $in
  let tmp_in = mktemp --suffix ".csv"
  let tmp_py = mktemp --suffix ".py"
  $tbl | to csv | save -f $tmp_in
  let models_csv = $models | str join ","

  r#'import json, sys, time, warnings
warnings.filterwarnings("ignore")
import pandas as pd
from sklearn.compose import ColumnTransformer
from sklearn.ensemble import RandomForestClassifier
from sklearn.linear_model import LogisticRegression
from sklearn.metrics import accuracy_score, f1_score, precision_score, recall_score
from sklearn.model_selection import train_test_split
from sklearn.neural_network import MLPClassifier
from sklearn.pipeline import Pipeline
from sklearn.preprocessing import LabelEncoder, OneHotEncoder, StandardScaler
from sklearn.svm import LinearSVC
from lightgbm import LGBMClassifier

df = pd.read_csv(sys.argv[1])
target = sys.argv[2]
models = [m.strip() for m in sys.argv[3].split(",") if m.strip()]
test_size = float(sys.argv[4])
seed = int(sys.argv[5])

X = df.drop(columns=[target])
le = LabelEncoder()
y = le.fit_transform(df[target].astype(str))

num_cols = [c for c in X.columns if pd.api.types.is_numeric_dtype(X[c])]
cat_cols = [c for c in X.columns if c not in num_cols]

prep_scaled = ColumnTransformer(
    transformers=[
        ("num", StandardScaler(), num_cols),
        ("cat", OneHotEncoder(handle_unknown="ignore"), cat_cols),
    ],
    remainder="drop",
)
prep_tree = ColumnTransformer(
    transformers=[
        ("num", "passthrough", num_cols),
        ("cat", OneHotEncoder(handle_unknown="ignore", sparse_output=False), cat_cols),
    ],
    remainder="drop",
)

X_train, X_test, y_train, y_test = train_test_split(
    X, y, test_size=test_size, random_state=seed, stratify=y
)

registry = {
    "logistic": Pipeline([("prep", prep_scaled), ("clf", LogisticRegression(max_iter=500, random_state=seed))]),
    "rf": Pipeline([("prep", prep_tree), ("clf", RandomForestClassifier(n_estimators=150, random_state=seed, n_jobs=-1))]),
    "lgbm": Pipeline([("prep", prep_tree), ("clf", LGBMClassifier(n_estimators=150, learning_rate=0.05, random_state=seed, verbose=-1, n_jobs=-1))]),
    "linear_svc": Pipeline([("prep", prep_scaled), ("clf", LinearSVC(random_state=seed, max_iter=2000))]),
    "mlp": Pipeline([("prep", prep_scaled), ("clf", MLPClassifier(hidden_layer_sizes=(64, 32), activation="relu", early_stopping=True, max_iter=300, random_state=seed))]),
}

rows = []
for name in models:
    if name not in registry:
        raise ValueError(f"Unsupported model key: {name}")
    pipe = registry[name]
    t0 = time.perf_counter()
    pipe.fit(X_train, y_train)
    elapsed_ms = (time.perf_counter() - t0) * 1000.0
    preds = pipe.predict(X_test)
    rows.append({
        "model": name,
        "accuracy": round(float(accuracy_score(y_test, preds)), 4),
        "precision": round(float(precision_score(y_test, preds, average="weighted", zero_division=0)), 4),
        "recall": round(float(recall_score(y_test, preds, average="weighted", zero_division=0)), 4),
        "f1_score": round(float(f1_score(y_test, preds, average="weighted", zero_division=0)), 4),
        "train_time_ms": round(elapsed_ms, 2),
    })

rows.sort(key=lambda r: r["f1_score"], reverse=True)
print(json.dumps(rows))
'# | save -f $tmp_py

  let res = ^/opt/modern-ml/bin/python $tmp_py $tmp_in $target $models_csv ($test_size | into string) ($seed | into string) | from json
  rm -f $tmp_in $tmp_py
  $res
}

# =========================================================
# FILE & DIRECTORY LISTING HELPERS (l, lc, lo, le)
# =========================================================

# List directory contents sorted by type and name (or by size)
export def l [
  pattern?: glob
  --all(-a)
  --du(-d)
  --sort_by_size(-s)
] {
  (if ($pattern | is-empty) {
    if $all and $du {
      ls -a --du
    } else if $all {
      ls -a
    } else if $du {
      ls --du
    } else {
      ls
    }
  } else {
    if $all and $du {
      ls -a --du $pattern
    } else if $all {
      ls -a $pattern
    } else if $du {
      ls --du $pattern
    } else {
      ls $pattern
    }
  })
  | if ($du and $sort_by_size) {
      sort-by -i type name | sort-by size
    } else if $sort_by_size {
      sort-by size
    } else {
      sort-by -i type name
    }
}

# List directory contents formatted as a compact grid
export def lc [] {
  l | grid -ci name
}

# List only file names sorted by type and name
export def lo [] {
  ls | sort-by -i type name | reject type size modified
}

# List directory contents sorted by extension
export def le [] {
  ls
  | sort-by -i type name
  | insert "ext" {|item|
      $item.name
      | path parse
      | get extension
    }
  | sort-by ext
}

