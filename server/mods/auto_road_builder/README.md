# 🛣️ Auto Road Builder

**Automated road construction mod for Luanti/VoxeLibre**

Build long roads instantly between two points with customizable width and materials. Perfect for connecting cities, creating highways, and massive infrastructure projects.

## Features

✅ **Instant Construction** - Build kilometers of road in seconds
✅ **Customizable Width** - From narrow paths to wide highways
✅ **Any Material** - Use any block type (slabs, concrete, stone, etc.)
✅ **Progress Reporting** - Real-time feedback during construction
✅ **Multiple Commands** - Flexible building options
✅ **Smart Direction** - Perpendicular road width calculation

## Installation

1. Copy the `auto_road_builder` folder to your `mods` directory:
   ```bash
   cp -r auto_road_builder /path/to/server/mods/
   ```

2. Enable the mod in your world configuration or add to `world.mt`:
   ```
   load_mod_auto_road_builder = true
   ```

3. Restart the server

4. Verify the mod is loaded:
   ```
   /help build_road
   ```

## Commands

### `/build_road <x1> <y1> <z1> <x2> <y2> <z2> [width] [material]`

Build a road between two specific coordinates.

**Parameters:**
- `x1 y1 z1` - Start position (X, Y, Z coordinates)
- `x2 y2 z2` - End position (X, Y, Z coordinates)
- `width` - Road width in blocks (optional, default: 10)
- `material` - Node name for road material (optional, default: `mcl_stairs:slab_concrete_grey`)

**Required privilege:** `server`

**Examples:**

```bash
# Basic usage (10 blocks wide, grey concrete slabs)
/build_road -124 30 73 -1770 3 902

# Custom width (15 blocks wide)
/build_road -124 30 73 -1770 3 902 15

# Custom material (stone slabs)
/build_road -124 30 73 -1770 3 902 10 mcl_stairs:slab_stone

# Narrow path (5 blocks wide with cobblestone slabs)
/build_road -77 24 71 -127 30 71 5 mcl_stairs:slab_cobble
```

---

### `/build_road_here <x2> <y2> <z2> [width] [material]`

Build a road from your **current position** to target coordinates.

**Parameters:**
- `x2 y2 z2` - End position
- `width` - Road width (optional, default: 10)
- `material` - Road material (optional, default: grey concrete slab)

**Required privilege:** `server`

**Examples:**

```bash
# Build road from where you're standing to Expansión Oeste
/build_road_here -1770 3 902

# Build with custom width
/build_road_here -1770 3 902 12

# Build with custom material
/build_road_here -1770 3 902 10 mcl_stairs:slab_stone
```

---

### `/road_continue <distance> [width] [material]`

Continue building road in the **same direction** as the last road built.

**Parameters:**
- `distance` - How many blocks to extend
- `width` - Road width (optional)
- `material` - Road material (optional)

**Required privilege:** `server`

**Example workflow:**

```bash
# Build initial segment
/build_road -77 24 71 -127 30 71 10

# Continue 100 blocks in same direction (west)
/road_continue 100

# Continue another 150 blocks
/road_continue 150
```

## Usage Examples

### Example 1: Connect Ciudad Principal to Expansión Oeste

```bash
# From current position at Ciudad Principal
/build_road_here -1770 3 902 10 mcl_stairs:slab_concrete_grey
```

**Result:** ~1700 block road built in ~5 seconds ⚡

---

### Example 2: Build Highway in Segments

```bash
# Segment 1: Ciudad Principal to checkpoint
/build_road -77 24 71 -277 28 300 12 mcl_stairs:slab_stone

# Segment 2: Continue from checkpoint
/build_road -277 28 300 -777 20 600 12 mcl_stairs:slab_stone

# Segment 3: Final stretch to destination
/build_road -777 20 600 -1770 3 902 12 mcl_stairs:slab_stone
```

---

### Example 3: Quick Path Between Buildings

```bash
# Narrow walking path (5 blocks wide)
/build_road -50 15 80 -150 15 120 5 mcl_stairs:slab_wood
```

## Supported Materials

### VoxeLibre Compatible Materials:

