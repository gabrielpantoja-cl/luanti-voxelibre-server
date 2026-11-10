---
description: Required mod directory structure and configuration for Wetlands server
globs: server/mods/**/mod.conf, server/mods/**/init.lua
---

# Mod Structure Rules

## Required Files
Every mod in `server/mods/<name>/` must have:
1. `mod.conf` — with `name`, `description`, `optional_depends`
2. `init.lua` — main entry point

## Enabling a Mod
1. Add `load_mod_<name> = true` to `server/config/luanti-original.conf` (this repo, git tracked)
2. Add `load_mod_<name> = true` to `world.mt` on VPS (both host + container files)
3. Restart server

## Disabling a Mod
Set `load_mod_<name> = false` in BOTH `luanti-<world>.conf` and the world's `world.mt` on the VPS — an explicit `world.mt` line wins over the `.conf`, and the `.conf` alone can't enable a mod either. See AGENTS.md → Configuration Hierarchy.

## Texture Rules
- NEVER name textures with VoxeLibre base names (e.g., `mobs_mc_villager_farmer.png`)
- Use unique prefixes: `wetlands_npc_*.png`, `wetlands_music_*.png`
- NEVER modify `docker-compose.yml` volume mappings for mods (causes texture ID conflicts)
- Player skins: 64x32 PNG. Villager textures: 64x64 PNG. These are NOT interchangeable.
