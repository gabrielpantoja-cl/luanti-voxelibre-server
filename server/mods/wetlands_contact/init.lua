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

-- Nombre del mundo en los avisos: world_name del wetlands_contact.conf del
-- mundo, o el que corresponde al puerto. El mod puede correr en varios mundos a
-- la vez; cada uno tiene su propio conf y ambos pueden compartir un bot.
local PORT_WORLD_NAMES = {
	["30000"] = "Wetlands",
	["30001"] = "Valdivia",
	["30002"] = "GAELSIN",
	["30003"] = "CTF",
	["30004"] = "Mineclonia",
}
local MIN_CHARS = 2              -- "hola", "ayuda!" valen; solo se rechaza 1 letra suelta
local MAX_CHARS = 300
local PLAYER_COOLDOWN = 15       -- segundos entre mensajes del mismo jugador
local PLAYER_LIMIT = 20          -- mensajes por jugador por WINDOW
local GLOBAL_LIMIT = 100         -- mensajes entre todos los jugadores por WINDOW
local WINDOW = 60 * 60           -- ventana de los limites, en segundos
local DUPLICATE_WINDOW = 3 * 60  -- el mismo mensaje no se repite dentro de este plazo
local HTTP_TIMEOUT = 10
local CONFIG_FILE = minetest.get_worldpath() .. "/wetlands_contact.conf"
local RELAY_DEFAULT_URL = "http://wetlands-contact-relay:8788"
local RELAY_POLL_INTERVAL = 3
local RELAY_KEY_CONTEXT = "wetlands-contact-relay-v1"
local WORLD_IDS_BY_PORT = {
	["30000"] = "original",
	["30001"] = "valdivia",
}

-- Anuncio en el HUD (esquina inferior derecha) al entrar al mundo.
local ANNOUNCE_DELAY = 5     -- segundos tras entrar, para no tapar la carga
local ANNOUNCE_SECONDS = 60  -- cuanto dura en pantalla
local ANNOUNCE_BLINK = 0.8   -- periodo del parpadeo entre ANNOUNCE_COLORS
local ANNOUNCE_COLORS = {0xFFE000, 0xFF8000}
local ANNOUNCE_OFFSET = {x = -24, y = -110}

-- abierto: cualquier jugador con "shout" (wetlands_newplayer se lo garantiza
-- a todos en cada ingreso); pausa: nadie. Vive en mod_storage para que el
-- admin lo cambie en caliente con /gabo_admin sin tocar el mod ni reiniciar.
-- No hay privilegio propio: wetlands_newplayer quita en cada ingreso toda
-- priv que no este en su lista, asi que un /grant no duraria. Un "piloto"
-- guardado por una version anterior se trata como "abierto".
local MODES = {abierto = true, pausa = true}
local DEFAULT_MODE = "abierto"

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

local function read_conf()
	local ok, conf = pcall(Settings, CONFIG_FILE)
	if ok and conf then
		return conf
	end
	return nil
end

local function world_name()
	local conf = read_conf()
	local name = conf and conf:get("world_name")
	if name and name ~= "" then
		return name
	end
	return PORT_WORLD_NAMES[minetest.settings:get("port") or ""] or "Luanti"
end

local function world_id()
	local expected = WORLD_IDS_BY_PORT[minetest.settings:get("port") or ""]
	local conf = read_conf()
	local configured = conf and conf:get("world_id")
	if configured == "original" or configured == "valdivia" then
		if expected and configured ~= expected then
			minetest.log("error", "[" .. modname .. "] world_id no coincide con el puerto")
			return nil
		end
		return configured
	end
	return expected
end

-- {api = "<base>/bot<token>", chat_id = "<chat del admin>"} o nil.
local function telegram_bot(conf)
	local token = conf:get("telegram_token")
	local chat_id = conf:get("telegram_chat_id")
	if not token or token == "" or not chat_id or chat_id == "" then
		return nil
	end
	-- telegram_api solo se cambia para apuntar al simulador en pruebas.
	local api = conf:get("telegram_api") or "https://api.telegram.org"
	return {api = api .. "/bot" .. token, chat_id = chat_id}
end

local function telegram_message(bot, text)
	return {
		url = bot.api .. "/sendMessage",
		-- Sin parse_mode: el texto se muestra tal cual, sin interpretar formato.
		data = minetest.write_json({
			chat_id = bot.chat_id,
			text = text,
			disable_web_page_preview = true,
		}),
	}
