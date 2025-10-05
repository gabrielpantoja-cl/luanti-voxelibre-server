-- mcl_decor/src/table_lamp.lua

local S = ...

local on_def = {
	description = S("Table Lamp"),
	tiles = {"mcl_decor_table_lamp.png"},
	use_texture_alpha = "clip",
	drawtype = "mesh",
	mesh = "mcl_decor_table_lamp.obj",
	paramtype = "light",
	stack_max = 64,
	selection_box = {
		type = "fixed",
		fixed = {-0.3125, -0.5, -0.3125, 0.3125, 0.5, 0.3125},
	},
	collision_box = {
		type = "fixed",
		fixed = {-0.3125, -0.5, -0.3125, 0.3125, 0.5, 0.3125},
	},
	is_ground_content = false,
	light_source = core.LIGHT_MAX,
	groups = {handy=1, axey=1, attached_node=1, deco_block=1, flammable=-1},
	sounds = mcl_sounds.node_sound_wood_defaults(),
	_mcl_blast_resistance = 0.9,
	_mcl_hardness = 0.9,
	on_rightclick = function(pos, node, _, itemstack)
		core.set_node(pos, {name="mcl_decor:table_lamp_off"})
		core.sound_play("mesecons_button_push", {pos=pos, max_hear_distance=8}, true)
	end
}
core.register_node("mcl_decor:table_lamp", on_def)

local off_def = table.copy(on_def)

off_def.tiles = {"mcl_decor_table_lamp_off.png"}
off_def.light_source = nil
off_def.drop = "mcl_decor:table_lamp"
off_def.groups.not_in_creative_inventory = 1
off_def._doc_items_create_entry = false
off_def.on_rightclick = function(pos, node, _, itemstack)
	core.set_node(pos, {name="mcl_decor:table_lamp"})
	core.sound_play("mesecons_button_push", {pos=pos, max_hear_distance=8}, true)
end

core.register_node("mcl_decor:table_lamp_off", off_def)

core.register_craft({
	output = "mcl_decor:table_lamp 3",
	recipe = {
		{"group:wool", "group:wool", "group:wool"},
		{"group:wool", "mcl_torches:torch", "group:wool"},
		{"mcl_core:cobble", "mesecons:wire_00000000_off", "mcl_core:cobble"}
	}
})
