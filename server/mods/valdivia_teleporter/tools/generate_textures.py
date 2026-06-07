#!/usr/bin/env python3
"""
Generate the teleporter pad textures for valdivia_teleporter.

Two 16x16 PNGs, reproducible (no hand-drawing):
  - valdivia_teleporter_top.png  : dark stone slab with a glowing cyan rune (ring + cross)
  - valdivia_teleporter_side.png : dark stone side with a bright cyan bottom edge

Run: python3 generate_textures.py
"""

import os
from PIL import Image

SCRIPT_DIR = os.path.dirname(os.path.abspath(__file__))
TEXTURES_DIR = os.path.join(os.path.dirname(SCRIPT_DIR), "textures")

SIZE = 16
DARK = (38, 42, 54, 255)       # base oscura (piedra azulada)
DARK2 = (28, 31, 42, 255)      # sombra
CYAN = (60, 230, 240, 255)     # runa luminosa
CYAN_DIM = (40, 150, 165, 255) # cian apagado


def new_img():
    return Image.new("RGBA", (SIZE, SIZE), (0, 0, 0, 0))


def make_top():
    img = new_img()
    px = img.load()
    cx = cy = 7.5  # centro
    for y in range(SIZE):
        for x in range(SIZE):
            # base con leve damero para textura
            px[x, y] = DARK if (x + y) % 2 == 0 else DARK2
    # anillo cian
    for y in range(SIZE):
        for x in range(SIZE):
            dist = ((x - cx) ** 2 + (y - cy) ** 2) ** 0.5
            if 4.3 <= dist <= 5.6:
                px[x, y] = CYAN
            elif 3.3 <= dist < 4.3:
                px[x, y] = CYAN_DIM
    # cruz central
    for i in range(2, SIZE - 2):
        px[i, 7] = CYAN
        px[i, 8] = CYAN
        px[7, i] = CYAN
        px[8, i] = CYAN
    return img


def make_side():
    img = new_img()
    px = img.load()
    for y in range(SIZE):
        for x in range(SIZE):
            px[x, y] = DARK if (x + y) % 2 == 0 else DARK2
    # borde inferior brillante (la losa "flota" en luz)
    for x in range(SIZE):
        px[x, SIZE - 1] = CYAN
        px[x, SIZE - 2] = CYAN_DIM
    return img


def main():
    os.makedirs(TEXTURES_DIR, exist_ok=True)
    make_top().save(os.path.join(TEXTURES_DIR, "valdivia_teleporter_top.png"))
    make_side().save(os.path.join(TEXTURES_DIR, "valdivia_teleporter_side.png"))
    print("Texturas generadas en", TEXTURES_DIR)


if __name__ == "__main__":
    main()
