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

### Option B: Download from a skin site

**Use the one-liner — it downloads, validates, keeps the 64x64 original and
converts to 64x32 in one step:**

```bash
./scripts/fetch-skin.sh <fuente> <salida_64x32.png> [original_64x64.png]
```

| Prefix | Site | Example |
|---|---|---|
| `msn:<slug>` | www.minecraftskins.net | `./scripts/fetch-skin.sh msn:trendyguy out.png raw.png` |
| `mcs:<slug>` | mc-skins.net | `./scripts/fetch-skin.sh mcs:yellow-raincoat-boy-6f72ef out.png raw.png` |
| `player:<name>` | mc-heads.net (real account's skin) | `./scripts/fetch-skin.sh player:Dinnerbone out.png raw.png` |
| `uuid:<uuid>` | crafatar.com | — |
| `https://…` | direct PNG URL | — |

**Always pass the third argument** (the 64x64 original). It is the only copy
of the full overlay layer and lets you re-convert later without the site.

#### Sites that CANNOT be automated

`minecraftskins.com` (**the Skindex**), `namemc.com`, `planetminecraft.com`,
`skinmc.net`, `novaskin.me` and `needcoolshoes.com` all answer **403** to
programmatic access — Cloudflare's bot wall. It is not a user-agent problem
and **a Playwright-controlled browser does not get through either** (verified
2026-10-30). Do not burn turns retrying them.

The Skindex is the biggest catalogue and the one that is blocked. When the
user wants a skin from there: they open it in their own browser, download the
PNG, and you convert it directly:

```bash
python scripts/convert-skin.py ~/Downloads/whatever.png destination_64x32.png
```

#### Browsing the two catalogues that do respond

Listing pages are plain HTML, no JS:

```bash
# categories: people, fantasy, games, mobs, movies, tv, other
curl -s https://www.minecraftskins.net/category/people | grep -oE 'href="/[a-z0-9]+"' | sort -u
```

The slug is what goes after `msn:`. Previews live at
`/static/front_preview/<slug>.png` and `/static/head/<slug>.png` — read those
with the Read tool to see a skin before downloading it.

Suggest search terms aligned with Wetlands values (children 7+):
- **For NPCs**: farmer, librarian, teacher, explorer, veterinarian, scientist, gardener, chef
- **For players**: panda, animal lover, nature, gardener, peaceful, creative
- **For background pedestrians** (`valdivia_transeuntes`): ordinary clothes
  only, and **no recognizable character** — no Spiderman, Ronaldo, Herobrine
  or anime cameos. Half of `category/people` is licensed characters; filter by
  slug name before downloading.

Full source matrix and rationale: `docs/00-SHARED/mods/SKIN_SOURCES.md`.

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

#### Method 1 (DEFAULT — use this): `scripts/convert-skin.py`, headless

```bash
python scripts/convert-skin.py source_64x64.png output_64x32.png
```

Does exactly what godly's Copy Jacket / Copy Sleeve / Copy Trouser buttons do
at alpha 1.0 — bakes the three right-side overlay regions onto the base before
cropping — with **no browser, no Playwright, and no state carried between
files**. It prints what it found, which is also your check:

```
3/3 regiones de overlay horneadas    <- a plain crop would have broken this one
0/3 regiones de overlay horneadas    <- no overlay; a crop would have been fine
ya era 64x32                         <- legacy skin, copied through untouched
```

In the 2026-10-30 pilot, 5 of 6 skins had real overlay. **Assume there is
overlay**; the script tells you when there isn't.

`./scripts/fetch-skin.sh` already calls this for you — you only run the
converter by hand for a PNG the user downloaded themselves.

**Known limitation**: 64x32 has no separate left arm/leg — it mirrors the
right side. A 64x64 with left/right asymmetry (a patch on one sleeve only)
loses it. That is the format, not a bug.

**Verify visually before committing:**
```bash
python scripts/render-skin-front.py <folder_of_64x32> sheet.png
```
Then Read `sheet.png` — it renders a front-facing figure per skin at 4x.

#### Method 1b (fallback if the script output looks wrong): godly via Playwright

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

#### Method 2 (last resort, ONLY for skins without overlay): top-half crop

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
   Use `scripts/convert-skin.py` (Method 1) for every skin — it bakes the
   overlay and tells you how many regions it found. The crop is safe only for
   plain characters where the bottom 32 rows of the 64x64 are transparent.
7. **If you fall back to godly, ALWAYS refresh the page** between files. The
   destination canvas accumulates overlays from prior sessions; loading a new
   file via the chooser does NOT reset it. Use `browser_navigate` to the
   converter URL again to get a clean state. (`scripts/convert-skin.py` has no
   such state — another reason it is the default.)
8. **Don't waste turns on the Skindex.** `minecraftskins.com` and five other
   galleries return 403 to any automated fetch, browser included. Ask the user
   to download the PNG by hand, or use a site from the table in "Option B".
9. **Always keep the 64x64 original** next to the converted 64x32 (in
   `raw_skins/` for mods, `server/skins/` for player skins). The 64x32 has
   already lost the left-side and unbaked overlay data — it cannot be undone.
