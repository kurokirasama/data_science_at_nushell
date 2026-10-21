# Política de Seguridad

> *Read the English version of this policy at [SECURITY.md](SECURITY.md).*

## Alcance y Versiones Compatibles

Este proyecto ofrece un libro de acceso abierto sobre flujos de ciencia de datos en la terminal Linux junto con una imagen de contenedor Docker complementaria (`ghcr.io/kurokirasama/dsin:latest`).

Las consideraciones de seguridad aplican principalmente a:
1. La **imagen de contenedor `dsin`** publicada en GitHub Container Registry (paquetes base, vulnerabilidades en binarios de terceros, permisos de archivos y configuraciones predeterminadas).
2. Los **scripts de automatización y compilación** (`docker/update-dsin-nushell.nu`, scripts de configuración) que se ejecutan en estaciones de trabajo.

| Componente | Soporte Activo |
| :--- | :--- |
| `ghcr.io/kurokirasama/dsin:latest` | :white_check_mark: Soporte activo |
| `docker/Dockerfile` y scripts | :white_check_mark: Soporte activo |
| Versiones anteriores etiquetadas | :x: Sin soporte |

---

## Reportar una Vulnerabilidad

Nos tomamos en serio la seguridad de nuestra comunidad y estudiantes. Si descubre una posible vulnerabilidad de seguridad (por ejemplo, permisos inseguros en el contenedor, vulnerabilidades críticas conocidas o fallos de ejecución en scripts):

1. **NO abra un issue público en GitHub.**
2. Reporte la vulnerabilidad de forma privada a través de **GitHub Private Vulnerability Reporting** en la pestaña de Seguridad del repositorio (`Security > Report a vulnerability`).
3. Alternativamente, envíe un correo electrónico directo al mantenedor a [kurokirasama@gmail.com](mailto:kurokirasama@gmail.com) incluyendo:
   - Una descripción detallada de la vulnerabilidad.
   - Pasos para reproducirla o prueba de concepto.
   - Componente afectado (etiqueta de imagen Docker, ruta del script).
   - Impacto potencial estimado.

---

## Proceso de Respuesta y Mitigación

- **Recepción:** Confirmaremos la recepción de su reporte dentro de un plazo máximo de 48 horas.
- **Evaluación:** Verificaremos la incidencia, determinaremos su severidad y planificaremos la corrección.
- **Corrección:** Si se requiere un parche en el contenedor o en los scripts, se compilará, verificará y publicará una imagen actualizada en `ghcr.io/kurokirasama/dsin:latest`.
- **Divulgación:** Tras el despliegue del parche de seguridad, se publicará una nota de seguridad reconociendo la contribución de quien reportó (si así lo desea).
