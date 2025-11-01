-- VoxeLibre Protection System v1.0.0
-- Comprehensive area protection with persistent storage and VoxeLibre integration
-- Compatible with Wetlands server philosophy

local modname = minetest.get_current_modname()
local modpath = minetest.get_modpath(modname)
local S = minetest.get_translator(modname)

-- Verificar VoxeLibre
if not minetest.get_modpath("mcl_core") then
    minetest.log("error", "[" .. modname .. "] VoxeLibre requerido")
    return
end

-- Namespace del mod
local protection = {}
_G[modname] = protection

-- Storage para áreas protegidas
local storage = minetest.get_mod_storage()
local protected_areas = {}
local player_positions = {}

-- Configuración
protection.settings = {
    max_radius = tonumber(minetest.settings:get(modname .. "_max_radius") or "50"),
    default_height = tonumber(minetest.settings:get(modname .. "_default_height") or "30"),
    allow_overlap = minetest.settings:get_bool(modname .. "_allow_overlap", false),
    enable_particles = minetest.settings:get_bool(modname .. "_enable_particles", true),
}

-- Privilegios personalizados
minetest.register_privilege("protect", {
    description = S("Can create and manage area protection"),
    give_to_singleplayer = false,
    give_to_admin = true,
})

-- Funciones de utilidad
local function log(level, message)
    minetest.log(level, "[" .. modname .. "] " .. message)
end

local function validate_pos(pos)
    return pos and type(pos) == "table" and
           type(pos.x) == "number" and
           type(pos.y) == "number" and
           type(pos.z) == "number"
end

local function validate_player(player)
    return player and player:is_player() and
           player:get_player_name() ~= ""
end

-- Almacenamiento persistente
local function save_areas()
    local serialized = minetest.serialize(protected_areas)
    if serialized then
        storage:set_string("protected_areas", serialized)
        log("info", "Protected areas saved to storage")
    else
        log("error", "Failed to serialize protected areas")
    end
end

local function load_areas()
    local serialized = storage:get_string("protected_areas")
    if serialized and serialized ~= "" then
        local loaded = minetest.deserialize(serialized)
        if loaded then
            protected_areas = loaded
            local count = 0
            for _ in pairs(protected_areas) do count = count + 1 end
            log("info", "Loaded " .. count .. " protected areas from storage")
        else
            log("warning", "Failed to deserialize protected areas")
        end
    end
end

-- Detección de superposición de áreas
local function check_area_overlap(min_pos, max_pos, exclude_area)
    for area_name, area_data in pairs(protected_areas) do
        if area_name ~= exclude_area then
            local a_min = area_data.min_pos
            local a_max = area_data.max_pos

            -- Verificar superposición en 3D
            if not (max_pos.x < a_min.x or min_pos.x > a_max.x or
                    max_pos.y < a_min.y or min_pos.y > a_max.y or
                    max_pos.z < a_min.z or min_pos.z > a_max.z) then
                return area_name
            end
        end
    end
    return false
end

-- Detectar si un nodo es un cofre o contenedor
local function is_chest_or_container(pos)
    local node = minetest.get_node(pos)
    if not node or not node.name then
        return false
    end

    -- Lista de contenedores permitidos en arenas PVP
    local allowed_containers = {
        ["mcl_chests:chest"] = true,
        ["mcl_chests:chest_left"] = true,
        ["mcl_chests:chest_right"] = true,
        ["mcl_chests:ender_chest"] = true,
        ["mcl_barrels:barrel_closed"] = true,
        ["mcl_barrels:barrel_open"] = true,
        ["mcl_furnaces:furnace"] = true,
        ["mcl_furnaces:furnace_active"] = true,
        ["mcl_hoppers:hopper"] = true,
        ["mcl_hoppers:hopper_side"] = true,
    }

    return allowed_containers[node.name] or false
end

