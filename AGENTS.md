# AGENTS.md

**Canonical agent instructions for this repository — the single source of truth.**
Read directly by opencode, Codex, and other AGENTS.md-aware tools, and pulled into
Claude Code via the `@AGENTS.md` import in [`CLAUDE.md`](./CLAUDE.md). **Make all shared
edits here, not in `CLAUDE.md`.** Personal, machine-local overrides (not shared) live in
`CLAUDE.local.md`.

## Project Overview

Wetlands is a **Luanti (formerly Minetest) game server** — a creative, educational, kid-friendly environment. Custom mods promote animal care and non-violent exploration, while a dedicated PvP arena exists for opt-in combat. Public address: `luanti.gabrielpantoja.cl:30000` (Wetlands) and `:30001` (Valdivia).

## Repository Scope

This repo (`luanti-voxelibre-server`) owns **all** Luanti code, config, mods, landing page, and Luanti deployment files. Host-level infrastructure (nginx, Docker host, and SSL) is managed separately. **Never** put host-only infrastructure in this repository.

## Key Technologies

- **Runtime**: Docker Compose v2 (`docker compose`) on the VPS. Docker Compose v1 (`docker-compose`) may still be available locally; they are interchangeable here.
- **Container image**: `linuxserver/luanti:latest` — inside the container, the server user is `abc`. The image's default UID is 911, but `docker-compose.yml` overrides it via `PUID=1000 PGID=1000`, so files written by the container land on the host as UID 1000. On the Oracle VPS, UID 1000 is the `opc` account; the human SSH user `gabriel` is UID 1002, so files created by the container are **not readable** by `gabriel` unless permissions allow group/other access — and the container often creates dirs as `0700`, blocking `git pull`.
- **Base game**: VoxeLibre (MineClone2) v0.90.1 at `server/games/mineclone2/`.
- **Mod language**: Lua. No build system, no package manager, no tests — changes are validated by running the server and playing.
- **VPS**: Oracle Cloud Free Tier, ARM aarch64. SSH as `<VPS_USER>@<VPS_IP>` (a working SSH config / default key is assumed).
- **Deployment**: manual `git pull` on the VPS. There are **no GitHub Actions workflows** in this repo.
- **Ports**: 30000/UDP (Wetlands), 30001/UDP (Valdivia), 30002/UDP (GAELSIN), 30003/UDP (Plano), 30004/UDP (Mineclonia), 80/443 (landing page via nginx on the VPS).
- **UI language**: Spanish.

## File Structure

```
docker-compose.yml                   # Dual-service: luanti-server + luanti-valdivia
                                     # Plus backup-cron and Discord notifier sidecars
server/config/luanti-original.conf            # Wetlands authoritative config (see hierarchy below)
server/config/luanti-valdivia.conf   # Valdivia config (singlenode mapgen, no mobs)
server/games/mineclone2/             # VoxeLibre game files, shared by both worlds
server/mods/                         # Custom + third-party mods
server/worlds/original/              # LOCAL REFERENCE ONLY (gitignored, real copy is on VPS)
server/config/world-mt/              # Read-only mirror of each world's live world.mt (scripts/sync-world-mt.sh)
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
| `server/worlds/<world>/world.mt` | **The gate.** To load, a mod needs `load_mod_X = true` here. An explicit line here always wins over the `.conf` | No, the live file is gitignored. There is a read-only mirror in `server/config/world-mt/<world>.world.mt` | On the VPS via SSH (sudo) |
| `server/config/luanti-<world>.conf` | Documents intent. **Not enough to enable a mod on its own** | Yes | This repo |

Rules (verified empirically, latest correction 2026-11-10):
- **To enable a mod, `world.mt` must contain `load_mod_X = true`.** The `.conf` alone does **not** turn a mod on, even when `world.mt` has no line for that mod.
  - Verified 2026-11-10 on Plano (30003): `load_mod_wetlands_mineclonia_fixes = true` existed only in `luanti-plano.conf`, Plano's `world.mt` had no `load_mod_*` lines at all, and the mod **did not load** (the TNT + campfire crash it patches happened again). It loaded only after the line was added to `worlds/plano/world.mt`. This disproves the old "the `.conf` is the default when `world.mt` is silent" rule, at least for enabling.
- **An explicit `load_mod_X` line in `world.mt` wins**, so `.conf = false` is **not** a kill-switch either.
  - Verified 2026-06-27: GAELSIN's `world.mt` had `load_mod_mcl_potions_hotfix = true` and the mod loaded despite `.conf = false`; the line in `world.mt` had to be flipped. (In Wetlands, whose `world.mt` had no line for it, `.conf = false` appeared to be enough. Don't rely on that.)
- **Rule of thumb: always edit both.** Use the `.conf` (git) so the intent is reviewable, and `world.mt` on the VPS (sudo; keep owner `1000:1000`, never chown `server/worlds` to the SSH user) because that is what actually takes effect. Then restart the container and **confirm the load in the logs**.
- **Confirming a load:** worlds run with `debug_log_level = warning`, so a mod's `minetest.log("action", ...)` **does not show up** in `docker logs`. To see "Loaded successfully", log it at `"warning"` level (as `wetlands_mineclonia_fixes` does), or test the feature in-game.

To enable a NEW mod (both files):
1. Add `load_mod_<name> = true` to `server/config/luanti-<world>.conf` and push via git.
2. Pull on the VPS.
3. Add `load_mod_<name> = true` to the world's `world.mt` on the VPS. Since `docker-compose.yml` bind-mounts `./server/worlds` into the container, the host file at `/home/<VPS_USER>/luanti-voxelibre-server/server/worlds/<world>/world.mt` **is** the container's file. One edit is enough:
   ```bash
   ssh <VPS_USER>@<VPS_IP> "echo 'load_mod_<name> = true' | sudo tee -a /home/<VPS_USER>/luanti-voxelibre-server/server/worlds/<world>/world.mt"
   ```
4. Restart the container and verify the load in the logs.
5. Refresh the mirror: `./scripts/sync-world-mt.sh <world>` and commit `server/config/world-mt/`.

To disable a mod: `load_mod_<name> = false` in the `.conf` (git) **and** in the world's `world.mt` on the VPS, restart, then refresh the mirror.

### No inline comments in `.conf` / `world.mt`
Luanti only treats a line as a comment when it **starts** with `#` (`Settings::parseConfigObject`). In `key = 15   # note` the value is the whole string `15   # note`, so a mod's `tonumber(minetest.settings:get(...))` returns nil and **silently falls back to its default**. Found 2026-11-10: `valdivia_transeuntes_max = 15  # ...` was really running at the mod default of 40 (and `por_jugador` at 12 instead of 5). Always put the comment on its own line above the setting.

