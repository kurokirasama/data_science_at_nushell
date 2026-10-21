#!/usr/bin/env nu
# =============================================================================
# build_dsin_book.nu
# Builds Files/DataScienceNushell.md (8 unified chapters, 100% Nushell-first,
# /data/ch02..ch08 built-in, save-after-open, no inline R/Python scripts,
# direct ttt/timg/parallel in PATH, GNU parallel + par-each, PCA+t-SNE+K-Means,
# Google Maps API + 4 Web APIs, and add-preamble/pandoc-expert formatting).
# =============================================================================

use chapters_1_to_5.nu *

def get_ch6_content [] {
'# Exploración y Visualización de Datos {#chapter-6-exploring-data}

El cuarto paso del flujo de trabajo OSEMN consiste en explorar los datos. Explorar nuestros conjuntos de datos desde múltiples ángulos (estadístico, estructural y visual) es fundamental antes de construir modelos predictivos. Como destacó John W. Tukey en su clásico libro *Exploratory Data Analysis* (1977), el análisis exploratorio de datos (EDA) nos permite descubrir patrones inesperados, detectar valores atípicos (*outliers*), verificar supuestos y formular hipótesis informadas.

En este capítulo abordaremos la exploración y visualización de datos desde tres perspectivas complementarias dentro de la imagen Docker `dsin`:

1. **Inspección de propiedades estructurales y estadísticas en Nushell**, utilizando los comandos nativos de inspección (`columns`, `describe`, `uniq`, `histogram`), el módulo matemático (`math`) y el motor de DataFrames `polars`.
2. **Cálculo de estadísticas descriptivas y pruebas diagnósticas mediante scripts en R y Python**, integrando sus salidas directamente en tuberías de Nushell para presentarlas como tablas estructuradas.
3. **Creación y visualización de gráficos estadísticos en la terminal**, generando figuras mediante scripts modulares con `ggplot2` en R y `matplotlib`/`seaborn` en Python, e inspeccionándolas directamente dentro de la terminal mediante el visor gráfico **`timg`** preinstalado en la imagen `dsin`.

Todos los archivos y scripts de este capítulo se encuentran preinstalados en `/data/ch06`:

```nushell
cd /data/ch06
ls | select name type size
```

## Inspeccionando Datos y sus Propiedades

Antes de graficar o modelar un conjunto de datos, necesitamos responder preguntas fundamentales sobre su estructura: ¿cuántas filas y columnas tiene?, ¿qué nombres y tipos de datos poseen las variables?, ¿existen columnas constantes o con valores faltantes?

En Nushell, dado que cualquier archivo tabular cargado con `open` se convierte inmediatamente en una tabla tipada en memoria, podemos responder estas preguntas combinando selectores y filtros nativos, y guardar los resúmenes o tablas depuradas directamente en disco.

### ¿Tiene Encabezado, Cuántos Registros y Qué Columnas?

Inspeccionemos el archivo `venture.csv` ubicado en `/data/ch06`:

```nushell
cd /data/ch06
open --raw venture.csv | lines | first 5
```

Al abrirlo de forma estructurada con `open venture.csv`, Nushell interpreta automáticamente la primera línea como encabezado y tipifica cada columna. Podemos consultar el número total de registros con `length` y listar los nombres de las columnas junto con su índice usando `columns` y `enumerate`:

```nushell
cd /data/ch06
open venture.csv | length
open venture.csv | columns | enumerate | first 15
open venture.csv | columns | enumerate | wrap col_info | flatten | save -f venture_columns.csv
```

### Inspeccionando Tipos de Datos e Inferencia de Esquemas

Veamos el archivo `datatypes.csv`, diseñado específicamente para ilustrar distintos tipos de datos (enteros, flotantes, booleanos, fechas y cadenas):

```nushell
cd /data/ch06
open datatypes.csv
open datatypes.csv | save -f datatypes_copy.json
```

Para conocer el tipo exacto que Nushell o Polars asignó a cada columna, podemos emplear `describe` o convertir la tabla a un DataFrame de Polars y consultar `polars schema`:

```nushell
cd /data/ch06
open datatypes.csv | polars into-df | polars schema | transpose column dtype
open datatypes.csv | polars into-df | polars schema | transpose column dtype | save -f datatypes_schema.csv
```

### Identificando Valores Únicos y Eliminando Columnas Constantes

En muchos conjuntos de datos administrativos o financieros (como `venture.csv`), existen columnas que contienen exactamente el mismo valor en todas las filas y que, por tanto, no aportan información estadística ni poder predictivo.

En Nushell podemos detectar el número de valores únicos de cada columna trasponiendo el primer registro o iterando sobre los nombres de las columnas con `get` y `uniq`:

```nushell
cd /data/ch06
let df = (open venture.csv)
let non_const_cols = ($df | columns | where {|c| ($df | get $c | uniq | length) > 1 })
$df | select ...$non_const_cols | first 5
$df | select ...$non_const_cols | save -f venture_clean.csv
```

Observa la claridad del flujo: identificamos programáticamente todas las columnas con más de un valor único (`uniq | length > 1`), filtramos la tabla original conservando únicamente dichas columnas mediante el operador de expansión `...$non_const_cols`, y guardamos el resultado limpio en `venture_clean.csv`.

## Calculando Estadísticas Descriptivas

Trabajemos ahora con el clásico conjunto de datos `tips.csv` (propinas en un restaurante según el total de la cuenta, sexo, hábito de fumar, día, horario y tamaño del grupo), ubicado en `/data/ch06/tips.csv`:

```nushell
cd /data/ch06
open tips.csv | first 10
open tips.csv | first 10 | save -f tips_sample.csv
```

### Estadísticas con `math` y `polars summary` en Nushell

Nushell incluye la familia de comandos `math` (`math sum`, `math avg`, `math median`, `math stddev`, `math variance`, `math min`, `math max`, `math mode`), que operan sobre listas numéricas o sobre todas las columnas numéricas de una tabla:

```nushell
cd /data/ch06
open tips.csv | select bill tip size | math avg
open tips.csv | select bill tip size | math stddev
open tips.csv | select bill tip size | math median | save -f tips_median.json
```

Si deseamos obtener simultáneamente el conteo, media, desviación estándar, mínimo, cuartiles (25%, 50%, 75%) y máximo de todas las variables del dataset, `polars summary` genera una tabla resumen completa en un solo paso:

```nu
cd /data/ch06
open tips.csv | polars into-df | polars summary | polars collect | polars into-nu
open tips.csv | polars into-df | polars summary | polars collect | polars into-nu | save -f tips_summary.csv
```

Para variables categóricas (como `day` o `time`), el comando nativo `histogram` calcula el conteo absoluto, cuantiles y porcentaje relativo, incluyendo además un gráfico de barras ASCII en la propia tabla:

```nu
cd /data/ch06
open tips.csv | histogram day
open tips.csv | histogram day | save -f tips_day_freq.csv
```

### Transformaciones y Resúmenes Estadísticos con Scripts en R y Python

En un flujo de trabajo políglota, frecuentemente deseamos aplicar funciones estadísticas especializadas de R (`dplyr`) o Python (`pandas` / `scipy`) y capturar el resultado de vuelta en Nushell como una tabla estructurada. En lugar de escribir código difícil de mantener en una sola línea, creamos archivos `.R` y `.py` modulares en nuestro directorio de trabajo y los invocamos desde Nushell.

Por ejemplo, revisemos el script `mutate_tips.R` en `/data/ch06`, que calcula el porcentaje de propina (`percent = tip / bill * 100`) usando `dplyr::mutate` y escribe el CSV resultante en la salida estándar:

```nushell
cd /data/ch06
open --raw mutate_tips.R
```

Al ejecutar `Rscript mutate_tips.R` y canalizar su salida hacia `from csv`, Nushell recibe una tabla tipada que podemos filtrar, ordenar y guardar en disco:

```nushell
cd /data/ch06
Rscript mutate_tips.R | from csv | first 10
Rscript mutate_tips.R | from csv | save -f tips_with_percent.csv
```

Del mismo modo, el script `summary_tips.R` agrupa las propinas por día y horario (`group_by(day, time)`) y calcula el conteo, la cuenta media y la propina media:

```nushell
cd /data/ch06
open --raw summary_tips.R
Rscript summary_tips.R | from csv | sort-by mean_tip -r
Rscript summary_tips.R | from csv | sort-by mean_tip -r | save -f tips_grouped_summary.csv
```

Y con Python (`corr_tips.py`), podemos calcular la matriz de correlación de Pearson entre `bill`, `tip` y `size` usando `pandas` y devolverla como tabla a Nushell:

```nushell
cd /data/ch06
open --raw corr_tips.py
python3 corr_tips.py | from csv
python3 corr_tips.py | from csv | save -f tips_correlations.csv
```

## Creando Visualizaciones Estadísticas desde la Línea de Comandos

Las estadísticas resumen nunca sustituyen por completo a la inspección visual (como demuestra el célebre *Cuarteto de Anscombe*, donde cuatro conjuntos de datos con idéntica media, varianza y correlación exhiben estructuras geométricas radicalmente distintas).

En nuestro entorno `dsin`, combinamos la potencia gráfica de **`ggplot2`** (en R) y **`matplotlib`/`seaborn`** (en Python) con el visor de imágenes de terminal **`timg`**. Como tanto `Rscript`, `python3` y `timg` están configurados en el `PATH` por defecto del contenedor `dsin`, podemos invocarlos directamente por su nombre sin prefijos especiales.

Veamos primero el script `plot_faceted.R`, que genera un gráfico de dispersión de `tip` versus `bill` con rectas de regresión lineal separadas por sexo y día (`tips_faceted.png`):

```nushell
cd /data/ch06
open --raw plot_faceted.R
Rscript plot_faceted.R
ls tips_faceted.png
```

### Visualizando Imágenes Directamente en la Terminal con `timg`

En el flujo de trabajo tradicional de los contenedores Docker sin servidor gráfico X11, el usuario debía copiar cada imagen generada hacia el sistema anfitrión para poder abrirla. En la imagen `dsin`, incluimos **`timg`** (*Terminal Image and Video Viewer*), una herramienta que renderiza archivos PNG, JPEG, SVG o incluso animaciones directamente dentro de la terminal utilizando bloques Unicode de alta resolución o los protocolos gráficos de Kitty/iTerm2/Sixel.

Para visualizar cualquier gráfico generado en `/data/ch06`, basta con ejecutar:

```nushell
cd /data/ch06
timg -g 80x25 tips_faceted.png
```

También podemos mostrar varios gráficos en una cuadrícula comparativa dentro de la terminal usando la bandera `--grid`:

```nushell
cd /data/ch06
Rscript plot_histogram.R
Rscript plot_density.R
timg --grid=2x1 -g 80x25 tips_histogram.png tips_density.png
```

### Alternativa Remota: Copiando Gráficos con `scp`

Si te encuentras conectado por SSH desde una terminal antigua que no soporta color verdadero de 24 bits, siempre puedes descargar la imagen hacia tu máquina local utilizando `scp` (*secure copy*):

```bash
# skip-docker-exec
scp usuario@servidor:/data/ch06/tips_faceted.png .
```

## Catálogo de Gráficos Estadísticos con Scripts en R y Python

La gramática de los gráficos (*Grammar of Graphics*) implementada en `ggplot2` descompone toda visualización estadística en tres elementos esenciales:

1. **Datos (`data`)**: el DataFrame tabular que deseamos representar.
2. **Mapeos estéticos (`aes`)**: la correspondencia entre columnas de los datos y propiedades visuales como posición (`x`, `y`), color (`color`, `fill`), forma (`shape`) o tamaño (`size`).
3. **Objetos geométricos (`geom_*`)**: la representación gráfica concreta (barras, puntos, líneas, cajas, violines o curvas de densidad).

En `/data/ch06` disponemos de una colección completa de scripts listos para usar que ilustran los gráficos fundamentales del análisis exploratorio.

### Gráfico de Barras (`geom_bar`)

Para visualizar la distribución de frecuencias de una variable categórica o discreta, como la cantidad de mesas atendidas por día de la semana en `tips.csv`, ejecutamos `plot_bar.R`:

```nushell
cd /data/ch06
open --raw plot_bar.R
Rscript plot_bar.R
timg -g 80x25 tips_bar.png
```

![Gráfico de barras generado con ggplot2](Files/dscl_0702.png)

### Histograma (`geom_histogram`)

Para inspeccionar la distribución empírica de una variable continua como el monto total de la cuenta (`bill`), ejecutamos `plot_histogram.R`:

```nushell
cd /data/ch06
open --raw plot_histogram.R
Rscript plot_histogram.R
timg -g 80x25 tips_histogram.png
```

![Histograma del total de la cuenta](Files/dscl_0703.png)

Ajustar el número de intervalos (`bins`) es crucial para evitar tanto el sobre-suavizado (pocas barras que ocultan multimodalidad) como el ruido excesivo (demasiadas barras estrechas).

### Gráfico de Densidad (`geom_density`)

Una alternativa suave al histograma es la estimación de densidad por núcleos (*Kernel Density Estimation*, KDE), implementada en `plot_density.R`:

```nushell
cd /data/ch06
open --raw plot_density.R
Rscript plot_density.R
timg -g 80x25 tips_density.png
```

![Estimación de densidad por núcleos](Files/dscl_0706.png)

### Gráfico de Líneas para Series Temporales (`geom_line`)

Cuando trabajamos con registros indexados en el tiempo, como la serie de fallecimientos mensuales por accidentes de tránsito en el Reino Unido (`Fatalities.csv`), un gráfico de líneas revela tendencias seculares y patrones estacionales. Veamos y ejecutemos `plot_accident.R`:

```nushell
cd /data/ch06
open Fatalities.csv | first 5
open Fatalities.csv | first 5 | save -f fatalities_head.csv
open --raw plot_accident.R
Rscript plot_accident.R
timg -g 80x25 fatalities_line.png
```

![Serie temporal de accidentes](Files/dscl_0707.png)

### Diagrama de Dispersión y Tendencia (`geom_point` y `geom_smooth`)

Para estudiar la relación conjunta entre dos variables cuantitativas continuas (`bill` y `tip`), utilizamos `plot_scatter.R` y `plot_trend.R`:

```nushell
cd /data/ch06
open --raw plot_scatter.R
Rscript plot_scatter.R
open --raw plot_trend.R
Rscript plot_trend.R
timg --grid=2x1 -g 80x25 tips_scatter.png tips_trend.png
```

![Diagrama de dispersión con curva de tendencia suavizada](Files/dscl_0710.png)

### Diagrama de Caja (`geom_boxplot`) y Gráfico de Violín (`geom_violin`)

Para comparar la distribución de una variable continua (`bill`) a través de varios grupos categóricos (`day`), los diagramas de caja (*boxplots*) resumen la mediana, el rango intercuartílico ($\text{IQR} = Q_3 - Q_1$) y los valores atípicos, mientras que los gráficos de violín muestran además la forma completa de la densidad en cada grupo:

```nushell
cd /data/ch06
open --raw plot_boxplot.R
Rscript plot_boxplot.R
open --raw plot_violin.R
Rscript plot_violin.R
timg --grid=2x1 -g 80x25 tips_boxplot.png tips_violin.png
```

![Diagrama de caja de cuentas por día](Files/dscl_0713.png)

### Visualización Estadística Equivalente en Python (`matplotlib` / `seaborn`)

También podemos generar visualizaciones multipanel desde Python ejecutando `plot_tips_py.py`, el cual produce el archivo `tips_python.png` y devuelve en formato JSON las estadísticas por día hacia Nushell:

```nushell
cd /data/ch06
open --raw plot_tips_py.py
python3 plot_tips_py.py | from json
python3 plot_tips_py.py | from json | save -f tips_py_summary.json
timg -g 80x25 tips_python.png
```

## Resumen

En este capítulo aprendimos a explorar tanto la estructura como la distribución estadística de nuestros datos desde la línea de comandos. Combinamos la inspección nativa de tablas en Nushell (`columns`, `uniq`, `math`, `histogram`, `polars summary`) con scripts modulares en R y Python (`mutate_tips.R`, `summary_tips.R`, `corr_tips.py`, `plot_*.R`, `plot_tips_py.py`), guardando los datos procesados en archivos estructurados y visualizando cada gráfico directamente dentro de la terminal gracias a `timg`.

En el próximo capítulo estudiaremos cómo acelerar drásticamente el procesamiento de datos y la ejecución de comandos externos utilizando las capacidades de paralelismo nativo de Nushell (`par-each`) junto con GNU `parallel`.'
}

