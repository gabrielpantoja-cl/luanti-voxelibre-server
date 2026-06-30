local modname = minetest.get_current_modname()

-- El mundo Valdivia fue generado con Arnis usando una version anterior de VoxeLibre
-- que nombraba estos nodos como mcl_*. La version actual usa mesecons_*.
-- Estos aliases hacen que los nodos viejos del mapa se rendericen correctamente.

minetest.register_alias("mcl_daylight_detector:daylight_detector", "mesecons_solarpanel:solar_panel_off")
minetest.register_alias("mcl_noteblock:noteblock",                  "mesecons_noteblock:noteblock")
minetest.register_alias("mcl_redstone_torch:redstoneblock",         "mesecons_torch:redstoneblock")

-- Banners: versiones viejas con color en el nombre -> nodo actual sin color
minetest.register_alias("mcl_banners:hanging_banner_white",         "mcl_banners:hanging_banner")
minetest.register_alias("mcl_banners:hanging_banner_red",           "mcl_banners:hanging_banner")
minetest.register_alias("mcl_banners:hanging_banner_silver",        "mcl_banners:hanging_banner")

minetest.log("action", "[" .. modname .. "] Loaded successfully")
