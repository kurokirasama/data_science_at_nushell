#!/usr/bin/env Rscript
# Clustering Jerárquico Aglomerativo (Ward.D2)
df <- read.csv("Fish.csv", stringsAsFactors = FALSE)
num_cols <- c("Weight", "Length1", "Length2", "Length3", "Height", "Width")
X <- scale(df[, num_cols])

d <- dist(X, method = "euclidean")
hc <- hclust(d, method = "ward.D2")
df$cluster <- paste0("cluster_", cutree(hc, k = 3))

write.csv(df[, c("Species", "Weight", "Height", "Width", "cluster")], "fish_hclust_r.csv", row.names = FALSE, quote = FALSE)

tab <- as.data.frame.matrix(table(df$cluster, df$Species))
out <- data.frame(
  cluster = rownames(tab),
  total_samples = as.integer(rowSums(tab)),
  dominant_species = colnames(tab)[max.col(tab, ties.method = "first")],
  dominant_count = apply(tab, 1, max)
)
write.csv(out, stdout(), row.names = FALSE, quote = FALSE)
