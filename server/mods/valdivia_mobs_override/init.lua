-- valdivia_mobs_override/init.lua
-- Permite que monstruos hostiles aparezcan en calles iluminadas de Valdivia
-- Aumenta max_light de 7 a 12 para zombies, skeletons, creepers, spiders
--
-- Problema: la iluminación urbana (faroles) genera luz 8-14 en calles,
-- bloqueando spawns que requieren luz < 7. Solución: subir tolerancia.

local MOD_NAME = "valdivia_mobs_override"

-- Lista de monstruos hostiles cuya tolerancia de luz queremos aumentar
-- Prefijo correcto en VoxeLibre: mobs_mc (no mcl_monsters)
local HOSTILE_MOBS = {
    "mobs_mc:zombie",
    "mobs_mc:skeleton",
    "mobs_mc:spider",
    "mobs_mc:husk",
    "mobs_mc:stray",
    "mobs_mc:baby_zombie",
    "mobs_mc:baby_husk",
    "mobs_mc:spider_cave",
}

-- Nivel de luz objetivo (default era 7, subimos a 12)
-- 12 permite spawns bajo faroles débiles pero no en interior iluminado
local NEW_MAX_LIGHT = 12

-- Esperar a que todos los mods se carguen antes de modificar
minetest.register_on_mods_loaded(function()
    local modified = 0

    -- Método 1: Buscar en mcl_mobs.mob_list (si existe)
    if mcl_mobs and mcl_mobs.mob_list then
        for _, mob_name in ipairs(HOSTILE_MOBS) do
            local mob_def = mcl_mobs.mob_list[mob_name]
            if mob_def then
                if mob_def.max_light and mob_def.max_light < NEW_MAX_LIGHT then
                    local old_light = mob_def.max_light
                    mob_def.max_light = NEW_MAX_LIGHT
                    modified = modified + 1
                    minetest.log("action", "[" .. MOD_NAME .. "] " .. mob_name ..
                        " (mob_list): max_light " .. old_light .. " -> " .. NEW_MAX_LIGHT)
                end
            end
        end
    end

    -- Método 2: Buscar directamente en minetest.registered_entities
    for entity_name, entity_def in pairs(minetest.registered_entities) do
        -- Buscar por nombre exacto
        local is_target = false
        for _, mob_name in ipairs(HOSTILE_MOBS) do
            if entity_name == mob_name then
                is_target = true
                break
            end
        end

        -- Buscar por patrón (zombie, skeleton, spider, husk, stray)
        if not is_target then
            local patterns = {"zombie", "skeleton", "spider", "husk", "stray"}
            for _, pattern in ipairs(patterns) do
                if entity_name:lower():find(pattern) then
                    is_target = true
                    break
                end
            end
        end

        if is_target and entity_def.max_light and entity_def.max_light < NEW_MAX_LIGHT then
            local old_light = entity_def.max_light
            entity_def.max_light = NEW_MAX_LIGHT
            modified = modified + 1
            minetest.log("action", "[" .. MOD_NAME .. "] " .. entity_name ..
                " (entity): max_light " .. old_light .. " -> " .. NEW_MAX_LIGHT)
        end
    end

    minetest.log("action", "[" .. MOD_NAME .. "] Configuración completada. " ..
        modified .. " registros de luz modificados.")
end)
