-- wetlands_rollback_flush
--
-- PROBLEMA QUE RESUELVE
-- Luanti 5.16.1 (src/server/rollback.cpp) NO tiene volcado periodico del
-- registro de rollback. RollbackManager::addAction() acumula las acciones en
-- RAM (action_todisk_buffer) y solo llama a flush() en tres casos:
--   1. el buffer alcanza 500 acciones,
--   2. alguien ejecuta /rollback_check o /rollback (getNodeActors /
--      getRevertActions llaman a flush() antes de consultar),
--   3. el servidor apaga limpiamente (destructor ~RollbackManager).
-- Si el proceso muere sin destructor -- p.ej. `docker stop` agota su plazo de
-- 10 s en un mundo grande y Docker manda SIGKILL -- se pierden hasta 499
-- acciones sin ningun error en el log.
--
-- Eso fue exactamente lo que paso en Wetlands: rollback.sqlite quedo con su
-- ultima accion el 2026-08-11 20:05:12 pese a que hubo jugadores hasta el
-- 2026-08-26. Nunca hubo error; simplemente el buffer nunca se volco.
--
-- SOLUCION
-- core.rollback_get_node_actions() entra por RollbackManager::getNodeActors(),
-- que llama a flush() antes de consultar. Una consulta minima (rango 1,
-- ventana 1 segundo, limite 1) es practicamente gratis y garantiza que el
-- buffer llegue a disco cada FLUSH_INTERVAL segundos.

local modname = minetest.get_current_modname()

-- Cada cuantos segundos se fuerza el volcado. 60 s acota la perdida maxima
-- ante un SIGKILL a un minuto de actividad.
local FLUSH_INTERVAL = 60

-- Posicion sonda para la consulta. Da igual cual sea: lo que importa es el
-- flush() que ocurre antes de leer.
local PROBE_POS = {x = 0, y = 0, z = 0}

if not minetest.settings:get_bool("enable_rollback_recording") then
	minetest.log("warning", "[" .. modname .. "] enable_rollback_recording = false: " ..
		"no hay buffer que volcar, el mod queda inactivo")
	return
end

local function force_flush()
	local ok, err = pcall(minetest.rollback_get_node_actions, PROBE_POS, 1, 1, 1)
	if not ok then
		minetest.log("error", "[" .. modname .. "] fallo al forzar flush: " .. tostring(err))
	end
	return ok
end

local function schedule_flush()
	force_flush()
	minetest.after(FLUSH_INTERVAL, schedule_flush)
end

minetest.after(FLUSH_INTERVAL, schedule_flush)

-- Volcado inmediato bajo demanda, util para verificar tras una prueba.
minetest.register_chatcommand("rollback_flush", {
	description = "Fuerza el volcado inmediato del buffer de rollback a rollback.sqlite",
	privs = {server = true},
	func = function(name)
		if force_flush() then
			return true, "Buffer de rollback volcado a rollback.sqlite"
		end
		return false, "Error al volcar el buffer, revisa debug.txt"
	end,
})

-- Un apagado limpio ya ejecuta el destructor, pero si el mod esta cargado
-- aprovechamos para dejar el buffer vacio lo antes posible.
minetest.register_on_shutdown(force_flush)

minetest.log("action", "[" .. modname .. "] Loaded successfully - flush cada " ..
	FLUSH_INTERVAL .. "s")
