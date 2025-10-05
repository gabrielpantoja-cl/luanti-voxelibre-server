-- mcl_decor/src/colored/curtains.lua

local color, tbl, S = ...

core.register_node("mcl_decor:curtain_"..color, {
	description = tbl.curtains_desc,
	tiles = {
		-- very hacky way to make curtains render as they should
		tbl.wooltile..".png^mcl_decor_curtain_alpha.png^[makealpha:255,126,126^mcl_decor_curtain_overlay.png",
		tbl.wooltile..".png^mcl_decor_curtain_alpha.png^[makealpha:255,126,126^mcl_decor_curtain_overlay.png^[transformFY",
		tbl.wooltile..".png^mcl_decor_curtain_overlay.png^[transformR270",
		tbl.wooltile..".png^mcl_decor_curtain_overlay.png^[transformR90",
		tbl.wooltile..".png^mcl_decor_curtain_overlay.png^[transformFY",
		tbl.wooltile..".png^mcl_decor_curtain_alpha.png^[makealpha:255,126,126^mcl_decor_curtain_overlay.png",
	},
	use_texture_alpha = "clip",
	stack_max = 64,
	inventory_image = tbl.wooltile..".png^mcl_decor_curtain_alpha.png^[makealpha:255,126,126^mcl_decor_curtain_overlay.png",
	wield_image = tbl.wooltile..".png^mcl_decor_curtain_alpha.png^[makealpha:255,126,126^mcl_decor_curtain_overlay.png",
	walkable = false,
	sunlight_propagates = true,
	drawtype = "nodebox",
	paramtype = "light",
	paramtype2 = "wallmounted",
	groups = {handy=1, flammable=-1, curtain=1, attached_node=1, dig_by_piston=1, deco_block=1, material_wool=1, [tbl.colorgroup]=1},
	sounds = mcl_sounds.node_sound_wood_defaults(),
	node_box = {
		type = "wallmounted",
	},
	_mcl_blast_resistance = 0.2,
	_mcl_hardness = 0.2,
	on_place = function(itemstack, placer, pointed_thing)
		local rc = mcl_util.call_on_rightclick(itemstack, placer, pointed_thing)
		if rc then
			return rc
		end

		local wdir = core.dir_to_wallmounted(pointed_thing.under - pointed_thing.above)
		-- restrict placing on floors/ceilings
		if wdir == 0 or wdir == 1 then return end

		itemstack = core.item_place(itemstack, placer, pointed_thing, wdir)
		return itemstack
	end,
	-- function to close curtains
	on_rightclick = function(pos, node, _, itemstack)
		core.set_node(pos, {name="mcl_decor:curtain_"..color.."_closed", param2=node.param2})
		-- play the sound
		core.sound_play("mcl_decor_curtain", {
			pos = pos,
			max_hear_distance = 8
		}, true)
		return itemstack
	end
})

core.register_node("mcl_decor:curtain_"..color.."_closed", {
	description = S("@1 (closed)", tbl.curtains_desc),
	tiles = {
		tbl.wooltile..".png^mcl_decor_curtain_overlay.png",
		tbl.wooltile..".png^mcl_decor_curtain_overlay.png^[transformFY",
		tbl.wooltile..".png^mcl_decor_curtain_overlay.png^[transformR270",
		tbl.wooltile..".png^mcl_decor_curtain_overlay.png^[transformR90",
		tbl.wooltile..".png^mcl_decor_curtain_overlay.png^[transformFY",
		tbl.wooltile..".png^mcl_decor_curtain_overlay.png",
	},
	use_texture_alpha = "clip",
	walkable = false,
	sunlight_propagates = true,
	drawtype = "nodebox",
	paramtype = "light",
	paramtype2 = "wallmounted",
	groups = {handy=1, flammable=-1, attached_node=1, dig_by_piston=1, not_in_creative_inventory=1},
	sounds = mcl_sounds.node_sound_wood_defaults(),
	node_box = {
		type = "wallmounted",
	},
	drop = "mcl_decor:curtain_"..color,
	_mcl_blast_resistance = 0.2,
	_mcl_hardness = 0.2,
	-- function to open curtains
	on_rightclick = function(pos, node, clicker, itemstack)
		core.set_node(pos, {name="mcl_decor:curtain_"..color, param2=node.param2})
		-- play the sound
		core.sound_play("mcl_decor_curtain", {
			pos = pos,
			max_hear_distance = 8
		}, true)
		return itemstack
	end
})

core.register_craft({
	output = "mcl_decor:curtain_"..color,
	recipe = {
		{"mcl_core:iron_nugget", "mcl_core:stick", "mcl_core:iron_nugget"},
		{"mcl_wool:"..color, "mcl_wool:"..color, "mcl_wool:"..color},
		{"mcl_wool:"..color, "", "mcl_wool:"..color}
	}
})

core.register_craft({
	type = "shapeless",
	output = "mcl_decor:curtain_"..color,
	recipe = {"group:curtain", "mcl_dye:"..tbl.dye},
})
