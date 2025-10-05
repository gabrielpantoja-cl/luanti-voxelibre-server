-- mcl_decor/src/wooden/init.lua

local S, include = ...

-- API
local files = {
	"chairs_tables",
	"slab_tables",
	"register",
}

include(files, {"src", "wooden"}, S)
