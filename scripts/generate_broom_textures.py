#!/usr/bin/env python3
"""
Generador de Texturas para Broom Racing Mod
Crea texturas PNG de 16x16 píxeles para escobas, checkpoints y partículas
"""

from PIL import Image, ImageDraw
import os

# Directorio de texturas
TEXTURE_DIR = "server/mods/broom_racing/textures"

# Colores
BROWN = (101, 67, 33)  # Marrón para escoba básica
DARK_BROWN = (76, 50, 25)
LIGHT_BROWN = (139, 90, 43)
WHEAT = (245, 222, 179)  # Color paja

GOLD = (255, 215, 0)  # Dorado para escoba rápida
DARK_GOLD = (184, 134, 11)
ORANGE = (255, 140, 0)

PURPLE = (138, 43, 226)  # Púrpura para escoba mágica
MAGENTA = (255, 0, 255)
CYAN = (0, 255, 255)
WHITE = (255, 255, 255)

YELLOW = (255, 255, 0)  # Para checkpoints
LIGHT_YELLOW = (255, 255, 128)
DARK_YELLOW = (200, 200, 0)

PARTICLE_COLORS = [
    (255, 200, 255),  # Rosa claro
    (200, 200, 255),  # Azul claro
    (255, 255, 200),  # Amarillo claro
    (255, 255, 255),  # Blanco
]

TRANSPARENT = (0, 0, 0, 0)


def create_broom_basic():
    """Escoba básica - marrón con paja"""
    img = Image.new('RGBA', (16, 16), TRANSPARENT)
    pixels = img.load()

    # Mango (palo vertical)
    for y in range(2, 14):
        pixels[7, y] = BROWN
        pixels[8, y] = LIGHT_BROWN

    # Paja (parte inferior)
    for y in range(10, 16):
        for x in range(4, 12):
            if (x + y) % 2 == 0:
                pixels[x, y] = WHEAT
            else:
                pixels[x, y] = DARK_BROWN

    # Detalles del mango
    pixels[7, 3] = DARK_BROWN
    pixels[8, 3] = DARK_BROWN

    img.save(os.path.join(TEXTURE_DIR, "broom_basic.png"))
    print("✅ Creada: broom_basic.png")


def create_broom_fast():
    """Escoba rápida - dorada con efectos"""
    img = Image.new('RGBA', (16, 16), TRANSPARENT)
    pixels = img.load()

    # Mango dorado
    for y in range(2, 14):
        pixels[7, y] = DARK_GOLD
        pixels[8, y] = GOLD

    # Paja dorada/naranja
    for y in range(10, 16):
        for x in range(4, 12):
            if (x + y) % 2 == 0:
                pixels[x, y] = GOLD
            else:
                pixels[x, y] = ORANGE

    # Detalles brillantes
    pixels[7, 3] = GOLD
    pixels[8, 3] = GOLD
    pixels[6, 5] = GOLD
    pixels[9, 5] = GOLD

    # Efectos de velocidad (líneas)
    pixels[5, 7] = ORANGE
    pixels[4, 8] = ORANGE
    pixels[10, 7] = ORANGE
    pixels[11, 8] = ORANGE

    img.save(os.path.join(TEXTURE_DIR, "broom_fast.png"))
    print("✅ Creada: broom_fast.png")


def create_broom_magic():
    """Escoba mágica - púrpura con efectos místicos"""
    img = Image.new('RGBA', (16, 16), TRANSPARENT)
    pixels = img.load()

    # Mango mágico (púrpura brillante)
    for y in range(2, 14):
        if y % 2 == 0:
            pixels[7, y] = PURPLE
            pixels[8, y] = MAGENTA
        else:
            pixels[7, y] = MAGENTA
            pixels[8, y] = PURPLE

    # Paja mágica (colores místicos)
    for y in range(10, 16):
        for x in range(4, 12):
            if (x + y) % 3 == 0:
                pixels[x, y] = PURPLE
            elif (x + y) % 3 == 1:
                pixels[x, y] = MAGENTA
            else:
                pixels[x, y] = CYAN

    # Efectos mágicos (estrellas)
    pixels[5, 4] = WHITE
    pixels[10, 4] = WHITE
    pixels[6, 6] = CYAN
    pixels[9, 6] = CYAN
    pixels[4, 9] = MAGENTA
    pixels[11, 9] = MAGENTA

    # Partículas mágicas alrededor
    pixels[3, 5] = PURPLE
    pixels[12, 5] = PURPLE
    pixels[3, 11] = CYAN
    pixels[12, 11] = CYAN

    img.save(os.path.join(TEXTURE_DIR, "broom_magic.png"))
    print("✅ Creada: broom_magic.png")


