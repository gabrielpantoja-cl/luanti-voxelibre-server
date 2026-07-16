# AGENTS.md

**Canonical agent instructions for this repository — the single source of truth.**
Read directly by opencode, Codex, and other AGENTS.md-aware tools, and pulled into
Claude Code via the `@AGENTS.md` import in [`CLAUDE.md`](./CLAUDE.md). **Make all shared
edits here, not in `CLAUDE.md`.** Personal, machine-local overrides (not shared) live in
`CLAUDE.local.md`.

## Project Overview

Wetlands is a **Luanti (formerly Minetest) game server** — a creative, educational, kid-friendly environment. Custom mods promote animal care and non-violent exploration, while a dedicated PvP arena exists for opt-in combat. Public address: `luanti.gabrielpantoja.cl:30000` (Wetlands) and `:30001` (Valdivia).

## Repository Scope

This repo (`luanti-voxelibre-server`) owns **all** Luanti code, config, mods, landing page, and deployment files. A separate repo, `infra/vps-oracle` (renamed from the older `vps-do`), owns host-level VPS configuration (nginx system service, Docker host, SSL). **Never** put Luanti-specific files in `vps-oracle`.

## Key Technologies

- **Runtime**: Docker Compose v2 (`docker compose`) on the VPS. Docker Compose v1 (`docker-compose`) may still be available locally; they are interchangeable here.
- **Container image**: `linuxserver/luanti:latest` — inside the container, the server user is `abc`. The image's default UID is 911, but `docker-compose.yml` overrides it via `PUID=1000 PGID=1000`, so files written by the container land on the host as UID 1000. On the Oracle VPS, UID 1000 is the `opc` account; the human SSH user `gabriel` is UID 1002, so files created by the container are **not readable** by `gabriel` unless permissions allow group/other access — and the container often creates dirs as `0700`, blocking `git pull`.
- **Base game**: VoxeLibre (MineClone2) v0.90.1 at `server/games/mineclone2/`.
- **Mod language**: Lua. No build system, no package manager, no tests — changes are validated by running the server and playing.
- **VPS**: Oracle Cloud Free Tier, ARM aarch64. SSH as `<VPS_USER>@<VPS_IP>` (a working SSH config / default key is assumed).
- **Deployment**: manual `git pull` on the VPS. There are **no GitHub Actions workflows** in this repo.
- **Ports**: 30000/UDP (Wetlands), 30001/UDP (Valdivia), 30002/UDP (GAELSIN), 30003/UDP (CTF), 80/443 (landing page via nginx on the VPS).
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
docs/                                # Public documentation (organized by world/port)
.env.local                           # Local secrets (gitignored)
```

## Configuration Hierarchy (CRITICAL)

There are two files that both list `load_mod_*` entries. Confusing which wins is the single most common source of "why doesn't my mod load" bugs.

| File | Role | Lives in git? | Edit where |
|------|------|---------------|------------|
| `server/worlds/<world>/world.mt` | **Authoritative gate** — `world.mt` **wins** whenever it has an explicit `load_mod_X` entry | No (gitignored) | On the VPS via SSH |
| `server/config/luanti-<world>.conf` | **Default only** — governs a mod **only if `world.mt` has no entry for it** | Yes | This repo |

Rules (corrected empirically 2026-06-27 when disabling `mcl_potions_hotfix`; supersedes the older 2026-04-19 `mypark` note):
- A mod loads **only if it ends up `= true`**. If `world.mt` has an explicit `load_mod_X` line, **that value wins** and the `.conf` is ignored for that mod.
- The `.conf` only acts as the default/fallback when `world.mt` has **no** `load_mod_X` entry at all. ⚠️ This means **`.conf = false` is NOT a reliable kill-switch**: if `world.mt` says `= true`, the mod loads anyway.
  - Verified: Wetlands' `original/world.mt` has no `mcl_potions_hotfix` line → `.conf = false` disabled it. GAELSIN's `gaelsin/world.mt` had `load_mod_mcl_potions_hotfix = true` → the mod loaded despite `.conf = false`; we had to flip the line in `world.mt` too.
  - **Why GAELSIN differs:** newer worlds were created by dumping every `load_mod_*` from their `.conf` into `world.mt`, so almost every mod has an explicit entry there and the `.conf` stops being a kill-switch. Wetlands is older and its `world.mt` is sparse.
- **To disable a mod with certainty, set `= false` in BOTH** the `.conf` (git) and the world's `world.mt` on the VPS (sudo; keep owner `1000:1000`, never chown `server/worlds` to the SSH user). Then restart the container.
- `luanti-<world>.conf` still pins several mods to `= false` (motorboat, biofuel, etc.) as a default, but treat that as a default, not a guarantee — confirm `world.mt` doesn't re-enable them.

To enable a NEW mod (both files must be updated):
1. Add `load_mod_<name> = true` to `server/config/luanti-original.conf` and push via git.
2. Pull on the VPS.
3. Add `load_mod_<name> = true` to the world's `world.mt` on the VPS. Since `docker-compose.yml` bind-mounts `./server/worlds` into the container, the host file at `/home/<VPS_USER>/luanti-voxelibre-server/server/worlds/original/world.mt` **is** the container file at `/config/.minetest/worlds/original/world.mt` — one edit is enough:
   ```bash
   ssh <VPS_USER>@<VPS_IP> "echo 'load_mod_<name> = true' | sudo tee -a /home/<VPS_USER>/luanti-voxelibre-server/server/worlds/original/world.mt"
   ```
4. Restart the container.

To disable a mod **reliably**: set `load_mod_<name> = false` in `luanti-original.conf` (git) **and** in the world's `world.mt` on the VPS (sudo). The `.conf` alone is **not** enough if `world.mt` has an explicit `load_mod_<name> = true` — `world.mt` wins (see the corrected hierarchy note above). Only when `world.mt` has no entry for the mod does the `.conf = false` suffice on its own.

Reference copy: `server/worlds/original/world.mt` in this repo is a local snapshot for convenience; it is gitignored and is not the file the running server reads. See `docs/00-SHARED/config/01-CONFIGURATION_HIERARCHY.md`.

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

When containers write to mounted volumes, permissions may break future host-side git operations. **DO NOT** run `chown -R` over the whole repo — it clobbers `server/worlds/` and `server/config/`, which must stay owned by the container user (set by `PUID` in `docker-compose.yml`, currently `1000` on the Oracle VPS). Scope the chown to **just the specific subdir** git is complaining about:

```bash
# Preferred: chown only the offending mod directory
ssh <VPS_USER>@<VPS_IP> "sudo chown -R <VPS_USER>:<VPS_USER> \
  /home/<VPS_USER>/luanti-voxelibre-server/server/mods/<mod_name>"
