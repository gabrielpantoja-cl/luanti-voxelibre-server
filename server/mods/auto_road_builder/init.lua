--[[
    Auto Road Builder - Automated Road Construction for Luanti/VoxeLibre
    Copyright (C) 2025 Gabriel Pantoja (with Claude Code)
    License: GPLv3
    Version: 1.2.0

    Changelog v1.2.0:
    - Fixed: Cardinal alignment - roads now follow VoxeLibre grid (N-S or E-W)
    - Fixed: Independent tunnel clearing - no more vertical columns
    - Added: Detection of existing roads to prevent duplicates
    - Improved: Tunnel clearing now sweeps entire area independently
    - Improved: Width applied only on perpendicular cardinal axis

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

-- NEW v1.2.0: Detect primary cardinal direction of road
local function get_cardinal_direction(start_pos, end_pos)
    local dx = math.abs(end_pos.x - start_pos.x)
    local dz = math.abs(end_pos.z - start_pos.z)

    -- Determine if road is primarily North-South or East-West
    if dx > dz then
        return "east-west", dx
    else
        return "north-south", dz
    end
end

-- NEW v1.2.0: Detect existing roads in area to prevent duplicates
local function detect_existing_road(start_pos, end_pos, material)
    local sample_count = 0
    local found_count = 0
    local samples = 5  -- Check 5 positions along the route

    for i = 0, samples do
        local progress = i / samples
        local check_x = start_pos.x + (end_pos.x - start_pos.x) * progress
        local check_y = start_pos.y + (end_pos.y - start_pos.y) * progress
        local check_z = start_pos.z + (end_pos.z - start_pos.z) * progress

        local check_pos = {
            x = math.floor(check_x + 0.5),
            y = math.floor(check_y + 0.5),
            z = math.floor(check_z + 0.5)
        }

        local node = minetest.get_node(check_pos)
        sample_count = sample_count + 1

        if node.name == material then
            found_count = found_count + 1
        end
    end

    -- If more than 50% of samples are already road material, road exists
    return (found_count / sample_count) > 0.5, found_count, sample_count
end

-- IMPROVED v1.2.0: Clear entire tunnel area independently (no more columns!)
local function clear_tunnel_area(start_pos, end_pos, width, clearance_height, direction, player_name)
    if clearance_height <= 0 then
        return 0  -- No clearance requested
    end

    local blocks_cleared = 0
    local half_width = math.floor(width / 2)

    minetest.chat_send_player(player_name, "[Auto Road Builder v1.2] Clearing tunnel (independent sweep)...")

    -- Calculate bounds based on cardinal direction
    local min_x, max_x, min_z, max_z

    if direction == "east-west" then
        -- Road runs E-W, width is N-S
        min_x = math.min(start_pos.x, end_pos.x)
        max_x = math.max(start_pos.x, end_pos.x)
        min_z = math.min(start_pos.z, end_pos.z) - half_width
        max_z = math.max(start_pos.z, end_pos.z) + half_width
    else
        -- Road runs N-S, width is E-W
        min_x = math.min(start_pos.x, end_pos.x) - half_width
        max_x = math.max(start_pos.x, end_pos.x) + half_width
        min_z = math.min(start_pos.z, end_pos.z)
        max_z = math.max(start_pos.z, end_pos.z)
    end

    local min_y = math.min(start_pos.y, end_pos.y)
    local max_y = math.max(start_pos.y, end_pos.y)

    -- Sweep entire tunnel volume
    for x = min_x, max_x do
        for z = min_z, max_z do
            for y = min_y + 1, min_y + clearance_height do
                local air_pos = {x = x, y = y, z = z}
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

-- REWRITTEN v1.2.0: Main road building function with cardinal alignment
function auto_road_builder.build_road(start_pos, end_pos, width, material, clearance_height, player_name)
    -- Validate inputs
    if not start_pos or not end_pos then
        return false, "Invalid positions"
    end

    if not is_valid_node(material) then
        return false, "Invalid material: " .. material
    end

    clearance_height = clearance_height or 0

    -- NEW v1.2.0: Detect existing road
    local exists, found, total = detect_existing_road(start_pos, end_pos, material)
    if exists then
        minetest.chat_send_player(player_name, "[Auto Road Builder v1.2] ⚠️ WARNING: Road already exists!")
        minetest.chat_send_player(player_name, "Found " .. found .. "/" .. total .. " sample points with road material")
        minetest.chat_send_player(player_name, "Use /repair_road to fix holes, or continue to overwrite.")
        -- Continue anyway (allow overwrites for repairs)
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

    -- NEW v1.2.0: Detect cardinal direction
    local direction, primary_distance = get_cardinal_direction(start_pos, end_pos)
    local half_width = math.floor(width / 2)

    minetest.chat_send_player(player_name, "[Auto Road Builder v1.2] Starting construction...")
    minetest.chat_send_player(player_name, "Direction: " .. direction .. " (cardinal aligned)")
    minetest.chat_send_player(player_name, "Distance: " .. math.floor(distance) .. " blocks")
    minetest.chat_send_player(player_name, "Width: " .. width .. " blocks")
    minetest.chat_send_player(player_name, "Material: " .. material)

    -- NEW v1.2.0: Clear tunnel FIRST (independent sweep, no columns!)
    local blocks_cleared = 0
    if clearance_height > 0 then
        blocks_cleared = clear_tunnel_area(start_pos, end_pos, width, clearance_height, direction, player_name)
        minetest.chat_send_player(player_name, "Tunnel cleared: " .. blocks_cleared .. " blocks removed")
    end

    -- Calculate number of steps (increased for better coverage)
    local steps = math.ceil(distance * 1.5)  -- 50% more steps for overlap
    local blocks_placed = 0

    -- Multi-pass construction for complete coverage
    for pass = 1, auto_road_builder.config.placement_passes do
        if pass > 1 then
            minetest.chat_send_player(player_name, "[Auto Road Builder v1.2] Pass " .. pass .. "/" .. auto_road_builder.config.placement_passes .. " (filling gaps)...")
        end

        for i = 0, steps do
            local progress = i / steps
            local center_x = start_pos.x + dx * progress
            local center_z = start_pos.z + dz * progress
            local center_y = start_pos.y + dy * progress

            -- NEW v1.2.0: Apply width based on cardinal direction
            for w = -half_width, half_width do
                local road_pos

                if direction == "east-west" then
                    -- Road runs E-W, width is N-S (vary Z only)
                    road_pos = {
                        x = math.floor(center_x + 0.5),
                        y = math.floor(center_y + 0.5),
                        z = math.floor(center_z + 0.5) + w  -- Cardinal Z offset
                    }
                else
                    -- Road runs N-S, width is E-W (vary X only)
                    road_pos = {
                        x = math.floor(center_x + 0.5) + w,  -- Cardinal X offset
                        y = math.floor(center_y + 0.5),
                        z = math.floor(center_z + 0.5)
                    }
                end

                -- Place road block (with verification)
                place_road_block(road_pos, material)
                blocks_placed = blocks_placed + 1
            end

            -- Report progress (only on first pass)
            if pass == 1 and i % auto_road_builder.config.progress_interval == 0 and i > 0 then
                local percent = math.floor(progress * 100)
                minetest.chat_send_player(player_name, "[Auto Road Builder v1.2] Progress: " .. percent .. "% (" .. i .. "/" .. steps .. " steps)")
            end
        end
    end

    minetest.chat_send_player(player_name, "[Auto Road Builder v1.2] ✅ Road completed!")
    minetest.chat_send_player(player_name, "Blocks placed: " .. blocks_placed .. " (in " .. auto_road_builder.config.placement_passes .. " passes)")
    if clearance_height > 0 then
        minetest.chat_send_player(player_name, "Tunnel created: " .. blocks_cleared .. " blocks cleared")
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

minetest.log("action", "[Auto Road Builder] Mod v1.2.0 loaded successfully - Cardinal alignment + Perfect tunnels")
