# CLAUDE.md

Guidance for Claude Code working with this repository.

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

## File Structure

```
docker-compose.yml              # Container orchestration
server/config/luanti.conf       # Server config (creative, no damage, no PvP)
server/games/mineclone2/        # VoxeLibre game files
server/mods/                    # Custom + third-party mods
server/worlds/world/world.mt    # LOCAL REFERENCE COPY (real one lives on VPS)
server/skins/                   # Player skins (64x32 PNG)
server/landing-page/            # Web landing page (HTML/CSS/JS)
server/backups/                 # Automated backup storage
scripts/                        # start.sh, backup.sh, deploy-landing.sh, etc.
docs/                           # Detailed documentation (see index below)
.env                            # Local secrets (gitignored) - admin credentials
```

## Configuration Hierarchy (CRITICAL)

There are TWO config files. Both contain `load_mod_*` entries. Understanding which wins is essential.

| File | Authority | Contains | Edit where |
|------|-----------|----------|------------|
| `server/config/luanti.conf` | **HIGHEST** (wins all conflicts) | Server settings + `load_mod` (master list) | This repo (git tracked) |
| `server/worlds/world/world.mt` | Lower (overridden by luanti.conf) | World backends + `load_mod` entries | **VPS via SSH** (not in git) |

### How `load_mod` works across both files:
- **Both files** have `load_mod_*` entries. `luanti.conf` is the master authority.
- If `luanti.conf` says `load_mod_X = false`, the mod is OFF even if `world.mt` says `true`.
- If `luanti.conf` says `load_mod_X = true`, the mod loads.
- If a mod is ONLY in `world.mt` (not in luanti.conf), `world.mt` controls it.
- `luanti.conf` also contains `= false` entries to explicitly disable mods (motorboat, biofuel, etc.)

### To enable a NEW mod:
1. Add `load_mod_<name> = true` to `server/config/luanti.conf` (in this repo, push via git)
2. Add `load_mod_<name> = true` to `world.mt` on VPS via SSH (both host file and container file)
3. Restart server

### To disable a mod:
- Set `load_mod_<name> = false` in `luanti.conf` -- this guarantees it stays off regardless of `world.mt`

### Reference copy:
- A local copy of `world.mt` exists at `server/worlds/world/world.mt` for reference only (gitignored)
- The real `world.mt` lives on the VPS at `/home/gabriel/luanti-voxelibre-server/server/worlds/world/world.mt`

Details: `docs/config/01-CONFIGURATION_HIERARCHY.md`

## Essential Commands

### Local
```bash
./scripts/start.sh                          # Start server locally
docker-compose logs -f luanti-server        # View logs
docker-compose restart luanti-server        # Restart
docker-compose down                         # Stop
```

### VPS Deployment
```bash
# Standard deploy flow: local -> GitHub -> VPS
git push origin main
ssh gabriel@167.172.251.27 "cd /home/gabriel/luanti-voxelibre-server && git pull origin main"
ssh gabriel@167.172.251.27 "cd /home/gabriel/luanti-voxelibre-server && docker-compose restart luanti-server"

# Verify after restart (use --since to avoid old log noise)
ssh gabriel@167.172.251.27 "docker logs --since='2m' luanti-voxelibre-server 2>&1 | grep -i 'error\|warning\|my_mod'"

# Enable a mod on VPS (world.mt must be edited in BOTH host and container)
ssh gabriel@167.172.251.27 "echo 'load_mod_my_mod = true' >> /home/gabriel/luanti-voxelibre-server/server/worlds/world/world.mt"
ssh gabriel@167.172.251.27 "docker exec luanti-voxelibre-server sh -c 'echo \"load_mod_my_mod = true\" >> /config/.minetest/worlds/world/world.mt'"
```

**IMPORTANT:** When checking logs after restart, always use `--since='2m'` or `--since='5m'` to filter only recent entries. The full log contains thousands of historical entries that will pollute search results.

## Development Workflow

