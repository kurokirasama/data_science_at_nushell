#!/usr/bin/env Rscript
df <- read.csv("wine.csv", stringsAsFactors = FALSE)
num_cols <- setdiff(names(df), c("type", "quality"))
pca <- prcomp(df[, num_cols], center = TRUE, scale. = TRUE)
var_exp <- (pca$sdev^2) / sum(pca$sdev^2) * 100

# Save loadings summary to stdout as CSV
out <- data.frame(
  component = paste0("PC", 1:5),
  std_dev = round(pca$sdev[1:5], 4),
  pct_variance = round(var_exp[1:5], 2),
  cum_variance = round(cumsum(var_exp)[1:5], 2)
)
write.csv(out, stdout(), row.names = FALSE, quote = FALSE)

# Also save 2D coordinates to wine_pca_r.csv
coords <- data.frame(
  pc1 = round(pca$x[, 1], 4),
  pc2 = round(pca$x[, 2], 4),
  type = df$type,
  quality = df$quality
)
write.csv(coords, "wine_pca_r.csv", row.names = FALSE, quote = FALSE)
