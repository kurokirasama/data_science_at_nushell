#!/usr/bin/env Rscript
df <- read.csv("tips.csv", stringsAsFactors = FALSE)
df$percent <- round(df$tip / df$bill * 100, 2)
write.csv(df, "percent.csv", row.names = FALSE, quote = FALSE)
tryCatch(write.csv(df, stdout(), row.names = FALSE, quote = FALSE), error = function(e) invisible(NULL))
