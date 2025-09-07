-- Home Teleport Mod

local S = minetest.get_translator("home_teleport")

-- Tabla para almacenar homes de jugadores
local homes = {}

-- Cargar homes del storage
local storage = minetest.get_mod_storage()

local function save_homes()
    storage:set_string("homes", minetest.serialize(homes))
end

local function load_homes()
    local data = storage:get_string("homes")
    if data ~= "" then
        homes = minetest.deserialize(data) or {}
    end
end

-- Cargar homes al iniciar
minetest.register_on_mods_loaded(function()
    load_homes()
    local home_count = 0
    for _ in pairs(homes or {}) do
        home_count = home_count + 1
    end
    minetest.log("info", "[Home Teleport] Mod cargado. " .. home_count .. " homes cargados.")
end)

-- Función para validar posición segura
local function is_safe_pos(pos)
    if not pos then return false end
    
    local pos_above = {x = pos.x, y = pos.y + 1, z = pos.z}
    local pos_below = {x = pos.x, y = pos.y - 1, z = pos.z}
    
    local node_below = minetest.get_node(pos_below)
    local node_at = minetest.get_node(pos)
    local node_above = minetest.get_node(pos_above)
    
    -- Verificar que hay suelo sólido abajo
    local def_below = minetest.registered_nodes[node_below.name]
    if not def_below or not def_below.walkable then
        return false
    end
    
    -- Verificar que el espacio del jugador está libre
    local def_at = minetest.registered_nodes[node_at.name]
    local def_above = minetest.registered_nodes[node_above.name]
    
    if def_at and def_at.walkable then return false end
    if def_above and def_above.walkable then return false end
    
    -- Verificar que no es lava u otros peligros
    if minetest.get_item_group(node_at.name, "destroys_items") > 0 then
        return false
    end
    
    return true
end

-- Comando /sethome
minetest.register_chatcommand("sethome", {
    description = S("Establece tu hogar en tu posición actual"),
    func = function(name, param)
        local player = minetest.get_player_by_name(name)
        if not player then
            return false, "Jugador no encontrado"
        end
        
        local pos = player:get_pos()
        pos = vector.round(pos)
        
        if not is_safe_pos(pos) then
            return false, minetest.colorize("#FF6B6B", "🏠 ¡Posición peligrosa! Busca un lugar más seguro.")
        end
        
        homes[name] = pos
        save_homes()
        
        return true, minetest.colorize("#90EE90", string.format("🏠 Hogar establecido en (%d, %d, %d)", 
            pos.x, pos.y, pos.z))
    end,
})

-- Comando /home
minetest.register_chatcommand("home", {
    description = S("Te teletransporta a tu hogar"),
    func = function(name, param)
        local player = minetest.get_player_by_name(name)
        if not player then
            return false, "Jugador no encontrado"
        end
        
        if not homes[name] then
            return false, minetest.colorize("#FF6B6B", "🏠 No tienes hogar establecido. Usa /sethome primero.")
        end
        
        local pos = homes[name]
        
        -- Verificar que la posición sigue siendo segura
        if not is_safe_pos(pos) then
            return false, minetest.colorize("#FF6B6B", "🏠 Tu hogar ya no es seguro. Usa /sethome en un nuevo lugar.")
        end
        
        player:set_pos(pos)
        return true, minetest.colorize("#90EE90", string.format("🏠 ¡Bienvenido a casa! (%d, %d, %d)", 
            pos.x, pos.y, pos.z))
    end,
})

-- Comando /spawn
minetest.register_chatcommand("spawn", {
    description = S("Te teletransporta al spawn del servidor"),
    func = function(name, param)
        local player = minetest.get_player_by_name(name)
        if not player then
            return false, "Jugador no encontrado"
        end
        
        -- Usar el sistema de spawn de VoxeLibre o fallback
        local spawn_pos = nil
        
        if mcl_spawn and mcl_spawn.get_world_spawn_pos then
            spawn_pos = mcl_spawn.get_world_spawn_pos()
        end
        
        -- Fallback a configuración del servidor
        if not spawn_pos then
            spawn_pos = minetest.setting_get_pos("static_spawnpoint") or {x = 0, y = 15, z = 0}
        end
        
        if spawn_pos then
            player:set_pos(spawn_pos)
            return true, minetest.colorize("#90EE90", string.format("🌱 Te teletransportaste al spawn (%d, %d, %d)", 
                spawn_pos.x, spawn_pos.y, spawn_pos.z))
        else
            return false, minetest.colorize("#FF6B6B", "❌ No se pudo encontrar el spawn del servidor.")
        end
    end,
})

-- Comando /setspawn para administradores
minetest.register_chatcommand("setspawn", {
    description = S("Establece el spawn del servidor (solo administradores)"),
    privs = {server = true},
    func = function(name, param)
        local player = minetest.get_player_by_name(name)
        if not player then
            return false, "Jugador no encontrado"
        end
        
        local pos = player:get_pos()
        pos = vector.round(pos)
        
        if not is_safe_pos(pos) then
            return false, minetest.colorize("#FF6B6B", "🌱 ¡Posición peligrosa para spawn! Busca un lugar más seguro.")
        end
        
        -- Actualizar configuración del servidor
        minetest.settings:set("static_spawnpoint", minetest.pos_to_string(pos))
        
        return true, minetest.colorize("#90EE90", string.format("🌱 Spawn del servidor establecido en (%d, %d, %d)", 
            pos.x, pos.y, pos.z))
    end,
})

-- Comando administrativo para ver/borrar homes
minetest.register_chatcommand("homes", {
    description = S("Lista todos los homes de los jugadores (admin)"),
    privs = {server = true},
    func = function(name, param)
        if not param or param == "" then
            -- Listar todos los homes
            if not homes or not next(homes) then
                return true, "No hay homes establecidos."
            end
            
            local msg = "🏠 Homes establecidos:\n"
            for player, pos in pairs(homes) do
                msg = msg .. string.format("• %s: (%d, %d, %d)\n", player, pos.x, pos.y, pos.z)
            end
            return true, msg
        elseif param:find("^del ") then
            -- Borrar home de un jugador
            local player_name = param:gsub("^del ", "")
            if homes[player_name] then
                homes[player_name] = nil
                save_homes()
                return true, minetest.colorize("#90EE90", "🏠 Home de " .. player_name .. " eliminado.")
            else
                return false, "El jugador " .. player_name .. " no tiene home establecido."
            end
        else
            -- Ver home de un jugador específico
            if homes[param] then
                local pos = homes[param]
                return true, string.format("🏠 Home de %s: (%d, %d, %d)", param, pos.x, pos.y, pos.z)
            else
                return false, "El jugador " .. param .. " no tiene home establecido."
            end
        end
    end,
})

-- Limpiar homes de jugadores que se desconectan (opcional, para ahorrar memoria)
minetest.register_on_leaveplayer(function(player)
    -- Mantenemos los homes incluso cuando los jugadores se desconectan
    -- Si quisiéramos limpiarlos automáticamente, podríamos hacerlo aquí
end)

-- Información del mod
minetest.log("info", "[Home Teleport] Comandos disponibles: /home, /sethome, /spawn, /setspawn, /homes")

-- Mensaje de bienvenida a nuevos jugadores
minetest.register_on_newplayer(function(player)
    minetest.after(5, function()
        if player and player:is_player() then
            minetest.chat_send_player(player:get_player_name(), 
                minetest.colorize("#90EE90", "🏠 Bienvenido a Vegan Wetlands! Usa /sethome para establecer tu hogar y /home para volver a él."))
        end
    end)
end)