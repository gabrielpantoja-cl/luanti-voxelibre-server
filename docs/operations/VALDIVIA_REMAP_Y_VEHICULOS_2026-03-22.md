# Valdivia 2.0 - Remap de texturas, vehiculos y notificaciones

**Fecha:** 22 marzo 2026
**Estado:** Completado (con tareas pendientes)

---

## Resumen

Sesion de mantenimiento del mundo Valdivia 2.0 (puerto 30001) para corregir texturas rojas/corruptas generadas por Arnis, habilitar todos los vehiculos, agregar notificaciones Discord, y actualizar la landing page.

---

## 1. Remap de texturas corruptas

### Problema

Arnis genera nodos con nombres que no existen en VoxeLibre, produciendo bloques rojos "no texture". Texturas detectadas en juego con F5:

| Nodo Arnis (incorrecto) | Nodo VoxeLibre (correcto) |
|------------------------|--------------------------|
| `mcl_core:redstone_block` | `mesecons_torch:redstoneblock` |
| `mcl_stairs:stair_wood_oak` | `mcl_stairs:stair_wood` |
| `mcl_core:sandstone_smooth` | `mcl_core:sandstonesmooth` |

### Solucion

Se agregaron mappings al script `scripts/remap-mineclonia-to-voxelibre.py`:

```python
# Stairs: Arnis usa sufijo _oak, VoxeLibre usa "wood" para oak
b"mcl_stairs:stair_wood_oak": b"mcl_stairs:stair_wood",
b"mcl_stairs:stair_wood_oak_inner": b"mcl_stairs:stair_wood_inner",
b"mcl_stairs:stair_wood_oak_outer": b"mcl_stairs:stair_wood_outer",
# Slabs: mismo patron _oak
b"mcl_stairs:slab_wood_oak": b"mcl_stairs:slab_wood",
b"mcl_stairs:slab_wood_oak_top": b"mcl_stairs:slab_wood_top",
b"mcl_stairs:slab_wood_oak_double": b"mcl_stairs:slab_wood_double",
```

Los mappings de `redstone_block` y `sandstone_smooth` ya existian en el script pero no se habian ejecutado sobre el map.sqlite en produccion.

### Ejecucion

```bash
# 1. Parar Valdivia
docker compose stop luanti-valdivia

# 2. Ejecutar remap (requiere zstandard)
sudo python3 scripts/remap-mineclonia-to-voxelibre.py server/worlds/valdivia/map.sqlite

# 3. Fix permisos y reiniciar
sudo chown -R 911:911 server/worlds/valdivia/
docker compose start luanti-valdivia
```

### Resultado

- **2,877,038 mapblocks** procesados
- **9,290 mapblocks** corregidos (0.32%)
- **Duracion:** ~25 minutos en VPS ARM Oracle Cloud
- **Backup automatico:** `map.sqlite.backup-before-remap` (441 MB)

### Leccion aprendida: optimizar para la proxima

El script procesa TODOS los mappings sobre TODOS los bloques, incluso los ya corregidos. Para la proxima vez, se deberia poder filtrar solo los mappings nuevos. Ver tarea pendiente abajo.

---

## 2. Vehiculos habilitados

Se habilitaron los 10 vehiculos del modpack `automobiles_pck` para Valdivia:

| Vehiculo | Estado anterior | Estado actual |
|----------|----------------|---------------|
| automobiles_lib | Habilitado | Habilitado |
| automobiles_vespa | Habilitado | Habilitado |
| automobiles_beetle | Habilitado | Habilitado |
| automobiles_motorcycle | Habilitado | Habilitado |
| automobiles_buggy | Habilitado | Habilitado |
| automobiles_trans_am | **Deshabilitado** | Habilitado |
| automobiles_roadster | **Deshabilitado** | Habilitado |
| automobiles_coupe | **Deshabilitado** | Habilitado |
| automobiles_catrelle | **Deshabilitado** | Habilitado |
| automobiles_delorean | **Deshabilitado** | Habilitado |

### Archivos modificados

- `server/config/luanti-valdivia.conf` - 5 nuevas lineas `load_mod_*`
- `server/worlds/valdivia/world.mt` (VPS) - 10 lineas `load_mod_*` agregadas

### Nota: conflicto de mods duplicados

