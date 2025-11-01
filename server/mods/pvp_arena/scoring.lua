-- Sistema de Scoring para PVP Arena
-- Autor: gabo (Gabriel Pantoja)
-- Versión: 1.0.0

pvp_arena.scores = {}
pvp_arena.killstreaks = {}
pvp_arena.session_stats = {}

-- ═══════════════════════════════════════════════════════
-- INICIALIZACIÓN DE ESTADÍSTICAS
-- ═══════════════════════════════════════════════════════

-- Inicializar estadísticas de un jugador
function pvp_arena.init_player_stats(player_name)
    if not pvp_arena.scores[player_name] then
        pvp_arena.scores[player_name] = {
            kills = 0,
            deaths = 0,
            current_streak = 0,
            best_streak = 0,
            last_kill_time = 0
        }
    end
end

-- Resetear estadísticas cuando un jugador entra a la arena
function pvp_arena.reset_session_stats(player_name)
    pvp_arena.init_player_stats(player_name)
    -- No reseteamos, mantenemos stats acumuladas de la sesión
end

-- ═══════════════════════════════════════════════════════
-- REGISTRO DE KILLS Y DEATHS
-- ═══════════════════════════════════════════════════════

-- Registrar una kill
function pvp_arena.register_kill(killer_name, victim_name)
    pvp_arena.init_player_stats(killer_name)
    pvp_arena.init_player_stats(victim_name)

    local killer_stats = pvp_arena.scores[killer_name]
    local victim_stats = pvp_arena.scores[victim_name]

    -- Actualizar estadísticas del killer
    killer_stats.kills = killer_stats.kills + 1
    killer_stats.current_streak = killer_stats.current_streak + 1
    killer_stats.last_kill_time = os.time()

    -- Actualizar best streak si aplica
    if killer_stats.current_streak > killer_stats.best_streak then
        killer_stats.best_streak = killer_stats.current_streak
    end

    -- Actualizar estadísticas de la víctima
    victim_stats.deaths = victim_stats.deaths + 1
    victim_stats.current_streak = 0  -- Se resetea el streak al morir

    -- Anunciar la kill
    pvp_arena.announce_kill(killer_name, victim_name, killer_stats.current_streak)

    -- Verificar y anunciar killstreaks especiales
    pvp_arena.check_killstreak(killer_name, killer_stats.current_streak)

    minetest.log("action", "[PVP Arena] " .. killer_name .. " killed " .. victim_name ..
                 " (streak: " .. killer_stats.current_streak .. ")")
end

-- ═══════════════════════════════════════════════════════
-- ANUNCIOS Y MENSAJES
-- ═══════════════════════════════════════════════════════

-- Anunciar una kill en el chat
function pvp_arena.announce_kill(killer_name, victim_name, streak)
    local msg = minetest.colorize("#FF6B6B", "💀 ") ..
                minetest.colorize("#FFEB3B", killer_name) ..
                minetest.colorize("#FFFFFF", " eliminó a ") ..
                minetest.colorize("#90CAF9", victim_name)

    if streak > 1 then
        msg = msg .. minetest.colorize("#FF6B6B", " [" .. streak .. " kills seguidas]")
    end

    -- Enviar a todos los jugadores en arenas
    for player_name, _ in pairs(pvp_arena.players_in_arena) do
        minetest.chat_send_player(player_name, msg)
    end

    -- Mostrar scoreboard actualizado después de cada kill
    minetest.after(1.0, function()
        pvp_arena.show_scoreboard_to_arena()
    end)
end

