---
name: voxelibre-compat
description: VoxeLibre compatibility rules — item name remappings, mod.conf gotchas, mcl_mobs quirks, entity migration patterns, and the default_privs trap. Use when writing any Lua for this server, debugging "unknown item", NPC immortality issues, or after renaming mods.
---

# VoxeLibre Compatibility

## Item Names (NEVER use vanilla Minetest names)
| Vanilla (WRONG)      | VoxeLibre (CORRECT)          |
|----------------------|------------------------------|
| `default:book`       | `mcl_books:book`             |
| `default:stick`      | `mcl_core:stick`             |
| `default:apple`      | `mcl_core:apple`             |
| `default:stone`      | `mcl_core:stone`             |
| `farming:wheat`      | `mcl_farming:wheat_item`     |

## mod.conf
- Use `optional_depends`, NEVER `depends`
- Do NOT depend on `mcl_sounds` (not available)

## mcl_mobs
- Put `hp_min`/`hp_max` inside `initial_properties = {}`, NOT at root level
- `on_punch` does NOT make NPCs immortal. Use `self.object:set_armor_groups({immortal = 1})` in `on_activate`
- Use `do_punch` (not `on_punch`) for custom punch handlers — mcl_mobs only copies `do_punch`

## Entity Migration
When renaming/deleting mods, register lightweight legacy entities with `:old_mod:entity` prefix that auto-replace on activation.

## default_privs
VoxeLibre ignores `default_privs` in minetest.conf. Use the `wetlands_newplayer` mod's `minetest.register_on_newplayer()` instead.
