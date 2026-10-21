#!/usr/bin/env Rscript
suppressPackageStartupMessages(library(ggplot2))
df <- read.csv("tips.csv")
p <- ggplot(df, aes(x = tip, fill = time)) +
  geom_density(alpha = 0.5) +
  labs(title = "Densidad de propinas por horario", x = "Propina (USD)", y = "Densidad") +
  theme_minimal()
ggsave("plot-density.png", plot = p, width = 6, height = 4, dpi = 120)
ggsave("tips_density.png", plot = p, width = 6, height = 4, dpi = 120)
