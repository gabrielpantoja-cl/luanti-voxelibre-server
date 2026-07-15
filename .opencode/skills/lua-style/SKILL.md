---
name: lua-style
description: Lua coding conventions for Wetlands mods. Use when writing or reviewing any .lua file under server/mods/ — covers structure (modname = current_modname()), naming (snake_case modules, UPPER_SNAKE_CASE constants), and content rules (kid-friendly, Spanish-first, no violence).
---

# Lua Style for Wetlands Mods

## Structure
- Start with `local modname = minetest.get_current_modname()`
- End with `minetest.log("action", "[" .. modname .. "] Loaded successfully")`
- Use local variables wherever possible

## Naming
- Mod directories: `snake_case` (e.g., `wetlands_npcs`)
- Functions: `snake_case`
- Constants: `UPPER_SNAKE_CASE`
- Prefix mod-specific globals with mod name

## Content Guidelines
- All content appropriate for children 7+
- No violence, no explicit content
- Spanish language for user-facing text
- Promote compassion, education, creativity
