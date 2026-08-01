-- PVP Arena Mod v1.3.2
-- Permite PvP en zonas específicas con sistema de scoring y respawn estilo LoL
-- Autor: gabo (Gabriel Pantoja)

-- ⚠️ SURVIVAL MODE EXCEPTIONS - Players who should NOT get creative privileges
local survival_players = {
    -- ["pepelomo"] = true,  -- ❌ DESACTIVADO 2026-01-16: Volvió a modo creativo después de 1 día en survival
}

pvp_arena = {}
pvp_arena.arenas = {}
pvp_arena.players_in_arena = {}
pvp_arena.player_creative_status = {}  -- Guardar estado de creative metadata antes de entrar
pvp_arena.player_creative_priv = {}    -- Guardar privilegio creative antes de entrar
pvp_arena.last_attacker = {}           -- Rastrear último atacante de cada jugador
pvp_arena.dead_players = {}            -- Rastrear jugadores muertos en respawn
pvp_arena.respawn_time = 5             -- Tiempo de respawn en segundos (estilo LoL)

-- Cargar sistema de scoring
dofile(minetest.get_modpath("pvp_arena") .. "/scoring.lua")

-- Cargar comandos del chat
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
            minetest.log("action", "[PVP Arena] Loaded arena: " .. arena.name)
        end
    end
    file:close()

    minetest.log("action", "[PVP Arena] Loaded " .. #pvp_arena.arenas .. " arenas")
end

-- Crear arena por defecto en coordenadas especificadas por gabo
function pvp_arena.create_default_arena()
    local default_arena = {
        name = "Arena Principal",
        center = {x = 41, y = 23, z = 232},  -- Coordenadas de la construcción existente
        radius = 25,  -- Radio de 25 bloques = 51x51 área
        respawn_point = {x = 41, y = 23, z = 205},  -- 27 bloques al norte (fuera de zona de combate)
        enabled = true,
        created_by = "gabo",
        created_at = os.time()
    }
    table.insert(pvp_arena.arenas, default_arena)
    pvp_arena.save_arenas()
    minetest.log("action", "[PVP Arena] Created default arena at (41, 23, 232) with respawn at (41, 23, 205)")
end

-- Guardar arenas a archivo
function pvp_arena.save_arenas()
    local file = io.open(minetest.get_worldpath() .. "/pvp_arenas.txt", "w")
    if not file then
        minetest.log("error", "[PVP Arena] Could not save arenas file")
        return
    end

    for _, arena in ipairs(pvp_arena.arenas) do
        file:write(minetest.serialize(arena) .. "\n")
    end
    file:close()
    minetest.log("action", "[PVP Arena] Arenas saved successfully")
end

-- Verificar si un jugador está en una arena
function pvp_arena.is_player_in_arena(player_name)
    local player = minetest.get_player_by_name(player_name)
    if not player then return false, nil end

    local pos = player:get_pos()

    for _, arena in ipairs(pvp_arena.arenas) do
        if arena.enabled then
            -- Verificar distancia horizontal (X y Z)
            local dx = pos.x - arena.center.x
            local dz = pos.z - arena.center.z
            local horizontal_distance = math.sqrt(dx*dx + dz*dz)

            -- Verificar altura (Y) - permitir arena en todas las alturas dentro del radio
            local dy = math.abs(pos.y - arena.center.y)

            -- Si está dentro del radio horizontal y a menos de 50 bloques de altura
            if horizontal_distance <= arena.radius and dy <= 50 then
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

    -- Marcar metadata de PVP habilitado
    local meta = player:get_meta()
    meta:set_int("pvp_enabled", enabled and 1 or 0)

    if enabled then
        -- ENTRAR A ARENA: Guardar estado creative y deshabilitarlo temporalmente
        local meta = player:get_meta()

        -- Guardar estado actual de gamemode (metadata de VoxeLibre)
        local current_gamemode = meta:get_string("gamemode")
        pvp_arena.player_creative_status[player_name] = current_gamemode

        -- Deshabilitar creative mode para este jugador (cambiar a survival)
        meta:set_string("gamemode", "survival")

        -- TAMBIÉN manejar privilegio creative por compatibilidad
        local privs = minetest.get_player_privs(player_name)
        pvp_arena.player_creative_priv[player_name] = privs.creative or false
        if privs.creative then
            privs.creative = nil
            minetest.set_player_privs(player_name, privs)
        end

        minetest.log("action", "[PVP Arena] Disabled creative for " .. player_name .. " (arena entry)")

        -- FORZAR HP: Activar sistema de vida para VoxeLibre
        player:set_hp(20)  -- Vida completa (20 HP = 10 corazones)

        -- Hacer vulnerable al jugador
        local armor_groups = player:get_armor_groups()
        armor_groups.fleshy = 100
        player:set_armor_groups(armor_groups)

        -- Forzar propiedades de daño para VoxeLibre
        player:set_properties({
            hp_max = 20,
            breath_max = 10
        })

    else
        -- SALIR DE ARENA: Restaurar creative mode
        local meta = player:get_meta()

        -- Restaurar gamemode metadata
        local previous_gamemode = pvp_arena.player_creative_status[player_name]
        if previous_gamemode and previous_gamemode == "creative" then
            meta:set_string("gamemode", "creative")
        else
            -- 2026-07-31 fix: antes este else forzaba "creative" para todos, lo
            -- cual era incompatible con el mundo survival. Si previous_gamemode
            -- es "" o "survival", ya esta correcto (la entrada a la arena lo
            -- puso en survival); no lo tocamos.
        end

        -- TAMBIÉN restaurar privilegio creative
        local had_creative_priv = pvp_arena.player_creative_priv[player_name]
        if had_creative_priv or previous_gamemode == "creative" then
            local privs = minetest.get_player_privs(player_name)
            privs.creative = true
            minetest.set_player_privs(player_name, privs)
        end

        pvp_arena.player_creative_status[player_name] = nil
        pvp_arena.player_creative_priv[player_name] = nil

        minetest.log("action", "[PVP Arena] Restored creative to " .. player_name .. " (arena exit)")

        -- Hacer invulnerable al jugador
        local armor_groups = player:get_armor_groups()
        armor_groups.fleshy = 0
        player:set_armor_groups(armor_groups)
    end

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
            pvp_arena.init_player_stats(name)  -- Inicializar stats
            minetest.log("action", "[PVP Arena] " .. name .. " entered " .. arena.name)

        elseif not in_arena and was_in_arena then
            -- Jugador SALIÓ de la arena
            pvp_arena.players_in_arena[name] = nil
            pvp_arena.set_pvp(name, false)
            pvp_arena.show_exit_message(player)
            minetest.log("action", "[PVP Arena] " .. name .. " left arena")
        end
    end
end)

