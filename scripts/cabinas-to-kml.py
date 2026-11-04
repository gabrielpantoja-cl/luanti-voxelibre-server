#!/usr/bin/env python3
"""Convierte las Cabinas TP de Valdivia a KML/KMZ para Google Earth.

Lee `valdivia_lugares.json` (el que escribe `valdivia_cabina` en el worldpath del
VPS) y produce un archivo que Google Earth abre directamente, con un pin por
cabina y un circulo de cobertura para ver si quedaron muy juntas o muy separadas.

Calibracion: Arnis genera a escala 1 nodo = 1 metro, asi que basta un punto ancla
mas la conversion metros->grados. El ancla es Plaza de la Republica, el spawn con
el que se genero el mundo (--spawn-lat/--spawn-lng de Arnis v2.9.0). Verificado
contra Plaza Chile con GPS real: error ~27 m.

Uso:
    python scripts/cabinas-to-kml.py valdivia_lugares.json cabinas.kmz
    python scripts/cabinas-to-kml.py valdivia_lugares.json cabinas.kml --radio 250

El formato de salida lo decide la extension (.kml o .kmz).

Camino inverso, para elegir un punto en Google Earth y saber adonde volar en el
juego a poner la cabina (imprime el /teleport listo para pegar):

    python scripts/cabinas-to-kml.py --donde=-39.850453,-73.216045

El `=` es obligatorio ahi: sin el, argparse lee la latitud negativa como opcion.

Ojo en Git Bash: Python de Windows no entiende rutas POSIX. Traducir con
`cygpath -w` antes de pasar una ruta.
"""

import argparse
import json
import math
import sys
import zipfile
from xml.sax.saxutils import escape

# --- Ancla de calibracion -----------------------------------------------------
# Plaza de la Republica: coordenadas con las que se genero el mundo (Arnis v2.9.0,
# --spawn-lat=-39.81422 --spawn-lng=-73.24589) y la posicion de juego resultante.
ANCLA_X, ANCLA_Z = 3766.0, -3249.0
ANCLA_LAT, ANCLA_LNG = -39.81422, -73.24589

M_POR_GRADO_LAT = 111320.0
M_POR_GRADO_LNG = M_POR_GRADO_LAT * math.cos(math.radians(ANCLA_LAT))


def juego_a_latlng(x, z):
    """Coordenadas Luanti -> (lat, lng). +X = este, +Z = norte, 1 nodo = 1 m."""
    return (
        ANCLA_LAT + (z - ANCLA_Z) / M_POR_GRADO_LAT,
        ANCLA_LNG + (x - ANCLA_X) / M_POR_GRADO_LNG,
    )


def latlng_a_juego(lat, lng):
    """Inversa: (lat, lng) -> coordenadas Luanti (x, z)."""
    return (
        ANCLA_X + (lng - ANCLA_LNG) * M_POR_GRADO_LNG,
        ANCLA_Z + (lat - ANCLA_LAT) * M_POR_GRADO_LAT,
    )


def circulo(lat, lng, radio_m, lados=48):
    pts = []
    for i in range(lados + 1):
        t = 2 * math.pi * i / lados
        dlat = radio_m * math.cos(t) / M_POR_GRADO_LAT
        dlng = radio_m * math.sin(t) / M_POR_GRADO_LNG
        pts.append(f"{lng + dlng:.7f},{lat + dlat:.7f},0")
    return " ".join(pts)


