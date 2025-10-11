#!/usr/bin/env python3
"""
Generate bathroom sign texture for 3dforniture mod
Creates a simple sign with "Baño $500" text
"""

from PIL import Image, ImageDraw, ImageFont
import os

# Configuration
OUTPUT_PATH = "../server/mods/3dforniture/textures/3dforniture_bathroom_sign.png"
IMAGE_SIZE = (256, 256)  # Standard texture size for Luanti/Minetest
BACKGROUND_COLOR = (255, 255, 255)  # White background
TEXT_COLOR = (0, 0, 0)  # Black text
BORDER_COLOR = (50, 50, 150)  # Dark blue border

def create_bathroom_sign():
    """Create a bathroom sign texture with text"""

    # Create image with white background
    img = Image.new('RGB', IMAGE_SIZE, BACKGROUND_COLOR)
    draw = ImageDraw.Draw(img)

    # Draw border
    border_width = 8
    draw.rectangle(
        [border_width, border_width,
         IMAGE_SIZE[0] - border_width, IMAGE_SIZE[1] - border_width],
        outline=BORDER_COLOR,
        width=border_width
    )

    # Try to use a decent font, fallback to default if not available
    try:
        # Try common system fonts
        font_large = ImageFont.truetype("/usr/share/fonts/truetype/dejavu/DejaVuSans-Bold.ttf", 50)
        font_small = ImageFont.truetype("/usr/share/fonts/truetype/dejavu/DejaVuSans-Bold.ttf", 36)
    except:
        try:
            font_large = ImageFont.truetype("/usr/share/fonts/truetype/liberation/LiberationSans-Bold.ttf", 50)
            font_small = ImageFont.truetype("/usr/share/fonts/truetype/liberation/LiberationSans-Bold.ttf", 36)
        except:
            # Use default font as fallback
            font_large = ImageFont.load_default()
            font_small = ImageFont.load_default()

    # Draw "Baño" text (centered, upper part)
    text1 = "Baño"
    bbox1 = draw.textbbox((0, 0), text1, font=font_large)
    text1_width = bbox1[2] - bbox1[0]
    text1_height = bbox1[3] - bbox1[1]
    text1_x = (IMAGE_SIZE[0] - text1_width) // 2
    text1_y = IMAGE_SIZE[1] // 3 - text1_height // 2

    draw.text((text1_x, text1_y), text1, fill=TEXT_COLOR, font=font_large)

    # Draw "$500" text (centered, lower part)
    text2 = "$500"
    bbox2 = draw.textbbox((0, 0), text2, font=font_small)
    text2_width = bbox2[2] - bbox2[0]
    text2_height = bbox2[3] - bbox2[1]
    text2_x = (IMAGE_SIZE[0] - text2_width) // 2
    text2_y = 2 * IMAGE_SIZE[1] // 3 - text2_height // 2

    draw.text((text2_x, text2_y), text2, fill=TEXT_COLOR, font=font_small)

    # Get absolute path for output
    script_dir = os.path.dirname(os.path.abspath(__file__))
    output_file = os.path.join(script_dir, OUTPUT_PATH)

    # Save the image
    img.save(output_file, 'PNG')
    print(f"✅ Bathroom sign texture created successfully!")
    print(f"   Output: {output_file}")
    print(f"   Size: {IMAGE_SIZE[0]}x{IMAGE_SIZE[1]} pixels")

if __name__ == "__main__":
    create_bathroom_sign()