-- Mensajes visuales al entrar
function pvp_arena.show_enter_message(player, arena)
    local name = player:get_player_name()

    minetest.chat_send_player(name,
        minetest.colorize("#FF6B6B", "╔═══════════════════════════════════╗"))
    minetest.chat_send_player(name,
        minetest.colorize("#FF6B6B", "║  ⚔️  ENTRASTE A " .. string.upper(arena.name) .. "  ⚔️   ║"))
    minetest.chat_send_player(name,
        minetest.colorize("#FF6B6B", "║                                   ║"))
    minetest.chat_send_player(name,
        minetest.colorize("#FFEB3B", "║  • El combate está habilitado     ║"))
    minetest.chat_send_player(name,
        minetest.colorize("#FFEB3B", "║  • Sal cuando quieras para paz    ║"))
    minetest.chat_send_player(name,
        minetest.colorize("#FFEB3B", "║  • /salir_arena para teleport     ║"))
    minetest.chat_send_player(name,
        minetest.colorize("#FF6B6B", "╚═══════════════════════════════════╝"))

    -- HUD temporal
    minetest.after(0.5, function()
        if minetest.get_player_by_name(name) then
            minetest.chat_send_player(name,
                minetest.colorize("#FF6B6B", "⚔️ PVP ACTIVADO ⚔️"))
        end
    end)
end

