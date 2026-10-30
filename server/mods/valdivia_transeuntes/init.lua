-- ============================================================================
-- valdivia_transeuntes
-- ============================================================================
-- Gente que camina por las calles de Valdivia (puerto 30001). No son guias ni
-- comerciantes: son figurantes. Aparecen solos cerca de cada jugador, caminan
-- por la calle, se detienen a mirar, y se borran cuando ya no hay nadie cerca.
--
-- Tres decisiones de diseno explican casi todo el archivo:
--
-- 1. NO HAY PATHFINDING. El A* de mcl_mobs se traba en los patios y escaleras
--    de la ciudad generada con Arnis (documentado en valdivia_policia). En vez
--    de buscar una ruta, el transeunte "sigue la calle": sondea lo que tiene
--    adelante y, si no se puede pisar, gira al rumbo valido mas parecido. En
--    una ciudad OSM las calles son los unicos corredores continuos que son
--    caminables, con dos nodos de aire y cielo abierto, asi que seguir ese
--    corredor equivale a caminar por la vereda.
--
-- 2. NO SE GUARDAN. Son efimeros (static_save = false): nacen cerca de un
--    jugador y se borran al alejarse. Asi no hay roster que reconciliar ni
--    huerfanos despues de un apagon (aca `docker stop` siempre termina en
--    SIGKILL y los mapblocks no alcanzan a escribirse).
--
-- 3. CADA UNO ES ALGUIEN. No hay "tipos" con skins intercambiables: hay un
--    elenco de personas, y cada persona tiene su nombre, su textura y sus
--    frases. Dos transeuntes nunca comparten identidad, ni siquiera skin, y
--    el mod garantiza que nadie aparezca dos veces al mismo tiempo.
--
-- Solo Valdivia: load_mod_valdivia_transeuntes = true en luanti-valdivia.conf
-- (y en el world.mt del VPS).

local modname = minetest.get_current_modname()

-- ============================================================================
-- 1. AJUSTES
-- ============================================================================
local function num(key, default)
    return tonumber(minetest.settings:get("valdivia_transeuntes_" .. key)) or default
end

local MAX_GLOBAL  = num("max", 40)          -- tope de transeuntes vivos en todo el mundo
local POR_JUGADOR = num("por_jugador", 12)  -- cuantos acompanan a cada jugador
local DIST_MIN    = num("dist_min", 22)     -- no nacen mas cerca que esto
local DIST_MAX    = num("dist_max", 45)     -- ni mas lejos
local DIST_BORRAR = num("dist_borrar", 70)  -- se borran al pasar esta distancia
local VELOCIDAD   = num("velocidad", 1.5)   -- nodos/segundo (un jugador va a 4.3)
local INTERVALO   = num("intervalo", 3)     -- segundos entre rondas del sembrador
local LUZ_MIN     = num("luz_min", 14)      -- luz natural a mediodia para contar como calle
local DIST_CERCA  = num("dist_cerca", 36)   -- mas alla de esto piensan mas lento (ver LOD)

local PASO       = 0.4    -- segundos entre decisiones de rumbo (de cerca)
local PASO_LEJOS = 2.0    -- idem, cuando nadie lo esta mirando
local SONDEO     = 1.6    -- nodos por delante que mira antes de avanzar
local P_GIRO     = 0.10   -- probabilidad de doblar aunque el frente este libre
local P_PAUSA    = 0.04   -- probabilidad de quedarse mirando
local PAUSA_MIN  = 2
local PAUSA_MAX  = 6
local HP         = 10000  -- inmortal de facto

local ENTITY = modname .. ":transeunte"
local C_NPC  = "#9FE09F"

