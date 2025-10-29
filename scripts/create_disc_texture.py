#!/usr/bin/env python3
"""
Script para crear texturas de discos de música para Luanti/VoxeLibre
Genera imágenes PNG de 16x16 píxeles con diseño de disco de vinilo
"""

from PIL import Image, ImageDraw, ImageFont
import sys

def create_disc_texture(text, output_path, bg_color=(255, 255, 255), text_color=(0, 0, 0), accent_color=(200, 50, 50)):
    """
    Crea una textura de disco de 16x16 píxeles

    Args:
        text: Texto a mostrar (máximo 2-3 caracteres)
        output_path: Ruta donde guardar la imagen
        bg_color: Color de fondo RGB
        text_color: Color del texto RGB
        accent_color: Color del borde/acento RGB
    """
    # Crear imagen de 16x16 píxeles
    size = 16
    img = Image.new('RGBA', (size, size), (0, 0, 0, 0))
    draw = ImageDraw.Draw(img)

    # Dibujar círculo exterior (borde del disco) - más grueso
    draw.ellipse([0, 0, 15, 15], fill=accent_color, outline=accent_color)

    # Dibujar círculo blanco interior (etiqueta del disco)
    draw.ellipse([2, 2, 13, 13], fill=bg_color, outline=bg_color)

    # Dibujar agujero central del disco
    center = size // 2
    hole_radius = 2
    draw.ellipse([center-hole_radius, center-hole_radius,
                  center+hole_radius, center+hole_radius],
                 fill=accent_color, outline=accent_color)

    # Intentar usar fuente pequeña para el texto
    try:
        # Buscar fuentes disponibles en el sistema
        font_paths = [
            '/usr/share/fonts/truetype/dejavu/DejaVuSans-Bold.ttf',
            '/usr/share/fonts/truetype/liberation/LiberationSans-Bold.ttf',
            '/usr/share/fonts/truetype/ubuntu/Ubuntu-B.ttf',
        ]

        font = None
        for font_path in font_paths:
            try:
                font = ImageFont.truetype(font_path, 6)
                break
            except:
                continue

        if font is None:
            font = ImageFont.load_default()
    except:
        font = ImageFont.load_default()

    # Calcular posición del texto (centrado)
    bbox = draw.textbbox((0, 0), text, font=font)
    text_width = bbox[2] - bbox[0]
    text_height = bbox[3] - bbox[1]

    x = (size - text_width) // 2
    y = (size - text_height) // 2 - 1  # Ajustar un poco arriba

    # Dibujar el texto
    draw.text((x, y), text, fill=text_color, font=font)

    # Guardar imagen
    img.save(output_path, 'PNG')
    print(f"✅ Textura creada: {output_path}")
    print(f"   Tamaño: {size}x{size} píxeles")
    print(f"   Texto: '{text}'")

if __name__ == "__main__":
    # Configuración para el disco "TE QUEDAS"
    output_path = "/home/gabriel/Documentos/luanti-voxelibre-server/server/mods/wetlands-music/textures/wetlands_music_te_quedas.png"

    # Crear textura con iniciales "JD" en estilo minimalista
    create_disc_texture(
        text="JD",
        output_path=output_path,
        bg_color=(255, 255, 255),      # Fondo blanco
        text_color=(0, 0, 0),          # Texto negro
        accent_color=(220, 60, 60)     # Borde rojo/rosado
    )

    print(f"\n📀 Disco 'TE QUEDAS' listo para usar en Luanti")
    print(f"   Autor: Gabriel Pantoja")
    print(f"   Ubicación: {output_path}")
