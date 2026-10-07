-- valdivia_cabina: red de transporte publico de Valdivia (puerto 30001).
--
-- La UNICA forma de viajar por la ciudad son las Cabinas TP: bloque rojo de
-- 1x2 disenado por Gaspi (cabina.lua). Clic derecho en una cabina abre el menu
-- con las DEMAS cabinas; cada cabina que coloca el admin se registra sola como
-- destino. Los NPC guia solo conversan (2026-10-07).
--
-- Este archivo es el nucleo: lista de cabinas, menu y viaje con espera/pausa.
-- La pestana "Mi casa" (valdivia_home) reutiliza valdivia_cabina.request para
-- ir a casa con las mismas reglas.
--
-- Destinos: worldpath/valdivia_lugares.json (solo cabinas). Los lugares fijos y
-- /lugar_guardar se retiraron 2026-10-07: duplicaban las cabinas puestas en los
-- mismos sitios.

local modname = minetest.get_current_modname()

valdivia_cabina = {}

local WARMUP = 3        -- segundos quieto antes de viajar
local COOLDOWN = 30     -- segundos entre viajes
local MOVE_TOL = 0.8    -- nodos que se puede mover durante la espera
local PER_COLUMN = 8    -- botones por columna del menu

valdivia_cabina.WARMUP = WARMUP
valdivia_cabina.COOLDOWN = COOLDOWN

local C_TITULO = "#FFD966"
local C_OK = "#7CFC7C"
local C_INFO = "#8EC7FF"
local C_WARN = "#FFB347"

local F = minetest.formspec_escape
local FORM_MENU = modname .. ":menu"

-- ===========================================================================
-- 1. DESTINOS = CABINAS (persistencia en worldpath/valdivia_lugares.json)
-- ===========================================================================
local STORAGE_FILE = minetest.get_worldpath() .. "/valdivia_lugares.json"

local lugares = {}  -- { {id, nombre, pos, yaw, cabina = "(x,y,z)"}, ... }

local function index_by_id(id)
    for i, l in ipairs(lugares) do
        if l.id == id then return i end
    end
end

local function copy_pos(p)
    return {x = p.x, y = p.y, z = p.z}
end

local function persist()
    local f = io.open(STORAGE_FILE, "w")
    if not f then
        minetest.log("error", "[" .. modname .. "] No se pudo escribir " .. STORAGE_FILE)
        return false
    end
    f:write(minetest.write_json(lugares))
    f:close()
    return true
end

function valdivia_cabina.set_lugar(id, nombre, pos, extra)
    local entry = {id = id, nombre = nombre, pos = copy_pos(pos)}
    for k, v in pairs(extra or {}) do entry[k] = v end
    local i = index_by_id(id)
    if i then lugares[i] = entry else table.insert(lugares, entry) end
    persist()
    return entry
end

function valdivia_cabina.remove_lugar(id)
    local i = index_by_id(id)
    if not i then return false end
    table.remove(lugares, i)
    persist()
    return true
end

function valdivia_cabina.get_lugar(id)
    local i = index_by_id(id)
    return i and lugares[i] or nil
end

function valdivia_cabina.get_lugares()
    return lugares
end

-- Carga solo cabinas. Migracion 2026-10-07: descarta los lugares fijos que la
-- version anterior guardaba en el JSON y quita el prefijo "Cabina " del nombre.
local function load_lugares()
    local f = io.open(STORAGE_FILE, "r")
    if not f then return end
    local data = minetest.parse_json(f:read("*a") or "")
    f:close()
    if type(data) ~= "table" then return end
    local migrado = false
    for _, l in ipairs(data) do
        if l.cabina and l.id and l.pos and l.pos.x and l.pos.y and l.pos.z then
            local nombre = l.nombre or l.id
            if not l.v then  -- formato viejo: "Cabina <nombre>"
                nombre = nombre:gsub("^Cabina ", "")
                migrado = true
            end
            if not index_by_id(l.id) then
                table.insert(lugares, {id = l.id, nombre = nombre, pos = copy_pos(l.pos),
                    yaw = l.yaw, cabina = l.cabina, v = 2})
            end
        else
            migrado = true
        end
    end
    if migrado then persist() end
end

load_lugares()

-- ===========================================================================
-- 2. VIAJE (espera quieto + pausa entre viajes; admin sin espera)
-- ===========================================================================
local pending = {}  -- name -> {dest, label, yaw, start, hp, left}
local last_tp = {}  -- name -> os.time() del ultimo viaje

local function say(name, color, msg)
    minetest.chat_send_player(name, minetest.colorize(color, msg))
end

local function is_admin(name)
    return minetest.check_player_privs(name, {server = true})
end

local function cooldown_left(name)
    if is_admin(name) or not last_tp[name] then return 0 end
    return math.max(0, COOLDOWN - (os.time() - last_tp[name]))
end

local function do_teleport(player, dest, label, yaw)
    local name = player:get_player_name()
    player:set_pos(dest)
    if yaw then player:set_look_horizontal(yaw) end
    last_tp[name] = os.time()
    say(name, C_OK, "Llegaste a " .. label .. ".")
    minetest.log("action", "[" .. modname .. "] " .. name .. " -> " .. label ..
        " " .. minetest.pos_to_string(vector.round(dest)))
end

