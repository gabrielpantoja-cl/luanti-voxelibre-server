#!/usr/bin/env python3
"""
Generate unique NPC textures for Wetlands NPCs mod v3.0.0.

Creates 64x64 PNG textures following the mobs_mc_villager.b3d UV map.
Each NPC type has a distinct color palette and clothing style.

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

# Color palettes per NPC type: (skin, hair, robe_primary, robe_secondary, robe_accent, shoes)
PALETTES = {
    "farmer": {
        "skin": (210, 180, 140),       # Tan skin
        "hair": (139, 90, 43),          # Brown hair
        "robe_primary": (76, 153, 0),   # Green robe
        "robe_secondary": (55, 120, 0), # Darker green
        "robe_accent": (139, 90, 43),   # Brown belt
        "shoes": (101, 67, 33),         # Dark brown shoes
        "hat": (200, 180, 100),         # Straw hat
        "eye": (60, 40, 20),            # Brown eyes
    },
    "librarian": {
        "skin": (225, 195, 160),        # Light skin
        "hair": (50, 50, 50),           # Dark hair
        "robe_primary": (40, 80, 160),  # Blue robe
        "robe_secondary": (30, 60, 130),# Darker blue
        "robe_accent": (200, 200, 200), # White collar
        "shoes": (40, 40, 40),          # Black shoes
        "hat": (40, 80, 160),           # Blue hat (monocle area)
        "eye": (40, 40, 40),            # Dark eyes
    },
    "teacher": {
        "skin": (190, 150, 120),        # Medium skin
        "hair": (30, 30, 30),           # Black hair
        "robe_primary": (130, 50, 160), # Purple robe
        "robe_secondary": (100, 30, 130),# Darker purple
        "robe_accent": (220, 220, 220), # White collar
        "shoes": (60, 30, 60),          # Dark purple shoes
        "hat": (130, 50, 160),          # Purple hat
        "eye": (50, 30, 10),            # Dark eyes
    },
    "explorer": {
        "skin": (195, 160, 130),        # Warm skin
        "hair": (100, 60, 30),          # Auburn hair
        "robe_primary": (140, 110, 60), # Khaki robe
        "robe_secondary": (120, 90, 40),# Darker khaki
        "robe_accent": (80, 50, 20),    # Brown belt
        "shoes": (80, 50, 20),          # Brown boots
        "hat": (100, 80, 40),           # Explorer hat
        "eye": (40, 80, 40),            # Green eyes
    },
}


def draw_villager_texture(npc_type: str, palette: dict) -> Image.Image:
    """Draw a 64x64 villager texture with the given color palette."""
    img = Image.new("RGBA", (64, 64), (0, 0, 0, 0))
    draw = ImageDraw.Draw(img)

    skin = palette["skin"]
    hair = palette["hair"]
    robe1 = palette["robe_primary"]
    robe2 = palette["robe_secondary"]
    accent = palette["robe_accent"]
    shoes = palette["shoes"]
    hat_color = palette["hat"]
    eye = palette["eye"]

    # === HEAD ===
    # Head top (8,0)-(16,8) - hair/hat
    draw.rectangle([8, 0, 15, 7], fill=hat_color)

    # Head bottom (16,0)-(24,8) - under chin
    draw.rectangle([16, 0, 23, 7], fill=skin)

    # Head front (8,8)-(16,16) - face
    draw.rectangle([8, 8, 15, 15], fill=skin)
    # Eyes
    draw.point((10, 11), fill=eye)
    draw.point((13, 11), fill=eye)
    # Nose
    draw.point((11, 12), fill=(skin[0] - 20, skin[1] - 20, skin[2] - 20))
    draw.point((12, 12), fill=(skin[0] - 20, skin[1] - 20, skin[2] - 20))
    # Mouth (slight smile)
    draw.point((11, 14), fill=(180, 100, 100))
    draw.point((12, 14), fill=(180, 100, 100))
    # Hair at top of face
    draw.rectangle([8, 8, 15, 9], fill=hair)

    # Head back (24,8)-(32,16) - back of head
    draw.rectangle([24, 8, 31, 15], fill=hair)

    # Head left (0,8)-(8,16)
    draw.rectangle([0, 8, 7, 15], fill=skin)
    draw.rectangle([0, 8, 7, 9], fill=hair)  # Hair strip

    # Head right (16,8)-(24,16)
    draw.rectangle([16, 8, 23, 15], fill=skin)
    draw.rectangle([16, 8, 23, 9], fill=hair)  # Hair strip

    # === BODY ===
    # Body top (20,16)-(28,20)
    draw.rectangle([20, 16, 27, 19], fill=accent)

    # Body bottom (28,16)-(36,20)
    draw.rectangle([28, 16, 35, 19], fill=robe2)

    # Body front (20,20)-(28,32)
    draw.rectangle([20, 20, 27, 31], fill=robe1)
    # Collar/accent at top
    draw.rectangle([20, 20, 27, 21], fill=accent)
    # Belt
    draw.rectangle([20, 27, 27, 28], fill=accent)

    # Add profession-specific detail on front
    if npc_type == "farmer":
        # Overalls straps
        draw.point((22, 22), fill=accent)
        draw.point((25, 22), fill=accent)
        draw.point((22, 23), fill=accent)
        draw.point((25, 23), fill=accent)
    elif npc_type == "librarian":
        # Book pocket
        draw.rectangle([22, 24, 25, 26], fill=(139, 90, 43))
    elif npc_type == "teacher":
        # Tie
        draw.point((23, 22), fill=(200, 50, 50))
        draw.point((24, 22), fill=(200, 50, 50))
        draw.point((23, 23), fill=(200, 50, 50))
        draw.point((24, 23), fill=(200, 50, 50))
        draw.point((23, 24), fill=(180, 40, 40))
        draw.point((24, 24), fill=(180, 40, 40))
    elif npc_type == "explorer":
        # Belt with buckle
        draw.rectangle([23, 27, 24, 28], fill=(200, 180, 0))

    # Body back (32,20)-(40,32)
    draw.rectangle([32, 20, 39, 31], fill=robe2)
    draw.rectangle([32, 27, 39, 28], fill=accent)

    # Body left (16,20)-(20,32)
    draw.rectangle([16, 20, 19, 31], fill=robe1)

    # Body right (28,20)-(32,32)
    draw.rectangle([28, 20, 31, 31], fill=robe1)

    # === ARMS ===
    # Right arm top (44,16)-(48,20)
    draw.rectangle([44, 16, 47, 19], fill=robe1)

    # Right arm bottom (48,16)-(52,20)
    draw.rectangle([48, 16, 51, 19], fill=robe1)

    # Right arm front (44,20)-(48,32)
    draw.rectangle([44, 20, 47, 31], fill=robe1)
    draw.rectangle([44, 28, 47, 31], fill=skin)  # Hand

    # Right arm back (52,20)-(56,32)
    draw.rectangle([52, 20, 55, 31], fill=robe2)
    draw.rectangle([52, 28, 55, 31], fill=skin)

    # Right arm left (40,20)-(44,32)
    draw.rectangle([40, 20, 43, 31], fill=robe1)
    draw.rectangle([40, 28, 43, 31], fill=skin)

    # Right arm right (48,20)-(52,32)
    draw.rectangle([48, 20, 51, 31], fill=robe1)
    draw.rectangle([48, 28, 51, 31], fill=skin)

    # === LEGS ===
    # Right leg top (4,16)-(8,20)
    draw.rectangle([4, 16, 7, 19], fill=robe2)

    # Right leg bottom (8,16)-(12,20)
    draw.rectangle([8, 16, 11, 19], fill=robe2)

    # Right leg front (4,20)-(8,32)
    draw.rectangle([4, 20, 7, 31], fill=robe2)
    draw.rectangle([4, 29, 7, 31], fill=shoes)

    # Right leg back (12,20)-(16,32)
    draw.rectangle([12, 20, 15, 31], fill=robe2)
    draw.rectangle([12, 29, 15, 31], fill=shoes)

    # Right leg left (0,20)-(4,32)
    draw.rectangle([0, 20, 3, 31], fill=robe2)
    draw.rectangle([0, 29, 3, 31], fill=shoes)

    # Right leg right (8,20)-(12,32)
    draw.rectangle([8, 20, 11, 31], fill=robe2)
    draw.rectangle([8, 29, 11, 31], fill=shoes)

    return img


def main():
    os.makedirs(OUTPUT_DIR, exist_ok=True)

    for npc_type, palette in PALETTES.items():
        filename = f"wetlands_npc_{npc_type}.png"
        filepath = os.path.join(OUTPUT_DIR, filename)

        img = draw_villager_texture(npc_type, palette)
        img.save(filepath)
        print(f"Generated: {filename} (64x64)")

    print(f"\nAll textures saved to: {OUTPUT_DIR}")


if __name__ == "__main__":
    main()
