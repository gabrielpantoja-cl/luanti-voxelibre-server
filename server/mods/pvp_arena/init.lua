-- PVP Arena Mod v1.1.0
-- Permite PvP en zonas específicas del servidor Wetlands
-- Autor: gabo (Gabriel Pantoja)

pvp_arena = {}
pvp_arena.arenas = {}
pvp_arena.players_in_arena = {}
pvp_arena.player_creative_status = {}  -- Guardar estado de creative antes de entrar

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
        enabled = true,
        created_by = "gabo",
        created_at = os.time()
    }
    table.insert(pvp_arena.arenas, default_arena)
    pvp_arena.save_arenas()
    minetest.log("action", "[PVP Arena] Created default arena at (41, 23, 232)")
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
        -- ENTRAR A ARENA: Guardar estado creative y removerlo temporalmente
        local privs = minetest.get_player_privs(player_name)
        pvp_arena.player_creative_status[player_name] = privs.creative or false

        if privs.creative then
            privs.creative = nil
            minetest.set_player_privs(player_name, privs)
            minetest.log("action", "[PVP Arena] Removed creative from " .. player_name .. " (arena entry)")
        end

        -- Hacer vulnerable al jugador
        local armor_groups = player:get_armor_groups()
        armor_groups.fleshy = 100
        player:set_armor_groups(armor_groups)

    else
        -- SALIR DE ARENA: Restaurar creative si lo tenía antes
        local had_creative = pvp_arena.player_creative_status[player_name]

        if had_creative then
            local privs = minetest.get_player_privs(player_name)
            privs.creative = true
            minetest.set_player_privs(player_name, privs)
            minetest.log("action", "[PVP Arena] Restored creative to " .. player_name .. " (arena exit)")
        end

        pvp_arena.player_creative_status[player_name] = nil

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

minetest.log("action", "[PVP Arena] Mod initialization complete")
