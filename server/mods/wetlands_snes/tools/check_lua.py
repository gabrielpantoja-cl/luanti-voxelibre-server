"""Chequeo de sintaxis de todos los .lua del mod.

No hay Lua instalado en la maquina de desarrollo, asi que usamos lupa
(LuaJIT/Lua embebido via pip) solo para compilar cada archivo. Compilar no
ejecuta nada: detecta errores de sintaxis, que es el 90% de los deploys
fallidos de este mod.

    pip install lupa
    python tools/check_lua.py
"""

import pathlib
import sys

from lupa import LuaRuntime

ROOT = pathlib.Path(__file__).resolve().parent.parent


def main() -> int:
    lua = LuaRuntime(unpack_returned_tuples=True)
    files = sorted(ROOT.rglob("*.lua"))
    if not files:
        print("no se encontraron .lua")
        return 1

    bad = 0
    for path in files:
        rel = path.relative_to(ROOT).as_posix()
        src = path.read_text(encoding="utf-8")
        try:
            lua.compile(src)
        except Exception as exc:  # noqa: BLE001 - queremos el mensaje crudo
            bad += 1
            print(f"FAIL  {rel}\n      {exc}")
        else:
            print(f"ok    {rel}  ({len(src.splitlines())} lineas)")

    print(f"\n{len(files) - bad}/{len(files)} archivos compilan")
    return 1 if bad else 0


if __name__ == "__main__":
    sys.exit(main())