-- Verificar y anunciar killstreaks especiales
function pvp_arena.check_killstreak(player_name, streak)
    local messages = {
        [3] = {text = "¡TRIPLE KILL!", color = "#FFA726"},
        [5] = {text = "¡KILLING SPREE!", color = "#FF7043"},
        [7] = {text = "¡RAMPAGE!", color = "#F4511E"},
        [10] = {text = "¡UNSTOPPABLE!", color = "#D32F2F"},
        [15] = {text = "¡GODLIKE!", color = "#C62828"},
        [20] = {text = "¡LEGENDARY!", color = "#B71C1C"}
    }

    local streak_msg = messages[streak]
    if streak_msg then
        local announcement = minetest.colorize(streak_msg.color, "🔥 " .. streak_msg.text .. " 🔥") .. " " ..
                            minetest.colorize("#FFEB3B", player_name) ..
                            minetest.colorize("#FFFFFF", " tiene ") ..
                            minetest.colorize("#FF6B6B", streak .. " kills seguidas!")

        -- Anunciar a todos en arenas
        for pname, _ in pairs(pvp_arena.players_in_arena) do
            minetest.chat_send_player(pname, announcement)
        end

        minetest.log("action", "[PVP Arena] " .. player_name .. " achieved " .. streak .. " killstreak!")
    end
end

-- ═══════════════════════════════════════════════════════
-- SCOREBOARD (TABLA DE POSICIONES)
-- ═══════════════════════════════════════════════════════

-- Obtener scoreboard ordenado
function pvp_arena.get_scoreboard()
    local players = {}

    -- Recopilar jugadores con estadísticas
    for player_name, stats in pairs(pvp_arena.scores) do
        if stats.kills > 0 or stats.deaths > 0 then
            table.insert(players, {
                name = player_name,
                kills = stats.kills,
                deaths = stats.deaths,
                streak = stats.current_streak,
                best_streak = stats.best_streak,
                kd_ratio = stats.deaths > 0 and (stats.kills / stats.deaths) or stats.kills
            })
        end
    end

    -- Ordenar por kills (descendente), luego por K/D ratio
    table.sort(players, function(a, b)
        if a.kills == b.kills then
            return a.kd_ratio > b.kd_ratio
        end
        return a.kills > b.kills
    end)

    return players
end

-- Formatear scoreboard como texto
function pvp_arena.format_scoreboard(max_entries)
    max_entries = max_entries or 10
    local scoreboard = pvp_arena.get_scoreboard()

    if #scoreboard == 0 then
        return minetest.colorize("#FFB74D", "📊 No hay estadísticas aún. ¡Sé el primero en combatir!")
    end

    local msg = minetest.colorize("#4CAF50", "╔═══════════════════════════════════════════════════╗\n")
    msg = msg .. minetest.colorize("#4CAF50", "║") ..
          minetest.colorize("#FFEB3B", "       🏆 SCOREBOARD - ARENA PVP 🏆           ") ..
          minetest.colorize("#4CAF50", "║\n")
    msg = msg .. minetest.colorize("#4CAF50", "╠═══════════════════════════════════════════════════╣\n")

    -- Header
    msg = msg .. minetest.colorize("#90CAF9", "║ #  Jugador              K    D    K/D   Streak   ║\n")
    msg = msg .. minetest.colorize("#4CAF50", "╠═══════════════════════════════════════════════════╣\n")

    -- Entries
    for i, player in ipairs(scoreboard) do
        if i > max_entries then break end

        -- Medalla para top 3
        local medal = ""
        if i == 1 then medal = "🥇"
        elseif i == 2 then medal = "🥈"
        elseif i == 3 then medal = "🥉"
        else medal = "  " end

        -- Color según posición
        local color = "#FFFFFF"
        if i == 1 then color = "#FFD700"  -- Oro
        elseif i == 2 then color = "#C0C0C0"  -- Plata
        elseif i == 3 then color = "#CD7F32"  -- Bronce
        end

        -- Formatear K/D ratio
        local kd_str = string.format("%.2f", player.kd_ratio)

        -- Formatear nombre (máx 18 caracteres - mejorado para evitar confusión)
        local name_display = player.name
        if #name_display > 18 then
            name_display = string.sub(name_display, 1, 15) .. "..."
        end
        name_display = string.format("%-18s", name_display)

        -- Formatear línea
        local line = string.format("║ %s %s %3d  %3d  %5s   %2d     ║",
            medal,
            name_display,
            player.kills,
            player.deaths,
            kd_str,
            player.streak
        )

        msg = msg .. minetest.colorize(color, line) .. "\n"
    end

    msg = msg .. minetest.colorize("#4CAF50", "╚═══════════════════════════════════════════════════╝")

    return msg
end

