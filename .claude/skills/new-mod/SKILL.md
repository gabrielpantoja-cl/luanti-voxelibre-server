---
name: new-mod
description: Create a new Luanti/VoxeLibre mod for the Wetlands server. Scaffolds the mod directory with mod.conf, init.lua, and enables it in server config.
argument-hint: [mod-name]
disable-model-invocation: true
allowed-tools: Read, Edit, Write, Glob, Grep
---

# Create New Wetlands Mod

Scaffold a new mod following Wetlands project conventions.

## Critical VoxeLibre Rules

- Use `optional_depends` instead of `depends` in mod.conf
- Use VoxeLibre item names, NOT vanilla Minetest names:
  - `mcl_core:stick` (not `default:stick`)
  - `mcl_core:stone` (not `default:stone`)
  - `mcl_books:book` (not `default:book`)
  - `mcl_farming:wheat_item` (not `farming:wheat`)
- Do NOT depend on `mcl_sounds` (not available)

## Process

### 1. Gather Information

Ask the user for:
- **Mod name**: lowercase with underscores (e.g., `animal_shelter`)
- **Purpose**: What the mod does
- **Dependencies**: Which VoxeLibre APIs it needs

### 2. Create Directory Structure

Create `server/mods/$ARGUMENTS/` with:

**mod.conf**:
```ini
name = [mod_name]
title = [Mod Title]
description = [Description for Wetlands server]
author = Wetlands Team
version = 1.0.0
optional_depends = mcl_core, mcl_formspec
```

**init.lua**:
```lua
-- [Mod Title] for Wetlands Server
-- Version: 1.0.0
-- [Brief description]

local modname = minetest.get_current_modname()
local modpath = minetest.get_modpath(modname)

-- [Mod logic here]

minetest.log("action", "[" .. modname .. "] Loaded successfully")
```

### 3. Enable in Server Config

Read `server/config/luanti.conf` and add:
```
load_mod_[mod_name] = true
```

### 4. Content Guidelines (Wetlands Values)

All mods must align with Wetlands values:
- Educational and compassionate content
- Appropriate for children 7+
- No violence, no explicit content
- Promote animal care, sustainability, creativity
- Spanish language support where applicable

### 5. Provide Commit Message

```
feat(mods): Add [mod_name] - [brief purpose]

New mod for Wetlands server:
- [Key feature 1]
- [Key feature 2]
```
