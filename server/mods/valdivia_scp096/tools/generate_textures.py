"""Genera las particulas de valdivia_scp096 (lagrima y furia).

El skin NO sale de aca: viene de server/skins/skins.json
(python scripts/rebuild-skins.py).

Uso: python tools/generate_textures.py   (desde la carpeta del mod)
"""
from pathlib import Path

from PIL import Image

OUT = Path(__file__).resolve().parent.parent / "textures"


def lagrima():
    # Gota celeste de 4x6 con brillo.
    im = Image.new("RGBA", (4, 6), (0, 0, 0, 0))
    azul, claro = (70, 170, 240, 230), (190, 230, 255, 255)
    for x, y in [(1, 0), (2, 0), (1, 1), (2, 1)]:
        im.putpixel((x, y), azul)
    for y in range(2, 5):
        for x in range(4):
            im.putpixel((x, y), azul)
    for x in (1, 2):
        im.putpixel((x, 5), azul)
    im.putpixel((1, 2), claro)
    im.save(OUT / "valdivia_scp096_lagrima.png")


def furia():
    # Mancha roja oscura de 4x4, borde semitransparente.
    im = Image.new("RGBA", (4, 4), (0, 0, 0, 0))
    for y in range(4):
        for x in range(4):
            borde = x in (0, 3) or y in (0, 3)
            if borde and (x, y) in [(0, 0), (3, 0), (0, 3), (3, 3)]:
                continue
            im.putpixel((x, y), (150, 10, 10, 150 if borde else 240))
    im.save(OUT / "valdivia_scp096_furia.png")


if __name__ == "__main__":
    OUT.mkdir(exist_ok=True)
    lagrima()
    furia()
    print("ok ->", OUT)
