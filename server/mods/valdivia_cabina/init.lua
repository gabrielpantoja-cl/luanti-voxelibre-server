-- valdivia_cabina: red de transporte publico de Valdivia (puerto 30001).
--
-- Dos partes:
--   1. NUCLEO compartido (este archivo): la lista de destinos, el menu
--      "Lugares" y el viaje con espera/pausa. Lo usan las cabinas, los NPC
--      guia (valdivia_spawn_npc) y la pestana "Mi casa" (valdivia_home), asi
--      que un destino nuevo aparece en todos lados y hay UNA sola logica de
--      teletransporte. API publica: tabla global `valdivia_cabina`.
--   2. CABINA TP (cabina.lua): bloque rojo de 1x2 disenado por Gaspi. Clic
--      derecho abre el menu; cada cabina que coloca el admin se registra sola
--      como destino.
--
-- Destinos: DEFAULT_LUGARES + worldpath/valdivia_lugares.json (lugares que el
-- admin guarda con /lugar_guardar y cabinas colocadas). Mismo archivo que usaba
-- valdivia_spawn_npc antes de 2026-10-07.

local modname = minetest.get_current_modname()

valdivia_cabina = {}

local WARMUP = 3        -- segundos quieto antes de viajar
local COOLDOWN = 30     -- segundos entre viajes
local MOVE_TOL = 0.8    -- nodos que se puede mover durante la espera
local HIDE_RADIUS = 20  -- el menu oculta el destino donde ya estas
local PER_COLUMN = 8    -- botones por columna del menu

valdivia_cabina.WARMUP = WARMUP
valdivia_cabina.COOLDOWN = COOLDOWN

local C_TITULO = "#FFD966"
local C_OK = "#7CFC7C"
local C_INFO = "#8EC7FF"
local C_WARN = "#FFB347"

local F = minetest.formspec_escape
local FORM_MENU = modname .. ":menu"

-- Lugares fijos. Los mas cercanos al jugador se ocultan (HIDE_RADIUS), asi un
-- mismo menu sirve de ida y de vuelta.
local DEFAULT_LUGARES = {
    {id = "plaza",         nombre = "Plaza de Chile (spawn)",        pos = {x = 3669.5, y = -8.5,  z = -3055.5}},
    {id = "catrico",       nombre = "Parque Catrico",                pos = {x = 5025.5, y = -17.5, z = -7028.5}},
    {id = "santa_elena",   nombre = "Santa Elena",                   pos = {x = 6323.1, y = -15.5, z = -7270}},
    {id = "huachocopihue", nombre = "Huachocopihue (Plaza Londres)", pos = {x = 4195.5, y = -5.6,  z = -5943.8}},
}

-- ===========================================================================
-- 1. DESTINOS (persistencia en worldpath/valdivia_lugares.json)
-- ===========================================================================
local STORAGE_FILE = minetest.get_worldpath() .. "/valdivia_lugares.json"

local lugares = {}  -- { {id, nombre, pos, yaw?, cabina?}, ... }

local function index_by_id(id)
    for i, l in ipairs(lugares) do
        if l.id == id then return i end
    end
end

local function copy_pos(p)
    return {x = p.x, y = p.y, z = p.z}
end

local function persist()
    -- Se guarda la lista completa; al cargar, lo guardado pisa a los defaults.
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

local function load_lugares()
    for _, l in ipairs(DEFAULT_LUGARES) do
        table.insert(lugares, {id = l.id, nombre = l.nombre, pos = copy_pos(l.pos)})
    end
    local f = io.open(STORAGE_FILE, "r")
    if not f then return end
    local data = minetest.parse_json(f:read("*a") or "")
    f:close()
    if type(data) ~= "table" then return end
    for _, l in ipairs(data) do
        if l.id and l.pos and l.pos.x and l.pos.y and l.pos.z then
            local entry = {id = l.id, nombre = l.nombre or l.id, pos = copy_pos(l.pos),
                yaw = l.yaw, cabina = l.cabina}
            local i = index_by_id(l.id)
            if i then lugares[i] = entry else table.insert(lugares, entry) end
        end
    end
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
local menu_ctx = {}  -- name -> {on_back = fn, visibles = {...}}

