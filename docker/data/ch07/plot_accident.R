#!/usr/bin/env Rscript
suppressPackageStartupMessages(library(ggplot2))
df <- read.csv("tips.csv")
p <- ggplot(df, aes(x = tip, y = bill, color = size)) +
  geom_path() +
  labs(title = "Geometria erronea: geom_path en observaciones independientes") +
  theme_minimal()
ggsave("plot-accident.png", plot = p, width = 6, height = 4, dpi = 120)
ggsave("fatalities_line.png", plot = p, width = 6, height = 4, dpi = 120)
