-- ============================================================================
-- valdivia_spawn_npc
-- ============================================================================
-- NPC guia estatico del spawn de Valdivia (puerto 30001).
-- Al hacerle click derecho abre un panel con: enlace de Discord (copiable),
-- reglas del servidor y teletransporte a lugares de la ciudad.
-- Ademas: mensaje de bienvenida al entrar y comando /discord de respaldo.
-- Apropiado para ninos 7+. Idioma: espanol.

local modname = minetest.get_current_modname()

-- ============================================================================
-- 1. CONSTANTES
-- ============================================================================
local DISCORD_INVITE = "https://discord.gg/Y3vfy2JnX"
local DISCORD_QR     = "valdivia_guia_discord_qr.png"  -- textura del QR (tools/generate_discord_qr.py)
local NPC_HP         = 65535
local ANCHOR_TOL     = 0.6   -- distancia (nodos) antes de re-anclar al guia

-- Dos NPCs guia con MISMO comportamiento pero SKINS distintos: uno para el
-- spawn (Plaza) y otro para el Parque Catrico. El del spawn conserva el nombre
-- de entidad ":guia" para no romper la instancia ya plantada en produccion.
local NPC_ENTITY        = modname .. ":guia"          -- guia del spawn
local NPC_ENTITY_PARQUE = modname .. ":guia_parque"   -- guia del Parque Catrico
local GUIA_ENTITIES = { [NPC_ENTITY] = true, [NPC_ENTITY_PARQUE] = true }

local FORM_GUIA    = modname .. ":guia"
local FORM_LUGARES = modname .. ":lugares"

local C_TITULO = "#FFD966"
local C_INFO   = "#8EC7FF"
local C_OK     = "#7CFC7C"

-- Lugares por defecto (Plaza + Parque Catrico). El menu de Lugares
-- oculta automaticamente el destino mas cercano al jugador (ver HIDE_RADIUS),
-- asi que un mismo NPC parado en la Plaza NO ofrece "ir a la Plaza", y uno en
-- el Parque Catrico ofrece "volver a la Plaza". Bidireccional con una sola lista.
-- El admin puede agregar mas destinos en vivo con /lugar_guardar (persisten en
-- valdivia_lugares.json).
local DEFAULT_LUGARES = {
    {id = "plaza",   nombre = "Plaza de la Republica (spawn)", pos = {x = 3766,   y = -4,    z = -3249}},
    {id = "catrico", nombre = "Parque Catrico",               pos = {x = 5025.5, y = -17.5, z = -7028.5}},
}

-- Radio (nodos) para ocultar en el menu el destino donde el jugador ya esta.
local HIDE_RADIUS = 20

-- ============================================================================
-- 2. PERSISTENCIA DE LUGARES (worldpath/valdivia_lugares.json)
-- ============================================================================
local STORAGE_FILE = minetest.get_worldpath() .. "/valdivia_lugares.json"

local lugares = {}  -- lista runtime: { {id, nombre, pos}, ... }

local function index_by_id(id)
    for i, l in ipairs(lugares) do
        if l.id == id then return i end
    end
    return nil
end

local function set_lugar(id, nombre, pos)
    local entry = {id = id, nombre = nombre, pos = pos}
    local i = index_by_id(id)
    if i then
        lugares[i] = entry
    else
        table.insert(lugares, entry)
    end
end

local function persist_lugares()
    local f = io.open(STORAGE_FILE, "w")
    if not f then
        minetest.log("error", "[" .. modname .. "] No se pudo escribir " .. STORAGE_FILE)
        return false
    end
    f:write(minetest.write_json(lugares))
    f:close()
    return true
end

