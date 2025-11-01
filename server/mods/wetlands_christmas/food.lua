-- Wetlands Christmas - Food Items (VoxeLibre compatible)
local depends, get_sound = ...

-- ========================================
-- CANDYCANE (Bastón de caramelo decorativo y comestible)
-- ========================================
minetest.register_node("wetlands_christmas:candycane", {
	description = "Bastón de Caramelo\nUn dulce bastón navideño decorativo",
	drawtype = "mesh",
	mesh = "christmas_decor_candycane.obj",
	tiles = {"christmas_decor_candycane.png"},
	inventory_image = "christmas_decor_candycane_inv.png",
	walkable = true,
	selection_box = {
		type = "fixed",
		fixed = {-0.3, -0.5, -0.3, 0.3, 0.5, 0.3},
	},
	collision_box = {
		type = "fixed",
		fixed = {-0.3, -0.5, -0.3, 0.3, 0.5, 0.3},
	},
	paramtype = "light",
	sunlight_propagates = true,
	paramtype2 = "facedir",
	groups = {handy=1, deco_block=1, dig_immediate=3},
	sounds = get_sound("stone"),
	on_use = minetest.item_eat(4),
	_mcl_blast_resistance = 0.5,
	_mcl_hardness = 0.5,
})

-- ========================================
-- GINGERBREAD (Galletas de jengibre)
-- ========================================
minetest.register_craftitem("wetlands_christmas:gingerbread_man", {
	description = "Galleta de Jengibre\nDeliciosa galleta con forma humana",
	inventory_image = "christmas_decor_gingerbread_man.png",
	on_use = minetest.item_eat(6),
	groups = {food=2, eatable=6},
})

minetest.register_craftitem("wetlands_christmas:gingerbread_man_raw", {
	description = "Galleta de Jengibre (cruda)\nNecesita hornearse",
	inventory_image = "christmas_decor_gingerbread_man_raw.png",
})

minetest.register_craftitem("wetlands_christmas:gingerbread_dough", {
	description = "Masa de Jengibre\nMasa para hacer galletas",
	inventory_image = "christmas_decor_gingerbread_dough.png",
})

minetest.register_craftitem("wetlands_christmas:ginger", {
	description = "Jengibre\nEspecia navideña aromática",
	inventory_image = "christmas_decor_ginger.png",
})

minetest.register_craftitem("wetlands_christmas:cookiecutter", {
	description = "Cortador de Galletas\nPara dar forma a las galletas",
	inventory_image = "christmas_decor_cookie_cutter.png",
})

-- ========================================
-- MILK GLASS (Vaso de leche vegetal)
-- ========================================
minetest.register_node("wetlands_christmas:milk_glass", {
	description = "Vaso de Leche de Avena\nPerfecto para acompañar galletas",
	drawtype = "plantlike",
	tiles = {"christmas_decor_milk_glass.png"},
	inventory_image = "christmas_decor_milk_glass_inv.png",
	wield_image = "christmas_decor_milk_glass.png",
	paramtype = "light",
	is_ground_content = false,
	walkable = false,
	stack_max = 1,
	selection_box = {
		type = "fixed",
		fixed = {-0.25, -0.5, -0.25, 0.25, 0.3, 0.25}
	},
	groups = {handy=1, dig_immediate=3, attached_node=1},
	sounds = get_sound("glass"),
	on_use = minetest.item_eat(4),
})

-- ========================================
-- DECORATIVE PLATE (Plato con galletas)
-- ========================================
minetest.register_node("wetlands_christmas:plate_with_cookies", {
	description = "Plato con Galletas (decorativo)\nDeliciosas galletas listas para servir",
	tiles = {"christmas_decor_plate_top.png"},
	inventory_image = "christmas_decor_plate_top.png",
	wield_image = "christmas_decor_plate_top.png",
	sunlight_propagates = true,
	walkable = false,
	climbable = false,
	is_ground_content = false,
	selection_box = {
		type = "wallmounted",
	},
	legacy_wallmounted = true,
	use_texture_alpha = "blend",
	drawtype = "signlike",
	paramtype = "light",
	paramtype2 = "wallmounted",
	groups = {handy=1, deco_block=1, dig_immediate=3, attached_node=1},
	sounds = get_sound("glass"),
})

-- ========================================
-- CANDY BLOCKS (Bloques de caramelo)
-- ========================================
minetest.register_node("wetlands_christmas:candycane_block", {
	description = "Bloque de Bastón de Caramelo\nBloque decorativo rayado",
	tiles = {
		"christmas_decor_candycane_block.png", "christmas_decor_candycane_block.png",
		"christmas_decor_candycane_block.png", "christmas_decor_candycane_block.png",
		"christmas_decor_candycane_block.png^[transformFX", "christmas_decor_candycane_block.png^[transformFX",
	},
	paramtype2 = "facedir",
	groups = {handy=1, building_block=1, deco_block=1},
	sounds = get_sound("stone"),
	_mcl_blast_resistance = 0.8,
	_mcl_hardness = 0.8,
})

