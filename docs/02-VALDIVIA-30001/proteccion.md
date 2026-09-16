# Protección de áreas en Valdivia — dos mods que conviven

Valdivia (puerto 30001) usa **dos** sistemas de protección a la vez, cada uno con
un rol distinto. Wetlands (30000) usa solo `protector`; Valdivia mantiene además
`voxelibre_protection` a propósito.

Estado: **en producción** desde 2026-09-16.

## Resumen

| | `voxelibre_protection` | `protector` (Protector Redo) |
|---|---|---|
| Para quién | Solo el admin (priv `protect`) | Todos los jugadores (basta `interact`) |
| Cómo se usa | Comandos (`/protect_here`, `/protect_area`…) | Colocar un bloque |
| Qué protege hoy | `spawn_plaza_chile`: la Plaza Chile y el Hotel Dreams/Discoteca | Las construcciones de cada jugador |
| Forma del área | Caja con `±radio` horizontal; alto por defecto 30 | Cubo de `±protector_radius` alrededor del bloque (hoy 20 → 41×41×41) |
| Dónde guarda | `mod_storage` del mundo (clave `protected_areas`) | En el propio bloque (metadata del nodo) |
| Config | `voxelibre_protection_max_radius = 120`, `voxelibre_protection_default_height = 30` | `protector_radius = 20`, `protector_spawn = 0`, `protector_hud_interval = 5`, `protector_show_interval = 20` |

Ambos se activan en `server/config/luanti-valdivia.conf` **y** en
`server/worlds/valdivia/world.mt` del VPS (`world.mt` gana; ver la jerarquía en
`AGENTS.md`).

## Por qué dos y no uno

- **La Plaza ya estaba protegida con `voxelibre_protection`.** El área
  `spawn_plaza_chile` (dueño `gabo`, creada con `/protect_here 110
  spawn_plaza_chile`, ver `current.md` → «Cambio de spawn») cubre `x 3559..3779`,
  `y -18..22`, `z -3165..-2945`. Es la **única** área de ese mod en Valdivia
  (verificado en `mod_storage.sqlite` el 2026-09-16).
- **Reemplazarla por la protección de spawn de Protector no es equivalente.**
  `protector_spawn` protegería un cubo parecido alrededor de
  `static_spawnpoint`, pero `voxelibre_protection` deja **usar con la mano
  vacía** los nodos interactivos (botones, puertas, palancas) dentro del área, y
  `protector` no tiene esa excepción. Cambiarlo podía dejar trabados los botones
  y puertas de la Plaza y de la discoteca.
- **Los jugadores necesitaban algo sin comandos.** `voxelibre_protection` exige
  el priv `protect`, que `valdivia_newplayer` no otorga; Protector solo pide
  `interact`.

## Cómo conviven

- Los dos envuelven `minetest.is_protected` y llaman a la función anterior: un
  nodo queda bloqueado si **cualquiera** de los dos lo protege.
- **Nadie puede poner un protector dentro de la Plaza:** colocar el bloque ya es
  una acción protegida por `spawn_plaza_chile`.
- Un protector colocado **junto** a la Plaza puede solapar su cubo con ella, y no
  pasa nada: la Plaza sigue bloqueada para ese jugador por `voxelibre_protection`.
- `protector_spawn = 0` a propósito: la Plaza ya está cubierta y no se protege
  dos veces.
- El admin construye en cualquier área si tiene `protection_bypass` (Protector)
  y es dueño de `spawn_plaza_chile` (`voxelibre_protection`).

## Uso para jugadores (Protector)

1. Sacar del inventario creativo el **Bloque de protección** (`protector:protect`)
   o el **Logotipo de la protección** (`protector:protect2`, versión plana tipo
   cartel) y colocarlo en su construcción.
2. **Clic derecho** sobre el bloque: muestra el cubo protegido durante 20 s y
   abre el formulario para **agregar o quitar miembros** (pueden construir ahí).
3. Al caminar dentro de un área protegida, el HUD muestra el dueño.
4. No se puede colocar un protector cuyo cubo se solape con el de **otro** dueño.
5. `/protector_show_area` muestra las áreas de los protectores cercanos;
   `/protector_hide` vuelve invisibles los protectores propios cercanos y
   `/protector_show` los hace visibles otra vez.

## Comandos de admin

| Comando | Mod | Uso |
|---------|-----|-----|
| `/area_info <nombre>` | `voxelibre_protection` | Detalle del área (dueño, límites, miembros) |
| `/list_areas` | `voxelibre_protection` | Lista las áreas |
| `/area_add_member <área> <jugador>` / `/area_remove_member` | `voxelibre_protection` | Miembros de un área |
| `/protect_here <radio> <nombre>` | `voxelibre_protection` | Protege alrededor de tu posición |
| `/unprotect_area <nombre>` | `voxelibre_protection` | Quita un área |
| `/protector_remove <nombres>` | `protector` | Lista de dueños cuyos protectores se borran a medida que se cargan cerca de jugadores (limpiar abusos). `/protector_remove -` vacía la lista |
| `/protector_replace <viejo> <nuevo>` | `protector` | Transfiere protectores de un dueño a otro (mismo mecanismo; `-` vacía la lista) |

## Ajustes y riesgos

- **Radio 20 en una ciudad pública.** Un jugador puede proteger un cubo de 41
  bloques sobre un edificio emblemático o una calle y bloquearlo para el resto.
  Si pasa, bajar `protector_radius` en `luanti-valdivia.conf` (8–10 basta para
  una casa; máximo del mod: 30) y reiniciar. Los protectores ya colocados pasan a
  usar el radio nuevo, porque se calcula en tiempo real. Para casos puntuales,
  `/protector_remove`.
- **No deshabilitar `voxelibre_protection`** sin antes re-proteger la Plaza por
  otra vía: al apagarlo, `spawn_plaza_chile` deja de aplicarse al instante
  (queda guardada en `mod_storage`, pero nadie la lee).
- **Warnings conocidos de `voxelibre_protection`** al arrancar (existían antes de
  Protector): `Overriding item mcl_chests:chest after server startup` (sus
  «Chest protection hooks») y `Undeclared global variable "pvp_arena"`. Anotados
  en [`ROADMAP.md`](ROADMAP.md).
- **Desactivar Protector:** `load_mod_protector = false` en el `.conf` **y** en el
  `world.mt` del VPS, y reiniciar. Los bloques colocados quedan como nodos
  desconocidos hasta reactivarlo.

## Historial

| Fecha | Evento |
|-------|--------|
| 2026-08 | `spawn_plaza_chile` creada con `voxelibre_protection` al mover el spawn a Plaza Chile |
| 2026-09-16 | Protector Redo habilitado en Valdivia (commit `3a4b86a5`): mismos valores que Wetlands salvo `protector_spawn = 0`; `voxelibre_protection` se mantiene para la Plaza |
