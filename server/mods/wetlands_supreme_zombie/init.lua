-- wetlands_supreme_zombie/init.lua
-- Zombie Supremo: mob jefe con 3 variantes de textura para elegir en produccion
-- Comandos: /invocar_zombie_supremo1|2|3
-- Apropiado para servidor Wetlands (7+). Sin gore, emocionante y derrotable.

local modname = minetest.get_current_modname()

if not minetest.get_modpath("mcl_mobs") then
    minetest.log("warning", "[" .. modname .. "] mcl_mobs no disponible. Mod no cargado.")
    return
end

-- ---------------------------------------------------------------------------
-- Constantes de configuracion (agresividad aumentada)
-- ---------------------------------------------------------------------------
local BOSS_HP           = 300
local BOSS_DAMAGE       = 12     -- antes 8
local BOSS_ARMOR        = 15
local BOSS_WALK         = 2.0    -- antes 1.5
local BOSS_RUN          = 3.5    -- antes 1.5 (ahora realmente corre)
local BOSS_SPEED_FURY   = 5.5    -- antes 3.0
local SHOCKWAVE_RADIUS  = 6      -- antes 4
local SHOCKWAVE_DELAY   = 3.5    -- antes 5.0 (ondas mas frecuentes)
local FURY_HP_TRIGGER   = 200    -- antes 150 (furia al ~67 % HP en vez del 50 %)
local RESURRECTION_HP   = 100

-- ---------------------------------------------------------------------------
-- Variantes de textura
-- Usamos colorize sobre mobs_mc_zombie.png (misma UV, 0 dependencias externas)
-- ratio 0=sin efecto, 255=color solido. Con 140-180 queda fuerte pero reconocible.
-- ---------------------------------------------------------------------------
local VARIANTES = {
    -- 1: Verde necrosis oscura - piel putrefacta casi negra
    {
        id          = "zombie_supremo1",
        nombre      = "Abominación Oscura",
        cmd         = "invocar_zombie_supremo1",
        textura     = "mobs_mc_zombie.png^[colorize:#003300:180",
    },
    -- 2: Rojo sangre - mutante corrompido/infectado
    {
        id          = "zombie_supremo2",
        nombre      = "Mutante de Sangre",
        cmd         = "invocar_zombie_supremo2",
        textura     = "mobs_mc_zombie.png^[colorize:#8b0000:160",
    },
    -- 3: Morado oscuro - coloso antiguo espectral
    {
        id          = "zombie_supremo3",
        nombre      = "Coloso Tenebroso",
        cmd         = "invocar_zombie_supremo3",
        textura     = "mobs_mc_zombie.png^[colorize:#1a001a:180",
    },
}

-- ---------------------------------------------------------------------------
-- Efectos de particulas
-- ---------------------------------------------------------------------------
local function spawn_shockwave_particles(pos)
    minetest.add_particlespawner({
        amount   = 50,
        time     = 0.5,
        minpos   = vector.subtract(pos, {x = SHOCKWAVE_RADIUS, y = 0, z = SHOCKWAVE_RADIUS}),
        maxpos   = vector.add(pos, {x = SHOCKWAVE_RADIUS, y = 0.5, z = SHOCKWAVE_RADIUS}),
        minvel   = {x = -3, y = 0.5, z = -3},
        maxvel   = {x = 3, y = 1, z = 3},
        minacc   = {x = 0, y = -1, z = 0},
        maxacc   = {x = 0, y = -1, z = 0},
        minexptime = 0.3,
        maxexptime = 1.0,
        minsize  = 2,
        maxsize  = 6,
        texture  = "mcl_particles_smoke.png",
        glow     = 4,
    })
end

local function spawn_fury_particles(pos)
    minetest.add_particlespawner({
        amount   = 40,
        time     = 3,
        minpos   = vector.subtract(pos, {x = 1, y = 0, z = 1}),
        maxpos   = vector.add(pos, {x = 1, y = 2, z = 1}),
        minvel   = {x = -2, y = 1, z = -2},
        maxvel   = {x = 2, y = 3, z = 2},
        minacc   = {x = 0, y = -2, z = 0},
        maxacc   = {x = 0, y = -2, z = 0},
        minexptime = 0.5,
        maxexptime = 1.5,
        minsize  = 2,
        maxsize  = 5,
        texture  = "mcl_particles_flame.png",
        glow     = 10,
    })
end

