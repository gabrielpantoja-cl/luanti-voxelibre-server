# NPC Census - Wetlands Server

> Scan date: 2026-02-15
> Scan method: map.sqlite full world scan (2,257,422 mapblocks, zstd decompression via libzstd)
> Server version: wetlands_npcs v2.0.0

## Summary

| Metric | Value |
|--------|-------|
| Total NPC entities in world | **75** |
| Expected (1 per type) | **9** |
| Duplicates | **66** |
| NPC types registered | 9 |

## Entity Census by Type

### Star Wars NPCs (model: `wetlands_npc_human.b3d`, 64x32)

| NPC | Entities | Duplicates | Status |
|-----|----------|------------|--------|
| anakin | 10 | 9 | OVER-SPAWNED |
| leia | 4 | 3 | OVER-SPAWNED |
| luke | 7 | 6 | OVER-SPAWNED |
| mandalorian | 8 | 7 | OVER-SPAWNED |
| yoda | 5 | 4 | OVER-SPAWNED |

### Classic NPCs (model: `mobs_mc_villager.b3d`, 64x64)

| NPC | Entities | Duplicates | Status |
|-----|----------|------------|--------|
| explorer | 13 | 12 | OVER-SPAWNED |
| farmer | 8 | 7 | OVER-SPAWNED |
| librarian | 18 | 17 | WORST - most duplicated |
| teacher | 2 | 1 | OVER-SPAWNED |

## Detailed Entity Positions

Positions are approximate (mapblock center, +/- 8 nodes).

### anakin (10 entities)
```
[1]  ~pos=(-1752, 8, 936)     <- far zone (explorer area?)
[2]  ~pos=(-8, 8, -120)
[3]  ~pos=(40, 24, -88)
[4]  ~pos=(88, 56, -40)       <- near current play area
[5]  ~pos=(-88, 24, 72)
[6]  ~pos=(24, 8, -56)
[7]  ~pos=(8, 24, 8)
[8]  ~pos=(-88, 40, 24)
[9]  ~pos=(56, 24, 56)
[10] ~pos=(40, 24, 56)
```

### explorer (13 entities)
```
[1]  ~pos=(-1720, 8, 984)     <- far zone cluster
[2]  ~pos=(-1736, 8, 968)     <- far zone cluster
[3]  ~pos=(-1752, -8, 968)    <- far zone cluster
[4]  ~pos=(-1800, 8, 872)     <- far zone cluster
[5]  ~pos=(-1800, 8, 952)     <- far zone cluster
[6]  ~pos=(-1768, 8, 936)     <- far zone cluster
[7]  ~pos=(-1720, 8, 968)     <- far zone cluster
[8]  ~pos=(-1800, 8, 856)     <- far zone cluster
[9]  ~pos=(104, 24, -88)
[10] ~pos=(8, 8, -72)
[11] ~pos=(-72, 24, 104)
[12] ~pos=(-8, 24, 136)
[13] ~pos=(-8, 24, 120)
```
NOTE: 8 explorers are clustered in a far zone around (-1750, 8, 930).

### farmer (8 entities)
```
[1]  ~pos=(-88, 24, -24)
[2]  ~pos=(24, 24, -104)
[3]  ~pos=(24, 24, -8)
[4]  ~pos=(24, 24, 24)
[5]  ~pos=(24, -24, 56)
[6]  ~pos=(-24, 24, 72)
[7]  ~pos=(8, 24, 56)
[8]  ~pos=(-40, 24, 152)
```

### leia (4 entities)
```
[1]  ~pos=(-72, 24, -8)
[2]  ~pos=(88, 56, -40)       <- near current play area
[3]  pos=(0.0, 0.0, 0.8)     <- near spawn!
[4]  ~pos=(8, 8, -40)
```

### librarian (18 entities) -- MOST DUPLICATED
```
[1]  ~pos=(-1704, 8, 872)     <- far zone
[2]  ~pos=(-1704, 8, 856)     <- far zone
[3]  ~pos=(-40, -8, -104)
[4]  ~pos=(8, 8, -88)
[5]  ~pos=(24, 8, -104)
[6]  ~pos=(24, 8, -88)
[7]  ~pos=(40, 24, -88)
[8]  ~pos=(88, 24, -40)
[9]  ~pos=(-72, 24, 40)
[10] ~pos=(40, 24, -72)
[11] ~pos=(40, 24, -8)
[12] ~pos=(8, 24, 8)
[13] ~pos=(24, 8, -24)
[14] ~pos=(56, 24, 8)
[15] ~pos=(8, 8, -40)
[16] ~pos=(-56, 24, 8)
[17] ~pos=(8, 24, 40)
[18] ~pos=(-8, 24, 88)
```

### luke (7 entities)
```
[1]  ~pos=(-24, 8, -120)
[2]  ~pos=(-40, 24, -120)
[3]  ~pos=(72, 56, -40)       <- near current play area
[4]  ~pos=(8, 8, -72)
[5]  ~pos=(24, 8, -56)
[6]  ~pos=(-8, 24, 56)
[7]  ~pos=(-88, 24, 88)
```

