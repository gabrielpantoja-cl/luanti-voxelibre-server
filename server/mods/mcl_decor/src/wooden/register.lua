-- mcl_decor/src/wooden/register.lua

local S = ...

local function readable_name(str)
	str = str:gsub("_", " ")
	return (str:gsub("^%l", string.upper))
end

if core.get_modpath("mcl_trees") then
	-- Mineclonia
	for name, def in pairs(mcl_trees.woods) do
		local rname = readable_name(name)
		local item = "mcl_trees:wood_"..name
		local wdef = core.registered_nodes[item]
		if wdef and wdef.tiles then
			mcl_decor.register_chair_and_table(name, S(rname.." Chair"), S(rname.."Table"), item, wdef.tiles[1])
			mcl_decor.register_slab_table(name, S(rname.." Slab Table"), item, wdef.tiles[1])
		end
	end
else
	-- VoxeLibre
	mcl_decor.register_chair_and_table("wooden", S("Oak Chair"), S("Oak Table"), "mcl_core:wood", "default_wood.png")
	mcl_decor.register_chair_and_table("dark_oak", S("Dark Oak Chair"), S("Dark Oak Table"), "mcl_core:darkwood", "mcl_core_planks_big_oak.png")
	mcl_decor.register_chair_and_table("jungle", S("Jungle Chair"), S("Jungle Table"), "mcl_core:junglewood", "default_junglewood.png")
	mcl_decor.register_chair_and_table("spruce", S("Spruce Chair"), S("Spruce Table"), "mcl_core:sprucewood", "mcl_core_planks_spruce.png")
	mcl_decor.register_chair_and_table("acacia", S("Acacia Chair"), S("Acacia Table"), "mcl_core:acaciawood", "default_acacia_wood.png")
	mcl_decor.register_chair_and_table("birch", S("Birch Chair"), S("Birch Table"), "mcl_core:birchwood", "mcl_core_planks_birch.png")
	mcl_decor.register_chair_and_table("mangrove", S("Mangrove Chair"), S("Mangrove Table"), "mcl_mangrove:mangrove_wood", "mcl_mangrove_planks.png")
	mcl_decor.register_chair_and_table("cherry", S("Cherry Chair"), S("Cherry Table"), "mcl_cherry_blossom:cherrywood", "mcl_cherry_blossom_planks.png")
	mcl_decor.register_chair_and_table("bamboo", S("Bamboo Chair"), S("Bamboo Table"), "mcl_bamboo:bamboo_plank", "mcl_bamboo_bamboo_block_stripped.png")
	mcl_decor.register_chair_and_table("crimson", S("Crimson Chair"), S("Crimson Table"), "mcl_crimson:crimson_hyphae_wood", "mcl_crimson_crimson_hyphae_wood.png", true)
	mcl_decor.register_chair_and_table("warped", S("Warped Chair"), S("Warped Table"), "mcl_crimson:warped_hyphae_wood", "mcl_crimson_warped_hyphae_wood.png", true)

	mcl_decor.register_slab_table("wooden", S("Oak Slab Table"), "mcl_core:wood", "default_wood.png")
	mcl_decor.register_slab_table("dark_oak", S("Dark Oak Slab Table"), "mcl_core:darkwood", "mcl_core_planks_big_oak.png")
	mcl_decor.register_slab_table("jungle", S("Jungle Slab Table"), "mcl_core:junglewood", "default_junglewood.png")
	mcl_decor.register_slab_table("spruce", S("Spruce Slab Table"), "mcl_core:sprucewood", "mcl_core_planks_spruce.png")
	mcl_decor.register_slab_table("acacia", S("Acacia Slab Table"), "mcl_core:acaciawood", "default_acacia_wood.png")
	mcl_decor.register_slab_table("birch", S("Birch Slab Table"), "mcl_core:birchwood", "mcl_core_planks_birch.png")
	mcl_decor.register_slab_table("mangrove", S("Mangrove Slab Table"), "mcl_mangrove:mangrove_wood", "mcl_mangrove_planks.png")
	mcl_decor.register_slab_table("cherry", S("Cherry Slab Table"), "mcl_cherry_blossom:cherrywood", "mcl_cherry_blossom_planks.png")
	mcl_decor.register_slab_table("bamboo", S("Bamboo Slab Table"), "mcl_bamboo:bamboo_plank", "mcl_bamboo_bamboo_block_stripped.png")
	mcl_decor.register_slab_table("crimson", S("Crimson Slab Table"), "mcl_crimson:crimson_hyphae_wood", "mcl_crimson_crimson_hyphae_wood.png", true)
	mcl_decor.register_slab_table("warped", S("Warped Slab Table"), "mcl_crimson:warped_hyphae_wood", "mcl_crimson_warped_hyphae_wood.png", true)
end
