#!/usr/bin/env python3
"""
Generate improved NPC textures for Wetlands NPCs mod v1.0.0.

Creates 64x64 PNG textures following the mobs_mc_villager.b3d UV map.
Hybrid approach:
  - Farmer & Librarian: detailed custom textures
  - Teacher: Obi-Wan Kenobi inspired (wise Jedi teacher)
  - Explorer: Luke Skywalker inspired (adventurer)

UV Map layout for villager model (64x64):
- Head: front(8,8)-(16,16), back(24,8)-(32,16), top(8,0)-(16,8), bottom(16,0)-(24,8)
        left(0,8)-(8,16), right(16,8)-(24,16)
- Body: front(20,20)-(28,32), back(32,20)-(40,32), top(20,16)-(28,20), bottom(28,16)-(36,20)
        left(16,20)-(20,32), right(28,20)-(32,32)
- Arms: front(44,20)-(48,32), back(52,20)-(56,32), top(44,16)-(48,20), bottom(48,16)-(52,20)
        left(40,20)-(44,32), right(48,20)-(52,32)
- Legs: front(4,20)-(8,32), back(12,20)-(16,32), top(4,16)-(8,20), bottom(8,16)-(12,20)
        left(0,20)-(4,32), right(8,20)-(12,32)
"""

import os
from PIL import Image, ImageDraw


OUTPUT_DIR = os.path.join(os.path.dirname(os.path.dirname(os.path.abspath(__file__))), "textures")


def shade(color, amount):
    """Darken (negative) or lighten (positive) a color."""
    return tuple(max(0, min(255, c + amount)) for c in color)


def blend(c1, c2, t=0.5):
    """Blend two colors. t=0 is c1, t=1 is c2."""
    return tuple(int(a + (b - a) * t) for a, b in zip(c1, c2))


def fill_rect_shaded(draw, x1, y1, x2, y2, base_color, edge_darken=15):
    """Fill a rectangle with subtle edge shading for depth."""
    w = x2 - x1 + 1
    h = y2 - y1 + 1
    for py in range(y1, y2 + 1):
        for px in range(x1, x2 + 1):
            # Distance from edges (0 at edge, max at center)
            dx = min(px - x1, x2 - px)
            dy = min(py - y1, y2 - py)
            d = min(dx, dy)
            if d == 0 and (w > 2 and h > 2):
                c = shade(base_color, -edge_darken)
            else:
                c = base_color
            draw.point((px, py), fill=c)


