# AGENTS.md

Guidance for Codex working with this repository.

## Project Overview

Wetlands is a **Luanti (formerly Minetest) game server** — a creative, educational, kid-friendly environment. Custom mods promote animal care and non-violent exploration, while a dedicated PvP arena exists for opt-in combat. Public address: `luanti.gabrielpantoja.cl:30000` (Wetlands) and `:30001` (Valdivia 2.0).

## Repository Scope

This repo (`luanti-voxelibre-server`) owns **all** Luanti code, config, mods, landing page, and deployment files. A separate repo, `infra/vps-oracle` (renamed from the older `vps-do`), owns host-level VPS configuration (nginx system service, Docker host, SSL). **Never** put Luanti-specific files in `vps-oracle`.

## Key Technologies

- **Runtime**: Docker Compose v2 (`docker compose`) on the VPS. Docker Compose v1 (`docker-compose`) may still be available locally; they are interchangeable here.
- **Container image**: `linuxserver/luanti:latest` — inside the container, the server user is `abc` (UID 911). Any file created by the container on a mounted volume ends up owned by UID 911 on the host.
- **Base game**: VoxeLibre (MineClone2) v0.90.1 at `server/games/mineclone2/`.
- **Mod language**: Lua. No build system, no package manager, no tests — changes are validated by running the server and playing.
- **VPS**: Oracle Cloud Free Tier, ARM aarch64. SSH as `<VPS_USER>@<VPS_IP>` (a working SSH config / default key is assumed).
- **Deployment**: manual `git pull` on the VPS. There are **no GitHub Actions workflows** in this repo.
- **Ports**: 30000/UDP (Wetlands), 30001/UDP (Valdivia 2.0), 80/443 (landing page via nginx on the VPS).
- **UI language**: Spanish.

## File Structure

```
docker-compose.yml                   # Dual-service: luanti-server + luanti-valdivia
                                     # Plus backup-cron and Discord notifier sidecars
server/config/luanti-original.conf            # Wetlands authoritative config (see hierarchy below)
server/config/luanti-valdivia.conf   # Valdivia config (singlenode mapgen, no mobs)
server/games/mineclone2/             # VoxeLibre game files, shared by both worlds
server/mods/                         # Custom + third-party mods
server/worlds/original/                 # LOCAL REFERENCE ONLY (gitignored, real copy is on VPS)
server/worlds/valdivia/              # Valdivia world (map.sqlite is ~480 MB, not in git)
server/skins/                        # Player skins (64x32 PNG)
server/landing-page/                 # HTML/CSS/JS for luanti.gabrielpantoja.cl
server/backups/                      # Tarball storage written by backup-cron (gitignored)
scripts/                             # Ops scripts (start, backup, sync, Arnis, etc.)
docs/                                # Public documentation (index below)
.env.local                           # Local secrets (gitignored)
```

## Configuration Hierarchy (CRITICAL)

There are two files that both list `load_mod_*` entries. Confusing which wins is the single most common source of "why doesn't my mod load" bugs.

| File | Role | Lives in git? | Edit where |
|------|------|---------------|------------|
| `server/worlds/original/world.mt` | **Primary enable gate** — a mod must be `= true` here to load | No (gitignored) | On the VPS via SSH |
| `server/config/luanti-original.conf` | **Kill-switch** — `= false` here overrides any `= true` in `world.mt` | Yes | This repo |

Rules (verified empirically 2026-04-19 when enabling `mypark`):
- A mod loads **only if `world.mt` has `load_mod_X = true`**. `luanti-original.conf = true` alone is **not sufficient** — the mod will silently not register.
- If `luanti-original.conf` has `load_mod_X = false`, the mod is OFF regardless of `world.mt`. This is the canonical kill-switch and doesn't need SSH.
- `luanti-original.conf` explicitly pins several mods to `= false` (motorboat, biofuel, etc.) so they stay off even if someone adds them to `world.mt`.

To enable a NEW mod (both files must be updated):
1. Add `load_mod_<name> = true` to `server/config/luanti-original.conf` and push via git.
2. Pull on the VPS.
3. Add `load_mod_<name> = true` to the world's `world.mt` on the VPS. Since `docker-compose.yml` bind-mounts `./server/worlds` into the container, the host file at `/home/<VPS_USER>/luanti-voxelibre-server/server/worlds/original/world.mt` **is** the container file at `/config/.minetest/worlds/original/world.mt` — one edit is enough:
   ```bash
   ssh <VPS_USER>@<VPS_IP> "echo 'load_mod_<name> = true' | sudo tee -a /home/<VPS_USER>/luanti-voxelibre-server/server/worlds/original/world.mt"
   ```