```

**If you already clobbered the wrong dirs** (symptom: `Couldn't save env meta` fatal on container start), restore container ownership:

```bash
ssh <VPS_USER>@<VPS_IP> "sudo chown -R 1000:1000 \
  /home/<VPS_USER>/luanti-voxelibre-server/server/worlds \
  /home/<VPS_USER>/luanti-voxelibre-server/server/config"
```

**Before pulling on the VPS (prevention — this is what avoids the half-applied-pull mess):**

A `git pull` that has to update any file under `server/mods/` will **abort mid-checkout** if those dirs are container-owned (`opc`), because git can't unlink/overwrite them. An aborted checkout leaves a **half-applied pull**: the new file contents are already written to disk but HEAD never advanced, so git now reports them as "local modifications" + "untracked files would be overwritten" and **every subsequent pull is blocked** until you recover by hand. The container routinely (re)creates mod dirs as `opc:opc` — sometimes `0700` — so after the server has been running a while this is the *default* failure mode, not an edge case. Pre-empt it:

```bash
# 1. See how far behind the VPS is and whether the working tree is dirty.
ssh <VPS_USER>@<VPS_IP> "cd /home/<VPS_USER>/luanti-voxelibre-server && \
  git fetch origin main && git status --short && \
  echo '--- incoming files under server/mods ---' && \
  git diff --name-only HEAD..origin/main | grep '^server/mods/'"

# 2. If the incoming range touches server/mods, pre-chown the WHOLE mods tree to gabriel
#    BEFORE pulling (not after the pull fails):
ssh <VPS_USER>@<VPS_IP> "sudo chown -R <VPS_USER>:<VPS_USER> \
  /home/<VPS_USER>/luanti-voxelibre-server/server/mods"

# 3. Now pull.
ssh <VPS_USER>@<VPS_IP> "cd /home/<VPS_USER>/luanti-voxelibre-server && git pull origin main"
```

