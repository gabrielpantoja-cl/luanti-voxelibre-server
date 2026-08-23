# Oretracker — `orehud` + `xray` en GAELSIN

Modpack de terceros (`server/mods/oretracker/`) instalado en GAELSIN desde
**2026-07-26**. Da asistencia de mineria opcional a jugadores con el privilege
adecuado. No toca el balance PvP ni la proteccion de areas.

Este doc cubre:

- Que hace cada submod y como funciona por dentro.
- Como se otorga el acceso a un jugador.
- Parametros de tuning y donde cambiarlos.
- Pitfalls conocidos (especialmente del xray).
- Cosas concretas que quedan por revisar para una v2.

Configuracion autoritativa: `server/config/luanti-gaelsin.conf:124,162` (gate
secundario) y `server/worlds/gaelsin/world.mt:30-31` (gate primario — `world.mt`
gana si las dos discrepan). Ver jerarquia en
[`docs/00-SHARED/config/01-CONFIGURATION_HIERARCHY.md`](../00-SHARED/config/01-CONFIGURATION_HIERARCHY.md).

---

## Submod `orehud`

**Source**: `server/mods/oretracker/orehud/init.lua`.

Marca con waypoints en la HUD los minerales que hay en un cubo de **8 bloques**
alrededor del jugador. Se actualiza cada **3 segundos** via `core.find_nodes_in_area`
+ `core.get_node_or_nil` (server-side), y los dibuja con `player:hud_add` usando
`hud_elem_type = "waypoint"`.

**Comando**: `/orehud` (toggle). Requiere priv `orehud`.

**Colores por mena** (detectados al arranque del server en este mundo):

```
[orehud] Found 23 ores configured.
coal, iron, gold, lapis, copper, redstone, diamond, emerald,
quartz, ancient_debris, glowstone, gilded_blackstone,
monster_egg, deepslate_* (todas las variantes)
```

**Comportamiento**:

- No toca nodos, no afecta a otros jugadores — solo agrega HUD waypoints.
- Drawtype waypoint nativo del cliente: triangulito de color en la direccion del
  bloque, no texto encima.
- Si un jugador esta en creativo o vuela, sigue mostrando solo los ores dentro
  del rango 3D (no cheat de vision lejana).
- Privilege `orehud` se entrega a singleplayer automaticamente (`give_to_singleplayer = true`).

**Parametros** (top de `init.lua`):

| Variable | Default | Significado |
|----------|---------|-------------|
| `orehud.detect_range` | `8` | Radio del cubo de escaneo en nodos. Mas alto = mucho mas caro. |
| `orehud.scan_frequency` | `3` | Segundos entre rescaneos. 0 = cada tick (no recomendado). |

---

## Submod `xray`

**Source**: `server/mods/oretracker/xray/init.lua` + `api.lua` + `register.lua`.

Vuelve invisibles (nodo `glasslike` con `light_source = 4`) los siguientes
nodos en un cubo de **6 bloques** alrededor del jugador, refrescado cada
**0.1 segundos**:

```
["mcl_core:stone", "mcl_core:granite", "mcl_core:andesite", "mcl_core:diorite",
 "mcl_core:sandstone", "mcl_core:redsandstone", "mcl_blackstone:blackstone",
 "mcl_blackstone:basalt", "mcl_nether:netherrack", "mcl_deepslate:deepslate",
 "mcl_colorblocks:hardened_clay", "mcl_colorblocks:hardened_clay_orange"]
```

**Comando**: `/xray` (toggle). Requiere priv `xray`.

**Como funciona por dentro** (por que importa saberlo):

1. `register.lua` corre al `on_mods_loaded`: por cada nodo "xrayable", registra
   un nodo gemelo `xray:<origen>` con `drawtype = "glasslike"`,
   `sunlight_propagates = true`, `light_source = 4`, `not_in_creative_inventory = 1`.
2. `api.lua` mantiene un `node_reference_counts` por coordenada. Cuando un jugador
   enciende xray, hace `inc_node_reference_counts_in_sphere(pos, 6, +1)` que
   `core.swap_node()`-ea cada nodo en rango al equivalente `xray:`. Cuando sale
   o se mueve, decrementa la cuenta y restaura.
3. Si N jugadores tienen xray en la misma zona, el contador es N. Solo cuando
   llega a 0 el nodo vuelve a su forma original. Esto evita que un jugador
   "cancele" los xray de otro.
4. Hay un `register_lbm` (`xray/init.lua:169-181`) que corre al cargar cada
   mapblock y restaura cualquier nodo `xray:` que haya quedado pegado (e.g. si
   el server crashea con xray prendido).

**Implicacion critica**: porque es server-side, **NO es x-ray personal**. Cuando
un jugador A activa xray, los jugadores B, C, D que esten cerca de A ven la
piedra invisible tambien, aunque no tengan el privilege. Esto es por diseno del
modpack — el server no tiene una API para "ocultar nodo solo a este cliente".

**Pitfalls conocidos** (del `README.md` original de ApolloX, autor del modpack):

