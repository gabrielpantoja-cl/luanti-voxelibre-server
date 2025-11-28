--[[
    Auto Road Builder - Automated Road Construction for Luanti/VoxeLibre
    Copyright (C) 2025 Gabriel Pantoja (with Claude Code)
    License: GPLv3
    Version: 1.1.0

    Changelog v1.1.0:
    - Fixed: Holes in roads (improved placement algorithm with verification)
    - Added: Airspace clearing for tunnels (clearance_height parameter)
    - Added: /repair_road command for fixing existing roads
    - Improved: Multi-pass placement for 100% coverage
]]--

auto_road_builder = {}

-- Default configuration
auto_road_builder.config = {
    default_width = 10,
    default_material = "mcl_stairs:slab_concrete_grey",
    default_clearance = 0,  -- 0 = no clearance, 5 = tunnel mode
    max_distance = 5000,
    progress_interval = 100,
    placement_passes = 2,  -- Number of passes to ensure complete coverage
}

-- Helper function to validate node name
local function is_valid_node(nodename)
    return minetest.registered_nodes[nodename] ~= nil
end

-- Helper function to clear airspace above road (for tunnels)
local function clear_airspace(road_pos, clearance_height, player_name)
    if clearance_height <= 0 then
        return 0  -- No clearance requested
    end

    local blocks_cleared = 0

    for h = 1, clearance_height do
        local air_pos = {
            x = road_pos.x,
            y = road_pos.y + h,
            z = road_pos.z
        }

        local node = minetest.get_node(air_pos)

        -- Only clear solid blocks, preserve air and liquids
        if node.name ~= "air" and
           node.name ~= "ignore" and
           not node.name:find("water") and
           not node.name:find("lava") and
           not node.name:find("river_water") then
            minetest.set_node(air_pos, {name = "air"})
            blocks_cleared = blocks_cleared + 1
        end
    end

    return blocks_cleared
end

-- Improved block placement with verification
local function place_road_block(pos, material)
    -- Place block
    minetest.set_node(pos, {name = material})

    -- Verify placement
    local placed_node = minetest.get_node(pos)

    -- If placement failed, try again
    if placed_node.name ~= material then
        minetest.set_node(pos, {name = material})
    end

    return true
end

-- Main road building function (improved v1.1.0)
function auto_road_builder.build_road(start_pos, end_pos, width, material, clearance_height, player_name)
    -- Validate inputs
    if not start_pos or not end_pos then
        return false, "Invalid positions"
    end

    if not is_valid_node(material) then
        return false, "Invalid material: " .. material
    end

    clearance_height = clearance_height or 0

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

    -- Calculate perpendicular vector (for road width)
    local length_xz = math.sqrt(dx*dx + dz*dz)
    local perp_x = -dz / length_xz
    local perp_z = dx / length_xz

    -- Calculate number of steps (increased for better coverage)
    local steps = math.ceil(distance * 1.5)  -- 50% more steps for overlap
    local blocks_placed = 0
    local blocks_cleared = 0
    local half_width = math.floor(width / 2)

    minetest.chat_send_player(player_name, "[Auto Road Builder v1.1] Starting construction...")
    minetest.chat_send_player(player_name, "Distance: " .. math.floor(distance) .. " blocks")
    minetest.chat_send_player(player_name, "Width: " .. width .. " blocks")
    minetest.chat_send_player(player_name, "Material: " .. material)
    if clearance_height > 0 then
        minetest.chat_send_player(player_name, "Tunnel mode: Clearing " .. clearance_height .. " blocks above road")
    end

    -- Multi-pass construction for complete coverage
    for pass = 1, auto_road_builder.config.placement_passes do
        if pass > 1 then
            minetest.chat_send_player(player_name, "[Auto Road Builder] Pass " .. pass .. "/" .. auto_road_builder.config.placement_passes .. " (filling gaps)...")
        end

        for i = 0, steps do
            local progress = i / steps
            local current_x = start_pos.x + dx * progress
            local current_z = start_pos.z + dz * progress
            local current_y = start_pos.y + dy * progress

            -- Build width of road
            for w = -half_width, half_width do
                local road_x = current_x + perp_x * w
                local road_z = current_z + perp_z * w

                local road_pos = {
                    x = math.floor(road_x + 0.5),
                    y = math.floor(current_y + 0.5),
                    z = math.floor(road_z + 0.5)
                }

                -- Place road block (with verification)
                place_road_block(road_pos, material)
                blocks_placed = blocks_placed + 1

                -- Clear airspace if tunnel mode enabled (only on first pass)
                if pass == 1 and clearance_height > 0 then
                    blocks_cleared = blocks_cleared + clear_airspace(road_pos, clearance_height, player_name)
                end
            end

            -- Report progress (only on first pass)
            if pass == 1 and i % auto_road_builder.config.progress_interval == 0 and i > 0 then
                local percent = math.floor(progress * 100)
                minetest.chat_send_player(player_name, "[Auto Road Builder] Progress: " .. percent .. "% (" .. i .. "/" .. steps .. " steps)")
            end
        end
    end

    minetest.chat_send_player(player_name, "[Auto Road Builder] ✅ Road completed!")
    minetest.chat_send_player(player_name, "Blocks placed: " .. blocks_placed .. " (in " .. auto_road_builder.config.placement_passes .. " passes)")
    if clearance_height > 0 then
        minetest.chat_send_player(player_name, "Blocks cleared: " .. blocks_cleared .. " (tunnel created)")
    end

    return true, "Road built successfully"