-- opts.titulo: titulo del menu; opts.on_back(name): muestra un boton "Volver".
function valdivia_cabina.show_menu(name, opts)
    opts = opts or {}
    local player = minetest.get_player_by_name(name)
    if not player then return end
    local ppos = player:get_pos()

    local visibles = {}
    for _, l in ipairs(lugares) do
        if vector.distance(ppos, l.pos) > HIDE_RADIUS then
            table.insert(visibles, l)
        end
    end
    menu_ctx[name] = {on_back = opts.on_back, visibles = visibles}

    local titulo = opts.titulo or "Lugares de Valdivia"
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
        table.insert(fs, "label[0.5,1.6;" .. F("Ya estas en el unico destino disponible.") .. "]")
    end
    for i, l in ipairs(visibles) do
        local col = math.floor((i - 1) / PER_COLUMN)
        local fila = (i - 1) % PER_COLUMN
        local etiqueta = (l.cabina and "[TP] " or "") .. l.nombre
        table.insert(fs, ("button_exit[%s,%s;7,0.8;tp_%d;%s]"):format(
            0.5 + col * 7.5, 1.2 + fila * 1.0, i, F(etiqueta)))
    end
    local y = 1.4 + filas * 1.0
    table.insert(fs, "label[0.5," .. y .. ";" .. minetest.colorize(C_INFO,
        F("Al viajar quedate quieto " .. WARMUP .. " s. [TP] = cabina.")) .. "]")
    if opts.on_back then
        table.insert(fs, "button[0.5," .. (y + 0.5) .. ";7,0.8;btn_volver;" .. F("Volver") .. "]")
    else
        table.insert(fs, "button_exit[0.5," .. (y + 0.5) .. ";7,0.8;btn_cerrar;" .. F("Cerrar") .. "]")
    end
    minetest.show_formspec(name, FORM_MENU, table.concat(fs))
end

minetest.register_on_player_receive_fields(function(player, formname, fields)
    if formname ~= FORM_MENU then return end
    local name = player:get_player_name()
    local ctx = menu_ctx[name]
    if not ctx then return true end
    if fields.btn_volver and ctx.on_back then
        ctx.on_back(name)
        return true
    end
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
-- 4. COMANDOS DE DESTINOS
-- ===========================================================================
minetest.register_chatcommand("lugar_guardar", {
    params = "<id> <nombre visible>",
    description = "Guarda tu posicion actual como destino del menu de Lugares (admin)",
    privs = {server = true},
    func = function(name, param)
        local player = minetest.get_player_by_name(name)
        if not player then return false, "Jugador no encontrado" end
        local id, nombre = (param or ""):match("^(%S+)%s+(.+)$")
        if not id then
            id = (param or ""):match("^(%S+)$")
            nombre = id
        end
        if not id then return false, "Uso: /lugar_guardar <id> <nombre visible>" end
        if not id:match("^[%w_]+$") then
            return false, "El id solo puede tener letras, numeros y _"
        end
        local pos = vector.round(player:get_pos())
        valdivia_cabina.set_lugar(id, nombre, pos, {yaw = player:get_look_horizontal()})
        return true, "Lugar '" .. id .. "' (" .. nombre .. ") guardado en " .. minetest.pos_to_string(pos)
    end,
})

minetest.register_chatcommand("lugar_borrar", {
    params = "<id>",
    description = "Quita un destino del menu de Lugares (admin). Las cabinas se quitan con /cabina quitar",
    privs = {server = true},
    func = function(name, param)
        local l = valdivia_cabina.get_lugar(param or "")
        if not l then return false, "No existe el lugar '" .. (param or "") .. "'. Mira /lugares." end
        if l.cabina then return false, "Es una cabina: parate al lado y usa /cabina quitar." end
        valdivia_cabina.remove_lugar(l.id)
        return true, "Lugar '" .. l.id .. "' quitado."
    end,
})

minetest.register_chatcommand("lugares", {
    description = "Lista los destinos de la red de Valdivia",
    func = function()
        if #lugares == 0 then return true, "No hay lugares registrados." end
        local lines = {"== Lugares de Valdivia =="}
        for _, l in ipairs(lugares) do
            table.insert(lines, "  " .. (l.cabina and "[TP] " or "") .. l.id .. " - " ..
                l.nombre .. " " .. minetest.pos_to_string(vector.round(l.pos)))
        end
        return true, table.concat(lines, "\n")
    end,
})

dofile(minetest.get_modpath(modname) .. "/cabina.lua")

minetest.log("action", "[" .. modname .. "] Loaded successfully (" .. #lugares .. " destinos)")
