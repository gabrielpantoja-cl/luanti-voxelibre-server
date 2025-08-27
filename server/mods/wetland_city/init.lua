-- ====================================
-- WETLAND CITY MOD - WETLANDS 🌿
-- ====================================
-- Genera una ciudad humedal eco-amigable
-- Inspirada en Valdivia, Chile - "La Región de los Ríos"

local S = minetest.get_translator("wetland_city")

-- Definir nodos personalizados para la ciudad humedal
wetland_city = {}

-- Detectar si estamos usando VoxeLibre o default
local using_mcl = minetest.get_modpath("mcl_core") ~= nil
local water_source = using_mcl and "mcl_core:water_source" or "default:water_source"
local dirt = using_mcl and "mcl_core:dirt" or "default:dirt"
local grass = using_mcl and "mcl_core:dirt_with_grass" or "default:dirt_with_grass"
local stone = using_mcl and "mcl_core:stone" or "default:stone"
local wood = using_mcl and "mcl_core:wood" or "default:wood"
local leaves = using_mcl and "mcl_core:leaves" or "default:leaves"
local tree = using_mcl and "mcl_core:tree" or "default:tree"
local papyrus = using_mcl and "mcl_flowers:reeds" or "default:papyrus"

-- Nodo especial: Sendero de madera para humedales
minetest.register_node("wetland_city:boardwalk", {
    description = S("Sendero de Madera Humedal"),
    tiles = {"wetland_city_boardwalk.png"},
    groups = {choppy = 2, oddly_breakable_by_hand = 2, wood = 1},
    sounds = default and default.node_sound_wood_defaults() or {},
})

-- Nodo: Plataforma observación aves
minetest.register_node("wetland_city:bird_platform", {
    description = S("Plataforma de Observación de Aves"),
    tiles = {
        "wetland_city_platform_top.png",
        "wetland_city_platform_top.png", 
        "wetland_city_platform_side.png"
    },
    groups = {choppy = 2, oddly_breakable_by_hand = 2, wood = 1},
    sounds = default and default.node_sound_wood_defaults() or {},
    on_rightclick = function(pos, node, clicker)
        if clicker and clicker:is_player() then
            minetest.chat_send_player(clicker:get_player_name(),
                "🦅 Observas las aves del humedal. Ves patos, cisnes y garzas viviendo en armonía.")
        end
    end,
})

-- Nodo: Cartel educativo sobre humedales  
minetest.register_node("wetland_city:info_sign", {
    description = S("Cartel Educativo Humedales"),
    tiles = {"wetland_city_sign.png"},
    drawtype = "nodebox",
    paramtype = "light",
    paramtype2 = "facedir",
    node_box = {
        type = "fixed",
        fixed = {
            {-0.5, -0.5, 0.4, 0.5, 0.5, 0.5}
        }
    },
    groups = {choppy = 2, oddly_breakable_by_hand = 2, wood = 1},
    sounds = default and default.node_sound_wood_defaults() or {},
    on_rightclick = function(pos, node, clicker)
        if clicker and clicker:is_player() then
            minetest.show_formspec(clicker:get_player_name(), "wetland_city:info",
                "size[10,8]" ..
                "label[0,0;🌿 HUMEDALES - INFORMACIÓN EDUCATIVA]" ..
                "textarea[0.5,1;9,3;;Los humedales son ecosistemas vitales que:" ..
                "\\n• Filtran el agua naturalmente" ..
                "\\n• Proporcionan hogar a cientos de especies de aves" ..
                "\\n• Almacenan carbono y combaten el cambio climático" ..
                "\\n• Son el hogar de plantas acuáticas únicas;" .. "]" ..
                "textarea[0.5,4;9,3;;En Wetlands protegemos estos espacios:" ..
                "\\n• Observamos y aprendemos sobre la fauna silvestre" ..
                "\\n• Plantamos especies nativas para restaurar el ecosistema" ..
                "\\n• Construimos senderos elevados para no disturbar la fauna" ..
                "\\n• Educamos sobre la importancia de la conservación;" .. "]" ..
                "button_exit[4,7;2,1;close;Cerrar]"
            )
        end
    end,
})

