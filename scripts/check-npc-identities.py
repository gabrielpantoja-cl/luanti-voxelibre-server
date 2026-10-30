#!/usr/bin/env python3
"""Valida que no haya dos NPC humanoides de Valdivia con la misma cara.

Por que existe: los NPC de Valdivia viven en mods distintos (valdivia_transeuntes,
valdivia_spawn_npc, valdivia_discoteca, valdivia_policia) y cada uno elegia sus
skins por su cuenta. El resultado fue que tres de los cuatro guias quedaron con
la cara de un bailarin de la discoteca, byte por byte, sin que nadie lo notara:
cada mod por separado estaba bien, el choque solo existia entre mods.

`server/skins/skins.json` es la fuente unica de la verdad y `rebuild-skins.py`
regenera los 64x32 desde ahi, pero valida solo que el original exista y que mida
lo que debe. Este script agrega la parte que falta: que nadie se repita.

Cinco chequeos, de peor a menos grave:

  1. destino repetido   -> dos entradas escriben el MISMO archivo: una le pisa
                           la textura a la otra y gana la ultima. Es un bug.
  2. imagenes identicas -> dos originales distintos con el mismo contenido byte
                           a byte. Dos personajes con la misma cara.
  3. original repetido  -> dos entradas comparten el mismo PNG de origen. Mismo
                           efecto que (2), pero explicito en el JSON.
  4. slug repetido      -> dos entradas bajadas del mismo skin de internet. Suele
                           ser el origen de (2) y (3).
  5. nombre repetido    -> dos personajes con el mismo nombre, aunque tengan
                           caras distintas. En Valdivia los transeuntes se
                           presentan por su nombre, asi que repetirlo confunde.

Uso:
    python scripts/check-npc-identities.py            # valida
    python scripts/check-npc-identities.py --listar   # ademas lista el censo

Sale con 1 si encuentra algo, para poder encadenarlo en un pre-commit o CI.
"""
import argparse
import collections
import hashlib
import json
import os
import re
import sys

if hasattr(sys.stdout, "reconfigure"):      # consola Windows en cp1252
    sys.stdout.reconfigure(encoding="utf-8", errors="replace")

JSON = os.path.join("server", "skins", "skins.json")


def cargar():
    if not os.path.exists(JSON):
        sys.exit(f"no encuentro {JSON} (corre esto desde la raiz del repo)")
    with open(JSON, encoding="utf-8") as fh:
        d = json.load(fh)
    return d["skins"], d.get("raw_dir", os.path.join("server", "skins", "raw"))


# Caras compartidas a proposito. Que un guia del parque sea tambien el que
# baila en la discoteca no es un bug: es la misma persona en dos momentos del
# dia, y en una ciudad chica eso se ve natural. Lo que el script tiene que
# cazar es el choque que NADIE decidio.
OVERLAPS_OK = {
    frozenset({"discoteca_hipster2", "guia_huachocopihue_skin"}):
        "el guia de Huachocopihue sale a bailar",
    frozenset({"discoteca_indie", "guia_skin"}):
        "el guia del spawn sale a bailar",
    frozenset({"discoteca_summer", "guia_parque_skin"}):
        "el guia del Parque Catrico sale a bailar",
}

# Partes que un humanoide tiene que dibujar si o si. Las coordenadas son del
# 64x32: la cabeza se mide en sus DOS capas (base y sombrero) porque hay skins
# que pintan la cara solo en la de arriba.
PARTES = {
    "cabeza": [(0, 0, 32, 16), (32, 0, 64, 16)],
    "torso":  [(20, 20, 28, 32)],
    "brazo":  [(44, 20, 48, 32)],
    "pierna": [(4, 20, 8, 32)],
}
MIN_OPACO = 20   # % de pixeles visibles bajo el cual la parte se da por ausente


def comprobar_partes(ruta):
    """Devuelve las partes del cuerpo que el skin no dibuja."""
    try:
        from PIL import Image
    except ImportError:
        return []                      # sin Pillow se omite este chequeo
    try:
        im = Image.open(ruta).convert("RGBA")
    except Exception:
        return ["archivo ilegible"]
    faltan = []
    for parte, cajas in PARTES.items():
        visibles = total = 0
        for caja in cajas:
            px = list(im.crop(caja).getdata())
            visibles += sum(1 for q in px if q[3] > 0)
            total += len(px)
        if total and 100 * visibles / total < MIN_OPACO:
            faltan.append(parte)
    return faltan


def agrupar(pares):
    """pares: [(clave, valor)] -> {valor: [claves]} solo con los repetidos."""
    m = collections.defaultdict(list)
    for clave, valor in pares:
        if valor is not None:
            m[valor].append(clave)
    return {v: sorted(ks) for v, ks in m.items() if len(ks) > 1}


def parsear_usa(texto):
    """'valdivia_transeuntes - Agustin (vecino)' -> ('valdivia_transeuntes',
    'Agustin', 'vecino'). El separador del JSON es un punto medio unicode, pero
    se acepta cualquiera para no depender de como se escribio la fila."""
    if not texto:
        return None, None, None
    partes = re.split(r"\s*[·|:-]\s*", texto, maxsplit=1)
    mod = partes[0].strip()
    resto = partes[1].strip() if len(partes) > 1 else ""
    m = re.match(r"^(.*?)\s*\(([^)]*)\)\s*$", resto)
    if m:
        return mod, m.group(1).strip(), m.group(2).strip()
    return mod, resto or None, None


