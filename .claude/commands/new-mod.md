---
name: new-mod
description: Scaffold a new Luanti/VoxeLibre mod for the Wetlands server with mod.conf, init.lua, and config entry.
argument-hint: <mod-name>
allowed-tools: Read, Edit, Write, Glob, Grep
---

# Create New Wetlands Mod: $ARGUMENTS

Scaffold a new mod following Wetlands project conventions.

## VoxeLibre Rules (CRITICAL)

- Use `optional_depends` instead of `depends` in mod.conf
- Use VoxeLibre item names, NOT vanilla Minetest:
  - `mcl_core:stick` (not `default:stick`)
  - `mcl_core:stone` (not `default:stone`)
  - `mcl_books:book` (not `default:book`)
  - `mcl_farming:wheat_item` (not `farming:wheat`)
- Do NOT depend on `mcl_sounds`

## Step 1: Gather Info

If `$ARGUMENTS` is empty, ask the user for a mod name (lowercase, underscores).
Ask for the mod's purpose and which VoxeLibre APIs it needs.

## Step 2: Create Files

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

## Step 3: Enable in Config

Add `load_mod_$ARGUMENTS = true` to `server/config/luanti.conf`.

## Step 4: Content Guidelines

All content must be:
- Educational and compassionate
- Appropriate for children 7+
- No violence or explicit content
- Spanish language support where applicable
