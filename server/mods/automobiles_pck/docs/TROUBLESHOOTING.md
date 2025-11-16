# Automobiles Pack - Troubleshooting Guide

**Server:** Wetlands VoxeLibre
**Modpack Version:** Adapted for VoxeLibre 0.90.1
**Last Updated:** 2025-11-15

---

## 🚨 Common Issues & Solutions

### 1. Server Crashes When Players Board Vehicles

**Symptoms:**
- Server restarts immediately when player right-clicks on vehicle
- Error in logs: `attempt to index global 'airutils' (a nil value)`

**Solution:**
✅ **FIXED** - See `VOXELIBRE_COMPATIBILITY_FIX.md` for complete solution

**Quick Fix:**
```bash
# Replace airutils references with automobiles_lib
sed -i 's/airutils\.is_mcl/automobiles_lib.is_mcl/g' \
  server/mods/automobiles_lib/init.lua \
  server/mods/automobiles_vespa/vespa_player.lua \
  server/mods/automobiles_motorcycle/motorcycle_player.lua
```

**Status:** ✅ Resolved in commit `41318d8`

---

### 2. Vehicles Don't Appear in Creative Inventory

**Symptoms:**
- Can't find vehicles in creative mode inventory
- No automobiles in search results

**Cause:**
Server is in **survival mode**, not creative mode.

**Solution:**
Vehicles must be **crafted** using recipes. See `README_WETLANDS.md` for crafting recipes.

**Alternative (for testing):**
```bash
# Temporarily enable creative mode
echo "creative_mode = true" >> server/config/luanti.conf
docker-compose restart luanti-server
```

---

### 3. Texture Corruption After Installing Mods

**Symptoms:**
- All blocks show same incorrect texture
- Pink/black checkerboard textures
- Missing block textures

**Cause:**
VoxeLibre has fragile texture system. Certain mods (motorboat, biofuel, mobkit) cause corruption.

**Solution:**
See main server docs: `/docs/TEXTURE_CORRUPTION_PROTOCOL.md`

**Prevention:**
- Never install mods with texture dependencies
- Always backup before adding new mods
- Test mods locally before production

---

### 4. Vehicles Not Loading/Working

**Symptoms:**
- Can place vehicle but can't interact
- Vehicle disappears after placement
- No vehicle entities visible

**Diagnostic Steps:**

1. **Check if mods are enabled:**
   ```bash
   docker-compose exec -T luanti-server ls -la /config/.minetest/mods/ | grep automobiles
   ```

2. **Verify world.mt configuration:**
   ```bash
   cat server/worlds/world/world.mt | grep automobiles
   ```
   Should show:
   ```
   load_mod_automobiles_lib = true
   load_mod_automobiles_vespa = true
   load_mod_automobiles_beetle = true
   load_mod_automobiles_motorcycle = true
   load_mod_automobiles_buggy = true
   ```

3. **Check server logs for errors:**
   ```bash
   docker-compose logs luanti-server | grep -iE "(automobiles|error)"
   ```

**Solution:**
If mods not in `world.mt`, add them manually and restart server.

---

### 5. Fuel System Not Working

**Symptoms:**
- Can't refuel vehicles
- No fuel consumption
- No educational messages appearing

**Diagnostic:**
```bash
# Check if vegan fuel system is loaded
docker-compose logs luanti-server | grep -i "fuel"
```

**Verification:**
Try refueling with wheat (should show educational message).

**Common Issues:**
- Using vanilla items instead of VoxeLibre items
- Not holding fuel item while right-clicking in vehicle
- Server in old version without vegan fuel system

**Solution:**
Ensure you're using VoxeLibre items:
- `mcl_farming:wheat_item` (not `default:wheat`)
- `mcl_core:emerald` (not `default:emerald`)

---

### 6. Modpack Structure Issues

**Symptoms:**
- Mods not loading despite being in `server/mods/`
- Server ignoring modpack

**Cause:**
VoxeLibre requires mods in top-level `mods/` directory, not nested in modpack.

**Current Structure (CORRECT):**
```
server/mods/
├── automobiles_lib/       ← Active (extracted)
├── automobiles_vespa/     ← Active (extracted)
├── automobiles_beetle/    ← Active (extracted)
├── automobiles_motorcycle/ ← Active (extracted)
├── automobiles_buggy/     ← Active (extracted)
└── automobiles_pck/       ← Repository backup (not used by server)
    ├── automobiles_lib/
    ├── automobiles_vespa/
    └── ...
```

