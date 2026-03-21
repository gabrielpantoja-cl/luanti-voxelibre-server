# 🏙️ Proyecto Valdivia — Recreación en Luanti/Minetest
**Estado:** Planificación  
**Fecha:** Marzo 2026  
**Objetivo:** Recrear la ciudad de Valdivia, Chile (2026) en el servidor Wetlands de Luanti, incluyendo ríos, humedales, edificaciones y geografía real.

---

## 📋 Resumen Ejecutivo

Crear una recreación fiel de Valdivia usando datos geoespaciales reales de OpenStreetMap y modelos de elevación de la NASA/SRTM, generando primero un mundo Minecraft con la herramienta **Arnis**, y luego convirtiéndolo al formato Luanti para integrarlo como zona separada dentro del servidor Wetlands existente.

---

## 🗺️ Área geográfica objetivo

**Ciudad:** Valdivia, Región de Los Ríos, Chile  
**Coordenadas bbox recomendadas:**
```
min_lat: -39.870
min_lng: -73.280
max_lat: -39.780
max_lng: -73.180
```

**Cobertura incluida:**
- Centro histórico de Valdivia
- Humedal Río Cruces
- Río Calle-Calle y Río Valdivia
- Isla Teja (UACh, Parque Saval)
- Barrios: Jardín, Las Ánimas, Collico, Pedro de Valdivia Norte
- Mercado Fluvial y costanera
- Muelle Schuster

---

## 🔧 Stack Tecnológico

### Herramienta principal: **Arnis**
- **Repo:** https://github.com/louis-e/arnis
- **Lenguaje:** Rust (compila en Linux/Mac/Windows)
- **Licencia:** Apache 2.0 (libre y gratuito)
- **Reconocimiento:** Publicado en AWS Blog, Hackaday, Tom's Hardware (dic 2024)
- **Fuentes de datos:**
  - **OpenStreetMap** → calles, edificios, parques, ríos, humedales, árboles
  - **NASA/Copernicus SRTM** → elevación real del terreno (topografía)
- **Output:** Mundo Minecraft Java Edition 1.17+ (formato `.mca`)

### Conversor: **mc2mt**
- **Repo:** https://github.com/dgm3333/mc2mt
- **Función:** Convierte mundos Minecraft → Luanti/Minetest
- **Mapeo de bloques:** Configurable para VoxeLibre

### Servidor destino: Luanti + VoxeLibre
- Servidor existente en `luanti.gabrielpantoja.cl:30000`
- Mundo principal: `vegan_wetlands` (intacto)
- Mundo Valdivia: mundo nuevo separado o zona dentro del mismo mundo

---

## 📐 Plan de Implementación

### FASE 1 — Generación del terreno base (Semana 1-2)

#### 1.1 Instalar Arnis en el VPS
```bash
# Instalar Rust
curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh

# Clonar y compilar Arnis
git clone https://github.com/louis-e/arnis
cd arnis
cargo build --release
```

#### 1.2 Generar el mundo Valdivia en Minecraft
```bash
# Crear carpeta de mundo vacía
mkdir -p /tmp/valdivia-mc/saves/valdivia

# Ejecutar Arnis con bbox de Valdivia
./target/release/arnis \
  --terrain \
  --path="/tmp/valdivia-mc/saves/valdivia" \
  --bbox="-39.870,-73.280,-39.780,-73.180"
```

**Tiempo estimado:** 15-45 minutos (depende del tamaño del área)  
**Espacio en disco:** ~2-5 GB

#### 1.3 Verificar resultado
- Abrir el mundo generado en Minecraft (local) o con `minetest-mapper`
- Confirmar que ríos, humedales y calles principales se generaron correctamente
- Verificar topografía del terreno (Valdivia tiene colinas suaves y zonas bajas de humedal)

---

### FASE 2 — Conversión a formato Luanti (Semana 2-3)