def draw_farmer_texture():
    """Detailed farmer villager - green overalls, straw hat, warm personality."""
    img = Image.new("RGBA", (64, 64), (0, 0, 0, 0))
    draw = ImageDraw.Draw(img)

    # Palette
    skin = (215, 180, 140)
    skin_shadow = (190, 155, 115)
    hair = (139, 95, 43)
    hair_dark = (110, 70, 25)
    hat = (210, 195, 120)
    hat_dark = (185, 170, 95)
    hat_band = (139, 95, 43)
    robe = (55, 135, 30)       # Rich green
    robe_dark = (40, 105, 20)
    robe_light = (70, 155, 40)
    apron = (200, 185, 140)    # Light tan apron
    apron_dark = (175, 160, 115)
    belt = (120, 75, 30)
    belt_dark = (95, 55, 15)
    buckle = (200, 180, 50)
    shoes = (100, 65, 30)
    shoes_dark = (75, 45, 15)
    eye_white = (240, 240, 235)
    eye_pupil = (60, 40, 20)
    mouth = (175, 110, 100)
    cheek = (225, 170, 140)

    # === HEAD TOP (8,0)-(16,8) - straw hat ===
    draw.rectangle([8, 0, 15, 7], fill=hat)
    # Hat brim darker edge
    draw.rectangle([8, 0, 15, 0], fill=hat_dark)
    draw.rectangle([8, 7, 15, 7], fill=hat_dark)
    draw.point((8, 0), fill=hat_dark)
    draw.point((15, 0), fill=hat_dark)
    # Hat band
    draw.rectangle([8, 4, 15, 4], fill=hat_band)
    # Straw texture lines
    for x in range(9, 15, 2):
        draw.point((x, 2), fill=hat_dark)
        draw.point((x, 5), fill=shade(hat, 10))

    # === HEAD BOTTOM (16,0)-(24,8) ===
    draw.rectangle([16, 0, 23, 7], fill=skin)
    draw.rectangle([16, 0, 23, 0], fill=skin_shadow)

    # === HEAD FRONT (8,8)-(16,16) - face ===
    draw.rectangle([8, 8, 15, 15], fill=skin)
    # Hat brim shadow at top
    draw.rectangle([8, 8, 15, 8], fill=hat_dark)
    draw.rectangle([8, 9, 15, 9], fill=shade(skin, -25))
    # Eyebrows
    draw.point((9, 10), fill=hair)
    draw.point((10, 10), fill=hair)
    draw.point((13, 10), fill=hair)
    draw.point((14, 10), fill=hair)
    # Eyes (white + pupil)
    draw.point((9, 11), fill=eye_white)
    draw.point((10, 11), fill=eye_pupil)
    draw.point((13, 11), fill=eye_pupil)
    draw.point((14, 11), fill=eye_white)
    # Nose
    draw.point((11, 12), fill=skin_shadow)
    draw.point((12, 12), fill=skin_shadow)
    draw.point((12, 13), fill=shade(skin, -10))
    # Cheeks (friendly blush)
    draw.point((9, 13), fill=cheek)
    draw.point((14, 13), fill=cheek)
    # Smile
    draw.point((10, 14), fill=mouth)
    draw.point((11, 14), fill=mouth)
    draw.point((12, 14), fill=mouth)
    draw.point((13, 14), fill=mouth)
    # Chin
    draw.rectangle([8, 15, 15, 15], fill=skin_shadow)

    # === HEAD BACK (24,8)-(32,16) ===
    draw.rectangle([24, 8, 31, 15], fill=hair)
    draw.rectangle([24, 8, 31, 8], fill=hat_dark)
    # Hair texture
    for x in range(25, 31, 2):
        draw.point((x, 11), fill=hair_dark)
        draw.point((x + 1, 13), fill=hair_dark)

    # === HEAD LEFT (0,8)-(8,16) ===
    draw.rectangle([0, 8, 7, 15], fill=skin)
    draw.rectangle([0, 8, 7, 8], fill=hat_dark)
    draw.rectangle([0, 9, 7, 9], fill=hair)
    draw.rectangle([6, 8, 7, 15], fill=skin_shadow)
    # Ear
    draw.point((3, 11), fill=shade(skin, -15))
    draw.point((3, 12), fill=shade(skin, -10))

    # === HEAD RIGHT (16,8)-(24,16) ===
    draw.rectangle([16, 8, 23, 15], fill=skin)
    draw.rectangle([16, 8, 23, 8], fill=hat_dark)
    draw.rectangle([16, 9, 23, 9], fill=hair)
    draw.rectangle([16, 8, 17, 15], fill=skin_shadow)
    # Ear
    draw.point((20, 11), fill=shade(skin, -15))
    draw.point((20, 12), fill=shade(skin, -10))

    # === BODY TOP (20,16)-(28,20) - shoulders ===
    draw.rectangle([20, 16, 27, 19], fill=robe)
    draw.rectangle([20, 16, 27, 16], fill=robe_light)

    # === BODY BOTTOM (28,16)-(36,20) ===
    draw.rectangle([28, 16, 35, 19], fill=robe_dark)

    # === BODY FRONT (20,20)-(28,32) - green shirt + apron ===
    draw.rectangle([20, 20, 27, 31], fill=robe)
    # Collar
    draw.point((23, 20), fill=skin)
    draw.point((24, 20), fill=skin)
    draw.rectangle([20, 20, 22, 20], fill=robe_light)
    draw.rectangle([25, 20, 27, 20], fill=robe_light)
    # Apron (tan rectangle)
    draw.rectangle([22, 23, 25, 29], fill=apron)
    draw.rectangle([22, 23, 25, 23], fill=apron_dark)  # top edge
    draw.point((22, 23), fill=apron_dark)
    draw.point((25, 23), fill=apron_dark)
    # Apron pocket
    draw.rectangle([23, 25, 24, 26], fill=apron_dark)
    # Suspender straps
    draw.point((22, 21), fill=belt)
    draw.point((25, 21), fill=belt)
    draw.point((22, 22), fill=belt)
    draw.point((25, 22), fill=belt)
    # Belt
    draw.rectangle([20, 27, 27, 27], fill=belt)
    draw.rectangle([23, 27, 24, 27], fill=buckle)
    # Lower robe
    draw.rectangle([20, 28, 27, 31], fill=robe_dark)
    # Center fold line
    draw.point((23, 29), fill=shade(robe_dark, -10))
    draw.point((24, 29), fill=shade(robe_dark, -10))
    draw.point((23, 30), fill=shade(robe_dark, -10))
    draw.point((24, 30), fill=shade(robe_dark, -10))

    # === BODY BACK (32,20)-(40,32) ===
    draw.rectangle([32, 20, 39, 31], fill=robe_dark)
    draw.rectangle([32, 27, 39, 27], fill=belt_dark)
    # Fabric fold lines
    draw.point((35, 23), fill=shade(robe_dark, -12))
    draw.point((35, 25), fill=shade(robe_dark, -12))
    draw.point((36, 29), fill=shade(robe_dark, -12))

    # === BODY LEFT (16,20)-(20,32) ===
    draw.rectangle([16, 20, 19, 31], fill=robe)
    draw.rectangle([16, 27, 19, 27], fill=belt_dark)
    draw.rectangle([16, 28, 19, 31], fill=robe_dark)

    # === BODY RIGHT (28,20)-(32,32) ===
    draw.rectangle([28, 20, 31, 31], fill=robe)
    draw.rectangle([28, 27, 31, 27], fill=belt_dark)
    draw.rectangle([28, 28, 31, 31], fill=robe_dark)

    # === ARMS ===
    # Arm top (44,16)-(48,20)
    draw.rectangle([44, 16, 47, 19], fill=robe)
    # Arm bottom (48,16)-(52,20)
    draw.rectangle([48, 16, 51, 19], fill=robe_dark)
    # Arm front (44,20)-(48,32)
    draw.rectangle([44, 20, 47, 31], fill=robe)
    draw.rectangle([44, 20, 44, 31], fill=robe_dark)  # edge shade
    draw.rectangle([44, 29, 47, 31], fill=skin)
    draw.point((44, 29), fill=skin_shadow)
    # Arm back (52,20)-(56,32)
    draw.rectangle([52, 20, 55, 31], fill=robe_dark)
    draw.rectangle([52, 29, 55, 31], fill=skin_shadow)
    # Arm left (40,20)-(44,32)
    draw.rectangle([40, 20, 43, 31], fill=robe)
    draw.rectangle([40, 29, 43, 31], fill=skin)
    # Arm right (48,20)-(52,32)
    draw.rectangle([48, 20, 51, 31], fill=robe)
    draw.rectangle([48, 29, 51, 31], fill=skin)

    # === LEGS ===
    for lx, ly in [(4, 20), (0, 20), (8, 20), (12, 20)]:
        w = 4 if lx in (0, 8) else 4
        draw.rectangle([lx, 16, lx + 3, 19], fill=robe_dark)
        draw.rectangle([lx, ly, lx + 3, ly + 11], fill=robe_dark)
        draw.rectangle([lx, ly + 9, lx + 3, ly + 11], fill=shoes)
        draw.point((lx, ly + 9), fill=shoes_dark)
        draw.point((lx + 3, ly + 9), fill=shoes_dark)

    return img