def create_broom_particle_trail():
    """Partícula de estela de escoba (estrella brillante)"""
    img = Image.new('RGBA', (8, 8), TRANSPARENT)
    draw = ImageDraw.Draw(img)

    # Estrella brillante (cruz + X)
    # Cruz vertical y horizontal
    draw.line([(4, 1), (4, 6)], fill=WHITE, width=1)
    draw.line([(1, 4), (6, 4)], fill=WHITE, width=1)
    # Diagonales
    draw.line([(2, 2), (5, 5)], fill=LIGHT_YELLOW, width=1)
    draw.line([(2, 5), (5, 2)], fill=LIGHT_YELLOW, width=1)
    # Centro brillante
    draw.point((4, 4), fill=WHITE)

    img.save(os.path.join(TEXTURE_DIR, "broom_particle_trail.png"))
    print("✅ Creada: broom_particle_trail.png")


def create_checkpoint_top():
    """Parte superior del checkpoint (dorado brillante)"""
    img = Image.new('RGBA', (16, 16), TRANSPARENT)
    draw = ImageDraw.Draw(img)

    # Círculo dorado con patrón
    for y in range(16):
        for x in range(16):
            dist = ((x - 8) ** 2 + (y - 8) ** 2) ** 0.5
            if dist < 7:
                if (x + y) % 2 == 0:
                    img.putpixel((x, y), GOLD)
                else:
                    img.putpixel((x, y), LIGHT_YELLOW)
            elif dist < 8:
                img.putpixel((x, y), DARK_GOLD)

    # Estrella central
    draw.point((8, 8), fill=WHITE)
    draw.point((7, 8), fill=WHITE)
    draw.point((9, 8), fill=WHITE)
    draw.point((8, 7), fill=WHITE)
    draw.point((8, 9), fill=WHITE)

    img.save(os.path.join(TEXTURE_DIR, "checkpoint_top.png"))
    print("✅ Creada: checkpoint_top.png")


def create_checkpoint_bottom():
    """Parte inferior del checkpoint (oro oscuro)"""
    img = Image.new('RGBA', (16, 16), TRANSPARENT)

    # Patrón cuadriculado oscuro
    for y in range(16):
        for x in range(16):
            if (x // 2 + y // 2) % 2 == 0:
                img.putpixel((x, y), DARK_GOLD)
            else:
                img.putpixel((x, y), BROWN)

    img.save(os.path.join(TEXTURE_DIR, "checkpoint_bottom.png"))
    print("✅ Creada: checkpoint_bottom.png")


def create_checkpoint_side():
    """Laterales del checkpoint (efecto portal dorado)"""
    img = Image.new('RGBA', (16, 16), TRANSPARENT)

    # Efecto de portal (ondas concéntricas)
    center_x, center_y = 8, 8
    for y in range(16):
        for x in range(16):
            dist = int(((x - center_x) ** 2 + (y - center_y) ** 2) ** 0.5)
            if dist % 3 == 0:
                img.putpixel((x, y), GOLD)
            elif dist % 3 == 1:
                img.putpixel((x, y), LIGHT_YELLOW)
            elif dist % 3 == 2:
                img.putpixel((x, y), YELLOW)

    # Bordes brillantes
    for i in range(16):
        img.putpixel((i, 0), WHITE)
        img.putpixel((i, 15), WHITE)
        img.putpixel((0, i), WHITE)
        img.putpixel((15, i), WHITE)

    img.save(os.path.join(TEXTURE_DIR, "checkpoint_side.png"))
    print("✅ Creada: checkpoint_side.png")


def create_checkpoint_particle():
    """Partícula de checkpoint (estrella dorada)"""
    img = Image.new('RGBA', (8, 8), TRANSPARENT)
    draw = ImageDraw.Draw(img)

    # Estrella dorada grande
    # Cruz principal
    draw.line([(4, 0), (4, 7)], fill=GOLD, width=1)
    draw.line([(0, 4), (7, 4)], fill=GOLD, width=1)
    # Diagonales
    draw.line([(1, 1), (6, 6)], fill=YELLOW, width=1)
    draw.line([(1, 6), (6, 1)], fill=YELLOW, width=1)
    # Centro brillante
    draw.rectangle([(3, 3), (4, 4)], fill=WHITE)

    img.save(os.path.join(TEXTURE_DIR, "checkpoint_particle.png"))
    print("✅ Creada: checkpoint_particle.png")


def main():
    print("🎨 Generando texturas para Broom Racing Mod...")
    print(f"📁 Directorio: {TEXTURE_DIR}\n")

    # Crear todas las texturas
    create_broom_basic()
    create_broom_fast()
    create_broom_magic()
    create_broom_particle_trail()
    create_checkpoint_top()
    create_checkpoint_bottom()
    create_checkpoint_side()
    create_checkpoint_particle()

    print("\n🎉 ¡Todas las texturas generadas exitosamente!")
    print(f"📊 Total: 8 archivos PNG creados en {TEXTURE_DIR}")


if __name__ == "__main__":
    main()
