# VoxeLibre Setup Guide for Vegan Wetlands Server

## Overview

This guide documents the complete setup process for VoxeLibre (formerly MineClone2) on the Vegan Wetlands Luanti server. VoxeLibre provides a Minecraft-like survival sandbox experience that serves as the base game for our vegan-themed educational server.

## What is VoxeLibre?

**VoxeLibre (MineClone2)** is an open-source game that recreates the Minecraft experience in the Luanti engine. It provides:

- Familiar block-building mechanics
- Survival gameplay elements
- Crafting systems
- Biomes and world generation
- Monster and animal spawning
- Complete compatibility with Luanti mods

**Version**: 0.90.1 (as of August 2025)
**Source**: Official Luanti ContentDB

## Installation Process

### Step 1: Download VoxeLibre

Download the latest stable release from the official ContentDB:

```bash
cd server/games
wget https://content.luanti.org/packages/Wuzzy/mineclone2/releases/32301/download/ -O mineclone2.zip
```

### Step 2: Extract and Install

```bash
unzip -q mineclone2.zip
ls -la mineclone2/  # Verify installation
rm mineclone2.zip   # Clean up
```

### Step 3: Verify Installation

Check that the game.conf file exists and contains correct metadata:

```bash
cat mineclone2/game.conf
```

Expected output:
```
title = VoxeLibre
description = A survival sandbox game. Survive, gather, hunt, build, explore, and do much more.
disallowed_mapgens = v6
version=0.90.1
```

### Step 4: Configure Docker Mapping

Ensure the games directory is properly mapped in `docker-compose.yml`:

```yaml
services:
  luanti-server:
    volumes:
      - ./server/config/luanti.conf:/config/.minetest/minetest.conf
      - ./server/mods:/config/.minetest/mods
      - ./server/worlds:/config/.minetest/worlds
      - ./server/games:/config/.minetest/games  # This line is critical
      - ./server/backups:/backups
```

### Step 5: Configure World to Use VoxeLibre

Each world must specify VoxeLibre in its `world.mt` file:

```bash
# Check existing world configuration
cat server/worlds/world/world.mt
```

The file should contain:
```
gameid = mineclone2
enable_damage = true
creative_mode = false
mod_storage_backend = sqlite3
auth_backend = sqlite3
player_backend = sqlite3
backend = sqlite3
world_name = world
```

### Step 6: Start the Server

```bash
docker-compose down  # Stop any existing containers
docker-compose up -d # Start with new configuration
```

### Step 7: Verify Successful Loading

Monitor the server logs for successful VoxeLibre loading:

```bash
docker-compose logs -f luanti-server
```

Look for these success indicators:
- `ACTION[Main]: World seed = [number]`
- `ACTION[Main]: VoxeLibre mapgen version = 0.87 or earlier`
- `ACTION[Main]: Server for gameid="mineclone2" listening on [::]:30000`
- No errors about "Game [] could not be found"

## Directory Structure

After successful installation, your games directory should look like:

```
server/games/
├── devtest/           # Default Luanti test game (pre-installed)
├── mineclone2/        # VoxeLibre game files
│   ├── game.conf      # Game metadata
│   ├── mods/          # Core VoxeLibre mods (hundreds of files)
│   ├── menu/          # Game menu backgrounds and UI
│   ├── textures/      # Game textures and UI elements
│   ├── releasenotes/  # Version history
│   └── settingtypes.txt # Game settings configuration
```

## Troubleshooting Common Issues

### Problem: "Game [] could not be found"

**Symptoms**: Server logs repeatedly show `ERROR[Main]: Game [] could not be found`

**Causes**:
1. VoxeLibre not properly installed
2. games directory not mapped in Docker
3. Incorrect world.mt configuration
4. File permission issues

**Solution Steps**:

1. **Verify VoxeLibre installation**:
   ```bash
   ls -la server/games/mineclone2/
   cat server/games/mineclone2/game.conf
   ```

