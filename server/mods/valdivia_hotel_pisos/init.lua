-- Un piso del Hotel Dreams por jugador (Valdivia, puerto 30001).
--
-- Problema: el bloque de `protector` protege un cubo de 41x41x41 (radio 20,
-- global). Los pisos del hotel miden 4 de alto, asi que un protector toma ~8
-- pisos y choca con los del admin que ya cubren el edificio.
--
-- Solucion: este mod envuelve core.is_protected DESPUES de protector (por eso
-- optional_depends = protector) y decide primero dentro del hotel:
--   * Interior de un piso CON dueno -> solo el dueno, sus amigos y quien tenga
--     protection_bypass/server pueden construir. El resto queda bloqueado (y el
--     carabinero de valdivia_policia actua igual que con un protector).
--   * Todo lo demas (piso 1, losas entre pisos, fachada, ascensor, pisos sin
--     dueno) -> se delega a la proteccion de siempre.
--   * En el hotel no se pueden colocar bloques protector (su cubo volveria a
--     pisar los pisos vecinos), salvo el admin.
--
-- El interior de un piso son solo las capas de aire entre dos losas. El dueno
-- no puede romper el suelo, el techo ni la fachada: no abre hoyos al vecino.
--
-- Asignaciones en el mod_storage del mundo; se manejan con /hotel (README.md).

local modname = minetest.get_current_modname()
local storage = minetest.get_mod_storage()

local NUM_PISOS = 15
local PISO_COMUN = 1          -- planta baja: zona comun, nunca se asigna

-- ---------------------------------------------------------------------------
-- Geometria: huella.json (medida desde map.sqlite, no a ojo)
-- ---------------------------------------------------------------------------
-- El hotel NO es una caja: la planta es un paralelogramo de bordes curvos, y
-- el paso entre pisos es 5 (losa + 4 de aire), tomado de las 15 paradas del
-- ascensor. huella.json trae, por piso, los intervalos [x1,x2] de cada fila z
-- del interior (losa erosionada 1 nodo: la fachada queda fuera).
local HUELLA
do
    local fh = io.open(minetest.get_modpath(modname) .. "/huella.json", "r")
    if fh then
        local parsed = minetest.parse_json(fh:read("*all"))
        fh:close()
        if parsed and parsed.pisos and parsed.base and parsed.paso then
            HUELLA = { base = parsed.base, paso = parsed.paso, techo = parsed.techo,
                ascensor = parsed.ascensor, pisos = {} }
            for n, filas in pairs(parsed.pisos) do
                local t = {}
                for z, iv in pairs(filas) do t[tonumber(z)] = iv end
                HUELLA.pisos[tonumber(n)] = t
            end
        end
    end
    if not HUELLA then
        minetest.log("error", "[" .. modname .. "] huella.json falta o es ilegible: el mod no protege nada")
    end
end

-- Caja holgada del edificio, solo para vetar bloques protector.
local CAJA = { x1 = 3682, x2 = 3728, z1 = -2970, z2 = -2917, y1 = -12, y2 = 72 }

local function en_hotel(pos)
    return pos.x >= CAJA.x1 and pos.x <= CAJA.x2 and pos.z >= CAJA.z1 and pos.z <= CAJA.z2
        and pos.y >= CAJA.y1 and pos.y <= CAJA.y2
end

local function en_ascensor(pos)
    local a = HUELLA.ascensor
    return a and pos.x >= a[1] and pos.x <= a[3] and pos.z >= a[2] and pos.z <= a[4]
end

local function losa(n)
    return HUELLA.base + (n - 1) * HUELLA.paso
end

-- Rango y (inclusive) del interior del piso n. El ultimo llega hasta el techo.
local function interior(n)
    local hi = losa(n + 1) - 1
    if n == NUM_PISOS and HUELLA.techo then hi = HUELLA.techo - 1 end
    return losa(n) + 1, hi
end

-- Numero de piso cuyo INTERIOR contiene pos, o nil (losa, fachada, ascensor, fuera).
local function piso_en(pos)
    if not HUELLA then return nil end
    local n = math.floor((pos.y - HUELLA.base) / HUELLA.paso) + 1
    if n == NUM_PISOS + 1 and HUELLA.techo and pos.y < HUELLA.techo then n = NUM_PISOS end
    if n < 1 or n > NUM_PISOS then return nil end
    local lo, hi = interior(n)
    if pos.y < lo or pos.y > hi then return nil end
    local fila = HUELLA.pisos[n] and HUELLA.pisos[n][pos.z]
    if not fila then return nil end
    for _, iv in ipairs(fila) do
        if pos.x >= iv[1] and pos.x <= iv[2] then
            if en_ascensor(pos) then return nil end
            return n
        end
    end
    return nil
