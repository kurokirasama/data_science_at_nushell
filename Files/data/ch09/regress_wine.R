#!/usr/bin/env Rscript
set.seed(42)
df <- read.csv("wine-white.csv", stringsAsFactors = FALSE)
n <- nrow(df)
idx <- sample(seq_len(n), size = floor(0.8 * n))
train <- df[idx, ]
test  <- df[-idx, ]

fit <- lm(quality ~ ., data = train)
preds <- predict(fit, newdata = test)

# Save predictions vs observed
res_df <- data.frame(
  observed = test$quality,
  predicted = round(preds, 4),
  abs_error = round(abs(test$quality - preds), 4)
)
write.csv(
  res_df, "wine_lm_predictions_r.csv",
  row.names = FALSE, quote = FALSE
)

# Output model coefficients to stdout as CSV
coefs <- summary(fit)$coefficients
out <- data.frame(
  term = rownames(coefs),
  estimate = round(coefs[, "Estimate"], 5),
  std_error = round(coefs[, "Std. Error"], 5),
  t_value = round(coefs[, "t value"], 3),
  t_stat = round(coefs[, "t value"], 3),
  p_value = signif(coefs[, "Pr(>|t|)"], 4)
)
write.csv(out, stdout(), row.names = FALSE, quote = FALSE)
