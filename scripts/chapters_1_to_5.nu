# =============================================================================
# chapters_1_to_5.nu — Content modules for Chapters 1 through 5
# =============================================================================

export def get_slice [lines: list<string>, start_line: int, end_line: int]: nothing -> string {
    $lines | slice ($start_line - 1)..($end_line - 1) | str join "\n"
}

export def patch_part2 [text: string]: nothing -> string {
    $text
    | str replace -a "cd path/to/DSITCL/\ncd ch09" "cd /data/ch03"
    | str replace -a "cd ch09" "cd /data/ch03"
    | str replace -a "cat wine.csv\n^ps\n^ps -X" "open tips.csv | first 5\nuname"
    | str replace -a "open edition.json\n```" "open edition.json\nopen edition.json | save -f edition_copia.json\n```"
    | str replace -a "open edition2.json | get edition" "open edition2.json | get edition\nopen edition2.json | get edition | save -f edition2_filtrado.json"
    | str replace -a "\"hello\" | save output.txt" "\"hello\" | save -f output.txt"
    | str replace -a "```nu\n\"def abc [] { 1 + 2 }\" | save output.nu" "```nu\n# skip-docker-exec (demostración de error de compilación)\n\"def abc [] { 1 + 2 }\" | save -f output.nu"
    | str replace -a "```nu\nsource $\"($my_path)/common.nu\"" "```nu\n# skip-docker-exec (demostración de error en tiempo de compilación)\nsource $\"($my_path)/common.nu\""
    | str replace -a "```nu\nconst my_path = ([$nu.home-path nushell] | path join)" "```nu\n# skip-docker-exec (ejemplo ilustrativo de ruta constante)\nconst my_path = ([$nu.home-dir nushell] | path join)"
    | str replace -a "```nu\n> ls | each { |row|" "```nu\n# skip-docker-exec\nls | where type == dir | each { |row|"
    | str replace -a "cargo search shells --limit 10\n\ncargo search shells --limit 10 | lines | parse \"{crate_name} = {version} #{description}\" | str trim" "'nu = \"0.116.1\" # A new type of shell\nttt = \"1.8.0\" # Terminal text editor' | lines | parse '{crate_name} = \"{version}\" #{description}' | update description { str trim }"
    | str replace -a "curl https://jsonplaceholder.typicode.com/posts\nhttp get https://jsonplaceholder.typicode.com/posts" "cd /data/ch05\nhttp get https://jsonplaceholder.typicode.com/posts | first 5"
    | str replace -a "$response | explore" "$response | first 5 # En sesión interactiva puedes usar: $response | explore"
    | str replace -a "upsert id {|item| $item.id | inc}" "upsert id {|item| $item.id + 1}"
    | str replace -a "upsert id {|item|\n   $item.id | inc\n  }" "upsert id {|item|\n   $item.id + 1\n  }"
    | str replace -a "$data | select date condition 0 1" "$data | first 2 | select date condition"
    | str replace -a "trueX | describe" "\"trueX\" | describe"
    | str replace -a "```nu\n# Ejecutar el binario ls externo que se encuentra en la ruta\n`ls`\n\n# Subir un directorio\n`..`\n```" "```nu\n# skip-docker-exec\n# Ejecutar el binario ls externo o cambiar de directorio interactivamente\n^ls\n```"
    | str replace -a "```nu\nls `./my dir/*`\n```" "```nu\n# skip-docker-exec\nls `./my dir/*`\n```"
    | str replace -a "http get https://raw.githubusercontent.com/rfordatascience/tidytuesday/master/data/2019/2019-07-30/video_games.csv\n| save vgsales.csv" "cd /data/ch06\nls vgsales.csv"
    | str replace -a "let df = polars open vgsales.csv" "cd /data/ch06\nlet df = (open vgsales.csv | polars into-df)"
    | str replace -a "let df = open vgsales.csv" "cd /data/ch06\nlet df = (open vgsales.csv)"
    | str replace -a "$df | explore" "$df | polars first 5 | polars collect"
    | str replace -a "$df | polars collect | explore" "$df | polars first 5 | polars collect"
    | str replace -a "$df_filtered | polars save /path/to/vgsales_filtered.csv\n$df_filtered | polars save ($env.PWD | path join vgsales_filtered.csv)" "$df_filtered | polars collect | polars save ($env.PWD | path join vgsales_filtered.csv)"
    | str replace -a "$df_filtered | polars save /home/kira/Dropbox/Documentos/Clases/UBB/DataScienceAtTheCommandLine/Files/data/my_data/vgsales_filtered.csv\n\n$data_by_year | polars save /home/kira/Dropbox/Documentos/Clases/UBB/DataScienceAtTheCommandLine/Files/data/my_data/data_by_year.csv" "$df_filtered | polars collect | polars save vgsales_filtered.csv\n$data_by_year | polars save data_by_year.csv"
    | str replace -a "$df_filtered | polars save vgsales_filtered.parquet\n$df_filtered | polars save vgsales_filtered.csv\n$data_by_year | polars save data_by_year.csv" "$df_filtered | polars collect | polars save vgsales_filtered.parquet\n$df_filtered | polars collect | polars save vgsales_filtered.csv\n$data_by_year | polars save data_by_year.csv"
    | str replace -a "let $df_pivoted = $df_aggregated\n| polars pivot --index [developer] --on [year] --values [price_mean] --sort\n| polars sort-by developer\n\n$df_pivoted | polars collect\n$df_pivoted | polars into-nu | explore" "let df_pivoted = ($df_aggregated | polars collect | polars pivot --index [developer] --on [year] --values [price_mean] --stable | polars collect | polars sort-by developer | polars collect)\n$df_pivoted | polars first 5 | polars into-nu\n$df_pivoted | polars into-nu | save -f vgsales_pivot.csv"
    | str replace -a "let config = { path: /tmp, limit: 5 }" "let my_config = { path: /tmp, limit: 5 }"
    | str replace -a "...$config," "...$my_config,"
    | str replace -a "foo \"bar\" \"baz\" ...[1 2 3] # Con ..., los números se tratan como argumentos separados\n[false, bar, baz, [1, 2, 3]]\nfoo \"bar\" \"baz\" [1 2 3] # Sin ..., [1 2 3] se trata como un solo argumento\n[false, bar, baz, [[1, 2, 3]]]" "foo \"bar\" \"baz\" ...[1 2 3] # Con ..., los números se tratan como argumentos separados\nfoo \"bar\" \"baz\" [1 2 3] # Sin ..., [1 2 3] se trata como un solo argumento"
    | str replace -a "def bar [ ...args ] { foo --flag \"bar\" \"baz\" ...$args }\nbar 1 2 3\n[true, bar, baz, [1, 2, 3]]" "def bar [ ...args ] { foo --flag \"bar\" \"baz\" ...$args }\nbar 1 2 3"
    | str replace -a "foo \"bar\" \"baz\" 1 ...[2 3] 4 5 ...(6..9 | take 2) last\n[false, bar, baz, [1, 2, 3, 4, 5, 6, 7, last]]" "foo \"bar\" \"baz\" 1 ...[2 3] 4 5 ...(6..9 | take 2) last"
    | str replace -a "foo \"bar\" \"baz\" 1 ...[2 3] --flag 4\n[true, bar, baz, [1, 2, 3, 4]]" "foo \"bar\" \"baz\" 1 ...[2 3] --flag 4"
    | str replace -a "foo \"bar\" ...[1 2] \"not opt\"\n# El nulo significa que no se dio ningún argumento para opt\n[false, bar, null, [1, 2, \"not opt\"]]" "foo \"bar\" ...[1 2] \"not opt\""
    | str replace -a "```nu\nlet val = 42\n\n$val\n\n$val = 100\n```" "```nu\n# skip-docker-exec (demostración de inmutabilidad)\nlet val = 42\n$val\n$val = 100\n```"
    | str replace -a "```nu\nError: nu::shell::assignment_requires_mutable_variable" "```text\nError: nu::shell::assignment_requires_mutable_variable"
    | str replace -a "```nu\n# método ingenuo para contar el número de elementos en una lista" "```nu\n# skip-docker-exec (demostración de error de captura mutable)\n# método ingenuo para contar el número de elementos en una lista"
    | str replace -a "```nu\nconst script_file = 'path/to/script.nu'\nsource $script_file\n```" "```nu\n# skip-docker-exec\nconst script_file = 'path/to/script.nu'\nsource $script_file\n```"
    | str replace -a "```nu\ngenerate khot {|weather_station|" "```nu\n# skip-docker-exec (flujo continuo con sleep 1hr)\ngenerate khot {|weather_station|"
    | str replace -a "for _ in 1..50_000 {" "for _ in 1..500 {"
    | str replace -a "1..50_000 | each {random int}" "1..5_000 | each {random int}"
    | str replace -a "1..10_000_000 | each {random int}" "1..50_000 | each {random int}"
    | str replace -a "> let $var = 42ls" "let $var = 42"
    | str replace -a "```nu\nstr mycommand\n```" "```nu\ndef \"str mycommand\" [] { \"hello\" }\nstr mycommand\n```"
    | str replace -a "```nu\ndef greet [name: int] {\n  $\"hello ($name)\"\n}\n\ngreet world\n```" "```nu\n# skip-docker-exec (demostración de verificación de tipos)\ndef greet [name: int] {\n  $\"hello ($name)\"\n}\n\ngreet world\n```"
    | str replace -a "```nu\ngreet\n\ngreet world\n```" "```nu\ndef greet [name = \"nushell\"] { $\"hello ($name)\" }\ngreet\ngreet world\n```"
    | str replace -a "```nu\n> greet -a 10 --switch=false\n> greet -a 10 --switch=true\n```" "```nu\ngreet -a 10 --twice=false hello\ngreet -a 10 --twice=true hello\n```"
    | str replace -a "```nu\nUsage:\n  > greet <name> {flags}" "```text\nUsage:\n  > greet <name> {flags}"
    | str replace -a "```nu\nA greeting command that can greet the caller\n\nUsage:" "```text\nA greeting command that can greet the caller\n\nUsage:"
    | str replace -a "```nu\n> 'foo' | if $in == 'foo' { 1 } else { 0 } | $in + 2\n3\n```" "```nu\n'foo' | if $in == 'foo' { 1 } else { 0 } | $in + 2\n```"
    | str replace -a "```nu\nif $x > 0 { 'positivo' }\n```" "```nu\nlet x = 5\nif $x > 0 { 'positivo' }\n```"
    | str replace -a "Hilary Mason and Chris H. Wiggins [^1]" "Hilary Mason y Chris H. Wiggins (2010)"
    | str replace -a "[^1]: [A Taxonomy of Data Science, 2010](http://www.dataists.com/2010/09/a-taxonomy-of-data-science)." ""
    | str replace -a "### Strings con Comillas Simples" "### Strings con Comillas Simples {#single-quoted-strings}"
    | str replace -a "### Strings con Comillas Dobles" "### Strings con Comillas Dobles {#double-quoted-strings}"
    | str replace -a "### Strings Raw" "### Strings Raw {#raw-strings}"
    | str replace -a "### Strings de Palabra Simple" "### Strings de Palabra Simple {#bare-word-strings}"
    | str replace -a "### Strings con Comillas Invertidas" "### Strings con Comillas Invertidas {#backtick-quoted-strings}"
    | str replace -a "### Interpolación de strings" "### Interpolación de strings {#string-interpolation}"
    | str replace -a "y `😊`." "y `emoji_cmd` (o cualquier símbolo unicode admitido)."
}

