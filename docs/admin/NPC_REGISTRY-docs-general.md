# Registro de NPCs - Wetlands Server

> Documento de control para el spawn manual y ubicacion de cada NPC del servidor.
> Cada NPC se coloca manualmente con `/spawn_npc <tipo>` y se documenta aqui.

**Ultima actualizacion**: 2026-02-21
**Version del mod**: wetlands_npcs v2.0.0 (11 NPCs registrados)
**Spawn del mundo**: (0, 15, 0)

---

## Censo Actual: 4 NPCs Activos

| # | NPC | Tipo | Modelo | Coordenadas | Zona | Fecha | Estado |
|---|-----|------|--------|-------------|------|-------|--------|
| 1 | Luke Skywalker | luke | humano (64x32) | Spawn principal | Spawn principal (caminando) | 2026-02-15 | Activo |
| 2 | Sensei Wu | sensei_wu | humano (64x32) | (2, 15, -10) | Spawn principal (estatico) | 2026-02-15 | Activo |
| 3 | Maestro Splinter | splinter | humano (64x32) | (82.2, 16.5, -41.1) | Edificio principal Wetlands (diorita, con ascensor) | 2026-02-15 | Activo |
| 4 | Anakin Skywalker | anakin | humano (64x32) | pendiente | - | - | Por colocar |
| 5 | Baby Yoda | yoda | humano (64x32) | pendiente | - | - | Por colocar |
| 6 | Mandalorian | mandalorian | humano (64x32) | pendiente | - | - | Por colocar |
| 7 | Princesa Leia | leia | humano (64x32) | Cerca de la casa de Gapi | Zona casa de Gapi (caminando) | 2026-02-21 | Activo |
| 8 | Agricultor | farmer | villager (64x64) | pendiente | - | - | Por colocar |
| 9 | Bibliotecario | librarian | villager (64x64) | pendiente | - | - | Por colocar |
| 10 | Maestro | teacher | villager (64x64) | pendiente | - | - | Por colocar |
| 11 | Explorador | explorer | villager (64x64) | pendiente | - | - | Por colocar |

---

## Descripcion de Personajes

### Sabios del Spawn (NPCs semi-estaticos, punto fijo con gestos)

**Sensei Wu** - Maestro ninja de Ninjago. Sabio anciano con tunica dorada y negra. Entreno a Kai, Jay, Zane, Cole y Lloyd. Ofrece sabiduria sobre disciplina, trabajo en equipo y honor.
- **Comportamiento**: idle=60%, wander=15%, social=20%, work=5%
- **Radio maximo**: 4 bloques desde spawn (return threshold: 6)
- **Gestos**: Saludo (swing brazo, 2.5s) y meditacion (sentado, 4s) cuando un jugador se acerca
- **Movimiento**: walk_chance=0 (mcl_mobs desactivado), movimiento controlado 100% por FSM
- **Ubicacion**: Spawn principal (2, 15, -10)

**Maestro Splinter** - Rata sensei de las Tortugas Ninja (TMNT). Maestro de artes marciales que ensena compasion y disciplina. Entreno a Leonardo, Rafael, Donatello y Miguel Angel.
- **Comportamiento**: idle=80%, wander=5%, social=10%, work=5%
- **Radio maximo**: 3 bloques desde spawn (return threshold: 5)
- **Gestos**: Saludo (swing brazo, 2s) y meditacion (sentado, 5s) cuando un jugador se acerca
- **Movimiento**: walk_chance=0, jump=false, controlado 100% por FSM
- **Ubicacion**: Edificio principal Wetlands (82.2, 16.5, -41.1) - Edificio de diorita con ascensor funcionando

### Star Wars (NPCs con modelo humano)

**Luke Skywalker** - Caballero Jedi. Heroe de la Alianza Rebelde. Ensena sobre el lado luminoso de la Fuerza, valentía y esperanza.
- **Comportamiento**: idle=20%, wander=30%, work=35%, social=15%
- **Radio maximo**: 15 bloques (global default)

**Anakin Skywalker** - Piloto legendario y Jedi. El "Elegido" de la profecia. Ensena sobre las consecuencias de las decisiones y la redencion.
- **Comportamiento**: idle=10%, wander=40%, work=35%, social=15%
- **Radio maximo**: 15 bloques (global default)

**Baby Yoda (Grogu)** - Pequeno ser poderoso en la Fuerza. Contemplativo y misterioso. Ensena sobre paciencia y el poder interior.
- **Comportamiento**: idle=40%, wander=20%, work=25%, social=15%
- **Radio maximo**: 15 bloques (global default)

**Mandalorian (Din Djarin)** - Cazarrecompensas con armadura de beskar. Protector de Grogu. Ensena sobre lealtad, honor y proteger a los debiles.
- **Comportamiento**: idle=15%, wander=50%, work=25%, social=10%
- **Radio maximo**: 15 bloques (global default)

**Princesa Leia** - Lider de la Rebelion. Diplomatica y valiente. Ensena sobre liderazgo, diplomacia y luchar por la justicia.
- **Comportamiento**: idle=20%, wander=25%, work=30%, social=25%
- **Radio maximo**: 15 bloques (global default)

### Clasicos (NPCs con modelo villager)

**Agricultor** - Cultiva vegetales y alimentos. Ensena sobre agricultura sostenible y nutricion vegetal.
- **Comportamiento**: idle=20%, wander=30%, work=40%, social=10%

**Bibliotecario** - Guarda y comparte conocimiento. Ensena sobre la importancia de la lectura y la educacion.
- **Comportamiento**: idle=40%, wander=20%, work=30%, social=10%