def draw_librarian_texture():
    """Detailed librarian villager - blue robe, spectacles, scholarly look."""
    img = Image.new("RGBA", (64, 64), (0, 0, 0, 0))
    draw = ImageDraw.Draw(img)

    # Palette
    skin = (230, 200, 165)
    skin_shadow = (205, 175, 140)
    hair = (55, 50, 45)
    hair_dark = (35, 30, 25)
    robe = (35, 75, 155)
    robe_dark = (25, 55, 125)
    robe_light = (50, 95, 175)
    collar = (215, 215, 220)
    collar_dark = (190, 190, 195)
    belt = (60, 45, 30)
    belt_dark = (40, 30, 15)
    book = (150, 40, 30)       # Red book
    book_pages = (240, 235, 220)
    shoes = (45, 35, 25)
    shoes_dark = (30, 20, 10)
    eye_white = (240, 240, 240)
    eye_pupil = (35, 35, 35)
    glasses = (180, 160, 100)  # Gold spectacles
    mouth = (165, 115, 105)

    # === HEAD TOP (8,0)-(16,8) ===
    draw.rectangle([8, 0, 15, 7], fill=hair)
    # Subtle hair texture
    for x in range(8, 16, 2):
        draw.point((x, 1), fill=hair_dark)
        draw.point((x + 1, 3), fill=hair_dark)
        draw.point((x, 5), fill=hair_dark)

    # === HEAD BOTTOM (16,0)-(24,8) ===
    draw.rectangle([16, 0, 23, 7], fill=skin)
    draw.rectangle([16, 0, 23, 0], fill=skin_shadow)

    # === HEAD FRONT (8,8)-(16,16) - face with glasses ===
    draw.rectangle([8, 8, 15, 15], fill=skin)
    # Hair at top
    draw.rectangle([8, 8, 15, 9], fill=hair)
    draw.point((8, 10), fill=hair)
    draw.point((15, 10), fill=hair)
    # Glasses frames (gold)
    draw.point((9, 11), fill=glasses)
    draw.point((10, 11), fill=glasses)
    draw.point((11, 11), fill=glasses)
    draw.point((12, 11), fill=glasses)  # bridge
    draw.point((13, 11), fill=glasses)
    draw.point((14, 11), fill=glasses)
    # Eyes behind glasses
    draw.point((9, 11), fill=eye_white)
    draw.point((10, 11), fill=eye_pupil)
    draw.point((13, 11), fill=eye_pupil)
    draw.point((14, 11), fill=eye_white)
    # Glasses rim below eyes
    draw.point((9, 12), fill=glasses)
    draw.point((11, 12), fill=glasses)
    draw.point((12, 12), fill=glasses)
    draw.point((14, 12), fill=glasses)
    # Nose
    draw.point((11, 13), fill=skin_shadow)
    draw.point((12, 13), fill=skin_shadow)
    # Mouth (neutral/thoughtful)
    draw.point((11, 14), fill=mouth)
    draw.point((12, 14), fill=mouth)
    # Chin shadow
    draw.rectangle([8, 15, 15, 15], fill=skin_shadow)

    # === HEAD BACK (24,8)-(32,16) ===
    draw.rectangle([24, 8, 31, 15], fill=hair)
    for x in range(24, 32, 2):
        draw.point((x, 10), fill=hair_dark)
        draw.point((x + 1, 12), fill=hair_dark)
        draw.point((x, 14), fill=hair_dark)

    # === HEAD LEFT (0,8)-(8,16) ===
    draw.rectangle([0, 8, 7, 15], fill=skin)
    draw.rectangle([0, 8, 7, 9], fill=hair)
    draw.rectangle([6, 8, 7, 15], fill=skin_shadow)
    draw.point((3, 11), fill=shade(skin, -12))

    # === HEAD RIGHT (16,8)-(24,16) ===
    draw.rectangle([16, 8, 23, 15], fill=skin)
    draw.rectangle([16, 8, 23, 9], fill=hair)
    draw.rectangle([16, 8, 17, 15], fill=skin_shadow)
    draw.point((20, 11), fill=shade(skin, -12))

    # === BODY TOP (20,16)-(28,20) ===
    draw.rectangle([20, 16, 27, 19], fill=collar)
    draw.rectangle([20, 19, 27, 19], fill=collar_dark)

    # === BODY BOTTOM (28,16)-(36,20) ===
    draw.rectangle([28, 16, 35, 19], fill=robe_dark)

    # === BODY FRONT (20,20)-(28,32) ===
    draw.rectangle([20, 20, 27, 31], fill=robe)
    # White collar / shirt showing
    draw.rectangle([22, 20, 25, 21], fill=collar)
    draw.point((23, 22), fill=collar_dark)
    draw.point((24, 22), fill=collar_dark)
    # Robe edges lighter
    draw.rectangle([20, 20, 20, 31], fill=robe_dark)
    draw.rectangle([27, 20, 27, 31], fill=robe_dark)
    # Center robe opening line
    draw.point((23, 23), fill=robe_dark)
    draw.point((24, 23), fill=robe_dark)
    draw.point((23, 24), fill=robe_dark)
    draw.point((24, 24), fill=robe_dark)
    # Book tucked in robe
    draw.rectangle([21, 25, 23, 27], fill=book)
    draw.point((24, 25), fill=book_pages)
    draw.point((24, 26), fill=book_pages)
    draw.point((24, 27), fill=book_pages)
    # Belt/sash
    draw.rectangle([20, 28, 27, 28], fill=belt)
    # Lower robe
    draw.rectangle([20, 29, 27, 31], fill=robe_dark)
    draw.point((23, 30), fill=shade(robe_dark, -10))
    draw.point((24, 30), fill=shade(robe_dark, -10))

    # === BODY BACK (32,20)-(40,32) ===
    draw.rectangle([32, 20, 39, 31], fill=robe_dark)
    draw.rectangle([32, 28, 39, 28], fill=belt_dark)
    draw.point((35, 24), fill=shade(robe_dark, -10))
    draw.point((36, 26), fill=shade(robe_dark, -10))

    # === BODY SIDES ===
    draw.rectangle([16, 20, 19, 31], fill=robe)
    draw.rectangle([16, 28, 19, 28], fill=belt_dark)
    draw.rectangle([16, 29, 19, 31], fill=robe_dark)
    draw.rectangle([28, 20, 31, 31], fill=robe)
    draw.rectangle([28, 28, 31, 28], fill=belt_dark)
    draw.rectangle([28, 29, 31, 31], fill=robe_dark)

    # === ARMS ===
    draw.rectangle([44, 16, 47, 19], fill=robe)
    draw.rectangle([48, 16, 51, 19], fill=robe_dark)
    draw.rectangle([44, 20, 47, 31], fill=robe)
    draw.rectangle([44, 20, 44, 31], fill=robe_dark)
    draw.rectangle([44, 29, 47, 31], fill=skin)
    draw.point((44, 29), fill=skin_shadow)
    draw.rectangle([52, 20, 55, 31], fill=robe_dark)
    draw.rectangle([52, 29, 55, 31], fill=skin_shadow)
    draw.rectangle([40, 20, 43, 31], fill=robe)
    draw.rectangle([40, 29, 43, 31], fill=skin)
    draw.rectangle([48, 20, 51, 31], fill=robe)
    draw.rectangle([48, 29, 51, 31], fill=skin)

    # === LEGS ===
    for lx in (4, 0, 8, 12):
        draw.rectangle([lx, 16, lx + 3, 19], fill=robe_dark)
        draw.rectangle([lx, 20, lx + 3, 31], fill=robe_dark)
        draw.rectangle([lx, 29, lx + 3, 31], fill=shoes)
        draw.point((lx, 29), fill=shoes_dark)
        draw.point((lx + 3, 29), fill=shoes_dark)

    return img


