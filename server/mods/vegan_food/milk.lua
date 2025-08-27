local mod = vegan_food
local S = core.get_translator(core.get_current_modname())
local Utils = dofile(core.get_modpath(core.get_current_modname()) .. "/utils.lua")

-- Plant Milk:
local plant_milk_table = {}
if core.get_modpath("mcl_mobitems") and core.registered_craftitems["mcl_mobitems:milk_bucket"] then
	plant_milk_table = Utils.shallow_copy(core.registered_craftitems["mcl_mobitems:milk_bucket"])
elseif core.get_modpath("mesecraft_mobs") and core.registered_craftitems["mesecraft_mobs:milk_bucket"] then
	plant_milk_table = Utils.shallow_copy(core.registered_craftitems["mesecraft_mobs:milk_bucket"])
elseif core.get_modpath("mobs") and core.registered_craftitems["mobs:bucket_milk"] then
	plant_milk_table = Utils.shallow_copy(core.registered_craftitems["mobs:bucket_milk"])
else
	plant_milk_table = {
		stack_max = 1,
		groups = { food = 3, can_eat_when_full = 1 },
		on_use = core.item_eat(0),
		on_place = core.item_eat(0),
		on_secondary_use = core.item_eat(0),
	}
end

plant_milk_table.description = S("Plant Milk")
plant_milk_table._doc_items_longdesc = S("Refreshing plant milk, obtained by mixing seeds, nuts, or beans with water in a crafting table. Drinking it will remove all status effects, but restores no hunger points.")
plant_milk_table.inventory_image = "vegan_food_milk_bucket.png"
plant_milk_table.wield_image = "vegan_food_milk_bucket.png"
if not plant_milk_table.groups then
	plant_milk_table.groups = {}
end
if not plant_milk_table.groups["food_milk"] then
	plant_milk_table.groups["food_milk"] = 1
end
plant_milk_table.groups[mod.groups.plant_milk] = 1
plant_milk_table.groups.craftitem = 1
plant_milk_table._mcl_blast_resistance = 0

core.register_craftitem(mod.craftitems.milk_bucket, plant_milk_table)

core.register_craft({
	type = "shapeless",
	output = mod.craftitems.milk_bucket,
	recipe = {
		"group:water_bucket",
		"group:" .. mod.groups.milkable_plant,
		"group:" .. mod.groups.milkable_plant,
		"group:" .. mod.groups.milkable_plant,
		"group:" .. mod.groups.milkable_plant,
		"group:" .. mod.groups.milkable_plant,
		"group:" .. mod.groups.milkable_plant,
	},
})

-- Tofu:

core.register_craftitem(mod.craftitems.tofu, {
	description = S("Tofu"),
	_doc_items_longdesc = S("A block of coagulated plant milk, made by cooking plant milk in a furnace. It can be used in recipes or eaten directly."),
	inventory_image = "vegan_food_tofu.png",
	wield_image = "vegan_food_tofu.png",
	on_place = core.item_eat(8),
	on_secondary_use = core.item_eat(8),
	on_use = core.item_eat(8),
	groups = {
		food = 2,
		eatable = 8,
		food_tofu = 1,
		food_meat = 1,
		craftitem = 1,
	},
	_mcl_saturation = 12.8,
	stack_max = 64,
	_mcl_blast_resistance = 0,
})

local empty_bucket = ""
if core.get_modpath("mcl_buckets") and core.registered_items["mcl_buckets:bucket_empty"] then
	empty_bucket = "mcl_buckets:bucket_empty"
elseif core.get_modpath("mesecraft_bucket") and core.registered_items["mesecraft_bucket:bucket_empty"] then
	empty_bucket = "mesecraft_bucket:bucket_empty"
elseif core.get_modpath("bucket") and core.registered_items["bucket:bucket_empty"] then
	empty_bucket = "bucket:bucket_empty"
end

local tofu_recipe = {
	type = "cooking",
	output = mod.craftitems.tofu,
	recipe = mod.craftitems.milk_bucket,
	cooktime = 10,
}

if empty_bucket ~= "" then
	tofu_recipe.replacements = {
		{ mod.craftitems.milk_bucket, empty_bucket },
	}
end

core.register_craft(tofu_recipe)

if core.get_modpath("mcl_hamburger") and core.global_exists("mcl_hamburger") then
	mcl_hamburger.register_burger_craft(mod.craftitems.tofu)
end
