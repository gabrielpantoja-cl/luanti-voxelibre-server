# 🏟️ Mod: Arena PVP - Zona de Combate Designada

**Versión**: 1.0.0 (Diseño)
**Estado**: 📝 Documentación - Pendiente de implementación
**Autor**: Gabriel Pantoja (gabo)
**Licencia**: MIT

## Descripción General

Mod personalizado para el servidor Wetlands que **permite PvP en zonas específicas** mientras mantiene el resto del servidor como **zona pacífica**. Ideal para eventos de combate, mini-juegos, y competencias sin comprometer la filosofía compasiva del servidor.

### Filosofía del Mod

- ✅ **Consensual**: Los jugadores eligen entrar a la arena
- ✅ **Delimitada**: PvP solo en áreas específicas
- ✅ **Educativa**: Enseña sobre zonas seguras y respeto
- ✅ **Reversible**: Salir de la arena = volver a zona pacífica

## Características Principales

### 1. Sistema de Zonas

**Detección automática de entrada/salida**:
- Jugador entra a coordenadas definidas → PvP activado
- Jugador sale de la arena → PvP desactivado
- Mensajes claros en pantalla

**Múltiples arenas soportadas**:
- Arena Principal (spawn)
- Arena del Bosque Encantado
- Arena de Halloween (evento especial)
- Hasta 10 arenas configurables

### 2. Mensajes y Avisos

**Al entrar a la arena**:
```
╔═══════════════════════════════════╗
║  ⚔️  ENTRASTE A LA ARENA PVP  ⚔️   ║
║                                   ║
║  • El combate está habilitado     ║
║  • Sal cuando quieras para paz    ║
║  • /salir_arena para teleport     ║
╚═══════════════════════════════════╝
```

**Al salir de la arena**:
```
✅ Has salido de la Arena PVP
🌱 Estás de vuelta en zona pacífica
```

### 3. Comandos del Jugador

| Comando | Descripción | Privilegio |
|---------|-------------|------------|
| `/arena_lista` | Muestra todas las arenas disponibles | Ninguno |
| `/arena_info` | Info de la arena donde estás | Ninguno |
| `/salir_arena` | Teleport fuera de la arena | Ninguno |
| `/arena_stats` | Tus estadísticas de combate | Ninguno |

### 4. Comandos de Administrador

| Comando | Descripción | Privilegio |
|---------|-------------|------------|
| `/crear_arena <nombre> <radio>` | Crea nueva arena en posición actual | `arena_admin` |
| `/eliminar_arena <nombre>` | Elimina una arena | `arena_admin` |
| `/arena_tp <nombre>` | Teleporta a una arena | `arena_admin` |
| `/arena_reset` | Reinicia todas las arenas | `server` |

## Implementación Técnica

### Estructura de Archivos

```
server/mods/pvp_arena/
├── mod.conf                 # Metadatos del mod
├── init.lua                 # Lógica principal
├── arena_manager.lua        # Gestión de zonas
├── player_tracker.lua       # Seguimiento de jugadores
├── commands.lua             # Comandos del chat
├── config.lua               # Configuración
├── locale/
│   └── es.txt              # Traducciones en español
└── textures/
    ├── arena_marker.png     # Marcador visual de límites
    └── pvp_icon.png         # Icono HUD
```

### `mod.conf`

```ini
name = pvp_arena
title = PVP Arena - Zonas de Combate
description = Sistema de zonas PVP delimitadas para servidor compasivo
depends = mcl_core, mcl_player
optional_depends = areas, worldedit
author = gabo
version = 1.0.0
```

### `init.lua` - Lógica Principal

