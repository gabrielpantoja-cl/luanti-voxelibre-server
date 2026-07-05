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

SRC = os.path.join(REPO, "server", "skins", "2024_06_19_indie-boy-22622590.png")
DST = os.path.join(MOD, "textures", "valdivia_guia_skin.png")


def main():
    img = Image.open(SRC).convert("RGBA")
    if img.size != (64, 64):
        raise SystemExit(f"Se esperaba 64x64, llego {img.size}")
    cropped = img.crop((0, 0, 64, 32))
    os.makedirs(os.path.dirname(DST), exist_ok=True)
    cropped.save(DST)
    print(f"OK: {DST} ({cropped.size[0]}x{cropped.size[1]})")


if __name__ == "__main__":
    main()