-- Mensajes visuales al salir
function pvp_arena.show_exit_message(player)
    local name = player:get_player_name()

    minetest.chat_send_player(name,
        minetest.colorize("#4CAF50", "✅ Has salido de la Arena PVP"))
    minetest.chat_send_player(name,
        minetest.colorize("#66BB6A", "🌱 Estás de vuelta en zona pacífica"))
end

-- Configurar jugadores al unirse.
-- 2026-07-31 fix: este callback antes otorgaba `creative` y setaba
-- `gamemode = "creative"` a todos los jugadores al unirse fuera de arena.
-- Eso era incompatible con el modo supervivencia dura del mundo Wetlands.
-- El comportamiento PvP (entrar/salir de arena) se mantiene intacto:
--   - Al entrar a la arena: guardar priv creative previo, forzar survival.
--   - Al salir de la arena: restaurar priv creative previo.
-- Los jugadores que NO son admin conservan sus privs reales
-- (otorgadas por `wetlands_newplayer`) y su gamemode lo maneja VoxeLibre
-- segun el privilege `creative` (sin esta hack de meta). Admin (`gabo`)
-- conserva inventario creativo via privilege `creative` en ADMIN_PRIVS.
--
-- Si en el futuro se quiere un comportamiento creativo-fuera-arena +
-- survival-dentro-arena (como antes), reintroducir el bloque aqui Y
-- revertir el whitelist en `wetlands_newplayer` para que admin no sea el
-- unico con creative.
-- minetest.register_on_joinplayer(function(player)
--     local name = player:get_player_name()
--     local meta = player:get_meta()
--     local in_arena = pvp_arena.is_player_in_arena(name)
--     if not in_arena then
--         meta:set_string("gamemode", "creative")
--         local privs = minetest.get_player_privs(name)
--         if not privs.creative then
--             privs.creative = true
--             minetest.set_player_privs(name, privs)
--         end
--         minetest.log("action", "[PVP Arena] Player " .. name .. " joined - CREATIVE mode with infinite inventory")
--     end
-- end)

