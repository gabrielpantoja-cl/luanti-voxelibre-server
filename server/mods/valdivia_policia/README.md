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
- **Anti-atasco sin pathfinding**: si queda a más de 25 nodos o deja de
  acercarse durante 4 s, reaparece cerca del jugador. Valdivia es una ciudad
  densa generada con Arnis y el A* de `mcl_mobs` se traba en patios y escaleras.
- **Ballesta**: cada 2,5 s, si hay `line_of_sight` y está a ≤ 14 nodos, lanza un
  dardo (`valdivia_policia:dardo`) a 22 nodos/s. 2 HP de daño por impacto.
- **No letal por defecto**: si al jugador le queda ≤ 2 HP, deja de disparar y
  avisa por chat. Con `valdivia_policia_letal = 1` sí remata.
- **Inmortal y no robable**: `armor_groups = {immortal = 1, fleshy = 0}`,
  `drops = {}`. Pegarle solo provoca una respuesta por chat.
- **Fuego amigo imposible**: el dardo guarda el nombre del infractor y solo
  impacta a ese jugador.

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
| `valdivia_policia_duracion` | 25 | Segundos de persecución |
| `valdivia_policia_cooldown` | 60 | Segundos entre policías para el mismo jugador |
| `valdivia_policia_max` | 3 | Tope global simultáneo |
| `valdivia_policia_velocidad` | 3.2 | Nodos/segundo (un jugador con `fast` corre más) |
| `valdivia_policia_danio` | 2 | HP por dardo |
| `valdivia_policia_cadencia` | 2.5 | Segundos entre disparos |
| `valdivia_policia_alcance` | 14 | Distancia máxima de tiro |
| `valdivia_policia_letal` | 0 | `1` = puede matar |

Recordá que `world.mt` manda: activar el mod exige la línea
`load_mod_valdivia_policia = true` también en
`server/worlds/valdivia/world.mt` del VPS.

## Texturas

- `valdivia_policia_skin.png` — 64×32 para `mcl_armor_character.b3d`, convertida
  desde un skin 64×64 horneando la capa overlay de la chaqueta (la gorra vive en
  (32,0)-(63,15), que el formato 64×32 ya conserva).
- `valdivia_policia_flecha.png` — dardo, 16×16.
- `valdivia_policia_particula.png` — destello al aparecer/impactar, 8×8.

## Pendiente

- Ballesta visible en la mano (requiere adjuntar un `wielditem` al bone del
  brazo de `mcl_armor_character.b3d`; sin verificar en este VoxeLibre).
- Sonido de silbato/disparo (`.ogg` propio, aún no grabado).
