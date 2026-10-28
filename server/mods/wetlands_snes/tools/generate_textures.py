"""
Genera las texturas 16x16 para el mod wetlands_snes.
Ejecutar desde la raíz del mod:
    python tools/generate_textures.py
"""

import os
from PIL import Image, ImageDraw

OUT = os.path.join(os.path.dirname(__file__), "..", "textures")
os.makedirs(OUT, exist_ok=True)


def save(img: Image.Image, name: str) -> None:
    path = os.path.join(OUT, name)
    img.save(path)
    print(f"  {name}")


def new(w: int = 16, h: int = 16) -> tuple[Image.Image, ImageDraw.ImageDraw]:
    img = Image.new("RGBA", (w, h), (0, 0, 0, 0))
    return img, ImageDraw.Draw(img)


# ─── Paleta SNES ──────────────────────────────────────────────────────────────
GRAY     = (192, 192, 192, 255)
GRAY_MID = (160, 160, 160, 255)
GRAY_DRK = (100, 100, 100, 255)
SLOT_OUT = ( 60,  60,  60, 255)
SLOT_IN  = ( 20,  20,  20, 255)
BTN_Y    = (102,  34, 170, 255)   # amarillo-morado (Y)
BTN_B    = (204, 170,   0, 255)   # amarillo (B)
BTN_A    = (204,  34,   0, 255)   # rojo (A)
BTN_X    = (  0,  86, 204, 255)   # azul (X)
BTN_SS   = (110, 110, 110, 255)   # Start / Select
LED_ON   = (255,  60,  60, 255)
BROWN    = (120,  80,  40, 255)
DIRT     = (100,  65,  30, 255)
MOLE_FUR = (140,  90,  50, 255)
MOLE_EYE = ( 20,  20,  20, 255)
MOLE_NOSE= (220, 140, 140, 255)


# ─── Top (vista superior de la consola) ───────────────────────────────────────
def make_top() -> Image.Image:
    img, d = new()
    d.rectangle([0, 0, 15, 15], fill=GRAY)
    d.rectangle([5,  1, 10, 13], fill=SLOT_OUT)   # borde ranura
    d.rectangle([6,  2,  9, 12], fill=SLOT_IN)    # interior ranura
    d.rectangle([1, 14, 14, 15], fill=GRAY_MID)   # franja borde frontal
    return img


# ─── Bottom ───────────────────────────────────────────────────────────────────
def make_bottom() -> Image.Image:
    img, d = new()
    d.rectangle([0, 0, 15, 15], fill=GRAY_MID)
    return img


# ─── Side ─────────────────────────────────────────────────────────────────────
def make_side() -> Image.Image:
    img, d = new()
    d.rectangle([0, 0, 15, 15], fill=GRAY)
    d.rectangle([0, 0, 0, 15], fill=GRAY_DRK)     # borde izquierdo
    d.rectangle([15, 0, 15, 15], fill=GRAY_DRK)   # borde derecho
    return img


# ─── Back ─────────────────────────────────────────────────────────────────────
def make_back() -> Image.Image:
    img, d = new()
    d.rectangle([0, 0, 15, 15], fill=GRAY)
    # Ranuras de ventilación
    for y in (4, 7, 10):
        d.rectangle([2, y, 13, y], fill=GRAY_DRK)
    return img


# ─── Front (cara con botones) ─────────────────────────────────────────────────
def make_front() -> Image.Image:
    img, d = new()
    d.rectangle([0, 0, 15, 15], fill=GRAY)

    # Botón de encendido (izquierda)
    d.rectangle([1, 5, 4, 7], fill=GRAY_DRK)
    # LED rojo
    d.rectangle([2, 3, 3, 4], fill=LED_ON)

    # Botón Reset (izquierda, más pequeño)
    d.rectangle([1, 9, 3, 10], fill=GRAY_DRK)

    # Botones ABXY (derecha, patrón diamante)
    # X (arriba)
    d.ellipse([ 9,  3, 11,  5], fill=BTN_X)
    # Y (izquierda)
    d.ellipse([ 7,  6,  9,  8], fill=BTN_Y)
    # A (derecha)
    d.ellipse([11,  6, 13,  8], fill=BTN_A)
    # B (abajo)
    d.ellipse([ 9,  9, 11, 11], fill=BTN_B)

    # Start / Select (centro-abajo)
    d.rectangle([5, 11, 7, 12], fill=BTN_SS)   # Select
    d.rectangle([9, 11, 11, 12], fill=BTN_SS)  # Start

    return img


