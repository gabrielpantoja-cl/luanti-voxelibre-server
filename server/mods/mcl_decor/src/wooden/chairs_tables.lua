-- mcl_decor/src/wooden/chairs_tables.lua

function mcl_decor.register_chair_and_table(name, desc, desc2, material, tiles, flammable)
	local group = {handy=1, axey=1, attached_node=1, material_wood=1, deco_block=1}
	local burntime = 0
	-- assume flammable by default
	if flammable or (flammable == nil) then
		group.fire_encouragement = 5
		group.fire_flammability = 20
		burntime = 8
	end

	-- chair part
	core.register_node("mcl_decor:"..name.."_chair", {
		description = desc,
		drawtype = "nodebox",
		node_box = {
			type = "fixed",
			fixed = {
				{-0.25, 0, 0.125, 0.25, 0.5, 0.25},
				{-0.25, -0.125, -0.25, 0.25, 0, 0.25},
				{-0.25, -0.5, 0.125, -0.125, -0.125, 0.25},
				{0.125, -0.5, -0.25, 0.25, -0.125, -0.125},
				{0.125, -0.5, 0.125, 0.25, -0.125, 0.25},
				{-0.25, -0.5, -0.25, -0.125, -0.125, -0.125},
			}
		},
		tiles = {tiles},
		is_ground_content = false,
		paramtype = "light",
		paramtype2 = "facedir",
		stack_max = 64,
		sunlight_propagates = true,
		selection_box = {
			type = "fixed",
			fixed = { -0.25, -0.5, -0.25, 0.25, 0.5, 0.25 },
		},
		groups = group,
		_mcl_hardness = 1,
		_mcl_blast_resistance = 1,
		sounds = mcl_sounds.node_sound_wood_defaults(),
		on_rightclick = mcl_cozy.sit
	})
	core.register_craft({
		output = "mcl_decor:"..name.."_chair",
		recipe = {
			{"", "", "mcl_core:stick"},
			{material, material, material},
			{"mcl_core:stick", "", "mcl_core:stick"}
		}
	})
	core.register_craft({
		output = "mcl_decor:"..name.."_chair",
		recipe = {
			{"mcl_core:stick", "", ""},
			{material, material, material},
			{"mcl_core:stick", "", "mcl_core:stick"}
		}
	})
	core.register_craft({
		type = "fuel",
		recipe = "mcl_decor:"..name.."_chair",
		burntime = burntime,
	})

	group.table = 1

	-- table part
	core.register_node("mcl_decor:"..name.."_table", {
		description = desc2,
		drawtype = "nodebox",
		node_box = {
			type = "fixed",
			fixed = {
				{ -0.5, 0.375, -0.5, 0.5, 0.5, 0.5 },
				{ -0.4375, -0.5, -0.4375, -0.3125, 0.375, -0.3125 },
				{ 0.3125, -0.5, -0.4375, 0.4375, 0.375, -0.3125 },
				{ 0.3125, -0.5, 0.3125, 0.4375, 0.375, 0.4375 },
				{ -0.4375, -0.5, 0.3125, -0.3125, 0.375, 0.4375 },
			},
		},
		selection_box = {
			type = "fixed",
			fixed = { -0.5, -0.5, -0.5, 0.5, 0.5, 0.5 },
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
		output = "mcl_decor:"..name.."_table".." 2",
		recipe = {
			{material, material, material},
			{"mcl_core:stick", "", "mcl_core:stick"},
			{"mcl_core:stick", "", "mcl_core:stick"}
		}
	})
	core.register_craft({
		type = "fuel",
		recipe = "mcl_decor:"..name.."_table",
		burntime = 10,
	})
end
