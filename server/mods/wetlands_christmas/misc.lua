-- Wetlands Christmas - Miscellaneous Decorations (VoxeLibre compatible)
local depends, get_sound = ...

-- ========================================
-- MISTLETOE (Muérdago)
-- ========================================
minetest.register_node("wetlands_christmas:mistletoe", {
	description = "Muérdago\nPlanta navideña tradicional",
	tiles = {"christmas_decor_mistletoe.png"},
	drawtype = "plantlike",
	walkable = false,
	sunlight_propagates = true,
	paramtype = "light",
	use_texture_alpha = "blend",
	groups = {handy=1, deco_block=1, dig_immediate=3, attached_node=1, plant=1},
	sounds = get_sound("leaves"),
	selection_box = {
		type = "fixed",
		fixed = {-0.3, -0.5, -0.3, 0.3, 0.3, 0.3},
	},
	_mcl_blast_resistance = 0.1,
	_mcl_hardness = 0.1,
})

-- ========================================
-- ICICLES (Carámbanos decorativos)
-- ========================================
minetest.register_node("wetlands_christmas:icicles_wall", {
	description = "Carámbanos (pared)\nCarámbanos helados brillantes",
	tiles = {
		{
			name = "christmas_decor_icicles.png",
			backface_culling = false,
			animation = {
				type = "vertical_frames",
				aspect_w = 32,
				aspect_h = 32,
				length = 2
			},
		}
	},
	inventory_image = "christmas_decor_icicles_inv.png",
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
	light_source = 3,
	paramtype2 = "wallmounted",
	groups = {handy=1, deco_block=1, dig_immediate=3, attached_node=1},
	sounds = get_sound("glass"),
	_mcl_blast_resistance = 0.1,
	_mcl_hardness = 0.1,
})

minetest.register_node("wetlands_christmas:icicles_hanging", {
	description = "Carámbanos (colgantes)\nCarámbanos que cuelgan del techo",
	tiles = {
		{
			name = "christmas_decor_icicles.png",
			backface_culling = false,
			animation = {
				type = "vertical_frames",
				aspect_w = 32,
				aspect_h = 32,
				length = 2
			},
		}
	},
	inventory_image = "christmas_decor_icicles_hanging_inv.png",
	drawtype = "plantlike",
	walkable = false,
	sunlight_propagates = true,
	paramtype = "light",
	light_source = 3,
	use_texture_alpha = "blend",
	groups = {handy=1, deco_block=1, dig_immediate=3, attached_node=1},
	sounds = get_sound("glass"),
	selection_box = {
		type = "fixed",
		fixed = {-0.3, 0, -0.3, 0.3, 0.5, 0.3},
	},
	_mcl_blast_resistance = 0.1,
	_mcl_hardness = 0.1,
})

-- ========================================
-- SNOWMAN (Muñeco de nieve decorativo)
-- ========================================
minetest.register_node("wetlands_christmas:snowman", {
	description = "Muñeco de Nieve\nAmigable decoración invernal",
	drawtype = "mesh",
	mesh = "christmas_decor_snowman.obj",
	tiles = {"christmas_decor_snowman.png"},
	inventory_image = "christmas_decor_snowman_inv.png",
	walkable = true,
	selection_box = {
		type = "fixed",
		fixed = {-0.4, -0.5, -0.4, 0.4, 0.9, 0.4},
	},
	collision_box = {
		type = "fixed",
		fixed = {-0.4, -0.5, -0.4, 0.4, 0.9, 0.4},
	},
	paramtype = "light",
	sunlight_propagates = true,
	paramtype2 = "facedir",
	groups = {handy=1, deco_block=1, dig_immediate=2},
	sounds = get_sound("stone"),
	_mcl_blast_resistance = 0.5,
	_mcl_hardness = 0.5,
})

-- ========================================
-- NUTCRACKER (Cascanueces decorativo)
-- ========================================
minetest.register_node("wetlands_christmas:nutcracker", {
	description = "Cascanueces\nGuardián navideño decorativo",
	drawtype = "mesh",
	mesh = "christmas_decor_nutcracker.obj",
	tiles = {"christmas_decor_nutcracker.png"},
	inventory_image = "christmas_decor_nutcracker_inv.png",
	walkable = true,
	selection_box = {
		type = "fixed",
		fixed = {-0.25, -0.5, -0.25, 0.25, 0.9, 0.25},
	},
	collision_box = {
		type = "fixed",
		fixed = {-0.25, -0.5, -0.25, 0.25, 0.9, 0.25},
	},
	paramtype = "light",
	sunlight_propagates = true,
	paramtype2 = "facedir",
	groups = {handy=1, deco_block=1, dig_immediate=2},
	sounds = get_sound("stone"),
	_mcl_blast_resistance = 0.8,
	_mcl_hardness = 0.8,
})

-- ========================================
-- STOCKING (Calcetín navideño - sin reward system)
-- ========================================
minetest.register_node("wetlands_christmas:stocking", {
	description = "Calcetín Navideño\nCalcetín decorativo festivo",
	drawtype = "mesh",
	mesh = "christmas_decor_stocking.obj",
	tiles = {"christmas_decor_stocking.png"},
	inventory_image = "christmas_decor_stocking_inv.png",
	walkable = false,
	selection_box = {
		type = "fixed",
		fixed = {-0.3, -0.5, -0.1, 0.3, 0.3, 0.2},
	},
	collision_box = {
		type = "fixed",
		fixed = {-0.3, -0.5, -0.1, 0.3, 0.3, 0.2},
	},
	paramtype = "light",
	sunlight_propagates = true,
	paramtype2 = "facedir",
	groups = {handy=1, deco_block=1, dig_immediate=3, attached_node=1},
	sounds = get_sound("leaves"),
	_mcl_blast_resistance = 0.1,
	_mcl_hardness = 0.1,
})

-- ========================================
-- SHRUBBERY (Arbusto navideño)
-- ========================================
minetest.register_node("wetlands_christmas:shrubbery", {
	description = "Arbusto Navideño\nPequeño arbusto decorado",
	tiles = {"christmas_decor_shrubbery.png"},
	drawtype = "plantlike",
	walkable = false,
	sunlight_propagates = true,
	paramtype = "light",
	use_texture_alpha = "clip",
	groups = {handy=1, deco_block=1, dig_immediate=3, attached_node=1, plant=1},
	sounds = get_sound("leaves"),
	selection_box = {
		type = "fixed",
		fixed = {-0.4, -0.5, -0.4, 0.4, 0.3, 0.4},
	},
	_mcl_blast_resistance = 0.1,
	_mcl_hardness = 0.1,
})

-- ========================================
-- CRAFTINGS (Simplified)
-- ========================================

-- Craft icicles wall from hanging
minetest.register_craft({
	output = "wetlands_christmas:icicles_wall",
	type = "shapeless",
	recipe = {"wetlands_christmas:icicles_hanging"},
})

-- Craft hanging from wall
minetest.register_craft({
	output = "wetlands_christmas:icicles_hanging",
	type = "shapeless",
	recipe = {"wetlands_christmas:icicles_wall"},
})

minetest.log("action", "[wetlands_christmas] Miscellaneous decorations loaded")