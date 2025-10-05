-- mcl_decor/src/coalquartz.lua

local S = ...

core.register_node("mcl_decor:checkerboard_tile", {
	description = S("Checkerboard Tile"),
	tiles = {"mcl_decor_coalquartz_tile.png"},
	is_ground_content = false,
	groups = {pickaxey=1, quartz_block=1, building_block=1, material_stone=1},
	sounds = mcl_sounds.node_sound_stone_defaults(),
	_mcl_blast_resistance = 4,
	_mcl_hardness = 3,
})

core.register_craft({
	output = "mcl_decor:checkerboard_tile 4",
	recipe = {
		{"mcl_blackstone:blackstone", "mcl_nether:quartz_block"},
		{"mcl_nether:quartz_block", "mcl_blackstone:blackstone"}
	}
})

core.register_craft({
	output = "mcl_decor:checkerboard_tile 4",
	recipe = {
		{"mcl_nether:quartz_block", "mcl_blackstone:blackstone"},
		{"mcl_blackstone:blackstone", "mcl_nether:quartz_block"}
	}
})

mcl_stairs.register_stair_and_slab_simple(
	"checkerboard_tile",
	"mcl_decor:checkerboard_tile",
	S("Checkerboard Stair"),
	S("Checkerboard Slab"),
	S("Double Checkerboard Slab")
)
