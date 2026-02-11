# GEMINI.md

Guidance for Google Gemini working with this repository.

## Project Overview

Wetlands is a **Luanti (formerly Minetest) game server** -- a compassionate, educational, creative environment for children 7+. Custom mods promote animal care, compassion, and non-violent gameplay. Server address: `luanti.gabrielpantoja.cl:30000`.

## Repository Scope

This repo (`luanti-voxelibre-server.git`) owns **all** Luanti code, config, mods, landing page, and deployment. It is independent from the VPS admin repo (`vps-do.git`). **Never** modify Luanti files in `vps-do.git`.

## Key Technologies

- **Runtime**: Docker Compose with `linuxserver/luanti:latest`
- **Base Game**: VoxeLibre (MineClone2) v0.90.1
- **Mods**: Lua scripts in `server/mods/`
- **Config**: `.conf` files, not JSON/YAML
- **Deploy**: GitHub Actions CI/CD + manual `git pull` on VPS
- **VPS**: `ssh gabriel@167.172.251.27`
- **Port**: 30000/UDP (game), 80/443 (landing page via nginx)
- **Language**: Spanish (es)

## Configuration Hierarchy (CRITICAL)

There are TWO config files. Both contain `load_mod_*` entries.

| File | Authority | Contains | Edit where |
|------|-----------|----------|------------|
| `server/config/luanti.conf` | **HIGHEST** (wins all conflicts) | Server settings + `load_mod` (master list) | This repo (git tracked) |
| `server/worlds/world/world.mt` | Lower (overridden by luanti.conf) | World backends + `load_mod` entries | **VPS via SSH** (not in git) |

**How `load_mod` works across both files:**
- Both files have `load_mod_*` entries. `luanti.conf` is the master authority.
- If `luanti.conf` says `load_mod_X = false`, the mod is OFF even if `world.mt` says `true`.
- If a mod is ONLY in `world.mt` (not in luanti.conf), `world.mt` controls it.
- `luanti.conf` also contains `= false` entries to explicitly disable dangerous mods (motorboat, biofuel, etc.)

**To enable a NEW mod:** add to BOTH `luanti.conf` (this repo) AND `world.mt` (VPS).

Details: `docs/config/01-CONFIGURATION_HIERARCHY.md`

## File Structure

```
docker-compose.yml              # Container orchestration
server/config/luanti.conf       # Server config (HIGHEST authority)
server/games/mineclone2/        # VoxeLibre game files
server/mods/                    # Custom + third-party mods
server/worlds/world/world.mt    # LOCAL REFERENCE COPY (real one lives on VPS)
server/skins/                   # Player skins (64x32 PNG)
server/landing-page/            # Web landing page (HTML/CSS/JS)
scripts/                        # start.sh, backup.sh, deploy-landing.sh, etc.
docs/                           # Detailed documentation
.env                            # Local secrets (gitignored)
```

## Essential Commands

```bash
# Local development
./scripts/start.sh                          # Start server locally
docker-compose logs -f luanti-server        # View logs
docker-compose restart luanti-server        # Restart

# VPS deployment flow: local -> GitHub -> VPS
git push origin main
ssh gabriel@167.172.251.27 "cd /home/gabriel/luanti-voxelibre-server && git pull origin main"
ssh gabriel@167.172.251.27 "cd /home/gabriel/luanti-voxelibre-server && docker-compose restart luanti-server"

# Check logs on VPS
ssh gabriel@167.172.251.27 "docker logs --tail=50 luanti-voxelibre-server 2>&1 | grep -i error"
```

## Texture Corruption -- Golden Rules

1. **NEVER modify `docker-compose.yml` volume mappings for mods** -- causes texture ID conflicts
2. **NEVER install mods with heavy texture dependencies** (motorboat, biofuel, mobkit) without local testing
3. **ALWAYS backup world data before mod changes**
4. **NEVER name mod textures with VoxeLibre base names** -- use unique prefixes

