#!/usr/bin/env nu
# =============================================================================
# setup_data_folders.nu — Builds clean /data/ch03..ch09 matching section numbers
# =============================================================================

let src_files = "/home/kira/Dropbox/Documentos/Clases/UBB/DataScienceAtTheCommandLine/Files"
let src_data = $"($src_files)/data"
let dst_data = "/home/kira/Dropbox/Documentos/Clases/UBB/DataScienceAtNushell/Files/data"
let docker_data = "/home/kira/Dropbox/Documentos/Clases/UBB/DataScienceAtNushell/docker/data"

rm -rf $dst_data
mkdir $dst_data
mkdir $"($dst_data)/ch03"
mkdir $"($dst_data)/ch04"
mkdir $"($dst_data)/ch05"
mkdir $"($dst_data)/ch06"
mkdir $"($dst_data)/ch07"
mkdir $"($dst_data)/ch08"
mkdir $"($dst_data)/ch09"
mkdir $"($dst_data)/.cache"

# Extract .cache from cache.7z
^7z x $"($src_data)/cache.7z" $"-o($dst_data)" -y | ignore

# -----------------------------------------------------------------------------
# ch03: Section 3 (Fundamentos y Estructuras de Datos en Nushell)
# -----------------------------------------------------------------------------
^cp -a $"($src_data)/ch02/." $"($dst_data)/ch03/"
'{"edition": 2024}' | from json | to json --indent 2 | save -f $"($dst_data)/ch03/edition.json"
rm -f $"($dst_data)/ch03/fac.py.bak" $"($dst_data)/ch03/edition2.json" $"($dst_data)/ch03/edition2.csv" $"($dst_data)/ch03/edition2.yaml"
cp $"($src_data)/ch07/tips.csv" $"($dst_data)/ch03/tips.csv"
cp $"($src_data)/ch04/stream.py" $"($dst_data)/ch03/stream.py"

# -----------------------------------------------------------------------------
# ch04: Section 4 (Programación y Creación de Herramientas de Línea de Comandos)
# -----------------------------------------------------------------------------
^cp -a $"($src_data)/ch04/." $"($dst_data)/ch04/"

# Fix top-words.py and top-words.R to use python3 and local stopwords file
'#!/usr/bin/env python3
import re
import sys
from collections import Counter
from pathlib import Path

def top_words(text, n):
    sw_path = Path("stopwords")
    if sw_path.exists():
        stopwords = set(sw_path.read_text(encoding="utf-8").splitlines())
    else:
        stopwords = set()

    words = re.findall(r"[a-z\x27]{2,}", text.lower())
    words = (w for w in words if w not in stopwords)

    for word, count in Counter(words).most_common(n):
        print(f"{count},{word}")

if __name__ == "__main__":
    text = sys.stdin.read()
    n = int(sys.argv[1]) if len(sys.argv) > 1 else 10
    print("count,word")
    top_words(text, n)
' | save -f $"($dst_data)/ch04/top-words.py"

'#!/usr/bin/env Rscript
args <- commandArgs(trailingOnly = TRUE)
n <- if (length(args) >= 1) as.integer(args[1]) else 10L

stopwords <- if (file.exists("stopwords")) readLines("stopwords", warn = FALSE) else character(0)

f_text <- file("stdin")
lines <- tolower(readLines(f_text, warn = FALSE))
close(f_text)

words <- unlist(regmatches(lines, gregexpr("[a-z\x27]{2,}", lines)))
words <- words[!(words %in% stopwords)]

counts <- sort(table(words), decreasing = TRUE)
top_n <- head(counts, n)
cat("count,word\n")
cat(sprintf("%d,%s\n", as.integer(top_n), names(top_n)), sep = "")
' | save -f $"($dst_data)/ch04/top-words.R"

'#!/usr/bin/env python3
import sys

CYCLE_OF_15 = ["fizzbuzz", None, None, "fizz", None,
               "buzz", "fizz", None, None, "fizz",
               "buzz", None, "fizz", None, None]

def fizz_buzz(n: int) -> str:
    return CYCLE_OF_15[n % 15] or str(n)

if __name__ == "__main__":
    for line in sys.stdin:
        line = line.strip()
        if line:
            print(fizz_buzz(int(line)))
' | save -f $"($dst_data)/ch04/fizzbuzz.py"

'#!/usr/bin/env Rscript
cycle_of_15 <- c("fizzbuzz", NA, NA, "fizz", NA,
                 "buzz", "fizz", NA, NA, "fizz",
                 "buzz", NA, "fizz", NA, NA)

fizz_buzz <- function(n) {
  word <- cycle_of_15[as.integer(n) %% 15 + 1]
  ifelse(is.na(word), n, word)
}

lines <- readLines(file("stdin"), warn = FALSE)
lines <- lines[nzchar(trimws(lines))]
for (n in lines) {
  cat(fizz_buzz(n), "\n", sep = "")
}
' | save -f $"($dst_data)/ch04/fizzbuzz.R"

# Create Nushell top-words progression files in ch04
'open --raw alice.txt
| str lowercase
| parse --regex "(?P<word>[a-z]{2,})"
| get word
| uniq -c
| sort-by count --reverse
| first 10
' | save -f $"($dst_data)/ch04/top-words-1.nu"

cp $"($dst_data)/ch04/top-words-1.nu" $"($dst_data)/ch04/top-words-2.nu"

'#!/usr/bin/env nu
open --raw alice.txt
| str lowercase
| parse --regex "(?P<word>[a-z]{2,})"
| get word
| uniq -c
| sort-by count --reverse
| first 10
' | save -f $"($dst_data)/ch04/top-words-3.nu"

'#!/usr/bin/env -S nu --stdin
def main [] {
    $in
    | str lowercase
    | parse --regex "(?P<word>[a-z]{2,})"
    | get word
    | uniq -c
    | sort-by count --reverse
    | first 10
}
' | save -f $"($dst_data)/ch04/top-words-4.nu"

'#!/usr/bin/env -S nu --stdin

# Extrae las palabras más frecuentes de un texto excluyendo stopwords
def main [
    num_words: int = 10 # Número de palabras frecuentes a retornar
    --stopwords-file (-s): path = "stopwords" # Archivo de palabras vacías
] {
    let input_text = $in
    let sw = if ($stopwords_file | path exists) {
        open --raw $stopwords_file | lines | each { str trim | str lowercase }
    } else {
        []
    }
    $input_text
    | str lowercase
    | parse --regex "(?P<word>[a-z]{2,})"
    | get word
    | where { |w| not ($w in $sw) }
    | uniq -c
    | rename word count
    | sort-by count --reverse
    | first $num_words
}
' | save -f $"($dst_data)/ch04/top-words-5.nu"
cp $"($dst_data)/ch04/top-words-5.nu" $"($dst_data)/ch04/top-words.nu"

# stats_utils.nu, maps.nu, osm_maps.nu in ch04
'# Módulo de utilidades estadísticas para Ciencia de Datos en Nushell

export def resumen-columna [col: string]: table -> record {
    let vals = ($in | get $col)
    {
        columna: $col
        n: ($vals | length)
        media: ($vals | math avg | math round --precision 3)
        mediana: ($vals | math median | math round --precision 3)
        desv_est: ($vals | math stddev | math round --precision 3)
        minimo: ($vals | math min)
        maximo: ($vals | math max)
    }
}