4. Restart the container.

To disable a mod: set `load_mod_<name> = false` in `luanti-original.conf`. This overrides `world.mt` unconditionally — no SSH needed.

Reference copy: `server/worlds/original/world.mt` in this repo is a local snapshot for convenience; it is gitignored and is not the file the running server reads. See `docs/config/01-CONFIGURATION_HIERARCHY.md`.

## Essential Commands

### Local

```bash
./scripts/start.sh                   # docker compose up -d
docker compose logs -f luanti-server
docker compose restart luanti-server
docker compose down
```

`./scripts/start.sh` currently calls `docker-compose` (v1). If you only have v2 installed, invoke services directly: `docker compose up -d luanti-server`.

### VPS deployment

```bash
# Standard flow: local → GitHub → VPS
git push origin main
ssh <VPS_USER>@<VPS_IP> "cd /home/<VPS_USER>/luanti-voxelibre-server && git pull origin main"
ssh <VPS_USER>@<VPS_IP> "cd /home/<VPS_USER>/luanti-voxelibre-server && docker compose restart luanti-server"

# Verify post-restart — ALWAYS use --since to avoid log noise
ssh <VPS_USER>@<VPS_IP> "docker logs --since='2m' luanti-voxelibre-server 2>&1 | grep -iE 'error|warning|my_mod'"
```

When containers write to mounted volumes, permissions may break future host-side git operations. **DO NOT** run `chown -R` over the whole repo — it clobbers `server/worlds/` and `server/config/`, which must stay owned by the container user (set by `PUID` in `docker-compose.yml`, currently `1000` on the Oracle VPS). Scope the chown to only what git needs to write:

```bash
ssh <VPS_USER>@<VPS_IP> "cd /home/<VPS_USER>/luanti-voxelibre-server && \
  sudo chown -R <VPS_USER>:<VPS_USER> server/mods server/games server/landing-page \
       server/skins scripts docs *.md *.yml *.conf 2>/dev/null || true"
```

**If you already clobbered the wrong dirs** (symptom: `Couldn't save env meta` fatal on container start), restore container ownership:

```bash
ssh <VPS_USER>@<VPS_IP> "sudo chown -R 1000:1000 \
  /home/<VPS_USER>/luanti-voxelibre-server/server/worlds \
  /home/<VPS_USER>/luanti-voxelibre-server/server/config"
```

If `git pull` still refuses because of a file git wants to overwrite (e.g. an edit someone made on the VPS), inspect with `git diff <file>` and either commit, stash, or `git checkout -- <file>` — don't force.

For Valdivia-specific ops (map.sqlite upload, generation, remap), see `docs/projects/proyecto-valdivia-luanti.md`.

## Development Workflow

### Adding a new mod
1. Create `server/mods/<mod_name>/mod.conf` + `init.lua`. In `mod.conf` use `optional_depends`, not `depends` (see pitfalls below).
2. Add `load_mod_<mod_name> = true` to `server/config/luanti-original.conf`.
3. Test locally with `./scripts/start.sh` and monitor logs.
4. Commit + push.
5. On VPS: `git pull`, then `echo 'load_mod_<mod_name> = true' | sudo tee -a server/worlds/original/world.mt`, then restart. **Skipping the world.mt step is the #1 cause of "mod files exist but items are unknown"** — `luanti-original.conf = true` alone does not register a new mod.

### Modifying server config
Edit `server/config/luanti-original.conf` in this repo. Push, pull on VPS, restart. Do **not** edit the `.conf` directly on the VPS — it will be overwritten on the next pull.

## Current server settings (from `server/config/luanti-original.conf`)

- `creative_mode = true`
- `enable_damage = true` — damage is on globally. This is intentional: hostile mobs can hurt players at night, and the PvP arena relies on it. Non-arena PvP is prevented by mod logic (`pvp_arena`), not by this flag.
- `only_peaceful_mobs = false` — hostile mobs spawn at night. Creepers are blocked separately by the `wetlands_no_creeper` mod. The landing page and README describe the overworld as "daytime safe, nighttime dangerous except Creepers".
- `static_spawnpoint = 0,15,0`
- `max_users = 20`

## New player privileges

VoxeLibre **ignores** `default_privs` in `minetest.conf`. Privileges for new players are granted by the `wetlands_newplayer` mod in `server/mods/wetlands_newplayer/init.lua` — the `PRIVS` table there is the source of truth. Edit that table to change the default privilege set; do **not** add `default_privs` anywhere.