#### 2.1 Convertir con mc2mt
```bash
git clone https://github.com/dgm3333/mc2mt
cd mc2mt
# Configurar mapeo de bloques Minecraft → VoxeLibre
# Editar blocks.txt para mapear:
# stone → mcl_core:stone
# grass_block → mcl_core:dirt_with_grass
# water → mclx_core:river_water_source
# etc.

python3 mc2mt.py \
  --input /tmp/valdivia-mc/saves/valdivia \
  --output /home/gabriel/luanti-voxelibre-server/server/worlds/valdivia
```

#### 2.2 Tabla de mapeo de bloques clave
| Minecraft | VoxeLibre |
|-----------|-----------|
| `stone` | `mcl_core:stone` |
| `grass_block` | `mcl_core:dirt_with_grass` |
| `water` | `mclx_core:river_water_source` |
| `sand` | `mcl_core:sand` |
| `oak_log` | `mcl_core:tree` |
| `oak_leaves` | `mcl_core:leaves` |
| `cobblestone` | `mcl_core:cobble` |
| `glass` | `mcl_core:glass` |
| `dirt` | `mcl_core:dirt` |
| `gravel` | `mcl_core:gravel` |

---

### FASE 3 — Integración en el servidor (Semana 3)

#### Opción A: Mundo paralelo (recomendada para empezar)
```yaml
# Agregar en docker-compose.yml un segundo servicio:
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

#### Opción B: Portal desde Wetlands → Valdivia
- Desarrollar mod Lua `valdivia_portal`
- Bloque especial cerca del spawn que teletransporta a coordenadas fijas en zona Valdivia
- La zona Valdivia existe en coordenadas alejadas (X=50000, Z=50000) del mundo principal
- **Requiere**: que ambos mundos compartan el mismo archivo de mundo (más complejo)

---

### FASE 4 — Enriquecimiento manual con WorldEdit (Semana 4-6)

Una vez el terreno base esté en el servidor, trabajar con WorldEdit para:

#### 4.1 Hitos históricos y culturales
- [ ] **Mercado Fluvial** — estructura con puestos de venta de artesanías y mariscos
- [ ] **Catedral de Valdivia** — fachada representativa en la Plaza de la República
- [ ] **Muelle Schuster** — estructura sobre el río con locomoción fluvial
- [ ] **Torreón del Barro / Los Canelos** — fuertes históricos coloniales
- [ ] **Cervecería Kunstmann** — edificio emblemático en Isla Teja
- [ ] **Campus UACh** — Universidad Austral de Chile en Isla Teja

#### 4.2 Geografía especial
- [ ] **Humedal Río Cruces** — zona con vegetación acuática, totoras, flamencos
- [ ] **Calle-Calle y río Valdivia** — agua fluida con corriente visual
- [ ] **Isla Teja** — correctamente separada por el río
- [ ] **Laguna Los Cóndores** — zona sur de la ciudad
- [ ] **Colinas del sector Jardín** — topografía característica

#### 4.3 Detalles urbanos
- [ ] **Calle General Lagos** — casonas patrimoniales estilo alemán
- [ ] **Mercado central** — puestos interiores
- [ ] **Costanera** — paseo peatonal junto al río con bancas y faroles
- [ ] **Puentes** — Puente Pedro de Valdivia, Puente Calle-Calle

---

### FASE 5 — Mods específicos de Valdivia (Semana 6-8)

#### 5.1 Mod `valdivia_fauna`
Criaturas características de Valdivia/Los Ríos:
- Coipo (nutria de río) — animal nadador en los humedales
- Flamenco austral — en Río Cruces
- Pudú — en zonas boscosas
- Chuncho (lechuza) — nocturno

#### 5.2 Mod `valdivia_flora`
Vegetación característica del sur de Chile:
- Coigüe (árbol nativo)
- Arrayán
- Totora (junco de humedal)
- Nalca (planta gigante)
- Murta (arbusto frutal)

#### 5.3 Mod `valdivia_culture`
Elementos culturales interactivos:
- Quioscos con información sobre la historia de Valdivia (textos educativos)
- NPCs con diálogos sobre el terremoto de 1960 y la reconstrucción
- Signos con nombres de calles reales
- Señalética de humedales protegidos

---

### FASE 6 — Portal de acceso desde Wetlands (Semana 8)

```lua
-- server/mods/valdivia_portal/init.lua
-- Bloque portal que teletransporta al spawn de Valdivia

