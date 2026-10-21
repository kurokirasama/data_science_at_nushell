#!/usr/bin/env Rscript
df <- read.csv("tips.csv", stringsAsFactors = FALSE)
df$pct_tip <- (df$tip / df$bill) * 100
agg <- aggregate(cbind(bill, tip, pct_tip) ~ day + time, data = df, FUN = function(x) c(mean = mean(x), sd = sd(x), median = median(x), iqr = IQR(x)))
out <- data.frame(
  day = agg$day,
  time = agg$time,
  bill_mean = round(agg$bill[, "mean"], 2),
  bill_sd = round(agg$bill[, "sd"], 2),
  tip_mean = round(agg$tip[, "mean"], 2),
  mean_tip = round(agg$tip[, "mean"], 2),
  tip_median = round(agg$tip[, "median"], 2),
  pct_tip_mean = round(agg$pct_tip[, "mean"], 2),
  pct_tip_iqr = round(agg$pct_tip[, "iqr"], 2)
)
write.csv(out, stdout(), row.names = FALSE, quote = FALSE)
