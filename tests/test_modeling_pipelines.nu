#!/usr/bin/env nu
# Test Suite for Chapter 9: 4-Family Polyglot Modeling Pipelines (CLI, Rscript .R, Python .py -> Nushell Tables)
use ~/.config/nushell/nu_modules/dsin_tools.nu *

def main [
    --mutate # Run mutation test by corrupting input column names
] {
    cd /data/ch09
    let raw_wine = (open wine-both.csv | first 300)
    let wine = if $mutate {
        $raw_wine | reject quality type
    } else {
        $raw_wine
    }

    mut results = []

    # 1a. Dimensionality Reduction (PCA & t-SNE) — External CLI (tapkee-reduce)
    let c1a = (try {
        if not ("type" in ($wine | columns)) { error make { msg: "Missing type" } }
        let res_pca = ($wine | tapkee-reduce --method pca --label-col type)
        let res_tsne = ($wine | first 100 | tapkee-reduce --method t-sne --label-col type)
        (($res_pca | length) == 300) and ("dim_1" in ($res_pca | columns)) and (($res_tsne | length) == 100) and ("dim_2" in ($res_tsne | columns))
    } catch { false })
    $results = ($results | append { test: "1a_dimred_cli_tapkee_pca_tsne", passed: $c1a })

    # 1b. Dimensionality Reduction — Rscript (pca_wine.R) -> Nushell table
    let c1b = (try {
        if $mutate { error make { msg: "Mutated" } }
        let res = (Rscript pca_wine.R | from csv)
        (($res | length) == 5) and ("component" in ($res | columns)) and ("pct_variance" in ($res | columns))
    } catch { false })
    $results = ($results | append { test: "1b_dimred_rscript_pca_wine", passed: $c1b })

    # 1c. Dimensionality Reduction — Python (pca_wine.py) -> Nushell table
    let c1c = (try {
        if $mutate { error make { msg: "Mutated" } }
        let res = (python3 pca_wine.py | from csv)
        (($res | length) == 5) and ("component" in ($res | columns)) and ("cum_variance" in ($res | columns))
    } catch { false })
    $results = ($results | append { test: "1c_dimred_python_pca_wine", passed: $c1c })

    # 2a. Clustering (K-Means) — CLI command (kmeans-cluster) -> Nushell table
    let c2a = (try {
        if not ("type" in ($wine | columns)) { error make { msg: "Missing type" } }
        let res = ($wine | kmeans-cluster --k 2)
        (($res | length) == 300) and ("cluster" in ($res | columns))
    } catch { false })
    $results = ($results | append { test: "2a_clustering_cli_kmeans", passed: $c2a })

    # 2b. Clustering (K-Means) — Rscript (cluster_wine.R) -> Nushell table
    let c2b = (try {
        if $mutate { error make { msg: "Mutated" } }
        let res = (Rscript cluster_wine.R | from csv)
        (($res | length) == 2) and ("cluster" in ($res | columns)) and ("dominant_type" in ($res | columns))
    } catch { false })
    $results = ($results | append { test: "2b_clustering_rscript_cluster_wine", passed: $c2b })

    # 2c. Clustering (K-Means) — Python (cluster_wine.py) -> Nushell table
    let c2c = (try {
        if $mutate { error make { msg: "Mutated" } }
        let res = (python3 cluster_wine.py | from csv)
        (($res | length) == 4) and ("k_clusters" in ($res | columns)) and ("silhouette" in ($res | columns))
    } catch { false })
    $results = ($results | append { test: "2c_clustering_python_cluster_wine", passed: $c2c })

    # 3a. Regression — External CLI (Vowpal Wabbit vw-regress) -> Nushell table
    let c3a = (try {
        if not ("quality" in ($wine | columns)) { error make { msg: "Missing quality" } }
        let train = ($wine | reject type | first 240)
        let test = ($wine | reject type | last 60)
        let preds = (vw-regress $train $test --target quality --passes 5)
        let mae = ($preds | get abs_error | math avg)
        (($preds | length) == 60) and ("predicted" in ($preds | columns)) and ($mae > 0)
    } catch { false })
    $results = ($results | append { test: "3a_regression_cli_vw", passed: $c3a })

    # 3b. Regression — Rscript (regress_wine.R) -> Nushell table
    let c3b = (try {
        if $mutate { error make { msg: "Mutated" } }
        let res = (Rscript regress_wine.R | from csv)
        (($res | length) >= 10) and ("term" in ($res | columns)) and ("t_stat" in ($res | columns))
    } catch { false })
    $results = ($results | append { test: "3b_regression_rscript_regress_wine", passed: $c3b })

    # 3c. Regression — Python (regress_wine.py) -> Nushell table
    let c3c = (try {
        if $mutate { error make { msg: "Mutated" } }
        let res = (python3 regress_wine.py | from csv)
        (($res | length) == 2) and ("mae" in ($res | columns)) and ("rmse" in ($res | columns))
    } catch { false })
    $results = ($results | append { test: "3c_regression_python_regress_wine", passed: $c3c })

    # 4a. Classification — External CLI (SKLL run_experiment + skll-metrics) -> Nushell table
    let c4a = (try {
        if $mutate { error make { msg: "Mutated" } }
        run_experiment -l classify.cfg out+err> /dev/null
        let res = (skll-metrics output/wine_summary.tsv)
        (($res | length) >= 4) and (($res | get accuracy | math max) > 0.8)
    } catch { false })
    $results = ($results | append { test: "4a_classification_cli_skll", passed: $c4a })

    # 4b. Classification — Rscript (classify_wine.R) -> Nushell table
    let c4b = (try {
        if $mutate { error make { msg: "Mutated" } }
        let res = (Rscript classify_wine.R | from csv)
        (($res | length) == 1) and (($res | first | get accuracy) > 0.9)
    } catch { false })
    $results = ($results | append { test: "4b_classification_rscript_classify_wine", passed: $c4b })

    # 4c. Classification — Python (classify_wine.py) -> Nushell table
    let c4c = (try {
        if $mutate { error make { msg: "Mutated" } }
        let res = (python3 classify_wine.py | from csv)
        (($res | length) == 2) and (($res | get accuracy | math min) > 0.95)
    } catch { false })
    $results = ($results | append { test: "4c_classification_python_classify_wine", passed: $c4c })

    # 5a. Minería de Datos: Hierarchical Clustering (hclust_fish.R & hclust_fish.py)
    let c5a = (try {
        if $mutate { error make { msg: "Mutated" } }
        let res_r = (Rscript hclust_fish.R | from csv)
        let res_py = (python3 hclust_fish.py | from csv)
        (("dominant_species" in ($res_r | columns)) and ("silhouette" in ($res_py | columns)))
    } catch { false })
    $results = ($results | append { test: "5a_mineria_hierarchical_clustering", passed: $c5a })

    # 5b. Minería de Datos: Multi-metric Optimal K Evaluation (cluster_eval.py)
    let c5b = (try {
        if $mutate { error make { msg: "Mutated" } }
        let res = (python3 cluster_eval.py | from csv)
        (($res | length) == 5) and ("calinski_harabasz" in ($res | columns))
    } catch { false })
    $results = ($results | append { test: "5b_mineria_optimal_k_eval", passed: $c5b })

    # 5c. Minería de Datos: Decision Trees (dt_banco.R & dt_banco.py)
    let c5c = (try {
        if $mutate { error make { msg: "Mutated" } }
        let res_r = (Rscript dt_banco.R | from csv)
        let res_py = (python3 dt_banco.py | from csv)
        (($res_r | first | get accuracy) > 0.85) and (($res_py | first | get accuracy) > 0.85)
    } catch { false })
    $results = ($results | append { test: "5c_mineria_decision_trees", passed: $c5c })

    # 5d. Minería de Datos: k-NN (knn_banco.R & knn_banco.py)
    let c5d = (try {
        if $mutate { error make { msg: "Mutated" } }
        let res_r = (Rscript knn_banco.R | from csv)
        let res_py = (python3 knn_banco.py | from csv)
        (($res_r | length) == 3) and (($res_py | length) == 3)
    } catch { false })
    $results = ($results | append { test: "5d_mineria_knn", passed: $c5d })

    # 5e. Minería de Datos: Naïve Bayes & SVM (nb_svm_banco.py)
    let c5e = (try {
        if $mutate { error make { msg: "Mutated" } }
        let res = (python3 nb_svm_banco.py | from csv)
        (($res | length) == 2) and (($res | first | get accuracy) > 0.85)
    } catch { false })
    $results = ($results | append { test: "5e_mineria_nb_svm", passed: $c5e })

    # 6a. UNAB / Guías: Multicollinearity (VIF) & Principal Component Regression (PCR)
    let c6a = (try {
        if $mutate { error make { msg: "Mutated" } }
        let res_py = (python3 vif_pcr_fish.py | from csv)
        let res_r = (Rscript vif_pcr_fish.R | from csv)
        let vif_res = (open fish_vif_py.csv)
        (($res_py | length) == 2) and (($res_r | length) == 2) and (($vif_res | length) == 5) and (($res_py | get r2 | math max) > 0.8)
    } catch { false })
    $results = ($results | append { test: "6a_mineria_unab_vif_pcr", passed: $c6a })

    # 6b. UNAB / Guías: Density Clustering (DBSCAN) & K-Medoids (PAM)
    let c6b = (try {
        if $mutate { error make { msg: "Mutated" } }
        let res_db = (python3 dbscan_fish.py | from csv)
        let res_pam = (Rscript pam_fish.R | from csv)
        (($res_db | length) >= 2) and ("cluster_type" in ($res_db | columns)) and (($res_pam | length) == 1) and (($res_pam | first | get avg_silhouette) > 0.3)
    } catch { false })
    $results = ($results | append { test: "6b_mineria_unab_dbscan_pam", passed: $c6b })

    # 6c. UNAB / Guías: Multi-Layer Perceptron Neural Networks (MLP)
    let c6c = (try {
        if $mutate { error make { msg: "Mutated" } }
        let res_py = (python3 mlp_banco.py | from csv)
        let res_r = (Rscript mlp_banco.R | from csv)
        (($res_py | length) == 2) and (($res_py | get accuracy | math max) > 0.95) and (($res_r | first | get accuracy) > 0.9)
    } catch { false })
    $results = ($results | append { test: "6c_mineria_unab_mlp_neuralnet", passed: $c6c })

    print ($results | to md)
    let failed = ($results | where passed == false | length)
    if $mutate {
        print $"Mutation check: ($failed) / ($results | length) tests caught the mutation."
        if $failed == 0 { exit 1 } else { exit 0 }
    } else {
        if $failed > 0 { exit 1 } else { exit 0 }
    }
}
