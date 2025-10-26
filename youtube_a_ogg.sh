#!/bin/bash
# -------------------------------------------------------------
# Script: youtube_a_ogg.sh
# Autor: Gabriel Pantoja (para uso con Claude Code en Linux Mint)
# Propósito: Descargar audio desde YouTube y convertirlo a .ogg
# Compatible con Minecraft y Luanti (Voxelibre)
# -------------------------------------------------------------

# Verifica dependencias
if ! command -v yt-dlp &> /dev/null; then
  echo "⚠️ yt-dlp no está instalado. Instalando..."
  sudo apt update && sudo apt install -y yt-dlp
fi

if ! command -v ffmpeg &> /dev/null; then
  echo "⚠️ ffmpeg no está instalado. Instalando..."
  sudo apt update && sudo apt install -y ffmpeg
fi

# Verifica si se pasó la URL
if [ -z "$1" ]; then
  echo "Uso: ./youtube_a_ogg.sh URL_DEL_VIDEO [NOMBRE_OPCIONAL]"
  echo "Ejemplo: ./youtube_a_ogg.sh https://www.youtube.com/watch?v=abcd1234 disco1"
  exit 1
fi

# Parámetros
URL="$1"
NOMBRE="${2:-audio_descargado}"  # si no se da nombre, usa 'audio_descargado'

# Carpeta de salida
SALIDA="./salida_ogg"
mkdir -p "$SALIDA"

echo "🎵 Descargando audio desde YouTube..."
yt-dlp -x --audio-format mp3 -o "$SALIDA/$NOMBRE.%(ext)s" "$URL"

# Verifica que el mp3 exista
MP3_FILE=$(find "$SALIDA" -type f -name "$NOMBRE.mp3")
if [ ! -f "$MP3_FILE" ]; then
  echo "❌ Error: no se pudo descargar el audio MP3."
  exit 1
fi

echo "🎧 Convirtiendo a formato OGG (mono, 44.1 kHz, Vorbis)..."
ffmpeg -y -i "$MP3_FILE" -ac 1 -ar 44100 -acodec libvorbis "$SALIDA/$NOMBRE.ogg"

# Elimina el MP3 original (opcional)
rm -f "$MP3_FILE"

echo "✅ Conversión completa."
echo "Archivo final: $SALIDA/$NOMBRE.ogg"
echo ""
echo "📂 Copia este archivo a la carpeta de tu mod:"
echo "   mods/tu_mod/sounds/$NOMBRE.ogg"
echo ""
echo "Luego puedes reproducirlo en Lua con:"
echo "   minetest.sound_play('tu_mod:$NOMBRE', {gain = 1.0})"
echo ""