export def filtrar-outliers [col: string, --z-max: float = 2.5]: table -> table {
    let tbl = $in
    let mu = ($tbl | get $col | math avg)
    let sd = ($tbl | get $col | math stddev)
    $tbl | where { |row| ((($row | get $col) - $mu) | math abs) <= ($z_max * $sd) }
}
' | save -f $"($dst_data)/ch04/stats_utils.nu"

'# Módulo de geocodificación con la API de Google Maps

export def loc-from-address [
    address: string
    --api-key (-k): string = "the_api_key"
] {
    let url = {
        scheme: "https"
        host: "maps.googleapis.com"
        path: "/maps/api/geocode/json"
        params: {
            address: $address
            key: $api_key
        }
    } | url join

    http get $url | get results.geometry.location
}

export def address-from-loc [
    latitude: number
    longitude: number
    --api-key (-k): string = "the_api_key"
] {
    let url = {
        scheme: "https"
        host: "maps.googleapis.com"
        path: "/maps/api/geocode/json"
        params: {
            latlng: $"($latitude),($longitude)"
            key: $api_key
        }
    } | url join

    let response = (http get $url)
    if $response.status != "OK" {
        error make -u {msg: "address not found!"}
    }
    $response.results.0.formatted_address
}
' | save -f $"($dst_data)/ch04/maps.nu"

chmod +x $"($dst_data)/ch04/top-words.py" $"($dst_data)/ch04/top-words.R" $"($dst_data)/ch04/fizzbuzz.py" $"($dst_data)/ch04/fizzbuzz.R" $"($dst_data)/ch04/top-words-2.nu" $"($dst_data)/ch04/top-words-3.nu" $"($dst_data)/ch04/top-words-4.nu" $"($dst_data)/ch04/top-words-5.nu" $"($dst_data)/ch04/top-words.nu"

# -----------------------------------------------------------------------------
# ch05: Section 5 (Obtención de Datos)
# -----------------------------------------------------------------------------
^cp -a $"($src_data)/ch03/." $"($dst_data)/ch05/"
rm -f $"($dst_data)/ch05/wikimedia-stream-samplecd"

{
    urls: [
        "https://jsonplaceholder.typicode.com/posts/1"
        "https://jsonplaceholder.typicode.com/posts/2"
        "https://jsonplaceholder.typicode.com/posts/3"
    ]
} | to json | save -f $"($dst_data)/ch05/urls.json"

[
    {userId: 1, id: 1, title: "sunt aut facere repellat provident", body: "quia et suscipit\nsuscipit recusandae consequuntur"}
    {userId: 1, id: 2, title: "qui est esse", body: "est rerum tempore vitae\nsequi sint nihil"}
    {userId: 1, id: 3, title: "ea molestias quasi exercitationem", body: "et iusto sed quo iure\nvoluptatem occaecati"}
    {userId: 1, id: 4, title: "eum et est occaecati", body: "ullam et saepe reiciendis voluptatem"}
    {userId: 1, id: 5, title: "nesciunt quas odio", body: "repudiandae veniam quaerat sunt sed"}
] | to json | save -f $"($dst_data)/ch05/posts_sample.json"

mkdir $"($dst_data)/ch05/.secret"
"demo_newsapi_key_12345" | save -f $"($dst_data)/ch05/.secret/newsapi.org_apikey"

# -----------------------------------------------------------------------------
# ch06: Section 6 (Depuración y Transformación de Datos)
# -----------------------------------------------------------------------------
^cp -a $"($src_data)/ch05/." $"($dst_data)/ch06/"
cp $"($dst_data)/ch04/fizzbuzz.py" $"($dst_data)/ch06/fizzbuzz.py"
cp $"($src_files)/vgsales.csv" $"($dst_data)/ch06/vgsales.csv"
rm -f $"($dst_data)/ch06/bills.csv" $"($dst_data)/ch06/customers.csv" $"($dst_data)/ch06/datetime.csv" $"($dst_data)/ch06/data_by_year.csv" $"($dst_data)/ch06/vgsales_filtered.csv" $"($dst_data)/ch06/fb.cnt" $"($dst_data)/ch06/fb.csv" $"($dst_data)/ch06/fb.png" $"($dst_data)/ch06/fb.seq" $"($dst_data)/ch06/Rplots.pdf" $"($dst_data)/ch06/table.html" $"($dst_data)/ch06/table.json"

# -----------------------------------------------------------------------------
# ch07: Section 7 (Exploración de Datos y Visualización en la Terminal)
# -----------------------------------------------------------------------------
^cp -a $"($src_data)/ch07/." $"($dst_data)/ch07/"
rm -f $"($dst_data)/ch07/plot-accident.png" $"($dst_data)/ch07/plot-bar.png" $"($dst_data)/ch07/plot-boxplot.png" $"($dst_data)/ch07/plot-density.png" $"($dst_data)/ch07/plot-histogram.png" $"($dst_data)/ch07/plot-labels.png" $"($dst_data)/ch07/plot-scatter.png" $"($dst_data)/ch07/plot-trend.png" $"($dst_data)/ch07/plot-trend-points.png" $"($dst_data)/ch07/tips.png" $"($dst_data)/ch07/tips2.png" $"($dst_data)/ch07/percent.csv" $"($dst_data)/ch07/.Rhistory" $"($dst_data)/ch07/docker_environment.txt"

# Create standalone R and Python scripts for Section 7 (no inline scripts!)
'#!/usr/bin/env Rscript
df <- read.csv("tips.csv", stringsAsFactors = FALSE)
df$percent <- round(df$tip / df$bill * 100, 2)
write.csv(df, "percent.csv", row.names = FALSE, quote = FALSE)
tryCatch(write.csv(df, stdout(), row.names = FALSE, quote = FALSE), error = function(e) invisible(NULL))
' | save -f $"($dst_data)/ch07/mutate_tips.R"

'#!/usr/bin/env Rscript
df <- read.csv("tips.csv", stringsAsFactors = FALSE)
df$pct_tip <- (df$tip / df$bill) * 100
agg <- aggregate(cbind(bill, tip, pct_tip) ~ day + time, data = df, FUN = function(x) c(mean = mean(x), sd = sd(x), median = median(x), iqr = IQR(x)))
out <- data.frame(
  day = agg$day,
  time = agg$time,
  bill_mean = round(agg$bill[, "mean"], 2),
  bill_sd = round(agg$bill[, "sd"], 2),
  tip_mean = round(agg$tip[, "mean"], 2),
  mean_tip = round(agg$tip[, "mean"], 2),
  tip_median = round(agg$tip[, "median"], 2),
  pct_tip_mean = round(agg$pct_tip[, "mean"], 2),
  pct_tip_iqr = round(agg$pct_tip[, "iqr"], 2)
)
write.csv(out, stdout(), row.names = FALSE, quote = FALSE)
' | save -f $"($dst_data)/ch07/summary_tips.R"

'#!/usr/bin/env python3
import pandas as pd
import sys

