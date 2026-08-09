# Wetlands

**A Luanti (Minetest) server with five worlds on a single VPS — for kids, families, and anyone who wants to play.**

> **[Visit our site](https://luanti.gabrielpantoja.cl/) | [Photo gallery](https://luanti.gabrielpantoja.cl/galeria.html)**

---

Wetlands hosts **five independent worlds** on one server. Each world has its own game, rules, configuration, and documentation.

See the per-world docs for what each world offers:

| Port | World | Game base | Mode | PvP |
|------|-------|-----------|------|-----|
| 30000 | Wetlands | VoxeLibre | Hard survival, compassionate and plant-based | No |
| 30001 | Valdivia | VoxeLibre + OSM | Exploration/survival | See world rules |
| 30002 | GAELSIN | VoxeLibre | Survival | Yes |
| 30003 | CTF | Capture the Flag | Team combat | Core gameplay |
| 30004 | Mineclonia | Mineclonia | Creative, no damage | No |

World-specific content should be confirmed in the corresponding configuration under `server/config/` and in the documentation under `docs/`.

## Wetlands (port 30000) — the family/educational world

The main world (port 30000) is **hard survival** with no PvP. Its design is compassionate and plant-based, but it is not creative mode: players gather resources, craft, take damage, and face hostile mobs at night. Creepers are blocked separately.

### Wetlands-specific philosophy

- **Animal compassion:** the Wetlands rules discourage harming animals.
- **Plant-based identity:** the server identity and documentation are plant-based; optional legacy replacement/education mods are currently disabled in the authoritative Wetlands configuration.
- **Controlled adventure:** hostile mobs spawn at night, Creepers are excluded, and PvP is disabled.

## How to join

1. **Install Luanti** for [PC](https://www.luanti.org) or mobile ([Android](https://play.google.com/store/apps/details?id=net.minetest.minetest) / [iOS](https://apps.apple.com/app/minetest/id1190647064)).
2. **Add our server:**
   - **Address:** `luanti.gabrielpantoja.cl`
   - **Port:** `30000` (Wetlands), `30001` (Valdivia), `30002` (GAELSIN), `30003` (CTF), `30004` (Mineclonia)
3. **That's it.** Jump in, explore, and create.

## What you can do here (in the Wetlands world, port 30000)

- **Build and explore** within survival limits
- **Protect wildlife** and collaborate on community projects
- **Survive the night** without Creepers or PvP
- **Use the currently enabled tools**, documented in `server/config/luanti-original.conf`

## Worlds

### Wetlands — port `30000`

Main hard-survival world with a compassionate identity. The authoritative settings are in `server/config/luanti-original.conf`; the world's `world.mt` on the VPS can override individual mod switches.

| Feature | Detail |
|---------|--------|
| Mode | Hard survival |
| Damage | On — hostile mobs spawn at night; Creepers excluded |
| PvP | Disabled |
| Players | Up to 20 concurrent |
| Spawn | `655.1,18.5,243.9` |
| Enabled custom content | `wetlands_newplayer`, `wetlands_no_creeper`, `wetlands_lastpos`, `server_rules`, custom skin support |

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
