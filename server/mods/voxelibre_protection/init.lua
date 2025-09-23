-- VoxeLibre Protection System
-- Uses native Luanti protection API

minetest.log("action", "[voxelibre_protection] Loading...")

-- Storage for protected areas
local protected_areas = {}
local player_positions = {}

-- Protection function - this is what VoxeLibre calls
local function is_area_protected(pos, name)
    for area_name, area_data in pairs(protected_areas) do
        local min_pos = area_data.min_pos
        local max_pos = area_data.max_pos

        if pos.x >= min_pos.x and pos.x <= max_pos.x and
           pos.y >= min_pos.y and pos.y <= max_pos.y and
           pos.z >= min_pos.z and pos.z <= max_pos.z then
            -- Check if player is owner or has permission
            if area_data.owner == name or name == "gabo" then
                return false -- Allow access
            else
                return true -- Protect area
            end
        end
    end
    return false -- Not protected
end

-- Register our protection handler
minetest.register_on_protection_violation(function(pos, name)
    minetest.chat_send_player(name, "⚠️ Esta área está protegida!")
end)

-- Override default protection check
local old_is_protected = minetest.is_protected
minetest.is_protected = function(pos, name)
    -- First check our areas
    if is_area_protected(pos, name) then
        return true
    end
    -- Then check default protection
    return old_is_protected(pos, name)
end

-- Commands
minetest.register_chatcommand("pos1", {
    params = "",
    description = "Set position 1 for area protection",
    privs = {server = true},
    func = function(name, param)
        local player = minetest.get_player_by_name(name)
        if not player then return false, "Player not found" end

        if not player_positions[name] then
            player_positions[name] = {}
        end

        local pos = vector.round(player:get_pos())
        player_positions[name].pos1 = pos

        return true, "Position 1 set to " .. minetest.pos_to_string(pos)
    end,
})

minetest.register_chatcommand("pos2", {
    params = "",
    description = "Set position 2 for area protection",
    privs = {server = true},
    func = function(name, param)
        local player = minetest.get_player_by_name(name)
        if not player then return false, "Player not found" end

        if not player_positions[name] then
            player_positions[name] = {}
        end

        local pos = vector.round(player:get_pos())
        player_positions[name].pos2 = pos

        return true, "Position 2 set to " .. minetest.pos_to_string(pos)
    end,
})

minetest.register_chatcommand("protect_area", {
    params = "<area_name>",
    description = "Protect area between pos1 and pos2",
    privs = {server = true},
    func = function(name, param)
        if not player_positions[name] or not player_positions[name].pos1 or not player_positions[name].pos2 then
            return false, "You need to set both pos1 and pos2 first!"
        end

        if param == "" then
            return false, "You need to provide an area name!"
        end

        local pos1 = player_positions[name].pos1
        local pos2 = player_positions[name].pos2

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

        protected_areas[param] = {
            owner = name,
            min_pos = min_pos,
            max_pos = max_pos
        }

        local volume = (max_pos.x - min_pos.x + 1) *
                      (max_pos.y - min_pos.y + 1) *
                      (max_pos.z - min_pos.z + 1)

        return true, "Area '" .. param .. "' protected! Volume: " .. volume .. " blocks"
    end,
})

minetest.register_chatcommand("unprotect_area", {
    params = "<area_name>",
    description = "Remove protection from area",
    privs = {server = true},
    func = function(name, param)
        if param == "" then
            return false, "You need to provide an area name!"
        end

        if not protected_areas[param] then
            return false, "Area '" .. param .. "' not found!"
        end

        if protected_areas[param].owner ~= name and name ~= "gabo" then
            return false, "You don't own this area!"
        end

        protected_areas[param] = nil
        return true, "Area '" .. param .. "' unprotected!"
    end,
})

minetest.register_chatcommand("list_areas", {
    params = "",
    description = "List all protected areas",
    privs = {server = true},
    func = function(name, param)
        local areas_text = "Protected areas:\n"
        local count = 0

        for area_name, area_data in pairs(protected_areas) do
            areas_text = areas_text .. "- " .. area_name .. " (owner: " .. area_data.owner .. ")\n"
            count = count + 1
        end

        if count == 0 then
            return true, "No protected areas found."
        end

        return true, areas_text
    end,
})

-- Quick protection for current position
minetest.register_chatcommand("protect_here", {
    params = "<radius> <area_name>",
    description = "Protect area around current position",
    privs = {server = true},
    func = function(name, param)
        local player = minetest.get_player_by_name(name)
        if not player then return false, "Player not found" end

        local parts = param:split(" ")
        local radius = tonumber(parts[1]) or 10
        local area_name = parts[2] or ("area_" .. name .. "_" .. os.time())

        if radius > 50 then
            return false, "Maximum radius is 50 blocks"
        end

        local pos = vector.round(player:get_pos())

        protected_areas[area_name] = {
            owner = name,
            min_pos = {x = pos.x - radius, y = pos.y - 10, z = pos.z - radius},
            max_pos = {x = pos.x + radius, y = pos.y + 20, z = pos.z + radius}
        }

        return true, "Area '" .. area_name .. "' protected with " .. radius .. " block radius!"
    end,
})

minetest.log("action", "[voxelibre_protection] Loaded successfully!")