export def get_frontmatter [with_course_info: bool = false]: nothing -> string {
    let course_info_section = if $with_course_info {
r#'
# Información del curso{-}

## Requisitos computacionales{-}

- Computador con sistema operativo Linux, macOS o Windows 10/11 (con WSL2).
- Docker instalado y configurado con la imagen oficial del curso `ghcr.io/kurokirasama/dsin:latest` (**Data Science in Nushell**).
- Al menos 4 GB de memoria RAM disponibles y 10 GB de espacio libre en disco.

## Evaluaciones{-}

- **Trabajo Individual:** 30% (1 semana)
- **Trabajo Grupal:** 25% (1 mes)
- **Presentación:** 45%

> Todas las entregas mediante repositorio de GitHub o GitLab.

## Contenidos{-}

1. **Capítulo 1 — Introducción:** La terminal como laboratorio científico, el paradigma Nushell de datos estructurados, sentido pedagógico de la omisión reflexiva de salidas y arquitectura del entorno reproducible `dsin`.
2. **Capítulo 2 — Instalación de Software:** Configuración de WSL2, Docker e imagen contenedorizada `dsin` con Nushell y `/data` integrados por defecto.
3. **Capítulo 3 — Fundamentos y Estructuras de Datos en Nushell:** El modelo OSEMN, la terminal, comparación entre shells tradicionales (`bash`, `zsh`) y Nushell, navegación del sistema, tipos de datos estructurados (*Strings*, *Listas*, *Registros* y *Tablas*), rutas de celda, edición en terminal con `ttt` y control de versiones con Git.
4. **Capítulo 4 — Programación y Creación de Herramientas de Línea de Comandos:** Operadores, variables, comandos personalizados (`def`, subcomandos, tipos, *flags*, *docstrings*, `$in`), control de flujo, desarrollo de comandos para la API de Google Maps y creación de herramientas CLI reutilizables en Nushell, Python y R.
5. **Capítulo 5 — Obtención de Datos:** Descarga nativa con `http get` y `http post`, inspección de cabeceras HTTP, descompresión de archivos, hojas de cálculo Microsoft Excel (`.xlsx`), consultas sobre bases de datos relacionales SQLite (`query db`) y consumo de APIs REST / flujos de transmisión (*streaming*).
6. **Capítulo 6 — Depuración y Transformación de Datos:** Filtrado y transformación de texto plano (`lines`, `parse`, `split column`, `shuffle`, `detect columns`), manipulación nativa de tablas y CSV (`where`, `select`, `upsert`, `merge`, `join`, `group-by`), procesamiento de XML/HTML/JSON y analítica columnar de alto rendimiento con el plugin **Polars** (`nu_plugin_polars`).
7. **Capítulo 7 — Exploración de Datos y Visualización en la Terminal:** Inspección de propiedades y tipos (`describe`, `explore`), estadísticas descriptivas nativas (`math`, `polars summary`) y políglotas (`Rscript` y `python3`), creación de gráficos estadísticos (`ggplot2` y `matplotlib`), visualización directa en consola con `timg` y transferencia segura con `scp`.
8. **Capítulo 8 — Procesamiento en Serie y Tuberías Paralelas:** Iteración serial con `each`, paralelismo nativo multihilo con `par-each --threads`, medición de tiempos con `timeit`, manejo resiliente de errores y paralelización de procesos externos con **GNU `parallel`** desde Nushell.
9. **Capítulo 9 — Modelado Políglota de Datos:** Preparación del conjunto de datos e implementación triple (herramienta CLI externa + `Rscript` + `python3` integrados en tablas Nushell) para Reducción de Dimensionalidad (`tapkee` / PCA / t-SNE), Clustering (`kmeans-cluster` / K-Means / Clustering Jerárquico), Regresión (`vw` / `lm` / `scikit-learn`) y Clasificación (`SKLL` / `glm` / `RandomForest` / Árboles de Decisión / k-NN / Naïve Bayes / SVM).

\newpage
'#
    } else {
        ""
    }

    (
r#'---
title: Ciencia de Datos en la Terminal con Nushell
author: Luis Gómez
number_sections: true
output: pdf_document
graphics: true
colorlinks: true
linkcolor: blue
fontsize: 12pt
monofont: "DejaVu Sans Mono"
header-includes:
  - '\usepackage{graphics}'
  - '\usepackage{amsmath}'
  - '\usepackage[spanish,activeacute,es-tabla]{babel}'
  - '\usepackage{hyphenat}'
  - '\usepackage{dsfont}'
  - '\usepackage[algoruled]{algorithm2e}'
  - '\usepackage{ragged2e}'
  - '\usepackage{hyperref}'
  - '\usepackage[all]{hypcap}'
  - '\newcommand{\algorithmiccomment}[1]{\hfill\# #1 }'
  - '\newcommand{\m}{\displaystyle}'
  - '\hyphenation{va-lo-res des-cri-tas mul-ti-di-men-sio-na-les ca-rac-te-ri-za-do}'
  - '\spanishdecimal{.}'
  - '\newcommand{\refer}[3][]{\hyperref[#3]{#2~\ref*{#3}#1}}'
  - '\usepackage[left=2cm,right=2cm,top=3cm,bottom=3cm]{geometry}'
  - '\usepackage{csvsimple}'
  - '\usepackage{tikz}'
  - '\usepackage{pgfplots}'
  - '\pgfplotsset{compat=1.18}'
  - '\usetikzlibrary{decorations.pathreplacing,automata,arrows,shadows,patterns,shapes}'
  - '\usepackage{pdflscape}'
  - '\usepackage{caption}'
  - '\usepackage{fontspec}'
  - '\usepackage{csquotes}'
  - '\usepackage{float}'
  - '\usepackage{array}'
  - '\setcounter{tocdepth}{5}'
  - '\setcounter{secnumdepth}{5}'
  - '\makeatletter'
  - '\renewcommand\subparagraph{\@startsection{subparagraph}{5}{\z@}{3.25ex \@plus1ex \@minus.2ex}{1.5ex \@plus.2ex}{\normalfont\normalsize\bfseries}}'
  - '\makeatother'
---

\tableofcontents
\renewcommand{\listfigurename}{Índice de figuras}
\listoffigures
\renewcommand{\listtablename}{Índice de tablas}
\listoftables
\newpage
'# + $course_info_section
    )
}

