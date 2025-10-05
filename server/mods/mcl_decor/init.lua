-- mcl_decor/init.lua

mcl_decor = {}

local S = core.get_translator("mcl_decor")
local modpath = core.get_modpath("mcl_decor")

-- improvized module loading system
-- * `files` = sequence of filenames without the .lua extension
-- * `basedir` = directories between modpath and the filenames, in sequence
-- * `...` = variables to share with the modules
local function include(files, basedir, ...)
	for i = 1, #files do
		loadfile(table.concat({
			modpath,
			table.concat(basedir, DIR_DELIM),
			files[i] .. ".lua"
		}, DIR_DELIM))(...)
	end
end

local modules = {
	"wooden" .. DIR_DELIM .. "init",
	"colored" .. DIR_DELIM .. "init",
	"paths",
	"hedges",
	"oven",
	"coalquartz",
	"table_lamp",
	"counter",
	"doorbell",
	"fridge",
	"compat",
}

include(modules, {"src"}, S, include)
