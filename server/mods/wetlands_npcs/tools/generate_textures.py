#!/usr/bin/env python3
"""
Generate NPC textures for Wetlands NPCs by recoloring VoxeLibre's base villager.

Instead of drawing pixel art from scratch (which gets the UV map wrong),
this script takes the real mobs_mc_villager.png and recolors it for each
NPC type, preserving the exact UV layout, shading, and detail.

Hybrid approach:
  - Farmer: warm green + brown apron tones
  - Librarian: deep blue robe + white accents
  - Teacher (Obi-Wan): tan/beige Jedi robe
  - Explorer (Luke): black/dark tunic
"""

import os
import colorsys
from PIL import Image

SCRIPT_DIR = os.path.dirname(os.path.abspath(__file__))
TEXTURES_DIR = os.path.join(os.path.dirname(SCRIPT_DIR), "textures")
RAW_SKINS_DIR = os.path.join(TEXTURES_DIR, "raw_skins")
REF_BASE = os.path.join(RAW_SKINS_DIR, "ref_villager_base.png")


def rgb_to_hsv(r, g, b):
    """Convert RGB (0-255) to HSV (h:0-360, s:0-1, v:0-1)."""
    h, s, v = colorsys.rgb_to_hsv(r / 255.0, g / 255.0, b / 255.0)
    return h * 360, s, v


def hsv_to_rgb(h, s, v):
    """Convert HSV (h:0-360, s:0-1, v:0-1) to RGB (0-255)."""
    r, g, b = colorsys.hsv_to_rgb(h / 360.0, s, v)
    return int(r * 255), int(g * 255), int(b * 255)


def classify_pixel(r, g, b):
    """Classify a pixel as 'robe', 'skin', or 'accent' based on color.

    Base villager colors:
    - Robe: greenish (65,75,35) to (79,91,41) - hue ~70-80
    - Skin: warm brown (145,122,97) to (157,135,111) - hue ~25-35
    - Nose/dark skin: (126,93,58) - hue ~28
    - Grey-green accents: (75,86,68) to (94,107,83)
    """
    h, s, v = rgb_to_hsv(r, g, b)

    # Very dark pixels -> robe shadow
    if v < 0.15:
        return "robe"

    # Skin tones: warm, medium-high value, moderate saturation
    # Hue range roughly 15-40 degrees (orange-brown)
    if 15 < h < 45 and s > 0.15 and v > 0.35:
        return "skin"

    # Green robe area: hue 50-100
    if 50 < h < 110:
        if s > 0.2:
            return "robe"
        else:
            return "robe_grey"  # grey-green accents

    # Low saturation grey-ish -> robe accent
    if s < 0.15 and v > 0.2:
        return "robe_grey"

    return "robe"


def recolor_pixel(r, g, b, pixel_class, palette):
    """Recolor a pixel based on its class and target palette.

    Preserves relative brightness and saturation while shifting hue.
    """
    h, s, v = rgb_to_hsv(r, g, b)

    if pixel_class == "skin":
        # Shift to target skin tone, preserve brightness
        th, ts, tv = rgb_to_hsv(*palette["skin"])
        # Keep relative brightness variation
        base_v = 0.55  # approximate base skin brightness
        v_ratio = v / base_v if base_v > 0 else 1.0
        new_v = min(1.0, tv * v_ratio)
        new_s = min(1.0, ts * (s / 0.35 if 0.35 > 0 else 1.0))
        new_s = max(0.05, min(1.0, new_s))
        return hsv_to_rgb(th, new_s, new_v)

    elif pixel_class == "robe":
        th, ts, tv = rgb_to_hsv(*palette["robe"])
        base_v = 0.32  # approximate base robe brightness
        v_ratio = v / base_v if base_v > 0 else 1.0
        new_v = min(1.0, tv * v_ratio)
        new_s = min(1.0, ts * (s / 0.55 if 0.55 > 0 else 1.0))
        new_s = max(0.05, min(1.0, new_s))
        return hsv_to_rgb(th, new_s, new_v)

    elif pixel_class == "robe_grey":
        # For grey accents on the robe, use a desaturated version of robe color
        th, ts, tv = rgb_to_hsv(*palette.get("robe_accent", palette["robe"]))
        base_v = 0.38
        v_ratio = v / base_v if base_v > 0 else 1.0
        new_v = min(1.0, tv * v_ratio)
        new_s = min(1.0, ts * 0.6)  # more desaturated
        return hsv_to_rgb(th, new_s, new_v)

    return (r, g, b)