**Emergency Recovery Protocol:**
```bash
ssh gabriel@167.172.251.27 "cd /home/gabriel/luanti-voxelibre-server && cp -r server/worlds server/worlds_EMERGENCY_BACKUP_$(date +%Y%m%d_%H%M%S)"
ssh gabriel@167.172.251.27 "cd /home/gabriel/luanti-voxelibre-server && docker-compose down && docker system prune -f"
ssh gabriel@167.172.251.27 "cd /home/gabriel/luanti-voxelibre-server && rm -rf server/games/mineclone2 && rm -f voxelibre.zip"
ssh gabriel@167.172.251.27 "cd /home/gabriel/luanti-voxelibre-server && wget https://content.luanti.org/packages/Wuzzy/mineclone2/releases/32301/download/ -O voxelibre.zip && unzip voxelibre.zip -d server/games/ && mv server/games/mineclone2-* server/games/mineclone2"
ssh gabriel@167.172.251.27 "cd /home/gabriel/luanti-voxelibre-server && docker-compose up -d"
```

## VoxeLibre Critical Pitfalls

### `default_privs` Does NOT Work
VoxeLibre ignores `default_privs`. The `wetlands_newplayer` mod grants privileges via `minetest.register_on_newplayer()`.

### Item Name Mapping
Mods must use VoxeLibre names:

| Vanilla | VoxeLibre |
|---------|-----------|
| `default:book` | `mcl_books:book` |
| `default:stick` | `mcl_core:stick` |
| `default:apple` | `mcl_core:apple` |
| `farming:wheat` | `mcl_farming:wheat_item` |
| `mcl_sounds` | Remove (not available) |

In `mod.conf`: use `optional_depends` instead of `depends`.

### mcl_mobs: hp_min/hp_max Deprecation
Put `hp_min`/`hp_max` inside `initial_properties = {}`, NOT at the root level of mob definitions.

## Authentication System (SQLite)

Luanti 5.13+ uses SQLite (`auth.sqlite`), not `auth.txt`.

```bash
# List users
docker-compose exec -T luanti-server sqlite3 /config/.minetest/worlds/world/auth.sqlite 'SELECT name FROM auth;'

# View user privileges (replace USER_ID)
docker-compose exec -T luanti-server sqlite3 /config/.minetest/worlds/world/auth.sqlite 'SELECT * FROM user_privileges WHERE id=USER_ID;'
```

## Server Config Summary

- **Mode**: Creative (no damage, no PvP, no TNT)
- **Max Players**: 20
- **Spawn**: 0,15,0 (static)
- **New Player Privileges**: interact, shout, fly, fast, noclip, give, creative, spawn

## Enabled Mods

### Custom Wetlands Mods
| Mod | Purpose |
|-----|---------|
| `wetlands_npcs` | Interactive NPCs with AI, voices, and dialogues |
| `wetlands_newplayer` | Auto-grant privileges to new players |
| `wetlands_music` | Background music system |
| `wetlands_christmas` | Seasonal Christmas content |
| `mcl_back_to_spawn` | `/back_to_spawn` teleportation |
| `server_rules` | `/reglas` command |
| `pvp_arena` | PVP arena system |
| `voxelibre_protection` | Area protection |

### Third-Party Mods
| Mod | Purpose |
|-----|---------|
| `worldedit` | Building tools |
| `chess` | In-game chess |
| `celevator` | Elevator system |
| `automobiles_*` | Vehicles (vespa, beetle, motorcycle, buggy) |
| `3dforniture` | 3D furniture |
| `mcl_decor` | Decoration blocks |
| `broom_racing` | Broom racing minigame |

## Project Constraints

- **No package.json** -- not a Node.js project
- **No build system** -- Docker Compose + Lua only
- **No unit tests** -- testing via manual gameplay
- **Lua scripting** -- all mod logic in Lua
- **SQLite auth** -- not text files
