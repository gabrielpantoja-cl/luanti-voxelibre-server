# valdivia_hotel_pisos

Un piso del Hotel Dreams por jugador (Valdivia, 30001), sin bloques protectores.

## Por qué no con `protector`

`protector_radius` es global y forma un cubo: con radio 20 cada bloque cubre
41×41×41, unos 10 pisos de 4 de alto, y además choca con el protector del admin
que ya cubre el hotel. Achicar el radio afectaría a toda la ciudad y modificar
el mod upstream para hacer cajas planas no vale la pena.

## Cómo funciona

El mod envuelve `minetest.is_protected` **después** de `protector`, así que
decide primero:

| Dónde | Quién construye |
|---|---|
| Interior de un piso con dueño (losa+1 … siguiente losa−1) | Dueño, sus amigos, admin (`server` / `protection_bypass`) |
| Piso 1, losas, zonas excluidas (ascensor, escaleras), pisos sin dueño | Lo que diga la protección normal (el protector de `gabo`) |

- El dueño no puede romper suelo ni techo: no abre hoyos al vecino.
- Dentro del hotel no se pueden colocar bloques protector (salvo admin).
- Romper un piso ajeno dispara al carabinero igual que un protector.
- Estado en el `mod_storage` del mundo.

## Calibración (admin, una vez)

1. Parado en una esquina interior: `/hotel marcar 1`; en la opuesta: `/hotel marcar 2`; luego `/hotel limites`.
2. Parado sobre el suelo del piso 1: `/hotel base` (mide la altura sola; o `/hotel base 4`).
3. Ascensor y escaleras: marcar sus dos esquinas y `/hotel excluir ascensor` (columna en todas las alturas).
4. Verificar subiendo piso por piso con `/hotel info`. Si un piso no es regular: `/hotel losa <n>` parado en él.

## Uso

- Admin: `/hotel asignar 15 luciano80`, `/hotel liberar 15`, `/hotel lista`.
- Dueño: `/hotel mio`, `/hotel amigo <jugador>`, `/hotel amigo quitar <jugador>`.
- Cualquiera: `/hotel info`.
