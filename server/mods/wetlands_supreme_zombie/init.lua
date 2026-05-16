-- wetlands_supreme_zombie/init.lua
-- Zombie Supremo: mob jefe gigante para el mundo Infierno (Wetlands 7+)
-- 3 variantes de textura (verde clasico / sangre / sombras)
-- Comandos: /invocar_zombie_supremo1|2|3 (alias: /invocar_zombie_supremo)

local modname = minetest.get_current_modname()

if not minetest.get_modpath("mcl_mobs") then
    minetest.log("warning", "[" .. modname .. "] mcl_mobs no disponible.")
    return
end

-- ---------------------------------------------------------------------------
-- Configuracion del boss
-- ---------------------------------------------------------------------------
local BOSS_HP           = 600
local BOSS_DAMAGE       = 15
local BOSS_WALK         = 2.5
local BOSS_RUN          = 4.5
local BOSS_SPEED_FURY   = 7.0
local BOSS_SCALE        = 3.0
local MAX_DAMAGE_PER_HIT = 50      -- TOPE: ni siquiera /kill creativo lo mata de un hit
local SHOCKWAVE_RADIUS  = 8
local SHOCKWAVE_DELAY   = 3.0
local FURY_HP_TRIGGER   = 400      -- 67 % de 600
local RESURRECTION_HP   = 300
local ROAR_INTERVAL     = 8.0
-- Olas de invocacion GARANTIZADAS por umbral de HP (75%, 50%, 25%)
local SUMMON_WAVE_1_HP  = BOSS_HP * 0.75   -- 450
local SUMMON_WAVE_2_HP  = BOSS_HP * 0.50   -- 300
local SUMMON_WAVE_3_HP  = BOSS_HP * 0.25   -- 150

-- Variantes (sobre el mismo modelo + textura base)
local VARIANTES = {
    {
        id      = "zombie_supremo1",
        nombre  = "Abominación Necrótica",
        cmd     = "invocar_zombie_supremo1",
        skin    = "mobs_mc_zombie.png",                            -- verde clasico
    },
    {
        id      = "zombie_supremo2",
        nombre  = "Mutante de Sangre",
        cmd     = "invocar_zombie_supremo2",
        skin    = "mobs_mc_zombie.png^[colorize:#8b0000:160",       -- rojo sangre
    },
    {
        id      = "zombie_supremo3",
        nombre  = "Coloso Tenebroso",
        cmd     = "invocar_zombie_supremo3",
        skin    = "mobs_mc_zombie.png^[colorize:#1a001a:180",       -- morado sombra
    },
}

-- ---------------------------------------------------------------------------
-- Particulas
-- ---------------------------------------------------------------------------
local function spawn_shockwave_particles(pos)
    minetest.add_particlespawner({
        amount = 60, time = 0.5,
        minpos = vector.subtract(pos, {x=SHOCKWAVE_RADIUS, y=0, z=SHOCKWAVE_RADIUS}),
        maxpos = vector.add(pos, {x=SHOCKWAVE_RADIUS, y=0.5, z=SHOCKWAVE_RADIUS}),
        minvel = {x=-4, y=0.5, z=-4}, maxvel = {x=4, y=1.5, z=4},
        minacc = {x=0, y=-1, z=0},   maxacc = {x=0, y=-1, z=0},
        minexptime = 0.3, maxexptime = 1.0,
        minsize = 3, maxsize = 8,
        texture = "mcl_particles_smoke.png", glow = 4,
    })
end

local function spawn_fury_particles(pos)
    minetest.add_particlespawner({
        amount = 50, time = 3,
        minpos = vector.subtract(pos, {x=1.5, y=0, z=1.5}),
        maxpos = vector.add(pos, {x=1.5, y=3.5, z=1.5}),
        minvel = {x=-2, y=1, z=-2}, maxvel = {x=2, y=4, z=2},
        minacc = {x=0, y=-2, z=0}, maxacc = {x=0, y=-2, z=0},
        minexptime = 0.5, maxexptime = 1.5,
        minsize = 3, maxsize = 6,
        texture = "mcl_particles_flame.png", glow = 12,
    })
end

local function spawn_roar_particles(pos)
    minetest.add_particlespawner({
        amount = 30, time = 0.8,
        minpos = vector.add(pos, {x=-1, y=2, z=-1}),
        maxpos = vector.add(pos, {x=1, y=3, z=1}),
        minvel = {x=-3, y=0.5, z=-3}, maxvel = {x=3, y=2, z=3},
        minacc = {x=0, y=0, z=0}, maxacc = {x=0, y=0, z=0},
        minexptime = 0.4, maxexptime = 1.2,
        minsize = 2, maxsize = 5,
        texture = "mcl_particles_smoke.png", glow = 6,
    })
