#!/usr/bin/env python3
"""
Convierte el skin fuente indie-boy (64x64, formato skin de Minecraft moderno)
al formato 64x32 que usa el modelo mcl_armor_character.b3d de VoxeLibre.

Se recorta la mitad superior (0,0,64,32) — el mismo proceso documentado en
AGENTS.md para los NPCs Star Wars de wetlands_npcs. Ejecutar una sola vez;
el PNG resultante queda versionado en el repo, no hace falta re-correrlo.

Uso:
    python3 tools/convert_skin.py
"""
import os
from PIL import Image

HERE = os.path.dirname(os.path.abspath(__file__))
MOD = os.path.dirname(HERE)
REPO = os.path.dirname(os.path.dirname(os.path.dirname(MOD)))
SKINS = os.path.join(REPO, "server", "skins")
TEX = os.path.join(MOD, "textures")

# (skin fuente 64x64, textura destino 64x32). El del spawn y el del Parque
# Catrico usan skins DISTINTOS a proposito.
JOBS = [
    ("2024_06_19_indie-boy-22622590.png", "valdivia_guia_skin.png"),        # guia del spawn
    ("2026_06_30_summer-gala-24161243.png", "valdivia_guia_parque_skin.png"),  # guia del Parque Catrico
]


def convert(src_name, dst_name):
    img = Image.open(os.path.join(SKINS, src_name)).convert("RGBA")
    if img.size != (64, 64):
        raise SystemExit(f"{src_name}: se esperaba 64x64, llego {img.size}")
    cropped = img.crop((0, 0, 64, 32))
    dst = os.path.join(TEX, dst_name)
    os.makedirs(TEX, exist_ok=True)
    cropped.save(dst)
    print(f"OK: {dst} ({cropped.size[0]}x{cropped.size[1]}) <- {src_name}")


def main():
    for src_name, dst_name in JOBS:
        convert(src_name, dst_name)


if __name__ == "__main__":
    main()
