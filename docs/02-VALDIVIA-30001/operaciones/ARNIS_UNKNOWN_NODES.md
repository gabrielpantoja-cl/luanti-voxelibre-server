# Arnis + VoxeLibre: corrección de nodos desconocidos y sin textura

**Última actualización**: 2026-06-30
**Aplica a**: Mundo Valdivia (puerto 30001), generado con Arnis v2.9.0

---

## El problema

Cuando Arnis genera un mundo desde OpenStreetMap usando una versión de VoxeLibre
distinta a la que corre el servidor, algunos nodos quedan almacenados en el
`map.sqlite` con nombres de una versión anterior. El servidor no los reconoce y
los jugadores ven:

- **`<unknown node>`** — cubo rosa con texto "unkn own node"
- **No texture** — cubo rojo con letras blancas (variante del mismo problema)

---

## Diagnóstico: identificar qué nodos están mal

### Paso 1 — Escanear el mapa con Python

El script lee directamente el `map.sqlite` y reporta todos los nombres de nodo
cuyo mod **no existe** como directorio en el servidor:

```bash
# En el VPS
python3 << 'PYEOF'
import sqlite3, struct, zstandard, os

DB = '/home/gabriel/luanti-voxelibre-server/server/worlds/valdivia/map.sqlite'
MODS_DIR = '/home/gabriel/luanti-voxelibre-server/server/games/mineclone2/mods'
EXTERNAL_MODS = '/home/gabriel/luanti-voxelibre-server/server/mods'

available_mods = set()
for root, dirs, files in os.walk(MODS_DIR):
    for d in dirs:
        available_mods.add(d)
for d in os.listdir(EXTERNAL_MODS):
    available_mods.add(d)

dctx = zstandard.ZstdDecompressor()

def get_names(raw):
    try:
        data = dctx.decompress(raw[1:], max_output_size=500_000)
    except: return set()
    p = 8  # flags(1)+lighting(2)+ts(4)+nimver(1)
    nim_count = struct.unpack_from('>H', data, p)[0]; p += 2
    names = set()
    for _ in range(nim_count):
        p += 2
        nlen = struct.unpack_from('>H', data, p)[0]; p += 2
        name = data[p:p+nlen].decode('utf-8', errors='replace'); p += nlen
        names.add(name)
    return names

conn = sqlite3.connect(DB)
missing = {}
for row in conn.execute('SELECT data FROM blocks'):
    for name in get_names(bytes(row[0])):
        if ':' not in name: continue
        mod = name.split(':')[0]
        if mod not in available_mods:
            missing[name] = missing.get(name, 0) + 1
conn.close()

for name, count in sorted(missing.items(), key=lambda x: -x[1]):
    print(f'{name}: en {count} bloques')
PYEOF
```

> **Nota técnica**: los bloques de Luanti 5.5+ están comprimidos con **Zstandard**
> (magic `28 b5 2f fd`), no con zlib. El script usa la librería `zstandard`
> (`pip install zstandard`), que ya estaba instalada en el VPS Oracle.
> El byte 0 es la versión del bloque (= 29); el resto es el stream zstd.
> Dentro del bloque descomprimido los node IDs van sin compresión adicional
> (4096 × u16 big-endian tras el name-id mapping).

### Paso 2 — Identificar el nombre actual en VoxeLibre

Para cada nombre viejo encontrado, buscar cómo se llama ahora:

```bash
# Buscar en los mods del juego
grep -r "register_node\|register_alias" \
  /home/gabriel/luanti-voxelibre-server/server/games/mineclone2/mods \
  --include="*.lua" | grep "<nombre_del_nodo>"
```

---

## Solución: mod `valdivia_aliases`

En lugar de modificar VoxeLibre o el mapa, se registran aliases en un mod
propio: `server/mods/valdivia_aliases/`.

```lua
-- server/mods/valdivia_aliases/init.lua
minetest.register_alias("nombre_viejo:nodo", "nombre_nuevo:nodo")
```

El mod se carga solo en Valdivia (`luanti-valdivia.conf` + `world.mt`).

---

## Aliases conocidos (VoxeLibre 0.90.1 → versión actual)

| Nombre en el mapa (viejo) | Nombre actual en VoxeLibre | Causa |
|---|---|---|
| `mcl_daylight_detector:daylight_detector` | `mesecons_solarpanel:solar_panel_off` | Redstone renombrado de `mcl_*` a `mesecons_*` |
| `mcl_noteblock:noteblock` | `mesecons_noteblock:noteblock` | Ídem |
| `mcl_redstone_torch:redstoneblock` | `mesecons_torch:redstoneblock` | Ídem |
| `mcl_banners:hanging_banner_white` | `mcl_banners:hanging_banner` | Colores eliminados del nombre; el color pasa a metadata |
| `mcl_banners:hanging_banner_red` | `mcl_banners:hanging_banner` | Ídem |
| `mcl_banners:hanging_banner_silver` | `mcl_banners:hanging_banner` | Ídem |

> **Patrón general**: los mods de redstone pasaron de `mcl_*` a `mesecons_*`.
> Los banners dejaron de llevar el color en el nombre del nodo.

---

## Flujo completo para una nueva generación con Arnis

1. Generar el mundo con Arnis y desplegarlo en el VPS.
2. Conectarse y explorar para detectar nodos visualmente incorrectos.
3. Correr el script de diagnóstico (Paso 1) para obtener la lista completa.
4. Buscar los nombres actuales (Paso 2) y agregar aliases a `valdivia_aliases/init.lua`.
5. Commit + push + `git pull` en el VPS + `docker compose restart luanti-valdivia`.
6. Reconectarse y verificar.

---

## Archivos relacionados

- `server/mods/valdivia_aliases/init.lua` — aliases activos
- `server/mods/valdivia_aliases/mod.conf` — dependencias opcionales
- `server/config/luanti-valdivia.conf` — `load_mod_valdivia_aliases = true`
- `server/worlds/valdivia/world.mt` (VPS) — ídem