end

local function spawn_resurrection_particles(pos)
    minetest.add_particlespawner({
        amount = 80, time = 2,
        minpos = vector.subtract(pos, {x=2, y=0, z=2}),
        maxpos = vector.add(pos, {x=2, y=4, z=2}),
        minvel = {x=-4, y=3, z=-4}, maxvel = {x=4, y=6, z=4},
        minacc = {x=0, y=-5, z=0}, maxacc = {x=0, y=-5, z=0},
        minexptime = 0.5, maxexptime = 2.0,
        minsize = 4, maxsize = 10,
        texture = "mcl_particles_smoke.png", glow = 10,
    })
end

-- ---------------------------------------------------------------------------
-- Habilidades
-- ---------------------------------------------------------------------------
local function execute_shockwave(self, pos)
    local objects = minetest.get_objects_inside_radius(pos, SHOCKWAVE_RADIUS)
    local hit_count = 0
    for _, obj in ipairs(objects) do
        if obj:is_player() then
            local ppos = obj:get_pos()
            if ppos then
                local push_dir = vector.subtract(ppos, pos)
                if vector.length(push_dir) < 0.1 then
                    push_dir = {x = 1, y = 0, z = 0}
                end
                push_dir = vector.normalize(push_dir)
                obj:add_velocity({
                    x = push_dir.x * 12,
                    y = 7,
                    z = push_dir.z * 12,
                })
                minetest.chat_send_player(obj:get_player_name(),
                    "[Zombie Supremo] ¡ONDA DE CHOQUE! Te ha lanzado por los aires.")
                hit_count = hit_count + 1
            end
        end
    end
    spawn_shockwave_particles(pos)
    return hit_count
end

local function execute_roar(self, pos, variant_name)
    spawn_roar_particles(pos)
    minetest.sound_play("mobs_mc_zombie_growl", {
        pos = pos, gain = 2.0, max_hear_distance = 32,
    })
    -- Aviso visual a jugadores cercanos
    for _, player in ipairs(minetest.get_connected_players()) do
        local ppos = player:get_pos()
        if ppos and vector.distance(pos, ppos) <= 30 then
            minetest.chat_send_player(player:get_player_name(),
                "[Zombie Supremo] El " .. variant_name .. " RUGE con furia ancestral.")
        end
    end
end

local function summon_zombies(self, pos, wave_label)
    local count = 4   -- 4 esbirros por ola
    local spawned = 0
    for i = 1, count do
        local angle  = (i / count) * (2 * math.pi)
        local offset = {x = math.cos(angle) * 4, y = 1, z = math.sin(angle) * 4}
        local spawn_pos = vector.add(pos, offset)
        local obj = minetest.add_entity(spawn_pos, "mobs_mc:zombie")
        if obj then
            spawned = spawned + 1
            spawn_roar_particles(spawn_pos)
            minetest.log("action", "[" .. modname .. "] Esbirro invocado en " ..
                minetest.pos_to_string(spawn_pos))
        else
            minetest.log("warning", "[" .. modname .. "] FALLO invocar esbirro en " ..
                minetest.pos_to_string(spawn_pos))
        end
    end
    minetest.chat_send_all(
        "[Wetlands] ¡OLA " .. (wave_label or "?") ..
        ": El Zombie Supremo INVOCO " .. spawned .. " esbirros zombi!")
    minetest.sound_play("mobs_mc_zombie_growl", {
        pos = pos, gain = 2.5, max_hear_distance = 40,
    })
end

