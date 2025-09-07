# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

Vegan Wetlands is a **Luanti (formerly Minetest) game server** designed as a compassionate, educational, and creative environment for children 7+ years old. The server features custom mods that promote animal care, compassionate education, and non-violent gameplay through animal sanctuaries.

**IMPORTANT**: This repository (`https://github.com/gabrielpantoja-cl/Vegan-Wetlands.git`) contains **ALL** Luanti-specific code, configuration, and deployment logic. It is completely independent from the VPS administrative repository (`vps-do.git`).

## Repository Architecture Strategy

### 🎮 This Repository (Vegan-Wetlands.git)
**Responsibility**: Complete Luanti server implementation
- Docker Compose configuration for Luanti
- Custom mods (animal_sanctuary, vegan_food, education_blocks)
- Server configuration files
- World data and backups
- **Landing page development** (HTML/CSS/JS for luanti.gabrielpantoja.cl)
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
- **Base Game**: VoxeLibre (MineClone2) v0.90.1 - Minecraft-like survival sandbox
- **Configuration**: Lua-based mods and `.conf` files
- **Deployment**: GitHub Actions CI/CD with automated backups (independent pipeline)
- **Server Port**: 30000/UDP (official server: `luanti.gabrielpantoja.cl:30000`)
- **Repository Strategy**: Centralized Luanti development in this dedicated repository

## VPS Access

```bash
# SSH access to production server
ssh gabriel@167.172.251.27
```

## 🚨 CONFIGURACIÓN NUCLEAR CRÍTICA

**⚠️ IMPORTANTE:** El servidor requiere una **configuración nuclear** que modifica archivos **FUERA del repositorio** para funcionar correctamente sin monstruos. Ver `docs/NUCLEAR_CONFIG_OVERRIDE.md` para detalles completos.

### Aplicar Configuración Nuclear (Si es Necesario):
```bash
# Usar script automatizado
./scripts/apply-nuclear-config.sh

# O aplicar manualmente - Ver docs/NUCLEAR_CONFIG_OVERRIDE.md
```

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

### Landing Page Deployment
```bash
# Deploy landing page to VPS
./scripts/deploy-landing.sh

# Verify landing page deployment
./scripts/deploy-landing.sh verify

# Create backup before deployment
./scripts/deploy-landing.sh backup

# Check deployment status
curl -I https://luanti.gabrielpantoja.cl
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
- `server/config/luanti.conf`: Server configuration (creative mode, compassionate-friendly settings)
- `server/games/`: VoxeLibre (MineClone2) game files
- `server/mods/`: Custom Lua mods (animal_sanctuary, vegan_food, education_blocks)
- `server/worlds/`: Persistent world data
- `server/backups/`: Automated backup storage
- `server/landing-page/`: Modern landing page (HTML/CSS/JS) for luanti.gabrielpantoja.cl
- `scripts/`: Maintenance scripts (start.sh, backup.sh, deploy-landing.sh)

### Custom Mods Structure
All mods follow Luanti mod structure:
- `mod.conf`: Mod metadata and dependencies
- `init.lua`: Main mod logic
- `textures/`: Image assets
- `sounds/`: Audio files
- `models/`: 3D model files

**Key Mods:**
1. **animal_sanctuary**: Replaces violent mechanics with animal care (brushes instead of weapons, feeding systems, shelters)
2. **vegan_food**: Plant-based food items (burgers, oat milk, plant-based cheese)
3. **education_blocks**: Interactive educational content about compassion and sustainability

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
- `/filosofia`: Educational content about the game's philosophy
- `/sit`: Sit down comfortably at current position
- `/lay`: Lie down and relax in grass or flower meadows (perfect for chill moments)

### Server Management Features
- New players automatically receive starter kit with plant-based foods (tofu, seitan, plant milk)
- Anti-grief protection with rollback recording
- Automatic health checks every 30 seconds
- Auto-restart on container failure

## Third-Party Content Attribution

### 🌱 Plant-Based Food Mod
**Source**: [vegan_food mod by Daenvil](https://content.luanti.org/packages/Daenvil/vegan_food/)  
**Version**: Latest from Luanti ContentDB  
**License**: 
- **Code**: GPL v3.0
- **Textures**: CC BY-SA 4.0

**Credits**:
- **Developer**: [Daenvil](https://github.com/daenvil)
- **Original textures**: Tofu and not-fish fillet by Daenvil
- **Base textures**: Derived from VoxeLibre, based on Pixel Perfection resource pack for Minecraft 1.11 by XSSheep
- **Special thanks**: [Mindful Minecraft community](https://veganminecraft.com)

**Integration**: Provides professional plant-based food items (tofu, seitan, plant milk, syrup) with high-quality textures for the starter kit, replacing placeholder items that lacked proper textures.

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

### Listing All Registered Users
To get a clean list of all registered usernames, run the following command from the project root on the VPS:
```bash
docker-compose exec -T luanti-server sqlite3 /config/.minetest/worlds/world/auth.sqlite 'SELECT name FROM auth;'
```

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

## VoxeLibre Game Installation

### Overview
The server runs **VoxeLibre (formerly MineClone2) v0.90.1**, a Minecraft-like survival sandbox game that provides familiar gameplay mechanics while being completely open-source.

### Installation Process
VoxeLibre is installed from the official Luanti ContentDB:

**Source**: `https://content.luanti.org/packages/Wuzzy/mineclone2/releases/32301/download/`