def recolor_texture(base_img, palette):
    """Recolor an entire texture image with a new palette."""
    result = base_img.copy().convert("RGBA")

    for y in range(result.height):
        for x in range(result.width):
            r, g, b, a = result.getpixel((x, y))
            if a == 0:
                continue

            pixel_class = classify_pixel(r, g, b)
            nr, ng, nb = recolor_pixel(r, g, b, pixel_class, palette)
            result.putpixel((x, y), (nr, ng, nb, a))

    return result


def add_face_details(img, palette):
    """Add subtle face details (eyes, expression) on the head front region.

    Head front is at approximately (8,8)-(16,18) in the villager UV.
    The face area within that is roughly rows 10-15.
    """
    draw_pixels = []

    eye_color = palette.get("eye", (40, 40, 40))
    eye_white = palette.get("eye_white", (230, 230, 225))

    # The villager face area: within (8,8)-(16,18)
    # Eyes are roughly at row 11-12 from top of texture
    # Left eye: x=10, Right eye: x=14
    # But we need to be careful not to overwrite important UV data
    # Only add if the palette requests it
    if palette.get("add_eyes", False):
        # Left eye
        draw_pixels.append((10, 11, eye_white))
        draw_pixels.append((11, 11, eye_color))
        # Right eye
        draw_pixels.append((14, 11, eye_color))
        draw_pixels.append((15, 11, eye_white))

    if palette.get("add_beard", False):
        beard_color = palette["beard"]
        # Beard on lower face area (rows 14-16)
        for x in range(9, 16):
            draw_pixels.append((x, 15, beard_color))
            draw_pixels.append((x, 16, beard_color))
        for x in range(10, 15):
            draw_pixels.append((x, 17, beard_color))

    for x, y, color in draw_pixels:
        if 0 <= x < img.width and 0 <= y < img.height:
            _, _, _, a = img.getpixel((x, y))
            if a > 0:  # Only draw on existing pixels
                img.putpixel((x, y), (*color, 255))

    return img


# NPC Palettes
PALETTES = {
    "farmer": {
        "robe": (55, 130, 35),        # Fresh green
        "robe_accent": (80, 100, 60),  # Grey-green
        "skin": (210, 175, 135),       # Warm tan
        "eye": (55, 35, 15),
        "eye_white": (235, 230, 220),
        "add_eyes": True,
    },
    "librarian": {
        "robe": (35, 65, 150),         # Deep blue
        "robe_accent": (60, 75, 110),  # Blue-grey
        "skin": (225, 195, 160),       # Fair skin
        "eye": (35, 35, 35),
        "eye_white": (235, 235, 235),
        "add_eyes": True,
    },
    "teacher": {
        # Obi-Wan Kenobi - tan/beige Jedi robe
        "robe": (170, 140, 95),        # Tan/beige
        "robe_accent": (145, 125, 90), # Darker tan
        "skin": (210, 180, 150),       # Warm skin
        "eye": (65, 115, 165),         # Blue eyes (Obi-Wan)
        "eye_white": (230, 230, 230),
        "add_eyes": True,
        "add_beard": True,
        "beard": (155, 115, 60),       # Ginger beard
    },
    "explorer": {
        # Luke Skywalker - dark/black outfit (RotJ)
        "robe": (35, 35, 40),          # Near-black
        "robe_accent": (55, 55, 60),   # Dark grey
        "skin": (215, 185, 155),       # Warm skin
        "eye": (65, 115, 165),         # Blue eyes (Luke)
        "eye_white": (230, 230, 230),
        "add_eyes": True,
    },
}


def main():
    if not os.path.exists(REF_BASE):
        print(f"ERROR: Base villager texture not found at: {REF_BASE}")
        print("Run this first on VPS:")
        print("  scp gabriel@167.172.251.27:.../textures/mobs_mc_villager.png raw_skins/ref_villager_base.png")
        return

    base_img = Image.open(REF_BASE).convert("RGBA")
    print(f"Loaded base texture: {base_img.size}")

    os.makedirs(TEXTURES_DIR, exist_ok=True)

    for npc_type, palette in PALETTES.items():
        filename = f"wetlands_npc_{npc_type}.png"
        filepath = os.path.join(TEXTURES_DIR, filename)

        result = recolor_texture(base_img, palette)
        result = add_face_details(result, palette)
        result.save(filepath)

        print(f"Generated: {filename} (recolored from VoxeLibre base)")

    print(f"\nAll textures saved to: {TEXTURES_DIR}")
    print("Hybrid: farmer/librarian=custom colors, teacher=Obi-Wan, explorer=Luke")


if __name__ == "__main__":
    main()
