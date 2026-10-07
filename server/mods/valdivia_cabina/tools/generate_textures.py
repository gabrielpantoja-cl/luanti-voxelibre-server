#!/usr/bin/env python3
"""
Genera las texturas 16x16 de la cabina TP de Valdivia a partir del dibujo de
Gaspi (cabina roja con techo rayado, letrero blanco "TP", puerta blanca con
manilla y pilares rayados). Pixel art reproducible: editar aca y re-ejecutar.

La cabina son dos nodos (abajo + arriba), cada uno con su textura de 16x16:

  frente_arriba : cornisa rayada (filas 0-3), letrero "TP" (4-10), puerta (11-15)
  frente_abajo  : puerta con manilla (0-13), zocalo (14-15)
  lado_arriba   : cornisa rayada + cuerpo rayado
  lado_abajo    : cuerpo rayado + zocalo
  techo         : techo rayado con borde
  base          : rojo oscuro

El nodebox (init.lua) mete el cuerpo 1 px hacia adentro (columnas 1-14) y deja
la cornisa y el zocalo a ancho completo (columnas 0-15).

Uso:
    python tools/generate_textures.py            # escribe textures/
    python tools/generate_textures.py --preview salida.png [--dibujo foto.jpg]
"""

import argparse
import os

from PIL import Image

MOD = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
OUT = os.path.join(MOD, "textures")
PREFIX = "valdivia_cabina_"

# Rojos del plumon del dibujo + blancos de la pizarra.
R = (198, 40, 58, 255)     # rojo base
RL = (228, 96, 112, 255)   # raya clara (el rayado a mano)
RD = (130, 22, 38, 255)    # contorno / sombra
W = (244, 240, 234, 255)   # blanco del letrero y la puerta
WS = (216, 208, 200, 255)  # blanco en sombra (borde interior de la puerta)
H = (80, 18, 30, 255)      # manilla


def rayado(x, y):
    """Rojo con rayas diagonales, como el sombreado a mano del dibujo."""
    return RL if (x + y) % 4 == 0 else R


def lienzo():
    return Image.new("RGBA", (16, 16), R)


def put(img, x, y, c):
    img.putpixel((x, y), c)


def columnas_frente(img, y, puerta=True):
    """Una fila del cuerpo frontal: borde, pilar rayado, marco, puerta, marco, pilar, borde."""
    for x in range(16):
        if x in (0, 15):
            c = RD            # solo visible en cornisa/zocalo (cuerpo va 1 px adentro)
        elif x in (1, 14):
            c = RD            # arista del cuerpo
        elif x in (4, 11):
            c = RD            # marco de la puerta
        elif 5 <= x <= 10 and puerta:
            c = WS if x == 5 else W
        else:
            c = rayado(x, y)  # pilares
        put(img, x, y, c)


def cornisa(img):
    for y in range(4):
        for x in range(16):
            put(img, x, y, RD if y == 3 else rayado(x, y))


def frente_arriba():
    img = lienzo()
    cornisa(img)
    # Letrero blanco "TP" entre dos lineas rojas oscuras.
    for x in range(16):
        put(img, x, 4, RD)
        put(img, x, 10, RD)
    for y in range(5, 10):
        for x in range(16):
            put(img, x, y, RD if x in (0, 1, 14, 15) else W)
    # T
    for x in range(3, 8):
        put(img, x, 5, R)
    for y in range(6, 10):
        put(img, 5, y, R)
    # P
    for y in range(5, 10):
        put(img, 9, y, R)
    for x, y in ((10, 5), (11, 5), (12, 6), (10, 7), (11, 7)):
        put(img, x, y, R)
    # Parte alta de la puerta.
    for y in range(11, 16):
        columnas_frente(img, y)
    return img


def frente_abajo():
    img = lienzo()
    for y in range(14):
        columnas_frente(img, y)
    # Manilla (el "-" del dibujo, a la izquierda de la puerta).
    put(img, 6, 3, H)
    put(img, 7, 3, H)
    for x in range(16):
        put(img, x, 14, RD)
        put(img, x, 15, RD if x in (0, 15) else R)
    return img


def lado(arriba):
    img = lienzo()
    for y in range(16):
        for x in range(16):
            put(img, x, y, RD if x in (0, 1, 14, 15) else rayado(x, y))
    if arriba:
        cornisa(img)
    else:
        for x in range(16):
            put(img, x, 14, RD)
            put(img, x, 15, RD if x in (0, 15) else R)
    return img


def techo():
    img = lienzo()
    for y in range(16):
        for x in range(16):
            borde = x in (0, 15) or y in (0, 15)
            put(img, x, y, RD if borde else rayado(x, y))
    return img


def base():
    return Image.new("RGBA", (16, 16), RD)


TEXTURAS = {
    "frente_arriba": frente_arriba,
    "frente_abajo": frente_abajo,
    "lado_arriba": lambda: lado(True),
    "lado_abajo": lambda: lado(False),
    "techo": techo,
    "base": base,
}


def preview(imgs, destino, dibujo=None):
    """Frente y lado (dos nodos apilados) en grande, junto al dibujo original."""
    escala = 16
    alto = 32 * escala
    frente = Image.new("RGBA", (16, 32))
    frente.paste(imgs["frente_arriba"], (0, 0))
    frente.paste(imgs["frente_abajo"], (0, 16))
    costado = Image.new("RGBA", (16, 32))
    costado.paste(imgs["lado_arriba"], (0, 0))
    costado.paste(imgs["lado_abajo"], (0, 16))
    piezas = []
    if dibujo:
        d = Image.open(dibujo).convert("RGBA")
        d = d.resize((int(d.width * alto / d.height), alto))
        piezas.append(d)
    piezas.append(frente.resize((16 * escala, alto), Image.NEAREST))
    piezas.append(costado.resize((16 * escala, alto), Image.NEAREST))
    piezas.append(imgs["techo"].resize((16 * escala, 16 * escala), Image.NEAREST))
    margen = 40
    ancho = sum(p.width for p in piezas) + margen * (len(piezas) + 1)
    lienzo_prev = Image.new("RGBA", (ancho, alto + 2 * margen), (40, 44, 52, 255))
    x = margen
    for p in piezas:
        lienzo_prev.paste(p, (x, margen), p)
        x += p.width + margen
    lienzo_prev.save(destino)


def main():
    ap = argparse.ArgumentParser()
    ap.add_argument("--preview")
    ap.add_argument("--dibujo")
    args = ap.parse_args()
    os.makedirs(OUT, exist_ok=True)
    imgs = {nombre: fn() for nombre, fn in TEXTURAS.items()}
    for nombre, img in imgs.items():
        img.save(os.path.join(OUT, PREFIX + nombre + ".png"))
    print("Texturas en", OUT)
    if args.preview:
        preview(imgs, args.preview, args.dibujo)
        print("Vista previa en", args.preview)


if __name__ == "__main__":
    main()
