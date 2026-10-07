-- ============================================================================
-- valdivia_spawn_npc
-- ============================================================================
-- NPC guia estatico del spawn de Valdivia (puerto 30001).
-- Al hacerle click derecho abre un panel con: reglas del servidor,
-- teletransporte a lugares de la ciudad y el aviso de /gabo para pedir ayuda.
-- Ademas: mensaje de bienvenida al entrar.
-- Apropiado para ninos 7+. Idioma: espanol.
--
-- 2026-09-10: se quito el QR/enlace de Discord (nadie lo usaba). Discord queda
-- solo para el admin (log de conexiones); los jugadores piden ayuda con /gabo
-- (mod wetlands_contact), que llega directo al admin por Telegram.
--
-- 2026-10-07: los destinos, el menu "Lugares" y el viaje viven en el nucleo
-- compartido valdivia_cabina (lo usan tambien las cabinas TP y "Mi casa").
-- Este mod solo abre ese menu; /lugar_guardar y /lugares se movieron alla.

local modname = minetest.get_current_modname()

-- ============================================================================
-- 1. CONSTANTES
-- ============================================================================
local NPC_HP         = 65535
local ANCHOR_TOL     = 0.6   -- distancia (nodos) antes de re-anclar al guia
local FACE_RANGE     = 12    -- distancia (nodos) para girar a mirar al jugador

-- NPCs guia con MISMO comportamiento pero SKINS distintos, uno por lugar. Para
-- agregar otro guia: crea el skin (tools/convert_skin.py) y anade una entrada
-- aqui. El del spawn conserva el nombre de entidad ":guia" para no romper la
-- instancia ya plantada en produccion.
local GUIAS = {
    spawn          = { entity = modname .. ":guia",                 skin = "valdivia_guia_skin.png",                 label = "Guia (spawn)" },
    parque         = { entity = modname .. ":guia_parque",          skin = "valdivia_guia_parque_skin.png",          label = "Guia (Parque Catrico)" },
    santa_elena    = { entity = modname .. ":guia_santa_elena",     skin = "valdivia_guia_santa_elena_skin.png",     label = "Guia (Santa Elena)" },
    huachocopihue  = { entity = modname .. ":guia_huachocopihue",   skin = "valdivia_guia_huachocopihue_skin.png",   label = "Guia (Huachocopihue)" },
}
-- Set de nombres de entidad para deteccion de duplicados.
local GUIA_ENTITIES = {}
for _, g in pairs(GUIAS) do GUIA_ENTITIES[g.entity] = true end

local FORM_GUIA    = modname .. ":guia"

local C_TITULO = "#FFD966"
local C_INFO   = "#8EC7FF"
local C_OK     = "#7CFC7C"