def get_ch7_content [] {
'# Tuberías Paralelas {#chapter-7-parallel-pipelines}

A medida que el volumen de datos o la complejidad computacional de nuestras tareas crece —por ejemplo, al consultar cientos de páginas de una API, comprimir docenas de archivos, entrenar modelos con múltiples combinaciones de hiperparámetros o transformar grandes volúmenes de texto—, la ejecución secuencial en un único núcleo de CPU puede convertirse en un cuello de botella importante.

En este capítulo aprenderemos a escalar nuestros flujos de trabajo desde la línea de comandos mediante dos enfoques complementarios que conviven en la imagen `dsin`:

1. **Paralelismo estructurado nativo en Nushell con `par-each`**, ideal para transformar listas, registros y tablas en memoria utilizando todos los hilos de CPU disponibles sin abandonar el modelo de tipos de Nushell.
2. **Paralelismo de procesos externos con GNU `parallel`**, la herramienta clásica de Unix para orquestar comandos externos, scripts en R/Python, tuberías divididas en bloques (`--pipe`) y ejecución distribuida en múltiples servidores vía SSH.

Todos los archivos de trabajo de este capítulo se encuentran en `/data/ch07`:

```nushell
cd /data/ch07
ls | select name type size
```

## Procesamiento en Serie: Recorriendo Datos con `each`

Antes de paralelizar una tarea, es fundamental asegurarnos de que funciona correctamente de manera secuencial. En Nushell, el comando estándar para iterar sobre cada elemento de una lista o cada fila de una tabla es `each`.

### Iterando sobre Números

Supongamos que queremos calcular el cuadrado de los primeros diez números enteros o evaluar cuáles son divisibles por 3:

```nushell
cd /data/ch07
1..10 | each {|x| {n: $x, cuadrado: ($x * $x), es_mult_3: (($x mod 3) == 0)} }
1..10 | each {|x| {n: $x, cuadrado: ($x * $x), es_mult_3: (($x mod 3) == 0)} } | save -f squares_table.csv
```

Para operaciones aritméticas o científicas más complejas, también contamos en `/data/ch07` con el script `pbc` (*parallel bc*), que evalúa expresiones matemáticas con precisión arbitraria:

```nu
cd /data/ch07
1..5 | to text | pbc "{1}^2" | lines | each {|v| $v | into int }
```

### Iterando sobre Líneas y Filas

En `/data/ch07` tenemos el archivo `movies.txt` y el archivo `input.csv`:

```nu
cd /data/ch07
open --raw movies.txt | lines | enumerate | each {|row| {idx: $row.index, movie: ($row.item | str trim), chars: ($row.item | str length)} }
open --raw movies.txt | lines | enumerate | each {|row| {idx: $row.index, movie: ($row.item | str trim), chars: ($row.item | str length)} } | save -f movies_summary.csv
```

### Iterando sobre Archivos

Del mismo modo, podemos recorrer todos los archivos CSV de un directorio, contar sus filas y consolidar el inventario en un nuevo archivo:

```nu
cd /data/ch07
ls *.csv | each {|f| {archivo: $f.name, bytes: $f.size, filas: (open $f.name | length)} }
ls *.csv | each {|f| {archivo: $f.name, bytes: $f.size, filas: (open $f.name | length)} } | save -f csv_inventory.csv
```

## Procesamiento en Paralelo en Nushell con `par-each`

Cuando el bloque de código que pasamos a `each` realiza trabajo intensivo de CPU o de entrada/salida (I/O) y cada iteración es independiente de las demás (*embarrassingly parallel*), podemos reemplazar `each` directamente por **`par-each`**.

![Comparación conceptual entre ejecución secuencial y ejecución en paralelo](Files/dscl_0801.png)

### Ejecución Concurrente y Control de Hilos (`--threads` y `--keep-order`)

En `/data/ch07` disponemos del script `slow.sh`, que simula un proceso costoso esperando un número aleatorio o fijo de segundos antes de terminar. Comparemos el tiempo de ejecución de 4 tareas usando `each` frente a `par-each` mediante el comando `timeit`:

```nu
cd /data/ch07
1..4 | par-each --threads 4 {|i| {job: $i, msg: $"Tarea ($i) completada"} }
1..4 | par-each --threads 4 --keep-order {|i| {job: $i, cuadrado: ($i * $i)} } | save -f parallel_jobs.csv
```

Dos banderas clave de `par-each` son:

- `--threads (-t) <int>`: limita el número máximo de hilos concurrentes (útil para no saturar un servidor compartido o no exceder límites de tasa de una API web).
- `--keep-order (-k)`: garantiza que la tabla o lista de salida conserve exactamente el mismo orden que la entrada original, independientemente de qué hilo termine primero.

## Paralelización de Procesos con GNU `parallel` desde Nushell

Además de `par-each`, la imagen `dsin` incluye **GNU `parallel`** (desarrollado por Ole Tange) directamente en el `PATH`. Mientras que `par-each` paraleliza cierres (*closures*) internos de Nushell devolviendo estructuras tipadas, GNU `parallel` destaca cuando necesitamos orquestar comandos externos de Unix, dividir flujos gigantescos por bloques de bytes o distribuir trabajos hacia múltiples máquinas remotas por SSH.

![Flujo de ejecución de GNU parallel distribuyendo argumentos en múltiples núcleos](Files/dscl_0802.png)

### Especificando Argumentos y Marcadores de Reemplazo (`{}`, `{/}`, `{.}` y `{#}`)

GNU `parallel` lee argumentos desde la entrada estándar (o tras el separador `:::`) y ejecuta una plantilla de comando para cada argumento utilizando marcadores de reemplazo:

- `{}`: el argumento completo.
- `{.}`: el argumento sin su extensión de archivo.
- `{/}`: el nombre base del archivo sin la ruta del directorio (*basename*).
- `{//}`: únicamente el directorio padre (*dirname*).
- `{#}`: el número secuencial del trabajo ejecutado ($1, 2, \dots, N$).
- `{%}`: el identificador de la ranura de ejecución (*job slot ID*).

Veamos cómo invocar `parallel` desde Nushell sobre `input.csv` usando `--colsep ','` y `--header :` para referenciar columnas por nombre o posición, y convertir la salida de nuevo en una tabla de Nushell:

```nu
cd /data/ch07
open input.csv
open --raw input.csv | parallel --colsep ',' --header : "echo {name}:{quantity}" | lines | where ($it | str contains ":") | split column ":" nombre cantidad | collect | save -f input_parallel.csv
open input_parallel.csv
```

### Controlando el Número de Trabajos Concurrentes (`--jobs`)

Por defecto, GNU `parallel` lanza tantos trabajos en paralelo como núcleos lógicos detecte en el sistema. Con la opción `--jobs` (o `-j`), podemos fijar un número exacto (por ejemplo `-j 4`), un porcentaje de núcleos (`-j 50%`) o sumar/restar hilos respecto al total (`-j +2`):

```nu
cd /data/ch07
1..4 | to text | parallel -j 4 "sh slow.sh {}" | lines
```

### Registro de Salidas y Etiquetado (`--results`, `--keep-order` y `--tag`)

Cuando ejecutamos múltiples experimentos en paralelo, los mensajes de salida pueden mezclarse en la terminal a medida que cada subproceso imprime líneas:

![Entrelazado de salidas cuando varios procesos escriben simultáneamente](Files/dscl_0803.png)

GNU `parallel` ofrece tres mecanismos para mantener el orden y la trazabilidad:

1. `--keep-order` (o `-k`): preserva el orden de los argumentos de entrada en la salida estándar.
2. `--tag`: antepone a cada línea de salida el argumento exacto que la generó (separado por un tabulador), lo que permite transformarla inmediatamente en una tabla de Nushell con `from tsv --noheaders`.
3. `--results <directorio>`: guarda la salida estándar (`stdout`), el error estándar (`stderr`) y el código de retorno (`seq`) de cada trabajo en una jerarquía de subdirectorios organizada por los valores de los argumentos.

Ejecutemos un ejemplo con `--tag` y `-k` en `/data/ch07` y guardemos la tabla resultante:

```nu
cd /data/ch07
1..5 | to text | parallel -k --tag "echo $(( {} * 10 ))" | from tsv --noheaders | rename arg resultado
1..5 | to text | parallel -k --tag "echo $(( {} * 10 ))" | from tsv --noheaders | rename arg resultado | save -f tagged_output.csv
```

También podemos combinar `parallel` con utilidades clásicas como `cowsay` (incluida en el `PATH` de `dsin`):

```nu
cd /data/ch07
["Nushell", "Polars"] | str join "\n" | parallel -k "cowsay {}"
```

### Creando Herramientas Paralelas y Procesamiento por Bloques (`--pipe`)

Cuando tenemos un archivo de texto de varios gigabytes y queremos aplicarle un comando de línea a línea sin crear millones de procesos individuales, la bandera `--pipe` (junto con `--block 10M`) divide la entrada estándar en bloques y envía cada bloque a una instancia paralela del comando:

```nu
cd /data/ch07
open --raw movies.txt | parallel --pipe -N 3 "wc -l" | lines | each {|x| $x | str trim | into int } | math sum
```

## Procesamiento Distribuido en Múltiples Nodos

Cuando una sola máquina no basta, tanto Nushell como GNU `parallel` permiten distribuir cargas de trabajo a través de una red de servidores accesibles mediante SSH.

### Obteniendo una Lista de Servidores Activos

Podemos definir nuestra lista de nodos en un archivo `hosts.txt` o en una tabla de Nushell y verificar su disponibilidad antes de lanzar el cálculo.

### Ejecutando un Comando en Todos los Nodos (`--nonall`)

Con `parallel --nonall --slf hosts.txt`, GNU `parallel` se conecta por SSH a cada servidor listado en `hosts.txt` y ejecuta el mismo comando de diagnóstico o aprovisionamiento (por ejemplo, `uptime` o `nu --version`):

```bash
# skip-docker-exec
parallel --nonall --slf hosts.txt "nu --version"
```

### Distribuyendo Datos Locales entre Nodos (`--pipe --slf`)

Si combinamos `--pipe` con `--slf hosts.txt`, GNU `parallel` trocea un flujo de datos local y envía cada fragmento por SSH a los distintos nodos del clúster para su procesamiento simultáneo:

```bash
# skip-docker-exec
cat gran_dataset.csv | parallel --pipe --header : --block 50M --slf hosts.txt "nu -c \"from csv | where amount > 100 | to csv\"" > filtrado_distribuido.csv
```

### Procesando Archivos en Nodos Remotos (`--transferfile` y `--return`)

Finalmente, cuando cada nodo debe procesar archivos locales distintos y devolver los archivos de resultados al nodo maestro, empleamos `--transferfile {}` y `--return {.}.out`:

```bash
# skip-docker-exec
ls *.csv | parallel --slf hosts.txt --transferfile {} --return {.}_clean.csv "nu limpiar_lote.nu {} {.}_clean.csv"
```

## Resumen

En este capítulo aprendimos a transformar flujos de trabajo secuenciales (`each`) en tuberías paralelas de alto rendimiento utilizando tanto `par-each` de forma nativa en Nushell como GNU `parallel` para orquestar procesos externos, bloques de flujo (`--pipe`) y ejecución distribuida por SSH.

En el Capítulo 8 culminaremos nuestro recorrido por el modelo OSEMN aplicando estas herramientas a la etapa de **Modelado Estadístico y Machine Learning**: reducción de dimensionalidad (PCA y t-SNE), agrupamiento o *clustering* (K-Means), regresión lineal/regularizada y clasificación supervisada.'
}

