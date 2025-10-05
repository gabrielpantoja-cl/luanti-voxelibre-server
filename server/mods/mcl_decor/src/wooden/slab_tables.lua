-- mcl_decor/src/wooden/slab_tables.lua

function mcl_decor.register_slab_table(name, desc, material, tiles, flammable)
	local group
	if flammable == nil then
		group = {handy=1, axey=1, attached_node=1, material_wood=1, deco_block=1, slab_table=1, flammable=-1}
	else
		group = {handy=1, axey=1, attached_node=1, material_wood=1, deco_block=1, slab_table=1}
	end
	core.register_node("mcl_decor:"..name.."_stable", {
		description = desc,
		drawtype = "nodebox",
		node_box = {
			type = "fixed",
			fixed = {
				{-0.125, -0.5, -0.125, 0.125, 0, 0.125},
				{-0.5, 0, -0.5, 0.5, 0.5, 0.5},
			},
		},
		tiles = {tiles},
		is_ground_content = false,
		paramtype = "light",
		stack_max = 64,
		sunlight_propagates = true,
		groups = group,
		_mcl_hardness = 2,
		_mcl_blast_resistance = 3,
		sounds = mcl_sounds.node_sound_wood_defaults(),
	})
	core.register_craft({
		output = "mcl_decor:"..name.."_stable".." 3",
		recipe = {
			{material, material, material},
			{"", "mcl_core:stick", ""}
		}
	})
	core.register_craft({
		type = "fuel",
		recipe = "mcl_decor:"..name.."_stable",
		burntime = 10,
	})
end
