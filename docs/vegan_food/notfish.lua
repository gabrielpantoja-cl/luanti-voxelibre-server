local mod = vegan_food
local S = core.get_translator(core.get_current_modname())

core.register_craftitem(mod.craftitems.raw_notfish_fillet, {
	description = S("Raw Not-fish Fillet"),
	_doc_items_longdesc = S("A fillet made of tofu and kelp. Cooking it improves its nutritional value."),
	inventory_image = "vegan_food_raw_notfish_fillet.png",
	on_place = core.item_eat(2),
	on_secondary_use = core.item_eat(2),
	stack_max = 64,
	groups = {
		food = 2,
		eatable = 2,
		smoker_cookable = 1,
		campfire_cookable = 1,
		food_tofu = 1,
		food_fish_raw = 1,
		compostability = 65,
	},
	_mcl_saturation = 0.4,
})

core.register_craft({
	type = "shapeless",
	output = mod.craftitems.raw_notfish_fillet,
	recipe = {
		"group:food_tofu",
		"group:food_kelp",
	},
})

core.register_craftitem(mod.craftitems.cooked_notfish_fillet, {
	description = S("Cooked Not-fish Fillet"),
	_doc_items_longdesc = S("A cooked fillet made of tofu and kelp. Tastes fishy."),
	inventory_image = "vegan_food_cooked_notfish_fillet.png",
	on_place = core.item_eat(5),
	on_secondary_use = core.item_eat(5),
	stack_max = 64,
	groups = {
		food = 2,
		eatable = 5,
		food_tofu = 1,
		food_fish = 1,
		compostability = 65,
	},
	_mcl_saturation = 6,
})

core.register_craft({
	type = "cooking",
	output = mod.craftitems.cooked_notfish_fillet,
	recipe = mod.craftitems.raw_notfish_fillet,
	cooktime = 10,
})