-- ---------------------------------------------------------------------------
-- Registro de variantes
-- ---------------------------------------------------------------------------
for _, v in ipairs(VARIANTES) do
    local entity_name = modname .. ":" .. v.id

    mcl_mobs.register_mob(entity_name, {
        description = "Zombie Supremo - " .. v.nombre,
        type        = "monster",
        spawn_class = "hostile",

        -- Visual en raiz (mcl_mobs lee desde aqui)
        visual       = "mesh",
        mesh         = "mobs_mc_zombie.b3d",
        visual_size  = {x = BOSS_SCALE, y = BOSS_SCALE, z = BOSS_SCALE},
        -- Textura en formato 2-capas: {armor, skin} (igual que VoxeLibre)
        textures     = {{"mobs_mc_empty.png", v.skin}},
        makes_footstep_sound = true,
        glow         = 3,

        -- Head tracking: la cabeza sigue al jugador cercano
        head_swivel  = "head.control",
        head_eye_height    = 1.55 * BOSS_SCALE,
        head_bone_position = vector.new(0, 6.3, 0),
        curiosity          = 10,
        head_pitch_multiplier = -1,

        -- Colision proporcional al tamano
        collisionbox = {-0.6, -0.01, -0.6, 0.6, 1.89 * BOSS_SCALE, 0.6},

        initial_properties = {
            hp_min = BOSS_HP,
            hp_max = BOSS_HP,
            breath_max = -1,
        },

        xp_min = 50,
        xp_max = 100,
        -- armor en mob def es solo placeholder; el real lo seteamos en on_activate
        armor  = {undead = 100, fleshy = 100},
        damage = BOSS_DAMAGE,
        knock_back = 0,            -- no se deja empujar

        walk_velocity = BOSS_WALK,
        run_velocity  = BOSS_RUN,
        jump_height   = 5,
        view_range    = 32,
        fear_height   = 0,
        pathfinding   = 1,
        floats        = 0,

        passive        = false,
        attack_type    = "dogfight",
        attack_animals = false,
        attack_players = true,
        attack_npcs    = true,
        reach          = 4,
        harmed_by_heal = true,

        -- Inmune a la luz solar (es un boss, no se quema)
        ignited_by_sunlight = false,
        sunlight_damage     = 0,

        -- Animaciones CORRECTAS del modelo mobs_mc_zombie.b3d
        animation = {
            stand_start = 40, stand_end = 49, stand_speed = 2,
            walk_start  = 0,  walk_end  = 39, speed_normal = 25,
            run_start   = 0,  run_end   = 39, speed_run   = 50,
            punch_start = 50, punch_end = 59, punch_speed = 20,
        },

        sounds = {
            random   = "mobs_mc_zombie_growl",
            war_cry  = "mobs_mc_zombie_growl",
            attack   = "mobs_mc_zombie_growl",
            damage   = "mobs_mc_zombie_hurt",
            death    = "mobs_mc_zombie_death",
            distance = 32,
        },

        drops = {
            {name = "mcl_core:emerald",     chance = 1,  min = 3, max = 8},
            {name = "mcl_core:diamond",     chance = 1,  min = 1, max = 3},
            {name = "mcl_books:book",       chance = 1,  min = 1, max = 1},
            {name = "mcl_core:emeraldblock", chance = 3, min = 1, max = 1},
        },

        -- -----------------------------------------------------------------
        -- on_activate: inicializacion
        -- -----------------------------------------------------------------
        on_activate = function(self, staticdata, dtime_s)
            self._resurrection_used = false
            self._resurrecting      = false
            self._shockwave_timer   = 0.0
            self._roar_timer        = 0.0
            self._fury_active       = false
            -- Olas de invocacion (cada una se dispara una sola vez)
            self._summon_wave_1     = false
            self._summon_wave_2     = false
            self._summon_wave_3     = false

            -- IMMORTAL: el damage default de Minetest queda en 0
            -- Nosotros aplicamos el dano manualmente en do_punch con tope
            self.object:set_armor_groups({immortal = 1})

            local pos = self.object:get_pos()
            if pos then
                minetest.chat_send_all(
                    "[Wetlands] ¡El Zombie Supremo (" .. v.nombre ..
                    ") ha despertado en " ..
                    minetest.pos_to_string(vector.round(pos)) ..
                    "! ¡Cuidado, aventureros!")
                minetest.sound_play("mobs_mc_zombie_growl", {
                    pos = pos, gain = 3.0, max_hear_distance = 48,
                })
            end
        end,

        -- -----------------------------------------------------------------
        -- do_punch: modo furia + chance de invocar esbirros + counter-push
        -- -----------------------------------------------------------------
        do_punch = function(self, hitter, time_from_last_punch, tool_capabilities, dir)
            -- Calculo manual de dano (porque armor_groups es immortal)
            local raw_damage = 5
            if tool_capabilities and tool_capabilities.damage_groups then
                raw_damage = tool_capabilities.damage_groups.fleshy
                          or tool_capabilities.damage_groups.knockback
                          or 5
            end

            -- Aplicar 40 % de reduccion de armadura
            local damage = raw_damage * 0.6
            -- TOPE: nunca mas de MAX_DAMAGE_PER_HIT por golpe (anti-instakill)
            damage = math.min(damage, MAX_DAMAGE_PER_HIT)
            damage = math.max(damage, 2)
            damage = math.floor(damage)

            local current_hp = self.object:get_hp()
            local new_hp = math.max(0, current_hp - damage)
            self.object:set_hp(new_hp)

            local pos = self.object:get_pos()

            -- Feedback al atacante
            if hitter and hitter:is_player() and new_hp > 0 then
                minetest.chat_send_player(hitter:get_player_name(),
                    "[Zombie Supremo] -" .. damage .. " HP  (" ..
                    new_hp .. "/" .. BOSS_HP .. ")")
            end

            -- Modo furia al 67 %
            if not self._fury_active and new_hp <= FURY_HP_TRIGGER and new_hp > 0 then
                self._fury_active  = true
                self.walk_velocity = BOSS_SPEED_FURY
                self.run_velocity  = BOSS_SPEED_FURY
                if pos then spawn_fury_particles(pos) end
                minetest.chat_send_all(
                    "[Wetlands] ¡El Zombie Supremo entra en MODO FURIA! ¡Corre!")
            end

            -- Contra-empuje al atacante (cuando esta en furia)
            if self._fury_active and hitter and hitter:is_player() and pos then
                local hpos = hitter:get_pos()
                if hpos then
                    local push = vector.normalize(vector.subtract(hpos, pos))
                    hitter:add_velocity({x = push.x * 6, y = 3, z = push.z * 6})
                end
            end

            -- Decir a mcl_mobs/Minetest que ya manejamos el dano
            return true
        end,

        -- -----------------------------------------------------------------
        -- on_step: resurreccion + shockwave + rugido periodico + summon timer
        -- -----------------------------------------------------------------
        on_step = function(self, dtime)
            self._shockwave_timer = (self._shockwave_timer or 0.0) + dtime
            self._roar_timer      = (self._roar_timer or 0.0) + dtime

            local pos = self.object:get_pos()
            if not pos then return end
            local hp = self.object:get_hp()

            -- OLAS DE INVOCACION GARANTIZADAS (cada una se dispara 1 vez)
            if not self._summon_wave_1 and hp <= SUMMON_WAVE_1_HP then
                self._summon_wave_1 = true
                summon_zombies(self, pos, "1 (75%)")
            elseif not self._summon_wave_2 and hp <= SUMMON_WAVE_2_HP then
                self._summon_wave_2 = true
                summon_zombies(self, pos, "2 (50%)")
            elseif not self._summon_wave_3 and hp <= SUMMON_WAVE_3_HP then
                self._summon_wave_3 = true
                summon_zombies(self, pos, "3 (25%)")
            end

            -- Resurreccion al llegar a 1 HP (una sola vez)
            if hp <= 1 and not self._resurrection_used and not self._resurrecting then
                self._resurrecting = true
                minetest.after(0.05, function()
                    if not self.object or not self.object:get_pos() then return end
                    self.object:set_hp(RESURRECTION_HP)
                    self._resurrection_used = true
                    self._resurrecting      = false
                    self._fury_active       = true
                    self.walk_velocity      = BOSS_SPEED_FURY
                    self.run_velocity       = BOSS_SPEED_FURY
                    self._shockwave_timer   = 0.0
                    local rpos = self.object:get_pos()
                    if rpos then spawn_resurrection_particles(rpos) end
                    minetest.chat_send_all(
                        "[Wetlands] ¡El Zombie Supremo ha RESUCITADO con " ..
                        RESURRECTION_HP .. " HP! ¡Aun no esta derrotado!")
                end)
            end

            -- Onda de choque cuando hay jugadores cerca
            if self._shockwave_timer >= SHOCKWAVE_DELAY then
                for _, player in ipairs(minetest.get_connected_players()) do
                    local ppos = player:get_pos()
                    if ppos and vector.distance(pos, ppos) <= (SHOCKWAVE_RADIUS * 1.8) then
                        self._shockwave_timer = 0.0
                        execute_shockwave(self, pos)
                        break
                    end
                end
            end

            -- Rugido periodico (intimidacion + feedback visual/audio)
            if self._roar_timer >= ROAR_INTERVAL then
                self._roar_timer = 0.0
                local any_close = false
                for _, player in ipairs(minetest.get_connected_players()) do
                    local ppos = player:get_pos()
                    if ppos and vector.distance(pos, ppos) <= 25 then
                        any_close = true
                        break
                    end
                end
                if any_close then execute_roar(self, pos, v.nombre) end
            end

            -- Mantener velocidad de furia
            if self._fury_active and self.walk_velocity ~= BOSS_SPEED_FURY then
                self.walk_velocity = BOSS_SPEED_FURY
                self.run_velocity  = BOSS_SPEED_FURY
            end
        end,

        on_die = function(self, pos)
            minetest.chat_send_all(
                "[Wetlands] ¡El Zombie Supremo (" .. v.nombre ..
                ") ha sido DERROTADO definitivamente! ¡Bien hecho, heroes!")
            if pos then
                spawn_resurrection_particles(pos)
                minetest.sound_play("mobs_mc_zombie_death", {
                    pos = pos, gain = 3.0, max_hear_distance = 48,
                })
            end
        end,
    })

    -- Comando de invocacion
    minetest.register_chatcommand(v.cmd, {
        params      = "",
        description = "Invoca al Zombie Supremo (" .. v.nombre .. ") en tu posicion",
        privs       = {server = true},
        func = function(name, param)
            local player = minetest.get_player_by_name(name)
            if not player then return false, "Jugador no encontrado." end
            local pos = player:get_pos()
            pos.y = pos.y + 1
            local obj = minetest.add_entity(pos, entity_name)
            if obj then
                return true, "¡" .. v.nombre .. " invocado en " ..
                    minetest.pos_to_string(vector.round(pos)) .. "!"
            else
                return false, "Error al invocar al Zombie Supremo."
            end
        end,
    })
