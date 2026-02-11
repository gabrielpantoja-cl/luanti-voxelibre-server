---
name: deploy-verify
description: Pre-deployment verification for Wetlands server. Checks mod integrity, config consistency, and identifies potential issues before pushing to production.
disable-model-invocation: true
allowed-tools: Read, Glob, Grep, Bash(git *)
---

# Pre-Deployment Verification

Run before pushing changes to production to catch common issues.

## Verification Steps

### 1. Git Status Review

Check what files changed:
```bash
git status
git diff --stat
```

### 2. Mod Integrity Check

For each mod in `server/mods/`:
- Verify `mod.conf` exists and has required fields (name, description)
- Verify `init.lua` exists and has no obvious syntax issues
- Check that `optional_depends` is used instead of `depends`
- Verify no references to vanilla Minetest item names (`default:*`)

### 3. Config Consistency

Read `server/config/luanti.conf` and verify:
- Every mod directory has a corresponding `load_mod_*` entry
- No orphaned `load_mod_*` entries for mods that don't exist
- Critical settings preserved:
  - `creative_mode = true`
  - `enable_damage = false`
  - `enable_pvp = false`
  - `enable_tnt = false`

### 4. Texture Safety

Check docker-compose.yml volume mappings haven't changed (texture corruption prevention).

### 5. Dangerous Changes Detection

Flag if any of these changed:
- `docker-compose.yml` (volume mappings)
- `server/worlds/` (world data should not be committed)
- `.env` or credential files
- `auth.sqlite`

### 6. Report

Provide:
- **SAFE TO DEPLOY** or **ISSUES FOUND**
- List of changes summary
- Any warnings or blockers
- Suggested commit message if all clear