## VoxeLibre critical pitfalls

### Item / namespace renames
Vanilla Minetest item names don't work in VoxeLibre. Common mappings:

| Vanilla (wrong) | VoxeLibre (correct) |
|-----------------|---------------------|
| `default:book` | `mcl_books:book` |
| `default:stick` | `mcl_core:stick` |
| `default:apple` | `mcl_core:apple` |
| `default:stone` | `mcl_core:stone` |
| `farming:wheat` | `mcl_farming:wheat_item` |

In `mod.conf`, use `optional_depends = mcl_core, mcl_farming`. Never depend on `mcl_sounds` — it doesn't exist in this VoxeLibre version.

### `mcl_mobs` quirks
- Put `hp_min` / `hp_max` inside `initial_properties = {}`, not at the root of the mob definition — root-level placement triggers deprecation warnings.
- Use `do_punch` (not `on_punch`) for custom punch handlers — `mcl_mobs` only copies `do_punch` onto the mob.
- To make an NPC immortal, `return true` from `on_punch` is **not enough**. Use:
  ```lua
  on_activate = function(self, staticdata, dtime_s)
      self.object:set_armor_groups({immortal = 1})
  end,
  ```

### Entity migration when renaming / removing a mod
When a mod that registered entities is renamed or deleted, already-spawned entities still reference the old namespace. The server then logs `LuaEntity name "old_mod:entity" not defined` and the entities sit as broken objects.

Fix: register a thin legacy entity that self-replaces on activation. The `:` prefix lets you register under a different namespace from the current mod:

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

### Nuclear config
An out-of-band override is applied to disable certain game rules not exposed via `luanti-original.conf`. Apply with `./scripts/apply-nuclear-config.sh`. See `docs/config/02-NUCLEAR_CONFIG.md`.

## Texture & asset rules

1. **Never change `docker-compose.yml` volume mappings for mods.** Luanti assigns texture IDs at mod-load order; changing the mount layout reshuffles them and corrupts textures on existing chunks.
2. **Never install mods with heavy texture dependencies** (motorboat, biofuel, mobkit) without testing locally first. They routinely conflict with existing mods.
3. **Back up before mod changes.** Quick option: `cp -r server/worlds server/worlds_BACKUP_$(date +%Y%m%d)`. Automated backups run in the `backup-cron` sidecar every 12h.
4. **Never name mod textures with VoxeLibre base names** (e.g. `mobs_mc_villager_farmer.png`). Always prefix: `wetlands_npc_*.png`, `wetlands_music_*.png`.

### Villager textures use the Minecraft villager UV, not the player skin UV
The `mobs_mc_villager.b3d` model expects a 64×64 texture laid out in the Minecraft villager UV layout (robe, hat overlay, nose). This is **different** from the 64×64 Minecraft player skin UV and from the 64×32 Luanti player skin UV.

Never draw a villager texture from scratch — you will get the UV wrong. Instead, recolor the base at `server/games/mineclone2/textures/mobs_mc_villager.png` using `server/mods/wetlands_npcs/tools/generate_textures.py`. A reference copy is at `server/mods/wetlands_npcs/textures/raw_skins/ref_villager_base.png`.

Recovery protocol for corrupted textures lives in the private repo: `infra/privado/luanti/operations/texture-recovery.md`.

### Skin / texture format matrix
| Format | Size | Model | Used by | UV layout |
|--------|------|-------|---------|-----------|
| Player skin | 64×32 | `mcl_armor_character.b3d` | `server/skins/`, Star Wars NPCs | Steve/Alex (head, torso, arms, legs) |
| Villager texture | 64×64 | `mobs_mc_villager.b3d` | Classic NPCs (farmer, etc.) | Minecraft villager (robe, hat overlay, nose) |
| Minecraft skin (downloaded) | 64×64 | N/A — must convert | Source from MinecraftSkins.com | Player skin format; **must be cropped to 64×32** before use |

To convert a downloaded Minecraft skin: `img.crop((0, 0, 64, 32))` with PIL, or use https://godly.github.io/minetest-skin-converter/.

### NPC dual model system (`wetlands_npcs`)
| NPC type | Model | Texture | Pose |
|----------|-------|---------|------|
| Star Wars (luke, anakin, yoda, mandalorian) | `mcl_armor_character.b3d` (aliased as `wetlands_npc_human.b3d`) | 64×32, 3 layers `{skin, blank, blank}` | Arms at sides |
| Classic (farmer, librarian, teacher, explorer) | `mobs_mc_villager.b3d` | 64×64, 1 layer | Arms crossed |

