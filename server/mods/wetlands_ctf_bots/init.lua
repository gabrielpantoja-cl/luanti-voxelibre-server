-- wetlands_ctf_bots — bots para el CTF de rubenwardy (puerto 30003)
--
-- Para que un jugador solo (o dos) tenga con quien jugar: rivales que atacan y
-- defienden su bandera, y companeros que escoltan al jugador. Al entrar aparece
-- un menu para elegir cuantos y la dificultad; /bots lo vuelve a abrir.
--
-- Por que entidades y no "jugadores falsos": el CTF ignora todo golpe cuyo
-- hitter no sea jugador (ctf_modebase/features.lua, on_punchplayer) y la toma de
-- bandera exige un jugador (flags/taking.lua). Asi que:
--   * el bot hiere al jugador con set_hp + reason {type = "set_hp"} (seguro);
--   * el jugador hiere al bot con espada (punch directo) y con armas de fuego
--     (ctf_ranged solo deja pegar a jugadores; ver el wrapper de rawf.bulletcast
--     al final del archivo);
--   * la bandera que lleva un bot es solo el nodo flag_captured_top; si el bot
--     llega a su base, el modulo termina la partida con start_new_match().
--
-- Los bots no se guardan (static_save = false) y cada bloque donde hay un bot se
-- mantiene activo con forceload transitorio: la base enemiga suele estar a
-- ~170 nodos del jugador, fuera de active_block_range.

local modname = minetest.get_current_modname()

if not (minetest.global_exists("ctf_modebase") and minetest.global_exists("ctf_teams")
		and minetest.global_exists("ctf_map") and minetest.global_exists("ctf_api")) then
	minetest.log("warning", "[" .. modname .. "] CTF no detectado: mod inactivo")
	return
end

local storage = minetest.get_mod_storage()
local ENTIDAD = modname .. ":bot"
local FORM = modname .. ":menu"

