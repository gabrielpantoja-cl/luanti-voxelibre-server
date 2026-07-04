-- valdivia_no_zombie_piglin: Valdivia es la unica ciudad publicada en la lista
-- de servidores de Luanti y debe verse como una ciudad, no como el Nether.
-- Algunos jugadores insistian en sacar el huevo de Zombie Piglin del
-- inventario creativo (todo jugador tiene el priv "creative" por default en
-- Valdivia, ver luanti-valdivia.conf) y llenar el mapa de zombified_piglin,
-- lo que recarga el mapa y arruina la estetica de la ciudad.
--
-- Este mod SOLO se carga en Valdivia (load_mod_valdivia_no_zombie_piglin en
-- luanti-valdivia.conf). No toca mobs_mc:piglin ni mobs_mc:piglin_brute: esos
-- dos siguen disponibles, el problema era especificamente el zombie.

local modname = minetest.get_current_modname()

local ZOMBIE_EGG = "mobs_mc:zombified_piglin"
local CLEANUP_ENTITIES = {
    ["mobs_mc:zombified_piglin"] = true,
    ["mobs_mc:baby_zombified_piglin"] = true,
}
local CLEANUP_INTERVAL = 300  -- 5 min: suficiente para ir limpiando sin ser agresivo

-- ===========================================================================
-- 1) Deshabilitar el huevo: no aparece en el inventario creativo y, si algun
--    jugador ya tenia uno en su inventario de antes, colocarlo no hace nada.
-- ===========================================================================

minetest.register_on_mods_loaded(function()
    local def = minetest.registered_items[ZOMBIE_EGG]
    if not def then
        minetest.log("warning", "[" .. modname .. "] " .. ZOMBIE_EGG .. " no existe, nada que deshabilitar")
        return
    end

    local groups = table.copy(def.groups or {})
    groups.not_in_creative_inventory = 1

    minetest.override_item(ZOMBIE_EGG, {
        groups = groups,
        on_place = function(itemstack)
            return itemstack  -- inerte: no invoca nada, no se consume
        end,
        on_secondary_use = function(itemstack)
            return itemstack
        end,
        _doc_items_usagehelp = "Este huevo esta deshabilitado en Valdivia.",
    })
end)

-- ===========================================================================
-- 2) Limpieza periodica de zombified_piglin / baby_zombified_piglin ya
--    invocados. Respeta nametag y domesticados, igual que /clearmobs.
--    Solo actua sobre entidades cargadas (limitacion del engine), pero al
--    repetirse cada CLEANUP_INTERVAL termina cubriendo todo el mapa a medida
--    que los jugadores recorren la ciudad.
-- ===========================================================================

local function cleanup_zombie_piglins()
    local removed = 0
    for _, le in pairs(minetest.luaentities) do
        if le.is_mob and CLEANUP_ENTITIES[le.name]
                and (not le.nametag or le.nametag == "")
                and not le.tamed then
            le.object:remove()
            removed = removed + 1
        end
    end
    if removed > 0 then
        minetest.log("action", "[" .. modname .. "] Limpieza automatica: " .. removed .. " zombified piglin eliminados")
    end
    minetest.after(CLEANUP_INTERVAL, cleanup_zombie_piglins)
end
minetest.after(10, cleanup_zombie_piglins)  -- primera pasada poco despues del arranque

minetest.log("action", "[" .. modname .. "] Loaded successfully")
