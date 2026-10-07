-- Cabina TP: bloque rojo de 1x2 disenado por Gaspi (sobrino del admin).
--
-- Dos nodos, como las puertas de VoxeLibre: "cabina" (abajo, el item) y
-- "cabina_arriba" (se crea sola). Asi cada mitad usa su textura de 16x16; un
-- nodebox de 2 de alto repetiria el dibujo dos veces en cada cara.
-- Texturas: tools/generate_textures.py.
--
-- Reglas:
--   * Solo el admin (priv server) coloca y quita cabinas (/cabina, /cabina quitar).
--     Nadie las rompe a golpes, ni pistones ni explosiones.
--   * Al colocarla, el admin le pone nombre y queda registrada como destino
--     "[TP] <nombre>"; se llega parado frente a la puerta, mirando la cabina.
--   * Clic derecho (en cualquiera de las dos mitades) abre el menu de destinos.

local modname = minetest.get_current_modname()
local F = minetest.formspec_escape

local CABINA = modname .. ":cabina"
local ARRIBA = modname .. ":cabina_arriba"
local FORM_NOMBRE = modname .. ":nombre"

local function tex(nombre)
    return modname .. "_" .. nombre .. ".png"
end

local function is_admin(name)
    return minetest.check_player_privs(name, {server = true})
end

-- El pedestal del viejo valdivia_teleporter (mod eliminado 2026-10-07) quedaba
-- como nodo desconocido si alguno sobrevivia en el mapa.
minetest.register_alias("valdivia_teleporter:pad", "air")

local sounds = mcl_sounds and mcl_sounds.node_sound_wood_defaults
    and mcl_sounds.node_sound_wood_defaults() or nil

-- Id de destino seguro para nombres de campo: sin "-" ni ",".
local function cabina_id(pos)
    local id = ("cabina_%d_%d_%d"):format(pos.x, pos.y, pos.z):gsub("-", "m")
    return id
end

-- Punto de llegada: la celda frente a la puerta, mirando hacia la cabina.
-- facedir_to_dir apunta hacia la cara de ATRAS; el frente (tile -Z) es el opuesto.
local function llegada(pos, param2)
    local atras = minetest.facedir_to_dir(param2 % 32)
    local dest = {x = pos.x - atras.x, y = pos.y - 0.5, z = pos.z - atras.z}
    return dest, minetest.dir_to_yaw(atras)
end

local function registrar(pos, nombre)
    local node = minetest.get_node(pos)
    local dest, yaw = llegada(pos, node.param2)
    local meta = minetest.get_meta(pos)
    meta:set_string("nombre", nombre)
    meta:set_string("infotext", "Cabina TP: " .. nombre .. "\n(clic derecho para viajar)")
    valdivia_cabina.set_lugar(cabina_id(pos), "Cabina " .. nombre, dest,
        {yaw = yaw, cabina = minetest.pos_to_string(pos)})
end

local function contar_cabinas()
    local n = 0
    for _, l in ipairs(valdivia_cabina.get_lugares()) do
        if l.cabina then n = n + 1 end
    end
    return n
end

local function abrir_menu(pos, clicker)
    if not clicker or not clicker:is_player() then return end
    local nombre = minetest.get_meta(pos):get_string("nombre")
    valdivia_cabina.show_menu(clicker:get_player_name(), {
        titulo = "Cabina TP" .. (nombre ~= "" and (" " .. nombre) or "") .. ": ¿a donde vamos?",
    })
end

-- ---------------------------------------------------------------------------
-- Nombre al colocar
-- ---------------------------------------------------------------------------
local nombrando = {}  -- admin -> pos de la cabina recien puesta

local function pedir_nombre(name, pos, actual)
    nombrando[name] = pos
    minetest.show_formspec(name, FORM_NOMBRE, table.concat({
        "formspec_version[4]",
        "size[8,3.6]",
        "label[0.5,0.6;", F("Nombre de esta cabina (ej: Costanera, Isla Teja):"), "]",
        "field[0.5,1.1;7,0.8;nombre;;", F(actual), "]",
        "field_close_on_enter[nombre;true]",
        "button_exit[0.5,2.3;7,0.8;ok;", F("Guardar"), "]",
    }))
end

minetest.register_on_player_receive_fields(function(player, formname, fields)
    if formname ~= FORM_NOMBRE then return end
    local name = player:get_player_name()
    local pos = nombrando[name]
    if not pos or not is_admin(name) then return true end
    local nombre = (fields.nombre or ""):gsub("^%s+", ""):gsub("%s+$", "")
    if (fields.ok or fields.key_enter_field) and nombre ~= ""
            and minetest.get_node(pos).name == CABINA then
        nombre = nombre:sub(1, 40)
        registrar(pos, nombre)
        minetest.chat_send_player(name, "Cabina \"" .. nombre .. "\" lista: ya aparece en el menu.")
    end
    if fields.quit then nombrando[name] = nil end
    return true
end)

-- ---------------------------------------------------------------------------
-- Nodos
-- ---------------------------------------------------------------------------
local comun = {
    drawtype = "nodebox",
    paramtype = "light",
    paramtype2 = "facedir",
    is_ground_content = false,
    sunlight_propagates = false,
    diggable = false,
    drop = "",
    sounds = sounds,
    on_blast = function() end,
    _mcl_hardness = -1,
    _mcl_blast_resistance = 3600000,
}

local function def(extra)
    local d = table.copy(comun)
    for k, v in pairs(extra) do d[k] = v end
    return d
end

