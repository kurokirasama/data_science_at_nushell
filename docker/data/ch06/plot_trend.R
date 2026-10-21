#!/usr/bin/env Rscript
suppressPackageStartupMessages(library(ggplot2))
df <- read.csv("tips.csv")
p1 <- ggplot(df, aes(x = bill, y = tip, color = time)) +
  geom_smooth(method = "loess", formula = y ~ x) +
  theme_minimal()
ggsave("plot-trend.png", plot = p1, width = 6, height = 4, dpi = 120)

p2 <- ggplot(df, aes(x = bill, y = tip, color = time)) +
  geom_point(alpha = 0.6) +
  geom_smooth(method = "loess", formula = y ~ x) +
  theme_minimal()
ggsave("plot-trend-points.png", plot = p2, width = 6, height = 4, dpi = 120)
ggsave("tips_trend.png", plot = p2, width = 6, height = 4, dpi = 120)