export def get_ch1_tail []: nothing -> string {
    r#'
## Linux, WSL2 y el Contenedor `dsin` (Data Science in Nushell) {#section-install-docker}

En este curso trabajaremos sobre una imagen Docker integrada llamada **`dsin`** (*Data Science in Nushell*), publicada en `ghcr.io/kurokirasama/dsin:latest`. A diferencia de los entornos tradicionales basados en *shells* de texto plano, el contenedor `dsin` inicia directamente en **Nushell** como *shell* predeterminado en el directorio de trabajo `/data`, e incluye preconfigurados:

- **Nushell (`nu`)** y su suite completa de complementos registrados: **`nu_plugin_polars`** (motor de DataFrames Arrow/Polars), **`nu_plugin_formats`**, **`nu_plugin_gstat`**, **`nu_plugin_inc`**, **`nu_plugin_query`**, **`nu_plugin_file`**, **`nu_plugin_plot`** (gráficos en la terminal) y **`nu_plugin_port_extension`**.
- **Directorio `/data` integrado por defecto:** Contiene todas las carpetas de datos del curso organizadas exactamente según el número del capítulo en que se utilizan (`/data/ch03`, `/data/ch04`, `/data/ch05`, `/data/ch06`, `/data/ch07`, `/data/ch08` y `/data/ch09`), sin necesidad de descargas ni configuraciones manuales adicionales.
- **Editor de texto en terminal `ttt`** en `$env.PATH` con resaltado de sintaxis y atajos preconfigurados.
- **Visor gráfico de terminal `timg`** en `$env.PATH` para inspeccionar imágenes y gráficos estadísticos directamente en la consola.
- **Ecosistema políglota:** R (`Rscript`, `tidyverse`, `ggplot2`, `rpart`, `class`, `cluster`), Python 3 (`pandas`, `scikit-learn`, `scipy`, `matplotlib`, `seaborn`, `skll`), **GNU Parallel (`parallel`)**, **Tapkee (`tapkee`)** y **Vowpal Wabbit (`vw`)**.
- **Módulo de herramientas del curso (`dsin_tools.nu`):** Comandos personalizados (`to-vw`, `vw-regress`, `tapkee-reduce`, `kmeans-cluster`) cargados automáticamente al iniciar.

### Instalación de Docker en Linux / WSL (basado en Debian/Ubuntu)

```bash
# skip-docker-exec
sudo apt update && sudo apt upgrade -y
sudo apt install -y ca-certificates curl gnupg lsb-release git
sudo usermod -aG docker $USER
```

### Instalación de Docker en Linux (basado en Arch / CachyOS / Manjaro)

```bash
# skip-docker-exec
sudo pacman -Syu --needed docker docker-buildx docker-compose git
sudo systemctl enable --now docker.service
sudo usermod -aG docker $USER
```

### Descarga y Ejecución del Contenedor `dsin`

Para descargar la imagen oficial del curso desde GitHub Container Registry:

```bash
# skip-docker-exec
docker pull ghcr.io/kurokirasama/dsin:latest
```

Para iniciar una sesión interactiva en el contenedor con el entorno listo para usar, ejecute:

```bash
# skip-docker-exec
docker run --rm -it ghcr.io/kurokirasama/dsin:latest
```

### Crear alias para llamado simple (opcional)

Si deseas iniciar el contenedor escribiendo únicamente `dsin` en tu terminal anfitriona, puedes definir un alias en tu archivo de configuración del shell anfitrión (`~/.bashrc` o `~/.config/nushell/config.nu`):

```bash
# skip-docker-exec
alias dsin='docker run --rm -it ghcr.io/kurokirasama/dsin:latest'
```

Una vez dentro del contenedor `dsin`, verificamos que nos encontramos en `/home/dsin`, inspeccionamos las carpetas de los capítulos en `/data` y comprobamos que todas las herramientas y complementos están disponibles:

```nu
pwd
ls /data | select name type
version | select version major minor patch
which nu ttt timg parallel vw tapkee run_experiment Rscript python3 | select command path type
plugin list | select name version status
```
'#
}

export def get_ch2_terminal_and_shells []: nothing -> string {
    r#'
## La Terminal

Antes de profundizar en las estructuras de datos de Nushell, revisemos los conceptos esenciales del entorno de terminal y cómo operaban los *shells* tradicionales que precedieron a Nushell.

### El Ambiente

En la terminal interactuamos mediante un ciclo continuo conocido como **REPL** (*Read-Eval-Print Loop*: Leer, Evaluar, Imprimir y Repetir):

1. La terminal muestra un indicador o *prompt* (por ejemplo, `/data/ch03>`) indicando el directorio actual y que está lista para recibir instrucciones.
2. El usuario escribe una línea de comando y presiona **`Enter`**.
3. El *shell* analiza (*parsea*) y evalúa la instrucción, ejecutando los programas o transformaciones correspondientes.
4. El resultado se imprime en la pantalla y el *prompt* vuelve a aparecer.

### Ejecutar un Comando y Guardar Resultados en Archivos

Ingresemos al directorio correspondiente a este capítulo (`/data/ch03`) e inspeccionemos los archivos disponibles:

```nu
cd /data/ch03
ls | select name type size
```

Si deseamos inspeccionar las primeras 5 líneas del archivo `movies.txt`, abrimos el archivo en el directorio actual (`open movies.txt`), dividimos sus líneas con `lines` y tomamos las primeras 5 con `first 5`:

```nu
cd /data/ch03
open movies.txt | lines | first 5
```

En ciencia de datos reproducible, además de visualizar el resultado en pantalla, frecuentemente necesitamos persistir el resultado procesado en un nuevo archivo utilizando el comando `save -f`:

```nu
cd /data/ch03
open movies.txt | lines | first 5 | to text | save -f movies_top5.txt
open movies_top5.txt
```

### Tipos de Herramientas en la Línea de Comandos

Cuando escribimos el nombre de un comando en la terminal, este puede corresponder a uno de cinco tipos de herramientas:

1. **Comando interno (*built-in*) de Nushell:** Ejecutado directamente por el motor de Nushell en memoria y que opera nativamente sobre datos estructurados (por ejemplo, `ls`, `open`, `where`, `select`, `math avg`).
2. **Comando personalizado (*custom command* / función):** Definido por el usuario o en un módulo mediante `def` o `export def` (por ejemplo, `to-vw` o `tapkee-reduce`).
3. **Alias:** Un nombre abreviado que expande a otro comando con opciones predefinidas (`alias ll = ls -l`).
4. **Script ejecutable interpretado:** Un archivo de texto con permisos de ejecución y una línea inicial *shebang* (`#!/usr/bin/env nu`, `#!/usr/bin/env python3`, `#!/usr/bin/env Rscript`).
5. **Ejecutable binario compilado:** Un programa compilado a código máquina ubicado en el `$env.PATH` del sistema (como `ttt`, `timg`, `vw`, `tapkee` o `git`).

Podemos consultar de qué tipo es cualquier comando utilizando `which`:

```nu
which ls open ttt timg python3 Rscript
```

### Otros Shells como Bash y Zsh: Qué Hacen, su Filosofía y su Uso

Para comprender cabalmente por qué **Nushell** representa un cambio de paradigma en la ciencia de datos, es fundamental conocer primero cómo funcionan los *shells* tradicionales de Unix/Linux, tales como **Bourne Shell (`sh`)**, **Bourne-Again Shell (`bash`)** y **Z Shell (`zsh`)**.

#### ¿Qué es y qué hace un Shell Tradicional?

Un *shell* tradicional cumple dos roles simultáneos en un sistema operativo tipo Unix:

- **Intérprete interactivo de órdenes:** Actúa como intermediario entre el usuario y el núcleo (*kernel*) del sistema operativo. Cuando escribes un comando en `bash`, el *shell* busca un archivo binario en las rutas de la variable `PATH`, solicita al *kernel* crear un nuevo proceso hijo mediante las llamadas al sistema `fork()` y `execve()`, y espera a que el proceso termine.
- **Lenguaje de *scripting* y automatización:** Permite encadenar programas, definir variables de entorno, evaluar condicionales (`if/then/fi`) y ejecutar ciclos (`for`, `while`) para automatizar tareas repetitivas de administración de sistemas.

#### La Filosofía Unix y los Flujos de Texto Plano

Diseñada en los Laboratorios Bell en la década de 1970 por Ken Thompson, Dennis Ritchie y Douglas McIlroy, la **filosofía Unix** se resume en tres principios fundamentales formulados por McIlroy (creador de las tuberías o *pipes* de Unix en 1973):

1. *Escribe programas que hagan una sola cosa y la hagan bien.*
2. *Escribe programas que trabajen juntos.*
3. *Escribe programas que manejen flujos de texto, porque esa es una interfaz universal.*

En `bash` y los demás *shells* compatibles con el estándar **POSIX**, cada proceso se comunica con el exterior a través de tres canales o flujos de bytes sin estructura:

- **Entrada estándar (`stdin`, descriptor 0):** Flujo de texto que el programa lee como entrada.
- **Salida estándar (`stdout`, descriptor 1):** Flujo de texto donde el programa escribe sus resultados normales.
- **Error estándar (`stderr`, descriptor 2):** Flujo de texto donde el programa emite mensajes de diagnóstico o error.

![Redirección de salida estándar en la terminal](dscl_0202.png)

#### Uso y Sintaxis Habitual en Bash

En un *shell* tradicional como `bash`, todas las herramientas (`grep`, `sed`, `awk`, `cut`, `tr`, `sort`, `uniq`, `wc`, `head`, `tail`) reciben **texto plano línea por línea** y devuelven **texto plano línea por línea**. Por ejemplo, en `bash`:

```bash
# skip-docker-exec
# Filtrar líneas que contienen "CHAPTER" y guardarlas con redirección '>'
grep "CHAPTER" alice.txt > chapters.txt

# Cortar la primera y tercera columna separadas por coma, ordenar y contar líneas
cut -d ',' -f 1,3 datos.csv | sort | uniq -c | head -n 5
```

En `bash`, el símbolo `|` conecta el flujo de bytes crudos del `stdout` del comando izquierdo con el `stdin` del comando derecho, mientras que `>` y `>>` redirigen ese flujo de bytes para sobrescribir o anexar un archivo en disco.

#### ¿Por qué el Modelo de Texto Plano de Bash es Frágil para la Ciencia de Datos?

Aunque el flujo de texto plano fue revolucionario hace cincuenta años, cuando hacemos **ciencia de datos moderna** trabajar únicamente con flujos de caracteres sin estructura introduce cuatro problemas críticos:

1. **Ausencia de tipos de datos:** Para `bash`, el número `42.5`, la fecha `2026-10-20`, el booleano `true` y el texto `"hola"` son exactamente lo mismo: secuencias de bytes ASCII. Para sumar una columna o comparar números hay que invocar lenguajes externos como `awk` o `bc`.
2. **Fragilidad ante delimitadores y espacios:** Herramientas como `cut -d ','` o `awk` dividen el texto buscando comas o espacios literales. Si un archivo CSV contiene un campo entre comillas con una coma interna (por ejemplo, `"Concepción, Chile"`), `cut` y `awk` parten erróneamente la columna por la mitad y corrompen toda la tabla.
3. **Pérdida de encabezados:** Si aplicas `sort` o `grep` a un archivo CSV en `bash`, la primera línea (que contiene los nombres de las columnas) es tratada como una fila de datos cualquiera, mezclándose con los registros o desapareciendo tras el filtro.
4. **Incompatibilidad con datos jerárquicos (JSON, XML, Excel, SQLite, Parquet):** El texto línea por línea no puede representar directamente objetos anidados ni tablas tipadas sin recurrir a múltiples conversores externos (`jq`, `xmllint`, `sqlite3`) con sintaxis inconexas entre sí.

**Nushell conserva lo mejor de la filosofía Unix** (la composición modular mediante tuberías `|`), pero reemplaza los flujos de texto crudo por **flujos de datos estructurados y tipados (tablas, registros y listas)**. Comprender esta diferencia hace que la siguiente sección resulte completamente natural.
'#
}