minetest.register_node("wetlands_christmas:peppermint_block", {
	description = "Bloque de Menta\nBloque decorativo con diseño de menta",
	tiles = {"christmas_decor_peppermint.png"},
	paramtype2 = "facedir",
	groups = {handy=1, building_block=1, deco_block=1},
	sounds = get_sound("stone"),
	_mcl_blast_resistance = 0.8,
	_mcl_hardness = 0.8,
})

minetest.register_node("wetlands_christmas:frosting_block", {
	description = "Bloque de Glaseado\nSuave y esponjoso",
	tiles = {"christmas_decor_frosting.png"},
	paramtype2 = "facedir",
	groups = {handy=1, building_block=1, deco_block=1},
	sounds = get_sound("leaves"),
	_mcl_blast_resistance = 0.3,
	_mcl_hardness = 0.3,
})

-- Decorative frosting trims
minetest.register_node("wetlands_christmas:frosting_trim", {
	description = "Moldura de Glaseado\nDecoración de pared festiva",
	tiles = {"christmas_decor_frosting_trim.png"},
	inventory_image = "christmas_decor_frosting_trim.png",
	wield_image = "christmas_decor_frosting_trim.png",
	sunlight_propagates = true,
	walkable = false,
	climbable = false,
	is_ground_content = false,
	selection_box = {
		type = "wallmounted",
	},
	legacy_wallmounted = true,
	use_texture_alpha = "blend",
	drawtype = "signlike",
	paramtype = "light",
	paramtype2 = "wallmounted",
	groups = {handy=1, deco_block=1, dig_immediate=3, attached_node=1},
	sounds = get_sound("leaves"),
})

minetest.register_node("wetlands_christmas:frosting_line", {
	description = "Línea de Glaseado\nDetalle decorativo delgado",
	tiles = {"christmas_decor_frosting_line.png"},
	inventory_image = "christmas_decor_frosting_line.png",
	wield_image = "christmas_decor_frosting_line.png",
	sunlight_propagates = true,
	walkable = false,
	climbable = false,
	is_ground_content = false,
	selection_box = {
		type = "wallmounted",
	},
	legacy_wallmounted = true,
	use_texture_alpha = "blend",
	drawtype = "signlike",
	paramtype = "light",
	paramtype2 = "wallmounted",
	groups = {handy=1, deco_block=1, dig_immediate=3, attached_node=1},
	sounds = get_sound("leaves"),
})

-- ========================================
-- GUMDROPS (Gomitas de colores)
-- ========================================
for color, hex in pairs({
	red = "#ff0000",
	orange = "#ff9000",
	yellow = "#fcff00",
	green = "#18cb35",
	blue = "#0096FF",
	purple = "#ae4eff",
}) do
	local color_spanish = {
		red = "Roja",
		orange = "Naranja",
		yellow = "Amarilla",
		green = "Verde",
		blue = "Azul",
		purple = "Morada",
	}

	minetest.register_node("wetlands_christmas:gumdrop_" .. color, {
		description = "Gomita " .. color_spanish[color] .. "\nDulce gelatinoso festivo",
		drawtype = "mesh",
		mesh = "christmas_decor_gumdrop.obj",
		tiles = {"christmas_decor_gumdrop.png^[colorize:" .. hex .. ":150"},
		walkable = true,
		selection_box = {
			type = "fixed",
			fixed = {-0.4, -0.5, -0.4, 0.4, 0.1, 0.4},
		},
		collision_box = {
			type = "fixed",
			fixed = {-0.4, -0.5, -0.4, 0.4, 0.1, 0.4},
		},
		paramtype = "light",
		sunlight_propagates = true,
		paramtype2 = "facedir",
		groups = {handy=1, deco_block=1, dig_immediate=3},
		sounds = get_sound("leaves"),
		on_use = minetest.item_eat(2),
		_mcl_blast_resistance = 0.1,
		_mcl_hardness = 0.1,
	})
end

-- ========================================
-- CRAFTINGS (VoxeLibre compatible)
-- ========================================

-- Craftings simplificados (sin dependencias complejas por ahora)
-- Los craftings avanzados se agregarán en siguiente iteración

-- Frosting trims from blocks
minetest.register_craft({
	output = "wetlands_christmas:frosting_trim 6",
	recipe = {
		{"wetlands_christmas:frosting_block", "wetlands_christmas:frosting_block", "wetlands_christmas:frosting_block"},
		{"", "wetlands_christmas:frosting_block", ""},
	}
})

minetest.register_craft({
	output = "wetlands_christmas:frosting_line 6",
	recipe = {
		{"wetlands_christmas:frosting_block", "wetlands_christmas:frosting_block", "wetlands_christmas:frosting_block"},
	}
})

-- Cookie cutter from gingerbread dough
minetest.register_craft({
	output = "wetlands_christmas:gingerbread_man_raw 5",
	type = "shapeless",
	recipe = {"wetlands_christmas:cookiecutter", "wetlands_christmas:gingerbread_dough"},
	replacements = {{"wetlands_christmas:cookiecutter", "wetlands_christmas:cookiecutter"}},
})

-- Cooking gingerbread
minetest.register_craft({
	type = "cooking",
	output = "wetlands_christmas:gingerbread_man",
	recipe = "wetlands_christmas:gingerbread_man_raw",
	cooktime = 10,
})

minetest.log("action", "[wetlands_christmas] Food items loaded")