# Proyecto Valdivia -- Recreacion en Luanti/Minetest

**Estado:** En implementacion (primera generacion completada)
**Fecha:** Marzo 2026
**Ultima actualizacion:** 21 marzo 2026
**Objetivo:** Recrear la ciudad de Valdivia, Chile (2026) en el servidor Wetlands de Luanti, incluyendo rios, humedales, edificaciones y geografia real.

---

## Resumen Ejecutivo

Crear una recreacion fiel de Valdivia usando datos geoespaciales reales de OpenStreetMap y modelos de elevacion SRTM. **La via principal es Arnis con soporte nativo Luanti** (PR #808, branch `luanti-support`), que genera directamente mundos Luanti desde OSM sin necesidad de conversion intermedia. El PR fue compilado y testeado exitosamente el 21 de marzo de 2026. La primera generacion (Colegio Planeta Azul, Valdivia) esta completa y funcional.

---

## Arnis PR #808 -- TESTEADO Y FUNCIONAL

**PR:** https://github.com/louis-e/arnis/pull/808
**Autor:** 3rd3 | **Fecha:** 21 marzo 2026 | **Estado:** Open (en review)

### Compilacion exitosa

- **Plataforma:** x86_64 Linux Mint
- **Rust:** 1.94.0
- **Tiempo de compilacion:** ~6 minutos (`cargo build --release`)
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
  --bbox="-39.8387,-73.2600,-39.8332,-73.2540"
```

**Notas importantes:**
- Requiere flag `--output-dir` (el directorio debe existir previamente)
- Output va a `<output-dir>/Arnis Luanti World 1/` (nota: espacio en el nombre de carpeta)
- Genera automaticamente: `map.sqlite`, `world.mt`, `map_meta.txt`, `env_meta.txt`
- Incluye un worldmod `arnis_mapgen` que maneja spawn, respawn, y fix de iluminacion en primer load
- Usa `singlenode` mapgen + compresion zstd

---

## Primera Generacion: Colegio Planeta Azul

### Datos de la generacion

| Aspecto | Valor |
|---------|-------|
| **Ubicacion** | -39.835957, -73.257018 (Valdivia, Chile) |
| **Bbox** | `-39.8387,-73.2600,-39.8332,-73.2540` |
| **Area** | ~600 x 500 metros |
| **Mapblocks iniciales** | 1,549 |
| **Mapblocks en map.sqlite** | 36,708 |
| **Tamano archivo** | 716 KB |
| **Spawn generado por Arnis** | 256, -56, -306 |
| **Rango de elevacion** | 8.1 metros (realista para tierras bajas de Valdivia) |
| **Tiempo de generacion** | ~30 segundos |

### Cobertura OSM del area

- Colegio Planeta Azul **NO** esta mapeado por nombre en OSM (solo Colegio San Lucas cercano)
- Buena cobertura general: calles (Arica, Pedro Ruiz Manriquez), arboles con datos de especie, parques, cancha deportiva, piscina, grifos, ciclovias
- Edificios aparecen como estructuras pero sin nombres especificos

---

## Incompatibilidad de Nodos: Mineclonia vs VoxeLibre (LECCION CRITICA)

### El problema

Arnis PR #808 genera nodos con nombres de **Mineclonia**, NO de VoxeLibre. Son forks del mismo codebase (MineClone2) pero han divergido en nombres de nodos:

| Mineclonia (generado por Arnis) | VoxeLibre (nuestro servidor) |
|--------------------------------|------------------------------|
| `mcl_trees:tree_oak` | `mcl_core:tree` |
| `mcl_trees:leaves_oak` | `mcl_core:leaves` |
| `mcl_trees:tree_birch` | `mcl_core:birchtree` |
| `mcl_trees:leaves_birch` | `mcl_core:birchleaves` |
| `mcl_trees:tree_spruce` | `mcl_core:sprucetree` |
| `mcl_trees:leaves_spruce` | `mcl_core:spruceleaves` |
| `mcl_trees:wood_oak` | `mcl_core:wood` |

**Otros nodos** (`mcl_colorblocks`, `mcl_stairs`, `mcl_flowers`, `mcl_doors`, etc.) ya son compatibles con VoxeLibre.

### Solucion implementada: Script de remapeo

Script Python `scripts/remap-mineclonia-to-voxelibre.py` que:
1. Lee mapblocks de map.sqlite
2. Salta el byte de version (0x1d = 29) antes de descomprimir zstd
3. Encuentra strings de nombres de nodos con prefijo de longitud en la tabla name-id mapping
4. Reemplaza nombres Mineclonia por equivalentes VoxeLibre
5. Recomprime con zstd
6. **Resultado:** 467 de 36,708 mapblocks remapeados exitosamente

### Correccion de gameid en world.mt

Arnis genera `gameid = mineclonia` pero VoxeLibre requiere `gameid = mineclone2`. Se debe cambiar manualmente despues de cada generacion.

---

## Minetest Game vs VoxeLibre: Cual es mas facil?

### Respuesta: VoxeLibre/Mineclonia es MEJOR para importar mundos

| Factor | Minetest Game | VoxeLibre/Mineclonia |
|--------|---------------|----------------------|
| Equivalencia de bloques MC | Parcial (necesita muchos mods extra) | Casi completa (nativo) |
| Bloques "Unknown" post-import | Muchos (lapis, quartz, nether, etc.) | Muy pocos (solo 7 nodos mcl_trees necesitan remapeo) |
| Arnis PR #808 | Soportado (`--luanti-game minetest_game`) | Soportado (`--luanti-game mineclonia`) |
| Experiencia de juego | Basica, menos bloques | Completa, similar a Minecraft |
| Compatibilidad con Wetlands | Requiere servidor separado con otro juego | Mismo juego, mismos mods |

**Conclusion:** VoxeLibre es la mejor opcion. La mayoria de nodos generados por Arnis son directamente compatibles. Solo 7 nodos de tipo `mcl_trees` requieren remapeo, lo cual se resuelve con el script Python.

---

## Expansion incremental: Confirmado viable

### Como funciona `map.sqlite`

- Almacena mapblocks individuales de 16x16x16 nodos, indexados por hash de posicion
- Cada mapblock es independiente -- se pueden INSERT nuevos sin afectar los existentes
- No hay limite practico de expansion (coord. limit: 31000 en cada eje)

### Requisito critico

Las tablas de mapeo nombre-a-ID deben ser consistentes entre generaciones al mergear map.sqlite de diferentes areas.

### Estrategia de expansion (presets en generate-valdivia.sh)

| Preset | Area | Bbox | Tamano aprox |
|--------|------|------|-------------|
| `colegio` | Colegio Planeta Azul (completado) | `-39.8387,-73.2600,-39.8332,-73.2540` | ~600 x 500 m |
| `mvp` | Centro + Costanera + Mercado Fluvial | `-39.825,-73.255,-39.810,-73.235` | ~1.5 x 2 km |
| `exp1` | + Isla Teja + Puentes | `-39.840,-73.265,-39.805,-73.225` | ~3.5 x 4 km |
| `exp2` | + Barrios Las Animas, Jardin | `-39.855,-73.275,-39.795,-73.200` | ~6.5 x 7.5 km |
| `full` | Ciudad completa + Humedal Rio Cruces | `-39.870,-73.280,-39.780,-73.180` | ~10 x 10 km |

### Problema de bordes

- Arnis usa `singlenode` mapgen -> areas fuera de la generacion son VACIO (aire)
- Los jugadores que caminen mas alla del area generada caen al vacio
- **Solucion futura:** Mod Lua con barrera invisible y mensaje "Zona en expansion..."

---

## Area geografica objetivo

**Ciudad:** Valdivia, Region de Los Rios, Chile
**Coordenadas bbox completas:**
```
min_lat: -39.870
min_lng: -73.280
max_lat: -39.780
max_lng: -73.180
```

**Cobertura completa (futuro):**
- Centro historico, Isla Teja (UACh, Parque Saval)
- Humedal Rio Cruces
- Rio Calle-Calle y Rio Valdivia
- Barrios: Jardin, Las Animas, Collico, Pedro de Valdivia Norte

---

## Infraestructura Creada

### Archivos en el repositorio

| Archivo | Proposito |
|---------|-----------|
| `docker-compose.yml` | Arquitectura dual: puerto 30000 (Wetlands) + puerto 30001 (Valdivia) |
| `server/config/luanti-valdivia.conf` | Config dedicada (creative, no mobs, singlenode mapgen) |
| `server/worlds/valdivia/world.mt` | Metadata del mundo Valdivia |
| `scripts/setup-arnis.sh` | Instala Rust, clona Arnis, compila desde PR #808 |
| `scripts/generate-valdivia.sh` | Genera mundo con presets de bbox (colegio, mvp, exp1, exp2, full) |
| `scripts/remap-mineclonia-to-voxelibre.py` | Corrige incompatibilidad de nombres de nodos |

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

### FASE 1 -- Primera generacion -- COMPLETADA

- [x] Generar area de prueba: Colegio Planeta Azul (~600x500m)
- [x] Verificar output: map.sqlite, world.mt, arnis_mapgen worldmod
- [x] Descubrir incompatibilidad de nodos Mineclonia vs VoxeLibre
- [x] Crear script de remapeo `remap-mineclonia-to-voxelibre.py`
- [x] Remapear 467 mapblocks exitosamente
- [x] Corregir gameid en world.mt (mineclonia -> mineclone2)

### FASE 2 -- Infraestructura de servidor -- COMPLETADA

- [x] Crear `docker-compose.yml` con arquitectura dual (puerto 30000 + 30001)
- [x] Crear `server/config/luanti-valdivia.conf`
- [x] Crear `server/worlds/valdivia/world.mt`
- [x] Crear scripts de automatizacion (`setup-arnis.sh`, `generate-valdivia.sh`)

### FASE 3 -- Expansion a MVP centro (PENDIENTE)

- [ ] Generar bbox MVP: centro + Costanera + Mercado Fluvial
- [ ] Verificar con minetestmapper + Luanti local en singleplayer
- [ ] Remapear nodos con script existente
- [ ] Desplegar en VPS como mundo paralelo en puerto 30001

### FASE 4 -- Mod de bordes y navegacion (PENDIENTE)

#### 4.1 Mod `valdivia_borders` -- Barrera de bordes
```lua
-- Prevenir que jugadores caigan al vacio fuera del area generada
-- Detectar cuando un jugador se acerca al borde y teletransportarlo de vuelta
-- Mostrar mensaje: "Has llegado al limite de la ciudad. Zona en expansion..."
```

#### 4.2 Mod `valdivia_nav` -- Navegacion por la ciudad
```lua
-- Senales con nombres de calles reales (extraidos de OSM)
-- Mapa interactivo en formspec con puntos de interes
-- Comando /valdivia_tp <lugar> para teletransportarse a hitos
```

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

## Datos tecnicos (actualizados con datos reales)

| Aspecto | Colegio (real) | MVP (estimado) | Ciudad completa (estimado) |
|---------|---------------|----------------|---------------------------|
| Area | ~600 x 500 m | ~1.5 x 2 km | ~10 x 10 km |
| Mapblocks | 36,708 | ~150,000 | ~2,000,000+ |
| Tamano disco | 716 KB | ~5-20 MB | ~500 MB - 2 GB |
| Tiempo generacion | ~30 seg | ~5-15 min | ~30-60 min |
| Elevacion | 8.1 m rango | Similar | Variable (cerros al este) |

---

## Riesgos y mitigaciones (actualizado con experiencia real)

| Riesgo | Prob. | Impacto | Estado/Mitigacion |
|--------|-------|---------|-------------------|
| PR #808 no se mergea pronto | Media | Ninguno | **MITIGADO:** Compilamos desde branch directamente |
| Nombres de nodos Mineclonia != VoxeLibre | Cierta | Bloques "Unknown" | **RESUELTO:** Script `remap-mineclonia-to-voxelibre.py` funciona. Solo 7 nodos mcl_trees necesitan remapeo |
| gameid incorrecto en world.mt | Cierta | Mundo no carga | **RESUELTO:** Cambiar `mineclonia` a `mineclone2` post-generacion |
| Arnis crashea con areas grandes | Media | No genera ciudad completa | Empezar con area pequena, expandir incrementalmente |
| Edificios OSM incompletos | Media | Faltan estructuras | Colegio Planeta Azul no aparece por nombre en OSM. Enriquecer con WorldEdit |
| Bordes del mundo generado = vacio | Cierta | Jugadores caen | Mod `valdivia_borders` pendiente |
| Compilacion Arnis en ARM (VPS) | Baja | No compila | Generar en PC local (x86), subir map.sqlite al VPS |
| Impacto en servidor Wetlands | Ninguno | -- | Mundo completamente separado (puerto 30001) |
| Espacio en nombre de carpeta output | Cierta | Confunde scripts | **CONOCIDO:** Output va a `Arnis Luanti World 1/`, scripts deben manejar esto |

---

## Proximos pasos inmediatos

1. **[x] Compilar Arnis desde branch PR #808** -- exitoso, Rust 1.94.0
2. **[x] Primera generacion de prueba** -- Colegio Planeta Azul completado
3. **[x] Resolver incompatibilidad de nodos** -- Script de remapeo funcional
4. **[x] Crear infraestructura de servidor dual** -- docker-compose, configs, scripts
5. **[ ] Generar MVP centro de Valdivia** -- bbox mas grande con landmarks principales
6. **[ ] Verificar MVP** con minetestmapper + Luanti local en singleplayer
7. **[ ] Desplegar en VPS** como mundo paralelo en puerto 30001
8. **[ ] Crear mod `valdivia_borders`** para prevenir caidas al vacio

---

## Ecosistema de herramientas (inventario completo)

### Generacion de mundos desde datos reales

| Herramienta | Tipo | Estado | Target | URL |
|-------------|------|--------|--------|-----|
| **Arnis v2.5** | OSM+DEM -> MC | Activo (1489 commits) | Minecraft Java/Bedrock | https://github.com/louis-e/arnis |
| **Arnis PR #808** | OSM+DEM -> Luanti | **Testeado, funcional** | minetest_game + Mineclonia | https://github.com/louis-e/arnis/pull/808 |
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

### Herramientas propias creadas

| Script | Lenguaje | Proposito |
|--------|----------|-----------|
| `scripts/setup-arnis.sh` | Bash | Instala Rust, clona y compila Arnis PR #808 |
| `scripts/generate-valdivia.sh` | Bash | Genera mundo con presets de bbox |
| `scripts/remap-mineclonia-to-voxelibre.py` | Python | Remplaza nombres de nodos Mineclonia por VoxeLibre en map.sqlite |

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

*Documento creado por Gabriel Pantoja + Claude -- Marzo 2026*
*Ultima actualizacion: 21 marzo 2026 -- Primera generacion completada*
