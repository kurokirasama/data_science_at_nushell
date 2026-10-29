#!/usr/bin/env Rscript
set.seed(42)
df <- read.csv("wine.csv", stringsAsFactors = FALSE)
num_cols <- setdiff(names(df), c("type", "quality"))
X <- scale(df[, num_cols])

km <- kmeans(X, centers = 2, nstart = 20)
df$cluster <- paste0("cluster_", km$cluster)

keep_cols <- c(
  "type", "quality", "alcohol", "volatile_acidity", "cluster"
)
write.csv(
  df[, keep_cols], "wine_kmeans_r.csv",
  row.names = FALSE, quote = FALSE
)

tab <- as.data.frame.matrix(table(df$cluster, df$type))
out <- data.frame(
  cluster = rownames(tab),
  size = as.integer(km$size),
  withinss = round(km$withinss, 2),
  red_count = tab$red,
  white_count = tab$white,
  dominant_type = ifelse(tab$red > tab$white, "red", "white")
)
write.csv(out, stdout(), row.names = FALSE, quote = FALSE)
