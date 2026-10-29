> **[ [English](README.md) | Español ]**
>
> 🌐 **Portal Web y Descarga Directa de PDFs:** [kurokirasama.github.io/data_science_at_nushell/es/](https://kurokirasama.github.io/data_science_at_nushell/es/)

# Ciencia de Datos en Nushell (Data Science at Nushell)

**Guía práctica y libro** de **Ciencia de Datos en la Línea de Comandos** con **Nushell**

- 📖 **Portal Web y Descarga Directa:** [https://kurokirasama.github.io/data_science_at_nushell/es/](https://kurokirasama.github.io/data_science_at_nushell/es/)
- 📄 **Edición Oficial en Español (PDF):** [DataScienceNushell.es.pdf](Files/DataScienceNushell.es.pdf) • [Enlace directo en línea](https://kurokirasama.github.io/data_science_at_nushell/Files/DataScienceNushell.es.pdf)
- 📄 **Edición en Inglés (PDF):** [DataScienceNushell.pdf](Files/DataScienceNushell.pdf) • [Enlace directo en línea](https://kurokirasama.github.io/data_science_at_nushell/Files/DataScienceNushell.pdf)

## Descripción

Libro y manual integral de **Ciencia de Datos en la Línea de Comandos** construido íntegramente sobre **Nushell** como shell interactivo, lenguaje de programación funcional/estructurado y motor de pipelines de datos, utilizando el contenedor Docker propio **`dsin`** (*Data Science in Nushell*).

Esta obra aborda desde la comparación con shells tradicionales (`bash`, `zsh` y la filosofía POSIX) y los conceptos fundamentales de bajo nivel en Nushell (strings, listas, registros, tablas, rutas de celda, tipado y creación de comandos personalizados) hasta el flujo completo OSEMN:

- **Obtención de Datos:** `http get`, `http post`, `url join`, descompresión, hojas Excel `.xlsx`, bases SQLite (`query db`), Parquet y APIs web (REST, autenticación, geocodificación con Google Maps / OpenStreetMap y streaming SSE).
- **Depuración y Transformación:** Nushell nativo + plugin `polars` (`nu_plugin_polars`).
- **Exploración y Visualización en Terminal:** Estadísticas descriptivas nativas (`math`, `polars summary`) y políglotas (`Rscript`, `python3`) junto con visualización gráfica en terminal mediante **`timg`**.
- **Paralelización:** Ejecución concurrente nativa con **`par-each`** y paralelización de procesos externos con **GNU `parallel`** desde Nushell.
- **Modelación Políglota:** Reducción de Dimensionalidad (PCA, t-SNE y UMAP), Clustering (K-Means, Jerárquico, DBSCAN y PAM), Regresión y Clasificación Supervisada (incluyendo Perceptrón Multicapa) integrando herramientas CLI (**`umap-reduce`**, **`lgbm-regress`**, **`duckdb-ols`**, **`ml-benchmark`**, **`tapkee`**, **`kmeans-cluster`**, **`vw`**, **`run_experiment`**) junto con **`Rscript`** y **`python3`** hacia tablas estructuradas de Nushell.

## Origen y Relación con la Obra Original de Jeroen Janssens

Este proyecto es una derivación directa, evolución metodológica y *spin-off* del influyente libro [**Data Science at the Command Line**](https://datascienceatthecommandline.com/2e/) (O'Reilly Media) de [**Jeroen Janssens**](https://jeroenjanssens.com/).

La obra original de Janssens sentó las bases del uso de la consola Unix para flujos integrales de ciencia de datos, apoyándose en utilidades clásicas de procesamiento de texto plano (`sed`, `awk`, `cut`, `grep`), la suite `csvkit` y scripts en Bash. **Data Science at Nushell** adapta y moderniza esa visión reemplazando los flujos tradicionales de caracteres no estructurados por el paradigma interactivo y estructurado de **Nushell** (`nu`), donde cada pipeline transporta tipos de datos semánticos, registros jerárquicos y tablas columnares aceleradas con **Polars** y Apache Arrow.

- **Libro original en línea (Segunda Edición):** [datascienceatthecommandline.com/2e](https://datascienceatthecommandline.com/2e/)
- **Repositorio oficial de la obra original en GitHub:** [jeroenjanssens/data-science-at-the-command-line](https://github.com/jeroenjanssens/data-science-at-the-command-line)
- **Data Science Toolbox (Docker upstream original):** [jeroenjanssens/datasciencetoolbox](https://github.com/jeroenjanssens/datasciencetoolbox)
- **Data Science Toolbox en Docker Hub:** [hub.docker.com/u/datasciencetoolbox](https://hub.docker.com/u/datasciencetoolbox)

## Contenidos (`Files/DataScienceNushell.es.md`)

1. **Capítulo 1:** Introducción (La terminal como laboratorio científico, el paradigma Nushell de datos estructurados, fundamento formativo de la omisión reflexiva de salidas y entorno reproducible)
2. **Capítulo 2:** Instalación de Software (`dsin` Docker + Nushell)
3. **Capítulo 3:** Fundamentos y Estructuras de Datos en Nushell (Introducción a la Terminal, Shells Tradicionales vs. Nushell, Strings, Listas, Registros, Tablas, Editor `ttt` y Git)
4. **Capítulo 4:** Programación en Nushell y Creación de Herramientas de Línea de Comandos (`def`, `export def`, flags, tipos, módulos, API de Google Maps e integración con R/Python)
5. **Capítulo 5:** Obtención de Datos (`http get`, descompresión, Excel, SQLite y APIs web)
6. **Capítulo 6:** Depuración y Transformación de Datos (Nushell nativo + plugin `polars`)
7. **Capítulo 7:** Exploración de Datos y Visualización en Terminal (`describe`, `math`, `polars`, scripts `.R`/`.py` y visualización con `timg`)
8. **Capítulo 8:** Procesamiento en Serie y Pipelines Paralelos (`each`, `par-each` y GNU `parallel`)
9. **Capítulo 9:** Modelado Políglota de Datos (Reducción de Dimensionalidad con PCA/t-SNE/UMAP, Clustering K-Means / Jerárquico / DBSCAN / PAM, Regresión con VW/LightGBM/DuckDB OLS y Clasificación Supervisada incluyendo MLP en CLI + `Rscript` + `python3` → Tablas Nushell)
10. **Capítulo 10:** Conclusión: La Terminal como Laboratorio de Inteligencia de Datos (El ciclo OSEMN en shells tipadas, ingeniería de software aplicada a la estadística, eficiencia out-of-core y frontera zero-copy en Apache Arrow, y guía metodológica para proyectos en producción)

## Imagen Docker (`dsin`)

La imagen oficial del entorno (`ghcr.io/kurokirasama/dsin:latest`) incluye:

- **Nushell (`nu`)** como shell por defecto con configuración personalizada (`config.nu`), módulo `dsin_tools.nu` (`to-vw`, `vw-regress`, `tapkee-reduce`, `kmeans-cluster`, `umap-reduce`, `lgbm-regress`, `duckdb-ols`, `ml-benchmark`) y plugins oficiales (`nu_plugin_polars`, `formats`, `query`, `gstat`, `inc`, `file`, `plot`, `port_extension`) pre-registrados.
- **Directorio `/data` integrado por defecto:** Contiene las carpetas por capítulo (`/data/ch03` a `/data/ch09`) listas para usar sin necesidad de descargas adicionales.
- **`ttt`**: Editor de texto en terminal preconfigurado en `$env.PATH`.
- **`timg`**: Visor de imágenes y gráficos directamente en la terminal en `$env.PATH`.
- **Motores de modelación, paralelización y análisis:** `Rscript` (`tidyverse`, `ggplot2`), `python3` y entorno aislado `/opt/modern-ml` con Python 3.12 vía `uv` (`umap-learn`, `lightgbm`, `scikit-learn`, `pandas`, `matplotlib`), binarios C++ autónomos `duckdb` y `lightgbm`, `parallel` (GNU Parallel), `vw` (Vowpal Wabbit), `tapkee` y `run_experiment` (SKLL).

```bash
docker pull ghcr.io/kurokirasama/dsin:latest
docker run --rm -it ghcr.io/kurokirasama/dsin:latest
```

## Actualización de Nushell en la Imagen `dsin`

Cuando el equipo de Nushell publica una nueva versión oficial, el repositorio incluye el script automatizado `update-dsin-nushell.nu` que consulta la última versión en GitHub Releases, actualiza `docker/Dockerfile`, empaqueta la carpeta `/data` actualizada, reconstruye la imagen `dsin` con la versión correspondiente de `nu` y `nu_plugin_polars`, y opcionalmente la publica en el registro de contenedores:

```nu
# Consultar si existe una nueva versión de Nushell disponible sin reconstruir
nu update-dsin-nushell.nu --check

# Reconstruir la imagen dsin con la versión más reciente de Nushell
nu update-dsin-nushell.nu

# Reconstruir fijando una versión específica y publicar en GHCR
nu update-dsin-nushell.nu --version 0.116.1 --push
```

## Compilación del Libro a PDF

Para generar el documento PDF oficial con XeLaTeX, resaltado de sintaxis nativo para Nushell y ocultamiento transparente de directivas de prueba mediante el filtro Lua:

```bash
cd Files
pandoc --pdf-engine=xelatex \
  --lua-filter=hide_skip.lua \
  --syntax-definition=nu.xml \
  --syntax-definition=nushell.xml \
  --syntax-highlighting=pandoc_highlight.theme \
  DataScienceNushell.es.md -o DataScienceNushell.es.pdf
```

## Estructura del Repositorio

```text
├── Files/
│   ├── DataScienceNushell.md      # Texto principal del libro en inglés (Pandoc Markdown)
│   ├── DataScienceNushell.es.md   # Versión original en español (Pandoc Markdown)
│   ├── DataScienceNushell.pdf     # Versión compilada en PDF en inglés (XeLaTeX)
│   ├── DataScienceNushell.es.pdf  # Versión compilada en PDF en español (XeLaTeX)
│   ├── *.png / *.jpg              # Figuras y diagramas de la obra
│   └── data/                      # Datos por capítulo (ch03..ch09) integrados en /data
├── docker/
│   ├── Dockerfile                 # Definición de la imagen independiente dsin
│   ├── UPSTREAM_AUDIT.md          # Auditoría y corrección de issues de dsatcl2e
│   ├── config.nu                  # Configuración personalizada de Nushell para dsin
│   ├── dsin_tools.nu              # Comandos Nushell para modelación (VW, Tapkee, K-Means)
│   └── update-dsin-nushell.nu     # Copia del script actualizador en docker/
├── update-dsin-nushell.nu         # Script principal para actualizar Nushell en dsin
├── README.md                      # Documentación principal en inglés
└── README.es.md                   # Documentación en español
```