### Directory Structure
```
server/games/
├── devtest/          # Default Luanti test game (shipped with container)
├── mineclone2/       # VoxeLibre game files
│   ├── game.conf     # Game metadata (title = VoxeLibre, version=0.90.1)
│   ├── mods/         # Core VoxeLibre mods
│   ├── menu/         # Game menu assets
│   └── textures/     # Game textures and UI elements
```

### Docker Volume Mapping
The games directory is mapped in `docker-compose.yml`:
```yaml
volumes:
  - ./server/games:/config/.minetest/games
```

### World Configuration
Each world specifies which game to use in `world.mt`:
```
gameid = mineclone2
```

### Troubleshooting VoxeLibre Installation

**Problem**: `ERROR[Main]: Game [] could not be found`
**Solution**: 
1. Ensure VoxeLibre is properly installed in `server/games/mineclone2/`
2. Verify `game.conf` exists with correct content
3. Check Docker volume mapping includes games directory
4. Restart server after installation

**Verification Commands**:
```bash
# Check if VoxeLibre is installed
ls -la server/games/mineclone2/

# Verify game.conf content
cat server/games/mineclone2/game.conf

# Check container can see the game
docker-compose exec luanti-server ls -la /config/.minetest/games/
```

## 🌱 Landing Page System

The landing page provides a modern, child-friendly web interface for Vegan Wetlands, accessible at `https://luanti.gabrielpantoja.cl`.

### Architecture Overview

**Dual-Purpose Domain**: `luanti.gabrielpantoja.cl`
- **HTTP/HTTPS**: Serves landing page (nginx on VPS)
- **UDP Port 30000**: Game server connection (Docker container)

**Repository Separation**:
- **This repo**: Landing page development (HTML/CSS/JS)
- **VPS repo (vps-do.git)**: nginx configuration and serving

### Landing Page Features

**Design Principles**:
- **Child-friendly**: Designed for ages 7+ with vibrant colors and simple navigation
- **Compassion focus**: Educational content about animal care and plant-based living
- **Responsive**: Works on desktop, tablet, and mobile devices
- **Accessible**: Screen reader friendly with proper ARIA labels

**Key Sections**:
1. **Hero**: Server connection info with copy-to-clipboard functionality
2. **How to Play**: Step-by-step guide to download Luanti and connect
3. **Features**: Highlights of compassionate gameplay, animal sanctuaries, and educational content
4. **Footer**: Server details and useful in-game commands

### File Structure

```
server/landing-page/
├── index.html                    # Main page
├── assets/
│   ├── css/
│   │   └── style.css            # Modern CSS with animations
│   ├── js/
│   │   └── main.js              # Interactive features
│   └── images/                  # Future: logos, screenshots
└── README.md                    # Landing page documentation
```

### Development Workflow

**Local Development**:
1. Edit files in `server/landing-page/`
2. Open `index.html` in browser for testing
3. Test responsiveness on different screen sizes

