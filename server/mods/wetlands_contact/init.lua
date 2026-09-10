-- wetlands_contact
--
-- /gabo <mensaje>: un jugador de Wetlands envia un mensaje breve que llega
-- al celular del administrador por Telegram (bot) o Discord (webhook), con un
-- POST HTTPS asincrono directo, sin servicios intermedios.
--
-- Las credenciales (token del bot o URL del webhook) se leen en cada envio de
-- <worldpath>/wetlands_contact.conf, que vive fuera de git y lo gestiona
-- operaciones. Formato y advertencias: README.md.
--
-- Wetlands recibe jugadores de muchos paises: los textos para jugadores estan
-- en ingles y locale/wetlands_contact.es.tr los traduce para clientes en
-- espanol. Los mensajes de /gabo_admin (solo admin) y los logs van en espanol.

local modname = minetest.get_current_modname()
local S = minetest.get_translator(modname)
local storage = minetest.get_mod_storage()

-- Solo puede pedirse durante la carga del mod. Devuelve nil si el mod no esta
-- listado en secure.http_mods; en ese caso /gabo responde "no disponible".
local http = minetest.request_http_api()

local WORLD_NAME = "Wetlands"
local MIN_CHARS = 2              -- "hola", "ayuda!" valen; solo se rechaza 1 letra suelta
local MAX_CHARS = 300
local PLAYER_COOLDOWN = 15       -- segundos entre mensajes del mismo jugador
local PLAYER_LIMIT = 20          -- mensajes por jugador por WINDOW
local GLOBAL_LIMIT = 100         -- mensajes entre todos los jugadores por WINDOW
local WINDOW = 60 * 60           -- ventana de los limites, en segundos
local DUPLICATE_WINDOW = 3 * 60  -- el mismo mensaje no se repite dentro de este plazo
local HTTP_TIMEOUT = 10
local CONFIG_FILE = minetest.get_worldpath() .. "/wetlands_contact.conf"

-- Anuncio en el HUD (esquina inferior derecha) al entrar al mundo.
local ANNOUNCE_DELAY = 5     -- segundos tras entrar, para no tapar la carga
local ANNOUNCE_SECONDS = 60  -- cuanto dura en pantalla
local ANNOUNCE_BLINK = 0.8   -- periodo del parpadeo entre ANNOUNCE_COLORS
local ANNOUNCE_COLORS = {0xFFE000, 0xFF8000}
local ANNOUNCE_OFFSET = {x = -24, y = -110}

-- piloto: solo jugadores con el privilegio "avisar"; abierto: cualquiera con
-- "shout"; pausa: nadie. Vive en mod_storage para que el admin lo cambie en
-- caliente con /gabo_admin sin tocar el mod ni reiniciar.
local MODES = {piloto = true, abierto = true, pausa = true}
local DEFAULT_MODE = "piloto"

-- Terminaciones de dominio que delatan un enlace aunque no lleve "http".
local LINK_TLDS = {
	"com", "cl", "net", "org", "io", "gg", "me", "ly", "co", "xyz",
	"tk", "app", "dev", "tv", "link", "info", "es", "ar", "mx",
}

local function safety_text()
	return S("Do not write your real name, phone number, address, passwords " ..
		"or other personal data. This is help for the game, not an emergency " ..
		"service: if you are in danger, talk to a trusted adult.")
end

local inflight = {} -- name -> true mientras se espera la respuesta del destino

minetest.register_privilege("avisar", {
	description = S("Can send messages to the admin with /gabo during the pilot"),
	give_to_singleplayer = false,
	give_to_admin = true,
})

local function get_mode()
	local mode = storage:get_string("mode")
	if MODES[mode] then
		return mode
	end
	return DEFAULT_MODE
end

local function announce_enabled()
	return storage:get_string("announce") ~= "off"
end

