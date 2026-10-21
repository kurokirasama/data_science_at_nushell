#!/usr/bin/env Rscript
suppressPackageStartupMessages(library(ggplot2))
df <- read.csv("tips.csv")
p <- ggplot(df, aes(x = bill, y = tip, color = time)) +
  geom_point(alpha = 0.8) +
  labs(title = "Diagrama de dispersion: Factura vs Propina", x = "Factura (USD)", y = "Propina (USD)") +
  theme_minimal()
ggsave("plot-scatter.png", plot = p, width = 6, height = 4, dpi = 120)
ggsave("tips_scatter.png", plot = p, width = 6, height = 4, dpi = 120)