end

-- ---------------------------------------------------------------------------
-- Estado persistente: cfg.pisos = { ["15"] = { dueno = "x", amigos = { y = true } } }
-- ---------------------------------------------------------------------------
local cfg

local function cargar()
    local crudo = storage:get_string("cfg")
    cfg = (crudo ~= "" and minetest.parse_json(crudo)) or {}
    if type(cfg) ~= "table" then cfg = {} end
    if type(cfg.pisos) ~= "table" then cfg.pisos = {} end
    -- Claves siempre string ("15") y amigos siempre tabla, venga como venga el JSON.
    local pisos = {}
    for k, p in pairs(cfg.pisos) do
        if type(p) == "table" and p.dueno then
            if type(p.amigos) ~= "table" then p.amigos = {} end
            pisos[tostring(k)] = p
        end
    end
    cfg.pisos = pisos
end

local function guardar()
    storage:set_string("cfg", minetest.write_json(cfg))
end

cargar()

local function es_admin(name)
    if not name or name == "" then return false end
    return minetest.check_player_privs(name, { server = true })
        or minetest.check_player_privs(name, { protection_bypass = true })
end

local function piso_de_jugador(name)
    for k, p in pairs(cfg.pisos) do
        if p.dueno == name then return tonumber(k), p end
    end
    return nil
end

-- ---------------------------------------------------------------------------
-- Proteccion
-- ---------------------------------------------------------------------------
local old_is_protected = minetest.is_protected

function minetest.is_protected(pos, name)
    local n = piso_en(pos)
    if n then
        local p = cfg.pisos[tostring(n)]
        if p and p.dueno then
            name = name or ""
            if name == p.dueno or p.amigos[name] or es_admin(name) then
                return false
            end
            return true
        end
    end
    return old_is_protected(pos, name)
end

-- Bloques protector prohibidos en el hotel (salvo admin).
minetest.register_on_mods_loaded(function()
    for _, item in ipairs({ "protector:protect", "protector:protect2", "protector:protect_hidden" }) do
        local def = minetest.registered_items[item]
        if def then
            local orig = def.on_place or minetest.item_place
            minetest.override_item(item, {
                on_place = function(itemstack, placer, pointed_thing)
                    local name = placer and placer:get_player_name() or ""
                    if pointed_thing and pointed_thing.type == "node" and not es_admin(name)
                    and (en_hotel(pointed_thing.above) or en_hotel(pointed_thing.under)) then
                        minetest.chat_send_player(name,
                            "En el Hotel Dreams no se usan bloques protectores: "
                            .. "cada piso ya esta protegido para su dueno. Mira /hotel")
                        return itemstack
                    end
                    return orig(itemstack, placer, pointed_thing)
                end,
            })
        end
    end
end)

-- ---------------------------------------------------------------------------
-- Comandos
-- ---------------------------------------------------------------------------
local AYUDA_ADMIN = "Admin: /hotel asignar <n> <jugador> | /hotel liberar <n> | /hotel lista"

local AYUDA_JUGADOR = table.concat({
    "/hotel mio                    -> tu piso y tus amigos",
    "/hotel amigo <jugador>        -> deja que alguien construya en tu piso",
    "/hotel amigo quitar <jugador> -> le quita el permiso",
    "/hotel info                   -> de quien es el piso donde estas",
}, "\n")

local function cmd_info(name)
    local player = minetest.get_player_by_name(name)
    if not player then return false, "No te encuentro." end
    if not HUELLA then return false, "El hotel no esta configurado (falta huella.json)." end
    local n = piso_en(vector.round(player:get_pos()))
    if not n then
        return true, "No estas en el interior de un piso del Hotel Dreams "
            .. "(fuera, losa, fachada o ascensor)."
    end
    local p = cfg.pisos[tostring(n)]
    local lo, hi = interior(n)
    return true, ("Piso %d (interior y=%d..%d): %s"):format(n, lo, hi,
        n == PISO_COMUN and "zona comun"
        or (p and p.dueno and ("de " .. p.dueno) or "sin dueno"))
