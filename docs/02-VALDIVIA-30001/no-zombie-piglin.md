# Zombie Piglin deshabilitado — Valdivia

Valdivia es la única ciudad de este proyecto publicada en la lista de servidores
de Luanti (`servers.luanti.org`), y su objetivo es verse como una ciudad, no
como el Nether. `mobs_spawn = false` ya impedía el spawn natural de hostiles,
pero eso no bloquea que un jugador **coloque un huevo manualmente**.

## Causa raíz

`luanti-valdivia.conf` da el priv `creative` a **todo jugador nuevo por
defecto** (`default_privs = interact,shout,fast,creative,spawn,teleport`), lo
que le da acceso al inventario creativo completo, incluidos los huevos de
invocación. Solo existen 3 huevos de piglin en VoxeLibre:

| Huevo | Item | Estado en Valdivia |
|-------|------|---------------------|
| Piglin | `mobs_mc:piglin` | Sin cambios |
| Piglin Brute | `mobs_mc:piglin_brute` | Sin cambios |
| **Zombie Piglin** | `mobs_mc:zombified_piglin` | **Deshabilitado** |

Jugadores porfiados sacaban el huevo de Zombie Piglin del inventario creativo
y colocaban muchos de una vez, recargando el mapa y afeando la ciudad.

## Solución: `valdivia_no_zombie_piglin`

Mod nuevo, **solo cargado en Valdivia** (`load_mod_valdivia_no_zombie_piglin`
en `luanti-valdivia.conf`; no toca Wetlands/GAELSIN/CTF, donde un piglin
zombie puede ser contenido legítimo del Nether):

1. **Oculta el huevo** del inventario creativo (`not_in_creative_inventory`)
   y lo vuelve **inerte**: si alguien ya tenía uno guardado de antes,
   colocarlo no invoca nada ni lo consume.
2. **Limpieza automática cada 5 minutos**: recorre `minetest.luaentities`
   (mismo mecanismo que el comando nativo `/clearmobs`) y elimina cualquier
   `mobs_mc:zombified_piglin` / `mobs_mc:baby_zombified_piglin` que siga
   activo, respetando nametag y domesticados. Solo actúa sobre entidades
   **cargadas** — la limitación del engine es la misma que la de
   `/clearmobs` — pero al repetirse cada 5 min termina cubriendo toda la
   ciudad a medida que los jugadores la recorren, sin tocar `map.sqlite`.

## Por qué NO se editó `map.sqlite` directamente (2026-07-04)

Se evaluó borrar los piglin ya invocados directamente en la base de datos.
Los mobs **no son filas de una tabla** — están serializados dentro del blob
binario comprimido de cada mapblock (`blocks.data`), sin una tabla
`objects(name, pos)` editable. Se intentó un diagnóstico de solo lectura
buscando la cadena `"piglin"` como texto plano en los ~1.9M bloques del mapa;
dio 0 coincidencias. Se descartó como método válido con un control: buscar
`"valdivia_discoteca"` (sabiendo que el DJ/bailarines SÍ están persistidos)
**también dio 0 coincidencias** — confirma que el nombre de la entidad no se
guarda como texto plano accesible por substring, y que parchear el blob a
mano arriesga corromper el mapblock. La vía correcta es siempre a través del
engine (`/clearmobs`, o el mod de arriba), nunca edición binaria directa.

## Comandos relacionados

```
/clearmobs zombified   — limpieza manual inmediata (solo mobs cargados; hay que estar cerca)
/mobstats               — conteo de mobs cargados por nombre, útil para verificar antes/después
```

## Historial

| Fecha | Evento |
|-------|--------|
| 2026-07-04 | Diagnóstico: `map.sqlite` no permite edición directa de mobs (formato binario, no hay tabla de objetos) |
| 2026-07-04 | Mod `valdivia_no_zombie_piglin` desplegado: huevo deshabilitado + limpieza automática cada 5 min |
