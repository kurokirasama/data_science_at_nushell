## Descripción de los Cambios

> *Read the English version of this Pull Request template at [pull_request_template.md](pull_request_template.md).*

Por favor proporcione un resumen claro y conciso de las modificaciones propuestas en este Pull Request:

- **Qué:**
- **Por qué:**

Cierra # (número de issue, si aplica)

---

## Tipo de Modificación

Por favor marque la opción aplicable:

- [ ] **Errata / Mejora de Contenido:** Errores tipográficos, gramaticales o mejoras pedagógicas en [Files/DataScienceNushell.md](file:///home/kira/Dropbox/Documentos/Clases/UBB/DataScienceAtNushell/Files/DataScienceNushell.md).
- [ ] **Corrección en Tubería de Nushell:** Actualización de sintaxis o corrección de comandos.
- [ ] **Docker y Entorno:** Mejoras al [Dockerfile](file:///home/kira/Dropbox/Documentos/Clases/UBB/DataScienceAtNushell/docker/Dockerfile), utilidades del contenedor o scripts de actualización.
- [ ] **Documentación y Gobernanza:** Actualizaciones al README, guías de contribución o metadatos del repositorio.

---

## Lista de Verificación Técnica

Antes de enviar su PR, verifique cada uno de los siguientes puntos:

- [ ] **Ejecución en Contenedor:** Todos los comandos, scripts y tuberías fueron probados con éxito (código de salida 0) dentro de `ghcr.io/kurokirasama/dsin:latest`.
- [ ] **Ancho de Bloques de Código (<80 Caracteres):** Todas las líneas dentro de bloques de código respetan el límite de 80 caracteres (sin desborde en el PDF).
- [ ] **Formato de Tuberías:** Las tuberías multilínea ubican el símbolo `|` al final de la línea para permitir copiar y pegar en la terminal.
- [ ] **Consistencia Terminológica:** Sigue las convenciones del libro (*pipe* para operador, *pipeline* para flujos de trabajo).
- [ ] **Compilación PDF:** Se verificó la compilación de [Files/DataScienceNushell.pdf](file:///home/kira/Dropbox/Documentos/Clases/UBB/DataScienceAtNushell/Files/DataScienceNushell.pdf) mediante Pandoc y [Files/hide_skip.lua](file:///home/kira/Dropbox/Documentos/Clases/UBB/DataScienceAtNushell/Files/hide_skip.lua) sin errores.
