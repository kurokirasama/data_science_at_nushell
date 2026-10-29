#!/usr/bin/env python
"""Extract split-count and gain importance from a LightGBM model."""
import json
import sys
import lightgbm as lgb


def main():
    if len(sys.argv) < 2:
        sys.stderr.write(
            "Usage: lgbm_importance.py <model_file.txt>\n"
        )
        sys.exit(1)

    model_file = sys.argv[1]
    booster = lgb.Booster(model_file=model_file)
    names = booster.feature_name()
    splits = booster.feature_importance(importance_type="split")
    gains = booster.feature_importance(importance_type="gain")
    tot = float(gains.sum())
    total_gain = tot if tot > 0 else 1.0

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


if __name__ == "__main__":
    main()