end

-- ---------------------------------------------------------------------------
-- Migracion de entidad legacy
-- ---------------------------------------------------------------------------
minetest.register_entity(":" .. modname .. ":zombie_supremo", {
    on_activate = function(self, staticdata, dtime_s)
        local pos = self.object:get_pos()
        self.object:remove()
        if pos then
            minetest.add_entity(pos, modname .. ":zombie_supremo1")
        end
    end,
})

-- ---------------------------------------------------------------------------
-- Alias /invocar_zombie_supremo → variante 1
-- ---------------------------------------------------------------------------
minetest.register_chatcommand("invocar_zombie_supremo", {
    params      = "",
    description = "Invoca al Zombie Supremo (alias de /invocar_zombie_supremo1)",
    privs       = {server = true},
    func = function(name, param)
        local player = minetest.get_player_by_name(name)
        if not player then return false, "Jugador no encontrado." end
        local pos = player:get_pos()
        pos.y = pos.y + 1
        local obj = minetest.add_entity(pos, modname .. ":zombie_supremo1")
        if obj then
            return true, "¡Abominación Necrótica invocada en " ..
                minetest.pos_to_string(vector.round(pos)) .. "!"
        else
            return false, "Error al invocar al Zombie Supremo."
        end
    end,
})

-- ---------------------------------------------------------------------------
-- Spawn egg
-- ---------------------------------------------------------------------------
minetest.register_craftitem(modname .. ":spawn_egg", {
    description = "Huevo de Zombie Supremo",
    inventory_image = "mobs_mc_spawn_egg.png^[colorize:#1a1a2e:180" ..
                      "^mobs_mc_spawn_egg_overlay.png^[colorize:#4a0000:100",
    stack_max = 64,
    groups    = {spawn_egg = 1},

    on_place = function(itemstack, placer, pointed_thing)
        if not placer or not placer:is_player() then return itemstack end
        if pointed_thing.type ~= "node" then return itemstack end
        local pos = pointed_thing.above
        if not pos then return itemstack end

        local name = placer:get_player_name()
        if not minetest.check_player_privs(name, {server = true}) and
           not minetest.is_creative_enabled(name) then
            minetest.chat_send_player(name,
                "[Zombie Supremo] Necesitas privilegios de servidor para invocarlo.")
            return itemstack
        end

        local obj = minetest.add_entity(pos, modname .. ":zombie_supremo1")
        if obj then
            minetest.chat_send_player(name,
                "[Wetlands] ¡Zombie Supremo invocado en " ..
                minetest.pos_to_string(vector.round(pos)) .. "!")
            if not minetest.is_creative_enabled(name) then
                itemstack:take_item()
            end
        else
            minetest.chat_send_player(name, "[Zombie Supremo] Error al invocar.")
        end
        return itemstack
    end,
})

local has_mobitems = minetest.get_modpath("mcl_mobitems")
local flesh_item   = has_mobitems and "mcl_mobitems:rotten_flesh" or "mcl_core:stone"

minetest.register_craft({
    output = modname .. ":spawn_egg",
    recipe = {
        {"",                 "mcl_core:emerald", ""},
        {"mcl_core:emerald", flesh_item,         "mcl_core:emerald"},
        {"",                 "mcl_core:emerald", ""},
    },
})

minetest.log("action", "[" .. modname .. "] Loaded successfully (giant + interactive)")