df = pd.read_csv("tips.csv")
df["pct_tip"] = df["tip"] / df["bill"] * 100.0
corr = df[["bill", "tip", "size", "pct_tip"]].corr().round(4)
corr.index.name = "variable"
corr.reset_index().to_csv(sys.stdout, index=False)
' | save -f $"($dst_data)/ch07/corr_tips.py"

'#!/usr/bin/env Rscript
suppressPackageStartupMessages(library(ggplot2))
df <- read.csv("tips.csv")
p <- ggplot(df, aes(x = bill, y = tip, color = size)) +
  geom_point() +
  facet_wrap(~day) +
  theme_minimal()
ggsave("tips.png", plot = p, width = 7, height = 4.5, dpi = 120)
ggsave("tips_faceted.png", plot = p, width = 7, height = 4.5, dpi = 120)
' | save -f $"($dst_data)/ch07/plot_faceted.R"

'#!/usr/bin/env Rscript
suppressPackageStartupMessages(library(ggplot2))
df <- read.csv("tips.csv")
p <- ggplot(df, aes(x = time, fill = time)) +
  geom_bar() +
  labs(title = "Recuento de observaciones por horario", x = "Horario (time)", y = "Frecuencia") +
  theme_minimal()
ggsave("plot-bar.png", plot = p, width = 6, height = 4, dpi = 120)
ggsave("tips_bar.png", plot = p, width = 6, height = 4, dpi = 120)
' | save -f $"($dst_data)/ch07/plot_bar.R"

'#!/usr/bin/env Rscript
suppressPackageStartupMessages(library(ggplot2))
df <- read.csv("tips.csv")
p <- ggplot(df, aes(x = tip, fill = time)) +
  geom_histogram(bins = 20, alpha = 0.85) +
  labs(title = "Histograma apilado de propinas por horario", x = "Propina (USD)", y = "Frecuencia") +
  theme_minimal()
ggsave("plot-histogram.png", plot = p, width = 6, height = 4, dpi = 120)
ggsave("tips_histogram.png", plot = p, width = 6, height = 4, dpi = 120)
' | save -f $"($dst_data)/ch07/plot_histogram.R"

'#!/usr/bin/env Rscript
suppressPackageStartupMessages(library(ggplot2))
df <- read.csv("tips.csv")
p <- ggplot(df, aes(x = tip, fill = time)) +
  geom_density(alpha = 0.5) +
  labs(title = "Densidad de propinas por horario", x = "Propina (USD)", y = "Densidad") +
  theme_minimal()
ggsave("plot-density.png", plot = p, width = 6, height = 4, dpi = 120)
ggsave("tips_density.png", plot = p, width = 6, height = 4, dpi = 120)
' | save -f $"($dst_data)/ch07/plot_density.R"

'#!/usr/bin/env Rscript
suppressPackageStartupMessages(library(ggplot2))
df <- read.csv("tips.csv")
p <- ggplot(df, aes(x = tip, y = bill, color = size)) +
  geom_path() +
  labs(title = "Geometria erronea: geom_path en observaciones independientes") +
  theme_minimal()
ggsave("plot-accident.png", plot = p, width = 6, height = 4, dpi = 120)
ggsave("fatalities_line.png", plot = p, width = 6, height = 4, dpi = 120)
' | save -f $"($dst_data)/ch07/plot_accident.R"

'#!/usr/bin/env Rscript
suppressPackageStartupMessages(library(ggplot2))
df <- read.csv("tips.csv")
p <- ggplot(df, aes(x = bill, y = tip, color = time)) +
  geom_point(alpha = 0.8) +
  labs(title = "Diagrama de dispersion: Factura vs Propina", x = "Factura (USD)", y = "Propina (USD)") +
  theme_minimal()
ggsave("plot-scatter.png", plot = p, width = 6, height = 4, dpi = 120)
ggsave("tips_scatter.png", plot = p, width = 6, height = 4, dpi = 120)
' | save -f $"($dst_data)/ch07/plot_scatter.R"

'#!/usr/bin/env Rscript
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
' | save -f $"($dst_data)/ch07/plot_trend.R"

'#!/usr/bin/env Rscript
suppressPackageStartupMessages(library(ggplot2))
df <- read.csv("tips.csv")
p <- ggplot(df, aes(x = factor(size), y = bill, fill = factor(size))) +
  geom_boxplot() +
  labs(x = "factor(size)", y = "bill") +
  theme_minimal()
ggsave("plot-boxplot.png", plot = p, width = 6, height = 4, dpi = 120)
ggsave("tips_boxplot.png", plot = p, width = 6, height = 4, dpi = 120)
' | save -f $"($dst_data)/ch07/plot_boxplot.R"

'#!/usr/bin/env Rscript
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
' | save -f $"($dst_data)/ch07/plot_violin.R"

'#!/usr/bin/env python3
import json
import sys
import pandas as pd
import matplotlib
matplotlib.use("Agg")
import matplotlib.pyplot as plt

df = pd.read_csv("tips.csv")
fig, axes = plt.subplots(1, 2, figsize=(10, 4), dpi=120)

axes[0].hist(df["bill"], bins=20, color="#10b981", edgecolor="#064e3b", alpha=0.85)
axes[0].set_title("Distribucion de Factura (Python / Matplotlib)")
axes[0].set_xlabel("Monto de Factura (USD)")
axes[0].set_ylabel("Frecuencia")

for t, grp in df.groupby("time"):
    axes[1].scatter(grp["bill"], grp["tip"], label=t, alpha=0.75)
axes[1].set_title("Propina vs Factura por Horario")
axes[1].set_xlabel("Factura (USD)")
axes[1].set_ylabel("Propina (USD)")
axes[1].legend()

plt.tight_layout()
plt.savefig("tips_python_grid.png")
plt.savefig("tips_python.png")

summary = df.groupby("day")[["bill", "tip"]].mean().round(2).reset_index().to_dict(orient="records")
print(json.dumps(summary))
' | save -f $"($dst_data)/ch07/plot_tips_py.py"

if not ($"($dst_data)/ch07/Fatalities.csv" | path exists) {
    cp $"($dst_data)/ch07/tips.csv" $"($dst_data)/ch07/Fatalities.csv"
}

glob $"($dst_data)/ch07/*.{R,py}" | each { |f| chmod +x $f }

# -----------------------------------------------------------------------------
# ch08: Section 8 (Procesamiento en Serie y Tuberías Paralelas)
# -----------------------------------------------------------------------------
^cp -a $"($src_data)/ch08/." $"($dst_data)/ch08/"
rm -rf $"($dst_data)/ch08/outdir"
rm -f $"($dst_data)/ch08/hi-1.txt" $"($dst_data)/ch08/hi-2.txt" $"($dst_data)/ch08/hi-3.txt" $"($dst_data)/ch08/hi-4.txt" $"($dst_data)/ch08/hi-5.txt" $"($dst_data)/ch08/one-big-file.txt" $"($dst_data)/ch08/emails" $"($dst_data)/ch08/emails.txt"

# Populate input.csv in ch08 with valid name,email,quantity rows
"name,email,quantity
Alicia Rivera,alicia.rivera@example.com,12
Bruno Soto,bruno.soto@example.com,25
Carla Mendez,carla.mendez@example.com,18
Diego Fuentes,diego.fuentes@example.com,30
Elena Vargas,elena.vargas@example.com,15
" | save -f $"($dst_data)/ch08/input.csv"