2. **Check Docker volume mapping**:
   ```bash
   docker-compose exec luanti-server ls -la /config/.minetest/games/
   ```
   You should see both `devtest` and `mineclone2` directories.

3. **Verify world configuration**:
   ```bash
   docker-compose exec luanti-server cat /config/.minetest/worlds/world/world.mt
   ```
   Ensure `gameid = mineclone2` is present.

4. **Check file permissions**:
   ```bash
   sudo chown -R 1000:1000 server/games/
   ```

5. **Restart server**:
   ```bash
   docker-compose down && docker-compose up -d
   ```

### Problem: Server starts but players can't see VoxeLibre content

**Symptoms**: Players connect but see default Luanti game instead of Minecraft-like blocks

**Solution**: Ensure the world was created with VoxeLibre. If migrating from another game:
1. Back up existing world data
2. Create a new world with `gameid = mineclone2`
3. Import/migrate necessary data

### Problem: Container can't access games directory

**Symptoms**: Container shows empty games directory or only sees `devtest`

**Solution**:
1. Verify volume mapping in docker-compose.yml
2. Check file permissions (must be readable by UID 1000)
3. Restart Docker containers after changes

## Configuration for Vegan Wetlands

### Custom Modifications

The Vegan Wetlands server runs VoxeLibre with the following modifications:

1. **Creative Mode**: Enabled for educational purposes
2. **Damage Disabled**: Child-friendly environment
3. **Custom Mods**: Vegan-themed additions that override violent mechanics
4. **Spanish Language**: Configured for Spanish-speaking audience

### Mod Integration

VoxeLibre works seamlessly with our custom vegan mods:

- **animal_sanctuary**: Replaces hostile mobs with friendly animals
- **vegan_foods**: Adds plant-based food alternatives
- **education_blocks**: Provides vegan education content

### Performance Considerations

VoxeLibre is resource-intensive compared to basic Luanti games:

- **Memory**: Requires ~2GB RAM minimum
- **Storage**: Game files are ~58MB compressed, ~200MB extracted
- **CPU**: Moderate CPU usage for world generation
- **Network**: Larger texture downloads for clients

## Maintenance and Updates

### Checking for Updates

Monitor the VoxeLibre ContentDB page for new releases:
- URL: https://content.luanti.org/packages/Wuzzy/mineclone2/

### Update Process

1. Backup current world data
2. Download new VoxeLibre version
3. Replace `server/games/mineclone2/` directory
4. Test locally before deploying
5. Update version references in documentation

### Backup Considerations

VoxeLibre worlds contain more complex data than basic Luanti games:
- Larger world files due to detailed biomes
- More metadata for complex items and mechanics
- Backup frequency should account for increased data generation

## Integration with CI/CD

The VoxeLibre installation is managed within this repository's CI/CD pipeline:

### Deployment Steps
1. Games directory is included in repository
2. Docker volume mapping handles container access
3. Automated backups protect world data
4. Health checks verify successful game loading

### Development Workflow
1. Test VoxeLibre changes locally
2. Commit games directory changes to git
3. Push triggers automatic deployment
4. Monitor deployment logs for success

## Security and Licensing

### VoxeLibre Licensing
- **License**: Various open-source licenses (GPL, CC, etc.)
- **Legal**: Fully legal Minecraft-inspired game
- **Commercial Use**: Allowed under open-source terms

### Security Considerations
- VoxeLibre is actively maintained with security updates
- No known security vulnerabilities as of version 0.90.1
- Regular updates recommended for stability and security

## Conclusion

VoxeLibre provides an excellent foundation for the Vegan Wetlands educational server, offering familiar Minecraft-like gameplay while maintaining complete open-source compatibility with our custom vegan-themed modifications.

The installation process, while requiring careful attention to Docker volume mapping and world configuration, results in a stable and feature-rich gaming environment perfect for our educational mission.