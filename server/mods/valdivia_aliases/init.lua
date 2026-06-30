local modname = minetest.get_current_modname()

-- El mundo Valdivia fue generado con Arnis usando una version anterior de VoxeLibre
-- que nombraba estos nodos como mcl_*. La version actual usa mesecons_*.
-- Estos aliases hacen que los nodos viejos del mapa se rendericen correctamente.

minetest.register_alias("mcl_daylight_detector:daylight_detector", "mesecons_solarpanel:solar_panel_off")
minetest.register_alias("mcl_noteblock:noteblock",                  "mesecons_noteblock:noteblock")
minetest.register_alias("mcl_redstone_torch:redstoneblock",         "mesecons_torch:redstoneblock")

minetest.log("action", "[" .. modname .. "] Loaded successfully")
