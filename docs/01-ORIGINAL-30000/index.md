# Proyecto WETLANDS — Mundo principal creativo y educativo

Primer y principal mundo del servidor: un entorno **creativo, educativo y kid-friendly** (apto para
niños 7+). Es el mundo "canónico" del servidor. Mods propios promueven el cuidado de animales y la
exploración no violenta; el PvP solo existe
en una arena opt-in. Dirección pública: `luanti.gabrielpantoja.cl:30000`.

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

- `creative_mode = true` — modo creativo nativo de VoxeLibre.
- `enable_damage = true` — el daño está activo globalmente. Es **intencional**: los mobs hostiles
  pueden dañar de noche y la arena PvP lo necesita. El PvP fuera de la arena lo impide la lógica del
  mod `pvp_arena`, no este flag.
- `only_peaceful_mobs = false` — los mobs hostiles aparecen de noche. Los Creepers se bloquean por
  separado con el mod `wetlands_no_creeper`. Resumen para jugadores: **"de día seguro, de noche
  peligroso excepto Creepers"**.
- `static_spawnpoint = 0,15,0`
- `max_users = 20`

## Privilegios de nuevos jugadores

VoxeLibre **ignora** `default_privs` en `minetest.conf`. Los privilegios iniciales los otorga el mod
`wetlands_newplayer` (`server/mods/wetlands_newplayer/init.lua`) — la tabla `PRIVS` ahí es la fuente
de verdad. No agregar `default_privs` en ningún lado.

## Mods (lista autoritativa: `server/config/luanti-original.conf`)

### Propios de Wetlands
`wetlands_npcs` (NPCs interactivos Star Wars + clásicos con IA/voces/diálogos), `wetlands_newplayer`,
`wetlands_music`, `wetlands_christmas`, `wetlands_no_creeper`, `wetlands_lastpos`, `mcl_back_to_spawn`,
`server_rules` (`/reglas`), `pvp_arena` (único lugar con PvP), `mcl_custom_world_skins`,
`voxelibre_protection`, `voxelibre_tv`.

### Terceros
`worldedit` (+commands/+shortcuts), `chess`, `celevator`, `automobiles_*` (vespa, beetle, motorcycle,
buggy…), `3dforniture`, `mcl_decor`, `broom_racing`, `auto_road_builder`, `halloween_ghost` /
`halloween_zombies` (estacionales).

## Operación

- **Jerarquía de config** (CRÍTICO): un mod carga solo si `world.mt` (en el VPS) lo habilita; y
  `luanti-original.conf = false` lo apaga incondicionalmente (kill-switch). Detalle en
  `docs/config/01-CONFIGURATION_HIERARCHY.md` y en `AGENTS.md`.
- **Deploy**: flujo estándar `git push → ssh git pull → docker compose restart luanti-server →
  revisar logs con --since`. Ver `AGENTS.md` (sección "VPS deployment").
- **Backups**: el sidecar `backup-cron` hace tarball cada 12 h en `server/backups/`. Diagnóstico en
  `docs/operations/BACKUP_STATUS.md`.
- **Config nuclear**: overrides fuera de banda con `./scripts/apply-nuclear-config.sh`
  (`docs/config/02-NUCLEAR_CONFIG.md`).

## Relación con los otros mundos

Los cuatro mundos comparten `server/games/` y `server/mods/`, pero cada uno tiene su `.conf`, su
carpeta de mundo y su servicio en `docker-compose.yml`:

| Mundo | Puerto | Doc |
|-------|--------|-----|
| **Wetlands (este)** | 30000 | este documento |
| Valdivia | 30001 | `mundo-2-puerto-30001-valdivia.md` |
| GAELSIN | 30002 | `mundo-3-puerto-30002-gaelsin.md` |
| CTF | 30003 | `mundo-4-puerto-30003-ctf.md` |

> Para todos los detalles de arquitectura, pitfalls de VoxeLibre, texturas y comandos, la fuente
> única de verdad es **[`AGENTS.md`](../../AGENTS.md)** en la raíz del repo.
