# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

Vegan Wetlands is a **Luanti (formerly Minetest) game server** designed as a vegan, educational, and creative environment for children 7+ years old. The server features custom mods that promote animal care, vegan education, and non-violent gameplay through animal sanctuaries.

**IMPORTANT**: This repository (`https://github.com/gabrielpantoja-cl/Vegan-Wetlands.git`) contains **ALL** Luanti-specific code, configuration, and deployment logic. It is completely independent from the VPS administrative repository (`vps-do.git`).

## Repository Architecture Strategy

### 🎮 This Repository (Vegan-Wetlands.git)
**Responsibility**: Complete Luanti server implementation
- Docker Compose configuration for Luanti
- Custom mods (animal_sanctuary, vegan_foods, education_blocks)
- Server configuration files
- World data and backups
- Luanti-specific CI/CD pipeline
- Game logic and mechanics

### 🏗️ VPS Administrative Repository (vps-do.git)
**Responsibility**: General VPS infrastructure
- nginx reverse proxy
- n8n automation
- Portainer container management
- General VPS services coordination
- **Does NOT contain Luanti-specific files**

### Why This Separation?
1. **Modularity**: Luanti development is independent of VPS infrastructure
2. **Scalability**: Easy to add new mods without touching VPS config
3. **Collaboration**: Contributors can work on game features without VPS access
4. **Version Control**: Luanti changes are tracked separately from infrastructure
5. **Deployment**: Each repository has its own specialized CI/CD pipeline

## Key Technologies & Architecture

- **Container Platform**: Docker Compose orchestration (self-contained)
- **Game Engine**: Luanti/Minetest server (Docker image `linuxserver/luanti:latest`)
- **Configuration**: Lua-based mods and `.conf` files
- **Deployment**: GitHub Actions CI/CD with automated backups (independent pipeline)
- **Server Port**: 30000/UDP (official server: `luanti.gabrielpantoja.cl:30000`)
- **Repository Strategy**: Centralized Luanti development in this dedicated repository

## Essential Commands

### Server Management
```bash
# Start the server (recommended)
./scripts/start.sh

# Or start manually
docker-compose up -d

# View server logs
docker-compose logs -f luanti-server

# Restart server
docker-compose restart luanti-server

# Stop server
docker-compose down

# Monitor server status
docker-compose ps
```

### Backup Operations
```bash
# Manual backup
./scripts/backup.sh

# Automatic backups run every 6 hours via cron container
# Location: server/backups/
# Retention: 10 latest backups
```

### Development and Testing
```bash
# Check server health
docker-compose ps
ss -tulpn | grep :30000

# Test connection locally
# Connect Luanti client to: localhost:30000 (creative mode)

# View container logs for debugging
docker-compose logs luanti-server
docker-compose logs backup-cron
```

## Architecture Details

### File Structure
- `docker-compose.yml`: Main container orchestration
- `server/config/luanti.conf`: Server configuration (creative mode, vegan-friendly settings)
- `server/mods/`: Custom Lua mods (animal_sanctuary, vegan_foods, education_blocks)
- `server/worlds/`: Persistent world data
- `server/backups/`: Automated backup storage
- `scripts/`: Maintenance scripts (start.sh, backup.sh)

### Custom Mods Structure
All mods follow Luanti mod structure:
- `mod.conf`: Mod metadata and dependencies
- `init.lua`: Main mod logic
- `textures/`: Image assets
- `sounds/`: Audio files
- `models/`: 3D model files

**Key Mods:**
1. **animal_sanctuary**: Replaces violent mechanics with animal care (brushes instead of weapons, feeding systems, shelters)
2. **vegan_foods**: Plant-based food items (burgers, oat milk, vegan cheese)
3. **education_blocks**: Interactive educational content about veganism

### Server Configuration
- **Mode**: Creative (no damage, no PvP, no TNT)
- **Language**: Spanish (es)
- **Max Players**: 20
- **Default Privileges**: `interact,shout,home,spawn,creative`
- **World Generation**: v7 with caves, dungeons, biomes
- **Spawn Point**: 0,15,0 (static)

## Development Workflow

### ⚠️ CRITICAL: Work Only in This Repository
All Luanti-related development must happen in this repository (`Vegan-Wetlands.git`). **Never** modify Docker Compose files or Luanti configuration in the VPS administrative repository (`vps-do.git`).

### Adding New Mods
1. Create mod directory in `server/mods/`
2. Add `mod.conf` with dependencies
3. Implement Lua logic in `init.lua`
4. Add textures to `textures/` folder
5. Update `server/config/luanti.conf` with `load_mod_<name> = true`
6. Test locally with `./scripts/start.sh`
7. Commit and push to trigger automatic deployment

### Modifying Server Config
- Edit `server/config/luanti.conf` **in this repository only**
- Common settings: `creative_mode`, `enable_damage`, `max_users`
- Test changes locally before deployment
- Restart server after configuration changes

### Deployment Process
1. **Local Development**: Test changes with `./scripts/start.sh`
2. **Commit & Push**: Push to `main` branch in this repository
3. **Automatic Deployment**: GitHub Actions handles VPS deployment
4. **Verification**: Check server status and logs