**Deployment Process**:
1. **Develop**: Make changes to landing page files
2. **Deploy**: Run `./scripts/deploy-landing.sh`
3. **Verify**: Check `https://luanti.gabrielpantoja.cl`

### Technical Implementation

**CSS Features**:
- CSS Custom Properties (variables) for consistent theming
- Responsive grid layouts
- Smooth animations and hover effects
- Modern gradients and shadows
- Mobile-first responsive design

**JavaScript Features**:
- Server address copy-to-clipboard
- Smooth scrolling navigation
- Intersection Observer for scroll animations
- Dynamic floating animal animations
- Accessibility enhancements

**Performance Optimizations**:
- Efficient CSS animations using `transform` and `opacity`
- Lazy loading for future images
- Minimal JavaScript footprint
- Cached static assets

### Deployment Script

The `scripts/deploy-landing.sh` script handles:

**Automated Tasks**:
1. **Pre-deployment**: SSH connectivity check, backup creation
2. **File Transfer**: rsync deployment with optimizations
3. **nginx Configuration**: Creates/updates server block for `luanti.gabrielpantoja.cl`
4. **Docker Integration**: Updates volume mappings in `vps-do.git`
5. **Service Management**: Reloads nginx, restarts containers
6. **Verification**: HTTP response testing and file validation

**Script Usage**:
```bash
# Full deployment
./scripts/deploy-landing.sh

# Verification only
./scripts/deploy-landing.sh verify

# Backup only
./scripts/deploy-landing.sh backup

# Help
./scripts/deploy-landing.sh help
```

### VPS Configuration

**nginx Configuration** (Created by deployment script):
```nginx
# /home/gabriel/vps-do/nginx/conf.d/luanti-landing.conf
server {
    listen 80;
    server_name luanti.gabrielpantoja.cl;
    root /var/www/luanti-landing;
    index index.html;
    
    # Static assets caching
    location ~* \.(js|css|png|jpg|jpeg|gif|ico|svg)$ {
        expires 1y;
        add_header Cache-Control "public, immutable";
    }
    
    # Security headers
    add_header X-Frame-Options DENY;
    add_header X-Content-Type-Options nosniff;
}
```

**Docker Volume Mapping**:
```yaml
# Added to vps-do/docker-compose.yml
nginx-proxy:
  volumes:
    - ./nginx/www/luanti-landing:/var/www/luanti-landing:ro
```

### Content Guidelines

**Language**: Spanish (primary server language)

**Key Messages**:
- "Servidor educativo y compasivo" (Educational and compassionate server)
- "Sin violencia, solo diversión" (No violence, just fun)
- "Cuida animales en santuarios" (Care for animals in sanctuaries)
- "Aprende sobre alimentación consciente jugando" (Learn about mindful eating while playing)

**Call-to-Actions**:
- Clear server address: `luanti.gabrielpantoja.cl`
- Download links for Luanti client
- Simple connection instructions
- In-game command references

### Future Enhancements

**Phase 2** (Planned):
- Real-time server status via API
- Screenshot gallery of player builds
- Player testimonials section
- Multi-language support (English)

**Phase 3** (Future):
- Interactive server map
- Player statistics dashboard
- Community blog integration
- Social media integration

### Troubleshooting

**Common Issues**:

1. **Landing page not loading**:
   ```bash
   # Check nginx status
   ssh gabriel@167.172.251.27 'cd /home/gabriel/vps-do && docker-compose logs nginx-proxy'
   
   # Test local file access
   ssh gabriel@167.172.251.27 'ls -la /home/gabriel/vps-do/nginx/www/luanti-landing/'
   ```

2. **Game connection still works but landing page doesn't**:
   - Game runs on UDP port 30000 (independent)
   - Web runs on HTTP/HTTPS port 80/443 (nginx)
   - Check nginx configuration in `vps-do.git`

3. **Deployment script fails**:
   ```bash
   # Check SSH connectivity
   ssh gabriel@167.172.251.27 'echo "SSH works"'
   
   # Verify VPS directory structure
   ssh gabriel@167.172.251.27 'ls -la /home/gabriel/vps-do/nginx/www/'
   ```

