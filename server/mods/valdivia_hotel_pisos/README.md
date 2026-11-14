# valdivia_hotel_pisos

Un piso del Hotel Dreams por jugador (Valdivia, 30001), sin bloques protectores.

## Por qué no con `protector`

`protector_radius` es global y forma un cubo: con radio 20 cada bloque cubre
41×41×41, unos 8 pisos, y además choca con los protectores del admin que ya
cubren el hotel. Achicar el radio afectaría a toda la ciudad y modificar el mod
upstream para hacer cajas planas no vale la pena.

## Geometría (medida desde `map.sqlite`, 2026-11-13)

- Planta: paralelogramo de bordes curvos, dentro de `x 3684..3725`, `z -2968..-2919`. **No es una caja.**
- 15 pisos con paso **5**: losa + 4 de aire. Losa del piso `n` en `y = -9 + 5·(n−1)`
  (piso 1: −9, piso 15: 61), tomado de las 15 paradas del ascensor. Techo en `y = 67`.
- Ascensor: `x 3707..3713`, `z -2943..-2935`, todas las alturas.
- Los pisos 4 y 8–10 conservan interiores originales de Arnis (entrepisos, tabiques).

`huella.json` guarda, por piso, los intervalos `[x1,x2]` de cada fila `z` del
interior: las columnas que tienen losa, erosionadas 1 nodo para dejar fuera la
fachada. Si el edificio cambia de forma hay que regenerarlo leyendo el mapa.

## Cómo funciona

El mod envuelve `minetest.is_protected` **después** de `protector`, así que
decide primero:

| Dónde | Quién construye |
|---|---|
| Interior de un piso con dueño | Dueño, sus amigos, admin (`server` / `protection_bypass`) |
| Piso 1, losas, fachada, ascensor, pisos sin dueño | Lo que diga la protección normal (los protectores de `gabo`) |

- El dueño no puede romper suelo, techo ni fachada: no abre hoyos al vecino.
- En el hotel no se pueden colocar bloques protector (salvo admin).
- Romper un piso ajeno dispara al carabinero igual que un protector.
- Asignaciones en el `mod_storage` del mundo.

## Uso

- Admin: `/hotel asignar 15 luciano80`, `/hotel liberar 15`, `/hotel lista`.
- Dueño: `/hotel mio`, `/hotel amigo <jugador>`, `/hotel amigo quitar <jugador>`.
- Cualquiera: `/hotel info` (en qué piso estás y de quién es).