def get_ch8_content [] {
    r#'
# Modelado de Datos {#chapter-8-modeling-data}

El quinto y último paso del modelo OSEMN consiste en **modelar los datos** (*Model Data*). Mientras que el análisis exploratorio y la visualización (Capítulo 6) nos permiten describir estructuras e identificar patrones históricos, el modelado estadístico y el aprendizaje automático (*Machine Learning*) nos proporcionan herramientas formales para **sintetizar dimensiones latentes, descubrir grupos naturales, predecir variables continuas y clasificar nuevas observaciones**.

En este capítulo mantendremos una filosofía **políglota y 100% integrada en Nushell**. Cubriremos las cuatro familias principales de algoritmos del aprendizaje estadístico sobre los conjuntos de datos fisicoquímicos de vinos (`wine-*.csv`), biométricos de peces (`Fish.csv`) y banca minorista (`banco.csv`), ubicados en `/data/ch08`:

1. **Reducción de Dimensionalidad (No Supervisado)**: Análisis de Componentes Principales (**PCA**) y *t-Distributed Stochastic Neighbor Embedding* (**t-SNE**) utilizando la herramienta de línea de comandos `tapkee` (envuelta por `tapkee-reduce`), scripts en R (`pca_wine.R`, `vif_pcr_fish.R`) y en Python (`pca_wine.py`, `vif_pcr_fish.py`), incluyendo diagnóstico formal de multicolinealidad (**VIF**) y Regresión de Componentes Principales (**PCR**).
2. **Agrupamiento o *Clustering* (No Supervisado)**: algoritmo **K-Means** (`kmeans-cluster`, `cluster_wine.R`, `cluster_wine.py`), **Clustering Jerárquico Aglomerativo** (`hclust_fish.R`, `hclust_fish.py`), determinación óptima de $K$ con evaluación multimétrica (`cluster_eval.py`), **Clustering Basado en Densidad con DBSCAN** (`dbscan_fish.py`) y **K-Medoides con PAM** (`pam_fish.R`).
3. **Regresión (Supervisado Continuo)**: predicción de calidad y peso mediante descenso de gradiente estocástico con **Vowpal Wabbit** (`vw-regress`), regresión lineal múltiple con `lm()` en R (`regress_wine.R`), regresión Ridge en Python (`regress_wine.py`) y regresión PCR.
4. **Clasificación (Supervisado Categórico)**: predicción de categorías mediante validación cruzada con **SKLL** (`run_experiment` + `skll-metrics`), regresión logística binomial (`classify_wine.R`), bosques aleatorios (*Random Forest*, `classify_wine.py`), **Árboles de Decisión** (`dt_banco.R`, `dt_banco.py`), **$k$-NN** (`knn_banco.R`, `knn_banco.py`), **Naïve Bayes y SVM** (`nb_svm_banco.py`) y **Redes Neuronales Artificiales MLP** (`mlp_banco.py`, `mlp_banco.R`).

En **todos** los métodos seguiremos el mismo estándar riguroso:

- Nos ubicamos primero en el directorio del capítulo (`cd /data/ch08`) y abrimos los archivos por su nombre local.
- Ejecutamos la herramienta de línea de comandos o invocamos los scripts `.R` / `.py` independientes (nunca código en línea difícil de depurar).
- Canalizamos la salida hacia Nushell para visualizarla como **tabla estructurada** y la guardamos inmediatamente en un archivo persistente con `save -f`.

## Preparación y Exploración del Conjunto de Datos de Vinos

Inspeccionemos primero los archivos preinstalados en `/data/ch08`:

```nushell
cd /data/ch08
ls | select name type size
```

Los archivos `wine-red.csv` (1.599 vinos tintos) y `wine-white.csv` (4.898 vinos blancos) contienen 11 variables fisicoquímicas continuas (`fixed_acidity`, `volatile_acidity`, `citric_acid`, `residual_sugar`, `chlorides`, `free_sulfur_dioxide`, `total_sulfur_dioxide`, `density`, `pH`, `sulphates`, `alcohol`) y la calificación sensorial `quality` (escala de 0 a 10).

Veamos cómo podemos construir el conjunto combinado `wine-both.csv` directamente en Nushell añadiendo la columna `type` (`red` o `white`) y guardándolo en disco:

```nushell
cd /data/ch08
let red = (open wine-red.csv | insert type "red")
let white = (open wine-white.csv | insert type "white")
let both = ($red | append $white)
$both | first 5
$both | save -f wine-both-generated.csv
```

Verifiquemos la distribución de clases (`red` vs `white`) y las estadísticas descriptivas por tipo de vino usando Polars:

```nushell
cd /data/ch08
open wine-both.csv | histogram type
open wine-both.csv | histogram type | save -f wine_type_distribution.csv
```

Y generemos una visualización exploratoria de las distribuciones de alcohol, acidez volátil y sulfatos entre vinos tintos y blancos ejecutando el script `plot_wine_eda.R` y visualizándola en la terminal con `timg`:

```nushell
cd /data/ch08
open --raw plot_wine_eda.R
Rscript plot_wine_eda.R
timg -g 80x25 wine_eda.png
```

## Reducción de Dimensionalidad (PCA y t-SNE)

Cuando trabajamos con un espacio de $p = 11$ variables fisicoquímicas correlacionadas, resulta imposible visualizar directamente la nube de puntos en dos dimensiones. Los algoritmos de reducción de dimensionalidad proyectan una matriz de datos $\mathbf{X} \in \mathbb{R}^{n \times p}$ hacia un subespacio de baja dimensión $\mathbf{Z} \in \mathbb{R}^{n \times d}$ (con $d = 2 \ll p$) preservando la mayor cantidad posible de estructura:

- **PCA (*Principal Component Analysis*)**: busca combinaciones lineales ortogonales de las variables originales que maximicen la varianza explicada:
  $$\mathbf{z}_k = \mathbf{X}\mathbf{w}_k \quad \text{sujeto a} \quad \|\mathbf{w}_k\|_2 = 1, \quad \mathbf{w}_k^\top \mathbf{w}_j = 0 \;\; (\forall j < k)$$
- **t-SNE (*t-Distributed Stochastic Neighbor Embedding*)**: técnica no lineal que convierte las distancias euclidianas entre pares de observaciones en probabilidades condicionales de vecindad y minimiza la divergencia de Kullback-Leibler respecto a una distribución $t$ de Student de un grado de libertad en el espacio bidimensional.

### Reducción de Dimensionalidad con Herramientas CLI (`tapkee-reduce`: PCA y t-SNE)

La imagen `dsin` incluye la herramienta C++ `tapkee` junto con el comando de Nushell `tapkee-reduce`, que estandariza automáticamente las columnas numéricas seleccionadas ($z = (x - \mu)/\sigma$), invoca `tapkee` y devuelve las coordenadas proyectadas `dim_1` y `dim_2` como tabla de Nushell.

Apliquemos primero **PCA** sobre una muestra de 200 vinos de `wine-both.csv`:

```nu
cd /data/ch08
let features = ["fixed_acidity" "volatile_acidity" "citric_acid" "residual_sugar" "chlorides" "free_sulfur_dioxide" "total_sulfur_dioxide" "density" "ph" "sulphates" "alcohol"]
open wine-both.csv | first 200 | tapkee-reduce --method pca --cols $features | select type quality dim_1 dim_2 | first 10
open wine-both.csv | first 200 | tapkee-reduce --method pca --cols $features | select type quality dim_1 dim_2 | save -f wine_pca_tapkee.csv
```

Del mismo modo, cambiando únicamente `--method pca` por `--method t-sne`, obtenemos la proyección no lineal **t-SNE** con `tapkee`:

```nu
cd /data/ch08
let features = ["fixed_acidity" "volatile_acidity" "citric_acid" "residual_sugar" "chlorides" "free_sulfur_dioxide" "total_sulfur_dioxide" "density" "ph" "sulphates" "alcohol"]
open wine-both.csv | first 150 | tapkee-reduce --method t-sne --cols $features | select type quality dim_1 dim_2 | first 10
open wine-both.csv | first 150 | tapkee-reduce --method t-sne --cols $features | select type quality dim_1 dim_2 | save -f wine_tsne_tapkee.csv
```

![Proyecciones bidimensionales obtenidas mediante reducción de dimensionalidad](Files/dscl_0902.png)

### Reducción de Dimensionalidad con `Rscript` (`pca_wine.R`)

Veamos el script `pca_wine.R` ubicado en `/data/ch08`, el cual utiliza la función nativa `prcomp(..., center = TRUE, scale. = TRUE)` de R para calcular todas las componentes principales y reportar la proporción de varianza explicada y acumulada de cada componente:

```nu
cd /data/ch08
open --raw pca_wine.R
Rscript pca_wine.R | from csv
Rscript pca_wine.R | from csv | save -f wine_pca_r.csv
```

Observa cómo las primeras 4 componentes principales resumen más del 64% de la varianza total de las 11 variables químicas originales.

### Reducción de Dimensionalidad con Python (`pca_wine.py`)

Revisemos y ejecutemos ahora el script `pca_wine.py`, que utiliza `StandardScaler` y `PCA` de `scikit-learn`:

```nu
cd /data/ch08
open --raw pca_wine.py
python3 pca_wine.py | from csv
python3 pca_wine.py | from csv | save -f wine_pca_py.csv
```

### Diagnóstico de Multicolinealidad (VIF) y Regresión de Componentes Principales (PCR)

En problemas de regresión con múltiples variables predictoras altamente correlacionadas, la estimación por mínimos cuadrados ordinarios (**MCO**) sufre de **multicolinealidad severa**. Esto infla drásticamente la varianza de los coeficientes estimados y torna inestables las predicciones. Una métrica estadística estándar para diagnosticar este fenómeno es el **Factor de Inflación de la Varianza** (**VIF**, *Variance Inflation Factor*):

$$\text{VIF}_j = \frac{1}{1 - R_j^2}$$

donde $R_j^2$ es el coeficiente de determinación obtenido al regresar la variable predictora $X_j$ sobre todas las demás variables predictoras. Un valor de $\text{VIF} > 10$ (y con mayor razón $\text{VIF} > 100$) señala multicolinealidad crítica.

En `/data/ch08`, el archivo `Fish.csv` contiene variables biométricas de peces (`Length1`, `Length2`, `Length3`, `Height`, `Width`) utilizadas para predecir el peso (`Weight`). Al existir tres medidas longitudinales contiguas, la multicolinealidad es extrema.

El método de **Regresión de Componentes Principales** (**PCR**, *Principal Component Regression*) resuelve este problema proyectando las variables explicativas originales sobre sus componentes principales ortogonales (que tienen covarianza exactamente cero) antes de ajustar la regresión lineal.

Ejecutemos el script `vif_pcr_fish.py` para calcular los valores de VIF y comparar el modelo de regresión múltiple tradicional frente al modelo PCR con 2 componentes principales:

```nu
cd /data/ch08
open --raw vif_pcr_fish.py
python3 vif_pcr_fish.py | from csv
python3 vif_pcr_fish.py | from csv | save -f fish_pcr_py.csv
open fish_vif_py.csv
```

Observemos cómo en Python las variables de longitud presentan valores de VIF superiores a 1.000, mientras que el modelo PCR con solo 2 componentes principales retiene más del 99% de la varianza explicada y logra un $R^2$ casi idéntico al modelo MCO completo sin riesgo de colinealidad.

Ejecutemos también la versión equivalente en R (`vif_pcr_fish.R`):

```nu
cd /data/ch08
open --raw vif_pcr_fish.R
Rscript vif_pcr_fish.R | from csv
Rscript vif_pcr_fish.R | from csv | save -f fish_pcr_r.csv
```

## Agrupamiento o Clustering

El **agrupamiento (*clustering*)** es una tarea de aprendizaje no supervisado cuyo objetivo es particionar un conjunto de $n$ observaciones en $K$ grupos o clústeres disjuntos $C_1, C_2, \dots, C_K$ de modo que las observaciones dentro de un mismo clúster sean lo más similares posible entre sí, y lo más distintas posible a las de otros clústeres.

El algoritmo **K-Means** busca encontrar los centroides $\boldsymbol{\mu}_1, \dots, \boldsymbol{\mu}_K \in \mathbb{R}^p$ que minimizan la suma de cuadrados dentro de los clústeres (*Within-Cluster Sum of Squares*, WCSS):

$$\underset{C_1, \dots, C_K}{\arg\min} \sum_{k=1}^{K} \sum_{\mathbf{x}_i \in C_k} \|\mathbf{x}_i - \boldsymbol{\mu}_k\|_2^2$$

Un requisito estadístico indispensable antes de aplicar K-Means sobre variables con distintas unidades físicas (como `total_sulfur_dioxide` en mg/L frente a `density` en g/cm$^3$) es **estandarizar las variables** a media cero y desviación estándar unitaria, para evitar que la variable de mayor escala numérica domine la distancia euclidiana.

### Clustering K-Means con Herramientas CLI (`kmeans-cluster`)

En el módulo `dsin_tools.nu` de la imagen `dsin` disponemos del comando `kmeans-cluster`, que estandariza las columnas numéricas indicadas, ejecuta K-Means con $K$ clústeres e inserta la columna `cluster` en la tabla de Nushell.

Apliquemos `kmeans-cluster --k 2` sobre las 11 variables químicas de `wine-both.csv` (sin revelar la columna `type` al algoritmo) y comparemos los clústeres descubiertos contra el tipo real de vino (`red` vs `white`):

```nu
cd /data/ch08
let features = ["fixed_acidity" "volatile_acidity" "citric_acid" "residual_sugar" "chlorides" "free_sulfur_dioxide" "total_sulfur_dioxide" "density" "ph" "sulphates" "alcohol"]
let clustered = (open wine-both.csv | kmeans-cluster --k 2 --cols $features)
$clustered | select type quality alcohol volatile_acidity cluster | first 10
$clustered | select type quality alcohol volatile_acidity cluster | save -f wine_kmeans_cli.csv
```

Podemos evaluar en Nushell la correspondencia entre los 2 clústeres no supervisados y la clase real `type` agrupando por `cluster` y `type`:

```nu
cd /data/ch08
let features = ["fixed_acidity" "volatile_acidity" "citric_acid" "residual_sugar" "chlorides" "free_sulfur_dioxide" "total_sulfur_dioxide" "density" "ph" "sulphates" "alcohol"]
open wine-both.csv | kmeans-cluster --k 2 --cols $features | polars into-df | polars group-by cluster type | polars agg [(polars col quality | polars count | polars as n_vinos) (polars col alcohol | polars mean | polars as mean_alcohol)] | polars collect | polars into-nu | sort-by cluster type
open wine-both.csv | kmeans-cluster --k 2 --cols $features | polars into-df | polars group-by cluster type | polars agg [(polars col quality | polars count | polars as n_vinos) (polars col alcohol | polars mean | polars as mean_alcohol)] | polars collect | polars into-nu | sort-by cluster type | save -f wine_kmeans_contingency.csv
```

¡Incluso sin etiquetas supervisadas, K-Means en el espacio químico estandarizado separa con altísima pureza los vinos tintos de los vinos blancos!

### Clustering K-Means con `Rscript` (`cluster_wine.R`)

Veamos el script `cluster_wine.R` en `/data/ch08`, que ejecuta `kmeans(..., centers = 3, nstart = 20)` en R y resume el tamaño y el perfil químico promedio de cada clúster:

```nushell
cd /data/ch08
open --raw cluster_wine.R
Rscript cluster_wine.R | from csv
Rscript cluster_wine.R | from csv | save -f wine_clusters_r.csv
```

### Clustering K-Means con Python (`cluster_wine.py`)

Revisemos y ejecutemos ahora el script `cluster_wine.py` con `scikit-learn` (`KMeans(n_clusters=3, random_state=42, n_init=10)`):

```nushell
cd /data/ch08
open --raw cluster_wine.py
python3 cluster_wine.py | from csv
python3 cluster_wine.py | from csv | save -f wine_clusters_py.csv
```

### Clustering Jerárquico Aglomerativo (hclust_fish.R y hclust_fish.py)

A diferencia de K-Means, que requiere especificar *a priori* el número de conglomerados $K$ y converge a particiones rígidas, el **clustering jerárquico** (*Hierarchical Clustering*) construye una jerarquía anidada de agrupamientos mediante una matriz de distancias disimilares $\mathbf{D} \in \mathbb{R}^{n \times n}$.

El enfoque **aglomerativo** (*bottom-up*) inicia con cada observación individual como un clúster unitario y, en cada paso, fusiona el par de clústeres más cercanos de acuerdo a un criterio de enlace (*linkage criterion*). Entre los criterios más robustos en minería de datos destaca el método de **Ward (`ward.D2`)**, que une en cada iteración el par de clústeres que minimiza el incremento en la varianza total dentro de los grupos.

En `/data/ch08`, disponemos del conjunto `Fish.csv` (159 observaciones de especies de peces comerciales con medidas biométricas: peso, 3 longitudes, altura y ancho). Ejecutemos el script `hclust_fish.R`, que escala las medidas, calcula la matriz de distancias euclidianas, aplica `hclust(d, method = "ward.D2")`, corta el árbol en $K = 3$ grupos mediante `cutree(hc, k = 3)` y resume la correspondencia con las especies dominantes:

```nu
cd /data/ch08
open --raw hclust_fish.R
Rscript hclust_fish.R | from csv
Rscript hclust_fish.R | from csv | save -f fish_hclust_r.csv
```

De igual modo, el script `hclust_fish.py` evalúa el clustering jerárquico aglomerativo con `scikit-learn` (`AgglomerativeClustering(linkage="ward")`) para distintos números de clústeres ($K = 2, 3, 4, 5$) calculando el coeficiente de silueta (*Silhouette Score*):

```nu
cd /data/ch08
open --raw hclust_fish.py
python3 hclust_fish.py | from csv
python3 hclust_fish.py | from csv | save -f fish_hclust_py.csv
```

### Determinación Óptima de K con Evaluación Multimétrica (cluster_eval.py)

Uno de los desafíos centrales en minería de datos consiste en seleccionar el número óptimo de clústeres $K$. En lugar de confiar únicamente en una inspección visual subjetiva del método del codo (*Elbow Method*), la práctica rigurosa evalúa simultáneamente múltiples métricas de validación interna:

1. **Inercia (WCSS)**: Suma de distancias al cuadrado al centroide más cercano (monótonamente decreciente con $K$).
2. **Coeficiente de Silueta (*Silhouette*)**: Mide cuán similar es un punto a su propio clúster en comparación con el clúster vecino más cercano (rango $[-1, 1]$, valores cercanos a 1 indican conglomerados densos y bien separados).
3. **Índice Calinski-Harabasz**: Razón entre la dispersión entre clústeres y la dispersión intra-clúster (valores mayores indican mejor separación).
4. **Índice Davies-Bouldin**: Promedio de similitud máxima de cada clúster con su clúster más semejante (valores menores indican mejor partición).

El script `cluster_eval.py` evalúa automáticamente estos 4 criterios sobre el conjunto bancario `banco.csv` (segmentación de clientes en variables estandarizadas de edad, ingreso, gasto en tarjeta e hipoteca) para $K \in [2, 6]$:

```nu
cd /data/ch08
open --raw cluster_eval.py
python3 cluster_eval.py | from csv
python3 cluster_eval.py | from csv | save -f banco_cluster_eval.csv
```

Podemos ordenar en Nushell la tabla por coeficiente de silueta descendente para identificar inmediatamente la partición más compacta:

```nu
cd /data/ch08
open banco_cluster_eval.csv | sort-by silhouette -r
```

### Clustering Basado en Densidad con DBSCAN y K-Medoides con PAM

Los algoritmos particionales como K-Means asumen que los conglomerados son esféricos, convexos y de tamaño similar. Cuando los datos presentan geometrías complejas o contienen observaciones atípicas extremas (*outliers*), se requieren paradigmas alternativos de agrupamiento:

1. **DBSCAN (*Density-Based Spatial Clustering of Applications with Noise*)**: Define los clústeres como regiones densas de puntos separadas por regiones de baja densidad. Posee dos parámetros fundamentales: el radio de vecindad $\varepsilon$ (`eps`) y el número mínimo de puntos `min_samples` requeridos para formar un núcleo denso. Aquellos puntos que no pertenecen a ninguna vecindad densa son catalogados automáticamente como **ruido o anomalías** (etiqueta `-1`), sin forzarlos artificialmente dentro de ningún clúster.
2. **K-Medoides con PAM (*Partitioning Around Medoids*)**: A diferencia de K-Means (que utiliza la media aritmética como centroide, haciéndolo vulnerable a valores atípicos), PAM restringe los centros a **observaciones reales del conjunto de datos** (*medoides*), ofreciendo una partición mucho más robusta ante distribuciones asimétricas y contaminación por valores extremos.

Ejecutemos el script `dbscan_fish.py` sobre las medidas biométricas estandarizadas de `Fish.csv` (`Weight`, `Length1`, `Length2`, `Length3`, `Height`, `Width`):

```nu
cd /data/ch08
open --raw dbscan_fish.py
python3 dbscan_fish.py | from csv
python3 dbscan_fish.py | from csv | save -f fish_dbscan_py.csv
```

Observemos cómo DBSCAN aísla automáticamente los ejemplares gigantescos como grupo `-1` (`Ruido / Outliers`) con un peso promedio superior a 1.400 gramos, evitando que distorsionen los clústeres homogéneos de peces medianos y pequeños.

Por su parte, el script `pam_fish.R` ejecuta el algoritmo PAM de la librería `cluster` en R para obtener los medoides representativos y la silueta promedio:

```nu
cd /data/ch08
open --raw pam_fish.R
Rscript pam_fish.R | from csv
Rscript pam_fish.R | from csv | save -f fish_pam_r.csv
```

## Regresión: Predicción de la Calidad del Vino

En el problema de **regresión supervisada**, deseamos aprender una función $f(\mathbf{x}) \approx y$ que prediga una variable respuesta cuantitativa ($y = \text{quality}$) a partir del vector de predictores fisicoquímicos $\mathbf{x} \in \mathbb{R}^{11}$.

Para evaluar rigurosamente la capacidad de generalización del modelo sobre datos no vistos, dividimos el conjunto de vinos blancos (`wine-white.csv`) en un conjunto de entrenamiento (`wine_train.csv`, primeros 3.500 registros) y un conjunto de prueba (`wine_test.csv`, registros restantes) utilizando las métricas:

- **Error Absoluto Medio (MAE)**: $\text{MAE} = \frac{1}{n}\sum_{i=1}^n |y_i - \hat{y}_i|$
- **Raíz del Error Cuadrático Medio (RMSE)**: $\text{RMSE} = \sqrt{\frac{1}{n}\sum_{i=1}^n (y_i - \hat{y}_i)^2}$

### Regresión en Línea con Vowpal Wabbit (`vw-regress`)

**Vowpal Wabbit (`vw`)** es un motor ultrarrápido de aprendizaje en línea por descenso de gradiente estocástico capaz de entrenar modelos sobre millones de registros sin cargar el dataset completo en RAM. El comando `vw-regress` incluido en `dsin_tools.nu` convierte automáticamente tablas de Nushell al formato nativo de Vowpal Wabbit (`target |features feat1:val1 feat2:val2 ...`), entrena el modelo y devuelve una tabla con `actual`, `predicted`, `error` y `abs_error`:

```nushell
cd /data/ch08
let data = (open wine-white.csv)
let train = ($data | first 3500)
let test = ($data | skip 3500)
let preds = (vw-regress $train $test --target quality --passes 15)
$preds | first 10
$preds | save -f wine_vw_predictions.csv
```

Calculemos el MAE y el error medio directamente en Nushell a partir de las predicciones de `vw-regress` y guardémoslos en un archivo resumen:

```nushell
cd /data/ch08
let preds = (open wine_vw_predictions.csv)
let metrics = {model: "Vowpal Wabbit (SGD)", n_test: ($preds | length), mae: ($preds.abs_error | math avg | math round --precision 4), bias: ($preds.error | math avg | math round --precision 4)}
$metrics
[$metrics] | save -f wine_vw_metrics.csv
```

### Regresión Lineal Múltiple con `Rscript` (`regress_wine.R`)

Veamos el script `regress_wine.R`, que ajusta un modelo lineal clásico por mínimos cuadrados ordinarios (`lm(quality ~ ., data = train)`) sobre los primeros 3.500 registros, evalúa el RMSE y MAE en el conjunto de prueba y devuelve los coeficientes estimados ($\hat{\beta}_j$, error estándar, estadístico $t$ y valor $p$):

```nushell
cd /data/ch08
open --raw regress_wine.R
Rscript regress_wine.R | from csv
Rscript regress_wine.R | from csv | save -f wine_regression_r.csv
```

Podemos filtrar en Nushell únicamente los predictores estadísticamente significativos al nivel $\alpha = 0.01$:

```nushell
cd /data/ch08
open wine_regression_r.csv | where p_value < 0.01 | sort-by t_stat -r
open wine_regression_r.csv | where p_value < 0.01 | sort-by t_stat -r | save -f wine_significant_predictors.csv
```

### Regresión Regularizada (Ridge) con Python (`regress_wine.py`)

Ejecutemos ahora el script `regress_wine.py`, que estandariza los predictores y ajusta una regresión Ridge ($\ell_2$) con `scikit-learn`:

```nushell
cd /data/ch08
open --raw regress_wine.py
python3 regress_wine.py | from csv
python3 regress_wine.py | from csv | save -f wine_regression_py.csv
```

## Clasificación Supervisada

Finalmente, abordemos el problema de **clasificación supervisada**: predecir una etiqueta categórica discreta (por ejemplo, si un vino es tinto o blanco en `wine-both.csv`, o si un cliente bancario aceptará un préstamo en `banco.csv`) a partir de sus atributos.

### Experimentos de Clasificación con SKLL (`run_experiment` + `skll-metrics`)

La imagen `dsin` incluye **SKLL (*SciKit-Learn Laboratory*)**, que permite definir experimentos declarativos de evaluación y validación cruzada mediante archivos de configuración `.cfg` (como `classify.cfg` en `/data/ch08`, que evalúa clasificadores sobre `train/features.csv` y `test/features.csv`).

Inspeccionemos `classify.cfg` y ejecutemos `run_experiment` junto con el comando `skll-metrics` para obtener la tabla comparativa de exactitud (*accuracy*) y guardarla en `wine_skll_summary.csv`:

```nu
cd /data/ch08
open --raw classify.cfg
run_experiment -l classify.cfg
skll-metrics output/wine_summary.tsv
skll-metrics output/wine_summary.tsv | save -f wine_skll_summary.csv
```

### Clasificación con Regresión Logística en `Rscript` (`classify_wine.R`)

Veamos y ejecutemos el script `classify_wine.R` en `/data/ch08`, que entrena un modelo lineal generalizado binomial (`glm(is_red ~ ., family = binomial())`) sobre una muestra estratificada de entrenamiento y evalúa su exactitud, sensibilidad y especificidad sobre el conjunto de prueba:

```nushell
cd /data/ch08
open --raw classify_wine.R
Rscript classify_wine.R | from csv
Rscript classify_wine.R | from csv | save -f wine_classification_r.csv
```

### Clasificación con Random Forest en Python (`classify_wine.py`)

Revisemos y ejecutemos `classify_wine.py`, que entrena un clasificador de Bosques Aleatorios (*Random Forest*) con 100 árboles en `scikit-learn` y devuelve la tabla de importancia de variables (*feature importances*) junto con la exactitud en prueba (`test_accuracy`):

```nushell
cd /data/ch08
open --raw classify_wine.py
python3 classify_wine.py | from csv
python3 classify_wine.py | from csv | save -f wine_classification_py.csv
```

Observa cómo `total_sulfur_dioxide`, `chlorides` y `volatile_acidity` emergen consistentemente como las variables más discriminantes para distinguir entre vinos tintos y blancos.

### Árboles de Decisión con R y Python (dt_banco.R y dt_banco.py)

Los **árboles de decisión** (*Decision Trees*) representan una familia fundamental de modelos supervisados no paramétricos ampliamente utilizados en minería de datos por su alta interpretabilidad y capacidad para modelar relaciones no lineales sin requerir escalado previo de atributos.

Evaluemos la predicción de aceptación de préstamos sobre `banco.csv` (5.000 clientes) utilizando `rpart` en R (`dt_banco.R` con profundidad máxima de 4 niveles):

```nu
cd /data/ch08
open --raw dt_banco.R
Rscript dt_banco.R | from csv
Rscript dt_banco.R | from csv | save -f banco_dt_r.csv
```

Ejecutemos ahora el clasificador equivalente en Python con `DecisionTreeClassifier` de `scikit-learn` (`dt_banco.py`):

```nu
cd /data/ch08
open --raw dt_banco.py
python3 dt_banco.py | from csv
python3 dt_banco.py | from csv | save -f banco_dt_py.csv
```

### Clasificación con Vecinos Más Cercanos k-NN (knn_banco.R y knn_banco.py)

El clasificador **$k$-Vecinos Más Cercanos ($k$-NN, *k-Nearest Neighbors*)** es un método de aprendizaje basado en instancias que clasifica una nueva observación asignándole la clase mayoritaria entre sus $k$ vecinos más próximos en el espacio de características estandarizado.

Ejecutemos `knn_banco.R` para evaluar el clasificador en R (`class::knn`) sobre `banco.csv` con $k \in \{3, 5, 7\}$:

```nu
cd /data/ch08
open --raw knn_banco.R
Rscript knn_banco.R | from csv
Rscript knn_banco.R | from csv | save -f banco_knn_r.csv
```

Y ejecutemos la contraparte en Python utilizando `KNeighborsClassifier` (`knn_banco.py`):

```nu
cd /data/ch08
open --raw knn_banco.py
python3 knn_banco.py | from csv
python3 knn_banco.py | from csv | save -f banco_knn_py.csv
```

### Clasificación Alternativa: Naïve Bayes y Máquinas de Vectores de Soporte (nb_svm_banco.py)

Como complemento a los árboles y vecinos cercanos, la minería de datos contemporánea emplea con frecuencia dos paradigmas adicionales:

1. **Clasificador Bayesiano Ingenuo Gaussiano (*Gaussian Naïve Bayes*)**: Aplica el teorema de Bayes asumiendo independencia condicional entre los predictores dada la clase, modelando cada atributo continuo mediante una distribución normal.
2. **Máquinas de Vectores de Soporte (SVM, *Support Vector Machines*)**: Encuentran el hiperplano óptimo que maximiza el margen de separación entre clases en un espacio inducido por un núcleo de base radial (RBF).

Ejecutemos `nb_svm_banco.py` para comparar el desempeño de ambos clasificadores sobre `banco.csv`:

```nu
cd /data/ch08
open --raw nb_svm_banco.py
python3 nb_svm_banco.py | from csv
python3 nb_svm_banco.py | from csv | save -f banco_nb_svm_py.csv
```

La tabla comparativa resultante permite a Nushell ordenar los modelos según su métrica $F_1$-score:

```nu
cd /data/ch08
open banco_nb_svm_py.csv | sort-by f1_score -r
```

### Redes Neuronales Artificiales: Perceptrón Multicapa (MLP)

Las **Redes Neuronales Artificiales** (*Artificial Neural Networks*, ANN) representan una de las familias más poderosas del aprendizaje automático contemporáneo. El **Perceptrón Multicapa** (**MLP**, *Multi-Layer Perceptron*) está compuesto por una capa de entrada, una o más capas ocultas con funciones de activación no lineales (como $\text{ReLU}(z) = \max(0, z)$ o la función logística sigmoide $\sigma(z) = \frac{1}{1 + e^{-z}}$), y una capa de salida:

$$\mathbf{h}^{(1)} = \sigma\left(\mathbf{W}^{(1)} \mathbf{x} + \mathbf{b}^{(1)}\right), \quad \hat{y} = \sigma\left(\mathbf{W}^{(2)} \mathbf{h}^{(1)} + \mathbf{b}^{(2)}\right)$$

El aprendizaje se realiza mediante el algoritmo de **retropropagación del error** (*backpropagation*), calculando las derivadas parciales de la función de pérdida respecto a cada peso mediante la regla de la cadena y actualizándolos con optimizadores de gradiente como **Adam** o SGD, junto con regularización L2 ($\alpha$) para mitigar el sobreajuste.

Un principio fundamental en el entrenamiento de redes neuronales es su **extrema sensibilidad al escalado de los atributos**. Si las variables no están estandarizadas a media cero y varianza unitaria, el gradiente oscila violentamente o se desvanece en las dimensiones de gran escala, impidiendo la convergencia.

Ejecutemos el script `mlp_banco.py` sobre `banco.csv` para entrenar y evaluar dos arquitecturas de MLP (una capa con 8 neuronas y dos capas con $(16, 8)$ neuronas):

```nu
cd /data/ch08
open --raw mlp_banco.py
python3 mlp_banco.py | from csv
python3 mlp_banco.py | from csv | save -f banco_mlp_py.csv
```

La red con arquitectura profunda $(16, 8)$ alcanza un $F_1$-score cercano a $0.95$ tras unas 400 iteraciones, superando el margen de los clasificadores lineales tradicionales.

De forma complementaria, el script `mlp_banco.R` entrena una red neuronal con la librería `nnet` en R:

```nu
cd /data/ch08
open --raw mlp_banco.R
Rscript mlp_banco.R | from csv
Rscript mlp_banco.R | from csv | save -f banco_mlp_r.csv
```

## Resumen del Capítulo y Conclusión del Curso

En este capítulo completamos el ciclo OSEMN aplicando técnicas de modelado no supervisado y supervisado desde la línea de comandos:

1. **Reducción de dimensionalidad (PCA y t-SNE) y diagnóstico de multicolinealidad** con `tapkee-reduce`, `pca_wine.R`, `pca_wine.py`, `vif_pcr_fish.py` y `vif_pcr_fish.R`.
2. **Agrupamiento (K-Means, Jerárquico, DBSCAN y PAM)** con `kmeans-cluster`, `cluster_wine.R`, `cluster_wine.py`, `hclust_fish.R`, `hclust_fish.py`, `cluster_eval.py`, `dbscan_fish.py` y `pam_fish.R`.
3. **Regresión supervisada** con Vowpal Wabbit (`vw-regress`), `regress_wine.R`, `regress_wine.py` y Regresión de Componentes Principales (PCR).
4. **Clasificación supervisada** con SKLL (`run_experiment` + `skll-metrics`), `classify_wine.R`, `classify_wine.py`, árboles de decisión (`dt_banco.R` y `dt_banco.py`), $k$-NN (`knn_banco.R` y `knn_banco.py`), Naïve Bayes y SVM (`nb_svm_banco.py`), y Redes Neuronales Artificiales MLP (`mlp_banco.py` y `mlp_banco.R`).

A lo largo de los ocho capítulos de **Ciencia de Datos en la Línea de Comandos con Nushell**, hemos comprobado que una shell moderna basada en tablas tipadas, combinada con DataFrames perezosos en Polars, paralelismo nativo (`par-each` y GNU `parallel`), edición y visualización en terminal (`ttt` y `timg`) e interoperabilidad fluida con R y Python dentro del contenedor `dsin`, constituye un entorno científico reproducible, expresivo y de alto rendimiento para la Ciencia de Datos.'#
}