- "If the server crashes while a player is using xray, xray's nodes are kept."
  Mitigado parcialmente por el LBM, pero nodos xray pueden aparecer pegados
  hasta que vuelvas a caminar cerca y el contador los libere.
- El bug "log off con xray prendido" — `xray.init.lua:48` registra
  `on_leaveplayer` que llama `xray.remove_players()` que SI restaura los nodos
  antes de salir. Pero si el server crashea, no.
- "fix_mode" (`fix_mode` en `xray/init.lua`) existe para limpieza manual pero
  el propio autor dice "no la dejes en produccion, sobrescribe los xray de
  otros jugadores". No la usamos.

**Parametros** (top de `init.lua`):

| Variable | Default | Significado |
|----------|---------|-------------|
| `xray.detect_range` | `6` | Radio del cubo de swap. Subir es caro para server. |
| `xray.scan_frequency` | `0.1` | Segundos entre rescaneos. 0.1 se siente fluido pero genera mucha load. |
| `xray.light_level` | `4` | `light_source` del nodo xray (0-14). 4 = luz media que permite ver la cueva. |

---

## Otorgar acceso a un jugador

Ambos son opt-in. Los nuevos jugadores en GAELSIN solo reciben
`interact, shout` (definido en `server/mods/wetlands_gaelsin_newplayer/init.lua`,
no usamos `wetlands_newplayer`). El admin otorga las ayudas:

```text
/grant <jugador> orehud
/grant <jugador> xray
```

Y se retiran con:

```text
/revoke <jugador> orehud
/revoke <jugador> xray
```

Para que un jugador vea ambas cosas en uso tiene que hacer toggle manual con
`/orehud` y `/xray` (los grants no activan las ayudas, solo dan el permiso).

---

## Verificacion post-deploy

Tras un `docker compose restart luanti-gaelsin`:

```bash
docker logs --since='1m' luanti-gaelsin-server 2>&1 | grep -iE 'orehud|xray|oretracker'
```

Lo que tenes que ver:

```
[Main]: [oretracker-orehud] Detected game MCL5.
[Main]: [oretracker-xray] Found 12 nodes configured.
[Server]: [oretracker-orehud] Found 23 ores configured.
```

Si no aparece "Found 12 nodes configured" del xray, quiere decir que
`load_mod_xray = true` no llego al `world.mt` del VPS (recordatorio: el `.conf`
solo es fallback, `world.mt` gana — ver jerarquia).

---

## Tuning / cambios

### Cambiar rangos o velocidades

Editar directamente `server/mods/oretracker/orehud/init.lua` o
`server/mods/oretracker/xray/init.lua` (los `detect_range` y `scan_frequency`
estan arriba del archivo). Si tocamos los `.lua`, hay que bumpear el cache de
modstore — reiniciar el container borra la cache y relee.

Pre-flight de permisos antes del pull (los dirs `server/mods/oretracker/*`
pueden estar owned por el container UID 1000 si el server los creo):

```bash
ssh <VPS_USER>@<VPS_IP> \
  "sudo chown -R <VPS_USER>:<VPS_USER> <PROJECT_PATH>/server/mods/oretracker"
```

### Cambiar la lista de nodos xrayable

Editar `server/mods/oretracker/xray/register.lua` (secciones por modo de juego)
o el bloque que escanea biomas (`xray/init.lua:130-142`). VoxeLibre se detecta
como "MCL5" porque registra `mcl_deepslate:deepslate` — eso prende los nodos
MCL2/5 comunes MAS los MCL5-only (blackstone, basalt, netherrack, deepslate).

### Cambiar la lista de ores del HUD

`server/mods/oretracker/orehud/init.lua` linea 161-200 (`extra_ores`) y la
tabla de colores en `orehud/api.lua:24-69` (`default_ore_colors`).

---

## Cosas por revisar (v2 pendiente)

Tras probar in-game el 2026-07-26, xray funciona como esperado. Pendientes de
diseno:

- [ ] **Latencia con scan cada 0.1s** — si varios jugadores prenden xray a la
  vez en la misma zona, el contador de refs escala, pero el scan per-jugador
  no. Aun asi, 10 fps de scan pueden causar microstutter. Pendiente medir.
- [ ] **Afectacion a jugadores sin xray** — por diseno del modpack. Mitigacion
  posible: wrapper server-side que use `core.add_player_velocity` para hacer
  "invisible" el swap solo a clientes sin priv `xray`. Esto requiere un fork
  del modpack o un overlay mod. No trivial.
- [ ] **Tecla X como toggle** — Minecraft-style. Requiere polling
  server-side de `player:get_control().aux1` (que por default es la tecla X en
  el cliente Luanti). Mas detalles en sesion de chat del 2026-07-26.
- [ ] **`xray.light_level = 4`** — ver si la luz emitida por los nodos xray
  ciega o esta bien. Si molesta, bajar a 2 o 3.
- [ ] **Limpiar el comentario "TESTING"** en `luanti-gaelsin.conf` una vez
  decidamos que xray se queda definitivamente.

---

## Historial

- **2026-07-26**: Activacion inicial de `orehud` + `xray` en GAELSIN. Commit
  `9aab096`. Probado in-game, funciona. Este doc creado.
