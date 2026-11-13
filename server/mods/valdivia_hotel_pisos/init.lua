-- Un piso del Hotel Dreams por jugador (Valdivia, puerto 30001).
--
-- Problema: el bloque de `protector` protege un cubo de 41x41x41 (radio 20,
-- global). Los pisos del hotel miden 4 de alto, asi que un protector toma ~10
-- pisos y choca con el del admin que ya cubre el edificio.
--
-- Solucion: este mod envuelve core.is_protected DESPUES de protector (por eso
-- optional_depends = protector) y decide primero dentro del hotel:
--   * Interior de un piso CON dueno -> solo el dueno, sus amigos y quien tenga
--     protection_bypass/server pueden construir. El resto queda bloqueado (y el
--     carabinero de valdivia_policia actua igual que con un protector).
--   * Todo lo demas (piso 1, losas entre pisos, zonas excluidas como ascensor
--     y escaleras, pisos sin dueno) -> se delega a la proteccion de siempre.
--   * Dentro del hotel no se pueden colocar bloques protector (su cubo volveria
--     a pisar los pisos vecinos), salvo el admin.
--
-- El interior de un piso son solo las capas de aire: losa+1 .. siguiente losa-1.
-- El dueno no puede romper el piso ni el techo, asi que no abre hoyos al vecino.
--
-- Todo se configura en el juego con /hotel (ver README.md) y se guarda en el
-- mod_storage del mundo.

local modname = minetest.get_current_modname()
local storage = minetest.get_mod_storage()

local NUM_PISOS = 15
local PISO_COMUN = 1          -- planta baja: zona comun, nunca se asigna
local ALTURA_DEFECTO = 4

-- ---------------------------------------------------------------------------
-- Estado persistente
-- ---------------------------------------------------------------------------
-- cfg = {
--   hotel = {x1, z1, x2, z2},          -- interior del hotel (inclusive)
--   base = y,                          -- y de la losa del piso 1
--   altura = 4,
--   losas = { ["7"] = y },             -- ajustes manuales de la losa del piso n
--   excluidas = { nombre = {x1,z1,x2,z2} },   -- columnas solo-admin (todas las y)
--   pisos = { ["15"] = { dueno = "luciano80", amigos = { pepe = true } } },
-- }
local cfg

local function cargar()
    local crudo = storage:get_string("cfg")
    cfg = (crudo ~= "" and minetest.parse_json(crudo)) or {}
    if type(cfg) ~= "table" then cfg = {} end
    cfg.altura = tonumber(cfg.altura) or ALTURA_DEFECTO
    cfg.losas = cfg.losas or {}
    cfg.excluidas = cfg.excluidas or {}
    cfg.pisos = cfg.pisos or {}
    -- parse_json convierte {} vacio en un array; normalizar sub-tablas
    for _, p in pairs(cfg.pisos) do
        if type(p.amigos) ~= "table" then p.amigos = {} end
    end
end

local function guardar()
    storage:set_string("cfg", minetest.write_json(cfg))
end

cargar()

-- ---------------------------------------------------------------------------
-- Geometria
-- ---------------------------------------------------------------------------
local function losa(n)
    return tonumber(cfg.losas[tostring(n)]) or (cfg.base + (n - 1) * cfg.altura)
end

local function en_caja(c, x, z)
    return x >= math.min(c[1], c[3]) and x <= math.max(c[1], c[3])
       and z >= math.min(c[2], c[4]) and z <= math.max(c[2], c[4])
end

local function configurado()
    return cfg.hotel ~= nil and cfg.base ~= nil
end

local function en_hotel(pos)
    if not configurado() then return false end
    return en_caja(cfg.hotel, pos.x, pos.z)
        and pos.y >= cfg.base and pos.y <= losa(NUM_PISOS + 1)
end

local function excluida(pos)
    for nombre, c in pairs(cfg.excluidas) do
        if en_caja(c, pos.x, pos.z) then return nombre end
    end
    return nil
end

