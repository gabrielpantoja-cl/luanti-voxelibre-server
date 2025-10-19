
import sys
from PIL import Image
import random

def add_noise(image_path):
    """
    Adds random noise to an image.
    """
    try:
        img = Image.open(image_path).convert("RGBA")
        pixels = img.load()
        for i in range(img.width):
            for j in range(img.height):
                r, g, b, a = pixels[i, j]
                noise = random.randint(-20, 20)
                r = max(0, min(255, r + noise))
                g = max(0, min(255, g + noise))
                b = max(0, min(255, b + noise))
                pixels[i, j] = (r, g, b, a)
        img.save(image_path)
        print(f"Added noise to {image_path}")
    except Exception as e:
        print(f"Error processing {image_path}: {e}")

if __name__ == "__main__":
    if len(sys.argv) > 1:
        for image_path in sys.argv[1:]:
            add_noise(image_path)
    else:
        print("Usage: python modify_textures.py <image_path1> <image_path2> ...")
