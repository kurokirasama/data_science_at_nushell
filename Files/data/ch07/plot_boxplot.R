#!/usr/bin/env Rscript
suppressPackageStartupMessages(library(ggplot2))
df <- read.csv("tips.csv")
p <- ggplot(df, aes(x = factor(size), y = bill, fill = factor(size))) +
  geom_boxplot() +
  labs(x = "factor(size)", y = "bill") +
  theme_minimal()
ggsave("plot-boxplot.png", plot = p, width = 6, height = 4, dpi = 120)
ggsave("tips_boxplot.png", plot = p, width = 6, height = 4, dpi = 120)
