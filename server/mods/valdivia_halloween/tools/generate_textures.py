#!/usr/bin/env python3
"""
Texturas del evento de Halloween de Valdivia. Pixel art reproducible: editar
aca y re-ejecutar, nunca dibujar a mano.

Salidas en textures/:

  valdivia_halloween_sangre1.png   16x16 RGBA  mancha chica (goteo)
  valdivia_halloween_sangre2.png   16x16 RGBA  mancha mediana (salpicadura)
  valdivia_halloween_sangre3.png   16x16 RGBA  mancha grande (charco)
  valdivia_halloween_luna.png      64x64 RGBA  luna de sangre (disco rojo)
  valdivia_halloween_particula.png  8x8  RGBA  gota para los particlespawner

Las manchas son calcomanias: fondo TRANSPARENTE y borde irregular, porque se
dibujan con drawtype "signlike" pegadas a la pared, el piso o el techo. Si el
fondo fuera opaco se verian como un cuadrado rojo flotando.

La semilla esta fija (SEMILLA) para que dos corridas den el mismo PNG y el
diff de git sea vacio cuando no se cambio nada.

Uso:
    python tools/generate_textures.py
    python tools/generate_textures.py --preview salida.png
"""

import argparse
import math
import os
import random

from PIL import Image

MOD = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
OUT = os.path.join(MOD, "textures")
SEMILLA = 31102026

# Paleta: rojo oscuro de comic, no gore fotorrealista. Este es un servidor para
# ninos de 7+; la sangre es decorado de Halloween, estilo pelicula de dibujos.
ROJO_OSCURO = (104, 10, 14)
ROJO = (152, 17, 20)
ROJO_CLARO = (190, 34, 34)
BRILLO = (224, 86, 76)


def _blob(px, cx, cy, radio, color, alpha, rnd, tam):
    """Mancha redondeada con borde comido al azar."""
    r2 = radio * radio
    for y in range(tam):
        for x in range(tam):
            d2 = (x - cx) ** 2 + (y - cy) ** 2
            if d2 > r2:
                continue
            # El borde se desgrana: cerca del limite la probabilidad de pintar baja.
            borde = math.sqrt(d2) / radio
            if borde > 0.74 and rnd.random() < (borde - 0.74) / 0.26:
                continue
            a = alpha if borde < 0.86 else int(alpha * 0.82)
            px[x, y] = color + (a,)


def mancha(tam, nucleos, gotas, rnd):
    img = Image.new("RGBA", (tam, tam), (0, 0, 0, 0))
    px = img.load()

    for cx, cy, radio in nucleos:
        _blob(px, cx, cy, radio, ROJO, 255, rnd, tam)
        # Centro mas oscuro: le da volumen sin salir del estilo plano.
        _blob(px, cx, cy, radio * 0.55, ROJO_OSCURO, 255, rnd, tam)

    # Salpicaduras sueltas alrededor.
    for _ in range(gotas):
        x = rnd.randrange(tam)
        y = rnd.randrange(tam)
        if px[x, y][3] == 0:
            px[x, y] = ROJO_CLARO + (rnd.choice((160, 200, 235)),)

    # Dos o tres pixeles de brillo para que no quede chato.
    pintados = [(x, y) for y in range(tam) for x in range(tam) if px[x, y][3] > 200]
    rnd.shuffle(pintados)
    for x, y in pintados[:3]:
        px[x, y] = BRILLO + (255,)

    return img


def luna(tam=64):
    """Disco rojo con mares mas oscuros. Transparente fuera del disco: el
    motor la dibuja como billboard cuadrado y la esquina se veria."""
    rnd = random.Random(SEMILLA + 7)
    img = Image.new("RGBA", (tam, tam), (0, 0, 0, 0))
    px = img.load()
    c = (tam - 1) / 2.0
    radio = tam * 0.46

    for y in range(tam):
        for x in range(tam):
            d = math.hypot(x - c, y - c)
            if d > radio:
                continue
            # Degradado: mas clara al centro-arriba, mas oscura al borde.
            t = d / radio
            mezcla = 1.0 - t * t
            base = (
                int(118 + 108 * mezcla),
                int(16 + 36 * mezcla),
                int(16 + 30 * mezcla),
            )
            a = 255 if t < 0.94 else int(255 * (1.0 - (t - 0.94) / 0.06))
            px[x, y] = base + (max(a, 0),)

    # Mares (crateres): manchones mas oscuros, siempre los mismos.
    for mx, my, mr in ((0.36, 0.34, 0.14), (0.62, 0.30, 0.09),
                       (0.44, 0.63, 0.17), (0.70, 0.60, 0.10),
                       (0.28, 0.55, 0.07)):
        ccx, ccy, cr = mx * tam, my * tam, mr * tam
        for y in range(tam):
            for x in range(tam):
                if px[x, y][3] == 0:
                    continue
                d = math.hypot(x - ccx, y - ccy)
                if d < cr * (0.8 + 0.4 * rnd.random()):
                    r, g, b, a = px[x, y]
                    px[x, y] = (int(r * 0.72), int(g * 0.66), int(b * 0.66), a)

    return img


def particula(tam=8):
    """Gota para los particlespawner (mordida, infeccion, charco al caer)."""
    img = Image.new("RGBA", (tam, tam), (0, 0, 0, 0))
    px = img.load()
    c = (tam - 1) / 2.0
    for y in range(tam):
        for x in range(tam):
            d = math.hypot(x - c, y - c)
            if d <= tam * 0.38:
                px[x, y] = ROJO + (255,)
            elif d <= tam * 0.48:
                px[x, y] = ROJO_OSCURO + (190,)
    return img


def main():
    ap = argparse.ArgumentParser()
    ap.add_argument("--preview", help="PNG con todas las texturas ampliadas")
    args = ap.parse_args()

    os.makedirs(OUT, exist_ok=True)
    rnd = random.Random(SEMILLA)

    salidas = {
        # Chica: un goteo de dos nucleos pegados.
        "valdivia_halloween_sangre1.png": mancha(16, [(6, 6, 4.0), (10, 10, 3.0)], 6, rnd),
        # Mediana: salpicadura de tres nucleos.
        "valdivia_halloween_sangre2.png": mancha(16, [(8, 7, 5.4), (4, 11, 3.4), (12, 4, 2.8)], 9, rnd),
        # Grande: charco que casi llena el nodo.
        "valdivia_halloween_sangre3.png": mancha(16, [(8, 8, 7.4), (4, 4, 4.0), (12, 11, 4.4)], 12, rnd),
        "valdivia_halloween_luna.png": luna(),
        "valdivia_halloween_particula.png": particula(),
    }

    for nombre, img in salidas.items():
        ruta = os.path.join(OUT, nombre)
        img.save(ruta)
        print("escrito %s (%dx%d)" % (nombre, img.width, img.height))

    if args.preview:
        escala = 8
        anchos = [min(i.width, 64) * escala for i in salidas.values()]
        hoja = Image.new("RGBA", (sum(anchos) + 10 * len(anchos), 64 * escala),
                         (24, 24, 28, 255))
        x = 5
        for img in salidas.values():
            grande = img.resize((img.width * escala, img.height * escala), Image.NEAREST)
            if grande.width > 64 * escala:
                grande = img.resize((64 * escala, 64 * escala), Image.NEAREST)
            hoja.alpha_composite(grande, (x, 0))
            x += grande.width + 10
        hoja.save(args.preview)
        print("preview: %s" % args.preview)


if __name__ == "__main__":
    main()