-- Función principal de protección
local function is_area_protected(pos, name, action_type)
    if not validate_pos(pos) or not name then
        return false
    end

    -- EXCEPCIÓN: Permitir abrir cofres en arenas PVP
    if action_type == "rightclick" and is_chest_or_container(pos) then
        -- Verificar si el jugador está en una arena PVP
        if pvp_arena and pvp_arena.is_player_in_arena then
            local in_arena = pvp_arena.is_player_in_arena(name)
            if in_arena then
                log("info", name .. " accessing chest in PVP arena (allowed)")
                return false -- Permitir acceso a cofres en arena
            end
        end
    end

    for area_name, area_data in pairs(protected_areas) do
        local min_pos = area_data.min_pos
        local max_pos = area_data.max_pos

        if pos.x >= min_pos.x and pos.x <= max_pos.x and
           pos.y >= min_pos.y and pos.y <= max_pos.y and
           pos.z >= min_pos.z and pos.z <= max_pos.z then

            -- Verificar permisos
            if area_data.owner == name or
               minetest.check_player_privs(name, {server = true}) or
               (area_data.members and area_data.members[name]) then
                return false -- Permitir acceso
            else
                return true, area_name -- Área protegida
            end
        end
    end
    return false -- No protegida
end

-- Registrar manejador de violación de protección
minetest.register_on_protection_violation(function(pos, name)
    local protected, area_name = is_area_protected(pos, name)
    if protected and area_name then
        local area_data = protected_areas[area_name]
        minetest.chat_send_player(name,
            S("🛡️ Área '@1' protegida por @2", area_name, area_data.owner))

        -- Efecto visual si está habilitado
        if protection.settings.enable_particles then
            minetest.add_particlespawner({
                amount = 15,
                time = 1,
                minpos = vector.subtract(pos, {x=0.5, y=0.5, z=0.5}),
                maxpos = vector.add(pos, {x=0.5, y=0.5, z=0.5}),
                minvel = {x=-1, y=0, z=-1},
                maxvel = {x=1, y=1, z=1},
                minacc = {x=0, y=-2, z=0},
                maxacc = {x=0, y=-2, z=0},
                minexptime = 1,
                maxexptime = 2,
                minsize = 1,
                maxsize = 2,
                texture = "bubble.png^[colorize:#ff0000:100",
            })
        end
    else
        minetest.chat_send_player(name, S("⚠️ Esta área está protegida!"))
    end
end)

-- Sobrescribir verificación de protección por defecto
local old_is_protected = minetest.is_protected
minetest.is_protected = function(pos, name)
    -- Primero verificar nuestras áreas
    local protected = is_area_protected(pos, name)
    if protected then
        return true
    end
    -- Luego verificar protección por defecto
    return old_is_protected(pos, name)
end

-- === COMANDOS DE CHAT ===

-- Comando pos1
minetest.register_chatcommand("pos1", {
    params = "",
    description = S("Establecer posición 1 para protección de área"),
    privs = {protect = true},
    func = function(name, param)
        local player = minetest.get_player_by_name(name)
        if not validate_player(player) then
            return false, S("Jugador no encontrado")
        end

        if not player_positions[name] then
            player_positions[name] = {}
        end

        local pos = vector.round(player:get_pos())
        player_positions[name].pos1 = pos

        return true, S("Posición 1 establecida en @1", minetest.pos_to_string(pos))
    end,
})

-- Comando pos2
minetest.register_chatcommand("pos2", {
    params = "",
    description = S("Establecer posición 2 para protección de área"),
    privs = {protect = true},
    func = function(name, param)
        local player = minetest.get_player_by_name(name)
        if not validate_player(player) then
            return false, S("Jugador no encontrado")
        end

        if not player_positions[name] then
            player_positions[name] = {}
        end

        local pos = vector.round(player:get_pos())
        player_positions[name].pos2 = pos

        return true, S("Posición 2 establecida en @1", minetest.pos_to_string(pos))
    end,
})

