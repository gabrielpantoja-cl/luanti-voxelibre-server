-- mcl_decor/src/colored/armchairs.lua

local color, tbl = ...

local adef = {
	description = tbl.armchair_desc,
	drawtype = "nodebox",
	node_box = {
		type = "connected",
		fixed = {
			{-0.5, -0.5, -0.5, 0.5, -0.0625, 0.1875},
			{-0.5, -0.5, 0.1875, 0.5, 0.5, 0.5},
		},
		disconnected_sides = {
			{-0.5, -0.4375, -0.5, -0.3125, 0.125, 0.1875},
			{0.3125, -0.4375, -0.5, 0.5, 0.125, 0.1875},
		},
		disconnected_right = {
			{0.3125, -0.4375, -0.5, 0.5, 0.125, 0.1875},
		},
		disconnected_left = {
			{-0.5, -0.4375, -0.5, -0.3125, 0.125, 0.1875},
		},
	},
	connects_to = {"group:armchair"},
	tiles = {tbl.wooltile..".png"},
	is_ground_content = false,
	paramtype = "light",
	paramtype2 = "4dir",
	place_param2 = 0,
	stack_max = 64,
	selection_box = {
		type = "fixed",
		fixed = { -0.5, -0.5, -0.5, 0.5, 0.5, 0.5 },
	},
	_mcl_cozy_offset = vector.new(0, 0, 0.1),
	groups = {handy=1, shearsy_wool=1, attached_node=1, deco_block=1, armchair=1, flammable=1, fire_encouragement=30, fire_flammability=60, [tbl.colorgroup]=1},
	_mcl_hardness = 1,
	_mcl_blast_resistance = 1,
	sounds = mcl_sounds.node_sound_wood_defaults(),
	on_rightclick = mcl_cozy.sit,
	on_place = function(itemstack, placer, pointed_thing)
		if pointed_thing.type ~= "node" then
			return itemstack
		end

		-- Call on_rightclick if the pointed node defines it
		local node = core.get_node(pointed_thing.under)
		if placer and not placer:get_player_control().sneak then
			if core.registered_nodes[node.name] and core.registered_nodes[node.name].on_rightclick then
				return core.registered_nodes[node.name].on_rightclick(pointed_thing.under, node, placer, itemstack) or itemstack
			end
		end

		local facedir = core.dir_to_facedir(placer:get_look_dir(), false)
		local name = "mcl_decor:"..color.."_armchair"

		if facedir == 0 then
			itemstack:set_name(name)
		elseif facedir == 1 then
			itemstack:set_name(name.."_1")
		elseif facedir == 2 then
			itemstack:set_name(name.."_2")
		elseif facedir == 3 then
			itemstack:set_name(name.."_3")
		end

		local new_itemstack = core.item_place_node(itemstack, placer, pointed_thing, facedir)
		new_itemstack:set_name(name)

		return new_itemstack
	end,
}
core.register_node("mcl_decor:"..color.."_armchair", adef)

-- register directional variations of armchairs
local adef2 = table.copy(adef)
adef2.drop = "mcl_decor:"..color.."_armchair"
adef2._doc_items_create_entry = false
adef2.groups.armchair = nil
adef2.groups.not_in_creative_inventory = 1
adef2.groups.armchair_1 = 1
adef2.place_param2 = 1
adef2.node_box = {
	type = "connected",
	fixed = {
		{ -0.5, -0.5, -0.5, 0.1875, -0.0625, 0.5 },
		{ 0.1875, -0.5, -0.5, 0.5, 0.5, 0.5 },
	},
	disconnected_front = {
		{ -0.5, -0.4375, -0.5, 0.1875, 0.125, -0.3125 },
	},
	disconnected_back = {
		{ -0.5, -0.4375, 0.3125, 0.1875, 0.125, 0.5 },
	},
}
adef2.connects_to = {"group:armchair_1"}
core.register_node("mcl_decor:"..color.."_armchair_1", adef2)

local adef3 = table.copy(adef2)
adef3.groups.armchair_1 = nil
adef3.groups.armchair_2 = 1
adef3.place_param2 = 2
adef3.node_box = {
	type = "connected",
	fixed = {
		{ -0.5, -0.5, -0.1875, 0.5, -0.0625, 0.5 },
		{ -0.5, -0.5, -0.5, 0.5, 0.5, -0.1875 },
	},
	disconnected_right = {
		{ 0.3125, -0.4375, -0.1875, 0.5, 0.125, 0.5 },
	},
	disconnected_left = {
		{ -0.5, -0.4375, -0.1875, -0.3125, 0.125, 0.5 },
	},
}
adef3.connects_to = {"group:armchair_2"}
core.register_node("mcl_decor:"..color.."_armchair_2", adef3)

local adef4 = table.copy(adef3)
adef4.groups.armchair_2 = nil
adef4.groups.armchair_3 = 1
adef4.place_param2 = 3
adef4.node_box = {
	type = "connected",
	fixed = {
		{ -0.1875, -0.5, -0.5, 0.5, -0.0625, 0.5 },
		{ -0.5, -0.5, -0.5, -0.1875, 0.5, 0.5 },
	},
	disconnected_back = {
		{ -0.1875, -0.4375, 0.3125, 0.5, 0.125, 0.5 },
	},
	disconnected_front = {
		{ -0.1875, -0.4375, -0.5, 0.5, 0.125, -0.3125 },
	},
}
adef4.connects_to = {"group:armchair_3"}
core.register_node("mcl_decor:"..color.."_armchair_3", adef4)

-- prevent doc entry spam
for i=1,3 do
	doc.add_entry_alias("nodes", "mcl_decor:"..color.."_armchair", "nodes", "mcl_decor:"..color.."_armchair_"..i)
end

core.register_lbm({
	name = "mcl_decor:"..color.."_armchair_facedir",
	nodenames = {"mcl_decor:"..color.."_armchair"},
	action = function(pos, node)
		if node.param2 == 1 then
			core.set_node(pos, {name="mcl_decor:"..color.."_armchair_1"})
		elseif node.param2 == 2 then
			core.set_node(pos, {name="mcl_decor:"..color.."_armchair_2"})
		elseif node.param2 == 3 then
			core.set_node(pos, {name="mcl_decor:"..color.."_armchair_3"})
		end
	end
})

core.register_craft({
	output = "mcl_decor:"..color.."_armchair",
	recipe = {
		{"", "", "mcl_wool:"..color},
		{"mcl_wool:"..color, "mcl_wool:"..color, "mcl_wool:"..color},
		{"mcl_core:stick", "mcl_core:stick", "mcl_core:stick"}
	}
})

core.register_craft({
	output = "mcl_decor:"..color.."_armchair",
	recipe = {
		{"mcl_wool:"..color, "", ""},
		{"mcl_wool:"..color, "mcl_wool:"..color, "mcl_wool:"..color},
		{"mcl_core:stick", "mcl_core:stick", "mcl_core:stick"}
	}
})

core.register_craft({
	type = "shapeless",
	output = "mcl_decor:"..color.."_armchair",
	recipe = {"group:armchair", "mcl_dye:"..tbl.dye},
})

core.register_craft({
	type = "fuel",
	recipe = "mcl_decor:"..color.."_armchair",
	burntime = 10,
})
