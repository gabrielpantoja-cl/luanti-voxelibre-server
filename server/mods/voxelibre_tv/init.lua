-- VoxeLibre TV Mod
-- Original by tony-ka, adapted for VoxeLibre by gabriel
-- Adds an animated television with multiple channels

-- TV Off State
minetest.register_node("voxelibre_tv:off", {
	description = "Televisor",
	tiles = {
		"voxelibre_tv_top.png",
		"voxelibre_tv_top.png",
		"voxelibre_tv_left.png",
		"voxelibre_tv_right.png",
		"voxelibre_tv_back.png",
		"voxelibre_tv_off.png"
	},
	drawtype = "nodebox",
	paramtype = "light",
	paramtype2 = "facedir",
	groups = {choppy=2, oddly_breakable_by_hand=2, handy=1},
	node_box = {
		type = "fixed",
		fixed = {
			{-0.5, -0.5, 0.0, 0.5, 0.3, 0.5},
		}
	},
	selection_box = {
		type = "fixed",
		fixed = {
			{-0.5, -0.5, 0.0, 0.5, 0.3, 0.5},
		}
	},
	on_punch = function(pos, node)
		minetest.set_node(pos, {name="voxelibre_tv:channel_1", param2=node.param2})
	end,
	_mcl_blast_resistance = 3,
	_mcl_hardness = 2,
})

-- TV Channel 1
minetest.register_node("voxelibre_tv:channel_1", {
	description = "Televisor (Canal 1)",
	tiles = {
		"voxelibre_tv_top.png",
		"voxelibre_tv_top.png",
		"voxelibre_tv_left.png",
		"voxelibre_tv_right.png",
		"voxelibre_tv_back.png",
		{
			name = "voxelibre_tv_channel_1.png",
			animation = {
				type = "vertical_frames",
				aspect_w = 16,
				aspect_h = 16,
				length = 2.0
			},
		}
	},
	drawtype = "nodebox",
	paramtype = "light",
	paramtype2 = "facedir",
	light_source = 8,
	groups = {choppy=2, oddly_breakable_by_hand=2, handy=1, not_in_creative_inventory=1},
	drop = "voxelibre_tv:off",
	node_box = {
		type = "fixed",
		fixed = {
			{-0.5, -0.5, 0.0, 0.5, 0.3, 0.5},
		}
	},
	selection_box = {
		type = "fixed",
		fixed = {
			{-0.5, -0.5, 0.0, 0.5, 0.3, 0.5},
		}
	},
	on_punch = function(pos, node)
		minetest.set_node(pos, {name="voxelibre_tv:channel_2", param2=node.param2})
	end,
	_mcl_blast_resistance = 3,
	_mcl_hardness = 2,
})

-- TV Channel 2
minetest.register_node("voxelibre_tv:channel_2", {
	description = "Televisor (Canal 2)",
	tiles = {
		"voxelibre_tv_top.png",
		"voxelibre_tv_top.png",
		"voxelibre_tv_left.png",
		"voxelibre_tv_right.png",
		"voxelibre_tv_back.png",
		{
			name = "voxelibre_tv_channel_2.png",
			animation = {
				type = "vertical_frames",
				aspect_w = 16,
				aspect_h = 16,
				length = 2.0
			},
		}
	},
	drawtype = "nodebox",
	paramtype = "light",
	paramtype2 = "facedir",
	light_source = 8,
	groups = {choppy=2, oddly_breakable_by_hand=2, handy=1, not_in_creative_inventory=1},
	drop = "voxelibre_tv:off",
	node_box = {
		type = "fixed",
		fixed = {
			{-0.5, -0.5, 0.0, 0.5, 0.3, 0.5},
		}
	},
	selection_box = {
		type = "fixed",
		fixed = {
			{-0.5, -0.5, 0.0, 0.5, 0.3, 0.5},
		}
	},
	on_punch = function(pos, node)
		minetest.set_node(pos, {name="voxelibre_tv:channel_3", param2=node.param2})
	end,
	_mcl_blast_resistance = 3,
	_mcl_hardness = 2,
})

-- TV Channel 3
minetest.register_node("voxelibre_tv:channel_3", {
	description = "Televisor (Canal 3)",
	tiles = {
		"voxelibre_tv_top.png",
		"voxelibre_tv_top.png",
		"voxelibre_tv_left.png",
		"voxelibre_tv_right.png",
		"voxelibre_tv_back.png",
		{
			name = "voxelibre_tv_channel_3.png",
			animation = {
				type = "vertical_frames",
				aspect_w = 16,
				aspect_h = 16,
				length = 2.0
			},
		}
	},
	drawtype = "nodebox",
	paramtype = "light",
	paramtype2 = "facedir",
	light_source = 8,
	groups = {choppy=2, oddly_breakable_by_hand=2, handy=1, not_in_creative_inventory=1},
	drop = "voxelibre_tv:off",
	node_box = {
		type = "fixed",
		fixed = {
			{-0.5, -0.5, 0.0, 0.5, 0.3, 0.5},
		}
	},
	selection_box = {
		type = "fixed",
		fixed = {
			{-0.5, -0.5, 0.0, 0.5, 0.3, 0.5},
		}
	},
	on_punch = function(pos, node)
		minetest.set_node(pos, {name="voxelibre_tv:off", param2=node.param2})
	end,
	_mcl_blast_resistance = 3,
	_mcl_hardness = 2,
})

-- Crafting Recipe (uses iron ingots instead of steel)
if minetest.get_modpath("mcl_core") then
	minetest.register_craft({
		output = "voxelibre_tv:off",
		recipe = {
			{"mcl_core:iron_ingot", "mcl_core:iron_ingot", ""},
			{"mcl_core:iron_ingot", "mcl_core:iron_ingot", ""},
			{"", "", ""}
		}
	})
else
	-- Fallback for testing without VoxeLibre
	minetest.log("warning", "[voxelibre_tv] mcl_core not found, TV won't be craftable")
end

minetest.log("action", "[voxelibre_tv] Mod loaded successfully")