-- Comando protect_area
minetest.register_chatcommand("protect_area", {
    params = S("<nombre_area>"),
    description = S("Proteger área entre pos1 y pos2"),
    privs = {protect = true},
    func = function(name, param)
        if not player_positions[name] or
           not player_positions[name].pos1 or
           not player_positions[name].pos2 then
            return false, S("¡Necesitas establecer pos1 y pos2 primero!")
        end

        if param == "" then
            return false, S("¡Necesitas proporcionar un nombre de área!")
        end

        -- Verificar si el área ya existe
        if protected_areas[param] then
            return false, S("El área '@1' ya existe!", param)
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

        -- Verificar superposición si no está permitida
        if not protection.settings.allow_overlap then
            local overlap = check_area_overlap(min_pos, max_pos)
            if overlap then
                return false, S("El área se superpone con '@1'", overlap)
            end
        end

        -- Verificar tamaño máximo
        local size_x = max_pos.x - min_pos.x + 1
        local size_z = max_pos.z - min_pos.z + 1
        local max_size = protection.settings.max_radius * 2

        if size_x > max_size or size_z > max_size then
            return false, S("Área demasiado grande. Máximo: @1x@1", max_size)
        end

        protected_areas[param] = {
            owner = name,
            min_pos = min_pos,
            max_pos = max_pos,
            created = os.time(),
            members = {}
        }

        save_areas()

        local volume = (max_pos.x - min_pos.x + 1) *
                      (max_pos.y - min_pos.y + 1) *
                      (max_pos.z - min_pos.z + 1)

        return true, S("¡Área '@1' protegida! Volumen: @2 bloques", param, volume)
    end,
})

-- Comando unprotect_area
minetest.register_chatcommand("unprotect_area", {
    params = S("<nombre_area>"),
    description = S("Quitar protección de área"),
    privs = {protect = true},
    func = function(name, param)
        if param == "" then
            return false, S("¡Necesitas proporcionar un nombre de área!")
        end

        if not protected_areas[param] then
            return false, S("¡Área '@1' no encontrada!", param)
        end

        if protected_areas[param].owner ~= name and
           not minetest.check_player_privs(name, {server = true}) then
            return false, S("¡No eres propietario de esta área!")
        end

        protected_areas[param] = nil
        save_areas()

        return true, S("¡Área '@1' desprotegida!", param)
    end,
})

-- Comando list_areas
minetest.register_chatcommand("list_areas", {
    params = "",
    description = S("Listar todas las áreas protegidas"),
    func = function(name, param)
        local areas_text = S("Áreas protegidas:") .. "\n"
        local count = 0

        for area_name, area_data in pairs(protected_areas) do
            local member_count = 0
            for _ in pairs(area_data.members or {}) do member_count = member_count + 1 end

            areas_text = areas_text .. "- " .. area_name ..
                        " (" .. S("propietario") .. ": " .. area_data.owner ..
                        ", " .. S("miembros") .. ": " .. member_count .. ")\n"
            count = count + 1
        end

        if count == 0 then
            return true, S("No se encontraron áreas protegidas.")
        end

        return true, areas_text
    end,
})

