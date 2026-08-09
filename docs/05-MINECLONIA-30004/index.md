# Mineclonia 🌮 — Puerto 30004

Quinto mundo del servidor Wetlands. Mundo **creativo puro** corriendo
[Mineclonia 0.123.0](https://codeberg.org/mineclonia/mineclonia),
fork de VoxeLibre enfocado en clonar fielmente Minecraft vanilla.

## Resumen rapido

| Campo | Valor |
|---|---|
| Nombre mostrado | Mineclonia 🎮 |
| Puerto (host) | **30004/UDP** |
| Puerto (container) | 30000 interno (mapeo 30004→30000 en docker-compose) |
| Container | `luanti-mineclonia-server` |
| Game base | Mineclonia 0.123.0 (NO VoxeLibre) |
| Modo | Creativo, sin dano, sin PvP |
| Mods custom | **Ninguno** — solo el game base |
| Seed | `mineclonia` |
| Spawn | `-14,4.5,240` |
| Max jugadores | 15 |
| Discord notifier | `luanti-discord-notifier-mineclonia` |

## Que es Mineclonia

Mineclonia es un game de Luanti que fork'eo de VoxeLibre/MineClone2 y
se enfoca en **clonar Minecraft vanilla** con la mayor fidelidad
posible. Diferencias con VoxeLibre:

- Nether portals mejorados
- Leaf decay mejorado
- Villages mejoradas
- Wandering traders + trader llamas
- Suspicious nodes, pottery sherds, decorated pots
- Conduits
- Deep dark biome + ancient hermitage
- Loom funcional
- Lush caves + cherry grove biomes
- Pathfinding/physics/AI de mobs reescritos
- **Mapgen propio (Lua)** compatible con seeds de Minecraft
- Sin hamburgers (villagers siguen comida tirada)
- Sin mobs renombrados (Creepers siguen siendo Creepers)
- ~2x mas pequeno en musica que VoxeLibre

> **Proyecto separado**: Mineclonia, VoxeLibre y MineClone2 NO son
> el mismo proyecto. MineClone2 = VoxeLibre (renombrado en 2022).
> Mineclonia es un fork aparte con su propio repositorio en Codeberg.

## Filosofia del mundo

Pedido explícito del usuario: *"la experiencia mas fiel al juego
original de minecraft"*. Por eso:

- **Cero mods custom** de Wetlands. Ni `wetlands_newplayer`, ni
  WorldEdit, ni NPCs, ni nada. El game base Mineclonia provee todo.
- **Modo creativo puro** — todos pueden volar, tomar cualquier item
  del inventario creativo y construir sin restricciones.
- **Sin dano** — no hay mobs hostiles, no hay PvP, no hay hunger.
- **Cero contenido de Wetlands** — este mundo no comparte mods ni
  assets con los otros mundos. Es una "isla" dentro del servidor.

## Instalacion del game base

Mineclonia NO viene con el image `linuxserver/luanti` — hay que
descargarlo en el VPS antes de arrancar el container. Ver
[`install.md`](./install.md) para el paso a paso.

## Configuracion

Ver `server/config/luanti-mineclonia.conf`. Puntos clave:

- `default_game = mineclonia` — game separado de VoxeLibre
- `creative_mode = true` + `enable_damage = false` — creativo puro
- `fixed_map_seed = mineclonia` — seed Minecraft-compatible
- **Sin `mg_name`** — Mineclonia usa su propio mapgen Lua; forzarlo
  a `v7` usaria el mapgen de Minetest (no el de Minecraft)
- `default_privs = interact,shout,teleport` — funciona directo
  porque Mineclonia **no es VoxeLibre**, no tiene el trap
  `default_privs` que VoxeLibre pisa con su propio sistema
- `enable_client_modding = true` (default de Mineclonia) — NO
  endurecido como Wetlands. Es la experiencia vanilla Minecraft.

## docker-compose

El servicio `luanti-mineclonia` sigue el patron de GAELSIN/CTF:
container escucha en 30000 internamente, host expone 30004. No
requiere el container-overrides de Valdivia (ese bug solo aplica
a mundos con `--port <otro>` en CLI_ARGS).

```yaml
luanti-mineclonia:
  image: linuxserver/luanti:latest
  container_name: luanti-mineclonia-server
  ports:
    - "30004:30000/udp"
  volumes:
    - ./server/config/luanti-mineclonia.conf:/config/.minetest/main-config/minetest.conf
    - ./server/mods:/config/.minetest/mods
    - ./server/worlds/mineclonia:/config/.minetest/worlds/mineclonia
    - ./server/games:/config/.minetest/games
  environment:
    - PUID=1000
    - PGID=1000
    - TZ=America/Santiago
    - CLI_ARGS=--worldname mineclonia
```

## Diferencias con otros mundos

| Aspecto | Wetlands | GAELSIN | CTF | Mineclonia |
|---|---|---|---|---|
| Game | VoxeLibre | VoxeLibre | capturetheflag | **Mineclonia** |
| Modo | Supervivencia | Supervivencia | PvP/CTF | **Creativo** |
| Mods custom | Muchos | Minimos | Cero | **Cero** |
| PvP | No | Si | Si (arma) | **No** |
| Dano | Si | Si | Si | **No** |
| Seed | Numerico | `GAELSIN` | Auto | **`mineclonia`** |
| Puerto | 30000 | 30002 | 30003 | **30004** |

## Como unirse

1. Abrir Luanti 5.10+ (cliente)
2. Pestaña "Unirse al juego"
3. Direccion: `luanti.gabrielpantoja.cl`
4. Puerto: `30004`
5. Nombre + password (cuenta nueva)
6. El inventario creativo aparece al lado de la busqueda — tomar
   cualquier item y construir

## Roadmap

v0 (actual): creativo puro, sin mods, seed `mineclonia`.

Cosas que se podrian agregar en el futuro (no estan):

- WorldEdit (mod popular para construir rapido en creativo)
- Mas seeds via `/gamemode` o nuevo mundo en otro puerto
- Coordenadas de "showcase" con builds destacados de la comunidad
- Multi-creativo con varios worlds (tipo `mineclonia2`, etc.)

## Ver tambien

- [`install.md`](./install.md) — Como instalar Mineclonia en el VPS
- `docs/00-SHARED/config/01-CONFIGURATION_HIERARCHY.md` — jerarquia
  de configuracion (world.mt vs luanti-mineclonia.conf)
- `AGENTS.md` → seccion "Multi-world architecture"