minetest.register_node(CABINA, def({
    description = "Cabina TP (diseno de Gaspi)",
    -- +Y, -Y, +X, -X, +Z (atras), -Z (frente)
    tiles = {tex("techo"), tex("base"), tex("lado_abajo"), tex("lado_abajo"),
        tex("lado_abajo"), tex("frente_abajo")},
    inventory_image = "[combine:16x32:0,0=" .. tex("frente_arriba") ..
        ":0,16=" .. tex("frente_abajo"),
    wield_image = "[combine:16x32:0,0=" .. tex("frente_arriba") ..
        ":0,16=" .. tex("frente_abajo"),
    node_box = {type = "fixed", fixed = {
        {-0.5, -0.5, -0.5, 0.5, -0.375, 0.5},            -- zocalo
        {-0.4375, -0.375, -0.4375, 0.4375, 0.5, 0.4375}, -- cuerpo
    }},
    groups = {not_in_creative_inventory = 1, unmovable_by_piston = 1},
    on_place = function(itemstack, placer, pointed_thing)
        local name = placer and placer:get_player_name() or ""
        if not is_admin(name) then
            minetest.chat_send_player(name, "Solo el admin puede colocar cabinas TP.")
            return itemstack
        end
        return minetest.item_place(itemstack, placer, pointed_thing)
    end,
    after_place_node = function(pos, placer)
        local name = placer:get_player_name()
        local arriba = {x = pos.x, y = pos.y + 1, z = pos.z}
        local def_arriba = minetest.registered_nodes[minetest.get_node(arriba).name]
        if not def_arriba or not def_arriba.buildable_to then
            minetest.remove_node(pos)
            minetest.chat_send_player(name, "No cabe: la cabina necesita 2 bloques de alto libres.")
            return true  -- no gasta el item
        end
        local param2 = minetest.get_node(pos).param2
        minetest.set_node(arriba, {name = ARRIBA, param2 = param2})
        local dest = llegada(pos, param2)
        local frente = minetest.registered_nodes[minetest.get_node(vector.round(
            {x = dest.x, y = pos.y, z = dest.z})).name]
        if frente and frente.walkable then
            minetest.chat_send_player(name, "Ojo: el frente de la puerta esta tapado; " ..
                "los viajeros llegaran ahi.")
        end
        -- Nombre provisorio ("Cabina 3") hasta que el admin escriba uno.
        registrar(pos, tostring(contar_cabinas() + 1))
        pedir_nombre(name, pos, "")
        return false
    end,
    on_destruct = function(pos)
        local arriba = {x = pos.x, y = pos.y + 1, z = pos.z}
        if minetest.get_node(arriba).name == ARRIBA then
            minetest.remove_node(arriba)
        end
        valdivia_cabina.remove_lugar(cabina_id(pos))
    end,
    on_rightclick = function(pos, node, clicker)
        abrir_menu(pos, clicker)
    end,
}))

minetest.register_node(ARRIBA, def({
    description = "Cabina TP (parte de arriba)",
    tiles = {tex("techo"), tex("base"), tex("lado_arriba"), tex("lado_arriba"),
        tex("lado_arriba"), tex("frente_arriba")},
    node_box = {type = "fixed", fixed = {
        {-0.4375, -0.5, -0.4375, 0.4375, 0.25, 0.4375}, -- cuerpo + letrero
        {-0.5, 0.25, -0.5, 0.5, 0.5, 0.5},              -- cornisa
    }},
    light_source = 5,  -- brilla un poco: se encuentra de noche
    groups = {not_in_creative_inventory = 1, unmovable_by_piston = 1},
    on_rightclick = function(pos, node, clicker)
        abrir_menu({x = pos.x, y = pos.y - 1, z = pos.z}, clicker)
    end,
}))

-- ---------------------------------------------------------------------------
-- Comando del admin
-- ---------------------------------------------------------------------------
local function cabina_cercana(pos, radio)
    local mejor, mejor_d
    local p1 = vector.subtract(pos, radio)
    local p2 = vector.add(pos, radio)
    for _, p in ipairs(minetest.find_nodes_in_area(p1, p2, {CABINA})) do
        local d = vector.distance(pos, p)
        if not mejor_d or d < mejor_d then mejor, mejor_d = p, d end
    end
    return mejor
end

minetest.register_chatcommand("cabina", {
    params = "[quitar | nombre <nuevo nombre>]",
    description = "Cabinas TP (admin): sin argumento te da una cabina; 'quitar' borra la " ..
        "mas cercana (5 bloques); 'nombre' renombra la mas cercana",
    privs = {server = true},
    func = function(name, param)
        local player = minetest.get_player_by_name(name)
        if not player then return false, "Jugador no encontrado" end
        local sub, resto = (param or ""):match("^%s*(%S*)%s*(.-)%s*$")
        if sub == "" then
            local left = player:get_inventory():add_item("main", ItemStack(CABINA))
            if not left:is_empty() then return false, "Inventario lleno." end
            return true, "Cabina TP en tu inventario. Colocala mirando hacia donde " ..
                "quieres la puerta (necesita 2 de alto)."
        end
        local pos = cabina_cercana(vector.round(player:get_pos()), 5)
        if not pos then return false, "No hay ninguna cabina a menos de 5 bloques." end
        if sub == "quitar" then
            local nombre = minetest.get_meta(pos):get_string("nombre")
            minetest.remove_node(pos)
            return true, "Cabina \"" .. nombre .. "\" quitada (y sacada del menu)."
        elseif sub == "nombre" then
            if resto == "" then
                pedir_nombre(name, pos, minetest.get_meta(pos):get_string("nombre"))
                return true
            end
            registrar(pos, resto:sub(1, 40))
            return true, "Cabina renombrada a \"" .. resto:sub(1, 40) .. "\"."
        end
        return false, "Uso: /cabina [quitar | nombre <nuevo nombre>]"
    end,
})