local function al_azar(t) return t[math.random(#t)] end

-- ============================================================================
-- 2. EL ELENCO
-- ============================================================================
-- Un personaje = un nombre + un oficio + UNA textura + SUS frases. Nadie
-- comparte skin ni dialogo con nadie: si ves a Camila dos veces, es un bug.
-- La textura se deduce del nombre (valdivia_transeunte_<nombre en minuscula>.png),
-- asi que sumar a alguien es agregar una fila aqui y dejar el PNG en textures/.
--
-- Cuando un skin trae una marca que lo identifica, el nombre se amarra a ella:
-- la polera de Hugo lleva una "H" dibujada, y por eso ese skin es de Hugo y de
-- nadie mas. Misma regla para cualquier skin futuro con inicial o numero.
local PERSONAJES = {
    -- --- Bomberos (en Chile son voluntarios) ---
    {nombre = "Rodrigo", oficio = "bombero", frases = {
        "Soy del Cuerpo de Bomberos. Aca somos todos voluntarios, sabias?",
        "Si alguna vez ves humo, avisa altiro y no te acerques solo.",
        "Hoy me toca revisar las mangueras en el cuartel.",
    }},
    {nombre = "Ignacio", oficio = "bombero", frases = {
        "Vengo saliendo de una practica en el cuartel.",
        "El casco pesa, pero pesa menos que un susto.",
        "Nos llaman a cualquier hora, por eso dejo la ropa lista.",
    }},

    -- --- Cocina y pan ---
    {nombre = "Pablo", oficio = "cocinero", frases = {
        "Trabajo en una cocina del centro. Hoy preparamos curanto.",
        "El secreto de una buena sopa es no apurarla.",
        "Si pasas al mediodia te guardo un pan amasado.",
    }},
    {nombre = "Rosa", oficio = "panadera", frases = {
        "Me levanto a las cuatro para que el pan este listo temprano.",
        "No hay nada mejor que una marraqueta recien salida del horno.",
        "Se siente el olor a horno desde la esquina, no?",
    }},

    -- --- Salud ---
    {nombre = "Daniela", oficio = "doctora", frases = {
        "Trabajo en el Hospital Base. Hoy me toco turno largo.",
        "Abrigate bien, que con esta humedad se resfria cualquiera.",
        "Tomar agua y dormir bien: eso lo receto siempre.",
    }},
    {nombre = "Fernanda", oficio = "enfermera", frases = {
        "Vengo saliendo del turno de noche.",
        "Si te raspas una rodilla, lavala con agua limpia primero.",
        "En el hospital siempre hay alguien despierto cuidando.",
    }},

    -- --- Oficinas y tramites ---
    {nombre = "Eduardo", oficio = "oficinista", frases = {
        "Voy a la oficina. Otra reunion mas.",
        "Compre el diario en el quiosco de la esquina.",
        "A las seis me vuelvo caminando por la costanera.",
    }},
    {nombre = "Hernan", oficio = "oficinista", frases = {
        "Se me paso el colectivo, me voy a pie no mas.",
        "Trabajo aqui cerca, en el segundo piso.",
        "Mi cafe de la manana es sagrado.",
    }},
    {nombre = "Gonzalo", oficio = "oficinista", frases = {
        "Con este abrigo no me pilla la lluvia.",
        "Llevo unos papeles a la municipalidad.",
        "En Valdivia uno aprende a andar siempre con paraguas.",
    }},
    {nombre = "Patricio", oficio = "oficinista", frases = {
        "Se me empanaron los lentes con la neblina.",
        "Reviso numeros todo el dia. Los numeros al menos no se mojan.",
        "A fin de mes esto se pone movido.",
    }},

    -- --- Construccion ---
    {nombre = "Manuel", oficio = "obrero", frases = {
        "Andamos levantando una casa aqui al lado.",
        "Casco puesto siempre, incluso para mirar.",
        "A las cinco se corta la jornada y nos vamos.",
    }},
    {nombre = "Sergio", oficio = "obrero", frases = {
        "Estos overoles ya vieron de todo.",
        "La madera buena viene del sur, de por aca mismo.",
        "Cuidado donde pisas, que a veces quedan clavos.",
    }},
    {nombre = "Victor", oficio = "obrero", frases = {
        "Vamos a mezclar cemento antes que empiece a llover.",
        "Si llueve fuerte se para la obra. Y aca llueve harto.",
        "Lo lindo es ver la casa terminada. Eso paga el dia.",
    }},
    {nombre = "Mauricio", oficio = "obrero", frases = {
        "Falta poco para cerrar el techo.",
        "Un techo bien hecho dura cincuenta anos.",
        "Pasame la escala... ah, perdona, te confundi con mi companero.",
    }},
    {nombre = "Marcelo", oficio = "obrero", frases = {
        "El chaleco reflectante es para que me vean los autos.",
        "Trabajo en plena calle, asi que ando atento.",
        "Tomate un descanso tu tambien, no todo es trabajar.",
    }},

    -- --- Campo, huerta y feria ---
    {nombre = "Ramon", oficio = "campesino", frases = {
        "Traigo papas del campo, a dos horas de aqui.",
        "Esta tierra da bien si uno la cuida.",
        "Me vuelvo antes que oscurezca.",
    }},
    {nombre = "Carmen", oficio = "jardinera", frases = {
        "Estoy plantando en la plaza. Van a quedar lindas las flores.",
        "Con tanta lluvia aqui crece todo casi solo.",
        "Si plantas algo, riegalo los primeros dias y listo.",
    }},
    {nombre = "Lucho", oficio = "campesino", frases = {
        "Vengo a la feria a vender lo de la huerta.",
        "La murta se da sola en el bosque de aca.",
        "Nada como un mate antes de salir.",
    }},
    {nombre = "Hilda", oficio = "campesina", frases = {
        "Traje huevos y queso fresco para vender.",
        "Aprendi a sembrar mirando a mi abuela.",
        "El invierno aqui es largo, pero la tierra lo agradece.",
    }},
    {nombre = "Olegario", oficio = "campesino", frases = {
        "Este sombrero me acompana hace anos.",
        "Las vacas no entienden de horarios, hay que madrugar.",
        "Buen dia para anda caminando.",
    }},

    -- --- Deporte ---
    {nombre = "Felipe", oficio = "deportista", frases = {
        "Salgo a trotar por la costanera todas las mananas.",
        "Si vas a correr, parte despacio. No es una carrera.",
        "El aire aqui es limpio, se nota al respirar.",
    }},

    -- --- Adultos mayores ---
    {nombre = "Arturo", oficio = "jubilado", frases = {
        "Ya no trabajo, ahora camino no mas.",
        "Conozco esta ciudad desde antes del terremoto del 60.",
        "Si quieres te acompano un rato.",
    }},
    {nombre = "Guillermo", oficio = "jubilado", frases = {
        "Voy a darle de comer a las palomas de la plaza.",
        "Antes todo esto eran puros potreros.",
        "Camino lento, pero igual llego.",
    }},
    {nombre = "Teresa", oficio = "jubilada", frases = {
        "Voy a la feria a comprar para toda la semana.",
        "Mis nietos tambien juegan por aqui.",
        "Tomate algo caliente, que esta helado.",
    }},

    -- --- Vecinas y vecinos del barrio ---
    {nombre = "Camila", oficio = "vecina", frases = {
        "Vivo a tres cuadras. Linda la tarde, no?",
        "Me gusta mirar el rio desde el puente.",
        "Si te pierdes, busca una cabina roja y vuelves.",
    }},
    {nombre = "Javiera", oficio = "vecina", frases = {
        "Voy al almacen de la esquina.",
        "Aqui uno saluda a todo el mundo, es la costumbre.",
        "Ojala no llueva mas por hoy.",
    }},
    {nombre = "Antonia", oficio = "vecina", frases = {
        "Vengo de dejar a mi hermana chica al colegio.",
        "Esta calle es tranquila, me gusta.",
        "Cuidado al cruzar, que pasan autos.",
    }},
    {nombre = "Florencia", oficio = "vecina", frases = {
        "Ando buscando donde tomar once.",
        "Me encantan los dias asi, con neblina.",
        "Mi gata se arranca siempre por estos techos.",
    }},
    {nombre = "Josefa", oficio = "vecina", frases = {
        "Voy a buscar un paraguas, se me quedo en la casa.",
        "Llevo toda la vida en este barrio.",
        "Los vecinos de aca son buena gente.",
    }},
    {nombre = "Emilia", oficio = "vecina", frases = {
        "Salgo a estirar las piernas un rato.",
        "Este frio se mete en los huesos.",
        "Que tengas buen dia.",
    }},
    {nombre = "Catalina", oficio = "vecina", frases = {
        "Voy a la biblioteca a devolver un libro.",
        "En invierno leo mucho mas, por la lluvia.",
        "Conoces el Mercado Fluvial? Vale la pena.",
    }},
    {nombre = "Paz", oficio = "vecina", frases = {
        "Con este poncho aguanto cualquier chaparron.",
        "Lo tejio mi mama. Abriga como ninguno.",
        "Si va a llover, mejor salir preparada.",
    }},
    {nombre = "Milaray", oficio = "vecina", frases = {
        "Mi nombre quiere decir flor de oro en mapudungun.",
        "Voy donde mi tia, vive cruzando la plaza.",
        "Aqui el rio manda. Todo pasa cerca del agua.",
    }},
    {nombre = "Valentina", oficio = "vecina", frases = {
        "Vengo de comprar pan para la once.",
        "Me gusta salir cuando deja de llover.",
        "Los patos del rio ya me conocen.",
    }},
    {nombre = "Matias", oficio = "vecino", frases = {
        "Ando buscando a mi perro, se arranco de nuevo.",
        "Si lo ves, es cafe y no para de mover la cola.",
        "Siempre vuelve solo, pero igual lo salgo a buscar.",
    }},
    {nombre = "Benjamin", oficio = "vecino", frases = {
        "Voy a la casa de un amigo aqui cerca.",
        "Me gusta andar en bicicleta por la costanera.",
        "Que bueno ver caras nuevas por el barrio.",
    }},
    {nombre = "Vicente", oficio = "vecino", frases = {
        "Vengo llegando de la feria, mira todo lo que traigo.",
        "Los sabados esto se llena de gente.",
        "Me quedan dos cuadras y llego.",
    }},
    {nombre = "Martin", oficio = "vecino", frases = {
        "Se me hizo tarde, voy apurado.",
        "Esta cuadra la camino todos los dias.",
        "Hasta luego, que te vaya bien.",
    }},
    {nombre = "Agustin", oficio = "vecino", frases = {
        "Voy a la plaza a juntarme con unos amigos.",
        "Aqui todos se conocen, para bien y para mal.",
        "Buena esa ropa que andas trayendo.",
    }},
    {nombre = "Joaquin", oficio = "vecino", frases = {
        "Ando dando vueltas no mas, sin apuro.",
        "Me gusta caminar cuando esta nublado.",
        "Conoces el Parque Saval? Queda cruzando el puente.",
    }},
    {nombre = "Cristobal", oficio = "vecino", frases = {
        "Vengo del trabajo, por fin.",
        "Llevo toda la semana esperando el sabado.",
        "Si buscas el centro, es para alla.",
    }},
    {nombre = "Gaspar", oficio = "vecino", frases = {
        "Esta chaqueta es la mas abrigada que tengo.",
        "Voy a ver si alcanzo a llegar antes de la lluvia.",
        "Que bueno encontrarse gente en la calle.",
    }},
    {nombre = "Elias", oficio = "vecino", frases = {
        "Voy a buscar a mi hermano al paradero.",
        "Aqui llueve, pero uno se acostumbra.",
        "Nos vemos por el barrio.",
    }},
    {nombre = "Renato", oficio = "vecino", frases = {
        "Salgo a comprar y vuelvo altiro.",
        "El invierno valdiviano no es broma.",
        "Que andes bien.",
    }},

    -- --- Rio y bosque ---
    {nombre = "Lautaro", oficio = "guardaparques", frases = {
        "Cuido el bosque de aqui cerca. No te lleves plantas, porfa.",
        "En el humedal hay cisnes de cuello negro. Son unicos.",
        "Si entras al bosque, no dejes basura. Nada mas que eso.",
    }},
    {nombre = "Gabriel", oficio = "pescador", frases = {
        "Vengo llegando del rio. Hoy estuvo tranquilo.",
        "Con este impermeable no me moja ni el invierno valdiviano.",
        "Sal temprano si quieres ver el rio con neblina.",
    }},
    {nombre = "Constanza", oficio = "pescadora", frases = {
        "El amarillo es para que me vean desde la orilla.",
        "Aprendi a remar antes que a andar en bicicleta.",
        "En el muelle siempre hay lobos marinos esperando.",
    }},
    {nombre = "Simon", oficio = "pescador", frases = {
        "Salgo antes que amanezca, asi se pesca.",
        "El rio cambia todos los dias, nunca es igual.",
        "Si bajas al muelle, no te acerques mucho al borde.",
    }},

    -- --- Feria fluvial ---
    {nombre = "Amanda", oficio = "feriante", frases = {
        "Llevelo, casero! Todo fresquito.",
        "Trabajo en el Mercado Fluvial, a la orilla del rio.",
        "Lo mejor de la feria son las papas y la murta.",
    }},
    {nombre = "Trinidad", oficio = "feriante", frases = {
        "A esta hora ya tengo el puesto armado.",
        "Pregunta no mas, que para eso estamos.",
        "Si vienes temprano, encuentras lo mejor.",
    }},
    {nombre = "Bastian", oficio = "feriante", frases = {
        "Ayudo a mi mama en el puesto los fines de semana.",
        "Aprendi a dar el vuelto antes que las tablas.",
        "Pasa a vernos, estamos cerca del rio.",
    }},

    -- --- Colegio y universidad ---
    {nombre = "Sofia", oficio = "escolar", frases = {
        "Voy atrasada al colegio!",
        "Hoy tengo prueba de historia. Deseame suerte.",
        "Mi curso fue de paseo al humedal. Habia muchos pajaros.",
    }},
    {nombre = "Diego", oficio = "escolar", frases = {
        "Se me olvido el cuaderno en la casa, otra vez.",
        "Sabias que el rio Calle-Calle pasa por aca al lado?",
        "En el recreo jugamos a la pelota en el patio.",
    }},
    {nombre = "Hugo", oficio = "estudiante", frases = {
        "La H de mi polera? Es por mi nombre: Hugo.",
        "Me la regalaron para mi cumpleanos, no me la saco nunca.",
        "Voy saliendo de clases, estudio aqui cerca.",
    }},
    {nombre = "Francisca", oficio = "estudiante", frases = {
        "Estudio en la Austral, alla en Isla Teja.",
        "Voy a la biblioteca, tengo que entregar un trabajo.",
        "Me falta un ramo para salir de vacaciones.",
    }},
    {nombre = "Nahuel", oficio = "estudiante", frases = {
        "Ando buscando donde estudiar tranquilo.",
        "Mi nombre significa tigre en mapudungun.",
        "Cruzando el puente queda la universidad.",
    }},
    {nombre = "Rayen", oficio = "estudiante", frases = {
        "Rayen quiere decir flor. Me lo puso mi abuela.",
        "Voy a juntarme con mi grupo de trabajo.",
        "Esta semana no he dormido nada, para que te digo.",
    }},

    -- --- Visitas ---
    {nombre = "Isidora", oficio = "turista", frases = {
        "Vine a conocer la ciudad. Es preciosa!",
        "Estoy buscando la Costanera para sacar fotos.",
        "Nunca habia visto tantos rios juntos.",
    }},
    {nombre = "Matilde", oficio = "turista", frases = {
        "Me dijeron que tengo que ver el Torreon. Sabes donde queda?",
        "Vengo del norte y aca todo es verde.",
        "Me compre un paraguas apenas llegue.",
    }},
    {nombre = "Ignacia", oficio = "turista", frases = {
        "Ando con el mapa en la mano y igual me pierdo.",
        "Alguien me dijo que hay que probar el curanto.",
        "Que lindo que llueva y a nadie le moleste.",
    }},
}

-- Indice por nombre en minuscula, para /transeunte <nombre> y para validar.
local POR_NOMBRE = {}
for i, p in ipairs(PERSONAJES) do
    p.id = i
    p.skin = "valdivia_transeunte_" .. p.nombre:lower() .. ".png"
    POR_NOMBRE[p.nombre:lower()] = p
end

-- ============================================================================
-- 3. ESTO ES CALLE?
-- ============================================================================
-- El corazon del mod. `p` es la posicion de los PIES.
--
-- La prueba de cielo abierto es la que separa calle de interior sin tener que
-- conocer los nombres de nodo con que Arnis pavimento la ciudad. Se pide la luz
-- natural con timeofday = 0.5 (mediodia) a proposito: la pregunta es "hay cielo
-- encima?", no "que hora es?". Sin ese 0.5 los transeuntes se meterian a las
-- casas de noche.
local function es_suelo(name)
    if name == "air" or name == "ignore" then return false end
    local def = minetest.registered_nodes[name]
    return def ~= nil and def.walkable == true and def.liquidtype == "none"
end

local function calcular_calle(p)
    if not es_suelo(minetest.get_node({x = p.x, y = p.y - 1, z = p.z}).name) then
        return false
    end
    if minetest.get_node(p).name ~= "air" then return false end
    if minetest.get_node({x = p.x, y = p.y + 1, z = p.z}).name ~= "air" then return false end
    local luz = minetest.get_natural_light(p, 0.5)
    return luz ~= nil and luz >= LUZ_MIN
end

-- Cache generacional. `calcular_calle` cuesta cuatro llamadas al motor, y con
-- decenas de transeuntes sondeando ocho rumbos cada 0.4 s se repiten los mismos
-- nodos miles de veces por minuto. La ciudad es practicamente estatica, asi que
-- la respuesta se guarda.
--
-- Por que dos generaciones y no un timestamp por entrada: invalidar al cavar o
-- construir obligaria a borrar una caja entera alrededor de cada nodo tocado
-- (la luz se propaga), y un jugador construyendo haria trizas la cache. En vez
-- de eso, cada VIDA_CACHE segundos la generacion actual pasa a ser la vieja y
-- se abre una nueva: lo que se consulta seguido se promueve solo, lo que no se
-- usa se cae, y un cambio en el mapa se nota a mas tardar en dos ciclos. Para
-- peatones de fondo ese retardo es invisible, y la memoria queda acotada sola.
local VIDA_CACHE = 25
local cache_actual, cache_vieja = {}, {}
local reloj_cache = 0

local function es_calle(p)
    local k = minetest.hash_node_position(p)
    local v = cache_actual[k]
    if v ~= nil then return v end
    v = cache_vieja[k]
    if v == nil then
        v = calcular_calle(p)
    end
    cache_actual[k] = v   -- promueve a la generacion nueva
    return v
end

-- Un techo plano pasa `es_calle` sin problema: es caminable y tiene cielo. Lo
-- que lo delata es el hueco de abajo, que es el interior del edificio. Bajo una
-- calle hay tierra; bajo un techo, a dos o tres nodos, hay aire.
local function tiene_suelo_macizo(p)
    for dy = 2, 4 do
        if minetest.get_node({x = p.x, y = p.y - dy, z = p.z}).name == "air" then
            return false
        end
    end
    return true
end

-- Descarta parches de un solo nodo: patios interiores, cornisas, la orilla del
-- rio. Una calle de verdad sigue siendo calle a los lados.
local function es_calle_ancha(p)
    local vecinos = 0
    for _, d in ipairs({{1, 0}, {-1, 0}, {0, 1}, {0, -1}}) do
        if es_calle({x = p.x + d[1], y = p.y, z = p.z + d[2]}) then
            vecinos = vecinos + 1
        end
    end
    return vecinos >= 3
end

-- ============================================================================
-- 4. RUMBOS
-- ============================================================================
-- Ocho direcciones fijas. Girar es moverse en esta lista, asi que "el giro mas
-- pequeno" es simplemente la diferencia de indice.
local DIRS = {}
for i = 0, 7 do
    local a = i * math.pi / 4
    DIRS[i + 1] = {x = math.cos(a), z = math.sin(a), yaw = a - math.pi / 2}
end

-- Se puede avanzar en este rumbo? Se mira el nodo de adelante y tambien uno
-- intermedio, para que no corte una esquina por la diagonal metiendose en un
-- muro. Se tolera un nodo de desnivel (veredas, badenes) porque mcl_mobs sube
-- solo hasta stepheight.
local function rumbo_libre(pos, idx)
    local d = DIRS[idx]
    local y = math.floor(pos.y + 0.5)
    for _, dist in ipairs({1, SONDEO}) do
        local x = math.floor(pos.x + d.x * dist)
        local z = math.floor(pos.z + d.z * dist)
        local ok = false
        for _, dy in ipairs({0, 1, -1}) do
            if es_calle({x = x, y = y + dy, z = z}) then
                ok = true
                break
            end
        end
        if not ok then return false end
    end
    return true
end

-- Rumbos validos ordenados por cuanto hay que girar (0 = seguir recto).
local function rumbos_validos(pos, actual)
    local out = {}
    for _, giro in ipairs({0, 1, -1, 2, -2, 3, -3, 4}) do
        local idx = ((actual - 1 + giro) % 8) + 1
        if rumbo_libre(pos, idx) then
            table.insert(out, {idx = idx, giro = math.abs(giro)})
        end
    end
    return out
end

-- ============================================================================
-- 5. EL TRANSEUNTE
-- ============================================================================
-- Igual que los guias y el carabinero: mcl_mobs solo registra, dibuja y aporta
-- la gravedad; el movimiento es nuestro. walk_chance = 0 es obligatorio o el
-- FSM de mcl_mobs pisa el set_velocity y el NPC avanza a tirones.
local vivos = {}     -- ObjectRef -> id de personaje
local en_uso = {}    -- id de personaje -> true (nadie aparece dos veces)

local function soltar(obj)
    local id = vivos[obj]
    if id then en_uso[id] = nil end
    vivos[obj] = nil
end

local function contar_vivos()
    local n = 0
    for obj in pairs(vivos) do
        if obj:get_pos() then n = n + 1 else soltar(obj) end
    end
    return n
end

-- Distancia al jugador mas cercano, o nil si no hay ninguno a la vista. Sirve
-- para dos cosas: el borrado por lejania y el LOD de abajo.
local function dist_jugador_mas_cercano(pos)
    local mejor
    for _, p in ipairs(minetest.get_connected_players()) do
        local pp = p:get_pos()
        if pp then
            local d = vector.distance(pos, pp)
            if not mejor or d < mejor then mejor = d end
        end
    end
    return mejor
end

-- Cara, ropa y nombre. Se aplica tanto al crear como en el primer paso, porque
-- no damos por sentado CUANDO llama mcl_mobs a nuestro on_activate: si lo
-- llamara dentro de add_entity, el personaje todavia no estaria puesto.
local function aplicar_aspecto(self)
    local p = PERSONAJES[self._pid or 0]
    if not p then return false end
    self.object:set_properties({
        textures = {p.skin, "blank.png", "blank.png"},
        infotext = p.nombre .. " - " .. p.oficio,
        static_save = false,
    })
    self._aspecto = true
    return true
end

local function registrar_mob()
    mcl_mobs.register_mob(ENTITY, {
        description = "Transeunte de Valdivia",
        type = "npc",
        spawn_class = "passive",
        passive = true,
        xp_min = 0,
        xp_max = 0,
        initial_properties = {
            hp_min = HP,
            hp_max = HP,
            -- Este VoxeLibre lo quiere aca Y en la raiz: con el collisionbox
            -- solo en la raiz loguea "Mob without collisionbox" al activarse.
            collisionbox = {-0.3, -0.01, -0.3, 0.3, 1.94, 0.3},
        },
        collisionbox = {-0.3, -0.01, -0.3, 0.3, 1.94, 0.3},
        visual = "mesh",
        mesh = "mcl_armor_character.b3d",
        -- 3 capas que pide mcl_armor_character.b3d: {skin, armadura, capa}
        textures = {{PERSONAJES[1].skin, "blank.png", "blank.png"}},
        makes_footstep_sound = true,
        walk_velocity = VELOCIDAD,
        run_velocity = VELOCIDAD,
        walk_chance = 0,
        -- Sin saltos: asi no se trepan a los techos ni a los autos.
        jump = false,
        stepheight = 1.1,
        fear_height = 0,
        fall_damage = 0,
        view_range = 16,
        drops = {},
        can_despawn = true,
        armor_groups = {immortal = 1, fleshy = 0},
        animation = {
            stand_start = 0, stand_end = 79, stand_speed = 30,
            walk_start = 168, walk_end = 187, walk_speed = 25,
            run_start = 168, run_end = 187, run_speed = 25,
        },

        on_activate = function(self, staticdata, dtime_s)
            self.object:set_armor_groups({immortal = 1, fleshy = 0})
            self.object:set_hp(HP)
            self.health = HP
            -- Efimeros: nunca se escriben en el mapblock.
            self.object:set_properties({static_save = false})
            self._edad = 0
            self._pausa = 0
            self._acum = 0
            self._rumbo = self._rumbo or math.random(8)
            if self._pid then aplicar_aspecto(self) end
        end,

        do_custom = function(self, dtime)
            if self.object:get_hp() < HP then
                self.object:set_hp(HP)
                self.object:set_armor_groups({immortal = 1, fleshy = 0})
            end

            -- Sin personaje no hay transeunte. Uno recien creado lo recibe en
            -- el mismo paso del servidor; si pasado un segundo sigue sin el es
            -- un resto de una version anterior del mod y se borra solo.
            self._edad = (self._edad or 0) + dtime
            if not PERSONAJES[self._pid or 0] then
                if self._edad > 1 then
                    soltar(self.object)
                    self.object:remove()
                end
                return
            end
            if not self._aspecto then aplicar_aspecto(self) end

            local pos = self.object:get_pos()
            if not pos then return end

            -- Decide rumbo cada PASO segundos, no cada tick: ocho sondeos por
            -- decision serian demasiados a veinte pasos por segundo.
            --
            -- LOD: si nadie lo tiene cerca, piensa cada PASO_LEJOS en vez de
            -- cada PASO. Sigue caminando igual (la velocidad no cambia), solo
            -- decide el rumbo cinco veces menos seguido. Nadie lo esta viendo
            -- doblar, y es lo que permite tener decenas vivos a la vez.
            local cerca = dist_jugador_mas_cercano(pos)
            local paso = (cerca and cerca <= DIST_CERCA) and PASO or PASO_LEJOS

            self._acum = (self._acum or 0) + dtime
            if self._acum < paso then return end
            self._acum = 0

            local vel = self.object:get_velocity()
            local vy = vel and vel.y or 0

            -- Pausa: se queda mirando.
            if (self._pausa or 0) > 0 then
                self._pausa = self._pausa - paso
                self.object:set_velocity({x = 0, y = vy, z = 0})
                self.object:set_animation({x = 0, y = 79}, 30, 0, true)
                return
            end

            local recto = rumbo_libre(pos, self._rumbo)
            if not recto or math.random() < P_GIRO then
                local opciones = rumbos_validos(pos, self._rumbo)
                if #opciones == 0 then
                    -- Encerrado (lo taparon, o la calle se cerro). Mejor
                    -- desaparecer que quedar vibrando contra un muro.
                    soltar(self.object)
                    self.object:remove()
                    return
                end
                if recto then
                    -- Dobla en la esquina: cualquiera menos seguir recto.
                    local giros = {}
                    for _, o in ipairs(opciones) do
                        if o.giro > 0 then table.insert(giros, o) end
                    end
                    if #giros > 0 then self._rumbo = al_azar(giros).idx end
                else
                    -- Se acabo la calle: el giro mas suave que si sirva. Entre
                    -- los empatados (izquierda y derecha) se sortea.
                    local mejor = opciones[1].giro
                    local empatados = {}
                    for _, o in ipairs(opciones) do
                        if o.giro == mejor then table.insert(empatados, o) end
                    end
                    self._rumbo = al_azar(empatados).idx
                end
            end

            if math.random() < P_PAUSA then
                self._pausa = PAUSA_MIN + math.random() * (PAUSA_MAX - PAUSA_MIN)
                return
            end

            local d = DIRS[self._rumbo]
            self.object:set_velocity({x = d.x * VELOCIDAD, y = vy, z = d.z * VELOCIDAD})
            self.object:set_yaw(d.yaw)
            self.object:set_animation({x = 168, y = 187}, 25, 0, true)
        end,

        -- Anti-grief: no se les puede hacer nada. El reclamo tiene cooldown
        -- propio porque un nino pega diez veces en dos segundos y si no, son
        -- diez lineas de chat identicas.
        do_punch = function(self, puncher)
            self.object:set_armor_groups({immortal = 1, fleshy = 0})
            self.object:set_hp(HP)
            self.health = HP
            local p = PERSONAJES[self._pid or 0]
            if p and puncher and puncher:is_player() then
                local ahora = minetest.get_gametime()
                if (self._ultimo_reclamo or -99) + 5 <= ahora then
                    self._ultimo_reclamo = ahora
                    minetest.chat_send_player(puncher:get_player_name(),
                        minetest.colorize("#FF6B6B", "[" .. p.nombre ..
                        "] Oye! No me pegues, voy pasando no mas."))
                end
            end
            return false
        end,

        -- Hablar. Dos reglas aprendidas mirandolos en produccion:
        --  * cooldown, porque el clic derecho se repite solo al dejar apretado
        --    y sin el son veinte lineas de chat en quince segundos;
        --  * la pausa se FIJA, no se acumula: antes cada clic reiniciaba los
        --    4 s y un jugador insistente dejaba al transeunte clavado.
        on_rightclick = function(self, clicker)
            if not clicker or not clicker:is_player() then return end
            local p = PERSONAJES[self._pid or 0]
            if not p then return end

            local ahora = minetest.get_gametime()
            if (self._ultima_frase or -99) + 3 > ahora then return end
            self._ultima_frase = ahora

            -- Nunca repite la frase anterior si tiene mas de una.
            local i = math.random(#p.frases)
            if #p.frases > 1 and i == self._frase_previa then
                i = (i % #p.frases) + 1
            end
            self._frase_previa = i

            minetest.chat_send_player(clicker:get_player_name(),
                minetest.colorize(C_NPC, "[" .. p.nombre .. "] ") .. p.frases[i])

            -- Se detiene un momento a conversar y mira a quien le hablo.
            self._pausa = math.max(self._pausa or 0, 4)
            local pos = self.object:get_pos()
            local cpos = clicker:get_pos()
            if pos and cpos then
                local dir = vector.subtract(cpos, pos)
                self.object:set_yaw(math.atan2(dir.z, dir.x) - math.pi / 2)
            end
        end,
    })
end

-- ============================================================================
-- 6. CREAR UNO
-- ============================================================================
-- Elige a alguien que NO este ya caminando por ahi. Si se pide a alguien
-- puntual y ya esta en la calle, no se clona: se devuelve nil.
local function elegir_libre()
    local libres = {}
    for i = 1, #PERSONAJES do
        if not en_uso[i] then table.insert(libres, i) end
    end
    if #libres == 0 then return nil end
    return al_azar(libres)
end

local function crear(pos, pid)
    pid = pid or elegir_libre()
    if not pid or not PERSONAJES[pid] or en_uso[pid] then return nil end

    local obj = minetest.add_entity(pos, ENTITY)
    if not obj then return nil end

    local le = obj:get_luaentity()
    if not le then
        obj:remove()
        return nil
    end

    le._pid = pid
    le._rumbo = math.random(8)
    le._edad = 0
    aplicar_aspecto(le)
    vivos[obj] = pid
    en_uso[pid] = true
    return obj
end

-- ============================================================================
-- 7. DONDE NACEN
-- ============================================================================
-- Tres filtros (calle / no es techo / calle ancha) y dos reglas de aparicion:
-- lejos y fuera de la vista. La segunda es la que evita que al jugador le
-- aparezca gente de la nada delante de los ojos.
local function buscar_sitio(player)
    local ppos = player:get_pos()
    if not ppos then return nil end
    local ojos = {x = ppos.x, y = ppos.y + 1.5, z = ppos.z}

    for _ = 1, 25 do
        local ang = math.random() * 2 * math.pi
        local r = DIST_MIN + math.random() * (DIST_MAX - DIST_MIN)
        local x = math.floor(ppos.x + math.cos(ang) * r)
        local z = math.floor(ppos.z + math.sin(ang) * r)

        -- Barrido vertical: la ciudad tiene desniveles, el suelo no esta a la
        -- misma altura que el jugador.
        for dy = 5, -8, -1 do
            local p = {x = x, y = math.floor(ppos.y + 0.5) + dy, z = z}
            if es_calle(p) and tiene_suelo_macizo(p) and es_calle_ancha(p) then
                local centro = {x = p.x + 0.5, y = p.y + 1, z = p.z + 0.5}
                if not minetest.line_of_sight(ojos, centro) then
                    return {x = p.x + 0.5, y = p.y, z = p.z + 0.5}
                end
                break  -- es calle, pero a la vista: probar otro punto
            end
        end
    end
    return nil
end

-- ============================================================================
-- 8. EL SEMBRADOR
-- ============================================================================
-- Un solo globalstep para todo el mod: siembra los que faltan, borra los que
-- quedaron lejos y hace rotar la cache de calle. Por jugador, no por NPC.
local reloj = 0

minetest.register_globalstep(function(dtime)
    -- Rotacion de la cache (ver seccion 3). Va fuera del if de abajo para que
    -- no dependa del intervalo del sembrador.
    reloj_cache = reloj_cache + dtime
    if reloj_cache >= VIDA_CACHE then
        reloj_cache = 0
        cache_vieja = cache_actual
        cache_actual = {}
    end

    reloj = reloj + dtime
    if reloj < INTERVALO then return end
    reloj = 0

    local jugadores = minetest.get_connected_players()

    -- Borrar los que ya no acompanan a nadie.
    for obj in pairs(vivos) do
        local pos = obj:get_pos()
        if not pos then
            soltar(obj)
        else
            local d = dist_jugador_mas_cercano(pos)
            if not d or d > DIST_BORRAR then
                soltar(obj)
                obj:remove()
            end
        end
    end

    if #jugadores == 0 then return end

    local total = contar_vivos()
    if total >= MAX_GLOBAL then return end

    -- De noche hay menos gente en la calle.
    local hora = minetest.get_timeofday()
    local noche = hora < 0.25 or hora > 0.78
    local cupo = noche and math.max(1, math.floor(POR_JUGADOR / 2)) or POR_JUGADOR

    for _, player in ipairs(jugadores) do
        if total >= MAX_GLOBAL then break end
        local ppos = player:get_pos()
        -- Si el jugador esta bajo tierra o encerrado no hay calle que sembrar,
        -- y los 25 sondeos serian puro gasto.
        local luz = ppos and minetest.get_natural_light(ppos, 0.5)
        if ppos and luz and luz >= 8 then
            local acompanantes = 0
            for obj in pairs(vivos) do
                local opos = obj:get_pos()
                if opos and vector.distance(opos, ppos) <= DIST_BORRAR then
                    acompanantes = acompanantes + 1
                end
            end
            if acompanantes < cupo then
                local sitio = buscar_sitio(player)
                if sitio and crear(sitio) then
                    total = total + 1
                end
            end
        end
    end
end)

-- ============================================================================
-- 9. COMANDOS (admin)
-- ============================================================================
minetest.register_chatcommand("transeunte", {
    params = "[nombre]",
    description = "Coloca un transeunte en tu posicion (admin). Sin argumento, uno libre al azar.",
    privs = {server = true},
    func = function(name, param)
        local player = minetest.get_player_by_name(name)
        if not player then return false, "Jugador no encontrado" end

        local pid
        local pedido = (param or ""):lower():match("%S+")
        if pedido then
            local p = POR_NOMBRE[pedido]
            if not p then
                return false, "No conozco a nadie asi. Usa /transeuntes lista."
            end
            if en_uso[p.id] then
                return false, p.nombre .. " ya anda caminando por ahi."
            end
            pid = p.id
        end

        local pos = player:get_pos()
        pos.y = pos.y + 0.5
        local obj = crear(pos, pid)
        if not obj then
            return false, pedido and "No se pudo crear a " .. pedido
                or "No queda nadie libre en el elenco (todos estan en la calle)."
        end
        local p = PERSONAJES[obj:get_luaentity()._pid]
        return true, p.nombre .. " (" .. p.oficio .. ") en " ..
            minetest.pos_to_string(vector.round(pos))
    end,
})

minetest.register_chatcommand("transeuntes", {
    params = "[info|lista|limpiar]",
    description = "Quienes andan en la calle, el elenco completo, o borrarlos a todos (admin).",
    privs = {server = true},
    func = function(name, param)
        local sub = (param or ""):lower():match("%S+") or "info"

        if sub == "limpiar" then
            local n = 0
            for obj in pairs(vivos) do
                if obj:get_pos() then obj:remove() end
                n = n + 1
            end
            vivos, en_uso = {}, {}
            return true, "Borrados " .. n .. " transeuntes."
        end

        if sub == "lista" then
            local lineas = {"Elenco de Valdivia (" .. #PERSONAJES .. " personas):"}
            for _, p in ipairs(PERSONAJES) do
                table.insert(lineas, "  " .. (en_uso[p.id] and "*" or " ") .. " " ..
                    p.nombre .. " (" .. p.oficio .. ")")
            end
            table.insert(lineas, "(* = en la calle ahora)")
            return true, table.concat(lineas, "\n")
        end

        local lineas = {"En la calle: " .. contar_vivos() .. "/" .. MAX_GLOBAL ..
            "   elenco: " .. #PERSONAJES .. "   hasta " .. POR_JUGADOR .. " por jugador"}
        for obj, pid in pairs(vivos) do
            local pos = obj:get_pos()
            local p = PERSONAJES[pid]
            if p and pos then
                table.insert(lineas, "  " .. p.nombre .. " (" .. p.oficio .. ") en " ..
                    minetest.pos_to_string(vector.round(pos)))
            end
        end
        return true, table.concat(lineas, "\n")
    end,
})

-- Diagnostico: dice por que un punto es o no es calle. Sirve para calibrar
-- LUZ_MIN sin adivinar; pararse en una calle, en una plaza, dentro de una casa
-- y sobre un techo, y comparar las cuatro salidas.
minetest.register_chatcommand("transeunte_scan", {
    description = "Explica si donde estas parado cuenta como calle (admin).",
    privs = {server = true},
    func = function(name)
        local player = minetest.get_player_by_name(name)
        if not player then return false, "Jugador no encontrado" end
        local ppos = player:get_pos()
        local p = {x = math.floor(ppos.x), y = math.floor(ppos.y + 0.5), z = math.floor(ppos.z)}
        local suelo = minetest.get_node({x = p.x, y = p.y - 1, z = p.z}).name
        local luz = minetest.get_natural_light(p, 0.5)

        -- Cuantos de los 24 nodos de alrededor pasan el filtro completo.
        local ok, total = 0, 0
        for dx = -2, 2 do
            for dz = -2, 2 do
                if dx ~= 0 or dz ~= 0 then
                    total = total + 1
                    if es_calle({x = p.x + dx, y = p.y, z = p.z + dz}) then ok = ok + 1 end
                end
            end
        end

        local n_cache = 0
        for _ in pairs(cache_actual) do n_cache = n_cache + 1 end

        return true, table.concat({
            "== scan en " .. minetest.pos_to_string(p) .. " ==",
            "suelo:           " .. suelo .. (es_suelo(suelo) and " (pisable)" or " (NO pisable)"),
            "luz natural 12h: " .. tostring(luz) .. "  (minimo " .. LUZ_MIN .. ")",
            "es_calle:        " .. tostring(es_calle(p)),
            "suelo macizo:    " .. tostring(tiene_suelo_macizo(p)) .. "  (false = techo)",
            "calle ancha:     " .. tostring(es_calle_ancha(p)),
            "alrededor:       " .. ok .. "/" .. total .. " nodos son calle",
            "cache de calle:  " .. n_cache .. " nodos en la generacion actual",
        }, "\n")
    end,
})

-- ============================================================================
-- 10. ARRANQUE
-- ============================================================================
if minetest.get_modpath("mcl_mobs") and mcl_mobs and mcl_mobs.register_mob then
    registrar_mob()
    minetest.log("action", "[" .. modname .. "] Loaded successfully - elenco de " ..
        #PERSONAJES .. " personas, hasta " .. MAX_GLOBAL .. " en la calle")
else
    minetest.log("error", "[" .. modname ..
        "] mcl_mobs no disponible; los transeuntes no se registraron.")
end