`chown -R server/mods` to gabriel is **safe**: the container reads mods as "other" (`r-x`) and never writes inside a mod dir at runtime (per-mod state lives in the world's `mod_storage`, not the mod dir). Still **never** chown `server/worlds`. Also note the VPS is often **many commits behind**, not one — a single pull may replay several feature commits at once (e.g. a whole new world), so the touched-file set is much larger than your latest commit; don't size the chown to just your diff.

**Failed `git pull` recovery patterns:**
- *"unable to unlink old <file>: Permission denied"* — file/dir is owned by container UID 1000 (`opc`) and gabriel (UID 1002) can't write. Chown just that subdir as above (or pre-chown `server/mods` per the prevention block).
- *"Your local changes to <file> would be overwritten by merge"* / *"untracked working tree files would be overwritten"* — two flavors:
  1. **Genuine local edit on VPS**: `sudo git diff <file>` to inspect, then commit, stash, or `git checkout -- <file>` — don't force.
  2. **Half-applied prior pull**: a previous `git pull` aborted mid-merge after writing files to disk but before advancing HEAD, so git now sees the new content as "local modifications" and the new files as untracked conflicts. **Verify before discarding**: for every flagged file, confirm the on-disk content already equals the pull target —
     ```bash
     diff -q <(git show origin/main:"$f") "$f"   # silent exit 0 = identical = safe pull artifact
     ```
     If it matches origin/main, it's a pure artifact: `git restore <tracked files>` and `rm <untracked files>`, then re-pull (fast-forwards cleanly and rewrites them all). If a file does **not** match, it's genuine VPS-local work — stop and inspect, never delete it.
- Always inspect first; never `git reset --hard` or `git clean -fd` to "make it go away".

For Valdivia-specific ops (map.sqlite upload, generation, remap), see `docs/02-VALDIVIA-30001/`. **Before any offline `map.sqlite` surgery** (node remap, scan, `sqlite3` edits) `docker compose stop luanti-<world>` first, run the edit with `sudo` (world files are `1000:1000`; keep that owner), then restart — never mutate the SQLite while the container is live. Node-name remaps use the in-place, length-prefixed byte-replacement pattern in `scripts/remap-*.py` / `scripts/fix-*.py` (scan first with a read-only pass to confirm the exact stale node name before rewriting).

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

### Formspec limits: links & copyable text (Luanti-wide)
A server mod **cannot** open a URL in a player's browser: `core.open_url()` is client-only (main menu / CSM), never callable server-side by design, and `hypertext[]` only fires internal form actions — it does not open URLs. There is also **no read-only-but-copyable widget**: the only element whose text a player can select and copy is an *editable* `field[]`/`textarea[]` (so it is also deletable — labels/hypertext are not copyable in the client). For sharing a Discord/URL, the working pattern (see `valdivia_spawn_npc`) is: a **QR code** shown via `image[]` (scan with phone = one-tap open) **plus** a copyable `field[]` as fallback. Don't promise a "clickable, non-deletable" link — it's not achievable in vanilla Luanti.

### Nuclear config
An out-of-band override is applied to disable certain game rules not exposed via `luanti-original.conf`. Apply with `./scripts/apply-nuclear-config.sh`. See `docs/00-SHARED/config/02-NUCLEAR_CONFIG.md`.

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

## Multi-world architecture

| World | Container | Port | Config | Purpose |
|-------|-----------|------|--------|---------|
| Wetlands | `luanti-voxelibre-server` | 30000/UDP | `luanti-original.conf` | Main creative world — NPCs, mods, PvP arena |
| Valdivia | `luanti-valdivia-server` | 30001/UDP | `luanti-valdivia.conf` | Real-world recreation of Valdivia, Chile from OpenStreetMap (Arnis PR #808) |
| GAELSIN | `luanti-gaelsin-server` | 30002/UDP | `luanti-gaelsin.conf` | Pure VoxeLibre survival world generated from seed `GAELSIN` (mapgen v7) — PvP on, hostile mobs at night, creepers blocked, no area protection; minimal mod set |
| CTF | `luanti-ctf-server` | 30003/UDP | `luanti-ctf.conf` | Capture-the-flag con armas sobre el juego `capturetheflag` de rubenwardy (no VoxeLibre) — singlenode mapgen + `backend = dummy`, armas y rondas automaticas |

All containers share the same `server/games/` and `server/mods/` directories. Valdivia uses `singlenode` mapgen with a pre-generated `map.sqlite` (~420 MB / 1.15M mapblocks as of 2026-06-29, not in git). See `docs/02-VALDIVIA-30001/current.md`.

**CTF world uses the official `capturetheflag` game by rubenwardy, not VoxeLibre.** The mods `server/mods/wetlands_flatworld/` and `server/mods/wetlands_ctf/` are vestigial from an earlier VoxeLibre-based implementation and are **NOT loaded** in `luanti-ctf.conf` — see `docs/04-CTF-30003/index.md` for the current setup (`default_game = capturetheflag`, `mg_name = singlenode`, `backend = dummy`). Decide whether to delete them or keep them as historical reference; if kept, add a `DEPRECATED` notice at the top of each `init.lua` to prevent future confusion.

**Valdivia-only mod — `valdivia_spawn_npc`** (`load_mod_valdivia_spawn_npc = true` in `luanti-valdivia.conf` only): the spawn greeter + teleport system for Valdivia (30001). A static, immortal NPC "Guía" (skin `mcl_armor_character.b3d`) stands at spawn; right-click opens a formspec with a **Discord QR + copyable invite**, server rules, and a **context-aware teleport menu** ("Lugares") that hides whichever destination the player is already near (`HIDE_RADIUS`), making spawn↔place travel bidirectional from one list. Destinations live in `DEFAULT_LUGARES` + `worldpath/valdivia_lugares.json` (admin adds them live with `/lugar_guardar`). Two guide entities with different skins are placed with `/spawn_guia [parque]`. Commands: `/discord`, `/spawn_guia`, `/lugar_guardar`, `/lugares`. See `docs/02-VALDIVIA-30001/guia-spawn.md`. Not loaded in Wetlands/GAELSIN/CTF.

**Valdivia-only mod — `valdivia_teleporter`** (currently **disabled**, `load_mod_valdivia_teleporter = false`): the older pedestal/`/ir` teleporter. Its `DESTINOS` coordinates are stale post-Arnis; superseded by `valdivia_spawn_npc`'s teleport menu. Left in the tree for reference — do not re-enable without re-verifying coordinates in-game.

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

## AI tooling

This section inventories the AI/agent configuration that lives alongside this repo.
**Canonical location**: `.opencode/` for OpenCode-native files. **Back-compat for Claude Code**: `.claude/`.
**Single source of truth for instruction text**: this file (`AGENTS.md`), loaded automatically by OpenCode via `opencode.json` → `instructions`. Claude Code loads it via the `@AGENTS.md` import in `CLAUDE.md`.

### Skills (on-demand)

Loaded with the OpenCode `skill` tool. Discoverable by description (frontmatter `description:` field).

| Skill | Purpose |
|-------|---------|
| `lua-style` | Lua coding conventions for Wetlands mods (structure, naming, kid-friendly content rules) |
| `mod-structure` | Required mod directory structure, `luanti-original.conf`/`world.mt` enable rules, texture pitfalls |
| `voxelibre-compat` | Item name remappings, `mod.conf` gotchas, `mcl_mobs` quirks, entity migration patterns, `default_privs` trap |
| `add-music` | Add a new music disc to `wetlands-music` (download from YouTube, convert to OGG, register) |
| `add-skin` | Add or update player skins (64×32 PNG) and NPC villager textures (64×64 PNG) |

### Agents

Defined in `.opencode/agents/` (OpenCode format). Invoke by name with `@<name>` from the chat, or by description matching. Most are specialists; `wetlands-orchestrator` is the project-wide delegator.

| Agent | Purpose |
|-------|---------|
| `lua-mod-expert` | Senior Lua / VoxeLibre mod development for educational, child-friendly content |
| `wetlands-landing-page-developer` | Specialist for the `server/landing-page/` site (HTML/CSS/JS, child-friendly UX) |
| `wetlands-mod-deployment` | Deployment, CI/CD, VPS operations, Docker Compose, zero-downtime deployments |
| `wetlands-mod-testing` | Pre-commit testing, VoxeLibre compatibility checks, QA |
| `wetlands-npc-expert` | The `wetlands_npcs` mod (FSM-based AI, dual movement, missions, gestures) |
| `wetlands-orchestrator` | Project-wide delegation hub for Docker/VPS/deployment coordination |

**Equivalents in `.claude/agents/`** (legacy Claude Code location, deprecated but still discovered) keep working for Claude Code sessions. Per the project plan, `.claude/{agents,commands,skills}` are replaced by OS-detected shims that resolve to the canonical `.opencode/` content.

### Fresh-clone setup

After `git clone`, the canonical `.opencode/` tree is committed and works immediately. To make `.claude/{agents,commands,skills}/` symlinks/junctions pointing at `.opencode/` (single source of truth, no duplication):

```bash
./scripts/setup-ai-shims.sh         # Linux/macOS
```

```powershell
powershell -File .\scripts\setup-ai-shims.ps1   # Windows
```

Both scripts are idempotent (safe to re-run), back up the original directories to `.claude/<dir>.bak-<timestamp>` before replacement, and print a rollback command per shim. Run with `--dry-run` / `-DryRun` first if you're cautious.

If you skip the shim setup, both CLIs still work — `.opencode/` is canonical and `.claude/` is a tracked copy of the same content (trimmed of Claude-Code-only frontmatter). The shim just avoids the duplication.

### Commands

Slash-commands in `.opencode/commands/`. Invoke as `/<name> [arguments]`. Body uses `$ARGUMENTS` / `$1`/`$2`/`$3`.

| Command | Purpose |
|---------|---------|
| `check-server` | Check VPS container status, recent log errors, mod loads, disk, players |
| `deploy` | Pre-flight checks → push → VPS pull → restart → verify (covers the half-applied-pull pitfall) |
| `new-mod` | Scaffold a new mod or adopt a third-party one, including the world.mt step on the VPS |

### Models and data residency

- **Primary model**: `MiniMax/MiniMax-M3` (1M context, multimodal, frontier coding) via the built-in `MiniMax` provider on OpenCode's provider list.
- **Pricing tier**: paid Token Plan (pay-per-token). No fallback configured — single-model by design.
- **Provider whitelist**: `enabled_providers: ["MiniMax"]` in `opencode.json` keeps the model picker clean.
- **Data sensitivity tier for this repo**: **Tier D — code & tooling**. Public code, configs, docs. No PII in the repo. Tier A or Tier B data must not be pasted into chat sessions without explicit per-token review (none of those tiers exist in this repo today, but the rule stands in case more sensitive content lands here later).
- **`.env`**: read access is denied by default in `opencode.json`; per-machine secrets live in `.env.local` (gitignored) and `.claude/settings.local.json` (gitignored). Their `AGENTS.local.md` mirror is also gitignored.

### MCP servers

Defined in `.mcp.json` at the project root (committed):
- `context7` — upstream/up-to-date library docs lookup (no creds).
- `playwright` — local browser automation (no creds; configured via `npx @playwright/mcp`).

Credentialed servers (`github`, `google-analytics`) intentionally stay in local scope per `docs/00-SHARED/operations/MCP_SERVERS.md` — do not commit secrets.

### When you change AI tooling

1. Prefer the canonical `.opencode/` paths.
2. Drop Claude-Code-only frontmatter (`model:` alias, `allowed-tools:`, `disable-model-invocation:`, `globs:`, `argument-hint:`) — OpenCode ignores them but clutter hurts maintainability.
3. Update this section so the inventory stays truthful.

## Documentation index

Detailed docs live under `docs/`, organized by world/port. Read these when you need specifics.

### Worlds (by port)
- `docs/01-ORIGINAL-30000/` — Wetlands main creative world (port 30000)
- `docs/02-VALDIVIA-30001/current.md` — Valdivia OSM recreation (port 30001)
- `docs/03-GAELSIN-30002/` — GAELSIN survival world (port 30002)
- `docs/04-CTF-30003/` — CTF (port 30003)
- `docs/05-FUTBOL/` — Fútbol soccer (port 30004, planned)

### Shared Configuration
- `docs/00-SHARED/config/01-CONFIGURATION_HIERARCHY.md` — luanti-original.conf vs world.mt
- `docs/00-SHARED/config/02-NUCLEAR_CONFIG.md` — nuclear config (disables monsters)
- `docs/00-SHARED/config/04-VOXELIBRE_SYSTEM.md` — VoxeLibre installation
- `docs/00-SHARED/config/07-CUSTOM_SKINS.md` — custom skin system
- `docs/00-SHARED/config/08-CREATIVE_NATIVE_MODE.md` — creative mode

### Admin
- `docs/00-SHARED/admin/comandos-admin.md` — admin commands reference
- `docs/00-SHARED/admin/QUICK_ADD_SKINS.md` — adding player skins

### Operations
- `docs/00-SHARED/operations/BACKUP_STATUS.md` — backup system (**operational**): local tarballs every 12h (`backup-cron` sidecar, `sqlite3 .backup` snapshot of all 3 worlds) + daily offsite upload to **Cloudflare R2** (host cron, `~/vps-do/scripts/backup-luanti-offsite.sh`). **Golden rule:** never leave manual `.sqlite` copies inside `server/worlds/` — `backup.sh`'s `rsync` sweeps them into every tarball and inflates each R2 upload (this happened: ~2.2 GB of junk in `valdivia/`). Put one-off snapshots in `server/backups/` or outside the repo.
- `docs/00-SHARED/operations/clonar-mundo-produccion-local.md` — pull a prod backup and run it locally
- `docs/02-VALDIVIA-30001/operaciones/SERVER_LIST_DUPLICATE_BUG.md` — bug del image `linuxserver/luanti` que hardcodea `--port 30000` y duplica servidores en `servers.luanti.org` cuando se usa otro puerto; fix via bind mount del script override en `server/container-overrides/svc-luanti/run`. El bug afecta directamente al mundo Valdivia (puerto 30001) por eso vive en su carpeta de operaciones. Cualquier servidor futuro con puerto ≠ 30000 también se verá afectado.

### Mods
- `docs/00-SHARED/mods/MODDING_GUIDE.md` — general modding guide
- `docs/00-SHARED/mods/WORLDEDIT_GUIDE.md` — WorldEdit usage
- `docs/00-SHARED/mods/CHESS_MOD.md` — chess
- `docs/01-ORIGINAL-30000/pvp/PVP_ARENA_WORLDEDIT_GUIDE.md` — PvP arena + WorldEdit

### Web
- `docs/00-SHARED/web/landing-page.md` — landing page architecture and deployment

### Private docs (separate repo: `infra/privado/luanti/`)
- `operations/` — deploy, backups, VPS sync, texture recovery
- `security/`, `incidents/` — security policies, past incident reports
- `architecture/` — user privileges, real-world locations, NPC registry, internal coordinates
- `credentials/` — VPS access, tokens, passwords