end

-- Cada destino arma la peticion HTTP (url + cuerpo JSON) para un texto, o
-- devuelve nil si a la config le faltan datos. Ojo: el token de Telegram y el
-- del webhook de Discord van DENTRO de la URL, y el motor escribe la URL en
-- ERROR[CurlFetch] cuando un envio falla. Por eso aqui no se loguea nunca la
-- URL, pero los logs del servidor deben tratarse como privados.
local DESTINATIONS = {
	telegram = function(conf, text)
		local bot = telegram_bot(conf)
		return bot and telegram_message(bot, text)
	end,
	discord = function(conf, text)
		local url = conf:get("discord_webhook")
		if not url or not url:match("^https?://") then
			return nil
		end
		-- write_json convierte {} en null, asi que allowed_mentions se agrega
		-- a mano: "parse":[] impide que un "@everyone" del jugador notifique a
		-- todo el servidor de Discord.
		local body = minetest.write_json({username = world_name(), content = text})
		return {
			url = url,
			data = body:sub(1, -2) .. ',"allowed_mentions":{"parse":[]}}',
		}
	end,
}

-- Devuelve {name = destino, build = function(text) -> peticion} o nil.
local function load_destination()
	local conf = read_conf()
	if not conf then
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

-- Si el jugador puede usar /gabo segun el modo y su "shout" (sin mirar
-- limites de frecuencia). Tambien decide a quien se le muestra el anuncio.
local function has_access(name)
	if not http or not load_destination() then
		return false, S("Messages to gabo are not available right now.")
	end
	if not minetest.check_player_privs(name, {shout = true}) then
		return false, S("You cannot send messages right now.")
	end
	if get_mode() == "pausa" then
		return false, S("Messages to gabo are paused for now. Please try again later.")
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
local request_counter = 0

local function player_hex(name)
	return (name:gsub(".", function(char)
		return string.format("%02x", char:byte())
	end))
end

local function new_request_id(id, name)
	request_counter = request_counter + 1
	return minetest.sha256(table.concat({
		id,
		name,
		tostring(os.time()),
		tostring(minetest.get_us_time()),
		tostring(request_counter),
	}, ":"))
end

local function admin_text(name, message)
	return "🌿 " .. world_name() .. " — mensaje para gabo\n" ..
		"Jugador: " .. name .. "\n" ..
		"Mensaje: " .. message
end

local function telegram_admin_text(id, name, message, request_id)
	return admin_text(name, message) .. "\n\n" ..
		"[[wetlands_contact:v1;world=" .. id .. ";player_hex=" ..
		player_hex(name) .. ";request=" .. request_id .. "]]"
end

local function send_message(name, message)
	local dest = load_destination()
	if not dest then
		notify(name, S("Your message could not be sent right now. Please try again later."))
		return
	end
	local text = admin_text(name, message)
	if dest.name == "telegram" then
		local id = world_id()
		if not id then
			notify(name, S("Your message could not be sent right now. Please try again later."))
			return
		end
		local request_id = new_request_id(id, name)
		text = telegram_admin_text(id, name, message, request_id)
	end
	local req = dest.build(text)
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

-- Las respuestas llegan desde el relay interno. Solo el sidecar consume
-- getUpdates; cada mundo pide exclusivamente la cola del jugador conectado.
local REPLY_PREFIX = minetest.colorize("#FFB000", "[gabo]") .. " "
local relay_inflight = {}

local function delivered_key(name)
	return "relay_delivered:" .. name
end