```lua
-- PVP Arena Mod v1.0.0
-- Permite PvP en zonas específicas del servidor

pvp_arena = {}
pvp_arena.arenas = {}
pvp_arena.players_in_arena = {}

-- Cargar configuración
dofile(minetest.get_modpath("pvp_arena") .. "/config.lua")
dofile(minetest.get_modpath("pvp_arena") .. "/arena_manager.lua")
dofile(minetest.get_modpath("pvp_arena") .. "/player_tracker.lua")
dofile(minetest.get_modpath("pvp_arena") .. "/commands.lua")

-- Cargar arenas desde archivo de configuración
function pvp_arena.load_arenas()
    local file = io.open(minetest.get_worldpath() .. "/pvp_arenas.txt", "r")
    if not file then
        minetest.log("info", "[PVP Arena] No arenas file found, creating default arena")
        pvp_arena.create_default_arena()
        return
    end

    for line in file:lines() do
        local arena = minetest.deserialize(line)
        if arena then
            table.insert(pvp_arena.arenas, arena)
        end
    end
    file:close()

    minetest.log("action", "[PVP Arena] Loaded " .. #pvp_arena.arenas .. " arenas")
end

-- Crear arena por defecto
function pvp_arena.create_default_arena()
    local default_arena = {
        name = "Arena Principal",
        center = {x = 100, y = 20, z = 100},
        radius = 50,
        enabled = true,
        created_by = "gabo",
        created_at = os.time()
    }
    table.insert(pvp_arena.arenas, default_arena)
    pvp_arena.save_arenas()
end

-- Guardar arenas a archivo
function pvp_arena.save_arenas()
    local file = io.open(minetest.get_worldpath() .. "/pvp_arenas.txt", "w")
    for _, arena in ipairs(pvp_arena.arenas) do
        file:write(minetest.serialize(arena) .. "\n")
    end
    file:close()
end

-- Verificar si un jugador está en una arena
function pvp_arena.is_player_in_arena(player_name)
    local player = minetest.get_player_by_name(player_name)
    if not player then return false, nil end

    local pos = player:get_pos()

    for _, arena in ipairs(pvp_arena.arenas) do
        if arena.enabled then
            local distance = vector.distance(pos, arena.center)
            if distance <= arena.radius then
                return true, arena
            end
        end
    end

    return false, nil
end

-- Habilitar/deshabilitar PvP para un jugador
function pvp_arena.set_pvp(player_name, enabled)
    local player = minetest.get_player_by_name(player_name)
    if not player then return end

    -- VoxeLibre: Modificar la capacidad de recibir daño de otros jugadores
    local meta = player:get_meta()
    meta:set_int("pvp_enabled", enabled and 1 or 0)

    minetest.log("action", "[PVP Arena] PVP " .. (enabled and "enabled" or "disabled") .. " for " .. player_name)
end

-- GlobalStep: Verificar jugadores cada segundo
local timer = 0
minetest.register_globalstep(function(dtime)
    timer = timer + dtime
    if timer < 1.0 then return end
    timer = 0

    for _, player in ipairs(minetest.get_connected_players()) do
        local name = player:get_player_name()
        local in_arena, arena = pvp_arena.is_player_in_arena(name)
        local was_in_arena = pvp_arena.players_in_arena[name]

        if in_arena and not was_in_arena then
            -- Jugador ENTRÓ a la arena
            pvp_arena.players_in_arena[name] = arena.name
            pvp_arena.set_pvp(name, true)
            pvp_arena.show_enter_message(player, arena)

        elseif not in_arena and was_in_arena then
            -- Jugador SALIÓ de la arena
            pvp_arena.players_in_arena[name] = nil
            pvp_arena.set_pvp(name, false)
            pvp_arena.show_exit_message(player)
        end
    end
end)

-- Mensajes visuales
function pvp_arena.show_enter_message(player, arena)
    minetest.chat_send_player(player:get_player_name(),
        minetest.colorize("#FF6B6B", "╔═══════════════════════════════════╗"))
    minetest.chat_send_player(player:get_player_name(),
        minetest.colorize("#FF6B6B", "║  ⚔️  ENTRASTE A " .. arena.name:upper() .. "  ⚔️   ║"))
    minetest.chat_send_player(player:get_player_name(),
        minetest.colorize("#FF6B6B", "║                                   ║"))
    minetest.chat_send_player(player:get_player_name(),
        minetest.colorize("#FFEB3B", "║  • El combate está habilitado     ║"))
    minetest.chat_send_player(player:get_player_name(),
        minetest.colorize("#FFEB3B", "║  • Sal cuando quieras para paz    ║"))
    minetest.chat_send_player(player:get_player_name(),
        minetest.colorize("#FFEB3B", "║  • /salir_arena para teleport     ║"))
    minetest.chat_send_player(player:get_player_name(),
        minetest.colorize("#FF6B6B", "╚═══════════════════════════════════╝"))
end

function pvp_arena.show_exit_message(player)
    minetest.chat_send_player(player:get_player_name(),
        minetest.colorize("#4CAF50", "✅ Has salido de la Arena PVP"))
    minetest.chat_send_player(player:get_player_name(),
        minetest.colorize("#66BB6A", "🌱 Estás de vuelta en zona pacífica"))
end

-- Inicialización
minetest.register_on_mods_loaded(function()
    pvp_arena.load_arenas()
    minetest.log("action", "[PVP Arena] Mod loaded successfully")
end)

-- Limpiar estado al desconectar
minetest.register_on_leaveplayer(function(player)
    local name = player:get_player_name()
    pvp_arena.players_in_arena[name] = nil
end)
```