def construir_kml(cabinas, radio_m):
    pins, coberturas = [], []
    for c in cabinas:
        n, lat, lng = escape(c["nombre"]), c["lat"], c["lng"]
        vecina = f"{c['vecina']} a {c['dist']:.0f} m" if c["vecina"] else "sin vecinas"
        pins.append(f"""  <Placemark>
    <name>{n}</name>
    <description><![CDATA[Juego: ({c['x']:.0f}, {c['y']:.0f}, {c['z']:.0f})<br/>
Real: {lat:.6f}, {lng:.6f}<br/>
Mas cercana: {escape(vecina)}]]></description>
    <styleUrl>#cabina</styleUrl>
    <Point><coordinates>{lng:.7f},{lat:.7f},0</coordinates></Point>
  </Placemark>""")
        coberturas.append(f"""    <Placemark>
      <name>{n} ({radio_m} m)</name>
      <styleUrl>#cobertura</styleUrl>
      <Polygon><outerBoundaryIs><LinearRing>
        <coordinates>{circulo(lat, lng, radio_m)}</coordinates>
      </LinearRing></outerBoundaryIs></Polygon>
    </Placemark>""")

    nl = "\n"
    return f"""<?xml version="1.0" encoding="UTF-8"?>
<kml xmlns="http://www.opengis.net/kml/2.2">
<Document>
  <name>Cabinas TP - Valdivia</name>
  <description>Red de Cabinas TP del servidor Luanti Valdivia (puerto 30001).
Escala 1 nodo = 1 metro. Ancla: Plaza de la Republica.</description>
  <Style id="cabina">
    <IconStyle>
      <color>ff3333ff</color><scale>1.1</scale>
      <Icon><href>http://maps.google.com/mapfiles/kml/paddle/red-circle.png</href></Icon>
    </IconStyle>
    <LabelStyle><scale>0.85</scale></LabelStyle>
  </Style>
  <Style id="cobertura">
    <LineStyle><color>883333ff</color><width>1.5</width></LineStyle>
    <PolyStyle><color>223333ff</color></PolyStyle>
  </Style>
{nl.join(pins)}
  <Folder>
    <name>Cobertura ({radio_m} m)</name>
    <open>0</open>
{nl.join(coberturas)}
  </Folder>
</Document>
</kml>"""


def main():
    ap = argparse.ArgumentParser(description="Cabinas TP de Valdivia -> KML/KMZ")
    ap.add_argument("entrada", nargs="?", help="valdivia_lugares.json del VPS")
    ap.add_argument("salida", nargs="?", help="archivo .kml o .kmz a escribir")
    ap.add_argument("--radio", type=int, default=400,
                    help="radio del circulo de cobertura en metros (default: 400)")
    ap.add_argument("--donde", metavar="LAT,LNG",
                    help="convierte un punto real a coordenadas de juego y termina")
    args = ap.parse_args()

    if args.donde:
        lat, lng = (float(v) for v in args.donde.replace(" ", "").split(","))
        x, z = latlng_a_juego(lat, lng)
        print(f"{lat:.6f}, {lng:.6f}  ->  x={x:.0f}  z={z:.0f}")
        print(f"/teleport {x:.0f},-10,{z:.0f}   (ajusta la Y al terreno)")
        return

    if not args.entrada or not args.salida:
        ap.error("faltan 'entrada' y 'salida' (o usa --donde LAT,LNG)")

    with open(args.entrada, encoding="utf-8") as f:
        datos = json.load(f)
    if not isinstance(datos, list):
        sys.exit(f"{args.entrada}: se esperaba una lista de lugares, llego {type(datos).__name__}")

    cabinas = []
    for l in datos:
        p = l["pos"]
        lat, lng = juego_a_latlng(p["x"], p["z"])
        cabinas.append({"nombre": l.get("nombre") or l["id"], "x": p["x"], "y": p["y"],
                        "z": p["z"], "lat": lat, "lng": lng})
    cabinas.sort(key=lambda c: c["nombre"].lower())

    for c in cabinas:
        otras = [(math.hypot(c["x"] - o["x"], c["z"] - o["z"]), o["nombre"])
                 for o in cabinas if o is not c]
        c["dist"], c["vecina"] = min(otras) if otras else (0.0, None)

    kml = construir_kml(cabinas, args.radio)
    if args.salida.lower().endswith(".kmz"):
        with zipfile.ZipFile(args.salida, "w", zipfile.ZIP_DEFLATED) as z:
            z.writestr("doc.kml", kml)
    else:
        with open(args.salida, "w", encoding="utf-8") as f:
            f.write(kml)

    print(f"{len(cabinas)} cabinas -> {args.salida}\n")
    print(f"{'Cabina':<28}{'x':>8}{'y':>7}{'z':>8}{'lat':>12}{'lng':>12}  {'vecina mas cerca'}")
    print("-" * 103)
    for c in cabinas:
        v = f"{c['vecina']} ({c['dist']:.0f} m)" if c["vecina"] else "-"
        print(f"{c['nombre']:<28}{c['x']:>8.0f}{c['y']:>7.0f}{c['z']:>8.0f}"
              f"{c['lat']:>12.6f}{c['lng']:>12.6f}  {v}")

    if len(cabinas) > 1:
        ds = sorted(c["dist"] for c in cabinas)
        print(f"\nDistancia al vecino mas cercano: min {ds[0]:.0f} m / "
              f"mediana {ds[len(ds) // 2]:.0f} m / max {ds[-1]:.0f} m")


if __name__ == "__main__":
    main()