Adding a new Star Wars-style NPC: download 64×64 skin → crop to 64×32 → save as `textures/wetlands_npc_<name>.png` → register via `register_npc()`.

Adding a new classic NPC: recolor `mobs_mc_villager.png` via `tools/generate_textures.py` → save as `textures/wetlands_npc_<name>.png` → register via `register_classic_npc()`.

Never use `mobs_mc_zombie.b3d` for humanoid NPCs — its bind pose has arms stretched forward (zombie). Always use `mcl_armor_character.b3d`.

## Dual world architecture

| World | Container | Port | Config | Purpose |
|-------|-----------|------|--------|---------|
| Wetlands | `luanti-voxelibre-server` | 30000/UDP | `luanti-original.conf` | Main creative world — NPCs, mods, PvP arena |
| Valdivia 2.0 | `luanti-valdivia-server` | 30001/UDP | `luanti-valdivia.conf` | Real-world recreation of Valdivia, Chile from OpenStreetMap (Arnis PR #808) |

Both containers share the same `server/games/` and `server/mods/` directories. Valdivia uses `singlenode` mapgen with a pre-generated `map.sqlite` (~480 MB, not in git). See `docs/projects/proyecto-valdivia-luanti.md`.

## Enabled mods (authoritative list: `server/config/luanti-original.conf`)

### Custom Wetlands mods
| Mod | Purpose |
|-----|---------|
| `wetlands_npcs` | Interactive NPCs (Star Wars + classic) with AI, voices, dialogs, dual model system |
| `wetlands_newplayer` | Grants the default privilege set on first join (replaces `default_privs`) |
| `wetlands_music` | Background music system |
| `wetlands_christmas` | Seasonal Christmas content |
| `wetlands_no_creeper` | Disables Creeper spawning (keeps other hostile mobs) |
| `wetlands_lastpos` | On rejoin, teleports returning players to their last logged-out position |
| `mcl_back_to_spawn` | `/back_to_spawn` teleport |
| `server_rules` | `/reglas` command, broadcast announcements |
| `pvp_arena` | PvP arena system — the only place PvP is allowed |
| `mcl_custom_world_skins` | Custom player skin selector |
| `voxelibre_protection` | Area protection |
| `voxelibre_tv` | In-game TV screens |

### Third-party mods
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
| `halloween_ghost`, `halloween_zombies` | Seasonal (activate in October) |

## Documentation index

Detailed docs live under `docs/`. Read these when you need specifics.

### Configuration
- `docs/config/01-CONFIGURATION_HIERARCHY.md` — luanti-original.conf vs world.mt
- `docs/config/02-NUCLEAR_CONFIG.md` — nuclear config (disables monsters)
- `docs/config/04-VOXELIBRE_SYSTEM.md` — VoxeLibre installation
- `docs/config/07-CUSTOM_SKINS.md` — custom skin system
- `docs/config/08-CREATIVE_NATIVE_MODE.md` — creative mode

### Admin
- `docs/admin/comandos-admin.md` — admin commands reference
- `docs/admin/QUICK_ADD_SKINS.md` — adding player skins

### Operations
- `docs/operations/BACKUP_STATUS.md` — backup system diagnosis and plan
- `docs/operations/clonar-mundo-produccion-local.md` — pull a prod backup and run it locally

### Mods
- `docs/mods/MODDING_GUIDE.md` — general modding guide
- `docs/mods/PVP_ARENA_WORLDEDIT_GUIDE.md` — PvP arena + WorldEdit
- `docs/mods/WORLDEDIT_GUIDE.md` — WorldEdit usage
- `docs/mods/CHESS_MOD.md` — chess

### Projects
- `docs/projects/proyecto-valdivia-luanti.md` — Valdivia 2.0 build / Arnis PR #808 notes
- `docs/projects/VALDIVIA_COORDENADAS.md` — in-game teleport points (sanitized public list)

### Web
- `docs/web/landing-page.md` — landing page architecture and deployment

### Private docs (separate repo: `infra/privado/luanti/`)
- `operations/` — deploy, backups, VPS sync, texture recovery
- `security/`, `incidents/` — security policies, past incident reports
- `architecture/` — user privileges, real-world locations, NPC registry, internal coordinates
- `credentials/` — VPS access, tokens, passwords