-- Función para generar la ciudad humedal en el spawn
function wetland_city.generate_spawn_city()
    local spawn_pos = {x = 0, y = 5, z = 0}
    
    -- Limpiar área para la ciudad
    local area_size = 50
    for x = -area_size, area_size do
        for z = -area_size, area_size do
            for y = 0, 30 do
                local pos = {x = spawn_pos.x + x, y = spawn_pos.y + y, z = spawn_pos.z + z}
                if y < 5 then
                    -- Crear base de tierra
                    minetest.set_node(pos, {name = dirt})
                elseif y == 5 then
                    -- Superficie con pasto
                    minetest.set_node(pos, {name = grass})
                else
                    -- Limpiar aire
                    minetest.set_node(pos, {name = "air"})
                end
            end
        end
    end
    
    -- Crear ríos principales (estilo Valdivia)
    wetland_city.create_river_system(spawn_pos)
    
    -- Generar humedales
    wetland_city.create_wetlands(spawn_pos)
    
    -- Construir infraestructura eco-amigable
    wetland_city.create_eco_infrastructure(spawn_pos)
    
    -- Añadir flora y fauna
    wetland_city.populate_wetlands(spawn_pos)
    
    minetest.log("action", "[Wetland City] Ciudad humedal generada en spawn")
end

-- Crear sistema de ríos entrelazados
function wetland_city.create_river_system(center_pos)
    -- Río principal (norte-sur)
    for z = -40, 40 do
        for x = -2, 2 do
            for y = 3, 5 do
                local pos = {
                    x = center_pos.x + x, 
                    y = center_pos.y + y, 
                    z = center_pos.z + z
                }
                if y == 5 then
                    minetest.set_node(pos, {name = water_source})
                else
                    minetest.set_node(pos, {name = dirt})
                end
            end
        end
    end
    
    -- Río secundario (este-oeste)  
    for x = -40, 40 do
        for z = -2, 2 do
            for y = 3, 5 do
                local pos = {
                    x = center_pos.x + x,
                    y = center_pos.y + y, 
                    z = center_pos.z + z
                }
                if y == 5 then
                    minetest.set_node(pos, {name = water_source})
                else
                    minetest.set_node(pos, {name = dirt})
                end
            end
        end
    end
    
    -- Afluentes menores
    local tributaries = {
        {start_x = -20, start_z = -20, end_x = -2, end_z = -2},
        {start_x = 20, start_z = 20, end_x = 2, end_z = 2},
        {start_x = -20, start_z = 20, end_x = -2, end_z = 2},
        {start_x = 20, start_z = -20, end_x = 2, end_z = -2}
    }
    
    for _, tributary in ipairs(tributaries) do
        local steps = math.max(math.abs(tributary.end_x - tributary.start_x), 
                               math.abs(tributary.end_z - tributary.start_z))
        for i = 0, steps do
            local progress = i / steps
            local x = math.floor(tributary.start_x + (tributary.end_x - tributary.start_x) * progress)
            local z = math.floor(tributary.start_z + (tributary.end_z - tributary.start_z) * progress)
            local pos = {x = center_pos.x + x, y = center_pos.y + 5, z = center_pos.z + z}
            minetest.set_node(pos, {name = water_source})
        end
    end
end

-- Crear áreas de humedal
function wetland_city.create_wetlands(center_pos)
    local wetland_areas = {
        {x = -30, z = -30, size = 15},
        {x = 30, z = 30, size = 15},
        {x = -30, z = 30, size = 12},
        {x = 30, z = -30, size = 12}
    }
    
    for _, wetland in ipairs(wetland_areas) do
        for x = wetland.x - wetland.size, wetland.x + wetland.size do
            for z = wetland.z - wetland.size, wetland.z + wetland.size do
                local distance = math.sqrt((x - wetland.x)^2 + (z - wetland.z)^2)
                if distance <= wetland.size then
                    local pos = {
                        x = center_pos.x + x,
                        y = center_pos.y + 5,
                        z = center_pos.z + z
                    }
                    
                    -- Crear charcos y zonas húmedas
                    if distance <= wetland.size * 0.6 then
                        minetest.set_node(pos, {name = water_source})
                    elseif distance <= wetland.size * 0.8 then
                        -- Tierra húmeda
                        pos.y = pos.y - 1
                        minetest.set_node(pos, {name = dirt})
                        pos.y = pos.y + 1
                        minetest.set_node(pos, {name = grass})
                    end
                end
            end
        end
    end
end

