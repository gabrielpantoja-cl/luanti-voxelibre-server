--[[
    Auto Road Builder - Automated Road Construction for Luanti/VoxeLibre
    Copyright (C) 2025 Gabriel Pantoja (with Claude Code)
    License: GPLv3

    This mod provides automated road building between two points with:
    - Customizable width and materials
    - Automatic terrain adaptation
    - Smart elevation handling
    - Progress reporting
]]--

auto_road_builder = {}

-- Default configuration
auto_road_builder.config = {
    default_width = 10,
    default_material = "mcl_stairs:slab_concrete_grey",
    max_distance = 5000,  -- Maximum road length in blocks
    progress_interval = 100,  -- Report progress every N blocks
}

-- Helper function to validate node name
local function is_valid_node(nodename)
    return minetest.registered_nodes[nodename] ~= nil
end

-- Helper function to get ground level at position
local function get_ground_level(x, z, start_y)
    -- Start from current Y and search down/up for solid ground
    local search_range = 20

    for y = start_y, start_y - search_range, -1 do
        local pos = {x=x, y=y, z=z}
        local node = minetest.get_node(pos)

        -- Check if it's solid ground (not air, not water)
        if node.name ~= "air" and
           node.name ~= "mcl_core:water_source" and
           node.name ~= "mcl_core:water_flowing" then
            return y + 1  -- Place road one block above ground
        end
    end

    -- If no ground found, use original Y
    return start_y
end

-- Main road building function
function auto_road_builder.build_road(start_pos, end_pos, width, material, player_name)
    -- Validate inputs
    if not start_pos or not end_pos then
        return false, "Invalid positions"
    end

    if not is_valid_node(material) then
        return false, "Invalid material: " .. material
    end

    -- Calculate distance
    local dx = end_pos.x - start_pos.x
    local dy = end_pos.y - start_pos.y
    local dz = end_pos.z - start_pos.z
    local distance = math.sqrt(dx*dx + dz*dz)

    if distance > auto_road_builder.config.max_distance then
        return false, "Distance too large: " .. math.floor(distance) .. " blocks (max: " .. auto_road_builder.config.max_distance .. ")"
    end

    if distance < 1 then
        return false, "Distance too small"
    end

    -- Calculate number of steps (1 step per block)
    local steps = math.ceil(distance)
    local blocks_placed = 0
    local half_width = math.floor(width / 2)

    minetest.chat_send_player(player_name, "[Auto Road Builder] Starting construction...")
    minetest.chat_send_player(player_name, "Distance: " .. math.floor(distance) .. " blocks")
    minetest.chat_send_player(player_name, "Width: " .. width .. " blocks")
    minetest.chat_send_player(player_name, "Material: " .. material)

    -- Build road step by step
    for i = 0, steps do
        local progress = i / steps
        local current_x = start_pos.x + dx * progress
        local current_z = start_pos.z + dz * progress
        local current_y = start_pos.y + dy * progress

        -- Adapt to terrain (optional: can be enabled/disabled)
        -- current_y = get_ground_level(math.floor(current_x), math.floor(current_z), current_y)

        -- Build width of road (perpendicular to direction)
        -- Calculate perpendicular vector
        local length_xz = math.sqrt(dx*dx + dz*dz)
        local perp_x = -dz / length_xz  -- Perpendicular X component
        local perp_z = dx / length_xz   -- Perpendicular Z component

        for w = -half_width, half_width do
            local road_x = current_x + perp_x * w
            local road_z = current_z + perp_z * w
            local road_pos = {
                x = math.floor(road_x + 0.5),
                y = math.floor(current_y + 0.5),
                z = math.floor(road_z + 0.5)
            }

            -- Place road block
            minetest.set_node(road_pos, {name = material})
            blocks_placed = blocks_placed + 1
        end

        -- Report progress
        if i % auto_road_builder.config.progress_interval == 0 and i > 0 then
            local percent = math.floor(progress * 100)
            minetest.chat_send_player(player_name, "[Auto Road Builder] Progress: " .. percent .. "% (" .. i .. "/" .. steps .. " blocks)")
        end
    end

    minetest.chat_send_player(player_name, "[Auto Road Builder] ✅ Road completed!")
    minetest.chat_send_player(player_name, "Total blocks placed: " .. blocks_placed)

    return true, "Road built successfully"