local function load_lugares()
    -- Sembrar defaults primero.
    for _, l in ipairs(DEFAULT_LUGARES) do
        set_lugar(l.id, l.nombre, {x = l.pos.x, y = l.pos.y, z = l.pos.z})
    end
    -- Superponer lo persistido.
    local f = io.open(STORAGE_FILE, "r")
    if not f then return end
    local content = f:read("*a")
    f:close()
    local data = minetest.parse_json(content or "")
    if type(data) == "table" then
        for _, l in ipairs(data) do
            if l.id and l.pos and l.pos.x and l.pos.y and l.pos.z then
                set_lugar(l.id, l.nombre or l.id, {x = l.pos.x, y = l.pos.y, z = l.pos.z})
            end
        end
    end
end

load_lugares()

-- ============================================================================
-- 3. TEXTOS (chat)
-- ============================================================================
local function enviar_discord(name)
    minetest.chat_send_player(name, minetest.colorize(C_TITULO,
        "== Comunidad de Valdivia en Discord =="))
    minetest.chat_send_player(name, "Copia este enlace y unete: " ..
        minetest.colorize(C_INFO, DISCORD_INVITE))
end

local function enviar_reglas(name)
    local reglas = {
        minetest.colorize(C_TITULO, "== Reglas de Valdivia =="),
        "1. Respeta a las demas personas: nada de insultos ni bromas pesadas.",
        "2. No destruyas ni rayes las construcciones de otros (anti-grief).",
        "3. Construye, explora y comparte: la ciudad es de todos.",
        "4. Sin groserias en el chat. Es un espacio para ninos y familias.",
        "5. Ante dudas o problemas, avisa a un admin o pregunta en Discord.",
        minetest.colorize(C_OK, "Gracias por hacer de Valdivia un lugar amable."),
    }
    for _, linea in ipairs(reglas) do
        minetest.chat_send_player(name, linea)
    end
end

-- ============================================================================
-- 4. FORMSPECS
-- ============================================================================
local F = minetest.formspec_escape

local function show_guia(name)
    if not name then return end
    -- Layout de dos columnas: a la izquierda campo/botones; a la derecha el QR
    -- de Discord (se escanea con el telefono y abre la invitacion de un toque,
    -- la via "cliqueable" que Luanti no permite server-side).
    local fs = "formspec_version[4]" ..
        "size[12,7.5]" ..
        "label[0.5,0.6;" .. minetest.colorize(C_TITULO, F("Guia de Valdivia")) .. "]" ..
        "label[0.5,1.2;" .. F("Bienvenid@ a la ciudad. Yo te oriento:") .. "]" ..
        -- Enlace de Discord en un campo copiable (unico widget seleccionable).
        "field[0.5,2.1;7.8,0.8;discord_url;" .. F("Discord (selecciona y copia el enlace)") ..
            ";" .. F(DISCORD_INVITE) .. "]" ..
        "field_close_on_enter[discord_url;false]" ..
        "button[0.5,3.4;7.8,0.8;btn_reglas;" .. F("Reglas del servidor") .. "]" ..
        "button[0.5,4.4;7.8,0.8;btn_lugares;" .. F("Lugares de Valdivia") .. "]" ..
        "button_exit[0.5,5.8;7.8,0.8;btn_cerrar;" .. F("Cerrar") .. "]" ..
        -- Columna derecha: QR de Discord
        "label[8.8,1.2;" .. minetest.colorize(C_INFO, F("Escanea y unete:")) .. "]" ..
        "image[8.8,1.5;2.7,2.7;" .. DISCORD_QR .. "]" ..
        "label[8.8,4.35;" .. F("(Discord con tu telefono)") .. "]"
    minetest.show_formspec(name, FORM_GUIA, fs)
    -- Sin eco al chat: el QR + el campo copiable del panel ya entregan el enlace.
    -- Para pedirlo por chat existe el comando /discord.
end

