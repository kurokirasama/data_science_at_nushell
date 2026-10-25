> **[ English | [Español](README.es.md) ]**
>
> 🌐 **Course Web Portal & Direct PDF Serving:** [kurokirasama.github.io/data_science_at_nushell](https://kurokirasama.github.io/data_science_at_nushell/)
>
> [!NOTE]
> This English documentation was translated with the assistance of AI from the original Spanish version. For the original Spanish documentation, see [README.es.md](README.es.md).

# Data Science at Nushell

**Practical Guide and Textbook** for **Data Science at the Command Line** with **Nushell**

- 📖 **Web Portal & Direct Downloads:** [https://kurokirasama.github.io/data_science_at_nushell/](https://kurokirasama.github.io/data_science_at_nushell/)
- 📄 **English Edition PDF:** [DataScienceNushell.pdf](Files/DataScienceNushell.pdf) • [Direct Online Link](https://kurokirasama.github.io/data_science_at_nushell/Files/DataScienceNushell.pdf)
- 📄 **Spanish Edition PDF:** [DataScienceNushell.es.pdf](Files/DataScienceNushell.es.pdf) • [Direct Online Link](https://kurokirasama.github.io/data_science_at_nushell/Files/DataScienceNushell.es.pdf)

## Description

A comprehensive textbook and practical manual for **Data Science at the Command Line**, built entirely around **Nushell** as an interactive shell, functional/structured programming language, and data pipeline engine, utilizing the dedicated standalone Docker container **`dsin`** (*Data Science in Nushell*).

This work covers everything from comparing traditional shells (`bash`, `zsh`, and the POSIX philosophy) to foundational low-level Nushell concepts (strings, lists, records, tables, cell paths, strong typing, and custom command creation), progressing through the entire OSEMN data science lifecycle:

- **Obtaining Data:** `http get`, `http post`, `url join`, decompression, Microsoft Excel spreadsheets (`.xlsx`), SQLite databases (`query db`), Apache Parquet, and web APIs (REST, authentication, geocoding with Google Maps / OpenStreetMap, and Server-Sent Events streaming).
- **Scrubbing and Transforming:** Native Nushell pipelines + the high-performance `polars` plugin (`nu_plugin_polars`).
- **Exploring and In-Terminal Visualization:** Descriptive statistics using native commands (`math`, `polars summary`) and polyglot integration (`Rscript`, `python3`), alongside direct in-terminal graphical visualization using **`timg`**.
- **Parallelization:** Native concurrent execution via **`par-each`** and external process parallelization with **GNU `parallel`** orchestrated from Nushell.
- **Polyglot Modeling:** Dimensionality Reduction (PCA and t-SNE), Clustering (K-Means, Hierarchical, DBSCAN, PAM), Regression, and Supervised Classification integrating command-line tools (**`tapkee`**, **`kmeans-cluster`**, **`vw`**, **`run_experiment`**) alongside **`Rscript`** and **`python3`** streaming directly into structured Nushell tables.

## Origins and Relationship to the Original Work by Jeroen Janssens

This project is a direct derivative, methodological evolution, and spin-off of the influential book [**Data Science at the Command Line**](https://datascienceatthecommandline.com/2e/) (O'Reilly Media) by [**Jeroen Janssens**](https://jeroenjanssens.com/).

Janssens' original work established the foundation for using the Unix console for end-to-end data science workflows, relying on classic plain-text processing utilities (`sed`, `awk`, `cut`, `grep`), the `csvkit` suite, and Bash scripts. **Data Science at Nushell** adapts and modernizes that vision by replacing unstructured character streams with **Nushell's** (`nu`) structured, typed paradigm, where every pipeline transports semantic data types, hierarchical records, and columnar tables accelerated by **Polars** and Apache Arrow.

- **Original Book Online (Second Edition):** [datascienceatthecommandline.com/2e](https://datascienceatthecommandline.com/2e/)
- **Official GitHub Repository for the Original Work:** [jeroenjanssens/data-science-at-the-command-line](https://github.com/jeroenjanssens/data-science-at-the-command-line)
- **Data Science Toolbox (Original Upstream Docker Image):** [jeroenjanssens/datasciencetoolbox](https://github.com/jeroenjanssens/datasciencetoolbox)
- **Data Science Toolbox on Docker Hub:** [hub.docker.com/u/datasciencetoolbox](https://hub.docker.com/u/datasciencetoolbox)

## Table of Contents (`Files/DataScienceNushell.md`)

1. **Chapter 1: Introduction** (The terminal as a scientific laboratory, the Nushell structured data paradigm, pedagogical rationale for selective output omission, and reproducible environments)
2. **Chapter 2: Software Installation** (`dsin` Docker container + Nushell)
3. **Chapter 3: Nushell Fundamentals and Data Structures** (Introduction to the Terminal, Traditional Shells vs. Nushell, Strings, Lists, Records, Tables, `ttt` Editor, and Git)
4. **Chapter 4: Programming in Nushell and CLI Tool Creation** (`def`, `export def`, flags, types, modules, Google Maps API, and R/Python integration)
5. **Chapter 5: Obtaining Data** (`http get`, decompression, Excel spreadsheets, SQLite databases, and Web APIs)
6. **Chapter 6: Scrubbing and Transforming Data** (Native Nushell + `polars` plugin)
7. **Chapter 7: Exploring Data and In-Terminal Visualization** (`describe`, `math`, `polars`, `.R`/`.py` scripts, and plotting with `timg`)
8. **Chapter 8: Serial Processing and Parallel Pipelines** (`each`, `par-each`, and GNU `parallel`)
9. **Chapter 9: Polyglot Data Modeling** (Dimensionality Reduction, K-Means / Hierarchical / DBSCAN / PAM Clustering, Regression, and Supervised Classification via CLI + `Rscript` + `python3` → Nushell Tables)

## Docker Image (`dsin`)

The official environment image (`ghcr.io/kurokirasama/dsin:latest`) includes:

- **Nushell (`nu`)** as the default shell with custom configuration (`config.nu`), `dsin_tools.nu` module (`to-vw`, `vw-regress`, `tapkee-reduce`, `kmeans-cluster`), and pre-registered official plugins (`nu_plugin_polars`, `formats`, `query`, `gstat`, `inc`, `file`, `plot`, `port_extension`).
- **Integrated `/data` Directory:** Contains all chapter data folders (`/data/ch03` to `/data/ch09`) ready for immediate use without additional downloads.
- **`ttt`**: Terminal text editor pre-configured in `$env.PATH`.
- **`timg`**: In-terminal image and plot viewer available directly in `$env.PATH`.
- **Modeling, Parallelization, and Statistical Engines:** `Rscript` (`tidyverse`, `ggplot2`), `python3` (`scikit-learn`, `polars`, `pandas`, `matplotlib`), `parallel` (GNU Parallel), `vw` (Vowpal Wabbit), `tapkee`, and `run_experiment` (SKLL).

```bash
docker pull ghcr.io/kurokirasama/dsin:latest
docker run --rm -it ghcr.io/kurokirasama/dsin:latest
```

## Upgrading Nushell in the `dsin` Image

When the Nushell core team publishes a new official release, this repository provides an automated script (`update-dsin-nushell.nu`) that queries the latest release on GitHub, updates `docker/Dockerfile`, bundles the updated `/data` directory, rebuilds the `dsin` image with the matching `nu` and `nu_plugin_polars` versions, and optionally publishes to the container registry:

```nu
# Check if a newer Nushell release is available without rebuilding
nu update-dsin-nushell.nu --check

# Rebuild the dsin image using the latest available Nushell release
nu update-dsin-nushell.nu

# Rebuild pinned to a specific version and push to GHCR
nu update-dsin-nushell.nu --version 0.116.1 --push
```

## Compiling the Textbook to PDF

To compile the official PDF document using XeLaTeX, complete with native Nushell syntax highlighting and transparent suppression of test directives via the Lua filter:

```bash
cd Files
pandoc --pdf-engine=xelatex \
  --lua-filter=hide_skip.lua \
  --syntax-definition=nu.xml \
  --syntax-definition=nushell.xml \
  --syntax-highlighting=pandoc_highlight.theme \
  DataScienceNushell.md -o DataScienceNushell.pdf
```

## Repository Structure

```text
├── Files/
│   ├── DataScienceNushell.md      # Primary English textbook (Pandoc Markdown)
│   ├── DataScienceNushell.es.md   # Spanish textbook (Pandoc Markdown)
│   ├── DataScienceNushell.pdf     # Compiled English PDF (XeLaTeX)
│   ├── DataScienceNushell.es.pdf  # Compiled Spanish PDF (XeLaTeX)
│   ├── *.png / *.jpg              # Course diagrams and figures
│   └── data/                      # Per-chapter data sets (ch03..ch09) bundled into /data
├── docker/
│   ├── Dockerfile                 # Standalone dsin Docker image definition
│   ├── UPSTREAM_AUDIT.md          # Upstream audit and fixes for dsatcl2e issues
│   ├── config.nu                  # Custom Nushell configuration for dsin
│   ├── dsin_tools.nu              # Nushell modeling commands (VW, Tapkee, K-Means)
│   └── update-dsin-nushell.nu     # Updater script copy in docker/
├── tests/                         # Automated verification test suite inside dsin
├── update-dsin-nushell.nu         # Primary Nushell upgrade automation script
├── README.md                      # Primary English documentation
└── README.es.md                   # Spanish documentation
```
