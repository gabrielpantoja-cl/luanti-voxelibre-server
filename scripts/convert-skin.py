#!/usr/bin/env python3
"""Convierte un skin de Minecraft 64x64 al formato 64x32 que usa Luanti
(mcl_armor_character.b3d), horneando la capa de overlay sobre la base.

Por que no basta `crop((0,0,64,32))`: el formato 64x64 guarda DOS capas, una
base y un overlay con alpha (chaqueta, mangas, pantalones, gorro). El recorte
se queda solo con la base y borra en silencio la chaqueta, la mochila y las
mangas. Paso documentado en AGENTS.md: a GAELSIN le costo el casco del
mandalorian y el peto de diamante.

Esto hace lo mismo que el conversor de godly (Copy Jacket / Copy Sleeve /
Copy Trouser con alpha 1.0), sin navegador:

  64x64                                   64x32 (salida)
  filas  0-15  cabeza base + gorro   ->   se copia tal cual (el formato 64x32
                                          YA tiene capa de gorro, no se hornea)
  filas 16-31  pierna/torso/brazo    ->   se copia tal cual
  filas 32-47  overlay de esos tres  ->   se hornea encima de las filas 16-31
  filas 48-63  brazo/pierna izq.     ->   se descarta: en 64x32 los miembros
                                          izquierdos son el espejo del derecho

Uso:  python scripts/convert-skin.py entrada_64x64.png salida_64x32.png
"""
import sys
from PIL import Image

# (region de overlay en el 64x64, esquina destino en la salida 64x32)
OVERLAYS = [
    ((0,  32, 16, 48), (0,  16)),   # pantalon derecho -> pierna derecha
    ((16, 32, 40, 48), (16, 16)),   # chaqueta         -> torso
    ((40, 32, 56, 48), (40, 16)),   # manga derecha    -> brazo derecho
]


def convert(src_path, dst_path):
    src = Image.open(src_path).convert("RGBA")
    if src.size == (64, 32):
        src.save(dst_path)
        return "ya era 64x32"
    if src.size != (64, 64):
        raise SystemExit(f"{src_path}: se esperaba 64x64 o 64x32, no {src.size}")

    out = src.crop((0, 0, 64, 32))
    horneado = 0
    for box, dest in OVERLAYS:
        layer = src.crop(box)
        if any(px[3] > 0 for px in layer.getdata()):
            out.alpha_composite(layer, dest)
            horneado += 1
    out.save(dst_path)
    return f"{horneado}/3 regiones de overlay horneadas"


if __name__ == "__main__":
    if len(sys.argv) != 3:
        raise SystemExit(__doc__)
    print(convert(sys.argv[1], sys.argv[2]))
