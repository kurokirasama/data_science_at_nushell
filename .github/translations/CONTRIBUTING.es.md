# Guía de Contribución: Ciencia de Datos en la Terminal Linux con Nushell

¡Gracias por su interés en contribuir a *Ciencia de Datos en la Terminal Linux con Nushell*! Este repositorio alberga un libro de acceso abierto y un entorno Docker reproducible (`dsin`) diseñado para enseñar flujos modernos de ciencia de datos estructurados en la terminal Linux utilizando [Nushell](https://www.nushell.sh/).

> *Read the English version of this guide at [CONTRIBUTING.md](../CONTRIBUTING.md).*

---

## Tabla de Contenidos

- [Código de Conducta](#código-de-conducta)
- [¿Cómo Puede Contribuir?](#cómo-puede-contribuir)
  - [1. Texto del Libro y Erratas](#1-texto-del-libro-y-erratas)
  - [2. Tuberías de Nushell y Corrección de Código](#2-tuberías-de-nushell-y-corrección-de-código)
  - [3. Entorno Docker y Herramientas](#3-entorno-docker-y-herramientas)
- [Pautas Técnicas para Contribuciones](#pautas-técnicas-para-contribuciones)
  - [Verificación de Ejecución en Contenedor](#verificación-de-ejecución-en-contenedor)
  - [Ancho de Bloques de Código (<80 Caracteres)](#ancho-de-bloques-de-código-80-caracteres)
  - [Sintaxis de Tuberías y Terminología](#sintaxis-de-tuberías-y-terminología)
  - [Verificación de Compilación PDF](#verificación-de-compilación-pdf)
- [Flujo de Trabajo para Pull Requests](#flujo-de-trabajo-para-pull-requests)

---

## Código de Conducta

Se espera que todas las personas que participen o contribuyan en este proyecto sigan nuestro [Código de Conducta](CODE_OF_CONDUCT.es.md). Puede reportar cualquier conducta inapropiada a [kurokirasama@gmail.com](mailto:kurokirasama@gmail.com).

---

## ¿Cómo Puede Contribuir?

### 1. Texto del Libro y Erratas
Si encuentra erratas, errores tipográficos, explicaciones confusas o posibles mejoras conceptuales en [Files/DataScienceNushell.md](file:///home/kira/Dropbox/Documentos/Clases/UBB/DataScienceAtNushell/Files/DataScienceNushell.md):
- Abra un problema (*issue*) utilizando la plantilla **📖 Errata y Sugerencias de Contenido**.
- O envíe una solicitud de extracción (*pull request*) con las correcciones específicas.
- La prosa debe mantener un tono profesional, claro y en español latinoamericano neutro.

### 2. Tuberías de Nushell y Corrección de Código
Conforme Nushell evoluciona con nuevas versiones, algunas construcciones sintácticas o indicadores de complementos pueden actualizarse:
- Si un comando falla o puede expresarse de manera más idiomática mediante herramientas nativas de Nushell, envíe una propuesta o PR.
- Cada ejemplo de código debe producir datos estructurados (tablas, registros, listas) en lugar de cadenas de texto plano siempre que sea posible.

### 3. Entorno Docker y Herramientas
La imagen complementaria `ghcr.io/kurokirasama/dsin:latest` agrupa Nushell junto con herramientas CLI de modelado, editores y utilidades de datos:
- Sugerencias sobre nuevas utilidades de terminal, actualizaciones de paquetes o mejoras al [Dockerfile](file:///home/kira/Dropbox/Documentos/Clases/UBB/DataScienceAtNushell/docker/Dockerfile) son bienvenidas a través de la plantilla **💡 Propuesta de Nueva Característica**.

---

## Pautas Técnicas para Contribuciones

Para mantener la máxima calidad editorial y computacional, todas las contribuciones deben cumplir los siguientes requisitos:

### Verificación de Ejecución en Contenedor
Todos los comandos de terminal, scripts de Nushell, scripts de Python/R y ejemplos de modelado CLI deben ejecutarse con código de salida 0 dentro de la imagen oficial de Docker `dsin:latest`.

Antes de enviar un PR, pruebe sus comandos directamente dentro del contenedor:

```bash
docker run --rm -v $(pwd)/Files/data:/data ghcr.io/kurokirasama/dsin:latest \
  nu -c "cd /data/ch04; open iris.csv | first 5"
```

Para sesiones interactivas:
```bash
docker run --rm -it -v $(pwd)/Files/data:/data ghcr.io/kurokirasama/dsin:latest nu
```

### Ancho de Bloques de Código (<80 Caracteres)
El libro se compila a PDF mediante XeLaTeX. Las líneas extensas dentro de los bloques de código no se ajustan automáticamente y desbordan los márgenes de página:
- Mantenga todas las líneas dentro de bloques de código por debajo de **80 caracteres**.
- Divida tuberías largas en varias líneas colocando el símbolo de tubería (`|`) al final de la línea.

### Sintaxis de Tuberías y Terminología
1. **Compatibilidad con Terminal:** En tuberías multilínea, coloque la tubería (`|`) al final de la línea:
   ```nu
   open iris.csv |
     where sepal_length > 5.0 |
     select species sepal_length |
     first 3
   ```
2. **Consistencia Terminológica:**
   - Emplee **«pipe»** para referirse al operador o símbolo de redirección individual.
   - Emplee **«pipeline»** para referirse al flujo de procesamiento completo o secuencia de trabajo.
   - Conserve la definición formal inicial (*«tuberías o pipes de Unix»*) en la primera mención pedagógica.

### Verificación de Compilación PDF
Compruebe que sus cambios no produzcan advertencias ni errores en la compilación de Pandoc. El proyecto utiliza un filtro Lua nativo ([Files/hide_skip.lua](file:///home/kira/Dropbox/Documentos/Clases/UBB/DataScienceAtNushell/Files/hide_skip.lua)) para omitir etiquetas internas de prueba en el PDF:

```bash
cd Files
pandoc --pdf-engine=xelatex \
  --syntax-definition=nu.xml \
  --syntax-definition=nushell.xml \
  --syntax-highlighting=pandoc_highlight.theme \
  --lua-filter=hide_skip.lua \
  DataScienceNushell.md -o DataScienceNushell.pdf
```

Verifique que el PDF resultante compile limpiamente y sin desbordes.

---

## Flujo de Trabajo para Pull Requests

1. Cree una bifurcación (*fork*) y una rama a partir de `main`:
   ```bash
   git checkout -b fix/chapter-04-pipeline
   ```
2. Realice sus modificaciones y confirme con mensajes claros y convencionales (`docs: ...`, `fix: ...`, `refactor: ...`).
3. Verifique que los comandos funcionen en el contenedor y que el PDF compile correctamente.
4. Envíe el Pull Request hacia la rama `main`.
5. Complete la lista de verificación de la [Plantilla de Pull Request](pull_request_template.es.md).
