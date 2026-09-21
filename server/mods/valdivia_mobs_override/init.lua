-- valdivia_mobs_override/init.lua
-- Permite que monstruos hostiles aparezcan en calles iluminadas de Valdivia
-- Sobreescribe mcl_mobs:mob_light_lvl() para subir max_light de 7 a 12
--
-- Problema: la iluminación urbana (faroles) genera luz 8-14 en calles,
-- bloqueando spawns que requieren luz < 7. Solución: subir tolerancia.

local MOD_NAME = "valdivia_mobs_override"

-- Nivel de luz objetivo (default era 7, subimos a 12)
-- 12 permite spawns bajo faroles débiles pero no en interior iluminado
local NEW_MAX_LIGHT = 12

-- Lista de mobs hostiles cuya luz queremos modificar
local HOSTILE_MOBS = {
    ["mobs_mc:zombie"] = true,
    ["mobs_mc:skeleton"] = true,
    ["mobs_mc:spider"] = true,
    ["mobs_mc:husk"] = true,
    ["mobs_mc:stray"] = true,
    ["mobs_mc:baby_zombie"] = true,
    ["mobs_mc:baby_husk"] = true,
    ["mobs_mc:spider_cave"] = true,
    ["mobs_mc:villager_zombie"] = true,
    ["mobs_mc:enderman"] = true,
    ["mobs_mc:witch"] = true,
    ["mobs_mc:silverfish"] = true,
    ["mobs_mc:slime"] = true,
    ["mobs_mc:magma_cube"] = true,
    ["mobs_mc:ghast"] = true,
    ["mobs_mc:blaze"] = true,
    ["mobs_mc:wither_skeleton"] = true,
    ["mobs_mc:vex"] = true,
    ["mobs_mc:evoker"] = true,
    ["mobs_mc:vindicator"] = true,
    ["mobs_mc:pillager"] = true,
    ["mobs_mc:ravager"] = true,
}

-- Guardar referencia a la función original
local original_mob_light_lvl = mcl_mobs.mob_light_lvl

-- Sobreescribir la función para modificar max_light
function mcl_mobs:mob_light_lvl(mob_name, dimension)
    -- Llamar a la función original para obtener valores base
    local min_light, max_light = original_mob_light_lvl(self, mob_name, dimension)

    -- Si es un mob hostile y el max_light es menor a nuestro objetivo, subirlo
    if HOSTILE_MOBS[mob_name] and max_light and max_light < NEW_MAX_LIGHT then
        minetest.log("action", "[" .. MOD_NAME .. "] " .. mob_name ..
            ": max_light " .. max_light .. " -> " .. NEW_MAX_LIGHT)
        return min_light, NEW_MAX_LIGHT
    end

    return min_light, max_light
end

minetest.log("action", "[" .. MOD_NAME .. "] Override de luz para monstruos hostiles activado. " ..
    "max_light subido a " .. NEW_MAX_LIGHT .. " para calles iluminadas.")
