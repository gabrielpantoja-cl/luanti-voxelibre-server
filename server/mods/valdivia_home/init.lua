-- valdivia_home: "set home / go home" con interfaz para Valdivia (30001).
--
-- Agrega una pestana "Mi casa" al inventario de supervivencia de VoxeLibre
-- (mcl_inventory.register_survival_inventory_tab, la misma API de la pestana
-- "Main Inventory") con tres botones: Ir a mi casa, Ir al spawn y Fijar mi
-- casa aqui. Los mismos viajes existen como comandos (/home, /spawn, /sethome)
-- porque el inventario creativo (admin) no muestra pestanas de supervivencia.
--
-- Reglas (supervivencia con mobs de noche):
--   * Antes de viajar hay que quedarse quieto WARMUP s; moverse o recibir dano
--     cancela el viaje. Asi no sirve para escapar al instante de una pelea.
--   * Entre viajes hay COOLDOWN s.
--   * No se puede fijar la casa dentro del area protegida de OTRO jugador
--     (protector): nadie puede "instalarse" en la casa de otro.
--   * Los jugadores con priv server (admin) no tienen espera ni pausa.
-- La casa se guarda en la metadata del jugador: sobrevive a reinicios.

local modname = minetest.get_current_modname()

local WARMUP = 3        -- segundos quieto antes de viajar
local COOLDOWN = 30     -- segundos entre viajes
local MOVE_TOL = 0.8    -- nodos que se puede mover durante la espera
local META_HOME = modname .. ":pos"

local TAB_ICON = "mcl_beds:bed_red_bottom"
local ICON_HOME = "mcl_beds:bed_red_bottom"
local ICON_SET = "mcl_maps:empty_map"
-- mcl_compass:compass es un alias; item_image_button necesita el nombre real.
local ICON_SPAWN = minetest.registered_aliases["mcl_compass:compass"] or "mcl_compass:compass"

local C_OK = "#7CFC7C"
local C_INFO = "#8EC7FF"
local C_WARN = "#FFB347"
local C_LABEL = "#313131"  -- mismo gris oscuro que las etiquetas de mcl_inventory

local F = minetest.formspec_escape

local pending = {}  -- name -> {dest, label, start, hp, left}
local last_tp = {}  -- name -> os.time() del ultimo viaje

local function say(name, color, msg)
    minetest.chat_send_player(name, minetest.colorize(color, msg))
end

local function is_admin(name)
    return minetest.check_player_privs(name, {server = true})
end

local function get_home(player)
    local s = player:get_meta():get_string(META_HOME)
    return s ~= "" and minetest.string_to_pos(s) or nil
end

local function get_spawn()
    return minetest.string_to_pos(minetest.settings:get("static_spawnpoint") or "")
end

local function cooldown_left(name)
    if is_admin(name) or not last_tp[name] then return 0 end
    return math.max(0, COOLDOWN - (os.time() - last_tp[name]))
end

local function refresh_inventory(player)
    if mcl_inventory and mcl_inventory.update_inventory then
        mcl_inventory.update_inventory(player)
    end
end

-- ---------------------------------------------------------------------------
-- Viajes
-- ---------------------------------------------------------------------------

local function do_teleport(player, dest, label)
    local name = player:get_player_name()
    player:set_pos(dest)
    last_tp[name] = os.time()
    say(name, C_OK, "Llegaste a " .. label .. ".")
    minetest.log("action", "[" .. modname .. "] " .. name .. " -> " .. label ..
        " " .. minetest.pos_to_string(vector.round(dest)))
end

local function request_teleport(player, dest, label)
    local name = player:get_player_name()
    if not dest then return end
    local left = cooldown_left(name)
    if left > 0 then
        say(name, C_WARN, "Espera " .. left .. " s antes de volver a viajar.")
        return
    end
    if is_admin(name) then
        do_teleport(player, dest, label)
        return
    end
    pending[name] = {
        dest = dest,
        label = label,
        start = player:get_pos(),
        hp = player:get_hp(),
        left = WARMUP,
    }
    say(name, C_INFO, "Viajando a " .. label .. " en " .. WARMUP ..
        " s... quedate quieto.")
end

local function go_home(player)
    local home = get_home(player)
    if not home then
        say(player:get_player_name(), C_WARN,
            "Todavia no tienes casa. Usa \"Fijar mi casa aqui\" (o /sethome).")
        return
    end
    request_teleport(player, home, "tu casa")
end

local function go_spawn(player)
    local spawn = get_spawn()
    if not spawn then
        say(player:get_player_name(), C_WARN, "El servidor no tiene un spawn fijo.")
        return
    end
    request_teleport(player, spawn, "el spawn (Plaza Chile)")
end

