#!/usr/bin/env Rscript
suppressPackageStartupMessages(library(class))
set.seed(42)
df <- read.csv("banco.csv")
features <- c(
  "edad", "ingreso", "familia",
  "gasto_tarjeta", "educacion", "hipoteca"
)
X <- scale(df[, features])
y <- df$prestamo

n <- nrow(X)
train_idx <- sample(seq_len(n), size = floor(0.8 * n))
train_x <- X[train_idx, ]
test_x  <- X[-train_idx, ]
train_y <- y[train_idx]
test_y  <- y[-train_idx]

rows <- list()
for (k in c(3, 5, 7)) {
  preds <- knn(
    train = train_x, test = test_x, cl = train_y, k = k
  )
  tbl <- table(test_y, preds)
  acc <- sum(diag(tbl)) / sum(tbl)
  has_r1 <- "1" %in% rownames(tbl)
  has_r0 <- "0" %in% rownames(tbl)
  has_c1 <- "1" %in% colnames(tbl)
  has_c0 <- "0" %in% colnames(tbl)
  tp <- if (has_r1 && has_c1) tbl["1", "1"] else 0
  fp <- if (has_r0 && has_c1) tbl["0", "1"] else 0
  fn <- if (has_r1 && has_c0) tbl["1", "0"] else 0
  prec <- if (tp + fp > 0) tp / (tp + fp) else 0
  rec <- if (tp + fn > 0) tp / (tp + fn) else 0
  f1 <- if (prec + rec > 0) 2 * prec * rec / (prec + rec) else 0
  rows[[length(rows) + 1]] <- data.frame(
    model = "R_knn",
    k_neighbors = k,
    accuracy = round(acc, 4),
    precision = round(prec, 4),
    recall = round(rec, 4),
    f1_score = round(f1, 4)
  )
}
out <- do.call(rbind, rows)
write.csv(out, "banco_knn_r.csv", row.names = FALSE, quote = FALSE)
write.csv(out, stdout(), row.names = FALSE, quote = FALSE)
