# GEMINI.md

Este documento detalla el proceso de investigación y descubrimiento realizado por el asistente Gemini para resolver la discrepancia en la gestión de usuarios del servidor Vegan Wetlands.

## Misión: Encontrar Todos los Usuarios Registrados

El objetivo era encontrar un método para listar a todos los usuarios registrados en el servidor, ya que el usuario "pepelomo" no aparecía en las consultas iniciales.

### 1. Investigación Inicial (Método Documentado)

- **Consulta:** Se solicitó un método para ver los usuarios desde el juego.
- **Acción:** Se revisó la documentación existente, específicamente `docs/2-guia-de-administracion.md`.
- **Hallazgo:** El documento indicaba que la lista de usuarios se obtenía del archivo `auth.txt` con el siguiente comando:
  ```bash
  docker-compose exec luanti-server sh -c 'cat /config/.minetest/worlds/vegan_wetlands/auth.txt | cut -d: -f1'
  ```
- **Resultado:** Al ejecutar este comando (después de corregir la ruta del proyecto en el VPS), solo se encontró al usuario `gabo`.

### 2. La Pista del Usuario Faltante

- **Conflicto:** El usuario insistió en que existían más jugadores, como `pepelomo`. Esto contradecía el contenido de `auth.txt`.
- **Hipótesis 1: Mundo Equivocado.** Se pensó que los usuarios podrían estar en otro directorio de mundo.
- **Acción:** Se listaron los mundos en el servidor (`/config/.minetest/worlds/`).
- **Hallazgo:** Se encontró un segundo directorio llamado `world`, además de `vegan_wetlands`.
- **Acción Fallida:** Se intentó leer `auth.txt` del directorio `world`, pero el archivo no existía.

### 3. El Punto de Inflexión: `NUCLEAR_CONFIG_OVERRIDE.md`

- **Hipótesis 2: Backend de Autenticación Diferente.** Si no era `auth.txt`, debía ser otro sistema. Se revisó `luanti.conf`, pero no se encontró ninguna configuración que anulara el backend por defecto (`files`).
- **Descubrimiento Clave:** Se encontró un documento llamado `docs/NUCLEAR_CONFIG_OVERRIDE.md`. Este documento, que detalla modificaciones críticas hechas directamente en el servidor, fue la clave.
- **Revelación:** Dentro de este archivo, un comando para otorgar privilegios masivos contenía la siguiente pista:
  ```bash
  ... sqlite3 /config/.minetest/worlds/world/auth.sqlite ...
  ```
- **Conclusión:** El servidor no usaba `auth.txt`. La autenticación se gestionaba a través de una base de datos **SQLite (`auth.sqlite`)** ubicada en el directorio `world`.

### 4. La Solución Final

- **Acción Correcta:** Se construyó un nuevo comando para consultar la base de datos SQLite:
  ```bash
  ssh gabriel@167.172.251.27 "cd /home/gabriel/Vegan-Wetlands && docker-compose exec -T luanti-server sqlite3 /config/.minetest/worlds/world/auth.sqlite 'SELECT name FROM auth;'"
  ```
- **Éxito:** Este comando devolvió la lista completa y correcta de todos los usuarios registrados, incluyendo a `pepelomo`.

## Conclusión del Proceso

La documentación inicial estaba desactualizada. La fuente de la verdad sobre la infraestructura del servidor no estaba en la guía de administración principal, sino en un documento de anulación de configuración (`NUCLEAR_CONFIG_OVERRIDE.md`) que reflejaba los cambios manuales realizados en producción.

Este proceso de descubrimiento ha sido documentado para asegurar que el conocimiento sobre el sistema de autenticación `auth.sqlite` quede registrado y la documentación principal sea corregida.