### `world.mt` mirror in the repo (`server/config/world-mt/`)

- `server/config/world-mt/<world>.world.mt` is a **read-only snapshot** of each live `world.mt` (original, valdivia, gaelsin, plano, mineclonia), refreshed with `./scripts/sync-world-mt.sh [world ...]` (requires `source .env`). Use it to see from the repo which mods each world actually loads and to diff against the `.conf`.
- **It never flows back to the VPS.** Edit the real `world.mt` over SSH, then sync the mirror. If the mirror and the `.conf` disagree, the mirror (= `world.mt`) is what the server does.
- **Why not version `server/worlds/<world>/world.mt` directly:** that path is the live, bind-mounted file. If it were tracked, every `git pull` on the VPS would overwrite it, or would get blocked because the VPS copy differs. Until 2026-11-10, `.gitignore` tracked `original/` and `valdivia/` that way, and both were stale relative to the VPS. They were untracked (`git rm --cached`, no files deleted) and the line `!server/worlds/*/world.mt` was removed from `.gitignore`.
- `server/config/world.mt` (old, from the 2025 config backup) is **not** the mirror and is not read by any server.

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

A `git pull` that has to update any file under `server/mods/` will **abort mid-checkout** if those dirs are container-owned (`opc`), because git can't unlink/overwrite them. An aborted checkout leaves a **half-applied pull**: the new file contents are already written to disk but HEAD never advanced, so git now reports them as "local modifications" + "untracked files would be overwritten" and **every subsequent pull is blocked** until you recover by hand. The container routinely (re)creates mod dirs as `opc:opc` — sometimes `0700` — so after the server has been running a while this is the *default* failure mode, not an edge case. **Even a single container restart is enough**: verified 2026-11-10, `server/mods` was chowned to the SSH user, Plano was restarted, and the next `git pull` (minutes later) failed with `unable to unlink old` because the tree was back to `opc`. Treat the pre-chown as mandatory before **every** pull that touches `server/mods`, not as a one-time fix. Pre-empt it:

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
2. Add `load_mod_<mod_name> = true` to `server/config/luanti-<world>.conf`.
3. Test locally with `./scripts/start.sh` and monitor logs.
4. Commit + push.
5. On VPS: `git pull`, then `echo 'load_mod_<mod_name> = true' | sudo tee -a server/worlds/<world>/world.mt`, then restart and confirm the load in the logs. **Skipping the world.mt step is the #1 cause of "mod files exist but items are unknown"**: `luanti-<world>.conf = true` alone does not load a mod, even if `world.mt` has no line for it (verified on Plano 2026-11-10).
6. `./scripts/sync-world-mt.sh <world>` and commit the updated mirror.

### Modifying server config
Edit `server/config/luanti-original.conf` in this repo. Push, pull on VPS, restart. Do **not** edit the `.conf` directly on the VPS — it will be overwritten on the next pull.

## Current server settings (from `server/config/luanti-original.conf`)

Wetlands is **hard survival** since 2026-07-31 (admin `gabo` keeps privileges via whitelist):

- `creative_mode = false` (and `mcl_enable_creative_mode = false`)
- `enable_damage = true`
- `enable_pvp = false` — no PvP anywhere; the `pvp_arena` opt-in arena was retired.
- `only_peaceful_mobs = false` — hostile mobs spawn at night. Creepers are blocked separately by the `wetlands_no_creeper` mod.
- `static_spawnpoint = 655.1,18.5,243.9`
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