-- Crear infraestructura ecológica
function wetland_city.create_eco_infrastructure(center_pos)
    -- Senderos de madera sobre los humedales
    local boardwalk_paths = {
        {start_x = -35, start_z = 0, end_x = -15, end_z = 0},
        {start_x = 15, start_z = 0, end_x = 35, end_z = 0},
        {start_x = 0, start_z = -35, end_x = 0, end_z = -15},
        {start_x = 0, start_z = 15, end_x = 0, end_z = 35}
    }
    
    for _, path in ipairs(boardwalk_paths) do
        local steps = math.max(math.abs(path.end_x - path.start_x), 
                               math.abs(path.end_z - path.start_z))
        for i = 0, steps do
            local progress = i / steps
            local x = math.floor(path.start_x + (path.end_x - path.start_x) * progress)
            local z = math.floor(path.start_z + (path.end_z - path.start_z) * progress)
            local pos = {x = center_pos.x + x, y = center_pos.y + 6, z = center_pos.z + z}
            minetest.set_node(pos, {name = "wetland_city:boardwalk"})
        end
    end
    
    -- Plataformas de observación
    local observation_points = {
        {x = -25, z = -25}, {x = 25, z = 25}, 
        {x = -25, z = 25}, {x = 25, z = -25}
    }
    
    for _, point in ipairs(observation_points) do
        local base_pos = {x = center_pos.x + point.x, y = center_pos.y + 6, z = center_pos.z + point.z}
        
        -- Crear plataforma 3x3
        for x = -1, 1 do
            for z = -1, 1 do
                local pos = {x = base_pos.x + x, y = base_pos.y, z = base_pos.z + z}
                minetest.set_node(pos, {name = "wetland_city:bird_platform"})
            end
        end
        
        -- Cartel educativo
        local sign_pos = {x = base_pos.x, y = base_pos.y + 1, z = base_pos.z + 2}
        minetest.set_node(sign_pos, {name = "wetland_city:info_sign"})
    end
    
    -- Puentes sobre los ríos principales
    local bridges = {
        {x = 0, z = 15, length = 5, direction = "x"},
        {x = 0, z = -15, length = 5, direction = "x"},
        {x = 15, z = 0, length = 5, direction = "z"},
        {x = -15, z = 0, length = 5, direction = "z"}
    }
    
    for _, bridge in ipairs(bridges) do
        for i = -bridge.length, bridge.length do
            local pos
            if bridge.direction == "x" then
                pos = {x = center_pos.x + i, y = center_pos.y + 7, z = center_pos.z + bridge.z}
            else
                pos = {x = center_pos.x + bridge.x, y = center_pos.y + 7, z = center_pos.z + i}
            end
            minetest.set_node(pos, {name = wood})
        end
    end
end

-- Poblar con flora y fauna (elementos decorativos)
function wetland_city.populate_wetlands(center_pos)
    local flora_positions = {}
    
    -- Generar posiciones aleatorias para flora
    for i = 1, 100 do
        local x = math.random(-45, 45)
        local z = math.random(-45, 45)
        local pos = {x = center_pos.x + x, y = center_pos.y + 6, z = center_pos.z + z}
        
        -- Verificar que no esté en agua
        local below = {x = pos.x, y = pos.y - 1, z = pos.z}
        local below_node = minetest.get_node(below)
        
        if below_node.name == grass or below_node.name == dirt then
            -- Plantar vegetación de humedal
            if math.random() < 0.3 then
                minetest.set_node(pos, {name = papyrus})
            elseif math.random() < 0.5 then
                minetest.set_node(pos, {name = tree})
                local above = {x = pos.x, y = pos.y + 1, z = pos.z}
                minetest.set_node(above, {name = leaves})
            end
        end
    end
    
    minetest.log("action", "[Wetland City] Flora poblada en humedales")
end

-- Chat command para regenerar la ciudad
minetest.register_chatcommand("generar_ciudad_humedal", {
    description = S("Genera la ciudad humedal en el spawn"),
    privs = {server = true},
    func = function(name, param)
        wetland_city.generate_spawn_city()
        return true, "🌿 Ciudad humedal generada exitosamente en el spawn"
    end,
})

-- Chat command para información sobre humedales
minetest.register_chatcommand("humedales", {
    description = S("Información sobre los humedales"),
    func = function(name, param)
        return true, "🦆 En los humedales observamos y protegemos la vida silvestre. " ..
                     "Usa /tp_humedal para visitar las plataformas de observación."
    end,
})

-- Comando para teletransportarse a los humedales
minetest.register_chatcommand("tp_humedal", {
    description = S("Teletransporte a plataforma de observación"),
    func = function(name, param)
        local player = minetest.get_player_by_name(name)
        if not player then return false, "Jugador no encontrado" end
        
        local platforms = {
            {x = -25, y = 12, z = -25},
            {x = 25, y = 12, z = 25},
            {x = -25, y = 12, z = 25},
            {x = 25, y = 12, z = -25}
        }
        
        local random_platform = platforms[math.random(#platforms)]
        player:set_pos(random_platform)
        
        return true, "🦅 ¡Teletransportado a plataforma de observación de aves!"
    end,
})

-- Generar la ciudad automáticamente al iniciar el servidor
minetest.register_on_mods_loaded(function()
    minetest.after(5, function()
        minetest.log("action", "[Wetland City] Iniciando generación de ciudad humedal...")
        wetland_city.generate_spawn_city()
    end)
end)

minetest.log("action", "[Wetland City] Mod cargado exitosamente")