-- ============================================================================
-- 3. TEXTOS (chat)
-- ============================================================================
local function enviar_reglas(name)
    local reglas = {
        minetest.colorize(C_TITULO, "== Reglas de Valdivia =="),
        "1. Respeta a las demas personas: nada de insultos ni bromas pesadas.",
        "2. No destruyas ni rayes las construcciones de otros (anti-grief).",
        "3. Construye, explora y comparte: la ciudad es de todos.",
        "4. Sin groserias en el chat. Es un espacio para ninos y familias.",
        "5. Ante dudas o problemas, escribele al admin con /gabo <mensaje>.",
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
    local fs = "formspec_version[4]" ..
        "size[8.8,5.9]" ..
        "label[0.5,0.6;" .. minetest.colorize(C_TITULO, F("Guia de Valdivia")) .. "]" ..
        "label[0.5,1.2;" .. F("Bienvenid@ a la ciudad. Yo te oriento:") .. "]" ..
        "button[0.5,1.8;7.8,0.8;btn_reglas;" .. F("Reglas del servidor") .. "]" ..
        "button[0.5,2.8;7.8,0.8;btn_lugares;" .. F("Lugares de Valdivia") .. "]" ..
        "label[0.5,4.0;" .. minetest.colorize(C_INFO,
            F("¿Necesitas ayuda? Escribe /gabo <mensaje>")) .. "]" ..
        "button_exit[0.5,4.6;7.8,0.8;btn_cerrar;" .. F("Cerrar") .. "]"
    minetest.show_formspec(name, FORM_GUIA, fs)
end

local function show_lugares(name)
    if valdivia_cabina then
        valdivia_cabina.show_menu(name, {on_back = show_guia})
    else
        minetest.chat_send_player(name, "Los viajes no estan disponibles ahora.")
    end
end

minetest.register_on_player_receive_fields(function(player, formname, fields)
    if formname ~= FORM_GUIA or not player or not player:is_player() then return end
    local name = player:get_player_name()
    if fields.btn_reglas then
        enviar_reglas(name)
    elseif fields.btn_lugares then
        show_lugares(name)
    end
    return true
end)

-- ============================================================================
-- 5. LOS NPC (mcl_mobs, estatico e inmortal)
-- ============================================================================
-- Jugador conectado mas cercano a pos dentro de `range` (o nil).
local function nearest_player(pos, range)
    local nearest, best = nil, range * range
    for _, p in ipairs(minetest.get_connected_players()) do
        local ppos = p:get_pos()
        if ppos then
            local dx, dy, dz = ppos.x - pos.x, ppos.y - pos.y, ppos.z - pos.z
            local d = dx * dx + dy * dy + dz * dz
            if d < best then best = d; nearest = p end
        end
    end
    return nearest
end

-- Mismo comportamiento para todos los guias; solo cambia el skin. Comparten
-- formspec, inmortalidad, anti-grief y el giro hacia el jugador mas cercano.
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

            local pos = self.object:get_pos()
            if not pos then return end

            -- Girar para mirar al jugador mas cercano (que no lo encuentren de
            -- espalda). Giro suave; misma convencion de yaw que wetlands_npcs
            -- para este modelo (mcl_armor_character.b3d).
            local player = nearest_player(pos, FACE_RANGE)
            if player then
                local ppos = player:get_pos()
                local dir = vector.subtract(ppos, pos)
                local target_yaw = math.atan2(dir.z, dir.x) - math.pi / 2
                local current_yaw = self.object:get_yaw() or 0
                local diff = target_yaw - current_yaw
                while diff > math.pi do diff = diff - 2 * math.pi end
                while diff < -math.pi do diff = diff + 2 * math.pi end
                self.object:set_yaw(current_yaw + diff * 0.3)
            end

            -- Re-anclar si se movio (empujones, agua, etc.).
            self._anchor_check = (self._anchor_check or 0) + dtime
            if self._anchor_check > 1 then
                self._anchor_check = 0
                if self._anchor and vector.distance(pos, self._anchor) > ANCHOR_TOL then
                    self.object:set_pos(self._anchor)
                    self.object:set_velocity({x = 0, y = 0, z = 0})
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
    for _, g in pairs(GUIAS) do
        register_guia(g.entity, g.skin)
    end
else
    minetest.log("error", "[" .. modname .. "] mcl_mobs no disponible; los NPC guia no se registraron.")
end

-- ============================================================================
-- 6. COMANDOS
-- ============================================================================
-- Sin /discord en Valdivia: server_rules registra uno (con el Discord de
-- Wetlands) y este mod carga despues (optional_depends), asi que se quita aqui.
if minetest.registered_chatcommands["discord"] then
    minetest.unregister_chatcommand("discord")
end

minetest.register_chatcommand("spawn_guia", {
    params = "[spawn|parque|santa_elena|huachocopihue]",
    description = "Coloca un NPC guia en tu posicion (admin). Sin arg = spawn; " ..
        "el resto usa ese skin. Elimina guias duplicados cercanos.",
    privs = {server = true},
    func = function(name, param)
        local player = minetest.get_player_by_name(name)
        if not player then return false, "Jugador no encontrado" end
        local tipo = (param or ""):lower():match("%S+") or "spawn"
        local g = GUIAS[tipo]
        if not g then
            local opts = {}
            for k in pairs(GUIAS) do table.insert(opts, k) end
            table.sort(opts)
            return false, "Tipo invalido. Opciones: " .. table.concat(opts, ", ")
        end
        local pos = player:get_pos()
        -- Quitar cualquier guia (de cualquier tipo) en radio 6 para no duplicar.
        local quitados = 0
        for _, obj in ipairs(minetest.get_objects_inside_radius(pos, 6)) do
            local le = obj:get_luaentity()
            if le and le.name and GUIA_ENTITIES[le.name] then
                obj:remove()
                quitados = quitados + 1
            end
        end
        pos.y = pos.y + 0.5
        local obj = minetest.add_entity(pos, g.entity)
        if not obj then return false, "Error al colocar el guia" end
        return true, g.label .. " colocado en " .. minetest.pos_to_string(vector.round(pos)) ..
            (quitados > 0 and (" (se quitaron " .. quitados .. " duplicados)") or "")
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
        -- descriptiva. Sin Discord ni "habla con el guia". El MOTD queda vacio y el aviso "modo pacifico" de mcl_mobs se
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
    -- OJO: la tabla es PLURAL (registered_on_joinplayers) aunque la funcion de
    -- registro sea singular (register_on_joinplayer) -- convencion de Luanti.
    local cbs = minetest.registered_on_joinplayers
    if type(cbs) ~= "table" then return end
    -- Luanti guarda el origen de cada callback en callback_origins[fn].mod.
    -- mcl_mobs registra UN solo on_joinplayer (el aviso de modo pacifico), asi
    -- que basta con quitar el que provenga del mod "mcl_mobs".
    local origins = minetest.callback_origins or {}
    for i = #cbs, 1, -1 do
        local fn = cbs[i]
        local origin = origins[fn]
        local from_mcl_mobs = origin and origin.mod == "mcl_mobs"
        if not from_mcl_mobs then  -- respaldo por si callback_origins no estuviera
            local ok, info = pcall(debug.getinfo, fn, "S")
            from_mcl_mobs = ok and info and info.source
                and info.source:find("mcl_mobs") and info.source:find("api")
        end
        if from_mcl_mobs then
            table.remove(cbs, i)
            minetest.log("action", "[" .. modname ..
                "] Aviso 'modo pacifico' de mcl_mobs silenciado")
        end
    end
end)

minetest.log("action", "[" .. modname .. "] Loaded successfully")