-- Numero de piso cuyo INTERIOR contiene pos, o nil (losa, fuera, excluida).
local function piso_en(pos)
    if not en_hotel(pos) or excluida(pos) then return nil end
    for n = 1, NUM_PISOS do
        local lo, hi = losa(n) + 1, losa(n + 1) - 1
        if pos.y >= lo and pos.y <= hi then return n end
    end
    return nil
end

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

-- Bloques protector prohibidos dentro del hotel (salvo admin).
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
                            .. "tu piso ya esta protegido. Mira /hotel")
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
local marcas = {}   -- [admin] = { [1] = pos, [2] = pos }

local function pies(name)
    local player = minetest.get_player_by_name(name)
    if not player then return nil end
    return vector.round(player:get_pos())
end

local function caja_de_marcas(name)
    local m = marcas[name]
    if not (m and m[1] and m[2]) then return nil end
    return { m[1].x, m[1].z, m[2].x, m[2].z }
end

local function fmt_caja(c)
    return ("x %d..%d, z %d..%d"):format(math.min(c[1], c[3]), math.max(c[1], c[3]),
        math.min(c[2], c[4]), math.max(c[2], c[4]))
end

local AYUDA_ADMIN = table.concat({
    "Calibrar (una vez):",
    "  /hotel marcar 1 | /hotel marcar 2  -> parate en dos esquinas opuestas del interior",
    "  /hotel limites                     -> guarda el interior del hotel con esas marcas",
    "  /hotel base [altura]               -> parado en el piso 1: losa del piso 1 (+ altura, se mide sola)",
    "  /hotel losa <n>                    -> parado en el piso n: corrige su losa si no es regular",
    "  /hotel excluir <nombre>            -> columna solo-admin (ascensor, escalera) con las marcas",
    "  /hotel incluir <nombre>            -> borra una exclusion",
    "Pisos:",
    "  /hotel asignar <n> <jugador> | /hotel liberar <n> | /hotel lista | /hotel info",
}, "\n")

local AYUDA_JUGADOR = table.concat({
    "/hotel mio                    -> tu piso y tus amigos",
    "/hotel amigo <jugador>        -> deja que alguien construya en tu piso",
    "/hotel amigo quitar <jugador> -> le quita el permiso",
    "/hotel info                   -> de quien es el piso donde estas",
}, "\n")