**Slabs (Recommended for roads):**
- `mcl_stairs:slab_concrete_grey` - Grey concrete (default)
- `mcl_stairs:slab_concrete_white` - White concrete
- `mcl_stairs:slab_concrete_black` - Black concrete
- `mcl_stairs:slab_stone` - Stone slab
- `mcl_stairs:slab_cobble` - Cobblestone slab
- `mcl_stairs:slab_stone_smooth` - Smooth stone slab
- `mcl_stairs:slab_andesite` - Andesite slab
- `mcl_stairs:slab_granite` - Granite slab

**Full Blocks (for elevated roads):**
- `mcl_core:stone` - Stone
- `mcl_core:cobble` - Cobblestone
- `mcl_concrete:grey` - Grey concrete block
- `mcl_concrete:white` - White concrete block

**Testing materials:**
If unsure about a material name, test with a small segment first:
```bash
/build_road -100 30 70 -110 30 70 5 mcl_stairs:slab_stone
```

## Configuration

Edit `init.lua` to change defaults:

```lua
auto_road_builder.config = {
    default_width = 10,                              -- Default road width
    default_material = "mcl_stairs:slab_concrete_grey",  -- Default material
    max_distance = 5000,                             -- Maximum road length
    progress_interval = 100,                         -- Progress report frequency
}
```

## Performance

- **Speed:** ~500-1000 blocks/second
- **Road from Ciudad Principal to Expansión Oeste:** ~1700 blocks in 3-5 seconds
- **Memory:** Minimal (processes one block at a time)
- **Server lag:** None (synchronous placement)

## Tips & Best Practices

### 1. Plan Your Route
Use `/teleport` to scout the route first:
```bash
/teleport gabo -124 30 73   # Start
/teleport gabo -1770 3 902  # End
```

### 2. Build in Segments for Variable Terrain
If terrain changes elevation significantly, build in segments:
```bash
/build_road -77 24 71 -277 32 71   # Uphill segment
/build_road -277 32 71 -777 28 71  # Flat segment
/build_road -777 28 71 -1770 3 902 # Downhill segment
```

### 3. Use Wider Roads for Highways
- **Narrow path:** 3-5 blocks (walking only)
- **Standard road:** 7-10 blocks (comfortable driving)
- **Highway:** 12-15 blocks (multi-lane)

### 4. Match Materials to Theme
- **Medieval:** Stone slabs, cobblestone
- **Modern:** Concrete (grey, black, white)
- **Natural:** Wood slabs, gravel

### 5. Undo Mistakes
If you make a mistake, there's no built-in undo. Best practice:
- Test with small segment first
- Use WorldEdit `//undo` if available
- Or manually remove with WorldEdit `//set air`

## Troubleshooting

### "Invalid material" error
**Problem:** Material name not recognized
**Solution:** Check spelling, try alternative:
```bash
# If mcl_stairs:slab_concrete_grey fails, try:
/build_road ... mcl_stairs:slab_stone
```

### "Distance too large" error
**Problem:** Road exceeds 5000 blocks
**Solution:** Build in segments or increase `max_distance` in config

### Road appears in wrong location
**Problem:** Coordinate typo
**Solution:** Double-check coordinates with F5 in-game

### Permission denied
**Problem:** Player lacks `server` privilege
**Solution:** Grant privilege:
```bash
/grant <player> server
```

## Planned Features

- [ ] Terrain adaptation mode (auto-adjust Y coordinate)
- [ ] Curved roads (bezier curves)
- [ ] Road decorations (streetlights, signs)
- [ ] Multi-layer roads (road + foundation)
- [ ] Save/load road templates
- [ ] GUI interface for road building

## Credits

**Author:** Gabriel Pantoja (with Claude Code)
**License:** GPLv3
**Version:** 1.0.0
**Server:** Wetlands Valdivia (luanti.gabrielpantoja.cl)
**Repository:** https://github.com/gabrielpantoja-cl/luanti-voxelibre-server

## Support

For issues, questions, or feature requests:
- Open an issue on GitHub
- Contact server admin: Gabriel Pantoja

---

**Built with ❤️ for the Wetlands community**