def get_references_content [] {
    r#'
# Referencias {#references}

## Ecosistema Nushell

- **Sitio web oficial de Nushell**: <https://www.nushell.sh>
- **The Nu Book (Documentación oficial)**: <https://www.nushell.sh/book/>
- **Referencia de Comandos de Nushell**: <https://www.nushell.sh/commands/>
- **Repositorio de Nushell en GitHub**: <https://github.com/nushell/nushell>
- **Repositorio del plugin Apache Arrow / Polars**: <https://github.com/nushell/nushell/tree/main/crates/nu_plugin_polars>
- **Plugins oficiales de formatos y consultas**: <https://github.com/nushell/nushell/tree/main/crates/nu_plugin_formats>, `nu_plugin_query`, `nu_plugin_gstat`, `nu_plugin_inc`
- **Comunidad y Discord de Nushell**: <https://discord.gg/NtAbbGn>

## Data Science at the Command Line (DSitCL)

- **Libro oficial en línea (Segunda edición)**: Janssens, Jeroen (2021). *Data Science at the Command Line: Facing the Future with Time-Tested Tools* (2nd ed.). O'Reilly Media. <https://datascienceatthecommandline.com/2e/>
- **Repositorio GitHub del libro original**: <https://github.com/jeroenjanssens/data-science-at-the-command-line>
- **Data Science Toolbox (Contenedores Docker base)**: <https://github.com/jeroenjanssens/datasciencetoolbox>
- **Repositorio de imágenes en Docker Hub**: `datasciencetoolbox` en <https://hub.docker.com/u/datasciencetoolbox>

## Herramientas de Línea de Comandos Integradas en `dsin`

- **ttt (Terminal Text Tree / Text Editor)**: Liam Galvin. Editor ligero de consola con soporte para mouse y resaltado de sintaxis. <https://github.com/liamg/ttt>
- **timg (Terminal Image and Video Viewer)**: Henner Zeller. Visor gráfico en alta resolución para terminales con soporte Sixel, Kitty y bloques Unicode. <https://github.com/hzeller/timg>
- **GNU Parallel**: Tange, Ole (2018). *GNU Parallel 2018*. Ole Tange. <https://www.gnu.org/software/parallel/>
- **Tapkee**: Lisitsyn, S., Widmer, C., & Rath, F. J. (2014). *Tapkee: An Efficient Dimension Reduction Library*. Journal of Machine Learning Research, 15(1), 3955-3959. <https://tapkee.lisitsyn.me/>
- **Vowpal Wabbit**: Langford, J., Li, L., & Strehl, A. (2007). *Vowpal Wabbit Online Learning Project*. Microsoft Research. <https://vowpalwabbit.org/>
- **SKLL (SciKit-Learn Laboratory)**: Educational Testing Service (ETS). Framework declarativo para experimentación con modelos de Scikit-Learn. <https://skll.readthedocs.io/>
- **Polars**: Ritchie Vink. Motor columnar de DataFrames multihilo de ultra-alto rendimiento en Rust. <https://pola.rs/>

## Bibliografía y Literatura Académica

- **Mason, H., & Wiggins, C. H. (2010)**. *A Taxonomy of Data Science*. Dataists. <http://www.dataists.com/2010/09/a-taxonomy-of-data-science>
- **Tukey, J. W. (1977)**. *Exploratory Data Analysis*. Reading, Mass.: Addison-Wesley Publishing Company.
- **Wickham, H., & Grolemund, G. (2017)**. *R for Data Science: Import, Tidy, Transform, Visualize, and Model Data*. O'Reilly Media.
- **Pedregosa, F., et al. (2011)**. *Scikit-learn: Machine Learning in Python*. Journal of Machine Learning Research, 12, 2825-2830.
- **Breiman, L. (2001)**. *Random Forests*. Machine Learning, 45(1), 5-32.
- **Hastie, T., Tibshirani, R., & Friedman, J. (2009)**. *The Elements of Statistical Learning: Data Mining, Inference, and Prediction* (2nd ed.). Springer New York.'#
}

