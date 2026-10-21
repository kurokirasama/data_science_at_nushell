#!/usr/bin/env Rscript
train <- read.csv("train/features.csv", stringsAsFactors = FALSE)
test  <- read.csv("test/features.csv", stringsAsFactors = FALSE)

train$target <- ifelse(train$type == "red", 1, 0)
test$target  <- ifelse(test$type == "red", 1, 0)

predictors <- setdiff(names(train), c("id", "type", "target"))
formula_str <- paste("target ~", paste(predictors, collapse = " + "))

fit <- glm(as.formula(formula_str), data = train, family = binomial(link = "logit"))
probs <- predict(fit, newdata = test, type = "response")
preds <- ifelse(probs >= 0.5, 1, 0)

tp <- sum(preds == 1 & test$target == 1)
tn <- sum(preds == 0 & test$target == 0)
fp <- sum(preds == 1 & test$target == 0)
fn <- sum(preds == 0 & test$target == 1)

acc <- (tp + tn) / nrow(test)
prec <- tp / (tp + fp)
rec <- tp / (tp + fn)
f1 <- 2 * prec * rec / (prec + rec)

out <- data.frame(
  model = "R_glm_binomial",
  accuracy = round(acc, 4),
  precision_red = round(prec, 4),
  recall_red = round(rec, 4),
  f1_red = round(f1, 4),
  tp = tp, tn = tn, fp = fp, fn = fn
)
write.csv(out, "wine_clf_r.csv", row.names = FALSE, quote = FALSE)
write.csv(out, stdout(), row.names = FALSE, quote = FALSE)
