# 🏰 Schematics Asombrosos desde mg_villages — Intento de Remap a VoxeLibre

**Última Actualización**: 2026-07-24
**Estado**: ⏸️ Bloqueado — schematics en VPS, pero el comando WorldEdit correcto para pegarlos en Wetlands está sin probar in-game.
**Propósito**: Documentar el intento de importar 3 edificios medievales (chateau, biblioteca, torre) desde el repo de Sokomine/mg_villages a Wetlands, y dejar listo el script de remap para futuros schematics.

---

## 📋 TL;DR

- ✅ Se descargaron 3 schematics (`.mts`) desde `Sokomine/mg_villages` en GitHub.
- ✅ Se creó `scripts/remap_schematics.py` que reescribe los nombres de nodos de `minetest_game` a `VoxeLibre` directamente en el archivo binario (sin tocar el bloque zlib).
- ✅ Se desplegaron los 3 schematics remapeados a `<PROJECT_PATH>/server/worlds/original/schems/` en el VPS (chown 1000:1000, 644).
- ❌ **No se pegó ningún schematic in-game** — el nombre del comando WorldEdit no era obvio y se perdió tiempo debuggeando.

El comando que debería funcionar (no testeado): **`/mtschemplace <archivo>`** (con shortcommands) o **`//mtschemplace <archivo>`** (con doble barra). El detalle está en la sección "Cómo retomar".

---

## 🎯 Objetivo

Construir cosas majestuosas en Wetlands (puerto 30000) sin tener que modelar cada bloque a mano. El mod WorldEdit permite pegar archivos `.mts` (Minetest Schematic) en posiciones elegidas. La idea era:

1. Buscar 3 edificios "asombrosos y originales" de la comunidad Minetest
2. Adaptarlos de `minetest_game` (formato antiguo) a VoxeLibre (el juego que usa Wetlands)
3. Pegarlos en el spawn de Wetlands

## 📦 Lo que se descargó