export def get_ch2_ttt []: nothing -> string {
    r#'
## Edición de Archivos en la Terminal con `ttt`

Cuando trabajamos en ciencia de datos desde la línea de comandos (especialmente dentro de contenedores Docker o servidores remotos vía SSH), necesitamos un editor de texto rápido, ergonómico y que funcione íntegramente dentro de la terminal. En el contenedor `dsin` disponemos de **`ttt`** (*Terminal Text Editor*), ubicado directamente en `$env.PATH` y preconfigurado con resaltado de sintaxis y atajos de teclado intuitivos.

Podemos verificar la versión instalada de `ttt` llamándolo directamente desde Nushell:

```nu
ttt -v
```

### Uso Básico de `ttt`

Para crear o editar un script de Nushell, Python, R o un archivo de configuración dentro de nuestro directorio del capítulo (`/data/ch03`), ejecutamos en una sesión interactiva:

```nu
# skip-docker-exec
cd /data/ch03
ttt mi_script.nu
```

Atajos esenciales preconfigurados en `ttt` dentro de `dsin`:

- **`Ctrl + S`:** Guardar el archivo actual.
- **`Ctrl + Q`:** Salir del editor.
- **`Ctrl + F`:** Buscar texto dentro del archivo.
- **`Ctrl + Z` / `Ctrl + Y`:** Deshacer / Rehacer cambios.

También podemos generar archivos estructurados directamente desde tuberías de Nushell en el directorio actual usando `save -f` y luego ejecutarlos o inspeccionarlos:

```nu
cd /data/ch03
"# Script generado en /data/ch03\ndef saludo [nombre: string] {\n  $\"Hola, ($nombre)!\"\n}\nsaludo 'Ciencia de Datos en Nushell'\n" | save -f ejemplo_ttt.nu
nu ejemplo_ttt.nu
nu ejemplo_ttt.nu | save -f saludo_salida.txt
open saludo_salida.txt
```
'#
}

