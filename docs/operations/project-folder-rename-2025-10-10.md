# 📂 Cambio de Nombre de Carpeta del Proyecto en VPS - 10 de Octubre de 2025

## Resumen
El 10 de octubre de 2025, la carpeta principal del proyecto en el VPS fue renombrada para alinearse con el nombre del repositorio y mejorar la consistencia.

## Detalles del Cambio
- **Fecha del Cambio**: 10 de Octubre de 2025
- **Ubicación**: VPS (gabriel@167.172.251.27)
- **Ruta Afectada**: `/home/gabriel/`
- **Nombre Anterior**: `luanti-voxelibre-server`
- **Nuevo Nombre**: `luanti-voxelibre-server`

## Razón del Cambio
El cambio se realizó para estandarizar el nombre del directorio del proyecto en el VPS con el nombre del repositorio de Git (`luanti-voxelibre-server.git`). Esto busca reducir confusiones y mejorar la gestión del proyecto.

## Impacto Potencial y Consideraciones
Este cambio puede tener implicaciones en scripts, configuraciones de Docker y otras herramientas que dependan de la ruta absoluta o relativa del proyecto.

### Áreas a Revisar:
1.  **Configuraciones de Docker Compose**: Asegurarse de que los `container_name` y las rutas de volúmenes en `docker-compose.yml` estén actualizadas. (Ya se realizó una actualización en `docker-compose.yml` para reflejar esto).
2.  **Scripts de Shell**: Cualquier script (`.sh`) que haga referencia a la ruta `/home/gabriel/Vegan-Wetlands` o al nombre `Vegan-Wetlands` debe ser actualizado. (Ya se realizó una actualización en los scripts de `scripts/` para reflejar esto).
3.  **Archivos de Configuración**: Otros archivos de configuración que puedan contener la ruta anterior.
4.  **Tareas Programadas (Cron Jobs)**: Si existen cron jobs que usen la ruta anterior, deben ser actualizados.
5.  **Documentación**: Actualizar cualquier documentación que haga referencia al nombre de la carpeta anterior.

## Acciones Tomadas (por Gemini)
- Se renombró la carpeta en el VPS de `luanti-voxelibre-server` a `luanti-voxelibre-server`.
- Se actualizaron las referencias en `docker-compose.yml`.
- Se actualizaron las referencias en los scripts de `scripts/`.
- Se actualizó el URL remoto de git en el VPS.

## Verificación
Se recomienda verificar el correcto funcionamiento de:
- El servidor Luanti.
- El sistema de backups.
- Cualquier script de mantenimiento o despliegue.

---
