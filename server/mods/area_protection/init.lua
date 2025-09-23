-- Area Protection Mod for VoxeLibre
-- Uses invisible barriers to protect buildings

local S = minetest.get_translator(minetest.get_current_modname())

-- Storage for player positions
local player_positions = {}

-- Initialize player positions table
local function init_player_pos(name)
    if not player_positions[name] then
        player_positions[name] = {}
    end
end

-- Command to set first position
minetest.register_chatcommand("pos1", {
    params = "",
    description = S("Set first position for area protection"),
    privs = {server = true},
    func = function(name, param)
        local player = minetest.get_player_by_name(name)
        if not player then
            return false, S("Player not found")
        end

        init_player_pos(name)
        local pos = player:get_pos()
        pos = vector.round(pos)
        player_positions[name].pos1 = pos

        return true, S("Position 1 set to @1", minetest.pos_to_string(pos))
    end,
})

-- Command to set second position
minetest.register_chatcommand("pos2", {
    params = "",
    description = S("Set second position for area protection"),
    privs = {server = true},
    func = function(name, param)
        local player = minetest.get_player_by_name(name)
        if not player then
            return false, S("Player not found")
        end

        init_player_pos(name)
        local pos = player:get_pos()
        pos = vector.round(pos)
        player_positions[name].pos2 = pos

        return true, S("Position 2 set to @1", minetest.pos_to_string(pos))
    end,
})

-- Function to create barrier walls around an area
local function create_barrier_walls(pos1, pos2)
    local min_pos = {
        x = math.min(pos1.x, pos2.x),
        y = math.min(pos1.y, pos2.y),
        z = math.min(pos1.z, pos2.z)
    }
    local max_pos = {
        x = math.max(pos1.x, pos2.x),
        y = math.max(pos1.y, pos2.y),
        z = math.max(pos1.z, pos2.z)
    }

    local barriers_placed = 0

    -- Create walls around the area (not filling the inside)
    for x = min_pos.x - 1, max_pos.x + 1 do
        for y = min_pos.y, max_pos.y + 3 do  -- 3 blocks above for jumping protection
            for z = min_pos.z - 1, max_pos.z + 1 do
                local place_barrier = false

                -- Check if this position is on the border
                if x == min_pos.x - 1 or x == max_pos.x + 1 or
                   z == min_pos.z - 1 or z == max_pos.z + 1 then
                    place_barrier = true
                end

                if place_barrier then
                    local pos = {x = x, y = y, z = z}
                    local node = minetest.get_node(pos)

                    -- Only place if it's air or replaceable
                    if node.name == "air" or node.name == "ignore" then
                        minetest.set_node(pos, {name = "mcl_core:barrier"})
                        barriers_placed = barriers_placed + 1
                    end
                end
            end
        end
    end

    return barriers_placed
end

-- Command to protect the selected area
minetest.register_chatcommand("protect", {
    params = "",
    description = S("Protect selected area with invisible barriers"),
    privs = {server = true},
    func = function(name, param)
        init_player_pos(name)

        if not player_positions[name].pos1 or not player_positions[name].pos2 then
            return false, S("You need to set both pos1 and pos2 first")
        end

        local pos1 = player_positions[name].pos1
        local pos2 = player_positions[name].pos2

        -- Calculate area size
        local volume = math.abs(pos2.x - pos1.x + 1) *
                      math.abs(pos2.y - pos1.y + 1) *
                      math.abs(pos2.z - pos1.z + 1)

        if volume > 50000 then
            return false, S("Area too large (max 50000 blocks)")
        end

        local barriers_placed = create_barrier_walls(pos1, pos2)

        return true, S("Area protected! @1 barriers placed around your building", barriers_placed)
    end,
})

-- Command to remove barriers in selected area
minetest.register_chatcommand("unprotect", {
    params = "",
    description = S("Remove barrier protection from selected area"),
    privs = {server = true},
    func = function(name, param)
        init_player_pos(name)

        if not player_positions[name].pos1 or not player_positions[name].pos2 then
            return false, S("You need to set both pos1 and pos2 first")
        end

        local pos1 = player_positions[name].pos1
        local pos2 = player_positions[name].pos2

        local min_pos = {
            x = math.min(pos1.x, pos2.x) - 1,
            y = math.min(pos1.y, pos2.y),
            z = math.min(pos1.z, pos2.z) - 1
        }
        local max_pos = {
            x = math.max(pos1.x, pos2.x) + 1,
            y = math.max(pos1.y, pos2.y) + 3,
            z = math.max(pos1.z, pos2.z) + 1
        }

        local barriers_removed = 0

        for x = min_pos.x, max_pos.x do
            for y = min_pos.y, max_pos.y do
                for z = min_pos.z, max_pos.z do
                    local pos = {x = x, y = y, z = z}
                    local node = minetest.get_node(pos)

                    if node.name == "mcl_core:barrier" then
                        minetest.set_node(pos, {name = "air"})
                        barriers_removed = barriers_removed + 1
                    end
                end
            end
        end

        return true, S("Protection removed! @1 barriers removed", barriers_removed)
    end,
})

-- Command to show barriers (give player a barrier item)
minetest.register_chatcommand("show_barriers", {
    params = "",
    description = S("Get a barrier item to see all barriers"),
    privs = {server = true},
    func = function(name, param)
        local player = minetest.get_player_by_name(name)
        if not player then
            return false, S("Player not found")
        end

        local inv = player:get_inventory()
        local itemstack = ItemStack("mcl_core:barrier 1")

        if inv:room_for_item("main", itemstack) then
            inv:add_item("main", itemstack)
            return true, S("Barrier item given. Hold it to see all barriers!")
        else
            return false, S("Inventory full")
        end
    end,
})

-- Quick protection command for current position
minetest.register_chatcommand("protect_here", {
    params = "<radius>",
    description = S("Protect area around your current position"),
    privs = {server = true},
    func = function(name, param)
        local player = minetest.get_player_by_name(name)
        if not player then
            return false, S("Player not found")
        end

        local radius = tonumber(param) or 10
        if radius > 50 then
            return false, S("Radius too large (max 50)")
        end

        local pos = vector.round(player:get_pos())
        init_player_pos(name)

        player_positions[name].pos1 = {x = pos.x - radius, y = pos.y - 5, z = pos.z - radius}
        player_positions[name].pos2 = {x = pos.x + radius, y = pos.y + 15, z = pos.z + radius}

        local barriers_placed = create_barrier_walls(player_positions[name].pos1, player_positions[name].pos2)

        return true, S("Area protected! @1 barriers placed in @2 block radius", barriers_placed, radius)
    end,
})

minetest.log("action", "[area_protection] Mod loaded successfully")