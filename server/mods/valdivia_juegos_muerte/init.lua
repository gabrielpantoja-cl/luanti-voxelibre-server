-- valdivia_juegos_muerte
-- Mini-juego "Juegos de la Muerte": laberinto con zombies y premio final.
-- Refactor SRE: VoxelManip batch, entity cleanup seguro, anti-grief bedrock.
-- Comando admin: /juegos_muerte colocar | limpiar | estado | premio

local modname = minetest.get_current_modname()

-- ============================================================================
-- 1. CONFIGURACIÓN (constantes UPPER_SNAKE_CASE)
-- ============================================================================
local MAZE_SIZE       = 21        -- Impar: 21x21 celdas
local CELL_SIZE       = 3         -- Nodos por celda (pasillo 3x3)
local WALL_HEIGHT     = 4         -- Altura paredes
local WALL_NODE       = "mcl_core:stonebrick"
local FLOOR_NODE      = "mcl_core:stonebrick"
local CEILING_NODE    = "mcl_core:stonebrick"
local BEDROCK_NODE    = "mcl_core:bedrock"      -- Capa anti-grief suelo/techo
local ENTRANCE_NODE   = "mcl_core:ironbars"
local EXIT_NODE       = "mcl_core:goldblock"
local PRIZE_CHEST     = "mcl_chests:chest"
local ZOMBIE_ENTITY   = "mcl_mobs:zombie"       -- VoxeLibre 0.90.1: entidad zombie nativa
local ZOMBIE_COUNT    = 8
local PRIZE_ITEMS = {
    {name = "mcl_core:diamond", count = 3},
    {name = "mcl_core:gold_ingot", count = 10},
    {name = "mcl_core:iron_ingot", count = 20},
    {name = "mcl_enchanting:book_enchanted", count = 1},
    {name = "mcl_core:apple", count = 16},
}

-- Colores chat
local C_TITLE = "#FFD700"
local C_OK    = "#7CFC00"
local C_INFO  = "#00BFFF"
local C_WARN  = "#FF8C00"
local C_ERR   = "#FF4444"

-- Estado global (persiste entre reinicios del mod, no entre reinicios del servidor)
valdivia_juegos_muerte = {
    maze_pos     = nil,   -- Pos base (esquina inferior SW)
    maze_data    = nil,   -- Grid del laberinto
    zombie_ids   = {},    -- IDs de entidades spawneadas (para cleanup)
    active       = false, -- Juego activo
    prize_pos    = nil,   -- Pos cofre premio
    maze_bounds  = nil,   -- {min, max} para cleanup por radio
}

-- ============================================================================
-- 2. UTILIDADES
-- ============================================================================
local function say(player_name, color, msg)
    minetest.chat_send_player(player_name, minetest.colorize(color, "[Juegos de la Muerte] ") .. msg)
end

local function broadcast(color, msg)
    minetest.chat_send_all(minetest.colorize(color, "[Juegos de la Muerte] ") .. msg)
end

local function has_server_priv(name)
    local player = minetest.get_player_by_name(name)
    return player and minetest.check_player_privs(player, {server = true})
end

-- ============================================================================
-- 3. GENERACIÓN DE LABERINTO (Recursive Backtracker)
-- ============================================================================
local function generate_maze(w, h)
    local grid = {}
    for y = 1, h do
        grid[y] = {}
        for x = 1, w do
            grid[y][x] = 1  -- 1 = pared, 0 = pasillo
        end
    end

    local function carve(x, y)
        grid[y][x] = 0
        local dirs = {{2,0},{-2,0},{0,2},{0,-2}}
        -- Fisher-Yates shuffle
        for i = #dirs, 2, -1 do
            local j = math.random(i)
            dirs[i], dirs[j] = dirs[j], dirs[i]
        end
        for _, d in ipairs(dirs) do
            local nx, ny = x + d[1], y + d[2]
            if nx > 0 and nx <= w and ny > 0 and ny <= h and grid[ny][nx] == 1 then
                grid[y + d[2]/2][x + d[1]/2] = 0
                carve(nx, ny)
            end
        end
    end

    carve(1, 1)
    grid[1][1] = 0
    grid[h][w] = 0
    return grid
end

