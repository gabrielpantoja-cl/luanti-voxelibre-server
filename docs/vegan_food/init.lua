vegan_food = {}

local mod = vegan_food
local MOD_ID = core.get_current_modname()
local MOD_PATH = core.get_modpath(MOD_ID)
local S = core.get_translator(MOD_ID)
local Utils = dofile(MOD_PATH .. "/utils.lua")

-- TODO egg replacements in recipes

mod.craftitems = {
	milk_bucket = MOD_ID .. ":milk_bucket",
	tofu = MOD_ID .. ":tofu",
	raw_seitan = MOD_ID .. ":raw_seitan",
	cooked_seitan = MOD_ID .. ":cooked_seitan",
	seitan_stew = MOD_ID .. ":seitan_stew",
	raw_notfish_fillet = MOD_ID .. ":raw_notfish_fillet",
	cooked_notfish_fillet = MOD_ID .. ":cooked_notfish_fillet",
	apple_syrup = MOD_ID .. ":apple_syrup_bottle",
	flower_syrup = MOD_ID .. ":flower_syrup_bottle",
}

mod.groups = {
	milkable_plant = "milkable_plant",
	plant_milk = "food_plant_milk",
	gluten_source = "gluten_source",
	vegan_soup = "food_vegan_soup",
}

Utils.add_to_group("mcl_farming:wheat_item", "food_wheat")
Utils.add_to_group("mcl_farming:potato_item", "food_potato")
Utils.add_to_group("mcl_core:sugar", "food_sugar")
Utils.add_to_group("gadgets_consumables:water_bottle", "water_bottle")
Utils.add_to_group("df_farming:cave_wheat", "food_wheat")
Utils.add_to_group("default:sand_with_kelp", "food_kelp")

core.register_on_mods_loaded(function()
	for name, _ in pairs(core.registered_items) do
		if (name:match(":potato$")) then
			Utils.add_to_group(name, "food_potato")
		end
		if (name:match(":seed_") or name:match("_seeds$") or name:match("_seed$")
				or core.get_item_group(name, "seed") > 0
				or core.get_item_group(name, "food_oats") > 0
				or core.get_item_group(name, "food_beans") > 0
				or core.get_item_group(name, "food_pine_nuts") > 0
				or core.get_item_group(name, "food_nuts") > 0
				or core.get_item_group(name, "food_potato") > 0
				or ((name:match(":bean") or name:match("_bean"))
					and not name:match("cocoa") and not name:match("coffee") and not name:match("stalk") and not name:match("pole"))
				or name:match(":sunflower")) then
			Utils.add_to_group(name, mod.groups.milkable_plant)
		end
		if (((name:match(":wheat")) and not name:find("seed"))
				or core.get_item_group(name, "food_wheat") > 0
				or name == "df_farming:cave_flour"
				or name == "farming:flour") then
			Utils.add_to_group(name, mod.groups.gluten_source)
		end
		if ((name:match("stew") or name:match("soup"))
				and not name:match("meat") and not name:match("rabbit")) then
			Utils.add_to_group(name, mod.groups.vegan_soup)
		end
		if (name:match(":apple$")
				or core.get_item_group(name, "food_apple") > 0) then
			Utils.add_to_group(name, "food_apple")
		end
		if name:match(":kelp") then
			Utils.add_to_group(name, "food_kelp")
		end
		if name:match(":glass_bottle") then
			Utils.add_to_group(name, "empty_bottle")
		end
	end
end)

dofile(MOD_PATH .. "/egg_alternatives.lua")
dofile(MOD_PATH .. "/milk.lua")
dofile(MOD_PATH .. "/seitan.lua")
dofile(MOD_PATH .. "/notfish.lua")
dofile(MOD_PATH .. "/syrup.lua")

if core.get_modpath("mcl_hamburger") then
	core.register_craft({
		type = "shapeless",
		output = "mcl_hamburger:hamburger",
		recipe = {
			"mcl_farming:bread",
			"mcl_farming:beetroot_item",
			"group:mushroom",
			"mcl_farming:bread",
		},
	})
end
