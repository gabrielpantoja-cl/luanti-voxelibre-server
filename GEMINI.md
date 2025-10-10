# GEMINI.md

This file provides specific guidance to Google Gemini when working with code in this repository.

## Project Overview

Vegan Wetlands is a **Luanti (formerly Minetest) game server** designed as a compassionate, educational, and creative environment for children 7+ years old. The server features custom mods that promote animal care, compassionate education, and non-violent gameplay through animal sanctuaries.

**IMPORTANT**: This repository (`https://github.com/gabrielpantoja-cl/luanti-voxelibre-server.git`) contains **ALL** Luanti-specific code, configuration, and deployment logic. It is completely independent from the VPS administrative repository (`vps-do.git`).

## 🚨 CRITICAL: Texture Corruption Prevention & Recovery Protocol

### **⚠️ GOLDEN RULES - NEVER BREAK THESE:**

1.  **🚫 NEVER modify `docker-compose.yml` to map mods directly.**
    ```yaml
    # ❌ THIS CORRUPTS TEXTURES:
    volumes:
      - ./server/mods/new_mod:/config/.minetest/games/mineclone2/mods/MISC/new_mod
    ```
    VoxeLibre's texture system is fragile. Mapping mods this way causes cascading and persistent texture ID conflicts.

2.  **🚫 NEVER install mods with known texture dependencies.**
    - Mods like `motorboat`, `biofuel`, `mobkit` are known to cause complete texture corruption.
    - Always test new mods in a local, isolated environment first.

3.  **✅ ALWAYS create a world backup before making any mod-related changes.**

### **🛠️ Emergency Texture Recovery Protocol**

**Symptoms of Corruption:**
- All blocks display the same incorrect texture.
- Missing textures (pink/black checkerboard pattern).
- Texture loading errors appear in server logs.
- Players report widespread visual glitches.

**IMMEDIATE RECOVERY STEPS:**

```bash
# STEP 1: EMERGENCY WORLD BACKUP (CRITICAL!)
ssh gabriel@167.172.251.27 "cd /home/gabriel/luanti-voxelibre-server && du -sh server/worlds/* && cp -r server/worlds server/worlds_EMERGENCY_BACKUP_$(date +%Y%m%d_%H%M%S)"

# STEP 2: REVERT PROBLEMATIC CHANGES
ssh gabriel@167.172.251.27 "cd /home/gabriel/luanti-voxelibre-server && git reset --hard HEAD~1"

# STEP 3: CLEAN CONTAINER STATE COMPLETELY
ssh gabriel@167.172.251.27 "cd /home/gabriel/luanti-voxelibre-server && docker-compose down && docker system prune -f"

# STEP 4: REMOVE CORRUPTED VOXELIBRE GAME FILES
ssh gabriel@167.172.251.27 "cd /home/gabriel/luanti-voxelibre-server && rm -rf server/games/mineclone2 && rm -f voxelibre.zip"

# STEP 5: DOWNLOAD FRESH VOXELIBRE (56MB)
ssh gabriel@167.172.251.27 "cd /home/gabriel/luanti-voxelibre-server && wget https://content.luanti.org/packages/Wuzzy/mineclone2/releases/32301/download/ -O voxelibre.zip && unzip voxelibre.zip -d server/games/ && mv server/games/mineclone2-* server/games/mineclone2"

# STEP 6: RESTART WITH A CLEAN STATE
ssh gabriel@167.172.251.27 "cd /home/gabriel/luanti-voxelibre-server && docker-compose up -d"

# STEP 7: VERIFY RECOVERY
ssh gabriel@167.172.251.27 "cd /home/gabriel/luanti-voxelibre-server && sleep 10 && docker-compose ps && du -sh server/worlds/world"
```

### **📊 Recovery Success Metrics (Last: Sep 9, 2025)**
- ✅ World data preserved (174MB intact).
- ✅ All blocks display correct textures.
- ✅ Server stable on port 30000.
- ✅ No dependency errors in logs.
- ✅ Players can connect normally.
- **Recovery Time**: ~3 minutes.
- **Data Loss**: Zero.

## Repository Architecture

### 🎮 This Repository (luanti-voxelibre-server.git)
**Responsibility**: Complete Luanti server implementation.
- Docker Compose configuration for Luanti.
- Custom mods (`animal_sanctuary`, `vegan_food`, `education_blocks`).
- Server configuration files (`luanti.conf`).
- World data and backups.
- **Landing page development** (HTML/CSS/JS for `luanti.gabrielpantoja.cl`).
- Luanti-specific CI/CD pipeline.
- Game logic and mechanics.

### 🏗️ VPS Administrative Repository (vps-do.git)
**Responsibility**: General VPS infrastructure.
- Nginx reverse proxy.
- n8n automation.
- Portainer container management.
- **Does NOT contain any Luanti-specific files.**

## Server Access

```bash
# SSH access to the production server
ssh gabriel@167.172.251.27
```

## Essential Commands

### Server Management
```bash
# Start the server (recommended method)
./scripts/start.sh

# Or start manually
docker-compose up -d

# View server logs in real-time
docker-compose logs -f luanti-server

# Restart the server
docker-compose restart luanti-server

# Stop the server
docker-compose down

# Monitor the status of server containers
docker-compose ps
```

### Backup Operations
```bash
# Perform a manual backup
./scripts/backup.sh

# Automatic backups run every 6 hours via a cron container.
# Location: server/backups/
# Retention: The 10 most recent backups are kept.
```