-- Pide un viaje. opts.yaw orienta la vista al llegar (ej. mirando la cabina).
function valdivia_cabina.request(player, dest, label, opts)
    if not player or not dest then return end
    local name = player:get_player_name()
    local yaw = opts and opts.yaw
    local left = cooldown_left(name)
    if left > 0 then
        say(name, C_WARN, "Espera " .. left .. " s antes de volver a viajar.")
        return
    end
    if is_admin(name) then
        do_teleport(player, dest, label, yaw)
        return
    end
    pending[name] = {dest = copy_pos(dest), label = label, yaw = yaw,
        start = player:get_pos(), hp = player:get_hp(), left = WARMUP}
    say(name, C_INFO, "Viajando a " .. label .. " en " .. WARMUP .. " s... quedate quieto.")
end

minetest.register_globalstep(function(dtime)
    for name, p in pairs(pending) do
        local player = minetest.get_player_by_name(name)
        if not player then
            pending[name] = nil
        else
            local pos = player:get_pos()
            if math.abs(pos.x - p.start.x) > MOVE_TOL or
                    math.abs(pos.y - p.start.y) > MOVE_TOL or
                    math.abs(pos.z - p.start.z) > MOVE_TOL then
                pending[name] = nil
                say(name, C_WARN, "Viaje cancelado: te moviste.")
            elseif player:get_hp() < p.hp then
                pending[name] = nil
                say(name, C_WARN, "Viaje cancelado: recibiste dano.")
            else
                p.left = p.left - dtime
                if p.left <= 0 then
                    pending[name] = nil
                    do_teleport(player, p.dest, p.label, p.yaw)
                end
            end
        end
    end
end)

-- ===========================================================================
-- 3. MENU DE DESTINOS
-- ===========================================================================
local menu_ctx = {}  -- name -> {visibles = {...}}

-- opts.titulo: titulo; opts.excluir: id de la cabina desde donde se abre.
function valdivia_cabina.show_menu(name, opts)
    opts = opts or {}
    if not minetest.get_player_by_name(name) then return end

    local visibles = {}
    for _, l in ipairs(lugares) do
        if l.id ~= opts.excluir then table.insert(visibles, l) end
    end
    table.sort(visibles, function(a, b) return a.nombre:lower() < b.nombre:lower() end)
    menu_ctx[name] = {visibles = visibles}

    local titulo = opts.titulo or "Cabinas TP de Valdivia"
    local ncols = math.max(1, math.ceil(#visibles / PER_COLUMN))
    local filas = math.min(math.max(#visibles, 1), PER_COLUMN)
    local ancho = 0.5 + ncols * 7.5
    local alto = 2.9 + filas * 1.0
    local fs = {
        "formspec_version[4]",
        "size[", ancho, ",", alto, "]",
        "label[0.5,0.6;", minetest.colorize(C_TITULO, F(titulo)), "]",
    }
    if #visibles == 0 then
        table.insert(fs, "label[0.5,1.6;" .. F("Todavia no hay otras cabinas.") .. "]")
    end
    for i, l in ipairs(visibles) do
        local col = math.floor((i - 1) / PER_COLUMN)
        local fila = (i - 1) % PER_COLUMN
        table.insert(fs, ("button_exit[%s,%s;7,0.8;tp_%d;%s]"):format(
            0.5 + col * 7.5, 1.2 + fila * 1.0, i, F(l.nombre)))
    end
    local y = 1.4 + filas * 1.0
    table.insert(fs, "label[0.5," .. y .. ";" .. minetest.colorize(C_INFO,
        F("Al viajar quedate quieto " .. WARMUP .. " s.")) .. "]")
    table.insert(fs, "button_exit[0.5," .. (y + 0.5) .. ";7,0.8;btn_cerrar;" .. F("Cerrar") .. "]")
    minetest.show_formspec(name, FORM_MENU, table.concat(fs))
end

minetest.register_on_player_receive_fields(function(player, formname, fields)
    if formname ~= FORM_MENU then return end
    local name = player:get_player_name()
    local ctx = menu_ctx[name]
    if not ctx then return true end
    for i, l in ipairs(ctx.visibles) do
        if fields["tp_" .. i] then
            valdivia_cabina.request(player, l.pos, l.nombre, {yaw = l.yaw})
            break
        end
    end
    if fields.quit then menu_ctx[name] = nil end
    return true
end)

minetest.register_on_leaveplayer(function(player)
    local name = player:get_player_name()
    pending[name] = nil
    last_tp[name] = nil
    menu_ctx[name] = nil
end)

-- ===========================================================================
-- 4. COMANDO /lugares (las cabinas se gestionan con /cabina, en cabina.lua)
-- ===========================================================================
minetest.register_chatcommand("lugares", {
    description = "Lista las cabinas TP de Valdivia",
    func = function()
        if #lugares == 0 then return true, "Todavia no hay cabinas TP." end
        local lines = {"== Cabinas TP de Valdivia =="}
        for _, l in ipairs(lugares) do
            table.insert(lines, "  " .. l.nombre .. " " .. minetest.pos_to_string(vector.round(l.pos)))
        end
        return true, table.concat(lines, "\n")
    end,
})

dofile(minetest.get_modpath(modname) .. "/cabina.lua")

minetest.log("action", "[" .. modname .. "] Loaded successfully (" .. #lugares .. " cabinas)")
