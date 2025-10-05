-- mcl_decor/src/counter.lua

local S = ...

core.register_node("mcl_decor:counter", {
	description = S("Counter"),
	tiles = {
		"default_obsidian.png",
		"default_obsidian.png",
		"default_obsidian.png^[lowpart:87:mcl_nether_quartz_block_bottom.png",
	},
	drawtype = "nodebox",
	paramtype = "light",
	node_box = {
		type = "connected",
		fixed = {
			{-0.5, 0.375, -0.5, 0.5, 0.5, 0.5}, -- countertop
			{-0.4375, -0.5, -0.4375, 0.4375, 0.375, 0.4375}, -- base
		},
		connect_front = {
			{-0.4375, -0.5, -0.5, 0.4375, 0.375, -0.4375},
		},
		connect_back = {
			{-0.4375, -0.5, 0.4375, 0.4375, 0.375, 0.5},
		},
		connect_left = {
			{-0.5, -0.5, -0.4375, -0.4375, 0.375, 0.4375},
		},
		connect_right = {
			{0.4375, -0.5, -0.4375, 0.5, 0.375, 0.4375},
		},
	},
	connects_to = {"mcl_decor:counter", "mcl_decor:oven", "mcl_core:obsidian", "group:quartz_block"},
	groups = {pickaxey=1, deco_block=1, material_stone=1},
	sounds = mcl_sounds.node_sound_stone_defaults(),
	_mcl_blast_resistance = 1.4,
	_mcl_hardness = 1.2,
})

core.register_craft({
	output = "mcl_decor:counter 2",
	recipe = {
		{"mcl_nether:quartz", "mcl_core:obsidian", "mcl_nether:quartz"},
		{"mcl_nether:quartz", "mcl_nether:quartz", "mcl_nether:quartz"},
		{"mcl_nether:quartz", "mcl_nether:quartz", "mcl_nether:quartz"},
	}
})
