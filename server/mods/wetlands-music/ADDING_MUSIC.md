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

## 🎯 Caso de Estudio Real: "Juegazos" de Chyste MC

Este es un ejemplo real de cómo agregamos rap chileno al servidor (Enero 2026).

### Contexto
- **Canción**: "Juegazos" - Chyste MC (rap chileno)
- **Fuente**: YouTube (https://www.youtube.com/watch?v=mkUSaxgA6lI)
- **Objetivo**: Agregar música urbana chilena al servidor
- **Textura**: Basada en logo de Gran Rah (productora)

### Proceso Completo Paso a Paso

#### 1. Instalación de Herramientas (Una vez)

```powershell
# Instalar yt-dlp para descargar de YouTube
pip install yt-dlp

# Instalar ffmpeg (PowerShell como Administrador)
choco install ffmpeg -y
```

#### 2. Descarga de YouTube con yt-dlp

```bash
# Descargar audio de YouTube en formato OGG directamente
python -m yt_dlp -x --audio-format vorbis --audio-quality 5 "https://www.youtube.com/watch?v=mkUSaxgA6lI" -o "temp_juegazos.%(ext)s"
```

**Resultado**: `temp_juegazos.webm` (3.8MB) - yt-dlp descarga en WebM por limitaciones de YouTube

#### 3. Conversión a OGG Vorbis con ffmpeg

```bash
# Convertir WebM a OGG Vorbis con calidad 5 (~160 kbps)
cd C:\Users\gabri\Developer\luanti-voxelibre-server
ffmpeg -i temp_juegazos.webm -c:a libvorbis -q:a 5 server/mods/wetlands-music/sounds/wetlands_music_juegazos.ogg
```

**Resultado**:
- Archivo: `wetlands_music_juegazos.ogg`
- Tamaño: 4.1MB
- Duración: 3:47
- Calidad: 160 kbps, stereo, 48000 Hz

#### 4. Creación de Textura 16x16 con ImageMagick

```bash
# Crear textura basada en logo Gran Rah (círculo con letras "GR")
cd server/mods/wetlands-music/textures
magick -size 16x16 xc:none -fill black -draw "circle 8,8 8,2" -fill white -draw "circle 8,8 8,3" -fill black -pointsize 8 -gravity center -annotate +0-1 "GR" wetlands_music_juegazos.png
```

**Resultado**:
- Archivo: `wetlands_music_juegazos.png`
- Tamaño: 669 bytes
- Dimensiones: 16x16 píxeles
- Formato: PNG con transparencia

#### 5. Registro en init.lua

```lua
-- Disc 11: Juegazos (Chyste MC - Rap Chileno)
mcl_jukebox.register_record(
	"Juegazos",
	"Chyste MC",
	"wetlands_juegazos",
	"wetlands_music_juegazos.png",
	"wetlands_music_juegazos"
)
```

#### 6. Actualizar Metadatos

**En `mod.conf`**:
```ini
version = 2.2.0
description = Custom music discs for Wetlands server... 11 unique discs with optimized 16x16 textures, including Chilean rap (Chyste MC).
```

**En `init.lua`**:
```lua
-- Version: 2.2.0
minetest.log("action", "[wetlands_music] Successfully registered 11 custom music discs")
```

#### 7. Limpieza y Verificación

```bash
# Eliminar archivos temporales
rm temp_juegazos.webm

# Verificar archivos finales
ls -lh server/mods/wetlands-music/sounds/wetlands_music_juegazos.ogg
ls -lh server/mods/wetlands-music/textures/wetlands_music_juegazos.png

# Verificar formato y calidad
file server/mods/wetlands-music/sounds/wetlands_music_juegazos.ogg
# Output: Ogg data, Vorbis audio, stereo, 48000 Hz, ~160000 bps
```

#### 8. Commit y Deploy

```bash
# Agregar todos los cambios
git add server/mods/wetlands-music/

# Commit descriptivo
git commit -m "feat(music): Agrega 'Juegazos' de Chyste MC - Rap chileno

Disco 11/11 - Tema de rap chileno para diversificar la colección musical.
- Artista: Chyste MC
- Duración: 3:47
- Textura: Logo Gran Rah adaptado a 16x16
- Descarga: YouTube con yt-dlp + ffmpeg
- Calidad: OGG Vorbis 160 kbps"

# Push cuando los jugadores hayan salido
git push origin main
```

### Lecciones Aprendidas

**✅ Buenas Prácticas**:
1. **Siempre usar yt-dlp** en lugar de youtube-dl (más actualizado)
2. **Convertir a OGG Vorbis** aunque yt-dlp descargue WebM
3. **Usar calidad 5** en ffmpeg (~160 kbps) - buen balance tamaño/calidad
4. **Texturas 16x16** son obligatorias para rendimiento óptimo
5. **ImageMagick** es excelente para crear texturas programáticamente

**⚠️ Problemas Comunes Resueltos**:

1. **Error "ffmpeg not found"**:
   - Solución: Instalar con `choco install ffmpeg -y` (requiere admin)

2. **Error "No such file or directory"**:
   - Causa: Ejecutar comando desde directorio incorrecto
   - Solución: Siempre `cd` al directorio del proyecto primero

3. **YouTube descarga WebM en lugar de audio directo**:
   - Normal: YouTube limita formatos desde 2024
   - Solución: Usar ffmpeg para convertir WebM → OGG

4. **Permisos de administrador en Windows**:
   - PowerShell: Click derecho → "Ejecutar como administrador"
   - Solo necesario para instalar herramientas, no para usarlas

### Tiempos Estimados

- Instalación de herramientas: 5-10 minutos (una sola vez)
- Descarga de YouTube: 30 segundos - 2 minutos
- Conversión a OGG: 10-30 segundos
- Creación de textura: 5-15 minutos (si es personalizada)
- Registro en código: 2-5 minutos
- Testing: 5 minutos
- **Total**: ~20-30 minutos por canción nueva

### Recursos y Referencias

**Herramientas Usadas**:
- **yt-dlp**: https://github.com/yt-dlp/yt-dlp (descarga de YouTube)
- **ffmpeg**: https://ffmpeg.org/ (conversión de audio)
- **ImageMagick**: https://imagemagick.org/ (creación de texturas)
- **Chocolatey**: https://chocolatey.org/ (gestor de paquetes Windows)

**Comandos de Instalación Rápida**:
```powershell
# PowerShell como Administrador
choco install ffmpeg imagemagick -y

# PowerShell normal
pip install yt-dlp
```

**Verificar Instalaciones**:
```bash
python -m yt_dlp --version    # Debe mostrar: 2025.12.08 o superior
ffmpeg -version               # Debe mostrar: 8.0.1 o superior
magick -version               # Debe mostrar: 7.1.2 o superior
```

---

**Happy music making! 🎶**