local function load_delivered(name, now)
	local value = minetest.parse_json(storage:get_string(delivered_key(name)), nil, true)
	local delivered = type(value) == "table" and value or {}
	local entries = {}
	for update_id, timestamp in pairs(delivered) do
		if type(timestamp) ~= "number" or now - timestamp > 8 * 24 * 60 * 60 then
			delivered[update_id] = nil
		else
			entries[#entries + 1] = {id = update_id, timestamp = timestamp}
		end
	end
	-- Acota el mod_storage incluso si el relay estuvo inaccesible para recibir ACKs.
	table.sort(entries, function(a, b) return a.timestamp > b.timestamp end)
	for i = 101, #entries do
		delivered[entries[i].id] = nil
	end
	return delivered
end

local function save_delivered(name, delivered)
	storage:set_string(delivered_key(name), minetest.write_json(delivered))
end

local function relay_config()
	local conf = read_conf()
	local id = world_id()
	if not conf or not id or (conf:get("destination") or "telegram") ~= "telegram" then
		return nil
	end
	local token = conf:get("telegram_token")
	if not token or token == "" then
		return nil
	end
	local url = conf:get("relay_url") or RELAY_DEFAULT_URL
	if not url:match("^https?://[%w%.%-]+:?%d*$") then
		return nil
	end
	return {
		world_id = id,
		url = url,
		key = minetest.sha256(RELAY_KEY_CONTEXT .. ":" .. token .. ":" .. id),
	}
end

local function relay_ack(relay, name, update_id)
	http.fetch({
		url = relay.url .. "/v1/ack?world_id=" .. relay.world_id ..
			"&player=" .. minetest.urlencode(name),
		method = "POST",
		timeout = HTTP_TIMEOUT,
		extra_headers = {
			"Content-Type: application/json",
			"X-Wetlands-Relay-Key: " .. relay.key,
		},
		data = minetest.write_json({update_id = update_id}),
	}, function(res)
		if not (res.succeeded and res.code >= 200 and res.code < 300) then
			minetest.log("warning", "[" .. modname .. "] ACK del relay pendiente para " .. name)
		end
	end)
end

local function handle_relay_messages(relay, name, messages)
	local delivered = load_delivered(name, os.time())
	for _, message in ipairs(messages) do
		local update_id = type(message.update_id) == "number" and
			string.format("%.0f", message.update_id) or tostring(message.update_id or "")
		local valid = update_id:match("^%d+$") and message.world_id == relay.world_id and
			message.player == name and type(message.text) == "string" and
			utf8_len(message.text) > 0 and utf8_len(message.text) <= 500
		if valid then
			if not delivered[update_id] then
				local player = minetest.get_player_by_name(name)
				if not player then
					return
				end
				minetest.chat_send_player(name, REPLY_PREFIX .. message.text)
				delivered[update_id] = os.time()
				save_delivered(name, delivered)
				minetest.log("action", "[" .. modname .. "] respuesta privada entregada a " .. name)
			end
			relay_ack(relay, name, update_id)
		else
			minetest.log("warning", "[" .. modname .. "] respuesta invalida recibida del relay")
		end
	end
end

local function poll_relay_for_player(name)
	if relay_inflight[name] or not minetest.get_player_by_name(name) then
		return
	end
	local relay = relay_config()
	if not relay then
		return
	end
	relay_inflight[name] = true
	http.fetch({
		url = relay.url .. "/v1/messages?world_id=" .. relay.world_id ..
			"&player=" .. minetest.urlencode(name),
		timeout = HTTP_TIMEOUT,
		extra_headers = {"X-Wetlands-Relay-Key: " .. relay.key},
	}, function(res)
		relay_inflight[name] = nil
		local data = res.succeeded and res.code == 200 and
			minetest.parse_json(res.data, nil, true)
		if type(data) == "table" and data.ok == true and type(data.messages) == "table" then
			handle_relay_messages(relay, name, data.messages)
		end
	end)
end

local function poll_relay()
	for _, player in ipairs(minetest.get_connected_players()) do
		poll_relay_for_player(player:get_player_name())
	end
	minetest.after(RELAY_POLL_INTERVAL, poll_relay)
end

if http then
	minetest.after(5, poll_relay)
end

-- Anuncio parpadeante en la esquina inferior derecha. Se dibuja dos veces
-- (sombra negra desplazada + texto de color) para que se lea sobre cielo,
-- nieve o arena.
local function show_announcement(name)
	local player = minetest.get_player_by_name(name)
	if not player or not announce_enabled() or not has_access(name) then
		return
	end
	local text = S("Type /gabo <message>") .. "\n" ..
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
	minetest.after(1, poll_relay_for_player, name)
end)

minetest.register_chatcommand("gabo_admin", {
	params = "<abierto|pausa|estado|anuncio on|anuncio off>",
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
			return false, "Uso: /gabo_admin <abierto|pausa|estado|anuncio on|anuncio off>"
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
