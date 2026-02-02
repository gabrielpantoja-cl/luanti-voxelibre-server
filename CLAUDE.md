# CLAUDE.md

Guidance for Claude Code working with this repository.

## Project Overview

Wetlands is a **Luanti (formerly Minetest) game server** — a compassionate, educational, creative environment for children 7+. Custom mods promote animal care, compassion, and non-violent gameplay. Server address: `luanti.gabrielpantoja.cl:30000`.

## Repository Scope

This repo (`luanti-voxelibre-server.git`) owns **all** Luanti code, config, mods, landing page, and deployment. It is independent from the VPS admin repo (`vps-do.git`). **Never** modify Luanti files in `vps-do.git`.

## Key Technologies

- **Runtime**: Docker Compose with `linuxserver/luanti:latest`
- **Base Game**: VoxeLibre (MineClone2) v0.90.1
- **Mods**: Lua scripts in `server/mods/`
- **Config**: `.conf` files, not JSON/YAML
- **Deploy**: GitHub Actions CI/CD to VPS (`ssh gabriel@167.172.251.27`)
- **Port**: 30000/UDP (game), 80/443 (landing page via nginx)
- **Language**: Spanish (es)

## File Structure

```
docker-compose.yml              # Container orchestration
server/config/luanti.conf       # Server config (creative, no damage, no PvP)
server/games/mineclone2/        # VoxeLibre game files
server/mods/                    # Custom mods (animal_sanctuary, vegan_food, education_blocks, etc.)
server/worlds/                  # Persistent world data + auth.sqlite
server/skins/                   # Player skins (64x32 PNG)
server/landing-page/            # Web landing page (HTML/CSS/JS)
server/backups/                 # Automated backup storage
scripts/                        # start.sh, backup.sh, deploy-landing.sh, etc.
docs/                           # Detailed documentation (see index below)
```

## Essential Commands

```bash
./scripts/start.sh                          # Start server (or: docker-compose up -d)
docker-compose logs -f luanti-server        # View logs
docker-compose restart luanti-server        # Restart
docker-compose down                         # Stop
docker-compose ps                           # Status
./scripts/backup.sh                         # Manual backup
./scripts/deploy-landing.sh                 # Deploy landing page
./scripts/sync-from-vps.sh --dry-run        # Check VPS config drift
```

## Development Workflow

### Adding New Mods
1. Create directory in `server/mods/<mod_name>/`
2. Add `mod.conf` (use `optional_depends`, not `depends` for VoxeLibre mods)
3. Write `init.lua`
4. Add `load_mod_<name> = true` to `server/config/luanti.conf`
5. Test locally with `./scripts/start.sh`
6. Commit and push to trigger deployment

### Modifying Config
- Edit `server/config/luanti.conf` in **this repo only**
- Key settings: `creative_mode`, `enable_damage`, `max_users`
- Restart server after changes

### Manual Commits Preferred
To conserve Claude Code quota, **Claude should not run git commands**. Instead:
1. Claude makes code changes and provides a ready-to-copy commit message
2. User reviews, stages, commits, and pushes in VS Code
3. GitHub Actions deploys automatically

Exception: emergency fixes where Claude can commit directly.

## Key Constraints

- **No package.json** — not a Node.js project
- **No build system** — Docker Compose + Lua only
- **No unit tests** — testing via manual gameplay
- **Lua scripting** — all mod logic in Lua
- **SQLite auth** — privileges in `server/worlds/world/auth.sqlite`, not text files

## VoxeLibre Critical Pitfalls

### `default_privs` Does NOT Work
VoxeLibre **ignores** the `default_privs` setting in `minetest.conf`. New players only get `creative, interact, shout` regardless of config. The `wetlands_newplayer` mod fixes this by granting privileges via `minetest.register_on_newplayer()`. Edit `server/mods/wetlands_newplayer/init.lua` to change privileges. **Always use the mod, never rely on `default_privs`.**

### Item Name Mapping (Minetest vanilla vs VoxeLibre)
Mods must use VoxeLibre names. Common mappings:

| Vanilla | VoxeLibre |
|---------|-----------|
| `default:book` | `mcl_books:book` |
| `default:stick` | `mcl_core:stick` |
| `default:apple` | `mcl_core:apple` |
| `default:stone` | `mcl_core:stone` |
| `farming:wheat` | `mcl_farming:wheat_item` |
| `mcl_sounds` | Remove (not available) |

In `mod.conf`: use `optional_depends = mcl_core, mcl_farming` instead of `depends = default, farming`.

### Nuclear Config
The server requires a nuclear config override to disable monsters. Apply with `./scripts/apply-nuclear-config.sh`. Details: `docs/config/02-NUCLEAR_CONFIG.md`.

## Texture Corruption — Golden Rules

1. **NEVER modify `docker-compose.yml` volume mappings for mods** — causes texture ID conflicts
2. **NEVER install mods with heavy texture dependencies** (motorboat, biofuel, mobkit) without local testing first
3. **ALWAYS backup world data before mod changes**: `cp -r server/worlds server/worlds_BACKUP_$(date +%Y%m%d)`

Recovery protocol: `docs/operations/texture-recovery.md`

## Server Config Summary

- **Mode**: Creative (no damage, no PvP, no TNT)
- **Max Players**: 20
- **Spawn**: 0,15,0 (static)
- **World Gen**: v7 with caves, dungeons, biomes
- **New Player Privileges**: interact, shout, fly, fast, noclip, give, creative, spawn (via `wetlands_newplayer` mod)

## Custom Mods

| Mod | Purpose |
|-----|---------|
| `animal_sanctuary` | Animal care mechanics (brushes, feeding, shelters) |
| `vegan_food` | Plant-based food items |
| `education_blocks` | Interactive educational content |
| `back_to_spawn` | `/back_to_spawn` teleportation |
| `wetlands_newplayer` | Auto-grant privileges to new players |
| `server_rules` | `/reglas` command |
| `pvp_arena` | PVP arena system |
| `worldedit` | Building tools |

## Documentation Index

Detailed docs live in `docs/`. Read these when you need specifics:

### Operations
- `docs/operations/deploy.md` — CI/CD pipeline and deployment process
- `docs/operations/backups.md` — Backup system and recovery
- `docs/operations/VPS_SYNC_WORKFLOW.md` — VPS synchronization workflow
- `docs/operations/DISCORD_NOTIFICATIONS.md` — Discord webhook notifications
- `docs/operations/texture-recovery.md` — Emergency texture corruption recovery
- `docs/operations/troubleshooting.md` — General troubleshooting

### Configuration
- `docs/config/01-CONFIGURATION_HIERARCHY.md` — Config file hierarchy
- `docs/config/02-NUCLEAR_CONFIG.md` — Nuclear config (no monsters)
- `docs/config/04-VOXELIBRE_SYSTEM.md` — VoxeLibre installation and system
- `docs/config/07-CUSTOM_SKINS.md` — Custom skin system
- `docs/config/08-CREATIVE_NATIVE_MODE.md` — Creative mode config

### Admin
- `docs/admin/USER_PRIVILEGES.md` — User privileges and SQLite admin
- `docs/admin/QUICK_ADD_SKINS.md` — Adding player skins
- `docs/admin/comandos-admin.md` — Admin commands reference
- `docs/admin/manual-administracion.md` — Admin manual

### Mods
- `docs/mods/MODDING_GUIDE.md` — General modding guide
- `docs/mods/PVP_ARENA_WORLDEDIT_GUIDE.md` — PVP Arena + WorldEdit
- `docs/mods/WORLDEDIT_GUIDE.md` — WorldEdit usage
- `docs/mods/CHESS_MOD.md` — Chess mod

### Web
- `docs/web/landing-page.md` — Landing page architecture and deployment

### Security
- `docs/security/policies/SERVER_SECURITY_POLICY.md` — Security policy
- `docs/security/procedures/INCIDENT_RESPONSE.md` — Incident response
