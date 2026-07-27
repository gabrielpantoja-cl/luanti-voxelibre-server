---
name: add-skin
description: Add or find skins/textures for the Wetlands server. Handles player skins (64x32) and NPC villager textures (64x64). Use when adding skins, searching for skins on MinecraftSkins.com, or updating NPC textures.
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

**The 64x64 Minecraft format has TWO layers** stacked into a single file:
**base** (the character's "undershirt") and **overlay** (armor, helmet, cape,
jackets, sleeves, trousers — painted on top with alpha). A naive top-half crop
keeps only the base and **silently discards every overlay pixel** — armor
becomes invisible, helmets disappear, capes vanish.

Real example from GAELSIN (2026-07-26): `mandalorian` lost its helmet and
`diamond_armor` lost its chestplate after a simple `crop((0,0,64,32))`.

#### Method 1 (Recommended for ANY skin with armor/helmet/cape/clothing overlay): godly via Playwright

**godly Minetest Skin Converter** (<https://godly.github.io/minetest-skin-converter/>,
GPLv3, 18★ on GitHub, runs 100% in the browser) does the right thing: it
copies the overlay regions (cape, jacket, sleeves, trousers) onto the base
with controllable alpha per region. This is the only method that recovers
the full Minecraft skin.

The MCP server `playwright` is configured at `.mcp.json` (project root) for
this. Drive godly programmatically with these steps:

1. **Navigate** to the converter:
   ```
   browser_navigate https://godly.github.io/minetest-skin-converter/
   ```

2. **Click the file input** to open the chooser, then upload the 64x64 PNG:
   ```
   browser_evaluate(() => document.querySelector('input[type=file]').click())
   browser_file_upload(paths=["/abs/path/to/source_64x64.png"])
   ```
   The source canvas updates automatically once the file loads.

3. **Set ALL alpha inputs to `1.0`** (the page defaults to `0.5` which makes
   overlays semi-transparent — wrong for faithful conversion):
   ```js
   ['alphaJacket','alphaTrouserLeft','alphaTrouserRight','alphaSleeveLeft','alphaSleeveRight']
     .forEach(id => { const el = document.getElementById(id); if (el) el.value = '1.0'; });
   ```
   Apply via `browser_evaluate`.

4. **Click every Copy button in order** (each composes one overlay region
   onto the 64x32 output canvas):
   - Copy Cape
   - Copy Jacket
   - Copy Left Trouser
   - Copy Right Trouser
   - Copy Left Sleeve
   - Copy Right Sleeve

   Use `browser_click` with the button text. The 3D preview is irrelevant
   (it shows the base layer only); the real output is the top-left 64x32 image.

5. **Extract the resulting 64x32 PNG** as a data URL from the new-skin
   `<img>`, then decode and save:
   ```js
   const url = document.querySelector('img[alt^="Placeholder for new skin"]').src;
   // url is "data:image/png;base64,..." — strip prefix, base64-decode, write to disk
   ```
   The output is always 64x32 RGBA with overlays baked in.

6. **Re-load for the next skin**: `browser_navigate` the URL again to get a
   clean state, then repeat from step 2. (Loading a new file does NOT clear
   the destination canvas — the overlays accumulate on top of the previous
   skin's result. Always refresh between files.)

The Playwright session stores screenshots and console logs in
`.playwright-mcp/` (gitignored). Comparison images (lossy-crop vs godly
side-by-side) help the user see the improvement before deploying.

#### Method 2 (Fallback, ONLY for skins without overlay): top-half crop

If the Minecraft skin has **no armor, no helmet, no cape, no jacket** (a
plain character with only the base layer visible), a simple top-half crop
is enough. Use this method ONLY when you've inspected the 64x64 and
confirmed there is no overlay detail to recover.

```bash
magick [input.png] -crop 64x32+0+0 +repage [output.png]
```

Or in Python:
```python
from PIL import Image
Image.open('source_64x64.png').crop((0, 0, 64, 32)).save('output_64x32.png')
```

Heuristic to decide between methods: open the 64x64 and check if the
**bottom half** (rows 32-63) has any non-transparent pixels. If yes → godly
(Method 1). If empty → crop (Method 2) is safe.

Or use the automated script (uses top-half crop internally — only valid for
overlay-free skins):
```bash
./scripts/add-skin.sh [input.png] [clean_name] [male|female]
```

The script automatically:
- Detects 64x64 and converts to 64x32 via top-half crop
- Sanitizes the filename
- Copies to `server/worlds/world/_world_folder_media/textures/`
- Updates `skins.txt`

### Manual Process (if script unavailable on Windows)

1. **Convert** (if 64x64) — pick Method 1 or Method 2 above. Method 1 is
   the only correct one for overlay-bearing skins:
```bash
# Method 2 (crop) — overlay-free skins only
magick [input.png] -crop 64x32+0+0 +repage [clean_name].png
# Method 1 (godly) — see step-by-step in "Conversion from Minecraft" above
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
6. **Top-half crop LOSES the overlay layer.** A `crop((0,0,64,32))` of a
   Minecraft 64x64 keeps only the base layer and discards the armor, helmet,
   cape, jacket, sleeves, and trousers that were painted on top with alpha.
   Use godly (Method 1 in "Conversion from Minecraft" above) for any skin
   with visible overlay detail. The crop is safe only for plain characters
   where the bottom 32 rows of the 64x64 are entirely transparent.
7. **When reprocessing a skin, ALWAYS refresh the godly page** between
   files. The destination canvas accumulates overlays from prior sessions;
   loading a new file via the chooser does NOT reset it. Use
   `browser_navigate` to the converter URL again to get a clean state.
