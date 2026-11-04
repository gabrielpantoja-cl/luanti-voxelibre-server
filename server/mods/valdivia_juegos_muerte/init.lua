-- valdivia_juegos_muerte
-- Mini-juego "Juegos de la Muerte": laberinto con zombies y premio final.
--
-- v2.0 - Reescrito tras dos crashes en produccion (2026-11-04):
--   * Todos los nombres de nodo/entidad verificados contra VoxeLibre 0.90.1.
--   * Ningun get_content_id() sobre un nombre sin registrar: eso abortaba el
--     callback de chat y tumbaba el servidor (ServerError: AsyncErr).
--   * El area original se respalda antes de construir y se RESTAURA al limpiar
--     (antes se rellenaba con aire: un crater permanente en la ciudad OSM).
--   * El cofre se coloca con set_node despues del VoxelManip, para que corra
--     on_construct de mcl_chests; via VoxelManip queda inservible.
--
-- Comando admin: /juegos_muerte colocar | limpiar | estado | premio

local modname = minetest.get_current_modname()

-- ============================================================================
-- 1. CONFIGURACION
-- ============================================================================
local MAZE_SIZE    = 21   -- Impar: celdas del grid (21 -> 11x11 salas)
local CELL_SIZE    = 3    -- Nodos por celda (pasillos de 3 de ancho)
local WALL_HEIGHT  = 4    -- Techo en base_y + WALL_HEIGHT
local ZOMBIE_COUNT = 8
local CONFIRM_TTL  = 30   -- Segundos para confirmar /juegos_muerte colocar

-- Nombres REALES en VoxeLibre 0.90.1 (verificados en server/games/mineclone2).
-- El segundo valor es el fallback si el nodo no existe en esta instalacion.
local NODE_SPEC = {
    wall     = {"mcl_core:stonebrick", "mcl_core:stone"},
    floor    = {"mcl_core:stonebrick", "mcl_core:stone"},
    ceiling  = {"mcl_core:stonebrick", "mcl_core:stone"},
    bedrock  = {"mcl_core:bedrock",    "mcl_core:stone"},
    entrance = {"xpanes:bar_flat",     "mcl_core:goldblock"},  -- NO mcl_core:ironbars
    gold     = {"mcl_core:goldblock",  "mcl_core:stone"},
    chest    = {"mcl_chests:chest",    "mcl_chests:chest"},
}

local ZOMBIE_ENTITY = "mobs_mc:zombie"   -- NO mcl_mobs:zombie

local PRIZE_ITEMS = {
    "mcl_core:diamond 3",
    "mcl_core:gold_ingot 10",
    "mcl_core:iron_ingot 20",
    "mcl_enchanting:book_enchanted 1",
    "mcl_core:apple 16",
}

-- Buffs de los zombies (defaults VoxeLibre: hp 20, walk .8, run 1.8, dmg 3)
local ZOMBIE_BUFF = {
    hp            = 30,
    walk_velocity = 1.2,
    run_velocity  = 2.4,
    view_range    = 24,
    damage        = 4,
}

local C_TITLE = "#FFD700"
local C_OK    = "#7CFC00"
local C_INFO  = "#00BFFF"
local C_WARN  = "#FF8C00"

local STATE_FILE = minetest.get_worldpath() .. "/valdivia_juegos_muerte_state.json"

-- ============================================================================
-- 2. ESTADO
-- ============================================================================
valdivia_juegos_muerte = {
    active      = false,
    base_pos    = nil,
    maze_bounds = nil,   -- {min, max, center, radius}
    prize_pos   = nil,
    backup      = nil,   -- RLE del area original: { {name, param2, count}, ... }
    zombies     = {},    -- ObjectRefs (no usamos get_id: no es API estable)
}
local JM = valdivia_juegos_muerte
local pending_confirm = {}   -- [player_name] = os.time()

-- ============================================================================
-- 3. UTILIDADES
-- ============================================================================
local function say(name, color, msg)
    minetest.chat_send_player(name, minetest.colorize(color, "[Juegos de la Muerte] ") .. msg)
end

local function broadcast(color, msg)
    minetest.chat_send_all(minetest.colorize(color, "[Juegos de la Muerte] ") .. msg)
end

local function log(level, msg)
    minetest.log(level, "[" .. modname .. "] " .. msg)
end

-- Nombres resueltos UNA sola vez, despues de que todos los mods cargaron.
local NODES = {}
local nodes_ready = false

