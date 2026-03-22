-- wetlands_fixlight: Recalcular luz en todo el mundo
-- Se ejecuta automaticamente al iniciar el servidor (sin jugadores)
-- Guarda progreso en mod_storage para resumir si se reinicia
-- Tambien disponible via /fixlight_world y /fixlight_stop

local CHUNK_SIZE = 32  -- nodos por lado por chunk (2 mapblocks)
local EMERGE_DELAY = 1.0  -- segundos entre chunks (sin jugadores no hay timeout)
local STARTUP_DELAY = 10  -- segundos antes de iniciar automaticamente
local LOG_INTERVAL = 100  -- logear progreso cada N chunks
local SAVE_INTERVAL = 50  -- guardar progreso cada N chunks

local storage = minetest.get_mod_storage()
local running = false

-- World bounds (from map.sqlite analysis of Valdivia v4)
local WORLD_MIN = {x = 0, y = -64, z = -5792}
local WORLD_MAX = {x = 7695, y = 63, z = -1}

local function build_chunks()
    local chunks = {}
    for x = WORLD_MIN.x, WORLD_MAX.x, CHUNK_SIZE do
        for z = WORLD_MIN.z, WORLD_MAX.z, CHUNK_SIZE do
            table.insert(chunks, {
                min = {x = x, y = WORLD_MIN.y, z = z},
                max = {
                    x = math.min(x + CHUNK_SIZE - 1, WORLD_MAX.x),
                    y = WORLD_MAX.y,
                    z = math.min(z + CHUNK_SIZE - 1, WORLD_MAX.z),
                },
            })
        end
    end
    return chunks
end

local function start_fixlight(start_from)
    if running then
        minetest.log("warning", "[fixlight] Ya hay un proceso en progreso")
        return false
    end

    local chunks = build_chunks()
    local total = #chunks
    local current = start_from or 0
    running = true

    minetest.log("action", "[fixlight] Iniciando desde chunk " ..
        current .. "/" .. total)

    local function process_next()
        if not running then
            minetest.log("action", "[fixlight] Cancelado en chunk " .. current)
            return
        end

        current = current + 1
        if current > total then
            running = false
            storage:set_string("completed", "true")
            storage:set_int("current_chunk", total)
            minetest.log("action",
                "[fixlight] COMPLETADO! " .. total .. " chunks procesados")
            return
        end

        local chunk = chunks[current]
        local p1 = vector.new(chunk.min.x, chunk.min.y, chunk.min.z)
        local p2 = vector.new(chunk.max.x, chunk.max.y, chunk.max.z)

        minetest.emerge_area(p1, p2, function(blockpos, action, calls_remaining)
            if calls_remaining == 0 then
                minetest.fix_light(p1, p2)

                -- Log progress
                if current % LOG_INTERVAL == 0 then
                    local pct = math.floor(current / total * 100)
                    minetest.log("action", "[fixlight] Progreso: " ..
                        current .. "/" .. total .. " (" .. pct .. "%)")
                end

                -- Save progress to mod_storage
                if current % SAVE_INTERVAL == 0 then
                    storage:set_int("current_chunk", current)
                end

                -- Notify connected players
                if current % math.max(1, math.floor(total / 10)) == 0 then
                    local pct = math.floor(current / total * 100)
                    for _, player in ipairs(minetest.get_connected_players()) do
                        minetest.chat_send_player(player:get_player_name(),
                            "[fixlight] Progreso: " .. pct .. "%")
                    end
                end

                minetest.after(EMERGE_DELAY, process_next)
            end
        end)
    end

    minetest.after(0.1, process_next)
    return true
end

-- Auto-start on server boot if not completed
minetest.after(STARTUP_DELAY, function()
    local completed = storage:get_string("completed")
    if completed == "true" then
        minetest.log("action",
            "[fixlight] Luz ya fue corregida previamente. Saltando.")
        return
    end

    local resume_from = storage:get_int("current_chunk")  -- 0 if not set
    minetest.log("action",
        "[fixlight] Auto-inicio: corrigiendo luz del mundo Valdivia...")
    start_fixlight(resume_from)
end)

-- Manual commands (still available)
minetest.register_chatcommand("fixlight_world", {
    params = "",
    description = "Recalcular luz en todo el mundo (para mapas Arnis)",
    privs = {server = true},
    func = function(name, param)
        -- Reset completion flag to allow re-run
        storage:set_string("completed", "")
        storage:set_int("current_chunk", 0)
        local ok = start_fixlight(0)
        if ok then
            return true, "Proceso iniciado. Progreso visible en logs del servidor."
        else
            return false, "Ya hay un proceso en progreso."
        end
    end,
})

minetest.register_chatcommand("fixlight_stop", {
    params = "",
    description = "Cancelar fixlight en progreso (guarda progreso)",
    privs = {server = true},
    func = function(name, param)
        if not running then
            return false, "No hay fixlight en progreso."
        end
        running = false
        return true, "Cancelando... el progreso queda guardado y se reanuda al reiniciar."
    end,
})

minetest.register_chatcommand("fixlight_status", {
    params = "",
    description = "Ver estado del fixlight",
    privs = {server = true},
    func = function(name, param)
        local completed = storage:get_string("completed")
        local saved_chunk = storage:get_int("current_chunk")
        local total = #build_chunks()
        if completed == "true" then
            return true, "Fixlight completado (" .. total .. " chunks)."
        elseif running then
            return true, "En progreso: chunk " .. saved_chunk .. "/" .. total
        else
            return true, "Detenido en chunk " .. saved_chunk .. "/" .. total ..
                ". Se reanudara al reiniciar el servidor."
        end
    end,
})
