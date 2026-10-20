# Ciencia de Datos en Nushell (Data Science at Nushell)

**Curso electivo** del programa de **Ingeniería Estadística** — **Universidad del Bío-Bío (UBB)**

**Instructor:** Dr. Luis Gómez (`lgomez@ubiobio.cl`)

## Descripción

Curso integrado de **Ciencia de Datos en la Línea de Comandos** construido íntegramente sobre **Nushell** como shell interactivo, lenguaje de programación funcional/estructurado y motor de pipelines de datos, utilizando el contenedor Docker propio **`dsin`** (*Data Science in Nushell*).

El curso aborda desde los conceptos fundamentales de bajo nivel en Nushell (strings, listas, registros, tablas, tipado y creación de comandos personalizados) hasta el flujo completo OSEMN (Obtención, Depuración con Nushell nativo y **Polars**, Exploración y visualización en terminal con **`timg`**, Paralelización con **`par-each`**, y Modelación políglota integrando herramientas CLI como **`vw`** / **`tapkee`** / **`skll`** junto con **`Rscript`** y **`python3`** hacia tablas estructuradas de Nushell).

## Contenidos (`Files/DataScienceNushell.md`)

1. **Capítulo 1:** Instalación de Software (`dsin` Docker + Nushell)
2. **Capítulo 2:** Introducción a la Terminal, Fundamentos de Nushell (Strings, Listas, Registros, Tablas, Editor `ttt`) y Control de Versiones (`git`)
3. **Capítulo 3:** Programación en Nushell y Creación de Herramientas de Línea de Comandos (`def`, `export def`, flags, tipos, módulos e integración con R/Python)
4. **Capítulo 4:** Obtención de Datos (`http get`, descompresión, Excel, SQLite, Parquet y APIs web)
5. **Capítulo 5:** Depuración y Transformación de Datos (Nushell nativo + plugin `polars`)
6. **Capítulo 6:** Exploración de Datos y Visualización en Terminal (`describe`, `math`, `polars`, R/Python y visualización con `timg`)
7. **Capítulo 7:** Paralelización de Pipelines (`each` y `par-each`)
8. **Capítulo 8:** Modelación de Datos Políglota (Reducción de Dimensionalidad, Regresión y Clasificación en CLI + `Rscript` + `python3` → Tablas Nushell)

## Imagen Docker (`dsin`)

La imagen oficial del curso (`kurokirasama/dsin:latest`) incluye:
- **Nushell (`nu`)** como shell por defecto con configuración personalizada (`config.nu`) y **`nu_plugin_polars`** pre-registrado.
- **`ttt`**: Editor de texto en terminal preconfigurado.
- **`timg`**: Visor de imágenes y gráficos directamente en la terminal.
- **Motores de modelación y análisis:** `Rscript` (`tidyverse`, `ggplot2`), `python3` (`scikit-learn`, `polars`, `pandas`, `matplotlib`), `vw` (Vowpal Wabbit), `tapkee` y `skll`.

```bash
docker pull kurokirasama/dsin:latest
docker run --rm -it -v "$(pwd):/data" kurokirasama/dsin:latest
```

## Estructura del Repositorio

```text
├── Files/
│   ├── DataScienceNushell.md   # Libro principal del curso (Pandoc Markdown)
│   ├── DataScienceNushell.pdf  # Versión compilada en PDF
│   ├── *.csv                   # Datasets del curso (IES, COVID-19, vgsales)
│   ├── *.png / *.jpg           # Figuras y diagramas
│   └── data/                   # Datos por capítulo
├── docker/
│   ├── Dockerfile              # Definición de la imagen independiente dsin
│   ├── config.nu               # Configuración personalizada de Nushell para dsin
│   └── update-dsin-nushell.nu  # Script para actualizar la versión de Nushell en dsin
├── tests/                      # Suite de verificación automatizada en contenedor dsin
└── README.md
```
