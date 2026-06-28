# Proyecto GAELSIN — Mundo de supervivencia VoxeLibre

Tercer mundo del servidor (puerto **30002**). Reemplaza al antiguo mundo **Infierno**
(que era una copia destructible de Wetlands con CTF guns). GAELSIN es un **mundo nuevo
generado desde cero** con la semilla `GAELSIN` y mapgen `v7`, en **modo supervivencia
VoxeLibre convencional**. No clona ningún mundo: VoxeLibre genera el mapa al primer
arranque a partir del seed.

Dirección pública: `luanti.gabrielpantoja.cl:30002`.

## Resumen

| Item | Valor |
|------|-------|
| Puerto | 30002/UDP |
| Container | `luanti-gaelsin-server` |
| Config | `server/config/luanti-gaelsin.conf` |
| Mundo | `server/worlds/gaelsin/` (gitignored, vive en el VPS) |
| Modo | Supervivencia pura (`creative_mode = false`) |
| Seed | `GAELSIN` (texto → hash determinista) |
| Mapgen | `v7` (`mg_flags = caves,light,decorations,biomes`) |
| PvP | Activo (`enable_pvp = true`) — sin arena, todo el mundo |
| Daño / mobs | Daño on; mobs hostiles de noche (`only_peaceful_mobs = false`) |
| Creepers | **Bloqueados** (mod `wetlands_no_creeper`) |
| Protección de áreas | **Sin** (`voxelibre_protection` off) |
| Fuego / TNT | Activos (supervivencia estándar) |
| Discord label | `GAELSIN ⚔️` |

## Nota sobre el seed

El seed `GAELSIN` es texto. Luanti convierte un `fixed_map_seed` no numérico a un
número determinista por hash, de modo que `fixed_map_seed = GAELSIN` + `mg_name = v7`
reproduce siempre el mismo mundo. El seed efectivo lo fija `luanti-gaelsin.conf` en el
primer arranque (un mundo fresco no tiene `map_meta.txt` previo que lo sobrescriba).

## Mods habilitados (set mínimo)

Solo núcleo + WorldEdit admin. La lista autoritativa es `luanti-gaelsin.conf` y debe
coincidir con el `world.mt` que escribe `scripts/setup-gaelsin-world.sh`:

- `wetlands_gaelsin_newplayer` — otorga **solo `interact, shout`** a nuevos jugadores
  (apropiado para supervivencia; no usa el `wetlands_newplayer` de Wetlands que da
  fly/creative).
- `wetlands_no_creeper` — bloquea creepers.
- `server_rules`, `wetlands_lastpos`, `mcl_potions_hotfix`.
- `_world_folder_media`, `mcl_custom_world_skins` — skins.
- `worldedit` (+ `_commands` / `_shortcommands`) — herramientas de admin.

Todo lo demás (NPCs, música, vehículos, CTF guns, protección, arena PvP, decoración,
Halloween) está explícitamente en `= false` como kill-switch en la config.

## Privilegios de nuevos jugadores

VoxeLibre ignora `default_privs`. Los privilegios los otorga el mod
`server/mods/wetlands_gaelsin_newplayer/init.lua` vía `minetest.register_on_newplayer`.
La tabla `PRIVS` da únicamente `interact` y `shout`. Editar esa tabla para cambiar el
set por defecto.

## Operaciones

Ambos scripts se ejecutan **en el VPS, como `gabriel` con `sudo`**.

### Crear el mundo (primera vez)

```bash
cd /home/gabriel/luanti-voxelibre-server
sudo ./scripts/setup-gaelsin-world.sh
docker compose up -d luanti-gaelsin discord-notifier-gaelsin
```

`setup-gaelsin-world.sh` crea `server/worlds/gaelsin/` con un `world.mt` fresco y hace
`chown 1000:1000`. El mapa se genera desde el seed al arrancar. Aborta si el directorio
ya existe.

### Reset (regenerar desde cero)

```bash
sudo ./scripts/reset-gaelsin.sh
```

Detiene los containers, mueve el mundo actual a `gaelsin_DESTROYED_<timestamp>` como
backup, recrea el `world.mt` fresco y reinicia. El mapa se regenera desde el seed.

### Firewall

El puerto **30002/UDP** ya estaba abierto del antiguo Infierno (Oracle Cloud security
list + iptables host). Si no lo estuviera:

```bash
sudo iptables -I INPUT -p udp --dport 30002 -j ACCEPT
sudo netfilter-persistent save
```

## Verificación post-deploy

```bash
docker logs --since=2m luanti-gaelsin-server 2>&1 | grep -iE 'error|listening|seed'
```

En el juego (`luanti.gabrielpantoja.cl:30002`):
- Mundo nuevo (no es el viejo Infierno).
- Supervivencia: sin vuelo, sin inventario creativo.
- Jugador nuevo: solo `interact, shout` (`/privs`).
- PvP activo; creepers ausentes; mobs hostiles de noche.
- Notificación Discord con label `GAELSIN ⚔️`.

## Coordenadas importantes

| Lugar | Coordenadas |
|-------|-------------|
| Casa del admin (spawn) | `313, 23, 86` |

> Para arquitectura, pitfalls de VoxeLibre, texturas y comandos, la fuente única de
> verdad es **[`AGENTS.md`](../../AGENTS.md)** en la raíz del repo.
