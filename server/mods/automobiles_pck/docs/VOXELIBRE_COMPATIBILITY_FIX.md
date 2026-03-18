# VoxeLibre Compatibility Fix - Critical Server Crash Resolution

**Date:** November 15, 2025
**Issue:** Server crashes when players attempt to board vehicles
**Severity:** CRITICAL - Server restart on every vehicle interaction
**Status:** ✅ RESOLVED

---

## 🔴 Problem Description

### Symptoms
- Server crashes immediately when players right-click on vehicles (Vespa, Beetle, Motorcycle, Buggy)
- Automatic server restart triggered by crash
- Players disconnected during vehicle boarding attempt

### Error Messages
```
WARNING[Server]: Undeclared global variable "airutils" accessed at /config/.minetest/mods/automobiles_lib/init.lua:238
ERROR[Main]: ServerError: AsyncErr: Lua: Runtime error from mod '??' in callback luaentity_run_simple_callback():
/config/.minetest/mods/automobiles_lib/init.lua:238: attempt to index global 'airutils' (a nil value)
```

### Affected Files
1. `server/mods/automobiles_pck/automobiles_lib/init.lua` (lines 238, 315, 354)
2. `server/mods/automobiles_pck/automobiles_vespa/vespa_player.lua` (lines 44, 143)
3. `server/mods/automobiles_pck/automobiles_motorcycle/motorcycle_player.lua` (lines 44, 152)

---

## 🔍 Root Cause Analysis

### The Problem
The `automobiles_pck` mod was originally designed to work with the **airutils** mod as a dependency. The code uses `airutils.is_mcl` to detect if running on VoxeLibre/MineClone2.

However, **airutils is NOT installed** on Wetlands server, causing a nil reference error when the code tries to access `airutils.is_mcl`.

### Why It Happens
When a player attempts to board a vehicle, the mod's `attach_driver` function runs:

```lua
-- BROKEN CODE (BEFORE FIX)
if automobiles_lib.is_minetest then
    player_api.player_attached[name] = true
    player_api.set_animation(player, "sit")
elseif airutils.is_mcl then  -- ❌ airutils doesn't exist!
    mcl_player.player_attached[name] = true
    mcl_player.player_set_animation(player, "sit" , 30)
    automobiles_lib.sit(player)
end
```

### Discovery Process
The mod **already had** the correct detection mechanism in `init.lua:18`:

```lua
automobiles_lib.is_mcl = core.get_modpath("mcl_player")
```

But various attach/detach functions incorrectly used `airutils.is_mcl` instead of `automobiles_lib.is_mcl`.

---

## ✅ Solution Applied

### The Fix
Replace all instances of `airutils.is_mcl` with `automobiles_lib.is_mcl` across the codebase.

### Changes Made

#### 1. automobiles_lib/init.lua (3 occurrences)

**Line 238 - attach_driver function:**
```lua
# BEFORE
elseif airutils.is_mcl then

# AFTER
elseif automobiles_lib.is_mcl then
```

**Line 315 - attach_pax function (passenger seat):**
```lua
# BEFORE
elseif airutils.is_mcl then

# AFTER
elseif automobiles_lib.is_mcl then
```

**Line 354 - attach_pax function (multi-passenger):**
```lua
# BEFORE
elseif airutils.is_mcl then

# AFTER
elseif automobiles_lib.is_mcl then
```

#### 2. automobiles_vespa/vespa_player.lua (2 occurrences)

**Line 44 - driver attachment:**
```lua
# BEFORE
elseif airutils.is_mcl then

# AFTER
elseif automobiles_lib.is_mcl then
```

**Line 143 - passenger attachment:**
```lua
# BEFORE
elseif airutils.is_mcl then

# AFTER
elseif automobiles_lib.is_mcl then
```

#### 3. automobiles_motorcycle/motorcycle_player.lua (2 occurrences)

**Line 44 - driver attachment:**
```lua
# BEFORE
elseif airutils.is_mcl then

# AFTER
elseif automobiles_lib.is_mcl then
```

**Line 152 - passenger attachment:**
```lua
# BEFORE
elseif airutils.is_mcl then

# AFTER
elseif automobiles_lib.is_mcl then
```

---

## 🛠️ Deployment Process

### Step 1: Local Repository Fix
```bash
# Apply fixes to modpack files
cd /home/gabriel/Documentos/luanti-voxelibre-server
sed -i 's/airutils\.is_mcl/automobiles_lib.is_mcl/g' \
  server/mods/automobiles_pck/automobiles_lib/init.lua \
  server/mods/automobiles_pck/automobiles_vespa/vespa_player.lua \
  server/mods/automobiles_pck/automobiles_motorcycle/motorcycle_player.lua
```

### Step 2: Git Commit & Push
```bash
git add server/mods/automobiles_pck/automobiles_lib/init.lua
git add server/mods/automobiles_pck/automobiles_motorcycle/motorcycle_player.lua
git add server/mods/automobiles_pck/automobiles_vespa/vespa_player.lua
git commit -m "🔧 FIX CRÍTICO: Corregir crashes del servidor con vehículos"
git push origin main
```

**Commit Hash:** `41318d8`