-- ============================================================================
-- 4. CONSTRUCCIÓN CON VOXELMANIP (BATCH - SIN LAG)
-- ============================================================================
local function build_maze_vmanip(maze_grid, base_pos)
    local h = #maze_grid
    local w = #maze_grid[1]

    -- Calcular bounding box total
    local min_x = base_pos.x - 2
    local min_y = base_pos.y - 2
    local min_z = base_pos.z - 2
    local max_x = base_pos.x + w * CELL_SIZE + 3
    local max_y = base_pos.y + WALL_HEIGHT + 3  -- +2 bedrock + margen
    local max_z = base_pos.z + h * CELL_SIZE + 3

    local vm = minetest.get_voxel_manip()
    local emin, emax = vm:read_from_map(
        {x = min_x, y = min_y, z = min_z},
        {x = max_x, y = max_y, z = max_z}
    )
    local area = VoxelArea:new({MinEdge = emin, MaxEdge = emax})
    local data = vm:get_data()

    -- Content IDs (cache para performance)
    local cid_air       = minetest.get_content_id("air")
    local cid_wall      = minetest.get_content_id(WALL_NODE)
    local cid_floor     = minetest.get_content_id(FLOOR_NODE)
    local cid_ceiling   = minetest.get_content_id(CEILING_NODE)
    local cid_bedrock   = minetest.get_content_id(BEDROCK_NODE)
    local cid_entrance  = minetest.get_content_id(ENTRANCE_NODE)
    local cid_gold      = minetest.get_content_id(EXIT_NODE)
    local cid_goldblk   = minetest.get_content_id("mcl_core:goldblock")
    local cid_chest     = minetest.get_content_id(PRIZE_CHEST)
    local cid_sign      = minetest.get_content_id("mcl_signs:sign_wall_oak")

    local function set_node_vm(x, y, z, cid)
        data[area:index(x, y, z)] = cid
    end

    -- --- 1. Capa de BEDROCK inferior (anti-grief suelo) ---
    for gz = 0, h * CELL_SIZE + 1 do
        for gx = 0, w * CELL_SIZE + 1 do
            local wx = base_pos.x + gx - 1
            local wz = base_pos.z + gz - 1
            set_node_vm(wx, base_pos.y - 1, wz, cid_bedrock)
            set_node_vm(wx, base_pos.y - 2, wz, cid_bedrock)  -- Doble capa
        end
    end

    -- --- 2. Generar celdas ---
    for gy = 1, h do
        for gx = 1, w do
            local cell = maze_grid[gy][gx]
            local wx = base_pos.x + (gx - 1) * CELL_SIZE
            local wz = base_pos.z + (gy - 1) * CELL_SIZE
            local cell_center_x = wx + math.floor(CELL_SIZE / 2)
            local cell_center_z = wz + math.floor(CELL_SIZE / 2)

            if cell == 1 then
                -- PARED: columnas en las 4 esquinas de la celda + relleno
                for dy = 0, WALL_HEIGHT - 1 do
                    local y = base_pos.y + dy
                    -- 4 esquinas
                    set_node_vm(wx, y, wz, cid_wall)
                    set_node_vm(wx + CELL_SIZE - 1, y, wz, cid_wall)
                    set_node_vm(wx, y, wz + CELL_SIZE - 1, cid_wall)
                    set_node_vm(wx + CELL_SIZE - 1, y, wz + CELL_SIZE - 1, cid_wall)
                    -- Rellenar bordes entre esquinas (pared sólida)
                    for dx = 1, CELL_SIZE - 2 do
                        set_node_vm(wx + dx, y, wz, cid_wall)
                        set_node_vm(wx + dx, y, wz + CELL_SIZE - 1, cid_wall)
                    end
                    for dz = 1, CELL_SIZE - 2 do
                        set_node_vm(wx, y, wz + dz, cid_wall)
                        set_node_vm(wx + CELL_SIZE - 1, y, wz + dz, cid_wall)
                    end
                end
            else
                -- PASILLO: suelo, techo, y bedrock arriba/abajo
                for dx = 0, CELL_SIZE - 1 do
                    for dz = 0, CELL_SIZE - 1 do
                        local nx = wx + dx
                        local nz = wz + dz
                        -- Suelo
                        set_node_vm(nx, base_pos.y, nz, cid_floor)
                        -- Techo
                        set_node_vm(nx, base_pos.y + WALL_HEIGHT, nz, cid_ceiling)
                        -- Bedrock encima del techo (anti-grief hacia arriba)
                        set_node_vm(nx, base_pos.y + WALL_HEIGHT + 1, nz, cid_bedrock)
                        set_node_vm(nx, base_pos.y + WALL_HEIGHT + 2, nz, cid_bedrock)
                    end
                end
            end
        end
    end

    -- --- 3. Entrada decorativa (celda 1,1) ---
    local ex = base_pos.x
    local ez = base_pos.z
    for dy = 1, WALL_HEIGHT do
        set_node_vm(ex + 1, base_pos.y + dy, ez - 1, cid_entrance)
        set_node_vm(ex + 1, base_pos.y + dy, ez + CELL_SIZE, cid_entrance)
    end
    -- Cartel en la entrada
    local sign_x = ex + 1
    local sign_y = base_pos.y + WALL_HEIGHT + 1
    local sign_z = ez + math.floor(CELL_SIZE / 2)
    set_node_vm(sign_x, sign_y, sign_z, cid_sign)

    -- --- 4. Salida / Premio (celda w,h - esquina opuesta) ---
    local cx = base_pos.x + (w - 1) * CELL_SIZE
    local cz = base_pos.z + (h - 1) * CELL_SIZE
    local prize_x = cx + math.floor(CELL_SIZE / 2)
    local prize_y = base_pos.y + 1
    local prize_z = cz + math.floor(CELL_SIZE / 2)

    -- Área de oro alrededor del cofre (3x3 en el suelo)
    for dx = -1, 1 do
        for dz = -1, 1 do
            local gx = prize_x + dx
            local gz = prize_z + dz
            local gy = base_pos.y
            if dx == 0 and dz == 0 then
                set_node_vm(gx, gy, gz, cid_chest)
            else
                set_node_vm(gx, gy, gz, cid_goldblk)
            end
            -- Bedrock debajo del oro
            set_node_vm(gx, gy - 1, gz, cid_bedrock)
            set_node_vm(gx, gy - 2, gz, cid_bedrock)
        end
    end

    -- Guardar bounds para cleanup por radio
    valdivia_juegos_muerte.maze_bounds = {
        min = {x = min_x, y = min_y, z = min_z},
        max = {x = max_x, y = max_y, z = max_z},
        center = {
            x = base_pos.x + (w * CELL_SIZE) / 2,
            y = base_pos.y + WALL_HEIGHT / 2,
            z = base_pos.z + (h * CELL_SIZE) / 2
        },
        radius = math.max(w, h) * CELL_SIZE / 2 + 10
    }

    -- Escribir todo de golpe
    vm:set_data(data)
    vm:write_to_map()
    vm:update_map()

    -- Guardar posición del cofre para meta posterior
    valdivia_juegos_muerte.prize_pos = {x = prize_x, y = prize_y, z = prize_z}

    return prize_x, prize_y, prize_z
