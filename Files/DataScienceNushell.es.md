---
title: Ciencia de Datos en la Terminal Linux con Nushell
author: Luis Gómez Guzmán
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
  - '\usepackage[spanish,es-noshorthands,es-tabla]{babel}'
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
  - '\usepackage{fvextra}'
  - '\fvset{breaklines=true,breakanywhere=true}'
  - '\DefineVerbatimEnvironment{verbatim}{Verbatim}{breaklines=true,breakanywhere=true,fontsize=\small}'
  - '\DefineVerbatimEnvironment{Highlighting}{Verbatim}{breaklines=true,breakanywhere=true,commandchars=\\\{\},fontsize=\small}'
  - '\setcounter{tocdepth}{5}'
  - '\setcounter{secnumdepth}{5}'
  - '\makeatletter'
  - '\renewcommand\paragraph{\@startsection{paragraph}{4}{\z@}{3.25ex \@plus1ex \@minus.2ex}{1.5ex \@plus.2ex}{\normalfont\normalsize\bfseries}}'
  - '\renewcommand\subparagraph{\@startsection{subparagraph}{5}{\z@}{3.25ex \@plus1ex \@minus.2ex}{1.5ex \@plus.2ex}{\normalfont\normalsize\bfseries}}'
  - '\makeatother'
---

\tableofcontents
\renewcommand{\listfigurename}{Índice de figuras}
\listoffigures
\renewcommand{\listtablename}{Índice de tablas}
\listoftables
\newpage


# Introducción {#chapter-1-introduction}

En la práctica contemporánea de la ciencia de datos, la escala masiva, la heterogeneidad y el dinamismo de los flujos de información exigen herramientas capaces de trascender la rigidez de las interfaces gráficas y la sobrecarga computacional propia de los entornos de desarrollo monolíticos. Durante más de cinco décadas, la consola de comandos de Unix se ha consolidado como el estándar de referencia para la reproducibilidad científica, la automatización desatendida y la eficiencia algorítmica. Su filosofía fundacional postula una premisa de notable vigencia: articular sistemas a partir de programas compactos y modulares, concebidos para resolver una tarea concreta con precisión técnica y acoplarse con naturalidad mediante canales estandarizados de comunicación.

Sin embargo, las shells tradicionales (entre las que destacan Bash y Zsh) fueron proyectadas en una época en que la información en tránsito se interpretaba exclusivamente como secuencias no estructuradas de caracteres. Bajo este esquema clásico, operar sobre matrices de datos, estructuras tabulares complejas o registros jerárquicos demanda intrincadas combinaciones de expresiones regulares y utilidades de corte léxico (tales como `sed`, `awk` y `cut`). Semejante paradigma introduce una fragilidad persistente; resulta vulnerable a delimitadores imprevistos, sufre ante secuencias de escape y, de modo crítico, despoja a las variables de sus atributos semánticos y tipos fundamentales.

Nushell (`nu`) supera de raíz esta limitación histórica mediante una arquitectura concebida expresamente para las exigencias del análisis de datos contemporáneo. En lugar de canalizar flujos de bytes planos y opacos, los pipelines de Nushell transportan estructuras de datos enriquecidas: tablas bidimensionales tipadas, registros jerárquicos indexados por clave y valor, listas ordenadas y valores primitivos regulados por esquemas estrictos. Al reconocer de forma nativa enteros, valores en coma flotante, marcas temporales con huso horario, rutas del sistema de archivos y magnitudes de memoria, Nushell permite filtrar, ordenar, remodelar y agregar conjuntos de información mediante una sintaxis declarativa, concisa y elegante.

A esta claridad expresiva se suma un desempeño computacional extraordinario. Su integración profunda con el motor columnar Polars (programado en Rust y edificado sobre el estándar en memoria Apache Arrow) dota a la terminal de una capacidad analítica sin precedentes. Esta sinergia hace viable ejecutar consultas analíticas multihilo sobre millones de registros en fracciones de segundo, preservando en todo momento la inmediatez y la ligereza del flujo interactivo en la línea de comandos.

