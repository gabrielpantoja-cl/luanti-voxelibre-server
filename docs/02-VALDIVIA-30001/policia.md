# Carabinero anti-grief (`valdivia_policia`)

Cuando alguien intenta romper un bloque —o construir— dentro de un área
protegida que no es suya, aparece un **carabinero** que lo persigue, lo reta por
chat y le **dispara con ballesta** durante 25 s. Después se rinde y desaparece.

Estado: **implementado 2026-10-30**. Solo Valdivia (30001).

No reemplaza a [`protector`](proteccion.md): el bloqueo de la acción lo sigue
haciendo Protector Redo, que queda **upstream sin modificar**. Este mod solo
agrega la consecuencia.

## Por qué con violencia

Valdivia es modo supervivencia con mobs hostiles de noche: el daño ya es parte
del mundo. La diferencia es que este daño es **dirigido y supervisado** — solo
le llega a quien agrede la propiedad de otro, nunca a quien pasaba por ahí, y es
**no letal por defecto**.

## Qué hace

| Elemento | Detalle |
|---|---|
| Disparador | `minetest.register_on_protection_violation`, que el motor llama cuando `minetest.is_protected` niega una acción. `protector` usa ese mismo gancho para `protector_hurt` / `protector_flip` (ambos apagados acá); el registro es plural, así que conviven. |
| Aparición | A ~5 nodos del infractor, sobre suelo firme con 2 nodos de aire. Si no hay espacio (jugador encerrado), **no aparece** — mejor ninguno que uno empotrado en un muro de Arnis. |
| Persecución | 40 s. Movimiento propio (`set_velocity` + `set_yaw`) a 4,2 nodos/s (un jugador normal corre 4,3), con `walk_chance = 0` para que el FSM de `mcl_mobs` no pelee con el nuestro. Mismo patrón que `wetlands_npcs`. |
| Ballesta (> 3 nodos) | Cada 1,2 s, si hay `line_of_sight` y está a ≤ 18 nodos: **4 HP**. |
| Porra (≤ 3 nodos) | Cada 1 s: **6 HP**. Acercarse al carabinero no te salva, te conviene arrancar. |
| No letal | Deja de atacar cuando el golpe mataría, y lo avisa por chat. Con `valdivia_policia_letal = 1` sí remata. |
| Inmortal | `armor_groups = {immortal = 1, fleshy = 0}`, `drops = {}`. Pegarle solo provoca una respuesta por chat; no se puede farmear. |
| Sin fuego amigo | El daño se aplica por nombre al infractor; el dardo que se ve volar no colisiona con nadie. |
| Se retira | Al acabarse el tiempo, o si el perseguido se desconecta o muere. |

## Las guardas (por qué no se vuelve una plaga)

| Guarda | Por qué |
|---|---|
| `protection_bypass` | El admin nunca es perseguido |
| Debounce 1 s | Un clic sostenido dispara el callback **muchas veces por segundo**; sin esto saldrían decenas de policías de un solo intento |
| Cooldown 60 s por jugador | Un policía por incidente, no uno por bloque |
| Un policía por infractor | No se acumulan entidades sobre la misma persona |
| Tope global 3 | Protege el rendimiento del servidor |

## Dos decisiones técnicas que vale conocer

**1. No usa pathfinding.** Si el carabinero queda a más de 25 nodos o deja de
acercarse durante 4 s, **reaparece** cerca del jugador (con destello, como si
hubiera dado la vuelta a la manzana). El A* de `mcl_mobs` se traba en los patios
y escaleras de una ciudad OSM densa como Valdivia; esto es más barato y nunca
deja al policía clavado contra una pared.

**2. El dardo es decorativo; el tiro se resuelve al disparar.** La primera
versión usaba un proyectil con colisión y **no acertaba nunca**: a 22 nodos/s y
con el paso del servidor en ~0,09 s el dardo avanza ~2 nodos por tick, así que
*se saltaba* al jugador justo cuando el policía lo tenía cerca. Verificado en
producción el 2026-10-30 con dos persecuciones completas sin un solo impacto.
Ahora el impacto se calcula al disparar (con `line_of_sight`) y se aplica tras
el tiempo de vuelo; el dardo solo se ve volar. Es `static_save = false`: jamás
se guarda en el mapa.

**3. El daño se aplica a mano si el `punch` no surte efecto.** En Valdivia los
jugadores no-admin están en **gamemode creativo** (`valdivia_newplayer`, para
tener inventario completo en un mundo de supervivencia) y VoxeLibre les anula el
daño del `punch` — verificado en producción el 2026-10-30: `hp=20` durante toda
una persecución. Si tras el impacto el HP no bajó, el dardo lo descuenta con
`set_hp`, con piso de 1 HP cuando el modo no letal está activo.

**4. Anti-huérfanos.** El policía guarda un timestamp `_vence`; en `on_activate`,
si no hay objetivo vivo o ya venció, **se borra solo**. Acá `docker stop` siempre
termina en SIGKILL (ver `MEMORY`/`AGENTS.md`), así que un reinicio a mitad de
persecución dejaría carabineros plantados por la ciudad sin este chequeo.

## Comandos (admin, priv `server`)

| Comando | Uso |
|---|---|
| `/policia [jugador]` | Envía un carabinero de prueba, saltándose el cooldown. Sin argumento va tras ti |
| `/policia_limpiar` | Retira todos los activos + barrido de huérfanos en radio 48 |

## Ajustes (`luanti-valdivia.conf`)

| Setting | Default | Qué controla |
|---|---|---|
| `valdivia_policia_duracion` | 40 | Segundos de persecución |
| `valdivia_policia_cooldown` | 30 | Segundos entre policías para el mismo jugador |
| `valdivia_policia_max` | 3 | Tope global simultáneo |
| `valdivia_policia_velocidad` | 4.2 | Nodos/segundo (un jugador normal corre 4,3; con `fast`, más — por eso existe la reubicación) |
| `valdivia_policia_danio` | 4 | HP por dardo |
| `valdivia_policia_cadencia` | 1.2 | Segundos entre disparos |
| `valdivia_policia_alcance` | 18 | Distancia máxima de tiro |
| `valdivia_policia_danio_porra` | 6 | HP del golpe cuerpo a cuerpo |
| `valdivia_policia_cadencia_porra` | 1.0 | Segundos entre porrazos |
| `valdivia_policia_dist_porra` | 3 | A esta distancia cambia ballesta → porra |
| `valdivia_policia_letal` | 0 | `1` = puede matar |

## Skin

`textures/valdivia_policia_skin.png`, 64×32 para `mcl_armor_character.b3d`
(3 capas: `{skin, blank, blank}`). Convertida desde un 64×64 **horneando la capa
overlay de la chaqueta** sobre el torso antes de recortar; la gorra vive en
(32,0)-(63,15), que el formato 64×32 ya conserva tal cual. Un
`crop((0,0,64,32))` pelado habría perdido la chaqueta — ver la matriz de
formatos en `AGENTS.md`. El 64×64 original queda archivado en
`server/mods/valdivia_policia/raw_skins/`.

## Despliegue

1. `load_mod_valdivia_policia = true` en `luanti-valdivia.conf` **y** en el
   `world.mt` de Valdivia del VPS (`world.mt` manda).
2. Reiniciar `luanti-valdivia`.
3. In-game: `/policia` para probarlo sin tener que romper nada.

Pendientes de verificación y mejoras: ver [`ROADMAP.md`](ROADMAP.md).
