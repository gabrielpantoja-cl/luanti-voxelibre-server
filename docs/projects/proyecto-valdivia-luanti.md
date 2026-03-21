# Proyecto Valdivia -- Recreacion en Luanti/Minetest

**Estado:** Planificacion
**Fecha:** Marzo 2026
**Ultima investigacion:** 21 marzo 2026
**Objetivo:** Recrear la ciudad de Valdivia, Chile (2026) en el servidor Wetlands de Luanti, incluyendo rios, humedales, edificaciones y geografia real.

---

## Resumen Ejecutivo

Crear una recreacion fiel de Valdivia usando datos geoespaciales reales de OpenStreetMap y modelos de elevacion SRTM. **La via principal es Arnis con soporte nativo Luanti** (PR #808, abierto 21-mar-2026), que genera directamente mundos Luanti desde OSM sin necesidad de conversion intermedia. Como fallback, se puede generar un mundo Minecraft con Arnis y convertirlo con MC2MT (ROllerozxa).

---

## Hallazgo clave: Arnis PR #808 -- Soporte nativo Luanti

**PR:** https://github.com/louis-e/arnis/pull/808
**Autor:** 3rd3 | **Fecha:** 21 marzo 2026 | **Estado:** Open (en review)

Este PR agrega generacion directa de mundos Luanti sin pasar por Minecraft:
- Nuevo modulo `luanti.rs` (568 lineas) -- serializa `map.sqlite` con formato mapblock v29 + compresion zstd
- Modulo `luanti_block_map.rs` (719 lineas) -- tablas de mapeo dual para **minetest_game** Y **mineclonia**
- Flag CLI: `--luanti --luanti-game mineclonia`
- Genera `world.mt`, `map_meta.txt`, `env_meta.txt` automaticamente
- Usa `singlenode` mapgen + worldmod Lua para recalcular iluminacion
- Dependencias: `rusqlite`, `zstd`

**Impacto:** Si se mergea, elimina completamente la Fase 2 (conversion) del plan original. Pipeline se reduce a: Arnis -> mundo Luanti listo.

---

## Minetest Game vs VoxeLibre: Cual es mas facil?

### Respuesta: VoxeLibre/Mineclonia es MEJOR para importar mundos

| Factor | Minetest Game | VoxeLibre/Mineclonia |
|--------|---------------|----------------------|
| Equivalencia de bloques MC | Parcial (necesita muchos mods extra) | Casi completa (nativo) |
| Bloques "Unknown" post-import | Muchos (lapis, quartz, nether, etc.) | Muy pocos |
| Herramientas de conversion | mcimport (antiguo, Python) | MC2MT ROllerozxa (C++, rapido) |
| Arnis PR #808 | Soportado (`--luanti-game minetest_game`) | Soportado (`--luanti-game mineclonia`) |
| Experiencia de juego | Basica, menos bloques | Completa, similar a Minecraft |
| Compatibilidad con Wetlands | Requiere servidor separado con otro juego | Mismo juego, mismos mods |

**Conclusion:** Contra-intuitivamente, VoxeLibre es la mejor opcion porque tiene equivalentes nativos para casi todos los bloques de Minecraft. Con Minetest Game necesitarias instalar docenas de mods adicionales para evitar bloques "Unknown". Ademas, al usar el mismo juego base que Wetlands, los mods existentes funcionan sin cambios.

**Nota importante:** Mineclonia y VoxeLibre son forks del mismo codebase (MineClone2), pero han divergido en algunos nombres de nodos. Sera necesario auditar la tabla de mapeo del PR #808 contra los nombres actuales de VoxeLibre v0.90.1.

---

## Expansion incremental: Empezar pequeno y crecer

### Respuesta: SI, es totalmente viable

**Como funciona `map.sqlite`:**
- Almacena mapblocks individuales de 16x16x16 nodos, indexados por hash de posicion
- Cada mapblock es independiente -- se pueden INSERT nuevos sin afectar los existentes
- No hay limite practico de expansion (coord. limit: 31000 en cada eje)

**Estrategia de expansion:**
1. Generar area pequena (ej: centro de Valdivia, ~2 km2)
2. Verificar que funciona correctamente
3. Generar areas adyacentes con Arnis
4. Insertar los nuevos mapblocks en el mismo `map.sqlite`
5. **Requisito critico:** las tablas de mapeo nombre-a-ID deben ser consistentes entre generaciones

**Problema de bordes:**
- Arnis usa `singlenode` mapgen -> areas fuera de la generacion son VACIO (aire)
- Los jugadores que caminen mas alla del area generada caen al vacio
- **Solucion:** Mod Lua que genera terreno natural basico (pasto, arboles) fuera del area de la ciudad, o barrera invisible con mensaje "Zona en construccion"

**Estrategia recomendada de expansion:**

| Fase | Area | Bbox aproximado | Tamano |
|------|------|-----------------|--------|
| MVP | Centro + Costanera + Mercado Fluvial | `-39.825,-73.255,-39.810,-73.235` | ~1.5 x 2 km |
| Expansion 1 | + Isla Teja + Puentes | `-39.840,-73.265,-39.805,-73.225` | ~3.5 x 4 km |
| Expansion 2 | + Barrios Las Animas, Jardin | `-39.855,-73.275,-39.795,-73.200` | ~6.5 x 7.5 km |
| Completa | Ciudad completa + Humedal Rio Cruces | `-39.870,-73.280,-39.780,-73.180` | ~10 x 10 km |

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

**Coordenadas bbox MVP (centro):**
```
min_lat: -39.825
min_lng: -73.255
max_lat: -39.810
max_lng: -73.235
```

**Cobertura MVP:**
- Mercado Fluvial y costanera
- Plaza de la Republica
- Calle General Lagos (casonas patrimoniales)
- Muelle Schuster
- Ribera del rio Valdivia

**Cobertura completa (futuro):**
- Centro historico, Isla Teja (UACh, Parque Saval)
- Humedal Rio Cruces
- Rio Calle-Calle y Rio Valdivia
- Barrios: Jardin, Las Animas, Collico, Pedro de Valdivia Norte

---

## Stack Tecnologico (actualizado)

### Via principal: Arnis con soporte Luanti nativo (PR #808)

| Componente | Detalle |
|------------|---------|
| **Arnis** | v2.5.0 "Metropolis Update" (feb 2026). 1,489 commits, muy activo |
| **Repo** | https://github.com/louis-e/arnis |
| **PR Luanti** | https://github.com/louis-e/arnis/pull/808 |
| **Lenguaje** | Rust (99.8%) + Tauri GUI |
| **Datos** | OSM (Overpass API) + AWS Terrain Tiles (elevacion) |
| **Output** | `map.sqlite` nativo Luanti (v29 mapblocks + zstd) |
| **Target** | `--luanti-game mineclonia` (compatible VoxeLibre) |
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

## Plan de Implementacion (revisado)

### FASE 0 -- Preparacion (1-2 dias)

#### 0.1 Monitorear PR #808
```bash
# Verificar estado del PR
gh pr view 808 --repo louis-e/arnis
```
- Si esta mergeado: seguir con Fase 1A (via directa)
- Si no esta mergeado: compilar desde el branch del PR, o usar Fase 1B (via fallback)

#### 0.2 Compilar Arnis desde branch del PR (si no esta mergeado)
```bash
# En PC local (x86_64) -- NO en VPS ARM para evitar complicaciones
git clone https://github.com/louis-e/arnis
cd arnis
git fetch origin pull/808/head:luanti-support
git checkout luanti-support
cargo build --release
```

### FASE 1A -- Generacion directa Luanti (via principal)

```bash
# Generar MVP: solo centro de Valdivia (~1.5 x 2 km)
./target/release/arnis \
  --luanti \
  --luanti-game mineclonia \
  --terrain \
  --bbox="-39.825,-73.255,-39.810,-73.235"
```

**Output esperado:** `~/.minetest/worlds/arnis/` con `map.sqlite`, `world.mt`, etc.

### FASE 1B -- Via fallback (MC + MC2MT)

Solo si PR #808 no funciona:

```bash
# Paso 1: Generar mundo Minecraft
./target/release/arnis \
  --terrain \
  --path="/tmp/valdivia-mc/saves/valdivia" \
  --bbox="-39.825,-73.255,-39.810,-73.235"

# Paso 2: Downgrade a formato MC 1.12 con Amulet (si necesario)
pip install amulet-core amulet-nbt
# (script de conversion)

# Paso 3: Convertir con MC2MT de ROllerozxa
git clone https://github.com/ROllerozxa/MC2MT
cd MC2MT
make
./MC2MT /tmp/valdivia-mc/saves/valdivia/ ~/.minetest/worlds/valdivia/
```

### FASE 2 -- Verificacion y ajustes (2-3 dias)

#### 2.1 Verificar mundo generado
```bash
# Vista top-down con minetestmapper
minetestmapper -i ~/.minetest/worlds/valdivia/ -o valdivia-map.png

# Abrir en Luanti local (singleplayer) y recorrer
```

#### 2.2 Auditar nombres de nodos
Comparar los nombres de nodos generados (Mineclonia) vs VoxeLibre v0.90.1:
```bash
# Listar nodos unicos en el mundo generado
sqlite3 ~/.minetest/worlds/valdivia/map.sqlite \
  "SELECT DISTINCT name FROM ... " # (requiere deserializar mapblocks)

# Comparar con nodos registrados en VoxeLibre
grep -r "minetest.register_node" server/games/mineclone2/mods/ | head -50
```

Si hay diferencias, crear script Python para renombrar nodos en `map.sqlite`.

### FASE 3 -- Integracion en servidor Wetlands (1 semana)

#### Opcion A: Mundo paralelo (RECOMENDADA)
```yaml
# Agregar en docker-compose.yml:
luanti-valdivia:
  image: linuxserver/luanti:latest
  container_name: luanti-valdivia-server
  ports:
    - "30001:30000/udp"
  volumes:
    - ./server/config/luanti-valdivia.conf:/config/.minetest/minetest.conf
    - ./server/worlds/valdivia:/config/.minetest/worlds/valdivia
    - ./server/games:/config/.minetest/games
    - ./server/mods:/config/.minetest/mods
  environment:
    - CLI_ARGS=--worldname valdivia
```

**Ventajas:**
- Cero riesgo para el servidor Wetlands principal
- Configuracion independiente (puede tener reglas diferentes)
- Se puede apagar/encender sin afectar Wetlands

#### Opcion B: Zona remota en mismo mundo
- Insertar mapblocks en coordenadas lejanas (X=50000, Z=50000) del mundo principal
- Portal de teletransporte desde spawn de Wetlands
- **Riesgo:** si algo sale mal, corrompe el mundo principal
- **No recomendada** para la fase inicial

### FASE 4 -- Mod de bordes y navegacion

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

### FASE 5 -- Enriquecimiento manual con WorldEdit (continuo)

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

### FASE 6 -- Mods especificos de Valdivia (futuro)

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

## Datos tecnicos

| Aspecto | MVP (centro) | Ciudad completa |
|---------|-------------|-----------------|
| Area | ~3 km2 | ~100 km2 |
| Dimension en bloques | ~1,500 x 2,000 | ~10,000 x 10,000 |
| Tamano disco estimado | ~200 MB - 1 GB | ~3-8 GB |
| RAM para generar | 4 GB | 8 GB |
| Tiempo generacion Arnis | ~5-15 min | ~30-60 min |
| Conversion (si fallback) | ~10 min | ~1-2 horas |

---

## Riesgos y mitigaciones (actualizado)

| Riesgo | Prob. | Impacto | Mitigacion |
|--------|-------|---------|------------|
| PR #808 no se mergea pronto | Media | Retrasa el inicio | Compilar desde branch del PR directamente |
| PR #808 tiene bugs con Mineclonia | Media | Bloques incorrectos | Auditar tabla de mapeo, corregir con script |
| Nombres de nodos Mineclonia != VoxeLibre | Alta | Bloques "Unknown" | Script Python para renombrar en map.sqlite |
| Arnis crashea con areas grandes | Media | No genera ciudad completa | Empezar con MVP pequeno, expandir incrementalmente |
| Edificios OSM incompletos (multi-polygon) | Media | Faltan estructuras | Enriquecer manualmente con WorldEdit |
| Bordes del mundo generado = vacio | Cierta | Jugadores caen | Mod `valdivia_borders` con barrera y mensaje |
| Compilacion Arnis en ARM (VPS) | Baja | No compila | Generar en PC local (x86), subir map.sqlite al VPS |
| Impacto en servidor Wetlands | Ninguno | -- | Mundo completamente separado (puerto 30001) |

---

## Proximos pasos inmediatos

1. **[ ] Monitorear PR #808** -- https://github.com/louis-e/arnis/pull/808
2. **[ ] Compilar Arnis desde branch PR #808** en PC local (x86)
3. **[ ] Test MVP** -- generar solo centro de Valdivia (bbox reducido ~1.5x2 km)
4. **[ ] Verificar** con minetestmapper + Luanti local en singleplayer
5. **[ ] Auditar nodos** -- comparar Mineclonia vs VoxeLibre v0.90.1
6. **[ ] Si funciona** -- subir al VPS como mundo paralelo en puerto 30001
7. **[ ] Si PR #808 no funciona** -- probar via fallback (Arnis MC + MC2MT ROllerozxa)

---

## Ecosistema de herramientas (inventario completo)

### Generacion de mundos desde datos reales

| Herramienta | Tipo | Estado | Target | URL |
|-------------|------|--------|--------|-----|
| **Arnis v2.5** | OSM+DEM -> MC | Activo (1489 commits) | Minecraft Java/Bedrock | https://github.com/louis-e/arnis |
| **Arnis PR #808** | OSM+DEM -> Luanti | En review (nuevo) | minetest_game + Mineclonia | https://github.com/louis-e/arnis/pull/808 |
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

*Documento creado por Gabriel Pantoja + Claude -- Marzo 2026*
*Investigacion actualizada: 21 marzo 2026*
