# valdivia_hotel_pisos

Un piso del Hotel Dreams por jugador (Valdivia, 30001), sin bloques protectores,
y el ascensor blindado en toda su altura.

## Por qué no con `protector`

`protector_radius` es global y forma un cubo: con radio 20 cada bloque cubre
41×41×41, unos 8 pisos, y además choca con los protectores del admin que ya
cubren el hotel. Achicar el radio afectaría a toda la ciudad y modificar el mod
upstream para hacer cajas planas no vale la pena.

## Geometría (medida desde `map.sqlite`, 2026-11-13)

- Planta: paralelogramo de bordes curvos, dentro de `x 3684..3725`, `z -2968..-2919`. **No es una caja.**
- 15 pisos con paso **5**: losa + 4 de aire. Losa del piso `n` en `y = -9 + 5·(n−1)`
  (piso 1: −9, piso 15: 61), coincide con las 15 paradas del ascensor. El techo
  está en `y = 67`, así que el piso 15 tiene **5** de alto (`y 62..66`).
- Los pisos 4 y 8–10 conservan interiores originales de Arnis (entrepisos, tabiques).

`huella.json` guarda, por piso, los intervalos `[x1,x2]` de cada fila `z` del
interior: las columnas que tienen losa, erosionadas 1 nodo para dejar fuera la
fachada. Si el edificio cambia de forma hay que regenerarlo leyendo el mapa.

## Ascensor: zona común blindada

| | |
|---|---|
| Piezas `celevator` (cabina, puertas, botones, linternas, PI, máquina, controlador, drive) | `x 3709..3711`, `z -2943..-2937`, `y -8..69` |
| Pozo de vidrio | `x 3708..3711`, `z -2940..-2936` |
| **Zona protegida** (huella + 2 de margen por lado) | **`x 3706..3713`, `z -2945..-2934`, `y -11..71`** |

Dentro de esa zona **solo el admin** (`server` o `protection_bypass`) puede
romper, colocar o usar lo que pida protección. Eso incluye a cualquier jugador
en modo creativo. La regla **no depende de los bloques protector**: aunque se
piquen o se muevan, el ascensor sigue blindado. Va primero en
`is_protected`, antes que los pisos.

Por qué tanto cuidado: picar el **drive** o la **máquina** borra su vínculo con
el carro (`carid`) y no se recupera al recolocarlos; repararlo exige
reubicar la máquina y reasignar el Car ID a mano. Además los nodos de la
cabina ya son indestructibles (parche en `celevator/car.lua`), y las
explosiones están apagadas en Valdivia (`mcl_explosions_griefing = false`).

Usar el ascensor no requiere nada: llamarlo, entrar y elegir piso funcionan
igual que antes (con los protectores de `gabo` ya estaba protegido para los
jugadores). Un jugador que golpee la cabina con *sneak* registra una violación
de protección, y eso puede traer al carabinero (`valdivia_policia`).

La constante es `ASCENSOR` en `init.lua`. Si se mueve el ascensor, volver a
medir y actualizarla.

## Cómo funciona

El mod envuelve `minetest.is_protected` **después** de `protector`, así que
decide primero:

| Dónde | Quién construye |
|---|---|
| Zona del ascensor (con margen) | Solo admin |
| Interior de un piso con dueño | Dueño, sus amigos, admin |
| Piso 1, losas, fachada, pisos sin dueño | Lo que diga la protección normal (los protectores de `gabo`) |

- El dueño no puede romper suelo, techo ni fachada: no abre hoyos al vecino.
- En el hotel no se pueden colocar bloques protector (salvo admin).
- Romper un piso ajeno dispara al carabinero igual que un protector.
- HUD abajo a la izquierda: `Piso N · Propietario: <jugador>`, `Piso N · Disponible`,
  `Hotel Dreams · Piso 1 (zona comun)` o `Ascensor · Zona comun protegida (gabo)`.
  Reutiliza el elemento de `protector` en vez de superponer otro.
- Asignaciones en el `mod_storage` del mundo (clave `cfg`). Los dueños actuales
  no se documentan en este repo público: se consultan con `/hotel lista`.

## Uso

- Admin: `/hotel asignar <n> <jugador>`, `/hotel liberar <n>`, `/hotel lista`. Un piso por jugador; el 1 no se asigna.
- Dueño: `/hotel mio`, `/hotel amigo <jugador>`, `/hotel amigo quitar <jugador>`.
- Cualquiera: `/hotel info` (en qué piso estás y de quién es).
