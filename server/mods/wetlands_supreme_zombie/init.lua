-- wetlands_supreme_zombie/init.lua
-- Zombie Supremo: mob jefe que combina El Gigante, El Mutante y El Rey Zombi
-- Apropiado para servidor educativo Wetlands (7+)
-- No gore. Emocionante, justo, derrotable.

local modname = minetest.get_current_modname()

-- ---------------------------------------------------------------------------
-- Guardia: verificar dependencias criticas
-- ---------------------------------------------------------------------------
if not minetest.get_modpath("mcl_mobs") then
    minetest.log("warning", "[" .. modname .. "] mcl_mobs no disponible. Mod no cargado.")
    return
end

-- ---------------------------------------------------------------------------
-- Constantes de configuracion
-- ---------------------------------------------------------------------------
local BOSS_HP          = 300
local BOSS_DAMAGE      = 8
local BOSS_ARMOR       = 15
local BOSS_SPEED_SLOW  = 1.5
local BOSS_SPEED_FURY  = 3.0
local SHOCKWAVE_RADIUS = 4
local SHOCKWAVE_DELAY  = 5.0   -- segundos entre ondas de choque
local FURY_HP_TRIGGER  = 150   -- 50 % de 300
local RESURRECTION_HP  = 100   -- HP con que renace