### Adding New Mods
1. Create directory in `server/mods/<mod_name>/`
2. Add `mod.conf` (use `optional_depends`, not `depends` for VoxeLibre mods)
3. Write `init.lua`
4. Add `load_mod_<name> = true` to `server/config/luanti.conf`
5. Test locally with `./scripts/start.sh`
6. Commit and push to GitHub
7. `git pull origin main` on VPS
8. Add `load_mod_<name> = true` to `world.mt` on VPS (both host + container files)
9. Restart server on VPS

### Modifying Config
- Edit `server/config/luanti.conf` in **this repo only**
- Key settings: `creative_mode`, `enable_damage`, `max_users`
- Push + pull + restart on VPS

## Key Constraints

- **No package.json** -- not a Node.js project
- **No build system** -- Docker Compose + Lua only
- **No unit tests** -- testing via manual gameplay
- **Lua scripting** -- all mod logic in Lua
- **SQLite auth** -- privileges in `server/worlds/world/auth.sqlite`, not text files

## VoxeLibre Critical Pitfalls

### `default_privs` Does NOT Work
VoxeLibre **ignores** the `default_privs` setting in `minetest.conf`. The `wetlands_newplayer` mod fixes this via `minetest.register_on_newplayer()`. Edit `server/mods/wetlands_newplayer/init.lua` to change privileges. **Always use the mod, never rely on `default_privs`.**

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

### mcl_mobs Deprecation: hp_min/hp_max
When registering mobs with `mcl_mobs.register_mob()`, put `hp_min` and `hp_max` inside `initial_properties = {}`, NOT at the root level. Root-level placement triggers deprecation warnings.

### Making NPCs Immortal
`return true` in `on_punch` does NOT work with mcl_mobs. The correct approach:
```lua
on_activate = function(self, staticdata, dtime_s)
    self.object:set_armor_groups({immortal = 1})
end,
```

### Entity Migration When Renaming/Deleting Mods
When a mod is renamed (e.g., `custom_villagers` -> `wetlands_npcs`) or deleted, entities already spawned in the world still reference the OLD mod name. The server logs `LuaEntity name "old_mod:entity" not defined` errors.

**Fix:** Register lightweight legacy entities under the old name that auto-replace on activation:
```lua
for _, vtype in ipairs({"farmer", "librarian", "teacher", "explorer"}) do
    minetest.register_entity(":old_mod:" .. vtype, {
        on_activate = function(self, staticdata, dtime_s)
            local pos = self.object:get_pos()
            self.object:remove()
            if pos then
                minetest.add_entity(pos, "new_mod:" .. vtype)
            end
        end,
    })
end
```
The `:` prefix in `:old_mod:entity` allows registering under a different mod namespace.

### Nuclear Config
The server requires a nuclear config override to disable monsters. Apply with `./scripts/apply-nuclear-config.sh`. Details: `docs/config/02-NUCLEAR_CONFIG.md`.

## Texture & Asset Rules

### Golden Rules
1. **NEVER modify `docker-compose.yml` volume mappings for mods** -- causes texture ID conflicts
2. **NEVER install mods with heavy texture dependencies** (motorboat, biofuel, mobkit) without local testing first
3. **ALWAYS backup world data before mod changes**: `cp -r server/worlds server/worlds_BACKUP_$(date +%Y%m%d)`
4. **NEVER name mod textures with VoxeLibre base names** (e.g. `mobs_mc_villager_farmer.png`) -- use unique prefixes like `wetlands_npc_*.png`

### Villager Textures: UV Map is NOT Player Skin Format
The `mobs_mc_villager.b3d` model uses the **Minecraft villager UV layout** (64x64), which is completely different from player skin UV (also 64x64 but different regions). The villager has: head with protruding nose, hat overlay, robe body, crossed arms, and legs -- all in unique UV positions.

**NEVER draw villager textures from scratch** -- you WILL get the UV wrong. Instead:
1. Use the base texture from `server/games/mineclone2/textures/mobs_mc_villager.png` as reference
2. **Recolor it** using the script at `server/mods/wetlands_npcs/tools/generate_textures.py`
3. Reference copies are at `server/mods/wetlands_npcs/textures/raw_skins/ref_villager_base.png`

