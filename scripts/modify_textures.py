import sys
from PIL import Image

def modify_texture(image_path):
    """
    Modifies the texture to have a silver disc with a black center.
    """
    try:
        img = Image.open(image_path).convert("RGBA")
        pixels = img.load()
        for i in range(img.width):
            for j in range(img.height):
                r, g, b, a = pixels[i, j]
                # Check for transparency
                if a > 0:
                    # Check for yellow (center)
                    if r > 200 and g > 200 and b < 100:
                        pixels[i, j] = (0, 0, 0, a)  # Black
                    else:
                        pixels[i, j] = (192, 192, 192, a)  # Silver
        img.save(image_path)
        print(f"Modified texture {image_path}")
    except Exception as e:
        print(f"Error processing {image_path}: {e}")

if __name__ == "__main__":
    if len(sys.argv) > 1:
        for image_path in sys.argv[1:]:
            modify_texture(image_path)
    else:
        print("Usage: python modify_textures.py <image_path1> <image_path2> ...")