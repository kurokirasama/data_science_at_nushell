#!/usr/bin/env Rscript
suppressPackageStartupMessages(library(ggplot2))
df <- read.csv("tips.csv")
p <- ggplot(df, aes(x = bill, y = tip, color = size)) +
  geom_point() +
  facet_wrap(~day) +
  theme_minimal()
ggsave("tips.png", plot = p, width = 7, height = 4.5, dpi = 120)
ggsave("tips_faceted.png", plot = p, width = 7, height = 4.5, dpi = 120)
