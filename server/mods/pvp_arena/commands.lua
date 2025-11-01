-- Comandos de chat para PVP Arena
-- Autor: gabo (Gabriel Pantoja)

-- ═══════════════════════════════════════════════════════
-- COMANDOS PARA JUGADORES
-- ═══════════════════════════════════════════════════════

-- /arena_lista - Muestra todas las arenas disponibles
minetest.register_chatcommand("arena_lista", {
    description = "Muestra todas las arenas PVP disponibles",
    func = function(name)
        if #pvp_arena.arenas == 0 then
            return true, minetest.colorize("#FFB74D", "No hay arenas disponibles actualmente.")
        end

        local msg = minetest.colorize("#4CAF50", "🏟️  Arenas PVP Disponibles:\n")
        for i, arena in ipairs(pvp_arena.arenas) do
            local status = arena.enabled and minetest.colorize("#4CAF50", "✅") or minetest.colorize("#FF6B6B", "❌")
            local coords = string.format("(%d, %d, %d)", arena.center.x, arena.center.y, arena.center.z)
            msg = msg .. string.format("%s %d. %s - Radio: %dm - Coords: %s\n",
                status, i, arena.name, arena.radius, coords)
        end
        return true, msg
    end
})

-- /salir_arena - Teleporta fuera de la arena
minetest.register_chatcommand("salir_arena", {
    description = "Teleporta fuera de la arena PVP",
    func = function(name)
        if not pvp_arena.players_in_arena[name] then
            return false, minetest.colorize("#FFB74D", "No estás en una arena PVP.")
        end

        local player = minetest.get_player_by_name(name)
        if not player then return false end

        -- Teleportar al spawn del servidor
        local spawn = minetest.setting_get_pos("static_spawnpoint") or {x=0, y=15, z=0}
        player:set_pos(spawn)

        minetest.log("action", "[PVP Arena] " .. name .. " used /salir_arena command")
        return true, minetest.colorize("#4CAF50", "✅ Has salido de la arena. Bienvenido a zona pacífica.")
    end
})

-- /arena_info - Información de la arena donde estás
minetest.register_chatcommand("arena_info", {
    description = "Información de la arena donde estás",
    func = function(name)
        local in_arena, arena = pvp_arena.is_player_in_arena(name)

        if not in_arena then
            return false, minetest.colorize("#FFB74D", "No estás en ninguna arena PVP.")
        end

        local msg = minetest.colorize("#4CAF50", "🏟️  Arena: ") .. arena.name .. "\n" ..
                    minetest.colorize("#2196F3", "📍 Centro: ") .. minetest.pos_to_string(arena.center) .. "\n" ..
                    minetest.colorize("#2196F3", "📏 Radio: ") .. arena.radius .. "m\n" ..
                    minetest.colorize("#2196F3", "👤 Creada por: ") .. arena.created_by .. "\n" ..
                    minetest.colorize("#FF6B6B", "⚔️ PVP: ACTIVO")

        return true, msg
    end
})

-- /arena_donde - Muestra tu distancia a la arena más cercana
minetest.register_chatcommand("arena_donde", {
    description = "Muestra tu distancia a la arena más cercana",
    func = function(name)
        local player = minetest.get_player_by_name(name)
        if not player then return false end

        local pos = player:get_pos()
        local closest_arena = nil
        local closest_distance = math.huge

        for _, arena in ipairs(pvp_arena.arenas) do
            if arena.enabled then
                local distance = vector.distance(pos, arena.center)
                if distance < closest_distance then
                    closest_distance = distance
                    closest_arena = arena
                end
            end
        end

        if not closest_arena then
            return false, minetest.colorize("#FFB74D", "No hay arenas disponibles.")
        end

        local direction = vector.direction(pos, closest_arena.center)
        local dir_text = ""
        if math.abs(direction.x) > math.abs(direction.z) then
            dir_text = direction.x > 0 and "Este" or "Oeste"
        else
            dir_text = direction.z > 0 and "Sur" or "Norte"
        end

        local msg = minetest.colorize("#4CAF50", "🏟️  Arena más cercana: ") .. closest_arena.name .. "\n" ..
                    minetest.colorize("#2196F3", "📏 Distancia: ") .. math.floor(closest_distance) .. " bloques\n" ..
                    minetest.colorize("#2196F3", "🧭 Dirección: ") .. dir_text .. "\n" ..
                    minetest.colorize("#2196F3", "📍 Coordenadas: ") .. minetest.pos_to_string(closest_arena.center)

        return true, msg
    end
})

-- ═══════════════════════════════════════════════════════
-- COMANDOS DE SCORING (Sistema de Puntuación)
-- ═══════════════════════════════════════════════════════

-- /arena_score - Muestra el scoreboard completo
minetest.register_chatcommand("arena_score", {
    description = "Muestra el scoreboard de la arena PVP",
    func = function(name)
        pvp_arena.show_scoreboard(name)
        return true
    end
})