'#!/usr/bin/env bash
parallel --colsep "," "echo \"$1\" | bc -l"
' | save -f $"($dst_data)/ch08/pbc"
chmod +x $"($dst_data)/ch08/pbc" $"($dst_data)/ch08/slow.sh"

# -----------------------------------------------------------------------------
# ch09: Section 9 (Modelación Políglota de Datos)
# -----------------------------------------------------------------------------
^cp -a $"($src_data)/ch09/." $"($dst_data)/ch09/"
rm -rf $"($dst_data)/ch09/output"
rm -f $"($dst_data)/ch09/2026-10_hola.txt" $"($dst_data)/ch09/output.nu" $"($dst_data)/ch09/output.txt" $"($dst_data)/ch09/edition.json" $"($dst_data)/ch09/edition2.json" $"($dst_data)/ch09/edition2.csv" $"($dst_data)/ch09/edition2.yaml" $"($dst_data)/ch09/predictions" $"($dst_data)/ch09/results.csv" $"($dst_data)/ch09/wine.cache" $"($dst_data)/ch09/wine.model" $"($dst_data)/ch09/wine2.model" $"($dst_data)/ch09/wine-pca.txt" $"($dst_data)/ch09/wine-pca.png" $"($dst_data)/ch09/wine-pca.csv" $"($dst_data)/ch09/wine-alcohol-vs-quality.png" $"($dst_data)/ch09/wine-quality.png" $"($dst_data)/ch09/wine-regression.png" $"($dst_data)/ch09/wine-tsne.png" $"($dst_data)/ch09/wine-scaled.csv" $"($dst_data)/ch09/wine-balanced.csv" $"($dst_data)/ch09/wine-test.vw" $"($dst_data)/ch09/wine-train.vw" $"($dst_data)/ch09/wine-white-clean.csv" $"($dst_data)/ch09/wine-red-clean.csv"
cp $"($dst_data)/ch09/wine.csv" $"($dst_data)/ch09/wine-both.csv"
open $"($dst_data)/ch09/wine.csv" | where type == "white" | reject type | save -f $"($dst_data)/ch09/wine-white.csv"
open $"($dst_data)/ch09/wine.csv" | where type == "red" | reject type | save -f $"($dst_data)/ch09/wine-red.csv"

# Create standalone R and Python modeling scripts in ch09 (no inline scripts!)
'#!/usr/bin/env Rscript
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
' | save -f $"($dst_data)/ch09/plot_wine_eda.R"

'#!/usr/bin/env Rscript
df <- read.csv("wine.csv", stringsAsFactors = FALSE)
num_cols <- setdiff(names(df), c("type", "quality"))
pca <- prcomp(df[, num_cols], center = TRUE, scale. = TRUE)
var_exp <- (pca$sdev^2) / sum(pca$sdev^2) * 100

# Save loadings summary to stdout as CSV
out <- data.frame(
  component = paste0("PC", 1:5),
  std_dev = round(pca$sdev[1:5], 4),
  pct_variance = round(var_exp[1:5], 2),
  cum_variance = round(cumsum(var_exp)[1:5], 2)
)
write.csv(out, stdout(), row.names = FALSE, quote = FALSE)

# Also save 2D coordinates to wine_pca_r.csv
coords <- data.frame(
  pc1 = round(pca$x[, 1], 4),
  pc2 = round(pca$x[, 2], 4),
  type = df$type,
  quality = df$quality
)
write.csv(coords, "wine_pca_r.csv", row.names = FALSE, quote = FALSE)
' | save -f $"($dst_data)/ch09/pca_wine.R"

'#!/usr/bin/env python3
import pandas as pd
from sklearn.preprocessing import StandardScaler
from sklearn.decomposition import PCA
import sys

df = pd.read_csv("wine.csv")
features = [c for c in df.columns if c not in ("type", "quality")]
X = StandardScaler().fit_transform(df[features])

pca = PCA(n_components=5, random_state=42)
coords = pca.fit_transform(X)

# Save 2D projection to wine_pca_py.csv
proj = pd.DataFrame({
    "pc1": coords[:, 0].round(4),
    "pc2": coords[:, 1].round(4),
    "type": df["type"],
    "quality": df["quality"]
})
proj.to_csv("wine_pca_py.csv", index=False)

# Output variance summary as CSV to stdout
summary = pd.DataFrame({
    "component": [f"PC{i+1}" for i in range(5)],
    "explained_variance": pca.explained_variance_.round(4),
    "pct_variance": (pca.explained_variance_ratio_ * 100).round(2),
    "cum_variance": (pca.explained_variance_ratio_.cumsum() * 100).round(2)
})
summary.to_csv(sys.stdout, index=False)
' | save -f $"($dst_data)/ch09/pca_wine.py"

'#!/usr/bin/env Rscript
set.seed(42)
df <- read.csv("wine.csv", stringsAsFactors = FALSE)
num_cols <- setdiff(names(df), c("type", "quality"))
X <- scale(df[, num_cols])

km <- kmeans(X, centers = 2, nstart = 20)
df$cluster <- paste0("cluster_", km$cluster)

# Save cluster assignments
write.csv(df[, c("type", "quality", "alcohol", "volatile_acidity", "cluster")], "wine_kmeans_r.csv", row.names = FALSE, quote = FALSE)

# Output cluster summary table to stdout
tab <- as.data.frame.matrix(table(df$cluster, df$type))
out <- data.frame(
  cluster = rownames(tab),
  size = as.integer(km$size),
  withinss = round(km$withinss, 2),
  red_count = tab$red,
  white_count = tab$white,
  dominant_type = ifelse(tab$red > tab$white, "red", "white")
)
write.csv(out, stdout(), row.names = FALSE, quote = FALSE)
' | save -f $"($dst_data)/ch09/cluster_wine.R"

'#!/usr/bin/env python3
import pandas as pd
from sklearn.preprocessing import StandardScaler
from sklearn.cluster import KMeans
from sklearn.metrics import silhouette_score
import sys

df = pd.read_csv("wine.csv")
features = [c for c in df.columns if c not in ("type", "quality")]
X = StandardScaler().fit_transform(df[features])

rows = []
for k in [2, 3, 4, 5]:
    km = KMeans(n_clusters=k, n_init=10, random_state=42)
    labels = km.fit_predict(X)
    sil = silhouette_score(X, labels, sample_size=1500, random_state=42)
    if k == 2:
        df_out = df[["type", "quality", "alcohol", "volatile_acidity"]].copy()
        df_out["cluster"] = [f"cluster_{l+1}" for l in labels]
        df_out.to_csv("wine_kmeans_py.csv", index=False)
    rows.append({
        "k_clusters": k,
        "inertia": round(float(km.inertia_), 2),
        "silhouette": round(float(sil), 4),
        "iterations": int(km.n_iter_)
    })

pd.DataFrame(rows).to_csv(sys.stdout, index=False)
' | save -f $"($dst_data)/ch09/cluster_wine.py"