local function cmd_info(name)
    local pos = pies(name)
    if not pos then return false, "No te encuentro." end
    local lineas = {}
    if not configurado() then
        lineas[#lineas + 1] = "El hotel aun no esta calibrado."
    else
        lineas[#lineas + 1] = ("Hotel: %s, losa piso 1 y=%d, altura %d.")
            :format(fmt_caja(cfg.hotel), cfg.base, cfg.altura)
        local ex = excluida(pos)
        local n = piso_en(pos)
        if not en_hotel(pos) then
            lineas[#lineas + 1] = "Estas fuera del hotel."
        elseif ex then
            lineas[#lineas + 1] = "Estas en la zona excluida '" .. ex .. "' (solo admin)."
        elseif not n then
            lineas[#lineas + 1] = ("Estas sobre una losa (y=%d)."):format(pos.y)
        else
            local p = cfg.pisos[tostring(n)]
            lineas[#lineas + 1] = ("Piso %d (interior y=%d..%d): %s"):format(n,
                losa(n) + 1, losa(n + 1) - 1,
                n == PISO_COMUN and "zona comun"
                or (p and p.dueno and ("de " .. p.dueno) or "sin dueno"))
        end
    end
    return true, table.concat(lineas, "\n")
end

local function cmd_admin(name, args)
    local sub = args[1]
    if sub == "marcar" then
        local i = tonumber(args[2])
        if i ~= 1 and i ~= 2 then return false, "Uso: /hotel marcar 1|2" end
        marcas[name] = marcas[name] or {}
        marcas[name][i] = pies(name)
        return true, ("Marca %d en %s"):format(i, minetest.pos_to_string(marcas[name][i]))
    elseif sub == "limites" then
        local c = caja_de_marcas(name)
        if not c then return false, "Primero /hotel marcar 1 y /hotel marcar 2" end
        cfg.hotel = c
        guardar()
        return true, "Interior del hotel: " .. fmt_caja(c)
    elseif sub == "base" then
        local pos = pies(name)
        if not pos then return false, "No te encuentro." end
        local altura = tonumber(args[2])
        local medido
        for y = pos.y, pos.y + 12 do
            local nd = minetest.registered_nodes[minetest.get_node({ x = pos.x, y = y, z = pos.z }).name]
            if nd and nd.walkable then medido = y - (pos.y - 1); break end
        end
        cfg.base = pos.y - 1
        cfg.altura = altura or medido or ALTURA_DEFECTO
        guardar()
        return true, ("Losa del piso 1 en y=%d. Altura de piso %d (medida: %s). "
            .. "Piso 15: interior y=%d..%d.")
            :format(cfg.base, cfg.altura, medido and tostring(medido) or "sin techo encima",
                losa(15) + 1, losa(16) - 1)
    elseif sub == "losa" then
        local n = tonumber(args[2])
        local pos = pies(name)
        if not n or n < 1 or n > NUM_PISOS + 1 or not pos then
            return false, "Uso: /hotel losa <n> (parado sobre el suelo del piso n)"
        end
        cfg.losas[tostring(n)] = pos.y - 1
        guardar()
        return true, ("Losa del piso %d fijada en y=%d"):format(n, pos.y - 1)
    elseif sub == "excluir" then
        local c = caja_de_marcas(name)
        if not c or not args[2] then return false, "Uso: /hotel excluir <nombre> (con las 2 marcas puestas)" end
        cfg.excluidas[args[2]] = c
        guardar()
        return true, ("Zona excluida '%s': %s (todas las alturas)"):format(args[2], fmt_caja(c))
    elseif sub == "incluir" then
        if not args[2] or not cfg.excluidas[args[2]] then return false, "No existe esa exclusion." end
        cfg.excluidas[args[2]] = nil
        guardar()
        return true, "Exclusion '" .. args[2] .. "' borrada."
    elseif sub == "asignar" then
        local n, jugador = tonumber(args[2]), args[3]
        if not n or not jugador then return false, "Uso: /hotel asignar <n> <jugador>" end
        if n == PISO_COMUN or n < 1 or n > NUM_PISOS then
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
                local amigos = {}
                for a in pairs(p.amigos) do amigos[#amigos + 1] = a end
                l[#l + 1] = ("Piso %d: %s%s"):format(n, p.dueno,
                    #amigos > 0 and (" (amigos: " .. table.concat(amigos, ", ") .. ")") or "")
            end
        end
        local ex = {}
        for nombre, c in pairs(cfg.excluidas) do ex[#ex + 1] = nombre .. " " .. fmt_caja(c) end
        if #ex > 0 then l[#l + 1] = "Excluidas: " .. table.concat(ex, "; ") end
        return true, #l > 0 and table.concat(l, "\n") or "Ningun piso asignado."
    end
    return nil
end

local function cmd_jugador(name, args)
    local sub = args[1]
    if sub == "mio" then
        local n, p = piso_de_jugador(name)
        if not n then return true, "No tienes piso en el Hotel Dreams. Pidelo con /gabo." end
        local amigos = {}
        for a in pairs(p.amigos) do amigos[#amigos + 1] = a end
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
    params = "mio | amigo [quitar] <jugador> | info | (admin) marcar/limites/base/losa/excluir/asignar/liberar/lista",
    description = "Pisos del Hotel Dreams: un piso por jugador",
    func = function(name, param)
        local args = (param or ""):split(" ")
        local ok, msg = cmd_jugador(name, args)
        if ok ~= nil then return ok, msg end
        if es_admin(name) then
            ok, msg = cmd_admin(name, args)
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

minetest.log("warning", "[" .. modname .. "] Loaded successfully")