-- Comando protect_here - Protección rápida
minetest.register_chatcommand("protect_here", {
    params = S("<radio> <nombre_area>"),
    description = S("Proteger área alrededor de la posición actual"),
    privs = {protect = true},
    func = function(name, param)
        local player = minetest.get_player_by_name(name)
        if not validate_player(player) then
            return false, S("Jugador no encontrado")
        end

        local parts = param:split(" ")
        local radius = tonumber(parts[1]) or 10
        local area_name = parts[2] or ("area_" .. name .. "_" .. os.time())

        if radius > protection.settings.max_radius then
            return false, S("Radio máximo es @1 bloques", protection.settings.max_radius)
        end

        if radius < 1 then
            return false, S("Radio mínimo es 1 bloque")
        end

        -- Verificar si el área ya existe
        if protected_areas[area_name] then
            return false, S("El área '@1' ya existe!", area_name)
        end

        local pos = vector.round(player:get_pos())
        local height = protection.settings.default_height

        local min_pos = {x = pos.x - radius, y = pos.y - 10, z = pos.z - radius}
        local max_pos = {x = pos.x + radius, y = pos.y + height, z = pos.z + radius}

        -- Verificar superposición
        if not protection.settings.allow_overlap then
            local overlap = check_area_overlap(min_pos, max_pos)
            if overlap then
                return false, S("El área se superpondría con '@1'", overlap)
            end
        end

        protected_areas[area_name] = {
            owner = name,
            min_pos = min_pos,
            max_pos = max_pos,
            created = os.time(),
            members = {}
        }

        save_areas()

        return true, S("¡Área '@1' protegida con radio de @2 bloques!", area_name, radius)
    end,
})

-- Comando add_member
minetest.register_chatcommand("area_add_member", {
    params = S("<nombre_area> <jugador>"),
    description = S("Añadir miembro a área protegida"),
    privs = {protect = true},
    func = function(name, param)
        local parts = param:split(" ")
        local area_name = parts[1]
        local member_name = parts[2]

        if not area_name or not member_name then
            return false, S("Uso: /area_add_member <nombre_area> <jugador>")
        end

        if not protected_areas[area_name] then
            return false, S("¡Área '@1' no encontrada!", area_name)
        end

        local area_data = protected_areas[area_name]
        if area_data.owner ~= name and
           not minetest.check_player_privs(name, {server = true}) then
            return false, S("¡No eres propietario de esta área!")
        end

        if not area_data.members then
            area_data.members = {}
        end

        area_data.members[member_name] = true
        save_areas()

        return true, S("¡Jugador '@1' añadido al área '@2'!", member_name, area_name)
    end,
})

-- Comando remove_member
minetest.register_chatcommand("area_remove_member", {
    params = S("<nombre_area> <jugador>"),
    description = S("Quitar miembro de área protegida"),
    privs = {protect = true},
    func = function(name, param)
        local parts = param:split(" ")
        local area_name = parts[1]
        local member_name = parts[2]

        if not area_name or not member_name then
            return false, S("Uso: /area_remove_member <nombre_area> <jugador>")
        end

        if not protected_areas[area_name] then
            return false, S("¡Área '@1' no encontrada!", area_name)
        end

        local area_data = protected_areas[area_name]
        if area_data.owner ~= name and
           not minetest.check_player_privs(name, {server = true}) then
            return false, S("¡No eres propietario de esta área!")
        end

        if area_data.members and area_data.members[member_name] then
            area_data.members[member_name] = nil
            save_areas()
            return true, S("¡Jugador '@1' removido del área '@2'!", member_name, area_name)
        else
            return false, S("¡Jugador '@1' no es miembro del área '@2'!", member_name, area_name)
        end
    end,
})

-- Comando de información de área
minetest.register_chatcommand("area_info", {
    params = S("<nombre_area>"),
    description = S("Mostrar información detallada de área"),
    func = function(name, param)
        if param == "" then
            return false, S("¡Necesitas proporcionar un nombre de área!")
        end

        if not protected_areas[param] then
            return false, S("¡Área '@1' no encontrada!", param)
        end

        local area = protected_areas[param]
        local info = S("=== Información del Área '@1' ===", param) .. "\n"
        info = info .. S("Propietario: @1", area.owner) .. "\n"
        info = info .. S("Creada: @1", os.date("%Y-%m-%d %H:%M:%S", area.created or 0)) .. "\n"
        info = info .. S("Posición mínima: @1", minetest.pos_to_string(area.min_pos)) .. "\n"
        info = info .. S("Posición máxima: @1", minetest.pos_to_string(area.max_pos)) .. "\n"

        local volume = (area.max_pos.x - area.min_pos.x + 1) *
                      (area.max_pos.y - area.min_pos.y + 1) *
                      (area.max_pos.z - area.min_pos.z + 1)
        info = info .. S("Volumen: @1 bloques", volume) .. "\n"

        if area.members then
            local member_list = {}
            for member, _ in pairs(area.members) do
                table.insert(member_list, member)
            end
            if #member_list > 0 then
                info = info .. S("Miembros: @1", table.concat(member_list, ", "))
            else
                info = info .. S("Miembros: Ninguno")
            end
        end

        return true, info
    end,
})