local function spawn_resurrection_particles(pos)
    minetest.add_particlespawner({
        amount   = 60,
        time     = 2,
        minpos   = vector.subtract(pos, {x = 1.5, y = 0, z = 1.5}),
        maxpos   = vector.add(pos, {x = 1.5, y = 3, z = 1.5}),
        minvel   = {x = -3, y = 2, z = -3},
        maxvel   = {x = 3, y = 5, z = 3},
        minacc   = {x = 0, y = -5, z = 0},
        maxacc   = {x = 0, y = -5, z = 0},
        minexptime = 0.5,
        maxexptime = 2.0,
        minsize  = 3,
        maxsize  = 8,
        texture  = "mcl_particles_smoke.png",
        glow     = 8,
    })
end

-- ---------------------------------------------------------------------------
-- Onda de choque
-- ---------------------------------------------------------------------------
local function execute_shockwave(self, pos)
    local objects   = minetest.get_objects_inside_radius(pos, SHOCKWAVE_RADIUS)
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
                    x = push_dir.x * 10,
                    y = 6,
                    z = push_dir.z * 10,
                })
                minetest.chat_send_player(
                    obj:get_player_name(),
                    "[Zombie Supremo] ¡ONDA DE CHOQUE! El zombie supremo te ha empujado."
                )
                hit_count = hit_count + 1
            end
        end
    end

    spawn_shockwave_particles(pos)
    if hit_count > 0 then
        minetest.log("action", "[" .. modname .. "] Onda de choque: " ..
            hit_count .. " jugador(es) empujados.")
    end
end

