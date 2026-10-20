# =========================================================
# Data Science at Nushell (dsin) — Polyglot & Modeling Helpers
# =========================================================

# Convert a Nushell table into Vowpal Wabbit (VW) line format.
export def to-vw [
  --target(-t): string = "quality" # Name of target column
  --namespace(-n): string = "f"    # Feature namespace label
]: table -> list<string> {
  let tbl = $in
  let cols = ($tbl | columns | where $it != $target)
  $tbl | each { |row|
    let y = ($row | get $target)
    let feats = ($cols | each { |c| $"($c):($row | get $c)" } | str join " ")
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
  let tmp_dir = (mktemp -d)
  let train_vw = $"($tmp_dir)/train.vw"
  let test_vw = $"($tmp_dir)/test.vw"
  let model_file = $"($tmp_dir)/model.vw"
  let pred_file = $"($tmp_dir)/preds.txt"

  $train_tbl | to-vw --target $target | str join "\n" | save -f $train_vw
  $test_tbl | to-vw --target $target | str join "\n" | save -f $test_vw

  ^vw --data $train_vw --final_regressor $model_file --passes $passes -l $learning_rate --cache_file $"($tmp_dir)/train.cache" --quiet
  ^vw --data $test_vw -i $model_file -t -p $pred_file --quiet

  let preds = (open --raw $pred_file | lines | where ($it | str trim | is-not-empty) | each { |x| $x | into float })
  let actuals = ($test_tbl | get $target | each { |x| $x | into float })

  rm -rf $tmp_dir

  $actuals | zip $preds | each { |pair|
    let obs = $pair.0
    let pred = ($pair.1 | math round -p 4)
    let err = (($obs - $pred) | math abs | math round -p 4)
    { observed: $obs, predicted: $pred, abs_error: $err }
  }
}

# Run Tapkee dimensionality reduction on a numeric Nushell table and return a structured table.
export def tapkee-reduce [
  --method(-m): string = "pca" # Tapkee method: pca, ltsa, isomap, mds, tsne, lle
  --target-dim(-d): int = 2    # Number of output dimensions
  --label-col(-l): string      # Optional label column to preserve alongside coordinates
]: table -> table {
  let tbl = $in
  let labels = if ($label_col | is-not-empty) and ($label_col in ($tbl | columns)) {
    $tbl | get $label_col
  } else { [] }
  let num_tbl = if ($label_col | is-not-empty) and ($label_col in ($tbl | columns)) {
    $tbl | reject $label_col
  } else { $tbl }

  let tmp_in = (mktemp --suffix ".csv")
  let tmp_out = (mktemp --suffix ".tsv")
  $num_tbl | to csv --noheaders | save -f $tmp_in

  ^tapkee -i $tmp_in -o $tmp_out -m $method -td $target_dim --delimiter ","
  let raw_coords = (open --raw $tmp_out | lines | where ($it | str trim | is-not-empty))
  rm -f $tmp_in $tmp_out

  let coords_tbl = ($raw_coords | each { |line|
    let parts = ($line | split row "," | each { |v| $v | str trim | into float | math round -p 4 })
    mut rec = {}
    for idx in 0..<($parts | length) {
      $rec = ($rec | insert $"dim($idx + 1)" ($parts | get $idx))
    }
    $rec
  })

  if ($labels | is-not-empty) {
    $coords_tbl | zip $labels | each { |p| $p.0 | insert $label_col $p.1 }
  } else {
    $coords_tbl
  }
}