### mandalorian (8 entities)
```
[1]  ~pos=(88, 56, -40)       <- near current play area
[2]  ~pos=(-72, 24, 40)
[3]  ~pos=(-24, 24, 8)
[4]  pos=(0.0, 0.0, 1.1)     <- near spawn!
[5]  pos=(0.0, 0.0, 0.1)     <- near spawn!
[6]  ~pos=(24, 24, -24)
[7]  ~pos=(8, 24, 40)
[8]  ~pos=(-72, 24, 104)
```

### teacher (2 entities)
```
[1]  ~pos=(72, 24, -56)
[2]  ~pos=(-88, 24, 56)
```

### yoda (5 entities)
```
[1]  ~pos=(72, 56, -40)       <- near current play area
[2]  ~pos=(-24, 24, -8)
[3]  ~pos=(-8, 24, -8)
[4]  ~pos=(24, 8, -40)
[5]  ~pos=(-8, 24, 56)
```

## Player Progress (from mod_storage.sqlite)

### gabo

| Field | Value |
|-------|-------|
| First join | 2026-02-15 15:02 |
| NPCs met | 1 (mandalorian) |
| Quests completed | 0 |
| Achievements | none |

**Active quests:**
| Quest | NPC | Type | Progress |
|-------|-----|------|----------|
| `mando_main_1` | Mandalorian | collect | 0/12 |
| `mando_side_bounty` | Mandalorian | collect | 0/6 |

**NPC Relationships:**
| NPC | Level | XP | Talks | Trades | Quests Done |
|-----|-------|----|-------|--------|-------------|
| Mandalorian | 0 (desconocido) | 5 | 1 | 0 | 0 |

### pepelomo

| Field | Value |
|-------|-------|
| First join | 2026-02-15 15:05 |
| NPCs met | 6 (luke, anakin, yoda, mandalorian, leia, farmer) |
| Quests completed | **6** |
| Achievements | `quest_novice` ("Aprendiz de Aventuras") |

**Completed quests (6):**
| Quest | NPC | Completed at |
|-------|-----|-------------|
| `luke_main_1` | Luke | 15:08 |
| `yoda_main_1` | Yoda | 15:10 |
| `leia_side_supplies` | Leia | 15:12 |
| `anakin_main_1` | Anakin | 15:14 |
| `mando_side_bounty` | Mandalorian | 15:17 |
| `farmer_main_1` | Farmer | 15:22 |

**Active quests:** None (all completed!)

**Side quest cooldowns:** `leia_side_supplies`, `mando_side_bounty`

**NPC Relationships:**
| NPC | Level | XP | Talks | Quests Done |
|-----|-------|----|-------|-------------|
| Luke | 0 | 25 | 0 | 1 |
| Anakin | 0 | 25 | 0 | 1 |
| Yoda | 0 | 30 | 1 | 1 |
| Mandalorian | 0 | 25 | 0 | 1 |
| Leia | 0 | 25 | 0 | 1 |
| Farmer | 0 | 25 | 0 | 1 |

**NPCs not yet met:** librarian, teacher, explorer

## Zone Analysis

The NPCs are spread across 3 distinct zones:

### Zone 1: Current Play Area (~pos 70-90, 50-56, -55 to -40)
Active zone where gabo and pepelomo are playing. Contains the 5 NPCs seen in recent logs:
- luke (obj#3703)
- mandalorian (obj#3284)
- yoda (obj#3283)
- leia (obj#3702)
- anakin (obj#3704)

### Zone 2: Near Spawn (0, 0, 0 to 100, 24, 150)
Most duplicate NPCs are scattered across this wider area. Likely leftover from earlier spawn egg testing.

### Zone 3: Far Zone (-1800, 8, 850 to -1700, 8, 990)
Cluster of 8 explorers + 2 librarians + 1 anakin. Appears to be an old exploration area.

## Diagnosis

### Root Cause of Duplicates
The mod registers NPC types but provides **no spawn management**. NPCs are placed manually via creative inventory spawn eggs. Each placement creates a new independent entity. There is no deduplication logic.

### Current Protection System
```lua
-- do_punch callback in npc_registry.lua
-- Players with "server" privilege CAN kill NPCs (admin mode)
-- Regular players get blocked with a friendly message
if minetest.check_player_privs(player_name, {server = true}) then
    -- Admin CAN kill - sets fleshy=100 for 1 second
    self._admin_punching = true
    self.object:set_armor_groups({fleshy = 100})
    -- ... reverts after 1 second
end
```

**Problem:** User `gabo` has `server` privilege and CAN accidentally kill NPCs by punching them. This is how duplicates got eliminated before but also how accidental kills happen.

## Recommendations

1. **Cleanup duplicates**: Keep only 1 NPC per type in the play area. Remove 66 duplicates.
2. **Anti-duplicate spawn**: Add logic to prevent spawning if one of the same type already exists.
3. **Admin protection toggle**: Change kill behavior so admins need a special tool or command, not bare-hand punch.
4. **Spawn point registry**: Define fixed spawn positions for each NPC so they respawn correctly after cleanup.

## Scan Technical Notes

- Compression: mapblock format v29, zstd compressed
- Decompression success: 174,373 / 2,257,422 (7.7%) - many blocks use older format versions
- The 75 found entities are a minimum count; there may be more in blocks that couldn't be decompressed
- Positions marked `~pos` are approximate (mapblock center, +/- 8 nodes)
- Positions marked `pos` are precise (extracted from static object header)