-- ---------------------------------------------------------------------------
-- Registro del Zombie Supremo con mcl_mobs
-- ---------------------------------------------------------------------------
mcl_mobs.register_mob(modname .. ":zombie_supremo", {
    description = "Zombie Supremo",
    type = "monster",
    spawn_class = "hostile",

    -- Propiedades fisicas (DENTRO de initial_properties segun API mcl_mobs)
    initial_properties = {
        hp_min = BOSS_HP,
        hp_max = BOSS_HP,
        collisionbox = {-0.5, -0.01, -0.5, 0.5, 1.9, 0.5},
        visual = "mesh",
        mesh = "mobs_mc_zombie.b3d",
        -- visual_size escala el modelo al doble (gigante)
        visual_size = {x = 2.0, y = 2.0},
        textures = {{"mobs_mc_zombie.png"}},
        makes_footstep_sound = true,
        glow = 0,
    },

    -- Estadisticas de combate
    xp_min = 20,
    xp_max = 50,
    armor = BOSS_ARMOR,
    damage = BOSS_DAMAGE,

    -- Movimiento
    walk_velocity = BOSS_SPEED_SLOW,
    run_velocity  = BOSS_SPEED_SLOW,
    jump_height   = 4,
    view_range    = 16,
    fear_height   = 0,   -- no huye de precipicios (implacable)

    -- Comportamiento de persecucion
    passive = false,
    attack_type = "punch",
    attack_animals = false,
    attack_players = true,
    reach = 3,

    -- Animaciones del modelo zombie
    animation = {
        speed_normal = 15,
        speed_run    = 25,
        stand_start  = 0,
        stand_end    = 0,
        walk_start   = 0,
        walk_end     = 40,
        run_start    = 0,
        run_end      = 40,
        punch_start  = 0,
        punch_end    = 40,
    },

    -- Sonidos (reutiliza los del zombie vanilla de VoxeLibre)
    sounds = {
        random   = "mobs_mc_zombie_growl",
        war_cry  = "mobs_mc_zombie_growl",
        attack   = "mobs_mc_zombie_growl",
        damage   = "mobs_mc_zombie_hurt",
        death    = "mobs_mc_zombie_death",
        distance = 20,
    },

    -- Drops al morir definitivamente (segunda muerte)
    drops = {
        {name = "mcl_core:emerald",  chance = 1,  min = 1, max = 3},
        {name = "mcl_books:book",    chance = 1,  min = 1, max = 1},
        {name = "mcl_core:diamond",  chance = 10, min = 1, max = 1},
    },

    -- -----------------------------------------------------------------------
    -- on_activate: inicializar estado interno del boss
    -- -----------------------------------------------------------------------
    on_activate = function(self, staticdata, dtime_s)
        -- Flag de resurreccion: false = todavia puede resucitar una vez
        self._resurrection_used = false

        -- Contadores de habilidades
        self._shockwave_timer = 0.0
        self._fury_active     = false

        -- Anuncio de aparicion
        local pos = self.object:get_pos()
        if pos then
            minetest.chat_send_all(
                "[Wetlands] ¡El Zombie Supremo ha despertado en " ..
                minetest.pos_to_string(vector.round(pos)) .. "! " ..
                "¡Cuidado, aventureros!"
            )
        end

        minetest.log("action", "[" .. modname .. "] Zombie Supremo activado.")
    end,

    -- -----------------------------------------------------------------------
    -- do_punch: manejar golpes recibidos (usar do_punch, no on_punch)
    -- -----------------------------------------------------------------------
    do_punch = function(self, hitter, time_from_last_punch, tool_capabilities, dir)
        local hp = self.object:get_hp()

        -- --- Modo Furia al 50 % de vida -----------------------------------
        if not self._fury_active and hp <= FURY_HP_TRIGGER then
            self._fury_active = true
            self.walk_velocity = BOSS_SPEED_FURY
            self.run_velocity  = BOSS_SPEED_FURY

            -- Efectos visuales de furia
            local pos = self.object:get_pos()
            if pos then
                minetest.add_particlespawner({
                    amount = 40,
                    time   = 3,
                    minpos = vector.subtract(pos, {x=1, y=0, z=1}),
                    maxpos = vector.add(pos, {x=1, y=2, z=1}),
                    minvel = {x=-2, y=1, z=-2},
                    maxvel = {x=2, y=3, z=2},
                    minacc = {x=0, y=-2, z=0},
                    maxacc = {x=0, y=-2, z=0},
                    minexptime = 0.5,
                    maxexptime = 1.5,
                    minsize = 2,
                    maxsize = 5,
                    texture = "mcl_particles_flame.png",
                    glow = 10,
                })
            end

            minetest.chat_send_all(
                "[Wetlands] ¡El Zombie Supremo ha entrado en MODO FURIA! ¡Corre!"
            )
            minetest.log("action", "[" .. modname .. "] Modo furia activado (HP=" .. hp .. ")")
        end

        -- --- Resurreccion al llegar a 0 HP --------------------------------
        -- mcl_mobs llama do_punch antes de aplicar el dano, pero revisamos HP
        -- actual. La logica de muerte real se maneja en on_die mas abajo.
        -- (Ver on_die para la implementacion de resurreccion)
    end,

    -- -----------------------------------------------------------------------
    -- on_die: logica de resurreccion (primer intento) o muerte real
    -- -----------------------------------------------------------------------
    on_die = function(self, pos)
        if not self._resurrection_used then
            -- Primera "muerte": resucitar con 100 HP
            self._resurrection_used = true

            minetest.after(0.1, function()
                -- Comprobar que la entidad siga existiendo antes de curar
                if not self.object then return end
                if not self.object:get_pos() then return end

                self.object:set_hp(RESURRECTION_HP)
                self._fury_active     = false
                self.walk_velocity    = BOSS_SPEED_FURY  -- sale furioso del renacimiento
                self.run_velocity     = BOSS_SPEED_FURY
                self._shockwave_timer = 0.0

                -- Efecto de resurreccion: explosion de particulas
                if pos then
                    minetest.add_particlespawner({
                        amount = 60,
                        time   = 2,
                        minpos = vector.subtract(pos, {x=1.5, y=0, z=1.5}),
                        maxpos = vector.add(pos, {x=1.5, y=3, z=1.5}),
                        minvel = {x=-3, y=2, z=-3},
                        maxvel = {x=3, y=5, z=3},
                        minacc = {x=0, y=-5, z=0},
                        maxacc = {x=0, y=-5, z=0},
                        minexptime = 0.5,
                        maxexptime = 2.0,
                        minsize = 3,
                        maxsize = 8,
                        texture = "mcl_particles_smoke.png",
                        glow = 8,
                    })
                end

                minetest.chat_send_all(
                    "[Wetlands] ¡El Zombie Supremo ha RESUCITADO con " ..
                    RESURRECTION_HP .. " HP! ¡No esta derrotado todavia!"
                )
                minetest.log("action", "[" .. modname .. "] Zombie Supremo resucitado con " .. RESURRECTION_HP .. " HP.")
            end)

            -- Devolver true le indica a mcl_mobs que NO procese la muerte ahora
            return true
        end

        -- Segunda muerte: muerte definitiva, caen los drops normales
        minetest.chat_send_all(
            "[Wetlands] ¡El Zombie Supremo ha sido DERROTADO definitivamente! " ..
            "¡Bien hecho, heroes!"
        )
        minetest.log("action", "[" .. modname .. "] Zombie Supremo derrotado definitivamente en " ..
            (pos and minetest.pos_to_string(vector.round(pos)) or "posicion desconocida"))
    end,

    -- -----------------------------------------------------------------------
    -- on_step: logica de onda de choque y control de velocidad
    -- -----------------------------------------------------------------------
    on_step = function(self, dtime)
        -- Acumular tiempo para la onda de choque
        self._shockwave_timer = (self._shockwave_timer or 0) + dtime

        -- Obtener posicion actual
        local pos = self.object:get_pos()
        if not pos then return end

        -- Verificar si hay un jugador cercano en rango de combate
        local in_combat = false
        local players_nearby = minetest.get_connected_players()
        for _, player in ipairs(players_nearby) do
            local ppos = player:get_pos()
            if ppos then
                local dist = vector.distance(pos, ppos)
                if dist <= (SHOCKWAVE_RADIUS * 2) then
                    in_combat = true
                    break
                end
            end
        end

        -- Ejecutar onda de choque solo cuando hay jugadores cerca
        if in_combat and self._shockwave_timer >= SHOCKWAVE_DELAY then
            self._shockwave_timer = 0.0
            self:_execute_shockwave(pos)
        end

        -- Sincronizar velocidades si el modo furia fue activado
        -- (mcl_mobs puede resetear velocidad internamente)
        if self._fury_active then
            if self.walk_velocity ~= BOSS_SPEED_FURY then
                self.walk_velocity = BOSS_SPEED_FURY
                self.run_velocity  = BOSS_SPEED_FURY
            end
        end
    end,

    -- -----------------------------------------------------------------------
    -- _execute_shockwave: metodo privado de onda de choque
    -- -----------------------------------------------------------------------
    _execute_shockwave = function(self, pos)
        -- Empujar a todos los jugadores en el radio
        local objects = minetest.get_objects_inside_radius(pos, SHOCKWAVE_RADIUS)
        local hit_count = 0

        for _, obj in ipairs(objects) do
            if obj:is_player() then
                local ppos = obj:get_pos()
                if ppos then
                    -- Calcular direccion de empuje (alejarse del boss)
                    local push_dir = vector.subtract(ppos, pos)
                    if vector.length(push_dir) < 0.1 then
                        push_dir = {x=1, y=0, z=0}
                    end
                    push_dir = vector.normalize(push_dir)

                    -- Velocidad de empuje: horizontal fuerte + vertical moderado
                    local push_vel = {
                        x = push_dir.x * 8,
                        y = 5,
                        z = push_dir.z * 8,
                    }
                    obj:add_velocity(push_vel)

                    -- Aviso al jugador
                    minetest.chat_send_player(
                        obj:get_player_name(),
                        "[Zombie Supremo] ¡ONDA DE CHOQUE! El zombie supremo te ha empujado."
                    )
                    hit_count = hit_count + 1
                end
            end
        end

        -- Efecto visual de onda de choque
        minetest.add_particlespawner({
            amount = 50,
            time   = 0.5,
            minpos = vector.subtract(pos, {x=SHOCKWAVE_RADIUS, y=0, z=SHOCKWAVE_RADIUS}),
            maxpos = vector.add(pos, {x=SHOCKWAVE_RADIUS, y=0.5, z=SHOCKWAVE_RADIUS}),
            minvel = {x=-3, y=0.5, z=-3},
            maxvel = {x=3, y=1, z=3},
            minacc = {x=0, y=-1, z=0},
            maxacc = {x=0, y=-1, z=0},
            minexptime = 0.3,
            maxexptime = 1.0,
            minsize = 2,
            maxsize = 6,
            texture = "mcl_particles_smoke.png",
            glow = 4,
        })

        if hit_count > 0 then
            minetest.log("action", "[" .. modname .. "] Onda de choque: " .. hit_count .. " jugador(es) empujados.")
        end
    end,
})

