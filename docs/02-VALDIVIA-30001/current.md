# Proyecto Valdivia [Chile] — Recreación completa en Luanti (puerto 30001)

**Estado:** Mundo generado con Arnis v2.9.0 y **desplegado en VPS** (29 junio 2026)
**Objetivo:** Recrear la ciudad completa de Valdivia, Chile desde OpenStreetMap en Luanti,
incluyendo toda el área urbana: Isla Teja, Las Ánimas, Santa Elena, Centro, Miraflores, Torobayo.
**Spawn:** Plaza de la República.
**Servidor:** Público en la lista de Luanti con el nombre `Valdivia [Chile]`.

## Estado actual — 30 junio 2026

### Configuración del servidor

| Parámetro | Valor |
|-----------|-------|
| Nombre público | `Valdivia [Chile]` |
| Puerto | 30001/UDP |
| Container | `luanti-valdivia-server` |
| `creative_mode` | `false` (sin vuelo global — ver pitfall abajo) |
| `enable_damage` | `true` (los jugadores reciben daño) |
| `enable_pvp` | `true` |
| Spawn | `2389, -55, -2887` (Colegio Planeta Azul — spawn estático en `world.mt`) |
| Anunciado en servidores.luanti.org | Sí |

### Mods activos en Valdivia (además de VoxeLibre base)

| Mod | Propósito |
|-----|-----------|
| `valdivia_newplayer` | Privilegios de nuevos jugadores: interact, shout, creative, fast, spawn, teleport (sin fly). También setea `gamemode=creative` en metadata por jugador para que VoxeLibre dé inventario creativo. |
| `valdivia_aliases` | Aliases de nodos viejos generados por Arnis → nombres actuales VoxeLibre |
| `wetlands_lastpos` | Jugadores vuelven a su última posición al reconectarse |
| `server_rules` | Comando `/reglas` |
| `valdivia_teleporter` | Teletransportador `/ir` — **deshabilitado** (coordenadas desactualizadas post-Arnis v2.9.0) |

### Aliases activos (`valdivia_aliases`)

| Nombre en el mapa (Arnis) | Nombre actual VoxeLibre |
|---|---|
| `mcl_daylight_detector:daylight_detector` | `mesecons_solarpanel:solar_panel_off` |
| `mcl_noteblock:noteblock` | `mesecons_noteblock:noteblock` |
| `mcl_redstone_torch:redstoneblock` | `mesecons_torch:redstoneblock` |
| `mcl_banners:hanging_banner_white/red/silver` | `mcl_banners:hanging_banner` |
| `mcl_ocean:seagrass` | `mcl_ocean:seagrass_dirt` |
| `mcl_ocean:tall_seagrass` | `mcl_ocean:seagrass_dirt` |
| `mcl_ocean:kelp` | `mcl_ocean:kelp_dirt` |
| `mcl_ocean:sea_pickle` | `mcl_ocean:seagrass_dirt` |

### Privilegios e inventario creativo

- **Jugadores nuevos**: `interact, shout, creative, fast, spawn, teleport` — sin `fly` ni `noclip`
- **gabo** (admin): todos los privilegios incluido `fly`
- **Inventario creativo**: todos los jugadores tienen acceso al inventario creativo completo de VoxeLibre

> ⚠️ **Pitfall VoxeLibre (documentado 30-jun-2026):** con `creative_mode = false`, el privilegio `creative` de Luanti no activa el inventario creativo de VoxeLibre. VoxeLibre sobreescribe `minetest.is_creative_enabled()` en `mcl_inventory/init.lua` y con el modo global apagado solo devuelve `true` si el jugador tiene la metadata `gamemode = "creative"`. El mod `valdivia_newplayer` setea esta metadata en `register_on_joinplayer` para todos los jugadores al conectarse.
>
> **Resumen**: `creative_mode = false` → sin vuelo global. Metadata `gamemode = "creative"` por jugador → inventario creativo por jugador. Los dos se combinan para dar el comportamiento deseado. Ver detalles en `operaciones/PRIVILEGIOS.md`.

### Pendiente

- [ ] Verificar y actualizar coordenadas del teletransportador `/ir` para el mundo Arnis v2.9.0 y re-habilitar `valdivia_teleporter`
- [ ] Investigar más nodos desconocidos que aún puedan existir (el scanner cubre mods faltantes; renombres dentro de mods existentes son más difíciles de detectar)

---

## Diagnóstico del nuevo mundo (VPS, 29 junio 2026)

### Métricas del mundo desplegado

| Métrica | Valor |
|---------|-------|
| `map.sqlite` | **460 MB** (481 MB en disco) |
| Mapblocks totales | **1.466.103** |
| X span | 401 bloques = **~6.4 km** |
| Y span | 24 bloques = **384 m** de altura |
| Z span | 592 bloques = **~9.5 km** |
| Área estimada | **~61 km²** |
| Edificios Overture Maps | **34.653** |
| Modelos 3D | 1 estadio (123.398 bloques), 1 avión |
| Rango de elevación | **316.3 m** (vs 83 m del mundo anterior) |
| Spawn generado | `3766, -4, -3249` (Plaza de la República — verificar) |
| Seed | `18241358796836382025` |
| Remapeo v1 aplicado | 222.521 mapblocks (árboles, madera, bambú, steps) |
| Remapeo v2 aplicado | 18.005 mapblocks (55 patrones stairs/slabs/planchas para 6 maderas + piedra) |
| Baked lighting | Sí (`--bake-lighting` en Arnis) |
| Arnis | v2.9.0 (release, CLI) |
| Gameid | `mineclone2` (corregido post-generación) |
| Servidor | Anunciado a `servers.luanti.org` |
| Website URL | `https://luanti.gabrielpantoja.cl` (botón "Abrir sitio web" del cliente Luanti) |

### Archivos en el VPS

| Archivo | Propósito |
|---------|-----------|
| `map.sqlite` | Datos del mundo (460 MB) |
| `world.mt` | `gameid = mineclone2` |
| `worldmods/arnis_mapgen/` | Worldmod: spawn, emerge parcial |
| `auth.sqlite` | Autenticación de jugadores |
| `players.sqlite` | Datos de jugadores |
| `mod_storage.sqlite` | Almacenamiento de mods |

### Cobertura del nuevo mundo

| Zona | Incluida |
|------|----------|
| Plaza de la República (spawn) | Sí |
| Centro histórico | Sí |
| Isla Teja | Sí |
| Las Ánimas | Sí |
| Santa Elena | Sí |
| Huachocopihue | Sí |
| Miraflores | Sí |
| Torobayo | Sí |
| Río Valdivia | Sí |
| Puente Pedro de Valdivia | Sí |
| Estadio | Sí (modelo 3D) |
| Humedal Río Cruces | Parcial |

### Errores conocidos

- `mcl_stairs:stair_oak` y otros stairs/slabs de madera aparecen como "no texture" — **pendiente remapeo v2** (script `remap-incremental-valdivia.py` listo)
- `mcl_noteblock:noteblock` no definido (nodo Mineclonia, mismo error que el mundo anterior) — bajo impacto
- Advertencias de biomas (`get_biome_list: failed to get biome`) — normales en VoxeLibre con singlenode