local function show_lugares(name)
    if not name then return end

    -- Ocultar el destino donde el jugador ya esta (dentro de HIDE_RADIUS),
    -- para no ofrecer "viajar a donde ya estas". Esto hace el sistema
    -- bidireccional: en la Plaza se ofrece el Parque, en el Parque la Plaza.
    local player = minetest.get_player_by_name(name)
    local ppos = player and player:get_pos()
    local visibles = {}
    for _, l in ipairs(lugares) do
        if not (ppos and vector.distance(ppos, l.pos) <= HIDE_RADIUS) then
            table.insert(visibles, l)
        end
    end

    local fs
    if #visibles == 0 then
        -- Nada que ofrecer: o no hay destinos, o el unico es donde ya estas.
        local msg = (#lugares == 0)
            and F("Todavia no hay lugares para viajar.")
            or  F("Ya estas en el unico destino disponible.")
        fs = "formspec_version[4]" ..
            "size[8,3.2]" ..
            "label[0.5,0.7;" .. minetest.colorize(C_TITULO, F("Lugares de Valdivia")) .. "]" ..
            "label[0.5,1.4;" .. msg .. "]" ..
            "label[0.5,1.9;" .. F("Un admin puede agregar mas con /lugar_guardar.") .. "]" ..
            "button[0.5,2.3;7,0.8;btn_volver;" .. F("Volver") .. "]"
    else
        local alto = 1.5 + (#visibles + 1) * 1.0
        fs = "formspec_version[4]" ..
            "size[8," .. alto .. "]" ..
            "label[0.5,0.7;" .. minetest.colorize(C_TITULO, F("Lugares de Valdivia")) .. "]"
        local y = 1.4
        for _, l in ipairs(visibles) do
            fs = fs .. "button[0.5," .. y .. ";7,0.8;tp_" .. l.id .. ";" .. F(l.nombre) .. "]"
            y = y + 1.0
        end
        fs = fs .. "button[0.5," .. y .. ";7,0.8;btn_volver;" .. F("Volver") .. "]"
    end
    minetest.show_formspec(name, FORM_LUGARES, fs)
end

minetest.register_on_player_receive_fields(function(player, formname, fields)
    if not player or not player:is_player() then return end
    local name = player:get_player_name()

    if formname == FORM_GUIA then
        if fields.btn_reglas then
            enviar_reglas(name)
        elseif fields.btn_lugares then
            show_lugares(name)
        end
        return

    elseif formname == FORM_LUGARES then
        if fields.btn_volver then
            show_guia(name)
            return
        end
        for _, l in ipairs(lugares) do
            if fields["tp_" .. l.id] then
                player:set_pos(l.pos)
                minetest.chat_send_player(name, minetest.colorize(C_OK,
                    "Viajando a " .. l.nombre .. "."))
                minetest.log("action", "[" .. modname .. "] " .. name ..
                    " -> " .. l.id .. " " .. minetest.pos_to_string(l.pos))
                return
            end
        end
    end
end)

-- ============================================================================
-- 5. LOS NPC (mcl_mobs, estatico e inmortal)
-- ============================================================================
-- Mismo comportamiento para ambos guias; solo cambia el skin. La entidad del
-- spawn y la del Parque Catrico comparten formspec, inmortalidad y anti-grief.
local function register_guia(entity_name, skin)
    mcl_mobs.register_mob(entity_name, {
        description = "Guia de Valdivia",
        type = "npc",
        spawn_class = "passive",
        passive = true,
        xp_min = 0,
        xp_max = 0,
        initial_properties = {
            hp_min = NPC_HP,
            hp_max = NPC_HP,
        },
        collisionbox = {-0.3, -0.01, -0.3, 0.3, 1.94, 0.3},
        visual = "mesh",
        mesh = "mcl_armor_character.b3d",
        -- 3 capas requeridas por mcl_armor_character.b3d: {skin, armor, cape}
        textures = {{skin, "blank.png", "blank.png"}},
        makes_footstep_sound = false,
        -- Estatico: no camina, no salta, no huye.
        walk_velocity = 0,
        run_velocity = 0,
        walk_chance = 0,
        jump = false,
        fear_height = 0,
        view_range = 8,
        drops = {},
        can_despawn = false,
        armor_groups = {immortal = 1, fleshy = 0},
        animation = {
            stand_start = 0, stand_end = 79, stand_speed = 30,
            walk_start = 168, walk_end = 187, walk_speed = 30,
        },

        on_activate = function(self, staticdata, dtime_s)
            self.object:set_armor_groups({immortal = 1, fleshy = 0})
            self.object:set_hp(NPC_HP)
            -- Ancla: posicion donde se activa, para re-anclarlo si lo empujan.
            self._anchor = self.object:get_pos()
            self._anchor_check = 0
        end,

        do_custom = function(self, dtime)
            -- Mantener inmortalidad.
            if self.object:get_hp() < NPC_HP then
                self.object:set_hp(NPC_HP)
                self.object:set_armor_groups({immortal = 1, fleshy = 0})
            end
            -- Re-anclar si se movio (empujones, agua, etc.).
            self._anchor_check = (self._anchor_check or 0) + dtime
            if self._anchor_check > 1 then
                self._anchor_check = 0
                local pos = self.object:get_pos()
                if pos and self._anchor then
                    if vector.distance(pos, self._anchor) > ANCHOR_TOL then
                        self.object:set_pos(self._anchor)
                        self.object:set_velocity({x = 0, y = 0, z = 0})
                    end
                end
            end
        end,

        on_rightclick = function(self, clicker)
            if not clicker or not clicker:is_player() then return end
            show_guia(clicker:get_player_name())
        end,

        -- Anti-grief: no recibe danio y no se puede matar a golpes.
        do_punch = function(self, puncher, time_from_last_punch, tool_capabilities, dir)
            self.object:set_armor_groups({immortal = 1, fleshy = 0})
            self.object:set_hp(NPC_HP)
            self.health = NPC_HP
            if puncher and puncher:is_player() then
                minetest.chat_send_player(puncher:get_player_name(),
                    minetest.colorize("#FF6B6B",
                    "[Guia] Soy tu amigo, no me pegues. Haz click derecho para hablar conmigo."))
            end
            return false
        end,
    })
end

if minetest.get_modpath("mcl_mobs") and mcl_mobs and mcl_mobs.register_mob then
    register_guia(NPC_ENTITY, "valdivia_guia_skin.png")               -- spawn (Plaza)
    register_guia(NPC_ENTITY_PARQUE, "valdivia_guia_parque_skin.png") -- Parque Catrico
else
    minetest.log("error", "[" .. modname .. "] mcl_mobs no disponible; los NPC guia no se registraron.")
end

-- ============================================================================
-- 6. COMANDOS
-- ============================================================================
minetest.register_chatcommand("discord", {
    description = "Muestra el enlace de la comunidad de Valdivia en Discord",
    func = function(name)
        enviar_discord(name)
        return true
    end,
})

minetest.register_chatcommand("spawn_guia", {
    params = "[parque]",
    description = "Coloca un NPC guia en tu posicion (admin). Sin arg = skin del spawn; " ..
        "'parque' = skin del Parque Catrico. Elimina duplicados cercanos.",
    privs = {server = true},
    func = function(name, param)
        local player = minetest.get_player_by_name(name)
        if not player then return false, "Jugador no encontrado" end
        local tipo = (param or ""):lower():match("%S+")
        local entity = (tipo == "parque") and NPC_ENTITY_PARQUE or NPC_ENTITY
        local pos = player:get_pos()
        -- Quitar cualquier guia (spawn o parque) en radio 6 para no duplicar.
        local quitados = 0
        for _, obj in ipairs(minetest.get_objects_inside_radius(pos, 6)) do
            local le = obj:get_luaentity()
            if le and le.name and GUIA_ENTITIES[le.name] then
                obj:remove()
                quitados = quitados + 1
            end
        end
        pos.y = pos.y + 0.5
        local obj = minetest.add_entity(pos, entity)
        if not obj then return false, "Error al colocar el guia" end
        local etiqueta = (entity == NPC_ENTITY_PARQUE) and "Guia (Parque Catrico)" or "Guia (spawn)"
        return true, etiqueta .. " colocado en " .. minetest.pos_to_string(vector.round(pos)) ..
            (quitados > 0 and (" (se quitaron " .. quitados .. " duplicados)") or "")
    end,
})

minetest.register_chatcommand("lugar_guardar", {
    params = "<id> <nombre visible>",
    description = "Guarda tu posicion actual como destino del menu de Lugares (admin)",
    privs = {server = true},
    func = function(name, param)
        local player = minetest.get_player_by_name(name)
        if not player then return false, "Jugador no encontrado" end
        param = param or ""
        local id, nombre = param:match("^(%S+)%s+(.+)$")
        if not id then
            id = param:match("^(%S+)$")
            nombre = id
        end
        if not id or id == "" then
            return false, "Uso: /lugar_guardar <id> <nombre visible>"
        end
        -- id seguro para nombres de campo del formspec.
        if not id:match("^[%w_]+$") then
            return false, "El id solo puede tener letras, numeros y _"
        end
        local pos = vector.round(player:get_pos())
        set_lugar(id, nombre, {x = pos.x, y = pos.y, z = pos.z})
        persist_lugares()
        return true, "Lugar '" .. id .. "' (" .. nombre .. ") guardado en " ..
            minetest.pos_to_string(pos)
    end,
})

minetest.register_chatcommand("lugares", {
    description = "Lista los destinos del menu de Lugares de Valdivia",
    func = function(name)
        if #lugares == 0 then return true, "No hay lugares registrados." end
        local lines = {"== Lugares de Valdivia =="}
        for _, l in ipairs(lugares) do
            table.insert(lines, "  " .. l.id .. " - " .. l.nombre .. " " ..
                minetest.pos_to_string(l.pos))
        end
        return true, table.concat(lines, "\n")
    end,
})

-- ============================================================================
-- 7. BIENVENIDA AL ENTRAR
-- ============================================================================
minetest.register_on_joinplayer(function(player)
    local name = player:get_player_name()
    minetest.after(3, function()
        if not minetest.get_player_by_name(name) then return end
        -- Bienvenida unica, corta y bonita: titulo en amarillo + una linea
        -- descriptiva. Sin Discord (vive en el panel del Guia) ni "habla con el
        -- guia". El MOTD queda vacio y el aviso "modo pacifico" de mcl_mobs se
        -- des-registra (seccion 8) para no duplicar el saludo ni ensuciar el chat.
        minetest.chat_send_player(name, minetest.colorize(C_TITULO,
            "¡Bienvenid@ a Valdivia [Chile]!") ..
            " Explora la capital de Los Ríos y haz amigos en la ciudad más linda de Chile.")
    end)
end)

-- ============================================================================
-- 8. SILENCIAR EL AVISO "Modo pacifico activo" DE mcl_mobs
-- ============================================================================
-- only_peaceful_mobs=true es necesario (bloquea huevos de mobs hostiles en
-- creativo), pero hace que mcl_mobs imprima "Modo pacifico activo! No apareceran
-- monstruos." al entrar. Es redundante con nuestra bienvenida y no hay setting
-- para apagarlo; ademas el juego es un submodulo (no parcheable por el flujo
-- normal). Solucion limpia desde el mod: quitar ese callback puntual del
-- registro de on_joinplayer, identificandolo por su archivo fuente
-- (mcl_mobs/api.lua tiene UN solo register_on_joinplayer, el del aviso). Se hace
-- tras cargar todos los mods, antes de que entre cualquier jugador.
minetest.register_on_mods_loaded(function()
    local cbs = minetest.registered_on_joinplayer
    if type(cbs) ~= "table" then return end
    for i = #cbs, 1, -1 do
        local ok, info = pcall(debug.getinfo, cbs[i], "S")
        if ok and info and info.source and info.source:find("mcl_mobs/api%.lua") then
            table.remove(cbs, i)
            minetest.log("action", "[" .. modname ..
                "] Aviso 'modo pacifico' de mcl_mobs silenciado")
        end
    end
end)

minetest.log("action", "[" .. modname .. "] Loaded successfully")