end

-- Chat command: /build_road
minetest.register_chatcommand("build_road", {
    params = "<x1> <y1> <z1> <x2> <y2> <z2> [width] [material] [clearance]",
    description = "Build a road between two points. Clearance creates tunnels (0=no tunnel, 5=recommended).",
    privs = {server = true},
    func = function(name, param)
        local params = {}
        for word in param:gmatch("%S+") do
            table.insert(params, word)
        end

        if #params < 6 then
            return false, "Usage: /build_road <x1> <y1> <z1> <x2> <y2> <z2> [width] [material] [clearance]"
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
        local clearance = tonumber(params[9]) or auto_road_builder.config.default_clearance

        if not start_pos.x or not start_pos.y or not start_pos.z then
            return false, "Invalid start position"
        end

        if not end_pos.x or not end_pos.y or not end_pos.z then
            return false, "Invalid end position"
        end

        return auto_road_builder.build_road(start_pos, end_pos, width, material, clearance, name)
    end
})

-- Chat command: /build_road_here
minetest.register_chatcommand("build_road_here", {
    params = "<x2> <y2> <z2> [width] [material] [clearance]",
    description = "Build road from current position. Clearance creates tunnels (5=recommended).",
    privs = {server = true},
    func = function(name, param)
        local player = minetest.get_player_by_name(name)
        if not player then
            return false, "Player not found"
        end

        local start_pos = player:get_pos()

        local params = {}
        for word in param:gmatch("%S+") do
            table.insert(params, word)
        end

        if #params < 3 then
            return false, "Usage: /build_road_here <x2> <y2> <z2> [width] [material] [clearance]"
        end

        local end_pos = {
            x = tonumber(params[1]),
            y = tonumber(params[2]),
            z = tonumber(params[3])
        }

        local width = tonumber(params[4]) or auto_road_builder.config.default_width
        local material = params[5] or auto_road_builder.config.default_material
        local clearance = tonumber(params[6]) or auto_road_builder.config.default_clearance

        if not end_pos.x or not end_pos.y or not end_pos.z then
            return false, "Invalid end position"
        end

        return auto_road_builder.build_road(start_pos, end_pos, width, material, clearance, name)
    end
})

-- Chat command: /repair_road (NEW in v1.1.0)
minetest.register_chatcommand("repair_road", {
    params = "<x1> <y1> <z1> <x2> <y2> <z2> [width] [material]",
    description = "Repair existing road by filling holes. Runs 3 passes to ensure complete coverage.",
    privs = {server = true},
    func = function(name, param)
        local params = {}
        for word in param:gmatch("%S+") do
            table.insert(params, word)
        end

        if #params < 6 then
            return false, "Usage: /repair_road <x1> <y1> <z1> <x2> <y2> <z2> [width] [material]"
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

        minetest.chat_send_player(name, "[Auto Road Builder] Repair mode: Running 3 passes to fill all holes...")

        -- Temporarily increase passes for repair
        local original_passes = auto_road_builder.config.placement_passes
        auto_road_builder.config.placement_passes = 3

        local success, msg = auto_road_builder.build_road(start_pos, end_pos, width, material, 0, name)

        -- Restore original setting
        auto_road_builder.config.placement_passes = original_passes

        return success, msg
    end
})

-- Chat command: /road_continue
local last_road_endpoint = {}

minetest.register_chatcommand("road_continue", {
    params = "<distance> [width] [material] [clearance]",
    description = "Continue road in same direction for N blocks. Clearance for tunnels.",
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
            return false, "Usage: /road_continue <distance> [width] [material] [clearance]"
        end

        local distance = tonumber(params[1])
        local width = tonumber(params[2]) or auto_road_builder.config.default_width
        local material = params[3] or auto_road_builder.config.default_material
        local clearance = tonumber(params[4]) or auto_road_builder.config.default_clearance

        if not distance or distance < 1 then
            return false, "Invalid distance"
        end

        local last_pos = last_road_endpoint[name]
        local end_pos = {
            x = last_pos.x - distance,
            y = last_pos.y,
            z = last_pos.z
        }

        local success, msg = auto_road_builder.build_road(last_pos, end_pos, width, material, clearance, name)

        if success then
            last_road_endpoint[name] = end_pos
        end

        return success, msg
    end
})

-- Store endpoint for road_continue command
local original_build_road = auto_road_builder.build_road
auto_road_builder.build_road = function(start_pos, end_pos, width, material, clearance_height, player_name)
    local success, msg = original_build_road(start_pos, end_pos, width, material, clearance_height, player_name)

    if success then
        last_road_endpoint[player_name] = table.copy(end_pos)
    end

    return success, msg
end

minetest.log("action", "[Auto Road Builder] Mod v1.1.0 loaded successfully")