-- ============================================================
-- CONFIGURACION
-- ============================================================
local MAX_HUMANOS = 2        -- con mas jugadores conectados, los bots se retiran
local MAX_BOTS_EQUIPO = 10   -- tope por equipo (rivales y companeros por igual)
local OPCIONES_RIVALES, OPCIONES_ALIADOS = {}, {}
for n = 0, MAX_BOTS_EQUIPO do
	OPCIONES_RIVALES[#OPCIONES_RIVALES + 1] = n
	OPCIONES_ALIADOS[#OPCIONES_ALIADOS + 1] = n
end
local RESPAWN_BOT = 8        -- segundos hasta que reaparece un bot eliminado
local VIDA_BASE = 200        -- hp_max de un jugador CTF (fallback)
local PENSAR_CADA = 0.25

-- vel: nodos/s; dano: fraccion de la vida maxima por golpe; cd: segundos entre
-- golpes; vida: fraccion de VIDA_BASE; alcance: radio para ver enemigos.
local DIFICULTADES = {
	facil   = {label = "Fácil",   vel = 3.2, dano = 0.05, cd = 1.3, vida = 0.6, alcance = 12},
	normal  = {label = "Normal",  vel = 4.0, dano = 0.08, cd = 1.0, vida = 0.8, alcance = 18},
	dificil = {label = "Difícil", vel = 4.8, dano = 0.12, cd = 0.8, vida = 1.0, alcance = 24},
}
local ORDEN_DIF = {"facil", "normal", "dificil"}

-- Mapas abiertos donde la navegacion funciona razonable. Con bots activos la
-- rotacion se limita a estos (si alguno soporta el modo actual).
local MAPAS_BOTS = {
	plains = true, plain_battle = true, green_hills = true,
	river_valley = true, savanna_ravine = true, coast = true,
}

local NOMBRES = {
	"Pudú", "Huemul", "Cóndor", "Puma", "Zorro", "Chucao", "Monito", "Coipo",
	"Guanaco", "Chingue", "Ñandú", "Pingüino", "Queltehue", "Loica", "Tiuque", "Chungungo",
	"Colocolo", "Degú", "Cachaña", "Carpintero", "Pidén", "Bandurria",
}

local NOMBRE_EQUIPO = {
	red = "Rojo", blue = "Azul", green = "Verde", orange = "Naranjo",
	purple = "Morado", yellow = "Amarillo",
}

local ANIM = {
	stand = {x = 0, y = 79},
	walk = {x = 168, y = 187},
	mine = {x = 189, y = 198},
	walk_mine = {x = 200, y = 219},
}

-- ============================================================
-- ESTADO
-- ============================================================
local function cargar_cfg()
	local c = minetest.deserialize(storage:get_string("cfg")) or {}
	return {
		rivales = math.min(tonumber(c.rivales) or 0, MAX_BOTS_EQUIPO),
		aliados = math.min(tonumber(c.aliados) or 0, MAX_BOTS_EQUIPO),
		dif = DIFICULTADES[c.dif] and c.dif or "normal",
	}
end

local cfg = cargar_cfg()

local function guardar_cfg()
	storage:set_string("cfg", minetest.serialize(cfg))
end

local partida = 0          -- id de partida; un bot de otra partida se borra solo
local bots = {}            -- id -> {team, rol, nombre, obj, muerto_hasta}
local siguiente_id = 0
local activos = false
local terminando = false
local equipo_aliado, equipo_rival
local dueno                -- jugador cuyo equipo es el "aliado"
local bandera_en_bot = {}  -- team -> id del bot que la lleva

local function ahora()
	return minetest.get_us_time() / 1e6
end

-- ============================================================
-- UTILIDADES
-- ============================================================
local function nombre_equipo(team)
	return NOMBRE_EQUIPO[team] or tostring(team)
end

local function color(team)
	return ctf_teams.team[team] and ctf_teams.team[team].color or "#ffffff"
end

local function col(team, texto)
	return minetest.colorize(color(team), texto)
end

local function avisar(texto)
	minetest.chat_send_all(minetest.colorize("#ffcc33", "[Bots] ") .. texto)
end

local function aviso_hud(player, texto)
	if minetest.global_exists("hud_events") then
		hud_events.new(player, {quick = true, text = texto, color = "warning"})
	end
end

local function nodo_def(pos)
	local n = minetest.get_node_or_nil(pos)
	if not n or n.name == "ignore" then return nil end
	return minetest.registered_nodes[n.name]
end

local function solido(pos)
	local d = nodo_def(pos)
	return d ~= nil and d.walkable ~= false
end

local function libre(pos)
	local d = nodo_def(pos)
	if not d or d.walkable ~= false then return false end
	return (d.damage_per_second or 0) <= 0
end

local function en_liquido(pos)
	local d = nodo_def(vector.round(pos))
	return d ~= nil and d.liquidtype ~= nil and d.liquidtype ~= "none"
end

-- p = posicion entera de los pies
local function parable(p)
	return solido(vector.offset(p, 0, -1, 0)) and libre(p) and libre(vector.offset(p, 0, 1, 0))
end

local function buscar_suelo(pos, rango_y)
	local p = vector.round(pos)
	for dy = 0, rango_y do
		local a = vector.offset(p, 0, dy, 0)
		if parable(a) then return a end
		if dy > 0 then
			local b = vector.offset(p, 0, -dy, 0)
			if parable(b) then return b end
		end
	end
end

local function dist_h(a, b)
	local dx, dz = a.x - b.x, a.z - b.z
	return math.sqrt(dx * dx + dz * dz)
end

local function mapa()
	return ctf_map.current_map
end

local function pos_bandera(team)
	local m = mapa()
	local t = m and m.teams and m.teams[team]
	return t and t.flag_pos
end

local function textura_bandera(team)
	return "default_wood.png^([combine:16x16:4,0=wool_white.png^[colorize:" .. color(team) .. ":200)"
end

local function piel(team)
	local c = color(team)
	return "character.png^(ctf_cosmetics_shirt.png^[multiply:" .. c ..
		")^(ctf_cosmetics_pants.png^[multiply:" .. c .. ")"
end

-- Devuelve a su poste una bandera que llevaba un bot.
local function devolver_bandera(team)
	local fp = pos_bandera(team)
	if not fp then return end
	local top = vector.offset(fp, 0, 1, 0)
	minetest.load_area(top)
	local n = minetest.get_node(top)
	if n.name == "ctf_modebase:flag_captured_top" then
		minetest.set_node(top, {name = "ctf_modebase:flag_top_" .. team, param2 = n.param2})
	end
end

local function tomar_bandera_nodo(team)
	local fp = pos_bandera(team)
	if not fp then return false end
	local top = vector.offset(fp, 0, 1, 0)
	local n = minetest.get_node(top)
	if n.name ~= "ctf_modebase:flag_top_" .. team then return false end
	minetest.set_node(top, {name = "ctf_modebase:flag_captured_top", param2 = n.param2})
	return true
end

-- Jugador humano que lleva la bandera del equipo `team`, si hay.
local function humano_con_bandera(team)
	for pname, teams in pairs(ctf_modebase.taken_flags or {}) do
		for _, t in ipairs(teams) do
			if t == team then return minetest.get_player_by_name(pname) end
		end
	end
end

local function jugador_vivo(p)
	if p:get_hp() <= 0 then return false end
	local props = p:get_properties()
	-- durante el respawn_delay del CTF: hp_max = 0 y pointable = false
	return props.pointable ~= false and (props.hp_max or 0) > 0
end

local function vida_max_bot()
	return math.floor(VIDA_BASE * DIFICULTADES[cfg.dif].vida)
end

-- Enemigos de `team` a menos de `radio` de `centro`, del mas cercano al mas lejano.
local function enemigos_de(team, centro, radio)
	local lista = {}
	for _, p in ipairs(minetest.get_connected_players()) do
		local t = ctf_teams.get(p)
		if t and t ~= team and jugador_vivo(p)
				and not (ctf_modebase.is_immune and ctf_modebase.is_immune(p)) then
			local d = vector.distance(centro, p:get_pos())
			if d <= radio then lista[#lista + 1] = {obj = p, d = d} end
		end
	end
	for _, b in pairs(bots) do
		if b.team ~= team and b.obj then
			local pos = b.obj:get_pos()
			if pos then
				local d = vector.distance(centro, pos)
				if d <= radio then lista[#lista + 1] = {obj = b.obj, d = d} end
			end
		end
	end
	table.sort(lista, function(a, b) return a.d < b.d end)
	return lista
end

local function ve_a(pos, obj)
	local op = obj:get_pos()
	if not op then return false end
	return minetest.line_of_sight(vector.offset(pos, 0, 1.5, 0), vector.offset(op, 0, 1.5, 0))
end

-- ============================================================
-- FORCELOAD (con conteo de referencias)
-- ============================================================
local cargados = {}

local function fl_clave(pos)
	local b = vector.floor(vector.divide(pos, 16))
	return b.x .. "," .. b.y .. "," .. b.z, vector.multiply(b, 16)
end

local function fl_tomar(pos)
	local k, base = fl_clave(pos)
	local e = cargados[k]
	if e then
		e.n = e.n + 1
	elseif minetest.forceload_block(base, true) then
		cargados[k] = {n = 1, pos = base}
	else
		return nil
	end
	return k
end

local function fl_soltar(k)
	local e = k and cargados[k]
	if not e then return end
	e.n = e.n - 1
	if e.n <= 0 then
		minetest.forceload_free_block(e.pos, true)
		cargados[k] = nil
	end
end

local function fl_soltar_todo()
	for _, e in pairs(cargados) do
		minetest.forceload_free_block(e.pos, true)
	end
	cargados = {}
end

-- ============================================================
-- COMBATE
-- ============================================================
local function particulas(pos)
	minetest.add_particlespawner({
		amount = 20, time = 0.3,
		minpos = vector.offset(pos, -0.4, 0.2, -0.4), maxpos = vector.offset(pos, 0.4, 1.8, 0.4),
		minvel = {x = -1, y = 0.5, z = -1}, maxvel = {x = 1, y = 2, z = 1},
		minexptime = 0.5, maxexptime = 1.2, minsize = 2, maxsize = 4,
		texture = "default_cloud.png",
	})
end

local function herir_jugador(b, bot_obj, player)
	local hpmax = player:get_properties().hp_max or VIDA_BASE
	if hpmax <= 20 then hpmax = VIDA_BASE end
	local dano = math.max(1, math.floor(hpmax * DIFICULTADES[cfg.dif].dano + 0.5))
	local hp = player:get_hp()
	if hp <= 0 then return end
	if hp - dano <= 0 then
		local pname = player:get_player_name()
		minetest.chat_send_all(col(b.team, "[Bot] " .. b.nombre) .. " eliminó a " ..
			col(ctf_teams.get(player) or "", pname))
	end
	-- reason "set_hp": nunca un "punch" falso (ver AGENTS.md, pitfall set_hp)
	player:set_hp(hp - dano, {type = "set_hp", from = modname})
	local bp, pp = bot_obj:get_pos(), player:get_pos()
	if bp and pp then
		local dir = vector.direction(bp, pp)
		player:add_velocity({x = dir.x * 4, y = 2, z = dir.z * 4})
	end
end

local function matar_bot(ent, autor)
	local b = bots[ent._id]
	local pos = ent.object:get_pos()
	if b then
		minetest.chat_send_all((autor or "Alguien") .. " eliminó a " .. col(b.team, "[Bot] " .. b.nombre))
		b.muerto_hasta = ahora() + RESPAWN_BOT
	end
	if pos then particulas(pos) end
	ent._muerto = true
	ent.object:remove()   -- on_deactivate devuelve la bandera y libera el forceload
end

local function herir_bot(ent, dano, autor, agresor)
	if ent._muerto then return end
	ent._hp = (ent._hp or 1) - dano
	ent.object:set_texture_mod("^[colorize:#ff0000:110")
	local obj = ent.object
	minetest.after(0.2, function()
		if obj:get_pos() then obj:set_texture_mod("") end
	end)
	if agresor then
		ent._agresor = agresor
		ent._agresor_hasta = ahora() + 6
	end
	if ent._hp <= 0 then matar_bot(ent, autor) end
end

local function golpear(ent, b, objetivo)
	if objetivo:is_player() then
		herir_jugador(b, ent.object, objetivo)
	else
		local otro = objetivo:get_luaentity()
		if otro and otro.name == ENTIDAD then
			herir_bot(otro, vida_max_bot() * DIFICULTADES[cfg.dif].dano * 1.5,
				col(b.team, "[Bot] " .. b.nombre), ent.object)
		end
	end
end

-- ============================================================
-- MOVIMIENTO
-- ============================================================
local function anim(ent, nombre)
	if ent._anim ~= nombre then
		ent._anim = nombre
		ent.object:set_animation(ANIM[nombre], 30, 0, true)
	end
end

local function pos_cerca_base(team)
	local fp = pos_bandera(team)
	if not fp then return nil end
	for _ = 1, 16 do
		local a = math.random() * math.pi * 2
		local r = 3 + math.random() * 4
		local p = buscar_suelo({x = fp.x + math.cos(a) * r, y = fp.y, z = fp.z + math.sin(a) * r}, 8)
		if p then return p end
	end
	return vector.offset(fp, 0, 2, 0)
end

local function planificar(ent, pos, meta)
	ent._ruta_t = 0
	ent._ruta_meta = vector.new(meta)
	ent._ruta = nil
	ent._ruta_i = 1
	local inicio = buscar_suelo(pos, 2)
	if not inicio then return end
	local sub = meta
	if vector.distance(pos, meta) > 30 then
		sub = vector.add(pos, vector.multiply(vector.direction(pos, meta), 26))
	end
	local fin = buscar_suelo(sub, 12)
	if not fin then return end
	local ruta = minetest.find_path(inicio, fin, 32, 1, 4, "A*_noprefetch")
	if ruta and #ruta > 0 then
		ent._ruta = ruta
	end
end

local function reubicar(ent, pos, b)
	local destino
	if ent._ruta and ent._ruta[ent._ruta_i + 3] then
		destino = ent._ruta[ent._ruta_i + 3]
	elseif ent._meta then
		destino = buscar_suelo(vector.add(pos, vector.multiply(vector.direction(pos, ent._meta), 5)), 8)
	end
	destino = destino or pos_cerca_base(b.team)
	if destino then
		particulas(pos)
		ent.object:set_pos(destino)
	end
	ent._ruta = nil
	ent._ruta_t = 99
end

-- ============================================================
-- CEREBRO
-- ============================================================
local function pensar(ent, b, pos)
	local dif = DIFICULTADES[cfg.dif]
	local enemigo_team = (b.team == equipo_rival) and equipo_aliado or equipo_rival
	local objetivo, meta

	if not ctf_modebase.match_started then
		-- tiempo de construccion: quedarse en la base
		local fp = pos_bandera(b.team)
		if fp and (not ent._patrulla or vector.distance(pos, ent._patrulla) < 2) then
			local a = math.random() * math.pi * 2
			ent._patrulla = {x = fp.x + math.cos(a) * 6, y = fp.y, z = fp.z + math.sin(a) * 6}
		end
		ent._objetivo, ent._meta = nil, ent._patrulla
		return
	end

	-- quien me pego hace poco tiene prioridad (salvo si llevo la bandera)
	if not ent._lleva and ent._agresor and ahora() < (ent._agresor_hasta or 0) then
		local ap = ent._agresor:get_pos()
		if ap and vector.distance(pos, ap) <= dif.alcance * 1.5
				and (not ent._agresor:is_player() or jugador_vivo(ent._agresor)) then
			objetivo = ent._agresor
		end
	end

	-- alguien se lleva nuestra bandera: perseguirlo
	local ladron = humano_con_bandera(b.team)
	if not objetivo and not ent._lleva and ladron then
		if b.rol == "defensor" or vector.distance(pos, ladron:get_pos()) < 40 then
			objetivo = ladron
		end
	end

	if not objetivo then
		if b.rol == "atacante" then
			if ent._lleva then
				meta = pos_bandera(b.team)
				local cerca = enemigos_de(b.team, pos, 3)[1]
				if cerca then objetivo = cerca.obj end
			else
				for _, c in ipairs(enemigos_de(b.team, pos, dif.alcance)) do
					if ve_a(pos, c.obj) then objetivo = c.obj break end
				end
				if not objetivo then
					local portador = bandera_en_bot[enemigo_team]
					local pb = portador and bots[portador]
					if pb and pb.obj and pb.obj:get_pos() then
						meta = pb.obj:get_pos()   -- escoltar al que la lleva
					else
						meta = pos_bandera(enemigo_team)
					end
				end
			end
		elseif b.rol == "defensor" then
			local fp = pos_bandera(b.team)
			local cerca = fp and enemigos_de(b.team, fp, dif.alcance)[1]
			if cerca then
				objetivo = cerca.obj
			elseif fp then
				if not ent._patrulla or vector.distance(pos, ent._patrulla) < 2 or math.random() < 0.02 then
					local a = math.random() * math.pi * 2
					ent._patrulla = {x = fp.x + math.cos(a) * 7, y = fp.y, z = fp.z + math.sin(a) * 7}
				end
				meta = ent._patrulla
			end
		else -- escolta: sigue al dueno y pelea con lo que se le acerque
			local jefe = dueno and minetest.get_player_by_name(dueno)
			local jpos = jefe and jefe:get_pos()
			for _, c in ipairs(enemigos_de(b.team, jpos or pos, dif.alcance)) do
				if ve_a(pos, c.obj) then objetivo = c.obj break end
			end
			if not objetivo and jpos and vector.distance(pos, jpos) > 5 then
				meta = jpos
			end
		end
	end

	ent._objetivo = objetivo
	ent._meta = objetivo and objetivo:get_pos() or meta
end

local function victoria_bots(b)
	if terminando or not ctf_modebase.in_game then return end
	terminando = true
	avisar(col(b.team, "[Bot] " .. b.nombre) .. " capturó la bandera. ¡Ganó el equipo " ..
		col(b.team, nombre_equipo(b.team)) .. "!")
	for _, p in ipairs(minetest.get_connected_players()) do
		aviso_hud(p, "¡Esta vez ganaron los bots! Nueva partida en 5 segundos")
	end
	ctf_modebase.start_new_match(5)
end

local function revisar_banderas(ent, b, pos)
	if not ctf_modebase.match_started or terminando then return end
	local enemigo_team = (b.team == equipo_rival) and equipo_aliado or equipo_rival

	if ent._lleva then
		local fp = pos_bandera(b.team)
		-- igual que en el CTF: no se captura si la bandera propia no esta en casa
		if fp and dist_h(pos, fp) < 2.5 and math.abs(pos.y - fp.y) < 3
				and not humano_con_bandera(b.team) then
			victoria_bots(b)
		end
	elseif b.rol == "atacante" and not bandera_en_bot[enemigo_team] then
		local fp = pos_bandera(enemigo_team)
		if fp and dist_h(pos, fp) < 2.2 and math.abs(pos.y - fp.y) < 3
				and tomar_bandera_nodo(enemigo_team) then
			ent._lleva = enemigo_team
			bandera_en_bot[enemigo_team] = ent._id
			ent.object:set_properties({textures = {piel(b.team), textura_bandera(enemigo_team)}})
			avisar(col(b.team, "[Bot] " .. b.nombre) .. " tomó la bandera del equipo " ..
				col(enemigo_team, nombre_equipo(enemigo_team)) .. ". ¡Atrápalo!")
			for _, p in ipairs(minetest.get_connected_players()) do
				if ctf_teams.get(p) == enemigo_team then
					aviso_hud(p, "¡Un bot se lleva tu bandera!")
				end
			end
		end
	end
end

-- ============================================================
-- ENTIDAD
-- ============================================================
local function on_step(ent, dtime, moveresult)
	local b = ent._id and bots[ent._id]
	if not b or ent._partida ~= partida then
		ent.object:remove()
		return
	end
	local pos = ent.object:get_pos()
	if not pos then return end

	-- mantener activo el bloque donde estoy
	local k = fl_clave(pos)
	if k ~= ent._flk then
		local nueva = fl_tomar(pos)
		fl_soltar(ent._flk)
		ent._flk = nueva
	end

	-- cayo fuera del mapa
	local m = mapa()
	if m and m.pos1 and m.pos2 and pos.y < math.min(m.pos1.y, m.pos2.y) - 5 then
		ent.object:set_pos(pos_cerca_base(b.team) or pos)
		ent.object:set_velocity({x = 0, y = 0, z = 0})
		return
	end

	ent._pensar_t = (ent._pensar_t or 0) + dtime
	if ent._pensar_t >= PENSAR_CADA then
		ent._pensar_t = 0
		pensar(ent, b, pos)
		revisar_banderas(ent, b, pos)
	end

	local dif = DIFICULTADES[cfg.dif]
	local vel = ent.object:get_velocity() or {x = 0, y = 0, z = 0}
	local en_suelo = moveresult and moveresult.touching_ground

	-- ataque
	local cerca_objetivo = false
	ent._cd = (ent._cd or 0) - dtime
	if ent._objetivo then
		local tp = ent._objetivo:get_pos()
		if not tp then
			ent._objetivo = nil
		else
			local d = vector.distance(pos, tp)
			cerca_objetivo = d <= 2.0
			if d <= 2.4 and ent._cd <= 0 and ctf_modebase.match_started then
				ent._cd = dif.cd
				ent._golpe_t = 0.35
				golpear(ent, b, ent._objetivo)
			end
			if cerca_objetivo then
				ent.object:set_yaw(minetest.dir_to_yaw(vector.direction(pos, tp)))
			end
		end
	end
	ent._golpe_t = math.max(0, (ent._golpe_t or 0) - dtime)

	-- desplazamiento
	local meta = ent._meta
	local quiere_moverse = meta ~= nil and not cerca_objetivo and dist_h(pos, meta) > 1.5
	if quiere_moverse then
		ent._ruta_t = (ent._ruta_t or 99) + dtime
		if not ent._ruta_meta or ent._ruta_t > 3 or vector.distance(ent._ruta_meta, meta) > 4 then
			planificar(ent, pos, meta)
		end

		local destino = meta
		if ent._ruta then
			local wp = ent._ruta[ent._ruta_i]
			while wp and dist_h(pos, wp) < 0.7 and math.abs(wp.y - pos.y) < 1.5 do
				ent._ruta_i = ent._ruta_i + 1
				wp = ent._ruta[ent._ruta_i]
			end
			if wp then
				destino = wp
			else
				ent._ruta = nil
				ent._ruta_t = 99   -- se acabo el tramo: replanificar ya
			end
		end

		local dx, dz = destino.x - pos.x, destino.z - pos.z
		local hd = math.sqrt(dx * dx + dz * dz)
		local vy = vel.y
		if en_liquido(pos) then
			vy = 3
		elseif en_suelo and (destino.y > pos.y + 1.2 or (ent._atascado or 0) >= 2) then
			vy = 6.5
		end
		local v = dif.vel * (ent._lleva and 0.9 or 1)
		if hd > 0.1 then
			ent.object:set_velocity({x = dx / hd * v, y = vy, z = dz / hd * v})
			ent.object:set_yaw(minetest.dir_to_yaw({x = dx, y = 0, z = dz}))
		else
			ent.object:set_velocity({x = 0, y = vy, z = 0})
		end
		anim(ent, ent._golpe_t > 0 and "walk_mine" or "walk")
	else
		ent.object:set_velocity({x = 0, y = en_liquido(pos) and 2 or vel.y, z = 0})
		anim(ent, ent._golpe_t > 0 and "mine" or "stand")
	end

	-- atascado: saltar, luego replanificar, luego reubicar
	ent._atasco_t = (ent._atasco_t or 0) + dtime
	if ent._atasco_t >= 1 then
		ent._atasco_t = 0
		if quiere_moverse and ent._ult_pos and vector.distance(pos, ent._ult_pos) < 0.4 then
			ent._atascado = (ent._atascado or 0) + 1
			if ent._atascado == 4 then
				ent._ruta, ent._ruta_t = nil, 99
			elseif ent._atascado >= 7 then
				ent._atascado = 0
				reubicar(ent, pos, b)
			end
		else
			ent._atascado = 0
		end
		ent._ult_pos = pos
	end
end

minetest.register_entity(ENTIDAD, {
	initial_properties = {
		visual = "mesh",
		mesh = "character.b3d",
		textures = {"character.png", "blank.png"},
		collisionbox = {-0.3, 0.0, -0.3, 0.3, 1.7, 0.3},
		selectionbox = {-0.3, 0.0, -0.3, 0.3, 1.7, 0.3},
		physical = true,
		collide_with_objects = true,
		stepheight = 1.1,
		hp_max = 1000,
		static_save = false,
		makes_footstep_sound = true,
	},

	on_activate = function(self)
		self.object:set_armor_groups({fleshy = 100})
		self.object:set_acceleration({x = 0, y = -9.81, z = 0})
	end,

	on_step = on_step,

	on_punch = function(self, puncher, tflp, caps, dir, damage)
		local b = self._id and bots[self._id]
		if not b or not puncher or not puncher:is_player() then return true end
		if not ctf_modebase.match_started then
			aviso_hud(puncher, "La partida aún no empieza")
			return true
		end
		local pteam = ctf_teams.get(puncher)
		if not pteam or pteam == b.team then return true end
		local pname = puncher:get_player_name()
		if ctf_modebase.remove_respawn_immunity and not ctf_modebase.remove_respawn_immunity(pname) then
			return true
		end
		local d = damage or 0
		if d <= 0 and caps and caps.damage_groups then
			local f = math.min(1, (tflp or 1) / (caps.full_punch_interval or 1))
			d = (caps.damage_groups.fleshy or 0) * f
		end
		if dir then
			self.object:add_velocity({x = dir.x * 3, y = 2, z = dir.z * 3})
		end
		herir_bot(self, d, col(pteam, pname), puncher)
		return true
	end,

	on_deactivate = function(self)
		fl_soltar(self._flk)
		self._flk = nil
		local b = self._id and bots[self._id]
		if self._lleva and self._partida == partida and bandera_en_bot[self._lleva] == self._id then
			bandera_en_bot[self._lleva] = nil
			devolver_bandera(self._lleva)
			avisar("La bandera del equipo " .. col(self._lleva, nombre_equipo(self._lleva)) ..
				" volvió a su base.")
		end
		if b and b.obj == self.object then
			b.obj = nil
			-- descargado sin morir (no deberia pasar): reaparece pronto
			b.muerto_hasta = b.muerto_hasta or (ahora() + 2)
		end
	end,
})

-- ============================================================
-- GESTION DE BOTS
-- ============================================================
local bases = {}

local function crear_bot(id)
	local b = bots[id]
	if not b then return end
	local pos = pos_cerca_base(b.team)
	if not pos then return end
	local obj = minetest.add_entity(pos, ENTIDAD)
	if not obj then return end
	local ent = obj:get_luaentity()
	ent._id = id
	ent._partida = partida
	ent._hp = vida_max_bot()
	ent._flk = fl_tomar(pos)
	b.obj = obj
	b.muerto_hasta = nil
	obj:set_properties({
		textures = {piel(b.team), "blank.png"},
		nametag = "[Bot] " .. b.nombre,
		nametag_color = color(b.team),
	})
	anim(ent, "stand")
end

local function despejar()
	if ctf_modebase.in_game then
		for team in pairs(bandera_en_bot) do devolver_bandera(team) end
	end
	for _, b in pairs(bots) do
		if b.obj then b.obj:remove() end
	end
	bots = {}
	bandera_en_bot = {}
	bases = {}
	activos = false
	fl_soltar_todo()
end

local function barajar(t)
	local c = {}
	for i, v in ipairs(t) do c[i] = v end
	for i = #c, 2, -1 do
		local j = math.random(i)
		c[i], c[j] = c[j], c[i]
	end
	return c
end

local function desplegar()
	despejar()
	local humanos = minetest.get_connected_players()
	if #humanos == 0 then return end
	local jefe = dueno and minetest.get_player_by_name(dueno) or humanos[1]
	dueno = jefe:get_player_name()
	equipo_aliado = ctf_teams.get(jefe)
	if not equipo_aliado or not pos_bandera(equipo_aliado) then return end   -- aun sin equipo
	equipo_rival = nil
	for _, t in ipairs(ctf_teams.current_team_list or {}) do
		if t ~= equipo_aliado and pos_bandera(t) then
			equipo_rival = t
			break
		end
	end
	if not equipo_rival then return end

	local nombres = barajar(NOMBRES)
	local n = 0
	local function agregar(team, rol)
		n = n + 1
		siguiente_id = siguiente_id + 1
		bots[siguiente_id] = {
			team = team, rol = rol, nombre = nombres[((n - 1) % #nombres) + 1],
			muerto_hasta = ahora() + n * 0.3,   -- aparecen escalonados
		}
	end
	local atacantes = math.ceil(cfg.rivales / 2)
	for i = 1, cfg.rivales do
		agregar(equipo_rival, i <= atacantes and "atacante" or "defensor")
	end
	for _ = 1, cfg.aliados do
		agregar(equipo_aliado, "escolta")
	end

	-- las dos bases quedan cargadas toda la partida
	bases = {fl_tomar(pos_bandera(equipo_rival)), fl_tomar(pos_bandera(equipo_aliado))}
	activos = true

	local partes = {}
	if cfg.rivales > 0 then
		partes[#partes + 1] = cfg.rivales .. " rival(es) en el equipo " .. col(equipo_rival, nombre_equipo(equipo_rival))
	end
	if cfg.aliados > 0 then
		partes[#partes + 1] = cfg.aliados .. " compañero(s) en el equipo " .. col(equipo_aliado, nombre_equipo(equipo_aliado))
	end
	avisar(table.concat(partes, " y ") .. " (" .. DIFICULTADES[cfg.dif].label .. "). Escribe /bots para cambiar.")
end

local function bots_deseados()
	local n = #minetest.get_connected_players()
	return cfg.rivales + cfg.aliados > 0 and n > 0 and n <= MAX_HUMANOS
end

local acumulado = 0
minetest.register_globalstep(function(dtime)
	acumulado = acumulado + dtime
	if acumulado < 1 then return end
	acumulado = 0

	local quiere = bots_deseados() and ctf_modebase.in_game and mapa() ~= nil and not terminando
	if activos and not quiere then
		if #minetest.get_connected_players() > MAX_HUMANOS then
			avisar("Llegaron más jugadores: los bots se retiran. ¡A jugar entre humanos!")
		end
		despejar()
	elseif quiere and not activos then
		desplegar()
	elseif activos then
		-- el dueno se fue o cambio de equipo: rearmar
		local jefe = dueno and minetest.get_player_by_name(dueno)
		if not jefe or ctf_teams.get(jefe) ~= equipo_aliado then
			dueno = nil
			desplegar()
			return
		end
		local t = ahora()
		for id, b in pairs(bots) do
			if not b.obj and b.muerto_hasta and t >= b.muerto_hasta then
				crear_bot(id)
			end
		end
	end
end)

ctf_api.register_on_new_match(function()
	partida = partida + 1
	terminando = false
	despejar()
end)

ctf_api.register_on_match_end(function()
	partida = partida + 1
	despejar()
end)

-- ============================================================
-- MAPAS: con bots, preferir mapas abiertos
-- ============================================================
local function mapas_bots_para(modo)
	local lista = {}
	for _, m in ipairs(ctf_modebase.map_catalog.maps) do
		if MAPAS_BOTS[m.dirname] and (not m.game_modes or table.indexof(m.game_modes, modo) ~= -1) then
			lista[#lista + 1] = m.dirname
		end
	end
	return lista
end

local seleccion_original = ctf_modebase.map_catalog.select_map_for_mode
ctf_modebase.map_catalog.select_map_for_mode = function(modo, ...)
	if not bots_deseados() or #mapas_bots_para(modo) == 0 then
		return seleccion_original(modo, ...)
	end
	ctf_modebase.map_catalog.select_map(function(m)
		return MAPAS_BOTS[m.dirname] and (not m.game_modes or table.indexof(m.game_modes, modo) ~= -1)
	end, true)
end

-- ============================================================
-- MENU
-- ============================================================
local seleccion = {}

local function boton(x, y, w, nombre, etiqueta, activo)
	local s = ""
	if activo then
		s = "style[" .. nombre .. ";bgcolor=#2e8b57;textcolor=#ffffff]"
	end
	return s .. "button[" .. x .. "," .. y .. ";" .. w .. ",0.8;" .. nombre .. ";" ..
		minetest.formspec_escape(etiqueta) .. "]"
end

local function mostrar_menu(pname)
	local s = seleccion[pname]
	if not s then
		s = {rivales = cfg.rivales, aliados = cfg.aliados, dif = cfg.dif}
		if s.rivales + s.aliados == 0 then s.rivales, s.aliados = 3, 2 end
		seleccion[pname] = s
	end
	local fs = {
		"formspec_version[4]",
		"size[11,8.8]",
		"hypertext[0.4,0.3;10.2,1.5;titulo;<global halign=center><big><b>¿Jugar con bots?</b></big>\n" ..
			"Agrega rivales y compañeros que juegan contigo. Tú cuentas en tu equipo: " ..
			"para que sea parejo, elige un compañero menos que rivales.]",
		"label[0.5,2.1;Rivales (equipo contrario):]",
	}
	for i, n in ipairs(OPCIONES_RIVALES) do
		fs[#fs + 1] = boton(0.5 + (i - 1) * 0.92, 2.4, 0.85, "r_" .. n, tostring(n), s.rivales == n)
	end
	fs[#fs + 1] = "label[0.5,3.8;Compañeros (en tu equipo):]"
	for i, n in ipairs(OPCIONES_ALIADOS) do
		fs[#fs + 1] = boton(0.5 + (i - 1) * 0.92, 4.1, 0.85, "a_" .. n, tostring(n), s.aliados == n)
	end
	fs[#fs + 1] = "label[0.5,5.5;Dificultad:]"
	for i, k in ipairs(ORDEN_DIF) do
		fs[#fs + 1] = boton(0.5 + (i - 1) * 3.4, 5.8, 3.2, "d_" .. k, DIFICULTADES[k].label, s.dif == k)
	end
	fs[#fs + 1] = "button_exit[0.5,7.4;4.9,1;jugar;" .. minetest.formspec_escape("¡Jugar!") .. "]"
	fs[#fs + 1] = "button_exit[5.6,7.4;4.9,1;sinbots;Jugar sin bots]"
	minetest.show_formspec(pname, FORM, table.concat(fs))
end

local function cambiar_a_mapa_bots()
	local m = mapa()
	if not (ctf_modebase.in_game and m) or MAPAS_BOTS[m.dirname] then return end
	if #minetest.get_connected_players() ~= 1 or next(ctf_modebase.taken_flags or {}) then return end
	local modo = ctf_modebase.current_mode
	local lista = mapas_bots_para(modo)
	if #lista == 0 then return end
	ctf_modebase.map_on_next_match = lista[math.random(#lista)]
	ctf_modebase.mode_on_next_match = modo
	avisar("Cambiando a un mapa abierto, mejor para los bots...")
	ctf_modebase.start_new_match(3)
end

local function aplicar(pname, s)
	cfg.rivales, cfg.aliados, cfg.dif = s.rivales, s.aliados, s.dif
	guardar_cfg()
	dueno = pname
	despejar()   -- el globalstep los vuelve a desplegar con la nueva config
	if cfg.rivales + cfg.aliados == 0 then
		avisar(pname .. " juega sin bots.")
	else
		cambiar_a_mapa_bots()
	end
end

minetest.register_on_player_receive_fields(function(player, formname, fields)
	if formname ~= FORM then return end
	local pname = player:get_player_name()
	local s = seleccion[pname]
	if not s then return true end

	if fields.jugar then
		aplicar(pname, s)
		seleccion[pname] = nil
		return true
	elseif fields.sinbots then
		aplicar(pname, {rivales = 0, aliados = 0, dif = s.dif})
		seleccion[pname] = nil
		return true
	elseif fields.quit then
		seleccion[pname] = nil
		return true
	end

	for campo in pairs(fields) do
		local tipo, valor = campo:match("^([rad])_(.+)$")
		if tipo == "r" then
			s.rivales = math.min(tonumber(valor) or s.rivales, MAX_BOTS_EQUIPO)
		elseif tipo == "a" then
			s.aliados = math.min(tonumber(valor) or s.aliados, MAX_BOTS_EQUIPO)
		elseif tipo == "d" and DIFICULTADES[valor] then
			s.dif = valor
		end
	end
	mostrar_menu(pname)
	return true
end)

minetest.register_chatcommand("bots", {
	params = "[off]",
	description = "Elegir bots para jugar CTF (rivales, compañeros, dificultad)",
	func = function(pname, param)
		if param == "off" then
			aplicar(pname, {rivales = 0, aliados = 0, dif = cfg.dif})
			return true, "Bots desactivados."
		end
		if #minetest.get_connected_players() > MAX_HUMANOS then
			return false, "Hay más de " .. MAX_HUMANOS .. " jugadores: los bots solo se usan con pocos jugadores."
		end
		mostrar_menu(pname)
		return true
	end,
})

minetest.register_on_joinplayer(function(player)
	local pname = player:get_player_name()
	minetest.after(5, function()
		if not minetest.get_player_by_name(pname) then return end
		if #minetest.get_connected_players() <= MAX_HUMANOS then
			mostrar_menu(pname)
		end
	end)
end)

minetest.register_on_leaveplayer(function(player)
	seleccion[player:get_player_name()] = nil
end)

-- Balas que pegan a los bots. ctf_ranged (process_ray) filtra los impactos con
-- `object = function(obj) return obj:is_player() and obj ~= user end`, asi que el
-- rayo atraviesa cualquier entidad y el bot nunca recibe el punch. Envolvemos
-- rawf.bulletcast (ctf_ranged lo busca en cada disparo, no lo cachea, y
-- spread_bulletcast de la escopeta pasa por el mismo campo) para que el filtro
-- tambien acepte nuestros bots. El dano llega por el punch normal -> on_punch.
local function es_bot(obj)
	local ent = obj and obj:get_luaentity()
	return ent ~= nil and ent.name == ENTIDAD and not ent._muerto
end

if minetest.global_exists("rawf") and type(rawf.bulletcast) == "function" then
	local bulletcast_orig = rawf.bulletcast
	rawf.bulletcast = function(...)
		local bc = bulletcast_orig(...)
		local hit_orig = type(bc) == "table" and rawget(bc, "hit_object_or_node")
		if hit_orig then
			rawset(bc, "hit_object_or_node", function(self, options)
				if options and options.object then
					local filtro = options.object
					options.object = function(obj)
						return es_bot(obj) or filtro(obj)
					end
				end
				return hit_orig(self, options)
			end)
		end
		return bc
	end
else
	minetest.log("warning", "[" .. modname .. "] rawf no encontrado: las balas no pegaran a los bots")
end

minetest.log("warning", "[" .. modname .. "] Loaded successfully")