### Landing Page Deployment
```bash
# Deploy the landing page to the VPS
./scripts/deploy-landing.sh
```

## Modern Authentication System (SQLite)

Luanti 5.13+ uses an **SQLite database (`auth.sqlite`)** for authentication, not `auth.txt`.

**Location**: `server/worlds/world/auth.sqlite`

### Useful Database Commands
```bash
# List all registered users
docker-compose exec -T luanti-server sqlite3 /config/.minetest/worlds/world/auth.sqlite 'SELECT name FROM auth;'

# Get the ID of a specific user
docker-compose exec -T luanti-server sqlite3 /config/.minetest/worlds/world/auth.sqlite 'SELECT id FROM auth WHERE name="USERNAME";'

# View the privileges of a specific user (replace ID)
docker-compose exec -T luanti-server sqlite3 /config/.minetest/worlds/world/auth.sqlite 'SELECT * FROM user_privileges WHERE id=USER_ID;'

# Grant all admin privileges to a user (replace USER_ID)
docker-compose exec -T luanti-server sqlite3 /config/.minetest/worlds/world/auth.sqlite "INSERT OR IGNORE INTO user_privileges (id, privilege) VALUES (USER_ID, 'server'), (USER_ID, 'privs'), (USER_ID, 'ban'), (USER_ID, 'kick'), (USER_ID, 'teleport'), (USER_ID, 'give'), (USER_ID, 'settime'), (USER_ID, 'worldedit'), (USER_ID, 'fly'), (USER_ID, 'fast'), (USER_ID, 'noclip'), (USER_ID, 'debug'), (USER_ID, 'password'), (USER_ID, 'rollback_check'), (USER_ID, 'basic_privs'), (USER_ID, 'bring'), (USER_ID, 'shutdown'), (USER_ID, 'time'), (USER_ID, 'mute'), (USER_ID, 'unban'), (USER_ID, 'creative'), (USER_ID, 'home'), (USER_ID, 'spawn');"
```

## VoxeLibre Mod System & Troubleshooting

### Mod Directory Structure
VoxeLibre has a specific loading order:
1.  `/config/.minetest/mods/` (High priority, for custom server mods)
2.  `/config/.minetest/games/mineclone2/mods/` (Low priority, for base game mods)

### Common Mod Issues & Solutions

**Issue: Custom commands like `/santuario` are not working.**
- **Cause**: Mod conflicts or dependency issues with VoxeLibre.
- **Solution**:
    1.  Ensure the mod's `mod.conf` lists dependencies as `optional_depends` (e.g., `optional_depends = mcl_core, mcl_farming`) instead of `depends`.
    2.  Replace vanilla Minetest item names in `init.lua` with their VoxeLibre equivalents.

**VoxeLibre Item Equivalents:**
| Minetest Vanilla | VoxeLibre Equivalent |
| :--- | :--- |
| `default:book` | `mcl_books:book` |
| `default:stick` | `mcl_core:stick` |
| `farming:wheat` | `mcl_farming:wheat_item` |
| `default:stone` | `mcl_core:stone` |
| `mcl_sounds` | ❌ **Remove dependency** |

**Emergency Mod Recovery:**
If a mod breaks the server:
```bash
# 1. Check logs for the specific error
docker-compose logs luanti-server | grep -i "error"

# 2. Temporarily disable the problematic mod
mv server/mods/problematic_mod server/mods/problematic_mod.disabled

# 3. Restart the server
docker-compose restart luanti-server
```

## In-Game Commands & Features

- `/santuario`: Information about animal sanctuary features.
- `/filosofia`: Educational content on the game's philosophy.
- `/sit`: Sit down at the current position.
- `/lay`: Lie down on grass or flower blocks.
- **Beds**: Sleeping in a bed sets your personal respawn point.

## Server Configuration
- **Mode**: Creative (no damage, no PvP, no TNT).
- **Language**: Spanish (`es`).
- **Max Players**: 20.
- **Default Privileges**: `interact,shout,home,spawn,creative`.
- **World Generation**: v7 with caves, dungeons, biomas.
- **Spawn Point**: 0, 15, 0 (static).

## Third-Party Content

### 🌱 Vegan Food Mod
- **Source**: [vegan_food by Daenvil](https://content.luanti.org/packages/Daenvil/vegan_food/)
- **License**: GPL v3.0 (code) / CC BY-SA 4.0 (textures)
- **Integration**: Provides plant-based food items for the starter kit.

## Project Constraints
- **No `package.json`**: This is not a Node.js project.
- **No traditional build system**: Uses Docker Compose and Lua scripting.
- **No unit tests**: Testing is performed manually through gameplay.
- **Configuration via `.conf` files**: Not JSON or YAML.
- **Scripting in Lua**: All mod logic is written in Lua.

---

## Historical Discovery Process: Authentication System

### Context
This document previously detailed the investigation process Gemini undertook to resolve a discrepancy in the server's user management system.

### Key Discovery
- **Problem**: Users were not appearing in the expected `auth.txt` file.
- **Solution**: The server uses a modern **SQLite database (`auth.sqlite`)** for authentication, not flat text files.
- **Source**: This was confirmed by inspecting the `docs/NUCLEAR_CONFIG_OVERRIDE.md` file and observing the server's runtime behavior.
- **Outcome**: The modern SQLite-based authentication system was correctly identified and documented.

This historical knowledge has been integrated into the main documentation above.