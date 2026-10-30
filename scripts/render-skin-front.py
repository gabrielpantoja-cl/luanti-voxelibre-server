"""Monigote frontal de un skin 64x32 de Luanti, para verificar a ojo."""
import sys, os, glob
from PIL import Image, ImageDraw

# (caja en el 64x32, posicion en el monigote 16x32)
PARTS = [
    ((8, 8, 16, 16),  (4, 0)),    # cara
    ((40, 8, 48, 16), (4, 0)),    # gorro (overlay cabeza)
    ((20, 20, 28, 32), (4, 8)),   # torso frente
    ((44, 20, 48, 32), (0, 8)),   # brazo der.
    ((44, 20, 48, 32), (12, 8)),  # brazo izq. (espejo)
    ((4, 20, 8, 32),  (4, 20)),   # pierna der.
    ((4, 20, 8, 32),  (8, 20)),   # pierna izq. (espejo)
]

def monigote(path, scale=4):
    s = Image.open(path).convert("RGBA")
    m = Image.new("RGBA", (16, 32), (0, 0, 0, 0))
    for box, dest in PARTS:
        m.alpha_composite(s.crop(box), dest)
    return m.resize((16 * scale, 32 * scale), Image.NEAREST)

if __name__ == "__main__":
    files = sorted(glob.glob(os.path.join(sys.argv[1], "*.png")))
    scale, pad = 4, 10
    w, h = 16 * scale, 32 * scale
    sheet = Image.new("RGBA", (len(files) * (w + pad) + pad, h + 2 * pad + 14), (32, 34, 38, 255))
    d = ImageDraw.Draw(sheet)
    for i, f in enumerate(files):
        x = pad + i * (w + pad)
        sheet.alpha_composite(monigote(f, scale), (x, pad))
        d.text((x, pad + h + 2), os.path.basename(f)[:14], fill=(220, 220, 220, 255))
    sheet.save(sys.argv[2])
    print(sys.argv[2], sheet.size)
