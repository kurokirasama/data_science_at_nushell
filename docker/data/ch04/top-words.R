#!/usr/bin/env Rscript
args <- commandArgs(trailingOnly = TRUE)
n <- if (length(args) >= 1) as.integer(args[1]) else 10L

stopwords <- if (file.exists("stopwords")) readLines("stopwords", warn = FALSE) else character(0)

f_text <- file("stdin")
lines <- tolower(readLines(f_text, warn = FALSE))
close(f_text)

words <- unlist(regmatches(lines, gregexpr("[a-z\x27]{2,}", lines)))
words <- words[!(words %in% stopwords)]

counts <- sort(table(words), decreasing = TRUE)
top_n <- head(counts, n)
cat("count,word\n")
cat(sprintf("%d,%s\n", as.integer(top_n), names(top_n)), sep = "")