local VALDIVIA_SPAWN = {x=0, y=64, z=0}  -- coordenadas en mundo Valdivia
-- (si es mismo mundo: x=50000, y=64, z=50000)

minetest.register_node("valdivia_portal:gate", {
    description = "Portal a Valdivia 🌊",
    tiles = {"valdivia_portal_gate.png"},
    groups = {cracky=1},
    on_walk_over = function(pos, node, player)
        -- Efecto de partículas
        minetest.add_particlespawner({
            amount = 20, time = 1,
            pos = pos,
            vel = {min={x=-1,y=1,z=-1}, max={x=1,y=2,z=1}},
            texture = "valdivia_portal_particle.png"
        })
        -- Mensaje de bienvenida
        minetest.chat_send_player(player:get_player_name(), 
            "🌊 Bienvenido/a a Valdivia, la ciudad de los ríos...")
        -- Teletransporte
        player:set_pos(VALDIVIA_SPAWN)
    end
})
```

---

## 📊 Datos técnicos del proyecto

| Aspecto | Detalle |
|---------|---------|
| Área total | ~100 km² (~10km × 10km) |
| Escala en bloques | 1 bloque = 1 metro (1:1) |
| Dimensión estimada | 10.000 × 10.000 bloques |
| Tamaño mundo generado | ~3-8 GB en disco |
| RAM mínima para generar | 8 GB (VPS tiene 24 GB ✅) |
| Tiempo generación Arnis | ~30-60 min |
| Tiempo conversión mc2mt | ~1-2 horas |
| Tiempo enriquecimiento manual | Semanas/meses (proceso creativo) |

---

## ⚠️ Riesgos y mitigaciones

| Riesgo | Probabilidad | Mitigación |
|--------|-------------|------------|
| mc2mt incompatible con VoxeLibre actual | Media | Escribir script Python propio de conversión con mapeo personalizado |
| Arnis genera terreno incorrecto para Valdivia | Baja | Verificar con vista previa antes de convertir |
| Tamaño del mundo excede disco del VPS | Baja | VPS tiene 193 GB disponibles, solo usa 32 GB actualmente |
| Conversión pierde edificios OSM | Media | Arnis genera edificios básicos; enriquecer con WorldEdit |
| Impacto en servidor Wetlands principal | Ninguno | Mundos completamente separados |

---

## 🚀 Próximos pasos inmediatos

1. **[ ] Decidir integración:** ¿Mundo separado (puerto 30001) o portal en mismo mundo?
2. **[ ] Instalar Rust + compilar Arnis** en el VPS
3. **[ ] Test con área pequeña** (solo centro de Valdivia, bbox reducido) para validar el pipeline completo antes de generar toda la ciudad
4. **[ ] Evaluar mc2mt** con el resultado del test → si no funciona, escribir conversor propio en Python
5. **[ ] Definir spawn point** de Valdivia → sugerencia: Mercado Fluvial o Plaza de la República

---

## 📚 Referencias y recursos

- **Arnis:** https://github.com/louis-e/arnis
- **mc2mt (conversor):** https://github.com/dgm3333/mc2mt
- **OpenStreetMap Valdivia:** https://www.openstreetmap.org/#map=13/-39.8282/-73.2335
- **SRTM elevación Chile:** https://srtm.csi.cgiar.org/
- **WorldEdit Luanti:** https://content.luanti.org/packages/sfan5/worldedit/
- **VoxeLibre nodos:** https://github.com/VoxeLibre/VoxeLibre/tree/master/mods/CORE/mcl_core
- **Artículo Arnis en AWS Blog:** https://aws.amazon.com/blogs/publicsector/building-realistic-minecraft-worlds-with-open-data-on-aws-how-arnis-uses-elevation-datasets-at-scale/

---

*Documento creado por Claw 🦾 — Marzo 2026*
