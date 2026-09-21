-- valdivia_mobs_override/init.lua
-- Permite que monstruos hostiles aparezcan en calles iluminadas de Valdivia
-- Aumenta max_light de 7 a 12 para zombies, skeletons, creepers, spiders
--
-- Problema: la iluminación urbana (faroles) genera luz 8-14 en calles,
-- bloqueando spawns que requieren luz < 7. Solución: subir tolerancia.

local MOD_NAME = "valdivia_mobs_override"

-- Lista de monstruos hostiles cuya tolerancia de luz queremos aumentar
local HOSTILE_MOBS = {
    "mcl_monsters:zombie",
    "mcl_monsters:skeleton",
    "mcl_monsters:spider",
    "mcl_monsters:creeper",
    -- Variantes
    "mcl_monsters:zombie_villager",
    "mcl_monsters:husk",
    "mcl_monsters:stray",
    "mcl_monsters:spider_cave",
}

-- Nivel de luz objetivo (default era 7, subimos a 12)
-- 12 permite spawns bajo faroles débiles pero no en interior iluminado
local NEW_MAX_LIGHT = 12

-- Esperar a que todos los mods se carguen antes de modificar
minetest.register_on_mods_loaded(function()
    local modified = 0

    -- Buscar en la tabla global de mobs registrados
    if mcl_mobs and mcl_mobs.mob_list then
        for _, mob_name in ipairs(HOSTILE_MOBS) do
            local mob_def = mcl_mobs.mob_list[mob_name]
            if mob_def then
                -- Buscar y modificar max_light en todos los registros de spawn
                if mob_def.spawns_in then
                    for spawn_name, spawn_data in pairs(mob_def.spawns_in) do
                        if spawn_data.max_light and spawn_data.max_light < NEW_MAX_LIGHT then
                            local old_light = spawn_data.max_light
                            spawn_data.max_light = NEW_MAX_LIGHT
                            modified = modified + 1
                            minetest.log("action", "[" .. MOD_NAME .. "] " .. mob_name ..
                                " spawn '" .. spawn_name .. "': max_light " ..
                                old_light .. " -> " .. NEW_MAX_LIGHT)
                        end
                    end
                end

                -- También modificar max_light principal si existe
                if mob_def.max_light and mob_def.max_light < NEW_MAX_LIGHT then
                    local old_light = mob_def.max_light
                    mob_def.max_light = NEW_MAX_LIGHT
                    modified = modified + 1
                    minetest.log("action", "[" .. MOD_NAME .. "] " .. mob_name ..
                        ": max_light principal " .. old_light .. " -> " .. NEW_MAX_LIGHT)
                end
            end
        end
    end

    -- Método alternativo: buscar en minetest.registered_entities
    for entity_name, entity_def in pairs(minetest.registered_entities) do
        for _, mob_name in ipairs(HOSTILE_MOBS) do
            if entity_name == mob_name or entity_name:find(mob_name, 1, true) then
                if entity_def.max_light and entity_def.max_light < NEW_MAX_LIGHT then
                    local old_light = entity_def.max_light
                    entity_def.max_light = NEW_MAX_LIGHT
                    modified = modified + 1
                    minetest.log("action", "[" .. MOD_NAME .. "] " .. entity_name ..
                        " (entity): max_light " .. old_light .. " -> " .. NEW_MAX_LIGHT)
                end
            end
        end
    end

    minetest.log("action", "[" .. MOD_NAME .. "] Configuración completada. " ..
        modified .. " registros de luz modificados.")
end)