-- Mostrar scoreboard a un jugador específico
function pvp_arena.show_scoreboard(player_name)
    local msg = pvp_arena.format_scoreboard(10)
    minetest.chat_send_player(player_name, msg)
end

-- Mostrar scoreboard a todos los jugadores en arenas
function pvp_arena.show_scoreboard_to_arena()
    local scoreboard_msg = pvp_arena.format_scoreboard(5)  -- Top 5 para anuncios

    for player_name, _ in pairs(pvp_arena.players_in_arena) do
        minetest.chat_send_player(player_name, scoreboard_msg)
    end
end

-- ═══════════════════════════════════════════════════════
-- ESTADÍSTICAS PERSONALES
-- ═══════════════════════════════════════════════════════

-- Mostrar estadísticas personales de un jugador
function pvp_arena.show_player_stats(player_name)
    pvp_arena.init_player_stats(player_name)
    local stats = pvp_arena.scores[player_name]

    local kd_ratio = stats.deaths > 0 and (stats.kills / stats.deaths) or stats.kills

    local msg = minetest.colorize("#4CAF50", "╔═══════════════════════════════════╗\n")
    msg = msg .. minetest.colorize("#4CAF50", "║") ..
          minetest.colorize("#FFEB3B", "   📊 TUS ESTADÍSTICAS PVP 📊   ") ..
          minetest.colorize("#4CAF50", "║\n")
    msg = msg .. minetest.colorize("#4CAF50", "╠═══════════════════════════════════╣\n")
    msg = msg .. minetest.colorize("#FFFFFF", "║ Kills:           ") ..
          minetest.colorize("#4CAF50", string.format("%4d", stats.kills)) ..
          minetest.colorize("#FFFFFF", "             ║\n")
    msg = msg .. minetest.colorize("#FFFFFF", "║ Deaths:          ") ..
          minetest.colorize("#FF6B6B", string.format("%4d", stats.deaths)) ..
          minetest.colorize("#FFFFFF", "             ║\n")
    msg = msg .. minetest.colorize("#FFFFFF", "║ K/D Ratio:       ") ..
          minetest.colorize("#FFEB3B", string.format("%0.2f", kd_ratio)) ..
          minetest.colorize("#FFFFFF", "             ║\n")
    msg = msg .. minetest.colorize("#FFFFFF", "║ Racha actual:    ") ..
          minetest.colorize("#FFA726", string.format("%4d", stats.current_streak)) ..
          minetest.colorize("#FFFFFF", "             ║\n")
    msg = msg .. minetest.colorize("#FFFFFF", "║ Mejor racha:     ") ..
          minetest.colorize("#FF7043", string.format("%4d", stats.best_streak)) ..
          minetest.colorize("#FFFFFF", "             ║\n")
    msg = msg .. minetest.colorize("#4CAF50", "╚═══════════════════════════════════╝")

    return msg
end

-- ═══════════════════════════════════════════════════════
-- LIMPIEZA Y MANTENIMIENTO
-- ═══════════════════════════════════════════════════════

-- Limpiar estadísticas de jugadores desconectados
function pvp_arena.cleanup_player_stats(player_name)
    -- Anunciar estadísticas finales si tenía kills/deaths
    if pvp_arena.scores[player_name] then
        local stats = pvp_arena.scores[player_name]
        if stats.kills > 0 or stats.deaths > 0 then
            local summary = minetest.colorize("#FFB74D", "📊 " .. player_name .. " se desconectó") .. " " ..
                           minetest.colorize("#FFFFFF", "- Stats finales: ") ..
                           minetest.colorize("#4CAF50", stats.kills .. "K") .. "/" ..
                           minetest.colorize("#FF6B6B", stats.deaths .. "D")

            -- Anunciar a jugadores en arenas
            for pname, _ in pairs(pvp_arena.players_in_arena) do
                minetest.chat_send_player(pname, summary)
            end
        end
    end

    -- OPCIONAL: Mantener stats o limpiar
    -- Para mantener stats entre sesiones, comentar la siguiente línea:
    -- pvp_arena.scores[player_name] = nil
    -- pvp_arena.killstreaks[player_name] = nil
end

minetest.log("action", "[PVP Arena] Scoring system loaded successfully")