### Backup and Recovery
- Backups are compressed tar.gz files of the worlds directory
- Manual restoration: extract backup to `server/worlds/`
- Automated cleanup retains only the 10 most recent backups
- **Backup location**: Managed within this repository's deployment pipeline

## Important Commands and Chat Features

### In-Game Commands
- `/santuario`: Information about animal sanctuary features
- `/veganismo`: Educational content about veganism

### Server Management Features
- New players automatically receive starter kit (brush, vegan food, medkit)
- Anti-grief protection with rollback recording
- Automatic health checks every 30 seconds
- Auto-restart on container failure

## Admin Privilege Management

### Overview
Modern Luanti servers (5.13+) use SQLite databases for user authentication and privileges instead of traditional text files. The privilege system requires direct database manipulation for administrative access.

### Database Structure
**Location**: `server/worlds/world/auth.sqlite` (mapped to `/config/.minetest/worlds/world/auth.sqlite` in container)

**Tables**:
1. **`auth`** - User authentication data
   ```sql
   CREATE TABLE `auth` (
     `id` INTEGER PRIMARY KEY AUTOINCREMENT,
     `name` TEXT UNIQUE NOT NULL,
     `password` TEXT NOT NULL,
     `last_login` INTEGER NOT NULL DEFAULT 0
   );
   ```

2. **`user_privileges`** - User privilege assignments
   ```sql
   CREATE TABLE `user_privileges` (
     `id` INTEGER,
     `privilege` TEXT,
     PRIMARY KEY (id, privilege),
     CONSTRAINT fk_id FOREIGN KEY (id) REFERENCES auth (id) ON DELETE CASCADE
   );
   ```

### Granting Admin Privileges

**Step 1: Access the container**
```bash
docker compose exec luanti-server /bin/bash
```

**Step 2: Get user ID**
```bash
sqlite3 /config/.minetest/worlds/world/auth.sqlite "SELECT id FROM auth WHERE name='username';"
```

**Step 3: Check current privileges**
```bash
sqlite3 /config/.minetest/worlds/world/auth.sqlite "SELECT * FROM user_privileges WHERE id=1;"
```

**Step 4: Grant all administrative privileges**
```bash
sqlite3 /config/.minetest/worlds/world/auth.sqlite "INSERT OR IGNORE INTO user_privileges (id, privilege) VALUES 
(1, 'server'), (1, 'privs'), (1, 'ban'), (1, 'kick'), (1, 'teleport'), 
(1, 'give'), (1, 'settime'), (1, 'worldedit'), (1, 'fly'), (1, 'fast'), 
(1, 'noclip'), (1, 'debug'), (1, 'password'), (1, 'rollback_check'), 
(1, 'basic_privs'), (1, 'bring'), (1, 'shutdown'), (1, 'time'), 
(1, 'mute'), (1, 'unban'), (1, 'creative'), (1, 'home'), (1, 'spawn');"
```

**Step 5: Restart server**
```bash
exit
docker compose restart luanti-server
```

### Key Findings
- **No `auth.txt` support**: Modern Luanti ignores traditional text-based auth files
- **SQLite only**: All authentication data stored in SQLite databases
- **Privilege storage**: Privileges stored as individual records, not comma-separated strings
- **Foreign key relationship**: `user_privileges.id` references `auth.id`
- **Container paths**: Configuration files mapped to `/config/.minetest/` in linuxserver/luanti container

### Troubleshooting
- **World selection**: Server defaults to `/config/.minetest/worlds/world/` regardless of `world_name` setting
- **Configuration mapping**: `luanti.conf` must be mapped to `/config/.minetest/minetest.conf`
- **Volume persistence**: Ensure world data is properly mapped to prevent loss of privileges on restart

## Key Constraints

- **No package.json**: This is not a Node.js project
- **No traditional build system**: Uses Docker Compose and Lua
- **No unit tests**: Game logic testing done through manual gameplay
- **Configuration via .conf files**: Not JSON/YAML config files
- **Lua-based scripting**: All mod logic written in Lua

## CI/CD Pipeline

**This repository has its own independent CI/CD pipeline** that deploys directly to the VPS without interfering with other services.

### Deployment Flow
GitHub Actions in **this repository** automatically:
1. Backs up current world state on VPS
2. Pulls latest code from `Vegan-Wetlands.git`
3. Updates Luanti containers on VPS
4. Validates server startup and connectivity
5. Can send notifications via webhooks (n8n integration available)

### Key Points
- **Independent deployment**: No dependency on vps-do.git
- **Safe updates**: Automatic backup before each deployment
- **Rollback capability**: Previous backups available if needed
- **Status monitoring**: Automated health checks post-deployment

### Repository Coordination
- **This repo (Vegan-Wetlands.git)**: Manages Luanti server lifecycle
- **VPS repo (vps-do.git)**: Manages general infrastructure (nginx, n8n, etc.)
- **No conflicts**: Each repository manages its own services independently