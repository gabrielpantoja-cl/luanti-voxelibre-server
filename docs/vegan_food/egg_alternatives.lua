local mod = vegan_food
local S = core.get_translator(core.get_current_modname())
local Utils = dofile(core.get_modpath(core.get_current_modname()) .. "/utils.lua")

if core.get_modpath("mcl_cake") and core.registered_items["mcl_cake:cake"] then
	Utils.add_to_group("mcl_cake:cake", "food_cake")
	local empty_bucket = ""
	if core.get_modpath("mcl_buckets") and core.registered_items["mcl_buckets:bucket_empty"] then
		empty_bucket = "mcl_buckets:bucket_empty"
	elseif core.get_modpath("mesecraft_bucket") and core.registered_items["mesecraft_bucket:bucket_empty"] then
		empty_bucket = "mesecraft_bucket:bucket_empty"
	elseif core.get_modpath("bucket") and core.registered_items["bucket:bucket_empty"] then
		empty_bucket = "bucket:bucket_empty"
	end
	local cake_recipe = {
		output = "mcl_cake:cake",
		recipe = {
			{"group:" .. mod.groups.plant_milk, "group:" .. mod.groups.plant_milk, "group:" .. mod.groups.plant_milk},
			{"group:food_sugar", "group:food_sugar", "group:food_sugar"},
			{"group:food_wheat", "group:food_wheat", "group:food_wheat"},
		},
	}
	if empty_bucket ~= "" then
		cake_recipe.replacements = {
			{"group:" .. mod.groups.plant_milk, empty_bucket},
			{"group:" .. mod.groups.plant_milk, empty_bucket},
			{"group:" .. mod.groups.plant_milk, empty_bucket},
		}
	end
	core.register_craft(cake_recipe)
end

if core.get_modpath("mcl_farming") and core.registered_items["mcl_farming:pumpkin_pie"] then
	Utils.add_to_group("mcl_farming:pumpkin", "food_pumpkin")
	Utils.add_to_group("mcl_farming:pumpkin_pie", "food_pie")
	core.register_craft({
		type = "shapeless",
		output = "mcl_farming:pumpkin_pie",
		recipe = {"group:food_pumpkin", "group:food_sugar", "group:food_wheat"},
	})
end