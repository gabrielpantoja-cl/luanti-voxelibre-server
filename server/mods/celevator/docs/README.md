# Celevator Mod Documentation

This document provides a comprehensive overview of the `celevator` mod, including its status, integration with VoxeLibre, and building guides.

---

## 1. Current Status and Integration

**Fecha**: 2025-11-08
**Estado General**: ⚠️ LISTO PERO BLOQUEADO POR VOXELIBRE
**Acción Requerida**: Reinstalar VoxeLibre

### 1.1. Achievements
- **Installation**: The `celevator` mod has been downloaded, installed in `server/mods/celevator/`, and enabled in `server/config/luanti.conf`.
- **VoxeLibre Compatibility**: The mod is fully compatible with VoxeLibre, with automatic detection of `mcl_core` for crafting recipes.
- **Documentation**: All documentation has been created and analyzed.

### 1.2. Identified Issue: Corrupt or Missing VoxeLibre
An error was detected during server startup, indicating missing VoxeLibre dependencies (`mcl_core`, `mcl_player`, etc.). This prevents `celevator` and other mods from being tested.

**Solution**: Reinstall VoxeLibre by following the recovery protocol in `GEMINI.md`.

---

## 2. VoxeLibre Compatibility Details

**Estado**: ✅ Compatible con VoxeLibre sin modificaciones

### 2.1. Automatic MCL Detection
The `crafts.lua` file automatically detects `mcl_core` and adjusts recipes accordingly, using materials like `mcl_core:iron_ingot`, `mcl_copper:copper_ingot`, and `mcl_core:glass`.

### 2.2. Sound System
`celevator` includes 21 professional `.ogg` sound files for a realistic experience, including door sounds, motor noises, and chimes.

### 2.3. Components and Crafting
The mod includes a variety of components, each with specific crafting recipes for VoxeLibre:
- **Cabins**: `car_standard`, `car_glassback`, `car_metal`, `car_metal_glassback`.
- **Doors**: `hwdoor_glass`, `hwdoor_steel`.
- **Controls**: Call buttons, direction indicators, and floor indicators.
- **Machinery**: Controller, motor, governor, and drive.
- **Guide Rails and Buffers**: For smooth and safe operation.

---

## 3. Building Guide

### 3.1. Optimal Dimensions
- **Standard Cabin**: 2 (width) x 3 (height) x 3 (depth) blocks.
- **Floor Height**: 5 blocks per floor is recommended for a comfortable space.

### 3.2. Elevator Shaft Dimensions
- **Minimum Shaft**: 3 (width) x 4 (depth) blocks.
- **Recommended Shaft**: 4 (width) x 5 (depth) blocks.

### 3.3. Construction Checklist
1.  **Plan**: Decide on the number of floors and calculate the total height.
2.  **Build**: Construct the shaft, install guide rails, and place buffers at the bottom.
3.  **Install**: Place cabins on each floor, install doors, and set up the motor and controller at the top.
4.  **Verify**: Test the elevator's movement, doors, and sounds.

### 3.4. Common Mistakes to Avoid
- **Floors too close**: Ensure a minimum of 4 blocks per floor.
- **Shaft too narrow**: Use a minimum of 3x4 blocks for the shaft.
- **Misaligned cabins**: All cabins must have the same X and Z coordinates.
- **Forgetting the motor**: The motor must be at the top of the shaft.

---

## 4. Educational Value

`celevator` is an excellent tool for teaching:
- **Physics**: Concepts of vertical motion, speed, and acceleration.
- **Engineering**: Pulley systems, gears, and motors.
- **Electricity**: Circuits, buttons, and indicators.
- **Safety**: Brakes, governors, and buffers.

---

*This document is a consolidation of `CELEVATOR_BUILDING_GUIDE.md`, `CELEVATOR_STATUS.md`, and `CELEVATOR_VOXELIBRE.md`.*

---

### Additional Information

Source for celevator_controller_manual.pdf is not included in this repository due to its large size.
If desired, the file can be downloaded from: https://cheapiesystems.com/media/celevator_controller_manual.odt

This isn't the README for the whole project, go up one folder for that.