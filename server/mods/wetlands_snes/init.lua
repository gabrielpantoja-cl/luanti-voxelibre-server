-- ============================================================================
-- wetlands_snes - Consola retro jugable
--
-- La consola es un nodo decorativo que al hacer click derecho abre un menu con
-- ocho juegos. Cuatro son en tiempo real y se juegan con el teclado (WASD),
-- dibujados en una rejilla de celdas HUD; los otros cuatro son por turnos en
-- formspec. El framework compartido vive en arcade.lua.
--
-- Estructura:
--   arcade.lua       framework (pantalla HUD, entrada, sesiones, records)
--   games/*.lua      un archivo por juego, se registra con arcade.register_game
--   tools/           generador de texturas + chequeos de Lua y de logica
-- ============================================================================

local modname = minetest.get_current_modname()
local modpath = minetest.get_modpath(modname)

-- API global del mod (la usan los archivos de games/ y otros mods).
wetlands_snes = dofile(modpath .. "/arcade.lua")
local arcade  = wetlands_snes

-- El orden de carga define el orden del menu.
for _, game in ipairs({
    "snake", "tetris", "breakout", "pong",
    "dosmil", "memoria", "topo", "trivia",
}) do
    dofile(modpath .. "/games/" .. game .. ".lua")
end

-- ============================================================
-- NODO: Consola retro
-- ============================================================

minetest.register_node(modname .. ":console", {
    description = "Consola Retro (8 juegos)",
    _doc_items_longdesc = "Una consola de los anios 90. Click derecho para " ..
        "jugar Snake, Tetris, Breakout, Pong, 2048, Memoria, Atrapa al Topo " ..
        "y la Trivia de Valdivia.",
    tiles = {
        "wetlands_snes_top.png",
        "wetlands_snes_bottom.png",
        "wetlands_snes_side.png",
        "wetlands_snes_side.png",
        "wetlands_snes_back.png",
        "wetlands_snes_front.png",
    },
    drawtype   = "nodebox",
    paramtype  = "light",
    paramtype2 = "facedir",
    node_box = {
        type  = "fixed",
        fixed = {
            { -0.5, -0.5, -0.25, 0.5, -0.08, 0.38 },   -- cuerpo plano
            { -0.13, -0.08, 0.05, 0.13, 0.22, 0.20 },  -- ranura cartucho
        },
    },
    selection_box = {
        type  = "fixed",
        fixed = { -0.5, -0.5, -0.25, 0.5, 0.22, 0.38 },
    },
    groups = {
        cracky                  = 2,
        oddly_breakable_by_hand = 1,
        handy                   = 1,
    },
    light_source          = 2,
    _mcl_blast_resistance = 3,
    _mcl_hardness         = 2,
    on_rightclick = function(pos, node, player, itemstack)
        if player and player:is_player() then
            arcade.show_menu(player:get_player_name())
        end
        return itemstack
    end,
})

-- ============================================================
-- ITEM: Control (abre el menu desde cualquier parte)
-- ============================================================

minetest.register_craftitem(modname .. ":controller", {
    description     = "Control Retro (usalo para abrir el menu)",
    inventory_image = "wetlands_snes_controller.png",
    on_use = function(itemstack, user)
        if user and user:is_player() then
            arcade.show_menu(user:get_player_name())
        end
        return itemstack
    end,
    on_place = function(itemstack, user)
        if user and user:is_player() then
            arcade.show_menu(user:get_player_name())
        end
        return itemstack
    end,
})

-- ============================================================
-- COMANDOS
-- ============================================================

minetest.register_chatcommand("arcade", {
    params      = "[salir]",
    description = "Abre la consola retro (o sale del juego actual)",
    func = function(name, param)
        if not minetest.get_player_by_name(name) then
            return false, "No estas conectado."
        end
        if param == "salir" then
            arcade.stop(name, true)
            minetest.close_formspec(name, "")
            return true, "Consola apagada."
        end
        arcade.show_menu(name)
        return true
    end,
})

minetest.register_chatcommand("snes", {
    description = "Alias de /arcade",
    func = function(name, param)
        return minetest.registered_chatcommands["arcade"].func(name, param)
    end,
})

-- ============================================================
-- RECETAS
-- ============================================================

if minetest.get_modpath("mcl_core") then
    minetest.register_craft({
        output = modname .. ":console",
        recipe = {
            { "mcl_core:iron_ingot", "mcl_core:stone",      "mcl_core:iron_ingot" },
            { "mcl_core:stone",      "mcl_core:stone",      "mcl_core:stone"      },
            { "mcl_core:iron_ingot", "mcl_core:iron_ingot", "mcl_core:iron_ingot" },
        },
    })
    minetest.register_craft({
        output = modname .. ":controller 2",
        recipe = {
            { "mcl_core:iron_ingot", "mcl_core:stone", "mcl_core:iron_ingot" },
            { "mcl_core:iron_ingot", "",               "mcl_core:iron_ingot" },
        },
    })
end

minetest.log("action", "[" .. modname .. "] Cargado exitosamente con " ..
    #arcade.order .. " juegos")