local function resolve_nodes()
    local missing = {}
    for key, spec in pairs(NODE_SPEC) do
        local want, fallback = spec[1], spec[2]
        if minetest.registered_nodes[want] then
            NODES[key] = want
        elseif minetest.registered_nodes[fallback] then
            NODES[key] = fallback
            log("warning", "nodo '" .. want .. "' no existe; usando fallback '" .. fallback .. "'")
        else
            NODES[key] = "air"
            missing[#missing + 1] = want
        end
    end
    if #missing > 0 then
        nodes_ready = false
        log("error", "nodos sin registrar ni fallback valido: " .. table.concat(missing, ", ")
            .. " -- /juegos_muerte colocar queda deshabilitado")
    else
        nodes_ready = true
    end
    if not minetest.registered_entities[ZOMBIE_ENTITY] then
        log("warning", "entidad '" .. ZOMBIE_ENTITY
            .. "' no registrada; el laberinto se construira sin zombies")
    end
end

-- ============================================================================
-- 4. PERSISTENCIA (el laberinto sobrevive reinicios; el estado en RAM no)
-- ============================================================================
local function save_state()
    if not JM.active then
        os.remove(STATE_FILE)
        return
    end
    local ok = minetest.safe_file_write(STATE_FILE, minetest.write_json({
        base_pos    = JM.base_pos,
        maze_bounds = JM.maze_bounds,
        prize_pos   = JM.prize_pos,
        backup      = JM.backup,
    }))
    if not ok then
        log("error", "no se pudo escribir el estado en " .. STATE_FILE
            .. " -- tras un reinicio el terreno no se podra restaurar")
    end
end

local function load_state()
    local f = io.open(STATE_FILE, "r")
    if not f then return end
    local raw = f:read("*a")
    f:close()
    local st = raw and minetest.parse_json(raw)
    if not (st and st.maze_bounds and st.backup) then
        log("warning", "estado persistido ilegible; se ignora")
        return
    end
    JM.base_pos    = st.base_pos
    JM.maze_bounds = st.maze_bounds
    JM.prize_pos   = st.prize_pos
    JM.backup      = st.backup
    JM.active      = true
    log("action", "laberinto activo recuperado del disco; '/juegos_muerte limpiar' lo restaurara")
end

-- ============================================================================
-- 5. GENERACION DEL LABERINTO (recursive backtracker, iterativo)
-- ============================================================================
local function generate_maze(w, h)
    local grid = {}
    for y = 1, h do
        grid[y] = {}
        for x = 1, w do grid[y][x] = 1 end   -- 1 = pared, 0 = pasillo
    end

    local dirs = {{2, 0}, {-2, 0}, {0, 2}, {0, -2}}
    local stack = {{x = 1, y = 1}}
    grid[1][1] = 0

    while #stack > 0 do
        local cur = stack[#stack]
        local order = {1, 2, 3, 4}
        for i = 4, 2, -1 do
            local j = math.random(i)
            order[i], order[j] = order[j], order[i]
        end
        local advanced = false
        for _, oi in ipairs(order) do
            local d = dirs[oi]
            local nx, ny = cur.x + d[1], cur.y + d[2]
            if nx > 0 and nx <= w and ny > 0 and ny <= h and grid[ny][nx] == 1 then
                grid[cur.y + d[2] / 2][cur.x + d[1] / 2] = 0
                grid[ny][nx] = 0
                stack[#stack + 1] = {x = nx, y = ny}
                advanced = true
                break
            end
        end
        if not advanced then stack[#stack] = nil end
    end

    grid[1][1] = 0
    grid[h][w] = 0
    return grid
end

-- ============================================================================
-- 6. BACKUP / RESTORE DEL AREA (RLE sobre NOMBRES, no content IDs)
--    Los content IDs dependen del orden de carga de mods: guardarlos en disco
--    corrompe la restauracion tras un reinicio.
-- ============================================================================
local function rle_encode(data, p2, area, pmin, pmax)
    local name_of = minetest.get_name_from_content_id
    local cache, out = {}, {}
    local ln, lp, run = nil, nil, 0
    for z = pmin.z, pmax.z do
        for y = pmin.y, pmax.y do
            for x = pmin.x, pmax.x do
                local i = area:index(x, y, z)
                local c = data[i]
                local nm = cache[c]
                if not nm then nm = name_of(c); cache[c] = nm end
                local pp = p2[i] or 0
                if nm == ln and pp == lp then
                    run = run + 1
                else
                    if ln then out[#out + 1] = {ln, lp, run} end
                    ln, lp, run = nm, pp, 1
                end
            end
        end
    end
    if ln then out[#out + 1] = {ln, lp, run} end
    return out
end

local function rle_apply(rle, data, p2, area, pmin, pmax)
    local cid_air = minetest.get_content_id("air")
    local cid_cache = {}
    local function cid_of(nm)
        local c = cid_cache[nm]
        if c then return c end
        if nm == "air" or nm == "ignore" or minetest.registered_nodes[nm] then
            c = minetest.get_content_id(nm)
        else
            log("warning", "nodo '" .. tostring(nm) .. "' del backup ya no existe; se restaura aire")
            c = cid_air
        end
        cid_cache[nm] = c
        return c
    end

    local ri = 1
    local left = (rle[1] and rle[1][3]) or 0
    local truncated = false
    for z = pmin.z, pmax.z do
        for y = pmin.y, pmax.y do
            for x = pmin.x, pmax.x do
                while left == 0 and ri <= #rle do
                    ri = ri + 1
                    left = (rle[ri] and rle[ri][3]) or 0
                end
                local entry = rle[ri]
                if not entry then
                    truncated = true
                else
                    local i = area:index(x, y, z)
                    data[i] = cid_of(entry[1])
                    p2[i] = entry[2] or 0
                    left = left - 1
                end
            end
        end
    end
    if truncated then
        log("error", "el backup RLE es mas corto que el area: parte del terreno no se restauro")
    end
    return not truncated
end

-- ============================================================================
-- 7. CONSTRUCCION (un solo VoxelManip)
-- ============================================================================
local function build_maze(grid, base)
    local gh = #grid
    local gw = #grid[1]
    local W = gw * CELL_SIZE    -- ancho del footprint en nodos
    local H = gh * CELL_SIZE

    -- Footprint + anillo perimetral de 1 nodo
    local pmin = {x = base.x - 1, y = base.y - 2,               z = base.z - 1}
    local pmax = {x = base.x + W, y = base.y + WALL_HEIGHT + 2, z = base.z + H}

    if minetest.load_area then minetest.load_area(pmin, pmax) end

    local vm = minetest.get_voxel_manip()
    local emin, emax = vm:read_from_map(pmin, pmax)
    local area = VoxelArea:new({MinEdge = emin, MaxEdge = emax})
    local data = vm:get_data()
    local p2   = vm:get_param2_data()

    -- Backup ANTES de tocar nada
    local backup = rle_encode(data, p2, area, pmin, pmax)

    local cid = {}
    for key, nm in pairs(NODES) do cid[key] = minetest.get_content_id(nm) end
    cid.air = minetest.get_content_id("air")

    local function put(x, y, z, c, param2)
        if area:contains(x, y, z) then
            local i = area:index(x, y, z)
            data[i] = c
            p2[i] = param2 or 0
        end
    end

    -- --- 1. Caja base: bedrock / suelo / aire / techo / bedrock ---
    for gz = -1, H do
        for gx = -1, W do
            local x, z = base.x + gx, base.z + gz
            put(x, base.y - 2, z, cid.bedrock)
            put(x, base.y - 1, z, cid.bedrock)
            put(x, base.y,     z, cid.floor)
            for dy = 1, WALL_HEIGHT - 1 do
                put(x, base.y + dy, z, cid.air)
            end
            put(x, base.y + WALL_HEIGHT,     z, cid.ceiling)
            put(x, base.y + WALL_HEIGHT + 1, z, cid.bedrock)
            put(x, base.y + WALL_HEIGHT + 2, z, cid.bedrock)
        end
    end

    -- --- 2. Paredes internas: celda de pared = bloque 3x3 SOLIDO ---
    for gy = 1, gh do
        for gx = 1, gw do
            if grid[gy][gx] == 1 then
                local wx = base.x + (gx - 1) * CELL_SIZE
                local wz = base.z + (gy - 1) * CELL_SIZE
                for dx = 0, CELL_SIZE - 1 do
                    for dz = 0, CELL_SIZE - 1 do
                        for dy = 1, WALL_HEIGHT - 1 do
                            put(wx + dx, base.y + dy, wz + dz, cid.wall)
                        end
                    end
                end
            end
        end
    end

    -- --- 3. Anillo perimetral solido (el laberinto queda cerrado) ---
    for gz = -1, H do
        for gx = -1, W do
            if gx == -1 or gx == W or gz == -1 or gz == H then
                for dy = 1, WALL_HEIGHT - 1 do
                    put(base.x + gx, base.y + dy, base.z + gz, cid.wall)
                end
            end
        end
    end

    -- --- 4. Entrada: hueco 1x2 en la cara -Z de la celda (1,1), con barrotes ---
    local door_gx = math.floor(CELL_SIZE / 2)   -- 1
    put(base.x + door_gx, base.y + 1, base.z - 1, cid.air)
    put(base.x + door_gx, base.y + 2, base.z - 1, cid.air)
    for _, side in ipairs({door_gx - 1, door_gx + 1}) do
        for dy = 1, WALL_HEIGHT - 1 do
            put(base.x + side, base.y + dy, base.z - 1, cid.entrance)
        end
    end

    -- --- 5. Premio en la celda opuesta (gw, gh) ---
    local prize_x = base.x + (gw - 1) * CELL_SIZE + math.floor(CELL_SIZE / 2)
    local prize_z = base.z + (gh - 1) * CELL_SIZE + math.floor(CELL_SIZE / 2)
    local prize_y = base.y + 1   -- ENCIMA del suelo, no reemplazandolo

    for dx = -1, 1 do
        for dz = -1, 1 do
            put(prize_x + dx, base.y, prize_z + dz, cid.gold)   -- alfombra de oro
        end
    end
    -- El cofre NO va aqui: mcl_chests necesita on_construct (ver seccion 8).
    put(prize_x, prize_y, prize_z, cid.air)

    vm:set_data(data)
    vm:set_param2_data(p2)
    vm:write_to_map(true)

    JM.backup    = backup
    JM.base_pos  = base
    JM.prize_pos = {x = prize_x, y = prize_y, z = prize_z}
    JM.maze_bounds = {
        min = pmin,
        max = pmax,
        center = {
            x = base.x + W / 2,
            y = base.y + WALL_HEIGHT / 2,
            z = base.z + H / 2,
        },
        radius = math.max(W, H) / 2 + 12,
    }

    return JM.prize_pos
end

-- ============================================================================
-- 8. COFRE DEL PREMIO (set_node -> corre on_construct de mcl_chests)
-- ============================================================================
local function place_prize_chest(prize_pos)
    minetest.set_node(prize_pos, {
        name = NODES.chest,
        param2 = minetest.dir_to_facedir({x = 0, y = 0, z = -1}),
    })

    local meta = minetest.get_meta(prize_pos)
    meta:set_string("infotext", "Cofre del Premio - Felicidades por llegar al final!")

    -- mcl_chests fija el tamano real en on_construct; no imponemos formspec propio.
    local inv = meta:get_inventory()
    if inv:get_size("main") == 0 then
        inv:set_size("main", 9 * 3)
    end
    for _, spec in ipairs(PRIZE_ITEMS) do
        local stack = ItemStack(spec)
        if stack:is_known() then
            inv:add_item("main", stack)
        else
            log("warning", "item de premio desconocido, se omite: " .. spec)
        end
    end
end

-- ============================================================================
-- 9. ZOMBIES (escalonados; se guardan los ObjectRef para el cleanup)
-- ============================================================================
local function spawn_zombies(grid, base)
    JM.zombies = {}
    if not minetest.registered_entities[ZOMBIE_ENTITY] then
        broadcast(C_WARN, "El laberinto esta listo, pero sin zombies (entidad no disponible).")
        return
    end

    local cells = {}
    local gh, gw = #grid, #grid[1]
    for gy = 1, gh do
        for gx = 1, gw do
            -- Ni la celda de entrada (1,1) ni la del premio (gw,gh)
            if grid[gy][gx] == 0
                and not (gx == 1 and gy == 1)
                and not (gx == gw and gy == gh) then
                cells[#cells + 1] = {gx = gx, gy = gy}
            end
        end
    end
    for i = #cells, 2, -1 do
        local j = math.random(i)
        cells[i], cells[j] = cells[j], cells[i]
    end

    local target = math.min(ZOMBIE_COUNT, #cells)
    local spawned = 0

    local function spawn_next(idx)
        if not JM.active then return end
        if idx > target then
            broadcast(C_WARN, "Cuidado: " .. spawned .. " zombies rondan los pasillos...")
            return
        end
        local c = cells[idx]
        local pos = {
            x = base.x + (c.gx - 1) * CELL_SIZE + math.floor(CELL_SIZE / 2),
            y = base.y + 1,
            z = base.z + (c.gy - 1) * CELL_SIZE + math.floor(CELL_SIZE / 2),
        }
        if minetest.get_node(pos).name == "air" then
            local obj = minetest.add_entity(pos, ZOMBIE_ENTITY)
            if obj then
                JM.zombies[#JM.zombies + 1] = obj
                spawned = spawned + 1
                local lua = obj:get_luaentity()
                if lua then
                    lua.health        = ZOMBIE_BUFF.hp
                    lua.walk_velocity = ZOMBIE_BUFF.walk_velocity
                    lua.run_velocity  = ZOMBIE_BUFF.run_velocity
                    lua.view_range    = ZOMBIE_BUFF.view_range
                    lua.damage        = ZOMBIE_BUFF.damage
                    obj:set_properties({hp_max = ZOMBIE_BUFF.hp})
                    obj:set_hp(ZOMBIE_BUFF.hp)
                end
            end
        end
        minetest.after(0.1, function() spawn_next(idx + 1) end)
    end

    spawn_next(1)
end

-- ============================================================================
-- 10. LIMPIEZA: restaura el terreno original (NO rellena con aire)
-- ============================================================================
local function clear_maze()
    if not JM.active then return false, "no habia laberinto activo" end
    local b = JM.maze_bounds
    if not b then
        JM.active = false
        save_state()
        return false, "no habia bounds guardados; nada que restaurar"
    end

    -- 1. Entidades. Los ObjectRef guardados pueden estar muertos tras un
    --    reinicio, asi que tambien barremos por radio.
    local removed = 0
    for _, obj in ipairs(JM.zombies or {}) do
        if obj and obj:get_pos() and not obj:is_player() then
            obj:remove()
            removed = removed + 1
        end
    end
    JM.zombies = {}

    for _, obj in ipairs(minetest.get_objects_inside_radius(b.center, b.radius)) do
        if obj and not obj:is_player() then
            local lua = obj:get_luaentity()
            if lua and lua.name == ZOMBIE_ENTITY then
                obj:remove()
                removed = removed + 1
            end
        end
    end

    -- 2. Nodos: restaurar desde el backup RLE
    local restored = false
    if JM.backup then
        if minetest.load_area then minetest.load_area(b.min, b.max) end
        local vm = minetest.get_voxel_manip()
        local emin, emax = vm:read_from_map(b.min, b.max)
        local area = VoxelArea:new({MinEdge = emin, MaxEdge = emax})
        local data = vm:get_data()
        local p2   = vm:get_param2_data()
        restored = rle_apply(JM.backup, data, p2, area, b.min, b.max)
        vm:set_data(data)
        vm:set_param2_data(p2)
        vm:write_to_map(true)
    else
        log("error", "sin backup: NO se restaura nada (mejor dejar el laberinto en pie "
            .. "que dejar un crater de aire)")
    end

    JM.active      = false
    JM.base_pos    = nil
    JM.maze_bounds = nil
    JM.prize_pos   = nil
    JM.backup      = nil
    save_state()

    log("action", "laberinto limpiado: " .. removed
        .. " entidades; terreno restaurado=" .. tostring(restored))
    return true, removed
end

-- ============================================================================
-- 11. COMANDO ADMIN
-- ============================================================================
minetest.register_chatcommand("juegos_muerte", {
    description = "Administra el mini-juego Juegos de la Muerte (laberinto con zombies)",
    params = "<colocar|limpiar|estado|premio>",
    privs = {server = true},
    func = function(name, param)
        local sub = (param:match("^(%S+)") or ""):lower()

        if sub == "colocar" or sub == "crear" then
            if not nodes_ready then
                return false, "Nodos requeridos no disponibles en esta instalacion; revisa el log del servidor."
            end
            if JM.active then
                return false, "Ya hay un laberinto activo. Usa '/juegos_muerte limpiar' primero."
            end
            local player = minetest.get_player_by_name(name)
            if not player then return false, "Jugador no encontrado" end

            local now = os.time()
            if not (pending_confirm[name] and now - pending_confirm[name] <= CONFIRM_TTL) then
                pending_confirm[name] = now
                local W = MAZE_SIZE * CELL_SIZE
                return true, minetest.colorize(C_WARN,
                    "ATENCION: esto sobrescribe un volumen de " .. (W + 2) .. "x"
                    .. (WALL_HEIGHT + 5) .. "x" .. (W + 2) .. " nodos en tu posicion. "
                    .. "El terreno original se respalda y se restaura con '/juegos_muerte limpiar'. "
                    .. "Repite el comando dentro de " .. CONFIRM_TTL .. "s para confirmar.")
            end
            pending_confirm[name] = nil

            local base = vector.round(player:get_pos())
            say(name, C_INFO, "Generando laberinto " .. MAZE_SIZE .. "x" .. MAZE_SIZE .. "...")
            local grid = generate_maze(MAZE_SIZE, MAZE_SIZE)
            JM.active = true

            local ok, err = pcall(function()
                local prize = build_maze(grid, base)
                place_prize_chest(prize)
            end)
            if not ok then
                JM.active = false
                log("error", "fallo al construir: " .. tostring(err))
                return false, "Error al construir (el servidor NO se cayo): " .. tostring(err)
            end

            save_state()
            spawn_zombies(grid, base)

            broadcast(C_TITLE, "Los Juegos de la Muerte han comenzado!")
            broadcast(C_INFO, "Un laberinto aparecio en ("
                .. base.x .. ", " .. base.y .. ", " .. base.z .. ").")
            broadcast(C_INFO, "Encuentra el cofre de oro en la esquina opuesta para reclamar tu premio!")
            return true, "Laberinto creado. Entrada en la cara norte (-Z)."

        elseif sub == "limpiar" or sub == "borrar" then
            if not JM.active then
                return false, "No hay laberinto activo para limpiar."
            end
            say(name, C_WARN, "Restaurando el terreno original...")
            local ok, res = clear_maze()
            if not ok then return false, "No se pudo limpiar: " .. tostring(res) end
            broadcast(C_INFO, "El laberinto fue desmantelado y el terreno restaurado.")
            return true, "Listo: " .. res .. " entidades eliminadas."

        elseif sub == "estado" then
            if not JM.active then
                return true, "INACTIVO - No hay laberinto colocado."
            end
            local p = JM.base_pos or {x = "?", y = "?", z = "?"}
            local live = 0
            for _, o in ipairs(JM.zombies or {}) do
                if o and o:get_pos() then live = live + 1 end
            end
            return true, ("ACTIVO - base (%s,%s,%s) | zombies vivos: %d/%d | backup: %d runs")
                :format(tostring(p.x), tostring(p.y), tostring(p.z),
                        live, ZOMBIE_COUNT, JM.backup and #JM.backup or 0)

        elseif sub == "premio" then
            if not (JM.active and JM.prize_pos) then
                return false, "No hay laberinto activo con premio."
            end
            local p = JM.prize_pos
            return true, "Premio en: (" .. p.x .. ", " .. p.y .. ", " .. p.z .. ")"

        else
            return false, "Uso: /juegos_muerte <colocar|limpiar|estado|premio>"
        end
    end,
})

-- ============================================================================
-- 12. VICTORIA (abrir el cofre del premio)
-- ============================================================================
local victory_claimed = false

minetest.register_on_player_receive_fields(function(player, formname, fields)
    if not formname or not formname:find("^mcl_chests:chest_") then return end
    if victory_claimed or not (JM.active and JM.prize_pos) then return end
    if not player or not player:is_player() then return end

    if vector.distance(player:get_pos(), JM.prize_pos) < 6 then
        victory_claimed = true
        local pname = player:get_player_name()
        broadcast(C_TITLE, pname .. " encontro el tesoro y gano los Juegos de la Muerte!")
        broadcast(C_OK, "Felicidades por tu valor y perseverancia!")
        minetest.after(60, function()
            if JM.active then
                broadcast(C_INFO, "Los Juegos de la Muerte concluyeron. El terreno vuelve a su estado original.")
                clear_maze()
            end
            victory_claimed = false
        end)
    end
end)

-- ============================================================================
-- 13. ARRANQUE
-- ============================================================================
minetest.register_on_mods_loaded(function()
    resolve_nodes()
    load_state()
end)

minetest.log("action", "[" .. modname
    .. "] Loaded successfully - v2.0 (nombres verificados, backup/restore de terreno)")