### Step 3: VPS Deployment
```bash
# SSH to VPS
ssh gabriel@<IP_VPS_ANTERIOR>

# Pull latest changes
cd /home/gabriel/luanti-voxelibre-server
git pull

# Apply fixes to extracted mods (critical for active server)
sed -i 's/airutils\.is_mcl/automobiles_lib.is_mcl/g' \
  server/mods/automobiles_lib/init.lua \
  server/mods/automobiles_vespa/vespa_player.lua \
  server/mods/automobiles_motorcycle/motorcycle_player.lua

# Restart server
docker-compose restart luanti-server
```

### Step 4: Verification
```bash
# Check for airutils errors (should return empty)
docker-compose logs --tail=100 luanti-server | grep -i airutils

# Monitor server health
docker-compose ps
```

---

## 📊 Testing Results

### Before Fix
- ❌ Server crash on vehicle boarding
- ❌ Players disconnected
- ❌ Vehicles unusable
- ❌ Error logs showing `airutils` nil reference

### After Fix
- ✅ Players can board vehicles successfully
- ✅ No server crashes
- ✅ Smooth vehicle operation
- ✅ No `airutils` errors in logs

### Tested Vehicles
- ✅ **Vespa** - Working perfectly
- ✅ **Beetle** (small red car) - Working perfectly
- ✅ **Motorcycle** - Working perfectly
- ✅ **Buggy** - Working perfectly

### Tested Actions
- ✅ Right-click to board vehicle
- ✅ Player animation changes to "sit"
- ✅ Vehicle controls (WASD/arrow keys)
- ✅ Jumping out of vehicle
- ✅ Multiple players on server with vehicles

---

## 🏗️ Architecture Notes

### Mod Structure on Wetlands Server

**Important:** The server has TWO copies of automobile mods:

1. **Original Modpack** (repository tracked):
   ```
   server/mods/automobiles_pck/
   ├── automobiles_lib/
   ├── automobiles_vespa/
   ├── automobiles_beetle/
   └── ...
   ```

2. **Extracted Mods** (active in server):
   ```
   server/mods/
   ├── automobiles_lib/      ← Server uses these
   ├── automobiles_vespa/    ← Server uses these
   ├── automobiles_beetle/   ← Server uses these
   └── automobiles_pck/      ← Repository version
   ```

**Why?** VoxeLibre requires mods to be in the top-level `mods/` directory, not nested in a modpack subdirectory.

### Deployment Strategy
1. **Fix modpack files** (tracked in git)
2. **Copy fixes to extracted mods** (active on server)
3. **Restart server** to load updated code

---

## 🔧 Maintenance Guidelines

### When Adding New Vehicles
If adding new submods from the automobiles pack:

1. Check for `airutils` references:
   ```bash
   grep -rn "airutils" server/mods/automobiles_pck/automobiles_[new_mod]/
   ```

2. Replace with `automobiles_lib`:
   ```bash
   sed -i 's/airutils\.is_mcl/automobiles_lib.is_mcl/g' [file_path]
   ```

3. Test on local server before production deployment

### If Mod Update from Upstream
When updating automobiles_pck from ContentDB:

1. **BACKUP CURRENT VERSION**
2. Apply update
3. **RE-APPLY THIS FIX** (airutils → automobiles_lib)
4. Test thoroughly before production

### Monitoring for Regressions
Watch for these error patterns in logs:
```bash
docker-compose logs luanti-server | grep -iE "(airutils|undefined|nil value)"
```

---

## 📚 Technical Details

### VoxeLibre Detection Mechanism
The mod correctly detects VoxeLibre using:

```lua
automobiles_lib.is_mcl = core.get_modpath("mcl_player")
```

This checks if the `mcl_player` mod exists, which is VoxeLibre's player API.

### Player Attachment System
When a player boards a vehicle:

1. **Minetest vanilla:**
   - Uses `player_api.player_attached`
   - Uses `player_api.set_animation`

2. **VoxeLibre (correct path):**
   - Uses `mcl_player.player_attached`
   - Uses `mcl_player.player_set_animation`
   - Calls custom `automobiles_lib.sit(player)`

### Why airutils Was Referenced
The original mod author (apercy) likely uses **airutils** as a common dependency across their vehicle mods. The airutils mod provides aircraft/vehicle utilities and game compatibility detection.

**For Wetlands:** We don't need airutils because:
- We're not using aircraft
- We have VoxeLibre detection built-in via `automobiles_lib.is_mcl`

---

## 🎯 Related Documentation

- **Mod Adaptation Guide:** `WETLANDS_ADAPTATION.md`
- **Vehicle Configuration:** `README.md`
- **VoxeLibre Mod System:** `/docs/mods/VOXELIBRE_MOD_SYSTEM.md`
- **Main Server Documentation:** `/CLAUDE.md`

---

## 👥 Credits

**Issue Reported By:** Gabriel & pepelomo (Wetlands players)
**Diagnosed By:** Claude Code (AI Assistant)
**Fix Applied By:** Gabriel Pantoja
**Testing:** pepelomo, gabo (in-game testing)
**Server:** Wetlands - luanti.gabrielpantoja.cl:30000

---

## 📝 Changelog

### 2025-11-15 - v1.0.0 - CRITICAL FIX
- ✅ Fixed server crashes on vehicle boarding
- ✅ Replaced 7 `airutils.is_mcl` references with `automobiles_lib.is_mcl`
- ✅ Tested and verified with all active vehicles
- ✅ Documentation created

---

**Status:** ✅ **PRODUCTION READY**
**Last Updated:** 2025-11-15
**Server Version:** Luanti 5.14.0 with VoxeLibre 0.90.1