-- Cada destino arma la peticion HTTP (url + cuerpo JSON) para un texto, o
-- devuelve nil si a la config le faltan datos. Ojo: el token de Telegram y el
-- del webhook de Discord van DENTRO de la URL, y el motor escribe la URL en
-- ERROR[CurlFetch] cuando un envio falla. Por eso aqui no se loguea nunca la
-- URL, pero los logs del servidor deben tratarse como privados.
local DESTINATIONS = {
	telegram = function(conf, text)
		local token = conf:get("telegram_token")
		local chat_id = conf:get("telegram_chat_id")
		if not token or token == "" or not chat_id or chat_id == "" then
			return nil
		end
		-- telegram_api solo se cambia para apuntar al simulador en pruebas.
		local api = conf:get("telegram_api") or "https://api.telegram.org"
		return {
			url = api .. "/bot" .. token .. "/sendMessage",
			-- Sin parse_mode: el texto del jugador se muestra tal cual, sin
			-- interpretar formato.
			data = minetest.write_json({
				chat_id = chat_id,
				text = text,
				disable_web_page_preview = true,
			}),
		}
	end,
	discord = function(conf, text)
		local url = conf:get("discord_webhook")
		if not url or not url:match("^https?://") then
			return nil
		end
		-- write_json convierte {} en null, asi que allowed_mentions se agrega
		-- a mano: "parse":[] impide que un "@everyone" del jugador notifique a
		-- todo el servidor de Discord.
		local body = minetest.write_json({username = WORLD_NAME, content = text})
		return {
			url = url,
			data = body:sub(1, -2) .. ',"allowed_mentions":{"parse":[]}}',
		}
	end,
}

-- Devuelve {name = destino, build = function(text) -> peticion} o nil.
local function load_destination()
	local ok, conf = pcall(Settings, CONFIG_FILE)
	if not ok or not conf then
		return nil
	end
	local name = conf:get("destination") or "telegram"
	local builder = DESTINATIONS[name]
	if not builder or not builder(conf, "") then
		return nil
	end
	return {
		name = name,
		build = function(text)
			return builder(conf, text)
		end,
	}
end