### `commands.lua` - Comandos del Chat

```lua
-- Comandos para jugadores

-- /arena_lista
minetest.register_chatcommand("arena_lista", {
    description = "Muestra todas las arenas PVP disponibles",
    func = function(name)
        if #pvp_arena.arenas == 0 then
            return true, "No hay arenas disponibles actualmente."
        end

        local msg = "🏟️  Arenas PVP Disponibles:\n"
        for i, arena in ipairs(pvp_arena.arenas) do
            local status = arena.enabled and "✅" or "❌"
            msg = msg .. string.format("%d. %s %s (Radio: %dm)\n",
                i, status, arena.name, arena.radius)
        end
        return true, msg
    end
})

-- /salir_arena
minetest.register_chatcommand("salir_arena", {
    description = "Teleporta fuera de la arena PVP",
    func = function(name)
        if not pvp_arena.players_in_arena[name] then
            return false, "No estás en una arena PVP."
        end

        local player = minetest.get_player_by_name(name)
        if not player then return false end

        -- Teleportar al spawn del servidor
        local spawn = minetest.setting_get_pos("static_spawnpoint") or {x=0, y=15, z=0}
        player:set_pos(spawn)

        return true, "✅ Has salido de la arena. Bienvenido a zona pacífica."
    end
})

-- /arena_info
minetest.register_chatcommand("arena_info", {
    description = "Información de la arena donde estás",
    func = function(name)
        local in_arena, arena = pvp_arena.is_player_in_arena(name)

        if not in_arena then
            return false, "No estás en ninguna arena PVP."
        end

        local msg = string.format(
            "🏟️  Arena: %s\n" ..
            "📍 Centro: %s\n" ..
            "📏 Radio: %dm\n" ..
            "👤 Creada por: %s",
            arena.name,
            minetest.pos_to_string(arena.center),
            arena.radius,
            arena.created_by
        )
        return true, msg
    end
})

-- Comandos para administradores

-- /crear_arena
minetest.register_chatcommand("crear_arena", {
    params = "<nombre> <radio>",
    description = "Crea una nueva arena PVP en tu posición actual",
    privs = {arena_admin = true},
    func = function(name, params)
        local arena_name, radius_str = params:match("^(%S+)%s+(%d+)$")

        if not arena_name or not radius_str then
            return false, "Uso: /crear_arena <nombre> <radio>"
        end

        local radius = tonumber(radius_str)
        if radius < 10 or radius > 200 then
            return false, "El radio debe estar entre 10 y 200 metros."
        end

        local player = minetest.get_player_by_name(name)
        if not player then return false end

        local new_arena = {
            name = arena_name,
            center = player:get_pos(),
            radius = radius,
            enabled = true,
            created_by = name,
            created_at = os.time()
        }

        table.insert(pvp_arena.arenas, new_arena)
        pvp_arena.save_arenas()

        return true, string.format("✅ Arena '%s' creada con radio de %dm", arena_name, radius)
    end
})

-- /eliminar_arena
minetest.register_chatcommand("eliminar_arena", {
    params = "<nombre>",
    description = "Elimina una arena PVP",
    privs = {arena_admin = true},
    func = function(name, arena_name)
        for i, arena in ipairs(pvp_arena.arenas) do
            if arena.name == arena_name then
                table.remove(pvp_arena.arenas, i)
                pvp_arena.save_arenas()
                return true, "✅ Arena '" .. arena_name .. "' eliminada"
            end
        end
        return false, "Arena no encontrada: " .. arena_name
    end
})
```