-- === INICIALIZACIÓN ===

-- Cargar áreas al inicializar
load_areas()

-- Guardar áreas periódicamente
local save_timer = 0
minetest.register_globalstep(function(dtime)
    save_timer = save_timer + dtime
    if save_timer >= 300 then -- Guardar cada 5 minutos
        save_areas()
        save_timer = 0
    end
end)

-- Guardar al cerrar servidor
minetest.register_on_shutdown(function()
    save_areas()
    log("info", "Areas saved on server shutdown")
end)

-- API pública para otros mods
protection.get_areas = function()
    return protected_areas
end

protection.is_protected = is_area_protected

protection.add_area = function(name, min_pos, max_pos, owner)
    if not name or not min_pos or not max_pos or not owner then
        return false, "Invalid parameters"
    end

    if protected_areas[name] then
        return false, "Area already exists"
    end

    protected_areas[name] = {
        owner = owner,
        min_pos = min_pos,
        max_pos = max_pos,
        created = os.time(),
        members = {}
    }

    save_areas()
    return true, "Area created successfully"
end

-- Hook para detectar acceso a cofres/contenedores
minetest.register_on_player_receive_fields(function(player, formname, fields)
    -- Este hook se dispara cuando se abre un formspec (inventario de cofre)
    -- Pero necesitamos interceptar ANTES de que se abra
end)

-- Override de can_dig para cofres (impedir romper en áreas protegidas)
local function register_chest_protection()
    -- Lista de tipos de cofres a proteger
    local chest_types = {
        "mcl_chests:chest",
        "mcl_chests:chest_left",
        "mcl_chests:chest_right",
        "mcl_barrels:barrel_closed",
        "mcl_barrels:barrel_open",
    }

    for _, chest_name in ipairs(chest_types) do
        local chest_def = minetest.registered_nodes[chest_name]
        if chest_def then
            local old_on_rightclick = chest_def.on_rightclick

            -- Sobrescribir on_rightclick para verificar permisos
            minetest.override_item(chest_name, {
                on_rightclick = function(pos, node, clicker, itemstack, pointed_thing)
                    if not clicker or not clicker:is_player() then
                        return itemstack
                    end

                    local player_name = clicker:get_player_name()

                    -- Verificar protección con tipo "rightclick"
                    local protected, area_name = is_area_protected(pos, player_name, "rightclick")

                    if protected then
                        minetest.chat_send_player(player_name,
                            S("🛡️ Este cofre está protegido en el área '@1'", area_name or "desconocida"))
                        return itemstack
                    end

                    -- Si no está protegido o tiene permisos, permitir abrir
                    if old_on_rightclick then
                        return old_on_rightclick(pos, node, clicker, itemstack, pointed_thing)
                    end

                    return itemstack
                end
            })

            log("info", "Registered chest protection for " .. chest_name)
        end
    end
end

-- Registrar protección de cofres después de que todos los mods carguen
minetest.register_on_mods_loaded(function()
    minetest.after(0.1, function()
        register_chest_protection()
        log("action", "Chest protection hooks installed")
    end)
end)

log("action", "VoxeLibre Protection System loaded successfully!")
log("info", "Loaded " .. (function()
    local count = 0
    for _ in pairs(protected_areas) do count = count + 1 end
    return count
end)() .. " protected areas")
log("info", "PVP Arena integration: " .. (pvp_arena and "ENABLED" or "DISABLED"))