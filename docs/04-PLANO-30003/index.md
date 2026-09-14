# Proyecto Plano — Mundo Mineclonia totalmente plano

Cuarto mundo del servidor Wetlands: un mundo **perfectamente plano** sobre el juego
**Mineclonia** (fork de VoxeLibre fiel a Minecraft — **no** es VoxeLibre). Pensado como
lienzo de construcción: superficie infinita de pasto, sin terreno irregular que estorbe.

> **Historial**: hasta el 2026-09-13 el puerto 30003 servía el juego
> [`capturetheflag`](https://github.com/MT-CTF/capturetheflag) de rubenwardy. Se retiró a
> pedido del admin y se reemplazó por este mundo. Los mods `server/mods/wetlands_ctf/` y
> `server/mods/wetlands_flatworld/` siguen siendo vestigiales y **no se cargan**.

## Resumen

| Item | Valor |
|---|---|
| Puerto público | **30003/UDP** |
| Container | `luanti-plano-server` |
| Config | `server/config/luanti-plano.conf` |
| Juego | `server/games/mineclonia/` (compartido con el mundo 30004) |
| Mundo | `server/worlds/plano/` (gitignored, se crea en el VPS) |
| Mapgen | `flat` + bioma único `Plains`, ersatz off, backend `sqlite3` (persistente) |
| Spawn | `0,10,0` (suelo en y=8) |
| Notifier Discord | `discord-notifier-plano` (label `Plano 🟩`) |

## Cómo se logra el mundo plano

**Ninguna semilla genera un mundo plano.** Es cuestión de *mapgen*, no de `fixed_map_seed`.
Usamos el mapgen `flat` del motor Luanti y forzamos un único bioma de pasto.

### Stack de bloques (medido, no teórico)

Generado localmente con esta config el 2026-09-13 y leído nodo por nodo:

| Rango Y | Nodo | De dónde sale |
|---|---|---|
| `8` | `mcl_core:dirt_with_grass` | `node_top` / `depth_top = 1` del bioma `Plains` |
| `7 .. 6` | `mcl_core:dirt` | `node_filler` / `depth_filler = 2` (uniforme: 169/169 columnas) |
| `5 .. -62` | `mcl_core:stone` | `node_stone` por defecto, **sin vetas de mineral** |
| `-63 .. -123` | `mcl_deepslate:deepslate` | bioma `Plains_deep_underground` |
| `-124 .. -128` | `mcl_core:bedrock` | `mcl_mapgen_core` (`mg_bedrock_overworld_min = -128`) |
| `<= -129` | `mcl_core:void` | límite del overworld |

**Planitud verificada** en `(0,0)`, `(±500,±500)`, `(2000,0)`, `(0,2000)` y `(-3000,3000)`:
81/81 columnas por punto con el suelo exactamente en `y = 8`, solo `dirt_with_grass`, sin una
sola planta ni accidente de terreno.

### Los ajustes clave (`server/config/luanti-plano.conf`)

```conf
mg_name = flat
mgflat_ground_level = 8
mgflat_spflags = nolakes,nohills
mg_flags = nocaves,nodungeons,nodecorations,noores,biomes,light
mcl_levelgen_enable_ersatz = false
water_level = -1

mg_biome_np_heat           = 58, 0, (1000, 1000, 1000), 5349, 3, 0.5, 2.0
mg_biome_np_humidity       = 39, 0, (1000, 1000, 1000), 842, 3, 0.5, 2.0
mg_biome_np_heat_blend     = 0, 0, (8, 8, 8), 13, 2, 1.0, 2.0
mg_biome_np_humidity_blend = 0, 0, (8, 8, 8), 90003, 2, 1.0, 2.0
```

- **`mg_flags` se aplica *sobre* los defaults** (`caves,dungeons,light,decorations,biomes,ores`):
  lo que no se nombra **conserva su valor por defecto (encendido)**. Comprobado leyendo el
  `map_meta.txt` generado: listar solo `nocaves,nodungeons,nodecorations` dejaba `ores`
  activo. Por eso hay que apagar explícitamente con el prefijo `no`. `noores` responde al
  "hacia abajo solo roca"; para tener minerales, cambiar a `ores` **antes** de crear el mundo.
  `biomes` y `light` se listan en positivo por claridad: sin `light` el mundo quedaría a
  oscuras y sin `biomes` no habría capa de pasto ni de tierra.
- **`mcl_levelgen_enable_ersatz = false` es imprescindible.** Mineclonia trae un generador
  Lua propio ("ersatz") que se activa por defecto en **cualquier mapgen que no sea
  singlenode** (`mods/MAPGEN/mcl_levelgen/register.lua:180`) y siembra vegetación y
  estructuras estilo Minecraft vía `core.register_on_generated`, es decir **ignorando el flag
  `nodecorations` del motor**. Con ersatz activo el mundo salía plano pero cubierto de pasto
  alto, amapolas y tulipanes. Apagarlo deja el lienzo limpio.
- **El truco del bioma único**: con `scale = 0` el ruido de calor/humedad es *constante* en
  todo el mundo, así que siempre gana el bioma más cercano al punto `(heat 58, humidity 39)`
  = `Plains` (definido en `server/games/mineclonia/mods/MAPGEN/mcl_biomes/init.lua`). Sin
  esto saldrían parches de desierto, nieve, mycelium, etc. Los ruidos `_blend` también van
  en `0` porque suman ±1.5 y podrían saltar a un bioma vecino.
- **Por qué no `mcl_superflat_classic = true`**: esa es la superflat clásica de Minecraft que
  trae Mineclonia (`mg_name = flat` + ese flag). Da solo 4 capas — pasto, tierra, tierra,
  bedrock — porque el bioma `flat` usa `node_stone = dirt` y no hay roca debajo. Como el
  requisito era "roca hacia abajo", se descartó.

### ⚠️ Los `mg_*` se congelan en `map_meta.txt`

Luanti guarda los parámetros de mapgen en `server/worlds/plano/map_meta.txt` **al crear el
mundo**. Cambiar `mg_name`, `mgflat_*` o los `mg_biome_np_*` en el `.conf` después **no tiene
ningún efecto**. Para cambiarlos:

1. `docker compose stop luanti-plano`
2. Renombrar el mundo (`mv server/worlds/plano server/worlds/plano.bak-$(date +%Y%m%d)`) y
   dejar que se regenere, **o** editar `map_meta.txt` a mano con `sudo` (dueño `1000:1000`).
3. `docker compose up -d luanti-plano`

Nunca editar `map_meta.txt` con el container corriendo.

## Diferencias con el mundo Mineclonia (30004)

| | Plano (30003) | Mineclonia (30004) |
|---|---|---|
| Mapgen | `flat` (motor Luanti) | `singlenode` → interceptado por `mcl_levelgen` |
| Terreno | plano infinito | terreno tipo Minecraft, seed `mineclonia` |
| Mods | `wetlands_mundos` | `wetlands_mundos` + `wetlands_mineclonia_trampas` |

Ambos comparten el mismo `server/games/mineclonia/`.

## Deploy (migración desde CTF)

### 1. Pull en el VPS

Seguir el flujo seguro de `AGENTS.md` (pre-chown de `server/mods` si el rango de commits lo
toca) y después:

```bash
ssh <VPS_USER>@<VPS_IP> "cd <PROJECT_PATH> && git pull origin main"
```

### 2. Bajar y borrar los containers CTF

El servicio pasó de `luanti-ctf` a `luanti-plano`: `docker compose up -d` **no** elimina el
container viejo, y este seguiría ocupando el puerto 30003.

```bash
ssh <VPS_USER>@<VPS_IP> "cd <PROJECT_PATH> && \
    docker stop luanti-ctf-server luanti-discord-notifier-ctf && \
    docker rm luanti-ctf-server luanti-discord-notifier-ctf"
```

### 3. Archivar el mundo CTF viejo (no borrar)

```bash
ssh <VPS_USER>@<VPS_IP> "cd <PROJECT_PATH> && \
    sudo mv server/worlds/ctf server/worlds/ctf_OLD-$(date +%Y%m%d)"
```

El mundo CTF usaba `backend = dummy`, así que no había mapa que perder — solo `auth.txt`.
El juego `server/games/capturetheflag/` puede archivarse igual (`sudo mv ... capturetheflag_OLD`)
cuando gabo confirme; no hace falta para el arranque.

### 4. Crear el mundo plano — **con `world.mt`, no solo el directorio**

⚠️ Un directorio vacío **no alcanza**. Comprobado: Luanti 5.17 loguea
`World 'plano' not available. Available worlds:` e ignora el bind mount, arrancando en su
mundo interno `/config/.minetest/worlds/world`, aunque `CLI_ARGS` traiga
`--worldname plano --gameid mineclonia`.

```bash
# 1. Crear el directorio del mundo
ssh <VPS_USER>@<VPS_IP> "sudo mkdir -p <PROJECT_PATH>/server/worlds/plano"

# 2. Escribir el world.mt (OBLIGATORIO antes del primer arranque)
ssh <VPS_USER>@<VPS_IP> "sudo tee <PROJECT_PATH>/server/worlds/plano/world.mt > /dev/null" <<'EOF'
gameid = mineclonia
backend = sqlite3
player_backend = sqlite3
auth_backend = sqlite3
world_name = plano
EOF

# 3. Dueno = UID del container (PUID=1000). Nunca chownear server/worlds al usuario SSH.
ssh <VPS_USER>@<VPS_IP> "sudo chown -R 1000:1000 <PROJECT_PATH>/server/worlds/plano"
```

El `map_meta.txt` sí se genera solo desde `luanti-plano.conf` en el primer arranque.

### 5. Levantar

```bash
ssh <VPS_USER>@<VPS_IP> "cd <PROJECT_PATH> && \
    docker compose up -d luanti-plano discord-notifier-plano"
```

### 6. Verificar

```bash
ssh <VPS_USER>@<VPS_IP> "docker logs --since=3m luanti-plano-server 2>&1 | \
    grep -iE 'error|warning|listening|world at|not available'"

# El mapgen quedó congelado correctamente?
ssh <VPS_USER>@<VPS_IP> "sudo cat <PROJECT_PATH>/server/worlds/plano/map_meta.txt | \
    grep -E 'mg_name|mgflat|np_heat|np_humidity|mg_flags'"
```

Entrar a `luanti.gabrielpantoja.cl:30003`: debería aparecer una llanura de pasto sin un solo
accidente de terreno. Cavar hasta y≈5 debe mostrar piedra.

El puerto 30003/UDP ya estaba abierto en Oracle Cloud + `ufw` desde CTF; no hay que tocar
firewall.

## Archivos del proyecto

| Archivo | Rol |
|---|---|
| `server/config/luanti-plano.conf` | Config del mundo (incluye el bloque de mapgen) |
| `docker-compose.yml` | Servicios `luanti-plano` + `discord-notifier-plano` |
| `server/games/mineclonia/` | Game base, compartido con el mundo 30004 |
| `server/worlds/plano/` | Mundo (gitignored, se crea en el VPS) |
| `server/worlds/plano/map_meta.txt` | Mapgen congelado — la fuente de verdad real |

## Troubleshooting

| Síntoma | Causa probable |
|---|---|
| Terreno con colinas/cuevas/árboles | El mundo se creó antes de que el `.conf` tuviera el bloque de mapgen → `map_meta.txt` viejo. Regenerar el mundo (paso 4). |
| Parches de arena/nieve/mycelium | Faltan los `mg_biome_np_*_blend` en `0`, o el mundo se creó sin ellos. |
| Todo piedra, sin pasto | `mg_flags` sin `biomes`. |
| Quiero minerales en la roca | Agregar `ores` a `mg_flags` y regenerar el mundo (paso 4). |
| Mundo a oscuras | `mg_flags` sin `light`. |
| Arranca con VoxeLibre o v7 en vez de Mineclonia | Falta `gameid = mineclonia` en `world.mt` / `--gameid` en `CLI_ARGS`. |
| Log `World 'plano' not available` y nada persiste | Falta el `world.mt` (paso 4): el server arrancó en su mundo interno `world`. |
| Pasto alto y flores sobre la superficie | `mcl_levelgen_enable_ersatz` no quedó en `false` al crear el mundo. |
| Puerto 30003 ocupado / sigue CTF | El container `luanti-ctf-server` viejo sigue vivo (paso 2). |