-- /mis_stats - Muestra tus estadísticas personales
minetest.register_chatcommand("mis_stats", {
    description = "Muestra tus estadísticas PVP personales",
    func = function(name)
        local stats_msg = pvp_arena.show_player_stats(name)
        return true, stats_msg
    end
})

-- ═══════════════════════════════════════════════════════
-- COMANDOS PARA ADMINISTRADORES
-- ═══════════════════════════════════════════════════════

-- Registrar privilegio de administrador de arenas
minetest.register_privilege("arena_admin", {
    description = "Permite crear y gestionar arenas PVP",
    give_to_singleplayer = true,
    give_to_admin = true,
})

-- /crear_arena <nombre> <radio>
minetest.register_chatcommand("crear_arena", {
    params = "<nombre> <radio>",
    description = "Crea una nueva arena PVP en tu posición actual (admin only)",
    privs = {arena_admin = true},
    func = function(name, params)
        local arena_name, radius_str = params:match("^(%S+)%s+(%d+)$")

        if not arena_name or not radius_str then
            return false, minetest.colorize("#FF6B6B", "❌ Uso: /crear_arena <nombre> <radio>\n") ..
                         minetest.colorize("#FFB74D", "Ejemplo: /crear_arena Arena_Halloween 40")
        end

        local radius = tonumber(radius_str)
        if radius < 10 or radius > 200 then
            return false, minetest.colorize("#FF6B6B", "❌ El radio debe estar entre 10 y 200 metros.")
        end

        -- Verificar si ya existe una arena con ese nombre
        for _, arena in ipairs(pvp_arena.arenas) do
            if arena.name == arena_name then
                return false, minetest.colorize("#FF6B6B", "❌ Ya existe una arena con ese nombre.")
            end
        end

        local player = minetest.get_player_by_name(name)
        if not player then return false end

        local pos = player:get_pos()
        local new_arena = {
            name = arena_name,
            center = {x = math.floor(pos.x), y = math.floor(pos.y), z = math.floor(pos.z)},
            radius = radius,
            enabled = true,
            created_by = name,
            created_at = os.time()
        }

        table.insert(pvp_arena.arenas, new_arena)
        pvp_arena.save_arenas()

        minetest.log("action", "[PVP Arena] " .. name .. " created arena '" .. arena_name .. "' at " .. minetest.pos_to_string(pos))

        return true, minetest.colorize("#4CAF50", "✅ Arena '") .. arena_name ..
                     minetest.colorize("#4CAF50", "' creada con radio de ") .. radius ..
                     minetest.colorize("#4CAF50", "m\n📍 Centro: ") .. minetest.pos_to_string(new_arena.center)
    end
})

-- /eliminar_arena <nombre>
minetest.register_chatcommand("eliminar_arena", {
    params = "<nombre>",
    description = "Elimina una arena PVP (admin only)",
    privs = {arena_admin = true},
    func = function(name, arena_name)
        if arena_name == "" then
            return false, minetest.colorize("#FF6B6B", "❌ Uso: /eliminar_arena <nombre>")
        end

        for i, arena in ipairs(pvp_arena.arenas) do
            if arena.name == arena_name then
                -- Desactivar PVP para todos los jugadores en esta arena
                for player_name, player_arena in pairs(pvp_arena.players_in_arena) do
                    if player_arena == arena_name then
                        pvp_arena.set_pvp(player_name, false)
                        pvp_arena.players_in_arena[player_name] = nil
                        local player = minetest.get_player_by_name(player_name)
                        if player then
                            minetest.chat_send_player(player_name,
                                minetest.colorize("#FFB74D", "⚠️ La arena '" .. arena_name .. "' ha sido eliminada"))
                        end
                    end
                end

                table.remove(pvp_arena.arenas, i)
                pvp_arena.save_arenas()

                minetest.log("action", "[PVP Arena] " .. name .. " deleted arena '" .. arena_name .. "'")
                return true, minetest.colorize("#4CAF50", "✅ Arena '") .. arena_name .. minetest.colorize("#4CAF50", "' eliminada")
            end
        end
        return false, minetest.colorize("#FF6B6B", "❌ Arena no encontrada: ") .. arena_name
    end
})

-- /arena_tp <nombre>
minetest.register_chatcommand("arena_tp", {
    params = "<nombre>",
    description = "Teleporta al centro de una arena (admin only)",
    privs = {arena_admin = true},
    func = function(name, arena_name)
        if arena_name == "" then
            return false, minetest.colorize("#FF6B6B", "❌ Uso: /arena_tp <nombre>")
        end

        for _, arena in ipairs(pvp_arena.arenas) do
            if arena.name == arena_name then
                local player = minetest.get_player_by_name(name)
                if not player then return false end

                player:set_pos(arena.center)
                minetest.log("action", "[PVP Arena] " .. name .. " teleported to arena '" .. arena_name .. "'")

                return true, minetest.colorize("#4CAF50", "✅ Teleportado al centro de '") .. arena_name .. "'"
            end
        end
        return false, minetest.colorize("#FF6B6B", "❌ Arena no encontrada: ") .. arena_name
    end
})

