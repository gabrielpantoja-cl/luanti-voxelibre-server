# Proyecto WETLANDS — Mundo principal de supervivencia compassivo

Primer y principal mundo del servidor: un entorno **supervivencia dura, educativa y kid-friendly** (apto
para niños 7+) con filosofía compassiva y plant-based. Es el mundo "canónico" del servidor. Mods
propios promueven el cuidado de animales y la exploración no violenta; **no hay PvP** (deshabilitado
a nivel engine + arena opt-in retirada el 2026-07-31). Dirección pública: `luanti.gabrielpantoja.cl:30000`.

## Resumen

| Item | Valor |
|---|---|
| Puerto público | **30000/UDP** |
| Container | `luanti-voxelibre-server` |
| Config | `server/config/luanti-original.conf` |
| Mundo | `server/worlds/original/` (gitignored, la copia real vive en el VPS) |
| Juego base | VoxeLibre (MineClone2) v0.90.1 |
| Mapgen | `v7` (mundo persistente, ya generado) |
| Notifier Discord | `discord-notifier` (label `Wetlands 🌱`) |

## Características del mundo

- `creative_mode = false`, `mcl_enable_creative_mode = false`, `mcl_creative_is_survival_like = true`,
  `give_initial_stuff = false`, `keepInventory = false` — **supervivencia dura desde 2026-07-31**.
- `enable_damage = true` — el daño está activo globalmente. Es **intencional**: los mobs hostiles
  pueden dañar de noche. **PvP deshabilitado** (`enable_pvp = false`) en todo el mundo desde
  el 2026-07-31 — la arena opt-in se retiró al pasar a supervivencia dura.
- `enable_fire = true`, `enable_tnt = true` — fuego y TNT habilitados como en supervivencia estándar.
- `only_peaceful_mobs = false` — los mobs hostiles aparecen de noche. Los Creepers se bloquean por
  separado con el mod `wetlands_no_creeper`. Resumen para jugadores: **"de día seguro, de noche
  peligroso excepto Creepers"**.
- `static_spawnpoint = 655.1,18.5,243.9` — spawn actual.
- Spawn historico original: `0,15,0` (usado antes del cambio de julio de 2026).
- `max_users = 20`.

## Privilegios

VoxeLibre **ignora** `default_privs` en `minetest.conf`. Los privilegios los otorga el mod
`wetlands_newplayer` (`server/mods/wetlands_newplayer/init.lua`):

- **Jugadores nuevos / no-admin**: solo `interact`, `shout`, `teleport`.
- **`gabo` (admin whitelist)**: además `fly`, `fast`, `noclip`, `give`, `creative`, `worldedit`,
  `debug`. Mantiene inventario creativo y herramientas de admin en un servidor survival.

El mod reconcilia los privilegios en cada `join` para retirar creative/fly/noclip a jugadores
existentes que los tuvieran del periodo creativo.

## Mods (lista autoritativa: `server/config/luanti-original.conf`)

Supervivencia dura desactivó mods no aplicables: NPCs, música, navidad, vehículos (`automobiles_*`),
muebles (`3dforniture`), decoración (`mcl_decor`), `mypark`, `chess`, `celevator`,
`auto_road_builder`, `halloween_*`, `broom_racing`, `protector`, `voxelibre_protection`,
`vegan_food`, `vegan_replacements`, `education_blocks`, `pvp_arena`. Mantiene núcleo de supervivencia.

### Propios de Wetlands (activos)
`wetlands_newplayer`, `wetlands_no_creeper`, `wetlands_lastpos`, `server_rules`,
`mcl_custom_world_skins`.

### Terceros (activos)
`worldedit` (+commands/+shortcuts), `_world_folder_media`.

## Operación

- **Jerarquía de config** (CRÍTICA): un mod carga solo si `world.mt` (en el VPS) lo habilita; y
  `luanti-original.conf = false` lo apaga incondicionalmente (kill-switch). Detalle en
  `docs/config/01-CONFIGURATION_HIERARCHY.md` y en `AGENTS.md`.
- **Deploy**: flujo estándar `git push → ssh git pull → docker compose restart luanti-server →
  revisar logs con --since`. Ver `AGENTS.md` (sección "VPS deployment").
- **Backups**: el sidecar `backup-cron` hace tarball cada 12 h en `server/backups/`. Diagnóstico en
  `docs/operations/BACKUP_STATUS.md`.
- **Config nuclear**: overrides fuera de banda con `./scripts/apply-nuclear-config.sh`
  (`docs/config/02-NUCLEAR_CONFIG.md`).

## Relación con los otros mundos

Los cinco mundos comparten `server/games/` y `server/mods/`, pero cada uno tiene su `.conf`, su
carpeta de mundo y su servicio en `docker-compose.yml`:

| Mundo | Puerto | Doc |
|-------|--------|-----|
| **Wetlands (este)** | 30000 | este documento |
| Valdivia | 30001 | `mundo-2-puerto-30001-valdivia.md` |
| GAELSIN | 30002 | `mundo-3-puerto-30002-gaelsin.md` |
| CTF | 30003 | `mundo-4-puerto-30003-ctf.md` |
| Mineclonia | 30004 | `../../05-MINECLONIA-30004/index.md` |

> Para todos los detalles de arquitectura, pitfalls de VoxeLibre, texturas y comandos, la fuente
> única de verdad es **[`AGENTS.md`](../../AGENTS.md)** en la raíz del repo.