-- Inicialización
minetest.register_on_mods_loaded(function()
    pvp_arena.load_arenas()
    minetest.log("action", "[PVP Arena] Mod loaded successfully with " .. #pvp_arena.arenas .. " arenas")
end)

-- Limpiar estado al desconectar
minetest.register_on_leaveplayer(function(player)
    local name = player:get_player_name()

    -- Si estaba en arena, restaurar creative antes de desconectar
    if pvp_arena.players_in_arena[name] then
        local had_creative = pvp_arena.player_creative_status[name]
        if had_creative then
            local privs = minetest.get_player_privs(name)
            privs.creative = true
            minetest.set_player_privs(name, privs)
        end

        pvp_arena.players_in_arena[name] = nil
        pvp_arena.player_creative_status[name] = nil
        minetest.log("action", "[PVP Arena] Cleaned up state for " .. name)
    end

    -- Limpiar tracking de ataques y anunciar estadísticas finales
    pvp_arena.last_attacker[name] = nil
    pvp_arena.dead_players[name] = nil  -- Limpiar estado de muerte
    pvp_arena.cleanup_player_stats(name)
end)

-- Hook para daño entre jugadores (verificación adicional)
minetest.register_on_punchplayer(function(player, hitter, time_from_last_punch, tool_capabilities, dir, damage)
    if not hitter:is_player() then
        return false  -- Permitir daño de mobs
    end

    local victim_name = player:get_player_name()
    local hitter_name = hitter:get_player_name()

    -- Verificar si AMBOS jugadores están en una arena
    local victim_in_arena = pvp_arena.is_player_in_arena(victim_name)
    local hitter_in_arena = pvp_arena.is_player_in_arena(hitter_name)

    if victim_in_arena and hitter_in_arena then
        -- Ambos en arena: PERMITIR daño
        -- Rastrear último atacante para sistema de scoring
        pvp_arena.last_attacker[victim_name] = {
            name = hitter_name,
            time = os.time()
        }
        return false
    else
        -- Al menos uno fuera de arena: CANCELAR daño
        if not hitter_in_arena then
            minetest.chat_send_player(hitter_name,
                minetest.colorize("#FF6B6B", "❌ No puedes atacar a jugadores fuera de la Arena PVP"))
        end
        return true  -- Cancelar el golpe
    end
end)

-- Activar modo fantasma (ghost mode) para jugador muerto
function pvp_arena.enable_ghost_mode(player_name)
    local player = minetest.get_player_by_name(player_name)
    if not player then return end

    -- Detectar en qué arena murió el jugador
    local _, current_arena = pvp_arena.is_player_in_arena(player_name)

    -- Guardar posición de muerte y arena
    pvp_arena.dead_players[player_name] = {
        death_pos = player:get_pos(),
        death_time = os.time(),
        arena = current_arena  -- Guardar referencia a la arena
    }

    -- Hacer invisible
    player:set_properties({
        visual_size = {x = 0, y = 0},
        makes_footstep_sound = false,
        is_visible = false,
        pointable = false
    })

    -- Modo espectador: fly + noclip temporales
    local privs = minetest.get_player_privs(player_name)
    privs.fly = true
    privs.noclip = true
    minetest.set_player_privs(player_name, privs)

    -- Hacer invulnerable completamente
    player:set_armor_groups({fleshy = 0, immortal = 1})

    minetest.log("action", "[PVP Arena] " .. player_name .. " entered ghost mode")
end

-- Desactivar modo fantasma y respawnear jugador
function pvp_arena.disable_ghost_mode(player_name)
    local player = minetest.get_player_by_name(player_name)
    if not player then return end

    -- Obtener arena donde murió el jugador
    local death_data = pvp_arena.dead_players[player_name]
    if not death_data or not death_data.arena then
        minetest.log("warning", "[PVP Arena] No arena data found for " .. player_name .. " during respawn")
        return
    end

    local arena = death_data.arena

    -- Determinar punto de respawn
    local respawn_pos
    if arena.respawn_point then
        -- Usar respawn point configurado de la arena
        respawn_pos = arena.respawn_point
    else
        -- Fallback: 10 bloques al norte del centro de la arena
        respawn_pos = {
            x = arena.center.x,
            y = arena.center.y,
            z = arena.center.z - 10
        }
    end

    -- Teleportar al jugador al punto de respawn
    player:set_pos(respawn_pos)
    minetest.log("action", "[PVP Arena] Teleported " .. player_name .. " to respawn point " .. minetest.pos_to_string(respawn_pos))

    -- Restaurar visibilidad
    player:set_properties({
        visual_size = {x = 1, y = 1},
        makes_footstep_sound = true,
        is_visible = true,
        pointable = true
    })

    -- Quitar fly/noclip
    local privs = minetest.get_player_privs(player_name)
    privs.fly = nil
    privs.noclip = nil
    minetest.set_player_privs(player_name, privs)

    -- Hacer vulnerable de nuevo
    player:set_armor_groups({fleshy = 100})

    -- HP completo
    player:set_hp(20)

    -- Limpiar estado de muerte
    pvp_arena.dead_players[player_name] = nil

    minetest.log("action", "[PVP Arena] " .. player_name .. " respawned successfully at arena respawn point")
end

-- Mostrar countdown de respawn
function pvp_arena.show_respawn_countdown(player_name, seconds_remaining)
    local player = minetest.get_player_by_name(player_name)
    if not player then return end

    local color = "#FF6B6B"
    local icon = "💀"

    if seconds_remaining <= 2 then
        color = "#FFEB3B"
        icon = "⚡"
    end

    local msg = minetest.colorize(color, icon .. " RESPAWN EN " .. seconds_remaining .. " SEGUNDOS " .. icon)
    minetest.chat_send_player(player_name, msg)
end

-- Hook para controlar el respawn y evitar que VoxeLibre teleporte al spawn del mundo
minetest.register_on_respawnplayer(function(player)
    local player_name = player:get_player_name()

    -- Si el jugador está en nuestro sistema de respawn de arena, manejamos nosotros
    if pvp_arena.dead_players[player_name] then
        local death_data = pvp_arena.dead_players[player_name]
        local arena = death_data.arena

        if arena then
            -- Determinar punto de respawn
            local respawn_pos
            if arena.respawn_point then
                respawn_pos = arena.respawn_point
            else
                respawn_pos = {
                    x = arena.center.x,
                    y = arena.center.y,
                    z = arena.center.z - 10
                }
            end

            -- Teleportar inmediatamente al punto de respawn de la arena
            player:set_pos(respawn_pos)
            minetest.log("action", "[PVP Arena] Prevented default spawn - player " .. player_name .. " will respawn at arena")

            -- Retornar true para evitar que VoxeLibre use el spawn por defecto
            return true
        end
    end

    -- Si no está en arena, dejar que VoxeLibre maneje el respawn normalmente
    return false
end)

-- Hook para detectar muertes de jugadores en arena
minetest.register_on_dieplayer(function(player, reason)
    local victim_name = player:get_player_name()

    -- Verificar si el jugador murió en una arena
    local in_arena = pvp_arena.is_player_in_arena(victim_name)
    if not in_arena then
        return  -- Muerte fuera de arena, ignorar
    end

    -- Verificar si hay un atacante registrado recientemente (últimos 10 segundos)
    local attacker_data = pvp_arena.last_attacker[victim_name]
    if attacker_data and (os.time() - attacker_data.time) <= 10 then
        -- Registrar la kill
        pvp_arena.register_kill(attacker_data.name, victim_name)
        pvp_arena.last_attacker[victim_name] = nil
    else
        -- Muerte sin atacante claro (caída, lava, etc.)
        pvp_arena.init_player_stats(victim_name)
        pvp_arena.scores[victim_name].deaths = pvp_arena.scores[victim_name].deaths + 1
        pvp_arena.scores[victim_name].current_streak = 0

        local death_msg = minetest.colorize("#90CAF9", victim_name) ..
                         minetest.colorize("#FFFFFF", " murió ") ..
                         minetest.colorize("#FFB74D", "(accidente)")

        -- Anunciar a jugadores en arenas
        for player_name, _ in pairs(pvp_arena.players_in_arena) do
            minetest.chat_send_player(player_name, death_msg)
        end

        pvp_arena.last_attacker[victim_name] = nil
    end

    -- SISTEMA DE RESPAWN ESTILO LOL: Ghost mode + Countdown
    -- Activar ghost mode inmediatamente
    pvp_arena.enable_ghost_mode(victim_name)

    -- Mensaje de muerte
    minetest.chat_send_player(victim_name,
        minetest.colorize("#FF6B6B", "═══════════════════════════════════"))
    minetest.chat_send_player(victim_name,
        minetest.colorize("#FF6B6B", "        💀 HAS MUERTO 💀         "))
    minetest.chat_send_player(victim_name,
        minetest.colorize("#FFEB3B", "   Revivirás en " .. pvp_arena.respawn_time .. " segundos...   "))
    minetest.chat_send_player(victim_name,
        minetest.colorize("#FF6B6B", "═══════════════════════════════════"))

    -- Countdown regresivo (5, 4, 3, 2, 1)
    for i = pvp_arena.respawn_time, 1, -1 do
        minetest.after((pvp_arena.respawn_time - i) + 0.5, function()
            local still_dead = pvp_arena.dead_players[victim_name]
            if still_dead and minetest.get_player_by_name(victim_name) then
                pvp_arena.show_respawn_countdown(victim_name, i)
            end
        end)
    end

    -- Respawn final después del countdown completo
    minetest.after(pvp_arena.respawn_time + 0.5, function()
        local respawned_player = minetest.get_player_by_name(victim_name)
        if respawned_player and pvp_arena.dead_players[victim_name] then
            -- Desactivar ghost mode y respawnear
            pvp_arena.disable_ghost_mode(victim_name)

            -- Mensaje de respawn
            minetest.chat_send_player(victim_name,
                minetest.colorize("#4CAF50", "✨ ¡HAS REVIVIDO! ✨"))
            minetest.chat_send_player(victim_name,
                minetest.colorize("#66BB6A", "🌱 De vuelta a la batalla con vida completa"))

            minetest.log("action", "[PVP Arena] " .. victim_name .. " respawned successfully")
        end
    end)
end)

minetest.log("action", "[PVP Arena] Mod initialization complete")
