---
name: add-music
description: Add a new music disc to the wetlands-music mod. Use when adding songs, music tracks, or audio to the Luanti server jukebox system.
argument-hint: [youtube-url-or-file] [track-name] [artist]
disable-model-invocation: true
allowed-tools: Bash(ffmpeg *), Bash(python *), Bash(magick *), Bash(dir *), Read, Edit, Write, Glob, Grep
---

# Add Music Disc to Wetlands

Guide Claude through adding a new music disc to the `wetlands-music` mod.

## Process

### 1. Gather Information

Ask the user for:
- **Source**: YouTube URL or local audio file path
- **Track name**: Display name for the disc (e.g., "Peaceful Meadow")
- **Artist**: Composer/artist name
- **Identifier**: Auto-generate from track name (lowercase, underscores). Example: "Peaceful Meadow" -> `peaceful_meadow`

### 2. File Naming Convention

- Audio: `wetlands_music_[identifier].ogg` -> goes in `server/mods/wetlands-music/sounds/`
- Texture: `wetlands_music_record_[identifier].png` -> goes in `server/mods/wetlands-music/textures/`

### 3. Download & Convert (if YouTube URL)

```bash
# Download from YouTube
python -m yt_dlp -x --audio-format vorbis --audio-quality 5 "[URL]" -o "temp_[identifier].%(ext)s"

# Convert to OGG Vorbis (YouTube often gives WebM)
ffmpeg -i "temp_[identifier].webm" -c:a libvorbis -q:a 5 "server/mods/wetlands-music/sounds/wetlands_music_[identifier].ogg"
```

If local file:
```bash
ffmpeg -i "[input-file]" -c:a libvorbis -q:a 5 "server/mods/wetlands-music/sounds/wetlands_music_[identifier].ogg"
```

### 4. Create Texture

Copy an existing texture as base or create with ImageMagick:
```bash
# Quick: copy existing
cp server/mods/wetlands-music/textures/wetlands_music_record_karu_beats.png server/mods/wetlands-music/textures/wetlands_music_record_[identifier].png

# Custom: create with ImageMagick (16x16 PNG)
magick -size 16x16 xc:none -fill black -draw "circle 8,8 8,2" -fill [color] -draw "circle 8,8 8,3" wetlands_music_record_[identifier].png
```

### 5. Register in init.lua

Read `server/mods/wetlands-music/init.lua` first, then add before the final log message:

```lua
-- Disc N: [Track Name] ([Artist])
mcl_jukebox.register_record(
	"[Track Name]",
	"[Artist]",
	"wetlands_[identifier]",
	"wetlands_music_record_[identifier].png",
	"wetlands_music_[identifier]"
)
```

### 6. Update mod metadata

- Increment version in `mod.conf`
- Update disc count in the log message in `init.lua`

### 7. Verification Checklist

Before finishing, verify:
- [ ] OGG file exists in `sounds/` and is under 5MB
- [ ] PNG texture exists in `textures/` and is 16x16
- [ ] Registration added to `init.lua` with unique identifier
- [ ] No duplicate identifiers
- [ ] Version bumped in `mod.conf`
- [ ] Disc count updated in log message

### 8. Provide Commit Message

Suggest a commit message (user commits manually per CLAUDE.md):
```
feat(music): Add '[Track Name]' by [Artist]

Disc N/total - [brief description]
- Duration: X:XX
- Quality: OGG Vorbis ~160 kbps
```

Clean up any temporary files.
