#!/usr/bin/env Rscript
suppressPackageStartupMessages(library(ggplot2))
df <- read.csv("tips.csv")
p <- ggplot(df, aes(x = factor(size), y = bill, fill = factor(size))) +
  geom_violin(alpha = 0.7) +
  labs(
    title = "Distribucion del importe de la factura por tamano del grupo",
    x = "Tamano del grupo",
    y = "Factura (USD)"
  ) +
  theme_minimal()
ggsave("plot-labels.png", plot = p, width = 6.5, height = 4.2, dpi = 120)
ggsave("tips_violin.png", plot = p, width = 6.5, height = 4.2, dpi = 120)
