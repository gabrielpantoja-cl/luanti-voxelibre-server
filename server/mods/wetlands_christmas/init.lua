-- Wetlands Christmas Decorations
-- Adaptado para VoxeLibre por gabrielpantoja-cl
-- Mod original: christmas_decor by GreenXenith

local MODPATH = minetest.get_modpath(minetest.get_current_modname())

-- Detección de dependencias VoxeLibre
local depends = {
	mcl_core = minetest.get_modpath("mcl_core"),
	mcl_farming = minetest.get_modpath("mcl_farming"),
	mcl_stairs = minetest.get_modpath("mcl_stairs"),
	mcl_sounds = minetest.get_modpath("mcl_sounds"),
	mcl_dye = minetest.get_modpath("mcl_dye") or minetest.get_modpath("mcl_core"), -- dye integrado en core
	mcl_buckets = minetest.get_modpath("mcl_buckets"),
}

-- Sistema de sonidos compatible con VoxeLibre
local function get_sound(sound_type)
	if depends.mcl_sounds then
		-- VoxeLibre sound system
		if sound_type == "stone" then
			return mcl_sounds.node_sound_stone_defaults()
		elseif sound_type == "glass" then
			return mcl_sounds.node_sound_glass_defaults()
		elseif sound_type == "leaves" then
			return mcl_sounds.node_sound_leaves_defaults()
		end
	end
	-- Fallback silencioso
	return {}
end

-- Función auxiliar para cargar módulos
local function include(filename)
	local file_path = MODPATH .. "/" .. filename
	local func, err = loadfile(file_path)
	if func then
		func(depends, get_sound)
	else
		minetest.log("error", "[wetlands_christmas] Error loading " .. filename .. ": " .. (err or "unknown error"))
	end
end

-- Cargar módulos de características
include("food.lua")
include("lights.lua")
include("misc.lua")

-- Log de carga exitosa
minetest.log("action", "[wetlands_christmas] Christmas decorations loaded successfully for VoxeLibre!")