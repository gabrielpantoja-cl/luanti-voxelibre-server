-- Mega cartel del Hotel Dreams (Valdivia, puerto 30001).
--
-- Que es: un mural vertical de cols x filas nodos en la planta baja (piso 1)
-- que lista los 15 pisos del hotel y que hay en cada uno.
--
-- Por que un mural y no un nodo: una textura de nodo de 16x16 no alcanza ni
-- para una palabra legible. Aca cada nodo lleva un recorte de 256x256 de una
-- sola lamina grande (tools/generate_cartel.py), asi que el cartel entero son
-- 1536x1024 px repartidos en 6x4 nodos -> se lee de pie desde el otro lado
-- del hall.
--
-- Por que NO se hizo dentro de celevator: el display del ascensor (el "PI") es
-- un display de 16 segmentos de TRES caracteres -- celevator.pi.settext() hace
-- string.sub(text, 1, 3) (pilantern.lua:132). Ahi no cabe "Rave Dreams": el
-- mod del ascensor no puede mostrar un directorio, por diseno.
--
-- Los pisos viven en pisos.json (fuente unica): lo lee este init.lua para el
-- formspec y tools/generate_cartel.py para dibujar las texturas. Al editarlo
-- hay que re-generar las texturas y commitearlas.
--
-- Solo el admin coloca el cartel (/cartel), y nadie lo puede romper: en
-- VoxeLibre "diggable = false" solo no basta (_mcl_autogroup reescribe todos
-- los nodos al cargar), por eso van los grupos unbreakable/indestructible.

local modname = minetest.get_current_modname()
local modpath = minetest.get_modpath(modname)
local F = minetest.formspec_escape

local FORM = modname .. ":directorio"
local GRUPO = "valdivia_hotel_cartel"
local DIST_DEFECTO = 3   -- nodos delante del admin donde arranca el mural
local RADIO_QUITAR = 20

local COLORES = {
    libre     = "#7FD1A0",
    reservado = "#F5C45E",
    fiesta    = "#FF7FD0",
}

-- ---------------------------------------------------------------------------
-- Datos (pisos.json)
-- ---------------------------------------------------------------------------
local DATOS = {
    titulo = "HOTEL DREAMS",
    subtitulo = "DIRECTORIO DE PISOS",
    pie = "",
    grid = { cols = 6, filas = 4, tile = 256 },
    pisos = {},
}

do
    local fh = io.open(modpath .. "/pisos.json", "r")
    if fh then
        local crudo = fh:read("*all")
        fh:close()
        local parsed = minetest.parse_json(crudo)
        if parsed and parsed.grid and parsed.pisos then
            DATOS = parsed
        else
            minetest.log("error", "[" .. modname .. "] pisos.json ilegible; uso valores por defecto")
        end
    else
        minetest.log("error", "[" .. modname .. "] falta pisos.json; uso valores por defecto")
    end
end

local COLS = tonumber(DATOS.grid.cols) or 6
local FILAS = tonumber(DATOS.grid.filas) or 4

local function nombre_nodo(fila, col)
    return ("%s:p_r%dc%d"):format(modname, fila, col)
end

