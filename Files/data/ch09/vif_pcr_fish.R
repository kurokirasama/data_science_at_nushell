#!/usr/bin/env Rscript
df <- read.csv("Fish.csv")
pred_cols <- c("Length1", "Length2", "Length3", "Height", "Width")
X <- df[, pred_cols]
y <- df$Weight

fit_ols <- lm(Weight ~ ., data = df[, c(pred_cols, "Weight")])
r2_ols <- summary(fit_ols)$r.squared
rmse_ols <- sqrt(mean(residuals(fit_ols)^2))

pca <- prcomp(X, scale. = TRUE)
fit_pcr <- lm(y ~ pca$x[, 1:2])
r2_pcr <- summary(fit_pcr)$r.squared
rmse_pcr <- sqrt(mean(residuals(fit_pcr)^2))

out_comp <- data.frame(
  model = c("R_OLS_Multiple_Regression", "R_PCR_Principal_Components"),
  components = c(5, 2),
  r2 = round(c(r2_ols, r2_pcr), 4),
  rmse = round(c(rmse_ols, rmse_pcr), 2)
)
write.csv(out_comp, "fish_pcr_r.csv", row.names = FALSE, quote = FALSE)
write.csv(out_comp, stdout(), row.names = FALSE, quote = FALSE)
