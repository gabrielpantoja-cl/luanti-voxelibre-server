-- valdivia_mob_debug/init.lua
-- Diagnóstico de spawning de monstruos en Valdivia
-- Comando: /diagnosticar_spawn

local function diagnosticar_spawn(name)
    -- Envolver TODO en pcall para nunca crashear el servidor
    local ok, result = pcall(function()
        local player = minetest.get_player_by_name(name)
        if not player then
            return false, "Jugador no encontrado"
        end

        local pos = player:get_pos()
        local pos_below = {x = pos.x, y = pos.y - 1, z = pos.z}

        -- Obtener bloque bajo los pies (con protección nil)
        local node_below = minetest.get_node(pos_below)
        if not node_below or not node_below.name then
            return false, "No se pudo leer el bloque bajo"
        end
        local node_def = minetest.registered_nodes[node_below.name] or {}

        -- Obtener bloque en la posición actual
        local node_here = minetest.get_node(pos)
        if not node_here or not node_here.name then
            return false, "No se pudo leer el bloque actual"
        end

        -- Obtener luz (get_artificial_light espera param1 numérico, NO la tabla)
        local natural_light = minetest.get_natural_light(pos) or 0
        local artificial_light = minetest.get_artificial_light(node_here.param1 or 0) or 0

        -- Obtener groups del bloque bajo
        local groups_below = node_def.groups or {}

        -- Verificar si es superficie válida para spawning
        local is_solid = (groups_below.solid or 0) ~= 0
        local is_water = (groups_below.water or 0) ~= 0
        local is_lava = (groups_below.lava or 0) ~= 0
        local is_leaves = (groups_below.leaves or 0) ~= 0
        local is_grass = (groups_below.grass_block or 0) ~= 0

        -- Calcular si podría spawnear hostiles
        local overworld_threshold = tonumber(minetest.settings:get("mcl_mobs_overworld_threshold")) or 0
        local overworld_sky_threshold = tonumber(minetest.settings:get("mcl_mobs_overworld_sky_threshold")) or 7

        local could_spawn_hostile = is_solid and (not is_water) and (not is_lava) and (not is_leaves)
            and (artificial_light <= overworld_threshold)
            and (natural_light <= overworld_sky_threshold)

        -- Construir reporte
        local report = {
            "=== DIAGNÓSTICO DE SPAWN ===",
            string.format("Posicion: (%.1f, %.1f, %.1f)", pos.x, pos.y, pos.z),
            string.format("Bloque bajo: %s", node_below.name),
            string.format("Bloque actual: %s", node_here.name),
            "",
            "--- LUZ ---",
            string.format("Luz natural (sky): %d", natural_light),
            string.format("Luz artificial (art): %d", artificial_light),
            "",
            "--- THRESHOLDS (config) ---",
            string.format("overworld_threshold: %d", overworld_threshold),
            string.format("overworld_sky_threshold: %d", overworld_sky_threshold),
            "",
            "--- GRUPOS DEL BLOQUE BAJO ---",
            string.format("solid: %d", groups_below.solid or 0),
            string.format("water: %d", groups_below.water or 0),
            string.format("lava: %d", groups_below.lava or 0),
            string.format("leaves: %d", groups_below.leaves or 0),
            string.format("grass_block: %d", groups_below.grass_block or 0),
            "",
            "--- ANALISIS ---",
            string.format("Es solido: %s", is_solid and "SI" or "NO"),
            string.format("Es agua/lava: %s", (is_water or is_lava) and "SI" or "NO"),
            string.format("Es hojas: %s", is_leaves and "SI" or "NO"),
            "",
            "--- RESULTADO ---",
            string.format("Podria spawnear hostiles: %s", could_spawn_hostile and "SI" or "NO"),
        }

        if not could_spawn_hostile then
            local reasons = {}
            if not is_solid then table.insert(reasons, "bloque bajo no es solido") end
            if is_water then table.insert(reasons, "estas sobre agua") end
            if is_lava then table.insert(reasons, "estas sobre lava") end
            if is_leaves then table.insert(reasons, "bloque bajo son hojas") end
            if artificial_light > overworld_threshold then
                table.insert(reasons, string.format("luz artificial (%d) > threshold (%d)", artificial_light, overworld_threshold))
            end
            if natural_light > overworld_sky_threshold then
                table.insert(reasons, string.format("luz natural (%d) > sky_threshold (%d)", natural_light, overworld_sky_threshold))
            end
            table.insert(report, "Motivos: " .. table.concat(reasons, ", "))
        end

        -- Enviar al chat
        local full_report = table.concat(report, "\n")
        minetest.chat_send_player(name, full_report)

        -- Log en servidor
        minetest.log("action", "[valdivia_mob_debug] Diagnostico para " .. name .. ": " ..
            string.format("pos=(%.1f,%.1f,%.1f) block=%s art_light=%d natural_light=%d spawn_ok=%s",
            pos.x, pos.y, pos.z, node_below.name, artificial_light, natural_light,
            tostring(could_spawn_hostile)))

        return true, "Diagnostico enviado al chat y log del servidor"
    end)

    if not ok then
        minetest.log("error", "[valdivia_mob_debug] Error en /diagnosticar_spawn: " .. tostring(result))
        return false, "Error interno: " .. tostring(result)
    end

    return result
end

minetest.register_chatcommand("diagnosticar_spawn", {
    description = "Diagnóstico de spawning de monstruos en la posición actual",
    func = diagnosticar_spawn,
})

minetest.log("action", "[valdivia_mob_debug] Comando /diagnosticar_spawn registrado")
