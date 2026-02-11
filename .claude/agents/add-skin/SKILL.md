---
name: add-skin
description: Add or find skins/textures for the Wetlands server. Handles player skins (64x32) and NPC villager textures (64x64). Use when adding skins, searching for skins on MinecraftSkins.com, or updating NPC textures.
argument-hint: [player|npc] [name] [file-or-search-term]
disable-model-invocation: true
allowed-tools: Bash(magick *), Bash(python *), Bash(dir *), Bash(./scripts/add-skin.sh *), Read, Write, Edit, Glob, Grep, WebSearch, WebFetch
---

# Wetlands Skin & Texture Manager

Unified skill for managing player skins and NPC textures on the Wetlands server.

## Step 1: Determine the Target

Ask the user what they need:

- **Player skin**: A skin players can select with `/skin` in-game (64x32 PNG)
- **NPC texture**: A texture for a wetlands_npcs villager entity (64x64 PNG)

If the user says something like "buscar skin para el farmer" or "cambiar textura del NPC", it's an **NPC texture**.
If they say "agregar skin para [username]" or "nuevo skin de jugador", it's a **player skin**.

## Step 2: Source the Texture

### Option A: User provides a local file

Validate the file:
```bash
magick identify [file-path]
```

### Option B: Search for a skin online

Search MinecraftSkins.com for appropriate skins:
```
WebSearch: site:minecraftskins.com [search-term]
```

Suggest search terms aligned with Wetlands values (children 7+):
- **For NPCs**: farmer, librarian, teacher, explorer, veterinarian, scientist, gardener, chef
- **For players**: panda, animal lover, nature, gardener, peaceful, creative

Once a skin is found, the user downloads it. Minecraft skins from minecraftskins.com are always **64x64 PNG**.

### Option C: Generate a texture programmatically (NPC only)

For NPC textures, the project has `server/mods/wetlands_npcs/tools/generate_textures.py` which creates 64x64 textures using PIL/Pillow following the `mobs_mc_villager.b3d` UV map.

---

## BRANCH A: Player Skin (64x32)

### Format Requirements
- **64x32 pixels** PNG with RGBA
- Simple filename: lowercase, underscores only, NO hyphens
- Bad names crash `mcl_maps` mod

### Conversion from Minecraft (64x64 -> 64x32)

Crop the top half only:
```bash
magick [input.png] -crop 64x32+0+0 +repage [output.png]
```

Or use the automated script:
```bash
./scripts/add-skin.sh [input.png] [clean_name] [male|female]
```

The script automatically:
- Detects 64x64 and converts to 64x32
- Sanitizes the filename
- Copies to `server/worlds/world/_world_folder_media/textures/`
- Updates `skins.txt`

### Manual Process (if script unavailable on Windows)

1. **Convert** (if 64x64):
```bash
magick [input.png] -crop 64x32+0+0 +repage [clean_name].png
```

2. **Copy texture** to:
```
server/worlds/world/_world_folder_media/textures/[clean_name].png
```

3. **Register in skins.txt** at `server/worlds/world/skins.txt`:
```lua
  {
    texture = "[clean_name]",
    gender = "male"
  },
```
Note: `texture` field does NOT include `.png` extension.
Gender `"female"` = slim arms, `"male"` = normal arms.

4. **Also copy** to `server/skins/[clean_name].png` for Git tracking (reference copy).

### Verification
```bash
magick identify server/worlds/world/_world_folder_media/textures/[clean_name].png
```
Must show: `PNG 64x32`

### Deployment
- Server restart required: `docker-compose restart luanti-server`
- Or use: `./scripts/sync-skins-to-vps.sh` for VPS deployment
- Players use `/skin` command in-game to select

---

## BRANCH B: NPC Texture (64x64)

### Format Requirements
- **64x64 pixels** PNG with alpha channel
- Filename: `wetlands_npc_[type].png`
- Must follow `mobs_mc_villager.b3d` UV map layout
- Stored in `server/mods/wetlands_npcs/textures/`

### Using a Minecraft Skin Directly

Minecraft skins are already 64x64 -- **no conversion needed** for the NPC villager model! The UV map is compatible with `mobs_mc_villager.b3d`.

Simply rename and copy:
```bash
copy [downloaded_skin.png] server\mods\wetlands_npcs\textures\wetlands_npc_[type].png
```

### Existing NPC Types

Read `server/mods/wetlands_npcs/init.lua` to see current villager registrations:
- `wetlands_npc_farmer.png` - Agricultor
- `wetlands_npc_librarian.png` - Bibliotecario
- `wetlands_npc_teacher.png` - Maestro
- `wetlands_npc_explorer.png` - Explorador

### Replacing an Existing NPC Texture

Just overwrite the PNG file in `server/mods/wetlands_npcs/textures/`. No code changes needed.

### Adding a New NPC Type

This requires code changes in `server/mods/wetlands_npcs/init.lua`:

1. **Add texture** to `server/mods/wetlands_npcs/textures/wetlands_npc_[newtype].png`

2. **Add dialogues** in the `wetlands_npcs.dialogues` table:
```lua
[newtype] = {
    greetings = { "...", "...", },
    about_work = { "...", "...", },
    education = { "...", "...", },
},
```

3. **Add trades** in the `wetlands_npcs.trades` table:
```lua
[newtype] = {
    {give = "item_name count", wants = "mcl_core:emerald N"},
},
```

4. **Register the villager**:
```lua
register_custom_villager("[newtype]", {
    description = S("[Description] de Wetlands"),
    textures = {
        {"wetlands_npc_[newtype].png"}
    },
})
```

5. **Add to valid_types** in the `spawn_villager` command.

6. **Add sounds** (optional): 3 OGG files named `wetlands_npc_talk_[newtype]1.ogg` through `3.ogg`

### UV Map Reference (64x64 villager model)

```
Head:  front(8,8)-(16,16)  back(24,8)-(32,16)  top(8,0)-(16,8)
Body:  front(20,20)-(28,32) back(32,20)-(40,32) top(20,16)-(28,20)
Arms:  front(44,20)-(48,32) back(52,20)-(56,32) top(44,16)-(48,20)
Legs:  front(4,20)-(8,32)   back(12,20)-(16,32) top(4,16)-(8,20)
```

### Verification
```bash
magick identify server/mods/wetlands_npcs/textures/wetlands_npc_[type].png
```
Must show: `PNG 64x64`

---

## Commit Messages

**Player skin**:
```
feat(skins): Add [clean_name] player skin

- Format: 64x32 PNG
- Gender: [male/female]
- Source: [MinecraftSkins.com / custom / etc.]
```

**NPC texture (replace)**:
```
feat(npcs): Update [type] NPC texture

- New texture from [source]
- Format: 64x64 PNG, villager UV map compatible
```

**NPC texture (new type)**:
```
feat(npcs): Add [type] NPC to Wetlands

- Texture: wetlands_npc_[type].png (64x64)
- Dialogues: greetings, about_work, education
- Trades: [brief list]
```

## Common Pitfalls

1. **Hyphens in filenames** crash `mcl_maps` -- always use underscores
2. **Player skins MUST be 64x32** -- 64x64 will look corrupted on players
3. **NPC textures MUST be 64x64** -- 64x32 will look corrupted on villager model
4. **skins.txt texture field** omits `.png` extension
5. **World folder files** are NOT in Git -- also copy to `server/skins/` for tracking
