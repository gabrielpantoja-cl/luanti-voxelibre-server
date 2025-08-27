local mod = vegan_food
local S = core.get_translator(core.get_current_modname())

core.register_craftitem(mod.craftitems.raw_seitan, {
	description = S("Raw Seitan"),
	_doc_items_longdesc = S("A raw gluten dough. Cooking it improves its nutritional value."),
	inventory_image = "vegan_food_raw_seitan.png",
	wield_image = "vegan_food_raw_seitan.png",
	on_place = core.item_eat(3),
	on_secondary_use = core.item_eat(3),
	on_use = core.item_eat(3),
	groups = {
		food = 2,
		eatable = 3,
		smoker_cookable = 1,
		campfire_cookable = 1,
		food_seitan_raw = 1,
		food_meat_raw = 1,
		compostability = 65,
		craftitem = 1,
	},
	_mcl_saturation = 1.8,
	stack_max = 64,
	_mcl_blast_resistance = 0,
})

local empty_bowl = ""
if core.get_modpath("mcl_core") and core.registered_items["mcl_core:bowl"] then
	empty_bowl = "mcl_core:bowl"
elseif core.get_modpath("farming") and core.registered_items["farming:bowl"] then
	empty_bowl = "farming:bowl"
elseif core.get_modpath("ethereal") and core.registered_items["ethereal:bowl"] then
	empty_bowl = "ethereal:bowl"
elseif core.get_modpath("crops") and core.registered_items["crops:clay_bowl"] then
	empty_bowl = "crops:clay_bowl"
end

local seitan_recipe = {
	type = "shapeless",
	output = mod.craftitems.raw_seitan,
	recipe = {
		"group:" .. mod.groups.gluten_source,
		"group:" .. mod.groups.gluten_source,
		"group:" .. mod.groups.gluten_source,
		"group:" .. mod.groups.vegan_soup,
	},
}

if empty_bowl ~= "" then
	seitan_recipe.replacements = {
		{ "group:" .. mod.groups.vegan_soup, empty_bowl },
	}
end

core.register_craft(seitan_recipe)

core.register_craftitem(mod.craftitems.cooked_seitan, {
	description = S("Seitan Steak"),
	_doc_items_longdesc = S("A cooked seitan dough in the shape of a steak."),
	inventory_image = "vegan_food_cooked_seitan.png",
	wield_image = "vegan_food_cooked_seitan.png",
	on_place = core.item_eat(8),
	on_secondary_use = core.item_eat(8),
	on_use = core.item_eat(8),
	groups = {
		food = 2,
		eatable = 8,
		food_seitan = 1,
		food_meat = 1,
		compostability = 65,
		craftitem = 1,
	},
	_mcl_saturation = 12.8,
	stack_max = 64,
	_mcl_blast_resistance = 0,
})

core.register_craft({
	type = "cooking",
	output = mod.craftitems.cooked_seitan,
	recipe = mod.craftitems.raw_seitan,
	cooktime = 10,
})

if core.get_modpath("mcl_core") and core.get_modpath("mcl_farming") then
	core.register_craftitem(mod.craftitems.seitan_stew, {
		description = S("Seitan Stew"),
		_doc_items_longdesc = S("Seitan stew, with carrots and a few good taters."),
		wield_image = "vegan_food_seitan_stew.png",
		inventory_image = "vegan_food_seitan_stew.png",
		stack_max = 1,
		on_place = core.item_eat(10, empty_bowl),
		on_secondary_use = core.item_eat(10, empty_bowl),
		groups = {
			food = 2,
			eatable = 10,
			food_seitan = 1,
			food_meat = 1,
			food_stew = 1,
			food_soup = 1,
			food_vegan_soup = 1,
			compostability = 65,
		},
		_mcl_saturation = 12.0,
	})

	core.register_craft({
		type = "shapeless",
		output = mod.craftitems.seitan_stew,
		recipe = {
			mod.craftitems.cooked_seitan,
			"mcl_farming:carrot_item",
			"mcl_farming:potato_item_baked",
			"group:mushroom",
			"mcl_core:bowl",
		},
	})
end --TODO alternatives for other games?

if core.get_modpath("mcl_hamburger") and core.global_exists("mcl_hamburger") then
	mcl_hamburger.register_burger_craft(mod.craftitems.cooked_seitan)
end
