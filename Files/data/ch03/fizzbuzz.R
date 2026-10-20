#!/usr/bin/env Rscript
cycle_of_15 <- c("fizzbuzz", NA, NA, "fizz", NA,
                 "buzz", "fizz", NA, NA, "fizz",
                 "buzz", NA, "fizz", NA, NA)

fizz_buzz <- function(n) {
  word <- cycle_of_15[as.integer(n) %% 15 + 1]
  ifelse(is.na(word), n, word)
}

lines <- readLines(file("stdin"), warn = FALSE)
lines <- lines[nzchar(trimws(lines))]
for (n in lines) {
  cat(fizz_buzz(n), "\n", sep = "")
}