def draw_teacher_texture():
    """Obi-Wan Kenobi inspired teacher - tan Jedi robes, beard, wise look."""
    img = Image.new("RGBA", (64, 64), (0, 0, 0, 0))
    draw = ImageDraw.Draw(img)

    # Obi-Wan palette (extracted from raw_obiwan_kenobi.png colors)
    skin = (210, 185, 155)
    skin_shadow = (185, 160, 130)
    hair = (160, 120, 65)       # Sandy brown/ginger
    hair_dark = (135, 95, 40)
    beard = (155, 115, 60)
    robe_outer = (170, 145, 105)  # Tan outer robe
    robe_outer_dark = (145, 120, 80)
    robe_inner = (205, 190, 160)  # Cream/light inner tunic
    robe_inner_dark = (180, 165, 135)
    belt = (120, 85, 45)
    belt_dark = (95, 60, 25)
    belt_buckle = (150, 140, 120)
    boots = (105, 75, 40)
    boots_dark = (80, 55, 25)
    eye_white = (235, 235, 230)
    eye_blue = (80, 130, 180)   # Obi-Wan's blue eyes
    mouth = (170, 130, 115)
    lightsaber_hilt = (160, 160, 170)  # Silver hilt hint

    # === HEAD TOP (8,0)-(16,8) ===
    draw.rectangle([8, 0, 15, 7], fill=hair)
    # Hair texture (slightly wavy)
    for x in range(8, 16):
        if x % 2 == 0:
            draw.point((x, 1), fill=hair_dark)
            draw.point((x, 4), fill=hair_dark)
        else:
            draw.point((x, 2), fill=hair_dark)
            draw.point((x, 5), fill=hair_dark)

    # === HEAD BOTTOM (16,0)-(24,8) ===
    draw.rectangle([16, 0, 23, 7], fill=skin)
    # Beard under chin
    draw.rectangle([18, 2, 21, 5], fill=beard)

    # === HEAD FRONT (8,8)-(16,16) - face with beard ===
    draw.rectangle([8, 8, 15, 15], fill=skin)
    # Hair
    draw.rectangle([8, 8, 15, 9], fill=hair)
    draw.point((8, 10), fill=hair)
    draw.point((15, 10), fill=hair)
    # Eyebrows (expressive)
    draw.point((9, 10), fill=hair_dark)
    draw.point((10, 10), fill=hair_dark)
    draw.point((13, 10), fill=hair_dark)
    draw.point((14, 10), fill=hair_dark)
    # Eyes (blue - Obi-Wan's signature)
    draw.point((9, 11), fill=eye_white)
    draw.point((10, 11), fill=eye_blue)
    draw.point((13, 11), fill=eye_blue)
    draw.point((14, 11), fill=eye_white)
    # Nose
    draw.point((11, 12), fill=skin_shadow)
    draw.point((12, 12), fill=skin_shadow)
    # Beard
    draw.point((9, 13), fill=beard)
    draw.point((10, 13), fill=beard)
    draw.point((11, 13), fill=beard)
    draw.point((12, 13), fill=beard)
    draw.point((13, 13), fill=beard)
    draw.point((14, 13), fill=beard)
    draw.point((10, 14), fill=beard)
    draw.point((11, 14), fill=beard)
    draw.point((12, 14), fill=beard)
    draw.point((13, 14), fill=beard)
    draw.point((11, 15), fill=beard)
    draw.point((12, 15), fill=beard)

    # === HEAD BACK (24,8)-(32,16) ===
    draw.rectangle([24, 8, 31, 15], fill=hair)
    for x in range(24, 32):
        if x % 2 == 0:
            draw.point((x, 10), fill=hair_dark)
            draw.point((x, 13), fill=hair_dark)

    # === HEAD LEFT (0,8)-(8,16) ===
    draw.rectangle([0, 8, 7, 15], fill=skin)
    draw.rectangle([0, 8, 7, 9], fill=hair)
    draw.rectangle([6, 8, 7, 15], fill=skin_shadow)
    draw.point((3, 11), fill=shade(skin, -12))
    # Side beard
    draw.point((5, 13), fill=beard)
    draw.point((5, 14), fill=beard)

    # === HEAD RIGHT (16,8)-(24,16) ===
    draw.rectangle([16, 8, 23, 15], fill=skin)
    draw.rectangle([16, 8, 23, 9], fill=hair)
    draw.rectangle([16, 8, 17, 15], fill=skin_shadow)
    draw.point((20, 11), fill=shade(skin, -12))
    draw.point((18, 13), fill=beard)
    draw.point((18, 14), fill=beard)

    # === BODY TOP (20,16)-(28,20) ===
    draw.rectangle([20, 16, 27, 19], fill=robe_outer)
    draw.rectangle([22, 16, 25, 17], fill=robe_inner)

    # === BODY BOTTOM (28,16)-(36,20) ===
    draw.rectangle([28, 16, 35, 19], fill=robe_outer_dark)

    # === BODY FRONT (20,20)-(28,32) - Jedi robe layers ===
    draw.rectangle([20, 20, 27, 31], fill=robe_outer)
    # Inner tunic V-opening
    draw.point((23, 20), fill=robe_inner)
    draw.point((24, 20), fill=robe_inner)
    draw.point((22, 21), fill=robe_inner)
    draw.point((23, 21), fill=robe_inner)
    draw.point((24, 21), fill=robe_inner)
    draw.point((25, 21), fill=robe_inner)
    draw.point((22, 22), fill=robe_inner)
    draw.point((23, 22), fill=robe_inner)
    draw.point((24, 22), fill=robe_inner)
    draw.point((25, 22), fill=robe_inner)
    draw.point((22, 23), fill=robe_inner)
    draw.point((23, 23), fill=robe_inner)
    draw.point((24, 23), fill=robe_inner)
    draw.point((25, 23), fill=robe_inner)
    # Robe fold lines
    draw.point((21, 24), fill=robe_outer_dark)
    draw.point((26, 24), fill=robe_outer_dark)
    draw.point((21, 26), fill=robe_outer_dark)
    draw.point((26, 26), fill=robe_outer_dark)
    # Belt/obi (wider sash)
    draw.rectangle([20, 27, 27, 28], fill=belt)
    draw.rectangle([20, 27, 27, 27], fill=belt_dark)
    draw.rectangle([23, 27, 24, 28], fill=belt_buckle)
    # Lightsaber hilt at belt
    draw.point((21, 28), fill=lightsaber_hilt)
    draw.point((21, 27), fill=lightsaber_hilt)
    # Lower robe
    draw.rectangle([20, 29, 27, 31], fill=robe_outer_dark)
    draw.point((23, 30), fill=shade(robe_outer_dark, -10))
    draw.point((24, 30), fill=shade(robe_outer_dark, -10))

    # === BODY BACK (32,20)-(40,32) ===
    draw.rectangle([32, 20, 39, 31], fill=robe_outer_dark)
    draw.rectangle([32, 27, 39, 28], fill=belt_dark)
    draw.point((35, 23), fill=shade(robe_outer_dark, -10))
    draw.point((36, 25), fill=shade(robe_outer_dark, -10))

    # === BODY SIDES ===
    draw.rectangle([16, 20, 19, 31], fill=robe_outer)
    draw.rectangle([16, 27, 19, 28], fill=belt_dark)
    draw.rectangle([16, 29, 19, 31], fill=robe_outer_dark)
    draw.rectangle([28, 20, 31, 31], fill=robe_outer)
    draw.rectangle([28, 27, 31, 28], fill=belt_dark)
    draw.rectangle([28, 29, 31, 31], fill=robe_outer_dark)

    # === ARMS (wide Jedi sleeves) ===
    draw.rectangle([44, 16, 47, 19], fill=robe_outer)
    draw.rectangle([48, 16, 51, 19], fill=robe_outer_dark)
    draw.rectangle([44, 20, 47, 31], fill=robe_outer)
    draw.rectangle([44, 20, 44, 31], fill=robe_outer_dark)
    # Sleeves cover hands more (Jedi style)
    draw.rectangle([44, 29, 47, 31], fill=skin)
    draw.point((44, 29), fill=robe_outer_dark)
    draw.point((45, 29), fill=shade(skin, -15))
    draw.rectangle([52, 20, 55, 31], fill=robe_outer_dark)
    draw.rectangle([52, 29, 55, 31], fill=skin_shadow)
    draw.rectangle([40, 20, 43, 31], fill=robe_outer)
    draw.rectangle([40, 29, 43, 31], fill=skin)
    draw.rectangle([48, 20, 51, 31], fill=robe_outer)
    draw.rectangle([48, 29, 51, 31], fill=skin)

    # === LEGS ===
    for lx in (4, 0, 8, 12):
        draw.rectangle([lx, 16, lx + 3, 19], fill=robe_outer_dark)
        draw.rectangle([lx, 20, lx + 3, 31], fill=robe_outer_dark)
        draw.rectangle([lx, 29, lx + 3, 31], fill=boots)
        draw.point((lx, 29), fill=boots_dark)
        draw.point((lx + 3, 29), fill=boots_dark)
        draw.point((lx + 1, 31), fill=boots_dark)

    return img


