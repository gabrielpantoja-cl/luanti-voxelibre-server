#!/usr/bin/env python3
"""
Dibuja el mega cartel del Hotel Dreams (Valdivia, 30001) y lo corta en los
mosaicos que usa el mod.

Una sola imagen grande (cols*tile x filas*tile) se trocea en nodos de 256x256:
cada nodo del cartel lleva su propio pedazo como textura. Asi el texto se puede
leer de verdad -- un nodo solo, con 16x16, no alcanza ni para una palabra.

Los pisos NO se escriben aca: viven en ../pisos.json (fuente unica, la misma
que lee init.lua para el formspec). Editar ese JSON y re-ejecutar:

    python tools/generate_cartel.py
    python tools/generate_cartel.py --preview       # tambien guarda la lamina entera

Salida: ../textures/valdivia_hotel_cartel_r<fila>c<col>.png  (fila 1 = arriba)
"""

import argparse
import json
import os

from PIL import Image, ImageDraw, ImageFont

MOD = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
OUT = os.path.join(MOD, "textures")
PREFIX = "valdivia_hotel_cartel_"
DATOS = os.path.join(MOD, "pisos.json")

# Paleta: azul noche de hotel + dorado. Sobria, legible de lejos.
FONDO_ARRIBA = (16, 28, 48)
FONDO_ABAJO = (7, 14, 26)
MARCO = (214, 174, 92)
MARCO_INT = (120, 96, 48)
TITULO = (247, 221, 160)
SUBTITULO = (158, 180, 206)
PIE = (120, 142, 168)
RAYA = (24, 40, 66)
BADGE_BG = (26, 44, 70)
BADGE_BORDE = (72, 104, 148)
BADGE_TXT = (236, 244, 255)

COLOR_ESTADO = {
    "libre": (127, 209, 160),
    "reservado": (245, 196, 94),
    "fiesta": (255, 127, 208),
}
COLOR_DETALLE = (176, 196, 220)

FUENTES_BOLD = [
    "C:/Windows/Fonts/arialbd.ttf",
    "/usr/share/fonts/truetype/dejavu/DejaVuSans-Bold.ttf",
    "/Library/Fonts/Arial Bold.ttf",
]
FUENTES_REG = [
    "C:/Windows/Fonts/arial.ttf",
    "/usr/share/fonts/truetype/dejavu/DejaVuSans.ttf",
    "/Library/Fonts/Arial.ttf",
]


def fuente(size, bold=True):
    for ruta in (FUENTES_BOLD if bold else FUENTES_REG):
        if os.path.exists(ruta):
            return ImageFont.truetype(ruta, size)
    raise SystemExit("No encontre una fuente TrueType; agrega una ruta en FUENTES_*.")


def ancho(draw, texto, font):
    izq, _, der, _ = draw.textbbox((0, 0), texto, font=font)
    return der - izq


def encajar(draw, texto, size_max, max_ancho, bold=True, size_min=18):
    """La fuente mas grande con la que 'texto' cabe en max_ancho."""
    size = size_max
    while size > size_min and ancho(draw, texto, fuente(size, bold)) > max_ancho:
        size -= 2
    return fuente(size, bold)


def centrado(draw, texto, font, cx, y, fill, sombra=None):
    w = ancho(draw, texto, font)
    if sombra:
        draw.text((cx - w / 2 + 3, y + 3), texto, font=font, fill=sombra)
    draw.text((cx - w / 2, y), texto, font=font, fill=fill)


def fondo(W, H):
    img = Image.new("RGBA", (W, H))
    d = ImageDraw.Draw(img)
    for y in range(H):
        t = y / max(1, H - 1)
        d.line(
            [(0, y), (W, y)],
            fill=tuple(
                int(a + (b - a) * t) + 0 for a, b in zip(FONDO_ARRIBA, FONDO_ABAJO)
            )
            + (255,),
        )
    # Marco doble dorado.
    d.rectangle([6, 6, W - 7, H - 7], outline=MARCO, width=6)
    d.rectangle([22, 22, W - 23, H - 23], outline=MARCO_INT, width=2)
    return img


def alto(draw, texto, font):
    _, arr, _, ab = draw.textbbox((0, 0), texto, font=font)
    return ab - arr


