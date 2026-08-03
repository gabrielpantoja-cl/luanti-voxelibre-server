# `wetlands_mineclonia_trampas` — Trampa amistosa para Mineclonia (30004)

> **Status (2026-08-03):** ✅ habilitado y verificado en juego por `gabo`.
> Activado en `server/config/luanti-mineclonia.conf` +
> `server/worlds/mineclonia/world.mt` (vía `load_mod_wetlands_mineclonia_trampas = true`).
> Único mod custom habilitado en Mineclonia — todos los demás mundos (Wetlands, Valdivia, GAELSIN, CTF) NO lo cargan.

## Qué hace

Registra un único nodo:

```
wetlands_mineclonia_trampas:secret_heart
```

que **se ve, suena y se comporta idénticamente a `mcl_core:stone`** (mismas texturas `default_stone.png`, mismo drop `mcl_core:cobble`, mismo sonido de piedra al picar/colocar). Cuando un jugador pisa el bloque:

1. **Mensaje en chat** del jugador afectado, color rosa fuerte (#FF69B4):
   ```
   ME ENCANTA JUGAR CONTIGO ❤️
   ```
2. **Lluvia de 30 partículas de corazón** (textura `wetlands_mineclonia_trampas_heart.png`) en la posición del bloque.
3. **Sin daño, sin knockback, sin romper nada** — solo un guiño visual.

Cooldown per-player de **5 segundos** (no se re-dispara si el jugador se queda parado arriba).

## Por qué existe este mod (en vez de usar vanilla Minecraft)

Minecraft vanilla permite armar trampas con la receta clásica:

```
pressure plate  →  redstone  →  TNT  →  BOOM 💥
```

Mineclonia tiene todos los componentes, pero la config `luanti-mineclonia.conf` los desactiva explícitamente para mantener el "creative sin daño":

| Setting | Valor | Efecto en la trampa clásica |
|---|---|---|
| `creative_mode` | `true` | Jugadores en creativo infinito (ok) |
| `enable_damage` | `false` | TNT no hace daño (ok — visual todavía funciona) |
| `enable_pvp` | `false` | — |
| `enable_fire` | **`false`** | **Redstone + presión + ignición no funcionan** 🔥 |
| `enable_tnt` | **`false`** | **TNT no detona** 💣 |
| `mobs_spawn` | `false` | Sin mobs que pisen la presión |

→ **El patrón vanilla no funciona en Mineclonia sin tocar la config.**

Dos opciones:

1. **Flipes los flags** (`enable_fire=true`, `enable_tnt=true`) — pero rompe la Filosofía "creative sin daño" y abre la puerta a grief con fuego.
2. **Mod trampa custom** (esta solución) — kid-friendly, sin daño, controlable, con efecto visible.

Elegimos la 2.

## Implementación técnica

### Pitfall: `on_stand` ya no existe en Luanti 5.14+

El callback de nodo `on_stand(pos, node, stander)` (que las pressure plates vanilla usaban) **fue removido del engine** en Luanti 5.14+. Ahora las pressure plates vanilla usan polling:

```lua
-- Patrón moderno (Luanti 5.14+):
core.register_globalstep(function(dtime)
    for _, player in ipairs(core.get_connected_players()) do
        local pos = player:get_pos()
        local block_under = {x = floor(pos.x), y = floor(pos.y - 0.5), z = floor(pos.z)}
        if registered_traps[block_under] then
            trigger_effect(player, block_under)
        end
    end
end)
```

Este mod usa exactamente el mismo patrón.

### Archivos

```
server/mods/wetlands_mineclonia_trampas/
├── mod.conf                                  # name + optional_depends
├── init.lua                                  # lógica completa (~60 líneas)
└── textures/
    └── wetlands_mineclonia_trampas_heart.png # partícula corazón (189 bytes,
                                              # copiada de mcl_base_textures)
```

### `mod.conf`

```ini
name = wetlands_mineclonia_trampas
description = Trampa amistosa - muestra "ME ENCANTA JUGAR CONTIGO" al pisar
optional_depends = mcl_core, mcl_sounds
```

`optional_depends` (no `depends`) porque:

- **`mcl_core`** provee el sonido `node_sound_stone_defaults()` y la textura `default_stone.png`. Si por algún motivo no existe (versión de Mineclonia distinta), el bloque registra igual pero aparece como cubo morado/negro.
- **`mcl_sounds`** provee la función `node_sound_stone_defaults()` para los sonidos de picar/colocar/caminar. Si no existe, el bloque se registra sin sonidos (gracioso pero aceptable).

(Ver `AGENTS.md` → "VoxeLibre critical pitfalls" → "Never depend on `mcl_sounds` — it doesn't exist in this VoxeLibre version" para el rationale de `optional_depends` vs `depends`. Esta regla aplica en VoxeLibre pero Mineclonia sí tiene `mcl_sounds`, así que usamos `optional_depends` por portabilidad.)

### `init.lua` — flujo

```lua
-- 1. Tabla de posiciones de trampas activas (en memoria)
local trap_positions = {}

-- 2. Tabla de cooldowns per-player (en memoria)
local cooldowns = {}

-- 3. Registra el nodo. Se ve como piedra.
core.register_node(":" .. modname .. ":secret_heart", {
    tiles = {"default_stone.png"},
    groups = {pickaxey = 1, stone = 1, handy = 1},
    drop = "mcl_core:cobble",            -- drop = cobble, no el bloque trampa
    sounds = mcl_sounds.node_sound_stone_defaults(),
    on_construct = add_to_trap_positions,
    on_destruct  = remove_from_trap_positions,
})

-- 4. ABM rescanea chunks cada 5s para re-poblar trap_positions
--    (necesario porque on_construct no se llama cuando un chunk
--     se CARGA del disco tras un restart, solo cuando se COLOCA
--     un bloque nuevo en runtime)
core.register_abm({...interval = 5, action = add_to_trap_positions})

-- 5. Globalstep polling cada 0.5s
core.register_globalstep(function(dtime)
    timer += dtime
    if timer < 0.5 then return end
    timer = 0
    for _, player in pairs(get_connected_players()) do
        -- check block 1 debajo del jugador
        -- check trap_positions[block]
        -- check cooldown
        -- trigger chat + partículas
    end
end)

-- 6. Limpia cooldown al desconectarse
core.register_on_leaveplayer(function(player)
    cooldowns[player:get_player_name()] = nil
end)
```

### Por qué polling y no ABM

ABM (Active Block Modifier) corre cada N segundos **por bloque**, no por jugador. Si usáramos ABM en el bloque trampa, se chequearía `core.get_connected_players()` desde el callback del bloque, lo cual es válido pero **consume CPU proporcional al número de trampas × jugadores**. Con polling centralizado cada 0.5s, el costo es constante: `num_jugadores × num_bloques_por_chat` = O(players) por step.

Con 5 jugadores conectados, es 10 lookups por segundo. Trivial.

### Latencia y precisión

- **Latencia de detección**: hasta 0.5s (período de polling). Un jugador que pisa el bloque espera <0.5s para ver el mensaje. Imperceptible.
- **Precisión de posición**: redondeo `floor(pos.x + 0.5)` para X y Z, `floor(pos.y - 0.5)` para Y. Esto matchea el bloque que está justo debajo de los pies del jugador, incluso si está saltando.
- **Falsos positivos**: si el jugador está parado exactamente en el borde entre dos trampas, podría activarse la de abajo. No es un problema real (el efecto es idéntico).

## Cómo usarlo en juego

### Opción 1: inventario creativo

1. Abrí inventario creativo (`/giveme` no es necesario si estás en creativo).
2. Buscá "Trampa" o "Secreto" o "Bloque Secreto".
3. Seleccioná el item.
4. Colocá como cualquier bloque.

### Opción 2: comando de admin

```
/giveme wetlands_mineclonia_trampas:secret_heart
```

### Lugares donde queda bien

- **Entrada de una base**: en el primer escalón. Cuando un amigo entre, recibe el mensaje.
- **Debajo de un item decorativo** (cuadro, cartel, etc.) que tape la stone — efecto sorpresa máximo.
- **En una escalera**: a mitad de camino.
- **Debajo de una cama**: cuando un amigo duerma y se levante, primer paso = mensaje.
- **En el spawn / alrededor de tu casa**: "trampas de bienvenida" para nuevos jugadores.

### Para esconderse mejor

El bloque es **idéntico a `mcl_core:stone`**, así que:

- Mezclalo entre piedras naturales (cerca de un bioma rocoso).
- Tápalo con un cuadro o un cartel — solo el jugador que lo pise descubrirá el mensaje.
- Ponelo como piso debajo de una alfombra decorativa (los jugadores caminan encima, no lo ven).

### Comportamiento esperado al picarlo

- Se pica como stone normal (drop `mcl_core:cobble`, no el bloque trampa).
- Esto **previene farmear infinitas trampas** (no se puede picar uno y obtener muchos).
- Si querés recolectarlo, picá con Silk Touch → drop = el bloque trampa. (Pero Mineclonia no tiene Silk Touch en el game base; si lo necesitás, decime y lo agrego como otra variante.)

## Cómo agregar una nueva variante del mod

Si querés más mensajes / efectos (ej: "FELIZ CUMPLEAÑOS 🎂" para tu amigo), podés duplicar el bloque:

```lua
-- En init.lua, agregar:
core.register_node(":" .. modname .. ":secret_birthday", {
    -- copiar definición de :secret_heart
    tiles = {"default_stone.png^default_stone.png^[lowpart:50:birthday_cake.png"},
    -- ...
    -- agregar a trap_positions y al polling como otra categoría
})
```

Alternativa más simple: **cambiar el mensaje hardcodeado en `init.lua`** y rebuild:

```lua
local MESSAGE = "FELIZ CUMPLEAÑOS 🎂"
```

…y commit + push + git pull en VPS + restart container. 5 minutos total.

## Permisos y seguridad

- **No requiere privilegios especiales**: cualquier jugador con `interact` (privilegio default en Mineclonia) puede colocar el bloque.
- **No registra comandos de admin**: no hay `/trampa`, `/give_trap`, etc. Si querés un comando para repartir, decime.
- **No escribe en mod_storage**: el mod no persiste nada en disco (las trampas mismas persisten porque son nodos en `map.sqlite`).
- **No envía mensajes broadcast**: el chat es solo al jugador que pisó. Otros jugadores no se enteran.
- **Sin sonidos fuertes**: las partículas son silenciosas. No hay un "BOOM" ni sonido de alarma.

## Logs y troubleshooting

### Verificar que el mod está cargado

1. Cliente Luanti: `/giveme wetlands_mineclonia_trampas:secret_heart`
   - Si te da un item llamado "Bloque Secreto de Cariño" → mod cargado ✓
   - Si te dice "Unknown item" → mod no cargado (revisar world.mt + restart container)
2. Server logs (VPS):
   ```bash
   ssh gabriel@159.112.138.229 "docker logs --since='30s' luanti-mineclonia-server 2>&1 | tail -20"
   ```
   - Sin errores relacionados a `wetlands_mineclonia_trampas` → ok
   - Errores tipo `Failed to load mod` → revisar `init.lua` syntax + `mod.conf`

### Pitfalls conocidos

- **`on_stand` no funciona**: no intentes registrar el callback como en Minetest clásico. Está removido. Usá `register_globalstep` con polling.
- **`mod_storage` no aparece**: si buscás el mod en `mod_storage/` no lo vas a encontrar. El mod no usa `core.get_mod_storage()`. Eso es OK.
- **`mcl_sounds` opcional**: si el mod está en otro game (no Mineclonia), los sonidos van a faltar pero el bloque igual registra.
- **Color rosa intenso (#FF69B4)**: si querés otro color, cambiá el hex en `core.colorize(...)` en `init.lua`. Colores kid-friendly recomendados: `#FFB6C1` (rosa claro), `#FFD700` (dorado), `#90EE90` (verde claro).

## Desactivar / desinstalar el mod

Si querés volver al estado "Mineclonia sin mods custom":

1. `server/config/luanti-mineclonia.conf` → comentar la línea:
   ```ini
   # load_mod_wetlands_mineclonia_trampas = true
   ```
2. `server/worlds/mineclonia/world.mt` (en VPS, vía `sudo`):
   ```bash
   sudo sed -i '/load_mod_wetlands_mineclonia_trampas/d' /home/gabriel/luanti-voxelibre-server/server/worlds/mineclonia/world.mt
   ```
3. `git push` + `git pull` en VPS + `docker compose restart luanti-mineclonia`.
4. Los bloques `secret_heart` ya colocados se quedan en el mapa como `unknown node` (tienen textura gris/negra hasta que vuelvas a activar el mod). Si querés borrarlos todos de una, contactame — hay un script para eso.

## Cross-references

- `AGENTS.md` → "Multi-world architecture" → tabla de mundos (Mineclonia ahora menciona este mod)
- `AGENTS.md` → "Mineclonia-only mod" (sección destacada)
- `docs/05-MINECLONIA-30004/index.md` → sección "Mods habilitados"
- `docs/05-MINECLONIA-30004/README.md` → tabla de mods
- `docs/05-MINECLONIA-30004/install.md` → si querés re-instalar el game base sin perder el mod
- `server/config/luanti-mineclonia.conf` → `load_mod_wetlands_mineclonia_trampas = true`
- Commit original: `6277308c feat(mineclonia): add wetlands_mineclonia_trampas - friendly trap block`

## Changelog

- **2026-08-03** — Inicial. Mod creado, desplegado en VPS, verificado en juego por `gabo`. Funciona.