> ### Comparación: mundo anterior (v1.0) vs nuevo mundo (v2.9.0)
>
> | Aspecto | Anterior (PR #808) | Nuevo (v2.9.0) |
> |---------|-------------------|----------------|
> | Área | ~47 km² | **~61 km²** (+30%) |
> | Edificios | OSM simple | **Overture Maps** (34K edificios 3D) |
> | Elevación | 83 m | **316 m** (realista, con cerros) |
> | Cobertura N-S | ~6.0 km | **~9.5 km** (+58%) |
> | Modelos 3D | No | Sí (estadio, avión) |
> | Terreno | Plano | Realista con elevaciones |
> | Spawn anterior | Colegio Planeta Azul (2389, -55, -2887) | Plaza de la República (3766, -4, -3249) |
> | Arnis | PR #808 (compilación manual) | **v2.9.0** (release oficial) |
> | Lighting | Fixlight manual (~12h) | **Baked lighting** (instantáneo) |

## Nueva generación — Arnis v2.9.0 (Mosaic Update, 16 junio 2026)

Arnis v2.9.0 trae cambios clave que hacen viable un mundo mucho más grande:

| Mejora | Impacto |
|--------|---------|
| **Streaming a disco** | Ya no almacena todo en RAM — escribe directo a disco |
| **Multi-core** | Distribuye la generación entre todos los núcleos de CPU |
| **Export Luanti nativo** | El PR #808 está fusionado en `main`. Seleccionas "Luanti (Mineclonia)" en la GUI |
| **GUI con mapa interactivo** | Dibujas el rectángulo visualmente en el mapa |
| **Edificios 3D reales** | Landmarks, estadios, puentes como estructuras reales |
| **Terreno multi-fuente** | Elevaciones más precisas con datos regionales |

Descarga: https://github.com/louis-e/arnis/releases/tag/v2.9.0

## Resultado de la generación (29 junio 2026, 00:06)

Mundo generado exitosamente en la Legion 5 con Arnis v2.9.0 CLI.

### Comando ejecutado

```bash
/home/gabriel/arnis/arnis-linux --luanti --terrain \
  --output-dir=/tmp/valdivia \
  --bbox="-39.870,-73.290,-39.785,-73.215" \
  --spawn-lat=-39.81422 --spawn-lng=-73.24589
```

### Métricas del mundo generado

| Métrica | Valor |
|---------|-------|
| `map.sqlite` | **420 MB** |
| Mapblocks totales | **1.153.548** (679.566 contenido + 473.982 aire) |
| Bloques con contenido | 672.975 |
| Bloques de aire | 480.573 |
| Edificios Overture Maps | **34.653** |
| Modelos 3D | 1 estadio (123.398 bloques), 1 avión (4.780 bloques) |
| Tiles de elevación AWS | 88 (resolución ~30m) |
| Rango de elevación | **316.3 m** (vs 83 m del mundo actual) |
| X span | 401 bloques = **~6.4 km** |
| Y span | 24 bloques = **384 m** de altura |
| Z span | 592 bloques = **~9.5 km** |
| Área estimada | **~61 km²** |
| Spawn generado | `3766, -4, -3249` |
| Worldmod | `arnis_mapgen` incluido (lazy fix-lighting) |

### Archivos generados

```
/tmp/valdivia/Arnis Luanti World 1/
├── map.sqlite          (420 MB)
├── world.mt            (gameid = mineclonia — cambiar a mineclone2)
├── map_meta.txt        (singlenode mapgen)
├── env_meta.txt
└── worldmods/
    └── arnis_mapgen/
        ├── init.lua    (spawn, emerge parcial, fix-lighting)
        ├── mod.conf
        └── mcl_levelgen.conf
```

### Diferencias clave con el mundo actual

| Aspecto | Actual (v1.0) | Nuevo (v2.9.0) |
|---------|---------------|----------------|
| `map.sqlite` | 524 MB | 420 MB (-20%) |
| Mapblocks | 3.497.213 | 1.153.548 (-67%) |
| Edificios 3D | No (OSM simple) | Sí (Overture Maps, 34K edificios) |
| Elevación | 83 m | 316 m (realista) |
| Cobertura N-S | ~6.0 km | **~9.5 km** (+58%) |
| Cobertura E-O | ~7.8 km | ~6.4 km (-18%) |
| Área total | ~47 km² | **~61 km²** (+30%) |
| Modelos 3D | No | Estadio + avión |
| Terreno | Plano | Realista con cerros |
| Spawn | Colegio Planeta Azul | Plaza de la República (3766, -4, -3249) |

**Nota:** El mundo nuevo tiene menos mapblocks pero más calidad: edificios 3D reales,
elevación realista (316 m vs 83 m), y mayor cobertura N-S (9.5 km vs 6.0 km).
La reducción en mapblocks se debe a que Arnis v2.9.0 solo genera bloques con contenido
real (no bloques vacíos), resultando en un archivo más eficiente.

### Pasos realizados para el despliegue

- [x] **Corregir gameid:** `mineclonia` → `mineclone2` en `world.mt`
- [x] **Spawn:** Configurado como `3766, -4, -3249` (Plaza de la República — verificado y corregido)
- [x] **Remapeo v1:** Ejecutado `scripts/remap-mineclonia-to-voxelibre.py` (222.521 mapblocks)
- [x] **Remapeo v2:** Ejecutado en VPS — 18.005 mapblocks de stairs/slabs/planchas
- [x] **Baked lighting:** Generado con `--bake-lighting` — no necesita fixlight manual
- [x] **Upload a VPS:** `rsync` a `gabriel@159.112.138.229` (~5 segundos)
- [x] **Permisos:** `sudo chown 1000:1000` (usuario container = opc)
- [x] **Servidor iniciado:** Docker container `luanti-valdivia-server` anunciado a servidores públicos
- [x] **Website URL:** `server_url = https://luanti.gabrielpantoja.cl` para botón "Abrir sitio web" en cliente Luanti
- [x] **Wetlands deslistado:** `server_announce = false` en `luanti-original.conf` (ya no aparece en lista pública)

### Pendiente

- [x] **Remapeo v2 completado:** 18.005 mapblocks remapeados ✅
- [ ] **Verificar texturas de stairs/slabs:** Tras remapeo v2, confirmar que `mcl_stairs:stair_oak` etc. se ven correctamente
- [ ] **Actualizar destinos** del teletransportador `/ir` con nuevas coordenadas del mundo v2

## Bbox (área a generar)

Para cubrir toda la ciudad incluyendo Isla Teja, Las Ánimas, Santa Elena y Torobayo:

| Parámetro | Valor |
|-----------|-------|
| **Bbox** | `-39.870, -73.290, -39.785, -73.215` |
| **Dimensiones** | ~9.5 km N-S × ~6.5 km E-O |
| **Spawn** | Plaza de la República (`--spawn-lat=-39.81422`, `--spawn-lng=-73.24589`) |
| **Área total** | ~62 km² (~5× más que el mundo actual) |
| **Tamaño estimado** | ~2-3 GB |
| **Tiempo estimado** | ~15-30 minutos (en PC local con buen hardware) |

## Proceso de generación

### Paso 1: Descargar / compilar Arnis en PC local

```bash
# Opción A: Descargar binario precompilado
# Ve a https://github.com/louis-e/arnis/releases/tag/v2.9.0
# Descarga arnis-linux (Linux) o arnis-windows.exe (Windows)

# Opción B: Compilar desde fuente
git clone https://github.com/louis-e/arnis.git
cd arnis
cargo build --release
```

### Paso 2: Generar con GUI (recomendado)

```bash
./arnis
# o: ./target/release/arnis
```

1. Se abre una ventana con un mapa interactivo
2. Navega a Valdivia, Chile
3. Dibuja el rectángulo desde aprox Isla Teja hasta Las Ánimas
4. En Settings → Output Format → selecciona **"Luanti (Mineclonia)"**
5. Marca **"Terrain"**
6. Opcional: ajusta spawn point a `-39.81422, -73.24589`
7. Haz clic en **"Start Generation"**

### Paso 2b: CLI (alternativa sin GUI)

```bash
./arnis \
  --luanti \
  --luanti-game mineclonia \
  --terrain \
  --output-dir=/tmp/valdivia \
  --bbox="-39.870,-73.290,-39.785,-73.215" \
  --spawn-lat=-39.81422 \
  --spawn-lng=-73.24589
```

El mundo se genera en `/tmp/valdivia/Arnis Luanti World 1/`.

### Paso 3: Subir al VPS

```bash
rsync -avz --progress \
  "/tmp/valdivia/Arnis Luanti World 1/" \
  gabriel@159.112.138.229:/home/gabriel/luanti-voxelibre-server/server/worlds/valdivia/
```

### Paso 4: Reemplazar el mundo actual (en VPS)

Detener container, reemplazar, chown, reiniciar:

```bash
# Backup del mundo actual
ssh gabriel@159.112.138.229 \
  "cd /home/gabriel/luanti-voxelibre-server && \
   docker compose stop luanti-valdivia && \
   mv server/worlds/valdivia server/worlds/valdivia_OLD_$(date +%Y%m%d)"

# Copiar el nuevo mundo (desde PC local)
rsync -avz --progress \
  "/tmp/valdivia/Arnis Luanti World 1/" \
  gabriel@159.112.138.229:/home/gabriel/luanti-voxelibre-server/server/worlds/valdivia/

# Chown al usuario del container
ssh gabriel@159.112.138.229 \
  "sudo chown -R 1000:1000 /home/gabriel/luanti-voxelibre-server/server/worlds/valdivia"

# Reiniciar
ssh gabriel@159.112.138.229 \
  "cd /home/gabriel/luanti-voxelibre-server && docker compose start luanti-valdivia"
```

## Config para hacerlo público

En `server/config/luanti-valdivia.conf`, agregar o modificar:

```conf
server_announce = true
server_name = Valdivia [Chile]
server_description = Recreación de Valdivia, Chile desde OpenStreetMap en Luanti. Explora la ciudad real, sus calles, ríos y edificios. Modo creativo.
server_url = https://luanti.gabrielpantoja.cl
server_keywords = valdivia,chile,ciudad,creativo,español
```

Esto hará que el mundo aparezca en la lista pública del cliente Luanti (pestaña "Unirse al juego" → Servidores). Cualquier persona buscando un servidor chileno o latinoamericano lo encontrará.

## Coordenadas de remapeo (Mineclonia → VoxeLibre)

Arnis genera nodos con nombres de **Mineclonia**. Nuestro servidor usa **VoxeLibre**.
Es necesario remapear los nombres de nodos con un script ABM en `world.mt` o vía
el mod `arnis_mapgen` que Arnis incluye.

**Nota:** Con `--luanti-game mineclonia` en Arnis v2.9.0, el export ya debería
generar nodos compatibles con Mineclonia/VoxeLibre (son forks del mismo código).
Verificar tras la generación y aplicar remapeo si es necesario (ver tabla completa
en sección "Incompatibilidad de Nodos" más abajo).

---

## Resumen Ejecutivo

Recreacion fiel de Valdivia usando datos geoespaciales reales de OpenStreetMap y modelos de elevacion SRTM. **La via principal es Arnis con soporte nativo Luanti** (PR #808, branch `luanti-support`), que genera directamente mundos Luanti desde OSM sin necesidad de conversion intermedia. El PR fue compilado y testeado exitosamente el 21 de marzo de 2026. Se realizaron tres generaciones progresivas hasta alcanzar la cobertura final (v3) con Rio Valdivia, Colegio Planeta Azul, industrias, Miraflores y Torobayo. El servidor esta en produccion publica en `luanti.gabrielpantoja.cl:30001`.

---

## Arnis PR #808 -- TESTEADO Y FUNCIONAL

**PR:** https://github.com/louis-e/arnis/pull/808
**Autor:** 3rd3 | **Fecha:** 21 marzo 2026 | **Estado:** Open (en review)

### Compilacion exitosa

- **Plataforma:** x86_64 Linux Mint
- **Rust:** 1.94.0
- **Tiempo de compilacion:** ~6 minutos (`cargo build --release`)
- **Binario:** `$HOME/arnis/target/release/arnis`
- **Dependencias del sistema requeridas:**
  ```
  libglib2.0-dev libgtk-3-dev libwebkit2gtk-4.1-dev
  libjavascriptcoregtk-4.1-dev libsoup-3.0-dev libssl-dev
  ```

### Uso CLI confirmado

```bash
./target/release/arnis \
  --luanti \
  --luanti-game mineclonia \
  --terrain \
  --output-dir=/ruta/existente \
  --bbox="-39.860,-73.285,-39.812,-73.225" \
  --spawn-lat=-39.835957 \
  --spawn-lng=-73.257018
```

**Notas importantes:**
- Requiere flag `--output-dir` (el directorio debe existir previamente)
- Output va a `<output-dir>/Arnis Luanti World 1/` (nota: espacio en el nombre de carpeta)
- Genera automaticamente: `map.sqlite`, `world.mt`, `map_meta.txt`, `env_meta.txt`
- Incluye un worldmod `arnis_mapgen` que maneja spawn, respawn, y fix de iluminacion en primer load
- Usa `singlenode` mapgen + compresion zstd
- La GUI NO tiene opcion Luanti todavia (solo Java/Bedrock), se debe usar CLI
- Flags opcionales: `--spawn-lat` y `--spawn-lng` para definir coordenadas de spawn

---

## Tres Generaciones Realizadas

### v1: Colegio solamente (~600x500m) -- DESCARTADA

| Aspecto | Valor |
|---------|-------|
| **Bbox** | `-39.8387,-73.2600,-39.8332,-73.2540` |
| **Area** | ~600 x 500 metros |
| **Mapblocks** | 1,549 |
| **Tamano archivo** | 716 KB |
| **Resultado** | Demasiado pequena, solo el colegio y alrededores inmediatos |

### v2: Colegio + alrededores (~3.6x2.9km) -- DESCARTADA

| Aspecto | Valor |
|---------|-------|
| **Bbox** | `-39.852,-73.272,-39.820,-73.238` |
| **Area** | ~3.6 x 2.9 km |
| **Mapblocks** | 61,324 |
| **Tamano archivo** | 26 MB |
| **Resultado** | Todavia pequena, no incluye el Rio Valdivia |

### v3: Area completa (~5.3x5.1km) -- FINAL (EN PRODUCCION)

| Aspecto | Valor |
|---------|-------|
| **Bbox** | `-39.860,-73.285,-39.812,-73.225` |
| **Area** | ~5.3 x 5.1 km |
| **Mapblocks totales** | 172,796 |
| **Mapblocks remapeados** | 45,128 |
| **Tamano archivo** | 70 MB |
| **Rango de elevacion** | 83.0 metros (cerros realistas) |
| **Spawn** | 2389, -55, -2664 (coordenadas del Colegio Planeta Azul) |
| **Tiempo de generacion** | ~2 minutos |
| **Cobertura** | Rio Valdivia, Colegio Planeta Azul, industrias, Miraflores, Torobayo |

### Cobertura OSM del area

- Colegio Planeta Azul **NO** esta mapeado por nombre en OSM (solo Colegio San Lucas cercano)
- Buena cobertura general: calles (Arica, Pedro Ruiz Manriquez), arboles con datos de especie, parques, cancha deportiva, piscina, grifos, ciclovias
- Edificios aparecen como estructuras pero sin nombres especificos

---

## Incompatibilidad de Nodos: Mineclonia vs VoxeLibre (LECCION CRITICA)

### El problema

Arnis PR #808 genera nodos con nombres de **Mineclonia**, NO de VoxeLibre. Son forks del mismo codebase (MineClone2) pero han divergido en nombres de nodos.

### Tabla completa de remapeo (19 nodos)

| Mineclonia (generado por Arnis) | VoxeLibre (nuestro servidor) |
|--------------------------------|------------------------------|
| `mcl_trees:tree_oak` | `mcl_core:tree` |
| `mcl_trees:tree_birch` | `mcl_core:birchtree` |
| `mcl_trees:tree_spruce` | `mcl_core:sprucetree` |
| `mcl_trees:tree_jungle` | `mcl_core:jungletree` |
| `mcl_trees:tree_acacia` | `mcl_core:acaciatree` |
| `mcl_trees:tree_dark_oak` | `mcl_core:darktree` |
| `mcl_trees:leaves_oak` | `mcl_core:leaves` |
| `mcl_trees:leaves_birch` | `mcl_core:birchleaves` |
| `mcl_trees:leaves_spruce` | `mcl_core:spruceleaves` |
| `mcl_trees:leaves_jungle` | `mcl_core:jungleleaves` |
| `mcl_trees:leaves_acacia` | `mcl_core:acacialeaves` |
| `mcl_trees:leaves_dark_oak` | `mcl_core:darkleaves` |
| `mcl_trees:wood_oak` | `mcl_core:wood` |
| `mcl_trees:wood_birch` | `mcl_core:birchwood` |
| `mcl_trees:wood_spruce` | `mcl_core:sprucewood` |
| `mcl_trees:wood_jungle` | `mcl_core:junglewood` |
| `mcl_trees:wood_acacia` | `mcl_core:acaciawood` |
| `mcl_trees:wood_dark_oak` | `mcl_core:darkwood` |
| `mcl_bamboo:scaffolding` | `mcl_core:wood` |

**Nota:** Originalmente se pensó que los demás nodos (`mcl_stairs`, `mcl_flowers`, etc.) eran compatibles,
pero en la práctica Arnis v2.9.0 genera stairs con nomenclatura Mineclonia (`mcl_stairs:stair_oak`)
que no existe en VoxeLibre (`mcl_stairs:stair_wood`). El **remapeo v2** (script `remap-incremental-valdivia.py`)
agrega estas conversiones (stairs, slabs, planks) para todos los tipos de madera, más cobblestone y stone_brick.

### Solucion implementada: Script de remapeo (v1 + v2)

Dos scripts Python:

**v1 — `scripts/remap-mineclonia-to-voxelibre.py`** (ejecutado en el nuevo mundo):
- Remapea árboles, hojas, maderas, bambú, areniscas, cristal gris, cadenas, bloques de redstone
- Stairs legacy (`mcl_stairs:stair_wood_oak` → `mcl_stairs:stair_wood`)
- **Resultado:** 222.521 de 1.153.548 mapblocks remapeados

**v2 — `scripts/remap-incremental-valdivia.py`** (pendiente de ejecutar en VPS):
- Remapea planks (`mcl_core:planks_oak` → `mcl_core:wood`)
- Remapea stairs Mineclonia (`mcl_stairs:stair_oak` → `mcl_stairs:stair_wood`)
- Cubre los 6 tipos de madera (oak, birch, spruce, jungle, acacia, dark_oak)
- Incluye slabs e inner/outer para todos
- Incluye cobblestone (`stair_cobblestone` → `stair_cobble`)
- Incluye stone_brick (`stair_stone_brick` → `stair_stonebrick`)

Ambos scripts usan el mismo mecanismo:
1. Leer mapblocks de map.sqlite
2. Saltar byte de versión (0x1d = 29), descomprimir zstd
3. Buscar strings de nombres de nodos con prefijo de longitud
4. Reemplazar y recomprimir

### Correccion de gameid en world.mt

Arnis genera `gameid = mineclonia` pero VoxeLibre requiere `gameid = mineclone2`. Se debe cambiar manualmente despues de cada generacion.

---

## Worldmod arnis_mapgen -- Fix critico

### Problema original

El worldmod `arnis_mapgen` generado por Arnis intenta hacer `emerge_area` del MAPA COMPLETO en el primer join del jugador (potencialmente billones de nodos). Esto causa un bucle infinito de "Loading map" que congela el servidor.

### Solucion aplicada

Se modifico el worldmod para que solo haga emerge de un area de **160x64x160 bloques** alrededor de la posicion del jugador. El resto del mapa se carga on-demand conforme el jugador se desplaza volando. Tambien maneja el teletransporte al spawn y el respawn.

Archivo: `server/worlds/valdivia/worldmods/arnis_mapgen/init.lua`

---

## Infraestructura Desplegada

### Archivos en el repositorio

| Archivo | Proposito |
|---------|-----------|
| `docker-compose.yml` | Arquitectura dual: puerto 30000 (Wetlands) + puerto 30001 (Valdivia) |
| `server/config/luanti-valdivia.conf` | Config dedicada (creative, no mobs, singlenode mapgen, todos los privilegios) |
| `server/worlds/valdivia/world.mt` | Metadata del mundo Valdivia (gameid = mineclone2) |
| `server/worlds/valdivia/worldmods/arnis_mapgen/` | Worldmod que maneja spawn, respawn y emerge parcial |
| `scripts/setup-arnis.sh` | Instala Rust, clona Arnis, compila desde PR #808 |
| `scripts/generate-valdivia.sh` | Genera mundo con presets de bbox (colegio, mvp, exp1, exp2, full) |
| `scripts/remap-mineclonia-to-voxelibre.py` | Corrige incompatibilidad de nombres de nodos (19 nodos) |

### Arquitectura del servidor dual

```yaml
# docker-compose.yml (simplificado)
luanti-server:        # Wetlands - puerto 30000
luanti-valdivia:      # Valdivia - puerto 30001
  image: linuxserver/luanti:latest
  ports: ["30001:30000/udp"]
  volumes:
    - ./server/config/luanti-valdivia.conf:/config/.minetest/minetest.conf
    - ./server/worlds/valdivia:/config/.minetest/worlds/valdivia
    - ./server/games:/config/.minetest/games
    - ./server/mods:/config/.minetest/mods
  environment:
    - CLI_ARGS=--worldname valdivia
```

**Ventajas de mundo separado:**
- Cero riesgo para el servidor Wetlands principal
- Configuracion independiente
- Se puede apagar/encender sin afectar Wetlands

---

## Despliegue en VPS (Oracle Cloud)

### Datos del VPS

| Aspecto | Valor |
|---------|-------|
| **IP** | <VPS_IP> |
| **Proveedor** | Oracle Cloud Free Tier |
| **Arquitectura** | ARM aarch64 |
| **Puerto Wetlands** | 30000/UDP |
| **Puerto Valdivia** | 30001/UDP |

### Proceso de despliegue

```bash
# 1. Push de cambios al repo
git push origin main

# 2. Pull en VPS
ssh -i ~/.ssh/id_ed25519 <VPS_USER>@<VPS_IP> \
  "cd $PROJECT_PATH && git pull origin main"

# 3. Subir map.sqlite (70MB, no esta en git)
scp -i ~/.ssh/id_ed25519 server/worlds/valdivia/map.sqlite \
  <VPS_USER>@<VPS_IP>:$PROJECT_PATH/server/worlds/valdivia/

# 4. Fix de permisos (container user abc = UID 911)
ssh -i ~/.ssh/id_ed25519 <VPS_USER>@<VPS_IP> \
  "sudo chown -R 911:911 $PROJECT_PATH/server/worlds/"

# 5. Levantar ambos servidores
ssh -i ~/.ssh/id_ed25519 <VPS_USER>@<VPS_IP> \
  "cd $PROJECT_PATH && docker compose up -d"
```

### Requisitos de red

- **Oracle Cloud Security List:** Regla de ingreso para UDP 30001 (ademas de la existente para UDP 30000)
- **DNS:** `luanti.gabrielpantoja.cl` apunta a <VPS_IP>

### Servidores activos 24/7

| Servidor | Direccion | Puerto | Mundo |
|----------|-----------|--------|-------|
| Wetlands | `luanti.gabrielpantoja.cl:30000` | 30000/UDP | world (VoxeLibre creative) |
| Valdivia 2.0 | `luanti.gabrielpantoja.cl:30001` | 30001/UDP | valdivia (recreacion OSM) |

---

## Expansion incremental: Confirmado viable

### Como funciona `map.sqlite`

- Almacena mapblocks individuales de 16x16x16 nodos, indexados por hash de posicion
- Cada mapblock es independiente -- se pueden INSERT nuevos sin afectar los existentes
- No hay limite practico de expansion (coord. limit: 31000 en cada eje)
- Se pueden generar nuevas areas y mergear en el futuro

### Presets de expansion (en generate-valdivia.sh)

| Preset | Area | Bbox | Tamano aprox |
|--------|------|------|-------------|
| `colegio` | Colegio Planeta Azul | `-39.8387,-73.2600,-39.8332,-73.2540` | ~600 x 500 m |
| `mvp` | Centro + Costanera + Mercado Fluvial | `-39.825,-73.255,-39.810,-73.235` | ~1.5 x 2 km |
| `exp1` | + Isla Teja + Puentes | `-39.840,-73.265,-39.805,-73.225` | ~3.5 x 4 km |
| `exp2` | + Barrios Las Animas, Jardin | `-39.855,-73.275,-39.795,-73.200` | ~6.5 x 7.5 km |
| `full` | Ciudad completa + Humedal Rio Cruces | `-39.870,-73.280,-39.780,-73.180` | ~10 x 10 km |

### Cobertura actual (v3)

El mundo en produccion cubre:
- Colegio Planeta Azul (punto de spawn)
- Rio Valdivia
- Miraflores
- Torobayo
- Zona industrial

### Problema de bordes

- Arnis usa `singlenode` mapgen -> areas fuera de la generacion son VACIO (aire)
- Los jugadores que caminen mas alla del area generada caen al vacio
- **Solucion futura:** Mod Lua con barrera invisible y mensaje "Zona en expansion..."

---

## Stack Tecnologico

### Via principal: Arnis con soporte Luanti nativo (PR #808) -- CONFIRMADO FUNCIONAL

| Componente | Detalle |
|------------|---------|
| **Arnis** | v2.5.0 "Metropolis Update" (feb 2026). 1,489 commits, muy activo |
| **Repo** | https://github.com/louis-e/arnis |
| **PR Luanti** | https://github.com/louis-e/arnis/pull/808 |
| **Lenguaje** | Rust 1.94.0 (99.8%) + Tauri GUI |
| **Datos** | OSM (Overpass API) + AWS Terrain Tiles (elevacion) |
| **Output** | `map.sqlite` nativo Luanti (v29 mapblocks + zstd) |
| **Target** | `--luanti-game mineclonia` (requiere remapeo para VoxeLibre) |
| **Licencia** | Apache 2.0 |

### Herramientas propias creadas

| Script | Lenguaje | Proposito |
|--------|----------|-----------|
| `scripts/setup-arnis.sh` | Bash | Instala Rust, clona y compila Arnis PR #808 |
| `scripts/generate-valdivia.sh` | Bash | Genera mundo con presets de bbox |
| `scripts/remap-mineclonia-to-voxelibre.py` | Python | Remplaza nombres de nodos Mineclonia por VoxeLibre en map.sqlite (19 nodos) |

### Via fallback: Arnis (MC) + MC2MT conversion

| Componente | Detalle |
|------------|---------|
| **Arnis** | Genera mundo Minecraft Java 1.17+ |
| **MC2MT** | https://github.com/ROllerozxa/MC2MT (C++, rapido, multithreaded) |
| **Target** | Mineclonia (compatible VoxeLibre) |
| **Limitacion** | MC2MT solo soporta MC hasta 1.12 -- necesita Amulet para downgrade |

### Herramientas NO viables (descartadas en investigacion)

| Herramienta | Razon de descarte |
|-------------|-------------------|
| mc2mt (dgm3333) | Abandonado (3 commits, 2015). NO usar |
| mcimport | Deprecated. Autor recomienda MC2MT de ROllerozxa |
| realterrain | Roto (admitido por autor). Solo terreno, sin edificios |
| geo-mapgen | Abandonado (2018). Solo terreno, sin OSM |
| OSM2Minetest | No existe. Ningun tool directo OSM->Luanti (excepto PR #808) |

### Verificacion del mundo generado

| Herramienta | Repo | Uso |
|-------------|------|-----|
| minetestmapper | https://github.com/luanti-org/minetestmapper | Vista top-down PNG (oficial, mantenido) |
| Mapserver | ContentDB: BuckarooBanzay/mapserver | Mapa web interactivo en tiempo real |

---

## Plan de Implementacion (actualizado con progreso real)

### FASE 0 -- Preparacion -- COMPLETADA

- [x] Compilar Arnis desde branch PR #808 en PC local (x86_64)
- [x] Instalar dependencias del sistema (libglib2.0-dev, libgtk-3-dev, etc.)
- [x] `cargo build --release` exitoso (~6 min)

### FASE 1 -- Generaciones iterativas -- COMPLETADA

- [x] v1: Generar area de prueba: Colegio Planeta Azul (~600x500m) -- demasiado pequena
- [x] v2: Generar area ampliada (~3.6x2.9km) -- todavia pequena, sin rio
- [x] v3 (FINAL): Generar area completa (~5.3x5.1km) -- incluye Rio Valdivia, Colegio, industrias, Miraflores, Torobayo
- [x] Descubrir incompatibilidad de nodos Mineclonia vs VoxeLibre
- [x] Crear script de remapeo `remap-mineclonia-to-voxelibre.py` (19 nodos)
- [x] Remapear 45,128 de 172,796 mapblocks exitosamente
- [x] Corregir gameid en world.mt (mineclonia -> mineclone2)

### FASE 2 -- Infraestructura de servidor -- COMPLETADA

- [x] Crear `docker-compose.yml` con arquitectura dual (puerto 30000 + 30001)
- [x] Crear `server/config/luanti-valdivia.conf`
- [x] Crear `server/worlds/valdivia/world.mt`
- [x] Crear scripts de automatizacion (`setup-arnis.sh`, `generate-valdivia.sh`)
- [x] Corregir worldmod arnis_mapgen (emerge parcial en vez de total)

### FASE 3 -- Despliegue en produccion -- COMPLETADA (2 iteraciones)

#### v1 (marzo 2026) — mundo Arnis PR #808

- [x] Subir map.sqlite (70MB) al VPS via scp
- [x] Configurar regla de ingreso UDP 30001 en Oracle Cloud Security List
- [x] Fix de permisos: `sudo chown -R 911:911 server/worlds/`
- [x] Levantar ambos servicios con docker compose
- [x] Verificar acceso publico en `luanti.gabrielpantoja.cl:30001`
- [x] Ambos servidores corriendo 24/7

#### v2 (29 junio 2026) — mundo Arnis v2.9.0

- [x] Generar nuevo mundo con `--bake-lighting` (420 MB, 1.15M mapblocks)
- [x] Remapeo v1: 222.521 mapblocks (árboles, madera, bambú)
- [x] Subir map.sqlite (460 MB) al VPS via rsync
- [x] Reemplazar mundo anterior (backup creado)
- [x] `sudo chown 1000:1000` (PUID del container)
- [x] Reiniciar container `luanti-valdivia-server`
- [x] Verificar logs: 0 errores de unknown node
- [x] Servidor anunciado a `servers.luanti.org`
- [ ] **Remapeo v2** pendiente: stairs/slabs/planchas con `remap-incremental-valdivia.py`

### FASE 4 -- Mod de bordes y navegacion (PARCIAL)

#### 4.1 Mod `valdivia_borders` -- Barrera de bordes (PENDIENTE)
```lua
-- Prevenir que jugadores caigan al vacio fuera del area generada
-- Detectar cuando un jugador se acerca al borde y teletransportarlo de vuelta
-- Mostrar mensaje: "Has llegado al limite de la ciudad. Zona en expansion..."
```

#### 4.2 Mod `valdivia_teleporter` -- Navegacion por la ciudad (HECHO -- 7 jun 2026)

Materializado como **`valdivia_teleporter`** (`server/mods/valdivia_teleporter/`):
- Comando **`/ir`** y nodo pedestal **`valdivia_teleporter:pad`** (`on_rightclick`) abren un
  menu formspec con las ubicaciones predefinidas.
- Solo cargado en Valdivia (`load_mod_valdivia_teleporter = true` en `luanti-valdivia.conf` +
  `world.mt` del VPS). Pedestal `diggable = false` (anti-grief). Texturas propias 16x16
  regenerables con `tools/generate_textures.py`.
- Las coordenadas viven en la tabla `DESTINOS` de `init.lua`. Para anadir un destino: agregar una
  fila ahi (id, nombre, pos) y reiniciar `luanti-valdivia`.

Destinos actuales del menu `/ir` y la lista completa de coordenadas publicas: ver la seccion
[«Coordenadas y teletransporte»](#coordenadas-y-teletransporte-referencia-in-game) mas abajo.

Pendiente futuro: senaletica de calles OSM y mapa interactivo con mas puntos de interes.

### FASE 5 -- Enriquecimiento manual con WorldEdit (FUTURO)

#### 5.1 Hitos historicos y culturales
- [ ] **Mercado Fluvial** -- estructura con puestos de artesanias y mariscos
- [ ] **Catedral de Valdivia** -- fachada en la Plaza de la Republica
- [ ] **Muelle Schuster** -- estructura sobre el rio
- [ ] **Torreon del Barro / Los Canelos** -- fuertes coloniales
- [ ] **Cerveceria Kunstmann** -- edificio emblematico en Isla Teja
- [ ] **Campus UACh** -- Universidad Austral en Isla Teja

#### 5.2 Geografia especial
- [ ] **Humedal Rio Cruces** -- vegetacion acuatica, totoras
- [ ] **Rio Calle-Calle y rio Valdivia** -- agua con corriente visual
- [ ] **Isla Teja** -- correctamente separada por el rio
- [ ] **Puentes** -- Pedro de Valdivia, Calle-Calle

#### 5.3 Detalles urbanos
- [ ] **Calle General Lagos** -- casonas patrimoniales estilo aleman
- [ ] **Costanera** -- paseo peatonal con bancas y faroles

### FASE 6 -- Mods especificos de Valdivia (FUTURO)

#### 6.1 Mod `valdivia_fauna`
- Coipo (nutria de rio) -- humedales
- Flamenco austral -- Rio Cruces
- Pudu -- zonas boscosas
- Chuncho (lechuza) -- nocturno

#### 6.2 Mod `valdivia_flora`
- Coigue, Arrayan (arboles nativos)
- Totora (junco de humedal)
- Nalca (planta gigante)
- Murta (arbusto frutal)

#### 6.3 Mod `valdivia_culture`
- Quioscos con historia de Valdivia (textos educativos)
- NPCs con dialogos sobre el terremoto de 1960
- Senaletica de humedales protegidos

---

## Datos tecnicos comparativos

| Aspecto | v1 Colegio (real) | v2 Ampliado (real) | v3 Final (real) | Ciudad completa (estimado) |
|---------|-------------------|-------------------|-----------------|---------------------------|
| Area | ~600 x 500 m | ~3.6 x 2.9 km | ~5.3 x 5.1 km | ~10 x 10 km |
| Mapblocks | 1,549 | 61,324 | 172,796 | ~2,000,000+ |
| Tamano disco | 716 KB | 26 MB | 70 MB | ~500 MB - 2 GB |
| Tiempo generacion | ~30 seg | ~1 min | ~2 min | ~30-60 min |
| Elevacion | 8.1 m rango | N/A | 83.0 m rango | Variable |
| Remapeados | 467 | N/A | 45,128 | N/A |

---

## Riesgos y mitigaciones (actualizado con experiencia real)

| Riesgo | Prob. | Impacto | Estado/Mitigacion |
|--------|-------|---------|-------------------|
| PR #808 no se mergea pronto | Media | Ninguno | **MITIGADO:** Compilamos desde branch directamente |
| Nombres de nodos Mineclonia != VoxeLibre | Cierta | Bloques "Unknown" | **RESUELTO:** Script `remap-mineclonia-to-voxelibre.py` funciona. 19 nodos remapeados (7 trees + 6 leaves + 6 woods) |
| gameid incorrecto en world.mt | Cierta | Mundo no carga | **RESUELTO:** Cambiar `mineclonia` a `mineclone2` post-generacion |
| arnis_mapgen emerge_area total | Cierta | "Loading map" infinito | **RESUELTO:** Modificado para emerge parcial 160x64x160 alrededor del jugador |
| Permisos de archivos en container | Cierta | Mundo no carga | **RESUELTO:** `sudo chown -R 911:911 server/worlds/` (UID 911 = user abc) |
| Puerto 30001 bloqueado | Cierta | No se conectan | **RESUELTO:** Regla de ingreso UDP 30001 en Oracle Cloud Security List |
| Arnis crashea con areas grandes | Baja | No genera | v3 de 5.3x5.1km genero sin problemas en ~2 min |
| Edificios OSM incompletos | Media | Faltan estructuras | Colegio Planeta Azul no aparece por nombre en OSM. Enriquecer con WorldEdit |
| Bordes del mundo generado = vacio | Cierta | Jugadores caen | Mod `valdivia_borders` pendiente |
| Compilacion Arnis en ARM (VPS) | Baja | No compila | Generar en PC local (x86), subir map.sqlite al VPS |
| Impacto en servidor Wetlands | Ninguno | -- | Mundo completamente separado (puerto 30001) |
| Espacio en nombre de carpeta output | Cierta | Confunde scripts | **CONOCIDO:** Output va a `Arnis Luanti World 1/`, scripts deben manejar esto |

---

## Area geografica objetivo

**Ciudad:** Valdivia, Region de Los Rios, Chile

### Cobertura actual (v3 en produccion)
```
min_lat: -39.860   max_lat: -39.812
min_lng: -73.285   max_lng: -73.225
```

### Cobertura futura (ciudad completa)
```
min_lat: -39.870   max_lat: -39.780
min_lng: -73.280   max_lng: -73.180
```

**Cobertura actual:** Rio Valdivia, Colegio Planeta Azul, Miraflores, Torobayo, zona industrial
**Cobertura futura:** Centro historico, Isla Teja (UACh, Parque Saval), Humedal Rio Cruces, Rio Calle-Calle, Barrios Jardin, Las Animas, Collico, Pedro de Valdivia Norte

---

## Minetest Game vs VoxeLibre: Cual es mas facil?

### Respuesta: VoxeLibre/Mineclonia es MEJOR para importar mundos

| Factor | Minetest Game | VoxeLibre/Mineclonia |
|--------|---------------|----------------------|
| Equivalencia de bloques MC | Parcial (necesita muchos mods extra) | Casi completa (nativo) |
| Bloques "Unknown" post-import | Muchos (lapis, quartz, nether, etc.) | Muy pocos (19 nodos necesitan remapeo) |
| Arnis PR #808 | Soportado (`--luanti-game minetest_game`) | Soportado (`--luanti-game mineclonia`) |
| Experiencia de juego | Basica, menos bloques | Completa, similar a Minecraft |
| Compatibilidad con Wetlands | Requiere servidor separado con otro juego | Mismo juego, mismos mods |

**Conclusion:** VoxeLibre es la mejor opcion. La mayoria de nodos generados por Arnis son directamente compatibles. Solo 19 nodos necesitan remapeo, lo cual se resuelve con el script Python.

---

## Ecosistema de herramientas (inventario completo)

### Generacion de mundos desde datos reales

| Herramienta | Tipo | Estado | Target | URL |
|-------------|------|--------|--------|-----|
| **Arnis v2.5** | OSM+DEM -> MC | Activo (1489 commits) | Minecraft Java/Bedrock | https://github.com/louis-e/arnis |
| **Arnis PR #808** | OSM+DEM -> Luanti | **Testeado, funcional, en produccion** | minetest_game + Mineclonia | https://github.com/louis-e/arnis/pull/808 |
| realterrain | DEM -> Luanti | Roto | Minetest Game | https://github.com/ubc-minetest-classroom/realterrain |
| geo-mapgen | GeoTIFF -> Luanti | Abandonado (2018) | Minetest Game | https://github.com/gaelysam/geo-mapgen |

### Conversion Minecraft -> Luanti

| Herramienta | Lenguaje | Target | MC max | Estado | URL |
|-------------|----------|--------|--------|--------|-----|
| **MC2MT (ROllerozxa)** | C++ | Mineclonia | 1.12 | Activo (2024) | https://github.com/ROllerozxa/MC2MT |
| MC2MT (ShadowNinja) | C++ | Minetest Game | 1.12 | 2023 | https://github.com/ShadowNinja/MC2MT |
| mc2mineclone | Python | MineClone2 | 1.12.2 | WIP | https://github.com/DavidRotert/mc2mineclone |
| mcimport | Python | MTG / MCL2 | Varios | Deprecated | https://github.com/minetest-tools/mcimport |
| mc2mt (dgm3333) | Python | Desconocido | Antiguo | Abandonado | https://github.com/dgm3333/mc2mt |

### Visualizacion y verificacion

| Herramienta | Tipo | Estado | URL |
|-------------|------|--------|-----|
| **minetestmapper** | PNG top-down (oficial) | Mantenido (2025) | https://github.com/luanti-org/minetestmapper |
| Mapserver | Mapa web interactivo | Activo (2024) | ContentDB: BuckarooBanzay/mapserver |
| minetest-worldmapper | PNG con transparencia | Activo (2025) | https://github.com/UgnilJoZ/minetest-worldmapper |

---

## Fuentes de la investigacion

- **Arnis repo:** https://github.com/louis-e/arnis
- **Arnis PR #808 (Luanti support):** https://github.com/louis-e/arnis/pull/808
- **Arnis issue #120 (feature request):** https://github.com/louis-e/arnis/issues/120
- **Arnis issue #805 (solicitud reciente):** https://github.com/louis-e/arnis/issues/805
- **MC2MT ROllerozxa:** https://github.com/ROllerozxa/MC2MT
- **mcimport:** https://github.com/minetest-tools/mcimport
- **mcimport PR #21 (MCL2):** https://github.com/minetest-tools/mcimport/pull/21
- **mc2mineclone:** https://github.com/DavidRotert/mc2mineclone
- **Forum: Real maps from OSM:** https://forum.minetest.net/viewtopic.php?t=17639
- **Forum: Map from cartographic data:** https://forum.minetest.net/viewtopic.php?t=28070
- **Forum: MC to Luanti conversion:** https://forum.luanti.org/viewtopic.php?f=14&t=13709
- **Hacker News: Arnis discussion:** https://news.ycombinator.com/item?id=42561711
- **AWS Blog: Arnis elevation:** https://aws.amazon.com/blogs/publicsector/building-realistic-minecraft-worlds-with-open-data-on-aws-how-arnis-uses-elevation-datasets-at-scale/
- **OpenStreetMap Valdivia:** https://www.openstreetmap.org/#map=13/-39.8282/-73.2335
- **SRTM elevacion Chile:** https://srtm.csi.cgiar.org/
- **VoxeLibre nodos:** https://github.com/VoxeLibre/VoxeLibre/tree/master/mods/CORE/mcl_core
- **WorldEdit Luanti:** https://content.luanti.org/packages/sfan5/worldedit/

---

## Coordenadas y teletransporte (referencia in-game)

> Lista publica saneada (las coordenadas internas/privadas viven en el repo privado).
> Documento vivo: actualizar con cada nueva ubicacion verificada en el juego.
> Bbox de referencia para la conversion de abajo: `-39.862,-73.285,-39.810,-73.195`
> (cobertura expandida; el build documentado arriba como v3 usa `-39.860,-73.285,-39.812,-73.225`).

### Teletransportador `/ir` (menu del mod `valdivia_teleporter`)

Destinos actuales (tabla `DESTINOS` en `server/mods/valdivia_teleporter/init.lua`):

| Destino | POS (x, y, z) |
|---------|---------------|
| Plaza de la República (spawn) | `3766, -4, -3249` (por verificar) |
| Los Fundadores | `4360, -51, -4211` (por verificar en mundo nuevo) |
| Santa Elena | `5844, -51, -4532` (por verificar en mundo nuevo) |
| Huachocopihue | `3761, -43, -3170` (por verificar en mundo nuevo) |
| Asociacion de Ferroviarios | `5079, -49, -2076` (por verificar en mundo nuevo) |

**Nota:** Las coordenadas del teletransportador son del mundo anterior (Arnis PR #808).
El nuevo mundo (Arnis v2.9.0) tiene un área y elevación diferentes — los destinos del `/ir`
probablemente ya no corresponden. Hay que verificarlos y actualizar la tabla `DESTINOS`
en `server/mods/valdivia_teleporter/init.lua`.

### Coordenadas publicas (`/teleport x,y,z`)

| Lugar | Comando teleport | Coords reales (lat, lng) | Notas |
|-------|-----------------|--------------------------|-------|
| **Plaza de la República** (spawn) | `/teleport 3766,-4,-3249` | -39.81422, -73.24589 | Nuevo spawn (verificar) |
| **Plaza estacionamiento Colegio** | `/teleport 2343,-56,-3148` | ~-39.838, -73.257 | Acceso al colegio |
| **Av Pedro Montt / Circunvalacion** | `/teleport 4517,-48,-3885` | ~-39.845, -73.233 | Cruce de avenidas |
| **Supermercado Trebol** | `/teleport 3358,-42,-3537` | ~-39.842, -73.246 | Av Simpson / Circunvalacion |
| **Plaza Civica Guacamayo** | `/teleport 2715,-47,-4381` | ~-39.849, -73.253 | |
| **Circunvalacion / San Luis** | `/teleport 5473,-53.5,-3842` | | Cruce Circunvalacion con San Luis |
| **Schneider / Circunvalacion** | `/teleport 5747,-44,-4000` | | Cruce Schneider con Circunvalacion |
| **Los Fundadores** | `/teleport 4360,-51,-4211` | | |
| **Plaza Londres (Huachocopihue)** | `/teleport 3761,-43,-3170` | | |
| **Asociacion de Ferroviarios** | `/teleport 5079,-49,-2076` | | Destino del teletransportador `/ir` |
| **Colegio Windsor** | `/teleport 3727,-44,-2619` | | Francia / Simpson |
| **Puente Pedro de Valdivia** | `/teleport 3111,-50,-176` | | Cruza el Rio Valdivia |

### Lugares por descubrir (estimados, pendientes de verificar)

| Lugar | Comando teleport estimado | Coords reales |
|-------|--------------------------|---------------|
| Rio Valdivia (centro) | `/teleport 2000,-50,-2000` | ~-39.840, -73.262 |
| Miraflores | `/teleport 4000,-45,-2500` | ~-39.830, -73.240 |
| Torobayo | `/teleport 1000,-45,-1500` | ~-39.825, -73.270 |
| Consorcio Maderero | `/teleport 1500,-45,-3500` | ~-39.848, -73.268 |

### Convertir coordenadas reales (lat, lng) -> coordenadas del juego

```
Bbox: min_lat=-39.862, min_lng=-73.285, max_lat=-39.810, max_lng=-73.195
Tamano: 5772m (N-S) x 7651m (E-O)

X = ((-73.285) - lng) / ((-73.285) - (-73.195)) * 7651
Z = -((-39.862) - lat) / ((-39.862) - (-39.810)) * 5772
Y = probar entre -30 y -55 (depende de la elevacion del terreno)
```

---

*Documento creado por Gabriel Pantoja + Claude -- Marzo 2026*
*Ultima actualizacion: 30 junio 2026*

### Historial de sesiones

- **30 junio 2026:** Corrección de nodos desconocidos (daylight_detector, noteblock, redstone_torch, banners, vegetación acuática del río). Nuevo mod `valdivia_newplayer` — privilegios sin fly. Desactivado `creative_mode` global para bloquear vuelo universal. Habilitado `wetlands_lastpos` (última posición al reconectarse). Nombre del servidor corregido: "Valdivia 2.0" → "Valdivia". Fix inventario creativo admin: VoxeLibre ignora privilegio `creative` con `creative_mode=false` — se resolvió seteando metadata `gamemode=creative` por jugador en `register_on_joinplayer`. Documentación completa en `operaciones/PRIVILEGIOS.md`.
- **30 junio 2026 (fix definitivo fly):** `mcl_privs` de VoxeLibre auto-otorgaba `fly` a todos los jugadores creativos (carrera de callbacks de join). `valdivia_newplayer` reescrito para imponer privilegios en **cada join** con `minetest.after(0)` (corre después de mcl_privs → gana siempre) + metadata `mcl_privs:fly_changed=1`. Auto-reparable. Ahora **solo `gabo` puede volar**; todos tienen `fast` e inventario creativo completo. Reconexión a última posición sigue activa vía `wetlands_lastpos`.
- **29 junio 2026 (sesión 2):** Fix spawn Y=-4 (emerge_area + world.mt). Fix Wetlands server_announce=false (deslistado). Fix Valdivia server_url=https://luanti.gabrielpantoja.cl. Remapeo v2 corriendo en VPS. Docs actualizados.
- **22 marzo 2026:** Remap de 9,290 mapblocks (texturas rojas), 10 vehiculos habilitados, notificaciones Discord para Valdivia, landing page actualizada con ambos mundos. Ver `docs/02-VALDIVIA-30001/operaciones/VALDIVIA_REMAP_Y_VEHICULOS_2026-03-22.md`
- **21 marzo 2026:** Servidor Valdivia v3 en produccion (puerto 30001), generacion con Arnis PR #808
