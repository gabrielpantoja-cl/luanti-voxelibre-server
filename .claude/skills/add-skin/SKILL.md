---
name: add-skin
description: Add a custom player skin to the Wetlands server. Use when a player needs a new skin added.
argument-hint: [player-name] [skin-file-path]
disable-model-invocation: true
allowed-tools: Bash(magick *), Bash(python *), Bash(dir *), Read, Write, Glob
---

# Add Player Skin to Wetlands

Add a custom skin for a player on the Wetlands server.

## Requirements

- Skin format: **64x32 PNG** (Luanti skin format)
- No transparency issues
- Appropriate for children 7+

## Process

### 1. Gather Information

- **Player name**: Exact Luanti username (case-sensitive)
- **Skin file**: Path to the PNG skin file

### 2. Validate Skin

Check the skin file:
```bash
magick identify [skin-file]
```
Must be: 64x32 pixels, PNG format.

If skin is Minecraft format (64x64), it needs conversion to 64x32.

### 3. Place Skin File

Copy to skins directory with correct naming:
```
server/skins/player_[username].png
```

File naming is lowercase: `player_[username].png`

### 4. Verify

Check the file exists and is correct format:
```bash
dir server\skins\player_[username].png
```

### 5. Provide Commit Message

```
feat(skins): Add custom skin for player [username]
```

## Notes

- Player must reconnect to see the new skin
- Server restart is NOT required for skin changes
- See `docs/admin/QUICK_ADD_SKINS.md` for detailed reference
