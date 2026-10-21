#!/usr/bin/env Rscript
suppressPackageStartupMessages(library(ggplot2))
df <- read.csv("tips.csv")
p <- ggplot(df, aes(x = time, fill = time)) +
  geom_bar() +
  labs(title = "Recuento de observaciones por horario", x = "Horario (time)", y = "Frecuencia") +
  theme_minimal()
ggsave("plot-bar.png", plot = p, width = 6, height = 4, dpi = 120)
ggsave("tips_bar.png", plot = p, width = 6, height = 4, dpi = 120)