'#!/usr/bin/env Rscript
set.seed(42)
df <- read.csv("wine-white.csv", stringsAsFactors = FALSE)
n <- nrow(df)
idx <- sample(seq_len(n), size = floor(0.8 * n))
train <- df[idx, ]
test  <- df[-idx, ]

fit <- lm(quality ~ ., data = train)
preds <- predict(fit, newdata = test)

# Save predictions vs observed
res_df <- data.frame(
  observed = test$quality,
  predicted = round(preds, 4),
  abs_error = round(abs(test$quality - preds), 4)
)
write.csv(res_df, "wine_lm_predictions_r.csv", row.names = FALSE, quote = FALSE)

# Output model coefficients to stdout as CSV
coefs <- summary(fit)$coefficients
out <- data.frame(
  term = rownames(coefs),
  estimate = round(coefs[, "Estimate"], 5),
  std_error = round(coefs[, "Std. Error"], 5),
  t_value = round(coefs[, "t value"], 3),
  t_stat = round(coefs[, "t value"], 3),
  p_value = signif(coefs[, "Pr(>|t|)"], 4)
)
write.csv(out, stdout(), row.names = FALSE, quote = FALSE)
' | save -f $"($dst_data)/ch09/regress_wine.R"

'#!/usr/bin/env python3
import pandas as pd
import numpy as np
from sklearn.model_selection import train_test_split
from sklearn.preprocessing import StandardScaler
from sklearn.pipeline import make_pipeline
from sklearn.linear_model import Ridge
from sklearn.ensemble import RandomForestRegressor
from sklearn.metrics import mean_absolute_error, mean_squared_error, r2_score
import sys

df = pd.read_csv("wine-white.csv")
X = df.drop(columns=["quality"])
y = df["quality"]

X_train, X_test, y_train, y_test = train_test_split(X, y, test_size=0.2, random_state=42)

models = {
    "Ridge(alpha=1.0)": make_pipeline(StandardScaler(), Ridge(alpha=1.0)),
    "RandomForest(n=100)": RandomForestRegressor(n_estimators=100, random_state=42, n_jobs=-1)
}

rows = []
for name, model in models.items():
    model.fit(X_train, y_train)
    preds = model.predict(X_test)
    rows.append({
        "model": name,
        "mae": round(float(mean_absolute_error(y_test, preds)), 4),
        "rmse": round(float(np.sqrt(mean_squared_error(y_test, preds))), 4),
        "r2": round(float(r2_score(y_test, preds)), 4)
    })

out_df = pd.DataFrame(rows)
out_df.to_csv("wine_reg_metrics_py.csv", index=False)
out_df.to_csv(sys.stdout, index=False)
' | save -f $"($dst_data)/ch09/regress_wine.py"

'#!/usr/bin/env Rscript
train <- read.csv("train/features.csv", stringsAsFactors = FALSE)
test  <- read.csv("test/features.csv", stringsAsFactors = FALSE)

train$target <- ifelse(train$type == "red", 1, 0)
test$target  <- ifelse(test$type == "red", 1, 0)

predictors <- setdiff(names(train), c("id", "type", "target"))
formula_str <- paste("target ~", paste(predictors, collapse = " + "))

fit <- glm(as.formula(formula_str), data = train, family = binomial(link = "logit"))
probs <- predict(fit, newdata = test, type = "response")
preds <- ifelse(probs >= 0.5, 1, 0)

tp <- sum(preds == 1 & test$target == 1)
tn <- sum(preds == 0 & test$target == 0)
fp <- sum(preds == 1 & test$target == 0)
fn <- sum(preds == 0 & test$target == 1)

acc <- (tp + tn) / nrow(test)
prec <- tp / (tp + fp)
rec <- tp / (tp + fn)
f1 <- 2 * prec * rec / (prec + rec)

out <- data.frame(
  model = "R_glm_binomial",
  accuracy = round(acc, 4),
  precision_red = round(prec, 4),
  recall_red = round(rec, 4),
  f1_red = round(f1, 4),
  tp = tp, tn = tn, fp = fp, fn = fn
)
write.csv(out, "wine_clf_r.csv", row.names = FALSE, quote = FALSE)
write.csv(out, stdout(), row.names = FALSE, quote = FALSE)
' | save -f $"($dst_data)/ch09/classify_wine.R"

'#!/usr/bin/env python3
import pandas as pd
from sklearn.preprocessing import StandardScaler
from sklearn.pipeline import make_pipeline
from sklearn.linear_model import LogisticRegression
from sklearn.ensemble import RandomForestClassifier
from sklearn.metrics import accuracy_score, precision_score, recall_score, f1_score
import sys

train = pd.read_csv("train/features.csv")
test  = pd.read_csv("test/features.csv")

features = [c for c in train.columns if c not in ("id", "type")]
X_train, y_train = train[features], (train["type"] == "red").astype(int)
X_test,  y_test  = test[features],  (test["type"] == "red").astype(int)

models = {
    "Python_LogisticRegression": make_pipeline(StandardScaler(), LogisticRegression(max_iter=500, random_state=42)),
    "Python_RandomForestClassifier": RandomForestClassifier(n_estimators=100, random_state=42, n_jobs=-1)
}

rows = []
for name, clf in models.items():
    clf.fit(X_train, y_train)
    preds = clf.predict(X_test)
    rows.append({
        "model": name,
        "accuracy": round(float(accuracy_score(y_test, preds)), 4),
        "precision_red": round(float(precision_score(y_test, preds)), 4),
        "recall_red": round(float(recall_score(y_test, preds)), 4),
        "f1_red": round(float(f1_score(y_test, preds)), 4)
    })

out_df = pd.DataFrame(rows)
out_df.to_csv("wine_clf_py.csv", index=False)
out_df.to_csv(sys.stdout, index=False)
' | save -f $"($dst_data)/ch09/classify_wine.py"

# Copy Minería de Datos & UNAB datasets into ch09
let mineria_base = "/home/kira/Dropbox/Documentos/Clases/UBB/Mineria_de_Datos"
cp $"($mineria_base)/material_unab/mine/guias/scripts/banco.csv" $"($dst_data)/ch09/banco.csv"
cp $"($mineria_base)/material_unab/mine/guias/scripts/Fish.csv" $"($dst_data)/ch09/Fish.csv"
cp $"($mineria_base)/Files/vertebrate.csv" $"($dst_data)/ch09/vertebrate.csv"
cp $"($mineria_base)/Files/python_snippets/zoo.csv" $"($dst_data)/ch09/zoo.csv"
cp $"($mineria_base)/Files/python_snippets/pima-indians-diabetes.data.csv" $"($dst_data)/ch09/pima-indians-diabetes.data.csv"

# Hierarchical clustering (hclust) scripts on Fish.csv
'#!/usr/bin/env Rscript
# Clustering Jerárquico Aglomerativo (Ward.D2)
df <- read.csv("Fish.csv", stringsAsFactors = FALSE)
num_cols <- c("Weight", "Length1", "Length2", "Length3", "Height", "Width")
X <- scale(df[, num_cols])

d <- dist(X, method = "euclidean")
hc <- hclust(d, method = "ward.D2")
df$cluster <- paste0("cluster_", cutree(hc, k = 3))

write.csv(df[, c("Species", "Weight", "Height", "Width", "cluster")], "fish_hclust_r.csv", row.names = FALSE, quote = FALSE)