end

local function nombres_amigos(p)
    local amigos = {}
    for a in pairs(p.amigos) do amigos[#amigos + 1] = a end
    table.sort(amigos)
    return amigos
end

local function cmd_admin(args)
    local sub = args[1]
    if sub == "asignar" then
        local n, jugador = tonumber(args[2]), args[3]
        if not n or not jugador then return false, "Uso: /hotel asignar <n> <jugador>" end
        if n ~= math.floor(n) or n == PISO_COMUN or n < 1 or n > NUM_PISOS then
            return false, ("El piso debe ser entre 2 y %d (el 1 es zona comun)."):format(NUM_PISOS)
        end
        local actual = piso_de_jugador(jugador)
        if actual and actual ~= n then
            return false, ("%s ya tiene el piso %d. Un piso por jugador: /hotel liberar %d primero.")
                :format(jugador, actual, actual)
        end
        cfg.pisos[tostring(n)] = { dueno = jugador, amigos = {} }
        guardar()
        minetest.chat_send_player(jugador, ("Ahora el piso %d del Hotel Dreams es tuyo. "
            .. "Puedes construir ahi. /hotel mio"):format(n))
        return true, ("Piso %d asignado a %s."):format(n, jugador)
    elseif sub == "liberar" then
        local n = tonumber(args[2])
        if not n or not cfg.pisos[tostring(n)] then return false, "Ese piso no tiene dueno." end
        cfg.pisos[tostring(n)] = nil
        guardar()
        return true, ("Piso %d liberado (lo construido queda)."):format(n)
    elseif sub == "lista" then
        local l = {}
        for n = 2, NUM_PISOS do
            local p = cfg.pisos[tostring(n)]
            if p then
                local amigos = nombres_amigos(p)
                l[#l + 1] = ("Piso %d: %s%s"):format(n, p.dueno,
                    #amigos > 0 and (" (amigos: " .. table.concat(amigos, ", ") .. ")") or "")
            end
        end
        return true, #l > 0 and table.concat(l, "\n") or "Ningun piso asignado."
    end
    return nil
end

local function cmd_jugador(name, args)
    local sub = args[1]
    if sub == "mio" then
        local n, p = piso_de_jugador(name)
        if not n then return true, "No tienes piso en el Hotel Dreams. Pidelo con /gabo." end
        local amigos = nombres_amigos(p)
        return true, ("Tu piso: %d. Amigos: %s"):format(n,
            #amigos > 0 and table.concat(amigos, ", ") or "ninguno")
    elseif sub == "amigo" then
        local n, p = piso_de_jugador(name)
        if not n then return false, "No tienes piso en el Hotel Dreams." end
        if args[2] == "quitar" and args[3] then
            p.amigos[args[3]] = nil
            guardar()
            return true, args[3] .. " ya no puede construir en tu piso."
        elseif args[2] and args[2] ~= "quitar" then
            if not minetest.player_exists(args[2]) then return false, "No existe el jugador " .. args[2] end
            p.amigos[args[2]] = true
            guardar()
            return true, args[2] .. " ahora puede construir en tu piso " .. n .. "."
        end
        return false, "Uso: /hotel amigo <jugador> | /hotel amigo quitar <jugador>"
    elseif sub == "info" then
        return cmd_info(name)
    end
    return nil
end

minetest.register_chatcommand("hotel", {
    params = "mio | amigo [quitar] <jugador> | info | (admin) asignar/liberar/lista",
    description = "Pisos del Hotel Dreams: un piso por jugador",
    func = function(name, param)
        local args = (param or ""):split(" ")
        local ok, msg = cmd_jugador(name, args)
        if ok ~= nil then return ok, msg end
        if es_admin(name) then
            ok, msg = cmd_admin(args)
            if ok ~= nil then return ok, msg end
            return true, AYUDA_JUGADOR .. "\n" .. AYUDA_ADMIN
        end
        return true, AYUDA_JUGADOR
    end,
})

-- API para otros mods (p.ej. el cartel).
valdivia_hotel_pisos = {
    dueno = function(n)
        local p = cfg.pisos[tostring(n)]
        return p and p.dueno or nil
    end,
}

minetest.log("warning", "[" .. modname .. "] Loaded successfully"
    .. (HUELLA and "" or " (SIN huella: inactivo)"))
