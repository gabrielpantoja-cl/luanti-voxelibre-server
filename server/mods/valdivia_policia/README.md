# valdivia_policia — Carabinero anti-grief

Mundo: **Valdivia (30001)** únicamente.

Cuando un jugador intenta romper un bloque (o construir) dentro de un área
protegida que no es suya, aparece un **carabinero** a unos 5 nodos, lo persigue,
lo reta por chat y le **dispara con ballesta** hasta que se acaba el tiempo de
persecución. Después se rinde y desaparece.

No reemplaza a [`protector`](../protector/): el bloqueo de la acción lo sigue
haciendo Protector Redo. Este mod solo agrega la consecuencia.

## Cómo se engancha

`minetest.register_on_protection_violation(pos, name)` — el motor lo dispara
cuando `minetest.is_protected` niega una acción. `protector` usa ese mismo
gancho para `protector_hurt` / `protector_flip` (ambos apagados en Valdivia); el
registro es plural, así que convivimos **sin tocar el mod upstream**.

Filtros antes de enviar un policía:

| Guarda | Por qué |
|---|---|
| `protection_bypass` | El admin nunca es perseguido |
| Debounce 1 s | Un clic sostenido dispara el callback muchas veces por segundo |
| Cooldown 60 s por jugador | Un policía por incidente, no uno por bloque |
| Un policía por infractor | Evita acumular entidades sobre la misma persona |
| Tope global (3) | Protege el rendimiento del servidor |

## Comportamiento

- **Persecución**: movimiento propio con `set_velocity` + `set_yaw`, igual que el
  FSM de `wetlands_npcs`. `walk_chance = 0` para que el FSM de `mcl_mobs` no
  pelee con el nuestro.
- **Caminata con cambios de marcha** (sección 4bis de `init.lua`): corre a
  4,2 n/s a más de 12 nodos, trota al acercarse, baja a paso de calle
  (~1,5 n/s) dentro de 4,5 nodos y **se detiene a 2 nodos** para encararte, con
  histéresis en el freno (vuelve a andar recién a 3,2) para que no tiemble en el
  borde. La velocidad se acelera y frena a 9 n/s² en vez de saltar de 0 al tope,
  y cada carabinero lleva un factor de ritmo propio (0,94–1,08) para que dos no
  caminen igual de parejos. `mcl_mobs` ya escala los fps del ciclo de pasos con
  la velocidad real, así que la cadencia acompaña sola.
- **Sin saltos de adorno**: `jump = false`. Con `walk_chance = 0` el `do_jump()`
  de `mcl_mobs` salta en **cada paso** —incluso quieto al lado del jugador— y le
  mete empujones de `set_acceleration` en el aire: eso era el carabinero
  rebotando como en un trampolín. El salto lo da el mod, y sólo tras 0,45 s sin
  avanzar de verdad (reja, cordón de 1,5 nodos, auto), con 0,8 s de pausa entre
  saltos; los escalones de un nodo los sube `stepheight = 1.1` sin saltar.
- **`do_custom` devuelve `false`**: eso corta el `on_step` de `mcl_mobs` justo
  antes de `do_states` (`api.lua:398`). Sin eso, `do_states_stand()` le ponía la
  velocidad en cero, reiniciaba la animación y le pateaba el yaw al azar **una
  vez por segundo** (timer de `api.lua:312`) — los tirones al caminar. Todo lo
  que sí se usa de `mcl_mobs` (gravedad en `falling()`, rotación suave, head
  swivel) corre antes de `do_custom`.
- **Anti-atasco sin pathfinding**: si queda a más de 25 nodos o deja de
  acercarse durante 2,5 s, reaparece cerca del jugador (ya frenado). Valdivia es
  una ciudad densa generada con Arnis y el A* de `mcl_mobs` se traba en patios y
  escaleras. Dentro de 4,5 nodos **no cuenta como atasco**: ahí frena a
  propósito, y sin esa excepción se reubicaba solo cada 2,5 s mientras caminaba
  al lado del infractor.
- **Ballesta** (más de 3 nodos): cada 1,2 s, si hay `line_of_sight` y está a
  ≤ 18 nodos, **4 HP** por impacto. El dardo que se ve volar es solo visual: el
  daño se resuelve al disparar, tras el tiempo de vuelo.