# ─── Controller (inventory image 16×16) ───────────────────────────────────────
def make_controller() -> Image.Image:
    img, d = new()
    BODY = (80, 80, 80, 255)

    # Cuerpo principal
    d.rectangle([1, 4, 14, 11], fill=BODY)
    # Agarres laterales
    d.rectangle([0, 5, 2, 9], fill=BODY)
    d.rectangle([13, 5, 15, 9], fill=BODY)

    # D-pad (cruz, lado izquierdo)
    d.rectangle([2, 6, 6, 8], fill=SLOT_IN)    # horizontal
    d.rectangle([3, 5, 5, 9], fill=SLOT_IN)    # vertical

    # Botones ABXY (diamante, lado derecho)
    d.ellipse([ 9,  4, 11,  6], fill=BTN_X)   # X
    d.ellipse([ 7,  6,  9,  8], fill=BTN_Y)   # Y
    d.ellipse([11,  6, 13,  8], fill=BTN_A)   # A
    d.ellipse([ 9,  8, 11, 10], fill=BTN_B)   # B

    # Start / Select (centro)
    d.rectangle([7, 7, 8, 8], fill=(160, 160, 160, 255))
    d.rectangle([9, 7, 10, 8], fill=(160, 160, 160, 255))

    return img


# ─── Agujero (celda vacía del juego Topo) ────────────────────────────────────
def make_hole() -> Image.Image:
    img, d = new()
    d.rectangle([0, 0, 15, 15], fill=BROWN)
    # Círculo oscuro (hoyo)
    d.ellipse([3, 4, 12, 12], fill=SLOT_IN)
    # Línea de sombra para efecto 3D
    d.arc([4, 5, 11, 9], start=200, end=340, fill=GRAY_DRK, width=1)
    return img


# ─── Topo (celda activa del juego Topo) ──────────────────────────────────────
def make_mole() -> Image.Image:
    img, d = new()
    d.rectangle([0, 0, 15, 15], fill=BROWN)
    # Orejas
    d.ellipse([2, 2,  5,  5], fill=MOLE_FUR)
    d.ellipse([10, 2, 13,  5], fill=MOLE_FUR)
    # Cabeza
    d.ellipse([2, 4, 13, 14], fill=MOLE_FUR)
    # Ojos
    d.ellipse([4, 7,  6,  9], fill=MOLE_EYE)
    d.ellipse([9, 7, 11,  9], fill=MOLE_EYE)
    # Brillos en ojos
    d.rectangle([4, 7, 4, 7], fill=(255, 255, 255, 255))
    d.rectangle([9, 7, 9, 7], fill=(255, 255, 255, 255))
    # Nariz
    d.ellipse([6, 10, 9, 12], fill=MOLE_NOSE)
    return img


if __name__ == "__main__":
    print("Generando texturas wetlands_snes...")
    save(make_top(),        "wetlands_snes_top.png")
    save(make_bottom(),     "wetlands_snes_bottom.png")
    save(make_side(),       "wetlands_snes_side.png")
    save(make_back(),       "wetlands_snes_back.png")
    save(make_front(),      "wetlands_snes_front.png")
    save(make_controller(), "wetlands_snes_controller.png")
    save(make_hole(),       "wetlands_snes_hole.png")
    save(make_mole(),       "wetlands_snes_mole.png")
    print("Listo!")
