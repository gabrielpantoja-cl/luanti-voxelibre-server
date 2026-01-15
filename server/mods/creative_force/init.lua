-- AGGRESSIVE Creative Force Mod - COMPLETELY DISABLES hostile mobs and FORCES creative mode
-- Author: Vegan Wetlands Team
-- Description: NUCLEAR OPTION - Ensures 100% creative mode and ZERO hostile entities

-- ⚠️ SURVIVAL MODE EXCEPTIONS - Players who should NOT get creative privileges
local survival_players = {
    ["pepelomo"] = true,  -- Requested to play in survival mode
}

-- List of creative privileges to grant - COMPLETE SET
local creative_privileges = {
    "creative",
    "give", 
    "fly",
    "fast",
    "noclip",
    "interact",
    "shout",
    "home",
    "spawn",
    "teleport",
    "settime",
    "debug",
    "basic_privs"
}

-- Function to grant all creative privileges to a player
local function grant_creative_privileges(player_name)
    -- Check if player is in survival exception list
    if survival_players[player_name] then
        minetest.log("info", "[creative_force] Player " .. player_name .. " is in SURVIVAL mode - skipping creative privileges")
        -- Grant only basic privileges for survival players
        local basic_privs = {"interact", "shout", "home", "spawn"}
        for _, priv in ipairs(basic_privs) do
            if not minetest.check_player_privs(player_name, {[priv] = true}) then
                local privs = minetest.get_player_privs(player_name)
                privs[priv] = true
                minetest.set_player_privs(player_name, privs)
            end
        end
        return false  -- Signal that creative mode was NOT granted
    end

    for _, priv in ipairs(creative_privileges) do
        if not minetest.check_player_privs(player_name, {[priv] = true}) then
            local privs = minetest.get_player_privs(player_name)
            privs[priv] = true
            minetest.set_player_privs(player_name, privs)
            minetest.log("info", "[creative_force] Granted privilege '" .. priv .. "' to player " .. player_name)
        end
    end
    return true  -- Signal that creative mode WAS granted
end

-- Function to give ALL items to a new player
local function give_all_items_to_player(player)
    local player_name = player:get_player_name()

    -- Skip if player is in survival mode
    if survival_players[player_name] then
        minetest.log("info", "[creative_force] Player " .. player_name .. " is in SURVIVAL mode - no starter kit given")
        return
    end

    local inv = player:get_inventory()
    if not inv then
        return
    end
    
    -- Clear existing inventory first
    inv:set_size("main", 36)
    inv:set_list("main", {})
    
    -- Essential VoxeLibre items for creative building and vegan gameplay
    local essential_items = {
        -- Building blocks
        "mcl_core:stone", "mcl_core:cobble", "mcl_core:dirt", "mcl_core:grass_path",
        "mcl_core:sand", "mcl_core:gravel", "mcl_core:clay", "mcl_core:brick_block",
        "mcl_core:sandstone", "mcl_core:redsandstone", "mcl_core:glass",
        
        -- Wood materials
        "mcl_core:wood", "mcl_core:junglewood", "mcl_core:pinewood", "mcl_core:acaciawood",
        "mcl_core:darkwood", "mcl_core:sprucewood", "mcl_core:birchwood",
        
        -- Wool and decoration
        "mcl_wool:white", "mcl_wool:red", "mcl_wool:green", "mcl_wool:blue",
        "mcl_wool:yellow", "mcl_wool:orange", "mcl_wool:purple", "mcl_wool:pink",
        
        -- Plant-based foods (vegan-friendly)
        "mcl_core:apple", "mcl_farming:bread", "mcl_farming:carrot", "mcl_farming:potato",
        "mcl_farming:beetroot", "mcl_farming:pumpkin_pie", "mcl_core:sugar",
        
        -- Tools for building (no weapons)
        "mcl_tools:pick_iron", "mcl_tools:shovel_iron", "mcl_tools:axe_iron",
        "mcl_buckets:bucket_empty", "mcl_buckets:bucket_water", "mcl_buckets:bucket_lava",
        
        -- Redstone and automation
        "mesecons:redstone", "mesecons_torch:redstoneblock", "mesecons_button:button_stone",
        "mesecons_pressureplates:pressure_plate_stone_off", "mesecons_pistons:piston_normal_off",
        
        -- Rails and minecarts (no violence)
        "mcl_minecarts:rail", "mcl_minecarts:golden_rail", "mcl_minecarts:activator_rail",
        "mcl_minecarts:minecart", "mcl_minecarts:chest_minecart",
        
        -- Seeds and farming
        "mcl_farming:wheat_seeds", "mcl_farming:carrot_item_seed", "mcl_farming:potato_item_seed",
        "mcl_farming:beetroot_seeds", "mcl_farming:pumpkin_seeds", "mcl_farming:melon_seeds",
        
        -- Animal care items (compassionate)
        "mcl_core:bone", "mcl_dye:bone_meal", "mcl_farming:hay_block",
        
        -- Creative essentials
        "mcl_core:barrier", "mcl_commands:command_block"
    }
    
    -- Add vegan food mod items if available
    if minetest.get_modpath("vegan_food") then
        table.insert(essential_items, "vegan_food:tofu")
        table.insert(essential_items, "vegan_food:soy_milk")
        table.insert(essential_items, "vegan_food:plant_milk")
        table.insert(essential_items, "vegan_food:seitan")
    end
    
    -- Fill inventory with essential items
    local slot = 1
    for _, item_name in ipairs(essential_items) do
        if slot <= 36 then
            -- Check if item exists before adding
            if minetest.registered_items[item_name] then
                inv:set_stack("main", slot, ItemStack(item_name .. " 64"))
                slot = slot + 1
            end
        else
            break -- Inventory full
        end
    end
    
    minetest.log("info", "[creative_force] Filled inventory with " .. (slot - 1) .. " essential vegan/creative items for player " .. player:get_player_name())
