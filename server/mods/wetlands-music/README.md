# Wetlands Music - Custom Music Discs

Custom music discs mod for the Wetlands Luanti/VoxeLibre server. This mod adds educational and compassionate-themed music tracks that can be played in VoxeLibre's jukeboxes.

## Features

- Custom music discs with unique tracks
- Compatible with VoxeLibre's jukebox system
- Educational and compassionate themes aligned with Wetlands philosophy
- Easy to add new music tracks

## Current Music Discs

### 1. Karu Beats
- **Artist**: Wetlands Music Collection
- **Identifier**: `wetlands_karu_beats`
- **File**: `wetlands_music_karu_beats.ogg`
- **Description**: An ambient, relaxing track perfect for exploring the sanctuary

## Technical Specifications

### Audio Format
- **Format**: OGG Vorbis (.ogg)
- **Recommended Quality**: 128-192 kbps
- **File Size**: 500KB - 4MB recommended
- **Naming Convention**: `wetlands_music_[identifier].ogg`

### Texture Format
- **Format**: PNG (RGBA)
- **Size**: 16x16 pixels
- **Naming Convention**: `wetlands_music_record_[identifier].png`
- **Location**: `textures/`

### File Structure
```
wetlands-music/
├── mod.conf              # Mod configuration
├── init.lua              # Main mod logic
├── README.md             # This file
├── sounds/               # Audio files (.ogg)
│   └── wetlands_music_karu_beats.ogg
└── textures/             # Disc textures (16x16 PNG)
    └── wetlands_music_record_karu_beats.png
```

## Adding New Music Discs

### Step 1: Prepare Audio File
1. Convert your audio to OGG Vorbis format
2. Optimize for web (128-192 kbps recommended)
3. Name it: `wetlands_music_[unique_identifier].ogg`
4. Place in `sounds/` directory

### Step 2: Create Texture
1. Create a 16x16 pixel PNG image
2. Use RGBA format with transparency if needed
3. Name it: `wetlands_music_record_[unique_identifier].png`
4. Place in `textures/` directory

### Step 3: Register the Disc
Add the following code to `init.lua`:

```lua
mcl_jukebox.register_record(
    "Track Title",                              -- Song title
    "Artist Name",                              -- Artist/composer
    "unique_identifier",                        -- Unique ID (lowercase, underscores)
    "wetlands_music_record_unique_identifier.png", -- Texture filename
    "wetlands_music_unique_identifier"          -- Sound filename (without .ogg)
)
```

## Usage In-Game

1. **Craft or obtain a jukebox** (if not in creative mode)
2. **Obtain a Wetlands music disc** from creative inventory or as a gift
3. **Right-click the jukebox** with the disc to insert and play
4. **Right-click again** to eject the disc
5. **Enjoy the music!** Only you can hear it (personal audio stream)

## Finding Wetlands Music Discs

In creative mode:
1. Open inventory (default: `I` key)
2. Search for "Wetlands" or "Karu Beats"
3. Find in the "Misc" or "Music" category

In survival mode:
- Discs can be given by server admins
- Future updates may include crafting recipes or treasure chests

## Dependencies

- **mcl_jukebox** (required) - VoxeLibre's jukebox system
- **mcl_core** (optional) - VoxeLibre core items

## Compatibility

- **Game**: VoxeLibre v0.90.1+
- **Engine**: Luanti 5.13+
- **Tested**: Wetlands Server (luanti.gabrielpantoja.cl:30000)

## Credits

### Mod Development
- **Developer**: Gabriel Pantoja
- **Project**: Wetlands Educational Server
- **License**: GPL v3.0

### Music Sources
Music tracks should be:
- Royalty-free or properly licensed
- CC-BY, CC0, or public domain recommended
- Attribution provided in track metadata

### Current Tracks
1. **Karu Beats** - [Source/Artist information]

## License

GPL v3.0 - See project root LICENSE file

## Support

For questions, suggestions, or new music submissions:
- Server: luanti.gabrielpantoja.cl:30000
- GitHub: github.com/gabrielpantoja-cl/luanti-voxelibre-server

## Roadmap

- [ ] Add more compassionate-themed tracks
- [ ] Create unique textures for each disc
- [ ] Add Spanish translations
- [ ] Educational track descriptions
- [ ] In-game music disc trader NPC
- [ ] Crafting recipes for survival mode

## Version History

### v1.0.0 (2025-10-19)
- Initial release
- Added Karu Beats music disc
- VoxeLibre jukebox integration
- Basic mod structure