**Solution:**
Extract submods from modpack to top-level `mods/` directory:
```bash
cp -r server/mods/automobiles_pck/automobiles_* server/mods/
```

---

### 7. Player Animation Stuck

**Symptoms:**
- Player stuck in sitting position after leaving vehicle
- Can't switch to walking animation

**Cause:**
Player detachment not working properly.

**Quick Fix (in-game):**
```
/kill
```
Player respawns with correct animation.

**Permanent Fix:**
Check for `airutils` errors (see issue #1 above).

---

### 8. Vehicle Controls Not Responding

**Symptoms:**
- Can board vehicle but can't drive
- WASD keys don't work
- Vehicle stuck in place

**Checklist:**
1. ✅ Are you the driver (not passenger)?
2. ✅ Is vehicle on solid ground?
3. ✅ Do you have privileges (`interact`)?
4. ✅ Is vehicle damaged? (punch to check HP)

**Solution:**
Remove and replace vehicle if stuck.

---

## 🔍 Diagnostic Commands

### Check Server Status
```bash
docker-compose ps
docker-compose logs --tail=50 luanti-server
```

### Search for Errors
```bash
# Find airutils errors
docker-compose logs luanti-server | grep -i airutils

# Find crash errors
docker-compose logs luanti-server | grep -iE "(error|crash|fatal)"

# Monitor in real-time
docker-compose logs -f luanti-server
```

### Check Mod Files
```bash
# List all automobile mods
ls -la server/mods/ | grep automobiles

# Check for airutils references (should be empty)
grep -rn "airutils" server/mods/automobiles_*/
```

### Verify Configuration
```bash
# Check world.mt
cat server/worlds/world/world.mt | grep automobiles

# Check luanti.conf
cat server/config/luanti.conf | grep automobiles
```

---

## 🛠️ Emergency Recovery

### If Server Won't Start After Mod Changes

1. **Restore from backup:**
   ```bash
   cp -r server/worlds_BACKUP_[date] server/worlds
   ```

2. **Disable problematic mods:**
   ```bash
   # Edit world.mt
   nano server/worlds/world/world.mt
   # Change: load_mod_[name] = true → false
   ```

3. **Clean restart:**
   ```bash
   docker-compose down
   docker system prune -f
   docker-compose up -d
   ```

### If Vehicles Cause Persistent Crashes

1. **Remove all vehicle entities from world:**
   ```bash
   # This requires SQL knowledge - backup first!
   # Contact server admin
   ```

2. **Temporarily disable mods:**
   ```bash
   mv server/mods/automobiles_* /tmp/automobiles_backup/
   docker-compose restart luanti-server
   ```

3. **Gradually re-enable:**
   Start with `automobiles_lib` only, then add one vehicle at a time.

---

## 📋 Pre-deployment Checklist

Before deploying automobile mods:

- [ ] Backup world data
- [ ] Check for `airutils` references
- [ ] Verify VoxeLibre item compatibility
- [ ] Test locally first
- [ ] Monitor logs during first 5 minutes
- [ ] Have rollback plan ready

---

## 🔗 Related Documentation

- **Main Fix:** `VOXELIBRE_COMPATIBILITY_FIX.md`
- **Adaptation Guide:** `WETLANDS_ADAPTATION.md`
- **User Guide:** `README_WETLANDS.md`
- **Server Docs:** `/CLAUDE.md`

---

## 📞 Getting Help

1. **Check logs first:**
   ```bash
   docker-compose logs --tail=100 luanti-server
   ```

2. **Search documentation:**
   - This file (TROUBLESHOOTING.md)
   - VOXELIBRE_COMPATIBILITY_FIX.md
   - Main server CLAUDE.md

3. **Report issue:**
   - GitHub: https://github.com/gabrielpantoja-cl/luanti-voxelibre-server/issues
   - Include: logs, steps to reproduce, server version

---

**Last Updated:** 2025-11-15
**Maintainer:** Gabriel Pantoja
**Server:** luanti.gabrielpantoja.cl:30000
