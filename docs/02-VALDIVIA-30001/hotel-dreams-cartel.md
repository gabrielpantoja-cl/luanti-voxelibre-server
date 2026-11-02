# Mega cartel del Hotel Dreams (`valdivia_hotel_cartel`)

**Mundo**: Valdivia (30001) — **solo ahí** (`load_mod_valdivia_hotel_cartel = true`
en `luanti-valdivia.conf`).
**Creado**: 2026-11-02.

Mural de **6 × 4 nodos** en la planta baja del Hotel Dreams con el directorio de
los 15 pisos: qué hay en cada uno y cuáles están reservados. Complementa al
ascensor (`celevator`, ver [`current.md`](current.md)): el ascensor te lleva, el
cartel te dice adónde.

## Contenido actual

| Piso | Qué hay | Estado |
|---|---|---|
| 1 | Rave Dreams, Sala Gamer y más — planta baja, zona común | fiesta |
| 2–10 | Disponible | libre |
| 11 | Reservado (`gael`) | reservado |
| 12 | Disponible | libre |
| 13 | Reservado (`loxos`) | reservado |
| 14 | Disponible | libre |
| 15 | Reservado (`luciano80`) | reservado |

La tabla **no se edita en Lua**: vive en
`server/mods/valdivia_hotel_cartel/pisos.json`, que es la fuente única que leen
tanto el mod (para el formspec) como el generador de texturas.

## Colocarlo en el juego

```
/cartel              # lo pone 3 nodos delante tuyo, mirándote
/cartel 5            # a 5 nodos
/cartel forzar       # aunque haya nodos en medio
/cartel quitar       # borra el cartel a 20 nodos a la redonda
/pisos               # abre el directorio como menú (cualquier jugador)
```

Solo el admin (`server`) coloca o quita. El mural arranca a la altura de tus
pies y sube 4 nodos (el hall tiene 5 de alto: los pisos están cada 5 bloques,
`y=-8` el piso 1), centrado en tu columna y orientado hacia donde estás parado.
Si alguna de las 24 celdas está ocupada **no coloca nada** y te dice cuál.

Los mosaicos son indestructibles (grupos `unbreakable`/`indestructible` +
`can_dig = false` + `on_blast` vacío): en VoxeLibre `diggable = false` solo
**se ignora**, porque `_mcl_autogroup` reescribe todos los nodos al cargar.

## Cambiar el directorio

1. Editar `server/mods/valdivia_hotel_cartel/pisos.json`.
2. `cd server/mods/valdivia_hotel_cartel && python tools/generate_cartel.py --preview`
3. Mirar `tools/cartel_preview.png` (la lámina entera, antes de trocear).
4. Commitear `pisos.json` + `textures/`.
5. Deploy normal (pull en el VPS) y **reiniciar el contenedor**: las texturas
   son media del servidor, los clientes las re-descargan al reconectar. No hay
   que volver a colocar el cartel — los nodos son los mismos.

`grid` en el JSON controla el tamaño (`cols`, `filas`). Si 6 nodos de ancho no
caben en la pared, bajar a `"cols": 5` y regenerar: los nodos se registran a
partir del JSON.

## Por qué no se resolvió "mejorando celevator"

Era la primera idea y **no es posible**: el display de piso del ascensor (el
*position indicator*) es un display de 16 segmentos de **tres caracteres** —
`celevator.pi.settext()` hace `string.sub(text, 1, 3)`
(`server/mods/celevator/pilantern.lua:132`), y el `floorname` que se edita en el
controlador alimenta exactamente ese display (`controllerfw.lua:1331`). "Rave
Dreams" no entra ni recortado. El propio mod lo dice en su wizard: *"The Floor
Name is how the floor will be displayed on the position indicators"*.

Lo que sí queda pendiente en `celevator`, y es puramente cosmético: los PI están
cargados como `0..14` y deberían ser `1..15` (o `PB, 2..15`). Se cambia en el
juego desde el controlador → *Edit Floor Table*; cambiar el PI nunca rompe un
botón, porque los botones usan el *landing number*, no el PI.

## Por qué un mural de nodos y no un solo nodo

Una textura de nodo de 16×16 px no alcanza para una palabra legible. El cartel
es una sola lámina de **1536 × 1024 px** troceada en 24 recortes de 256×256, uno
por nodo — el mismo truco que usa `celevator` para su display, pero a lo grande.
Cada mosaico es un nodo distinto (`valdivia_hotel_cartel:p_r<fila>c<col>`) y el
comando `/cartel` los coloca en orden, así que la alineación nunca se hace a
mano.

Detalle completo del mod: `server/mods/valdivia_hotel_cartel/README.md`.