def fila(d, x, y, w, h, piso, i):
    """Una linea del directorio: badge con el numero + nombre (y detalle debajo)."""
    if i % 2 == 0:
        d.rounded_rectangle([x, y, x + w, y + h - 8], radius=10, fill=RAYA)

    bw, bh = 118, h - 24
    by = y + 8
    d.rounded_rectangle(
        [x + 8, by, x + 8 + bw, by + bh], radius=12, fill=BADGE_BG, outline=BADGE_BORDE, width=3
    )
    num = str(piso["n"])
    fnum = encajar(d, num, int(bh * 0.74), bw - 24)
    centrado(d, num, fnum, x + 8 + bw / 2, by + (bh - alto(d, num, fnum)) / 2 - fnum.size * 0.17, BADGE_TXT)

    tx = x + 8 + bw + 22
    disponible = x + w - tx - 12
    nombre = piso["nombre"]
    detalle = piso.get("detalle")
    color = COLOR_ESTADO.get(piso.get("estado", "libre"), COLOR_ESTADO["libre"])

    # El detalle (quien reservo el piso) va en una segunda linea mas chica: si
    # se mete en la misma linea obliga a encoger el nombre hasta lo ilegible.
    fn = encajar(d, nombre, int(bh * (0.52 if detalle else 0.62)), disponible)
    if detalle:
        fd = fuente(max(18, int(fn.size * 0.6)), bold=False)
        bloque = fn.size * 1.16 + fd.size * 1.1
        ty = y + (h - 8 - bloque) / 2
        d.text((tx, ty), nombre, font=fn, fill=color)
        d.text((tx + 2, ty + fn.size * 1.16), "(%s)" % detalle, font=fd, fill=COLOR_DETALLE)
    else:
        ty = y + (h - 8 - fn.size * 1.2) / 2
        d.text((tx, ty), nombre, font=fn, fill=color)


def dibujar(datos):
    g = datos["grid"]
    tile, cols, filas = g["tile"], g["cols"], g["filas"]
    W, H = cols * tile, filas * tile
    img = fondo(W, H)
    d = ImageDraw.Draw(img, "RGBA")

    # Cabecera.
    ftit = encajar(d, datos["titulo"], 132, W - 160)
    centrado(d, datos["titulo"], ftit, W / 2, 30, TITULO, sombra=(0, 0, 0, 160))
    fsub = encajar(d, datos["subtitulo"], 38, W - 240)
    centrado(d, datos["subtitulo"], fsub, W / 2, 34 + ftit.size * 1.2, SUBTITULO)
    y_sep = int(44 + ftit.size * 1.2 + fsub.size * 1.4)
    d.line([(60, y_sep), (W - 60, y_sep)], fill=MARCO_INT, width=3)

    # Dos columnas: el alto del hall (4 nodos) no da para 15 lineas apiladas,
    # y en dos columnas cada linea mide el doble -> se lee desde lejos.
    pisos = datos["pisos"]
    mitad = (len(pisos) + 1) // 2
    cols_pisos = [pisos[:mitad], pisos[mitad:]]

    fpie = fuente(30, bold=False)
    y0 = y_sep + 18
    y_pie = H - 40 - fpie.size
    row_h = (y_pie - y0 - 10) / mitad
    col_w = (W - 100 - 30) / 2

    for c, grupo in enumerate(cols_pisos):
        x = 50 + c * (col_w + 30)
        for i, piso in enumerate(grupo):
            fila(d, int(x), int(y0 + i * row_h), int(col_w), int(row_h), piso, i)

    centrado(d, datos["pie"], fpie, W / 2, y_pie, PIE)
    return img


def canto():
    """Textura de 16x16 para los cantos del mural (las caras que no son el frente)."""
    img = Image.new("RGBA", (16, 16), (12, 22, 38, 255))
    d = ImageDraw.Draw(img)
    d.rectangle([0, 0, 15, 15], outline=(44, 36, 20, 255))
    d.line([(0, 0), (15, 0)], fill=MARCO_INT + (255,))
    return img


def main():
    ap = argparse.ArgumentParser()
    ap.add_argument("--preview", action="store_true", help="guarda tambien la lamina completa")
    args = ap.parse_args()

    with open(DATOS, encoding="utf-8") as fh:
        datos = json.load(fh)

    img = dibujar(datos)
    g = datos["grid"]
    tile, cols, filas = g["tile"], g["cols"], g["filas"]

    os.makedirs(OUT, exist_ok=True)
    for r in range(filas):
        for c in range(cols):
            trozo = img.crop((c * tile, r * tile, (c + 1) * tile, (r + 1) * tile))
            trozo.save(os.path.join(OUT, "%sr%dc%d.png" % (PREFIX, r + 1, c + 1)))
    canto().save(os.path.join(OUT, "%scanto.png" % PREFIX))
    print("Listo: %d mosaicos de %dx%d + canto en %s" % (filas * cols, tile, tile, OUT))

    if args.preview:
        ruta = os.path.join(os.path.dirname(os.path.abspath(__file__)), "cartel_preview.png")
        img.save(ruta)
        print("Lamina completa: %s" % ruta)


if __name__ == "__main__":
    main()
