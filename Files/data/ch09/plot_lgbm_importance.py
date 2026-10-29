#!/opt/modern-ml/bin/python
"""Render LightGBM feature gain and split counts."""
import os
import sys
import warnings

os.environ.setdefault("MPLCONFIGDIR", "/tmp/matplotlib_cache")
warnings.filterwarnings("ignore")

import lightgbm as lgb
import matplotlib
matplotlib.use("Agg")
import matplotlib.pyplot as plt
import pandas as pd


def load_importance(src):
    if src.endswith(".json"):
        return pd.read_json(src)
    if src.endswith(".txt"):
        booster = lgb.Booster(model_file=src)
    else:
        df = pd.read_csv(src).iloc[:3500]
        drop_c = [
            c for c in ("type", "quality") if c in df.columns
        ]
        X = df.drop(columns=drop_c)
        y = df["quality"]
        dtrain = lgb.Dataset(X, label=y)
        params = {
            "objective": "regression",
            "learning_rate": 0.05,
            "num_leaves": 31,
            "seed": 42,
            "num_threads": 4,
            "force_col_wise": True,
            "verbosity": -1,
        }
        booster = lgb.train(params, dtrain, num_boost_round=100)

    gains = booster.feature_importance(importance_type="gain")
    splits = booster.feature_importance(importance_type="split")
    tot = float(gains.sum()) if float(gains.sum()) > 0 else 1.0
    return pd.DataFrame({
        "feature": booster.feature_name(),
        "splits": splits,
        "gain_pct": gains * 100.0 / tot,
    })


def main():
    src = sys.argv[1] if len(sys.argv) > 1 else "wine-white.csv"
    png_out = (
        sys.argv[2] if len(sys.argv) > 2 else "lgbm_importance.png"
    )
    df = load_importance(src).sort_values(
        "gain_pct", ascending=True
    )

    fig, (ax1, ax2) = plt.subplots(
        1, 2, figsize=(11.0, 4.4), dpi=130
    )

    bars1 = ax1.barh(
        df["feature"], df["gain_pct"], color="#0284c7"
    )
    ax1.set_title("Relative Split Gain (%)", fontweight="bold")
    ax1.set_xlabel("Share of Squared-Error Reduction (%)")
    ax1.set_xlim(0, float(df["gain_pct"].max()) * 1.22)
    ax1.grid(True, axis="x", ls="--", lw=0.4, alpha=0.5)
    for b in bars1:
        w = b.get_width()
        ax1.text(
            w + 0.5, b.get_y() + b.get_height() / 2,
            f"{w:.1f}%", va="center", fontsize=8
        )

    ax2.barh(df["feature"], df["splits"], color="#0f766e")
    ax2.set_title("Interior Split Frequency", fontweight="bold")
    ax2.set_xlabel("Total Splits Across 100 Trees")
    ax2.set_yticks([])
    ax2.grid(True, axis="x", ls="--", lw=0.4, alpha=0.5)

    fig.suptitle(
        "LightGBM Feature Importance Diagnostics (wine-white.csv)",
        fontsize=11.5, fontweight="bold", y=1.01
    )
    fig.tight_layout()
    fig.savefig(png_out, bbox_inches="tight", dpi=130)
    top_f = df.iloc[-1]["feature"]
    top_g = df.iloc[-1]["gain_pct"]
    print(f"Saved {png_out} (top={top_f}: {top_g:.2f}%)")


if __name__ == "__main__":
    main()
