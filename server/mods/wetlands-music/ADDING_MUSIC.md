# Quick Guide: Adding New Music to Wetlands

This guide will help you quickly add new music tracks to the Wetlands server.

## 🎵 Step-by-Step Process

### 1. Prepare Your Audio File

**Requirements:**
- Format: **OGG Vorbis** (.ogg)
- Quality: 128-192 kbps recommended
- Length: 1-5 minutes ideal
- Size: Under 4MB preferred

**Converting to OGG:**

Using **ffmpeg** (recommended):
```bash
# Convert MP3 to OGG
ffmpeg -i input.mp3 -c:a libvorbis -q:a 5 output.ogg

# Convert from any format
ffmpeg -i input.wav -c:a libvorbis -b:a 160k output.ogg
```

Using **Audacity** (GUI):
1. Open your audio file
2. File → Export → Export as OGG
3. Choose quality: 5-7 (corresponds to ~128-192 kbps)
4. Save

### 2. Name Your Files

Choose a unique identifier (lowercase, underscores only):
- ✅ Good: `peaceful_meadow`, `sanctuary_song`, `compassion_melody`
- ❌ Bad: `Track1`, `MyMusic`, `song-with-dashes`

**File naming:**
- Audio: `wetlands_music_[identifier].ogg`
- Texture: `wetlands_music_record_[identifier].png`

**Example:**
- Identifier: `peaceful_meadow`
- Audio: `wetlands_music_peaceful_meadow.ogg`
- Texture: `wetlands_music_record_peaceful_meadow.png`

### 3. Create or Use a Texture

**Option A: Use existing texture (quick)**
```bash
# Copy an existing disc texture
cp textures/wetlands_music_record_karu_beats.png \
   textures/wetlands_music_record_peaceful_meadow.png
```

**Option B: Create custom texture**

Requirements:
- Size: exactly 16x16 pixels
- Format: PNG with RGBA
- Recommended tools: GIMP, Aseprite, Pixelorama

Textures can be:
- Different colored discs
- Unique patterns
- Thematic designs (animals, plants, etc.)

### 4. Add Files to Mod

```bash
# Place audio file
cp your_music.ogg server/mods/wetlands-music/sounds/wetlands_music_peaceful_meadow.ogg

# Place texture file
cp your_texture.png server/mods/wetlands-music/textures/wetlands_music_record_peaceful_meadow.png
```

### 5. Register the Music Disc

Edit `server/mods/wetlands-music/init.lua` and add:

```lua
-- Wetlands Custom Disc: Peaceful Meadow
mcl_jukebox.register_record(
    "Peaceful Meadow",                          -- Track title (shown in-game)
    "Nature Sounds Collection",                 -- Artist/composer name
    "wetlands_peaceful_meadow",                 -- Unique identifier
    "wetlands_music_record_peaceful_meadow.png", -- Texture filename
    "wetlands_music_peaceful_meadow"            -- Sound filename (no .ogg)
)
```

### 6. Test Locally

```bash
# Start local server
./scripts/start.sh

# Connect to localhost:30000
# Check server logs for errors
docker-compose logs -f luanti-server | grep wetlands_music
```

**In-game testing:**
1. Open creative inventory (`I` key)
2. Search for your track name (e.g., "Peaceful Meadow")
3. Place a jukebox
4. Right-click jukebox with disc
5. Music should play!

### 7. Deploy to Production

```bash
# Commit changes
git add server/mods/wetlands-music/
git commit -m "feat(music): Add Peaceful Meadow disc"
git push

# GitHub Actions will automatically deploy to VPS
# Check deployment status on GitHub Actions tab
```

## 🎨 Creative Tips

### Music Themes for Wetlands
- **Nature sounds**: Forest ambience, rain, ocean waves
- **Calm melodies**: Piano, acoustic guitar, flute
- **Ambient music**: Relaxing electronic, meditation music
- **Educational**: Songs about animals, compassion, sustainability
- **Cultural**: World music, traditional instruments

### Texture Ideas
- **Color coding**: Different colors for different moods
  - Green: Nature/forest tracks
  - Blue: Water/ocean themes
  - Orange: Warm/uplifting music
  - Purple: Calm/meditation

- **Thematic icons**: Small 16x16 symbols
  - Trees for forest tracks
  - Water drops for ocean themes
  - Hearts for compassionate themes
  - Animals for sanctuary music

### Music Sources (Royalty-Free)

**Recommended sites:**
- **FreePD.com**: Public domain music
- **Incompetech**: CC-BY (attribution required)
- **ccMixter**: Various CC licenses
- **Jamendo**: Indie artists with open licenses
- **YouTube Audio Library**: Free music with attribution

**Always check:**
- License allows commercial use (server hosting)
- Attribution requirements (add to track metadata)
- Modifications allowed (converting to OGG)

## 📋 Checklist

Before deploying a new track:

- [ ] Audio is in OGG Vorbis format
- [ ] File size is reasonable (< 4MB)
- [ ] Audio quality is good (no distortion, clear sound)
- [ ] Texture is 16x16 PNG
- [ ] Files follow naming convention
- [ ] init.lua registration added with unique identifier
- [ ] No typos in filenames or identifiers
- [ ] Music license allows use (royalty-free/CC)
- [ ] Attribution provided if required
- [ ] Tested locally before deploying
- [ ] Committed with descriptive message

## 🐛 Troubleshooting

**Music disc doesn't appear in-game:**
- Check server logs: `docker-compose logs luanti-server | grep wetlands_music`
- Verify mod loaded: Look for "wetlands_music loaded successfully"
- Check identifier uniqueness (no duplicates)
- Verify file paths match exactly

**Music doesn't play:**
- Check sound file exists in `sounds/` folder
- Verify filename matches (case-sensitive!)
- Check OGG format: `file sounds/wetlands_music_*.ogg`
- Test audio file: `ffplay sounds/wetlands_music_*.ogg`

**Texture missing (purple/pink square):**
- Check texture exists in `textures/` folder
- Verify PNG format: `file textures/wetlands_music_record_*.png`
- Check size: `identify textures/wetlands_music_record_*.png` (should be 16x16)

**Server won't start:**
- Check Lua syntax errors in init.lua
- Verify all strings properly quoted
- Check for missing commas in register_record calls
- Review logs: `docker-compose logs luanti-server`

## 🔧 Advanced: Batch Adding

If you have multiple tracks to add:

```bash
#!/bin/bash
# Script to batch process music tracks

for file in source_music/*.mp3; do
    # Extract filename without extension
    filename=$(basename "$file" .mp3)
    identifier=$(echo "$filename" | tr '[:upper:]' '[:lower:]' | tr ' ' '_')

    # Convert to OGG
    ffmpeg -i "$file" -c:a libvorbis -q:a 5 \
        "server/mods/wetlands-music/sounds/wetlands_music_${identifier}.ogg"

    # Copy reference texture
    cp server/mods/wetlands-music/textures/wetlands_music_record_karu_beats.png \
       "server/mods/wetlands-music/textures/wetlands_music_record_${identifier}.png"

    echo "Processed: $filename → $identifier"
done
```

Then manually edit `init.lua` to register each track.

## 📞 Need Help?

- Check existing tracks in init.lua for reference
- Review README.md for technical details
- Test in local environment first
- Ask server admin (Gabriel) for assistance

---

**Happy music making! 🎶**