end

-- COMPLETELY DISABLE ALL DAMAGE
minetest.register_on_player_hpchange(function(player, hp_change, reason)
    return 0  -- NO DAMAGE EVER
end, true)

-- Track players who have already received their starter kit
local players_with_kit = {}

-- Hook into player join event
minetest.register_on_joinplayer(function(player)
    local player_name = player:get_player_name()
    minetest.log("info", "[creative_force] Player " .. player_name .. " joined, checking mode...")

    -- Grant privileges (creative or survival based on exception list)
    local is_creative = grant_creative_privileges(player_name)

    -- Check if this is a new player (first time joining)
    local is_new_player = not players_with_kit[player_name]

    -- Give full starter kit only to creative players
    if is_creative and is_new_player then
        minetest.after(1.5, function()
            if player and player:is_player() then
                give_all_items_to_player(player)
                players_with_kit[player_name] = true
                minetest.chat_send_player(player_name, "🎁 ¡Kit de inicio completo! Tienes todos los materiales esenciales para construir y crear sin límites.")
            end
        end)
    end
    
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
    
    -- Send appropriate welcome message
    minetest.after(2.0, function()
        if player and player:is_player() then
            if survival_players[player_name] then
                minetest.chat_send_player(player_name, "⚔️ ¡Bienvenido a Vegan Wetlands en MODO SUPERVIVENCIA! Deberás recolectar recursos, craftear herramientas y sobrevivir. ¡Buena suerte!")
            else
                minetest.chat_send_player(player_name, "🌱 ¡Bienvenido a Vegan Wetlands! Modo creativo activado - construye, explora y aprende sobre veganismo sin violencia. Usa /santuario para info sobre cuidado de animales.")
            end
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

-- NUCLEAR OPTION: Remove ALL hostile entities EVERY SECOND
local timer = 0
minetest.register_globalstep(function(dtime)
    timer = timer + dtime
    if timer >= 1 then -- Check EVERY SECOND - AGGRESSIVE
        timer = 0
        
        local hostile_entities = {
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
            "mcl_bows:arrow_entity"  -- ALSO REMOVE ARROWS!
        }
        
        local removed_count = 0
        -- Search ENTIRE world for hostile entities
        for _, obj in ipairs(minetest.get_objects_inside_radius({x=0, y=0, z=0}, 65536)) do
            local entity = obj:get_luaentity()
            if entity and entity.name then
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
            minetest.log("info", "[creative_force] REMOVED " .. removed_count .. " hostile entities/arrows")
        end
    end
end)

-- FORCE HEAL ALL PLAYERS TO FULL HP EVERY SECOND
minetest.register_globalstep(function(dtime)
    for _, player in ipairs(minetest.get_connected_players()) do
        if player and player:is_player() then
            player:set_hp(20) -- Force full health
        end
    end
end)

-- Chat command to manually give starter kit
minetest.register_chatcommand("starter_kit", {
    description = "Gives you the complete starter kit with all essential items",
    func = function(name, param)
        local player = minetest.get_player_by_name(name)
        if not player then
            return false, "You must be online to use this command."
        end

        if survival_players[name] then
            return false, "⚔️ Estás en modo supervivencia - debes recolectar recursos por tu cuenta."
        end

        give_all_items_to_player(player)
        players_with_kit[name] = true

        return true, "🎁 ¡Kit de inicio completo entregado! Tienes todos los materiales esenciales."
    end,
})

-- Chat command to give starter kit to another player (for admins)
minetest.register_chatcommand("give_starter_kit", {
    params = "<player>",
    description = "Give starter kit to another player (admin only)",
    privs = {give = true},
    func = function(name, param)
        if param == "" then
            return false, "Uso: /give_starter_kit <nombre_jugador>"
        end

        if survival_players[param] then
            return false, "⚔️ " .. param .. " está en modo supervivencia - no puede recibir kit de inicio."
        end

        local target_player = minetest.get_player_by_name(param)
        if not target_player then
            return false, "Jugador '" .. param .. "' no encontrado o no está online."
        end

        give_all_items_to_player(target_player)
        players_with_kit[param] = true

        minetest.chat_send_player(param, "🎁 ¡Un administrador te ha dado el kit de inicio completo!")

        return true, "Kit de inicio entregado a " .. param
    end,
})

minetest.log("info", "[creative_force] Creative Force mod loaded - forcing creative mode for child-friendly vegan server with COMPLETE starter kits")