tab <- as.data.frame.matrix(table(df$cluster, df$Species))
out <- data.frame(
  cluster = rownames(tab),
  total_samples = as.integer(rowSums(tab)),
  dominant_species = colnames(tab)[max.col(tab, ties.method = "first")],
  dominant_count = apply(tab, 1, max)
)
write.csv(out, stdout(), row.names = FALSE, quote = FALSE)
' | save -f $"($dst_data)/ch09/hclust_fish.R"

'#!/usr/bin/env python3
# Clustering Jerárquico con Scikit-Learn
import pandas as pd
from sklearn.preprocessing import StandardScaler
from sklearn.cluster import AgglomerativeClustering
from sklearn.metrics import silhouette_score
import sys

df = pd.read_csv("Fish.csv")
num_cols = ["Weight", "Length1", "Length2", "Length3", "Height", "Width"]
X = StandardScaler().fit_transform(df[num_cols])

rows = []
for k in [2, 3, 4, 5]:
    model = AgglomerativeClustering(n_clusters=k, linkage="ward")
    labels = model.fit_predict(X)
    sil = silhouette_score(X, labels)
    if k == 3:
        df_out = df[["Species", "Weight", "Height", "Width"]].copy()
        df_out["cluster"] = [f"cluster_{l+1}" for l in labels]
        df_out.to_csv("fish_hclust_py.csv", index=False)
    rows.append({
        "linkage": "ward",
        "n_clusters": k,
        "silhouette": round(float(sil), 4)
    })

pd.DataFrame(rows).to_csv(sys.stdout, index=False)
' | save -f $"($dst_data)/ch09/hclust_fish.py"

# Optimal K evaluation script (Inertia, Silhouette, Calinski-Harabasz, Davies-Bouldin)
'#!/usr/bin/env python3
import pandas as pd
from sklearn.preprocessing import StandardScaler
from sklearn.cluster import KMeans
from sklearn.metrics import silhouette_score, calinski_harabasz_score, davies_bouldin_score
import sys

df = pd.read_csv("banco.csv")
features = ["edad", "ingreso", "gasto_tarjeta", "hipoteca"]
X = StandardScaler().fit_transform(df[features])

rows = []
for k in range(2, 7):
    km = KMeans(n_clusters=k, n_init=10, random_state=42)
    labels = km.fit_predict(X)
    rows.append({
        "k": k,
        "inertia": round(float(km.inertia_), 2),
        "silhouette": round(float(silhouette_score(X, labels, sample_size=1000, random_state=42)), 4),
        "calinski_harabasz": round(float(calinski_harabasz_score(X, labels)), 2),
        "davies_bouldin": round(float(davies_bouldin_score(X, labels)), 4)
    })

pd.DataFrame(rows).to_csv(sys.stdout, index=False)
' | save -f $"($dst_data)/ch09/cluster_eval.py"

# Decision Tree classification (R and Python)
'#!/usr/bin/env Rscript
suppressPackageStartupMessages(library(rpart))
set.seed(42)
df <- read.csv("banco.csv")
features <- c("edad", "ingreso", "familia", "gasto_tarjeta", "educacion", "hipoteca", "prestamo")
df_sub <- df[, features]

n <- nrow(df_sub)
train_idx <- sample(seq_len(n), size = floor(0.8 * n))
train <- df_sub[train_idx, ]
test  <- df_sub[-train_idx, ]

fit <- rpart(prestamo ~ ., data = train, method = "class", control = rpart.control(maxdepth = 4))
preds <- predict(fit, newdata = test, type = "class")

tbl <- table(test$prestamo, preds)
acc <- sum(diag(tbl)) / sum(tbl)
tp <- if ("1" %in% rownames(tbl) && "1" %in% colnames(tbl)) tbl["1", "1"] else 0
fp <- if ("0" %in% rownames(tbl) && "1" %in% colnames(tbl)) tbl["0", "1"] else 0
fn <- if ("1" %in% rownames(tbl) && "0" %in% colnames(tbl)) tbl["1", "0"] else 0
prec <- if (tp + fp > 0) tp / (tp + fp) else 0
rec <- if (tp + fn > 0) tp / (tp + fn) else 0
f1 <- if (prec + rec > 0) 2 * prec * rec / (prec + rec) else 0

out <- data.frame(
  model = "R_rpart_decision_tree",
  max_depth = 4,
  accuracy = round(acc, 4),
  precision = round(prec, 4),
  recall = round(rec, 4),
  f1_score = round(f1, 4)
)
write.csv(out, "banco_dt_r.csv", row.names = FALSE, quote = FALSE)
write.csv(out, stdout(), row.names = FALSE, quote = FALSE)
' | save -f $"($dst_data)/ch09/dt_banco.R"

'#!/usr/bin/env python3
import pandas as pd
from sklearn.model_selection import train_test_split
from sklearn.tree import DecisionTreeClassifier
from sklearn.metrics import accuracy_score, precision_score, recall_score, f1_score
import sys

df = pd.read_csv("banco.csv")
features = ["edad", "ingreso", "familia", "gasto_tarjeta", "educacion", "hipoteca"]
X = df[features]
y = df["prestamo"]

X_train, X_test, y_train, y_test = train_test_split(X, y, test_size=0.2, random_state=42)

clf = DecisionTreeClassifier(max_depth=4, random_state=42)
clf.fit(X_train, y_train)
preds = clf.predict(X_test)

out = pd.DataFrame([{
    "model": "Python_DecisionTreeClassifier",
    "max_depth": 4,
    "accuracy": round(float(accuracy_score(y_test, preds)), 4),
    "precision": round(float(precision_score(y_test, preds, zero_division=0)), 4),
    "recall": round(float(recall_score(y_test, preds, zero_division=0)), 4),
    "f1_score": round(float(f1_score(y_test, preds, zero_division=0)), 4)
}])
out.to_csv("banco_dt_py.csv", index=False)
out.to_csv(sys.stdout, index=False)
' | save -f $"($dst_data)/ch09/dt_banco.py"

# k-NN classification (R and Python)
'#!/usr/bin/env Rscript
suppressPackageStartupMessages(library(class))
set.seed(42)
df <- read.csv("banco.csv")
features <- c("edad", "ingreso", "familia", "gasto_tarjeta", "educacion", "hipoteca")
X <- scale(df[, features])
y <- df$prestamo

n <- nrow(X)
train_idx <- sample(seq_len(n), size = floor(0.8 * n))
train_x <- X[train_idx, ]
test_x  <- X[-train_idx, ]
train_y <- y[train_idx]
test_y  <- y[-train_idx]