-- Marcas de tiempo de los envios recientes (en orden), guardadas como
-- "t1,t2,..." para que los limites sobrevivan a un reinicio. Una lista global
-- ("global_sends") y una por jugador ("sends:<nombre>").
local function load_sends(key, now)
	local sends = {}
	for ts in storage:get_string(key):gmatch("%d+") do
		ts = tonumber(ts)
		if now - ts < WINDOW then
			sends[#sends + 1] = ts
		end
	end
	return sends
end

local function save_sends(key, sends)
	storage:set_string(key, table.concat(sends, ","))
end

local function utf8_len(s)
	return select(2, s:gsub("[^\128-\191]", ""))
end

-- Se guarda el hash, no el texto, para detectar repeticiones sin conservar
-- el mensaje del jugador.
local function message_hash(message)
	return minetest.sha1(message:lower())
end

-- Si el jugador puede usar /gabo segun el modo y sus privilegios (sin mirar
-- limites de frecuencia). Tambien decide a quien se le muestra el anuncio.
local function has_access(name)
	if not http or not load_destination() then
		return false, S("Messages to gabo are not available right now.")
	end
	if not minetest.check_player_privs(name, {shout = true}) then
		return false, S("You cannot send messages right now.")
	end
	local mode = get_mode()
	if mode == "pausa" then
		return false, S("Messages to gabo are paused for now. Please try again later.")
	end
	if mode == "piloto" and not minetest.check_player_privs(name, {avisar = true}) then
		return false, S("Messages to gabo are being tested and are not available to everyone yet.")
	end
	return true
end

-- Devuelve true o false + motivo legible para el jugador.
local function can_send(name)
	local ok, reason = has_access(name)
	if not ok then
		return false, reason
	end
	if inflight[name] then
		return false, S("Your previous message is still being sent. Please wait a moment.")
	end
	local now = os.time()
	-- Los admins pueden probar sin esperar; el limite global si les aplica.
	if not minetest.check_player_privs(name, {server = true}) then
		local sends = load_sends("sends:" .. name, now)
		local last = sends[#sends]
		if last and now - last < PLAYER_COOLDOWN then
			return false, S("Please wait @1 second(s) before sending another message.",
				PLAYER_COOLDOWN - (now - last))
		end
		if #sends >= PLAYER_LIMIT then
			return false, S("You have sent a lot of messages. You can send more in @1 minute(s).",
				math.ceil((WINDOW - (now - sends[1])) / 60))
		end
	end
	if #load_sends("global_sends", now) >= GLOBAL_LIMIT then
		return false, S("There are a lot of messages right now. Please try again later.")
	end
	return true
end

local function normalize(raw)
	local s = minetest.strip_colors(raw or "")
	s = s:gsub("%c", " ")
	s = s:gsub("%s+", " ")
	return s:match("^%s*(.-)%s*$")
end

local function has_link(lower)
	if lower:find("://", 1, true) or lower:find("www.", 1, true) then
		return true
	end
	for _, tld in ipairs(LINK_TLDS) do
		if lower:find("[%w%-]%." .. tld .. "%f[^%w]") then
			return true
		end
	end
	return false
end

local function has_personal_data(s)
	-- Telefono: 8 o mas digitos, admitiendo los separadores habituales.
	for run in s:gmatch("%d[%d%s%-%.%(%)%+]*%d") do
		if select(2, run:gsub("%d", "")) >= 8 then
			return true
		end
	end
	if s:find("[%w%._%-%+]+@[%w%-]+%.%a+") then
		return true
	end
	return false
end

local function is_spammy(lower)
	-- Mismo caracter 8+ veces seguidas ("aaaaaaaa", "!!!!!!!!").
	if lower:find("(.)%1%1%1%1%1%1%1") then
		return true
	end
	-- Misma palabra 4+ veces seguidas.
	if (" " .. lower .. " "):find(" (%S+) %1 %1 %1 ") then
		return true
	end
	-- Mensajes largos con casi ningun caracter distinto ("jajajajaja...").
	if utf8_len(lower) >= 20 then
		local seen, distinct = {}, 0
		for c in lower:gmatch("%S") do
			if not seen[c] then
				seen[c] = true
				distinct = distinct + 1
			end
		end
		if distinct < 5 then
			return true
		end
	end
	return false
end

-- Devuelve el texto limpio, o nil + motivo para el jugador.
local function validate_message(name, raw)
	local clean = normalize(raw)
	local len = utf8_len(clean)
	if len < MIN_CHARS then
		return nil, S("Please write a slightly longer message so gabo can understand it.")
	end
	if len > MAX_CHARS then
		return nil, S("Your message has @1 characters; the maximum is @2.", len, MAX_CHARS)
	end
	-- Datos personales antes que enlaces: un correo tambien parece un dominio.
	if has_personal_data(clean) then
		return nil, S("It looks like you wrote a phone number or an email. For your safety, please remove it.")
	end
	local lower = clean:lower()
	if has_link(lower) then
		return nil, S("Messages cannot include links or web addresses.")
	end
	if is_spammy(lower) then
		return nil, S("Your message has too many repetitions. Please write it more clearly.")
	end
	-- "dup:<nombre>" = "<hash>:<epoch>" del ultimo mensaje entregado.
	local dup_hash, dup_at = storage:get_string("dup:" .. name):match("^(%x+):(%d+)$")
	if dup_hash == message_hash(clean) and os.time() - tonumber(dup_at) < DUPLICATE_WINDOW then
		return nil, S("You already sent this same message. No need to repeat it.")
	end
	return clean
end

local function notify(name, text)
	minetest.chat_send_player(name, "[gabo] " .. text)
end

-- Lo que recibe el admin en el celular. Sin IP, coordenadas ni datos del
-- cliente: solo mundo, jugador y mensaje.
local function admin_text(name, message)
	return "🌿 " .. WORLD_NAME .. " — mensaje para gabo\n" ..
		"Jugador: " .. name .. "\n" ..
		"Mensaje: " .. message
end

local function send_message(name, message)
	local dest = load_destination()
	local req = dest.build(admin_text(name, message))
	local now = os.time()

	-- Se registra antes de enviar: ni un comando repetido ni un destino lento
	-- permiten rebasar los limites.
	local player_key = "sends:" .. name
	for _, key in ipairs({player_key, "global_sends"}) do
		local sends = load_sends(key, now)
		sends[#sends + 1] = now
		save_sends(key, sends)
	end
	inflight[name] = true

	http.fetch({
		url = req.url,
		method = "POST",
		timeout = HTTP_TIMEOUT,
		extra_headers = {"Content-Type: application/json"},
		data = req.data,
	}, function(res)
		inflight[name] = nil
		if res.succeeded and res.code >= 200 and res.code < 300 then
			storage:set_string("dup:" .. name, message_hash(message) .. ":" .. now)
			minetest.log("action", "[" .. modname .. "] mensaje de " .. name ..
				" entregado a " .. dest.name)
			notify(name, S("Done! Your message will reach gabo. Thank you."))
		else
			-- El fallo no es culpa del jugador: le devolvemos su turno. El
			-- limite global se mantiene para no martillar un destino caido.
			local sends = load_sends(player_key, os.time())
			for i = #sends, 1, -1 do
				if sends[i] == now then
					table.remove(sends, i)
					break
				end
			end
			save_sends(player_key, sends)
			minetest.log("warning", "[" .. modname .. "] mensaje de " .. name ..
				" NO entregado a " .. dest.name .. ": code=" .. tostring(res.code) ..
				" timeout=" .. tostring(res.timeout))
			notify(name, S("Your message could not be sent right now. Please try again later."))
		end
	end)
end

minetest.register_chatcommand("gabo", {
	params = S("<message>"),
	description = S("Send a short message to the admin gabo (max. @1 characters)", MAX_CHARS),
	func = function(name, param)
		local ok, reason = can_send(name)
		if not ok then
			return false, reason
		end
		if param:trim() == "" then
			return true, S("Usage: /gabo <your message>") .. ". " .. safety_text()
		end
		local clean, err = validate_message(name, param)
		if not clean then
			return false, err
		end
		send_message(name, clean)
		return true, S("Sending your message to gabo...")
	end,
})

-- Anuncio parpadeante en la esquina inferior derecha. Se dibuja dos veces
-- (sombra negra desplazada + texto de color) para que se lea sobre cielo,
-- nieve o arena.
local function show_announcement(name)
	local player = minetest.get_player_by_name(name)
	if not player or not announce_enabled() or not has_access(name) then
		return
	end
	local text = S("Need help? Type /gabo <message>") .. "\n" ..
		S("to write directly to the admin")
	local base = {
		type = "text",
		position = {x = 1, y = 1},
		alignment = {x = -1, y = -1},
		-- 1.5 en clientes >= 5.16; los anteriores redondean hacia abajo (1).
		size = {x = 1.5},
		style = 1,
		text = text,
	}
	local shadow = table.copy(base)
	shadow.number = 0x000000
	shadow.offset = {x = ANNOUNCE_OFFSET.x + 2, y = ANNOUNCE_OFFSET.y + 2}
	shadow.z_index = 99
	local label = table.copy(base)
	label.number = ANNOUNCE_COLORS[1]
	label.offset = ANNOUNCE_OFFSET
	label.z_index = 100
	local ids = {player:hud_add(shadow), player:hud_add(label)}

	local elapsed, tick = 0, 1
	local function step()
		local p = minetest.get_player_by_name(name)
		if not p then
			return
		end
		elapsed = elapsed + ANNOUNCE_BLINK
		if elapsed >= ANNOUNCE_SECONDS then
			for _, id in ipairs(ids) do
				p:hud_remove(id)
			end
			return
		end
		tick = tick % #ANNOUNCE_COLORS + 1
		p:hud_change(ids[2], "number", ANNOUNCE_COLORS[tick])
		minetest.after(ANNOUNCE_BLINK, step)
	end
	minetest.after(ANNOUNCE_BLINK, step)
end

minetest.register_on_joinplayer(function(player)
	local name = player:get_player_name()
	minetest.after(ANNOUNCE_DELAY, show_announcement, name)
end)

minetest.register_chatcommand("gabo_admin", {
	params = "<piloto|abierto|pausa|estado|anuncio on|anuncio off>",
	description = "Controla el sistema de mensajes /gabo",
	privs = {server = true},
	func = function(name, param)
		param = param:trim():lower()
		if param == "" or param == "estado" then
			local dest = load_destination()
			return true, string.format(
				"/gabo: modo=%s | anuncio=%s | http=%s | destino=%s | ultima hora: %d/%d",
				get_mode(),
				announce_enabled() and "on" or "off",
				http and "si" or "NO (falta secure.http_mods)",
				dest and dest.name or "SIN CONFIGURAR",
				#load_sends("global_sends", os.time()), GLOBAL_LIMIT)
		end
		local announce = param:match("^anuncio%s+(%a+)$")
		if announce == "on" or announce == "off" then
			storage:set_string("announce", announce)
			minetest.log("action", "[" .. modname .. "] " .. name .. " puso el anuncio en " .. announce)
			return true, "Anuncio de /gabo: " .. announce
		end
		if not MODES[param] then
			return false, "Uso: /gabo_admin <piloto|abierto|pausa|estado|anuncio on|anuncio off>"
		end
		storage:set_string("mode", param)
		minetest.log("action", "[" .. modname .. "] " .. name .. " cambio el modo a " .. param)
		return true, "Modo de /gabo: " .. param
	end,
})

if not http then
	minetest.log("warning", "[" .. modname .. "] sin API HTTP: agrega " .. modname ..
		" a secure.http_mods; /gabo quedara no disponible")
elseif not load_destination() then
	minetest.log("warning", "[" .. modname .. "] falta o esta incompleto " .. CONFIG_FILE ..
		" (telegram_token + telegram_chat_id, o destination = discord + discord_webhook);" ..
		" /gabo quedara no disponible")
end

minetest.log("action", "[" .. modname .. "] Loaded successfully - modo " .. get_mode())