Fuentes: [`Sokomine/mg_villages`](https://github.com/Sokomine/mg_villages) en GitHub, carpeta `schems/`.

| Archivo | Dimensiones | Nodos únicos | Qué es |
|---|---|---|---|
| `chateau_without_garden.mts` | 32×30×23 | 54 | **Chateau francés medieval** (el más impactante) |
| `library_1_0.mts` | 12×9×11 | 14 | Biblioteca medieval pequeña |
| `default_town_tower.mts` | 10×16×10 | 18 | Torre medieval clásica |

Los 3 archivos están en formato `.mts` (Minetest Schematic) versión 4. Verificados con descompresión zlib exitosa (88 KB / 4.7 KB / 6.4 KB descomprimidos respectivamente).

## 🔄 El problema: schematics incompatibles con VoxeLibre

Los schematics de `mg_villages` usan nodos de `minetest_game`:
- `default:wood`, `default:cobble`, `default:stone`...
- `stairs:slab_cobble`, `stairs:stair_wood`...
- `doors:door_wood_a`, `doors:hidden`...
- `beds:bed_top`, `beds:bed_bottom`...
- `cottages:shelf`, `cottages:bench`, `cottages:roof_straw`... (mod `cottages` NO existe en Wetlands)
- `vessels:glass_bottle`, `vessels:drinking_glass`... (mod `vessels` NO existe en Wetlands)
- `mg_villages:mob_workplace_marker` (mod `mg_villages` NO existe en Wetlands)

VoxeLibre usa prefijos `mcl_*`:
- `mcl_core:wood`, `mcl_core:cobble`, `mcl_core:stone`...
- `mcl_stairs:slab_cobble`, `mcl_stairs:stair_wood`...
- `mcl_doors:door_wood_a`, `mcl_doors:hidden`...
- `mcl_beds:bed_top`, `mcl_beds:bed_bottom`...
- (`cottages:`, `vessels:`, `mg_villages:` — **sin equivalente en VoxeLibre**)

Si se pegan tal cual, los nodos desconocidos se renderizan como bloque "unknown" o invisible. Eso rompería la geometría del chateau.

## 🛠️ El script: `scripts/remap_schematics.py`

Se creó un script Python que reescribe **solo la lookup table de nombres** del `.mts`, sin tocar el bloque zlib (los índices no cambian, así que el mapa 3D sigue válido).

### Tabla de remap (resumen)

| Original (minetest_game) | → | VoxeLibre | Notas |
|---|---|---|---|
| `default:*` | → | `mcl_core:*` | La mayoría directos |
| `stairs:*` | → | `mcl_stairs:*` | Todos |
| `doors:*` | → | `mcl_doors:*` | Todos |
| `beds:*` | → | `mcl_beds:*` | Todos |
| `cottages:shelf` | → | `mcl_core:bookshelf` | Mejor aproximación |
| `cottages:glass_pane` | → | `mcl_core:glass` | |
| `cottages:roof_*` | → | `mcl_stairs:slab_wood` | Pérdida: techo de paja |
| `cottages:bench/table` | → | `air` | Sin equivalente |
| `cottages:barrel*` | → | `air` | Sin equivalente |
| `cottages:hatch_wood` | → | `mcl_doors:trapdoor` | Aproximación |
| `cottages:fence_*` | → | `mcl_core:fence_wood` | |
| `cottages:bed_head/foot` | → | `mcl_beds:bed_top/bottom` | |
| `vessels:*` | → | `air` | Sin equivalente |
| `mg_villages:mob_workplace_marker` | → | `air` | Sin equivalente |
| `default:applex` (typo) | → | `mcl_core:dirt` | Typo del archivo fuente |

### Uso del script

```bash
# Ver cambios sin modificar
python scripts/remap_schematics.py --dry-run server/worlds/original/schems/foo.mts

# Aplicar remap (con backup .bak)
python scripts/remap_schematics.py --backup server/worlds/original/schems/foo.mts
```

### Resultado del remap (verificado)

| Archivo | Antes | Después | zlib válido |
|---|---|---|---|
| `chateau_without_garden.mts` | 5.875 B | 5.770 B | ✓ 88.320 B descomprimido |
| `library_1_0.mts` | 616 B | 612 B | ✓ 4.752 B descomprimido |
| `default_town_tower.mts` | 706 B | 709 B | ✓ 6.400 B descomprimido |

82 nodos remapeados en total.

**Pérdida en el chateau** (lossy): 16 nodos `cottages:*` + 3 nodos `vessels:*` + 1 nodo `mg_villages:*` se convierten en `air` (vacío). La estructura (muros, escaleras, puertas, camas, ventanas) sobrevive, pero los muebles internos (bancos, mesas, barricas) y el techo de paja se pierden.

## 📁 Despliegue en el VPS

Los 3 schematics están ahora en:
- **Host**: `<PROJECT_PATH>/server/worlds/original/schems/`
- **Container**: `/config/.minetest/worlds/original/schems/` (vía bind-mount desde `./server/worlds/...`)

Permisos: `opc:opc 644` (container user). El container los ve correctamente.

`server/worlds/` está en `.gitignore`, así que los schematics NO se commitean al repo. Solo se deployan al VPS manualmente (vía `scp` o similar).

## 🐛 El problema con los comandos de WorldEdit (no resuelto)

El chateau, biblioteca y torre están listos en el VPS, pero **nunca se llegó a pegar uno solo in-game** por una cadena de confusiones con los nombres de comandos de WorldEdit.

### Línea de tiempo del debug

1. **"Invalid command 'place'"** — el usuario probó `/place` (que no existe en WorldEdit base)
2. **"Invalid command 'load'"** — el usuario probó `/load` (con shortcommands). Pero la ayuda que salió en el chat era de un comando que ya existía...
3. Se descubrió que el comando correcto en WorldEdit para `.mts` es `//mtschemplace` (no `/load` ni `/mtsch`)
4. Se perdió tiempo debuggeando el contenedor (bind mounts rotos, logs en nivel WARNING, `ls` devolviendo resultados raros por CWD) cuando en realidad los mods SÍ estaban cargados — solo había que usar el comando correcto

### Mapa de comandos de WorldEdit (este server específico)

Inspeccionando `/config/.minetest/mods/worldedit_commands/schematics.lua` dentro del container:

| Shortcommands (`/`) | Doble barra (`//`) | Lee | Formato |
|---|---|---|---|
| `/load` | `//load` | `schems/<file>[.we\|.wem]` | WorldEdit |
| `/mtschemcreate` | `//mtschemcreate` | (guarda) | `.mts` |
| **`/mtschemplace`** | **`//mtschemplace`** | **`schems/<file>.mts`** | **Minetest** |
| `/mtschemprob` | `//mtschemprob` | — | (probabilities) |

**Clave:** para `.mts` (nuestro caso) el comando es `/mtschemplace`, NO `/load`.

### Diagnóstico extra: la ayuda que sí funcionó

El usuario reportó haber visto esta salida en el chat:
> "Load nodes from \"(world folder)/schems/<file>[.we[m]]\" with position 1 of the current WorldEdit region as the origin;"

Esa es la descripción de `//load` (formato WorldEdit). El usuario la interpretó como "ah, entonces el comando es load", pero eso es el comando equivocado para `.mts`.

## 🔄 Cómo retomar (cuando vuelvas al server)

### Paso 1: Verificar que los schematics están en `schems/`
```
/schems        (si existe, lista los .mts disponibles)
```
o desde SSH:
```bash
ls <PROJECT_PATH>/server/worlds/original/schems/
```

### Paso 2: Marcar pos1
Parado en el lugar donde querés la base:
```
/pos1
```

### Paso 3: Pegar el chateau
```
/mtschemplace chateau_without_garden
```

Repetir para los otros:
```
/mtschemplace library_1_0
/mtschemplace default_town_tower
```

### Si el comando no existe o falla

| Error | Causa probable | Fix |
|---|---|---|
| `Invalid command: mtschemplace` | WorldEdit no está cargado en este mundo | Verificar `world.mt` del mundo activo y `worldedit*` en mods cargados |
| `You are not allowed to use any WorldEdit commands.` | Falta privilegio `worldedit` | `/grant worldedit gabo` |
| `Could not open file "chateau_without_garden"` | El archivo no está donde se espera | Verificar que el `.mts` esté en `schems/` con permisos correctos |
| `Invalid file format!` | El `.mts` quedó corrupto tras el remap | Re-correr el remap con `--backup` y verificar con `zlib.decompress` |
| `Loading failed!` | El schematic tiene nodos desconocidos (más allá de los que ya remapeamos) | Editar el script `scripts/remap_schematics.py` para agregar más mappings |

## 📚 Archivos en el repo (commiteados)

- `scripts/remap_schematics.py` — herramienta reutilizable, funciona con cualquier `.mts` que se le pase

## 📚 Archivos NO en el repo (en VPS solamente)

- `server/worlds/original/schems/chateau_without_garden.mts` (5.770 B)
- `server/worlds/original/schems/library_1_0.mts` (612 B)
- `server/worlds/original/schems/default_town_tower.mts` (709 B)
- Los `.bak` originales (por si hay que revertir)

Si se quieren bajar otros schematics de la comunidad, el flujo es:
```bash
# Local
curl -L -o server/worlds/original/schems/nuevo.mts https://raw.githubusercontent.com/.../nuevo.mts
python scripts/remap_schematics.py server/worlds/original/schems/nuevo.mts
scp server/worlds/original/schems/nuevo.mts <VPS_USER>@<VPS_IP>:<PROJECT_PATH>/server/worlds/original/schems/
```

## 🔗 Referencias

- [Sokomine/mg_villages en GitHub](https://github.com/Sokomine/mg_villages) — fuente de los schematics
- [Sokomine/cottages](https://github.com/Sokomine/cottages) — los nodos `cottages:*` que se pierden en el remap
- [`docs/00-SHARED/mods/WORLDEDIT_GUIDE.md`](../../00-SHARED/mods/WORLDEDIT_GUIDE.md) — guía general de WorldEdit en Wetlands
- `scripts/remap_schematics.py` (en este repo) — script de remap con tabla completa

## 📝 Lección aprendida

1. **No asumir que `/load` es el comando universal** — WorldEdit tiene comandos separados para `.we`/`.wem` (`/load`) y `.mts` (`/mtschemplace`).
2. **Antes de debuggear el container, leer la fuente del mod** — el nombre del comando está literalmente en el `init.lua` de worldedit_commands.
3. **Los schematics Sokomine NO son 100% compatibles con VoxeLibre** — muchos `cottages:*` y `vessels:*` no tienen equivalente. El remap ayuda pero es losssy.