Este libro se basa en el trabajo de Jeroen Janssens en su obra *Data Science at the Command Line* (O'Reilly Media). Su propuesta demostró que la terminal de Unix es un entorno ágil y eficaz para el análisis de datos. Sin embargo, las herramientas de línea de comandos han evolucionado notablemente en los últimos años.

Mientras que el libro original utilizaba herramientas clásicas orientadas a texto plano y utilidades como `csvkit`, este libro adopta Nushell y su modelo de datos estructurados. Esto permite mantener los principios de modularidad y reproducibilidad de Unix, pero con tablas tipadas, esquemas claros y mayor robustez al procesar información.

Este libro está pensado para trabajarse de manera práctica, con la terminal abierta junto a la lectura. Por esta razón, la mayoría de los ejemplos de código no incluyen la salida de los comandos (salvo gráficos en consola, imágenes o diagramas indispensables). La intención es que ejecutes cada comando, explores sus resultados y experimentes directamente con Nushell.

Omitir las salidas en los ejemplos responde a tres objetivos prácticos: primero, fomentar el aprendizaje activo escribiendo y ejecutando los comandos en lugar de solo leerlos; segundo, aprovechar las capacidades interactivas de Nushell (como `explore`, la paginación de tablas y el autocompletado), que se aprecian mejor en vivo; y tercero, desarrollar el hábito de inspeccionar datos intermedios con `describe` y diagnosticar errores de forma autónoma. Te invitamos a modificar los parámetros, probar filtros alternativos y explorar los resultados en tu propia terminal.

Para garantizar que cada experiencia práctica se ejecute en condiciones rigurosamente reproducibles e inmunes a divergencias de configuración local, el texto se apoya en un entorno unificado denominado `dsin` (Data Science in Nushell), distribuido como imagen pública de Docker en `ghcr.io/kurokirasama/dsin:latest`. Dicho contenedor constituye una estación analítica completa. Encapsula la versión más reciente de Nushell con un perfil afinado para el procesamiento de datos, su ecosistema de complementos (con soporte nativo para Polars, manipulación de formatos estructurados, consultas relacionales avanzadas, control de versiones y graficación en terminal), entornos robustos de Python y R configurados con sus bibliotecas científicas indispensables, algoritmos de alto rendimiento para modelado predictivo (como Vowpal Wabbit, Tapkee y SKLL), herramientas modernas de línea de comandos (entre las que destacan el editor interactivo `ttt` y el visor gráfico de alta fidelidad `timg`), así como la totalidad de los conjuntos de datos del curso, organizados meticulosamente por capítulos en el directorio `/data`.

Este libro está organizado siguiendo las etapas del ciclo clásico OSEMN (*Obtain*, *Scrub*, *Explore*, *Model* e *iNterpret*), propuesto originalmente por Hilary Mason y Chris Wiggins. El recorrido comienza en el [capítulo 2](#chapter-2-installation) con la instalación del software y la preparación del entorno de trabajo reproducible mediante Docker y el contenedor `dsin`. A continuación, el [capítulo 3](#chapter-3-nushell-fundamentals) establece las bases operativas de la línea de comandos y el sistema de tipos de datos en Nushell, mientras que el [capítulo 4](#chapter-4-programming-cli-tools) profundiza en la programación estructurada y la creación de herramientas modulares reutilizables. El [capítulo 5](#chapter-5-data-acquisition) aborda las estrategias de obtención e ingesta de datos desde la web, APIs, archivos estructurados y bases de datos relacionales. Posteriormente, el [capítulo 6](#chapter-6-data-cleaning) introduce la limpieza y transformación de datos junto a la analítica columnar con Polars. La exploración estadística y la visualización gráfica en la terminal se desarrollan en el [capítulo 7](#chapter-7-data-exploration), dando paso en el [capítulo 8](#chapter-8-parallel-pipelines) a la orquestación de flujos de trabajo, procesamiento en serie y pipelines paralelos. Finalmente, el [capítulo 9](#chapter-9-polyglot-modeling) aborda el modelado predictivo políglota, integrando reducción de dimensionalidad, agrupamiento no supervisado, regresión y clasificación supervisada.


\newpage

# Instalación de Software {#chapter-2-installation}

En esta sección se entregaran las instrucciones para instalar el software necesario para este libro, tanto en Windows 10+ como en Linux, para distribución basada en Debian como Ubuntu.

## Windows 10+

### Instalación Ubuntu WSL

1. Habilitar WSL1, ejecutando en Powershell (con permisos de administrador):

```powershell
Enable-WindowsOptionalFeature -Online -FeatureName Microsoft-Windows-Subsystem-Linux

```

2. Habilitar VMP, ejecutando en Powershell:

```powershell
Enable-WindowsOptionalFeature -Online -FeatureName VirtualMachinePlatform

```

3. Listar las distribuciones disponibles y seleccionar (recomendada Ubuntu 24.04):

```powershell
wsl --list --online
```

4. Instalamos la distribución seleccionada:

```powershell
wsl --install -d Ubuntu-24.04
```

4. Configuramos para que la distribución Linux en WSL use v2. Ejecutamos en Powershell:

```powershell
wsl --set-version Ubuntu-24.04 2

```

Para hacerlo por defecto en todas las distribuciones (recomendado):

```powershell
wsl --set-default-version 2

```

5. Actualizar kernel. Descarga desde [WSL](https://wslstorestorage.blob.core.windows.net/wslblob/wsl_update_x64.msi) e instalar.

### Instalación de Docker

1. Descargar instalador Docker para Windows desde: [docker](https://docs.docker.com/desktop/install/windows-install/) y ejecutar. Seleccionar "Usar WSL 2...".

2. Habilitar "Iniciar Docker al iniciar sesión", en la configuración de Docker.

3. Reiniciar.

### Abrir distribución

Para entrar a la distribución instalada, ejecutar en `cmd` o `powershell`:

```powershell
wsl

```



## Linux, WSL2 y el Contenedor `dsin` (Data Science in Nushell) {#section-install-docker}

En este libro trabajaremos sobre una imagen Docker integrada llamada **`dsin`** (*Data Science in Nushell*), publicada en `ghcr.io/kurokirasama/dsin:latest`. A diferencia de los entornos tradicionales basados en *shells* de texto plano, el contenedor `dsin` inicia directamente en **Nushell** como *shell* predeterminado en el directorio de trabajo `/data`, e incluye preconfigurados:

- **Nushell (`nu`)** y su suite completa de complementos registrados: **`nu_plugin_polars`** (motor de DataFrames Arrow/Polars), **`nu_plugin_formats`**, **`nu_plugin_gstat`**, **`nu_plugin_inc`**, **`nu_plugin_query`**, **`nu_plugin_file`**, **`nu_plugin_plot`** (gráficos en la terminal) y **`nu_plugin_port_extension`**.
- **Directorio `/data` integrado por defecto:** Contiene todas las carpetas de datos del libro organizadas exactamente según el número del capítulo en que se utilizan (`/data/ch03`, `/data/ch04`, `/data/ch05`, `/data/ch06`, `/data/ch07`, `/data/ch08` y `/data/ch09`), sin necesidad de descargas ni configuraciones manuales adicionales.
- **Editor de texto en terminal `ttt`** en `$env.PATH` con resaltado de sintaxis y atajos preconfigurados.
- **Visor gráfico de terminal `timg`** en `$env.PATH` para inspeccionar imágenes y gráficos estadísticos directamente en la consola.
- **Ecosistema políglota:** R (`Rscript`, `tidyverse`, `ggplot2`, `rpart`, `class`, `cluster`), Python 3 (`pandas`, `scikit-learn`, `scipy`, `matplotlib`, `seaborn`, `skll`), **GNU Parallel (`parallel`)**, **Tapkee (`tapkee`)** y **Vowpal Wabbit (`vw`)**.
- **Módulo de herramientas del libro (`dsin_tools.nu`):** Comandos personalizados (`to-vw`, `vw-regress`, `tapkee-reduce`, `kmeans-cluster`) cargados automáticamente al iniciar.

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

Para descargar la imagen oficial del libro desde GitHub Container Registry:

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
ls /data
version
which nu ttt timg parallel vw tapkee run_experiment Rscript python3
plugin list
```



\newpage

# Fundamentos y Estructuras de Datos en Nushell {#chapter-3-nushell-fundamentals}

## Ciencia de Datos

De acuerdo a la definición de Hilary Mason y Chris H. Wiggins (2010), la _ciencia de datos_ se define de acuerdo a 4 pasos:

1. Obtención de datos.
2. Depuración de datos.
3. Exploración de datos.
4. Modelación de datos.
5. Interpretación de datos.

En este libro veremos los primeros 4 pasos.

Aunque estos 5 pasos se discuten en forma lineal e incremental, en la practica es común el moverse de uno a otro o incluso realizarlos en paralelo (\refer{Figura}{fig:osemn}). Es decir, la ciencia de datos es un proceso iterativo no lineal.

\begin{figure}[h]
\centering
\includegraphics[width=0.8\textwidth]{dscl_0101.png}
\caption{Proceso de la ciencia de datos.}
\label{fig:osemn}
\end{figure}



### Obtención de datos

Sin datos, no hay ciencia de datos, por lo que el primer paso es obtenerlos. Para ello, se puede necesitar realizar uno o mas de las siguientes tareas:

- Descargar datos desde otra ubicación, por ejemplo, pagina web o servidor.
- Obtener datos desde una base de datos o a través de una API, por ejemplo, MySQL o Twitter.
- Extraer datos de un archivo, por ejemplo, html, excel, csv.
- Generar datos, ya sea mediante sensores o haciendo encuestas.

Los formatos mas usuales para almacenar datos son, texto plano (txt), csv, json, html, xml, excel.

### Depuración de datos

No es poco usual que los datos obtenidos tengan valores faltantes, inconsistencias, errores, caracteres erróneos o columnas no interesantes. En tales casos, los datos deben depurarse o limpiarse antes de poder hacer cualquier cosa con ellos. La operaciones mas comunes incluyen:

- Filtrar lineas.
- Extraer algunas columnas.
- Reemplazar valores.
- Extraer palabras.
- Lidiar con datos faltantes y duplicados.
- Convertir de un formato a otro.

Usualmente, un 80% de cualquier trabajo con datos corresponde a la obtención y depuración. El otro 20% es la exploración, modelación y visualización.

### Exploración de datos

Una vez hecha la limpieza de datos, se procede a explorarlos. Es en esta etapa donde realmente se comprende de mejor forma los datos obtenidos. A través de la terminal se puede:

- Observar los datos.
- Derivar estadísticas.
- Crear visualizaciones.

### Modelación de datos

Si se quiere explicar los datos o predecir lo que pasara, probablemente se necesita crear un modelo estadístico de los datos. Algunas técnicas para crear modelos incluyen clustering, clasificación, regresión y reducción de dimensionalidad.

La terminal no es apta para programar un nuevo modelo desde 0, pero es muy útil el ser capaz de crear un modelo desde ella.

### Interpretación de datos

El ultimo y probablemente mas importante paso es interpretarlos. Este paso involucra:

- Obtener conclusiones.
- Evaluación de resultados.
- Comunicación de resultados.

Esta etapa no involucra la terminal, y queda en manos del investigador.

## Historia de la terminal

La _terminal_ (_terminal emulator_) en un programa o interfaz que nos permite acceder a la _linea de comandos_ (_command line_) a través de un tipo particular de sintaxis llamado _shell_.

Originalmente, una terminal era una pieza de _hardware_ usado para ingresar y mostrar datos a/desde un computador.

Los primeros computadores, eran maquinas que ocupaban mucho espacio (ver \refer{Figura}{fig:first}) y las primeras terminales eran tele-impresoras electrónicas (teletypewriter o tty) como se muestra en la (ver \refer{Figura}{fig:firstterminal}).

\begin{figure}[h]
\centering
\includegraphics[width=0.8\textwidth]{univac-9400.jpg}
\caption{Primeros computadores.}
\label{fig:first}
\end{figure}

\begin{figure}[h]
\centering
\includegraphics[width=0.5\textwidth]{teletype-model-33.jpg}
\caption{Primeras terminales.}
\label{fig:firstterminal}
\end{figure}

Conforme fue avanzando la tecnología, estas terminales se reemplazaron por terminales de video (ver \refer{Figura}{fig:videoterminal}).

\begin{figure}[h]
\centering
\includegraphics[width=0.5\textwidth]{DEC-VT100-terminal.jpg}
\caption{Primeras terminales de video.}
\label{fig:videoterminal}
\end{figure}

Notar que lo mostrado en la \refer{Figura}{fig:videoterminal} no es un computador, es solo la interfaz para poder conectarse al computador. En la \refer{Figura}{fig:videoterminal2} se muestra conectada a uno.

\begin{figure}[h]
\centering
\includegraphics[width=0.5\textwidth]{DEC-VT52-terminal-PDP-11-55.jpg}
\caption{Primeras terminales conectadas a un computador.}
\label{fig:videoterminal2}
\end{figure}

En la actualidad no son necesarias estas terminales de _hardware_, por lo que se usan emuladores de terminales para realizar la comunicación directa con el sistema operativo sin necesidad de una interfaz gráfica (gui), esto ultimo siendo lo mas conocido (ventanas, botones, etc).

### Shell

La _shell_ es la sintaxis particular que se utiliza para ejecutar comandos y programas en la terminal. Hay varios tipos de _shell_, como _bash_, _csh_, _zsh_, _nushell_, entre muchos otros, siendo la mas usual _bash_ como la por defecto en la mayoría de distribuciones Linux.

En este libro utilizaremos la shell Nushell, en la cual a cada comando lo precede un indicador llamado prompt (por ejemplo, `/data>`), que señala que la terminal está lista para recibir instrucciones.

### Ventajas del uso de la terminal

El uso de la terminal para ciencia de datos tienes varias ventajas, como por ejemplo:

- Es ágil: permite explorar datos de forma interactiva, obteniendo resultados de forma casi inmediata.
- Es integradora: se integra bien con otras tecnologías y software.
- Es escalable: se pueden automatizar muchas tareas mediante _scripts_, lo que da como resultado herramientas mas complejas.
- Es extensible: permite el uso de diferentes lenguajes de programación.
- Es ubicua: se encuentra en todos los sistemas operativos.



## La Terminal

Antes de profundizar en las estructuras de datos de Nushell, revisemos los conceptos esenciales del entorno de terminal y cómo operaban los *shells* tradicionales que precedieron a Nushell.

### El Ambiente

En la terminal interactuamos mediante un ciclo continuo conocido como **REPL** (*Read-Eval-Print Loop*: Leer, Evaluar, Imprimir y Repetir):

1. La terminal muestra un indicador o *prompt* (por ejemplo, `/data/ch03>`) indicando el directorio actual y que está lista para recibir instrucciones.
2. El usuario escribe una línea de comando y presiona **`Enter`**.
3. El *shell* analiza (*parsea*) y evalúa la instrucción, ejecutando los programas o transformaciones correspondientes.
4. El resultado se imprime en la pantalla y el *prompt* vuelve a aparecer.

### Ejecutar un Comando y Guardar Resultados en Archivos

Para comenzar a trabajar con los ejemplos de este capítulo, ingresamos a su directorio correspondiente:

```nu
cd /data/ch03
```

A partir de este punto, todos los comandos se ejecutan dentro de `/data/ch03`. Inspeccionemos los archivos disponibles:

```nu
ls
```

Si deseamos inspeccionar las primeras 5 líneas del archivo `movies.txt`, abrimos el archivo en el directorio actual (`open movies.txt`), dividimos sus líneas con `lines` y tomamos las primeras 5 con `first 5`:

```nu
open movies.txt | lines | first 5
```

En ciencia de datos reproducible, además de visualizar el resultado en pantalla, frecuentemente necesitamos persistir el resultado procesado en un nuevo archivo utilizando el comando `save -f`:

```nu
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
3. **Pérdida de encabezados:** Si se aplica `sort` o `grep` a un archivo CSV en `bash`, la primera línea (que contiene los nombres de las columnas) es tratada como una fila de datos cualquiera, mezclándose con los registros o desapareciendo tras el filtro.
4. **Incompatibilidad con datos jerárquicos (JSON, XML, Excel, SQLite, Parquet):** El texto línea por línea no puede representar directamente objetos anidados ni tablas tipadas sin recurrir a múltiples conversores externos (`jq`, `xmllint`, `sqlite3`) con sintaxis inconexas entre sí.

**Nushell conserva lo mejor de la filosofía Unix** (la composición modular mediante pipes `|`), pero reemplaza los flujos de texto crudo por **flujos de datos estructurados y tipados (tablas, registros y listas)**. Comprender esta diferencia hace que la siguiente sección resulte completamente natural.


## Como entender nu

### Nushell no es bash

Nushell es tanto un lenguaje de programación estructurado como un shell interactivo. Debido a esta concepción dual, posee una metodología propia y consistente para operar sobre archivos, directorios, servicios web y estructuras de datos tabulares. Se ha diseñado tomando como inspiración los flujos de trabajo tradicionales de otros shells para facilitar la transición:

```nu
ls | length
```

Nushell también ofrece soporte nativo para inspeccionar el estado y el código de salida de comandos ejecutados previamente mediante la variable de entorno `$env.LAST_EXIT_CODE`.

Sin embargo, a pesar de estas comodidades, Nushell no es bash. El modelo de ejecución de bash y el estándar POSIX tradicional (basado en cadenas de caracteres no estructuradas) difieren de la arquitectura tipada de Nushell. Por ejemplo, en bash se utiliza habitualmente el operador de redirección `>` para escribir en un archivo:

```sh
echo "hello" > output.txt
```

En Nushell, el carácter `>` está reservado como el operador aritmético de comparación "mayor que", lo que garantiza la coherencia sintáctica dentro del lenguaje. Para persistir datos en disco, el flujo se canaliza de forma explícita hacia el comando `save`:

```nu
"hello" | save -f output.txt
```

En Nushell, la información fluye estructuradamente a lo largo del pipeline hasta su presentación final o hasta ser procesada por un comando terminal. Es posible emitir directamente cualquier estructura de datos (escalares, listas, registros y tablas) encadenándolas con el operador pipe (`|`).

### «Bashismos» y Atajos de Productividad Soportados en Nushell

Aunque Nushell no es un shell POSIX y promueve el procesamiento de datos estructurados, incorpora deliberadamente diversos atajos interactivos populares en bash (frecuentemente denominados *bashismos*) para agilizar la labor diaria en la terminal sin comprometer la integridad del lenguaje:

#### Expansión de Historial con Sintaxis *Bang-Bang* (`!`)

Gracias al motor de línea de comandos interactivo de Nushell (`reedline`), se cuenta con soporte nativo para atajos de recuperación de comandos del historial:

- **`!!`:** Inserta en el búfer de entrada el último comando ejecutado.
- **`!$`:** Inserta el último argumento o token separado por espacios del comando previo.
- **`!<índice>`:** Recupera e inserta el comando correspondiente a dicho número de orden en el historial (consultable con `history`).
- **`!-<n>`:** Inserta el comando ejecutado $n$ posiciones atrás en el historial.
- **`!<prefijo>`:** Recupera el comando más reciente que coincida con el prefijo indicado.

A diferencia del comportamiento tradicional en bash (donde los comandos *bang-bang* se ejecutan de manera inmediata), en Nushell **el comando expandido se deposita en el búfer de edición de la línea de comandos**, permitiendo inspeccionar, modificar y validar la instrucción antes de presionar `Enter`. Es posible explorar el tutorial interactivo integrado ejecutando directamente:

```nu
# skip-docker-exec (tutorial interactivo en terminal)
tutor bashisms
```

#### Secuenciación y Control de Procesos Externos

- **Secuenciación con punto y coma (`;`):** Se permite encadenar múltiples instrucciones consecutivas separándolas mediante `;` (por ejemplo, `cd /data; ls`). A diferencia de bash, los operadores booleanos no son `&&` ni `||`, sino las palabras clave `and` y `or` (o bloques condicionales `if`).
- **Invocación explícita de ejecutables externos (`^`):** Cuando un comando interno de Nushell coincide en nombre con un binario instalado en el sistema operativo (como `ls`, `ps` o `find`), anteponer el símbolo circunflejo `^` (`^ls`, `^ps`) fuerza la ejecución directa del binario del sistema operativo ubicado en `$env.PATH`.
- **Variables de entorno por comando (*one-shot*):** Para definir una variable de entorno temporal asociada exclusivamente a una única ejecución externa, se antepone la asignación al comando (por ejemplo, `FOO=bar ^mi_script`).
- **Redirecciones estándar para ejecutables externos:** Nushell dispone de operadores de redirección hacia archivos (`o>` para *stdout*, `e>` para *stderr*, `o+e>` para ambos flujos combinados y `e>|` para canalizar los errores hacia una tubería).



<!--
### El entorno de Nushell es *scoped*
Nushell toma múltiples indicaciones de diseño de lenguajes compilados. Una de esas indicaciones es que los lenguajes deben evitar el estado mutable global. Los shells han utilizado comúnmente la mutación global para actualizar el entorno, pero Nushell se aleja de este enfoque.

En Nushell, los bloques controlan su propio entorno. Los cambios en el entorno tienen un ámbito limitado al bloque donde ocurren.

En la práctica, esto permite escribir código conciso para trabajar con subdirectorios; por ejemplo, si se requiere compilar cada subproyecto en el directorio actual, se puede ejecutar:

```nu
# skip-docker-exec
ls | where type == dir | each { |row|
    cd $row.name
    make
}
```

El comando `cd` cambia las variables de entorno `PWD`, y este cambio de variable no escapa del bloque, lo que permite que cada iteración comience desde el directorio actual e ingrese al siguiente subdirectorio.

Tener el entorno *scoped* de esta manera hace que los comandos sean más predecibles, fáciles de leer y, cuando llegue el momento, fáciles de depurar. Nushell también proporciona comandos auxiliares como `def --env`, `load-env`, como formas convenientes de realizar lotes de actualizaciones en el entorno.

La buena práctica de codificación de no tener variables mutables globales se extiende al entorno en Nushell. El uso de los comandos auxiliares integrados permitirá trabajar más fácilmente con el entorno en Nushell. Aprovechar el hecho de que los entornos tienen un ámbito limitado a los bloques también puede ayudarte a escribir scripts más concisos e interactuar con comandos externos sin agregar cosas a un entorno global que no necesitas.
-->

<!--AQUI-->


## Elementos básicos de nushell

En esta sección se revisarán los primeros elementos de Nushell.

Nushell funciona bajo el principio fundamental de que todo flujo de información consiste en datos estructurados; en consecuencia, se pueden formular consultas y transformaciones directas (análogas a las de SQL) sobre la salida de cada instrucción. Para ilustrar esta distinción, resulta clarificador contrastar la salida de texto plano que genera el comando externo del sistema operativo con la salida estructurada que produce Nushell.

Si se ejecuta el comando externo tradicional del sistema anteponiendo el acento circunflejo `^`:

```nu
^ls
```

> **Nota sobre el operador `^`:** En Nushell, el símbolo `^` actúa como operador de escape hacia binarios externos del sistema operativo. Le indica al motor que ignore cualquier comando interno (*built-in*), alias o función personalizada de Nushell y ejecute directamente el archivo binario ejecutable que coincida con ese nombre en las rutas de `$env.PATH` (en este caso, `/bin/ls`). Su salida consiste puramente en un flujo de caracteres sin estructura interna.

Por el contrario, al ejecutar el comando nativo `ls` de Nushell:

```nu
ls
```

Se observa que `ls` retorna una tabla estructurada y tipada en lugar de un bloque de texto no estructurado. Cada fila representa un archivo o directorio y cada columna (`name`, `type`, `size`, `modified`) posee un tipo de dato concreto. Al igual que en una base de datos o en una hoja de cálculo, esta tabla permite ordenar, filtrar, proyectar y consultar los registros de manera directa.

Para ordenar la tabla por tamaño, se toma la salida de `ls` y se canaliza hacia un comando capaz de ordenar colecciones tabulares según los valores de una columna:

```nu
ls | sort-by size | reverse
ls | sort-by size -r
ls | sort-by modified
```

Se puede observar que para que esto funcione no se utilizan argumentos de línea de comandos de `ls`. En su lugar, se utiliza el comando `sort-by` que Nu proporciona para hacer la clasificación de la salida del comando `ls`. Para ver los archivos más grandes en la parte superior, también se utiliza `reverse` o la opcion `-r` de `sort-by`.

Nu proporciona muchos comandos que pueden funcionar en tablas. Por ejemplo, se puede utilizar `where` para filtrar el contenido de la tabla `ls` para que sólo muestre los archivos de más de 5 kilobytes

```nu
ls | where size > 100kb
```

Al igual que en la filosofía Unix, ser capaz de hacer que los comandos se comuniquen entre sí entrega formas de mezclar y combinar en muchas combinaciones diferentes. Veamos un comando diferente:

```nu
ps
```

Este comando entrega una lista de todos los procesos actuales que el sistema está ejecutando, cuál es su estado y cuál es su nombre. También podemos ver la carga de CPU de los procesos.

Si se quisiera mostrar los procesos que están utilizando activamente la CPU, se puede proceder como sigue:

```nu
ps | where cpu > 0
```

Nu no solo permite tablas estructuradas de forma simple, si no que también permite anidaciones arbitrarias. Por ejemplo, consideremos el comando `help commands`. Este comando proporciona información para todos los comandos de Nushell como una tabla.

```nu
help commands
```

La salida es bastante extensa, por lo que se obtendra la fila para el comando `each`.

```nu
help commands | where name == each
help commands | where name == each | first
```

Al ecuperar una sola fila de una tabla se obtiene un _registro_ (_record_), que es un conjunto de pares clave-valor. Observar como la columnas "signatures" contiene un registro en lugar de valores simples. Para ver sólo una de estas "claves" o columnas, se puede utilizar el comando `get`:

```nu
help commands | where name == each | first | get description
help commands | where name == each | first | get params
```

El comando `get` nos permite saltar al contenido de los datos estructurados (una tabla, registro o lista). Incluso se puede pasar columnas anidadas para acceder a los datos a cualquier profundidad.

```nu
help commands | where name == each | first | get category
help commands | where name == each | first | get command_type
help commands | where name == each | first | get description
help commands | where name == each | first
```

Estas columnas anidadas se llaman _rutas de celda_ (_cellpaths_). Nu tomará la ruta de la celda e irá al bit de datos correspondiente en una tabla, registro o lista. Las rutas de celda también admiten números de fila, por lo que los comandos anterior también se puede escribir como:

```nu
help commands | where name == each | first | get params
help commands | where name == each | first | get params.0
help commands | where name == each | first | get params.3.description
```

Si se quiere ver la estructura anidada, se puede utilizar `table -e`:

```nu
help commands | where name == each | first | table -e
```

Notar que se pueden acceder a todas las herramientas estandar de la terminal utilizando el símbolo `^` si existe una versión nushell. Si no existe, no es necesario utilizarlo:

```nu
^ls
open tips.csv | first 5
uname
```

Todo comando nushell que retorna datos lo hará en una tabla, por ejemplo:

```nu
#muestra los procesos en ejecucion
ps

#ordenados por mayor utilizacion de cpu
ps | where cpu > 0 | sort-by cpu -r
```

### Obtener Ayuda

Se puede leer texto de ayuda para cualquiera de los comandos incorporados de Nu usando el comando `help` o pasando la opción `--help` a un comando. También se puede buscar un tema utilizando `help -f <topic>`.

```nu
help explore
help http get
help -f open
```

Asimismo, Nushell proporciona el comando `tutor`, una guía interactiva integrada directamente en la terminal orientada al aprendizaje práctico y progresivo de las capacidades de la shell:

- `tutor`: Muestra el mensaje de bienvenida y las instrucciones de uso generales.
- `tutor list`: Enumera todos los temas didácticos disponibles (como tablas, rutas de celda, expresiones, variables, bloques, condicionales y cierres).
- `tutor <tema>`: Carga la lección correspondiente al concepto indicado (por ejemplo, `tutor table`, `tutor closure` o `tutor pipeline-input`).
- `tutor -f <frase>` o `tutor --find <frase>`: Busca términos y explicaciones específicas a lo largo de las lecciones del tutorial.

```nu
tutor
tutor list
tutor table
```


## Tipos de Datos y Variables en Nushell

Tras haber interactuado de forma práctica con las tablas estructuradas de `ls`, los filtros relacionales con unidades dimensionales (`where size > 100kb`) y el direccionamiento mediante rutas de celda, resulta indispensable formalizar los fundamentos teóricos que sustentan este comportamiento. En esta sección se analiza la taxonomía del sistema de tipos de Nushell, el modelo de compilación en dos fases y los mecanismos formales de vinculación y ciclo de vida de variables mediante `let`, `mut` y `const`.

### Sistema de Tipos de Datos en Nushell

Una de las transformaciones conceptuales más profundas que introduce Nushell frente a las shells tradicionales de Unix radica en su sistema de tipos fuertemente estructurado. En entornos convencionales como Bash o Zsh, toda información en tránsito consiste en secuencias arbitrarias de bytes o cadenas de texto sin formato. Dicha arquitectura fuerza al usuario a recurrir de manera constante a utilidades externas como `awk`, `cut` o expresiones regulares complejas para extraer significado numérico, categórico o temporal. Por el contrario, en Nushell cada elemento que fluye a través de un pipeline conserva íntegra su identidad de tipo, lo cual posibilita operaciones semánticas directas, validaciones rigurosas en tiempo de ejecución y notables optimizaciones al manipular datos estructurados.

Para inspeccionar dinámicamente el tipo de cualquier dato o el resultado intermedio transmitido a través de un pipe, se emplea el comando `describe`:

```nu
[
  (42 | describe),
  (3.14 | describe),
  ("ciencia de datos" | describe),
  (true | describe),
  (2026-10-21 | describe),
  (15min | describe),
  (2.5gb | describe)
]
```

Nushell clasifica sus tipos en escalares primitivos, tipos con unidades dimensionales (tamaños de archivo y duraciones temporales), estructuras compuestas y tipos del sistema de ejecución. La Tabla 1 sintetiza este catálogo fundamental:

| Categoría | Tipo de Dato | Sintaxis y Literales de Ejemplo | Descripción Operativa |
| :--- | :--- | :--- | :--- |
| **Escalares** | `int` | `42`, `-10`, `0x2A` | Entero de 64 bits con signo para conteos y operaciones discretas. |
| **Escalares** | `float` | `3.14159`, `-0.001`, `Infinity` | Número decimal de precisión doble IEEE 754 de 64 bits. |
| **Escalares** | `string` | `"texto"`, `'simple'`, `r#'crudo'#` | Cadena de texto codificada en UTF-8 con soporte para interpolación `$"..."`. |
| **Escalares** | `bool` | `true`, `false` | Valor lógico para bifurcaciones condicionales y filtros relacionales. |
| **Escalares** | `nothing` | `null` | Representa la ausencia explícita de valor o resultado vacío. |
| **Dimensionales** | `filesize` | `512b`, `10kb`, `4mb`, `2gb`, `1tb` | Magnitud binaria/decimal con soporte aritmético (`2gb - 500mb`). |
| **Dimensionales** | `duration` | `100ms`, `5sec`, `2min`, `3hr`, `7day` | Intervalo temporal con conversión y suma automática (`1hr + 30min`). |
| **Dimensionales** | `datetime` | `2026-10-21`, `2026-10-21T15:30:00Z` | Marca temporal absoluta en formato ISO 8601 con zona horaria. |
| **Estructuras** | `list<T>` | `[1 2 3]`, `["a" "b" "c"]` | Colección ordenada de valores indexables secuencialmente. |
| **Estructuras** | `record<...>` | `{nombre: "Carlos", edad: 30}` | Conjunto de pares clave-valor heterogéneos análogos a un objeto JSON. |
| **Estructuras** | `table<...>` | `[[id valor]; [1 100] [2 200]]` | Estructura bidimensional equivalente a una lista homogénea de registros. |
| **Estructuras** | `range` | `1..10`, `0..<5`, `1..` | Intervalo numérico continuo o semiabierto eficiente en memoria. |
| **Avanzados** | `binary` | `0x[deadbeef]`, `0x[48 65 6c 6c 6f]` | Secuencia cruda de bytes binarios para flujos de red o archivos binarios. |
| **Avanzados** | `closure` | `{|x| $x * 2 }`, `{ $in > 10 }` | Bloque ejecutable anónimo con argumentos o captura del flujo de entrada `$in`. |
| **Avanzados** | `glob` | `*.csv`, `**/*.parquet` | Patrón de concordancia de rutas del sistema de archivos. |
| **Avanzados** | `cell-path` | `$.nombre`, `$.columna.0` | Ruta de direccionamiento declarativa a columnas o celdas internas. |

Table: Sistema de tipos de datos fundamentales en Nushell.

Los tipos dimensionales representan una de las ventajas analíticas más potentes del entorno: Nushell comprende intrínsecamente las magnitudes físicas y normaliza de forma automática las comparaciones sin exigir conversiones algebraicas manuales. Por ejemplo, al filtrar registros por tamaño de archivo (`where size > 50mb`) o por umbrales de latencia (`where latency < 200ms`), el motor de evaluación ejecuta el cálculo dimensional exacto entre unidades compatibles.

### Nushell como un lenguaje compilado

Una parte importante del diseño de Nushell y específicamente donde difiere de muchos lenguajes dinámicos es que Nushell convierte el código fuente en algo para ejecutar, y luego ejecuta el resultado. No tiene una función `eval` que permita continuar introduciendo nuevo código fuente durante el tiempo de ejecución. Esto significa que las tareas como incluir archivos para que formen parte de un proyecto deben ser rutas conocidas, al igual que las inclusiones en lenguajes compilados como C++ o Rust.

Por ejemplo, lo siguiente no tiene sentido en Nushell, y fallará al ejecutarse si se ejecuta como un script:

```nu
# skip-docker-exec (demostración de error de compilación)
"def abc [] { 1 + 2 }" | save -f output.nu
source "output.nu"
abc
```

El comando `source` aumentará el código fuente que se compila, pero el `save` de la línea anterior no habrá tenido la oportunidad de ejecutarse. Nushell ejecuta todo el bloque como si fuera un solo archivo, en lugar de ejecutar una línea a la vez. En el ejemplo, dado que el archivo `output.nu` no se crea hasta después del paso de 'compilación', el comando `source` no puede leer las definiciones del mismo durante el tiempo de análisis.

Otro problema común es intentar crear dinámicamente el nombre de archivo desde el que obtener el código fuente:

```nu
# skip-docker-exec (demostración de error en tiempo de compilación)
source $"($my_path)/common.nu"
```

Esto no funciona si `my_path` es una variable de tiempo de ejecución regular declarada con `let`. Esto requeriría que el
evaluador se ejecutara y evaluara la cadena, pero desafortunadamente Nushell necesita esta información en tiempo de compilación.

Sin embargo, si `my_path` es una constante, entonces esto
funcionaría, ya que la cadena se puede evaluar en tiempo de compilación:

```nu
# skip-docker-exec (ejemplo ilustrativo de ruta constante)
const my_path = ([$nu.home-dir nushell] | path join)
source $"($my_path)/common.nu" # sources /home/user/nushell/common.nu
```

Nushell está diseñado para usar un solo paso de compilación para todo el código fuente, y esto es independiente de la evaluación. Esto permitirá un fuerte soporte IDE, mensajes de error precisos, un lenguaje más fácil de usar para herramientas de terceros y, en el futuro, incluso una salida más sofisticada, como la posibilidad de compilar Nushell directamente a un archivo binario.

### Declaración y Ciclo de Vida de Variables: let, mut y const {#declaracion-y-ciclo-de-vida-de-variables-let-mut-y-const}

La asignación y vinculación de valores en Nushell se articula en torno a tres palabras clave fundamentales: `let`, `mut` y `const`. Cada una de ellas define un comportamiento específico en relación con el instante de evaluación (tiempo de compilación frente a tiempo de ejecución), las garantías de inmutabilidad en memoria y la capacidad de captura dentro de cierres (*closures*).

#### Reglas de Nomenclatura y Referencia

Una vez declarada una variable, nos referimos a ella anteponiendo el símbolo `$` a su identificador (por ejemplo, `$total`). 

Nushell establece ciertas restricciones sobre los caracteres admisibles en los nombres de variables para prevenir ambigüedades con los operadores de la sintaxis. En particular, los nombres de variables no pueden contener los siguientes caracteres:

```text
.  [  (  {  +  -  *  ^  /  =  !  <  >  &  |
```

Asimismo, en las sentencias de declaración se permite anteponer opcionalmente el carácter `$` al nombre de la variable (`let $var = 42`), lo cual resulta funcionalmente equivalente a declararla sin dicho prefijo (`let var = 42`).

#### Inmutabilidad en tiempo de ejecución: let

Fiel a los principios de la programación funcional moderna, Nushell promueve el uso sistemático de la inmutabilidad. Toda variable declarada mediante `let` se evalúa dinámicamente en tiempo de ejecución, permaneciendo estrictamente inalterable durante toda su existencia en el entorno:

```nu
# skip-docker-exec (demostración de inmutabilidad)
let tasa = 0.15
$tasa = 0.20 # Error: nu::shell::assignment_requires_mutable_variable
```

Aunque una variable inmutable no admite reasignación directa mediante el operador `=`, Nushell implementa de manera nativa el **sombreado de variables** (*variable shadowing*). Este mecanismo permite declarar un nuevo enlace con idéntico identificador dentro del mismo alcance o en un bloque anidado, sustituyendo la referencia previa sin comprometer la transparencia referencial ni alterar el valor original en los ámbitos circundantes:

```nu
let conteo = 10
do {
  let conteo = 50
  $conteo # En el bloque interno vale 50
}
$conteo # En el ámbito exterior continúa valiendo 10
# Sombreado explícito en el ámbito exterior: ahora vale 11
let conteo = $conteo + 1
```

Las variables inmutables gestionadas con `let` son seguras ante concurrencia y pueden capturarse sin restricciones dentro de bloques y cierres funcionales tales como `each` o `par-each`.

#### Mutabilidad imperativa controlada: mut

En escenarios computacionales donde un algoritmo demanda acumulación explícita de estado dentro de estructuras iterativas imperativas (como `loop` o `while`), Nushell proporciona la palabra clave `mut`. Una variable mutable autoriza la reasignación mediante operadores de modificación en sitio:

```nu
mut total = 0
$total += 15
$total *= 2
$total # Resultado: 30
```

Nushell admite una serie de operadores de asignación específicos para variables mutables, detallados en la Tabla 2:

| Operador | Descripción Operativa |
| :--- | :--- |
| `=` | Asigna un nuevo valor directamente a la variable mutable. |
| `+=` | Suma un valor a la variable y actualiza su contenido (`$val += 5`). |
| `-=` | Resta un valor a la variable y actualiza su contenido (`$val -= 2`). |
| `*=` | Multiplica la variable por un valor y actualiza su contenido (`$val *= 3`). |
| `/=` | Divide la variable por un valor y actualiza su contenido (`$val /= 2`). |
| `++=` | Concatena una lista o un elemento adicional a una lista existente. |

Table: Operadores de asignación para variables mutables en Nushell.

Los operadores aritméticos compuestos (`+=`, `-=`, `*=`, `/=`) solo son válidos sobre tipos de datos que admiten la operación matemática subyacente. Por su parte, el operador `++=` requiere expresamente que la variable de destino o el operando proporcionado sea una lista.

Sin embargo, la mutabilidad impone una restricción de diseño fundamental: **los cierres (*closures*) y las funciones anidadas no pueden capturar variables mutables**. La siguiente instrucción desencadenará un error sintáctico inmediato:

```nu
# skip-docker-exec (demostración de restricción en cierres)
mut contador = 0
[1 2 3] | each { $contador += 1 } # Error: nu::shell::capture_of_mutable_var
```

Esta directriz garantiza la robustez del sistema: los comandos integrados en pipelines procesan datos mediante flujos continuos (*streaming*) y con frecuencia se ejecutan de manera concurrente o paralela (mediante primitivas como `par-each`). Permitir la captura y mutación concurrente de variables externas introduciría condiciones de carrera (*race conditions*) y comprometería el determinismo del motor.

#### Constantes de tiempo de análisis: const

La arquitectura interna de Nushell opera bajo una estricta separación en dos fases:

1. **Fase de análisis sintáctico y compilación estática (*parse-time*):** El analizador de Nushell procesa el texto completo del script o bloque de instrucciones antes de que se ejecute la primera línea. En esta fase se verifica la validez gramatical, se determinan las firmas de los comandos, se resuelven las palabras clave y se cargan los módulos externos (`source`, `use`).
2. **Fase de evaluación y ejecución dinámica (*runtime*):** Es la etapa en la que los datos fluyen a través de las tuberías (*pipelines*), se evalúan las expresiones, se escribe en el disco (`save`), se invocan procesos externos y se computan los resultados en memoria.

Comprender la frontera entre ambas etapas es esencial en Nushell. Consideremos, por ejemplo, la siguiente secuencia de instrucciones:

```nu
# skip-docker-exec (demostración de la separación parse-time vs runtime)
"def abc [] { 1 + 2 }" | save -f output.nu
source "output.nu"
abc
```

Si se ejecutan estas instrucciones **línea por línea** de manera interactiva en la terminal (REPL), el procedimiento funciona correctamente: la primera línea se compila (*parse-time*) y se ejecuta (*runtime*), creando el archivo `output.nu` en disco; al ingresar la segunda línea, `output.nu` ya existe físicamente, por lo que el analizador puede leerlo estáticamente en su propia fase de análisis e incorporar el comando `abc` al entorno.

Sin embargo, si se intenta **ejecutar todo el bloque en una sola llamada** (o dentro de un script `.nu`), el proceso falla inmediatamente con el error `nu::parser::sourced_file_not_found`:

```text
Error: nu::parser::sourced_file_not_found
  × File not found: output.nu
  help: sourced files need to be available before your script is run
```

El motivo radica en que `source` es una directiva de tiempo de análisis (*parse-time*). Cuando Nushell analiza el bloque completo, necesita inspeccionar el contenido de `output.nu` para compilar la llamada a `abc` en la tercera línea; pero en ese instante la primera línea (`save -f output.nu`) aún no ha comenzado a evaluarse dinámicamente en *runtime*, por lo que el archivo todavía no existe en el sistema de archivos.

Para resolver requerimientos estructurales donde el compilador necesita conocer valores de antemano (como rutas de módulos fijos o valores por defecto en firmas de comandos) se diseñó `const`. Una constante declarada con `const` se resuelve de forma determinista y estática durante la fase de análisis (*parse-time*). En consecuencia, solo puede asociarse a valores literales o expresiones puras que el compilador logre computar íntegramente de manera anticipada:

```nu
# skip-docker-exec (definición de constante en tiempo de compilación)
const ruta_modulos = ([$nu.home-dir mis_scripts] | path join)
use $"($ruta_modulos)/utilidades.nu" *
```

Si intentásemos suministrar una variable declarada con `let` al comando `use` del ejemplo previo, la compilación fallaría de inmediato, dado que el contenido de una vinculación `let` aún no existe en memoria durante el análisis gramatical del script.

La Tabla 3 sintetiza las diferencias operativas y técnicas entre las tres modalidades de vinculación:

| Criterio | `let` (Inmutable) | `mut` (Mutable) | `const` (Constante de compilación) |
| :--- | :--- | :--- | :--- |
| **Fase de evaluación** | Tiempo de ejecución (*runtime*) | Tiempo de ejecución (*runtime*) | Tiempo de análisis (*parse-time*) |
| **Reasignación directa (`=`)** | No permitida | Permitida (`$var = ...`, `+=`) | No permitida |
| **Sombreado (*Shadowing*)** | Sí (`let x = $x + 1`) | No (se emplea asignación) | Sí (en nuevos ámbitos) |
| **Captura en cierres (*Closures*)** | Sí (segura en streaming y paralelo) | No (rechazada por el compilador) | Sí |
| **Válida en `source` / `use`** | No (desconocida al compilar) | No | Sí (resuelta estáticamente) |
| **Uso canónico en Nushell** | Por defecto en el 90%+ del código | Bucles clásicos (`while`, `loop`) | Rutas de módulos, plugins, esquemas fijos |

Table: Comparativa de vinculación de variables en Nushell: `let`, `mut` y `const`.

#### Paradigma Funcional frente a Mutabilidad Imperativa

En el desarrollo idiomático con Nushell, la recomendación fundamental consiste en preferir variables inmutables para la gran mayoría de las tareas analíticas. Las soluciones funcionales basadas en transformaciones de pipelines ofrecen tres ventajas determinantes:

1. **Mayor rendimiento:** Evitan la continua realocación de estructuras intermedias en memoria.
2. **Soporte nativo de streaming:** La siguiente etapa del pipeline comienza a procesar datos en cuanto se emite el primer registro, sin esperar a que el bucle complete la totalidad de las iteraciones.
3. **Escalabilidad concurrente:** Habilitan la paralelización automática de tareas mediante primitivas como `par-each`.

En la práctica, los patrones clásicos que en otros lenguajes demandan acumulación mutable se resuelven en Nushell mediante comandos declarativos de alto nivel:

- **Contadores de iteración:** En lugar de incrementar manualmente un contador mutable, se utiliza `enumerate` en combinación con `each`:
  ```nu
  ls |
    enumerate |
    each { |elt|
      $"Elemento #($elt.index) mide ($elt.item.size)"
    }
  ```

- **Reducción y agregación de valores:** Para acumular un resultado a través de una lista (por ejemplo, localizar la cadena de mayor longitud), se emplea `reduce`:
  ```nu
  [uno dos tres cuatro cinco seis] | reduce { |actual, maximo|
    if ($actual | str length) > ($maximo | str length) {
      $actual
    } else {
      $maximo
    }
  }
  ```

- **Generación dinámica de flujos continuos:** Para consumir datos de fuentes externas o secuencias que se producen bajo demanda, se emplea `generate`:
  ```nu
  # skip-docker-exec (generación funcional de secuencias)
  generate { |contador|
    if $contador < 5 {
      { out: ($contador * 10), next: ($contador + 1) }
    }
  } 0
  ```

##### Consideraciones de Rendimiento

El empleo de filtros de pipeline con variables inmutables es con frecuencia órdenes de magnitud más rápido que la mutación secuencial asistida por sentencias tradicionales como `for` y `while`. Cuando acumulamos valores en una lista mutable dentro de un bucle `for`, cada invocación a `append` genera una nueva lista intermedia, introduciendo una penalización de rendimiento acumulativa:

- **Enfoque imperativo con bucle `for` y variable mutable:**
  ```nu
  timeit {
    mut randoms = []
    for _ in 1..500 {
      $randoms = ($randoms | append (random int))
    }
  }
  ```
  *Tiempo medido aproximado: ~1 minuto y 4 segundos para 50,000 inserciones.*

- **Enfoque idiomático funcional con `each`:**
  ```nu
  timeit {
    let randoms = 1..500 | each { random int }
  }
  ```
  *Tiempo medido aproximado: ~19 milisegundos para 5,000 elementos, y poco más de 4 segundos para 50,000 iteraciones.*

Además de la drástica reducción temporal, `each` transmite sus salidas inmediatamente por el pipeline, permitiendo que las etapas posteriores procesen la información de forma continua e integrada.


## Moviéndose por el Sistema

Una característica definitoria de un shell es la capacidad de navegar e interactuar con el sistema de archivos. Nushell es, por supuesto, ninguna excepción. A continuación se presentan los comandos fundamentales para la interacción con el sistema de archivos:

### Viendo el Contenido de un Directorio

```nu
cd /data/ch03
ls
```

Como se indicó anteriormente, el comando `ls` devuelve el contenido de un directorio en forma de tabla estructurada.

El comando `ls` también admite un argumento posicional opcional para acotar los elementos visualizados. Por ejemplo, se pueden listar los archivos con extensión `.csv`:

```nu
cd /data/ch03
ls *.csv
```

### Patrones Glob (comodines)

Al asterisco (`*`) en el argumento opcional anterior `*.csv` se le denomina habitualmente comodín o *glob*. Permite establecer concordancias de patrones sobre rutas del sistema. El patrón `*.csv` se interpreta como: *«coincidir con cualquier nombre de archivo cuyo sufijo sea .csv»*.

El comodín más general es `*`, que concuerda con cualquier secuencia de caracteres en el directorio activo. Con frecuencia, este patrón se combina con prefijos o extensiones, como `*.bak` o `temp*`.

Nushell también soporta el comodín doble `**`, que desciende recursivamente por subdirectorios anidados. Por ejemplo, `ls **/*` enumera recursivamente todas las rutas no ocultas a partir del directorio de trabajo:

```nu
cd /data
ls **/*.csv
```

Aquí se busca cualquier archivo con extensión `.csv` en cualquier nivel de profundidad a partir del directorio `/data`.

La sintaxis globbing de Nushell no solo admite `*`, sino también la coincidencia de caracteres individuales con `?` y grupos de caracteres con `[...]`.

Escapar los patrones `*`, `?` y `[]` funciona delimitándolos entre comillas simples, comillas dobles o
"cadena raw". Por ejemplo, para mostrar el contenido de un directorio llamado `[slug]`, se utiliza use `ls "[slug]"` o `ls '[slug]'`.

Sin embargo, las cadenas delimitados con _comillas inversas_ (o backtips) no escapan los glob. Por ejemplo, compare los siguientes escenarios:

1. Sin comillas: Patrón glob

    Una _cadena de palabra simple_ sin comillas con caracteres glob se interpreta como un patrón glob, por lo que lo siguiente eliminará todos los archivos en el directorio actual que contengan
    `myfile` como cualquier parte del nombre del archivo:

    ```nu
    rm *myfile*
    ```

2. Entre comillas: Literal de cadena con asteriscos

    Cuando se cita con comillas simples o dobles, o se usa una _cadena raw_, se pasa al comando una _cadena_ con los asteriscos literales escapados (u otros caracteres glob). El resultado no es un glob. El siguiente comando solo eliminará un archivo llamado literalmente `*myfile*` (incluidos los asteriscos). Otros archivos con `myfile` en el nombre no se ven afectados:

    ```nu
    rm "*myfile*"
    ```

3. Entre comillas invertidas: Patrón glob

    Los asteriscos (y otros patrones glob) dentro de una _cadena entre comillas invertidas_ se interpretan como un patrón glob. Observe que este es el mismo comportamiento que el del ejemplo de cadena de palabra simple en el n.° 1 anterior.

    Lo siguiente, como en el primer ejemplo, elimina todos los archivos en el directorio actual que contienen `myfile` como parte del nombre del archivo

    ```nu
    rm `*myfile*`
    ```

> Nushell también incluye un comando `glob` dedicado con soporte para escenarios globbing más complejos.

#### Conversión de Cadenas a Globs

Las técnicas de comillas mencionadas anteriormente son útiles al construir globos literales, pero es posible que se deban construir globs mediante programación. Hay varias técnicas disponibles para este propósito:

1. `into glob`

    El comando `into glob` se puede usar para convertir una cadena (y otros tipos) en un glob. Por ejemplo:

    ```nu
    # Encuentra archivos cuyo nombre incluya el mes actual en el formato YYYY-mm
    let current_month = date now | format date '%Y-%m'
    let glob_pattern = $"*($current_month)*" | into glob
    ls $glob_pattern
    ```

2. El operador de propagación (_spread operator_) combinado con el comando `glob`:

    El comando `glob` (nota: no es lo mismo que `into glob`) produce una `list` de nombres de archivo que coinciden con el patrón de globo. Esta lista se puede expandir y pasar a los comandos del sistema de archivos utilizando el operador de propagación `...`:

    ```nu
    # Encuentra archivos cuyo nombre incluya el mes actual en el formato YYYY-mm
    let current_month = date now | format date '%Y-%m'
    ls ...(glob $"*($current_month)*")
    ```

3. Forzar el tipo `glob` mediante anotación:

    ```nu
    # Encuentra archivos cuyo nombre incluya el mes actual en el formato YYYY-mm
    let current_month = date now | format date '%Y-%m'
    let glob_pattern: glob = $"*($current_month)*"
    ls $glob_pattern
    ```


## Trabajando con strings

Como con la mayoría de los lenguajes, los strings son una colección de 0 o más caracteres que representan texto. Esto puede incluir nombres de archivos, rutas de archivos, nombres de columnas, y mucho más. Las strings son tan comunes que Nushell ofrece múltiples formatos de string para que coincidan con cada caso de uso.

### Formatos de String

| Formato de string                                           | Ejemplo                 | Escapes                             | Notas                                                                                     |
| ----------------------------------------------------------- | ----------------------- | ----------------------------------- | ----------------------------------------------------------------------------------------- |
| [String con comillas simples](#single-quoted-strings)       | `'[^\n]+'`              | Ninguno                             | No puede contener comillas simples dentro del string                                      |
| [String con comillas dobles](#double-quoted-strings)        | `"The\nEnd"`            | Escapes de barra invertida estilo C | Todas las barras invertidas literales deben tener escape                                  |
| [Strings raw](#raw-strings)                                 | `r#'Raw string'#`       | Ninguno                             | Puede incluir comillas simples                                                            |
| [String de palabra simple](#bare-word-strings)              | `ozymandias`            | Ninguno                             | Solo puede contener caracteres de "palabra"; No se puede usar en la posición de comando   |
| [String con comillas invertidas](#backtick-quoted-strings)  | <code>\`[^\n]+\`</code> | Ninguno                             | String simple que puede incluir espacios en blanco. No puede contener comillas invertidas |
| [Interpolación con comillas simples](#string-interpolation) | `$'Captain ($name)'`    | Ninguno                             | No puede contener ningún `'` o `()` no coincidentes                                       |
| [Interpolación con comillas dobles](#string-interpolation)  | `$"Captain ($name)"`    | Escapes de barra invertida estilo C | Todas las barras invertidas literales y `()` deben tener escape                           |

### Strings con Comillas Simples {#single-quoted-strings}

El string más simple en Nushell es el string con comillas simples. Este string usa el carácter `'` para rodear algún texto. Por ejemplo:

```nu
'hello world'

'The
end'
```

Los strings con comillas simples no le hacen nada al texto que se les da, lo que las hace ideales para contener una amplia gama de datos de texto.

### Strings con Comillas Dobles {#double-quoted-strings}

Para strings más complejas, Nushell también ofrece strings con comillas dobles. Estas strings usan el carácter `"` para rodear el texto. También admiten la capacidad de escapar caracteres dentro del texto usando el carácter `\`.

Por ejemplo, se podría escribir un texto seguido de una nueva línea y luego otro texto, usando caracteres de escape y un string con comillas dobles:

```nu
"hello\nworld"
```

Los caracteres de escape permiten agregar rápidamente un carácter que de otro modo sería difícil de escribir.

Nushell actualmente admite los siguientes caracteres de escape:

- `\"` - carácter de comillas dobles
- `\'` - carácter de comillas simples
- `\\` - barra invertida
- `\/` - barra diagonal
- `\b` - retroceso
- `\f` - avance de formulario
- `\r` - retorno de carro
- `\n` - nueva línea (avance de línea)
- `\t` - tabulación
- `\u{X...}` - un solo carácter unicode, donde X... son 1-6 dígitos hexadecimales (0-9, A-F)

### Strings Raw {#raw-strings}

Los strings raw se comportan igual que las strings con comillas simples, excepto que las strings raw también pueden contener comillas simples. Esto es posible porque las strings raw están encerradas por un `r#'` inicial y un `'#` final.

```nu
r#'Raw strings can contain 'quoted' text.'#
```

Se pueden agregar símbolos `#` adicionales al principio y al final del string raw para encerrar
uno menos que la misma cantidad de símbolos `#` junto a un símbolo `'` en el string. Esto se puede usar para anidar strings raw:

```nu
r###'r##'This is an example of a raw string.'##'###
```

### Strings de Palabra Simple {#bare-word-strings}

Al igual que otros lenguajes de shell (pero a diferencia de la mayoría de los otros lenguajes de programación), las strings que constan de una sola 'palabra' también se pueden escribir sin comillas:

```nu
print hello
print "hello"

[hello] | describe
```

Pero se debe tener cuidado: si usa una palabra simple directamente en la línea de comandos (es decir, no dentro de una estructura de datos o como un parámetro de comando) o dentro de paréntesis redondos `(` `)`, se interpretará como un comando externo:

```nu
hello
Error: nu::shell::external_command

  × External command failed
   ╭─[entry #5:1:1]
 1 │ hello
   · ──┬──
   ·   ╰── executable was not found
   ╰────
  help: program not found
```

Además, muchas palabras simples tienen un significado especial en nu, por lo que no se interpretarán como una string:

```nu
true | describe

[true] | describe

[trueX] | describe

"trueX" | describe
```

Entonces, si bien los strings simples son útiles para el uso informal de la línea de comandos, al programar más formalmente en nu, se recomienda usar comillas.

### Strings con Comillas Invertidas {#backtick-quoted-strings}

Las strings de palabras simples, por su naturaleza, no pueden incluir espacios ni comillas. Como alternativa, Nushell también incluye strings con comillas invertidas
usando el carácter <code>`</code>. En la mayoría de los casos, estos deberían funcionar igual que una string de palabra simple.

Por ejemplo, al igual que con una palabra simple, una string entre comillas invertidas en la primera posición de una expresión se interpretará como un _comando_ o _ruta_.
Por ejemplo:

```nu
# skip-docker-exec
# Ejecutar el binario ls externo o cambiar de directorio interactivamente
^ls
```

Las strings con comillas invertidas pueden ser útiles para combinar globs con archivos o directorios que incluyen espacios:

```nu
# skip-docker-exec
ls `./my dir/*`
```

### Strings como comandos externos

Puede colocar el signo `^` delante de cualquier string (incluida una variable) para que Nushell ejecute la string como si fuera un comando externo:

```nu
^ls

^'ls'

let foo = 'ls'
^$foo
```

También se puede usar el comando `run-external` para este propósito, que proporciona indicadores y opciones adicionales.

### Añadir y anteponer a strings

Hay varias formas de anteponer o añadir strings. Si se desea agregar algo al principio de cada string, se puede iterar:

```nu
['foo', 'bar'] | each {|s| '~/' ++ $s} # ~/foo, ~/bar
['foo', 'bar'] | each {|s| '~/' + $s} # ~/foo, ~/bar
```

También puede usar una expresión regular para reemplazar el principio o el final de una string:

```nu
['foo', 'bar'] | str replace -r '^' '~/' # ~/foo, ~/bar
['foo', 'bar'] | str replace -r '$' '~/' # foo~/, bar~/
```

Si se desea obtener un string a partir de una lista:

```nu
"hello" | append "world!" | str join " "

ls | get name | str join "/"
```

También se puede usar reduce:

```nu
1..10 | reduce -f "" {|elt, acc| $acc + ($elt | into string) + " + "}
```

Aunque en el caso de los strings, especialmente si no se tiene que operar en las strings, suele ser más fácil y correcto (observe el + adicional al final del ejemplo anterior) usar `str join`.

Finalmente, también se puede usar la interpolación de strings.

### Interpolación de strings {#string-interpolation}

Los casos de uso de strings más complejos también necesitan una nueva forma de string: interpolación de strings. Esta es una forma de construir texto a partir de texto sin formato y el resultado de ejecutar expresiones. La interpolación de strings combina los resultados, dándo una nueva string.

La interpolación de strings usa `$" "` y `$' '` como formas de encapsular texto interpolado.

Por ejemplo, si se tiene una variable llamada `$name` y queremos saludar al nombre de la persona contenida en esta variable:

```nu
let name = "Alice"

$"greetings, ($name)"

$"greetings, (ls | get name.2)"
```

Al encapsular expresiones en `()`, podemos ejecutarlas hasta su finalización y usar los resultados para ayudar a construir el string.

La interpolación de strings tiene una forma con comillas simples, `$' '`, y una con comillas dobles, `$" "`. Éstas corresponden a las strings con comillas simples y comillas dobles: la interpolación de strings con comillas simples no admite caracteres de escape, mientras que la interpolación de strings con comillas dobles sí.

A partir de la versión 0.61, las strings interpoladas admiten el escape de paréntesis, de modo que los caracteres `(` y `)` se pueden usar en una string sin que Nushell intente evaluar lo que aparece entre ellos:

```nu
$"2 + 2 is (2 + 2) \(adivinaste!)"
```

Los strings interpolados se pueden evaluar en tiempo de análisis, pero si incluyen valores cuyo formato depende de su configuración y su `config.nu` aún no se ha cargado, utilizarán la configuración predeterminada.
Entonces, si se tiene algo como esto en su `config.nu`, `x` será `"2.0 KB"` incluso si su configuración dice que use `MB` para todos los tamaños de archivo (las fechas y horas utilizarán de manera similar la configuración predeterminada).

```nu
const x = $"(2kb)"
```

### Dividir Strings

El comando `split row` crea una lista a partir de una string basándose en un delimitador.

```nu
"red,green,blue" | split row ","
```

El comando `split column` creará una tabla a partir de una string basándose en un delimitador. Esto aplica nombres de columna genéricos a la tabla.

```nu
"red,green,blue" | split column ","
```

Finalmente, el comando `split chars` dividirá una string en una lista de caracteres.

```nu
'aeiou' | split chars
```

### El comando `str`

Muchas funciones de string son subcomandos del comando `str`. Puede obtener una lista completa usando `help str`.

Por ejemplo, puede buscar si una string contiene una subcadena (_substring_) en particular usando `str contains`:

```nu
"hello world" | str contains "o wo"
```

También se puede utilizar el operador `=~`.

#### Recortar Strings

Se puede recortar los lados de una string con el comando `str trim`. De forma predeterminada, el comando `str trim` recorta los espacios en blanco de ambos lados de la string. Por ejemplo:

```nu
'       My   string   ' | str trim
```

Se puede especificar en qué lado se produce el recorte con las opciones `--right` y `--left`. (`-r` y `-l` son las opciones abreviadas respectivamente)

Para recortar un carácter específico, se utiliza `--char <Carácter>` o `-c <Carácter>` para especificar el carácter a recortar.

Ejemplo:

```nu
'=== Nu shell ===' | str trim -r -c '='
```

#### Substrings

Los substrings son porciones de una string. Tienen un punto de inicio y un punto final

```nu
'Hello World!' | str index-of 'o'

'Hello World!' | str index-of 'r'

'Hello World!' | str substring 4..8
```

#### Relleno de Strings

Con el comando `fill` puede agregar relleno a una string. El relleno agrega caracteres a la string hasta que tenga una cierta longitud. Por ejemplo:

```nu
'1234' | fill -a right -c '0' -w 10

'1234' | fill -a left -c '0' -w 10
```

#### Invertir Strings

Esto se puede hacer fácilmente con el comando `str reverse`.

```nu
'Nushell' | str reverse

['Nushell' 'is' 'cool'] | str reverse
```

#### Análisis de Strings

Con el comando `parse` se puede analizar una string en columnas. Por ejemplo:

```nu
'Nushell 0.80' | parse '{shell} {version}'

'where all data is structured!' | parse --regex '(?P<subject>\w*\s?\w+) is (?P<adjective>\w+)'
```

Si se sabe que un string contiene datos separados por comas, separados por tabulaciones o separados por varios espacios, puede usar `from csv`, `from tsv` o `from ssv`, respectivamente:

```nu
"acronym,long\nAPL,A Programming Language" | from csv

"name  duration\nonestop.mid  4:06" | from ssv

"rank\tsuit\nJack\tSpades\nAce\tClubs" | from tsv
```

### Comparación de Strings

Además de los operadores estándar `==` y `!=`, existen algunos operadores para comparar específicamente strings entre sí.

Para expresiones regulares:

```nu
'APL' =~ '^\w{0,3}$'
'FORTRAN' !~ '^\w{0,3}$'
```

Existen otros dos operadores para comparaciones más sencillas:

```nu
'JavaScript' starts-with 'Java'

'OCaml' ends-with 'Caml'
```

### Convertir Strings

Hay varias formas de convertir strings a otros tipos y viceversa.

#### A string

1. Usando `into string`. Ej: `123 | into string`
2. Usando interpolación de strings. Ej: `$'(123)'`

#### De string

1. Usando `into <tipo>`. Ej: `'123' | into int`

### Colorear Strings

Se pueden colorear strings con el comando `ansi`. Por ejemplo:

```nu
$'(ansi purple_bold)This text is a bold purple!(ansi reset)'
```

`ansi purple_bold` hace que el texto sea de color púrpura intenso
`ansi reset` restablece el color al predeterminado. (Consejo: Siempre debe terminar las strings coloreadas con `ansi reset`)


## Trabajando con listas

Las listas son equivalentes a las columnas individuales de las tablas. Una lista es esencialmente una "tabla de una columna" (sin nombre de columna). Por lo tanto, cualquier comando que opere en una columna _también_ opera en una lista. Por ejemplo, `where` se puede usar con listas:

```nu
[bell book candle] | where ($it =~ 'b')
```

### Creando listas

Una lista es una colección ordenada de valores.
Una lista se crea usando corchetes que rodean los valores separados por espacios, saltos de línea y/o comas.
Por ejemplo, `[foo bar baz]` o `[foo, bar, baz]`.

> Las listas de Nushell son similares a las matrices JSON. El mismo `[ "Item1", "Item2", "Item3" ]` que representa una matriz JSON también se puede usar para crear una lista de Nushell.

### Actualizando listas

Se usa `insert` para insertar valores en las listas a medida que fluyen a través de la _pipeline_, por ejemplo, insertamos el valor `10` en el medio de una lista:

```nu
[1, 2, 3, 4] | insert 2 10
```

También se puede usar `update` para reemplazar el segundo elemento con el valor `10`.

```nu
[1, 2, 3, 4] | update 1 10
```

### Eliminando o Agregando Elementos de la Lista

Además de `insert` y `update`, también se tiene `prepend` y `append`. Estos permiten insertar al principio de una lista o al final de la lista, respectivamente.

Por ejemplo:

```nu
let colors = [yellow green]
let colors = $colors | prepend red
let colors = $colors | append purple
let colors = $colors ++ ["blue"]
let colors = ["black"] ++ $colors
$colors # [black red yellow green purple blue]
```

En caso de que se requiera eliminar elementos de la lista, hay muchas maneras. `skip` permite omitir las primeras filas de la entrada, mientras que `drop` permite omitir filas numeradas específicas del final de la lista.

```nu
let colors = [red yellow green purple]
let colors = $colors | skip 1
let colors = $colors | drop 2
$colors # [yellow]
```

También está `last` y `first` que permiten tomar valores desde el final o el principio de la lista, respectivamente.

```nu
let colors = [red yellow green purple black magenta]
let colors = $colors | last 3
$colors # [purple black magenta]
```

Y desde el principio de una lista,

```nu
let colors = [yellow green purple]
let colors = $colors | first 2
$colors # [yellow green]
```

#### Usando el Operador de Propagación

Para agregar una o más listas, opcionalmente con valores intercalados, se puede usar el
operador de propagación (`...`)

```nu
let x = [1 2]

[
   ...$x
   3
   ...(4..7 | take 2)
]
```

### Iterando sobre Listas

Para iterar sobre los elementos de una lista, se utiliza el comando `each` con un bloque
de código Nu que especifica qué hacer con cada elemento. El parámetro de bloque (por ejemplo, `|elt|` en `{ |elt| print $elt }`) es el elemento de lista actual, pero el filtro [`enumerate`](/commands/docs/enumerate.md) se puede usar para proporcionar valores de `index` y `item` si es necesario. Por ejemplo:

```nu
let names = [Mark Tami Amanda Jeremy]

$names | each { |elt| $"Hello, ($elt)!" }

$names | enumerate | each { |elt| $"($elt.index + 1) - ($elt.item)" }
```

El comando `where` se puede usar para crear un subconjunto de una lista, filtrando eficazmente la lista según una condición.

El siguiente ejemplo obtiene todos los colores cuyos nombres terminan en "e".

```nu
let colors = [red orange yellow green blue purple]
$colors | where ($it | str ends-with 'e')
# El bloque pasado a `where` debe evaluarse como un booleano.
# Esto imprime la lista [orange blue purple].
```

En este ejemplo, mantenemos solo los valores superiores a `7`.

```nu
let scores = [7 10 8 6 7]
$scores | where $it > 7 # [10 8]
```

El comando `reduce` calcula un solo valor a partir de una lista.
Utiliza un bloque que toma 2 parámetros: el elemento actual (convencionalmente llamado `elt`) y un acumulador
(convencionalmente llamado `acc`). Para especificar un valor inicial para el acumulador, usa la opción `--fold` (`-f`).
Para cambiar `elt` para que tenga valores de `index` y `item`, se usa el filtro [`enumerate`](/commands/docs/enumerate.md).
Por ejemplo:

```nu
let scores = [3 8 4]
$"total = ($scores | reduce { |elt, acc| $acc + $elt })" # total = 15

$"total = ($scores | math sum)" # enfoque más fácil, mismo resultado

$"product = ($scores | reduce --fold 1 { |elt, acc| $acc * $elt })" # product = 96

$scores | enumerate | reduce --fold 0 { |elt, acc| $acc + $elt.index * $elt.item } # 0*3 + 1*8 + 2*4 = 16
```

### Accediendo a la Lista

Para acceder a un elemento de la lista en un índice dado, se usa la forma `$name.index` donde `$name` es una variable que contiene una lista.

Por ejemplo, se puede acceder al segundo elemento de la lista a continuación con `$names.1`.

```nu
let names = [Mark Tami Amanda Jeremy]
$names.1 # da Tami
```

Si el índice está en alguna variable `$index`, podemos usar el comando `get` para extraer el elemento de la lista.

```nu
let names = [Mark Tami Amanda Jeremy]
let index = 1
$names | get $index # da Tami
```

El comando `length` devuelve el número de elementos de una lista.
Por ejemplo, `[red green blue] | length` imprime `3`.

El comando `is-empty` determina si una cadena, lista o tabla está vacía.
Se puede usar con listas de la siguiente manera:

```nu
let colors = [red green blue]
$colors | is-empty # false

let colors = []
$colors | is-empty # true
```

Los operadores `in` y `not-in` se utilizan para probar si un valor está en una lista. Por ejemplo:

```nu
let colors = [red green blue]
'blue' in $colors # true
'yellow' in $colors # false
'gold' not-in $colors # true
```

El comando `any` determina si algún elemento de una lista coincide con una condición dada.
Por ejemplo:

```nu
let colors = [red green blue]
# ¿Algún nombre de color termina con "e"?
$colors | any {|elt| $elt | str ends-with "e" } # true

# ¿La longitud de algún nombre de color es inferior a 3?
$colors | any {|elt| ($elt | str length) < 3 } # false

let scores = [3 8 4]
# ¿Alguna puntuación es superior a 7?
$scores | any {|elt| $elt > 7 } # true

# ¿Alguna puntuación es impar?
$scores | any {|elt| $elt mod 2 == 1 } # true
```

El comando `all` determina si todos los elementos de una lista coinciden con una condición dada.
Por ejemplo:

```nu
let colors = [red green blue]
# ¿Todos los nombres de color terminan con "e"?
$colors | all {|elt| $elt | str ends-with "e" } # false

# ¿La longitud de todos los nombres de color es mayor o igual a 3?
$colors | all {|elt| ($elt | str length) >= 3 } # true

let scores = [3 8 4]
# ¿Todas las puntuaciones son superiores a 7?
$scores | all {|elt| $elt > 7 } # false

# ¿Todas las puntuaciones son pares?
$scores | all {|elt| $elt mod 2 == 0 } # false
```

### Convirtiendo la Lista

El comando `flatten` crea una nueva lista a partir de una lista existente agregando elementos de listas anidadas a la lista de nivel superior. Esto se puede llamar varias veces para aplanar listas anidadas a cualquier profundidad.
Por ejemplo:

```nu
[1 [2 3] 4 [5 6]]
[1 [2 3] 4 [5 6]] | table -e
[1 [2 3] 4 [5 6]] | flatten # [1 2 3 4 5 6]

[[1 2] [3 [4 5 [6 7 8]]]]
[[1 2] [3 [4 5 [6 7 8]]]] | table -e
[[1 2] [3 [4 5 [6 7 8]]]] | flatten

[[1 2] [3 [4 5 [6 7 8]]]] | flatten | flatten | flatten # [1 2 3 4 5 6 7 8]
```

El comando `wrap` convierte una lista en una tabla. Cada valor de la lista se convertirá en una fila separada con una sola columna:

```nu
let zones = [UTC CET Europe/Moscow Asia/Yekaterinburg]

# Mostrar el reloj mundial para las zonas horarias seleccionadas
$zones |
  wrap 'Zone' |
  upsert Time {|row|
    (date now | date to-timezone $row.Zone | format date '%Y.%m.%d %H:%M')
  }
```


## Trabajando con Registros (records)

Los registros son aproximadamente equivalentes a las filas individuales de una tabla. Esencialmente son una "tabla de una fila". Por lo tanto, la mayoría de los comandos que operan en una fila de tabla _también_ operan en un registro. Por ejemplo, `update` se puede usar con registros:

```nu
let my_record = {
   name: "Sam"
   age: 30
   }
$my_record | update age { $in + 1 }
```

### Creando registros

Un registro es una colección de cero o más asignaciones de pares clave-valor. Es similar a un objeto JSON y se puede crear utilizando la misma sintaxis:

```nu
# Nushell
{ "apples": 543, "bananas": 411, "oranges": 0 }
╭─────────┬─────╮
│ apples  │ 543 │
│ bananas │ 411 │
│ oranges │ 0   │
╰─────────┴─────╯
# JSON
'{ "apples": 543, "bananas": 411, "oranges": 0 }' | from json
```

En Nushell, los pares clave-valor de un registro también se pueden separar utilizando espacios o saltos de línea.

Como los registros pueden tener muchos campos, de forma predeterminada, se muestran verticalmente en lugar de de izquierda a derecha. Para mostrar un registro de izquierda a derecha, de debe convertir a un "nuon". Por ejemplo:

```nu
{
   name: "Sam"
   rank: 10
} | to nuon
```

### Actualizando Registros

Al igual que con las listas, se pueden insertar valores en los registros. Por ejemplo:

```nu
{ "apples": 543, "bananas": 411, "oranges": 0 } | insert pears { 21 }
```

También se pueden actualizar valores:

```nu
{ "apples": 543, "bananas": 411, "oranges": 0 } | update oranges { 100 }
```

Para hacer una copia de un registro con nuevos campos, se puede:

- Usar el comando `merge`:

```nu
let first_record = { name: "Sam", rank: 10 }
$first_record | merge { title: "Mayor" }
```

- Usar el operador de propagación (`...`) para expandir el primer registro dentro de un nuevo registro:

```nu
let first_record = { name: "Sam", rank: 10 }
{
   ...$first_record
   title: "Mayor"
 }
```

### Iterando sobre un Registro

Se puede iterar sobre los pares clave-valor de un registro transponiéndolo primero a una tabla:

```nu
{ "apples": 543, "bananas": 411, "oranges": 0 } |
  transpose fruit count |
  each {|f| $"We have ($f.count) ($f.fruit)" }
```

<!--AQUI-->


## Trabajando con tablas

Una de las maneras comunes de ver datos en Nu es a través de una tabla. Nu viene con una serie de comandos para trabajar con tablas para que sea conveniente encontrar lo que se está buscando, y para reducir los datos a solo lo que se necesita.

Para comenzar, obtenemos una tabla que podamos usar:

```nu
ls
```

### Ordenando los Datos

Se puede ordenar una tabla llamando al comando `sort-by` y estableciendo qué columnas utilizar para ordenar. Si se quisiese ordenar la tabla anterior por el tamaño del archivo:

```nu
ls | sort-by size
```

Se puede ordenar una tabla por cualquier columna que se pueda comparar. Por ejemplo, se podría también haber ordenado la anterior usando las columnas "name", "accessed", o "modified".

### Seleccionando Datos

Se puede seleccionar datos de una tabla eligiendo seleccionar columnas específicas o filas específicas, con el comando `select`:

```nu
ls | select name size
```

Esto ayuda a crear una tabla que está más enfocada en lo que se necesitan. Si solo quisiéramos ver los 5 archivos más pequeños en este directorio, ejecutamos:

```nu
ls | sort-by size | first 5
```

Notar que primero se ordenam la tabla por tamaño para llegar al archivo más pequeño, y luego se utiliza `first 5` para devolver las primeras 5 filas de la tabla.

También se pueden saltar filas que no se necesitan:

```nu
ls | sort-by size | first 5 | skip 2
```

También se pueden seleccionar filas directamente:

```nu
ls | sort-by name | select 5
```

### Obteniendo Datos de una Tabla

Hasta ahora, se ha trabajado con tablas recortando la tabla a solo lo que se necesita. A veces, se puede necesitar ir un paso más allá y solo mirar los valores en las celdas en sí mismas en lugar de tomar una columna completa. Por ejemplo, supongamos que queremos obtener solo una lista de los nombres de los archivos:

```nu
ls | get name
```

Esto podría verse como el comando `select` que se vió anteriormente:

```nu
ls | select name
```

Se ven similares, pero hay diferencias:

- `select`: crea una nueva tabla que incluye solo las columnas especificadas.
- `get`: devuelve los valores dentro de la columna especificada como una lista.

### Cambiando Datos en una Tabla

En adición a seleccionar datos de una tabla, también se pueden actualizar lo que la tabla tiene. Se puede necesitar combinar tablas, añadir nuevas columnas, o editar el contenido de una celda. En Nu, en lugar de editar en el lugar, cada uno de los comandos en la sección devolverá una nueva tabla.

#### Concatenando Tablas

Se pueden concatenar tablas usando `append`:

```nu
let first = [[a b]; [1 2]]
let second = [[a b]; [3 4]]

$first
$second

$first | append $second
```

Si los nombres de columna no son idénticos, entonces, adicionalmente, se crearán columnas y valores según sea necesario:

```nu
let first = [[a b]; [1 2]]
let second = [[a b]; [3 4]]
let third = [[a c]; [3 4]]

$first | append $second | append $third
```

También puede usar el operador `++` como un reemplazo en línea para `append`:

```nu
$first ++ $second ++ $third
```

#### Combinando Tablas

Se puede utilizar el comando `merge` para combinar dos (o más) tablas:

```nu
let first = [[a b]; [1 2]]
let second = [[c d]; [3 4]]

$first | merge $second
```

Con una tercera tabla:

```nu
let third = [[e f]; [5 6]]
```

Se pueden unir las tres tablas de esta manera:

```nu
$first | merge $second  | merge $third
```

O se podría usar el comando `reduce` para combinar dinámicamente todas las tablas:

```nu
[$first $second $third] | reduce {|elt, acc| $acc | merge $elt }
```

### Añadiendo una columna

Se puede utilizar el comando `insert` para agregar una nueva columna a la tabla. Por ejemplo:

```nu
{edition: 2024} | save -f edition.json
open edition.json
open edition.json | save -f edition_copia.json
```

Agregamos una columna llamada "next_edition" con el valor 2025:

```nu
open edition.json | insert next_edition 2025
```

Notar que esta visualización puede ser ligeramente confusa, porque parece que lo que se acaba de hacer es añadir una fila. En este caso, se debe recordar que las filas tienen números, las columnas tienen nombres. Si todavía es confuso, se puede añadir una fila mas, lo quehará que la tabla se renderice como se espera:

```nu
open edition.json | insert next_edition 2025 | append {edition: 2021 next_edition: 2023}
```

Notar que si se abre el archivo original, el contenido se ha mantenido igual:

```nu
open edition.json
open edition.json | save -f edition_copia.json
```

Los cambios en Nu son cambios funcionales, lo que significa que trabajan en los valores en sí mismos en lugar de intentar causar un cambio permanente. Esto permite hacer muchos tipos diferentes de trabajo en la _pipeline_ hasta que se está listo para escribir el resultado con los cambios elegidos. Se puede escribir el resultado usando el comando `save`:

```nu
open edition.json |
  insert next_edition 2025 |
  append {edition: 2021 next_edition: 2023} |
  save -f edition2.json

open edition.json
open edition2.json
```

### Actualizando una Columna

De forma similar al comando `insert`, el comando [`update` sirve para cambiar el contenido de una columna a un nuevo valor.

```nu
open edition.json
open edition.json | save -f edition_copia.json
```

Y ahora, actualizamos la edición:

```nu
open edition.json | update edition 2025
```

También se puede utilizar el comando `upsert`para insertar o actualizar dependiendo de si la columna ya existe.

### Moviendo Columnas

Se puede usar `move` para mover columnas en una tabla. Por ejemplo, si se quisiera mover la columna "name" de `ls` después de la columna "size", se puede realizar:

```nu
ls

ls | move name --after size
```

### Renombrando Columnas

También se puede columnas en una tabla pasándola por el comando `rename`:

```nu
ls | rename filename filetype filesize filedate
```

### Rechazando/Eliminando Columnas

También pueden rechazar/eliminar columnas en una tabla pasándola por el comando de `reject`:

```nu
ls -l

ls -l | reject readonly num_links inode created accessed modified
```


## Navegando y Accediendo a Datos Estructurados

Dado el fuerte soporte de Nushell para datos estructurados, algunas de las tareas más comunes involucran navegar y acceder a esos datos.

### Antecedentes

Para los ejemplos y descripciones a continuación, se debe tener en cuenta varias definiciones con respecto a los datos estructurados:

- **_Lista:_** Las listas contienen una serie de cero o más valores de cualquier tipo. Una lista con cero valores se conoce como una "lista vacía".
- **_Registro:_** Los registros contienen cero o más pares de claves con nombre y su valor correspondiente. Los datos en el valor de un registro también pueden ser de cualquier tipo. Un registro con cero pares clave-valor se conoce como un "registro vacío".
- **_Datos Anidados:_** Los valores contenidos en una lista, registro o tabla pueden ser de un tipo básico o datos estructurados en sí mismos. Esto significa que los datos se pueden anidar en múltiples niveles y en múltiples formas:
    - Los valores de la lista pueden contener tablas, registros e incluso otras listas
        - **_Tabla:_** Las tablas son una lista de registros
    - Los valores de registro pueden contener tablas, listas y otros registros
        - Esto significa que los registros de una tabla también pueden contener tablas anidadas, listas y otros registros

> Debido a que una tabla es una lista de registros, cualquier comando o sintaxis que funcione en una lista también funcionará en una tabla. Lo contrario no es necesariamente el caso; hay algunos comandos y sintaxis que funcionan en tablas pero no en listas.

### Rutas de Celda

Una ruta de celda (_cellpath_) es la forma principal de acceder a valores dentro de datos estructurados. Esta ruta se basa en un concepto similar al de una hoja de cálculo, donde las columnas tienen nombres y las filas tienen números. Los nombres e índices de las rutas de celda están separados por puntos.

#### Registros

Para un registro, la ruta de celda especifica el nombre de una clave, que es una `string`.

Por ejemplo, para acceder a un Valor de Registro:

```nu
let my_record = {
    a: 5
    b: 42
  }

$my_record.b + 5
```

#### Listas

Para una lista, la ruta de celda especifica la posición (índice) del valor en la lista. Este es un `int`:

Por ejemplo, para acceder a un Valor de Lista (recordar que los índices de lista comienzan en 0):

```nu
let scoobies_list = [ Velma Fred Daphne Shaggy Scooby ]

$scoobies_list.3

```

#### Tablas

- Para acceder a una columna, una ruta de celda usa el nombre de la columna, que es una `string`
- Para acceder a una fila, usa el número de índice de la fila, que es un `int`
- Para acceder a una sola celda, usa una combinación del nombre de la columna con el índice de la fila.

Los siguientes ejemplos usarán la siguiente tabla:
<!--fix:tabla no cabe dentro del ancho de pagina-->
```nu
let data = [[date                        temps                                   condition ];
            [2022-02-01T14:30:00+05:00,  [ 38.24, 38.50, 37.99, 37.98, 39.10 ],  'summy'   ],
            [2022-02-02T14:30:00+05:00,  [ 35.24, 35.94, 34.91, 35.24, 36.65 ],  'sunny'   ],
            [2022-02-03T14:30:00+05:00,  [ 35.17, 36.67, 34.42, 35.76, 36.52 ],  'cloudy'  ],
            [2022-02-04T14:30:00+05:00,  [ 39.24, 40.94, 39.21, 38.99, 38.80 ],  'rain'    ],
           ]

$data

$data | table -e
```

Esto representa datos meteorológicos en forma de una tabla con tres columnas:

1. **_date_**: Una `date` de Nushell para cada día
2. **_temps_**: Una `list` de Nushell de 5 valores `float` que representan lecturas de temperatura en diferentes estaciones meteorológicas en el área
3. **_condition_**: Una `string` de Nushell para la condición meteorológica de cada día para el área

##### Ejemplo - Acceder a una Fila de la Tabla (Registro)

Acceder a los datos del segundo día como un registro:

```nu
> $data.1
╭───────────┬───────────────╮
│ date      │ 2 years ago   │
│           │ ╭───┬───────╮ │
│ temps     │ │ 0 │ 35.24 │ │
│           │ │ 1 │ 35.94 │ │
│           │ │ 2 │ 34.91 │ │
│           │ │ 3 │ 35.24 │ │
│           │ │ 4 │ 36.65 │ │
│           │ ╰───┴───────╯ │
│ condition │ sunny         │
╰───────────┴───────────────╯
```

##### Ejemplo - Acceder a una Columna de la Tabla (Lista)

```nu
$data.condition
```

##### Ejemplo - Acceder a una Celda de la Tabla (Valor)

La condición para el cuarto día:

```nu
$data.condition.3

$data | get condition | get 3

$data | get condition.3
```

### Datos Anidados

Dado que los datos se pueden anidar, una ruta de celda puede contener referencias a múltiples nombres o índices.

#### Ejemplo - Accediendo a Datos de Tabla Anidados

Para obtener la temperatura en la segunda estación meteorológica el tercer día:

```nu
$data.temps.2.1
```

El primer índice `2` accede al tercer día, luego el siguiente índice `1` accede a la lectura de temperatura de la segunda estación meteorológica.

### Usando `get` y `select`

Además de la sintaxis literal de la ruta de celda utilizada anteriormente, Nushell también proporciona varios comandos que utilizan rutas de celda. Los más importantes de estos son:

- `get` es equivalente a usar una ruta de celda literal pero con soporte para nombres de variables y expresiones. `get`, como los ejemplos de ruta de celda anteriores, devuelve el **valor** indicado por la ruta de celda.
- `select` es sutilmente, pero críticamente, diferente. Devuelve la **estructura de datos** especificada en sí misma, en lugar de solo su valor.
    - Usar `select` en una tabla devolverá una tabla de igual o menor tamaño
    - Usar `select` en una lista devolverá una lista de igual o menor tamaño
    - usar `select` en un registro devolverá un registro de igual o menor tamaño

Continuando con la tabla de muestra anterior:

#### Ejemplo - `get` vs. `select` una fila de la tabla

```nu
$data | get 1
$data | select 1
```

Observe que:

- `get` devuelve el mismo registro que el ejemplo `$data.1` anterior
- `select` devuelve una nueva tabla de una sola fila, incluidos los nombres de las columnas y los índices de las filas

Los índices de fila de la tabla resultante de `select` no son los mismos que los del original. La nueva tabla tiene su propio índice que comienza en 0.

Para obtener el índice original, se puede usar el comando [`enumerate`](/commands/docs/enumerate.md). Por ejemplo:

```nu
$data | enumerate | select 1
```

#### Ejemplo - `select` con múltiples filas y columnas

Debido a que `select` da como resultado una nueva tabla, es posible especificar varios nombres de columna, índices de fila o incluso ambos. Este ejemplo crea una nueva tabla que contiene las columnas de fecha y condición de la primera y segunda filas:

```nu
$data | first 2 | select date condition
```

### Nombres de Clave/Columna con espacios

Si un nombre de clave o un nombre de columna contiene espacios u otros caracteres que impiden que sea accesible como una cadena de palabra simple, entonces el nombre de la clave se puede especificar entre comillas.

Ejemplo:

```nu
let record_example = {
    "key x":12
    "key y":4
  }
$record_example."key x"

# o
$record_example | get "key x"
```

También se requieren comillas cuando un nombre de clave puede confundirse con un valor numérico.

Ejemplo:

```nu
let record_example = {
    "1": foo
    "2": baz
    "3": far
  }

$record_example."1"

```

No se debe confundir el nombre de la clave con un índice de fila en este caso. Aquí, al primer elemento se le _asigna_ el nombre de clave `1` (una cadena). Si se convierte a una tabla usando el comando `transpose`, la clave `1` (`string`) estaría en el índice de fila `0` (un entero).

### Manejo de Datos Faltantes

#### El Operador Opcional

De forma predeterminada, el acceso a la ruta de celda fallará si no puede acceder a la fila o columna solicitada. Para suprimir estos errores, puede agregar un `?` a un miembro de la ruta de celda para marcarlo como opcional:

##### Ejemplo - El Operador Opcional

Usando los datos de temperatura de arriba:

```nu
let cp: cell-path = $.temps?.1

$data | reject temps | get $cp
```

De forma predeterminada, las celdas faltantes se reemplazarán por `null` cuando se acceda a ellas a través del operador opcional.

#### Asignar un `default` para datos faltantes o `null`

El comando `default` se puede usar para aplicar un valor predeterminado al resultado de una columna faltante o nula.

```nu
let missing_value = [{a:1 b:2} {b:1}]
$missing_value

let with_default_value = $missing_value | default 'n/a' a
$with_default_value

$with_default_value.1.a
```

### Otros comandos para acceder a datos estructurados

- `reject` es lo opuesto a `select`, eliminando las filas y columnas especificadas
- `range` especifica las filas de una lista o tabla para seleccionar usando un tipo `range`.



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
ttt mi_script.nu
```

Atajos esenciales y configuración predeterminada de `ttt` dentro de `dsin`:

- **`Alt + Q`:** Salir del editor.
- **`Ctrl + S`:** Guardar el archivo actual.
- **`Ctrl + F`:** Buscar texto dentro del archivo.
- **`Ctrl + Z` / `Ctrl + Y`:** Deshacer / Rehacer cambios.

La configuración incluida en el entorno utiliza el tema `black-rain-blur`, tabulación de 4 espacios con sangría suave, ajuste automático de línea (*word wrap*), numeración de líneas, coloreado de pares de delimitadores (*bracket pair colorization*) y visualización de archivos ocultos en el explorador integrado.

También podemos generar archivos estructurados directamente desde pipelines de Nushell en el directorio actual usando `save -f` y luego ejecutarlos o inspeccionarlos:

```nu
"# Script generado en /data/ch03\ndef saludo [nombre: string] {\n  $\"Hola, ($nombre)!\"\n}\nsaludo 'Ciencia de Datos en Nushell'\n" | save -f ejemplo_ttt.nu
nu ejemplo_ttt.nu
nu ejemplo_ttt.nu | save -f saludo_salida.txt
open saludo_salida.txt
```


## Control de Versiones

Esta sección se introduce en el mundo del control de versiones con Git y cómo plataformas como GitHub y GitLab pueden potenciar el flujo de trabajo en ciencia de datos.

En el desarrollo de cualquier proyecto, especialmente en ciencia de datos, el código fuente evoluciona constantemente. Llevar un control de estos cambios resulta crucial para evitar errores, facilitar la colaboración y garantizar la reproducibilidad de los análisis. Aquí es donde entra en juego el **control de versiones**.

El _control de versiones_ es un sistema que registra los cambios realizados en un archivo o conjunto de archivos a lo largo del tiempo. Permite regresar a versiones anteriores, comparar diferentes versiones, identificar quién realizó un cambio específico y mucho más.

Este sistema es esencial para la ciencia de datos debido a:

- **Seguimiento de cambios:** Permite entender la evolución del código, facilitando la identificación y corrección de errores.
- **Colaboración eficiente:** En proyectos colaborativos, varios miembros pueden trabajar simultáneamente sin sobrescribir el trabajo del otro.
- **Restauración de versiones anteriores:** Permite volver a puntos específicos en el desarrollo, lo cual es útil si se introducen errores o se desea revertir un cambio.
- **Reproducibilidad:** Garantiza la consistencia del código y los resultados a lo largo del tiempo, lo que es fundamental en la investigación científica.

### Git: La herramienta esencial

**Git** es un sistema de control de versiones distribuido, ampliamente utilizado en la actualidad. A diferencia de sistemas centralizados, cada usuario posee una copia completa del historial del proyecto, lo que permite trabajar sin conexión y facilita la colaboración.

**Conceptos básicos de Git:**

- **Repositorio:** Un directorio que contiene todos los archivos del proyecto y su historial de cambios.
- **Rama (branch):** Una línea de desarrollo independiente dentro del repositorio. Permite trabajar en nuevas características o corregir errores sin afectar la rama principal.
- **Commit:** Una instantánea del estado del proyecto en un momento determinado. Cada commit contiene un mensaje que describe los cambios realizados.
- **Merge:** La acción de combinar los cambios de una rama a otra.

**Estados de un archivo:**

- **Modificado (modified):** Se han realizado cambios en el archivo, pero aún no se han guardado en el repositorio.
- **Preparado (staged):** Se han marcado los archivos modificados para incluirlos en el siguiente commit.
- **Confirmado (committed):** Los cambios se han guardado en el repositorio.

**Comandos esenciales de Git:**

- **`git init`**: Crea un nuevo repositorio Git en el directorio actual.
- **`git clone <URL>`**: Crea una copia local de un repositorio remoto existente.
- **`git add <archivo>`**: Agrega un archivo al área de preparación (staging area).
- **`git commit -m "Mensaje del commit"`**: Crea un nuevo commit con los archivos preparados.
- **`git push`**: Envía los commits locales al repositorio remoto.
- **`git pull`**: Descarga los cambios del repositorio remoto al repositorio local.
- **`git branch`**: Muestra las ramas existentes.
- **`git checkout <nombre_de_la_rama>`**: Cambia a la rama especificada.
- **`git merge <nombre_de_la_rama>`**: Combina la rama especificada con la rama actual.

**Flujos de trabajo comunes con Git:**

- **Flujo de trabajo centralizado:** Todos los desarrolladores trabajan en una sola rama principal. Es un flujo de trabajo simple, adecuado para proyectos pequeños.
- **Flujo de trabajo con ramas (feature branching):** Se crea una rama separada para cada nueva característica o corrección de errores. Permite un desarrollo más organizado y facilita la colaboración en proyectos grandes.

### Clonar e Instalar Herramientas CLI: Ejemplo con ddgr

Para examinar de forma práctica el ciclo de descarga, instalación e integración de herramientas externas de línea de comandos en el entorno `dsin`, instalaremos `ddgr`. Esta utilidad, desarrollada en Python, permite realizar búsquedas web directamente desde la terminal mediante DuckDuckGo.

En primer lugar, nos aseguramos de estar en el directorio principal del usuario (`~`), creamos un directorio para el código fuente y clonamos el repositorio:

```nu
# skip-docker-exec (requiere conexión a internet para clonar)
cd ~
mkdir ~/software
cd ~/software
git clone --depth 1 https://github.com/jarun/ddgr.git
cd ddgr
```

A continuación, instalamos la herramienta usando `make`. En el contenedor `dsin`, el directorio `/home/dsin/bin` ya se encuentra en `$env.PATH`, por lo que indicamos `/home/dsin` como prefijo de instalación:

```nu
# skip-docker-exec (instalación local en ~/bin)
make install PREFIX=/home/dsin
which ddgr
```

Una vez instalada, podemos utilizar `ddgr` de dos formas distintas:

#### 1. Modo interactivo en la terminal

Podemos realizar búsquedas interactivas directamente en la consola:

```nu
# skip-docker-exec (modo interactivo en terminal)
ddgr como clonar un repositorio github
```

En este modo, navegamos entre los resultados con las teclas `n` (página siguiente) y `p` (página anterior), abrimos enlaces ingresando el número correspondiente y salimos presionando `q`.

#### 2. Salida estructurada e integración con pipelines de Nushell

Una de las mayores ventajas de las herramientas CLI modernas es su capacidad para exportar datos estructurados. Al ejecutar `ddgr` con el parámetro `--json`, podemos enviar su salida a un pipeline de Nushell y procesarla con `from json`:

```nu
# skip-docker-exec (consulta web que requiere acceso a red en vivo)
ddgr --json -n 3 "nushell data science" |
  from json |
  select title url
```

De esta forma, los resultados de búsqueda se convierten inmediatamente en una tabla de Nushell, lo que permite filtrarlos con `where`, proyectar columnas con `select` o exportarlos a otros formatos de manera directa.

### GitHub/GitLab

**GitHub** y **GitLab** son plataformas de alojamiento de código basadas en Git que ofrecen herramientas adicionales para la colaboración y gestión de proyectos.

**Creación de un repositorio remoto:**

1. Crear una cuenta gratuita en GitHub o GitLab.
2. Crear un nuevo repositorio e indicar un nombre y una descripción.

**Conexión del repositorio local con el remoto:**

1. En la configuración del repositorio remoto, copiar la URL de clonación.
2. En la terminal, navegar al directorio del repositorio local.
3. Ejecutar el comando `git remote add origin <URL_del_repositorio_remoto>`.

**Colaboración en proyectos:**

- **Clonar un repositorio existente:** Utilizar el comando `git clone <URL_del_repositorio>` para crear una copia local.
- **Bifurcación (fork) de repositorios:** Crear una copia personal de un repositorio para trabajar en él de forma independiente.
- **Pull requests:** Proponer cambios al repositorio original. Se realiza una solicitud al propietario del repositorio para que revise y combine los cambios.

**Herramientas adicionales en GitHub/GitLab:**

- **Gestión de issues:** Permite registrar errores, tareas y solicitudes de características.
- **Wiki:** Un espacio para documentar el proyecto de forma colaborativa.
- **Integración continua/despliegue continuo (CI/CD):** Permite automatizar pruebas, compilación y despliegue del código.

### Mejores prácticas para proyectos de ciencia de datos

- **Organización de proyectos:** Utilizar una estructura de directorios clara para organizar el código, los datos y la documentación.
- **Archivos `.gitignore`:** Excluir del control de versiones archivos innecesarios, como datos sin procesar o archivos temporales.
- **Mensajes de commit informativos:** Describir claramente los cambios realizados en cada commit.
- **Gestión de dependencias:** Utilizar archivos de requisitos para especificar las librerías y versiones necesarias para ejecutar el código.


### Commit y Push

Para crear proyectos en Gitlab o Github, primero se debe crear una cuenta de usuario.

Github permite la existencia de solo un repositorio personal privado (en su versión gratis), mientras que Gitlab no tiene esa limitante.

Una vez creada la cuenta de usuario, se debe autentificar la maquina local mediante una clave `ssh`.

Creamos la clave (seleccione Si a todo):

```bash
ssh-keygen -t rsa
cat ~/.ssh/id_rsa.pub
```

Copie el contenido de ese archivo y cree una nueva clave ssh en la web de github/gitlab.

Ahora en la web de github/gitlab, creamos un nuevo repositorio vacío y seleccionamos un nombre.

En la máquina local, realizamos los siguiente para conectarla al repositorio.

```bash
git config --global init.defaultBranch main
cd ~/software
mkdir test #o algun nombre seleccionado
cd test
echo "# test" >> README.md
git init
git add README.md
git commit -m "first commit" #mensaje a eleccion
git branch -M main
git remote add origin git@github.com:your_user/your_repo_name.git
git push -u origin main
```

Esto sincroniza el directorio local con el repositorio.

Supongamos que hacemos algún cambio al contenido de este directorio. Por ejemplo, editamos el archivo `README.md`:

```bash
nano README.md
```

Para subir los cambios realizamos:

```bash
git add -A
git status
git commit -am "mensaje apropiado"
git push origin main
```

### Hacer aportes a un repositorio

Para realizar aportes a un repositorio, o una _pull request_ (PR), se debe realizar un siguiente:

1. **Crear una copia del repositorio o un _fork_.**

- En el navegador web, ir al repositorio de GitHubitlab al que desea contribuir.
- En la esquina superior derecha de la página del repositorio, hacer click en el bóton "Fork". Esto crea una copia del repositorio en su cuenta de GitHub/Gitlab.

2. **Clonar su Repositorio Bifurcado.**

- En la página del _fork_ en su repositorio copie la URL de clonación `ssh`.
- En la terminal, ejecutar:

    ```bash
    git clone <copied_https_url>
    ```

Reemplace `<copied_https_url>` con la URL que copió en el paso anterior.

3. **Crear una Nueva Rama (_branch_).**

    ```bash
    cd <repository_directory>
    git checkout -b <your-branch-name>
    ```

> Por ejemplo: `git checkout -b fix-typo-in-readme`

4. **Hacer sus Cambios y hacer el _commit_.**

- Realice los cambios deseados en el código o la documentación.
- Realice `git add`, `git commit` y `git push` según lo descrito en la sección anterior.

5. **Crear la Solicitud de Aporte (_Pull Request_).**

- **Navegar a GitHub:** Vuelva al repositorio original que bifurcó en GitHub.
- **Crear PR:** Por lo general, verá un aviso sobre su rama recientemente enviada. Haga clic en el botón "Comparar y solicitar PR". Si no es así, vaya a la pestaña "Solicitudes de extracción" y haga clic en "Nueva solicitud de extracción", luego seleccione su rama.
- **Revisar y Enviar:** Revise cuidadosamente sus cambios, agregue un título y una descripción a su solicitud de extracción explicando sus cambios y haga clic en "Crear solicitud de extracción".

### Sugerencias de mensajes commit

Algunas directrices al momento de elegir el mensaje del `commit`.

1. Elija una etiqueta. Algunas sugerencias:

- _build_: Cambios que afectan al sistema de compilación o a las dependencias externas (ejemplos de ámbitos: `gulp`, `broccoli`, `npm`).
- _chore_: Actualización de bibliotecas, derechos de autor u otra configuración del repositorio, incluye la actualización de dependencias.
- _ci_: Cambios en nuestros archivos de configuración y scripts de CI (ejemplos de ámbitos: Travis, Circle, GitHub Actions).
- _docs_: Cambios que no son de código, como corregir errores tipográficos o añadir nueva documentación.
- _feat_: Una confirmación de tipo _feat_ introduce una nueva característica en la base de código.
- _fix_: Una confirmación de tipo _fix_ corrige un error en su base de código.
- _perf_: Un cambio de código que mejora el rendimiento.
- _refactor_: Un cambio de código que no corrige un error ni añade una característica.
- _style_: Cambios que no afectan al significado del código (espacios en blanco, formato, punto y coma faltantes, etc.).
- _test_: Añadir pruebas que faltan o corregir las existentes.

2. Elija un título para la confirmación.

3. Resuma el _commit_, escribiendo una lista mínima de los cambio realizados.

4. El mensaje _commit_ final debe tener el siguiente formato:

    ```md
    <etiqueta>: <título>

    - Item 1
    - Item 2
      etc
    ```

### Recursos adicionales

- **Documentación oficial:**
    - Git: [https://git-scm.com/docs](https://git-scm.com/docs)
    - GitHub: [https://docs.github.com/](https://docs.github.com/)
    - GitLab: [https://docs.gitlab.com/](https://docs.gitlab.com/)

- **Ejemplos de proyectos de ciencia de datos que utilizan Git y GitHub:**
    - [TensorFlow](https://github.com/tensorflow/tensorflow)
    - [scikit-learn](https://github.com/scikit-learn/scikit-learn)
    - [Pandas](https://github.com/pandas-dev/pandas)

### Para mayor exploración

Una lista completa de los comandos o herramientas utilizadas en este libro se encuentran en el siguiente link: [https://jeroenjanssens.com/dsatcl/list-of-command-line-tools](https://jeroenjanssens.com/dsatcl/list-of-command-line-tools).

\newpage

<!-- capitulo 3 -->



\newpage

# Programación y Creación de Herramientas de Línea de Comandos {#chapter-4-programming-cli-tools}

## Programación en Nushell

Esta sección entra en más detalle de Nushell como un lenguaje de programación.

Al igual que la mayoría de los lenguajes de programación permiten definir funciones, Nushell usa comandos personalizados (_custom commands_) para este propósito.

Los _alias_ de Nushell funcionan de manera similar a los alias de otras shell y son parte del lenguaje de programación, no solo una característica del shell.

Las operaciones comunes pueden, como la suma o la búsqueda regex, hacerse con _operadores_.
No todas las operaciones son compatibles con todos los tipos de datos y Nushell se asegurará de hacerlo saber.

Se pueden almacenar resultados intermedios en _variables_. Las variables pueden ser inmutables, mutables o una constante de tiempo de análisis.

Los _scripts_ son la forma más simple de organización del código: simplemente se escribe el código en un archivo y se ejecuta.
Sin embargo, también se pueden ejecutar scripts como programas independientes con firmas de línea de comandos utilizando el comando `main`.

### Operadores

Nushell soporta los siguientes operadores para operaciones comunes de matemáticas, lógica y cadenas:

| Operador      | Descripción                                                               |
| ------------- | ------------------------------------------------------------------------- |
| `+`           | sumar                                                                     |
| `-`           | restar                                                                    |
| `*`           | multiplicar                                                               |
| `/`           | dividir                                                                   |
| `//`          | división de piso                                                          |
| `mod`         | módulo                                                                    |
| `**`          | exponenciación (potencia)                                                 |
| `==`          | igual                                                                     |
| `!=`          | no igual                                                                  |
| `<`           | menor que                                                                 |
| `<=`          | menor o igual que                                                         |
| `>`           | mayor que                                                                 |
| `>=`          | mayor o igual que                                                         |
| `=~`          | coincidencia de expresiones regulares / cadena contiene otra              |
| `!~`          | coincidencia inversa de expresiones regulares / cadena _no_ contiene otra |
| `in`          | valor en lista                                                            |
| `not-in`      | valor no en lista                                                         |
| `not`         | no lógico                                                                 |
| `and`         | y dos expresiones booleanas (cortocircuitos)                              |
| `or`          | o dos expresiones booleanas (cortocircuitos)                              |
| `xor`         | o exclusivo dos expresiones booleanas                                     |
| `bit-or`      | o bit a bit                                                               |
| `bit-xor`     | xor bit a bit                                                             |
| `bit-and`     | y bit a bit                                                               |
| `bit-shl`     | desplazamiento bit a bit a la izquierda                                   |
| `bit-shr`     | desplazamiento bit a bit a la derecha                                     |
| `starts-with` | cadena comienza con                                                       |
| `ends-with`   | cadena termina con                                                        |
| `++`          | agregar listas                                                            |

Los paréntesis se pueden usar para agrupar para especificar el orden de evaluación o para llamar a comandos y usar los resultados en una expresión

#### Orden de Operaciones

Para entender la precedencia de las operaciones, se puede ejecutar el comando: `help operators | sort-by precedence -r`.

Presentado en orden descendente de precedencia, el artículo detalla las operaciones de la siguiente manera:

- Paréntesis (`()`)
- Exponenciación/Potencia (`**`)
- Multiplicar (`*`), Dividir (`/`), División Entera/Suelo (`//`), y Módulo (`mod`)
- Sumar (`+`) y Restar (`-`)
- Desplazamiento de bits (`bit-shl`, `bit-shr`)
- Operaciones de comparación (`==`, `!=`, `<`, `>`, `<=`, `>=`), pruebas de pertenencia (`in`, `not-in`, `starts-with`, `ends-with`), coincidencia de expresiones regulares (`=~`, `!~`), y agregar a la lista (`++`)
- Bit a bit and (`bit-and`)
- Bit a bit xor (`bit-xor`)
- Bit a bit or (`bit-or`)
- Lógico and (`and`)
- Lógico xor (`xor`)
- Lógico or (`or`)
- Operaciones de asignación
- Lógico not (`not`)

Por ejemplo:

```nu
3 * (1 + 2)
```

#### Tipos

No todos las operaciones tienen sentido para todos los tipos de datos.
Si se intenta realizar una operación en tipos de datos no compatibles, se encontrará con un mensaje de error que debería explicar qué salió mal:

```nu
> "spam" - 1
Error: nu::parser::unsupported_operation (link)

  × Tipos no coincidentes para la operación.
   ╭─[entry #49:1:1]
 1 │ "spam" - 1
   · ───┬── ┬ ┬
   ·    │   │ ╰── int
   ·    │   ╰── no admite estos valores.
   ·    ╰── string
   ╰────
  help: Cambie string o int para que sean los tipos correctos e intente nuevamente.
```

Las reglas a veces pueden parecer un poco estrictas, pero por otro lado, debería haber menos efectos secundarios inesperados

#### Expresión Regular / Operadores string-contains

Los operadores `=~` y `!~` proporcionan una forma conveniente de evaluar expresiones regulares. No se necesita saber de expresiones regulares para usarlos; también son una forma fácil de comprobar si una cadena contiene otra.

- `string =~ pattern` devuelve **true** si `string` contiene una coincidencia para `pattern`, y **false** en caso contrario.
- `string !~ pattern` devuelve **false** si `string` contiene una coincidencia para `pattern`, y **true** en caso contrario.

Por ejemplo:

```nu
"foobarbaz" =~ "bar" # devuelve true
"foobarbaz" !~ "bar" # devuelve false
ls | where name =~ ^nu # devuelve todos los archivos cuyos nombres comienzan con "nu"
```

#### Sensibilidad a Mayúsculas y Minúsculas

Los operadores suelen ser sensibles a mayúsculas y minúsculas cuando operan con cadenas. Hay algunas maneras de trabajar sin distinción entre mayúsculas y minúsculas:

1. En los operadores de expresiones regulares, especifique el modificador de modo insensible a mayúsculas y minúsculas `(?i)`:

```nu
"FOO" =~ "foo" # devuelve falso
"FOO" =~ "(?i)foo" # devuelve verdadero
```

2. Utilice la opción `--ignore-case` del comando `str contains`:

```nu
"FOO" | str contains --ignore-case "foo"
```

3. Convierta las cadenas a minúsculas con `str downcase` antes de comparar:

```nu
("FOO" | str downcase) == ("Foo" | str downcase)
```

#### Operador de propagación

Nushell tiene un operador de propagación (`...`) para desempaquetar listas y registros. Se puede
expandir listas o registros en lugares donde se esperan múltiples valores o pares clave-valor.

Hay tres lugares donde puede usar el operador de propagación:

- En literales de lista.
- En literales de registro.
- En llamadas de comando.

##### En literales de Lista

Supongamos que se tienen varias listas que desea concatenar, pero también quiere intercalar
algunos valores individuales. Esto se puede hacer con `append` y `prepend`, pero la propagación el operador puede permitir hacerlo más fácilmente.

```nu
let dogs = [Spot, Teddy, Tommy]
let cats = ["Mr. Humphrey Montgomery", Kitten]
[
    ...$dogs
    Polly
    ...($cats | each { |elt| $"($elt) \(cat\)" })
    ...[Porky Bessie]
    ...Nemo
]
```

El siguiente código es una versión equivalente usando `append`:

```nu
$dogs |
  append Polly |
  append ($cats | each { |elt| $"($elt) \(cat\)" }) |
  append [Porky Bessie] |
  append ...Nemo
```

Considerar que cada llamada a `append` da como resultado la creación de una nueva lista, lo que significa que en este segundo
ejemplo, se crean 3 listas intermedias innecesarias. Este no es el caso con el operador de propagación, por lo que puede haber beneficios de rendimiento (muy menores) al usar `...` si se está uniendo muchas listas grandes
juntas, una y otra vez.

Puede haber notado que el último elemento de la lista resultante anterior es `"...Nemo"`. Esto se debe a que dentro de los literales de lista, solo se puede usar para difundir listas, no cadenas. Como tal, dentro de los literales de lista, solo se puede usar antes de variables (`...$foo`), subexpresiones (`...(foo)`), y literales de lista (`...[foo]`).

El `...` tampoco se reconocerá como el operador de propagación si hay algún espacio en blanco entre él y la siguiente expresión:

```nu
[ ... [] ]
```

Esto es principalmente para que `...` no se confunda con el operador de propagación en comandos como `mv ... $dir`.

##### En literales de Registro

Digamos que se tiene un registro con alguna información de configuración y desea agregar más campos a este registro:

```nu
let my_config = { path: /tmp, limit: 5 }
```

Se puede crear un nuevo registro con todos los campos de `$config` y algunas nuevas adiciones usando la propagación operador. Se puede usar la propagación de múltiples registros dentro de un solo literal de registro.

```nu
{
    ...$my_config,
    users: [alice bob],
    ...{ url: example.com },
    ...(sys mem)
}
```

De manera similar a las listas, dentro de los literales de registro, el operador de propagación solo se puede usar antes de las variables (`...$foo`),
subexpresiones (`...(foo)`), y literales de registro (`...{foo:bar}`). Aquí también, no es necesario que haya espacio en blanco entre el `...` y la siguiente expresión para que se reconozca como el operador de propagación.

##### En llamadas de Comando

También se pueden propagar argumentos a un comando, siempre que tenga un parámetro `rest` o sea un comando externo.

Aquí hay un ejemplo de comando personalizado que tiene un parámetro `rest`:

```nu
def foo [ --flag req opt? ...args ] { [$flag, $req, $opt, $args] | to nuon }
```

Tiene una opción (`--flag`), un parámetro posicional requerido (`req`), un parámetro posicional opcional (`opt?`), y el parámetro rest (`args`).

Si se tiene una lista de argumentos para pasar a `args`, se puede propagar de la misma manera que propagaría una lista dentro de un literal de lista. Se aplican las mismas reglas: el operador de propagación solo se reconoce antes de variables, subexpresiones y literales de lista, y no se permiten espacios en blanco en el medio.

```nu
foo "bar" "baz" ...[1 2 3] # Con ..., los números se tratan como argumentos separados
foo "bar" "baz" [1 2 3] # Sin ..., [1 2 3] se trata como un solo argumento
```

Una forma más útil de usar el operador de propagación es si tiene otro comando con un parámetro `rest` y desea que reenvíe sus argumentos a `foo`:

```nu
def bar [ ...args ] { foo --flag "bar" "baz" ...$args }
bar 1 2 3
```

Puede propagar varias listas en una sola llamada y también intercalar argumentos individuales:

```nu
foo "bar" "baz" 1 ...[2 3] 4 5 ...(6..9 | take 2) last
```

Las opciones/argumentos con nombre pueden ir después de un argumento de propagación, al igual que pueden ir después de argumentos `rest` regulares:

```nu
foo "bar" "baz" 1 ...[2 3] --flag 4
```

Si un argumento de propagación viene antes de un parámetro posicional opcional, ese parámetro opcional se trata como omitido:

```nu
foo "bar" ...[1 2] "not opt"
```

### Variables en Scripts y Herramientas CLI

El modelo conceptual de variables de Nushell, sus reglas de nomenclatura y la distinción entre `let`, `mut` y `const` fueron introducidos en los [fundamentos del Capítulo 3](#declaracion-y-ciclo-de-vida-de-variables-let-mut-y-const). Al diseñar herramientas y funciones reutilizables, la directriz principal consiste en priorizar variables inmutables con `let` y flujos continuos (*streaming*) de transformación, reservando `mut` exclusivamente para algoritmos imperativos donde la acumulación local sea indispensable y `const` para dependencias evaluadas estáticamente durante el análisis de compilación (`source`, `use`).

### Comandos personalizados

La capacidad de Nu para componer _pipelines_ largos permite mucho control sobre los datos y sistema, pero tiene el precio de escribir mucho. Idealmente, se podrían guardar las _pipelines_ bien elaborados para usarlos una y otra vez.

Aquí es donde entran los comandos personalizados.

Un ejemplo de definición de un comando personalizado:

```nu
def greet [name:string] {
  ['hello' $name]
}
```

En esta definición, se define el comando `greet`, que toma un solo parámetro `name`. Siguiendo a este parámetro está el bloque que representa lo que sucederá cuando se ejecute el comando personalizado. Cuando se llama, el comando personalizado establecerá el valor pasado para `name` como la variable `$name`, que estará disponible para el bloque.

Para ejecutar lo anterior, podemos llamarlo como llamaríamos a los comandos integrados:

```nu
greet "world"
```

> El valor producido por la última línea de un comando se convierte en el valor devuelto del comando. En este caso, se devuelve una lista que contiene la cadena `'hello'` y `$name`. Para evitar esto, se puede colocar `null` (o el comando `ignore` al final de la _pipeline_, así: `['hello' $name] | null`. También se debe tener en cuenta que la mayoría de los comandos del sistema de archivos, como `save` o `cd`, siempre generan `null`.

> Si se quiere generar una sola cadena de texto, se puede usa la sintaxis de interpolación de cadenas para incrustar `$name` en ella:

```nu
def greet [name:string] {
  $"hello ($name)"
}

greet nushell
```

### Nombres de Comandos

En Nushell, un nombre de comando es una cadena de caracteres. Aquí hay algunos ejemplos de nombres de comandos válidos: `greet`, `get-size`, `mycommand123`, `my command`, y `emoji_cmd` (o cualquier símbolo unicode admitido).

> Es una práctica común en Nushell separar las palabras del comando con `-` para una mejor legibilidad. Por ejemplo `get-size` en lugar de `getsize` o `get_size`.

### Subcomandos

También se pueden definir subcomandos a comandos usando un espacio. Por ejemplo, si se quisiera agregar un nuevo subcomando a `str`, se puede crear nombrando el subcomando de forma tal que comience con "str ". Por ejemplo:

```nu
def "str mycommand" [] {
  "hello"
}
```

Se puede llamar al comando personalizado como si fuera un subcomando incorporado de `str`:

```nu
def "str mycommand" [] { "hello" }
str mycommand
```

Por supuesto, los comandos con espacios en sus nombres se definen de la misma manera:

```nu
def "custom command" [] {
  "this is a custom command with a space in the name!"
}
```

### Tipos de Parámetros

Cuando se definen comandos personalizados, se puede nombrar y, opcionalmente, establecer el tipo para cada parámetro. Por ejemplo, se puede escribir lo anterior como:

```nu
def greet [name: string] {
  $"hello ($name)"
}
```

Los tipos de parámetros son opcionales. Nushell permite omitirlos y tratar el parámetro como `any` si es así. Si se selecciono un tipo en un parámetro, Nushell comprobará este tipo cuando llame a la función.

Por ejemplo, supongamos que necesitamos un dato tipo `int` en su lugar:

```nu
# skip-docker-exec (demostración de verificación de tipos)
def greet [name: int] {
  $"hello ($name)"
}

greet world
```

Si intentamos ejecutar lo anterior, Nushell nos indica que los tipos no coinciden:

```
error: Type Error
  ┌─ shell:6:7
  │
5 │ greet world
  │       ^^^^^ Expected int
```

Esto ayuda a guiar a los usuarios de las definiciones para que invoquen los comandos únicamente con argumentos del tipo esperado. Para consultar el catálogo completo de los tipos de datos admitidos en Nushell (`string`, `int`, `float`, `filesize`, `datetime`, `table`, etc.) y sus descripciones operativas, consulte la [Tabla 1 en el Capítulo 3](#chapter-3-nushell-fundamentals).

### Parámetros con un Valor Predeterminado

Para hacer un parámetro opcional y directamente proporcionar un valor predeterminado para él, se puede proporcionar un valor predeterminado en la definición del comando.

```nu
def greet [age, name = "nushell"] {
  $"hello ($name) + ($age)"
}
```

Se puede llamar a este comando sin el parámetro o con un valor para anular el valor predeterminado:

```nu
def greet [name = "nushell"] { $"hello ($name)" }
greet
greet world
```

También puede combinar un valor predeterminado con un requisito de tipo:

```nu
def congratulate [age: int = 18] {
  $"Happy birthday! You are ($age) years old now!"
}
```

Si se desea comprobar si un parámetro opcional está presente o no y no solo confiar en un valor predeterminado, se pueden utilizar parámetros posicionales opcionales en su lugar.

### Parámetros Posicionales Opcionales

Por defecto, los parámetros posicionales son requeridos. Si un parámetro posicional no se entrega, se encontrará un error:

```nu
  × Missing required positional argument.
   ╭─[entry #23:1:1]
 1 │ greet
   ·      ▲
   ·      ╰── missing name
   ╰────
  help: Usage: greet <name>
```

Podemos en cambio marcar un parámetro posicional como opcional poniendo un signo de interrogación (`?`) después de su nombre. Por ejemplo:

```nu
def greet [name?: string] {
  $"hello ($name)"
}

greet
greet world
```

Hacer un parámetro posicional opcional no cambia su nombre cuando se accede en el cuerpo. Como el ejemplo de arriba muestra, todavía se accede con `$name`, a pesar del sufijo `?` en la lista de parámetros.

Cuando un parámetro opcional no se entrega, su valor en el cuerpo del comando es igual a `null`. Podemos usar esto para actuar en el caso donde un parámetro no fue entregado:

```nu
def greet [name?: string] {
  if ($name == null) {
    "hello, I don't know your name!"
  } else {
    $"hello ($name)"
  }
}

greet
```

Si solo se quiere establecer un valor por defecto cuando el parámetro falta, es más simple usar un valor por defecto en cambio.

Si se usan parámetros posicionales requeridos y opcionales juntos, entonces los parámetros requeridos deben aparecer en la definición primero.

### Opciones (_flags_)

Además de pasar parámetros posicionales, también puede pasar parámetros con nombre definiendo opciones para los comandos personalizados.

Por ejemplo:

```nu
def greet [
  name: string
  --age: int
] {
  [$name $age]
}
```

En la definición de `greet` anterior, se define el parámetro posicional `name`, así como una opción llamada `age`. Esto permite a quien llama a `greet` pasar opcionalmente también el parámetro `age`.

Se puede llamar a lo anterior usando:

```nu
greet world --age 10
```

O:

```nu
greet --age 10 world
```

O incluso omitir la opción por completo:

```nu
greet world
```

Las opciones también se pueden definir para tener una versión abreviada. Esto permite pasar una opción de forma más simple, así como una opción larga-y-más-fácil-de-leer.

Extendemos el ejemplo anterior para usar una opción abreviada para el valor de `age`:

```nu
def greet [
  name: string
  --age (-a): int
] {
  [$name $age]
}
```

> _Nota:_ Las opciones se nombran por su nombre largo, por lo que el ejemplo anterior necesitaría usar `$age` y no `$a`.

Ahora, se puede llamar a esta definición actualizada usando la la opción abreviada:

```nu
greet -a 10 hello
```

Las opciones también se pueden usar como interruptores (_switches_) básicos. Esto significa que su presencia o ausencia se toma como un argumento para la definición. Extendiendo el ejemplo anterior:

```nu
def greet [
  name: string
  --age (-a): int
  --twice
] {
  if $twice {
    [$name $name $age $age]
  } else {
    [$name $age]
  }
}
```

Y la definición se puede llamar como:

```nu
greet -a 10 --twice hello
```

O simplemente sin la opción del switch:

```nu
greet -a 10 hello
```

También se puede asignar un valor de verdadero/falso para habilitar/deshabilitar la opción:

```nu
greet -a 10 --twice=false hello
greet -a 10 --twice=true hello
```

Las opciones pueden contener guiones. Se puede acceder a ellas reemplazando el guion con un guion bajo:

```nu
def greet [
  name: string
  --age (-a): int
  --two-times
] {
  if $two_times {
    [$name $name $age $age]
  } else {
    [$name $age]
  }
}
```

### Parámetros rest

Puede haber casos en los que se desee definir un comando que tome cualquier número de argumentos posicionales. Podemos hacer esto con un parámetro te tipo `rest`, usando la siguiente sintaxis `...`:

```nu
def greet [...name: string] {
  print "hello all:"
  for $n in $name {
    print $n
  }
}

greet earth mars jupiter venus
```

Se puede llamar a la definición anterior del comando `greet` con cualquier número de argumentos, incluyendo ninguno en absoluto. Todos los argumentos se recopilan en `$name` como una lista.

Los parámetros rest se pueden usar junto con los parámetros posicionales:

```nu
def greet [vip: string, ...name: string] {
  print $"hello to our VIP ($vip)"
  print "and hello to everybody else:"
  for $n in $name {
    print $n
  }
}

greet moon earth mars jupiter venus
```

Para pasar una lista a un parámetro `rest`, puede usar el operador de propagación `...`:

```nu
let planets = [earth mars jupiter venus]

greet moon ...$planets
```

### Documentando un Comando

Para facilitar el uso y mantenimiento de los comandos personalizados, Nushell permite documentar descripciones detalladas tanto a nivel del comando completo como para cada uno de sus parámetros y opciones.

Adicionalmente, Nushell soporta un sistema de **anotaciones y metadatos con `@`** que se anteponen a la definición de `def`:

- **`@category <nombre>`:** Clasifica el comando dentro del inventario general del sistema (visible al consultar `help commands`).
- **`@search-terms <términos...>`:** Registra palabras clave adicionales para que el comando sea localizable mediante búsquedas semánticas con `help --find`.
- **`@example "descripción" { código } --result resultado`:** Incorpora ejemplos ejecutables con su salida esperada, los cuales se renderizan automáticamente en la sección de ejemplos de `help`.

A continuación se muestra una definición exhaustivamente documentada:

```nu
# Comando de saludo personalizado que ilustra anotaciones y documentación
@category utilidades
@search-terms saludo bienvenida mensaje
@example "Saludar indicando la edad" { greet "Carlos" --age 28 } --result ["Carlos", 28]
def greet [
  name: string      # Nombre de la persona a saludar
  --age (-a): int   # Edad opcional de la persona
] {
  [$name $age]
}
```

Una vez registrado el comando, al invocar `help greet` se obtiene una ficha técnica completa generada de manera automática:

```text
Comando de saludo personalizado que ilustra anotaciones y documentación

Search terms: saludo, bienvenida, mensaje

Usage:
  > greet <name> {flags}

Flags:
  -a, --age <int>: Edad opcional de la persona
  -h, --help: Muestra este mensaje de ayuda

Parameters:
  name <string>: Nombre de la persona a saludar

Examples:
  Saludar indicando la edad
  > greet "Carlos" --age 28
  ╭───┬────────╮
  │ 0 │ Carlos │
  │ 1 │     28 │
  ╰───┴────────╯
```

Ahora, si se ejecuta `help greet`, se entrega un texto de ayuda más útil:

```text
A greeting command that can greet the caller

Usage:
  > greet <name> {flags}

Parameters:
  <name> The name of the person to greet

Flags:
  -h, --help: Display this help message
  -a, --age <integer>: The age of the person
```

### Cierres (Closures)

Un **cierre** (*closure*) en Nushell es un bloque anónimo de código ejecutable que puede recibir argumentos, procesar el flujo de entrada de una tubería (`$in`) y capturar variables de su entorno léxico exterior. Los cierres constituyen ciudadanos de primera clase en el lenguaje: pueden almacenarse en variables, transferirse como argumentos hacia otros comandos y ejecutarse dinámicamente cuando sea requerido.

#### Sintaxis y Parámetros

Los cierres se delimitan mediante llaves `{ ... }`. Cuando un cierre define parámetros formales, estos se especifican entre barras verticales al inicio del bloque (`{ |parámetro1, parámetro2| ... }`), admitiendo anotaciones estáticas de tipo:

```nu
# Cierre con un parámetro tipado
let duplicar = { |x: int| $x * 2 }

# Cierre con dos parámetros
let ponderar = { |val: float, peso: float| $val * $peso }
```

#### Invocación Dinámica con el Comando `do`

Para evaluar un cierre almacenado en una variable se utiliza el comando nativo `do`:

```nu
do $duplicar 21
do $ponderar 4.5 0.8
```

#### Uso en Tuberías y Funciones de Orden Superior

El rol más relevante de los cierres en ciencia de datos tiene lugar al procesar colecciones y tablas en combinación con funciones de orden superior como `each`, `where`, `filter`, `reduce` y `par-each`:

```nu
# Transformación elemento a elemento con each
[1 2 3 4 5] | each { |n| $n ** 2 }

# Filtrado condicional con where
[10 25 3 48 7] | where { |val| $val > 20 }
```

Cuando un cierre no declara parámetros explícitos mediante `|...|`, puede consumir directamente el registro emitido por la etapa anterior de la tubería mediante la variable especial `$in`:

```nu
[5 12 18] | each { $in * 10 }
```

#### Captura de Entorno e Inmutabilidad

Un cierre puede capturar variables inmutables (`let` o `const`) presentes en el ámbito léxico donde fue declarado. Sin embargo, por principios de diseño orientados a la seguridad y a la concurrencia determinista en pipelines paralelos, **los cierres en Nushell tienen estrictamente prohibido capturar y mutar variables mutables (`mut`)**. Cualquier tentativa de modificar una variable mutable exterior desde dentro de un cierre genera un error sintáctico inmediato (`nu::shell::capture_of_mutable_var`).

### Salida de la _pipeline_

Los comandos personalizados transmiten su salida al igual que los comandos incorporados. Por ejemplo:

```nu
ls | get name
```

Hacemos una copia de `ls` a un comando personalizado:

```nu
def my-ls [] { ls }
```

Se puede usar la salida de este comando tal como se haría con `ls`.

```nu
my-ls | get name
```

Esto nos permite construir fácilmente comandos personalizados y procesar su salida. Tenga en cuenta que no usamos sentencias de retorno como otros lenguajes. En cambio, construimos pipelines que generan flujos de datos que se pueden conectar a otros pipelines.

### Entrada de la _pipeline_

Los comandos personalizados también pueden tomar entrada desde la _pipeline_, al igual que otros comandos. Esta entrada se pasa automáticamente al bloque que utiliza el comando personalizado.

Consideremos el siguiente comando que calcula el doble para cada elemento de una lista:

```nu
def double [] {
  each { |elt| 2 * $elt }
}
```

Y puede utilizarse de la siguiente forma:

```nu
[1 2 3] | double
```

También se puede almacenar la entrada para su uso posterior utilizando la variable `$in`:

```nu
def nullify [...cols] {
  let start = $in
  $cols | reduce --fold $start { |col, df|
    $df | upsert $col null
  }
}
```

### Control de flujo

Nushell proporciona varios comandos que ayudan a determinar cómo se ejecutan diferentes grupos de código. En los lenguajes de programación esta funcionalidad a menudo se conoce como _control de flujo_.

#### Elección (Condicionales)

Los siguientes comandos ejecutan código basado en una condición dada.

::: tip
Los comandos de elección/condicionales son expresiones, por lo que devuelven valores, a diferencia de los otros comandos en esta página. Esto significa que lo siguiente funciona.

```nu
'foo' | if $in == 'foo' { 1 } else { 0 } | $in + 2
```

:::

##### `if`

`if` evalúa de código ramificados basados en los resultados de una o más condiciones similares a la funcionalidad "if" en otros lenguajes de programación. Por ejemplo:

```nu
let x = 5
if $x > 0 { 'positivo' }
```

Devuelve `'positivo'` cuando la condición es `true` (`$x` es mayor que cero) y `null` cuando la condición es `false` (`$x` es menor o igual a cero).

Se puede agregar una rama `else` al `if` después del primer bloque que se ejecuta y devuelve el valor resultante del bloque `else` cuando la condición es `false`. Por ejemplo:

```nu
if $x > 0 { 'positivo' } else { 'no-positivo' }
```

Esta vez devuelve `'positivo'` cuando la condición es `true` (`$x` es mayor que cero) y `'no-positivo'` cuando la condición es `false` (`$x` es menor o igual a cero).

También podemos se pueden anidar múltiples `if`s de la siguiente manera:

```nu
if $x > 0 { 'positive' } else if $x == 0 { 'zero' } else { "negative" }
```

o bien:

```nu
if $x > 0 {
   'positive'
} else if $x == 0 {
   'zero'
} else {
   "negativo"
}
```

Cuando la primera condición es `true` (`$x` es mayor que cero) devolverá `'positivo'`, cuando la primera condición es `false` y la siguiente condición es `true` (`$x` es igual a cero) devolverá `'zero'`, de lo contrario devolverá `'negativo'` (cuando `$x` es menor que cero).

##### `match`

`match` ejecuta una de varias ramas condicionales basadas en el valor dado para coincidir. También puede hacer alguna coincidencia de patrones para desempaquetar valores en tipos compuestos como listas y registros.

El uso básico de `match` puede ejecutar condicionalmente diferentes códigos como una sentencia "switch" común en otros lenguajes. `match` comprueba si el valor después de la palabra `match` es igual al valor al comienzo de cada rama antes del `=>` y si lo es, ejecuta el código después del `=>` de esa rama.

```nu
match 2 {
    1 => 'one',
    2 => {
        let w = 'w'
        't' + $w + 'o'
    },
    3 => 'three',
    4 => 'four'
}
```

Las ramas pueden devolver un solo valor o, como se muestra en la segunda rama, pueden devolver los resultados de un bloque.

###### Rama comodín

También puede tener una condición comodín para cuando el valor dado no coincide con ninguna de las otras condiciones al tener una rama cuyo valor coincidente es `_`.

```nu
let foo = match 7 {
    1 => 'one',
    2 => 'two',
    3 => 'three',
    _ => 'other number'
}

$foo
```

> Notar que , `match` es una expresión, por lo que podemos asignar el resultado a una variable.

###### Coincidencia de patrones

Se pueden "desempaquetar" valores de tipos como listas y registros con coincidencia de patrones. Luego se puede asignar variables a las partes que se desea desempaquetar y usarlas en las expresiones coincidentes.

```nu
let foo = { name: 'bar', count: 7 }

match $foo {
    { name: 'bar', count: $it } => ($it + 3),
    { name: _, count: $it } => ($it + 7),
    _ => 1
}
```

El `_` en la segunda rama significa que coincide con cualquier registro con el campo `name` y `count`, no solo con aquellos donde `name` es `'bar'`.

###### Guardias

También puede agregar una condición adicional a cada rama llamada "guardia" (_guard_) para determinar si la rama debe coincidir. Para hacerlo, después del patrón coincidente, se utiliza un `if` y luego la condición antes del `=>`.

```nu
let foo = { name: 'bar', count: 7 }

match $foo {
    { name: 'bar', count: $it } if $it < 5 => ($it + 3),
    { name: 'bar', count: $it } if $it >= 5 => ($it + 7),
    _ => 1
}
```

#### Bucles

Los comandos de bucle permiten repetir un bloque de código varias veces.

##### Bucles y Otros Comandos de Iteración

La funcionalidad de los comandos de bucle es similar a los comandos que aplican un cierre sobre elementos en una lista o tabla como `each` o `where` y muchas veces se puede lograr lo mismo con cualquiera. Por ejemplo:

```nu
mut result = []
for $it in [1 2 3] {
   $result = ($result | append ($it + 1))
}

$result


[1 2 3] | each { $in + 1 }
```

Si bien puede ser tentador usar bucles si se está familiarizado con ellos en otros lenguajes, se considera más en el estilo Nushell (idiomático) usar comandos que aplican cierres cuando se puede resolver un problema de cualquier manera. La razón de esto es debido a una desventaja bastante grande con el uso de bucles.

###### Desventajas del Bucle

La mayor desventaja de los bucles es que son sentencias, a diferencia de `each` que es una expresión. Las expresiones, como `each` siempre resultan en algún valor de salida, sin embargo, las sentencias no.

Esto significa que no funcionan bien con variables inmutables y el uso de variables inmutables se considera más estilo Nushell. Sin una variable mutable declarada de antemano en el ejemplo de la sección anterior, sería imposible usar `for` para obtener la lista de números con números incrementados, o cualquier valor en absoluto.

Las sentencias tampoco funcionan en las _pipelines_ de Nushell, que requieren alguna salida. De hecho, Nushell dará un error si se intentas:

```nu
[1 2 3] | for x in $in { $x + 1 } | $in ++ [5 6 7]
Error: nu::parser::unexpected_keyword

  × Statement used in pipeline.
   ╭─[entry #5:1:1]
 1 │ [1 2 3] | for x in $in { $x + 1 } | $in ++ [5 6 7]
   ·           ─┬─
   ·            ╰── not allowed in pipeline
   ╰────
  help: 'for' keyword is not allowed in pipeline. Use 'for' by itself, outside of a pipeline.
```

Debido a que Nushell está muy orientado a la _pipeline_, esto significa que usar comandos de expresión como `each` es típicamente más natural que las sentencias de bucle.

###### Ventajas del Bucle

Si los bucles tienen una desventaja tan grande, ¿por qué existen? Bueno, una razón es que los cierres (_clousures_), como los que usa `each`, no pueden modificar variables mutables en el entorno circundante. Si se intentas modificar una variable mutable en un cierre, se obtendrá un error:

```nu
mut foo = []

[1 2 3] | each { $foo = ($foo | append ($in + 1)) }
Error: nu::parser::expected_keyword

  × Capture of mutable variable.
   ╭─[entry #8:1:1]
 1 │ [1 2 3] | each { $foo = ($foo | append ($in + 1)) }
   ·                  ──┬─
   ·                    ╰── capture of mutable variable
   ╰────
```

Si se modifica una variable de entorno en un cierre, se puede, pero solo se modificará dentro del alcance del cierre, dejándola sin cambios en cualquier otro lugar. Los bucles, sin embargo, usan bloques lo que significa que pueden modificar una variable mutable regular o una variable de entorno dentro del alcance mayor.

```nu
mut result = []

for $it in [1 2 3] { $result = ($result | append ($it + 1)) }

$result
```

##### `for`

`for` recorre un rango o colección como una lista o una tabla.

```nu
for x in [1 2 3] { $x * $x | print }
```

###### Alternativas de Comandos de Expresión

- `each`
- `par-each`
- `where`
- `reduce`

##### `while`

`while` repite el mismo bloque de código hasta que la condición dada es `false`.

```nu
mut x = 0;

while $x < 10 { $x = $x + 1 }

$x
```

###### Alternativas de Comandos de Expresión

Los comandos "until" y otros comandos "while"

- `take until`
- `take while`
- `skip until`
- `skip while`

##### `loop`

`loop` repite un bloque infinitamente. Se puede usar `break` (como se describe en la siguiente sección) para limitar cuántas veces se repite. También puede ser útil para ejecutar scripts continuamente, como un indicador interactivo.

```nu
mut x = 0; loop { if $x > 10 { break }; $x = $x + 1 }; $x

```

##### `break`

`break` detendrá la ejecución del código en un bucle y reanudará la ejecución después del bucle. Efectivamente "rompiendo" el bucle.

```nu
for x in 1..10 { if $x > 3 { break }; print $x }
```

##### `continue`

`continue` detendrá la ejecución del bucle actual, omitiendo el resto del código en el bucle, e irá al siguiente bucle. Si el bucle normalmente terminaría, como si `for` ha iterado a través de todos los elementos dados, o si la condición de `while` ahora es falsa, no se repetirá de nuevo y la ejecución continuará después del bloque de bucle.

```nu
mut x = -1
while $x <= 6 {
	$x = $x + 1;
	if $x mod 3 == 0 {
		continue
	}
	print $x
}

```

##### Errores

###### `error make`

`error make` crea un error que detiene la ejecución del código y cualquier código que lo haya llamado, hasta que sea manejado por un bloque `try`, o termine el script y muestre el mensaje de error. Esta funcionalidad es la misma que "excepciones" en otros lenguajes.

```nu
error make { msg: 'Some error info' }; print 'unprinted'


Error:   × Some error info
   ╭─[entry #9:1:1]
 1 │ print 'printed'; error make { msg: 'Some error info' }; print 'unprinted'
   ·                  ─────┬────
   ·                       ╰── originates from here
   ╰────
```

El registro que se le pasa proporciona información al código que lo captura o al mensaje de error resultante.

###### `try`

`try` capturará los errores creados en cualquier lugar del bloque de código de `try` y reanudará la ejecución del código después del bloque.

```nu
try { error make { msg: 'Some error info' }}; print 'Resuming'

```

Esto incluye la captura de errores incorporados.

```nu
try { 1 / 0 }; print 'Resuming'
```

El valor resultante será `nothing` si ocurre un error y el valor devuelto del bloque si no ocurre un error.

Si se incluye un bloque `catch` después del bloque `try`, ejecutará el código en el bloque `catch` si ocurrió un error en el bloque `try`.

```nu
try { 1 / 0 } catch { 'An error happened!' } | $in ++ ' And now I am resuming.'
```

> No se ejecutará el bloque `catch` si no se produce un error.

```nu
try { 1 / 0 } catch { |e| $e.msg }
```

##### Otros

###### `return`

`return` finaliza un cierre o comando anticipadamente donde se llama, sin ejecutar el resto del comando/cierre, y devuelve el valor dado. No es a menudo necesario ya que el último valor en un cierre o comando también se devuelve, pero a veces puede ser conveniente.

```nu
def 'positive-check' [it] {
    if $it > 0 {
        return 'positive'
    };

    'non-positive'
}
```

```nu
positive-check 3

positive-check (-3)

let positive_check = {|elt| if $elt > 0 { return 'positive' }; 'non-positive' }

do $positive_check 3

do $positive_check (-3)
```



## Conversión de One-Liners en Herramientas de Línea de Comandos

A lo largo de este libro se construirán numerosos pipelines compactos de una sola línea (*one-liners*). Cuando se requiere reutilizar un *one-liner* frecuentemente sobre distintos archivos o con diferentes parámetros, conviene transformarlo en una **herramienta de línea de comandos ejecutable**.

En `/data/ch04` contamos con el texto completo de *Las aventuras de Alicia en el país de las maravillas* (`alice.txt`) y una lista de palabras vacías del idioma inglés (`stopwords`):

```nu
ls
```

En primer lugar, se muestra cómo obtener las 10 palabras más frecuentes de `alice.txt` en Nushell (sin filtrar y filtrando *stopwords*), mostrando el resultado en pantalla y guardándolo también en un archivo CSV:

```nu
open --raw alice.txt |
  str lowercase |
  parse --regex '(?P<word>[a-z]{2,})' |
  get word |
  uniq -c |
  rename word count |
  sort-by count --reverse |
  first 10
```

A continuación se filtran las palabras vacías contenidas en el archivo `stopwords` y guardamos el resultado tanto en pantalla como en el archivo `top10_alice.csv`:

```nu
let sw = open --raw stopwords | lines | each { str trim | str lowercase }
let top10 = open --raw alice.txt
    | str lowercase
    | parse --regex '(?P<word>[a-z]{2,})'
    | get word
    | where { |w| not ($w in $sw) }
    | uniq -c
    | rename word count
    | sort-by count --reverse
    | first 10

$top10
$top10 | save -f top10_alice.csv
```

Para convertir este *one-liner* en una herramienta de línea de comandos reutilizable y parametrizada en Nushell, se siguen **6 pasos sistemáticos**:

1. Crear el archivo de script (`top-words-1.nu`).
2. Otorgar permisos de ejecución (`chmod u+x`).
3. Definir la directiva *shebang* (`#!/usr/bin/env -S nu --stdin`).
4. Generalizar la entrada para leer dinámicamente desde el pipe (`$in`).
5. Añadir argumentos y opciones tipadas mediante `def main [...]`.
6. Extender la variable de entorno `$env.PATH`.

### Paso 1: Crear el Archivo

En `/data/ch04` se almacena el pipeline inicial dentro del script `top-words-1.nu` (el cual puede editarse interactivamente con `ttt top-words-1.nu`):

```nu
# skip-docker-exec (código de top-words-1.nu)
# Código de top-words-1.nu
let sw = if ("stopwords" | path exists) {
    open --raw stopwords | lines | each { str trim | str lowercase }
} else {
    []
}
open --raw alice.txt
| str lowercase
| parse --regex "(?P<word>[a-z]{2,})"
| get word
| where { |w| not ($w in $sw) }
| uniq -c
| rename word count
| sort-by count --reverse
| first 10
```

Para inspeccionar el contenido de un script o archivo de código fuente desde la terminal, Nushell permite imprimir su texto directamente mediante `open --raw <archivo>`. Adicionalmente, para una lectura más cómoda con resaltado de sintaxis y numeración de líneas, el entorno dispone de la utilidad especializada **`bat`** (`bat top-words-1.nu`). A partir de este punto se adoptará preferentemente `bat` para la visualización de código:

```nu
open --raw top-words-1.nu
bat top-words-1.nu
nu top-words-1.nu
nu top-words-1.nu | save -f salida_paso1.csv
```

### Paso 2: Dar Permisos de Ejecución

Se copia `top-words-1.nu` a `top-words-2.nu` y se le otorgan permisos de ejecución para el usuario propietario mediante `chmod u+x`:

```nu
# skip-docker-exec (código de top-words-2.nu)
# Código de top-words-2.nu (idéntico en contenido a top-words-1.nu)
let sw = if ("stopwords" | path exists) {
    open --raw stopwords | lines | each { str trim | str lowercase }
} else {
    []
}
open --raw alice.txt
| str lowercase
| parse --regex "(?P<word>[a-z]{2,})"
| get word
| where { |w| not ($w in $sw) }
| uniq -c
| rename word count
| sort-by count --reverse
| first 10
```

Se configuran y verifican los permisos con `chmod` y `ls`:

```nu
cp top-words-1.nu top-words-2.nu
chmod u+x top-words-2.nu
ls -l top-words-1.nu top-words-2.nu | select name mode size
```

En la columna `mode` (por ejemplo, `-rwxr-xr-x`), el primer carácter `-` indica un archivo regular, mientras que las ternas siguientes corresponden a los permisos de lectura (`r`), escritura (`w`) y ejecución (`x`) del usuario propietario (`u`), grupo (`g`) y otros usuarios (`o`).

### Paso 3: Definir el Shebang

La directiva *shebang* (`#!/usr/bin/env -S nu --stdin`) en la primera línea del archivo le instruye al núcleo del sistema operativo qué intérprete invocar cuando el script se llama directamente como un binario ejecutable (`./top-words-3.nu`):

```nu
# skip-docker-exec (código de top-words-3.nu)
# Código de top-words-3.nu
#!/usr/bin/env -S nu --stdin
let sw = if ("stopwords" | path exists) {
    open --raw stopwords | lines | each { str trim | str lowercase }
} else {
    []
}
open --raw alice.txt
| str lowercase
| parse --regex "(?P<word>[a-z]{2,})"
| get word
| where { |w| not ($w in $sw) }
| uniq -c
| rename word count
| sort-by count --reverse
| first 10
```

Se visualiza el script con `bat` y se ejecuta directamente:

```nu
bat top-words-3.nu
./top-words-3.nu
./top-words-3.nu | save -f salida_paso3.json
```

### Paso 4: Remover la Entrada Fija

Al reemplazar la referencia fija a `alice.txt` por la variable especial `$in` dentro de una función `main` en `top-words-4.nu`, la herramienta queda desacoplada de cualquier archivo concreto y puede procesar cualquier flujo recibido a través de una tubería (`|`):

```nu
# skip-docker-exec (código de top-words-4.nu)
# Código de top-words-4.nu
#!/usr/bin/env -S nu --stdin
def main [] {
    $in
    | str lowercase
    | parse --regex "(?P<word>[a-z]{2,})"
    | get word
    | uniq -c
    | sort-by count --reverse
    | first 10
}
```

Se inspecciona con `bat` y se prueba la canalización desde la terminal:

```nu
bat top-words-4.nu
open --raw alice.txt | ./top-words-4.nu
open --raw alice.txt | ./top-words-4.nu | save -f salida_paso4.json
```

### Paso 5: Añadir Argumentos y Opciones Tipadas (`def main`)

Al declarar parámetros formales en `def main [num_words: int = 10, --stopwords-file (-s): path = "stopwords"]` dentro de `top-words-5.nu`, Nushell asume la validación estática de tipos, asigna valores predeterminados y genera automáticamente el panel de ayuda `--help`:

```nu
# skip-docker-exec (código de top-words-5.nu)
# Código de top-words-5.nu
#!/usr/bin/env -S nu --stdin

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
```

Se inspecciona con `bat` y se ejecuta especificando parámetros posicionales:

```nu
bat top-words-5.nu
open --raw alice.txt | ./top-words-5.nu 8
open --raw alice.txt | ./top-words-5.nu 8 | save -f top8_alice.json
```

### Paso 6: Extender el `$env.PATH`

Para invocar la herramienta desde cualquier ubicación del sistema de archivos sin necesidad del prefijo `./`, se instala el script en un directorio registrado dentro de `$env.PATH` (como `/home/dsin/bin`):

```nu
cp top-words-5.nu /home/dsin/bin/top-words-nu
chmod +x /home/dsin/bin/top-words-nu
open --raw alice.txt | top-words-nu 5
open --raw alice.txt | top-words-nu 5 | save -f top5_alice.json
```

## Creando Herramientas de Línea de Comandos con Python y R

Dado que la línea de comandos es agnóstica al lenguaje, podemos combinar scripts escritos en **Python** (`#!/usr/bin/env python3`) y **R** (`#!/usr/bin/env Rscript`) dentro de nuestros pipelines de Nushell. Siguiendo las buenas prácticas de este libro, siempre creamos o inspeccionamos primero el archivo `.py` o `.R` en el directorio del capítulo y luego lo invocamos desde Nushell, convirtiendo su salida en una tabla estructurada con `from csv` y guardando los resultados.

### Portando la Herramienta a Python (`top-words.py`) y R (`top-words.R`)

En `/data/ch04` disponemos de las implementaciones completas en Python (`top-words.py`) y en R (`top-words.R`). Inspeccionemos primero el archivo `top-words.py` y ejecutémoslo desde Nushell:

```nu
bat top-words.py
open --raw alice.txt | python3 top-words.py 5 | from csv
open --raw alice.txt | python3 top-words.py 5 | from csv | save -f top_words_py.csv
```

Ahora inspeccionemos el script en R (`top-words.R`), ejecutémoslo sobre `alice.txt`, transformemos su salida a una tabla de Nushell y guardémosla en `top_words_r.csv`:

```nu
bat top-words.R
open --raw alice.txt | Rscript top-words.R 5 | from csv
open --raw alice.txt | Rscript top-words.R 5 | from csv | save -f top_words_r.csv
```

### Procesando Datos en Transmisión (*Streaming*) desde `stdin` (`fizzbuzz.py` y `fizzbuzz.R`)

Cuando la entrada es un flujo línea por línea, tanto Python como R pueden procesar cada línea conforme llega desde `stdin`. En `/data/ch04` contamos con `fizzbuzz.py` y `fizzbuzz.R`, que implementan el problema clásico de *FizzBuzz* (imprimir `"fizz"` si el número es divisible por 3, `"buzz"` si es divisible por 5, y `"fizzbuzz"` si es divisible por 15):

```nu
bat fizzbuzz.py
1..15 | to text | python3 fizzbuzz.py | lines | wrap resultado_py
1..15 | to text | python3 fizzbuzz.py | lines | wrap resultado_py | save -f fizzbuzz_py.csv
```

Y de manera idéntica con el script `fizzbuzz.R`:

```nu
bat fizzbuzz.R
1..15 | to text | Rscript fizzbuzz.R | lines | wrap resultado_r
1..15 | to text | Rscript fizzbuzz.R | lines | wrap resultado_r | save -f fizzbuzz_r.csv
```




\newpage

# Obtención de Datos {#chapter-5-data-acquisition}

Este capítulo aborda el primer paso del modelo OSEMN: la **obtención de datos** (*Obtain*). Los datos pueden provenir de archivos locales, servidores web HTTP/HTTPS, archivos comprimidos (`.tar.gz`, `.zip`), hojas de cálculo de Microsoft Excel (`.xlsx`), bases de datos relacionales SQLite (`.db`) o APIs web REST y de transmisión continua (*streaming*).

Comenzamos ingresando al directorio `/data/ch05`, que ya viene incluido por defecto en el contenedor `dsin`:

```nu
cd /data/ch05
```

A partir de este punto, todos los comandos del capítulo se ejecutan dentro de `/data/ch05`. Inspeccionemos sus archivos disponibles:

```nu
ls | sort-by name
```

## Copiando Archivos Locales en el Contenedor Docker

Aunque la imagen `dsin` ya incluye todos los conjuntos de datos del libro en `/data/ch03` a `/data/ch09`, en proyectos propios es frecuente necesitar transferir archivos adicionales entre el computador anfitrión y el contenedor Docker:

- **Montando una carpeta local al iniciar el contenedor:** Ejecutando `docker run --rm -it -v "$(pwd):/data/mis_datos" ghcr.io/kurokirasama/dsin:latest`.
- **Copiando archivos hacia o desde un contenedor en ejecución:** Utilizando `docker cp archivo_local.csv <container_id>:/data/ch05/` desde el sistema anfitrión.

## Descargando desde Internet con `http get`

Nushell incorpora su propio cliente HTTP nativo (`http get`, `http post`, `http head`, `http put`, `http delete`) que reemplaza a herramientas clásicas como `curl` o `wget`. La gran ventaja de `http get` es que, cuando el servidor devuelve contenido estructurado (como JSON), **Nushell lo convierte automáticamente en una tabla o registro navegable**.

### Descargando Archivos JSON y Páginas Web

En `/data/ch05` contamos con el archivo `urls.json` y muestras de publicaciones JSON. Cuando consultamos un *endpoint* REST o abrimos `posts_sample.json`, podemos explorar la tabla devuelta y guardarla inmediatamente en disco con `save -f`:

```nu
let response = open posts_sample.json
$response | first 3 | select userId id title
$response | save -f posts.json
open posts.json | first 3 | select id title
```

Si descargamos o leemos un documento HTML (como `MolinosFriesland.html` en `/data/ch05`), podemos inspeccionar sus primeras líneas con `open --raw` y guardar un extracto procesado:

```nu
# skip-docker-exec (requiere descarga web previa)
open --raw MolinosFriesland.html | lines | first 10
open --raw MolinosFriesland.html | lines | first 10 | to text | save -f molinos_encabezado.txt
```

### Descargando desde Múltiples URLs y Consultas `http post`

En `/data/ch05/urls.json` tenemos una lista de *endpoints* bajo la clave `urls`:

```nu
open urls.json
open urls.json | get urls
open urls.json | get urls | to text | save -f lista_urls.txt
```

Cuando trabajamos con conexión a Internet, podemos recorrer todas las URLs con `each { |u| http get $u }` o enviar cargas útiles (*payloads*) JSON a un servidor mediante `http post`:

```nu
# skip-docker-exec
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

Cuando un conjunto de datos posee un volumen considerable o agrupa múltiples archivos, habitualmente se distribuye comprimido en formatos como `.tar.gz`, `.zip` o `.7z`.

En `/data/ch05` se dispone del archivo comprimido `logs.tar.gz`. Antes de proceder a su extracción, resulta conveniente examinar su tabla de contenidos. Esto puede realizarse tanto con la utilidad estándar `tar` (`-tzf`) como con la herramienta universal **`7z`** (utilizando el subcomando `l` para listar el contenido):

```nu
tar -tzf logs.tar.gz | lines | first 10
tar -tzf logs.tar.gz | lines | save -f indice_logs.txt
7z l logs.tar.gz
```

Dado que los archivos empaquetados en `logs.tar.gz` no residen dentro de un directorio raíz propio, se crea previamente la carpeta `logs_extraidos` y se procede a la descompresión. En primer lugar, se muestra la extracción mediante `tar` con la opción `-C`:

```nu
rm -rf logs_extraidos
mkdir logs_extraidos
tar -xzf logs.tar.gz -C logs_extraidos
```

De forma equivalente, la descompresión puede llevarse a cabo utilizando **`7z`**. Dado que `logs.tar.gz` corresponde a un archivo `.tar` comprimido con `gzip`, es posible extraerlo de manera directa canalizando la salida estándar de `7z` a través de un pipeline sin escribir archivos intermedios en disco (`-so` para emitir hacia *stdout* y `-si` para leer desde *stdin* con `-o` para especificar la carpeta de destino):

```nu
rm -rf logs_7z
mkdir logs_7z
7z x logs.tar.gz -so | 7z x -si -ttar -o./logs_7z
```

Una vez finalizada la extracción, se consolida el tamaño y el número de líneas de cada archivo de registro en una tabla estructurada de Nushell, guardando el resultado en `resumen_logs.csv`:

```nu
let resumen_logs = ls logs_extraidos
    | each { |f|
        {
            archivo: ($f.name | path basename)
            bytes: $f.size
            lineas: (open --raw $f.name | lines | length)
        }
    }
    | sort-by archivo
$resumen_logs | first 5
$resumen_logs | save -f resumen_logs.csv
```

## Conversión de Hojas de Cálculo de Microsoft Excel y Archivos CSV

El formato CSV (*Comma-Separated Values*) almacena registros tabulares separados por saltos de línea y campos delimitados por comas. En `/data/ch05` se tienen tres variantes del conjunto de datos de las Tortugas Ninja (`tmnt-with-header.csv`, `tmnt-basic.csv` y `tmnt-missing-newline.csv`).

En Nushell, `open` detecta automáticamente el encabezado de `tmnt-with-header.csv`:

```nu
open tmnt-with-header.csv
open tmnt-with-header.csv | save -f tmnt_con_encabezado.json
```

Si un archivo CSV **no posee fila de encabezado** (como `tmnt-missing-newline.csv`), utilizamos `open --raw` combinado con `from csv --noheaders` y asignamos nombres descriptivos con `rename`, guardando la tabla normalizada en `tmnt_normalizado.csv`:

```nu
open --raw tmnt-missing-newline.csv | from csv --noheaders | rename nombre apodo color arma
open --raw tmnt-missing-newline.csv | from csv --noheaders | rename nombre apodo color arma | save -f tmnt_normalizado.csv
```

Por su parte, para trabajar con hojas de cálculo de **Microsoft Excel (`.xlsx` y `.xls`)**, Nushell no necesita herramientas externas: el comando `open` lee directamente el libro Excel y devuelve un registro donde cada clave es el nombre de una hoja de trabajo. Inspeccionemos `cars.xlsx` en `/data/ch05`:

```nu
open cars.xlsx | columns
```

Vemos que `cars.xlsx` contiene la hoja `autos`. Extraemos dicha hoja con `get autos`, mostramos sus primeras filas y la exportamos a un archivo CSV (`cars_exportado.csv`):

```nu
open cars.xlsx | get autos | first 5 | select make "body.style" horsepower "city.mpg" price
open cars.xlsx | get autos | save -f cars.csv
open cars.xlsx | get autos | save -f cars_exportado.csv
```

Si deseamos filtrar únicamente los vehículos de la marca `toyota` usando una expresión regular (`^toyota$`), mostramos la tabla resultante y la guardamos en `cars_toyota.csv`:

```nu
open cars.csv | where make =~ '^toyota$' | select make "body.style" "engine.size" horsepower price | first 8
open cars.csv | where make =~ '^toyota$' | save -f cars_toyota.csv
```

## Consultando Bases de Datos Relacionales (SQLite)

En `/data/ch05` disponemos de la base de datos relacional SQLite `r-datasets.db`, que almacena conjuntos de datos clásicos de R. En Nushell podemos inspeccionar las tablas contenidas en la base de datos directamente con `open r-datasets.db | columns`:

```nu
open r-datasets.db | columns | first 10
```

Para ejecutar consultas SQL `SELECT` directamente sobre `r-datasets.db`, utilizamos el comando nativo **`query db`**, mostrando el resultado como tabla Nushell y guardándolo en `mtcars_ordenado.csv`:

```nu
open r-datasets.db | query db "SELECT row_names, mpg, cyl, hp, wt FROM mtcars ORDER BY mpg DESC" | first 8
open r-datasets.db | query db "SELECT row_names, mpg, cyl, hp, wt FROM mtcars ORDER BY mpg DESC" | save -f mtcars_ordenado.csv
```

También podemos realizar agrupaciones SQL directamente con `query db` y guardar el resumen en `mtcars_por_cilindros.csv`:

```nu
let resumen_cyl = open r-datasets.db
    | query db "SELECT cyl, COUNT(*) AS n_autos, ROUND(AVG(mpg), 2) AS mpg_promedio, ROUND(AVG(hp), 1) AS hp_promedio FROM mtcars GROUP BY cyl ORDER BY cyl"
$resumen_cyl
$resumen_cyl | save -f mtcars_por_cilindros.csv
```

## Llamando a las API Web

Las APIs web (*Application Programming Interfaces*) devuelven datos estructurados (generalmente en formato JSON) listos para ser consumidos y procesados dentro de los pipelines de Nushell. En la práctica analítica contemporánea, gran parte de los datos no reside en archivos locales, sino en plataformas remotas accesibles mediante peticiones HTTP autenticadas o flujos de eventos en tiempo real.

A continuación, examinaremos la autenticación con claves y cuatro casos de estudio prácticos en Nushell, estructurados como comandos y módulos reutilizables listos para integrarse en pipelines de datos:

1. **Construcción de URLs autenticadas con News API:** Generación segura de endpoints mediante registros y `url join`.
2. **Geocodificación con la API de Google Maps:** Conversión bidireccional entre direcciones postales y coordenadas geográficas (latitud y longitud).
3. **Traducción Automatizada con Google Translate:** Traducción dinámica de cadenas y flujos de texto en pipelines analíticos.
4. **Búsqueda Web Estructurada con Ollama Search:** Consulta en vivo e ingesta de resultados web formateados como tablas de Nushell.
5. **Flujos de Eventos en Tiempo Real (*Streaming*):** Procesamiento de streams continuos con Wikimedia EventStreams.

Todos los módulos y ejemplos de esta sección se ubican en el directorio `/data/ch05` (con réplicas disponibles en `/data/ch04`):

```nu
cd /data/ch05
```

### Autenticación con Clave API y Construcción de URLs

Muchas APIs web (como *News API* o *Google Maps*) requieren una clave de autenticación almacenada de forma segura en un archivo local (por ejemplo, `.secret/newsapi.org_apikey` en `/data/ch05`). En Nushell leemos la clave con `open --raw` y construimos la URL autenticada de manera limpia con `url join`:

```nu
# skip-docker-exec (requiere clave de API en .secret)
let api_key = open --raw .secret/newsapi.org_apikey | str trim
let news_url = {
    scheme: "https"
    host: "newsapi.org"
    path: "/v2/everything"
    params: {
        q: "linux"
        apiKey: $api_key
    }
} | url join
$news_url
$news_url | save -f news_endpoint.txt
```

### Geocodificación con la API de Google Maps

De acuerdo con la [documentación oficial de Geocoding API de Google Maps](https://developers.google.com/maps/documentation/geocoding/overview), el servicio permite convertir direcciones postales en coordenadas geográficas (geocodificación directa) o transformar pares de latitud y longitud en una dirección formateada legible (geocodificación inversa) mediante peticiones HTTP GET.

#### Obtención de la Clave de Acceso (API Key)

Para utilizar los servicios de Google Maps Platform se requiere una clave de acceso (*API Key*) generada en [Google Cloud Console](https://console.cloud.google.com/):

1. Ingrese a Google Cloud Console con su cuenta de Google.
2. Cree un nuevo proyecto o seleccione uno existente desde la barra superior.
3. Diríjase a **APIs & Services** $\rightarrow$ **Library**.
4. Busque **Geocoding API** y haga clic en **Enable**.
5. Diríjase a **APIs & Services** $\rightarrow$ **Credentials**.
6. Haga clic en **Create Credentials** $\rightarrow$ **API Key**. Copie la clave generada y consérvela en un entorno seguro.

#### Anatomía de la Petición y url join

Para consultar la API, construimos una URL con esquema `https`, servidor `maps.googleapis.com`, ruta `/maps/api/geocode/json` y parámetros de consulta (`address` o `latlng`, junto con la clave `key`).

En lugar de concatenar cadenas manualmente (lo cual induce errores con espacios y caracteres especiales), Nushell provee el comando **`url join`**, que compone y codifica de manera automática una URL válida a partir de un registro estructurado:

```nu
let mapsAPIkey = "the_api_key"
let address = "Paseo Yugoslavo 176, Valparaiso, Chile"
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

De igual forma, el comando inverso **`url parse`** descompone cualquier URL en sus elementos constitutivos como un registro de Nushell:

```nu
open consulta_maps.json | url join | url parse
```

Al despachar la petición mediante `http get $url`, la respuesta JSON de Google Maps entrega una tabla `results`, dentro de la cual se encuentra el registro `geometry.location` con los campos `lat` y `lng`:

```nu
# Estructura de respuesta devuelta por Google Geocoding API
let sample_response = {
    status: "OK"
    results: [
        {
            formatted_address: "Paseo Yugoslavo 176, Valparaíso, Región de Valparaíso, Chile"
            geometry: {
                location: { lat: -33.0400281, lng: -71.6289843 }
            }
        }
    ]
}
$sample_response.results | select formatted_address
$sample_response.results.geometry.location
$sample_response.results.geometry.location | save -f coordenadas.json
```

#### Implementación del Módulo maps.nu

Empaquetamos estas operaciones en el módulo `/data/ch05/maps.nu` (también disponible en `/data/ch04/maps.nu`). Su código fuente completo es el siguiente:

```nu
# Módulo de geocodificación con la API de Google Maps

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

    let response = http get $url
    if $response.status != "OK" {
        error make -u {msg: "address not found!"}
    }
    $response.results.0.formatted_address
}
```

Para utilizar el módulo, lo importamos en nuestra sesión interactiva con `use maps.nu *`:

```nu
# skip-docker-exec
use maps.nu *
loc-from-address "Paseo Yugoslavo 176, Valparaiso, Chile"
address-from-loc -33.0400281 -71.6289843
```

### Traducción Automatizada con Google Translate

El segundo caso aborda la traducción de textos y etiquetas dentro de pipelines de datos. De acuerdo con la [documentación de Google Cloud Translation API](https://cloud.google.com/translate/docs/basic/translating-text), el servicio traduce texto de forma dinámica entre decenas de idiomas mediante peticiones HTTP.

#### Obtención de la Clave de Acceso (API Key)

1. En la misma consola de [Google Cloud Console](https://console.cloud.google.com/), ingrese a su proyecto.
2. Diríjase a **APIs & Services** $\rightarrow$ **Library**.
3. Busque **Cloud Translation API** y presione **Enable**.
4. Puede reutilizar la API Key creada para Google Maps o generar una nueva en **APIs & Services** $\rightarrow$ **Credentials** $\rightarrow$ **Create Credentials** $\rightarrow$ **API Key**.

#### Implementación del Módulo translate.nu

El módulo `/data/ch05/translate.nu` permite recibir texto tanto a través del pipeline (`$in`) como por argumento posicional (`text`), con parámetros opcionales para idioma de origen (`--source`, con auto-detección por defecto) e idioma de destino (`--destination`, con español por defecto). Si no se proporciona una clave comercial, el script utiliza de forma alternativa el endpoint web directo de Google Translate, permitiendo pruebas inmediatas:

```nu
# Módulo de traducción con Google Translate

export def trans [
    text?: string                      # Texto a traducir (o desde el pipeline $in)
    --source (-s): string = "auto"     # Idioma de origen (por defecto auto-detección)
    --destination (-d): string = "es"  # Idioma de destino (por defecto español)
    --api-key (-k): string = ""        # Clave opcional de Google Cloud Translation API
] {
    let input_text = if ($text | is-empty) { $in } else { $text }
    if ($input_text | is-empty) {
        error make -u { msg: "Debe proporcionar un texto para traducir (como argumento o mediante tubería)." }
    }

    if ($api_key | is-not-empty) {
        let url = {
            scheme: "https"
            host: "translation.googleapis.com"
            path: "/language/translate/v2"
            params: {
                key: $api_key
                q: $input_text
                source: (if $source == "auto" { "" } else { $source })
                target: $destination
                format: "text"
            }
        } | url join

        let response = http post $url {}
        $response.data.translations.0.translatedText
    } else {
        let url = {
            scheme: "https"
            host: "translate.googleapis.com"
            path: "/translate_a/single"
            params: {
                client: "gtx"
                sl: $source
                tl: $destination
                dt: "t"
                q: $input_text
            }
        } | url join

        http get $url | get 0.0.0
    }
}
```

Importamos el comando `trans` y lo aplicamos en nuestras tuberías:

```nu
# skip-docker-exec
use translate.nu *
"Data science workflows at the command line" | trans
trans "Structured data pipelines in Nushell" --destination "fr"
```

### Búsqueda Web e Ingesta con Ollama Search API

El tercer caso de estudio integra búsquedas en la web en vivo directamente hacia tablas tipadas de Nushell utilizando la API de búsqueda web de [Ollama](https://ollama.com). Esto permite a los pipelines de datos enriquecer datasets con información actualizada en internet sin recurrir a navegadores gráficos ni volcados de HTML desestructurados.

#### Obtención del Token de Acceso (API Key)

1. Regístrese o inicie sesión en [ollama.com](https://ollama.com).
2. Diríjase a la sección de configuración de claves de su cuenta en [ollama.com/settings/keys](https://ollama.com/settings/keys).
3. Genere y copie su clave personal de API (*Ollama API Key*).
4. En Nushell, puede exportar la variable de entorno `$env.OLLAMA_API_KEY = "su_clave"` en su configuración o pasarla explícitamente con el parámetro `--api-key` (`-k`).

#### Implementación del Módulo ollama_search.nu

El módulo `/data/ch05/ollama_search.nu` realiza una petición HTTP POST con el encabezado de autenticación `Authorization: Bearer <token>`, recibe la respuesta estructurada en formato JSON y devuelve directamente los resultados como una tabla de Nushell (o como texto Markdown si se activa la bandera `--md`):

```nu
# Módulo de búsqueda web estructurada mediante Ollama Search API

export def ollama-search [
    query: string                      # Consulta de búsqueda web
    --max-results (-n): int = 5        # Cantidad máxima de resultados a devolver
    --api-key (-k): string = ""        # Token de autenticación de Ollama
    --md (-m)                          # Formatear la salida como texto Markdown
    --verbose (-v)                     # Mostrar mensajes informativos
] {
    let token = if ($api_key | is-not-empty) {
        $api_key
    } else {
        try { $env.OLLAMA_API_KEY } catch { "" }
    }

    if ($token | is-empty) {
        error make -u { msg: "Se requiere un token de Ollama. Use --api-key (-k) o defina $env.OLLAMA_API_KEY." }
    }

    let url = "https://ollama.com/api/web_search"
    let body = { query: $query, max_results: $max_results }
    let headers = {
        Authorization: $"Bearer ($token)"
        "Content-Type": "application/json"
    }

    if $verbose { print $"Consultando la web mediante Ollama Search API: ($query)" }

    let response = try {
        http post -t application/json $url -H $headers $body -e
    } catch { |e|
        error make -u { msg: $"Error de conexión con Ollama Search API: ($e.msg)" }
    }

    let data = if ($response | describe) == "string" {
        $response | from json
    } else {
        $response
    }

    if ($data | get -o error | is-not-empty) {
        error make -u { msg: $"Ollama API Error: ($data.error)" }
    }

    if $md {
        return (
            $data.results
            | default []
            | each { |item|
                [
                    $"# ($item.title)"
                    $"link: ($item.url)"
                    ""
                    $item.content
                ] | str join (char nl)
            }
            | str join $"(char nl)(char nl)"
        )
    }

    $data.results | default []
}
```

Podemos utilizar la herramienta para alimentar pipelines posteriores con comandos como `select`, `where` o `save`:

```nu
# skip-docker-exec
use ollama_search.nu *
ollama-search "nushell data science pipelines" -n 3 | select title url
ollama-search "command line data science" --md | save -f resultados_busqueda.md
```

### API de Transmisión (*Streaming*)

Algunas APIs web transmiten eventos en tiempo real de forma continua, como el flujo *EventStreams* de Wikimedia (`https://stream.wikimedia.org/v2/stream/recentchange`). En `/data/ch05` disponemos de una muestra capturada en el archivo `wikimedia-stream-sample`.

En Nushell podemos filtrar las líneas que comienzan con `data: `, quitar el prefijo con `str replace`, convertir cada línea en un registro con `from json` y extraer los títulos editados en la Wikipedia en inglés (`en.wikipedia.org`), mostrando la tabla en pantalla y guardándola en `wikimedia_edits_en.csv`:

```nu
let edits_en = open --raw wikimedia-stream-sample
    | lines
    | where ($it | str starts-with "data: ")
    | each { |line| $line | str replace "^data: " "" | from json }
    | where ($it.type? == "edit") and ($it.server_name? == "en.wikipedia.org")
    | select -o title user bot timestamp

$edits_en | first 10
$edits_en | save -f wikimedia_edits_en.csv
```




\newpage

# Depuración y Transformación de Datos {#chapter-6-data-cleaning}

Este capítulo aborda el segundo paso del modelo OSEMN: **depurar y transformar los datos** (*Scrub*). Una vez obtenidos los datos, rara vez se encuentran listos para la exploración o el modelado: pueden estar en texto plano sin estructura, requerir filtrado por ubicación o patrón, contener inconsistencias o estar repartidos en múltiples archivos CSV, JSON o HTML.

Comenzamos ingresando al directorio `/data/ch06`:

```nu
cd /data/ch06
```

A partir de este punto, todos los ejemplos de este capítulo se desarrollan dentro de `/data/ch06`. Inspeccionemos sus archivos:

```nu
ls | sort-by name
```

## Transformaciones en un Pipeline de Datos

Con frecuencia, la salida de una herramienta requiere una transformación intermedia antes de poder alimentar la siguiente etapa del análisis. Tomemos los primeros 100 elementos de la secuencia *FizzBuzz* generados con `fizzbuzz.py` en `/data/ch06`, guardémoslos en `fb.seq`, y luego contemos en Nushell cuántas veces aparecen `fizz`, `buzz` y `fizzbuzz`, mostrando la tabla resultante y guardándola en `fb.csv`:

```nu
1..100 | to text | python3 fizzbuzz.py | save -f fb.seq
let conteo_fb = open --raw fb.seq
    | lines
    | where ($it =~ "fizz|buzz")
    | uniq -c
    | rename value count
    | sort-by count --reverse
$conteo_fb
$conteo_fb | save -f fb.csv
```

## Texto Plano

El texto plano (*plain text*) consiste en secuencias de caracteres legibles por humanos divididas por saltos de línea. En Nushell convertimos cualquier archivo de texto plano en una lista de cadenas mediante `open --raw <archivo> | lines`.

### Filtrando Líneas

#### Basado en la Ubicación

En `/data/ch06` disponemos del archivo `lines` con 10 líneas numeradas (`Line 1` a `Line 10`). Veamos cómo filtrar líneas según su posición con `first`, `last`, `skip`, `drop` y `slice`, mostrando los resultados y guardando los subconjuntos en archivos:

```nu
open --raw lines | lines
```

- **Primeras 3 líneas (`first 3`) y últimas 3 líneas (`last 3`):**

```nu
open --raw lines | lines | first 3
open --raw lines | lines | last 3
open --raw lines | lines | first 3 | to text | save -f lines_primeras3.txt
```

- **Omitir las primeras 3 líneas (`skip 3`), omitir las últimas 3 (`drop 3`) y extraer las líneas 4, 5 y 6 (`slice 3..5`):**

```nu
open --raw lines | lines | skip 3
open --raw lines | lines | drop 3
open --raw lines | lines | slice 3..5
open --raw lines | lines | slice 3..5 | to text | save -f lines_4_a_6.txt
```

- **Extraer únicamente las líneas en posiciones impares usando `enumerate` y el operador módulo (`mod`):**

```nu
open --raw lines | lines | enumerate | where ($it.index mod 2) == 0 | get item
open --raw lines | lines | enumerate | where ($it.index mod 2) == 0 | get item | to text | save -f lines_impares.txt
```

#### Basado en un Patrón

Para conservar o descartar líneas según una expresión regular, utilizamos `where ($it =~ "patrón")` (o `!~` para invertir la coincidencia). En `/data/ch06/alice.txt`, extraigamos los encabezados de capítulos que comienzan con `CHAPTER` seguidos de `The`, y contemos el total de líneas no vacías del libro:

```nu
open --raw alice.txt | lines | where ($it =~ '(?i)^chapter')
open --raw alice.txt | lines | where ($it =~ '^CHAPTER (.*)\. The')
open --raw alice.txt | lines | where ($it =~ '^CHAPTER (.*)\. The') | to text | save -f capitulos_the.txt
open --raw alice.txt | lines | where ($it | str trim | is-not-empty) | length
```

#### Basado en Aleatoriedad (Muestreo)

Cuando formulamos un pipeline sobre un archivo muy grande, resulta útil tomar una muestra aleatoria con el comando nativo **`shuffle`** combinado con **`first`**:

```nu
1..1000 | each { |i| $"Line ($i)" } | shuffle | first 10
1..1000 | each { |i| $"Line ($i)" } | shuffle | first 10 | to text | save -f muestra_10_lineas.txt
```

### Extrayendo Valores

Para extraer únicamente el número romano y el título de cada capítulo de `alice.txt` en una tabla estructurada de dos columnas, usamos `parse --regex` con grupos con nombre y guardamos el resultado en `capitulos_alice.csv`:

```nu
let caps = open --raw alice.txt
    | lines
    | where ($it =~ '^CHAPTER ')
    | parse --regex '^CHAPTER (?P<numero>[IVXLCDM]+)\.\s+(?P<titulo>.*)$'

$caps
$caps | save -f capitulos_alice.csv
```

Y si deseamos construir un conjunto de datos con todas las palabras únicas de `alice.txt` que comienzan con la letra `a` y terminan con la letra `e`, mostramos las primeras 15 y guardamos el listado completo en `palabras_a_e.csv`:

```nu
let palabras_ae = open --raw alice.txt
    | str lowercase
    | parse --regex '(?P<palabra>[a-z]{2,})'
    | get palabra
    | where ($it =~ '^a.*e$')
    | uniq
    | sort
    | wrap palabra

$palabras_ae | first 15
$palabras_ae | save -f palabras_a_e.csv
```

### Reemplazando y Eliminando Valores

En Nushell, la familia de comandos `str` (`str replace`, `str uppercase`, `str lowercase`, `str trim`) opera nativamente sobre texto **UTF-8**, por lo que convierte correctamente caracteres acentuados y no ASCII (como `'hallo wêreld!'` o `'helló világ'`) donde la herramienta clásica `tr` fallaba por operar sobre bytes individuales:

```nu
"hello world!" | str replace -a " " "_"
"hello world!" | str replace -a --regex '[ !]' ''
"hallo wêreld!" | str uppercase
"helló világ" | str uppercase
"  hello     world!  " | str trim | str replace -a --regex '\s+' ' ' | str replace "hello" "bye"
"  hello     world!  " | str trim | str replace -a --regex '\s+' ' ' | str replace "hello" "bye" | save -f saludo_limpio.txt
```


## Formateando salida de comandos (parsing)

Nushell ofrece la posibilidad de transformar la salida de comandos nushell, con diferentes formas de lograr el mismo objetivo.

Las funciones integradas que se pueden utilizar incluyen:

- `lines`
- `detect columns`
- `parse`
- `str ...`
- `from ssv`

A continuación, se muestran algunos ejemplos ilustrativos de salida tabular.

### `detect columns` (bastante automático)

Esta herramienta intenta dividir automáticamente el texto en varias columnas.

```nu
df -h

df -h | str replace "Mounted on" Mounted_On | detect columns
```

Para una salida como la de `df` esta es probablemente la forma más compacta de lograr una salida tabular. `str replace` es necesario porque uno de los encabezados de columna tiene un espacio en él.

### Usando `from ssv`

También se puede usar el analizador de datos `from` incorporado para `ssv` (*s*pace *s*eparated *v*alues):

```nu
df -h | str replace "Mounted on" Mounted_On | from ssv --aligned-columns --minimum-spaces 1
```

La salida es idéntica al ejemplo anterior. `from ssv` admite varias opciones para ajustar su comportamiento.
Notar que de todas formas se debe corregir los encabezados de las columnas si contienen espacios inesperados.

### Usando `parse`

Permite analizar un patrón arbitrario de una cadena de texto en una tabla de varias columnas.

```nu
'nu = "0.116.1" # A new type of shell
ttt = "1.8.0" # Terminal text editor' | lines | parse '{crate_name} = "{version}" #{description}' | update description { str trim }
```



## CSV y Tablas Estructuradas

### Cuerpos, Encabezados y Columnas

En las herramientas clásicas de texto (`grep`, `sed`, `tr`, `sort`), filtrar u ordenar un archivo CSV requería utilidades auxiliares (`body`, `header`, `cols`) para evitar mezclar el encabezado con los datos o modificar columnas equivocadas.

En **Nushell**, al abrir un archivo CSV con `open`, el encabezado se convierte automáticamente en el esquema de nombres de columnas de la tabla, y cualquier operación (`sort-by`, `where`, `update`) actúa exclusivamente sobre las filas o la columna indicada sin corromper jamás el encabezado.

Por ejemplo, en `/data/ch06`, convirtamos a mayúsculas únicamente la columna `day` de `tips.csv`, mostrando las primeras 5 filas y guardando la tabla resultante en `tips_day_upper.csv`:

```nu
open tips.csv | update day { str uppercase } | first 5
open tips.csv | update day { str uppercase } | save -f tips_day_upper.csv
```

### Realizando Consultas SQL en CSV

Cuando deseamos expresar transformaciones complejas utilizando sintaxis **SQL** sobre archivos CSV, Nushell permite volcar cualquier tabla directamente a una base de datos SQLite con `into sqlite` y consultarla con `query db`. Veamos cómo consultar `tips.csv` con SQL y guardar el resultado en `tips_sql_resultado.csv`:

```nu
rm -f tips_temp.db
open tips.csv | into sqlite tips_temp.db
open tips_temp.db | query db "SELECT bill, tip, day, time, size FROM main WHERE bill > 40.0 AND day LIKE 'S%'"
open tips_temp.db | query db "SELECT bill, tip, day, time, size FROM main WHERE bill > 40.0 AND day LIKE 'S%'" | save -f tips_sql_resultado.csv
```

### Extrayendo y Reordenando Columnas

Para extraer un subconjunto de columnas en un orden específico utilizamos `select`, y para excluir una o más columnas conservando el resto utilizamos `reject`:

```nu
open iris.csv | select sepal_length petal_length sepal_width petal_width | first 5
open iris.csv | reject species | first 5
open iris.csv | select sepal_length petal_length sepal_width petal_width | save -f iris_columnas_reordenadas.csv
```

### Filtrando Filas

En Nushell filtramos filas de tablas CSV combinando condiciones numéricas y expresiones regulares legibles mediante `where`:

```nu
open tips.csv | where size >= 5 | first 6
open tips.csv | where bill > 40.0 and day =~ '^S'
open tips.csv | where bill > 40.0 and day =~ '^S' | save -f tips_altos_finde.csv
```

### Combinar Columnas (y Robustez ante Comas Internas)

Consideremos los archivos `names.csv` y `names-comma.csv` en `/data/ch06`, los cuales contienen compositores cuyos nombres (`first_name`) y apellidos (`last_name`) deseamos combinar en una columna `full_name`:

```nu
open names.csv
open names-comma.csv
```

En `names-comma.csv`, el último registro contiene una coma dentro del apellido (`"Stravinsky, Jr."`). Mientras que `sed`, `awk` y `cut` fallaban al partir por esa coma interna, el analizador CSV de Nushell respeta las comillas del estándar RFC 4180 y construye `full_name` de manera impecable:

```nu
let nombres_limpios = open names-comma.csv
    | insert full_name { |row| $"($row.first_name) ($row.last_name)" }
    | select id full_name born

$nombres_limpios
$nombres_limpios | save -f names_completos.csv
```

### Combinando Múltiples Archivos CSV

#### Concatenar Horizontalmente (`merge`)

En `/data/ch06` podemos dividir `tips.csv` en tres archivos CSV con distintas columnas (`bills.csv`, `datetime.csv` y `customers.csv`) y luego volver a unirlos horizontalmente lado a lado mediante el comando **`merge`**, guardando el resultado en `tips_horizontal.csv`:

```nu
open tips.csv | select bill tip | save -f bills.csv
open tips.csv | select day time | save -f datetime.csv
open tips.csv | select sex smoker size | save -f customers.csv

let unido_horizontal = open bills.csv | merge (open customers.csv) | merge (open datetime.csv)
$unido_horizontal | first 5
$unido_horizontal | save -f tips_horizontal.csv
```

#### Unión Relacional (`join`)

Cuando dos tablas comparten una columna clave (como `species` en `iris.csv` e `irismeta.csv`), realizamos un cruce relacional (*inner join*) con el comando **`join`**, seleccionamos las columnas de interés y guardamos el resultado en `iris_usda.csv`:

```nu
open irismeta.csv
let iris_enriquecido = open iris.csv
    | join (open irismeta.csv) species
    | select sepal_length sepal_width species usda_id

$iris_enriquecido | slice 48..53
$iris_enriquecido | save -f iris_usda.csv
```

## Trabajando con XML/HTML y JSON

En `/data/ch06` contamos con el archivo JSON `users.json` y los archivos extraídos de Wikipedia `wiki.html`, `table.html` y `table.json`.

En lugar de modificar `users.json` con expresiones regulares de texto como `sed` (lo cual podría alterar valores además de nombres de claves), en Nushell abrimos `users.json` como estructura de datos, renombramos el campo `gender` a `sex` en la tabla `results` y guardamos el resultado tanto en JSON como en CSV:

```nu
let usuarios = open users.json
    | get results
    | select gender email nat phone
    | rename sex email nat phone

$usuarios | first 5
$usuarios | save -f users_sex.csv
```

De igual manera, a partir de la tabla HTML convertida a JSON en `table.json` (lista de países y territorios por relación frontera/superficie de Wikipedia), podemos extraer las filas en Nushell y guardar el conjunto de datos tabular en `countries_from_json.csv`:

```nu
# skip-docker-exec (requiere descarga web previa de Wikipedia)
open countries.csv | first 10
open countries.csv | first 10 | save -f countries_top10.csv
```


## El plugin polars de Nushell

Polars se define como una biblioteca de `DataFrame` para Rust que se caracteriza por su extrema rapidez y eficiencia en el uso de la memoria. El plugin `polars` para Nushell permite utilizar las potentes capacidades de Polars directamente desde la línea de comandos. Esto abre un mundo de posibilidades para el análisis y la manipulación de datos a alta velocidad, directamente en la terminal.

La filosofía de Polars se centra en aprovechar al máximo el hardware moderno, utilizando un motor de consulta paralelizado y optimizado para la ejecución en múltiples núcleos. Esto significa que se pueden procesar conjuntos de datos mucho más grandes que con las herramientas tradicionales de línea de comandos, y a menudo de forma mucho más rápida que con soluciones en memoria como Pandas.

### Casos de uso

El plugin `polars` resulta ideal para:

- **Análisis exploratorio de datos (EDA)**: se pueden investigar y resumir rápidamente grandes conjuntos de datos.
- **Canalizaciones de limpieza y transformación de datos**: se pueden crear potentes canalizaciones para limpiar y transformar datos.
- **Procesamiento de datos por lotes**: se pueden procesar grandes volúmenes de datos de manera eficiente.
- **Alternativa a `pandas` o `dplyr` en la línea de comandos**: se pueden realizar operaciones complejas de `DataFrames` sin salir de la terminal.

### Conceptos básicos

Los dos conceptos principales en Polars son el `DataFrame` y la `Serie`.

- **`DataFrame`**: se define como una estructura de datos tabular bidimensional, similar a una hoja de cálculo o una tabla SQL. Consta de filas y columnas, donde cada columna es una `Serie`.
- **`Serie`**: se describe como una matriz unidimensional de datos, que representa una única columna en un `DataFrame`.

#### Diferencia entre DataFrames de Polars y Tablas de Nushell

Es importante entender la diferencia entre un `DataFrame` de Polars y una tabla de Nushell. Aunque a primera vista pueden parecer similares, se observan diferencias fundamentales en su diseño y uso:

- **Representación en Memoria:** Las tablas de Nushell se representan como una lista de filas, donde cada fila es una colección de pares clave-valor. Esto resulta ideal para la mayoría de las tareas de la línea de comandos. Los `DataFrames` de Polars, por otro lado, utilizan un formato columnar. Esto significa que los datos de cada columna se almacenan juntos en memoria, lo que permite un procesamiento y análisis de datos mucho más rápido, especialmente para conjuntos de datos grandes.

- **API y Operaciones:** Las tablas de Nushell se manipulan utilizando los comandos estándar de Nushell como `where`, `sort-by`, `group-by`, etc. Los `DataFrames` de Polars tienen su propio conjunto de comandos (los que comienzan con `polars`), que están optimizados para operaciones de datos a gran escala.

- **Rendimiento:** Para conjuntos de datos pequeños y medianos, el rendimiento de las tablas de Nushell es excelente. Sin embargo, para conjuntos de datos muy grandes, los `DataFrames` de Polars ofrecen un rendimiento significativamente mayor debido a su diseño columnar y su capacidad para realizar operaciones en paralelo.

En resumen, se puede pensar en las tablas de Nushell como una forma versátil y fácil de usar para trabajar con datos estructurados en la línea de comandos, mientras que los `DataFrames` de Polars son una herramienta más especializada y de alto rendimiento para el análisis de datos a gran escala. El plugin `polars` permite cambiar sin problemas entre estos dos paradigmas, brindando lo mejor de ambos mundos.

### Uso básico

Para utilizar el plugin `polars`, primero se deben cargar los datos en un `DataFrame`. El plugin `polars` admite una variedad de formatos de archivo, incluidos CSV, JSON, Parquet y más.

#### Carga de datos

Para este ejemplo, se utilizará un conjunto de datos de ventas de videojuegos. Se pueden descargar los datos usando el siguiente comando:

```nu
ls vgsales.csv
```

> Fuente: [https://raw.githubusercontent.com/rfordatascience/tidytuesday/master/data/2019/2019-07-30/video_games.csv](https://raw.githubusercontent.com/rfordatascience/tidytuesday/master/data/2019/2019-07-30/video_games.csv)

Ahora, se puede cargar el archivo `vgsales.csv` en un DataFrame de Polars de la siguiente manera:

```nu
let df = open vgsales.csv | polars into-df
$df | polars first 5 | polars collect
$df | describe
```

Esto crea un `DataFrame` de Polars que puede usarse para su posterior análisis.

> En caso de error con `polars open`, se puede abrir el archivo usando el comando `open vgsales.csv | polars into-df`.

#### Exploración de datos

Una vez que se han cargado los datos en un `DataFrame`, se puede ver su esquema usando el comando `polars schema`. Esto mostrará los nombres de las columnas y sus tipos de datos.

```nu
$df | polars schema
```

Se observa que algunas variables aparecen de tipo `object`, que es el tipo de datos predeterminado para Polars cuando no se especifica un tipo de datos específico. En estos casos, se puede especificar el tipo de datos adecuado usando el comando `polars into-df` con la opción `--schema`.

```nu
let df = open vgsales.csv
  | polars into-df --schema {
      number: i64,
      game: str,
      release_date: str,
      price: str,
      owners: str,
      developer: str,
      publisher: str,
      average_playtime: str,
      median_playtime: str,
      metascore: str
    }
```

> Cuando hay valores `NA`, se definen temporalmente las variables numéricas de tipo `str`.

#### Conversión de tipos de datos

Para poder abrir el archivo, se tuvo que usar el tipo `str` para las columnas `number`, `price`, `owners`, `average_playtime`, `median_playtime`, y `metascore`.

Para convertir estas columnas al tipo apropiado se utilizan:

```nu
let df = $df
  | collect
  | polars with-column [
    (polars col price
    	| polars str-replace-all --pattern "Free" --replace "0"
     	| polars cast f64
    ),
    (polars col average_playtime | polars cast i64),
    (polars col median_playtime | polars cast i64),
    (polars col metascore | polars cast i64)
  ]

$df | polars schema
$df | polars summary | polars collect
$df | polars summary | polars select descriptor "price (f64)" "average_playtime (i64)" "median_playtime (i64)" "metascore (i64)" | polars collect

$df | polars first 5 | polars collect
```

En este proceso:

- `collect`: Recolecta un flujo (*stream*) en un valor.
- `polars with-column`: Añade una o varias series/expresiones a un `DataFrame` o `LazyFrame`.
- `polars col`: Crea una expresión que referencia una columna existente (p. ej. `polars col price`).
- `polars str-replace-all`: Reemplaza todas las ocurrencias que casan con un patrón regex por una cadena dada.
- `polars cast`: Convierte (castea) el tipo de una expresión o columna a un dtype especificado (p. ej. `f64`, `i64`).

Se debe notar que se tuvo que limpiar la columna `price` antes de poder convertirla a un número.

La columna `price` original contenía la palabra "**Free**" (Gratis) en algunas filas. No se puede convertir (hacer `cast`) directamente una columna que contiene texto (como "Free") a un tipo numérico (como `f64`). Intentar hacerlo fallaría porque el computador no sabe qué número corresponde a "Free".

Para arreglar esto, se usa un proceso de dos pasos dentro del comando `with-column`:

1.  `polars str-replace-all --pattern "Free" --replace "0"`: Este comando encontró cada instancia del texto "Free" en la columna `price` y la reemplazó por el texto "0".
2.  `polars cast f64`: _Después_ de que todos los valores "Free" fueran reemplazados por "0", la columna solo contenía textos que parecían números (ej. "1.99", "59.99", y ahora "0"). En ese momento, ya era seguro convertir toda la columna a `f64` (un número de punto flotante de 64 bits) sin errores.

### Manipulación de datos

El plugin `polars` proporciona una amplia gama de comandos para manipular `DataFrames`.

#### Selección de columnas

Se pueden seleccionar columnas de un `DataFrame` usando el comando `polars select`. Por ejemplo, para seleccionar las columnas `game`, `price`, y `metascore` del `DataFrame` de ventas de videojuegos, se usaría el siguiente comando:

```nu
$df | polars select game price metascore
```

Se observa que se obtiene lo siguiente:

```
╭────────────────┬───────────────────────────────────────────────────────╮
│ plan           │ SELECT [col("game"), col("price"), col("metascore")]  │
│                │   DF ["number", "game", "release_date", "price",      │
│                │   ...]; PROJECT */10 COLUMNS                          │
│ optimized_plan │ DF ["number", "game", "release_date", "price", ...];  │
│                │   PROJECT["game", "price", "metascore"] 3/10 COLUMNS  │
╰────────────────┴───────────────────────────────────────────────────────╯
```

Este resultado es el **plan de consulta** de Polars. Es una mirada interna a cómo el motor de Polars procesará la solicitud. Se divide en dos partes:

- **`plan` (Plan Lógico):** Esta es la traducción directa del comando a una serie de operaciones. En este caso, `SELECT [col("game"), col("price"), col("metascore")]` indica que se ha solicitado seleccionar esas tres columnas.

- **`optimized_plan` (Plan Optimizado):** Este es el plan de ejecución real que Polars utilizará. El motor de Polars analiza el plan lógico y lo optimiza para obtener la máxima eficiencia. En este ejemplo, el plan optimizado muestra que realizará una operación de "proyección" para seleccionar solo las 3 columnas que se solicitaron de las 10 columnas totales del DataFrame.

Esta es una característica clave de la **evaluación perezosa (lazy evaluation)** de Polars. En lugar de ejecutar cada comando de inmediato, se construye un plan de todas las operaciones, se optimiza y luego se ejecuta de la manera más eficiente posible. Esto es lo que hace que Polars sea tan rápido, especialmente con grandes conjuntos de datos.

Para ver el resultado, se debe terminar la _pipeline_ con `polars collect`. Esto ejecutará el plan optimizado y devolverá el resultado como un DataFrame.

```nu
$df | polars select game price metascore | polars collect
```

#### Filtrado de filas

Se pueden filtrar filas de un `DataFrame` usando el comando `polars filter`. Por ejemplo, para filtrar el `DataFrame` de ventas de videojuegos para incluir solo los juegos cuyo nombre de desarrollador (_developer_) contiene la palabra "Action", se usaría el siguiente comando:

```nu
#búsqueda Insensible a Mayúsculas/Minúsculas
let filter_condition = polars col developer | polars contains "(?i)Action"
$df | polars filter $filter_condition | polars collect

#búsqueda Sensible a Mayúsculas/Minúsculas
let filter_condition = polars col developer | polars contains "Action"
$df | polars filter $filter_condition | polars collect

#eliminar na in price
let filter_condition = polars col price | polars is-not-null
$df | polars filter $filter_condition | polars collect
```

Por otro lado, para eliminar todas las filas con valores nulos en todas las columnas, se usaría el siguiente comando:

```nu
let df_filtered = $df | polars drop-nulls
$df_filtered | polars collect
```

#### Ordenación de datos

Se puede ordenar un `DataFrame` usando el comando `polars sort-by`. Por ejemplo, para ordenar el `DataFrame` de ventas de videojuegos por la columna `price` en orden descendente, se usaría el siguiente comando:

```nu
$df_filtered | polars sort-by price --reverse [true]
```

#### Agrupación y agregación

Se pueden agrupar y agregar datos en un `DataFrame` usando los comandos `group-by` y `agg`. Por ejemplo, para agrupar el `DataFrame` de ventas de videojuegos por la columna `developer` y calcular el número total de juegos por cada desarrollador, se usaría el siguiente comando:

```nu
$df_filtered |
  polars group-by developer |
  polars agg (polars col game | polars count) |
  polars sort-by game --reverse [true] |
  polars collect
```

- Para estadísticas por `developer`:

```nu
$df_filtered |
  polars group-by developer |
  polars agg [
    (polars col price | polars mean | polars as "price_mean"),
    (polars col game  | polars count | polars as "n_games")
  ] |
  polars sort-by developer |
  polars collect
```

- Para estadísticas por año de `release_date`:

```nu
#se mira la columna release_date
$df_filtered | polars select release_date | polars collect

#primero se extrae año, luego se agrupa
let data_by_year = $df_filtered |
  polars with-column [
    (polars col release_date
       | polars str-replace-all --pattern ".*,\\s*(\\d{4})$" --replace "$1" # extrae el año
       | polars str-replace-all --pattern "^\\s+|\\s+$" --replace ""        # trim
       | polars cast i64
       | polars as "year")
   ] |
  polars group-by year |
  polars agg [
    (polars col price | polars mean | polars as "price_mean"),
    (polars col game  | polars count | polars as "n_games")
  ] |
  polars sort-by year |
  polars collect

#se visualiza
$data_by_year
$data_by_year | describe
$data_by_year | polars into-nu #tabla nu
$data_by_year | polars into-nu | describe
```

### Guardado y formatos

Para guardar un `DataFrame` en un archivo, se usaría el comando `polars save`. Por ejemplo, para guardar el `DataFrame` de ventas de videojuegos filtrado en un archivo CSV, se usaría el siguiente comando:

```nu
$df_filtered | polars collect | polars save vgsales_filtered.parquet
$df_filtered | polars collect | polars save vgsales_filtered.csv
$data_by_year | polars save data_by_year.csv
```

Si lo anterior no funciona, en algunos casos es necesario entregar la ruta completa del archivo. Por ejemplo:

```nu
$df_filtered | polars collect | polars save ($env.PWD | path join vgsales_filtered.csv)
```

```nu
$df_filtered | polars collect | polars save vgsales_filtered.csv
$data_by_year | polars save data_by_year.csv
```

### Pivoteo de columnas

El comando `polars pivot` en Nushell es una operación de transformación de datos que convierte un DataFrame del formato largo al formato ancho, similar a la función PIVOT en SQL o la función `pivot_wider` en R. Esta operación es fundamental para reorganizar datos tabulares, permitiendo que valores únicos de una columna se conviertan en nuevas columnas, mientras que los valores de otra columna se distribuyen como datos en estas nuevas columnas. Es especialmente útil para crear tablas de resumen, reportes y visualizaciones donde se necesita mostrar múltiples métricas organizadas por categorías específicas.

Dentro de sus opciones principales se encuentran:

- **`--index` (`-i`)**: Define las columnas que servirán como identificadores únicos de las filas en el resultado. Estas columnas mantienen su estructura original y no se transforman, funcionando como las claves que identifican cada fila en el formato ancho resultante.

- **`--on` (`-o`)**: Especifica la columna cuyos valores únicos se convertirán en los nombres de las nuevas columnas en el DataFrame resultante. Cada valor distinto en esta columna generará una nueva columna en el formato ancho.

- **`--values` (`-v`)**: Determina las columnas cuyos valores se distribuirán en las nuevas columnas creadas a partir de los valores únicos de la columna especificada con `--on`. Estas son las columnas que contienen los datos numéricos o categóricos que se desean reorganizar.

El comando también incluye opciones adicionales como `--aggregate` para definir funciones de agregación cuando hay valores duplicados, `--separator` para personalizar el delimitador en nombres de columnas generadas, y `--sort` para ordenar las columnas resultantes.

Para ilustración, se considera el siguiente ejemplo.

Primero, se preparan los datos para el pivoteo:

- Se repite el procesamiento anterior a `release_date`.
- Se extraen columnas `developer`, `price`, `year`.
- Se agrupa por `developer` y `year`.
- Se calcula promedio de `price` de acuerdo al agrupamiento.

```nu
let df_aggregated = $df_filtered |
  polars with-column [
    (polars col release_date
      | polars str-replace-all --pattern ".*,\\s*(\\d{4})$" --replace "$1"
      | polars str-replace-all --pattern "^\\s+|\\s+$" --replace ""
      | polars cast i64
      | polars as "year"
    )
  ] |
  polars select [
    (polars col developer)
    (polars col price)
    (polars col year)
  ] |
  polars group-by [developer year] |
  polars agg [(polars col price | polars mean | polars as price_mean)]

$df_aggregated | polars collect
$df_aggregated | polars sort-by year | polars collect
$df_aggregated | polars sort-by developer | polars collect
```

Se hace el pivoteo:

```nu
let df_pivoted = ($df_aggregated | polars sort-by year | polars collect | polars pivot --index [developer] --on [year] --values [price_mean] --stable | polars collect | polars sort-by developer | polars collect)
$df_pivoted | polars first 5 | polars into-nu
$df_pivoted | polars into-nu | save -f vgsales_pivot.csv
```

### Buenas prácticas y recomendaciones

- Siempre se deben nombrar explícitamente las columnas creadas con `polars as` dentro de expresiones complejas.
- Se deben limpiar los formatos de moneda y separadores antes de castear a numérico.
- Se debe llamar `collect` o `save` al final de una _pipeline_.
- Se prefieren formatos columnares (Parquet, Arrow) para almacenamiento intermedio o persistente.
- Se debe revisar el `schema` y `summary` con frecuencia para detectar valores atípicos y NA.
- Para desarrollos iterativos, usar `polars collect | polars into-nu` permite inspeccionar resultados en formato de tabla de Nushell y combinar con otras utilidades de la shell.

### Conclusión

El plugin `polars` para Nushell combina la expresividad y conveniencia de la shell con el rendimiento de Polars. Permite construir pipelines de limpieza, transformación, agregación y guardado de datos de manera eficiente. Usando estrategias sencillas; limpieza de cadenas, uso de `polars as` para nombrar columnas, evaluación perezosa (lazyframes) y formatos columnares; se pueden crear flujos reproducibles y escalables directamente desde la terminal.



\newpage

# Exploración y Visualización de Datos {#chapter-7-data-exploration}

El cuarto paso del flujo de trabajo OSEMN consiste en explorar los datos. Explorar nuestros conjuntos de datos desde múltiples ángulos (estadístico, estructural y visual) es fundamental antes de construir modelos predictivos. Como destacó John W. Tukey en su clásico libro *Exploratory Data Analysis* (1977), el análisis exploratorio de datos (EDA) nos permite descubrir patrones inesperados, detectar valores atípicos (*outliers*), verificar supuestos y formular hipótesis informadas.

En este capítulo abordaremos la exploración y visualización de datos desde tres perspectivas complementarias dentro de la imagen Docker `dsin`:

1. **Inspección de propiedades estructurales y estadísticas en Nushell**, utilizando los comandos nativos de inspección (`columns`, `describe`, `uniq`, `histogram`), el módulo matemático (`math`) y el motor de DataFrames `polars`.
2. **Cálculo de estadísticas descriptivas y pruebas diagnósticas mediante scripts en R y Python**, integrando sus salidas directamente en pipelines de Nushell para presentarlas como tablas estructuradas.
3. **Creación y visualización de gráficos estadísticos en la terminal**, generando figuras mediante scripts modulares con `ggplot2` en R y `matplotlib`/`seaborn` en Python, e inspeccionándolas directamente dentro de la terminal mediante el visor gráfico **`timg`** preinstalado en la imagen `dsin`.

Todos los archivos y scripts de este capítulo se encuentran en `/data/ch07`. Para comenzar, nos posicionamos en este directorio:

```nu
cd /data/ch07
```

A partir de este punto, ejecutaremos todas las actividades dentro de `/data/ch07`. Inspeccionemos los archivos disponibles:

```nu
ls
```

## Inspeccionando Datos y sus Propiedades

Antes de graficar o modelar un conjunto de datos, necesitamos responder preguntas fundamentales sobre su estructura: ¿cuántas filas y columnas tiene?, ¿qué nombres y tipos de datos poseen las variables?, ¿existen columnas constantes o con valores faltantes?

En Nushell, dado que cualquier archivo tabular cargado con `open` se convierte inmediatamente en una tabla tipada en memoria, podemos responder estas preguntas combinando selectores y filtros nativos, y guardar los resúmenes o tablas depuradas directamente en disco.

### ¿Tiene Encabezado, Cuántos Registros y Qué Columnas?

Inspeccionemos el archivo `venture.csv` ubicado en `/data/ch07`:

```nu
open --raw venture.csv | lines | first 5
```

Al abrirlo de forma estructurada con `open venture.csv`, Nushell interpreta automáticamente la primera línea como encabezado y tipifica cada columna. Podemos consultar el número total de registros con `length` y listar los nombres de las columnas junto con su índice usando `columns` y `enumerate`:

```nu
open venture.csv | length
open venture.csv | columns | enumerate | first 15
open venture.csv | columns | enumerate | wrap col_info | flatten | save -f venture_columns.csv
```

### Inspeccionando Tipos de Datos e Inferencia de Esquemas

Veamos el archivo `datatypes.csv`, diseñado específicamente para ilustrar distintos tipos de datos (enteros, flotantes, booleanos, fechas y cadenas):

```nu
open datatypes.csv
open datatypes.csv | save -f datatypes_copy.json
```

Para conocer el tipo exacto que Nushell o Polars asignó a cada columna, podemos emplear `describe` o convertir la tabla a un DataFrame de Polars y consultar `polars schema`:

```nu
open datatypes.csv | polars into-df | polars schema | transpose column dtype
open datatypes.csv | polars into-df | polars schema | transpose column dtype | save -f datatypes_schema.csv
```

### Identificando Valores Únicos y Eliminando Columnas Constantes

En muchos conjuntos de datos administrativos o financieros (como `venture.csv`), existen columnas que contienen exactamente el mismo valor en todas las filas y que, por tanto, no aportan información estadística ni poder predictivo.

En Nushell podemos detectar el número de valores únicos de cada columna trasponiendo el primer registro o iterando sobre los nombres de las columnas con `get` y `uniq`:

```nu
let df = open venture.csv
let non_const_cols = $df | columns | where {|c| ($df | get $c | uniq | length) > 1 }
$df | select ...$non_const_cols | first 5
$df | select ...$non_const_cols | save -f venture_clean.csv
```

Observa la claridad del flujo: identificamos programáticamente todas las columnas con más de un valor único (`uniq | length > 1`), filtramos la tabla original conservando únicamente dichas columnas mediante el operador de expansión `...$non_const_cols`, y guardamos el resultado limpio en `venture_clean.csv`.

## Calculando Estadísticas Descriptivas

Trabajemos ahora con el clásico conjunto de datos `tips.csv` (propinas en un restaurante según el total de la cuenta, sexo, hábito de fumar, día, horario y tamaño del grupo), ubicado en `/data/ch07/tips.csv`:

```nu
open tips.csv | first 10
open tips.csv | first 10 | save -f tips_sample.csv
```

### Estadísticas con `math` y `polars summary` en Nushell

Nushell incluye la familia de comandos `math` (`math sum`, `math avg`, `math median`, `math stddev`, `math variance`, `math min`, `math max`, `math mode`), que operan sobre listas numéricas o sobre todas las columnas numéricas de una tabla:

```nu
open tips.csv | select bill tip size | math avg
open tips.csv | select bill tip size | math stddev
open tips.csv | select bill tip size | math median | save -f tips_median.json
```

Si deseamos obtener simultáneamente el conteo, media, desviación estándar, mínimo, cuartiles (25%, 50%, 75%) y máximo de todas las variables del dataset, `polars summary` genera una tabla resumen completa en un solo paso:

```nu
open tips.csv | polars into-df | polars summary | polars collect | polars into-nu
open tips.csv | polars into-df | polars summary | polars collect | polars into-nu | save -f tips_summary.csv
```

Para variables categóricas (como `day` o `time`), el comando nativo `histogram` calcula el conteo absoluto, cuantiles y porcentaje relativo, incluyendo además un gráfico de barras ASCII en la propia tabla:

```nu
open tips.csv | histogram day
open tips.csv | histogram day | save -f tips_day_freq.csv
```

### Transformaciones y Resúmenes Estadísticos con Scripts en R y Python

En un flujo de trabajo políglota, frecuentemente deseamos aplicar funciones estadísticas especializadas de R (`dplyr`) o Python (`pandas` / `scipy`) y capturar el resultado de vuelta en Nushell como una tabla estructurada. En lugar de escribir código difícil de mantener en una sola línea, creamos archivos `.R` y `.py` modulares en nuestro directorio de trabajo y los invocamos desde Nushell.

Por ejemplo, revisemos el script `mutate_tips.R` en `/data/ch07`, que calcula el porcentaje de propina (`percent = tip / bill * 100`) usando `dplyr::mutate` y escribe el CSV resultante en la salida estándar:

```nu
bat mutate_tips.R
```

Al ejecutar `Rscript mutate_tips.R` y canalizar su salida hacia `from csv`, Nushell recibe una tabla tipada que podemos filtrar, ordenar y guardar en disco:

```nu
Rscript mutate_tips.R | from csv | first 10
Rscript mutate_tips.R | from csv | save -f tips_with_percent.csv
```

Del mismo modo, el script `summary_tips.R` agrupa las propinas por día y horario (`group_by(day, time)`) y calcula el conteo, la cuenta media y la propina media:

```nu
bat summary_tips.R
Rscript summary_tips.R | from csv | sort-by mean_tip -r
Rscript summary_tips.R | from csv | sort-by mean_tip -r | save -f tips_grouped_summary.csv
```

Y con Python (`corr_tips.py`), podemos calcular la matriz de correlación de Pearson entre `bill`, `tip` y `size` usando `pandas` y devolverla como tabla a Nushell:

```nu
bat corr_tips.py
python3 corr_tips.py | from csv
python3 corr_tips.py | from csv | save -f tips_correlations.csv
```

## Creando Visualizaciones Estadísticas desde la Línea de Comandos

Las estadísticas resumen nunca sustituyen por completo a la inspección visual (como demuestra el célebre *Cuarteto de Anscombe*, donde cuatro conjuntos de datos con idéntica media, varianza y correlación exhiben estructuras geométricas radicalmente distintas).

En nuestro entorno `dsin`, combinamos la potencia gráfica de **`ggplot2`** (en R) y **`matplotlib`/`seaborn`** (en Python) con el visor de imágenes de terminal **`timg`**. Como tanto `Rscript`, `python3` y `timg` están configurados en el `PATH` por defecto del contenedor `dsin`, podemos invocarlos directamente por su nombre sin prefijos especiales.

Veamos primero el script `plot_faceted.R`, que genera un gráfico de dispersión de `tip` versus `bill` con rectas de regresión lineal separadas por sexo y día (`tips_faceted.png`):

```nu
bat plot_faceted.R
Rscript plot_faceted.R
ls tips_faceted.png
```

### Visualizando Imágenes Directamente en la Terminal con `timg`

En el flujo de trabajo tradicional de los contenedores Docker sin servidor gráfico X11, el usuario debía copiar cada imagen generada hacia el sistema anfitrión para poder abrirla. En la imagen `dsin`, incluimos **`timg`** (*Terminal Image and Video Viewer*), una herramienta que renderiza archivos PNG, JPEG, SVG o incluso animaciones directamente dentro de la terminal utilizando bloques Unicode de alta resolución o los protocolos gráficos de Kitty/iTerm2/Sixel.

Para visualizar cualquier gráfico generado en `/data/ch07`, basta con ejecutar:

```nu
timg -g 80x25 tips_faceted.png
```

También podemos mostrar varios gráficos en una cuadrícula comparativa dentro de la terminal usando la bandera `--grid`:

```nu
Rscript plot_histogram.R
Rscript plot_density.R
timg --grid=2x1 -g 80x25 tips_histogram.png tips_density.png
```

### Alternativa Remota: Copiando Gráficos con `scp`

Si te encuentras conectado por SSH desde una terminal antigua que no soporta color verdadero de 24 bits, siempre puedes descargar la imagen hacia tu máquina local utilizando `scp` (*secure copy*):

```bash
# skip-docker-exec
scp usuario@servidor:/data/ch07/tips_faceted.png .
```

## Catálogo de Gráficos Estadísticos con Scripts en R y Python

La gramática de los gráficos (*Grammar of Graphics*) implementada en `ggplot2` descompone toda visualización estadística en tres elementos esenciales:

1. **Datos (`data`)**: el DataFrame tabular que deseamos representar.
2. **Mapeos estéticos (`aes`)**: la correspondencia entre columnas de los datos y propiedades visuales como posición (`x`, `y`), color (`color`, `fill`), forma (`shape`) o tamaño (`size`).
3. **Objetos geométricos (`geom_*`)**: la representación gráfica concreta (barras, puntos, líneas, cajas, violines o curvas de densidad).

En `/data/ch07` disponemos de una colección completa de scripts listos para usar que ilustran los gráficos fundamentales del análisis exploratorio.

### Gráfico de Barras (`geom_bar`)

Para visualizar la distribución de frecuencias de una variable categórica o discreta, como la cantidad de mesas atendidas por día de la semana en `tips.csv`, ejecutamos `plot_bar.R`:

```nu
bat plot_bar.R
Rscript plot_bar.R
timg -g 80x25 tips_bar.png
```

![Gráfico de barras generado con ggplot2](dscl_0702.png)

### Histograma (`geom_histogram`)

Para inspeccionar la distribución empírica de una variable continua como el monto total de la cuenta (`bill`), ejecutamos `plot_histogram.R`:

```nu
bat plot_histogram.R
Rscript plot_histogram.R
timg -g 80x25 tips_histogram.png
```

![Histograma del total de la cuenta](dscl_0703.png)

Ajustar el número de intervalos (`bins`) es crucial para evitar tanto el sobre-suavizado (pocas barras que ocultan multimodalidad) como el ruido excesivo (demasiadas barras estrechas).

### Gráfico de Densidad (`geom_density`)

Una alternativa suave al histograma es la estimación de densidad por núcleos (*Kernel Density Estimation*, KDE), implementada en `plot_density.R`:

```nu
bat plot_density.R
Rscript plot_density.R
timg -g 80x25 tips_density.png
```

![Estimación de densidad por núcleos](dscl_0706.png)

### Gráfico de Líneas para Series Temporales (`geom_line`)

Cuando trabajamos con registros indexados en el tiempo, como la serie de fallecimientos mensuales por accidentes de tránsito en el Reino Unido (`Fatalities.csv`), un gráfico de líneas revela tendencias seculares y patrones estacionales. Veamos y ejecutemos `plot_accident.R`:

```nu
open Fatalities.csv | first 5
open Fatalities.csv | first 5 | save -f fatalities_head.csv
bat plot_accident.R
Rscript plot_accident.R
timg -g 80x25 fatalities_line.png
```

![Serie temporal de accidentes](dscl_0707.png)

### Diagrama de Dispersión y Tendencia (`geom_point` y `geom_smooth`)

Para estudiar la relación conjunta entre dos variables cuantitativas continuas (`bill` y `tip`), utilizamos `plot_scatter.R` y `plot_trend.R`:

```nu
bat plot_scatter.R
Rscript plot_scatter.R
bat plot_trend.R
Rscript plot_trend.R
timg --grid=2x1 -g 80x25 tips_scatter.png tips_trend.png
```

![Diagrama de dispersión con curva de tendencia suavizada](dscl_0710.png)

### Diagrama de Caja (`geom_boxplot`) y Gráfico de Violín (`geom_violin`)

Para comparar la distribución de una variable continua (`bill`) a través de varios grupos categóricos (`day`), los diagramas de caja (*boxplots*) resumen la mediana, el rango intercuartílico ($\text{IQR} = Q_3 - Q_1$) y los valores atípicos, mientras que los gráficos de violín muestran además la forma completa de la densidad en cada grupo:

```nu
bat plot_boxplot.R
Rscript plot_boxplot.R
bat plot_violin.R
Rscript plot_violin.R
timg --grid=2x1 -g 80x25 tips_boxplot.png tips_violin.png
```

![Diagrama de caja de cuentas por día](dscl_0713.png)

### Visualización Estadística Equivalente en Python (`matplotlib` / `seaborn`)

También podemos generar visualizaciones multipanel desde Python ejecutando `plot_tips_py.py`, el cual produce el archivo `tips_python.png` y devuelve en formato JSON las estadísticas por día hacia Nushell:

```nu
bat plot_tips_py.py
python3 plot_tips_py.py | from json
python3 plot_tips_py.py | from json | save -f tips_py_summary.json
timg -g 80x25 tips_python.png
```

## Resumen

En este capítulo aprendimos a explorar tanto la estructura como la distribución estadística de nuestros datos desde la línea de comandos. Combinamos la inspección nativa de tablas en Nushell (`columns`, `uniq`, `math`, `histogram`, `polars summary`) con scripts modulares en R y Python (`mutate_tips.R`, `summary_tips.R`, `corr_tips.py`, `plot_*.R`, `plot_tips_py.py`), guardando los datos procesados en archivos estructurados y visualizando cada gráfico directamente dentro de la terminal gracias a `timg`.

En el próximo capítulo estudiaremos cómo acelerar drásticamente el procesamiento de datos y la ejecución de comandos externos utilizando las capacidades de paralelismo nativo de Nushell (`par-each`) junto con GNU `parallel`.


\newpage

# Procesamiento en Serie y Pipelines Paralelos {#chapter-8-parallel-pipelines}

A medida que el volumen de datos o la complejidad computacional de nuestras tareas crece —por ejemplo, al consultar cientos de páginas de una API, comprimir docenas de archivos, entrenar modelos con múltiples combinaciones de hiperparámetros o transformar grandes volúmenes de texto—, la ejecución secuencial en un único núcleo de CPU puede convertirse en un cuello de botella importante.

En este capítulo aprenderemos a escalar nuestros flujos de trabajo desde la línea de comandos mediante dos enfoques complementarios que conviven en la imagen `dsin`:

1. **Paralelismo estructurado nativo en Nushell con `par-each`**, ideal para transformar listas, registros y tablas en memoria utilizando todos los hilos de CPU disponibles sin abandonar el modelo de tipos de Nushell.
2. **Paralelismo de procesos externos con GNU `parallel`**, la herramienta clásica de Unix para orquestar comandos externos, scripts en R/Python, flujos divididos en bloques con el flag `--pipe` y ejecución distribuida en múltiples servidores vía SSH.

Todos los archivos de trabajo de este capítulo se encuentran en `/data/ch08`. Nos posicionamos en este directorio:

```nu
cd /data/ch08
```

A partir de este punto, ejecutaremos todos los comandos en `/data/ch08`. Inspeccionemos los archivos disponibles:

```nu
ls
```

## Procesamiento en Serie: Recorriendo Datos con `each`

Antes de paralelizar una tarea, es fundamental asegurarnos de que funciona correctamente de manera secuencial. En Nushell, el comando estándar para iterar sobre cada elemento de una lista o cada fila de una tabla es `each`.

### Iterando sobre Números

Supongamos que queremos calcular el cuadrado de los primeros diez números enteros o evaluar cuáles son divisibles por 3:

```nu
1..10 | each {|x| {n: $x, cuadrado: ($x * $x), es_mult_3: (($x mod 3) == 0)} }
1..10 | each {|x| {n: $x, cuadrado: ($x * $x), es_mult_3: (($x mod 3) == 0)} } | save -f squares_table.csv
```

Para operaciones aritméticas o científicas más complejas, también contamos en `/data/ch08` con el script `pbc` (*parallel bc*), que evalúa expresiones matemáticas con precisión arbitraria:

```nu
1..5 | to text | pbc "{1}^2" | lines | each {|v| $v | into int }
```

### Iterando sobre Líneas y Filas

En `/data/ch08` tenemos el archivo `movies.txt` y el archivo `input.csv`:

```nu
open --raw movies.txt | lines | enumerate | each {|row| {idx: $row.index, movie: ($row.item | str trim), chars: ($row.item | str length)} }
open --raw movies.txt | lines | enumerate | each {|row| {idx: $row.index, movie: ($row.item | str trim), chars: ($row.item | str length)} } | save -f movies_summary.csv
```

### Iterando sobre Archivos

Del mismo modo, podemos recorrer todos los archivos CSV de un directorio, contar sus filas y consolidar el inventario en un nuevo archivo:

```nu
ls *.csv | each {|f| {archivo: $f.name, bytes: $f.size, filas: (open $f.name | length)} }
ls *.csv | each {|f| {archivo: $f.name, bytes: $f.size, filas: (open $f.name | length)} } | save -f csv_inventory.csv
```

## Procesamiento en Paralelo en Nushell con `par-each`

Cuando el bloque de código que pasamos a `each` realiza trabajo intensivo de CPU o de entrada/salida (I/O) y cada iteración es independiente de las demás (*embarrassingly parallel*), podemos reemplazar `each` directamente por **`par-each`**.

![Comparación conceptual entre ejecución secuencial y ejecución en paralelo](dscl_0801.png)

### Ejecución Concurrente y Control de Hilos (`--threads` y `--keep-order`)

En `/data/ch08` disponemos del script `slow.sh`, que simula un proceso costoso esperando un número aleatorio o fijo de segundos antes de terminar. Comparemos el tiempo de ejecución de 4 tareas usando `each` frente a `par-each` mediante el comando `timeit`:

```nu
1..4 | par-each --threads 4 {|i| {job: $i, msg: $"Tarea ($i) completada"} }
1..4 | par-each --threads 4 --keep-order {|i| {job: $i, cuadrado: ($i * $i)} } | save -f parallel_jobs.csv
```

Dos banderas clave de `par-each` son:

- `--threads (-t) <int>`: limita el número máximo de hilos concurrentes (útil para no saturar un servidor compartido o no exceder límites de tasa de una API web).
- `--keep-order (-k)`: garantiza que la tabla o lista de salida conserve exactamente el mismo orden que la entrada original, independientemente de qué hilo termine primero.

## Paralelización de Procesos con GNU `parallel` desde Nushell

Además de `par-each`, la imagen `dsin` incluye **GNU `parallel`** (desarrollado por Ole Tange) directamente en el `PATH`. Mientras que `par-each` paraleliza cierres (*closures*) internos de Nushell devolviendo estructuras tipadas, GNU `parallel` destaca cuando necesitamos orquestar comandos externos de Unix, dividir flujos gigantescos por bloques de bytes o distribuir trabajos hacia múltiples máquinas remotas por SSH.

![Flujo de ejecución de GNU parallel distribuyendo argumentos en múltiples núcleos](dscl_0802.png)

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
open input.csv
open --raw input.csv | parallel --colsep ',' --header : "echo {name}:{quantity}" | lines | where ($it | str contains ":") | split column ":" nombre cantidad | collect | save -f input_parallel.csv
open input_parallel.csv
```

### Controlando el Número de Trabajos Concurrentes (`--jobs`)

Por defecto, GNU `parallel` lanza tantos trabajos en paralelo como núcleos lógicos detecte en el sistema. Con la opción `--jobs` (o `-j`), podemos fijar un número exacto (por ejemplo `-j 4`), un porcentaje de núcleos (`-j 50%`) o sumar/restar hilos respecto al total (`-j +2`):

```nu
1..4 | to text | parallel -j 4 "sh slow.sh {}" | lines
```

### Registro de Salidas y Etiquetado (`--results`, `--keep-order` y `--tag`)

Cuando ejecutamos múltiples experimentos en paralelo, los mensajes de salida pueden mezclarse en la terminal a medida que cada subproceso imprime líneas:

![Entrelazado de salidas cuando varios procesos escriben simultáneamente](dscl_0803.png)

GNU `parallel` ofrece tres mecanismos para mantener el orden y la trazabilidad:

1. `--keep-order` (o `-k`): preserva el orden de los argumentos de entrada en la salida estándar.
2. `--tag`: antepone a cada línea de salida el argumento exacto que la generó (separado por un tabulador), lo que permite transformarla inmediatamente en una tabla de Nushell con `from tsv --noheaders`.
3. `--results <directorio>`: guarda la salida estándar (`stdout`), el error estándar (`stderr`) y el código de retorno (`seq`) de cada trabajo en una jerarquía de subdirectorios organizada por los valores de los argumentos.

Ejecutemos un ejemplo con `--tag` y `-k` en `/data/ch08` y guardemos la tabla resultante:

```nu
1..5 | to text | parallel -k --tag "echo $(( {} * 10 ))" | from tsv --noheaders | rename arg resultado
1..5 | to text | parallel -k --tag "echo $(( {} * 10 ))" | from tsv --noheaders | rename arg resultado | save -f tagged_output.csv
```

También podemos combinar `parallel` con utilidades clásicas como `cowsay` (incluida en el `PATH` de `dsin`):

```nu
["Nushell", "Polars"] | str join "\n" | parallel -k "cowsay {}"
```

### Creando Herramientas Paralelas y Procesamiento por Bloques (`--pipe`)

Cuando tenemos un archivo de texto de varios gigabytes y queremos aplicarle un comando de línea a línea sin crear millones de procesos individuales, la bandera `--pipe` (junto con `--block 10M`) divide la entrada estándar en bloques y envía cada bloque a una instancia paralela del comando:

```nu
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

En este capítulo aprendimos a transformar flujos de trabajo secuenciales (`each`) en pipelines paralelos de alto rendimiento utilizando tanto `par-each` de forma nativa en Nushell como GNU `parallel` para orquestar procesos externos, bloques de flujo (`--pipe`) y ejecución distribuida por SSH.

En el Capítulo 9 culminaremos nuestro recorrido por el modelo OSEMN aplicando estas herramientas a la etapa de **Modelado Estadístico y Machine Learning**: reducción de dimensionalidad (PCA y t-SNE), agrupamiento o *clustering* (K-Means), regresión lineal/regularizada y clasificación supervisada.



\newpage

# Modelado Políglota de Datos {#chapter-9-polyglot-modeling}

El quinto y último paso del modelo OSEMN consiste en **modelar los datos** (*Model Data*). Mientras que el análisis exploratorio y la visualización (Capítulo 7) nos permiten describir estructuras e identificar patrones históricos, el modelado estadístico y el aprendizaje automático (*Machine Learning*) nos proporcionan herramientas formales para **sintetizar dimensiones latentes, descubrir grupos naturales, predecir variables continuas y clasificar nuevas observaciones**.

En este capítulo mantendremos una filosofía **políglota y 100% integrada en Nushell**. Cubriremos las cuatro familias principales de algoritmos del aprendizaje estadístico sobre los conjuntos de datos fisicoquímicos de vinos (`wine-*.csv`), biométricos de peces (`Fish.csv`) y banca minorista (`banco.csv`), ubicados en `/data/ch09`:

1. **Reducción de Dimensionalidad (No Supervisado)**: Análisis de Componentes Principales (**PCA**) y *t-Distributed Stochastic Neighbor Embedding* (**t-SNE**) utilizando la herramienta de línea de comandos `tapkee` (envuelta por `tapkee-reduce`), scripts en R (`pca_wine.R`, `vif_pcr_fish.R`) y en Python (`pca_wine.py`, `vif_pcr_fish.py`), incluyendo diagnóstico formal de multicolinealidad (**VIF**) y Regresión de Componentes Principales (**PCR**).
2. **Agrupamiento o *Clustering* (No Supervisado)**: algoritmo **K-Means** (`kmeans-cluster`, `cluster_wine.R`, `cluster_wine.py`), **Clustering Jerárquico Aglomerativo** (`hclust_fish.R`, `hclust_fish.py`), determinación óptima de $K$ con evaluación multimétrica (`cluster_eval.py`), **Clustering Basado en Densidad con DBSCAN** (`dbscan_fish.py`) y **K-Medoides con PAM** (`pam_fish.R`).
3. **Regresión (Supervisado Continuo)**: predicción de calidad y peso mediante descenso de gradiente estocástico con **Vowpal Wabbit** (`vw-regress`), regresión lineal múltiple con `lm()` en R (`regress_wine.R`), regresión Ridge en Python (`regress_wine.py`) y regresión PCR.
4. **Clasificación (Supervisado Categórico)**: predicción de categorías mediante validación cruzada con **SKLL** (`run_experiment` + `skll-metrics`), regresión logística binomial (`classify_wine.R`), bosques aleatorios (*Random Forest*, `classify_wine.py`), **Árboles de Decisión** (`dt_banco.R`, `dt_banco.py`), **$k$-NN** (`knn_banco.R`, `knn_banco.py`), **Naïve Bayes y SVM** (`nb_svm_banco.py`) y **Redes Neuronales Artificiales MLP** (`mlp_banco.py`, `mlp_banco.R`).

En **todos** los métodos seguiremos el mismo estándar riguroso:

- Nos ubicamos primero en el directorio del capítulo (`/data/ch09`) y abrimos los archivos por su nombre local.
- Ejecutamos la herramienta de línea de comandos o invocamos los scripts `.R` / `.py` independientes (nunca código en línea difícil de depurar).
- Canalizamos la salida hacia Nushell para visualizarla como **tabla estructurada** y la guardamos inmediatamente en un archivo persistente con `save -f`.

Para trabajar con los modelos y conjuntos de datos de este capítulo, nos posicionamos en `/data/ch09`:

```nu
cd /data/ch09
```

A partir de este punto, todos los ejemplos y análisis del capítulo se ejecutan dentro de `/data/ch09`.

## Preparación y Exploración del Conjunto de Datos de Vinos

Inspeccionemos primero los archivos preinstalados en `/data/ch09`:

```nu
ls
```

Los archivos `wine-red.csv` (1.599 vinos tintos) y `wine-white.csv` (4.898 vinos blancos) contienen 11 variables fisicoquímicas continuas (`fixed_acidity`, `volatile_acidity`, `citric_acid`, `residual_sugar`, `chlorides`, `free_sulfur_dioxide`, `total_sulfur_dioxide`, `density`, `pH`, `sulphates`, `alcohol`) y la calificación sensorial `quality` (escala de 0 a 10).

Veamos cómo podemos construir el conjunto combinado `wine-both.csv` directamente en Nushell añadiendo la columna `type` (`red` o `white`) y guardándolo en disco:

```nu
let red = open wine-red.csv | insert type "red"
let white = open wine-white.csv | insert type "white"
let both = $red | append $white
$both | first 5
$both | save -f wine-both-generated.csv
```

Verifiquemos la distribución de clases (`red` vs `white`) y las estadísticas descriptivas por tipo de vino usando Polars:

```nu
open wine-both.csv | histogram type
open wine-both.csv | histogram type | save -f wine_type_distribution.csv
```

Y generemos una visualización exploratoria de las distribuciones de alcohol, acidez volátil y sulfatos entre vinos tintos y blancos ejecutando el script `plot_wine_eda.R` y visualizándola en la terminal con `timg`:

```nu
bat plot_wine_eda.R
Rscript plot_wine_eda.R
timg -g 80x25 wine_eda.png
```

## Reducción de Dimensionalidad (PCA y t-SNE)

Cuando trabajamos con un espacio de $p = 11$ variables fisicoquímicas correlacionadas, resulta imposible visualizar directamente la nube de puntos en dos dimensiones. Los algoritmos de reducción de dimensionalidad proyectan una matriz de datos $\mathbf{X} \in \mathbb{R}^{n \times p}$ hacia un subespacio de baja dimensión $\mathbf{Z} \in \mathbb{R}^{n \times d}$ (con $d = 2 \ll p$) preservando la mayor cantidad posible de estructura:

- **PCA (*Principal Component Analysis*)**: busca combinaciones lineales ortogonales de las variables originales que maximicen la varianza explicada:
  $$\mathbf{z}_k = \mathbf{X}\mathbf{w}_k \quad \text{sujeto a} \quad \|\mathbf{w}_k\|_2 = 1, \quad \mathbf{w}_k^\top \mathbf{w}_j = 0 \;\; (\forall j < k)$$

- **t-SNE (*t-Distributed Stochastic Neighbor Embedding*)**: técnica no lineal que convierte las distancias euclidianas entre pares de observaciones en probabilidades condicionales de vecindad y minimiza la divergencia de Kullback-Leibler respecto a una distribución $t$ de Student de un grado de libertad en el espacio bidimensional.

### Reducción de Dimensionalidad con Herramientas CLI (`tapkee-reduce`: PCA y t-SNE)

#### La Herramienta Base: `tapkee`

**Tapkee** es una eficiente biblioteca de plantillas en C++ desarrollada por Sergey Lisitsyn ([http://tapkee.lisitsyn.me/](http://tapkee.lisitsyn.me/)) orientada al cálculo rápido de mapeos dimensionales. Entre los algoritmos integrados destacan:

- *Principal Component Analysis* (PCA)
- *t-Distributed Stochastic Neighbor Embedding* (t-SNE)
- *Multidimensional Scaling* (MDS)
- *Isomap*
- *Locally Linear Embedding* (LLE)

Como herramienta de línea de comandos, `tapkee` opera bajo la filosofía Unix clásica: lee una matriz puramente numérica sin encabezados y devuelve las coordenadas proyectadas delimitadas por espacios o comas. Sus argumentos principales son:

- `-i <archivo>`: archivo de entrada con los datos numéricos.
- `-o <archivo>`: archivo de destino para las coordenadas resultantes.
- `-m <método>`: método de reducción (`pca`, `t-sne`, `isomap`, `mds`, `lle`, etc.).
- `-td <dimensiones>`: dimensionalidad del espacio proyectado (típicamente `2`).
- `--delimiter <delimitador>`: carácter delimitador de columnas (por ejemplo, `","`).

Podemos verificar el funcionamiento elemental de la herramienta base extrayendo las columnas numéricas de los primeros 200 registros de `wine-both.csv` sin encabezados y despachando `tapkee` directamente:

```nu
# skip-docker-exec
open wine-both.csv
    | first 200
    | select fixed_acidity volatile_acidity citric_acid residual_sugar chlorides free_sulfur_dioxide total_sulfur_dioxide density ph sulphates alcohol
    | to csv --noheaders
    | save -f wine_matrix.csv

tapkee -i wine_matrix.csv -o wine_pca_coords.tsv -m pca -td 2 --delimiter ","
open --raw wine_pca_coords.tsv | lines | first 5
```

Si bien la herramienta binaria procesa los números con enorme rapidez, utilizarla de manera cruda en un flujo analítico presenta limitaciones evidentes: las columnas de texto (como `type`) deben eliminarse previamente, los encabezados deben suprimirse y las coordenadas resultantes quedan desconectadas de las filas originales, exigiendo complejas operaciones manuales de unión.

#### Implementación del Wrapper: `tapkee-reduce`

Para resolver esta brecha y ofrecer una experiencia analítica ergonómica que preserve la estructura tabular de Nushell, el módulo `dsin_tools.nu` define el comando wrapper **`tapkee-reduce`**:

```nu
# Run Tapkee dimensionality reduction on a numeric Nushell table and return a structured table.
export def tapkee-reduce [
  --method(-m): string = "pca" # Tapkee method: pca, ltsa, isomap, mds, tsne, t-sne, lle
  --target-dim(-d): int = 2    # Number of output dimensions
  --label-col(-l): string      # Optional label column to preserve alongside coordinates
  --cols(-c): list<string>     # Optional explicit list of feature columns
]: table -> table {
  let tbl = $in
  let norm_method = if $method == "tsne" { "t-sne" } else { $method }
  let num_tbl = if ($cols != null) and (($cols | length) > 0) {
    $tbl | select ...$cols
  } else if ($label_col != null) and ($label_col | is-not-empty) and ($label_col in ($tbl | columns)) {
    $tbl | reject $label_col
  } else {
    let non_num = ["type"] | where {|c| $c in ($tbl | columns)}
    if ($non_num | is-not-empty) { $tbl | reject ...$non_num } else { $tbl }
  }

  let tmp_in = mktemp --suffix ".csv"
  let tmp_out = mktemp --suffix ".tsv"
  $num_tbl | to csv --noheaders | save -f $tmp_in

  tapkee -i $tmp_in -o $tmp_out -m $norm_method -td $target_dim --delimiter ","
  let raw_coords = open --raw $tmp_out | lines | where ($it | str trim | is-not-empty)
  rm -f $tmp_in $tmp_out

  let coords_tbl = $raw_coords | each { |line|
    let parts = $line | split row "," | each { |v| $v | str trim | into float | math round -p 4 }
    mut rec = {}
    for idx in 0..<($parts | length) {
      let val = $parts | get $idx
      $rec = ($rec | insert $"dim($idx + 1)" $val | insert $"dim_($idx + 1)" $val)
    }
    $rec
  }

  $tbl | merge $coords_tbl
}
```

Analicemos la arquitectura del comando:

1. **Aislamiento de atributos numéricos:** Examina los argumentos de entrada. Si se especifican columnas con `--cols`, las selecciona; de lo contrario, excluye automáticamente columnas de etiquetas categóricas como `type`.
2. **Archivos temporales limpios con `mktemp`:** Genera rutas efímeras y exporta la matriz mediante `to csv --noheaders`.
3. **Invocación transparente de `tapkee`:** Ejecuta el binario C++ con el método seleccionado.
4. **Reintegración tabular con `merge`:** Lee la salida estructurada, redondea las coordenadas a cuatro decimales y fusiona horizontalmente los campos `dim_1` y `dim_2` con la tabla original, preservando todas las etiquetas y atributos iniciales.

#### Ejecución en Pipelines de Nushell

Con este wrapper integrado, la reducción de dimensionalidad se expresa como una única etapa fluida dentro del pipeline:

Apliquemos primero **PCA** sobre una muestra de 200 vinos de `wine-both.csv`:

```nu
let features = ["fixed_acidity" "volatile_acidity" "citric_acid" "residual_sugar" "chlorides" "free_sulfur_dioxide" "total_sulfur_dioxide" "density" "ph" "sulphates" "alcohol"]
open wine-both.csv | first 200 | tapkee-reduce --method pca --cols $features | select type quality dim_1 dim_2 | first 10
open wine-both.csv | first 200 | tapkee-reduce --method pca --cols $features | select type quality dim_1 dim_2 | save -f wine_pca_tapkee.csv
```

Del mismo modo, cambiando únicamente `--method pca` por `--method t-sne`, obtenemos la proyección no lineal **t-SNE** con `tapkee`:

```nu
let features = ["fixed_acidity" "volatile_acidity" "citric_acid" "residual_sugar" "chlorides" "free_sulfur_dioxide" "total_sulfur_dioxide" "density" "ph" "sulphates" "alcohol"]
open wine-both.csv | first 150 | tapkee-reduce --method t-sne --cols $features | select type quality dim_1 dim_2 | first 10
open wine-both.csv | first 150 | tapkee-reduce --method t-sne --cols $features | select type quality dim_1 dim_2 | save -f wine_tsne_tapkee.csv
```

![Proyecciones bidimensionales obtenidas mediante reducción de dimensionalidad](dscl_0902.png)

### Reducción de Dimensionalidad con `Rscript` (`pca_wine.R`)

Veamos el script `pca_wine.R` ubicado en `/data/ch09`, el cual utiliza la función nativa `prcomp(..., center = TRUE, scale. = TRUE)` de R para calcular todas las componentes principales y reportar la proporción de varianza explicada y acumulada de cada componente:

```nu
bat pca_wine.R
Rscript pca_wine.R | from csv
Rscript pca_wine.R | from csv | save -f wine_pca_r.csv
```

Observa cómo las primeras 4 componentes principales resumen más del 64% de la varianza total de las 11 variables químicas originales.

### Reducción de Dimensionalidad con Python (`pca_wine.py`)

Revisemos y ejecutemos ahora el script `pca_wine.py`, que utiliza `StandardScaler` y `PCA` de `scikit-learn`:

```nu
bat pca_wine.py
python3 pca_wine.py | from csv
python3 pca_wine.py | from csv | save -f wine_pca_py.csv
```

### Diagnóstico de Multicolinealidad (VIF) y Regresión de Componentes Principales (PCR)

En problemas de regresión con múltiples variables predictoras altamente correlacionadas, la estimación por mínimos cuadrados ordinarios (**MCO**) sufre de **multicolinealidad severa**. Esto infla drásticamente la varianza de los coeficientes estimados y torna inestables las predicciones. Una métrica estadística estándar para diagnosticar este fenómeno es el **Factor de Inflación de la Varianza** (**VIF**, *Variance Inflation Factor*):

$$\text{VIF}_j = \frac{1}{1 - R_j^2}$$

donde $R_j^2$ es el coeficiente de determinación obtenido al regresar la variable predictora $X_j$ sobre todas las demás variables predictoras. Un valor de $\text{VIF} > 10$ (y con mayor razón $\text{VIF} > 100$) señala multicolinealidad crítica.

En `/data/ch09`, el archivo `Fish.csv` contiene variables biométricas de peces (`Length1`, `Length2`, `Length3`, `Height`, `Width`) utilizadas para predecir el peso (`Weight`). Al existir tres medidas longitudinales contiguas, la multicolinealidad es extrema.

El método de **Regresión de Componentes Principales** (**PCR**, *Principal Component Regression*) resuelve este problema proyectando las variables explicativas originales sobre sus componentes principales ortogonales (que tienen covarianza exactamente cero) antes de ajustar la regresión lineal.

Ejecutemos el script `vif_pcr_fish.py` para calcular los valores de VIF y comparar el modelo de regresión múltiple tradicional frente al modelo PCR con 2 componentes principales:

```nu
bat vif_pcr_fish.py
python3 vif_pcr_fish.py | from csv
python3 vif_pcr_fish.py | from csv | save -f fish_pcr_py.csv
open fish_vif_py.csv
```

Observemos cómo en Python las variables de longitud presentan valores de VIF superiores a 1.000, mientras que el modelo PCR con solo 2 componentes principales retiene más del 99% de la varianza explicada y logra un $R^2$ casi idéntico al modelo MCO completo sin riesgo de colinealidad.

Ejecutemos también la versión equivalente en R (`vif_pcr_fish.R`):

```nu
bat vif_pcr_fish.R
Rscript vif_pcr_fish.R | from csv
Rscript vif_pcr_fish.R | from csv | save -f fish_pcr_r.csv
```

## Agrupamiento o Clustering

El **agrupamiento (*clustering*)** es una tarea de aprendizaje no supervisado cuyo objetivo es particionar un conjunto de $n$ observaciones en $K$ grupos o clústeres disjuntos $C_1, C_2, \dots, C_K$ de modo que las observaciones dentro de un mismo clúster sean lo más similares posible entre sí, y lo más distintas posible a las de otros clústeres.

El algoritmo **K-Means** busca encontrar los centroides $\boldsymbol{\mu}_1, \dots, \boldsymbol{\mu}_K \in \mathbb{R}^p$ que minimizan la suma de cuadrados dentro de los clústeres (*Within-Cluster Sum of Squares*, WCSS):

$$\underset{C_1, \dots, C_K}{\arg\min} \sum_{k=1}^{K} \sum_{\mathbf{x}_i \in C_k} \|\mathbf{x}_i - \boldsymbol{\mu}_k\|_2^2$$

Un requisito estadístico indispensable antes de aplicar K-Means sobre variables con distintas unidades físicas (como `total_sulfur_dioxide` en mg/L frente a `density` en g/cm$^3$) es **estandarizar las variables** a media cero y desviación estándar unitaria, para evitar que la variable de mayor escala numérica domine la distancia euclidiana.

### Clustering K-Means con Herramientas CLI (`kmeans-cluster`)

#### Fundamento del Algoritmo y Estandarización Previa

En tareas de agrupamiento con atributos que presentan órdenes de magnitud muy dispares (por ejemplo, `total_sulfur_dioxide` alcanza valores de hasta 440 mg/L mientras que `density` varía entre 0.98 y 1.03 g/cm$^3$), el cálculo de distancias euclidianas queda completamente sesgado por la variable con mayor varianza escalar. Por tanto, antes de calcular centroides es imperativo aplicar **estandarización $z$-score**:

$$z_{ij} = \frac{x_{ij} - \bar{x}_j}{s_j}$$

#### Implementación del Wrapper: `kmeans-cluster`

En lugar de requerir que el analista escriba manualmente scripts externos de preparación y ajuste cada vez que desea evaluar clústeres, el comando **`kmeans-cluster`** (disponible en `dsin_tools.nu`) encapsula la estandarización, el ajuste del modelo y la asignación de clústeres directamente desde la terminal de Nushell:

```nu
# Run K-Means clustering on a numeric Nushell table and return cluster assignments.
export def kmeans-cluster [
  --k(-k): int = 2             # Number of clusters K
  --clusters: int = 0          # Alias for --k
  --label-col(-l): string      # Optional label column to exclude from features
  --cols(-c): list<string>     # Optional explicit list of feature columns
]: table -> table {
  let tbl = $in
  let n_clusters = if $clusters > 0 { $clusters } else { $k }
  let tmp_in = mktemp --suffix ".csv"
  let tmp_py = mktemp --suffix ".py"
  $tbl | to csv | save -f $tmp_in

  let lbl = $label_col | default "type"
  let cols_csv = if ($cols != null) and (($cols | length) > 0) {
    $cols | str join ","
  } else { "" }

  'import sys, pandas as pd
from sklearn.preprocessing import StandardScaler
from sklearn.cluster import KMeans

df = pd.read_csv(sys.argv[1])
k = int(sys.argv[2])
lbl = sys.argv[3]
cols_arg = sys.argv[4]
if cols_arg:
    num_cols = [c for c in cols_arg.split(",") if c in df.columns]
else:
    num_cols = [c for c in df.columns if c not in (lbl, "type") and pd.api.types.is_numeric_dtype(df[c])]
X = StandardScaler().fit_transform(df[num_cols])
km = KMeans(n_clusters=k, n_init=10, random_state=42)
clusters = km.fit_predict(X)
df["cluster"] = [f"cluster_{c+1}" for c in clusters]
df.to_csv(sys.stdout, index=False)
' | save -f $tmp_py

  let res = python3 $tmp_py $tmp_in ($n_clusters | into string) $lbl $cols_csv | from csv
  rm -f $tmp_in $tmp_py
  $res
}
```

El script interno automatiza tres operaciones esenciales:

1. Filtra los predictores numéricos excluyendo las variables de respuesta o clasificación (`type`).
2. Aplica `StandardScaler()` para garantizar una escala euclidiana homogénea.
3. Ajusta `KMeans(n_clusters=k, n_init=10)` y agrega la etiqueta `cluster_1`, `cluster_2`, etc., a cada fila, devolviendo una tabla regular de Nushell lista para agregaciones.

#### Ejecución y Análisis de Contingencia

Apliquemos `kmeans-cluster --k 2` sobre las 11 variables químicas de `wine-both.csv` (sin revelar la columna `type` al algoritmo) y comparemos los clústeres descubiertos contra el tipo real de vino (`red` vs `white`):

```nu
let features = ["fixed_acidity" "volatile_acidity" "citric_acid" "residual_sugar" "chlorides" "free_sulfur_dioxide" "total_sulfur_dioxide" "density" "ph" "sulphates" "alcohol"]
let clustered = open wine-both.csv | kmeans-cluster --k 2 --cols $features
$clustered | select type quality alcohol volatile_acidity cluster | first 10
$clustered | select type quality alcohol volatile_acidity cluster | save -f wine_kmeans_cli.csv
```

Podemos evaluar en Nushell la correspondencia entre los 2 clústeres no supervisados y la clase real `type` agrupando por `cluster` y `type`:

```nu
let features = ["fixed_acidity" "volatile_acidity" "citric_acid" "residual_sugar" "chlorides" "free_sulfur_dioxide" "total_sulfur_dioxide" "density" "ph" "sulphates" "alcohol"]
open wine-both.csv | kmeans-cluster --k 2 --cols $features | polars into-df | polars group-by cluster type | polars agg [(polars col quality | polars count | polars as n_vinos) (polars col alcohol | polars mean | polars as mean_alcohol)] | polars collect | polars into-nu | sort-by cluster type
open wine-both.csv | kmeans-cluster --k 2 --cols $features | polars into-df | polars group-by cluster type | polars agg [(polars col quality | polars count | polars as n_vinos) (polars col alcohol | polars mean | polars as mean_alcohol)] | polars collect | polars into-nu | sort-by cluster type | save -f wine_kmeans_contingency.csv
```

¡Incluso sin etiquetas supervisadas, K-Means en el espacio químico estandarizado separa con altísima pureza los vinos tintos de los vinos blancos!

### Clustering K-Means con `Rscript` (`cluster_wine.R`)

Veamos el script `cluster_wine.R` en `/data/ch09`, que ejecuta `kmeans(..., centers = 3, nstart = 20)` en R y resume el tamaño y el perfil químico promedio de cada clúster:

```nu
bat cluster_wine.R
Rscript cluster_wine.R | from csv
Rscript cluster_wine.R | from csv | save -f wine_clusters_r.csv
```

### Clustering K-Means con Python (`cluster_wine.py`)

Revisemos y ejecutemos ahora el script `cluster_wine.py` con `scikit-learn` (`KMeans(n_clusters=3, random_state=42, n_init=10)`):

```nu
bat cluster_wine.py
python3 cluster_wine.py | from csv
python3 cluster_wine.py | from csv | save -f wine_clusters_py.csv
```

### Clustering Jerárquico Aglomerativo (hclust_fish.R y hclust_fish.py)

A diferencia de K-Means, que requiere especificar *a priori* el número de conglomerados $K$ y converge a particiones rígidas, el **clustering jerárquico** (*Hierarchical Clustering*) construye una jerarquía anidada de agrupamientos mediante una matriz de distancias disimilares $\mathbf{D} \in \mathbb{R}^{n \times n}$.

El enfoque **aglomerativo** (*bottom-up*) inicia con cada observación individual como un clúster unitario y, en cada paso, fusiona el par de clústeres más cercanos de acuerdo a un criterio de enlace (*linkage criterion*). Entre los criterios más robustos en minería de datos destaca el método de **Ward (`ward.D2`)**, que une en cada iteración el par de clústeres que minimiza el incremento en la varianza total dentro de los grupos.

En `/data/ch09`, disponemos del conjunto `Fish.csv` (159 observaciones de especies de peces comerciales con medidas biométricas: peso, 3 longitudes, altura y ancho). Ejecutemos el script `hclust_fish.R`, que escala las medidas, calcula la matriz de distancias euclidianas, aplica `hclust(d, method = "ward.D2")`, corta el árbol en $K = 3$ grupos mediante `cutree(hc, k = 3)` y resume la correspondencia con las especies dominantes:

```nu
bat hclust_fish.R
Rscript hclust_fish.R | from csv
Rscript hclust_fish.R | from csv | save -f fish_hclust_r.csv
```

De igual modo, el script `hclust_fish.py` evalúa el clustering jerárquico aglomerativo con `scikit-learn` (`AgglomerativeClustering(linkage="ward")`) para distintos números de clústeres ($K = 2, 3, 4, 5$) calculando el coeficiente de silueta (*Silhouette Score*):

```nu
bat hclust_fish.py
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
bat cluster_eval.py
python3 cluster_eval.py | from csv
python3 cluster_eval.py | from csv | save -f banco_cluster_eval.csv
```

Podemos ordenar en Nushell la tabla por coeficiente de silueta descendente para identificar inmediatamente la partición más compacta:

```nu
open banco_cluster_eval.csv | sort-by silhouette -r
```

### Clustering Basado en Densidad con DBSCAN y K-Medoides con PAM

Los algoritmos particionales como K-Means asumen que los conglomerados son esféricos, convexos y de tamaño similar. Cuando los datos presentan geometrías complejas o contienen observaciones atípicas extremas (*outliers*), se requieren paradigmas alternativos de agrupamiento:

1. **DBSCAN (*Density-Based Spatial Clustering of Applications with Noise*)**: Define los clústeres como regiones densas de puntos separadas por regiones de baja densidad. Posee dos parámetros fundamentales: el radio de vecindad $\varepsilon$ (`eps`) y el número mínimo de puntos `min_samples` requeridos para formar un núcleo denso. Aquellos puntos que no pertenecen a ninguna vecindad densa son catalogados automáticamente como **ruido o anomalías** (etiqueta `-1`), sin forzarlos artificialmente dentro de ningún clúster.
2. **K-Medoides con PAM (*Partitioning Around Medoids*)**: A diferencia de K-Means (que utiliza la media aritmética como centroide, haciéndolo vulnerable a valores atípicos), PAM restringe los centros a **observaciones reales del conjunto de datos** (*medoides*), ofreciendo una partición mucho más robusta ante distribuciones asimétricas y contaminación por valores extremos.

Ejecutemos el script `dbscan_fish.py` sobre las medidas biométricas estandarizadas de `Fish.csv` (`Weight`, `Length1`, `Length2`, `Length3`, `Height`, `Width`):

```nu
bat dbscan_fish.py
python3 dbscan_fish.py | from csv
python3 dbscan_fish.py | from csv | save -f fish_dbscan_py.csv
```

Observemos cómo DBSCAN aísla automáticamente los ejemplares gigantescos como grupo `-1` (`Ruido / Outliers`) con un peso promedio superior a 1.400 gramos, evitando que distorsionen los clústeres homogéneos de peces medianos y pequeños.

Por su parte, el script `pam_fish.R` ejecuta el algoritmo PAM de la librería `cluster` en R para obtener los medoides representativos y la silueta promedio:

```nu
bat pam_fish.R
Rscript pam_fish.R | from csv
Rscript pam_fish.R | from csv | save -f fish_pam_r.csv
```

## Regresión: Predicción de la Calidad del Vino

En el problema de **regresión supervisada**, deseamos aprender una función $f(\mathbf{x}) \approx y$ que prediga una variable respuesta cuantitativa ($y = \text{quality}$) a partir del vector de predictores fisicoquímicos $\mathbf{x} \in \mathbb{R}^{11}$.

Para evaluar rigurosamente la capacidad de generalización del modelo sobre datos no vistos, dividimos el conjunto de vinos blancos (`wine-white.csv`) en un conjunto de entrenamiento (`wine_train.csv`, primeros 3.500 registros) y un conjunto de prueba (`wine_test.csv`, registros restantes) utilizando las métricas:

- **Error Absoluto Medio (MAE)**: $\text{MAE} = \frac{1}{n}\sum_{i=1}^n |y_i - \hat{y}_i|$
- **Raíz del Error Cuadrático Medio (RMSE)**: $\text{RMSE} = \sqrt{\frac{1}{n}\sum_{i=1}^n (y_i - \hat{y}_i)^2}$

### Regresión en Línea con Vowpal Wabbit (`vw-regress`)

#### La Herramienta Base: Vowpal Wabbit (`vw`)

**Vowpal Wabbit (`vw`)** es un sistema de aprendizaje automático de alto rendimiento desarrollado originalmente en Yahoo! Research y mantenido por Microsoft Research bajo el liderazgo de John Langford ([https://vowpalwabbit.org/](https://vowpalwabbit.org/)). Está optimizado para aprendizaje en línea (*online learning*) a gran escala mediante algoritmos de gradiente descendente estocástico (SGD) y trucos de *hashing* de características (*feature hashing*), lo que le permite procesar flujos masivos de datos con consumo de memoria constante.

#### Formato Nativo de Entrada de Vowpal Wabbit

A diferencia de las herramientas estándar que aceptan tablas CSV, `vw` utiliza un formato textual propio altamente eficiente diseñado para representaciones dispersas y espacios de nombres. La estructura formal de cada línea es:

```text
[etiqueta] [peso] [etiqueta_opcional]|EspacioNombres caracteristica1:valor1 caracteristica2:valor2 ...
```

Por ejemplo, una observación del conjunto de datos de vino blanco se expresa como:

```text
6 |f fixed_acidity:7 volatile_acidity:0.27 citric_acid:0.36 residual_sugar:20.7 chlorides:0.045 free_sulfur_dioxide:45 total_sulfur_dioxide:170 density:1.001 ph:3 pH:3 sulphates:0.45 alcohol:8.8
```

Donde:

- `6`: valor de la variable respuesta cuantitativa (`quality`).
- `|f`: el símbolo de barra vertical divide la etiqueta de las características; `f` es el identificador del espacio de nombres (*features*).
- `fixed_acidity:7 ...`: pares clave-valor numéricos que definen los predictores.

#### Comandos Base de Entrenamiento y Prueba en `vw`

En la línea de comandos estándar de Unix, el flujo con `vw` consta de dos llamadas fundamentales:

1. **Entrenamiento del modelo:**
   ```bash
   vw --data train.vw --final_regressor model.vw --passes 10 -c -l 0.5 --quiet
   ```
   - `--data`: archivo de entrenamiento en formato VW.
   - `--final_regressor`: archivo binario de salida donde se guardan los pesos ajustados del modelo.
   - `--passes`: número de iteraciones completas sobre los datos.
   - `-c` / `--cache_file`: genera y utiliza un archivo de caché binario optimizado para relecturas rápidas durante múltiples pasadas.
   - `-l`: tasa de aprendizaje inicial (*learning rate*) del gradiente descendente.
   - `--quiet`: suprime las impresiones diagnósticas por cada bloque de registros.

2. **Evaluación y predicción sobre datos de prueba:**
   ```bash
   vw --data test.vw -i model.vw -t -p preds.txt --quiet
   ```
   - `-i`: carga los pesos del modelo preentrenado.
   - `-t`: modo prueba (*test-only*), congelando los pesos sin actualizar el modelo.
   - `-p`: archivo de salida donde se registrarán las predicciones escalares generadas.

#### Implementación de los Wrappers: `to-vw` y `vw-regress`

En Nushell no es necesario depender de herramientas externas como `csv2vw` ni gestionar manualmente archivos intermedios. El módulo `dsin_tools.nu` define dos comandos complementarios:

El conversor **`to-vw`**, que transforma cualquier tabla de Nushell en una lista de cadenas con el formato nativo de Vowpal Wabbit:

```nu
# Convert a Nushell table into Vowpal Wabbit (VW) line format.
export def to-vw [
  --target(-t): string = "quality" # Name of target column
  --namespace(-n): string = "f"    # Feature namespace label
]: table -> list<string> {
  let tbl = $in
  let cols = $tbl | columns | where $it != $target
  $tbl | each { |row|
    let y = $row | get $target
    let feats = $cols | each { |c| $"($c):($row | get $c)" } | str join " "
    $"($y) |($namespace) ($feats)"
  }
}
```

Y el comando orquestador **`vw-regress`**, que entrena el modelo sobre una tabla de entrenamiento, infiere predicciones sobre la tabla de prueba y devuelve una tabla estructurada de Nushell:

```nu
# Train and evaluate a Vowpal Wabbit regression model and return predictions as a Nushell table.
export def vw-regress [
  train_tbl: table
  test_tbl: table
  --target(-t): string = "quality"
  --passes(-p): int = 10
  --learning-rate(-l): float = 0.5
]: nothing -> table {
  let tmp_dir = mktemp -d
  let train_vw = $"($tmp_dir)/train.vw"
  let test_vw = $"($tmp_dir)/test.vw"
  let model_file = $"($tmp_dir)/model.vw"
  let pred_file = $"($tmp_dir)/preds.txt"

  $train_tbl | to-vw --target $target | str join "\n" | save -f $train_vw
  $test_tbl | to-vw --target $target | str join "\n" | save -f $test_vw

  vw --data $train_vw --final_regressor $model_file --passes $passes -l $learning_rate --cache_file $"($tmp_dir)/train.cache" --quiet
  vw --data $test_vw -i $model_file -t -p $pred_file --quiet

  let preds = open --raw $pred_file | lines | where ($it | str trim | is-not-empty) | each { |x| $x | into float }
  let actuals = $test_tbl | get $target | each { |x| $x | into float }

  rm -rf $tmp_dir

  $actuals | zip $preds | each { |pair|
    let obs = $pair.0
    let pred = $pair.1 | math round -p 4
    let signed_err = (($pred - $obs) | math round -p 4)
    let err = (($obs - $pred) | math abs | math round -p 4)
    { actual: $obs, observed: $obs, predicted: $pred, error: $signed_err, abs_error: $err }
  }
}
```

#### Ejecución del Pipeline en Nushell

Evaluemos el modelo entrenando sobre los primeros 3.500 vinos blancos y prediciendo sobre los 1.398 restantes:

```nu
let data = open wine-white.csv
let train = $data | first 3500
let test = $data | skip 3500
let preds = vw-regress $train $test --target quality --passes 15
$preds | first 10
$preds | save -f wine_vw_predictions.csv
```

Calculemos el MAE y el error medio directamente en Nushell a partir de las predicciones de `vw-regress` y guardémoslos en un archivo resumen:

```nu
let preds = open wine_vw_predictions.csv
let metrics = {model: "Vowpal Wabbit (SGD)", n_test: ($preds | length), mae: ($preds.abs_error | math avg | math round --precision 4), bias: ($preds.error | math avg | math round --precision 4)}
$metrics
[$metrics] | save -f wine_vw_metrics.csv
```

### Regresión Lineal Múltiple con `Rscript` (`regress_wine.R`)

Veamos el script `regress_wine.R`, que ajusta un modelo lineal clásico por mínimos cuadrados ordinarios (`lm(quality ~ ., data = train)`) sobre los primeros 3.500 registros, evalúa el RMSE y MAE en el conjunto de prueba y devuelve los coeficientes estimados ($\hat{\beta}_j$, error estándar, estadístico $t$ y valor $p$):

```nu
bat regress_wine.R
Rscript regress_wine.R | from csv
Rscript regress_wine.R | from csv | save -f wine_regression_r.csv
```

Podemos filtrar en Nushell únicamente los predictores estadísticamente significativos al nivel $\alpha = 0.01$:

```nu
open wine_regression_r.csv | where p_value < 0.01 | sort-by t_stat -r
open wine_regression_r.csv | where p_value < 0.01 | sort-by t_stat -r | save -f wine_significant_predictors.csv
```

### Regresión Regularizada (Ridge) con Python (`regress_wine.py`)

Ejecutemos ahora el script `regress_wine.py`, que estandariza los predictores y ajusta una regresión Ridge ($\ell_2$) con `scikit-learn`:

```nu
bat regress_wine.py
python3 regress_wine.py | from csv
python3 regress_wine.py | from csv | save -f wine_regression_py.csv
```

## Clasificación Supervisada

Finalmente, abordemos el problema de **clasificación supervisada**: predecir una etiqueta categórica discreta (por ejemplo, si un vino es tinto o blanco en `wine-both.csv`, o si un cliente bancario aceptará un préstamo en `banco.csv`) a partir de sus atributos.

### Experimentos de Clasificación con SKLL (`run_experiment` + `skll-metrics`)

#### La Herramienta Base: SciKit-Learn Laboratory (`skll`)

**SKLL** (*SciKit-Learn Laboratory*, pronunciado *skull*) es un entorno de línea de comandos desarrollado por Educational Testing Service (ETS) para automatizar experimentos reproducibles de aprendizaje automático con `scikit-learn` sin requerir código Python repetitivo ([https://skll.readthedocs.io/](https://skll.readthedocs.io/)).

La ejecución se gobierna íntegramente mediante un archivo de configuración declarativo `.cfg`. En `/data/ch09` disponemos de `classify.cfg`, cuya estructura examinamos a continuación:

```ini
[General]
experiment_name = wine
task = evaluate

[Input]
train_directory = train
test_directory = test
featuresets = [["features.csv"]]
learners = ["LogisticRegression", "RandomForestClassifier", "LinearSVC"]
label_col = type

[Tuning]
grid_search = false
objectives = ['accuracy']

[Output]
results_directory = output
log = output
```

Los bloques principales definen:

- `task = evaluate`: evalúa los modelos especificados sobre el conjunto de prueba independiente (`test_directory`).
- `learners`: lista de algoritmos de `scikit-learn` a entrenar y comparar de manera competitiva en paralelo.
- `label_col`: columna con la variable respuesta o etiqueta supervisada.
- `results_directory`: carpeta donde SKLL guardará las predicciones detalladas y el archivo de resumen consolidado `wine_summary.tsv`.

El comando base para iniciar el experimento desde la terminal es:

```bash
run_experiment -l classify.cfg
```

#### Implementación del Wrapper: `skll-metrics`

Para incorporar los resultados de SKLL de forma transparente a los pipelines de Nushell sin necesidad de recurrir a herramientas clásicas de corte de columnas, el módulo `dsin_tools.nu` proporciona el comando **`skll-metrics`**:

```nu
# Parse SKLL experiment summary TSV into a clean Nushell table.
export def skll-metrics [
  summary_tsv: path = "output/wine_summary.tsv"
]: nothing -> table {
  let target_path = if ($summary_tsv | path exists) {
    $summary_tsv
  } else if ("output/wine_summary.tsv" | path exists) {
    "output/wine_summary.tsv"
  } else {
    $summary_tsv
  }
  open $target_path | select learner_name accuracy
}
```

#### Ejecución y Comparación Tabular

Inspeccionemos `classify.cfg`, ejecutemos `run_experiment` y procesemos el resultado con `skll-metrics`:

```nu
open --raw classify.cfg
run_experiment -l classify.cfg
skll-metrics output/wine_summary.tsv
skll-metrics output/wine_summary.tsv | save -f wine_skll_summary.csv
```

### Clasificación con Regresión Logística en `Rscript` (`classify_wine.R`)

Veamos y ejecutemos el script `classify_wine.R` en `/data/ch09`, que entrena un modelo lineal generalizado binomial (`glm(is_red ~ ., family = binomial())`) sobre una muestra estratificada de entrenamiento y evalúa su exactitud, sensibilidad y especificidad sobre el conjunto de prueba:

```nu
bat classify_wine.R
Rscript classify_wine.R | from csv
Rscript classify_wine.R | from csv | save -f wine_classification_r.csv
```

### Clasificación con Random Forest en Python (`classify_wine.py`)

Revisemos y ejecutemos `classify_wine.py`, que entrena un clasificador de Bosques Aleatorios (*Random Forest*) con 100 árboles en `scikit-learn` y devuelve la tabla de importancia de variables (*feature importances*) junto con la exactitud en prueba (`test_accuracy`):

```nu
bat classify_wine.py
python3 classify_wine.py | from csv
python3 classify_wine.py | from csv | save -f wine_classification_py.csv
```

Observa cómo `total_sulfur_dioxide`, `chlorides` y `volatile_acidity` emergen consistentemente como las variables más discriminantes para distinguir entre vinos tintos y blancos.

### Árboles de Decisión con R y Python (dt_banco.R y dt_banco.py)

Los **árboles de decisión** (*Decision Trees*) representan una familia fundamental de modelos supervisados no paramétricos ampliamente utilizados en minería de datos por su alta interpretabilidad y capacidad para modelar relaciones no lineales sin requerir escalado previo de atributos.

Evaluemos la predicción de aceptación de préstamos sobre `banco.csv` (5.000 clientes) utilizando `rpart` en R (`dt_banco.R` con profundidad máxima de 4 niveles):

```nu
bat dt_banco.R
Rscript dt_banco.R | from csv
Rscript dt_banco.R | from csv | save -f banco_dt_r.csv
```

Ejecutemos ahora el clasificador equivalente en Python con `DecisionTreeClassifier` de `scikit-learn` (`dt_banco.py`):

```nu
bat dt_banco.py
python3 dt_banco.py | from csv
python3 dt_banco.py | from csv | save -f banco_dt_py.csv
```

### Clasificación con Vecinos Más Cercanos k-NN (knn_banco.R y knn_banco.py)

El clasificador **$k$-Vecinos Más Cercanos ($k$-NN, *k-Nearest Neighbors*)** es un método de aprendizaje basado en instancias que clasifica una nueva observación asignándole la clase mayoritaria entre sus $k$ vecinos más próximos en el espacio de características estandarizado.

Ejecutemos `knn_banco.R` para evaluar el clasificador en R (`class::knn`) sobre `banco.csv` con $k \in \{3, 5, 7\}$:

```nu
bat knn_banco.R
Rscript knn_banco.R | from csv
Rscript knn_banco.R | from csv | save -f banco_knn_r.csv
```

Y ejecutemos la contraparte en Python utilizando `KNeighborsClassifier` (`knn_banco.py`):

```nu
bat knn_banco.py
python3 knn_banco.py | from csv
python3 knn_banco.py | from csv | save -f banco_knn_py.csv
```

### Clasificación Alternativa: Naïve Bayes y Máquinas de Vectores de Soporte (nb_svm_banco.py)

Como complemento a los árboles y vecinos cercanos, la minería de datos contemporánea emplea con frecuencia dos paradigmas adicionales:

1. **Clasificador Bayesiano Ingenuo Gaussiano (*Gaussian Naïve Bayes*)**: Aplica el teorema de Bayes asumiendo independencia condicional entre los predictores dada la clase, modelando cada atributo continuo mediante una distribución normal.
2. **Máquinas de Vectores de Soporte (SVM, *Support Vector Machines*)**: Encuentran el hiperplano óptimo que maximiza el margen de separación entre clases en un espacio inducido por un núcleo de base radial (RBF).

Ejecutemos `nb_svm_banco.py` para comparar el desempeño de ambos clasificadores sobre `banco.csv`:

```nu
bat nb_svm_banco.py
python3 nb_svm_banco.py | from csv
python3 nb_svm_banco.py | from csv | save -f banco_nb_svm_py.csv
```

La tabla comparativa resultante permite a Nushell ordenar los modelos según su métrica $F_1$-score:

```nu
open banco_nb_svm_py.csv | sort-by f1_score -r
```

### Redes Neuronales Artificiales: Perceptrón Multicapa (MLP)

Las **Redes Neuronales Artificiales** (*Artificial Neural Networks*, ANN) representan una de las familias más poderosas del aprendizaje automático contemporáneo. El **Perceptrón Multicapa** (**MLP**, *Multi-Layer Perceptron*) está compuesto por una capa de entrada, una o más capas ocultas con funciones de activación no lineales (como $\text{ReLU}(z) = \max(0, z)$ o la función logística sigmoide $\sigma(z) = \frac{1}{1 + e^{-z}}$), y una capa de salida:

$$\mathbf{h}^{(1)} = \sigma\left(\mathbf{W}^{(1)} \mathbf{x} + \mathbf{b}^{(1)}\right), \quad \hat{y} = \sigma\left(\mathbf{W}^{(2)} \mathbf{h}^{(1)} + \mathbf{b}^{(2)}\right)$$

El aprendizaje se realiza mediante el algoritmo de **retropropagación del error** (*backpropagation*), calculando las derivadas parciales de la función de pérdida respecto a cada peso mediante la regla de la cadena y actualizándolos con optimizadores de gradiente como **Adam** o SGD, junto con regularización L2 ($\alpha$) para mitigar el sobreajuste.

Un principio fundamental en el entrenamiento de redes neuronales es su **extrema sensibilidad al escalado de los atributos**. Si las variables no están estandarizadas a media cero y varianza unitaria, el gradiente oscila violentamente o se desvanece en las dimensiones de gran escala, impidiendo la convergencia.

Ejecutemos el script `mlp_banco.py` sobre `banco.csv` para entrenar y evaluar dos arquitecturas de MLP (una capa con 8 neuronas y dos capas con $(16, 8)$ neuronas):

```nu
bat mlp_banco.py
python3 mlp_banco.py | from csv
python3 mlp_banco.py | from csv | save -f banco_mlp_py.csv
```

La red con arquitectura profunda $(16, 8)$ alcanza un $F_1$-score cercano a $0.95$ tras unas 400 iteraciones, superando el margen de los clasificadores lineales tradicionales.

De forma complementaria, el script `mlp_banco.R` entrena una red neuronal con la librería `nnet` en R:

```nu
bat mlp_banco.R
Rscript mlp_banco.R | from csv
Rscript mlp_banco.R | from csv | save -f banco_mlp_r.csv
```

## Modelado Moderno Nativo de Pipelines

Las utilidades clásicas de modelado en consola estudiadas en las secciones anteriores (`tapkee`, `vw` y `run_experiment`) fueron concebidas originalmente para *shells* POSIX orientadas a flujos planos de caracteres. Como las tuberías tradicionales de Unix carecen de esquemas tipados, cada herramienta histórica exige una capa adicional de formateo externo: `tapkee` requiere matrices numéricas sin encabezados y descarta las etiquetas de clase, `vw` obliga a serializar cada observación mediante gramáticas personalizadas de espacios de nombres (`to-vw`), y `skll` impone jerarquías rígidas de directorios (`train/`, `test/`, `output/`) gobernadas por archivos `.cfg` en disco.

En una *shell* tipada como Nushell, los motores de modelado pueden intercambiar tablas estructuradas (`table -> table`) directamente a través de flujos estándar sin configuraciones accesorias en disco. Dentro del contenedor `dsin`, los binarios autónomos compilados en C++ (`duckdb` y `lightgbm`) conviven junto a un entorno aislado de Python 3.12 en `/opt/modern-ml` (aprovisionado mediante el gestor estático `uv`), lo que permite integrar bibliotecas contemporáneas (`umap-learn`, `lightgbm` y `scikit-learn` 1.9+) preservando intactas las dependencias de Python 3.9 requeridas por `skll`. Verifiquemos las versiones disponibles directamente desde `/data/ch09`:

```nu
duckdb --version
uv --version
/opt/modern-ml/bin/python -c "import umap, lightgbm, sklearn; print(f'sklearn={sklearn.__version__}, lightgbm={lightgbm.__version__}')"
```

### Proyección Topológica de Variedades con UMAP (`umap-reduce`)

Mientras el Análisis de Componentes Principales restringe la proyección a combinaciones lineales ortogonales y t-SNE optimiza afinidades locales por pares con alto costo computacional sin conservar distancias globales entre conglomerados, **UMAP** (*Uniform Manifold Approximation and Projection*, McInnes et al., 2018) representa los datos de alta dimensión mediante un conjunto simplicial difuso ponderado sobre una variedad riemanniana localmente conexa. Al minimizar la entropía cruzada difusa entre los grafos topológicos de alta y baja dimensión, el algoritmo preserva simultáneamente la estructura vecinal fina (controlada por `--neighbors`) y la disposición global entre grupos (controlada por `--min-dist`).

En `dsin_tools.nu`, el comando **`umap-reduce`** estandariza automáticamente las columnas numéricas, calcula la proyección en `/opt/modern-ml` y devuelve la tabla original de Nushell enriquecida con las coordenadas `umap_1` y `umap_2`:

```nu
# Compute UMAP manifold coordinates on a numeric Nushell table and return a structured table.
export def umap-reduce [
  --neighbors(-n): int = 15    # Size of local neighborhood
  --min-dist(-m): float = 0.1  # Minimum effective distance between embedded points
  --target-dim(-d): int = 2    # Number of embedding dimensions
  --seed(-s): int = 42         # Random state for reproducibility
  --label-col(-l): string      # Optional label column to exclude from features and preserve
  --cols(-c): list<string>     # Optional explicit list of numeric feature columns
]: table -> table {
  let tbl = $in
  let tmp_in = mktemp --suffix ".csv"
  let tmp_py = mktemp --suffix ".py"
  $tbl | to csv | save -f $tmp_in

  let lbl = $label_col | default "type"
  let cols_csv = if ($cols != null) and (($cols | length) > 0) {
    $cols | str join ","
  } else { "" }

  r#'import os, sys, warnings
os.environ.setdefault("NUMBA_CACHE_DIR", "/tmp/numba_cache")
warnings.filterwarnings("ignore")
import pandas as pd
from sklearn.preprocessing import StandardScaler
import umap

df = pd.read_csv(sys.argv[1])
n_neighbors = int(sys.argv[2])
min_dist = float(sys.argv[3])
n_components = int(sys.argv[4])
seed = int(sys.argv[5])
lbl = sys.argv[6]
cols_arg = sys.argv[7]

if cols_arg:
    num_cols = [c for c in cols_arg.split(",") if c in df.columns]
else:
    num_cols = [c for c in df.columns if c != lbl and pd.api.types.is_numeric_dtype(df[c])]

X = StandardScaler().fit_transform(df[num_cols])
reducer = umap.UMAP(
    n_neighbors=min(n_neighbors, max(2, len(df) - 1)),
    min_dist=min_dist,
    n_components=n_components,
    random_state=seed,
)
emb = reducer.fit_transform(X)
for idx in range(n_components):
    df[f"umap_{idx + 1}"] = emb[:, idx].round(4)
df.to_csv(sys.stdout, index=False)
'# | save -f $tmp_py

  let res = ^/opt/modern-ml/bin/python $tmp_py $tmp_in ($neighbors | into string) ($min_dist | into string) ($target_dim | into string) ($seed | into string) $lbl $cols_csv | from csv
  rm -f $tmp_in $tmp_py
  $res
}
```

A diferencia de `tapkee`, que omite los metadatos categóricos salvo que se reintegren por posición de fila, `umap-reduce` conserva `type` y `quality` alineados dentro de un único pipeline:

```nu
let features = ["fixed_acidity" "volatile_acidity" "citric_acid" "residual_sugar" "chlorides" "free_sulfur_dioxide" "total_sulfur_dioxide" "density" "ph" "sulphates" "alcohol"]
open wine-both.csv | first 200 | umap-reduce --label-col type --cols $features | select type quality umap_1 umap_2 | first 10
open wine-both.csv | first 200 | umap-reduce --label-col type --cols $features | select type quality umap_1 umap_2 | save -f wine_umap.csv
```

Para contrastar geométricamente la maximización lineal de varianza, la atracción de vecindarios locales y la proyección topológica sobre las mismas mediciones fisicoquímicas, el script `/data/ch09/plot_umap_comparison.py` genera un panel triple con PCA, t-SNE y UMAP sobre una muestra balanceada de 800 vinos, inspeccionable directamente en consola mediante `timg`:

```nu
bat plot_umap_comparison.py
/opt/modern-ml/bin/python plot_umap_comparison.py
timg -g 80x25 umap_comparison.png
```

![Comparación de proyecciones bidimensionales mediante PCA, t-SNE y UMAP sobre atributos fisicoquímicos del vino](umap_comparison.png){width=95%}

### Árboles Potenciados por Gradiente desde CLI con LightGBM (`lgbm-regress`)

Vowpal Wabbit sobresale al procesar millones de indicadores dispersos de texto que exceden la memoria principal, pero en tablas densas con una docena de predictores continuos el *hashing* lineal pierde interacciones no lineales y umbrales de partición. **LightGBM** (Ke et al., 2017) compila en un ejecutable C++ autónomo (`/usr/local/bin/lightgbm`) que agrupa variables continuas en histogramas discretos y expande los árboles de regresión por hoja (*leaf-wise*) según la mayor reducción de pérdida cuadrática. Para el trabajo en consola, `lightgbm` lee archivos CSV con encabezados de forma nativa (`header=true` y `label_column=name:quality`), eliminando por completo codificadores manuales por línea como `to-vw`.

El comando **`lgbm-regress`** en `dsin_tools.nu` coordina el entrenamiento, la predicción fuera de muestra y el cálculo de importancia por ganancia de partición directamente sobre tablas de entrenamiento y prueba de Nushell:

```nu
# Train and evaluate standalone LightGBM C++ CLI regression on train/test Nushell tables.
export def lgbm-regress [
  train_tbl: table
  test_tbl: table
  --target(-t): string = "quality"
  --num-trees(-n): int = 100
  --learning-rate(-l): float = 0.05
  --num-leaves: int = 31
  --importance(-i)             # Return sorted feature-gain importance table instead of test predictions
]: nothing -> table {
  let tmp_dir = mktemp -d
  let train_csv = $"($tmp_dir)/train.csv"
  let test_csv = $"($tmp_dir)/test_features.csv"
  let model_file = $"($tmp_dir)/model.txt"
  let pred_file = $"($tmp_dir)/preds.txt"

  let feat_cols = $train_tbl | columns | where $it != $target
  $train_tbl | select ...($feat_cols | append $target) | to csv | save -f $train_csv
  $test_tbl | select ...$feat_cols | to csv | save -f $test_csv

  ^lightgbm task=train objective=regression $"data=($train_csv)" header=true $"label_column=name:($target)" $"num_trees=($num_trees)" $"learning_rate=($learning_rate)" $"num_leaves=($num_leaves)" seed=42 deterministic=true force_col_wise=true $"output_model=($model_file)" verbosity=-1 out+err> /dev/null

  if $importance {
    let imp_py = $"($tmp_dir)/imp.py"
    r#'import json, sys, lightgbm as lgb
booster = lgb.Booster(model_file=sys.argv[1])
names = booster.feature_name()
splits = booster.feature_importance(importance_type="split")
gains = booster.feature_importance(importance_type="gain")
total_gain = float(gains.sum()) if float(gains.sum()) > 0 else 1.0
rows = [
    {
        "feature": str(n),
        "splits": int(s),
        "gain": round(float(g), 4),
        "gain_pct": round(float(g) * 100.0 / total_gain, 2),
    }
    for n, s, g in zip(names, splits, gains)
]
rows.sort(key=lambda r: r["gain"], reverse=True)
print(json.dumps(rows))
'# | save -f $imp_py
    let imp_tbl = ^/opt/modern-ml/bin/python $imp_py $model_file | from json
    rm -rf $tmp_dir
    return $imp_tbl
  }

  ^lightgbm task=predict $"data=($test_csv)" header=true $"input_model=($model_file)" $"output_result=($pred_file)" verbosity=-1 out+err> /dev/null

  let preds = open --raw $pred_file | lines | where ($it | str trim | is-not-empty) | each { |x| $x | into float }
  let actuals = $test_tbl | get $target | each { |x| $x | into float }
  rm -rf $tmp_dir

  $actuals | zip $preds | each { |pair|
    let obs = $pair.0
    let pred = $pair.1 | math round -p 4
    let signed_err = ($pred - $obs) | math round -p 4
    let abs_err = ($obs - $pred) | math abs | math round -p 4
    { actual: $obs, observed: $obs, predicted: $pred, error: $signed_err, abs_error: $abs_err }
  }
}
```

Al evaluar `lgbm-regress` sobre la misma partición de 3,500 filas de entrenamiento y 1,398 de prueba en `wine-white.csv` empleada antes con Vowpal Wabbit, el Error Absoluto Medio (MAE) en validación desciende de `0.5693` (`vw-regress`) a `0.5429`, mientras que el modificador `--importance` cuantifica el aporte estructural de cada predictor:

```nu
let white = open wine-white.csv
let train_w = $white | first 3500
let test_w = $white | skip 3500
let preds_lgbm = lgbm-regress $train_w $test_w --target quality
$preds_lgbm | get abs_error | math avg | math round -p 4
lgbm-regress $train_w $test_w --target quality --importance
```

La graduación alcohólica concentra la mayor reducción acumulada de error (`33.54%` de la ganancia total), seguida por `volatile_acidity` (`12.17%`), `free_sulfur_dioxide` (`11.07%`) y `residual_sugar` (`7.85%`).

### Regresión Analítica Vectorizada en Proceso con DuckDB (`duckdb-ols`)

Antes de ajustar ensambles multiparamétricos, el diagnóstico estadístico riguroso aconseja examinar las relaciones lineales marginales de cada regresor candidato. **DuckDB** (Raasveldt & Mühleisen, 2019) encapsula un motor SQL analítico columnar y vectorizado dentro de un único binario portátil (`/usr/local/bin/duckdb`) con salida nativa en JSON (`duckdb -json`). Sus funciones estadísticas agregadas del estándar SQL:2003 (`regr_slope`, `regr_intercept`, `corr`, `regr_r2` y `regr_count`) estiman parámetros de Mínimos Cuadrados Ordinarios en bucles SIMD de una sola pasada en menos de 200 milisegundos.

El comando **`duckdb-ols`** envía cualquier tabla de Nushell hacia `duckdb -json` y reconstruye de inmediato una tabla tipada ordenada por coeficiente de determinación ($R^2$):

```nu
# Compute vectorized Ordinary Least Squares regression diagnostics via DuckDB CLI.
export def duckdb-ols [
  --target(-y): string = "quality" # Dependent response column
  --predictor(-x): string = ""     # Optional single predictor column (omit to rank all numeric predictors)
]: table -> table {
  let tbl = $in
  let first_row = $tbl | first
  let candidate_cols = if ($predictor | is-not-empty) {
    [$predictor]
  } else {
    $tbl | columns | where { |c|
      ($c != $target) and ((($first_row | get $c | describe) == "int") or (($first_row | get $c | describe) == "float"))
    }
  }

  let tmp_csv = mktemp --suffix ".csv"
  $tbl | select ...($candidate_cols | append $target) | to csv | save -f $tmp_csv

  let unions = $candidate_cols | each { |col|
    $"SELECT '($col)' AS predictor, ROUND\(regr_slope\(\"($target)\", \"($col)\"\), 4\) AS slope, ROUND\(regr_intercept\(\"($target)\", \"($col)\"\), 4\) AS intercept, ROUND\(corr\(\"($target)\", \"($col)\"\), 4\) AS pearson_r, ROUND\(regr_r2\(\"($target)\", \"($col)\"\), 4\) AS r_squared, CAST\(regr_count\(\"($target)\", \"($col)\"\) AS BIGINT\) AS n FROM tbl"
  } | str join " UNION ALL "

  let sql = $"CREATE TEMP TABLE tbl AS SELECT * FROM read_csv_auto\('($tmp_csv)'\); SELECT * FROM \(($unions)\) ORDER BY r_squared DESC;"
  let res = ^duckdb -json -c $sql | from json
  rm -f $tmp_csv
  $res
}
```

Al recorrer los 11 predictores fisicoquímicos sobre las 4,898 observaciones de `wine-white.csv`, emerge con claridad la diferencia entre asociación lineal marginal y ganancia no lineal en árboles:

```nu
open wine-white.csv | duckdb-ols --target quality
open wine-white.csv | duckdb-ols --target quality --predictor alcohol
```

En términos lineales simples, `alcohol` presenta el mayor poder explicativo individual ($\hat{\beta}_1 = 0.3135$, $r = 0.4356$, $R^2 = 0.1897$), escoltado por `density` ($r = -0.3071$, $R^2 = 0.0943$) y `chlorides` ($r = -0.2099$, $R^2 = 0.0441$). Por el contrario, `free_sulfur_dioxide` y `residual_sugar` registran un $R^2$ marginal casi nulo bajo ajuste lineal, aunque ocupan el tercer y cuarto lugar en ganancia dentro de LightGBM; su efecto sensorial opera mediante umbrales e interacciones químicas (concentraciones insuficientes de dióxido de azufre libre favorecen la oxidación, mientras que niveles excesivos generan notas picantes indeseadas).

### Evaluación Multimarco en Streaming y Redes Neuronales (`ml-benchmark`)

En la sección dedicada a SKLL (`run_experiment`), comparar una Regresión Logística frente a un Bosque Aleatorio requirió poblar carpetas `train/` y `test/`, redactar un archivo declarativo `classify.cfg` y extraer métricas desde archivos tabulados en `output/`. Un diseño nativo para pipelines prescinde por completo de ese andamiaje en disco.

El comando **`ml-benchmark`** recibe cualquier tabla de Nushell mediante `$in`, ejecuta una partición estratificada de entrenamiento y prueba, aplica preprocesamiento diferenciado por tipo de columna (`StandardScaler` y `OneHotEncoder` para algoritmos sensibles a la escala, paso directo de variables numéricas para árboles) y compara cinco familias de modelos en una sola instrucción:

1. **Regresión Logística (`logistic`):** Clasificador lineal penalizado en escala *log-odds*.
2. **Máquina de Soporte Vectorial Lineal (`linear_svc`):** Hiperplano de margen máximo con pérdida bisagra (*hinge loss*).
3. **Perceptrón Multicapa (`mlp`):** Red neuronal prealimentada (`MLPClassifier`) con dos capas ocultas ReLU de $(64, 32)$ unidades, optimizador Adam y detención temprana (*early stopping*).
4. **Bosque Aleatorio (`rf`):** Ensamble *bagging* de árboles de decisión descorrelacionados.
5. **LightGBM (`lgbm`):** Árboles de decisión potenciados por gradiente basados en histogramas.

```nu
# Benchmark multiple classification architectures (including MLP) on a Nushell table in one streaming pipeline.
export def ml-benchmark [
  --target(-t): string = "type"
  --models(-m): list<string> = ["logistic", "rf", "lgbm", "linear_svc", "mlp"]
  --test-size: float = 0.25
  --seed(-s): int = 42
]: table -> table {
  let tbl = $in
  let tmp_in = mktemp --suffix ".csv"
  let tmp_py = mktemp --suffix ".py"
  $tbl | to csv | save -f $tmp_in
  let models_csv = $models | str join ","

  r#'import json, sys, time, warnings
warnings.filterwarnings("ignore")
import pandas as pd
from sklearn.compose import ColumnTransformer
from sklearn.ensemble import RandomForestClassifier
from sklearn.linear_model import LogisticRegression
from sklearn.metrics import accuracy_score, f1_score, precision_score, recall_score
from sklearn.model_selection import train_test_split
from sklearn.neural_network import MLPClassifier
from sklearn.pipeline import Pipeline
from sklearn.preprocessing import LabelEncoder, OneHotEncoder, StandardScaler
from sklearn.svm import LinearSVC
from lightgbm import LGBMClassifier

df = pd.read_csv(sys.argv[1])
target = sys.argv[2]
models = [m.strip() for m in sys.argv[3].split(",") if m.strip()]
test_size = float(sys.argv[4])
seed = int(sys.argv[5])

X = df.drop(columns=[target])
le = LabelEncoder()
y = le.fit_transform(df[target].astype(str))

num_cols = [c for c in X.columns if pd.api.types.is_numeric_dtype(X[c])]
cat_cols = [c for c in X.columns if c not in num_cols]

prep_scaled = ColumnTransformer(
    transformers=[
        ("num", StandardScaler(), num_cols),
        ("cat", OneHotEncoder(handle_unknown="ignore"), cat_cols),
    ],
    remainder="drop",
)
prep_tree = ColumnTransformer(
    transformers=[
        ("num", "passthrough", num_cols),
        ("cat", OneHotEncoder(handle_unknown="ignore", sparse_output=False), cat_cols),
    ],
    remainder="drop",
)

X_train, X_test, y_train, y_test = train_test_split(
    X, y, test_size=test_size, random_state=seed, stratify=y
)

registry = {
    "logistic": Pipeline([("prep", prep_scaled), ("clf", LogisticRegression(max_iter=500, random_state=seed))]),
    "rf": Pipeline([("prep", prep_tree), ("clf", RandomForestClassifier(n_estimators=150, random_state=seed, n_jobs=-1))]),
    "lgbm": Pipeline([("prep", prep_tree), ("clf", LGBMClassifier(n_estimators=150, learning_rate=0.05, random_state=seed, verbose=-1, n_jobs=-1))]),
    "linear_svc": Pipeline([("prep", prep_scaled), ("clf", LinearSVC(random_state=seed, max_iter=2000))]),
    "mlp": Pipeline([("prep", prep_scaled), ("clf", MLPClassifier(hidden_layer_sizes=(64, 32), activation="relu", early_stopping=True, max_iter=300, random_state=seed))]),
}

rows = []
for name in models:
    if name not in registry:
        raise ValueError(f"Unsupported model key: {name}")
    pipe = registry[name]
    t0 = time.perf_counter()
    pipe.fit(X_train, y_train)
    elapsed_ms = (time.perf_counter() - t0) * 1000.0
    preds = pipe.predict(X_test)
    rows.append({
        "model": name,
        "accuracy": round(float(accuracy_score(y_test, preds)), 4),
        "precision": round(float(precision_score(y_test, preds, average="weighted", zero_division=0)), 4),
        "recall": round(float(recall_score(y_test, preds, average="weighted", zero_division=0)), 4),
        "f1_score": round(float(f1_score(y_test, preds, average="weighted", zero_division=0)), 4),
        "train_time_ms": round(elapsed_ms, 2),
    })

rows.sort(key=lambda r: r["f1_score"], reverse=True)
print(json.dumps(rows))
'# | save -f $tmp_py

  let res = ^/opt/modern-ml/bin/python $tmp_py $tmp_in $target $models_csv ($test_size | into string) ($seed | into string) | from json
  rm -f $tmp_in $tmp_py
  $res
}
```

La comparación simultánea de las cinco arquitecturas sobre `wine-both.csv` y sobre la cartera bancaria `banco.csv` se reduce a pipelines directos de una línea, sin generar archivos `.cfg` ni directorios residuales:

```nu
open wine-both.csv | ml-benchmark --target type
open banco.csv | reject ID ZIP_cod | ml-benchmark --target prestamo
```

En `banco.csv`, donde la aceptación del crédito personal depende de umbrales marcados de ingreso, nivel educacional y tamaño familiar, las fronteras lineales se estabilizan cerca de $F_1 \approx 0.95$ (`logistic` con `0.9484` y `linear_svc` con `0.9511`). La incorporación de capas ocultas no lineales mediante el Perceptrón Multicapa (`mlp`) eleva el $F_1$ ponderado hasta `0.9797` en menos de medio segundo de ajuste, mientras que los ensambles de árboles alineados con los ejes (`rf` con `0.9895` y `lgbm` con `0.9919`) alcanzan la mayor discriminación global, en concordancia con la evidencia empírica reciente sobre datos tabulares heterogéneos (Grinsztajn et al., 2022). Al devolver una tabla nativa de Nushell, cualquier filtrado posterior (`where train_time_ms < 500` o `first 3`) se encadena directamente con los operadores estándar del lenguaje.

### La Frontera del Aprendizaje Automático Nativo en Rust

Dado que tanto el núcleo de Nushell como `nu_plugin_polars` están implementados en Rust sobre el formato columnar en memoria Apache Arrow, la evolución natural del modelado en terminal apunta hacia complementos compilados en Rust que consuman lotes Arrow sin serialización intermedia a CSV o JSON. Cuatro desarrollos activos ilustran esta dirección técnica:

- **`linfa` y `smartcore`:** Bibliotecas de aprendizaje estadístico en Rust puro que implementan PCA, K-Means, DBSCAN, modelos lineales penalizados, máquinas de soporte vectorial y bosques aleatorios con verificación estricta de tipos en compilación.
- **`candle` y `burn`:** Motores minimalistas de cálculo tensorial y aprendizaje profundo en Rust capaces de compilar redes prealimentadas (`MLP`) y arquitecturas modernas en binarios autónomos con aceleración opcional por GPU y sin depender del intérprete de Python.
- **`nutorch`:** Complemento para Nushell que expone tensores de LibTorch como valores nativos dentro de los pipelines interactivos de la consola.

Aunque Python (`scikit-learn`, `umap-learn`) y C++ (`lightgbm`, `duckdb`) constituyen hoy los motores numéricos más maduros para el trabajo tabular cotidiano, conocer la arquitectura de plugins de Nushell prepara al ingeniero estadístico para adoptar flujos de modelado de copia cero (*zero-copy*) conforme madure el ecosistema científico en Rust.

## Resumen del Capítulo y Conclusión del Libro

En este capítulo completamos el ciclo OSEMN aplicando técnicas de modelado no supervisado y supervisado desde la línea de comandos:

1. **Reducción de dimensionalidad (PCA y t-SNE) y diagnóstico de multicolinealidad** con `tapkee-reduce`, `pca_wine.R`, `pca_wine.py`, `vif_pcr_fish.py` y `vif_pcr_fish.R`.
2. **Agrupamiento (K-Means, Jerárquico, DBSCAN y PAM)** con `kmeans-cluster`, `cluster_wine.R`, `cluster_wine.py`, `hclust_fish.R`, `hclust_fish.py`, `cluster_eval.py`, `dbscan_fish.py` y `pam_fish.R`.
3. **Regresión supervisada** con Vowpal Wabbit (`vw-regress`), `regress_wine.R`, `regress_wine.py` y Regresión de Componentes Principales (PCR).
4. **Clasificación supervisada** con SKLL (`run_experiment` + `skll-metrics`), `classify_wine.R`, `classify_wine.py`, árboles de decisión (`dt_banco.R` y `dt_banco.py`), $k$-NN (`knn_banco.R` y `knn_banco.py`), Naïve Bayes y SVM (`nb_svm_banco.py`), y Perceptrón Multicapa (`mlp_banco.py` y `mlp_banco.R`).
5. **Modelado moderno nativo de pipelines** eliminando el formateo manual de texto y archivos `.cfg` mediante proyecciones topológicas **UMAP** (`umap-reduce`), árboles potenciados por gradiente en C++ con **LightGBM** (`lgbm-regress`), regresión analítica vectorizada en proceso con **DuckDB** (`duckdb-ols`) y evaluación multimarco en streaming incluyendo redes neuronales (`ml-benchmark`).

A lo largo de los nueve capítulos de **Ciencia de Datos en la Línea de Comandos con Nushell**, hemos comprobado que una shell moderna basada en tablas tipadas, combinada con DataFrames perezosos en Polars, paralelismo nativo (`par-each` y GNU `parallel`), edición y visualización en terminal (`ttt` y `timg`) e interoperabilidad fluida con R, Python y motores compilados dentro del contenedor `dsin`, constituye un entorno científico reproducible, expresivo y de alto rendimiento para la Ciencia de Datos.


\newpage

# Para seguir explorando

Como este libro trata sobre la intersección de la línea de comandos y la ciencia de datos, muchos temas relacionados solo se han mencionado superficialmente. Las siguientes subsecciones proporcionan una lista de temas y recursos sugeridos para consultar.

## La Línea de Comandos

- _The Linux Command Line: A Complete Introduction, 2nd Edition_ Por William E. Shotts, Jr. (No Starch Press, 2019)
- _Unix Power Tools, 3rd Edition_ por Jerry Peek, Shelley Powers, Tim O'Reilly, y Mike Loukides (O'Reilly Media, 2002)
- _Learning the Vi and Vim Editors, 7th Edition_ por Arnold Robbins, Elbert Hannah, y Linda Lamb (O'Reilly Media, 2008)

## Programación de Shell

- _Classic Shell Scripting_ por Arnold Robbins y Nelson H.F. Beebe (O'Reilly Media, 2005)
- _Wicked Cool Shell Scripts, 2nd Edition_ por Dave Taylor y Brandon Perry (No Starch Press, 2017)
- _Bash Cookbook_ por Carl Albing JP Vossen (O'Reilly Media, 2018)
- _Nushell Book_: [https://www.nushell.sh/book/](https://www.nushell.sh/book/)

## Python, R y SQL

- _Learn Python 3 the Hard Way_ por Zed A. Shaw (Addison-Wesley Professional, 2017)
- _Python for Data Analysis, 2nd Edition_ por Wes McKinney (O'Reilly Media, 2017)
- _Data Science from Scratch, 2nd Edition_ por Joel Grus (O'Reilly Media, 2019)
- _R for Data Science_ por Garrett Grolemund y Hadley Wickham (O'Reilly Media, 2016)
- _R for Everyone, 2nd edition_ por Jared Lander (Addison-Wesley Professional, 2017)
- _Sams Teach Yourself SQL in 10 Minutes a Day, 5th Edition_ por Ben Forta (Sams, 2020)

## APIs

- _Mining the Social Web, 3rd Edition_ por Matthew A. Russell y Mikhail Klassen (O'Reilly Media, 2019)
- _Data Source Handbook_ por Pete Warden (O'Reilly Media, 2011)

## Aprendizaje Automático

- _Python Machine Learning, 3rd Edition_ por Sebastian Raschka y Vahid Mirjalili (Packt Publishing, 2019)
- _Pattern Recognition and Machine Learning_ por Christopher M. Bishop (Springer, 2006)
- _LightGBM Documentation_: [https://lightgbm.readthedocs.io/](https://lightgbm.readthedocs.io/)
- _DuckDB Documentation_: [https://duckdb.org/docs/](https://duckdb.org/docs/)
- _UMAP Documentation_: [https://umap-learn.readthedocs.io/](https://umap-learn.readthedocs.io/)



\newpage

# Referencias {#chapter-references}

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
- **DuckDB**: Motor de base de datos SQL analítico embebido y vectorizado en proceso. <https://duckdb.org/>
- **LightGBM**: Framework compilado de árboles de decisión potenciados por gradiente de alto rendimiento. <https://github.com/microsoft/LightGBM>
- **UMAP (`umap-learn`)**: Reducción de dimensionalidad no lineal mediante aproximación y proyección uniforme de variedades. <https://github.com/lmcinnes/umap>
- **uv**: Gestor ultrarrápido de paquetes y entornos aislados de Python escrito en Rust. <https://github.com/astral-sh/uv>
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
- **Ke, G., Meng, Q., Finley, T., Wang, T., Chen, W., Ma, W., Ye, Q., & Liu, T. Y. (2017)**. *LightGBM: A Highly Efficient Gradient Boosting Decision Tree*. Advances in Neural Information Processing Systems, 30, 3146-3154.
- **McInnes, L., Healy, J., & Melville, J. (2018)**. *UMAP: Uniform Manifold Approximation and Projection for Dimension Reduction*. arXiv preprint arXiv:1802.03426.
- **Raasveldt, M., & Mühleisen, H. (2019)**. *DuckDB: An Embeddable Analytical Database*. Proceedings of the 2019 International Conference on Management of Data (SIGMOD '19), 1981-1984.
- **Grinsztajn, L., Oyallon, E., & Varoquaux, G. (2022)**. *Why do tree-based models still outperform deep learning on typical tabular data?* Advances in Neural Information Processing Systems, 35, 507-520.
- **Hastie, T., Tibshirani, R., & Friedman, J. (2009)**. *The Elements of Statistical Learning: Data Mining, Inference, and Prediction* (2nd ed.). Springer New York.