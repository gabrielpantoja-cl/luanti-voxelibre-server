-- mcl_decor/src/compat.lua

local S = ...

-- MCL2 -> MCLA migration fix
core.register_alias("mcl_decor:oak_chair", "mcl_decor:wooden_chair")
core.register_alias("mcl_decor:wooden_chair", "mcl_decor:oak_chair")

-- MCLA old hedge nodenames fix
if core.global_exists("mcl_trees") then
	for name in pairs(mcl_trees.woods) do
		core.register_alias("mcl_fences:"..name.."_hedge", "mcl_decor:"..name.."_hedge")
	end
end

-- Coalquartz -> Checkerboard
core.register_alias("mcl_decor:coalquartz_tile", "mcl_decor:checkerboard_tile")
core.register_alias("mcl_stairs:stair_coalquartz_tile", "mcl_stairs:stair_checkerboard_tile")
core.register_alias("mcl_stairs:stair_coalquartz_tile_outer", "mcl_stairs:stair_checkerboard_tile_outer")
core.register_alias("mcl_stairs:stair_coalquartz_tile_inner", "mcl_stairs:stair_checkerboard_tile_inner")
core.register_alias("mcl_stairs:slab_coalquartz_tile", "mcl_stairs:slab_checkerboard_tile")
core.register_alias("mcl_stairs:slab_coalquartz_tile_top", "mcl_stairs:slab_checkerboard_tile_top")
core.register_alias("mcl_stairs:slab_coalquartz_tile_double", "mcl_stairs:slab_checkerboard_tile_double")

-- Subtitles support
if core.global_exists("subtitles") then
	subtitles.register_description("mcl_decor_fridge_open", S("Fridge opens"))
	subtitles.register_description("mcl_decor_fridge_close", S("Fridge closes"))
	subtitles.register_description("mcl_decor_curtain", S("Curtain moves"))
end