Los 5 vehiculos originales existen en DOS ubicaciones:
- `server/mods/automobiles_beetle/` (sueltos)
- `server/mods/automobiles_pck/automobiles_beetle/` (dentro del modpack)

Luanti prioriza los sueltos y muestra warnings. No causa problemas funcionales pero genera ruido en los logs.

---

## 3. Notificaciones Discord para Valdivia

### Problema

El notificador Discord solo monitoreaba el servidor Wetlands (puerto 30000). Las conexiones/desconexiones en Valdivia (puerto 30001) no generaban notificaciones.

### Solucion

1. **Script actualizado** (`scripts/discord-notifier.sh`): nueva variable `SERVER_LABEL` para diferenciar mensajes
2. **docker-compose.yml**: nuevo servicio `discord-notifier-valdivia` con `CONTAINER_NAME=luanti-valdivia-server` y `SERVER_LABEL=Valdivia 2.0`
3. **Documentacion actualizada**: `docs/operations/DISCORD_NOTIFICATIONS.md`

### Estado actual

Container temporal lanzado manualmente (`docker run`) para no interrumpir la sesion de juego. En el proximo `docker compose up -d` sera reemplazado por el servicio gestionado por compose.

---

## 4. Landing page actualizada

Se agrego referencia a ambos mundos en la landing page (`server/landing-page/`):

- **Hero**: selector de mundos con cards para Wetlands (30000) y Valdivia 2.0 (30001) con badge "NUEVO" animado
- **Paso 2 "Conectarse"**: ambos puertos documentados
- **Caracteristicas**: nueva card "Valdivia 2.0" con badge "NUEVO"
- **Footer**: seccion "Mundos Disponibles" con ambos mundos
- **CSS**: cache-buster `?v=20260322` para forzar recarga de estilos

---

## 5. Anuncio en el servidor Wetlands

Se modifico `server/mods/server_rules/init.lua` para mostrar un anuncio rotativo cada 5 segundos invitando a los jugadores a probar Valdivia 2.0 en puerto 30001. Esto reemplaza temporalmente los 5 mensajes rotativos anteriores (reglas, spawn, web, discord).

---

## Tareas pendientes

### Alta prioridad

- [ ] **Reiniciar docker compose limpio** - Ejecutar `docker compose up -d` cuando no haya jugadores conectados para que los servicios queden gestionados por compose (especialmente `discord-notifier-valdivia`)
- [ ] **Verificar texturas en juego** - Confirmar visualmente que `mcl_core:redstone_block`, `mcl_stairs:stair_wood_oak` y `mcl_core:sandstone_smooth` ya no aparecen como bloques rojos
- [ ] **Buscar mas texturas rotas** - Explorar el mapa de Valdivia y anotar cualquier otro bloque rojo con F5 para agregar al remap

### Media prioridad

- [ ] **Optimizar script de remap** - Agregar opcion de filtrar por mappings especificos (ej: `--only "stair_wood_oak,redstone_block"`) para no reprocesar los 2.8M bloques completos cada vez
- [ ] **Limpiar mods duplicados de automobiles** - Decidir si eliminar los sueltos (`server/mods/automobiles_beetle/` etc.) o el modpack (`automobiles_pck/`), para eliminar los warnings de conflicto
- [ ] **Restaurar mensajes rotativos** - El anuncio de Valdivia cada 5 segundos es temporal. Eventualmente volver a los mensajes educativos (reglas, spawn, web, discord) o integrar Valdivia como uno mas de la rotacion

### Baja prioridad

- [ ] **Agregar coordenadas de Valdivia** - Seguir explorando y documentando en `docs/projects/VALDIVIA_COORDENADAS.md`
- [ ] **Screenshot de Valdivia para galeria** - Tomar capturas del mundo para agregar a la landing page y gallery data

---

## Commits relacionados

| Commit | Descripcion |
|--------|-------------|
| `e26e39d` | add oak stairs/slabs remap for Valdivia world |
| `4875c2f` | enable all automobile mods for Valdivia world |
| `2455414` | (usuario) server_rules, landing page, coordenadas |
| `00cc5d5` | add cache-buster to CSS for landing page update |
| `f6edf0f` | add Discord notifier for Valdivia server (port 30001) |