### Player Skins vs Villager Textures
| Format | Size | Used by | UV Layout |
|--------|------|---------|-----------|
| Player skin | 64x32 | `server/skins/` | Steve/Alex format (head, torso, arms, legs) |
| Villager texture | 64x64 | `mobs_mc_villager.b3d` | Minecraft villager format (robe, hat overlay, nose) |

These are **NOT interchangeable**. Downloaded Minecraft player skins cannot be used directly as villager textures.

Recovery protocol: `docs/operations/texture-recovery.md`

## Server Config Summary

- **Mode**: Creative (no damage, no PvP, no TNT)
- **Max Players**: 20
- **Spawn**: 0,15,0 (static)
- **World Gen**: v7 with caves, dungeons, biomes
- **New Player Privileges**: interact, shout, fly, fast, noclip, give, creative, spawn (via `wetlands_newplayer` mod)

## Enabled Mods (from world.mt)

### Custom Wetlands Mods
| Mod | Purpose |
|-----|---------|
| `wetlands_npcs` | Interactive NPCs with AI, voices, and dialogues (v1.0.0) |
| `wetlands_newplayer` | Auto-grant privileges to new players |
| `wetlands_music` | Background music system |
| `wetlands_christmas` | Seasonal Christmas content |
| `mcl_back_to_spawn` | `/back_to_spawn` teleportation |
| `server_rules` | `/reglas` command |
| `pvp_arena` | PVP arena system |
| `mcl_custom_world_skins` | Custom player skins |
| `voxelibre_protection` | Area protection |
| `voxelibre_tv` | In-game TV screens |

### Third-Party Mods
| Mod | Purpose |
|-----|---------|
| `worldedit` + commands + shortcuts | Building tools |
| `chess` | In-game chess |
| `celevator` | Elevator system |
| `automobiles_*` (lib, vespa, beetle, motorcycle, buggy) | Vehicles |
| `3dforniture` | 3D furniture |
| `mcl_decor` | Decoration blocks |
| `broom_racing` | Broom racing minigame |
| `auto_road_builder` | Road building tool |
| `halloween_ghost` | Seasonal ghost |
| `halloween_zombies` | Seasonal zombies |

## Documentation Index

Detailed docs live in `docs/`. Read these when you need specifics:

### Operations
- `docs/operations/deploy.md` -- CI/CD pipeline and deployment process
- `docs/operations/backups.md` -- Backup system and recovery
- `docs/operations/VPS_SYNC_WORKFLOW.md` -- VPS synchronization workflow
- `docs/operations/texture-recovery.md` -- Emergency texture corruption recovery

### Configuration
- `docs/config/01-CONFIGURATION_HIERARCHY.md` -- Config file hierarchy (luanti.conf vs world.mt)
- `docs/config/02-NUCLEAR_CONFIG.md` -- Nuclear config (no monsters)
- `docs/config/04-VOXELIBRE_SYSTEM.md` -- VoxeLibre installation and system
- `docs/config/07-CUSTOM_SKINS.md` -- Custom skin system
- `docs/config/08-CREATIVE_NATIVE_MODE.md` -- Creative mode config

### Admin
- `docs/admin/USER_PRIVILEGES.md` -- User privileges and SQLite admin
- `docs/admin/QUICK_ADD_SKINS.md` -- Adding player skins
- `docs/admin/comandos-admin.md` -- Admin commands reference

### Mods
- `docs/mods/MODDING_GUIDE.md` -- General modding guide
- `docs/mods/PVP_ARENA_WORLDEDIT_GUIDE.md` -- PVP Arena + WorldEdit
- `docs/mods/WORLDEDIT_GUIDE.md` -- WorldEdit usage
- `docs/mods/CHESS_MOD.md` -- Chess mod

### Web
- `docs/web/landing-page.md` -- Landing page architecture and deployment

### Security
- `docs/security/policies/SERVER_SECURITY_POLICY.md` -- Security policy
- `docs/security/procedures/INCIDENT_RESPONSE.md` -- Incident response