def get_introduction_content [] {
    r#'
# Introducción {-}

## La Terminal como Laboratorio Científico

En la práctica contemporánea de la ciencia de datos, la escala, la heterogeneidad y el dinamismo de los flujos de información demandan herramientas que trasciendan la rigidez de las interfaces gráficas y la sobrecarga de los entornos integrados monolíticos. Durante más de cinco décadas, la consola de comandos de Unix se ha consolidado como el estándar por excelencia de la reproducibilidad científica, la automatización desatendida y la eficiencia computacional. Su filosofía fundacional postula que el software debe construirse a partir de programas compactos y modulares, capaces de resolver una tarea concreta con maestría técnica y de coordinarse fluidamente mediante canales estandarizados de comunicación.

No obstante, las shells tradicionales (entre las que destacan Bash y Zsh) fueron diseñadas en una época en que la información en tránsito se concebía exclusivamente como secuencias no estructuradas de caracteres. Bajo este esquema clásico, operar sobre estructuras tabulares complejas o registros anidados dentro de una terminal demanda intrincadas combinaciones de expresiones regulares y utilidades de corte léxico (como `sed`, `awk` y `cut`). Este enfoque resulta propenso a fallas sutiles provocadas por delimitadores imprevistos, induce ambigüedades en secuencias de escape y despoja a los datos de sus tipos semánticos originales.

## El Paradigma Nushell: Datos Estructurados en la Consola

Nushell (`nu`) rompe de raíz con esta limitación histórica mediante una arquitectura concebida expresamente para la era moderna del análisis de datos. En lugar de transmitir flujos de bytes planos y opacos, las tuberías de Nushell transportan tablas bidimensionales tipadas, registros jerárquicos de clave y valor, listas ordenadas y valores primitivos gobernados por esquemas estrictos.

Al reconocer de forma nativa tipos de datos como enteros, números en coma flotante, marcas temporales con zona horaria, rutas del sistema de archivos y tamaños de memoria, Nushell permite filtrar, ordenar, remodelar y agregar conjuntos de información mediante una sintaxis declarativa, expresiva y limpia. Más aún, su integración profunda con el motor columnar Polars (programado en Rust y edificado sobre el estándar en memoria Apache Arrow) dota a la consola de una potencia analítica masiva. Con ello, resulta viable ejecutar consultas analíticas multihilo sobre millones de registros en fracciones de segundo sin abandonar la comodidad del flujo interactivo en la terminal.

## Una Guía Práctica e Interactiva: El Sentido Pedagógico de Omitir Salidas

Este texto no fue concebido para una lectura pasiva, contemplativa o meramente teórica. Se trata de una guía práctica interactiva (un manual de experimentación computacional paso a paso) proyectada para ser estudiada con una terminal abierta junto al documento en todo momento.

Por esta razón metodológica consciente, la inmensa mayoría de los bloques de código presentados a lo largo de los capítulos no incluyen la salida textual producida por los comandos. Salvo en circunstancias donde se despliegan gráficos generados en la consola, imágenes renderizadas mediante utilidades gráficas o diagramas esquemáticos indispensables para ilustrar la arquitectura de los datos, las respuestas del sistema se han omitido de manera deliberada.

Esta decisión pedagógica responde a tres principios fundamentales del aprendizaje técnico profundo:

1. **Compromiso Activo frente a la Ilusión de Comprensión:** Observar una tabla de resultados previamente renderizada en la página crea la falsa sensación de dominio conceptual, inhibiendo el esfuerzo cognitivo del estudiante. Al escribir, adaptar y despachar cada instrucción en la consola, el lector experimenta en primera persona la dinámica del flujo de datos, desarrolla memoria procedimental y comprende de forma tangible la mecánica interna de las tuberías.
2. **Exploración en Tiempo Real y Descubrimiento Guiado:** Las capacidades distintivas de Nushell cobran sentido únicamente en la interacción viva con el intérprete. La exploración multidimensional con `explore`, la paginación interactiva de registros extensos, el autocompletado contextual y la inspección dinámica de esquemas exigen una presencia activa frente al teclado.
3. **Desarrollo de Resiliencia Diagnóstica:** El quehacer cotidiano en la ciencia de datos requiere familiaridad con las discrepancias estructurales, las advertencias de conversión y los mensajes de error. Omitir las respuestas predecibles entrena al estudiante en el hábito analítico de inspeccionar el estado intermedio de los pipelines mediante herramientas como `describe`, verificando tipos y dimensiones de manera autónoma.

Por lo tanto, convocamos al lector a asumir una postura de indagación constante. No reproduzca los ejemplos como recetas mecánicas: altere los parámetros, formule filtros alternativos, combine operadores inesperados e interrogue rigurosamente la salida que su propia terminal le devuelve.

## El Entorno Unificado dsin: Reproducibilidad sin Fricciones

Para garantizar que cada experiencia práctica se ejecute bajo condiciones idénticas y libres de divergencias de configuración, el libro se sustenta en un entorno unificado y reproducible denominado `dsin` (Data Science in Nushell), distribuido como una imagen pública de Docker en `ghcr.io/kurokirasama/dsin:latest`.

Este contenedor provee una estación de trabajo completa que encapsula:

- La versión más reciente de Nushell configurada con parámetros analíticos avanzados y personalizaciones ergonómicas para la consola.
- El ecosistema integral de plugins oficiales y comunitarios, con soporte de vanguardia para Polars (`nu_plugin_polars`), formatos estructurados (`nu_plugin_formats`), consultas avanzadas (`nu_plugin_query`), estados de repositorios Git (`nu_plugin_gstat`) y representación gráfica (`nu_plugin_plot`).
- Entornos consolidados y actualizados de Python y R, provistos de sus bibliotecas analíticas, científicas y estadísticas fundamentales.
- Herramientas analíticas de alto rendimiento para modelado predictivo en terminal, tales como Vowpal Wabbit (`vw`), Tapkee y el kit de aprendizaje supervisado SKLL.
- Utilidades modernas de visualización y edición en consola, entre las que sobresalen el editor de texto interactivo `ttt` y el visor gráfico de alta fidelidad `timg`.
- La totalidad de las bases de datos y conjuntos de datos utilizados en los ejercicios del texto, meticulosamente ordenados por capítulo en el directorio `/data`.

## Organización del Contenido y el Ciclo OSEMN

La progresión pedagógica de la obra se estructura con fidelidad en torno a las etapas del ciclo clásico OSEMN (Obtain, Scrub, Explore, Model, iNterpret), formulado originalmente por Hilary Mason y Chris Wiggins, complementado con las bases instrumentales necesarias para dominar la ingeniería de datos en la terminal:

- **Capítulo 1: Instalación del Entorno.** Despliegue de la infraestructura de virtualización, aprovisionamiento del contenedor `dsin` y configuración de la estación de trabajo.
- **Capítulo 2: Fundamentos de la Terminal y Nushell.** Navegación en el árbol de directorios, tipos estructurados, rutas de celda, edición interactiva en consola y control de versiones con Git.
- **Capítulo 3: Creación de Herramientas de Línea de Comandos.** Arquitectura de scripts en Nushell, diseño de funciones robustas con tipado estricto, tuberías personalizadas e integración con APIs externas mediante parámetros de geocodificación.
- **Capítulo 4: Obtención de Datos (Obtain).** Adquisición programática desde fuentes remotas en la web, consumo de servicios RESTful, extracción de archivos comprimidos, lectura de hojas de cálculo y consulta de bases de datos relacionales SQLite.
- **Capítulo 5: Depuración y Transformación (Scrub).** Normalización de texto, reestructuración tabular, expresiones regulares aplicadas a campos tipados y procesamiento columnar masivo con Polars.
- **Capítulo 6: Exploración y Visualización (Explore).** Estimación de descriptores estadísticos univariados y multivariados, gramática de gráficos mediante `ggplot2` y `matplotlib`, y renderizado gráfico directo en la celda de la terminal con `timg`.
- **Capítulo 7: Procesamiento Paralelo.** Concurrencia nativa en pipelines estructurados con `par-each`, gestión de flujos asíncronos y distribución masiva de tareas sobre procesadores multinúcleo mediante GNU Parallel.
- **Capítulo 8: Modelado Políglota de Datos (Model & Interpret).** Aplicación rigurosa de algoritmos de reducción dimensional (análisis de componentes principales PCA y t-SNE), métodos de agrupamiento (K-Means, jerárquico aglomerativo, DBSCAN y partición alrededor de medoides PAM), regresión lineal regularizada (OLS, Ridge, regresión por componentes principales PCR) y modelos de clasificación supervisada (árboles de decisión, k-NN, Naïve Bayes, máquinas de vectores de soporte SVM y redes neuronales feedforward MLP).

Que este recorrido práctico sirva como fundamento sólido para transformar la terminal en un entorno creativo, riguroso y de alto rendimiento al servicio de la ciencia de datos.'#
}

