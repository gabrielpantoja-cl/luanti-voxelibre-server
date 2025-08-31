-- Creative Force Mod - Forces creative mode for all players
-- Author: Vegan Wetlands Team
-- Description: Ensures all players have creative privileges and removes hostile mobs

-- List of creative privileges to grant
local creative_privileges = {
    "creative",
    "give", 
    "fly",
    "fast",
    "noclip",
    "interact",
    "shout"
}

-- Function to grant all creative privileges to a player
local function grant_creative_privileges(player_name)
    for _, priv in ipairs(creative_privileges) do
        if not minetest.check_player_privs(player_name, {[priv] = true}) then
            local privs = minetest.get_player_privs(player_name)
            privs[priv] = true
            minetest.set_player_privs(player_name, privs)
            minetest.log("info", "[creative_force] Granted privilege '" .. priv .. "' to player " .. player_name)
        end
    end
end

-- Hook into player join event
minetest.register_on_joinplayer(function(player)
    local player_name = player:get_player_name()
    minetest.log("info", "[creative_force] Player " .. player_name .. " joined, ensuring creative privileges...")
    
    -- Grant creative privileges immediately
    grant_creative_privileges(player_name)
    
    -- Also set creative inventory mode for VoxeLibre
    if mcl_player and mcl_player.set_player_formspec then
        minetest.after(1.0, function()
            if player and player:is_player() then
                -- Force creative inventory
                local inv = player:get_inventory()
                if inv then
                    -- Enable creative inventory
                    player:set_inventory_formspec(mcl_player.get_creative_formspec(player_name))
                end
            end
        end)
    end
    
    -- Send welcome message
    minetest.after(2.0, function()
        if player and player:is_player() then
            minetest.chat_send_player(player_name, "🌱 ¡Bienvenido a Vegan Wetlands! Modo creativo activado - construye, explora y aprende sobre veganismo sin violencia. Usa /santuario para info sobre cuidado de animales.")
        end
    end)
end)

-- Disable hostile mob spawning completely
minetest.register_on_mods_loaded(function()
    -- Remove hostile mobs from MCL2
    if minetest.get_modpath("mcl_mobs") then
        local hostile_mobs = {
            "mobs_mc:zombie",
            "mobs_mc:skeleton", 
            "mobs_mc:creeper",
            "mobs_mc:spider",
            "mobs_mc:cave_spider",
            "mobs_mc:witch",
            "mobs_mc:enderman",
            "mobs_mc:slime_big",
            "mobs_mc:slime_small",
            "mobs_mc:slime_tiny",
            "mobs_mc:magma_cube_big",
            "mobs_mc:magma_cube_small", 
            "mobs_mc:magma_cube_tiny",
            "mobs_mc:ghast",
            "mobs_mc:blaze",
            "mobs_mc:zombiepig",
            "mobs_mc:wither_skeleton",
            "mobs_mc:wither",
            "mobs_mc:ender_dragon",
            "mobs_mc:shulker",
            "mobs_mc:guardian",
            "mobs_mc:guardian_elder",
            "mobs_mc:vindicator",
            "mobs_mc:evoker",
            "mobs_mc:vex",
            "mobs_mc:pillager",
            "mobs_mc:ravager",
            "mobs_mc:phantom"
        }
        
        for _, mob_name in ipairs(hostile_mobs) do
            -- Clear spawn data for hostile mobs
            if minetest.registered_entities[mob_name] then
                minetest.log("info", "[creative_force] Disabling hostile mob: " .. mob_name)
                minetest.registered_entities[mob_name].spawn = nil
                minetest.registered_entities[mob_name].on_spawn = nil
            end
        end
        
        -- Override mob spawn function to prevent hostile spawns
        if mobs and mobs.spawn then
            local original_spawn = mobs.spawn
            mobs.spawn = function(def)
                -- Only allow peaceful mobs
                local mob_name = def.name or ""
                local is_hostile = false
                
                for _, hostile_mob in ipairs(hostile_mobs) do
                    if mob_name:find(hostile_mob) then
                        is_hostile = true
                        break
                    end
                end
                
                if not is_hostile then
                    return original_spawn(def)
                else
                    minetest.log("info", "[creative_force] Blocked hostile mob spawn: " .. mob_name)
                end
            end
        end
    end
end)

-- Remove existing hostile entities periodically
local timer = 0
minetest.register_globalstep(function(dtime)
    timer = timer + dtime
    if timer >= 30 then -- Check every 30 seconds
        timer = 0
        
        local hostile_entities = {
            "mobs_mc:zombie",
            "mobs_mc:skeleton",
            "mobs_mc:creeper", 
            "mobs_mc:spider",
            "mobs_mc:cave_spider",
            "mobs_mc:witch",
            "mobs_mc:enderman"
        }
        
        local removed_count = 0
        for _, obj in ipairs(minetest.get_objects_inside_radius({x=0, y=0, z=0}, 32000)) do
            local entity = obj:get_luaentity()
            if entity then
                for _, hostile_name in ipairs(hostile_entities) do
                    if entity.name == hostile_name then
                        obj:remove()
                        removed_count = removed_count + 1
                        break
                    end
                end
            end
        end
        
        if removed_count > 0 then
            minetest.log("info", "[creative_force] Removed " .. removed_count .. " hostile entities")
        end
    end
end)

minetest.log("info", "[creative_force] Creative Force mod loaded - forcing creative mode for child-friendly vegan server")