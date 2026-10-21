#!/usr/bin/env Rscript
suppressPackageStartupMessages(library(cluster))
df <- read.csv("Fish.csv")
num_cols <- c("Weight", "Length1", "Length2", "Length3", "Height", "Width")
X <- scale(df[, num_cols])

fit_pam <- pam(X, k = 3, metric = "euclidean")
sil <- silhouette(fit_pam)
avg_sil <- mean(sil[, 3])

out <- data.frame(
  model = "R_cluster_pam_kmedoids",
  k_clusters = 3,
  avg_silhouette = round(avg_sil, 4),
  cluster_1_size = fit_pam$clusinfo[1, 1],
  cluster_2_size = fit_pam$clusinfo[2, 1],
  cluster_3_size = fit_pam$clusinfo[3, 1]
)
write.csv(out, "fish_pam_r.csv", row.names = FALSE, quote = FALSE)
write.csv(out, stdout(), row.names = FALSE, quote = FALSE)
