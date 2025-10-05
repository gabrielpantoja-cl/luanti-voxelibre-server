-- mcl_decor/src/colored/dyed_wood.lua

local color, tbl, S = ...

local planks_name = "mcl_decor:"..color.."_planks"
local planks_tile = "mcl_decor_dyed_planks.png^[colorize:"..tbl.hexcolor..":125"

core.register_node(planks_name, {
	description = tbl.planks_desc,
	tiles = {planks_tile},
	stack_max = 64,
	is_ground_content = false,
	groups = {handy=1, axey=1, flammable=3, wood=1, building_block=1, material_wood=1, fire_encouragement=5, fire_flammability=20, [tbl.colorgroup]=1},
	sounds = mcl_sounds.node_sound_wood_defaults(),
	_mcl_blast_resistance = 3,
	_mcl_hardness = 2,
})

core.register_craft({
	type = "shapeless",
	output = planks_name,
	recipe = {"group:wood", "mcl_dye:"..tbl.dye}
})

mcl_stairs.register_stair_and_slab_simple(
	color.."_planks",
	planks_name,
	S("@1 Stair", tbl.planks_desc),
	S("@1 Slab", tbl.planks_desc),
	S("Double @1 Slab", tbl.planks_desc),
	"woodlike"
)

local wood_def = core.registered_nodes["mcl_core:wood"]

mcl_fences.register_fence_and_fence_gate(
	color.."_fence",
	tbl.fence_desc,
	tbl.fence_gate_desc,
	planks_tile,
	{handy=1, axey=1, flammable=2, fence_wood=1, fire_encouragement=5, fire_flammability=20, [tbl.colorgroup]=1},
	wood_def._mcl_hardness,
	wood_def._mcl_blast_resistance,
	{"group:fence_wood"},
	mcl_sounds.node_sound_wood_defaults()
)

core.register_craft({
	output = "mcl_decor:"..color.."_fence 3",
	recipe = {
		{planks_name, "mcl_core:stick", planks_name},
		{planks_name, "mcl_core:stick", planks_name},
	},
})

core.register_craft({
	output = "mcl_decor:"..color.."_fence_gate",
	recipe = {
		{"mcl_core:stick", planks_name, "mcl_core:stick"},
		{"mcl_core:stick", planks_name, "mcl_core:stick"},
	},
})

core.register_craft({
	type = "shapeless",
	output = "mcl_decor:"..color.."_fence",
	recipe = {"group:fence_wood", "mcl_dye:"..tbl.dye}
})

core.register_craft({
	type = "shapeless",
	output = "mcl_decor:"..color.."_fence_gate",
	recipe = {"group:fence_gate,fence_wood", "mcl_dye:"..tbl.dye}
})