## Configuración

### Archivo de Arenas: `pvp_arenas.txt`

Ubicación: `server/worlds/world/pvp_arenas.txt`

```lua
return {name = "Arena Principal", center = {x=100, y=20, z=100}, radius=50, enabled=true, created_by="gabo", created_at=1728739200}
return {name = "Arena del Bosque", center = {x=-200, y=25, z=300}, radius=30, enabled=true, created_by="gabo", created_at=1728739300}
```

### Privilegios Necesarios

Agregar a `server/config/luanti.conf`:

```ini
# Privilegio para administrar arenas PVP
default_privs = interact,shout,creative,arena_admin
```

## Uso del Mod

### Para Jugadores

1. **Encontrar arena**: Usar `/arena_lista` para ver arenas disponibles
2. **Entrar**: Caminar hacia la arena (mensaje automático aparecerá)
3. **Combatir**: PvP habilitado solo dentro de la arena
4. **Salir**: Caminar fuera O usar `/salir_arena`

### Para Administradores

#### Crear una Arena Nueva

```lua
-- 1. Posicionarte en el centro donde quieres la arena
-- 2. Ejecutar comando
/crear_arena Arena_Halloween 40

-- Esto crea arena con 40m de radio desde tu posición
```

#### Listar Arenas Existentes

```lua
/arena_lista

-- Salida:
-- 🏟️  Arenas PVP Disponibles:
-- 1. ✅ Arena Principal (Radio: 50m)
-- 2. ✅ Arena del Bosque (Radio: 30m)
```

#### Eliminar Arena

```lua
/eliminar_arena Arena_del_Bosque
```

## Construcción de la Arena

### Arena Principal Recomendada

**Ubicación sugerida**: x=100, y=20, z=100 (cerca del spawn)
**Radio**: 50 metros
**Diseño**:

```
┌──────────────────────────────────────┐
│                                      │
│   🏛️  Gradas de espectadores         │
│                                      │
│   ⚔️   Arena central (30x30)         │
│                                      │
│   🛡️  Cofres con equipo PVP          │
│   - Espadas de hierro                │
│   - Arcos y flechas                  │
│   - Armaduras                        │
│   - Manzanas doradas                 │
│                                      │
│   🚪 4 entradas (Norte/Sur/Este/Oeste)│
│                                      │
└──────────────────────────────────────┘
```

**Materiales sugeridos**:
- Piso: Adoquines (`mcl_core:stone`)
- Paredes: Ladrillos de piedra (`mcl_core:stonebrick`)
- Iluminación: Antorchas (`mcl_torches:torch`)
- Decoración: Banners de equipo

### Marcadores Visuales

Usar bloques de colores en los límites de la arena:

```lua
-- Colocar bloques de lana roja en el perímetro cada 10 bloques
-- Altura Y+2 para visibilidad
```

## Eventos y Mini-Juegos

### Torneo Semanal

**Formato**: 1v1 eliminación simple
**Premio**: Diamantes o items especiales
**Reglas**:
- 3 rounds de 2 minutos cada uno
- Sin regeneración entre rounds
- Equipo estándar proporcionado

