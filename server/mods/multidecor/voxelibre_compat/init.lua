-- VoxeLibre Compatibility Layer for Multidecor
-- This mod provides compatibility between Minetest default API and VoxeLibre

-- Create default namespace if it doesn't exist
default = default or {}

-- Sound definitions compatible with VoxeLibre
function default.node_sound_stone_defaults()
	return mcl_sounds and mcl_sounds.node_sound_stone_defaults() or {
		footstep = {name = "default_hard_footstep", gain = 0.3},
		dug = {name = "default_hard_footstep", gain = 1.0},
		place = {name = "default_place_node_hard", gain = 1.0}
	}
end

function default.node_sound_wood_defaults()
	return mcl_sounds and mcl_sounds.node_sound_wood_defaults() or {
		footstep = {name = "default_wood_footstep", gain = 0.3},
		dug = {name = "default_wood_footstep", gain = 1.0},
		place = {name = "default_place_node", gain = 1.0}
	}
end

function default.node_sound_metal_defaults()
	return mcl_sounds and mcl_sounds.node_sound_metal_defaults() or {
		footstep = {name = "default_metal_footstep", gain = 0.3},
		dug = {name = "default_metal_footstep", gain = 1.0},
		place = {name = "default_place_node_metal", gain = 1.0}
	}
end

function default.node_sound_glass_defaults()
	return mcl_sounds and mcl_sounds.node_sound_glass_defaults() or {
		footstep = {name = "default_glass_footstep", gain = 0.3},
		dug = {name = "default_break_glass", gain = 1.0},
		place = {name = "default_place_node_hard", gain = 1.0}
	}
end

-- Item aliases: Minetest default → VoxeLibre
-- These aliases redirect old item names to VoxeLibre equivalents

-- Clay
minetest.register_alias("default:clay_lump", "mcl_core:clay_lump")
minetest.register_alias("default:clay", "mcl_core:clay")

-- Paper and books
minetest.register_alias("default:paper", "mcl_core:paper")
minetest.register_alias("default:book", "mcl_books:book")

-- Basic materials
minetest.register_alias("default:stick", "mcl_core:stick")
minetest.register_alias("default:wood", "mcl_core:wood")
minetest.register_alias("default:stone", "mcl_core:stone")
minetest.register_alias("default:cobble", "mcl_core:cobble")
minetest.register_alias("default:dirt", "mcl_core:dirt")
minetest.register_alias("default:sand", "mcl_core:sand")
minetest.register_alias("default:gravel", "mcl_core:gravel")

-- Metals and minerals
minetest.register_alias("default:iron_lump", "mcl_core:iron_nugget")
minetest.register_alias("default:iron_ingot", "mcl_core:iron_ingot")
minetest.register_alias("default:steel_ingot", "mcl_core:iron_ingot")
minetest.register_alias("default:gold_lump", "mcl_core:gold_nugget")
minetest.register_alias("default:gold_ingot", "mcl_core:gold_ingot")
minetest.register_alias("default:coal_lump", "mcl_core:coal_lump")
minetest.register_alias("default:diamond", "mcl_core:diamond")

-- Glass
minetest.register_alias("default:glass", "mcl_core:glass")
minetest.register_alias("default:obsidian_glass", "mcl_core:obsidian")

-- Wool
minetest.register_alias("default:wool_white", "mcl_wool:white")

-- Dyes (VoxeLibre uses mcl_dye)
local dye_colors = {
	"white", "grey", "dark_grey", "black",
	"red", "orange", "yellow", "green",
	"dark_green", "blue", "cyan", "violet",
	"magenta", "pink", "brown"
}

for _, color in ipairs(dye_colors) do
	-- Map dye:color to mcl_dye:color
	minetest.register_alias("dye:" .. color, "mcl_dye:" .. color)
end

-- Beds
minetest.register_alias("beds:bed", "mcl_beds:bed_red")

-- Flowers
minetest.register_alias("flowers:rose", "mcl_flowers:poppy")
minetest.register_alias("flowers:dandelion_yellow", "mcl_flowers:dandelion")

-- Buckets
minetest.register_alias("bucket:bucket_water", "mcl_buckets:bucket_water")
minetest.register_alias("bucket:bucket_empty", "mcl_buckets:bucket_empty")
minetest.register_alias("bucket:bucket_lava", "mcl_buckets:bucket_lava")

-- Farming
minetest.register_alias("farming:wheat", "mcl_farming:wheat_item")
minetest.register_alias("farming:cotton", "mcl_farming:cotton_item")

-- Wood types
minetest.register_alias("default:wood", "mcl_core:wood")
minetest.register_alias("default:oakwood", "mcl_core:wood")
minetest.register_alias("default:pinewood", "mcl_core:sprucewood")
minetest.register_alias("default:aspenwood", "mcl_core:birchwood")
minetest.register_alias("default:junglewood", "mcl_core:junglewood")
minetest.register_alias("default:acacia_wood", "mcl_core:acaciawood")

-- Leaves
minetest.register_alias("default:leaves", "mcl_core:leaves")

-- Clay and brick
minetest.register_alias("default:clay_brick", "mcl_core:brick")

-- More metals
minetest.register_alias("default:copper_ingot", "mcl_copper:copper_ingot")
minetest.register_alias("default:tin_ingot", "mcl_core:iron_ingot") -- VoxeLibre doesn't have tin, use iron

-- Stairs (if using xpanes in recipes)
minetest.register_alias("xpanes:pane_flat", "mcl_core:glass")
minetest.register_alias("stairs:slab_glass", "mcl_stairs:slab_glass")

-- Log compatibility messages
minetest.log("action", "[Multidecor VoxeLibre Compat] Compatibility layer loaded successfully")
minetest.log("action", "[Multidecor VoxeLibre Compat] All item aliases registered for VoxeLibre")
