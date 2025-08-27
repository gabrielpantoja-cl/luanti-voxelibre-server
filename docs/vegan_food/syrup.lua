local mod = vegan_food
local S = core.get_translator(core.get_current_modname())
local Utils = dofile(core.get_modpath(core.get_current_modname()) .. "/utils.lua")

local apple_syrup_table = {}
if core.get_modpath("mcl_honey") and core.registered_craftitems["mcl_honey:honey_bottle"] then
	apple_syrup_table = Utils.shallow_copy(core.registered_craftitems["mcl_honey:honey_bottle"])
elseif core.get_modpath("bees") and core.registered_craftitems["bees:bottle_honey"] then
	apple_syrup_table = Utils.shallow_copy(core.registered_craftitems["bees:bottle_honey"])
elseif core.get_modpath("mobs") and core.registered_craftitems["mobs:honey"] then
	apple_syrup_table = Utils.shallow_copy(core.registered_craftitems["mobs:honey"])
end

if next(apple_syrup_table) == nil then
	return
end

apple_syrup_table.description = S("Apple Syrup Bottle")
apple_syrup_table._doc_items_longdesc = S(
	"Syrup made from apples. Used to craft honey blocks and to restore hunger points.")
apple_syrup_table.inventory_image = "vegan_food_syrup.png"
apple_syrup_table.wield_image = "vegan_food_syrup.png"
if not apple_syrup_table.groups then
	apple_syrup_table.groups = {}
end
apple_syrup_table.groups["food_honey"] = 1
apple_syrup_table.groups["food_syrup"] = 1
core.register_craftitem(mod.craftitems.apple_syrup, apple_syrup_table)

core.register_craft({
	type = "shapeless",
	output = mod.craftitems.apple_syrup,
	recipe = {
		"group:empty_bottle",
		"group:food_apple",
	},
})

local flower_syrup_table = Utils.shallow_copy(apple_syrup_table)
flower_syrup_table.description = S("Flower Syrup Bottle")
flower_syrup_table._doc_items_longdesc = S(
	"Syrup made from flowers. Used to craft honey blocks and to restore hunger points.")

core.register_craftitem(mod.craftitems.flower_syrup, flower_syrup_table)

core.register_craft({
	type = "shapeless",
	output = mod.craftitems.flower_syrup,
	recipe = {
		"group:water_bottle",
		"group:flower",
		"group:flower",
		"group:flower",
		"group:flower",
		"group:flower",
		"group:flower",
	},
})

if core.get_modpath("mcl_core") and core.get_modpath("mcl_potions") then
	core.register_craft({
		type = "shapeless",
		output = "mcl_core:sugar 3",
		recipe = { "group:food_syrup" },
		replacements = {
			{ "group:food_syrup", "mcl_potions:glass_bottle" },
		},
	})
end