def format_for_pandoc [doc: string] {
    let cleaned_doc = (
        $doc
        | str replace -a "(Files/dscl_" "(dscl_"
        | str replace -a "```nushell" "```nu"
    )
    let all_lines = ($cleaned_doc | lines)
    # Find the second "---" which closes the YAML frontmatter
    mut dash_indices = []
    for item in ($all_lines | enumerate) {
        if ($item.item | str trim) == "---" {
            $dash_indices = ($dash_indices | append $item.index)
        }
    }
    let yaml_end = (if ($dash_indices | length) >= 2 { $dash_indices | get 1 } else { 0 })
    let front = ($all_lines | take ($yaml_end + 1))
    let body = ($all_lines | skip ($yaml_end + 1))

    # Strip any standalone --- horizontal rule lines in the body (outside code blocks)
    # and ensure a blank line precedes the start of every bullet/numbered list outside code blocks
    mut out_body = []
    mut in_code = false
    mut prev_line = ""
    mut in_list = false

    for line in $body {
        let trimmed = ($line | str trim)
        if ($trimmed | str starts-with "```") {
            $in_code = (not $in_code)
            $in_list = false
            $out_body = ($out_body | append $line)
            $prev_line = $line
            continue
        }

        if (not $in_code) and ($trimmed == "---") {
            # Skip standalone horizontal rules in body per add-preamble rule
            continue
        }

        if (not $in_code) {
            # Ensure a \newpage before each new level-1 section heading (# )
            let is_h1 = ($trimmed =~ '^[#] [^ ]')
            if $is_h1 and (($prev_line | str trim) != "\\newpage") {
                if (($prev_line | str trim) != "") {
                    $out_body = ($out_body | append "")
                }
                $out_body = ($out_body | append "\\newpage" | append "")
            }

            let is_list_item = (($trimmed =~ '^[-*+] ') or ($trimmed =~ '^[0-9]+[.] '))
            if $is_list_item and (not $in_list) and (($prev_line | str trim) != "") {
                $out_body = ($out_body | append "")
            }
            $in_list = $is_list_item
        }

        $out_body = ($out_body | append $line)
        $prev_line = $line
    }

    ($front | append $out_body | str join "\n") + "\n"
}

