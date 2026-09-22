-- valdivia_spawn_fix/init.lua
-- Elimina restriccion de biomas para monstruos en Valdivia (mapa Arnis/singlenode)
--
-- PROBLEMA: El mapa de Valdivia fue generado con Arnis for Minecraft (OpenStreetMap).
-- Esto usa mapgen singlenode, lo que significa que los biomas estandar de VoxeLibre
-- no existen en la superficie. El motor de mcl_mobs bloquea silenciosamente los spawns
-- porque el bioma actual no coincide con la lista spawn_biomes de los monstruos.
--
-- SOLUCION: Re-registrar las entradas de spawning de los monstruos principales SIN
-- restriccion de biomas. Esto anula silenciosamente el chequeo de biomas.
-- Referencia: spawning.lua linea 583:
--   if spawn_def.biomes and not spawn_def.biomes_lookup[state.biome] then return false end
-- Si biomes es nil, el chequeo se salta.

local hostile_mobs = {
    -- { name, chance, aoc, interval, min_light, max_light }
    { "mobs_mc:zombie",       1500, 4, 30, 0, 7 },
    { "mobs_mc:baby_zombie",    50, 4, 30, 0, 7 },
    { "mobs_mc:skeleton",      800, 2, 20, 0, 7 },
    { "mobs_mc:spider",       1000, 4, 30, 0, 7 },
    { "mobs_mc:stalker",       400, 4, 30, 0, 7 },
}

-- Esperar a que todos los mods esten cargados para asegurar que
-- mcl_mobs:spawn_setup esta disponible y las entidades estan registradas
minetest.register_on_mods_loaded(function()
    -- Verificar que mcl_mobs esta disponible
    if not mcl_mobs or not mcl_mobs.spawn_setup then
        minetest.log("error", "[valdivia_spawn_fix] mcl_mobs no disponible, abortando")
        return
    end

    local registered = 0
    local skipped = 0

    for _, mob in ipairs(hostile_mobs) do
        local name, chance, aoc, interval, min_light, max_light = mob[1], mob[2], mob[3], mob[4], mob[5], mob[6]

        -- Verificar que la entidad esta registrada
        if minetest.registered_entities[name] then
            local ok, err = pcall(function()
                mcl_mobs:spawn_setup({
                    name = name,
                    dimension = "overworld",
                    type_of_spawning = "ground",
                    -- SIN biomes = sin restriccion de bioma
                    -- El chequeo en spawning.lua:583 se salta cuando biomes es nil
                    min_light = min_light,
                    max_light = max_light,
                    chance = chance,
                    interval = interval,
                    aoc = aoc,
                    min_height = mcl_vars.mg_overworld_min,
                    max_height = mcl_vars.mg_overworld_max,
                })
            end)

            if ok then
                registered = registered + 1
                minetest.log("action", string.format(
                    "[valdivia_spawn_fix] Registrado %s sin restriccion de bioma (chance=%d)",
                    name, chance))
            else
                minetest.log("error", string.format(
                    "[valdivia_spawn_fix] Error registrando %s: %s", name, tostring(err)))
            end
        else
            skipped = skipped + 1
            minetest.log("warning", string.format(
                "[valdivia_spawn_fix] Entidad %s no registrada, omitiendo", name))
        end
    end

    minetest.log("action", string.format(
        "[valdivia_spawn_fix] Completado: %d registrados, %d omitidos",
        registered, skipped))
end)

minetest.log("action", "[valdivia_spawn_fix] Mod cargado - esperando mods_loaded para registrar spawns")