def main():
    ap = argparse.ArgumentParser(description=__doc__,
                                 formatter_class=argparse.RawDescriptionHelpFormatter)
    ap.add_argument("--listar", action="store_true",
                    help="imprime el censo completo de NPC por mod")
    args = ap.parse_args()

    skins, raw_dir = cargar()

    # --- censo: quien es quien, segun el campo `usa` ---
    censo = []
    for clave, info in sorted(skins.items()):
        mod, nombre, rol = parsear_usa(info.get("usa", ""))
        censo.append((clave, mod, nombre, rol))

    problemas = []

    # 1. dos entradas escribiendo el mismo archivo
    for valor, claves in agrupar([(k, v.get("destino")) for k, v in skins.items()]).items():
        problemas.append(("destino repetido (una pisa a la otra)", valor, claves))

    # 2. mismo contenido byte a byte, aunque el archivo se llame distinto
    hashes = []
    faltantes = []
    for clave, info in skins.items():
        ruta = os.path.join(raw_dir, info["original"])
        if not os.path.exists(ruta):
            faltantes.append((clave, info["original"]))
            continue
        with open(ruta, "rb") as fh:
            hashes.append((clave, hashlib.md5(fh.read()).hexdigest()))
    for valor, claves in agrupar(hashes).items():
        problemas.append(("misma cara (imagenes identicas)", valor[:12], claves))

    # 3 y 4. origen compartido declarado en el propio JSON
    for valor, claves in agrupar([(k, v.get("original")) for k, v in skins.items()]).items():
        problemas.append(("mismo PNG de origen", valor, claves))
    for valor, claves in agrupar([(k, v.get("fuente")) for k, v in skins.items()]).items():
        problemas.append(("mismo slug descargado", valor, claves))

    # 5. nombres de persona repetidos entre mods
    nombres = [(c, n.lower()) for c, _m, n, _r in censo if n]
    for valor, claves in agrupar(nombres).items():
        problemas.append(("nombre de persona repetido", valor, claves))

    # 6. skins incompletos: a Gonzalo le faltaba la cabeza entera y se fue a
    #    produccion sin que nadie lo viera hasta encontrarlo caminando sin
    #    cabeza por la ciudad. En mc-skins.net los skins sin cabeza no son raros.
    #
    #    Ojo con el falso positivo: muchos skins dibujan la cara SOLO en la capa
    #    de sombrero (filas 32-64 del 64x32), asi que mirar unicamente la base
    #    marca como rotos a los que estan perfectos. Se suman las dos capas.
    for clave, info in sorted(skins.items()):
        destino = info.get("destino")
        if not destino or not os.path.exists(destino):
            continue
        faltan = comprobar_partes(destino)
        if faltan:
            problemas.append(("skin incompleto (no se dibuja entero)",
                              ", ".join(faltan), [clave]))

    # Un mismo choque dispara varios chequeos a la vez (mismo slug -> mismo PNG
    # -> misma cara). Se agrupa por el conjunto de claves implicadas y se
    # reporta una vez, con el motivo mas grave primero y el resto como detalle.
    orden = {t: i for i, t in enumerate([
        "destino repetido (una pisa a la otra)",
        "misma cara (imagenes identicas)",
        "mismo PNG de origen",
        "mismo slug descargado",
        "nombre de persona repetido",
    ])}
    agrupados = collections.OrderedDict()
    aceptados = []
    for tipo, valor, claves in sorted(problemas, key=lambda p: orden.get(p[0], 99)):
        motivo_ok = OVERLAPS_OK.get(frozenset(claves))
        if motivo_ok is not None:
            if all(motivo_ok != m for _, m in aceptados):
                aceptados.append((claves, motivo_ok))
            continue
        agrupados.setdefault(tuple(claves), []).append((tipo, valor))

    # --- salida ---
    if args.listar:
        por_mod = collections.defaultdict(list)
        for clave, mod, nombre, rol in censo:
            por_mod[mod or "(sin mod declarado)"].append((nombre or clave, rol))
        print(f"Censo de NPC humanoides de Valdivia ({len(censo)} skins)\n")
        for mod in sorted(por_mod):
            filas = sorted(por_mod[mod])
            print(f"  {mod}  ({len(filas)})")
            for nombre, rol in filas:
                print(f"      {nombre}" + (f" - {rol}" if rol else ""))
            print()

    if faltantes:
        print(f"Originales que no estan en {raw_dir}/:")
        for clave, orig in sorted(faltantes):
            print(f"  {clave}: falta {orig}")
        print()

    if aceptados:
        print("Caras compartidas a proposito (no son errores):")
        for claves, motivo in aceptados:
            print(f"  {motivo}: {' = '.join(claves)}")
        print()

    if not agrupados:
        print(f"OK: {len(skins)} skins, ninguna repetida sin querer "
              f"y ninguna incompleta.")
        return 0

    print(f"{len(agrupados)} choque(s) de identidad:\n")
    for claves, motivos in agrupados.items():
        principal, valor = motivos[0]
        print(f"  {principal}: {valor}")
        for c in claves:
            usa = skins[c].get("usa") or "(sin `usa` declarado)"
            print(f"      {c}  ->  {usa}")
        if len(motivos) > 1:
            print("      (ademas: " +
                  "; ".join(f"{t} = {v}" for t, v in motivos[1:]) + ")")
        print()
    print("Arreglo: dale a una de las dos un skin propio (bajalo con")
    print("scripts/fetch-skin.sh), actualiza su fila en server/skins/skins.json")
    print("y corre `python scripts/rebuild-skins.py`.")
    return 1


if __name__ == "__main__":
    sys.exit(main())