rows <- list()
for (k in c(3, 5, 7)) {
  preds <- knn(train = train_x, test = test_x, cl = train_y, k = k)
  tbl <- table(test_y, preds)
  acc <- sum(diag(tbl)) / sum(tbl)
  tp <- if ("1" %in% rownames(tbl) && "1" %in% colnames(tbl)) tbl["1", "1"] else 0
  fp <- if ("0" %in% rownames(tbl) && "1" %in% colnames(tbl)) tbl["0", "1"] else 0
  fn <- if ("1" %in% rownames(tbl) && "0" %in% colnames(tbl)) tbl["1", "0"] else 0
  prec <- if (tp + fp > 0) tp / (tp + fp) else 0
  rec <- if (tp + fn > 0) tp / (tp + fn) else 0
  f1 <- if (prec + rec > 0) 2 * prec * rec / (prec + rec) else 0
  rows[[length(rows) + 1]] <- data.frame(
    model = "R_knn",
    k_neighbors = k,
    accuracy = round(acc, 4),
    precision = round(prec, 4),
    recall = round(rec, 4),
    f1_score = round(f1, 4)
  )
}
out <- do.call(rbind, rows)
write.csv(out, "banco_knn_r.csv", row.names = FALSE, quote = FALSE)
write.csv(out, stdout(), row.names = FALSE, quote = FALSE)
' | save -f $"($dst_data)/ch09/knn_banco.R"

'#!/usr/bin/env python3
import pandas as pd
from sklearn.model_selection import train_test_split
from sklearn.preprocessing import StandardScaler
from sklearn.neighbors import KNeighborsClassifier
from sklearn.metrics import accuracy_score, precision_score, recall_score, f1_score
import sys

df = pd.read_csv("banco.csv")
features = ["edad", "ingreso", "familia", "gasto_tarjeta", "educacion", "hipoteca"]
X = df[features]
y = df["prestamo"]

X_train, X_test, y_train, y_test = train_test_split(X, y, test_size=0.2, random_state=42)
scaler = StandardScaler()
X_train_s = scaler.fit_transform(X_train)
X_test_s  = scaler.transform(X_test)

rows = []
for k in [3, 5, 7]:
    clf = KNeighborsClassifier(n_neighbors=k)
    clf.fit(X_train_s, y_train)
    preds = clf.predict(X_test_s)
    rows.append({
        "model": "Python_KNeighborsClassifier",
        "k_neighbors": k,
        "accuracy": round(float(accuracy_score(y_test, preds)), 4),
        "precision": round(float(precision_score(y_test, preds, zero_division=0)), 4),
        "recall": round(float(recall_score(y_test, preds, zero_division=0)), 4),
        "f1_score": round(float(f1_score(y_test, preds, zero_division=0)), 4)
    })

out_df = pd.DataFrame(rows)
out_df.to_csv("banco_knn_py.csv", index=False)
out_df.to_csv(sys.stdout, index=False)
' | save -f $"($dst_data)/ch09/knn_banco.py"

# Naïve Bayes & SVM (Python)
'#!/usr/bin/env python3
import pandas as pd
from sklearn.model_selection import train_test_split
from sklearn.preprocessing import StandardScaler
from sklearn.naive_bayes import GaussianNB
from sklearn.svm import SVC
from sklearn.metrics import accuracy_score, precision_score, recall_score, f1_score
import sys

df = pd.read_csv("banco.csv")
features = ["edad", "ingreso", "familia", "gasto_tarjeta", "educacion", "hipoteca"]
X = df[features]
y = df["prestamo"]

X_train, X_test, y_train, y_test = train_test_split(X, y, test_size=0.2, random_state=42)
scaler = StandardScaler()
X_train_s = scaler.fit_transform(X_train)
X_test_s  = scaler.transform(X_test)

models = {
    "GaussianNB": GaussianNB(),
    "SVC(kernel=rbf)": SVC(kernel="rbf", C=1.0, random_state=42)
}

rows = []
for name, clf in models.items():
    clf.fit(X_train_s, y_train)
    preds = clf.predict(X_test_s)
    rows.append({
        "model": name,
        "accuracy": round(float(accuracy_score(y_test, preds)), 4),
        "precision": round(float(precision_score(y_test, preds, zero_division=0)), 4),
        "recall": round(float(recall_score(y_test, preds, zero_division=0)), 4),
        "f1_score": round(float(f1_score(y_test, preds, zero_division=0)), 4)
    })

out_df = pd.DataFrame(rows)
out_df.to_csv("banco_nb_svm_py.csv", index=False)
out_df.to_csv(sys.stdout, index=False)
' | save -f $"($dst_data)/ch09/nb_svm_banco.py"

# Copy Life_Expectancy_Data.csv if available
let life_exp_src = "/home/kira/Dropbox/Documentos/Clases/UBB/Mineria_de_Datos/material_unab/mine/guias/scripts/Life_Expectancy_Data.csv"
if ($life_exp_src | path exists) {
    cp $life_exp_src $"($dst_data)/ch09/Life_Expectancy_Data.csv"
}

# Multicollinearity (VIF) & Principal Component Regression (PCR) - Python & R
'#!/usr/bin/env python3
import pandas as pd
import numpy as np
from sklearn.linear_model import LinearRegression
from sklearn.decomposition import PCA
from sklearn.metrics import r2_score, mean_squared_error
import sys

df = pd.read_csv("Fish.csv")
pred_cols = ["Length1", "Length2", "Length3", "Height", "Width"]
X = df[pred_cols]
y = df["Weight"]

# VIF calculation: VIF_i = 1 / (1 - R^2_i)
vif_data = []
for col in pred_cols:
    X_other = X.drop(columns=[col])
    y_target = X[col]
    reg = LinearRegression().fit(X_other, y_target)
    r2_val = reg.score(X_other, y_target)
    vif = 1.0 / (1.0 - r2_val) if r2_val < 0.99999 else 9999.0
    vif_data.append({"feature": col, "vif": round(float(vif), 2)})

vif_df = pd.DataFrame(vif_data)
vif_df.to_csv("fish_vif_py.csv", index=False)

# OLS Multiple Regression vs PCR (K=2)
ols = LinearRegression().fit(X, y)
ols_preds = ols.predict(X)
ols_r2 = r2_score(y, ols_preds)
ols_rmse = np.sqrt(mean_squared_error(y, ols_preds))

pca = PCA(n_components=2)
X_pca = pca.fit_transform(X)
pcr = LinearRegression().fit(X_pca, y)
pcr_preds = pcr.predict(X_pca)
pcr_r2 = r2_score(y, pcr_preds)
pcr_rmse = np.sqrt(mean_squared_error(y, pcr_preds))

comp_df = pd.DataFrame([
    {"model": "Python_OLS_Multiple_Regression", "components": 5, "r2": round(float(ols_r2), 4), "rmse": round(float(ols_rmse), 2)},
    {"model": "Python_PCR_Principal_Components", "components": 2, "r2": round(float(pcr_r2), 4), "rmse": round(float(pcr_rmse), 2)}
])
comp_df.to_csv("fish_pcr_py.csv", index=False)
comp_df.to_csv(sys.stdout, index=False)
' | save -f $"($dst_data)/ch09/vif_pcr_fish.py"

'#!/usr/bin/env Rscript
df <- read.csv("Fish.csv")
pred_cols <- c("Length1", "Length2", "Length3", "Height", "Width")
X <- df[, pred_cols]
y <- df$Weight

fit_ols <- lm(Weight ~ ., data = df[, c(pred_cols, "Weight")])
r2_ols <- summary(fit_ols)$r.squared
rmse_ols <- sqrt(mean(residuals(fit_ols)^2))

pca <- prcomp(X, scale. = TRUE)
fit_pcr <- lm(y ~ pca$x[, 1:2])
r2_pcr <- summary(fit_pcr)$r.squared
rmse_pcr <- sqrt(mean(residuals(fit_pcr)^2))

