-- wetlands_fixlight: Recalcular luz en todo el mundo
-- Procesa el mundo en chunks para no crashear el servidor
-- Uso: /fixlight_world

local CHUNK_SIZE = 80  -- nodos por lado por chunk (5 mapblocks)
local EMERGE_DELAY = 0.5  -- segundos entre chunks

local running = false

minetest.register_chatcommand("fixlight_world", {
    params = "",
    description = "Recalcular luz en todo el mundo (para mapas Arnis)",
    privs = {server = true},
    func = function(name, param)
        if running then
            return false, "Ya hay un fixlight_world en progreso. Espera a que termine."
        end

        -- World bounds (from map.sqlite analysis)
        local world_min = {x = 0, y = -64, z = -5792}
        local world_max = {x = 7695, y = 63, z = -1}

        -- Build list of chunks to process
        local chunks = {}
        for x = world_min.x, world_max.x, CHUNK_SIZE do
            for z = world_min.z, world_max.z, CHUNK_SIZE do
                table.insert(chunks, {
                    min = {x = x, y = world_min.y, z = z},
                    max = {
                        x = math.min(x + CHUNK_SIZE - 1, world_max.x),
                        y = world_max.y,
                        z = math.min(z + CHUNK_SIZE - 1, world_max.z),
                    },
                })
            end
        end

        local total = #chunks
        local current = 0
        running = true

        minetest.chat_send_player(name,
            "[fixlight_world] Iniciando: " .. total .. " chunks a procesar...")
        minetest.log("action", "[fixlight_world] " .. name ..
            " inicio fixlight de " .. total .. " chunks")

        local function process_next()
            if not running then
                minetest.chat_send_player(name, "[fixlight_world] Cancelado.")
                return
            end

            current = current + 1
            if current > total then
                running = false
                minetest.chat_send_player(name,
                    "[fixlight_world] Completado! " .. total .. " chunks procesados.")
                minetest.log("action", "[fixlight_world] Completado: " .. total .. " chunks")
                return
            end

            local chunk = chunks[current]
            local p1 = vector.new(chunk.min.x, chunk.min.y, chunk.min.z)
            local p2 = vector.new(chunk.max.x, chunk.max.y, chunk.max.z)

            -- Emerge (cargar en memoria) y luego fix_light
            minetest.emerge_area(p1, p2, function(blockpos, action, calls_remaining)
                if calls_remaining == 0 then
                    minetest.fix_light(p1, p2)

                    -- Progress update every 10%
                    local pct = math.floor(current / total * 100)
                    if current % math.max(1, math.floor(total / 10)) == 0 then
                        minetest.chat_send_player(name,
                            "[fixlight_world] Progreso: " .. current .. "/" .. total ..
                            " (" .. pct .. "%)")
                    end

                    minetest.after(EMERGE_DELAY, process_next)
                end
            end)
        end

        minetest.after(0.1, process_next)
        return true, "Proceso iniciado. Recibiras actualizaciones de progreso."
    end,
})

minetest.register_chatcommand("fixlight_stop", {
    params = "",
    description = "Cancelar fixlight_world en progreso",
    privs = {server = true},
    func = function(name, param)
        if not running then
            return false, "No hay fixlight_world en progreso."
        end
        running = false
        return true, "Cancelando fixlight_world..."
    end,
})