local function set_home(player)
    local name = player:get_player_name()
    local pos = vector.round(player:get_pos())
    if minetest.is_protected(pos, name) then
        say(name, C_WARN, "No puedes fijar tu casa aqui: esta zona esta protegida por otra persona.")
        return
    end
    player:get_meta():set_string(META_HOME, minetest.pos_to_string(pos))
    say(name, C_OK, "Tu casa quedo guardada en " .. minetest.pos_to_string(pos) .. ".")
    refresh_inventory(player)
end

minetest.register_globalstep(function(dtime)
    for name, p in pairs(pending) do
        local player = minetest.get_player_by_name(name)
        if not player then
            pending[name] = nil
        else
            local pos = player:get_pos()
            local moved = math.abs(pos.x - p.start.x) > MOVE_TOL or
                math.abs(pos.y - p.start.y) > MOVE_TOL or
                math.abs(pos.z - p.start.z) > MOVE_TOL
            if moved then
                pending[name] = nil
                say(name, C_WARN, "Viaje cancelado: te moviste.")
            elseif player:get_hp() < p.hp then
                pending[name] = nil
                say(name, C_WARN, "Viaje cancelado: recibiste dano.")
            else
                p.left = p.left - dtime
                if p.left <= 0 then
                    pending[name] = nil
                    do_teleport(player, p.dest, p.label)
                end
            end
        end
    end
end)

minetest.register_on_leaveplayer(function(player)
    local name = player:get_player_name()
    pending[name] = nil
    last_tp[name] = nil
end)

-- ---------------------------------------------------------------------------
-- Pestana "Mi casa" del inventario de supervivencia
-- ---------------------------------------------------------------------------

local function label(x, y, text)
    return "label[" .. x .. "," .. y .. ";" .. F(minetest.colorize(C_LABEL, text)) .. "]"
end

local function build_tab(player)
    local home = get_home(player)
    local home_txt = home and ("Tu casa: " .. minetest.pos_to_string(home))
        or "Todavia no fijas tu casa."
    return table.concat({
        label(0.6, 0.6, "Ir a mi casa"),
        "item_image_button[0.6,0.9;1.2,1.2;", ICON_HOME, ";valdivia_home_go;]",
        "tooltip[valdivia_home_go;", F("Viajar a tu casa (quedate quieto " .. WARMUP .. " s)"), "]",

        label(5.6, 0.6, "Ir al spawn (Plaza Chile)"),
        "item_image_button[5.6,0.9;1.2,1.2;", ICON_SPAWN, ";valdivia_home_spawn;]",
        "tooltip[valdivia_home_spawn;", F("Viajar al spawn de la ciudad"), "]",

        label(0.6, 2.75, "Fijar mi casa aqui"),
        "item_image_button[0.6,3.05;1.2,1.2;", ICON_SET, ";valdivia_home_set;]",
        "tooltip[valdivia_home_set;", F("Guardar este lugar como tu casa"), "]",

        label(5.6, 3.3, home_txt),
        label(5.6, 3.8, "Espera " .. WARMUP .. " s quieto y " .. COOLDOWN .. " s entre viajes."),
    })
end

local function handle_tab(player, fields)
    if fields.valdivia_home_go then
        go_home(player)
    elseif fields.valdivia_home_spawn then
        go_spawn(player)
    elseif fields.valdivia_home_set then
        set_home(player)
    end
end

if mcl_inventory and mcl_inventory.register_survival_inventory_tab then
    mcl_inventory.register_survival_inventory_tab({
        id = "valdivia_home",
        description = "Mi casa",
        item_icon = TAB_ICON,
        show_inventory = true,
        build = build_tab,
        handle = handle_tab,
    })
else
    minetest.log("warning", "[" .. modname .. "] mcl_inventory sin API de pestanas; solo comandos")
end

-- ---------------------------------------------------------------------------
-- Comandos (respaldo y para el admin en creativo)
-- ---------------------------------------------------------------------------

local function with_player(fn)
    return function(name)
        local player = minetest.get_player_by_name(name)
        if not player then return false, "Jugador no encontrado" end
        fn(player)
        return true
    end
end

minetest.register_chatcommand("sethome", {
    description = "Guarda tu posicion actual como tu casa",
    privs = {interact = true},
    func = with_player(set_home),
})

minetest.register_chatcommand("home", {
    description = "Viaja a tu casa (quedate quieto " .. WARMUP .. " s)",
    privs = {interact = true},
    func = with_player(go_home),
})

minetest.register_chatcommand("spawn", {
    description = "Viaja al spawn de la ciudad (Plaza Chile)",
    privs = {interact = true},
    func = with_player(go_spawn),
})

minetest.log("action", "[" .. modname .. "] Loaded successfully")