-- /arena_toggle <nombre>
minetest.register_chatcommand("arena_toggle", {
    params = "<nombre>",
    description = "Activa/desactiva una arena PVP (admin only)",
    privs = {arena_admin = true},
    func = function(name, arena_name)
        if arena_name == "" then
            return false, minetest.colorize("#FF6B6B", "❌ Uso: /arena_toggle <nombre>")
        end

        for _, arena in ipairs(pvp_arena.arenas) do
            if arena.name == arena_name then
                arena.enabled = not arena.enabled
                pvp_arena.save_arenas()

                -- Si se desactiva, desactivar PVP para jugadores dentro
                if not arena.enabled then
                    for player_name, player_arena in pairs(pvp_arena.players_in_arena) do
                        if player_arena == arena_name then
                            pvp_arena.set_pvp(player_name, false)
                            pvp_arena.players_in_arena[player_name] = nil
                            local player = minetest.get_player_by_name(player_name)
                            if player then
                                minetest.chat_send_player(player_name,
                                    minetest.colorize("#FFB74D", "⚠️ La arena ha sido desactivada temporalmente"))
                            end
                        end
                    end
                end

                local status = arena.enabled and
                    minetest.colorize("#4CAF50", "✅ activada") or
                    minetest.colorize("#FF6B6B", "❌ desactivada")

                minetest.log("action", "[PVP Arena] " .. name .. " toggled arena '" .. arena_name .. "' to " .. (arena.enabled and "enabled" or "disabled"))

                return true, "Arena '" .. arena_name .. "' " .. status
            end
        end
        return false, minetest.colorize("#FF6B6B", "❌ Arena no encontrada: ") .. arena_name
    end
})

-- /arena_stats - Estadísticas de todas las arenas
minetest.register_chatcommand("arena_stats", {
    description = "Muestra estadísticas de uso de arenas (admin only)",
    privs = {arena_admin = true},
    func = function(name)
        local total_arenas = #pvp_arena.arenas
        local active_arenas = 0
        local players_in_pvp = 0

        for _, arena in ipairs(pvp_arena.arenas) do
            if arena.enabled then
                active_arenas = active_arenas + 1
            end
        end

        for _ in pairs(pvp_arena.players_in_arena) do
            players_in_pvp = players_in_pvp + 1
        end

        local msg = minetest.colorize("#4CAF50", "📊 Estadísticas de Arenas PVP\n") ..
                    minetest.colorize("#2196F3", "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━\n") ..
                    "Total de arenas: " .. total_arenas .. "\n" ..
                    "Arenas activas: " .. active_arenas .. "\n" ..
                    "Jugadores en PVP: " .. players_in_pvp .. "\n"

        if players_in_pvp > 0 then
            msg = msg .. minetest.colorize("#FFB74D", "\nJugadores activos:\n")
            for player_name, arena_name in pairs(pvp_arena.players_in_arena) do
                msg = msg .. "  • " .. player_name .. " → " .. arena_name .. "\n"
            end
        end

        return true, msg
    end
})

-- /grant_creative_all - Otorga creative a TODOS los usuarios existentes (admin only)
minetest.register_chatcommand("grant_creative_all", {
    description = "Otorga creative mode a todos los usuarios existentes sin él (admin only)",
    privs = {server = true},
    func = function(name)
        local granted_count = 0
        local already_have = 0

        -- Obtener todos los usuarios autenticados
        local auth_handler = minetest.get_auth_handler()

        -- Iterar sobre todos los jugadores conocidos
        for username in auth_handler.iterate() do
            local privs = minetest.get_player_privs(username)

            if not privs.creative then
                -- Otorgar creative
                privs.creative = true
                privs.give = true
                privs.fly = true
                privs.fast = true
                privs.noclip = true
                privs.home = true
                privs.protect = true
                minetest.set_player_privs(username, privs)
                granted_count = granted_count + 1

                minetest.log("action", "[PVP Arena] Granted creative to existing user: " .. username)
            else
                already_have = already_have + 1
            end
        end

        local msg = minetest.colorize("#4CAF50", "✅ Operación completada:\n") ..
                    minetest.colorize("#2196F3", "• Usuarios con creative otorgado: ") .. granted_count .. "\n" ..
                    minetest.colorize("#FFB74D", "• Usuarios que ya tenían creative: ") .. already_have

        return true, msg
    end
})

minetest.log("action", "[PVP Arena] Commands registered successfully")