end

-- ============================================================================
-- 5. POST-PROCESADO: Meta del cofre + Zombies (async, fuera de VoxelManip)
-- ============================================================================
local function setup_chest_and_zombies(maze_grid, base_pos, prize_x, prize_y, prize_z)
    -- Meta del cofre (requiere get_meta, no funciona en VoxelManip)
    local chest_pos = {x = prize_x, y = prize_y, z = prize_z}
    local meta = minetest.get_meta(chest_pos)
    meta:set_string("infotext", "Cofre del Premio - ¡Felicidades por llegar al final!")
    meta:set_string("formspec", "size[8,9]list[context;main;0,0;8,4;]list[current_player;main;0,5;8,4;]")
    local inv = meta:get_inventory()
    inv:set_size("main", 8 * 4)

    -- Llenar cofre con premios (slots aleatorios)
    local slots = {}
    for i = 1, 32 do slots[i] = i end
    for i = #slots, 2, -1 do
        local j = math.random(i)
        slots[i], slots[j] = slots[j], slots[i]
    end
    local item_idx = 1
    for _, prize in ipairs(PRIZE_ITEMS) do
        if prize.count > 0 and item_idx <= #slots then
            inv:set_stack("main", slots[item_idx], ItemStack(prize.name .. " " .. prize.count))
            item_idx = item_idx + 1
        end
    end

    -- Texto del cartel de entrada
    local sign_pos = {
        x = base_pos.x + 1,
        y = base_pos.y + WALL_HEIGHT + 1,
        z = base_pos.z + math.floor(CELL_SIZE / 2)
    }
    local sign_meta = minetest.get_meta(sign_pos)
    sign_meta:set_string("text", "¡Bienvenido a los\nJuegos de la Muerte!\nLlega al centro y\ngaía tu premio.\n\n¡Valor y honor!")

    -- --- Spawn zombies (async, escalonado para no bloquear) ---
    local valid_cells = {}
    local h = #maze_grid
    local w = #maze_grid[1]
    for gy = 2, h - 1 do
        for gx = 2, w - 1 do
            if maze_grid[gy][gx] == 0 then
                table.insert(valid_cells, {gx = gx, gy = gy})
            end
        end
    end

    for i = #valid_cells, 2, -1 do
        local j = math.random(i)
        valid_cells[i], valid_cells[j] = valid_cells[j], valid_cells[i]
    end

    local spawned = 0
    local max_spawn = math.min(ZOMBIE_COUNT, #valid_cells)

    local function spawn_next(idx)
        if idx > max_spawn then
            broadcast(C_WARN, "Cuidado: " .. spawned .. " zombies rondan los pasillos...")
            return
        end

        local cell = valid_cells[idx]
        local spawn_pos = {
            x = base_pos.x + (cell.gx - 1) * CELL_SIZE + math.floor(CELL_SIZE / 2),
            y = base_pos.y + 1,
            z = base_pos.z + (cell.gy - 1) * CELL_SIZE + math.floor(CELL_SIZE / 2)
        }

        -- Verificar aire (el VoxelManip ya puso suelo/techo, pero la entidad necesita espacio)
        local node = minetest.get_node(spawn_pos)
        if node.name == "air" then
            local ent = minetest.add_entity(spawn_pos, ZOMBIE_ENTITY)
            if ent then
                local eid = ent:get_id()
                valdivia_juegos_muerte.zombie_ids[eid] = true
                spawned = spawned + 1

                -- Buffear zombie para el reto
                local luaent = ent:get_luaentity()
                if luaent then
                    luaent.hp_min = 30
                    luaent.hp_max = 40
                    ent:set_hp(40)
                    -- Hacerlos más rápidos/agresivos
                    luaent.walk_velocity = 2.5
                    luaent.run_velocity = 3.5
                    luaent.view_range = 24
                    luaent.damage = 4
                end
            end
        end

        -- Siguiente en next tick
        minetest.after(0.05, function() spawn_next(idx + 1) end)
    end

    spawn_next(1)
end

-- ============================================================================
-- 6. LIMPIEZA SEGURA (VoxelManip + get_objects_inside_radius)
-- ============================================================================
local function clear_maze()
    if not valdivia_juegos_muerte.active then return end

    local bounds = valdivia_juegos_muerte.maze_bounds
    if not bounds then
        minetest.log("warning", "[valdivia_juegos_muerte] No hay bounds para limpiar")
        return
    end

    -- 1. Eliminar ENTIDADES (zombies) por radio - API CORRECTA
    local objs = minetest.get_objects_inside_radius(bounds.center, bounds.radius)
    local removed_entities = 0
    for _, obj in ipairs(objs) do
        if obj and not obj:is_player() then
            local luaent = obj:get_luaentity()
            -- Solo borrar nuestras entidades (zombies) o entidades sin nombre en la zona
            if luaent and (luaent.name == ZOMBIE_ENTITY or valdivia_juegos_muerte.zombie_ids[obj:get_id()]) then
                obj:remove()
                removed_entities = removed_entities + 1
            end
        end
    end
    valdivia_juegos_muerte.zombie_ids = {}

    -- 2. Limpiar NODOS con VoxelManip (restaurar a aire)
    local vm = minetest.get_voxel_manip()
    local emin, emax = vm:read_from_map(bounds.min, bounds.max)
    local area = VoxelArea:new({MinEdge = emin, MaxEdge = emax})
    local data = vm:get_data()
    local cid_air = minetest.get_content_id("air")

    for z = bounds.min.z, bounds.max.z do
        for y = bounds.min.y, bounds.max.y do
            for x = bounds.min.x, bounds.max.x do
                data[area:index(x, y, z)] = cid_air
            end
        end
    end

    vm:set_data(data)
    vm:write_to_map()
    vm:update_map()

    -- 3. Reset estado
    valdivia_juegos_muerte.maze_pos     = nil
    valdivia_juegos_muerte.maze_data    = nil
    valdivia_juegos_muerte.active       = false
    valdivia_juegos_muerte.prize_pos    = nil
    valdivia_juegos_muerte.maze_bounds  = nil

    minetest.log("action", "[valdivia_juegos_muerte] Laberinto limpiado: " .. removed_entities .. " entidades eliminadas")
end

-- ============================================================================
-- 7. COMANDO ADMIN: /juegos_muerte
-- ============================================================================
minetest.register_chatcommand("juegos_muerte", {
    description = "Administra el mini-juego Juegos de la Muerte (laberinto con zombies)",
    params = "<colocar|limpiar|estado|premio>",
    privs = {server = true},
    func = function(name, param)
        if not has_server_priv(name) then
            return false, "Privilegios insuficientes (requiere 'server')"
        end

        local subcmd = (param:match("^(%S+)") or ""):lower()

        if subcmd == "colocar" or subcmd == "crear" then
            if valdivia_juegos_muerte.active then
                return false, "Ya hay un laberinto activo. Usa '/juegos_muerte limpiar' primero."
            end

            local player = minetest.get_player_by_name(name)
            if not player then return false, "Jugador no encontrado" end

            local pos = vector.round(player:get_pos())
            valdivia_juegos_muerte.maze_pos = pos

            say(name, C_INFO, "Generando laberinto " .. MAZE_SIZE .. "x" .. MAZE_SIZE .. "...")

            -- Generar grid en memoria (rápido)
            local maze_grid = generate_maze(MAZE_SIZE, MAZE_SIZE)
            valdivia_juegos_muerte.maze_data = maze_grid
            valdivia_juegos_muerte.active = true

            -- Construir TODO con VoxelManip (una sola operación)
            say(name, C_INFO, "Construyendo estructura (VoxelManip batch)...")
            local prize_x, prize_y, prize_z = build_maze_vmanip(maze_grid, pos)

            -- Post-proceso: cofre meta + zombies (async)
            say(name, C_INFO, "Colocando premio y spawneando zombies...")
            setup_chest_and_zombies(maze_grid, pos, prize_x, prize_y, prize_z)

            broadcast(C_TITLE, "¡Los Juegos de la Muerte han comenzado!")
            broadcast(C_INFO, "Un laberinto ha aparecido en (" .. pos.x .. ", " .. pos.y .. ", " .. pos.z .. ").")
            broadcast(C_INFO, "¡Encuentra el cofre de oro en el centro para reclamar tu premio!")
            say(name, C_OK, "Laberinto creado. El cofre y zombies se terminan de colocar en segundos.")

            return true, "Generando laberinto completo con VoxelManip..."

        elseif subcmd == "limpiar" or subcmd == "borrar" then
            if not valdivia_juegos_muerte.active then
                return false, "No hay laberinto activo para limpiar."
            end
            say(name, C_WARN, "Limpiando laberinto (VoxelManip + entity cleanup)...")
            clear_maze()
            broadcast(C_INFO, "El laberinto de los Juegos de la Muerte ha sido desmantelado.")
            return true, "Laberinto eliminado limpiamente."

        elseif subcmd == "estado" then
            if valdivia_juegos_muerte.active then
                local p = valdivia_juegos_muerte.maze_pos
                local zcount = 0
                for _ in pairs(valdivia_juegos_muerte.zombie_ids) do zcount = zcount + 1 end
                return true, "ACTIVO - Pos: (" .. p.x .. "," .. p.y .. "," .. p.z ..
                    ") Zombies registrados: " .. zcount .. "/" .. ZOMBIE_COUNT
            else
                return true, "INACTIVO - No hay laberinto colocado."
            end

        elseif subcmd == "premio" then
            if not valdivia_juegos_muerte.active or not valdivia_juegos_muerte.prize_pos then
                return false, "No hay laberinto activo con premio."
            end
            local p = valdivia_juegos_muerte.prize_pos
            return true, "Premio en: (" .. p.x .. ", " .. p.y .. ", " .. p.z .. ")"

        else
            return false, "Uso: /juegos_muerte <colocar|limpiar|estado|premio>"
        end
    end
})

-- ============================================================================
-- 8. DETECTAR VICTORIA (apertura del cofre del premio)
-- ============================================================================
minetest.register_on_player_receive_fields(function(player, formname, fields)
    if not formname or not formname:match("^mcl_chests:chest") then return end
    if not valdivia_juegos_muerte.active or not valdivia_juegos_muerte.prize_pos then return end

    local pname = player:get_player_name()
    local ppos = player:get_pos()
    local prize = valdivia_juegos_muerte.prize_pos

    if vector.distance(ppos, prize) < 6 then
        broadcast(C_TITLE, "¡" .. pname .. " ha encontrado el tesoro y ganado los Juegos de la Muerte!")
        broadcast(C_OK, "¡Felicidades por tu valor, perseverancia y honor!")

        -- Auto-limpiar tras 60s (dar tiempo a recoger items)
        minetest.after(60, function()
            if valdivia_juegos_muerte.active then
                broadcast(C_INFO, "Los Juegos de la Muerte han concluido. El laberinto se desmantela.")
                clear_maze()
            end
        end)
    end
end)

-- ============================================================================
-- 9. ALIASES Y LOG
-- ============================================================================
minetest.register_alias("valdivia_juegos_muerte:maze_wall", WALL_NODE)
minetest.register_alias("valdivia_juegos_muerte:maze_floor", FLOOR_NODE)

minetest.log("action", "[" .. modname .. "] Loaded successfully - Mini-juego SRE-hardened listo para Valdivia")