
import sys
from PIL import Image, ImageDraw

def create_gold_k_texture(image_path):
    """
    Creates a gold texture with a black 'K' in the center.
    """
    try:
        img = Image.new("RGBA", (16, 16), (0, 0, 0, 0))
        draw = ImageDraw.Draw(img)

        # Gold color
        gold_color = (255, 215, 0, 255)

        # Draw the disc
        draw.ellipse((0, 0, 15, 15), fill=gold_color, outline="black")

        # Draw the black 'K'
        k_color = (0, 0, 0, 255)

        # Simple 'K' shape
        # Vertical bar
        draw.line((4, 4, 4, 11), fill=k_color, width=1)
        # Upper arm
        draw.line((5, 7, 8, 4), fill=k_color, width=1)
        # Lower arm
        draw.line((5, 7, 8, 11), fill=k_color, width=1)


        img.save(image_path)
        print(f"Created gold K texture at {image_path}")
    except Exception as e:
        print(f"Error processing {image_path}: {e}")

if __name__ == "__main__":
    if len(sys.argv) == 2:
        create_gold_k_texture(sys.argv[1])
    else:
        print("Usage: python modify_textures.py <image_path>")
