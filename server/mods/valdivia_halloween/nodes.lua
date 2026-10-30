-- ============================================================================
-- valdivia_halloween / nodes.lua  --  las manchas de sangre
-- ============================================================================
-- Tres nodos (chica, mediana, grande) que son CALCOMANIAS, no bloques:
-- drawtype "signlike" + paramtype2 "wallmounted" dibuja una lamina plana
-- pegada a la cara del nodo solido vecino, asi que una misma mancha sirve para
-- el piso, una pared o el techo segun su param2. Eso es justo lo que se
-- necesita para ensangrentar los edificios de Arnis sin tocar un solo nodo del
-- mapa: la mancha ocupa el AIRE de al lado del muro, no el muro.
--
-- walkable = false y pointable = true: no estorban al caminar, pero el admin
-- puede apuntarlas y picarlas a mano si alguna quedo fea.
--
-- No entran al inventario creativo (not_in_creative_inventory = 1). En
-- Valdivia los jugadores tienen inventario creativo completo
-- (mcl_enable_creative_mode = true en luanti-valdivia.conf), y sangre repartida
-- a mano por todo el mapa seria sangre que /halloween off no sabe borrar:
-- limpiar solo deshace lo que puso el mod.
--
-- OJO VoxeLibre: _mcl_autogroup reescribe todos los nodos al cargar y fuerza
-- diggable = true salvo en grupo unbreakable/indestructible (ver AGENTS.md).
-- Aca eso no molesta porque las queremos picables, pero si alguna vez se busca
-- una mancha indestructible no alcanza con diggable = false.

local modname = minetest.get_current_modname()
local V = valdivia_halloween

V.NODOS = {
    modname .. ":sangre1",
    modname .. ":sangre2",
    modname .. ":sangre3",
}

-- Busqueda O(1) para el limpiador: "este nodo es nuestro?"
V.ES_NODO = {}
for _, n in ipairs(V.NODOS) do V.ES_NODO[n] = true end

for i = 1, 3 do
    local tex = "valdivia_halloween_sangre" .. i .. ".png"
    minetest.register_node(modname .. ":sangre" .. i, {
        description = "Mancha de sangre (Halloween)",
        drawtype = "signlike",
        tiles = {tex},
        inventory_image = tex,
        wield_image = tex,
        paramtype = "light",
        paramtype2 = "wallmounted",
        sunlight_propagates = true,
        walkable = false,
        pointable = true,
        is_ground_content = false,
        buildable_to = false,
        floodable = true,          -- si sube el rio, se va sola
        drop = "",
        selection_box = {type = "wallmounted"},
        groups = {
            handy = 1,
            dig_immediate = 3,
            attached_node = 1,     -- si se pica el muro, la mancha cae sola
            not_in_creative_inventory = 1,
            dig_by_water = 1,
            destroy_by_lava_flow = 1,
            dig_by_piston = 1,
        },
        _mcl_hardness = 0,
        _mcl_blast_resistance = 0,
    })
end

-- Particula de gota. La usan la mordida, la infeccion y el goteo ambiental.
function V.salpicar(pos, cantidad, fuerza)
    cantidad = cantidad or 12
    fuerza = fuerza or 2
    minetest.add_particlespawner({
        amount = cantidad,
        time = 0.3,
        minpos = {x = pos.x - 0.3, y = pos.y, z = pos.z - 0.3},
        maxpos = {x = pos.x + 0.3, y = pos.y + 0.6, z = pos.z + 0.3},
        minvel = {x = -fuerza, y = 1, z = -fuerza},
        maxvel = {x = fuerza, y = fuerza + 1, z = fuerza},
        minacc = {x = 0, y = -9, z = 0},
        maxacc = {x = 0, y = -9, z = 0},
        minexptime = 0.4,
        maxexptime = 1.1,
        minsize = 1,
        maxsize = 2.5,
        texture = "valdivia_halloween_particula.png",
        glow = 3,
    })
end

minetest.log("action", "[" .. modname .. "] nodes.lua: 3 manchas registradas")
