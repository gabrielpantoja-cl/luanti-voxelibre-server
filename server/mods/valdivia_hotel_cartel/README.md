# valdivia_hotel_cartel

Mega cartel **directorio del Hotel Dreams** para Valdivia (puerto 30001): un
mural de **6 × 4 nodos** en la planta baja (piso 1) que lista los 15 pisos y qué
hay en cada uno.

Solo se carga en Valdivia (`load_mod_valdivia_hotel_cartel = true` en
`luanti-valdivia.conf`).

## Comandos

| Comando | Quién | Qué hace |
|---|---|---|
| `/cartel` | admin (`server`) | Coloca el mural 3 nodos delante tuyo, orientado hacia ti |
| `/cartel <1-12>` | admin | Igual, pero a esa distancia |
| `/cartel forzar` | admin | Coloca aunque haya nodos en medio (los reemplaza) |
| `/cartel quitar` | admin | Borra todos los nodos de cartel a 20 nodos a la redonda |
| `/pisos` | cualquiera | Abre el directorio como formspec |

El mural arranca **a la altura de tus pies** y sube 4 nodos, centrado en tu
columna. Si alguna de las 24 celdas está ocupada, el comando **no coloca nada**
y te dice cuál — medio cartel puesto es peor que ninguno. Clic derecho en
cualquier mosaico abre el mismo directorio en pantalla.

## Cómo cambiar los pisos

Todo vive en **`pisos.json`** (fuente única: la leen `init.lua` para el
formspec y el generador para dibujar). Después de editarlo:

```bash
cd server/mods/valdivia_hotel_cartel
python tools/generate_cartel.py --preview   # regenera textures/ + lámina de revisión
```

y commitear las texturas. En el juego hace falta reiniciar el contenedor
(las texturas son media del servidor) y volver a poner el cartel no es
necesario: los nodos son los mismos, solo cambia la imagen.

Campos de cada piso:

| Campo | Para qué |
|---|---|
| `n` | Número de piso (coincide con el *landing number* del ascensor) |
| `nombre` | Texto grande |
| `detalle` | Segunda línea chica, en gris (quién lo reservó) |
| `estado` | `libre` (verde), `reservado` (dorado), `fiesta` (rosado) |

`grid` controla el tamaño del mural (`cols`, `filas`, `tile`). Si 6 nodos de
ancho no caben en la pared del hall, bajar a `"cols": 5` y regenerar: el mod
registra los nodos según el JSON, no hay nada hardcodeado.

## Por qué un mural y no un solo nodo

Una textura de nodo de 16×16 px no alcanza ni para una palabra legible. Acá la
lámina completa es de **1536 × 1024 px** y cada nodo lleva un recorte de
256×256, así que el cartel se lee de pie desde el otro lado del hall.

## Por qué no se hizo dentro de `celevator`

El display del ascensor (*position indicator*) es de **16 segmentos y tres
caracteres**: `celevator.pi.settext()` hace `string.sub(text, 1, 3)`
(`celevator/pilantern.lua:132`), y el `floorname` del controlador alimenta
exactamente ese display. Ahí no cabe "Rave Dreams" — el mod del ascensor no
puede mostrar un directorio, por diseño. Lo que sí conviene hacer en
`celevator` es lo cosmético pendiente: dejar los PI en `1..15` en vez de
`0..14`, desde el formspec del controlador (*Edit Floor Table*).

## Indestructible

En VoxeLibre `diggable = false` **se ignora**: `_mcl_autogroup` reescribe todos
los nodos al cargar y les pone `diggable = true` salvo que estén en el grupo
`unbreakable`/`indestructible`. Por eso los mosaicos llevan esos grupos +
`can_dig = false` + `on_blast` vacío, igual que `valdivia_cabina` (dos
jugadores rompieron cabinas el 2026-10-07 por no tenerlos).
