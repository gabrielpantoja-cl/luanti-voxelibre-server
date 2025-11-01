-- Wetlands Christmas - Lights (VoxeLibre compatible)
local depends, get_sound = ...

-- ========================================
-- LED COMPONENTS (Simplified - sin basic_materials)
-- ========================================
minetest.register_craftitem("wetlands_christmas:led_rgb", {
	description = "LED RGB\nLuz LED de colores",
	inventory_image = "christmas_decor_led_rgb.png",
})

minetest.register_craftitem("wetlands_christmas:led_white", {
	description = "LED Blanco\nLuz LED blanca",
	inventory_image = "christmas_decor_led_white.png",
})

minetest.register_craftitem("wetlands_christmas:wire", {
	description = "Cable Eléctrico\nPara conectar luces",
	inventory_image = "christmas_decor_wire.png",
})

-- ========================================
-- CHRISTMAS LIGHTS (Luces navideñas)
-- ========================================
local function register_lights(desc, nodename, aspect, length)
	minetest.register_node("wetlands_christmas:lights_" .. nodename, {
		description = desc .. " Navideñas\nLuces decorativas festivas",
		tiles = {
			{
				name = "christmas_decor_lights_" .. nodename .. ".png",
				backface_culling = false,
				animation = {
					type = "vertical_frames",
					aspect_w = aspect,
					aspect_h = aspect,
					length = length
				},
			}
		},
		inventory_image = "christmas_decor_lights_" .. nodename .. "_inv.png",
		wield_image = "christmas_decor_lights_" .. nodename .. "_inv.png",
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
		light_source = 10,
		paramtype2 = "wallmounted",
		groups = {handy=1, deco_block=1, dig_immediate=3, attached_node=1, christmas_lights=1},
		sounds = get_sound("leaves"),
		_mcl_blast_resistance = 0.1,
		_mcl_hardness = 0.1,
	})
end

-- Register all light types
register_lights("Luces Blancas", "white", 16, 6)
register_lights("Luces Blancas Carámbano", "white_icicle", 16, 6)
register_lights("Luces Multicolor", "multicolor", 16, 6)
register_lights("Luces Multicolor Bombilla", "multicolor_bulb", 8, 3)

-- ========================================
-- GARLAND (Guirnaldas)
-- ========================================
minetest.register_node("wetlands_christmas:garland", {
	description = "Guirnalda\nGuirnalda verde festiva",
	tiles = {"christmas_decor_garland.png"},
	inventory_image = "christmas_decor_garland.png",
	wield_image = "christmas_decor_garland.png",
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
	_mcl_blast_resistance = 0.1,
	_mcl_hardness = 0.1,
})

minetest.register_node("wetlands_christmas:garland_lights", {
	description = "Guirnalda con Luces\nGuirnalda con luces brillantes",
	tiles = {
		{
			name = "christmas_decor_garland_lights.png",
			backface_culling = false,
			animation = {
				type = "vertical_frames",
				aspect_w = 64,
				aspect_h = 64,
				length = 16
			},
		}
	},
	inventory_image = "christmas_decor_garland_lights_inv.png",
	wield_image = "christmas_decor_garland_lights_inv.png",
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
	light_source = 8,
	paramtype2 = "wallmounted",
	groups = {handy=1, deco_block=1, dig_immediate=3, attached_node=1},
	sounds = get_sound("leaves"),
	_mcl_blast_resistance = 0.1,
	_mcl_hardness = 0.1,
})

-- ========================================
-- CRAFTINGS (Simplified for VoxeLibre)
-- ========================================

-- Craft garland with lights
minetest.register_craft({
	output = "wetlands_christmas:garland_lights",
	type = "shapeless",
	recipe = {
		"wetlands_christmas:garland",
		"wetlands_christmas:led_white",
		"wetlands_christmas:led_white",
		"wetlands_christmas:led_white"
	},
})

-- Craft basic lights (simplified - sin basic_materials)
minetest.register_craft({
	output = "wetlands_christmas:lights_white 6",
	recipe = {
		{"wetlands_christmas:led_white", "wetlands_christmas:led_white", "wetlands_christmas:led_white"},
		{"wetlands_christmas:wire", "wetlands_christmas:wire", "wetlands_christmas:wire"},
		{"wetlands_christmas:led_white", "wetlands_christmas:led_white", "wetlands_christmas:led_white"},
	},
})

minetest.register_craft({
	output = "wetlands_christmas:lights_white_icicle 6",
	recipe = {
		{"wetlands_christmas:wire", "wetlands_christmas:wire", "wetlands_christmas:wire"},
		{"wetlands_christmas:led_white", "wetlands_christmas:led_white", "wetlands_christmas:led_white"},
		{"wetlands_christmas:led_white", "wetlands_christmas:led_white", "wetlands_christmas:led_white"},
	},
})

minetest.register_craft({
	output = "wetlands_christmas:lights_multicolor 6",
	recipe = {
		{"wetlands_christmas:led_rgb", "wetlands_christmas:led_rgb", "wetlands_christmas:led_rgb"},
		{"wetlands_christmas:wire", "wetlands_christmas:wire", "wetlands_christmas:wire"},
		{"wetlands_christmas:led_rgb", "wetlands_christmas:led_rgb", "wetlands_christmas:led_rgb"},
	},
})

minetest.log("action", "[wetlands_christmas] Lights loaded")