#!/usr/bin/env python3
"""
Genera el código QR de la invitación de Discord como textura del mod.

El jugador escanea el QR del formspec con la cámara de su teléfono y abre Discord
directo — la vía "un toque" que reemplaza al enlace cliqueable (Luanti no permite
que el servidor abra el navegador del cliente).

El PNG resultante queda versionado en textures/; sólo hay que re-correr esto si
cambia la invitación (DISCORD_INVITE). Requiere la lib `qrcode` (con PIL).

Uso:
    python3 tools/generate_discord_qr.py
"""
import os
import qrcode

# Debe coincidir con DISCORD_INVITE en init.lua.
DISCORD_INVITE = "https://discord.gg/Y3vfy2JnX"

HERE = os.path.dirname(os.path.abspath(__file__))
MOD = os.path.dirname(HERE)
DST = os.path.join(MOD, "textures", "valdivia_guia_discord_qr.png")


def main():
    qr = qrcode.QRCode(
        version=None,                # auto: usa la versión mínima que quepa
        error_correction=qrcode.constants.ERROR_CORRECT_M,
        box_size=10,                 # px por módulo -> QR nítido
        border=4,                    # zona de silencio estándar (4 módulos)
    )
    qr.add_data(DISCORD_INVITE)
    qr.make(fit=True)
    # Negro sobre blanco: máximo contraste, escaneable sobre fondo oscuro
    img = qr.make_image(fill_color="black", back_color="white").convert("RGB")
    os.makedirs(os.path.dirname(DST), exist_ok=True)
    img.save(DST)
    print(f"OK: {DST} ({img.size[0]}x{img.size[1]}) -> {DISCORD_INVITE}")


if __name__ == "__main__":
    main()
