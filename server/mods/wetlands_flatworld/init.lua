-- wetlands_flatworld
-- Mundo 100% plano de pura tierra maciza sobre mapgen "singlenode".
-- El motor no genera nada por si solo; este callback rellena cada chunk emergido:
--   * y <= SURFACE_Y  -> tierra (mcl_core:dirt)
--   * y >  SURFACE_Y  -> aire
-- Asi la superficie es instantanea y la tierra hacia abajo se materializa bajo
-- demanda cuando los jugadores cavan, hasta el limite del motor (~ -31000).

local modname = minetest.get_current_modname()

-- Ultima capa de tierra. Aire en todo y > SURFACE_Y. La superficie pisable queda
-- en y=0, asi que el static_spawnpoint del mundo va en 0,2,0.
local SURFACE_Y = 0

-- En VoxeLibre la tierra es mcl_core:dirt (NO default:dirt). Fallback defensivo
-- por si el mod base no estuviera disponible.
local DIRT_NODE = minetest.registered_nodes["mcl_core:dirt"] and "mcl_core:dirt" or "air"
local c_dirt = minetest.get_content_id(DIRT_NODE)
local c_air  = minetest.get_content_id("air")

minetest.register_on_generated(function(minp, maxp, blockseed)
    -- Chunk completamente por encima de la superficie: singlenode ya deja aire.
    if minp.y > SURFACE_Y then
        return
    end

    local vm, emin, emax = minetest.get_mapgen_object("voxelmanip")
    local data = vm:get_data()
    local area = VoxelArea:new({ MinEdge = emin, MaxEdge = emax })

    for z = minp.z, maxp.z do
        for x = minp.x, maxp.x do
            for y = minp.y, maxp.y do
                data[area:index(x, y, z)] = (y <= SURFACE_Y) and c_dirt or c_air
            end
        end
    end

    vm:set_data(data)
    -- El motor escribe el voxelmanip de mapgen y calcula la iluminacion al
    -- retornar de on_generated; no hace falta write_to_map() ni calc_lighting().
end)

minetest.log("action", "[" .. modname .. "] Loaded successfully (superficie tierra en y=" .. SURFACE_Y .. ")")
