--[[
   VoxeLibre Compatibility Layer for 3D Forniture

   Adapts default Minetest items to VoxeLibre equivalents

   Author: Claude Code (adapted for Wetlands server)
   Date: October 10, 2025
   License: GPL v2 (same as original mod)
]]--

-- Create default namespace if it doesn't exist
if not default then
    default = {}
end

-- Item Aliases: Map Minetest default items to VoxeLibre (mcl_*) equivalents
local item_aliases = {
    -- Wood and building materials
    ["default:wood"] = "mcl_core:wood",
    ["default:stick"] = "mcl_core:stick",
    ["default:cobble"] = "mcl_core:cobble",
    ["default:stone"] = "mcl_core:stone",
    ["default:paper"] = "mcl_core:paper",

    -- Metals
    ["default:steel_ingot"] = "mcl_core:iron_ingot",
    ["default:iron_lump"] = "mcl_core:iron_lump",
    ["default:coal_lump"] = "mcl_core:coal_lump",

    -- Tools and items
    ["default:torch"] = "mcl_torches:torch",
}

-- Register all aliases
for old_name, new_name in pairs(item_aliases) do
    minetest.register_alias(old_name, new_name)
end

-- Bucket compatibility
-- VoxeLibre uses mcl_buckets instead of bucket mod
if not minetest.get_modpath("bucket") and minetest.get_modpath("mcl_buckets") then
    minetest.register_alias("bucket:bucket_empty", "mcl_buckets:bucket_empty")
    minetest.register_alias("bucket:bucket_water", "mcl_buckets:bucket_water")
end

-- Stairs compatibility
-- VoxeLibre uses mcl_stairs instead of stairs mod
if not minetest.get_modpath("stairs") and minetest.get_modpath("mcl_stairs") then
    minetest.register_alias("stairs:slab_wood", "mcl_stairs:slab_wood")
end

-- Sound compatibility stub
-- VoxeLibre may use different sound system
if not default.node_sound_defaults then
    default.node_sound_defaults = function(table)
        -- Return empty sound definition for compatibility
        return {}
    end
end

if not default.node_sound_stone_defaults then
    default.node_sound_stone_defaults = function(table)
        return {}
    end
end

if not default.node_sound_wood_defaults then
    default.node_sound_wood_defaults = function(table)
        return {}
    end
end

minetest.log("action", "[3D Forniture] VoxeLibre compatibility layer loaded successfully")