### `player:set_hp()` with a faked `punch` reason crashes the whole server
Applying damage from a mod with `player:set_hp(hp, {type = "punch", ...})` and no `object` field **takes the server down**. VoxeLibre's `mcl_damage.from_mt` routes `type == "punch"` into `from_punch(reason, mt_reason.object)`, which does `mcl_reason.direct = object` and immediately `mcl_reason.direct:get_luaentity()` — with `object` nil that's `attempt to index field 'direct' (a nil value)` at `mcl_damage/init.lua:101`, raised inside `on_player_hpchange`, surfacing as `ServerError: AsyncErr` and a full shutdown. Found 2026-10-30: it killed Valdivia the first time armor fully absorbed a `valdivia_policia` hit, because the mod's top-up path then fired.

Use `{type = "set_hp", from = "<mod>"}` instead — `from_mt` falls through to its `generic` branch and indexes nothing. Related: a plain `object:punch(...)` often delivers **far less** than the `damage_groups` you ask for (armor soaks it, and players in gamemode `creative` take none at all), so a mod that needs a guaranteed amount must punch first and then top up with a `set_hp` carrying a safe reason.

### Custom-movement mobs: `walk_chance = 0` turns `jump = true` into a trampoline
Any mob that drives its own movement from `do_custom` sets `walk_chance = 0` so
`mcl_mobs`' FSM stops fighting the `set_velocity`. Two side effects of that combo bite:

1. **Perpetual jumping.** `mcl_mobs` calls `do_jump()` on *every* step (`api.lua:385`,
   before `do_custom`), and its bail-out is
   `if self.walk_chance ~= 0 and not (ndef and ndef.walkable) ... then return false`
   (`movement.lua:283`). With `walk_chance = 0` that `and` never holds, so the mob jumps
   with a clear path ahead and even standing still next to a player — and `do_jump()` also
   fires `set_acceleration` forward three times per jump (`minetest.after` 0.1/0.2/0.3),
   overriding gravity. It reads as the mob bouncing on a trampoline. Fix: **`jump = false`**
   (that's the first line of `do_jump`, so it's a hard off switch) and implement the jump in
   `do_custom`, only when the mob is actually stuck. `stepheight = 1.1` already climbs
   one-node steps without any jump. Found 2026-10-31 on `valdivia_policia`;
   `valdivia_transeuntes` had `jump = false` from the start for the same reason.
2. **Velocity zeroed once per second.** `do_states_stand()` does `set_velocity(0)` +
   `set_animation("stand")` + `turn_by(random)` on a 1 s timer (`api.lua:312`). `do_custom`
   runs *before* it, so every second there is one frozen tick with the animation restarted
   and the yaw kicked at random — visible as jerky walking. Fix: **`return false` from
   `do_custom`**, which cuts `on_step` right before `do_states` (`api.lua:398`). Everything
   still needed from `mcl_mobs` (gravity in `falling()`, `check_smooth_rotation`,
   head swivel, `set_animation_speed`) already ran by then.

Two freebies worth using instead of reinventing: `self:set_yaw(yaw, delay_en_ticks)` gives
eased turning via `check_smooth_rotation`, and `set_animation_speed()` already scales the
frame speed with real velocity for every mob (`frame_speed_multiplier = 1` default,
`init.lua:275`) — so only switch the frame *range*, never fight over the fps.

Two more traps in the same family, both found 2026-11-04 on `valdivia_transeuntes` (which
had `walk_chance = 0` and `jump = false` but *not* the `return false`, so it still walked
badly next to the already-fixed `valdivia_policia`):

3. **Re-sending the same frame range restarts the walk cycle.** `self.object:set_animation()`
   with an unchanged range makes the client's `setFrameLoop` jump back to the first frame, so
   calling it once per decision tick resets the stride several times a second — it reads as
   shuffling. `mcl_mobs`' own `mob_class:set_animation(name)` dedupes via `_current_animation`
   (`effects.lua:274`), but a raw `object:set_animation` bypasses that: memoize the range
   yourself and only send it on a real change. If another mod ever drives the same entity
   (e.g. `valdivia_halloween` taking over a pedestrian) it will send its own ranges, so clear
   your memo when you hand control over and when you get it back.
4. **`set_animation_speed()` normalizes by `run_velocity`, so a slow mob skates.** The formula
   is `(v / max(1, run_velocity)) * animation.walk_speed * frame_speed_multiplier`
   (`effects.lua:417`). A pedestrian at `run_velocity = 1.5` therefore gets the *full*
   `walk_speed` fps at 1.5 n/s, while the player uses the same `mcl_armor_character.b3d` at
   30 fps moving ~4.3 n/s (`mcl_player/init.lua:224`) — about 7 fps per node/second. Feet end
   up ~2.4× faster than the body. Fix with `frame_speed_multiplier = 7 * max(1, vel) /
   walk_speed`, and note it **cannot be set from the mob def**: `register_mob` hardcodes
   `frame_speed_multiplier = 1` (`init.lua:275`) instead of reading `def`, so assign it on the
   instance in `on_activate`.

Related, not an engine quirk: a mob that re-aims by picking a random one of 8 compass
directions looks drunk. Weight the "turn for no reason" roll heavily toward ±45° and keep its
probability low; reserve the big turns for when the probe says the path is actually blocked.

### `minetest.get_content_id()` on an unregistered node takes the server down
`get_content_id("mcl_core:ironbars")` doesn't return nil for an unknown name — it **raises**,
and from inside a chatcommand that surfaces as `ServerError: AsyncErr: Lua: Runtime error from
mod '' in callback on_chat_message(): "Unknown node: <name>"` and a **full shutdown**. Found
2026-11-04: `valdivia_juegos_muerte` crashed Valdivia twice in a row because the mod had
invented four node/entity names, and fixing them one crash at a time just moved the crash to
the next `get_content_id` line. The names it guessed wrong, as a reminder that VoxeLibre
spellings are not guessable:

