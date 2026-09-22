-- valdivia_utils/init.lua
-- Utilidades para Valdivia: generador de minas subterraneas
--
-- Comando /generar_mina <radio> <profundidad>
-- Rellena el vacio (air/ignore/void) debajo del jugador con deepslate y vetas.

local MOD_NAME = "valdivia_utils"

-- Distribucion de bloques (por 1000)
-- 940 deepslate, 30 carbono, 20 hierro, 8 oro, 2 diamante
local ORE_TABLE = {
    { node = "mcl_core:deepslate",             weight = 940 },
    { node = "mcl_core:deepslate_coal_ore",    weight = 30  },
    { node = "mcl_core:deepslate_iron_ore",    weight = 20  },
    { node = "mcl_core:deepslate_gold_ore",    weight = 8   },
    { node = "mcl_core:deepslate_diamond_ore", weight = 2   },
}

-- nodos que consideramos "vacio"
-- ⚠️ CRÍTICO: NUNCA incluir "ignore" — el motor prohíbe set_node sobre chunks no cargados
-- "ignore" = áreas del mapa aún no generadas; escribir sobre ellas causa crash C++
local AIR_NODES = {
    ["air"] = true,
    ["mcl_core:void"] = true,
}

--- Selecciona un bloque aleatorio segun la tabla de pesos
local function pick_ore()
    local roll = math.random(1, 1000)
    local cumulative = 0
    for _, entry in ipairs(ORE_TABLE) do
        cumulative = cumulative + entry.weight
        if roll <= cumulative then
            return entry.node
        end
    end
    return ORE_TABLE[1].node -- fallback: deepslate
end

-- ========================
-- Comando /generar_mina
-- ========================
minetest.register_chatcommand("generar_mina", {
    params = "<radio> <profundidad>",
    description = "Genera mina subterranea: rellena vacio con deepslate y vetas de minerales",
    privs = { server = true, give = true },
    func = function(name, param)
        -- Blindaje pcall: cualquier error futuro retorna mensaje al chat en vez de crashear
        local ok, result = pcall(function()
            -- Parsear parametros
            local radio, prof = string.match(param, "^(%d+)%s+(%d+)$")
            if not radio then
                return false, "Uso: /generar_mina <radio> <profundidad>\n"
                    .. "Ejemplo: /generar_mina 10 5"
            end
            radio = tonumber(radio)
            prof = tonumber(prof)

            -- Limites de seguridad
            if radio < 1 or radio > 100 then
                return false, "Radio debe ser entre 1 y 100 nodos"
            end
            if prof < 1 or prof > 50 then
                return false, "Profundidad debe ser entre 1 y 50 nodos"
            end

            local player = minetest.get_player_by_name(name)
            if not player then
                return false, "Jugador no encontrado"
            end

            local pos = player:get_pos()
            local px = math.floor(pos.x)
            local py = math.floor(pos.y)
            local pz = math.floor(pos.z)

            local filled = 0
            local ores = 0

            -- Triple bucle: x, y, z
            for x = px - radio, px + radio do
                for y = py - 1, py - prof, -1 do
                    for z = pz - radio, pz + radio do
                        local p = { x = x, y = y, z = z }
                        local node = minetest.get_node_or_nil(p)
                        if node and AIR_NODES[node.name] then
                            local block = pick_ore()
                            minetest.set_node(p, { name = block })
                            filled = filled + 1
                            if block ~= "mcl_core:deepslate" then
                                ores = ores + 1
                            end
                        end
                    end
                end
            end

            local msg = string.format(
                "[Valdivia Utils] Mina generada: %d bloques rellenados, %d vetas "
                .. "(%d deepslate, %d minerales)",
                filled, ores, filled - ores, ores
            )
            minetest.log("action", msg)

            return true, string.format(
                "Mina generada!\n"
                .. "Radio: %d nodos | Profundidad: %d nodos\n"
                .. "Total: %d bloques rellenados\n"
                .. "Vetas: %d minerales (carbono, hierro, oro, diamante)",
                radio, prof, filled, ores
            )
        end)

        if not ok then
            minetest.log("error", "[" .. MOD_NAME .. "] Error en /generar_mina: " .. tostring(result))
            return false, "Error interno: " .. tostring(result)
        end

        return result
    end,
})

minetest.log("action", "[" .. MOD_NAME .. "] Mod cargado. Comando /generar_mina disponible.")