- **Porra** (≤ 3 nodos): cada 1 s, **6 HP**. Acercarse no te salva.
- **El daño se aplica sí o sí**: `punch` normal primero y, si no bajó el HP,
  descuento directo con `set_hp` — los jugadores no-admin están en gamemode
  creativo y VoxeLibre les anula el `punch`.
- **No letal por defecto**: deja de atacar cuando el golpe mataría y avisa por
  chat. Con `valdivia_policia_letal = 1` sí remata.
- **Inmortal y no robable**: `armor_groups = {immortal = 1, fleshy = 0}`,
  `drops = {}`. Pegarle solo provoca una respuesta por chat.
- **Fuego amigo imposible**: el daño se aplica por nombre al infractor; el
  dardo visual no colisiona con nadie.

## Ciclo de vida (lo que evita basura en el mapa)

- El dardo es `static_save = false`: nunca se guarda en el mapa.
- El policía guarda `_vence` (timestamp). En `on_activate`, si no hay objetivo o
  ya venció, **se borra solo**. Acá `docker stop` siempre termina en SIGKILL, así
  que un reinicio a mitad de persecución dejaría carabineros plantados por la
  ciudad sin este chequeo.
- Se retira también al desconectarse o morir el perseguido.
- Si no hay suelo con dos nodos de aire alrededor del jugador, **no spawnea**
  (mejor ninguno que uno empotrado dentro de un muro).

## Comandos (admin, priv `server`)

| Comando | Qué hace |
|---|---|
| `/policia [jugador]` | Envía un carabinero de prueba (sin cooldown). Sin argumento, va tras ti |
| `/policia_limpiar` | Retira todos los activos + barrido de huérfanos en radio 48 |

## Ajustes (`luanti-valdivia.conf`)

| Setting | Default | Qué controla |
|---|---|---|
| `valdivia_policia_duracion` | 40 | Segundos de persecución |
| `valdivia_policia_cooldown` | 30 | Segundos entre policías para el mismo jugador |
| `valdivia_policia_max` | 3 | Tope global simultáneo |
| `valdivia_policia_velocidad` | 4.2 | Nodos/segundo a fondo (un jugador normal corre 4.3). El trote es 0,60× y el paso de calle 0,36× de este valor |
| `valdivia_policia_aceleracion` | 9 | Nodos/s² al cambiar de marcha (más bajo = arranca y frena más suave) |
| `valdivia_policia_danio` | 4 | HP por dardo |
| `valdivia_policia_cadencia` | 1.2 | Segundos entre disparos |
| `valdivia_policia_alcance` | 18 | Distancia máxima de tiro |
| `valdivia_policia_danio_porra` | 6 | HP del golpe cuerpo a cuerpo |
| `valdivia_policia_cadencia_porra` | 1.0 | Segundos entre porrazos |
| `valdivia_policia_dist_porra` | 3 | A esta distancia cambia ballesta → porra |
| `valdivia_policia_letal` | 0 | `1` = puede matar |

Recordá que `world.mt` manda: activar el mod exige la línea
`load_mod_valdivia_policia = true` también en
`server/worlds/valdivia/world.mt` del VPS.

## Texturas

- `valdivia_policia_skin.png` — 64×32 para `mcl_armor_character.b3d`. Original
  64×64 en `server/skins/raw/policia.png`, mapeo en `server/skins/skins.json`
  (su `fuente` quedó en `null`: no se anotó de dónde se bajó). Convertida
  desde un skin 64×64 horneando la capa overlay de la chaqueta (la gorra vive en
  (32,0)-(63,15), que el formato 64×32 ya conserva).
- `valdivia_policia_flecha.png` — dardo, 16×16.
- `valdivia_policia_particula.png` — destello al aparecer/impactar, 8×8.

## Pendiente

- Ballesta visible en la mano (requiere adjuntar un `wielditem` al bone del
  brazo de `mcl_armor_character.b3d`; sin verificar en este VoxeLibre).
- Sonido de silbato/disparo (`.ogg` propio, aún no grabado).
