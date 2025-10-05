-- mcl_decor/src/hedges.lua

local S = ...

-- API
function mcl_decor.register_hedge(name, desc, material, tiles, color, paramtype2, palette, foliage_palette)
	-- register the node
	local nodename = "mcl_decor:"..name.."_hedge"
	local def = {
		description = desc,
		tiles = {tiles},
		use_texture_alpha = "clip",
		drawtype = "nodebox",
		paramtype = "light",
		paramtype2 = paramtype2,
		color = color,
		palette = palette,
		is_ground_content = false,
		sunlight_propagates = true,
		connects_to = {"group:hedge", "group:leaves"},
		node_box = {
			type = "connected",
			fixed = {-4/16, -8/16, -4/16, 4/16, 8/16, 4/16},
			connect_front = {-3/16, -8/16, -8/16, 3/16, 8/16, -4/16},
			connect_back = {-3/16, -8/16, 4/16, 3/16, 8/16, 8/16},
			connect_right = {4/16, -8/16, -3/16, 8/16, 8/16, 3/16},
			connect_left = {-8/16, -8/16, -3/16, -4/16, 8/16, 3/16},
		},
		collision_box = {
			type = "fixed",
			fixed = {-4/16, -8/16, -4/16, 4/16, 16/16, 4/16}
		},
		groups = {
			handy = 1, axey = 1, hedge = 1, deco_block = 1,
			flammable = 2, fire_encouragement = 10,
			fire_flammability = 10, foliage_palette = foliage_palette
		},
		sounds = mcl_sounds.node_sound_leaves_defaults(),
		_mcl_blast_resistance = 1,
		_mcl_hardness = 1,
	}
	if mcl_core.get_foliage_block_type then -- VoxeLibre-only
		def.on_construct = function(pos)
			local node = core.get_node(pos)
			local new_node = mcl_core.get_foliage_block_type(pos)
			if new_node.param2 ~= node.param2 then
				core.swap_node(pos, new_node)
			end
		end
	end
	core.register_node(nodename, def)

	-- crafting recipe
	core.register_craft({
		output = nodename .. " 6",
		recipe = {
			{material, "mcl_core:stick", material},
			{material, "mcl_core:stick", material},
		}
	})
end

local function readable_name(str)
	str = str:gsub("_", " ")
	return (str:gsub("^%l", string.upper))
end

local leaves = {
	["oak"] = {
		desc = S("Oak Hedge"),
		material = "mcl_core:leaves",
	},
	["dark"] = {
		desc = S("Dark Oak Hedge"),
		material = "mcl_core:darkleaves",
	},
	["jungle"] = {
		desc = S("Jungle Hedge"),
		material = "mcl_core:jungleleaves",
	},
	["acacia"] = {
		desc = S("Acacia Hedge"),
		material = "mcl_core:acacialeaves",
	},
	["spruce"] = {
		desc = S("Spruce Hedge"),
		material = "mcl_core:spruceleaves",
	},
	["birch"] = {
		desc = S("Birch Hedge"),
		material = "mcl_core:birchleaves",
	},
	["mangrove"] = {
		desc = S("Mangrove Hedge"),
		material = "mcl_mangrove:mangroveleaves",
	},
	["cherry"] = {
		desc = S("Cherry Hedge"),
		material = "mcl_cherry_blossom:cherryleaves",
	},
}

local leaves_lush_caves = {
	["azalea"] = {
		desc = S("Azalea Hedge"),
		material = "mcl_lush_caves:azalea_leaves",
	},
	["azalea_flowering"] = {
		desc = S("Flowering Azalea Hedge"),
		material = "mcl_lush_caves:azalea_leaves_flowering",
	},
}

local function register_bulk(tables)
	for name, tbl in pairs(tables) do
		local def = core.registered_nodes[tbl.material]
		mcl_decor.register_hedge(name, tbl.desc, tbl.material, def.tiles[1], def.color, def.paramtype2, def.palette, def.groups.foliage_palette)
	end
end

if core.get_modpath("mcl_trees") then
	-- mineclonia, use mcl_trees api
	leaves.dark_oak = leaves.dark
	leaves.cherry_blossom = leaves.cherry
	for name, tbl in pairs(mcl_trees.woods) do
		local rname = readable_name(name)
		local material = "mcl_trees:leaves_"..name
		local ldef = core.registered_nodes[material]
		if ldef then
			mcl_decor.register_hedge(name, S(rname.." Hedge"), material, ldef.tiles[1], ldef.color, ldef.paramtype2, ldef.palette, 1)
		end
	end
else
	register_bulk(leaves)
end

if core.get_modpath("mcl_lush_caves") then -- lush caves support
	register_bulk(leaves_lush_caves)
end

-- all hedges should be fuel
core.register_craft({
	type = "fuel",
	recipe = "group:hedge",
	burntime = 5,
})
