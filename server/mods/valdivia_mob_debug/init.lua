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

        -- Calcular si podría spawnear hostiles
        local overworld_threshold = tonumber(minetest.settings:get("mcl_mobs_overworld_threshold")) or 0
        local overworld_sky_threshold = tonumber(minetest.settings:get("mcl_mobs_overworld_sky_threshold")) or 7

        local could_spawn_hostile = is_solid and (not is_water) and (not is_lava) and (not is_leaves)
            and (artificial_light <= overworld_threshold)
            and (natural_light <= overworld_sky_threshold)

        -- ═══════════════════════════════════════════════════════════════
        -- NUEVO: Detección de Bioma
        -- ═══════════════════════════════════════════════════════════════
        local biome_info = minetest.get_biome_data(pos)
        local biome_id = biome_info and biome_info.biome or nil
        local biome_name = "desconocido"
        local biome_valid_for_hostiles = "desconocido"

        if biome_id then
            local biome_def = minetest.registered_biomes[biome_id]
            if biome_def then
                biome_name = biome_def.name or "sin_nombre"
            else
                biome_name = "id_" .. tostring(biome_id)
            end

            -- VoxeLibre define hostile_mob_biomes en la config o usa lista por defecto
            -- Los biomas seguros para hostiles son los normales (no mushroom_island, no deep_ocean)
            local hostile_biomes_str = minetest.settings:get("mcl_mobs_hostile_mob_biomes") or ""
            if hostile_biomes_str ~= "" then
                -- Parsear lista de biomas permitidos
                local allowed = false
                for b in string.gmatch(hostile_biomes_str, "[^,]+") do
                    if string.find(biome_name, b:trim()) then
                        allowed = true
                        break
                    end
                end
                biome_valid_for_hostiles = allowed and "SI (en lista)" or "NO (no en lista)"
            else
                -- Si no hay config, VoxeLibre usa lista interna por defecto
                -- Biomas generalmente excluidos: mushroom_island, deep_ocean
                local excluded = {"mushroom", "ocean_deep", "deep_ocean"}
                local is_excluded = false
                for _, ex in ipairs(excluded) do
                    if string.find(biome_name:lower(), ex) then
                        is_excluded = true
                        break
                    end
                end
                biome_valid_for_hostiles = is_excluded and "NO (bioma excluido por defecto)" or "SI (bioma normal)"
            end
        end

        -- ═══════════════════════════════════════════════════════════════
        -- NUEVO: Conteo de Entidades (Mob Cap)
        -- ═══════════════════════════════════════════════════════════════
        local entity_radius = 64
        local objects = minetest.get_objects_inside_radius(pos, entity_radius)
        local total_entities = 0
        local hostile_count = 0
        local passive_count = 0
        local player_count = 0
        local other_count = 0
        local entity_types = {}

        for _, obj in ipairs(objects) do
            total_entities = total_entities + 1

            if obj:is_player() then
                player_count = player_count + 1
            else
                local ent = obj:get_luaentity()
                if ent then
                    local ent_name = ent.name or "unknown"
                    local is_hostile = false

                    -- Detectar si es hostile (patrones de mobs_mc)
                    local hostile_patterns = {"zombie", "skeleton", "spider", "creeper", "witch", "enderman"}
                    for _, pattern in ipairs(hostile_patterns) do
                        if string.find(ent_name:lower(), pattern) then
                            is_hostile = true
                            break
                        end
                    end

                    if is_hostile then
                        hostile_count = hostile_count + 1
                    else
                        passive_count = passive_count + 1
                    end

                    -- Contar por tipo
                    entity_types[ent_name] = (entity_types[ent_name] or 0) + 1
                else
                    other_count = other_count + 1
                end
            end
        end

        -- Límite de entidades por defecto en Luanti (hardcoded en el engine)
        local max_objects_per_block = 64  -- Default, puede variar
        local entity_density = total_entities / (entity_radius * entity_radius * entity_radius / 1000)

        -- ═══════════════════════════════════════════════════════════════
        -- Construir reporte
        -- ═══════════════════════════════════════════════════════════════
        local report = {
            "═══════════════════════════════════════",
            "  DIAGNOSTICO DE SPAWN - VALDIVIA",
            "═══════════════════════════════════════",
            "",
            "--- POSICION ---",
            string.format("Coordenadas: (%.1f, %.1f, %.1f)", pos.x, pos.y, pos.z),
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
            "",
            "═══════════════════════════════════════",
            "  BIOOMA (NUEVO)",
            "═══════════════════════════════════════",
            string.format("Bioma detectado: %s", biome_name),
            string.format("ID de bioma: %s", tostring(biome_id)),
            string.format("Valido para hostiles: %s", biome_valid_for_hostiles),
            "",
            "--- Config de biomas hostiles ---",
            string.format("mcl_mobs_hostile_mob_biomes: %s",
                minetest.settings:get("mcl_mobs_hostile_mob_biomes") or "(no definido = default)"),
            "",
            "═══════════════════════════════════════",
            "  ENTIDADES (NUEVO)",
            "═══════════════════════════════════════",
            string.format("Radio de escaneo: %d nodos", entity_radius),
            string.format("Total entidades: %d", total_entities),
            string.format("  Hostiles: %d", hostile_count),
            string.format("  Pasivos: %d", passive_count),
            string.format("  Jugadores: %d", player_count),
            string.format("  Otros: %d", other_count),
            "",
            "--- Top 5 tipos de entidad ---",
        }

        -- Ordenar entidades por cantidad (top 5)
        local sorted_types = {}
        for etype, count in pairs(entity_types) do
            table.insert(sorted_types, {name = etype, count = count})
        end
        table.sort(sorted_types, function(a, b) return a.count > b.count end)
        for i = 1, math.min(5, #sorted_types) do
            table.insert(report, string.format("  %d. %s (x%d)", i, sorted_types[i].name, sorted_types[i].count))
        end

        -- Continuar con análisis
        table.insert(report, "")
        table.insert(report, "--- ANALISIS ---")
        table.insert(report, string.format("Es solido: %s", is_solid and "SI" or "NO"))
        table.insert(report, string.format("Es agua/lava: %s", (is_water or is_lava) and "SI" or "NO"))
        table.insert(report, string.format("Es hojas: %s", is_leaves and "SI" or "NO"))

        -- Verificar saturación de mob cap
        local mob_cap_warning = total_entities > 30
        if mob_cap_warning then
            table.insert(report, string.format("ALERTA: %d entidades en radio %d — posibles saturacion", total_entities, entity_radius))
        end

        table.insert(report, "")
        table.insert(report, "═══════════════════════════════════════")
        table.insert(report, "  RESULTADO FINAL")
        table.insert(report, "═══════════════════════════════════════")
        table.insert(report, string.format("Podria spawnear hostiles: %s", could_spawn_hostile and "SI" or "NO"))

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
            table.insert(report, "Motivos del bloqueo: " .. table.concat(reasons, ", "))
        else
            -- Si dice que sí pero no aparecen, dar pistas
            local hints = {}
            if biome_valid_for_hostiles ~= "SI (bioma normal)" and biome_valid_for_hostiles ~= "desconocido" then
                table.insert(hints, "BIOMA BLOQUEADO: " .. biome_name .. " no permite hostiles")
            end
            if mob_cap_warning then
                table.insert(hints, "MOB CAP SATURADO: demasiadas entidades cerca")
            end
            if hostile_count > 0 then
                table.insert(hints, string.format("Ya hay %d hostiles activos — el spawn funciona pero hay limite", hostile_count))
            end
            if #hints > 0 then
                table.insert(report, "Posibles causas del fallo:")
                for _, h in ipairs(hints) do
                    table.insert(report, "  → " .. h)
                end
            else
                table.insert(report, "Config OK pero spawn no ocurre — revisar spawn_biomes del mob")
            end
        end

        -- Enviar al chat
        local full_report = table.concat(report, "\n")
        minetest.chat_send_player(name, full_report)

        -- Log en servidor
        minetest.log("action", "[valdivia_mob_debug] Diagnostico para " .. name .. ": " ..
            string.format("pos=(%.1f,%.1f,%.1f) biome=%s entities=%d hostile=%d passive=%d spawn_ok=%s",
            pos.x, pos.y, pos.z, biome_name, total_entities, hostile_count, passive_count,
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
    description = "Diagnostico de spawning de monstruos en la posicion actual",
    func = diagnosticar_spawn,
})

minetest.log("action", "[valdivia_mob_debug] Comando /diagnosticar_spawn registrado (v2 - biome + entities)")
