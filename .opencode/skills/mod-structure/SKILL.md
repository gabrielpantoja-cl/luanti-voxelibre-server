---
name: mod-structure
description: Required mod directory structure and configuration for the Wetlands server. Use when creating or adopting mods in server/mods/<name>/, when wiring up load_mod_* in luanti-original.conf, or when debugging texture/skin issues from wrong volume mounts.
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
Set `load_mod_<name> = false` in `luanti-original.conf` — overrides `world.mt` regardless.

## Texture Rules
- NEVER name textures with VoxeLibre base names (e.g., `mobs_mc_villager_farmer.png`)
- Use unique prefixes: `wetlands_npc_*.png`, `wetlands_music_*.png`
- NEVER modify `docker-compose.yml` volume mappings for mods (causes texture ID conflicts)
- Player skins: 64x32 PNG. Villager textures: 64x64 PNG. These are NOT interchangeable.