out_comp <- data.frame(
  model = c("R_OLS_Multiple_Regression", "R_PCR_Principal_Components"),
  components = c(5, 2),
  r2 = round(c(r2_ols, r2_pcr), 4),
  rmse = round(c(rmse_ols, rmse_pcr), 2)
)
write.csv(out_comp, "fish_pcr_r.csv", row.names = FALSE, quote = FALSE)
write.csv(out_comp, stdout(), row.names = FALSE, quote = FALSE)
' | save -f $"($dst_data)/ch09/vif_pcr_fish.R"

# Density-Based Spatial Clustering (DBSCAN) - Python
'#!/usr/bin/env python3
import pandas as pd
from sklearn.preprocessing import StandardScaler
from sklearn.cluster import DBSCAN
import sys

df = pd.read_csv("Fish.csv")
num_cols = ["Weight", "Length1", "Length2", "Length3", "Height", "Width"]
X = df[num_cols]
scaler = StandardScaler()
X_scaled = scaler.fit_transform(X)

db = DBSCAN(eps=0.9, min_samples=4)
df["cluster"] = db.fit_predict(X_scaled)

grouped = df.groupby("cluster").agg(
    n_samples=("Species", "count"),
    avg_weight=("Weight", lambda x: round(float(x.mean()), 1)),
    avg_length=("Length1", lambda x: round(float(x.mean()), 1)),
    avg_height=("Height", lambda x: round(float(x.mean()), 1)),
    avg_width=("Width", lambda x: round(float(x.mean()), 1))
).reset_index()

grouped["cluster_type"] = grouped["cluster"].apply(lambda c: "Ruido / Outliers" if c == -1 else f"Cluster {c}")
out = grouped[["cluster", "cluster_type", "n_samples", "avg_weight", "avg_length", "avg_height", "avg_width"]]
out.to_csv("fish_dbscan_py.csv", index=False)
out.to_csv(sys.stdout, index=False)
' | save -f $"($dst_data)/ch09/dbscan_fish.py"

# K-Medoids Clustering (PAM) - R
'#!/usr/bin/env Rscript
suppressPackageStartupMessages(library(cluster))
df <- read.csv("Fish.csv")
num_cols <- c("Weight", "Length1", "Length2", "Length3", "Height", "Width")
X <- scale(df[, num_cols])

fit_pam <- pam(X, k = 3, metric = "euclidean")
sil <- silhouette(fit_pam)
avg_sil <- mean(sil[, 3])

out <- data.frame(
  model = "R_cluster_pam_kmedoids",
  k_clusters = 3,
  avg_silhouette = round(avg_sil, 4),
  cluster_1_size = fit_pam$clusinfo[1, 1],
  cluster_2_size = fit_pam$clusinfo[2, 1],
  cluster_3_size = fit_pam$clusinfo[3, 1]
)
write.csv(out, "fish_pam_r.csv", row.names = FALSE, quote = FALSE)
write.csv(out, stdout(), row.names = FALSE, quote = FALSE)
' | save -f $"($dst_data)/ch09/pam_fish.R"

# Multi-Layer Perceptron (MLP) Artificial Neural Networks - Python & R
'#!/usr/bin/env python3
import pandas as pd
import numpy as np
import warnings
warnings.filterwarnings("ignore")
from sklearn.model_selection import train_test_split
from sklearn.preprocessing import StandardScaler
from sklearn.neural_network import MLPClassifier
from sklearn.metrics import accuracy_score, precision_score, recall_score, f1_score
import sys

df = pd.read_csv("banco.csv")
features = ["edad", "ingreso", "familia", "gasto_tarjeta", "educacion", "hipoteca"]
X = df[features]
y = df["prestamo"]

X_train, X_test, y_train, y_test = train_test_split(X, y, test_size=0.2, random_state=42)
scaler = StandardScaler()
X_train_s = scaler.fit_transform(X_train)
X_test_s  = scaler.transform(X_test)

rows = []
for hidden in [(8,), (16, 8)]:
    clf = MLPClassifier(hidden_layer_sizes=hidden, max_iter=500, random_state=42)
    clf.fit(X_train_s, y_train)
    preds = clf.predict(X_test_s)
    rows.append({
        "model": f"Python_MLP_{hidden}",
        "accuracy": round(float(accuracy_score(y_test, preds)), 4),
        "precision": round(float(precision_score(y_test, preds, zero_division=0)), 4),
        "recall": round(float(recall_score(y_test, preds, zero_division=0)), 4),
        "f1_score": round(float(f1_score(y_test, preds, zero_division=0)), 4),
        "iterations": int(clf.n_iter_)
    })

out = pd.DataFrame(rows)
out.to_csv("banco_mlp_py.csv", index=False)
out.to_csv(sys.stdout, index=False)
' | save -f $"($dst_data)/ch09/mlp_banco.py"

'#!/usr/bin/env Rscript
suppressPackageStartupMessages(library(nnet))
set.seed(42)
df <- read.csv("banco.csv")
features <- c("edad", "ingreso", "familia", "gasto_tarjeta", "educacion", "hipoteca")
df[features] <- scale(df[features])

n <- nrow(df)
train_idx <- sample(seq_len(n), size = floor(0.8 * n))
train <- df[train_idx, c(features, "prestamo")]
test  <- df[-train_idx, c(features, "prestamo")]

fit <- nnet(prestamo ~ ., data = train, size = 6, decay = 0.01, maxit = 400, trace = FALSE)
preds_prob <- predict(fit, newdata = test, type = "raw")
preds <- ifelse(preds_prob > 0.5, 1, 0)

tbl <- table(test[["prestamo"]], preds)
acc <- sum(diag(tbl)) / sum(tbl)
tp <- if ("1" %in% rownames(tbl) && "1" %in% colnames(tbl)) tbl["1", "1"] else 0
fp <- if ("0" %in% rownames(tbl) && "1" %in% colnames(tbl)) tbl["0", "1"] else 0
fn <- if ("1" %in% rownames(tbl) && "0" %in% colnames(tbl)) tbl["1", "0"] else 0
prec <- if (tp + fp > 0) tp / (tp + fp) else 0
rec <- if (tp + fn > 0) tp / (tp + fn) else 0
f1 <- if (prec + rec > 0) 2 * prec * rec / (prec + rec) else 0

out <- data.frame(
  model = "R_nnet_neural_network",
  hidden_units = 6,
  accuracy = round(acc, 4),
  precision = round(prec, 4),
  recall = round(rec, 4),
  f1_score = round(f1, 4)
)
write.csv(out, "banco_mlp_r.csv", row.names = FALSE, quote = FALSE)
write.csv(out, stdout(), row.names = FALSE, quote = FALSE)
' | save -f $"($dst_data)/ch09/mlp_banco.R"

glob $"($dst_data)/ch09/*.{R,py}" | each { |f| chmod +x $f }

# Sync to docker/data
rm -rf $docker_data
mkdir $docker_data
^cp -a $"($dst_data)/." $docker_data

print "Successfully built /data/ch03..ch09 structure and synced to docker/data!"
ls $dst_data | select name type