**Manual Recovery**:
```bash
# Manual deployment if script fails
rsync -avz server/landing-page/ gabriel@167.172.251.27:/home/gabriel/vps-do/nginx/www/luanti-landing/

# Reload nginx manually
ssh gabriel@167.172.251.27 'cd /home/gabriel/vps-do && docker-compose exec nginx-proxy nginx -s reload'
```

## 🚨 Critical Issue Recovery: Texture Corruption (Aug 31, 2025)

### **Problem Description**
Complete texture corruption affecting all blocks in VoxeLibre - all blocks displayed the same incorrect texture, making the game unplayable.

### **🔍 Root Cause Analysis**

**Technical Cause**: Mod texture ID conflict cascade
1. **Texture Atlas Conflict**: The `motorboat` mod redefined texture IDs that already existed in VoxeLibre's texture system
2. **ID Mapping Corruption**: When both systems loaded simultaneously, multiple blocks began pointing to the same texture resource
3. **Cache Persistence**: The incorrect texture mappings were cached in VoxeLibre's internal files
4. **Cascading Failure**: Even after removing the problematic mod, the corrupted cache persisted

**Sequence of Events**:
```
Motorboat mod installed → Texture ID conflicts → Cache corruption → All blocks use same texture → Visual catastrophe
```

### **🛠️ Recovery Procedure**

**CRITICAL**: Always backup world data before attempting recovery!

```bash
# 1. Remove ALL problematic mods
ssh gabriel@167.172.251.27 "cd /home/gabriel/Vegan-Wetlands && rm -rf server/mods/motorboat server/mods/biofuel server/mods/mobkit"

# 2. Download fresh VoxeLibre (56MB)
ssh gabriel@167.172.251.27 "cd /home/gabriel/Vegan-Wetlands && rm -rf server/games/mineclone2"
ssh gabriel@167.172.251.27 "cd /home/gabriel/Vegan-Wetlands && wget https://content.luanti.org/packages/Wuzzy/mineclone2/releases/32301/download/ -O voxelibre.zip"
ssh gabriel@167.172.251.27 "cd /home/gabriel/Vegan-Wetlands && unzip voxelibre.zip -d server/games/ && mv server/games/mineclone2-* server/games/mineclone2"

# 3. Clean container state completely
ssh gabriel@167.172.251.27 "cd /home/gabriel/Vegan-Wetlands && docker compose down && docker system prune -f"

# 4. Remove any mods with broken dependencies
ssh gabriel@167.172.251.27 "cd /home/gabriel/Vegan-Wetlands && rm -rf server/mods/education_blocks"

# 5. Restart with clean slate
ssh gabriel@167.172.251.27 "cd /home/gabriel/Vegan-Wetlands && docker compose up -d"

# 6. Verify world data preservation
ssh gabriel@167.172.251.27 "cd /home/gabriel/Vegan-Wetlands && du -sh server/worlds/*"
```

### **🔍 Prevention Strategies**

1. **Mod Testing Protocol**:
   - Always test new mods in local development environment first
   - Check for texture file conflicts before deployment
   - Verify mod compatibility with VoxeLibre specifically

2. **Backup Strategy**:
   - Regular world backups before any mod changes
   - Keep clean VoxeLibre installation as backup
   - Document working mod combinations

3. **Warning Signs**:
   - Repeated texture blocks in different areas
   - Missing textures (pink/black checkerboard)
   - Server logs showing texture loading errors

### **🎯 Key Learnings**

- **VoxeLibre is sensitive** to texture system modifications
- **Third-party mods can cause deep corruption** of base game files
- **Container restarts alone don't fix cached file corruption**
- **Fresh base game installation is often necessary** for texture issues
- **World data remains safe** even during severe texture corruption

### **📋 Recovery Success Metrics**

- ✅ World data preserved (73MB intact)
- ✅ All blocks display correct textures
- ✅ Server stable on port 30000
- ✅ No dependency errors in logs
- ✅ Player can connect and play normally

**Recovery Time**: ~15 minutes (mostly download time for fresh VoxeLibre)
**Data Loss**: Zero (world fully preserved)
**Resolution**: Complete - textures restored to normal functionality
```