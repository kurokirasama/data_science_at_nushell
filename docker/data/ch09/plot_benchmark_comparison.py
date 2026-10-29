#!/opt/modern-ml/bin/python
"""Render multi-model F1, accuracy, and training latency charts."""
import json
import os
import subprocess
import sys
import tempfile
import warnings

os.environ.setdefault("OMP_NUM_THREADS", "4")
os.environ.setdefault("MPLCONFIGDIR", "/tmp/matplotlib_cache")
warnings.filterwarnings("ignore")

import matplotlib
matplotlib.use("Agg")
import matplotlib.pyplot as plt
import numpy as np
import pandas as pd


def load_benchmark(src):
    if src.endswith(".json") and os.path.exists(src):
        return pd.read_json(src)

    df_raw = pd.read_csv(src)
    drop_c = [c for c in ("ID", "ZIP_cod") if c in df_raw.columns]
    df_clean = df_raw.drop(columns=drop_c)
    tgt = "prestamo" if "prestamo" in df_clean.columns else "type"

    with tempfile.NamedTemporaryFile(
        mode="w", suffix=".csv", delete=False
    ) as tmp:
        df_clean.to_csv(tmp.name, index=False)
        tmp_path = tmp.name

    script_dir = os.path.dirname(os.path.abspath(__file__))
    bench_py = os.path.join(script_dir, "ml_benchmark.py")
    cmd = [
        sys.executable, bench_py,
        "--input", tmp_path,
        "--target", tgt,
        "--models", "logistic,linear_svc,mlp,rf,lgbm",
    ]
    raw_out = subprocess.check_output(cmd, text=True)
    os.remove(tmp_path)
    return pd.DataFrame(json.loads(raw_out))


def main():
    src = sys.argv[1] if len(sys.argv) > 1 else "banco.csv"
    png_out = (
        sys.argv[2] if len(sys.argv) > 2
        else "benchmark_comparison.png"
    )
    df = load_benchmark(src).sort_values(
        "f1_score", ascending=True
    )

    fig, (ax1, ax2) = plt.subplots(
        1, 2, figsize=(11.2, 4.3), dpi=130
    )
    x = np.arange(len(df))
    w = 0.36

    b1 = ax1.bar(
        x - w / 2, df["f1_score"], w,
        label="Weighted F1", color="#0284c7"
    )
    ax1.bar(
        x + w / 2, df["accuracy"], w,
        label="Accuracy", color="#0f766e"
    )
    min_sc = float(df[["f1_score", "accuracy"]].min().min())
    ax1.set_ylim(max(0.0, min_sc - 0.04), 1.015)
    ax1.set_xticks(x)
    ax1.set_xticklabels(df["model"])
    ax1.set_title("Classification Metrics", fontweight="bold")
    ax1.set_ylabel("Score")
    ax1.legend(loc="lower right", frameon=True)
    ax1.grid(True, axis="y", ls="--", lw=0.4, alpha=0.5)
    for b in b1:
        h = b.get_height()
        ax1.text(
            b.get_x() + b.get_width() / 2, h + 0.002,
            f"{h:.3f}", ha="center", va="bottom", fontsize=7.5
        )

    bars_t = ax2.barh(
        df["model"], df["train_time_ms"], color="#be123c"
    )
    ax2.set_title("Training Latency (ms)", fontweight="bold")
    ax2.set_xlabel("Wall-Clock Time (ms)")
    max_ms = float(df["train_time_ms"].max())
    ax2.set_xlim(0, max_ms * 1.25)
    ax2.grid(True, axis="x", ls="--", lw=0.4, alpha=0.5)
    for b in bars_t:
        wt = b.get_width()
        ax2.text(
            wt + max_ms * 0.02,
            b.get_y() + b.get_height() / 2,
            f"{wt:.0f} ms", va="center", fontsize=8
        )

    fig.suptitle(
        "Multi-Model Tabular Classification Benchmark",
        fontsize=11.5, fontweight="bold", y=1.01
    )
    fig.tight_layout()
    fig.savefig(png_out, bbox_inches="tight", dpi=130)
    best = df.iloc[-1]
    print(
        f"Saved {png_out} (best={best['model']}: "
        f"F1={best['f1_score']:.4f})"
    )


if __name__ == "__main__":
    main()