def draw_explorer_texture():
    """Luke Skywalker inspired explorer - black/dark outfit, heroic look."""
    img = Image.new("RGBA", (64, 64), (0, 0, 0, 0))
    draw = ImageDraw.Draw(img)

    # Luke Skywalker palette (Return of the Jedi - black outfit)
    skin = (220, 190, 160)
    skin_shadow = (195, 165, 135)
    hair = (130, 100, 55)      # Sandy blond
    hair_dark = (105, 75, 35)
    tunic = (40, 40, 45)       # Black tunic
    tunic_dark = (25, 25, 30)
    tunic_light = (55, 55, 60)
    flap = (50, 50, 55)        # Front flap/collar
    belt = (75, 60, 40)        # Brown utility belt
    belt_dark = (55, 40, 20)
    buckle = (170, 165, 155)   # Silver buckle
    glove = (35, 35, 40)       # Black glove (right hand)
    boots = (50, 45, 35)
    boots_dark = (35, 30, 20)
    eye_white = (235, 235, 235)
    eye_blue = (75, 125, 175)  # Luke's blue eyes
    mouth = (175, 135, 120)
    lightsaber_green = (80, 200, 80)  # Green lightsaber hint

    # === HEAD TOP (8,0)-(16,8) ===
    draw.rectangle([8, 0, 15, 7], fill=hair)
    # Messy hair texture
    for x in range(8, 16):
        y_offset = 1 if x % 3 == 0 else (2 if x % 3 == 1 else 0)
        draw.point((x, y_offset), fill=hair_dark)
        draw.point((x, y_offset + 3), fill=shade(hair, 10))

    # === HEAD BOTTOM (16,0)-(24,8) ===
    draw.rectangle([16, 0, 23, 7], fill=skin)
    draw.rectangle([16, 0, 23, 0], fill=skin_shadow)

    # === HEAD FRONT (8,8)-(16,16) ===
    draw.rectangle([8, 8, 15, 15], fill=skin)
    # Hair
    draw.rectangle([8, 8, 15, 9], fill=hair)
    draw.point((8, 10), fill=hair)
    draw.point((15, 10), fill=hair)
    # Hair falls slightly on forehead
    draw.point((10, 10), fill=hair)
    draw.point((11, 10), fill=hair)
    # Eyebrows
    draw.point((9, 10), fill=hair_dark)
    draw.point((14, 10), fill=hair_dark)
    # Eyes (blue - like Luke)
    draw.point((9, 11), fill=eye_white)
    draw.point((10, 11), fill=eye_blue)
    draw.point((13, 11), fill=eye_blue)
    draw.point((14, 11), fill=eye_white)
    # Nose
    draw.point((11, 12), fill=skin_shadow)
    draw.point((12, 12), fill=skin_shadow)
    # Slight smile (determined but kind)
    draw.point((10, 13), fill=shade(skin, -8))
    draw.point((13, 13), fill=shade(skin, -8))
    draw.point((11, 14), fill=mouth)
    draw.point((12, 14), fill=mouth)
    # Jaw/chin
    draw.rectangle([8, 15, 15, 15], fill=skin_shadow)

    # === HEAD BACK (24,8)-(32,16) ===
    draw.rectangle([24, 8, 31, 15], fill=hair)
    for x in range(24, 32, 2):
        draw.point((x, 10), fill=hair_dark)
        draw.point((x + 1, 13), fill=hair_dark)

    # === HEAD LEFT (0,8)-(8,16) ===
    draw.rectangle([0, 8, 7, 15], fill=skin)
    draw.rectangle([0, 8, 7, 9], fill=hair)
    draw.rectangle([6, 8, 7, 15], fill=skin_shadow)
    draw.point((3, 11), fill=shade(skin, -12))

    # === HEAD RIGHT (16,8)-(24,16) ===
    draw.rectangle([16, 8, 23, 15], fill=skin)
    draw.rectangle([16, 8, 23, 9], fill=hair)
    draw.rectangle([16, 8, 17, 15], fill=skin_shadow)
    draw.point((20, 11), fill=shade(skin, -12))

    # === BODY TOP (20,16)-(28,20) ===
    draw.rectangle([20, 16, 27, 19], fill=tunic)
    draw.rectangle([22, 16, 25, 16], fill=tunic_light)

    # === BODY BOTTOM (28,16)-(36,20) ===
    draw.rectangle([28, 16, 35, 19], fill=tunic_dark)

    # === BODY FRONT (20,20)-(28,32) - Jedi Knight black tunic ===
    draw.rectangle([20, 20, 27, 31], fill=tunic)
    # V-neck collar opening
    draw.point((23, 20), fill=tunic_light)
    draw.point((24, 20), fill=tunic_light)
    draw.point((22, 21), fill=flap)
    draw.point((23, 21), fill=tunic_light)
    draw.point((24, 21), fill=tunic_light)
    draw.point((25, 21), fill=flap)
    # Front fold/flap (asymmetric like Jedi tunic)
    draw.point((22, 22), fill=flap)
    draw.point((22, 23), fill=flap)
    draw.point((22, 24), fill=flap)
    draw.point((22, 25), fill=flap)
    draw.point((22, 26), fill=flap)
    # Right side fold
    draw.point((25, 22), fill=tunic_dark)
    draw.point((25, 23), fill=tunic_dark)
    draw.point((25, 24), fill=tunic_dark)
    # Edge shading
    draw.rectangle([20, 20, 20, 31], fill=tunic_dark)
    draw.rectangle([27, 20, 27, 31], fill=tunic_dark)
    # Utility belt
    draw.rectangle([20, 27, 27, 28], fill=belt)
    draw.rectangle([20, 27, 27, 27], fill=belt_dark)
    # Belt buckle
    draw.point((23, 27), fill=buckle)
    draw.point((24, 27), fill=buckle)
    draw.point((23, 28), fill=buckle)
    draw.point((24, 28), fill=buckle)
    # Lightsaber hilt on belt
    draw.point((26, 27), fill=lightsaber_green)
    draw.point((26, 28), fill=(160, 160, 170))  # hilt
    # Lower tunic
    draw.rectangle([20, 29, 27, 31], fill=tunic_dark)
    draw.point((23, 30), fill=shade(tunic_dark, -8))
    draw.point((24, 30), fill=shade(tunic_dark, -8))

    # === BODY BACK (32,20)-(40,32) ===
    draw.rectangle([32, 20, 39, 31], fill=tunic_dark)
    draw.rectangle([32, 27, 39, 28], fill=belt_dark)
    draw.point((35, 23), fill=shade(tunic_dark, -8))

    # === BODY SIDES ===
    draw.rectangle([16, 20, 19, 31], fill=tunic)
    draw.rectangle([16, 27, 19, 28], fill=belt_dark)
    draw.rectangle([16, 29, 19, 31], fill=tunic_dark)
    draw.rectangle([28, 20, 31, 31], fill=tunic)
    draw.rectangle([28, 27, 31, 28], fill=belt_dark)
    draw.rectangle([28, 29, 31, 31], fill=tunic_dark)

    # === ARMS ===
    draw.rectangle([44, 16, 47, 19], fill=tunic)
    draw.rectangle([48, 16, 51, 19], fill=tunic_dark)
    draw.rectangle([44, 20, 47, 31], fill=tunic)
    draw.rectangle([44, 20, 44, 31], fill=tunic_dark)
    # Right hand: black glove (Luke's mechanical hand)
    draw.rectangle([44, 29, 47, 31], fill=glove)
    draw.rectangle([52, 20, 55, 31], fill=tunic_dark)
    draw.rectangle([52, 29, 55, 31], fill=glove)
    # Left hand: skin
    draw.rectangle([40, 20, 43, 31], fill=tunic)
    draw.rectangle([40, 29, 43, 31], fill=skin)
    draw.rectangle([48, 20, 51, 31], fill=tunic)
    draw.rectangle([48, 29, 51, 31], fill=skin)

    return img


def main():
    os.makedirs(OUTPUT_DIR, exist_ok=True)

    generators = {
        "farmer": draw_farmer_texture,
        "librarian": draw_librarian_texture,
        "teacher": draw_teacher_texture,
        "explorer": draw_explorer_texture,
    }

    for npc_type, gen_func in generators.items():
        filename = f"wetlands_npc_{npc_type}.png"
        filepath = os.path.join(OUTPUT_DIR, filename)
        img = gen_func()
        img.save(filepath)
        print(f"Generated: {filename} (64x64)")

    print(f"\nAll textures saved to: {OUTPUT_DIR}")
    print("Hybrid approach: farmer/librarian=custom, teacher=Obi-Wan, explorer=Luke")


if __name__ == "__main__":
    main()
