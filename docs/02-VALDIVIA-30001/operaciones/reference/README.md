# Archivos de referencia — worldmods VPS-only

Los worldmods de Valdivia viven dentro de `server/worlds/valdivia/worldmods/`, que está
**gitignored** (el mundo real está solo en el VPS). Esta carpeta guarda copias de referencia
en git para que sobrevivan aunque se pierda el VPS o se regenere el mundo.

## `arnis_mapgen-init.lua.corrected`

Versión **corregida** del worldmod `arnis_mapgen` que Arnis genera automáticamente.

El worldmod original que genera Arnis tiene dos comportamientos problemáticos en su
`register_on_joinplayer`:

1. **Forzaba el spawn en cada join** (`set_pos(SPAWN)` incondicional) → pisaba a
   `wetlands_lastpos` y los jugadores "siempre aparecían en spawn".
2. **Otorgaba `fly` y `fast` a todos** → vuelo universal, en conflicto con la política
   de que solo `gabo` vuela.

La versión corregida:
- Solo fuerza spawn a jugadores **nuevos** (sin metadata `wetlands_lastpos:pos`). A los que
  regresan los coloca `wetlands_lastpos`.
- **No toca privilegios** (eso es tarea de `valdivia_newplayer`).
- Conserva intactos: `set_mapgen_setting singlenode`, el `register_on_respawnplayer` (spawn al
  morir) y el globalstep de lazy fix-lighting.

### Cómo aplicarla tras regenerar Valdivia con Arnis

```bash
WM=/home/gabriel/luanti-voxelibre-server/server/worlds/valdivia/worldmods/arnis_mapgen/init.lua
scp docs/02-VALDIVIA-30001/operaciones/reference/arnis_mapgen-init.lua.corrected \
  gabriel@VPS:/tmp/arnis_fix.lua
ssh gabriel@VPS "sudo cp \$WM \${WM}.bak-\$(date +%Y%m%d-%H%M%S) && \
  sudo cp /tmp/arnis_fix.lua \$WM && sudo chown 1000:1000 \$WM && rm /tmp/arnis_fix.lua"
ssh gabriel@VPS "cd /home/gabriel/luanti-voxelibre-server && docker compose restart luanti-valdivia"
```

> ⚠️ Verificar que `SPAWN` en el archivo corresponda al spawn del mundo regenerado
> (puede cambiar entre generaciones de Arnis).
