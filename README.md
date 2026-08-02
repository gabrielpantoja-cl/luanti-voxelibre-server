# Wetlands

**A Luanti (Minetest) server with five worlds on a single VPS — for kids, families, and anyone who wants to play.**

> **[Visit our site](https://luanti.gabrielpantoja.cl/) | [Photo gallery](https://luanti.gabrielpantoja.cl/galeria.html)**

---

Wetlands hosts **five independent worlds** on one server. **Only the main world (port 30000)** is designed as a kid-friendly, education-focused, plant-based survival space. The other four worlds (Valdivia, GAELSIN, CTF, Mineclonia) follow their own game base rules — they are not vegan, not kid-safe, and not subject to the same content filters.

See the per-world docs for what each world offers:

| Port | World | Game base | Kid-safe? | Plant-based? |
|------|-------|-----------|-----------|--------------|
| 30000 | Wetlands | VoxeLibre | ✅ Sí | ✅ Sí |
| 30001 | Valdivia | VoxeLibre (OSM) | ✅ Sí (exploración) | ❌ No |
| 30002 | GAELSIN | VoxeLibre | ❌ No (PvP + hostiles) | ❌ No |
| 30003 | CTF | Capture the Flag | ❌ No (armas) | ❌ No |
| 30004 | Mineclonia | Mineclonia | ✅ Sí (creativo) | ❌ No |

## Wetlands (port 30000) — the family/educational world

The main world (port 30000) is designed as a safe, controlled space for kids and families. Adventure and learning go hand in hand. It is **compassivo y plant-based** — we promote plant alternatives through mods (`vegan_food`, `vegan_replacements`, `education_blocks`) rather than hiding the ecosystem, so players have genuine plant-based options in a familiar VoxeLibre world.

### Wetlands-specific philosophy

- **Animal compassion:** we care for animals, we don't harm them (Wetlands-only).
- **Plant-based by design:** mods replace animal items (meat, leather, etc.) with plant alternatives (tofu, seitan, plant milk, vegetables) and add new plant-based recipes — see [`docs/01-ORIGINAL-30000/VEGAN_PHILOSOPHY.md`](docs/01-ORIGINAL-30000/VEGAN_PHILOSOPHY.md) for the full commitment. **Wetlands-only.**
- **Creative education:** learn about sustainability and conscious eating while you play (Wetlands-only).
- **Controlled adventure:** by day you explore and build freely. At night hostile mobs spawn (Creepers excluded). There's a dedicated PvP arena for combat when you want it.

## How to join

1. **Install Luanti** for [PC](https://www.luanti.org) or mobile ([Android](https://play.google.com/store/apps/details?id=net.minetest.minetest) / [iOS](https://apps.apple.com/app/minetest/id1190647064)).
2. **Add our server:**
   - **Address:** `luanti.gabrielpantoja.cl`
   - **Port:** `30000` (Wetlands), `30001` (Valdivia), `30002` (GAELSIN), `30003` (CTF), `30004` (Mineclonia)
3. **That's it.** Jump in, explore, and create.

## What you can do here (in the Wetlands world, port 30000)

- **Build animal sanctuaries** to protect wildlife
- **Explore a rich world** full of biomes and secrets
- **Talk to educational NPCs** with their own voices, teaching about nature
- **Drive vehicles** — vespas, motorcycles, buggies, beetles
- **Play chess** with other players
- **Fight in the PvP arena** — a dedicated area for those who want action
- **Collaborate** with other players on large community projects

## Worlds

### Wetlands — port `30000`

Main creative world. The safe, family-friendly hub. **Only world with the plant-based/server-filosofía.**

| Feature | Detail |
|---------|--------|
| Mode | Creative (build without limits) |
| Damage | On — hostile mobs spawn at night (Creepers excluded) |
| PvP | Arena only |
| Players | Up to 20 concurrent |
| NPCs | Interactive villagers with Animal Crossing-style voices |
| Vehicles | Vespa, motorcycle, buggy, beetle |
| Music | Original ambient soundtrack |
| Mods | 25+ custom and third-party mods |

### Valdivia — port `30001`

A real-world recreation of Valdivia, Chile, generated from OpenStreetMap data via the [Arnis](https://github.com/luanti-org/arnis) tool. Explore the city's streets, plazas, and rivers as voxels. **Vegan-friendly in spirit (exploración sin combate) pero no es plant-based — sigue siendo VoxeLibre estándar.**

### GAELSIN — port `30002`

Pure VoxeLibre survival world. No creative mode, no area protection, PvP on. Hostile mobs spawn at night (Creepers excluded). Generated from seed `GAELSIN` with mapgen v7. **NO plant-based — PvP y mobs hostiles forman parte del desafio.**

### CTF — port `30003`

Capture-the-flag using the official [`capturetheflag`](https://github.com/MT-CTF/capturetheflag) game by rubenwardy (not VoxeLibre). Swords, guns, grenades; rounds start automatically when both teams have players. **NO plant-based — armas y combate son el core.**

### Mineclonia — port `30004`

[Mineclonia](https://codeberg.org/mineclonia/mineclonia) 0.123.0, a fork of VoxeLibre that targets a faithful Minecraft vanilla experience. Creative mode, no damage, no PvP, no custom mods — just the game base. Seed `mineclonia`. **NO plant-based — experiencia Minecraft vanilla fiel.**

## Known bugs

- **Arrows deal damage outside the arena:** bows currently cause damage anywhere on the map, not only inside the PvP arena. Projectile damage restriction is in progress.

## Tech stack

- **Engine**: [Luanti](https://www.luanti.org) 5.16+
- **Base games**: VoxeLibre (MineClone2) v0.90.1, Mineclonia 0.123.0, capturetheflag (rubenwardy)
- **Mod language**: Lua
- **Infrastructure**: Docker Compose on a VPS (Oracle Cloud, ARM aarch64)

## Contributing

This project is open source under the MIT License (see [LICENSE](LICENSE)). Third-party content inside `server/games/` and individual mods keeps its original license.

If you want to contribute:

- **Repository**: [GitHub](https://github.com/gabrielpantoja-cl/luanti-voxelibre-server)
- **Mods**: `server/mods/` (Lua)
- **Landing page**: `server/landing-page/` (HTML/CSS/JS)
- **Docs**: `docs/`

Open an issue or PR — contributions appropriate for a kid-friendly educational server are welcome.

---

**See you in-game.**
