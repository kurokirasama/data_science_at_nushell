#!/opt/modern-ml/bin/python
"""Render OLS residual diagnostics on wine-white.csv."""
import os
import sys
import warnings

os.environ.setdefault("MPLCONFIGDIR", "/tmp/matplotlib_cache")
warnings.filterwarnings("ignore")

import matplotlib
matplotlib.use("Agg")
import matplotlib.pyplot as plt
import numpy as np
import pandas as pd
from sklearn.linear_model import LinearRegression
from sklearn.metrics import r2_score


def main():
    csv_in = sys.argv[1] if len(sys.argv) > 1 else "wine-white.csv"
    png_out = (
        sys.argv[2] if len(sys.argv) > 2 else "wine_residuals.png"
    )

    df = pd.read_csv(csv_in)
    drop_c = [c for c in ("type", "quality") if c in df.columns]
    X = df.drop(columns=drop_c).select_dtypes(
        include=[np.number]
    )
    y = df["quality"].to_numpy(dtype=float)

    ols = LinearRegression().fit(X, y)
    y_hat = ols.predict(X)
    resid = y - y_hat
    r2 = r2_score(y, y_hat)
    sigma = float(np.std(resid, ddof=X.shape[1] + 1))

    fig, (ax1, ax2) = plt.subplots(
        1, 2, figsize=(10.5, 4.2), dpi=130
    )

    ax1.scatter(
        y_hat, resid, s=10, alpha=0.28,
        color="#0284c7", edgecolors="none"
    )
    ax1.axhline(0.0, color="#be123c", ls="--", lw=1.4)
    ax1.set_title("Residuals vs. Fitted Values", fontweight="bold")
    ax1.set_xlabel("Fitted Sensory Quality")
    ax1.set_ylabel("Residual (Observed - Fitted)")
    ax1.grid(True, ls="--", lw=0.4, alpha=0.5)

    ax2.hist(
        resid, bins=32, density=True,
        color="#0f766e", alpha=0.72, edgecolor="white"
    )
    grid_x = np.linspace(resid.min(), resid.max(), 200)
    gauss = np.exp(-0.5 * (grid_x / sigma) ** 2) / (
        sigma * np.sqrt(2.0 * np.pi)
    )
    ax2.plot(
        grid_x, gauss, color="#be123c", lw=1.8,
        label=f"Normal (sd={sigma:.2f})"
    )
    ax2.set_title("Residual Error Distribution", fontweight="bold")
    ax2.set_xlabel("Residual")
    ax2.set_ylabel("Density")
    ax2.legend(loc="best", frameon=True)
    ax2.grid(True, ls="--", lw=0.4, alpha=0.5)

    fig.suptitle(
        f"Multivariate OLS Diagnostics ({csv_in}, R2 = {r2:.3f})",
        fontsize=11.5, fontweight="bold", y=1.01
    )
    fig.tight_layout()
    fig.savefig(png_out, bbox_inches="tight", dpi=130)
    print(f"Saved {png_out} (R2={r2:.4f}, sd={sigma:.4f})")


if __name__ == "__main__":
    main()