**Maestro** - Educador de ciencia y compasion. Ensena sobre respeto animal, ciencia y naturaleza.
- **Comportamiento**: idle=25%, wander=25%, work=35%, social=15%

**Explorador** - Viajero y estudioso de biomas. Ensena sobre biodiversidad y conservacion ambiental.
- **Comportamiento**: idle=10%, wander=60%, work=20%, social=10%

---

## Sistema de Comportamiento

### Arquitectura de movimiento (dos sistemas)

Los NPCs tienen **dos sistemas de movimiento** que interactuan:

| Sistema | Parametro | Controla | Respeta radio |
|---------|-----------|----------|---------------|
| **mcl_mobs** (built-in) | `walk_chance` | Movimiento aleatorio nativo del motor | NO |
| **FSM wetlands** (ai_behaviors.lua) | `behavior_weights` | Estados IDLE/WANDER/WORK/SOCIAL/SLEEP | SI |

**Regla critica**: Para NPCs con restriccion de radio, `walk_chance` DEBE ser **0**. Si no, mcl_mobs mueve al NPC sin respetar limites. El movimiento lo controla nuestro FSM via `set_velocity()` directo.

### Home tether (anclaje al spawn)

- Cada NPC recuerda su `home_pos` (donde fue spawneado)
- `max_wander_radius`: radio maximo de movimiento desde home
- `return_home_threshold`: si se aleja mas, fuerza retorno inmediato
- Los estados WORK y SOCIAL tambien verifican que el destino este dentro del radio

### Configuracion por defecto vs overrides

| Parametro | Global | Splinter | Sensei Wu |
|-----------|--------|----------|-----------|
| max_wander_radius | 15 | 3 | 4 |
| return_home_threshold | 20 | 5 | 6 |
| poi_search_radius | 15 | 3 | 4 |
| social_search_radius | 10 | 4 | 6 |
| walk_chance | 33 | 0 | 0 |
| jump | true | false | false |

### Sistema de gestos (idle_gestures)

Cuando un jugador esta a menos de 8 bloques y el NPC esta en IDLE:
- El NPC gira suavemente hacia el jugador (interpolacion 30%/tick)
- Puede ejecutar gestos configurables (con cooldown entre gestos)

| NPC | Gesto | Animacion | Duracion | Cooldown |
|-----|-------|-----------|----------|----------|
| Sensei Wu | Saludo | mine (189-198) | 2.5s | 8s |
| Sensei Wu | Meditacion | sit (81-160) | 4s | 8s |
| Splinter | Saludo | mine (189-198) | 2s | 10s |
| Splinter | Meditacion | sit (81-160) | 5s | 10s |

### Animaciones disponibles (modelo humano mcl_armor_character.b3d)

| Animacion | Frames | Uso |
|-----------|--------|-----|
| stand | 0-79 | Idle, reposo |
| sit | 81-160 | Sentado, meditacion |
| lay | 162-166 | Acostado |
| walk | 168-187 | Caminar |
| mine | 189-198 | Swing brazo (saludo/gesto) |
| walk_mine | 200-219 | Caminar gesticulando |
| run | 440-459 | Correr |

---

## Proceso de Limpieza (2026-02-15)

### Problema
El servidor tenia **75 NPCs duplicados** por spawns manuales sin control previo.

### Acciones realizadas
1. Se agrego comando `/npc_removeall confirm` para eliminacion masiva
2. Se agrego sistema **home tether** para evitar drift de NPCs
3. Primera limpieza: 16 NPCs eliminados (zona de juego activa)
4. Segunda limpieza: 25 NPCs eliminados (zona spawn, ampliando radio)
5. Tercera verificacion: "No hay NPCs de Wetlands en zonas activas"
6. Scan de map.sqlite: 0 NPCs encontrados en 2,257,422 mapblocks

### Zona pendiente de verificar
- **Far West** (-1770, 3, 902): Nueva Ciudad. Puede tener NPCs remanentes.
  - Comando: `/teleport gabo -1770 20 930`
  - Verificar: `/npc_census`
  - Limpiar: `/npc_removeall confirm`

### Total eliminados: ~41 NPCs

---

## Comandos de Referencia

```
/spawn_npc <tipo>        -- Spawnear NPC en tu posicion
/npc_removeall confirm   -- Eliminar TODOS los NPCs
/npc_remove [radio]      -- Eliminar el NPC mas cercano
/npc_census              -- Contar NPCs activos
/npc_cleanup confirm     -- Eliminar duplicados (deja 1 por tipo)
/npc_info                -- Lista de NPCs disponibles
/villager_debug on|off   -- Debug de estados AI
/villager_state          -- Ver estado AI de NPCs cercanos
/villager_config get|set -- Configurar AI en runtime
```

---

## Skins Disponibles (sin usar)

Estos skins estan en `raw_skins/` listos para convertir y registrar como NPCs futuros:

| Skin | Archivo | Descripcion |
|------|---------|-------------|
| Darth Vader | raw_darth_vader.png | Villano Star Wars |
| Obi-Wan Kenobi | raw_obiwan_kenobi.png | Maestro Jedi |
| Ancient Druid | raw_ancient_druid.png | Druida anciano |
| Forest Druid Gerald | raw_forest_druid_gerald.png | Druida del bosque |
| Medieval Merchant Girl | raw_medieval_merchant_girl.png | Mercader medieval |
| Merlin Wizard | raw_merlin_wizard.png | Mago Merlin |
| Ophelia Merchant | raw_ophelia_merchant.png | Mercader Ophelia |

**IMPORTANTE**: Al convertir skins 64x64 a 64x32, usar composite de overlay layers, NO crop simple. Ver script en `tools/generate_textures.py`.