def main [] {
    let src_md = "/home/kira/Dropbox/Documentos/Clases/UBB/DataScienceAtTheCommandLine/Files/DataScienceCLI.md"
    let dst_md = "/home/kira/Dropbox/Documentos/Clases/UBB/DataScienceAtNushell/Files/DataScienceNushell.md"
    let dst_ubb_md = "/home/kira/Dropbox/Documentos/Clases/UBB/DataScienceAtNushell/Files/DataScienceNushell_ubb.md"

    let lines = (open --raw $src_md | lines)

    # 1. Frontmatter + Introduction + Ch1 (Windows 10+ & Linux/WSL2/dsin container)
    let intro = (get_introduction_content)
    let ch1_body = ((get_slice $lines 81 147) + "\n\n" + (get_ch1_tail))
    let ch1_public = ((get_frontmatter false) + "\n" + $intro + "\n\n" + $ch1_body)
    let ch1_ubb = ((get_frontmatter true) + "\n" + $intro + "\n\n" + $ch1_body)

    # 2. Chapter 2: Introducción y Fundamentos de Nushell
    #    - Ciencia de Datos (OSEMN) + Historia de la terminal (240..372)
    #    - La Terminal + Otros Shells como Bash y Zsh (get_ch2_terminal_and_shells)
    #    - Como entender nu (4629..4717)
    #    - Elementos básicos, Moviéndose por el Sistema, Strings, Listas, Registros, Tablas, Rutas de Celda
    #    - Edición con ttt + Control de Versiones (Git)
    let ch2 = (
        "# Introducción y Fundamentos de Nushell {#chapter-2-introduction}\n\n" +
        (patch_part2 (get_slice $lines 244 372)) + "\n\n" +
        (get_ch2_terminal_and_shells) + "\n\n" +
        (patch_part2 (get_slice $lines 4629 4717)) + "\n\n" +
        (patch_part2 (get_slice $lines 4198 4313)) + "\n\n" +
        (patch_part2 (get_slice $lines 4527 4628)) + "\n\n" +
        (patch_part2 (get_slice $lines 5458 5815)) + "\n\n" +
        (patch_part2 (get_slice $lines 4891 5133)) + "\n\n" +
        (patch_part2 (get_slice $lines 5134 5217)) + "\n\n" +
        (patch_part2 (get_slice $lines 4314 4526)) + "\n\n" +
        (patch_part2 (get_slice $lines 5218 5457)) + "\n\n" +
        (get_ch2_ttt) + "\n\n" +
        (patch_part2 (get_slice $lines 865 1135))
    )

    # 3. Chapter 3: Programación y Creación de Herramientas de Línea de Comandos
    let ch3 = (
        "# Programación y Creación de Herramientas de Línea de Comandos {#chapter-3-programming-cli-tools}\n\n" +
        (patch_part2 (get_slice $lines 6165 7433)) + "\n\n" +
        (get_ch3_maps_and_cli_tools)
    )

    # 4. Chapter 4: Obtención de Datos (Web, APIs, Archivos, Excel, SQLite)
    let ch4 = (
        (get_ch4_content) + "\n\n" +
        (patch_part2 (get_slice $lines 4765 4890))
    )

    # 5. Chapter 5: Depuración y Transformación de Datos (Plain text, Parsing, CSV, SQL, JSON/HTML, Polars)
    let nu_parsing = (patch_part2 (get_slice $lines 4718 4764))
    let nu_polars = (patch_part2 (get_slice $lines 5816 6164))
    let ch5 = (get_ch5_content $nu_parsing $nu_polars)

    # 6. Chapter 6: Exploración y Visualización de Datos (math, Polars, R/Python scripts, timg)
    let ch6 = (get_ch6_content)

    # 7. Chapter 7: Tuberías Paralelas (each, par-each, GNU parallel, distributed)
    let ch7 = (get_ch7_content)

    # 8. Chapter 8: Modelado de Datos (PCA/t-SNE, K-Means Clustering, Regression, Classification)
    let ch8 = (get_ch8_content)

    # Epilogue: Para seguir explorando
    let epilogue = (get_slice $lines 7602 7636)

    # References section
    let references = (get_references_content)

    let raw_book_public = (
        [
            $ch1_public
            $ch2
            $ch3
            $ch4
            $ch5
            $ch6
            $ch7
            $ch8
            $epilogue
            $references
        ] | str join "\n\n"
    )

    let raw_book_ubb = (
        [
            $ch1_ubb
            $ch2
            $ch3
            $ch4
            $ch5
            $ch6
            $ch7
            $ch8
            $epilogue
            $references
        ] | str join "\n\n"
    )

    let formatted_book_public = (format_for_pandoc $raw_book_public)
    $formatted_book_public | save -f $dst_md

    let formatted_book_ubb = (format_for_pandoc $raw_book_ubb)
    $formatted_book_ubb | save -f $dst_ubb_md

    let out_lines = (open --raw $dst_md | lines)
    let ubb_lines = (open --raw $dst_ubb_md | lines)
    print $"Successfully built public ($dst_md) with ($out_lines | length) lines."
    print $"Successfully built UBB ($dst_ubb_md) with ($ubb_lines | length) lines."
}
