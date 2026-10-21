#!/usr/bin/env Rscript
suppressPackageStartupMessages(library(ggplot2))
df <- read.csv("wine.csv")
p1 <- ggplot(df, aes(x = quality, fill = type)) +
  geom_density(adjust = 3, alpha = 0.5) +
  labs(title = "Distribucion de Calidad por Tipo de Vino", x = "Calidad", y = "Densidad") +
  theme_minimal()
ggsave("wine-quality.png", plot = p1, width = 6, height = 4, dpi = 120)
ggsave("wine_eda.png", plot = p1, width = 6, height = 4, dpi = 120)

p2 <- ggplot(df, aes(x = alcohol, y = quality, color = type)) +
  geom_smooth(method = "loess", formula = y ~ x) +
  labs(title = "Relacion entre Alcohol y Calidad por Tipo de Vino", x = "Alcohol (%)", y = "Calidad") +
  theme_minimal()
ggsave("wine-alcohol-vs-quality.png", plot = p2, width = 6, height = 4, dpi = 120)