-- ---------------------------------------------------------------------------
-- Formspec: el mismo directorio, pero de cerca
-- ---------------------------------------------------------------------------
local function mostrar_directorio(name)
    local fs = {
        "formspec_version[4]",
        "size[11,12.6]",
        "style_type[label;font=bold;font_size=*1.6]",
        "label[0.6,1;" .. F(DATOS.titulo) .. "]",
        "style_type[label;font=normal;font_size=*1]",
        "label[0.6,1.7;" .. F("Directorio de pisos") .. "]",
        "box[0.6,2;9.8,0.03;#D6AE5C]",
    }
    local y = 2.3
    for _, piso in ipairs(DATOS.pisos) do
        local color = COLORES[piso.estado] or COLORES.libre
        local texto = piso.nombre or ""
        if piso.detalle and piso.detalle ~= "" then
            texto = texto .. "  (" .. piso.detalle .. ")"
        end
        fs[#fs + 1] = ("box[0.6,%f;1,0.55;#1A2C46]"):format(y)
        fs[#fs + 1] = ("label[0.9,%f;%s]"):format(y + 0.28, F(tostring(piso.n)))
        -- colorize DESPUES de escapar: formspec_escape duplica las barras y
        -- rompe la secuencia de color si se hace al reves.
        fs[#fs + 1] = ("label[2,%f;%s]"):format(y + 0.28, minetest.colorize(color, F(texto)))
        y = y + 0.62
    end
    fs[#fs + 1] = ("label[0.6,%f;%s]"):format(y + 0.35, F(DATOS.pie or ""))
    fs[#fs + 1] = ("button_exit[8.6,%f;1.8,0.8;ok;%s]"):format(y + 0.6, F("Cerrar"))
    minetest.show_formspec(name, FORM, table.concat(fs))
end

-- ---------------------------------------------------------------------------
-- Nodos: un mosaico por celda del mural
-- ---------------------------------------------------------------------------
local canto = modname .. "_canto.png"

for fila = 1, FILAS do
    for col = 1, COLS do
        minetest.register_node(nombre_nodo(fila, col), {
            description = ("Cartel Hotel Dreams (%d,%d)"):format(fila, col),
            drawtype = "nodebox",
            paramtype = "light",
            paramtype2 = "facedir",
            sunlight_propagates = true,
            light_source = 6,
            is_ground_content = false,
            node_box = {
                type = "fixed",
                fixed = { { -0.5, -0.5, -0.5, 0.5, 0.5, -0.4 } },
            },
            tiles = {
                canto, canto, canto, canto, canto,
                ("%s_r%dc%d.png"):format(modname, fila, col),
            },
            use_texture_alpha = "opaque",
            groups = {
                [GRUPO] = 1,
                unbreakable = 1,
                indestructible = 1,
                unmovable_by_piston = 1,
                not_in_creative_inventory = 1,
            },
            diggable = false,
            can_dig = function() return false end,
            on_blast = function() end,
            drop = "",
            on_rightclick = function(_, _, clicker)
                if clicker and clicker:is_player() then
                    mostrar_directorio(clicker:get_player_name())
                end
            end,
        })
    end
end

-- ---------------------------------------------------------------------------
-- Colocacion
-- ---------------------------------------------------------------------------
local function signo(v)
    return v >= 0 and 1 or -1
end

-- Direccion cardinal a la que mira el jugador: el mural tiene que quedar
-- alineado a los ejes, no en diagonal.
local function mirada_cardinal(player)
    local d = player:get_look_dir()
    if math.abs(d.x) > math.abs(d.z) then
        return { x = signo(d.x), y = 0, z = 0 }
    end
    return { x = 0, y = 0, z = signo(d.z) }
end

-- Celda (fila, col) del mural -> posicion en el mundo. fila 1 = arriba,
-- col 1 = a la izquierda del que mira el cartel.
local function celda_pos(base, mirada, fila, col)
    local der = { x = mirada.z, y = 0, z = -mirada.x }
    local off = (col - 1) - math.floor(COLS / 2)
    return {
        x = base.x + der.x * off,
        y = base.y + (FILAS - fila),
        z = base.z + der.z * off,
    }
end

local function colocar(name, dist, forzar)
    local player = minetest.get_player_by_name(name)
    if not player then return false, "No te encuentro en el mundo." end

    local mirada = mirada_cardinal(player)
    local pies = vector.round(player:get_pos())
    local base = {
        x = pies.x + mirada.x * dist,
        y = pies.y,
        z = pies.z + mirada.z * dist,
    }
    -- El frente del nodo (tile -Z) tiene que apuntar de vuelta al admin;
    -- facedir_to_dir devuelve la cara TRASERA, asi que se pasa la mirada.
    local param2 = minetest.dir_to_facedir(mirada)

    -- Reviso TODAS las celdas antes de poner ninguna: medio cartel colocado
    -- es peor que nada.
    local ocupadas = {}
    for fila = 1, FILAS do
        for col = 1, COLS do
            local p = celda_pos(base, mirada, fila, col)
            local n = minetest.get_node(p).name
            if n ~= "air" and minetest.get_item_group(n, GRUPO) ~= 1 then
                ocupadas[#ocupadas + 1] = minetest.pos_to_string(p) .. " (" .. n .. ")"
            end
        end
    end
    if #ocupadas > 0 and not forzar then
        return false, ("No hay espacio: %d de %d celdas ocupadas, p.ej. %s.\n")
            :format(#ocupadas, FILAS * COLS, ocupadas[1])
            .. "Muevete, apunta a una pared despejada, o usa: /cartel forzar"
    end

    for fila = 1, FILAS do
        for col = 1, COLS do
            minetest.set_node(celda_pos(base, mirada, fila, col),
                { name = nombre_nodo(fila, col), param2 = param2 })
        end
    end

    local esquina = celda_pos(base, mirada, FILAS, 1)
    minetest.log("action", ("[%s] %s coloco el cartel en %s (%dx%d)")
        :format(modname, name, minetest.pos_to_string(esquina), COLS, FILAS))
    return true, ("Cartel puesto: %d x %d nodos, esquina inferior izquierda en %s.\n")
        :format(COLS, FILAS, minetest.pos_to_string(esquina))
        .. "Clic derecho abre el directorio. Para sacarlo: /cartel quitar"
end

local function quitar(name)
    local player = minetest.get_player_by_name(name)
    if not player then return false, "No te encuentro en el mundo." end
    local pos = vector.round(player:get_pos())
    local encontrados = minetest.find_nodes_in_area(
        vector.subtract(pos, RADIO_QUITAR), vector.add(pos, RADIO_QUITAR), "group:" .. GRUPO)
    if #encontrados == 0 then
        return false, "No hay cartel a menos de " .. RADIO_QUITAR .. " nodos."
    end
    for _, p in ipairs(encontrados) do
        minetest.remove_node(p)
    end
    minetest.log("action", ("[%s] %s quito %d nodos de cartel"):format(modname, name, #encontrados))
    return true, ("Saque %d nodos de cartel."):format(#encontrados)
end

minetest.register_chatcommand("cartel", {
    params = "[quitar | forzar | <distancia>]",
    description = "Coloca el mega cartel del Hotel Dreams delante tuyo (solo admin)",
    privs = { server = true },
    func = function(name, param)
        param = (param or ""):gsub("^%s+", ""):gsub("%s+$", "")
        if param == "quitar" or param == "sacar" then
            return quitar(name)
        end
        local forzar = (param == "forzar")
        local dist = tonumber(param) or DIST_DEFECTO
        dist = math.max(1, math.min(12, dist))
        return colocar(name, dist, forzar)
    end,
})

minetest.register_chatcommand("pisos", {
    description = "Muestra el directorio de pisos del Hotel Dreams",
    func = function(name)
        mostrar_directorio(name)
        return true
    end,
})

minetest.log("action", "[" .. modname .. "] Loaded successfully")
