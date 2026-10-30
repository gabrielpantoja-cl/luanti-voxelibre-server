#!/usr/bin/env python3
"""Regenera los 64x32 de los NPC de Valdivia desde server/skins/skins.json.

skins.json es la fuente unica de la verdad: dice de donde salio cada skin
(sitio + slug), cual es su original 64x64 en server/skins/raw/, y a que
textura de que mod va. Este script la ejecuta.

Antes habia un convertidor por mod, cada uno distinto, y tres de ellos usaban
el recorte con perdida: los 11 bailarines de la discoteca y los 4 guias
perdieron su capa de overlay (chaqueta, manga, pantalon) sin que nadie lo
notara. Con una sola ruta de conversion eso no puede volver a pasar.

Uso:
    python scripts/rebuild-skins.py              # regenera lo que cambio
    python scripts/rebuild-skins.py --check      # solo informa, no escribe
    python scripts/rebuild-skins.py --force      # reescribe todo
"""
import argparse
import json
import os
import sys

from PIL import Image

HERE = os.path.dirname(os.path.abspath(__file__))
REPO = os.path.dirname(HERE)

# (region de overlay en el 64x64, esquina destino en la salida 64x32)
OVERLAYS = [
    ((0,  32, 16, 48), (0,  16)),   # pantalon derecho -> pierna derecha
    ((16, 32, 40, 48), (16, 16)),   # chaqueta         -> torso
    ((40, 32, 56, 48), (40, 16)),   # manga derecha    -> brazo derecho
]


def convertir(src):
    """64x64 (dos capas) -> 64x32 con el overlay horneado. 64x32 pasa igual."""
    if src.size == (64, 32):
        return src.copy(), 0
    if src.size != (64, 64):
        raise ValueError(f"se esperaba 64x64 o 64x32, no {src.size}")
    out = src.crop((0, 0, 64, 32))
    horneado = 0
    for box, dest in OVERLAYS:
        capa = src.crop(box)
        if any(px[3] > 0 for px in capa.getdata()):
            out.alpha_composite(capa, dest)
            horneado += 1
    return out, horneado


def main():
    ap = argparse.ArgumentParser()
    ap.add_argument("--check", action="store_true", help="no escribe, solo informa")
    ap.add_argument("--force", action="store_true", help="reescribe aunque no cambie")
    args = ap.parse_args()

    manifiesto = json.load(open(os.path.join(REPO, "server", "skins", "skins.json"),
                                encoding="utf-8"))
    raw_dir = os.path.join(REPO, *manifiesto["raw_dir"].split("/"))

    hechos = cambiados = salteados = 0
    errores = []

    for clave, info in manifiesto["skins"].items():
        destino = os.path.join(REPO, *info["destino"].split("/"))

        if not info.get("original"):
            print(f"  SALTEADO {clave}: sin original 64x64 "
                  f"({info.get('nota', 'sin nota')})")
            salteados += 1
            continue

        origen = os.path.join(raw_dir, info["original"])
        if not os.path.exists(origen):
            errores.append(f"{clave}: falta el original {info['original']}")
            continue

        try:
            nuevo, horneado = convertir(Image.open(origen).convert("RGBA"))
        except ValueError as exc:
            errores.append(f"{clave}: {exc}")
            continue

        bytes_nuevos = nuevo.tobytes()
        igual = (not args.force and os.path.exists(destino)
                 and Image.open(destino).convert("RGBA").tobytes() == bytes_nuevos)
        if igual:
            hechos += 1
            continue

        marca = "=" if not os.path.exists(destino) else "~"
        print(f"  {marca} {info['destino']}  ({horneado}/3 overlay)")
        if not args.check:
            os.makedirs(os.path.dirname(destino), exist_ok=True)
            nuevo.save(destino)
        hechos += 1
        cambiados += 1

    print(f"\n{hechos} skins, {cambiados} {'desactualizados' if args.check else 'reescritos'}"
          f", {salteados} salteados")
    for e in errores:
        print(f"ERROR {e}", file=sys.stderr)
    return 1 if errores else 0


if __name__ == "__main__":
    sys.exit(main())