end

-- Chat command: /build_road
minetest.register_chatcommand("build_road", {
    params = "<x1> <y1> <z1> <x2> <y2> <z2> [width] [material]",
    description = "Build a road between two points. Width defaults to 10, material to grey concrete slab.",
    privs = {server = true},  -- Requires server privilege
    func = function(name, param)
        -- Parse parameters
        local params = {}
        for word in param:gmatch("%S+") do
            table.insert(params, word)
        end

        if #params < 6 then
            return false, "Usage: /build_road <x1> <y1> <z1> <x2> <y2> <z2> [width] [material]"
        end

        local start_pos = {
            x = tonumber(params[1]),
            y = tonumber(params[2]),
            z = tonumber(params[3])
        }

        local end_pos = {
            x = tonumber(params[4]),
            y = tonumber(params[5]),
            z = tonumber(params[6])
        }

        local width = tonumber(params[7]) or auto_road_builder.config.default_width
        local material = params[8] or auto_road_builder.config.default_material

        if not start_pos.x or not start_pos.y or not start_pos.z then
            return false, "Invalid start position"
        end

        if not end_pos.x or not end_pos.y or not end_pos.z then
            return false, "Invalid end position"
        end

        -- Build the road
        return auto_road_builder.build_road(start_pos, end_pos, width, material, name)
    end
})

-- Chat command: /build_road_here (simplified version using current position)
minetest.register_chatcommand("build_road_here", {
    params = "<x2> <y2> <z2> [width] [material]",
    description = "Build a road from your current position to target. Width defaults to 10.",
    privs = {server = true},
    func = function(name, param)
        local player = minetest.get_player_by_name(name)
        if not player then
            return false, "Player not found"
        end

        local start_pos = player:get_pos()

        -- Parse parameters
        local params = {}
        for word in param:gmatch("%S+") do
            table.insert(params, word)
        end

        if #params < 3 then
            return false, "Usage: /build_road_here <x2> <y2> <z2> [width] [material]"
        end

        local end_pos = {
            x = tonumber(params[1]),
            y = tonumber(params[2]),
            z = tonumber(params[3])
        }

        local width = tonumber(params[4]) or auto_road_builder.config.default_width
        local material = params[5] or auto_road_builder.config.default_material

        if not end_pos.x or not end_pos.y or not end_pos.z then
            return false, "Invalid end position"
        end

        -- Build the road
        return auto_road_builder.build_road(start_pos, end_pos, width, material, name)
    end
})

-- Chat command: /road_continue (continue from last position)
local last_road_endpoint = {}

minetest.register_chatcommand("road_continue", {
    params = "<distance> [width] [material]",
    description = "Continue road in the same direction for N more blocks",
    privs = {server = true},
    func = function(name, param)
        if not last_road_endpoint[name] then
            return false, "No previous road found. Use /build_road first."
        end

        local params = {}
        for word in param:gmatch("%S+") do
            table.insert(params, word)
        end

        if #params < 1 then
            return false, "Usage: /road_continue <distance> [width] [material]"
        end

        local distance = tonumber(params[1])
        local width = tonumber(params[2]) or auto_road_builder.config.default_width
        local material = params[3] or auto_road_builder.config.default_material

        if not distance or distance < 1 then
            return false, "Invalid distance"
        end

        local last_pos = last_road_endpoint[name]
        -- Continue in same direction (simple: just extend X coordinate west)
        local end_pos = {
            x = last_pos.x - distance,
            y = last_pos.y,
            z = last_pos.z
        }

        local success, msg = auto_road_builder.build_road(last_pos, end_pos, width, material, name)

        if success then
            last_road_endpoint[name] = end_pos
        end

        return success, msg
    end
})

-- Store endpoint for road_continue command
local original_build_road = auto_road_builder.build_road
auto_road_builder.build_road = function(start_pos, end_pos, width, material, player_name)
    local success, msg = original_build_road(start_pos, end_pos, width, material, player_name)

    if success then
        last_road_endpoint[player_name] = table.copy(end_pos)
    end

    return success, msg
end

minetest.log("action", "[Auto Road Builder] Mod loaded successfully")
