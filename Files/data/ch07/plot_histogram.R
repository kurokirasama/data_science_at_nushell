#!/usr/bin/env Rscript
suppressPackageStartupMessages(library(ggplot2))
df <- read.csv("tips.csv")
p <- ggplot(df, aes(x = tip, fill = time)) +
  geom_histogram(bins = 20, alpha = 0.85) +
  labs(title = "Histograma apilado de propinas por horario", x = "Propina (USD)", y = "Frecuencia") +
  theme_minimal()
ggsave("plot-histogram.png", plot = p, width = 6, height = 4, dpi = 120)
ggsave("tips_histogram.png", plot = p, width = 6, height = 4, dpi = 120)