### Capture the Flag

Con el mod `areas`, se puede crear dos zonas:

```lua
-- Zona Roja: x=80-120, z=80-90
-- Zona Azul: x=80-120, z=110-120
-- Bandera: mcl_banners:banner_item_red / blue
```

## Integración con Otros Mods

### Compatibilidad

| Mod | Compatible | Notas |
|-----|------------|-------|
| `areas` | ✅ Sí | Se pueden combinar protecciones |
| `worldedit` | ✅ Sí | Facilita construcción de arenas |
| `mcl_armor` | ✅ Sí | Armaduras funcionan normalmente |
| `mcl_enchanting` | ✅ Sí | Encantamientos permitidos |
| `mcl_shields` | ✅ Sí | Escudos funcionan |

### Hooks para Extensiones

```lua
-- Otros mods pueden registrar callbacks
pvp_arena.register_on_enter_arena(function(player, arena)
    -- Tu código aquí
end)

pvp_arena.register_on_exit_arena(function(player)
    -- Tu código aquí
end)
```

## Testing y Validación

### Test Checklist

- [ ] Jugador entra a arena → PvP habilitado
- [ ] Jugador sale de arena → PvP deshabilitado
- [ ] Mensajes aparecen correctamente
- [ ] `/salir_arena` funciona
- [ ] `/crear_arena` funciona con privilegios
- [ ] Arenas se guardan y cargan correctamente
- [ ] Múltiples jugadores en arena simultáneamente
- [ ] Combate funciona dentro de arena
- [ ] Combate NO funciona fuera de arena

### Comandos de Debug

```lua
-- Ver estado de jugadores en arenas
/lua minetest.chat_send_all(dump(pvp_arena.players_in_arena))

-- Forzar recarga de arenas
/lua pvp_arena.load_arenas()
```

## FAQ - Preguntas Frecuentes

**P: ¿Puedo tener varias arenas?**
R: Sí, hasta 10 arenas simultáneamente.

**P: ¿Las arenas funcionan en modo creativo?**
R: Sí, aunque el daño no reducirá vida infinita del creativo.

**P: ¿Cómo deshabilito temporalmente una arena?**
R: Editar `pvp_arenas.txt` y cambiar `enabled=false`.

**P: ¿Se puede usar con protecciones de `areas`?**
R: Sí, son compatibles. La arena controla PvP, `areas` controla construcción.

**P: ¿Qué pasa si un jugador se desconecta dentro de la arena?**
R: Al reconectar, el sistema detecta automáticamente su posición.

## Roadmap - Futuras Mejoras

### v1.1.0 (Próxima versión)
- [ ] Sistema de estadísticas (kills, deaths, K/D ratio)
- [ ] Leaderboard persistente
- [ ] Zonas de espectadores (no PvP pero dentro del área)

### v1.2.0
- [ ] Torneos automatizados con brackets
- [ ] Sistema de equipos (Team PvP)
- [ ] Rewards automáticos por victorias

### v2.0.0
- [ ] Arenas con diferentes reglas (sin armas, solo mágicas, etc.)
- [ ] Efectos visuales en los límites de arena
- [ ] Integración con sistema de economía (cobrar entrada)

## Contribuciones

¿Quieres mejorar este mod? Pull requests bienvenidos:

1. Fork del repositorio
2. Crear branch: `git checkout -b feature/nueva-caracteristica`
3. Commit: `git commit -m "Agregada nueva característica"`
4. Push: `git push origin feature/nueva-caracteristica`
5. Crear Pull Request

## Licencia

MIT License - Libre para usar, modificar y distribuir

## Créditos

- **Desarrollador**: Gabriel Pantoja (gabo)
- **Servidor**: Wetlands 🌱 Luanti/VoxeLibre
- **Inspiración**: Necesidad de PvP consensual en servidor compasivo
- **Testing**: gabo, pepelomo

---

**Documentado**: 2025-10-12
**Versión del documento**: 1.0.0