-- ---------------------------------------------------------------------------
-- Registro de variantes
-- ---------------------------------------------------------------------------
for _, v in ipairs(VARIANTES) do
    local entity_name = modname .. ":" .. v.id

    mcl_mobs.register_mob(entity_name, {
        description  = "Zombie Supremo - " .. v.nombre,
        type         = "monster",
        spawn_class  = "hostile",

        -- Visual en raiz (mcl_mobs lee self.textures desde aqui)
        collisionbox = {-0.5, -0.01, -0.5, 0.5, 1.9, 0.5},
        visual       = "mesh",
        mesh         = "mobs_mc_zombie.b3d",
        visual_size  = {x = 2.0, y = 2.0},
        textures     = {{v.textura}},
        makes_footstep_sound = true,
        glow         = 2,

        initial_properties = {
            hp_min = BOSS_HP,
            hp_max = BOSS_HP,
        },

        xp_min = 20,
        xp_max = 50,
        armor  = BOSS_ARMOR,
        damage = BOSS_DAMAGE,

        walk_velocity = BOSS_WALK,
        run_velocity  = BOSS_RUN,
        jump_height   = 4,
        view_range    = 28,
        fear_height   = 0,

        passive        = false,
        attack_type    = "punch",
        attack_animals = false,
        attack_players = true,
        reach          = 4,

        animation = {
            speed_normal = 15,
            speed_run    = 30,
            stand_start  = 0,
            stand_end    = 0,
            walk_start   = 0,
            walk_end     = 40,
            run_start    = 0,
            run_end      = 40,
            punch_start  = 0,
            punch_end    = 40,
        },

        sounds = {
            random   = "mobs_mc_zombie_growl",
            war_cry  = "mobs_mc_zombie_growl",
            attack   = "mobs_mc_zombie_growl",
            damage   = "mobs_mc_zombie_hurt",
            death    = "mobs_mc_zombie_death",
            distance = 20,
        },

        drops = {
            {name = "mcl_core:emerald", chance = 1,  min = 1, max = 3},
            {name = "mcl_books:book",   chance = 1,  min = 1, max = 1},
            {name = "mcl_core:diamond", chance = 10, min = 1, max = 1},
        },

        on_activate = function(self, staticdata, dtime_s)
            self._resurrection_used = false
            self._resurrecting      = false
            self._shockwave_timer   = 0.0
            self._fury_active       = false

            self.object:set_armor_groups({fleshy = 100})

            local pos = self.object:get_pos()
            if pos then
                minetest.chat_send_all(
                    "[Wetlands] ¡El Zombie Supremo (" .. v.nombre ..
                    ") ha despertado en " ..
                    minetest.pos_to_string(vector.round(pos)) ..
                    "! ¡Cuidado, aventureros!"
                )
            end
        end,

        do_punch = function(self, hitter, time_from_last_punch, tool_capabilities, dir)
            local hp = self.object:get_hp()
            if not self._fury_active and hp <= FURY_HP_TRIGGER and hp > 0 then
                self._fury_active  = true
                self.walk_velocity = BOSS_SPEED_FURY
                self.run_velocity  = BOSS_SPEED_FURY

                local pos = self.object:get_pos()
                if pos then spawn_fury_particles(pos) end

                minetest.chat_send_all(
                    "[Wetlands] ¡El Zombie Supremo ha entrado en MODO FURIA! ¡Corre!"
                )
            end
        end,

        on_step = function(self, dtime)
            self._shockwave_timer = (self._shockwave_timer or 0.0) + dtime

            local pos = self.object:get_pos()
            if not pos then return end

            local hp = self.object:get_hp()

            -- Resurreccion: cuando HP llega a 1, se hace immortal, se cura y vuelve
            if hp <= 1 and not self._resurrection_used and not self._resurrecting then
                self._resurrecting = true
                self.object:set_armor_groups({immortal = 1})

                minetest.after(0.05, function()
                    if not self.object then return end
                    if not self.object:get_pos() then return end

                    self.object:set_hp(RESURRECTION_HP)
                    self.object:set_armor_groups({fleshy = 100})

                    self._resurrection_used = true
                    self._resurrecting      = false
                    self._fury_active       = false
                    self.walk_velocity      = BOSS_SPEED_FURY
                    self.run_velocity       = BOSS_SPEED_FURY
                    self._shockwave_timer   = 0.0

                    local rpos = self.object:get_pos()
                    if rpos then spawn_resurrection_particles(rpos) end

                    minetest.chat_send_all(
                        "[Wetlands] ¡El Zombie Supremo ha RESUCITADO con " ..
                        RESURRECTION_HP .. " HP! ¡No esta derrotado todavia!"
                    )
                end)
            end

            -- Onda de choque cuando hay jugadores cerca
            if self._shockwave_timer >= SHOCKWAVE_DELAY then
                local in_combat = false
                for _, player in ipairs(minetest.get_connected_players()) do
                    local ppos = player:get_pos()
                    if ppos and vector.distance(pos, ppos) <= (SHOCKWAVE_RADIUS * 2) then
                        in_combat = true
                        break
                    end
                end
                if in_combat then
                    self._shockwave_timer = 0.0
                    execute_shockwave(self, pos)
                end
            end

            -- Mantener velocidad de furia si esta activa
            if self._fury_active then
                if self.walk_velocity ~= BOSS_SPEED_FURY then
                    self.walk_velocity = BOSS_SPEED_FURY
                    self.run_velocity  = BOSS_SPEED_FURY
                end
            end
        end,

        on_die = function(self, pos)
            minetest.chat_send_all(
                "[Wetlands] ¡El Zombie Supremo (" .. v.nombre ..
                ") ha sido DERROTADO definitivamente! ¡Bien hecho, heroes!"
            )
        end,
    })

    -- Comando de invocacion para esta variante
    minetest.register_chatcommand(v.cmd, {
        params      = "",
        description = "Invoca al Zombie Supremo (" .. v.nombre .. ") en tu posicion",
        privs       = {server = true},
        func = function(name, param)
            local player = minetest.get_player_by_name(name)
            if not player then
                return false, "Jugador no encontrado."
            end
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
-- Migracion de entidad legacy: zombie_supremo → zombie_supremo1
-- Maneja entidades guardadas antes del renombrado.
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
-- Alias legacy: /invocar_zombie_supremo → variante 1
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
            return true, "¡Abominación Oscura invocada en " ..
                minetest.pos_to_string(vector.round(pos)) .. "!"
        else
            return false, "Error al invocar al Zombie Supremo."
        end
    end,
})

-- ---------------------------------------------------------------------------
-- Spawn egg (invoca variante 1 por defecto)
-- ---------------------------------------------------------------------------
minetest.register_craftitem(modname .. ":spawn_egg", {
    description   = "Huevo de Zombie Supremo",
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
            minetest.chat_send_player(name, "[Zombie Supremo] Error al invocar la entidad.")
        end
        return itemstack
    end,
})

local has_mobitems = minetest.get_modpath("mcl_mobitems")
local flesh_item   = has_mobitems and "mcl_mobitems:rotten_flesh" or "mcl_core:stone"

minetest.register_craft({
    output = modname .. ":spawn_egg",
    recipe = {
        {"",               "mcl_core:emerald", ""},
        {"mcl_core:emerald", flesh_item,        "mcl_core:emerald"},
        {"",               "mcl_core:emerald", ""},
    },
})

minetest.log("action", "[" .. modname .. "] Loaded successfully")
