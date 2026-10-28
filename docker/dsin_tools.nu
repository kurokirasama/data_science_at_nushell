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
  --neighbors(-n): int = 15
  --min-dist(-m): float = 0.1
  --target-dim(-d): int = 2
  --seed(-s): int = 42
  --label-col(-l): string = "type"
  --cols(-c): list<string>
]: table -> table {
  let tbl = $in
  let cols_flag = if ($cols != null) and (($cols | length) > 0) {
    ["--cols" ($cols | str join ",")]
  } else { [] }

  let tmp_in = (mktemp --suffix ".csv")
  $tbl | to csv | save -f $tmp_in

  let py_script = if ("/usr/local/bin/umap-reduce-py" | path exists) {
    "/usr/local/bin/umap-reduce-py"
  } else if ("/data/ch09/umap_reduce.py" | path exists) {
    "/data/ch09/umap_reduce.py"
  } else {
    "umap_reduce.py"
  }

  let res = (python $py_script
    --input $tmp_in
    --neighbors $neighbors
    --min-dist $min_dist
    --target-dim $target_dim
    --seed $seed
    --label-col $label_col
    ...$cols_flag | from csv)

  rm -f $tmp_in
  $res
}

# Train and evaluate LightGBM C++ CLI regression on Nushell tables.
export def lgbm-regress [
  train_tbl: table
  test_tbl: table
  --target(-t): string = "quality"
  --num-trees(-n): int = 100
  --learning-rate(-l): float = 0.05
  --num-leaves: int = 31
  --importance(-i)
]: nothing -> table {
  let tmp_dir = (mktemp -d)
  let train_csv = $"($tmp_dir)/train.csv"
  let test_csv = $"($tmp_dir)/test_features.csv"
  let model_file = $"($tmp_dir)/model.txt"
  let pred_file = $"($tmp_dir)/preds.txt"

  let feat_cols = ($train_tbl | columns | where $it != $target)
  $train_tbl | select ...($feat_cols | append $target) | to csv | save -f $train_csv
  $test_tbl | select ...$feat_cols | to csv | save -f $test_csv

  let lgbm_train_args = [
    "task=train"
    "objective=regression"
    $"data=($train_csv)"
    "header=true"
    $"label_column=name:($target)"
    $"num_trees=($num_trees)"
    $"learning_rate=($learning_rate)"
    $"num_leaves=($num_leaves)"
    "seed=42"
    "force_col_wise=true"
    $"output_model=($model_file)"
    "verbosity=-1"
  ]
  ^lightgbm ...$lgbm_train_args out+err> /dev/null

  if $importance {
    let py_imp = if ("/usr/local/bin/lgbm-importance" | path exists) {
      "/usr/local/bin/lgbm-importance"
    } else if ("/data/ch09/lgbm_importance.py" | path exists) {
      "/data/ch09/lgbm_importance.py"
    } else {
      "lgbm_importance.py"
    }
    let imp_tbl = (python $py_imp $model_file | from json)
    rm -rf $tmp_dir
    return $imp_tbl
  }

  let lgbm_pred_args = [
    "task=predict"
    $"data=($test_csv)"
    "header=true"
    $"input_model=($model_file)"
    $"output_result=($pred_file)"
    "verbosity=-1"
  ]
  ^lightgbm ...$lgbm_pred_args out+err> /dev/null

  let preds = (open --raw $pred_file | lines |
    where ($it | str trim | is-not-empty) | each { into float })
  let actuals = ($test_tbl | get $target | each { into float })
  rm -rf $tmp_dir

  $actuals | zip $preds | each { |pair|
    let obs = $pair.0
    let pred = ($pair.1 | math round -p 4)
    let signed_err = (($pred - $obs) | math round -p 4)
    let abs_err = (($obs - $pred) | math abs | math round -p 4)
    { actual: $obs, observed: $obs, predicted: $pred,
      error: $signed_err, abs_error: $abs_err }
  }
}

# Compute vectorized Ordinary Least Squares regression diagnostics via DuckDB CLI.
export def duckdb-ols [
  --target(-y): string = "quality"
  --predictor(-x): string = ""
]: table -> table {
  let tbl = $in
  let first_row = ($tbl | first)
  let candidate_cols = if ($predictor | is-not-empty) {
    [$predictor]
  } else {
    $tbl | columns | where { |c|
      let val_type = ($first_row | get $c | describe)
      ($c != $target) and (($val_type == "int") or ($val_type == "float"))
    }
  }

  let tmp_csv = (mktemp --suffix ".csv")
  $tbl | select ...($candidate_cols | append $target) | to csv | save -f $tmp_csv

  let unions = ($candidate_cols | each { |col|
    [
      $"SELECT '($col)' AS predictor, "
      $"ROUND\(regr_slope\(\"($target)\", \"($col)\"\), 4\) AS slope, "
      $"ROUND\(regr_intercept\(\"($target)\", \"($col)\"\), 4\) AS intercept, "
      $"ROUND\(corr\(\"($target)\", \"($col)\"\), 4\) AS pearson_r, "
      $"ROUND\(regr_r2\(\"($target)\", \"($col)\"\), 4\) AS r_squared, "
      $"CAST\(regr_count\(\"($target)\", \"($col)\"\) AS BIGINT\) AS n FROM tbl"
    ] | str join ""
  } | str join " UNION ALL ")

  let sql = [
    $"CREATE TEMP TABLE tbl AS SELECT * FROM read_csv_auto\('($tmp_csv)'\); "
    $"SELECT * FROM \(($unions)\) ORDER BY r_squared DESC;"
  ] | str join ""

  let res = (^duckdb -json -c $sql | from json)
  rm -f $tmp_csv
  $res
}

# Benchmark multiple classification architectures on streaming Nushell tables.
export def ml-benchmark [
  --target(-t): string = "type"
  --models(-m): list<string> = ["logistic", "rf", "lgbm", "linear_svc", "mlp"]
  --test-size: float = 0.25
  --seed(-s): int = 42
]: table -> table {
  let tbl = $in
  let models_csv = ($models | str join ",")
  let tmp_in = (mktemp --suffix ".csv")
  $tbl | to csv | save -f $tmp_in

  let py_bench = if ("/usr/local/bin/ml-benchmark-py" | path exists) {
    "/usr/local/bin/ml-benchmark-py"
  } else if ("/data/ch09/ml_benchmark.py" | path exists) {
    "/data/ch09/ml_benchmark.py"
  } else {
    "ml_benchmark.py"
  }

  let res = (python $py_bench
    --input $tmp_in
    --target $target
    --models $models_csv
    --test-size $test_size
    --seed $seed | from json)

  rm -f $tmp_in
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