export def get_ch3_maps_and_cli_tools []: nothing -> string {
    r##'
## Ejemplo de Desarrollo de Comando: API de Google Maps y Geocodificación

En esta sección desarrollaremos un módulo reutilizable de Nushell (`maps.nu`) que interactúa con la **API de Google Maps** (y su equivalente abierto en **OpenStreetMap Nominatim**) para realizar geocodificación directa (obtener latitud y longitud a partir de una dirección postal) y geocodificación inversa (obtener la dirección formateada a partir de coordenadas geográficas).

### Obtener API Key

Para utilizar los servicios oficiales de Google Maps Platform se debe crear una clave de acceso (*API Key*) en el sitio web de [Google Cloud Console](https://console.cloud.google.com/cloud-resource-manager):

1. Ingrese al sitio web de Google Cloud Console.
2. Cree un nuevo proyecto.
3. Diríjase al *Dashboard* y seleccione el proyecto recién creado.
4. Diríjase a *APIs & Services* $\rightarrow$ *Library*.
5. Busque y active **Geocoding API** y **Directions API**.
6. Diríjase a *APIs & Services* $\rightarrow$ *Credentials*.
7. Haga clic en *Create Credentials* $\rightarrow$ *API Key* y guarde la clave obtenida en un lugar seguro.

### Exploración de la API y Anatomía de una URL

De acuerdo con la [documentación oficial de Geocoding API](https://developers.google.com/maps/documentation/geocoding), podemos obtener las coordenadas geográficas asociadas a una dirección o viceversa mediante peticiones HTTP GET.

Nos ubicamos primero en el directorio del capítulo 4 (`/data/ch04`) y definimos la clave de API junto con la dirección de prueba correspondiente al campus Concepción de la Universidad del Bío-Bío:

```nu
cd /data/ch04
let mapsAPIkey = "the_api_key"
let address = "Avenida Collao 1202, Concepcion, Chile"
```

Para consultar la API, debemos construir una URL con la siguiente estructura:

`https://maps.googleapis.com/maps/api/geocode/json?address=Avenida+Collao+1202%2C+Concepcion%2C+Chile&key=the_api_key`

Toda URL (*Uniform Resource Locator*) se compone de las siguientes partes estructurales:

- **Scheme (Esquema):** Indica el *protocolo* utilizado para acceder al recurso:
  - `http://` (*Hypertext Transfer Protocol*): Protocolo estándar sin cifrar.
  - `https://` (*HTTP Secure*): Versión cifrada mediante TLS/SSL para comunicación segura.
  - `ftp://` (*File Transfer Protocol*): Transferencia de archivos.
  - `file://`: Acceso a archivos en el sistema local.
- **Host (Servidor):** Especifica el nombre de dominio (por ejemplo, `maps.googleapis.com`) o dirección IP donde reside el servicio, opcionalmente seguido de un puerto (`:8080`).
- **Path (Ruta):** Identifica el recurso o *endpoint* específico dentro del servidor, comenzando con `/` (por ejemplo, `/maps/api/geocode/json`).
- **Parámetros (*Query Parameters*):** Pares `clave=valor` opcionales que siguen al signo de interrogación `?` y se separan mediante `&` (por ejemplo, `address=...&key=...`).

En lugar de concatenar cadenas manualmente (lo que es propenso a errores con espacios y caracteres especiales), el comando **`url join`** de Nushell construye y codifica automáticamente una URL válida a partir de un registro estructurado, y podemos guardar esta estructura en un archivo de configuración:

```nu
cd /data/ch04
let mapsAPIkey = "the_api_key"
let address = "Avenida Collao 1202, Concepcion, Chile"
let url_record = {
    scheme: "https"
    host: "maps.googleapis.com"
    path: "/maps/api/geocode/json"
    params: {
        address: $address
        key: $mapsAPIkey
    }
}
$url_record | url join
$url_record | save -f consulta_maps.json
```

De igual manera, el comando inverso **`url parse`** descompone cualquier URL en sus componentes estructurales como un registro de Nushell:

```nu
cd /data/ch04
open consulta_maps.json | url join | url parse
open consulta_maps.json | url join | url parse | save -f url_descompuesta.json
```

Cuando se realiza la petición con una clave activa mediante `let response = (http get $url)`, la respuesta JSON de Google Maps contiene la tabla `results`, dentro de la cual se ubica el registro `geometry.location` con los campos numéricos `lat` y `lng`:

```nu
# Estructura de respuesta devuelta por Google Geocoding API
let sample_response = {
    status: "OK"
    results: [
        {
            formatted_address: "Collao 1202, Concepción, Bío Bío, Chile"
            geometry: {
                location: { lat: -36.8221967, lng: -73.0120093 }
            }
        }
    ]
}
$sample_response.results | select formatted_address
$sample_response.results.geometry.location
$sample_response.results.geometry.location | save -f coordenadas_ubb.json
```

### Empaquetando el Módulo `maps.nu` con `ttt`

Podemos compilar estas dos operaciones (geocodificación directa e inversa) en un módulo reutilizable `maps.nu` dentro de `/data/ch04` editándolo con `ttt`:

```nu
# skip-docker-exec
cd /data/ch04
ttt maps.nu
```

El archivo `maps.nu` (ya disponible en `/data/ch04/maps.nu`) contiene los dos comandos exportados `loc-from-address` y `address-from-loc`:

```nu
cd /data/ch04
open --raw maps.nu
```

Cuando se cuenta con una clave válida de Google Maps, se importa el módulo con `use maps.nu *` y se invocan ambos comandos:

```nu
# skip-docker-exec
cd /data/ch04
use maps.nu *
loc-from-address "Avenida Collao 1202, Concepcion, Chile"
address-from-loc -36.8221967 -73.0120093
```

## Conversión de One-Liners en Herramientas de Línea de Comandos

A lo largo del curso construiremos numerosas tuberías compactas de una sola línea (*one-liners*). Cuando necesitamos reutilizar un *one-liner* frecuentemente sobre distintos archivos o con diferentes parámetros, conviene transformarlo en una **herramienta de línea de comandos ejecutable**.

En `/data/ch04` contamos con el texto completo de *Las aventuras de Alicia en el país de las maravillas* (`alice.txt`) y una lista de palabras vacías del idioma inglés (`stopwords`):

```nu
cd /data/ch04
ls | select name type size
```

Primero, veamos cómo obtener las 10 palabras más frecuentes de `alice.txt` en Nushell (sin filtrar y filtrando *stopwords*), mostrando el resultado en pantalla y guardándolo también en un archivo CSV:

```nu
cd /data/ch04
open --raw alice.txt
| str lowercase
| parse --regex '(?P<word>[a-z]{2,})'
| get word
| uniq -c
| rename word count
| sort-by count --reverse
| first 10
```

Ahora filtramos las palabras vacías contenidas en el archivo `stopwords` y guardamos el resultado tanto en pantalla como en el archivo `top10_alice.csv`:

```nu
cd /data/ch04
let sw = (open --raw stopwords | lines | each { str trim | str lowercase })
let top10 = (
    open --raw alice.txt
    | str lowercase
    | parse --regex '(?P<word>[a-z]{2,})'
    | get word
    | where { |w| not ($w in $sw) }
    | uniq -c
    | rename word count
    | sort-by count --reverse
    | first 10
)
$top10
$top10 | save -f top10_alice.csv
```

Para convertir este *one-liner* en una herramienta de línea de comandos reutilizable y parametrizada en Nushell, seguimos **6 pasos sistemáticos**:

1. Crear el archivo de script (`top-words-1.nu`).
2. Otorgar permisos de ejecución (`chmod u+x`).
3. Definir la línea *shebang* (`#!/usr/bin/env nu`).
4. Remover la entrada fija para leer desde la tubería (`$in`).
5. Añadir argumentos y opciones tipadas con `def main [...]`.
6. Extender la variable de entorno `$env.PATH`.

### Paso 1: Crear el Archivo

En `/data/ch04` guardamos nuestra tubería inicial en `top-words-1.nu` (también podemos crearla o editarla interactivamente con `ttt top-words-1.nu`):

```nu
cd /data/ch04
open --raw top-words-1.nu
nu top-words-1.nu
nu top-words-1.nu | save -f salida_paso1.csv
```

### Paso 2: Dar Permisos de Ejecución

Copiamos `top-words-1.nu` a `top-words-2.nu` y le otorgamos permisos de ejecución para el usuario propietario mediante `chmod u+x`:

```nu
cd /data/ch04
cp top-words-1.nu top-words-2.nu
chmod u+x top-words-2.nu
ls -l top-words-1.nu top-words-2.nu | select name mode size
```

En la columna `mode` (por ejemplo, `-rwxr-xr-x`), el primer carácter `-` indica un archivo regular (o `d` si es un directorio), los tres siguientes (`rwx`) corresponden a los permisos de lectura (`r`), escritura (`w`) y ejecución (`x`) del propietario (`u`), seguidos por los permisos del grupo (`g`) y de otros usuarios (`o`).

### Paso 3: Definir el Shebang

El *shebang* (`#!/usr/bin/env nu`) en la primera línea del archivo le indica al sistema operativo que debe utilizar el ejecutable `nu` ubicado en el entorno para interpretar el script cuando se invoca directamente como `./top-words-3.nu`:

```nu
cd /data/ch04
open --raw top-words-3.nu
./top-words-3.nu
./top-words-3.nu | save -f salida_paso3.json
```

### Paso 4: Remover la Entrada Fija

Si reemplazamos `open --raw alice.txt` por la variable especial de entrada de tubería `$in` en `top-words-4.nu`, nuestra herramienta deja de estar atada a un único archivo y puede analizar cualquier texto que le enviemos mediante `|`:

```nu
cd /data/ch04
open --raw top-words-4.nu
open --raw alice.txt | ./top-words-4.nu
open --raw alice.txt | ./top-words-4.nu | save -f salida_paso4.json
```

### Paso 5: Añadir Argumentos y Opciones Tipadas (`def main`)

En Nushell, al definir `def main [num_words: int = 10, --stopwords-file (-s): path = "stopwords"]` dentro de un script ejecutable (`top-words-5.nu`), Nushell valida automáticamente los tipos de los argumentos, asigna valores por defecto y genera la página de ayuda `--help` sin necesidad de librerías externas:

```nu
cd /data/ch04
open --raw top-words-5.nu
open --raw alice.txt | ./top-words-5.nu 8
open --raw alice.txt | ./top-words-5.nu 8 | save -f top8_alice.json
```

### Paso 6: Extender el `$env.PATH`

Para poder invocar nuestra herramienta desde cualquier directorio sin escribir `./`, agregamos el directorio `/data/ch04` (o `/home/dsin/bin`) a `$env.PATH`:

```nu
cd /data/ch04
cp top-words-5.nu /home/dsin/bin/top-words-nu
chmod +x /home/dsin/bin/top-words-nu
open --raw alice.txt | top-words-nu 5
open --raw alice.txt | top-words-nu 5 | save -f top5_alice.json
```

## Creando Herramientas de Línea de Comandos con Python y R

Dado que la línea de comandos es agnóstica al lenguaje, podemos combinar scripts escritos en **Python** (`#!/usr/bin/env python3`) y **R** (`#!/usr/bin/env Rscript`) dentro de nuestras tuberías de Nushell. Siguiendo las buenas prácticas del curso, siempre creamos o inspeccionamos primero el archivo `.py` o `.R` en el directorio del capítulo y luego lo invocamos desde Nushell, convirtiendo su salida en una tabla estructurada con `from csv` y guardando los resultados.

### Portando la Herramienta a Python (`top-words.py`) y R (`top-words.R`)

En `/data/ch04` disponemos de las implementaciones completas en Python (`top-words.py`) y en R (`top-words.R`). Inspeccionemos primero el archivo `top-words.py` y ejecutémoslo desde Nushell:

```nu
cd /data/ch04
open --raw top-words.py
open --raw alice.txt | python3 top-words.py 5 | from csv
open --raw alice.txt | python3 top-words.py 5 | from csv | save -f top_words_py.csv
```

Ahora inspeccionemos el script en R (`top-words.R`), ejecutémoslo sobre `alice.txt`, transformemos su salida a una tabla de Nushell y guardémosla en `top_words_r.csv`:

```nu
cd /data/ch04
open --raw top-words.R
open --raw alice.txt | Rscript top-words.R 5 | from csv
open --raw alice.txt | Rscript top-words.R 5 | from csv | save -f top_words_r.csv
```

### Procesando Datos en Transmisión (*Streaming*) desde `stdin` (`fizzbuzz.py` y `fizzbuzz.R`)

Cuando la entrada es un flujo línea por línea, tanto Python como R pueden procesar cada línea conforme llega desde `stdin`. En `/data/ch04` contamos con `fizzbuzz.py` y `fizzbuzz.R`, que implementan el problema clásico de *FizzBuzz* (imprimir `"fizz"` si el número es divisible por 3, `"buzz"` si es divisible por 5, y `"fizzbuzz"` si es divisible por 15):

```nu
cd /data/ch04
open --raw fizzbuzz.py
1..15 | to text | python3 fizzbuzz.py | lines | wrap resultado_py
1..15 | to text | python3 fizzbuzz.py | lines | wrap resultado_py | save -f fizzbuzz_py.csv
```

Y de manera idéntica con el script `fizzbuzz.R`:

```nu
cd /data/ch04
open --raw fizzbuzz.R
1..15 | to text | Rscript fizzbuzz.R | lines | wrap resultado_r
1..15 | to text | Rscript fizzbuzz.R | lines | wrap resultado_r | save -f fizzbuzz_r.csv
```
'##
}

export def get_ch4_content []: nothing -> string {
    r#'
# Obtención de Datos {#chapter-5-data-acquisition}

Este capítulo aborda el primer paso del modelo OSEMN: la **obtención de datos** (*Obtain*). Los datos pueden provenir de archivos locales, servidores web HTTP/HTTPS, archivos comprimidos (`.tar.gz`, `.zip`), hojas de cálculo de Microsoft Excel (`.xlsx`), bases de datos relacionales SQLite (`.db`) o APIs web REST y de transmisión continua (*streaming*).

Comenzamos ingresando al directorio `/data/ch05` (que corresponde al Capítulo 5 y ya viene incluido por defecto en el contenedor `dsin`) e inspeccionando sus archivos:

```nu
cd /data/ch05
ls | select name type size | sort-by name
```

## Copiando Archivos Locales en el Contenedor Docker

Aunque la imagen `dsin` ya incluye todos los conjuntos de datos del curso en `/data/ch03` a `/data/ch09`, en proyectos propios es frecuente necesitar transferir archivos adicionales entre el computador anfitrión y el contenedor Docker:

- **Montando una carpeta local al iniciar el contenedor:** Ejecutando `docker run --rm -it -v "$(pwd):/data/mis_datos" ghcr.io/kurokirasama/dsin:latest`.
- **Copiando archivos hacia o desde un contenedor en ejecución:** Utilizando `docker cp archivo_local.csv <container_id>:/data/ch05/` desde el sistema anfitrión.

## Descargando desde Internet con `http get`

Nushell incorpora su propio cliente HTTP nativo (`http get`, `http post`, `http head`, `http put`, `http delete`) que reemplaza a herramientas clásicas como `curl` o `wget`. La gran ventaja de `http get` es que, cuando el servidor devuelve contenido estructurado (como JSON), **Nushell lo convierte automáticamente en una tabla o registro navegable**.

### Descargando Archivos JSON y Páginas Web

En `/data/ch05` contamos con el archivo `urls.json` y muestras de publicaciones JSON. Cuando consultamos un *endpoint* REST o abrimos `posts_sample.json`, podemos explorar la tabla devuelta y guardarla inmediatamente en disco con `save -f`:

```nu
cd /data/ch05
let response = (open posts_sample.json)
$response | first 3 | select userId id title
$response | save -f posts.json
open posts.json | first 3 | select id title
```

Si descargamos o leemos un documento HTML (como `MolinosFriesland.html` en `/data/ch05`), podemos inspeccionar sus primeras líneas con `open --raw` y guardar un extracto procesado:

```nu
cd /data/ch05
open --raw MolinosFriesland.html | lines | first 10
open --raw MolinosFriesland.html | lines | first 10 | to text | save -f molinos_encabezado.txt
```

### Descargando desde Múltiples URLs y Consultas `http post`

En `/data/ch05/urls.json` tenemos una lista de *endpoints* bajo la clave `urls`:

```nu
cd /data/ch05
open urls.json
open urls.json | get urls
open urls.json | get urls | to text | save -f lista_urls.txt
```

Cuando trabajamos con conexión a Internet, podemos recorrer todas las URLs con `each { |u| http get $u }` o enviar cargas útiles (*payloads*) JSON a un servidor mediante `http post`:

```nu
# skip-docker-exec
cd /data/ch05
open urls.json | get urls | each { |u| http get $u } | save -f respuestas_api.json

{
  my_payload: {
    title: "foo"
    body: "bar"
    userId: 1
  }
} | get my_payload | to json | http post --content-type "application/json" https://jsonplaceholder.typicode.com/posts $in
```

### Siguiendo Redirecciones e Inspeccionando Cabeceras HTTP (`http head`)

Cuando se accede a una URL acortada (como `bit.ly`) o se depura un servidor web, es útil inspeccionar únicamente las cabeceras HTTP y el código de estado (por ejemplo, `200 OK`, `301 Moved Permanently`, `303 See Other`, `403 Forbidden`, `404 Not Found`) utilizando `http head` o la bandera `--full` de `http get`:

```nu
# skip-docker-exec
http head https://www.wikipedia.org | first 8
```

## Descomprimiendo Archivos

Cuando un conjunto de datos es muy grande o agrupa decenas de archivos pequeños, suele distribuirse comprimido en formatos como `.tar.gz`, `.zip` o `.7z`.

En `/data/ch05` disponemos del archivo comprimido `logs.tar.gz`. Antes de extraerlo a ciegas, inspeccionamos su tabla de contenidos con `tar -tzf`:

```nu
cd /data/ch05
tar -tzf logs.tar.gz | lines | first 10
tar -tzf logs.tar.gz | lines | save -f indice_logs.txt
```

Como los archivos dentro de `logs.tar.gz` no están contenidos en una subcarpeta única, creamos primero el directorio `logs_extraidos` con `mkdir` y descomprimimos allí usando la opción `-C`, consolidando luego el conteo de líneas de cada archivo en una tabla que también guardamos en `resumen_logs.csv`:

```nu
cd /data/ch05
rm -rf logs_extraidos
mkdir logs_extraidos
tar -xzf logs.tar.gz -C logs_extraidos
let resumen_logs = (
    ls logs_extraidos
    | each { |f|
        {
            archivo: ($f.name | path basename)
            bytes: $f.size
            lineas: (open --raw $f.name | lines | length)
        }
    }
    | sort-by archivo
)
$resumen_logs | first 5
$resumen_logs | save -f resumen_logs.csv
```

## Conversión de Hojas de Cálculo de Microsoft Excel y Archivos CSV

El formato CSV (*Comma-Separated Values*) almacena registros tabulares separados por saltos de línea y campos delimitados por comas. En `/data/ch05` tenemos tres variantes del conjunto de datos de las Tortugas Ninja (`tmnt-with-header.csv`, `tmnt-basic.csv` y `tmnt-missing-newline.csv`).

En Nushell, `open` detecta automáticamente el encabezado de `tmnt-with-header.csv`:

```nu
cd /data/ch05
open tmnt-with-header.csv
open tmnt-with-header.csv | save -f tmnt_con_encabezado.json
```

Si un archivo CSV **no posee fila de encabezado** (como `tmnt-missing-newline.csv`), utilizamos `open --raw` combinado con `from csv --noheaders` y asignamos nombres descriptivos con `rename`, guardando la tabla normalizada en `tmnt_normalizado.csv`:

```nu
cd /data/ch05
open --raw tmnt-missing-newline.csv | from csv --noheaders | rename nombre apodo color arma
open --raw tmnt-missing-newline.csv | from csv --noheaders | rename nombre apodo color arma | save -f tmnt_normalizado.csv
```

Por su parte, para trabajar con hojas de cálculo de **Microsoft Excel (`.xlsx` y `.xls`)**, Nushell no necesita herramientas externas: el comando `open` lee directamente el libro Excel y devuelve un registro donde cada clave es el nombre de una hoja de trabajo. Inspeccionemos `cars.xlsx` en `/data/ch05`:

```nu
cd /data/ch05
open cars.xlsx | columns
```

Vemos que `cars.xlsx` contiene la hoja `autos`. Extraemos dicha hoja con `get autos`, mostramos sus primeras filas y la exportamos a un archivo CSV (`cars_exportado.csv`):

```nu
cd /data/ch05
open cars.xlsx | get autos | first 5 | select make "body.style" horsepower "city.mpg" price
open cars.xlsx | get autos | save -f cars_exportado.csv
```

Si deseamos filtrar únicamente los vehículos de la marca `toyota` usando una expresión regular (`^toyota$`), mostramos la tabla resultante y la guardamos en `cars_toyota.csv`:

```nu
cd /data/ch05
open cars.csv | where make =~ '^toyota$' | select make "body.style" "engine.size" horsepower price | first 8
open cars.csv | where make =~ '^toyota$' | save -f cars_toyota.csv
```

## Consultando Bases de Datos Relacionales (SQLite)

En `/data/ch05` disponemos de la base de datos relacional SQLite `r-datasets.db`, que almacena conjuntos de datos clásicos de R. En Nushell podemos inspeccionar las tablas contenidas en la base de datos directamente con `open r-datasets.db | columns`:

```nu
cd /data/ch05
open r-datasets.db | columns | first 10
```

Para ejecutar consultas SQL `SELECT` directamente sobre `r-datasets.db`, utilizamos el comando nativo **`query db`**, mostrando el resultado como tabla Nushell y guardándolo en `mtcars_ordenado.csv`:

```nu
cd /data/ch05
open r-datasets.db | query db "SELECT row_names, mpg, cyl, hp, wt FROM mtcars ORDER BY mpg DESC" | first 8
open r-datasets.db | query db "SELECT row_names, mpg, cyl, hp, wt FROM mtcars ORDER BY mpg DESC" | save -f mtcars_ordenado.csv
```

También podemos realizar agrupaciones SQL directamente con `query db` y guardar el resumen en `mtcars_por_cilindros.csv`:

```nu
cd /data/ch05
let resumen_cyl = (
    open r-datasets.db
    | query db "SELECT cyl, COUNT(*) AS n_autos, ROUND(AVG(mpg), 2) AS mpg_promedio, ROUND(AVG(hp), 1) AS hp_promedio FROM mtcars GROUP BY cyl ORDER BY cyl"
)
$resumen_cyl
$resumen_cyl | save -f mtcars_por_cilindros.csv
```

## Llamando a las API Web

Las APIs web (*Application Programming Interfaces*) devuelven datos estructurados (generalmente en formato JSON) listos para ser procesados en una tubería de Nushell.

### Autenticación con Clave API

Muchas APIs web (como *News API* o *Google Maps*) requieren una clave de autenticación almacenada de forma segura en un archivo local (por ejemplo, `.secret/newsapi.org_apikey` en `/data/ch05`). En Nushell leemos la clave con `open --raw` y construimos la URL autenticada con `url join`:

```nu
cd /data/ch05
let api_key = (open --raw .secret/newsapi.org_apikey | str trim)
let news_url = ({
    scheme: "https"
    host: "newsapi.org"
    path: "/v2/everything"
    params: {
        q: "linux"
        apiKey: $api_key
    }
} | url join)
$news_url
$news_url | save -f news_endpoint.txt
```

### API de Transmisión (*Streaming*)

Algunas APIs web transmiten eventos en tiempo real de forma continua, como el flujo *EventStreams* de Wikimedia (`https://stream.wikimedia.org/v2/stream/recentchange`). En `/data/ch05` disponemos de una muestra capturada en el archivo `wikimedia-stream-sample`.

En Nushell podemos filtrar las líneas que comienzan con `data: `, quitar el prefijo con `str replace`, convertir cada línea en un registro con `from json` y extraer los títulos editados en la Wikipedia en inglés (`en.wikipedia.org`), mostrando la tabla en pantalla y guardándola en `wikimedia_edits_en.csv`:

```nu
cd /data/ch05
let edits_en = (
    open --raw wikimedia-stream-sample
    | lines
    | where ($it | str starts-with "data: ")
    | each { |line| $line | str replace "^data: " "" | from json }
    | where ($it.type? == "edit") and ($it.server_name? == "en.wikipedia.org")
    | select -o title user bot timestamp
)
$edits_en | first 10
$edits_en | save -f wikimedia_edits_en.csv
```
'#
}

export def get_ch5_content [nu_parsing: string, nu_polars: string]: nothing -> string {
    let sec_head = r#'
# Depuración y Transformación de Datos {#chapter-6-data-cleaning}

Este capítulo aborda el segundo paso del modelo OSEMN: **depurar y transformar los datos** (*Scrub*). Una vez obtenidos los datos, rara vez se encuentran listos para la exploración o el modelado: pueden estar en texto plano sin estructura, requerir filtrado por ubicación o patrón, contener inconsistencias o estar repartidos en múltiples archivos CSV, JSON o HTML.

Comenzamos ingresando al directorio `/data/ch06` e inspeccionando sus archivos:

```nu
cd /data/ch06
ls | select name type size | sort-by name
```

## Transformaciones en una Tubería de Datos

Con frecuencia, la salida de una herramienta requiere una transformación intermedia antes de poder alimentar la siguiente etapa del análisis. Tomemos los primeros 100 elementos de la secuencia *FizzBuzz* generados con `fizzbuzz.py` en `/data/ch06`, guardémoslos en `fb.seq`, y luego contemos en Nushell cuántas veces aparecen `fizz`, `buzz` y `fizzbuzz`, mostrando la tabla resultante y guardándola en `fb.csv`:

```nu
cd /data/ch06
1..100 | to text | python3 fizzbuzz.py | save -f fb.seq
let conteo_fb = (
    open --raw fb.seq
    | lines
    | where ($it =~ "fizz|buzz")
    | uniq -c
    | rename value count
    | sort-by count --reverse
)
$conteo_fb
$conteo_fb | save -f fb.csv
```

## Texto Plano

El texto plano (*plain text*) consiste en secuencias de caracteres legibles por humanos divididas por saltos de línea. En Nushell convertimos cualquier archivo de texto plano en una lista de cadenas mediante `open --raw <archivo> | lines`.

### Filtrando Líneas

#### Basado en la Ubicación

En `/data/ch06` disponemos del archivo `lines` con 10 líneas numeradas (`Line 1` a `Line 10`). Veamos cómo filtrar líneas según su posición con `first`, `last`, `skip`, `drop` y `slice`, mostrando los resultados y guardando los subconjuntos en archivos:

```nu
cd /data/ch06
open --raw lines | lines
```

- **Primeras 3 líneas (`first 3`) y últimas 3 líneas (`last 3`):**

```nu
cd /data/ch06
open --raw lines | lines | first 3
open --raw lines | lines | last 3
open --raw lines | lines | first 3 | to text | save -f lines_primeras3.txt
```

- **Omitir las primeras 3 líneas (`skip 3`), omitir las últimas 3 (`drop 3`) y extraer las líneas 4, 5 y 6 (`slice 3..5`):**

```nu
cd /data/ch06
open --raw lines | lines | skip 3
open --raw lines | lines | drop 3
open --raw lines | lines | slice 3..5
open --raw lines | lines | slice 3..5 | to text | save -f lines_4_a_6.txt
```

- **Extraer únicamente las líneas en posiciones impares usando `enumerate` y el operador módulo (`mod`):**

```nu
cd /data/ch06
open --raw lines | lines | enumerate | where ($it.index mod 2) == 0 | get item
open --raw lines | lines | enumerate | where ($it.index mod 2) == 0 | get item | to text | save -f lines_impares.txt
```

#### Basado en un Patrón

Para conservar o descartar líneas según una expresión regular, utilizamos `where ($it =~ "patrón")` (o `!~` para invertir la coincidencia). En `/data/ch06/alice.txt`, extraigamos los encabezados de capítulos que comienzan con `CHAPTER` seguidos de `The`, y contemos el total de líneas no vacías del libro:

```nu
cd /data/ch06
open --raw alice.txt | lines | where ($it =~ '(?i)^chapter')
open --raw alice.txt | lines | where ($it =~ '^CHAPTER (.*)\. The')
open --raw alice.txt | lines | where ($it =~ '^CHAPTER (.*)\. The') | to text | save -f capitulos_the.txt
open --raw alice.txt | lines | where ($it | str trim | is-not-empty) | length
```

#### Basado en Aleatoriedad (Muestreo)

Cuando formulamos una tubería sobre un archivo muy grande, resulta útil tomar una muestra aleatoria con el comando nativo **`shuffle`** combinado con **`first`**:

```nu
cd /data/ch06
1..1000 | each { |i| $"Line ($i)" } | shuffle | first 10
1..1000 | each { |i| $"Line ($i)" } | shuffle | first 10 | to text | save -f muestra_10_lineas.txt
```

### Extrayendo Valores

Para extraer únicamente el número romano y el título de cada capítulo de `alice.txt` en una tabla estructurada de dos columnas, usamos `parse --regex` con grupos con nombre y guardamos el resultado en `capitulos_alice.csv`:

```nu
cd /data/ch06
let caps = (
    open --raw alice.txt
    | lines
    | where ($it =~ '^CHAPTER ')
    | parse --regex '^CHAPTER (?P<numero>[IVXLCDM]+)\.\s+(?P<titulo>.*)$'
)
$caps
$caps | save -f capitulos_alice.csv
```

Y si deseamos construir un conjunto de datos con todas las palabras únicas de `alice.txt` que comienzan con la letra `a` y terminan con la letra `e`, mostramos las primeras 15 y guardamos el listado completo en `palabras_a_e.csv`:

```nu
cd /data/ch06
let palabras_ae = (
    open --raw alice.txt
    | str lowercase
    | parse --regex '(?P<palabra>[a-z]{2,})'
    | get palabra
    | where ($it =~ '^a.*e$')
    | uniq
    | sort
    | wrap palabra
)
$palabras_ae | first 15
$palabras_ae | save -f palabras_a_e.csv
```

### Reemplazando y Eliminando Valores

En Nushell, la familia de comandos `str` (`str replace`, `str uppercase`, `str lowercase`, `str trim`) opera nativamente sobre texto **UTF-8**, por lo que convierte correctamente caracteres acentuados y no ASCII (como `'hallo wêreld!'` o `'helló világ'`) donde la herramienta clásica `tr` fallaba por operar sobre bytes individuales:

```nu
cd /data/ch06
"hello world!" | str replace -a " " "_"
"hello world!" | str replace -a --regex '[ !]' ''
"hallo wêreld!" | str uppercase
"helló világ" | str uppercase
"  hello     world!  " | str trim | str replace -a --regex '\s+' ' ' | str replace "hello" "bye"
"  hello     world!  " | str trim | str replace -a --regex '\s+' ' ' | str replace "hello" "bye" | save -f saludo_limpio.txt
```
'#

    let sec_csv = r#'
## CSV y Tablas Estructuradas

### Cuerpos, Encabezados y Columnas

En las herramientas clásicas de texto (`grep`, `sed`, `tr`, `sort`), filtrar u ordenar un archivo CSV requería utilidades auxiliares (`body`, `header`, `cols`) para evitar mezclar el encabezado con los datos o modificar columnas equivocadas.

En **Nushell**, al abrir un archivo CSV con `open`, el encabezado se convierte automáticamente en el esquema de nombres de columnas de la tabla, y cualquier operación (`sort-by`, `where`, `update`) actúa exclusivamente sobre las filas o la columna indicada sin corromper jamás el encabezado.

Por ejemplo, en `/data/ch06`, convirtamos a mayúsculas únicamente la columna `day` de `tips.csv`, mostrando las primeras 5 filas y guardando la tabla resultante en `tips_day_upper.csv`:

```nu
cd /data/ch06
open tips.csv | update day { str uppercase } | first 5
open tips.csv | update day { str uppercase } | save -f tips_day_upper.csv
```

### Realizando Consultas SQL en CSV

Cuando deseamos expresar transformaciones complejas utilizando sintaxis **SQL** sobre archivos CSV, Nushell permite volcar cualquier tabla directamente a una base de datos SQLite con `into sqlite` y consultarla con `query db`. Veamos cómo consultar `tips.csv` con SQL y guardar el resultado en `tips_sql_resultado.csv`:

```nu
cd /data/ch06
rm -f tips_temp.db
open tips.csv | into sqlite tips_temp.db
open tips_temp.db | query db "SELECT bill, tip, day, time, size FROM main WHERE bill > 40.0 AND day LIKE 'S%'"
open tips_temp.db | query db "SELECT bill, tip, day, time, size FROM main WHERE bill > 40.0 AND day LIKE 'S%'" | save -f tips_sql_resultado.csv
```

### Extrayendo y Reordenando Columnas

Para extraer un subconjunto de columnas en un orden específico utilizamos `select`, y para excluir una o más columnas conservando el resto utilizamos `reject`:

```nu
cd /data/ch06
open iris.csv | select sepal_length petal_length sepal_width petal_width | first 5
open iris.csv | reject species | first 5
open iris.csv | select sepal_length petal_length sepal_width petal_width | save -f iris_columnas_reordenadas.csv
```

### Filtrando Filas

En Nushell filtramos filas de tablas CSV combinando condiciones numéricas y expresiones regulares legibles mediante `where`:

```nu
cd /data/ch06
open tips.csv | where size >= 5 | first 6
open tips.csv | where bill > 40.0 and day =~ '^S'
open tips.csv | where bill > 40.0 and day =~ '^S' | save -f tips_altos_finde.csv
```

### Combinar Columnas (y Robustez ante Comas Internas)

Consideremos los archivos `names.csv` y `names-comma.csv` en `/data/ch06`, los cuales contienen compositores cuyos nombres (`first_name`) y apellidos (`last_name`) deseamos combinar en una columna `full_name`:

```nu
cd /data/ch06
open names.csv
open names-comma.csv
```

En `names-comma.csv`, el último registro contiene una coma dentro del apellido (`"Stravinsky, Jr."`). Mientras que `sed`, `awk` y `cut` fallaban al partir por esa coma interna, el analizador CSV de Nushell respeta las comillas del estándar RFC 4180 y construye `full_name` de manera impecable:

```nu
cd /data/ch06
let nombres_limpios = (
    open names-comma.csv
    | insert full_name { |row| $"($row.first_name) ($row.last_name)" }
    | select id full_name born
)
$nombres_limpios
$nombres_limpios | save -f names_completos.csv
```

### Combinando Múltiples Archivos CSV

#### Concatenar Horizontalmente (`merge`)

En `/data/ch06` podemos dividir `tips.csv` en tres archivos CSV con distintas columnas (`bills.csv`, `datetime.csv` y `customers.csv`) y luego volver a unirlos horizontalmente lado a lado mediante el comando **`merge`**, guardando el resultado en `tips_horizontal.csv`:

```nu
cd /data/ch06
open tips.csv | select bill tip | save -f bills.csv
open tips.csv | select day time | save -f datetime.csv
open tips.csv | select sex smoker size | save -f customers.csv

let unido_horizontal = (open bills.csv | merge (open customers.csv) | merge (open datetime.csv))
$unido_horizontal | first 5
$unido_horizontal | save -f tips_horizontal.csv
```

#### Unión Relacional (`join`)

Cuando dos tablas comparten una columna clave (como `species` en `iris.csv` e `irismeta.csv`), realizamos un cruce relacional (*inner join*) con el comando **`join`**, seleccionamos las columnas de interés y guardamos el resultado en `iris_usda.csv`:

```nu
cd /data/ch06
open irismeta.csv
let iris_enriquecido = (
    open iris.csv
    | join (open irismeta.csv) species
    | select sepal_length sepal_width species usda_id
)
$iris_enriquecido | slice 48..53
$iris_enriquecido | save -f iris_usda.csv
```

## Trabajando con XML/HTML y JSON

En `/data/ch06` contamos con el archivo JSON `users.json` y los archivos extraídos de Wikipedia `wiki.html`, `table.html` y `table.json`.

En lugar de modificar `users.json` con expresiones regulares de texto como `sed` (lo cual podría alterar valores además de nombres de claves), en Nushell abrimos `users.json` como estructura de datos, renombramos el campo `gender` a `sex` en la tabla `results` y guardamos el resultado tanto en JSON como en CSV:

```nu
cd /data/ch06
let usuarios = (
    open users.json
    | get results
    | select gender email nat phone
    | rename sex email nat phone
)
$usuarios | first 5
$usuarios | save -f users_sex.csv
```

De igual manera, a partir de la tabla HTML convertida a JSON en `table.json` (lista de países y territorios por relación frontera/superficie de Wikipedia), podemos extraer las filas en Nushell y guardar el conjunto de datos tabular en `countries_from_json.csv`:

```nu
cd /data/ch06
open countries.csv | first 10
open countries.csv | first 10 | save -f countries_top10.csv
```
'#

    [$sec_head, $nu_parsing, $sec_csv, $nu_polars] | str join "\n\n"
}