-- ---------------------------------------------------------------------------
-- Spawn egg: "Huevo de Zombie Supremo"
-- ---------------------------------------------------------------------------
minetest.register_craftitem(modname .. ":spawn_egg", {
    description = "Huevo de Zombie Supremo",
    inventory_image = "mobs_mc_spawn_egg.png^[colorize:#1a1a2e:180^mobs_mc_spawn_egg_overlay.png^[colorize:#4a0000:100",
    stack_max = 64,
    groups = {spawn_egg = 1},

    on_place = function(itemstack, placer, pointed_thing)
        if not placer or not placer:is_player() then
            return itemstack
        end

        if pointed_thing.type ~= "node" then
            return itemstack
        end

        local pos = pointed_thing.above
        if not pos then return itemstack end

        -- Solo admins o en modo creativo pueden invocar al boss
        local name = placer:get_player_name()
        if not minetest.check_player_privs(name, {server = true}) and
           not minetest.is_creative_enabled(name) then
            minetest.chat_send_player(name,
                "[Zombie Supremo] Necesitas privilegios de servidor para invocar al Zombie Supremo.")
            return itemstack
        end

        local obj = minetest.add_entity(pos, modname .. ":zombie_supremo")
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

-- ---------------------------------------------------------------------------
-- Receta: 1 mcl_mobitems:rotten_flesh en el centro, 4 esmeraldas en cruz
-- ---------------------------------------------------------------------------
local has_mobitems = minetest.get_modpath("mcl_mobitems")
local flesh_item   = has_mobitems and "mcl_mobitems:rotten_flesh" or "mcl_core:stone"

minetest.register_craft({
    output = modname .. ":spawn_egg",
    recipe = {
        {"",                      "mcl_core:emerald", ""},
        {"mcl_core:emerald",      flesh_item,         "mcl_core:emerald"},
        {"",                      "mcl_core:emerald", ""},
    }
})

-- ---------------------------------------------------------------------------
-- Comando admin: invocar Zombie Supremo en posicion del jugador
-- ---------------------------------------------------------------------------
minetest.register_chatcommand("invocar_zombie_supremo", {
    params = "",
    description = "Invoca al Zombie Supremo en tu posicion (requiere privs server)",
    privs = {server = true},
    func = function(name, param)
        local player = minetest.get_player_by_name(name)
        if not player then
            return false, "Jugador no encontrado."
        end

        local pos = player:get_pos()
        pos.y = pos.y + 1

        local obj = minetest.add_entity(pos, modname .. ":zombie_supremo")
        if obj then
            return true, "¡Zombie Supremo invocado en " .. minetest.pos_to_string(vector.round(pos)) .. "!"
        else
            return false, "Error al invocar al Zombie Supremo."
        end
    end,
})

-- ---------------------------------------------------------------------------
-- Log de carga
-- ---------------------------------------------------------------------------
minetest.log("action", "[" .. modname .. "] Loaded successfully")