| Guessed (wrong) | Real in VoxeLibre 0.90.1 |
|---|---|
| `mcl_core:stone_bricks` | `mcl_core:stonebrick` (no underscore, singular) |
| `mcl_core:ironbars` | `xpanes:bar_flat` (a different mod entirely) |
| `mcl_signs:sign_wall_oak` | `mcl_signs:wall_sign_oak` |
| `mcl_mobs:zombie` | `mobs_mc:zombie` (`mcl_mobs` is the API, `mobs_mc` has the mobs) |

Two rules: **verify every name against `server/games/mineclone2/` before writing it**
(`grep -rhoE 'register_node\("[a-z_]+:<thing>[a-z_]*"' mods/`), and **never call
`get_content_id` on an unvalidated name** — resolve names once in
`minetest.register_on_mods_loaded` against `minetest.registered_nodes`, keep a per-node
fallback, and disable the feature with a chat message if something is missing. Wrap the build
in a `pcall` on top. Note `minetest.add_entity` with an unknown entity is the opposite failure:
it logs a warning and returns nil, so a wrong mob name fails **silently**.

### VoxelManip skips `on_construct` — chests, signs and anything stateful break
`mcl_chests:chest` is a dummy node that swaps itself to `mcl_chests:chest_small` in
`on_construct` (that's where the 9×3 inventory and the model entity are created). Written via
`vm:set_data()` the callback never runs, so the chest stays a dead placeholder. Place such
nodes with `minetest.set_node` **after** `vm:write_to_map()`, and don't impose your own
formspec on a `mcl_chests` node — read the real inventory with `meta:get_inventory()` and
`inv:add_item()`. Same trap for `mcl_signs` (text lives on an entity spawned in `on_construct`).

### Restoring a VoxelManip region: snapshot node *names*, never content IDs
A mod that bulldozes an area must back it up first, and `limpiar`-style cleanup must restore
that backup rather than fill with air — in Valdivia (an OSM recreation of a real city) an
air-fill leaves a permanent crater where buildings were. Two gotchas: **content IDs are not
stable across restarts** (they depend on mod load order), so a backup persisted to disk has to
store node names + `param2`, not cids; and the backup has to live in the world dir
(`worldpath/<mod>_state.json`), because the built nodes survive a restart while in-RAM state
doesn't — otherwise a restart orphans the structure with no way to remove it. RLE over
(name, param2) keeps it small: a 65×9×65 region of city terrain compressed to ~1500 runs.
See `server/mods/valdivia_juegos_muerte/`.

### `diggable = false` is silently ignored in VoxeLibre
VoxeLibre's `_mcl_autogroup` rewrites **every** node on load and sets `diggable = true` unless the node is in group `unbreakable` or `indestructible` (or is a liquid). A node with only `diggable = false` **can be dug by any player** — found 2026-10-07 when players broke `valdivia_cabina` cabins. For a truly indestructible node use:
```lua
groups = {unbreakable = 1, indestructible = 1, unmovable_by_piston = 1},
diggable = false,
can_dig = function() return false end,   -- second barrier
on_blast = function() end,
```
Remove such nodes with a command/`minetest.remove_node`, not by digging.

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
A server mod **cannot** open a URL in a player's browser: `core.open_url()` is client-only (main menu / CSM), never callable server-side by design, and `hypertext[]` only fires internal form actions — it does not open URLs. There is also **no read-only-but-copyable widget**: the only element whose text a player can select and copy is an *editable* `field[]`/`textarea[]` (so it is also deletable — labels/hypertext are not copyable in the client). For sharing a Discord/URL, the working pattern is: a **QR code** shown via `image[]` (scan with phone = one-tap open) **plus** a copyable `field[]` as fallback (used by `valdivia_spawn_npc` until 2026-09-10; see git history of `tools/generate_discord_qr.py`). Don't promise a "clickable, non-deletable" link — it's not achievable in vanilla Luanti.

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

Recovery protocol for corrupted textures is maintained outside this public repository.

### Skin / texture format matrix
| Format | Size | Model | Used by | UV layout |
|--------|------|-------|---------|-----------|
| Player skin | 64×32 | `mcl_armor_character.b3d` | `server/skins/`, Star Wars NPCs | Steve/Alex (head, torso, arms, legs) |
| Villager texture | 64×64 | `mobs_mc_villager.b3d` | Classic NPCs (farmer, etc.) | Minecraft villager (robe, hat overlay, nose) |
| Minecraft skin (downloaded) | 64×64 | N/A — must convert | Source: `./scripts/fetch-skin.sh` (ver `docs/00-SHARED/mods/SKIN_SOURCES.md`) | Player skin format with **two layers** (base + overlay); both must be preserved in the 64×32 output |

**Converting a downloaded Minecraft skin to a 64×32 player skin** — the
64×64 file has **two layers**: a base layer and an overlay layer painted on
top with alpha (armor plates, helmets, capes, jackets, sleeves, trousers).
A naive `img.crop((0, 0, 64, 32))` only takes the base and silently
discards every overlay pixel — armor becomes invisible, helmets disappear,
capes vanish. The fix is to **bake the overlay onto the base** before
cropping:

- **Default, for every skin**: `python scripts/convert-skin.py <64x64.png>
  <64x32.png>`. Bakes the three right-side overlay regions (jacket, sleeve,
  trouser) onto the base before cropping — the same thing godly's Copy
  buttons do at alpha 1.0 — headless, and it prints how many overlay regions
  it actually found so you know whether a plain crop would have broken that
  skin. Legacy 64×32 inputs pass through untouched.
- **Fallback, if that output looks wrong**: drive
  <https://godly.github.io/minetest-skin-converter/> via the `playwright`
  MCP server (Copy Cape / Jacket / Trouser / Sleeve, with per-region alpha).
  Step-by-step in the [`add-skin` skill](.opencode/skills/add-skin/SKILL.md).
- **Never** `img.crop((0, 0, 64, 32))` by hand. It is only correct when the
  bottom 32 rows are fully transparent, and the converter already tells you
  when that's the case.

**Downloading skins**: `./scripts/fetch-skin.sh <fuente> <salida_64x32.png>
<original_64x64.png>` does fetch + validate + convert in one step. Prefixes:
`msn:` (minecraftskins.net), `mcs:` (mc-skins.net), `player:`/`uuid:` (Mojang
mirrors). **`minecraftskins.com` (the Skindex), namemc, planetminecraft,
skinmc, novaskin and needcoolshoes all return 403 to automated access**
(Cloudflare bot wall — a Playwright browser doesn't get through either,
verified 2026-10-30); those need a manual browser download. Always keep the
64×64 original — the 64×32 has already lost data. Full matrix:
`docs/00-SHARED/mods/SKIN_SOURCES.md`.

A documented case of the lossy crop biting us: GAELSIN `mandalorian` lost
its helmet and `diamond_armor` lost its chestplate until re-processed with
godly on 2026-07-26. The godlier version of the doc with full recipes lives
at `docs/03-GAELSIN-30002/skins.md`.

### Single source of truth for Valdivia's humanoid skins

**`server/skins/skins.json`** is the one place that records where every
Valdivia NPC skin came from (site + slug), which 64×64 original it maps to,
and which mod texture it becomes. All originals live together in
`server/skins/raw/`; **no mod keeps a `raw_skins/` directory any more** — each
mod holds only its 64×32 `textures/*.png`, which is what Luanti needs there.

```bash
python scripts/rebuild-skins.py --check   # what's stale
python scripts/rebuild-skins.py           # regenerate the 64×32 that changed
```

Covers `valdivia_transeuntes` (60), `valdivia_discoteca` (11),
`valdivia_spawn_npc` (4 guides) and `valdivia_policia` (1, `fuente: null` —
never recorded). **`wetlands_npcs` is deliberately NOT in the manifest yet**:
dual model system (64×32 humanoid + 64×64 villager), 24 originals under older
conventions, and a `tools/generate_textures.py` that *generates* villager
textures rather than converting them. Migrating it is separate work.

Why it exists: there was one converter per mod and three used the lossy crop.
**The 11 discoteca dancers and the 4 guides had silently lost their overlay
layer** — measured 2026-10-30, all 15 had real overlay (20–300 px each). They
were regenerated from the originals. Adding a skin without adding its row to
`skins.json` is how that state was reached; don't.

Details: `docs/00-SHARED/mods/SKIN_SOURCES.md`.

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
| Wetlands | `luanti-voxelibre-server` | 30000/UDP | `luanti-original.conf` | Main world — hard survival, no PvP, compassionate / plant-based identity |
| Valdivia | `luanti-valdivia-server` | 30001/UDP | `luanti-valdivia.conf` | Real-world recreation of Valdivia, Chile from OpenStreetMap (Arnis PR #808) |
| GAELSIN | `luanti-gaelsin-server` | 30002/UDP | `luanti-gaelsin.conf` | Pure VoxeLibre survival world generated from seed `GAELSIN` (mapgen v7) — PvP on, hostile mobs at night, creepers blocked, no area protection; minimal mod set |
| Plano | `luanti-plano-server` | 30003/UDP | `luanti-plano.conf` | Mundo Mineclonia **totalmente plano** — mapgen `flat` + bioma unico `Plains` (pasto / tierra / roca hasta bedrock), sin cuevas ni arboles, creativo sin dano. Reemplazo del retirado CTF (2026-09-13) |
| Mineclonia | `luanti-mineclonia-server` | 30004/UDP | `luanti-mineclonia.conf` | Mineclonia 0.123.0 (fork de VoxeLibre, no es VoxeLibre) — **modo supervivencia**, dano activo, mobs agresivos de noche, sin PvP ni fire/TNT (anti-grief), seed `mineclonia`. Mods custom: `wetlands_mineclonia_trampas` (bloque "stone-like" que al pisarlo muestra un mensaje amistoso en chat + corazones), `wetlands_contact` (`/gabo`, con respuestas desde Telegram) y `valdivia_aviso_entrada` (aviso "X joining..."). Ver `docs/05-MINECLONIA-30004/README.md`. |

All containers share the same `server/games/` and `server/mods/` directories. Valdivia uses `singlenode` mapgen with a pre-generated `map.sqlite` (~420 MB / 1.15M mapblocks as of 2026-06-29, not in git). See `docs/02-VALDIVIA-30001/current.md`. Mineclonia se sirve desde `server/games/mineclonia/` (clonado de Codeberg, ~50 MB, committeado igual que `server/games/mineclone2/`). Ver `docs/05-MINECLONIA-30004/install.md`.

**Port 30003 runs Mineclonia on a flat world, not CTF.** The `capturetheflag` game by rubenwardy was retired on 2026-09-13. The mods `server/mods/wetlands_flatworld/`, `server/mods/wetlands_ctf/` and `server/mods/ctf_guns/` are vestigial and **NOT loaded** — decide whether to delete them or add a `DEPRECATED` notice at the top of each `init.lua`.

**Flat-world mapgen (CRITICAL — `luanti-plano.conf`)**: no seed produces a flat world; it is a mapgen matter. Recipe, verified end-to-end locally on 2026-09-13: `mg_name = flat` + `mgflat_ground_level = 8` + `mgflat_spflags = nolakes,nohills` + `mg_flags = nocaves,nodungeons,nodecorations,noores,biomes,light` + `mcl_levelgen_enable_ersatz = false`, plus constant heat/humidity noise (`scale = 0`, `_blend` noises zeroed too) pinned at `(58, 39)` so the `Plains` biome wins everywhere. Measured result: grass y=8, dirt y=7..6, stone y=5..-62, deepslate y=-63..-123, bedrock y=-124..-128; ground exactly at y=8 at every sampled point out to (-3000,3000). Three traps, each hit for real:
1. `mg_flags` is applied **on top of** the defaults (`caves,dungeons,light,decorations,biomes,ores`) — anything not named keeps its default (**on**), so a flag must be killed with the `no` prefix (`noores`), not by omission.
2. Mineclonia's Lua generator **ersatz** turns itself on in any non-singlenode mapgen (`mcl_levelgen/register.lua:180`) and plants vegetation/structures through `core.register_on_generated`, **ignoring `nodecorations`** — it must be disabled explicitly or the flat world comes up carpeted in tall grass and flowers.
3. A world directory without a `world.mt` is **not** a world: Luanti 5.17 logs `World '<name>' not available` and silently boots its own internal `world`, even with `--worldname X --gameid Y` in `CLI_ARGS`. Write `world.mt` (`gameid`, `backend`, `player_backend`, `auth_backend`, `world_name`) before the first start.

⚠️ Every `mg_*` setting is frozen into `server/worlds/plano/map_meta.txt` at world creation — editing the `.conf` afterwards does nothing; regenerate the world or edit `map_meta.txt` with the container stopped. See `docs/04-PLANO-30003/index.md`.

**Valdivia-only mod — `valdivia_spawn_npc`** (`load_mod_valdivia_spawn_npc = true` in `luanti-valdivia.conf` only): the spawn greeter + teleport system for Valdivia (30001). A static, immortal NPC "Guía" (skin `mcl_armor_character.b3d`) stands at spawn; right-click opens a **talk-only** formspec: server rules, a hint that travel is done with the red Cabinas TP, and a `/gabo` help hint. Since 2026-10-07 the guide **does not teleport** (travel lives only in `valdivia_cabina`). Guides are placed with `/spawn_guia [tipo]`. No player-facing Discord in Valdivia since 2026-09-10: the QR/invite was removed and the mod unregisters `server_rules`' `/discord`; players reach the admin via `/gabo` (`wetlands_contact`), and Discord is admin-only (join/leave notifier). See `docs/02-VALDIVIA-30001/guia-spawn.md`. Not loaded in Wetlands/GAELSIN/Plano.

**Valdivia-only mod — `valdivia_cabina`** (2026-10-07): red 1×2 "Cabina TP" designed by the admin's nephew Gaspi (two nodes, 16×16 textures from `tools/generate_textures.py`), placed only by the admin (`/cabina`, `/cabina nombre`, `/cabina quitar`); each placed cabin auto-registers as a destination, and **cabins are the only destinations** (no fixed places, no `/lugar_guardar`; the menu lists the other cabins by plain name). It is also the travel core (global `valdivia_cabina`: `get_lugares`/`set_lugar`/`remove_lugar`, `show_menu`, `request` with 3 s stand-still + 30 s cooldown), reused by `valdivia_home` for go-home. Destinations persist in `worldpath/valdivia_lugares.json`. `/lugares` lists the cabins. Replaces the deleted `valdivia_teleporter` (alias `valdivia_teleporter:pad → air`). See `docs/02-VALDIVIA-30001/cabina-tp.md`.

**Valdivia-only mod — `valdivia_policia`** (2026-10-30, `load_mod_valdivia_policia = true` in `luanti-valdivia.conf` only): anti-grief consequence layered on top of `protector`. Hooks `minetest.register_on_protection_violation` (the same hook `protector` uses for the unused `protector_hurt`/`protector_flip`, so the upstream mod stays untouched) and spawns a "Carabinero" that chases the offender and shoots crossbow bolts at them. Since 2026-11-12 each chase takes **one heart in total** (`valdivia_policia_castigo = 2` HP) and the cop then leaves; non-lethal by default (`valdivia_policia_letal = 1` to allow kills). The cop **can be killed** (`valdivia_policia_vida = 20`; normal players are in survival via `valdivia_newplayer`; `do_punch` only bypasses `mcl_mobs`' creative one-hit kill for creative-gamemode hitters, i.e. the admin), drops nothing, one cop per offender with a 60 s cooldown and a global cap of 3. Movement is custom `set_velocity` with `walk_chance = 0` (same pattern as `wetlands_npcs`), and the anti-stuck rule **relocates** the cop near the player instead of pathfinding — `mcl_mobs`' A* gets stuck in Arnis' dense city blocks. Since 2026-10-31 the gait is smoothed (section `4bis` of its `init.lua`): `jump = false` + own stuck-only jump, `do_custom` returns `false`, acceleration ramp of 9 n/s², and speed gears run → trot → walk → stop at 2 nodes with hysteresis (see the `walk_chance = 0` pitfall above). The cop stores a `_vence` timestamp and deletes itself in `on_activate` if it has no live target, so a SIGKILL mid-chase can't leave orphans in the map. Admin: `/policia [player]`, `/policia_limpiar`. See `server/mods/valdivia_policia/README.md`.

**Valdivia-only mod — `valdivia_transeuntes`** (2026-10-30, `load_mod_valdivia_transeuntes = true` in `luanti-valdivia.conf` only): background pedestrians walking the city streets — six types (`vecino`, `escolar`, `estudiante`, `feriante`, `pescador`, `turista`), two skins each, a random Chilean first name, and one chat line per type on right-click. Immortal, ephemeral (`static_save = false`), no quests, no formspec. **They are seeded automatically**, not hand-placed: a single 5 s `globalstep` spawns up to 5 per player (half at night, global cap 15) at 30–45 nodes, only where `line_of_sight` from the player is false, and deletes them past 70 nodes from everyone. Nothing persists, so a SIGKILL leaves no orphans and there is no roster to reconcile. **Navigation is probe-based, not A\*** (same reason as `valdivia_policia`): each walker sondea 1.6 nodes ahead and takes the smallest valid turn, where "valid" means walkable non-liquid floor + 2 air + `minetest.get_natural_light(p, 0.5) >= 14`. That light test with a **fixed noon timeofday** is what keeps them out of buildings at any hour — it asks "is there sky above?", not "what time is it?". Seeding adds two more filters: solid ground 2–4 nodes below (a flat roof passes the street test but is hollow underneath) and ≥3 of 4 orthogonal neighbours also being street (kills one-node patios and the riverbank). `jump = false` so they can never climb onto a roof. Admin: `/transeunte [tipo]`, `/transeuntes [info|limpiar]`, `/transeunte_scan` (calibration — prints why a spot is or isn't street). See `server/mods/valdivia_transeuntes/README.md` and `docs/02-VALDIVIA-30001/transeuntes.md`.

**Valdivia-only mod — `valdivia_hotel_cartel`** (2026-11-02, `load_mod_valdivia_hotel_cartel = true` en `luanti-valdivia.conf` only): mega cartel directorio del Hotel Dreams — mural de **6×4 nodos** en la planta baja con los 15 pisos (qué hay en cada uno, cuáles están reservados). Lo coloca el admin con `/cartel` (orientado hacia él, con chequeo previo de las 24 celdas: si alguna está ocupada **no coloca nada**), se saca con `/cartel quitar`, y `/pisos` lo abre como formspec para cualquier jugador. Los pisos viven en `pisos.json` — **fuente única** que leen tanto `init.lua` (formspec) como `tools/generate_cartel.py`, que dibuja una lámina de 1536×1024 y la trocea en 24 texturas de 256×256, una por nodo (16×16 no da para texto legible). Mosaicos indestructibles (`unbreakable`/`indestructible` + `can_dig` + `on_blast`, el pitfall de `diggable = false`). **No se hizo dentro de `celevator` porque no se puede**: el PI del ascensor es un display de 16 segmentos de **3 caracteres** (`celevator.pi.settext()` → `string.sub(text,1,3)`, `pilantern.lua:132`), y el `floorname` del controlador alimenta justamente ese display. Ver `docs/02-VALDIVIA-30001/hotel-dreams-cartel.md`.

**Mineclonia-only mod — `wetlands_mineclonia_trampas`** (`load_mod_wetlands_mineclonia_trampas = true` in `luanti-mineclonia.conf` only): a single node `wetlands_mineclonia_trampas:secret_heart` that looks identical to `mcl_core:stone` (so it can be hidden), but when a player stands on it shows a hard-coded chat message ("ME ENCANTA JUGAR CONTIGO ❤️") + heart particles. No damage, no knockback — purely a friendly surprise compatible with survival mode. Detection is via `core.register_globalstep` polling (Luanti 5.14+ removed the `on_stand` node callback that vanilla pressure plates used to use). Per-player 5-second cooldown. **Mineclonia-only** by config; not loaded in Wetlands/Valdivia/GAELSIN/Plano. See `docs/05-MINECLONIA-30004/README.md`.

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
| `wetlands_contact` | `/gabo <message>` → direct HTTPS to the admin's Telegram bot or Discord webhook (no bridge). Rate-limited, child-safety filters, blinking HUD hint on join; player strings in **English** with `locale/*.es.tr` (international audience — exception to the Spanish-UI rule). Needs `secure.http_mods` + an out-of-git `worlds/original/wetlands_contact.conf`. See its `README.md` |
| `mcl_back_to_spawn` | `/back_to_spawn` teleport |
| `server_rules` | `/reglas` command, broadcast announcements |
| `pvp_arena` | PvP arena system — the only place PvP is allowed |
| `mcl_custom_world_skins` | Custom player skin selector |
| `protector` | Protector Redo (TenPlus1, upstream 2026-07-19): place a block to protect a cube (radius 20, area grid shown 20 s), right-click shows the area and adds members; spawn protected within 20 nodes. Replaced the command-based `voxelibre_protection` (disabled) on 2026-09-16 |
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

Defined in `.opencode/agents/` (OpenCode format). Invoke by name with `@<name>` from the chat, or by description matching. **`orchestrator` is the PRIMARY default agent** (set via `default_agent` in `opencode.json`); all other custom agents are `mode: subagent` and only invokable via `@<name>` or task delegation.

| Agent | Mode | Purpose |
|-------|------|---------|
| `orchestrator` | **primary** | **Default agent** — coordinates Docker/VPS/deployment, delegates to specialists |
| `lua-mod-expert` | subagent | Senior Lua / VoxeLibre mod development for educational, child-friendly content |
| `wetlands-landing-page-developer` | subagent | Specialist for the `server/landing-page/` site (HTML/CSS/JS, child-friendly UX) |
| `wetlands-mod-deployment` | subagent | Deployment, CI/CD, VPS operations, Docker Compose, zero-downtime deployments |
| `wetlands-mod-testing` | subagent | Pre-commit testing, VoxeLibre compatibility checks, QA |
| `wetlands-npc-expert` | subagent | The `wetlands_npcs` mod (FSM-based AI, dual movement, missions, gestures) |

Use `@build` for git operations (commit/push/super-commit) and `@plan` for pure planning sessions.

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

- **Primary model**: `openai/gpt-5.6-luna` via ChatGPT Plus/Pro OAuth.
- **Pricing tier**: ChatGPT Plus subscription. No fallback configured, single-model by design.
- **Provider whitelist**: `enabled_providers: ["openai"]` in `opencode.json` keeps the model picker clean.
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
Each world folder has a `ROADMAP.md` (single list of pending work, same checklist format); cross-world priorities live in the root `ROADMAP.md`.
- `docs/01-ORIGINAL-30000/` — Wetlands main world, hard survival without PvP (port 30000)
- `docs/02-VALDIVIA-30001/current.md` — Valdivia OSM recreation (port 30001); pending work lives in `docs/02-VALDIVIA-30001/ROADMAP.md`, area protection (two coexisting mods) in `proteccion.md`
- `docs/03-GAELSIN-30002/` — GAELSIN survival world (port 30002)
- `docs/04-PLANO-30003/` — Plano, mundo Mineclonia plano (port 30003) — antes CTF, retirado 2026-09-13
- `docs/05-MINECLONIA-30004/` — Mineclonia supervivencia (port 30004) — antes planeado como `05-FUTBOL/`, redefinido 2026-08-01 a Mineclonia (fork de VoxeLibre).

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
- `docs/00-SHARED/operations/BACKUP_STATUS.md` — public backup architecture and safety notes. Host-specific credentials, paths, remotes, retention details, and recovery commands are maintained outside this repository. **Golden rule:** never leave manual `.sqlite` copies inside `server/worlds/` — `backup.sh`'s `rsync` sweeps them into every tarball and inflates each upload. Put one-off snapshots in `server/backups/` or outside the repo.
- `docs/00-SHARED/operations/clonar-mundo-produccion-local.md` — pull a prod backup and run it locally
- `docs/02-VALDIVIA-30001/operations/SERVER_LIST_DUPLICATE_BUG.md` — bug del image `linuxserver/luanti` que hardcodea `--port 30000` y duplica servidores en `servers.luanti.org` cuando se usa otro puerto; fix via bind mount del script override en `server/container-overrides/svc-luanti/run`. El bug afecta directamente al mundo Valdivia (puerto 30001) por eso vive en su carpeta de operaciones. Cualquier servidor futuro con puerto ≠ 30000 también se verá afectado.

### Mods
- `docs/00-SHARED/mods/MODDING_GUIDE.md` — general modding guide
- `docs/00-SHARED/mods/SKIN_SOURCES.md` — qué sitios de skins se pueden automatizar y cuáles bloquean (403), `fetch-skin.sh`, conversión 64×64 → 64×32
- `docs/00-SHARED/mods/WORLDEDIT_GUIDE.md` — WorldEdit usage
- `docs/00-SHARED/mods/CHESS_MOD.md` — chess
- `docs/01-ORIGINAL-30000/pvp/PVP_ARENA_WORLDEDIT_GUIDE.md` — PvP arena + WorldEdit

### Web
- `docs/00-SHARED/web/landing-page.md` — landing page architecture and deployment

### Operational documentation boundary
- Host-specific deploy, backup, VPS sync, texture recovery, security, incident, privilege, and internal-location runbooks are intentionally maintained outside this public repository.
- This repository contains only reproducible development guidance and sanitized public architecture notes. Never add credentials, private paths, player records, or production-world data here.
