# valdivia_juegos_muerte

Mini-juego **"Juegos de la Muerte"** para Valdivia (puerto 30001): un laberinto
cerrado con zombies y un cofre de premio en la esquina opuesta a la entrada.

Solo admin (`privs = {server = true}`). `load_mod_valdivia_juegos_muerte = true`
vive en `server/config/luanti-valdivia.conf` **y** en `worlds/valdivia/world.mt`.

## Comandos

| Comando | Qué hace |
|---|---|
| `/juegos_muerte colocar` | Construye el laberinto en tu posición. **Pide confirmación**: hay que repetir el comando dentro de 30 s. |
| `/juegos_muerte limpiar` | Quita los zombies y **restaura el terreno original** desde el backup. |
| `/juegos_muerte estado` | Activo/inactivo, base, zombies vivos, tamaño del backup. |
| `/juegos_muerte premio` | Coordenadas del cofre. |

Abrir el cofre estando a menos de 6 nodos anuncia al ganador y auto-limpia a los 60 s.

## Geometría

Grid de `MAZE_SIZE = 21` celdas (11×11 salas) × `CELL_SIZE = 3` nodos =
footprint de 63×63, más un anillo perimetral de 1 nodo. Altura útil
`WALL_HEIGHT - 1 = 3` nodos, techo en `base_y + 4`, doble capa de bedrock
arriba y abajo (anti-grief). Entrada: hueco de 1×2 en la cara **−Z** de la
celda (1,1), flanqueado por barrotes. Volumen total tocado: **65 × 9 × 65**.

El laberinto está cerrado y el premio es siempre alcanzable (verificado por BFS
en `tools/` — ver "Pruebas").

## Lecciones aprendidas (v1 tumbó el servidor dos veces, 2026-11-04)

1. **`minetest.get_content_id()` sobre un nombre sin registrar aborta el
   callback.** Desde un chatcommand eso sale como
   `ServerError: AsyncErr: Runtime error from mod '' in callback on_chat_message()`
   y **baja el servidor completo**. v1 inventó cuatro nombres:

   | v1 (inexistente) | Real en VoxeLibre 0.90.1 |
   |---|---|
   | `mcl_core:stone_bricks` | `mcl_core:stonebrick` |
   | `mcl_core:ironbars` | `xpanes:bar_flat` |
   | `mcl_signs:sign_wall_oak` | `mcl_signs:wall_sign_oak` (el cartel se eliminó) |
   | `mcl_mobs:zombie` | `mobs_mc:zombie` |

   Arreglarlos uno por uno no sirve: v2 resuelve los nombres **una vez** en
   `register_on_mods_loaded` contra `minetest.registered_nodes`, con fallback por
   nodo, y deshabilita `colocar` con un mensaje de chat si falta algo. Nunca
   vuelve a llamar `get_content_id` a ciegas. La construcción además va dentro de
   un `pcall`.

2. **Un cofre colocado por VoxelManip queda inservible.** `mcl_chests:chest` es
   un nodo "dummy" que se convierte en `mcl_chests:chest_small` en su
   `on_construct` (ahí se crea el inventario de 9×3 y la entidad del modelo).
   VoxelManip **no** corre `on_construct`. El cofre se coloca con
   `minetest.set_node` después de escribir el VoxelManip, y no se le impone
   formspec propio (v1 ponía uno de 8×4 que no coincidía con el inventario real).

3. **`limpiar` no puede rellenar con aire.** Valdivia es una recreación OSM de
   una ciudad real: v1 dejaba un cráter permanente de 65×13×65 donde antes había
   edificios. v2 toma un **snapshot RLE del área antes de construir** y lo
   restaura al limpiar. El RLE guarda **nombres de nodo, no content IDs** — los
   IDs dependen del orden de carga de mods, así que persistirlos a disco
   corrompería la restauración tras un reinicio.

4. **El estado se persiste a disco.** El laberinto son nodos (sobreviven un
   reinicio); el estado en RAM no. `worlds/valdivia/valdivia_juegos_muerte_state.json`
   guarda bounds + backup, así que `/juegos_muerte limpiar` sigue funcionando
   después de reiniciar el contenedor. Sin esto, un reinicio dejaba el laberinto
   huérfano e imposible de quitar.

5. **`ObjectRef:get_id()` no es API estable de Luanti** y ni VoxeLibre lo usa.
   v1 lo llamaba para indexar los zombies; se reemplazó por guardar los
   `ObjectRef` directamente, más un barrido por radio como respaldo (los refs
   mueren en un reinicio).

6. Los zombies de VoxeLibre tienen `sunlight_damage = 2`: sin techo se queman de
   día. De ahí que el laberinto sea cerrado.

## Pruebas

No hay framework de tests en este repo. La validación de v2 se hizo con un arnés
Lua que simula la API de Luanti (VoxelManip, VoxelArea, registro de nodos, mapa
falso) y comprueba:

- carga del mod y resolución de nombres, con y sin nodos/entidades faltantes
  (degrada con warnings, no crashea);
- confirmación en dos pasos de `colocar`;
- cofre a `base_y + 1` sobre el oro a `base_y`;
- **BFS**: el premio es alcanzable desde la entrada y no se puede salir caminando;
- **restauración exacta**: 71.085 nodos comparados antes/después, 0 diferencias
  (nombre y `param2`).

Además `luac -p init.lua` para sintaxis. Lo semántico (mcl_mobs, formspecs del
cofre) solo se valida con el servidor corriendo.
