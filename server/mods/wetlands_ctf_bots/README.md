# wetlands_ctf_bots

Bots para el CTF de rubenwardy (puerto 30003), para que un jugador solo (o dos)
tenga con quién jugar. Solo se carga en `luanti-ctf.conf` + `worlds/ctf/world.mt`.

## Uso

- Al entrar (con ≤ 2 jugadores conectados) aparece el menú **¿Jugar con bots?**:
  rivales (0–10), compañeros (0–10) y dificultad (Fácil / Normal / Difícil).
- `/bots` vuelve a abrir el menú; `/bots off` los apaga.
- La elección se guarda (mod_storage) y se reaplica en cada partida nueva.
- Si se conectan más de 2 jugadores, los bots se retiran solos.

## Cómo juegan

| Rol | Equipo | Qué hace |
|---|---|---|
| Atacante (mitad de los rivales, redondeado arriba) | rival | Va por la bandera enemiga, la lleva a su base; escolta al bot que la lleva |
| Defensor | rival | Patrulla a ~7 nodos de su bandera, ataca a quien se acerque |
| Escolta | tu equipo | Te sigue y ataca a los enemigos que se te acercan |

Todos persiguen a quien lleve la bandera de su equipo. Pelean cuerpo a cuerpo.

- **Daño a jugadores**: `set_hp` con `reason = {type = "set_hp"}`, un % del `hp_max`
  según la dificultad (5 / 8 / 12 %). Respetan la inmunidad de respawn del CTF.
- **Daño a bots**: con las armas normales del CTF (espada, rifle). Vida = 60 / 80 / 100 %
  de 200. Sin fuego amigo. Reaparecen en su base a los 8 s.
- **Bandera**: si un bot toma la tuya, el poste queda como `flag_captured_top`; si lo
  eliminas, vuelve. Si llega a su base (y su bandera está en casa), **ganan los bots**
  y empieza otra partida (`ctf_modebase.start_new_match(5)`). Si tú capturas la de
  ellos, es la captura normal del CTF.
- **Navegación**: `minetest.find_path` por tramos de ~26 nodos; si se atasca salta,
  replanifica y a los 7 s se reubica unos nodos más adelante.
- **Mapas**: con bots activos, la rotación se limita a mapas abiertos (`MAPAS_BOTS`).
  Al activar bots estando solo en otro mapa, se cambia de partida a uno de esos.

## Detalles técnicos

- Entidades, no jugadores falsos: el CTF ignora golpes de no-jugadores
  (`features.lua` `on_punchplayer`) y la toma de bandera exige jugador.
- `static_save = false` + forceload transitorio del bloque de cada bot y de ambas
  bases (`max_forceloaded_blocks = 32` en `luanti-ctf.conf`); si un bot igual se
  descarga, el gestor lo hace reaparecer.
- Cada bot guarda el id de partida; uno de una partida vieja se borra solo.
