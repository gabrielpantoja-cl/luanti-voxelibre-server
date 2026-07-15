---
name: new-mod
description: Scaffold a new Luanti/VoxeLibre mod for the Wetlands server, or adopt a third-party one. Handles mod.conf, init.lua, luanti-original.conf entry, and documents the required world.mt step on the VPS.
---

# Create or Adopt a Wetlands Mod: $ARGUMENTS

Two paths:

- **Scaffold from scratch** — new custom mod (default when `$ARGUMENTS` is a snake_case name that doesn't exist yet).
- **Adopt third-party** — `git clone` an upstream mod (e.g. from ContentDB/GitHub) into `server/mods/<name>/` without its `.git`. Validate compat before enabling.

Ask which path if unclear.

## VoxeLibre Rules (CRITICAL)

- Use `optional_depends` instead of `depends` in `mod.conf` — `depends` on missing mods blocks load.
- Use VoxeLibre item names, NOT vanilla Minetest:
  - `mcl_core:stick` (not `default:stick`)
  - `mcl_core:stone` (not `default:stone`)
  - `mcl_books:book` (not `default:book`)
  - `mcl_farming:wheat_item` (not `farming:wheat`)
- Do NOT depend on `mcl_sounds` — it doesn't exist in this VoxeLibre version.
- For mobs/NPCs: `mcl_mobs` expects `hp_min`/`hp_max` inside `initial_properties = {}`, and uses `do_punch` (not `on_punch`) for custom punch handlers.
- Texture/node names must be prefixed with the mod name — never reuse VoxeLibre base names like `mobs_mc_*`.

## Path A — Scaffold new mod

### Step 1: Gather Info

If `$ARGUMENTS` is empty, ask the user for a mod name (lowercase, underscores). Ask for the mod's purpose and which VoxeLibre APIs it needs.

### Step 2: Create Files

Create `server/mods/$ARGUMENTS/`:

**mod.conf**:
```ini
name = $ARGUMENTS
title = [Title]
description = [Description] for Wetlands server
author = Wetlands Team
version = 1.0.0
optional_depends = mcl_core
```

**init.lua**:
```lua
local modname = minetest.get_current_modname()
local modpath = minetest.get_modpath(modname)

-- [Mod logic here]

minetest.log("action", "[" .. modname .. "] Loaded successfully")
```

## Path B — Adopt third-party mod

### Step 1: Research compatibility

Before cloning, verify upstream:
- License permits redistribution (MIT, CC0, GPL, etc.)
- No `depends = default` or `depends = mcl_sounds`
- Texture/node names use a unique prefix
- Works in VoxeLibre (or at minimum doesn't reference vanilla Minetest namespaces)

### Step 2: Clone without git history

```bash
cd /home/gabriel/Developer/personal/luanti-voxelibre-server/server/mods
git clone --depth 1 <upstream-url> $ARGUMENTS
rm -rf $ARGUMENTS/.git
```

### Step 3: Audit

- Read `init.lua` — confirm no `default:*` references.
- Read `mod.conf` — confirm no hard `depends` on missing mods.
- List `textures/` — confirm prefixes don't collide with VoxeLibre (no `mobs_mc_*`, etc.).
- If groups like `choppy`/`oddly_breakable_by_hand` are used (Minetest Game), note that survival-mode tools may not match VoxeLibre's (`handy`/`pickaxey`). Creative mode is unaffected.

## Step 3 (common): Enable in luanti-original.conf

Add to `server/config/luanti-original.conf`, in the appropriate themed section (decoration, transport, etc.), with a short comment explaining what the mod does and its license:

```
load_mod_$ARGUMENTS = true  # [what it adds] ([upstream], [license])
```

## Step 4 (common): Test locally

```bash
./scripts/start.sh                    # docker compose up -d
docker compose logs -f luanti-server  # watch for errors
```

Join at `localhost:30000` and `/giveme $ARGUMENTS:<item>` to confirm registration.

## Step 5 (common): Deploy + **world.mt on VPS** (CRITICAL)

After committing and pushing:

```bash
ssh <VPS_USER>@<VPS_IP> "cd /home/<VPS_USER>/luanti-voxelibre-server && git pull origin main"

# REQUIRED: a mod must be listed in world.mt to register.
# luanti-original.conf = true alone is NOT sufficient — verified 2026-04-19 with mypark.
ssh <VPS_USER>@<VPS_IP> "echo 'load_mod_$ARGUMENTS = true' | sudo tee -a /home/<VPS_USER>/luanti-voxelibre-server/server/worlds/world/world.mt"

ssh <VPS_USER>@<VPS_IP> "cd /home/<VPS_USER>/luanti-voxelibre-server && docker compose restart luanti-server"
```

Verify in-game with `/giveme $ARGUMENTS:<item>`.

## Step 6: Content Guidelines

All content must be:
- Educational and compassionate
- Appropriate for children 7+
- No violence or explicit content
- Spanish language support where applicable

## Common failure: "unknown item" after deploy

If `/giveme $ARGUMENTS:<item>` returns "unknown item" in production:
1. Check `world.mt` on the VPS: `ssh <VPS_USER>@<VPS_IP> "grep $ARGUMENTS /home/<VPS_USER>/luanti-voxelibre-server/server/worlds/world/world.mt"` — if empty, add the line (Step 5) and restart.
2. Check container mount: `ssh <VPS_USER>@<VPS_IP> "docker exec luanti-voxelibre-server ls /config/.minetest/mods/$ARGUMENTS/"` — if missing, the `git pull` didn't include the mod.
3. Check `docker logs --since='2m' luanti-voxelibre-server | grep $ARGUMENTS` for load errors.
