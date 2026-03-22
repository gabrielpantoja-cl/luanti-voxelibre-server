# Correccion de Lightmap en Mundos Generados por Arnis

## Problema

Arnis genera mapas de OpenStreetMap escribiendo directamente al `map.sqlite` sin calcular la iluminacion correctamente. Esto causa:

- **Sombras negras en el suelo** (nodos con light=0)
- **Follaje de arboles "quemado"** (hojas completamente negras bajo la copa)
- **Manchas oscuras estaticas** que no se mueven como sombras de nubes

Estos artefactos son **corrupcion de lightmap**, no problemas de texturas. Cada nodo en un mapblock almacena un valor de luz (0-15) y Arnis no propaga la luz solar correctamente.

## Solucion: Mod wetlands_fixlight

El mod `server/mods/wetlands_fixlight/` agrega dos comandos:

### `/fixlight_world`
Recalcula la luz en **todo el mundo** procesando chunks secuencialmente.

- Requiere privilegio `server`
- Muestra progreso cada 10%
- Procesa chunks de 32 nodos con 2s de delay entre cada uno
- Usa `minetest.emerge_area()` + `minetest.fix_light()`

### `/fixlight_stop`
Cancela un `/fixlight_world` en progreso.

## Parametros de rendimiento

El emerge de mapblocks genera lag. Si el lag supera ~3 segundos, los jugadores conectados reciben timeout ("Connection timed out").

| Parametro | Valor | Efecto |
|-----------|-------|--------|
| `CHUNK_SIZE` | 32 | Nodos por lado por chunk (2 mapblocks). Menor = menos lag por iteracion |
| `EMERGE_DELAY` | 2.0 | Segundos entre chunks. Mayor = menos lag pero mas lento |

**Estado actual:** Con CHUNK_SIZE=32 y EMERGE_DELAY=2.0, aun se producen timeouts esporadicos. Opciones para resolver:

1. **Ejecutar sin jugadores conectados** -- el timeout no afecta si nadie esta jugando
2. **Aumentar EMERGE_DELAY** a 3-5 segundos -- mas lento pero mas estable
3. **Reducir CHUNK_SIZE** a 16 -- chunks mas pequenos, menos picos de lag
4. **Solucion offline** -- script Python que modifique la luz directamente en el SQLite (complejo, requiere entender el formato de mapblock v29)

## Solucion alternativa: WorldEdit manual

Para corregir zonas especificas sin lag global:

```
//pos1          (en una esquina del area oscura)
//pos2          (en la esquina opuesta)
//fixlight      (recalcula luz en la seleccion)
```

## Remap de nodos (relacionado)

Arnis tambien genera nombres de nodos incorrectos que causan bloques rojos "no texture". Estos se corrigen con el script `scripts/remap-mineclonia-to-voxelibre.py` ANTES de subir el mapa al servidor.

Mapeos conocidos de Arnis:

| Nodo Arnis | Nodo VoxeLibre | Descripcion |
|------------|----------------|-------------|
| `mcl_core:chain` | `mcl_lanterns:chain` | Cadenas de postes de luz |
| `mcl_core:redstone_block` | `mesecons_torch:redstoneblock` | Bloque de redstone |
| `mcl_core:wood_oak` | `mcl_core:wood` | Madera de roble |
| `mcl_core:wood_birch` | `mcl_core:birchwood` | Madera de abedul |
| `mcl_core:wood_spruce` | `mcl_core:sprucewood` | Madera de abeto |
| `mcl_core:wood_jungle` | `mcl_core:junglewood` | Madera de jungla |
| `mcl_core:wood_acacia` | `mcl_core:acaciawood` | Madera de acacia |
| `mcl_core:wood_dark_oak` | `mcl_core:darkwood` | Madera de roble oscuro |
| `mcl_core:sandstone_smooth` | `mcl_core:sandstonesmooth` | Arenisca lisa |
| `mcl_core:sandstone_carved` | `mcl_core:sandstonecarved` | Arenisca tallada |
| `mcl_core:glass_grey` | `mcl_core:glass_gray` | Vidrio gris (grey vs gray) |

## Workflow completo post-Arnis

```bash
# 1. Generar mundo con Arnis
./scripts/generate-valdivia.sh full

# 2. Remapear nodos incorrectos
python3 scripts/remap-mineclonia-to-voxelibre.py server/worlds/valdivia/map.sqlite

# 3. Subir al VPS
scp -i ~/.ssh/id_rsa server/worlds/valdivia/map.sqlite \
  gabriel@159.112.138.229:/tmp/valdivia_map.sqlite
ssh -i ~/.ssh/id_rsa gabriel@159.112.138.229 \
  "sudo cp /tmp/valdivia_map.sqlite /home/gabriel/luanti-voxelibre-server/server/worlds/valdivia/map.sqlite && \
   sudo chown 911:911 /home/gabriel/luanti-voxelibre-server/server/worlds/valdivia/map.sqlite"

# 4. Reiniciar servidor
ssh -i ~/.ssh/id_rsa gabriel@159.112.138.229 \
  "cd /home/gabriel/luanti-voxelibre-server && docker compose restart luanti-valdivia"

# 5. Conectarse y ejecutar /fixlight_world (idealmente sin otros jugadores)
```

---

*Ultima actualizacion: 22 marzo 2026*
