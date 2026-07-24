# wetlands_gabo_skin

Disfraz completo del admin `gabo` en GAELSIN: skin de **Enderman** + **nametag
invisible**. Asi los demas jugadores no pueden identificarlo ni por la textura ni
por la etiqueta de nombre. Se aplica automaticamente al entrar y al respawnear.

## Como funciona

| Pieza | Donde vive | En git? |
|---|---|---|
| Logica del mod (skin + nametag) | `server/mods/wetlands_gabo_skin/init.lua` | Si |
| Textura (referencia) | `server/skins/enderman.png` | Si |
| Textura (en el VPS) | `server/worlds/gaelsin/_world_folder_media/textures/enderman.png` | **No** (la carpeta `worlds/` esta gitignoreada) |
| Activacion | `load_mod_wetlands_gabo_skin = true` en `server/config/luanti-gaelsin.conf` | Si |

**Skin (mcl_skins):** la textura es 64x32 RGBA (formato player skin de VoxeLibre).
`_world_folder_media` la sirve al cliente en el handshake, por eso el skin aparece
sin que el cliente tenga que descargar nada extra. Se registra en el lookup
`texture_to_simple_skin` (necesario para que `update_player_skin` resuelva
`slim_arms`) y se quita del array `simple_skins` (el que recorre el menu `/skin`).

**Nametag (`set_nametag_attributes`):** se llama con `text=""` y `color.a=0`,
lo que deja la etiqueta invisible para todos. Luanti no soporta nametag
per-viewer, asi que **gabo tampoco ve su propio nombre** sobre la cabeza
(solo lo reconoce por el skin). Se reaplica en cada `on_joinplayer` y
`on_respawnplayer` por si el engine lo resetea.

## Deployment en VPS

```bash
# 1. Push desde la maquina local
git push origin main

# 2. Pull + restart en el VPS
ssh <VPS_USER>@<VPS_IP> "cd /home/<VPS_USER>/luanti-voxelibre-server && \
  sudo git pull origin main && \
  sudo chown -R 1000:1000 server/mods/wetlands_gabo_skin && \
  docker compose restart luanti-gaelsin-server"

# 3. Copiar la textura al world folder media (solo la primera vez, este path
#    no esta en git porque server/worlds/ esta gitignoreado).
ssh <VPS_USER>@<VPS_IP> "sudo cp server/skins/enderman.png \
  server/worlds/gaelsin/_world_folder_media/textures/enderman.png && \
  sudo chown 1000:1000 \
  server/worlds/gaelsin/_world_folder_media/textures/enderman.png"

# 4. Verificar en logs
ssh <VPS_USER>@<VPS_IP> "docker logs --since='1m' luanti-gaelsin-server 2>&1 | \
  grep -i 'wetlands_gabo_skin'"
```

Deberias ver dos lineas:

```
[wetlands_gabo_skin] Skin 'enderman.png' registrado (oculto del menu /skin)
[wetlands_gabo_skin] Loaded successfully - disfraz completo (skin + nametag) para gabo (world: gaelsin)
```

Al entrar como `gabo`:

```
[wetlands_gabo_skin] Nametag de gabo ocultado al entrar
[wetlands_gabo_skin] Skin 'enderman.png' aplicado a gabo
```

Al respawnear `gabo`:

```
[wetlands_gabo_skin] Nametag de gabo re-ocultado tras respawn
```

## Cambiar el skin

Para usar otra textura:

1. Edita `SKIN_TEXTURE` en `init.lua` (incluye `.png`).
2. Reemplaza `server/skins/enderman.png` con la nueva imagen (64x32 RGBA).
3. Reemplaza la copia en `_world_folder_media/textures/` en el VPS.
4. Reinicia el container de GAELSIN.

## Desactivar el nametag-hide (si gabo quiere ser identificable)

Comenta el bloque `register_on_joinplayer` y `register_on_respawnplayer` que
llama a `hide_gabo_nametag(p)` en `init.lua`. El skin sigue funcionando, solo
se restaura la etiqueta "gabo" sobre la cabeza.

## Limitaciones

- `mcl_skins` necesita la textura registrada en `texture_to_simple_skin` para
  resolver `slim_arms` al renderizar. Por eso el mod SI la registra, pero la
  quita del array `simple_skins` (que es el que recorre el menu `/skin`). El
  trade-off: la textura vive en la memoria del servidor; si el jugador NoSoB
  ve el ID en un debug formspec, lo vera. En juego nadie lo nota.
- El skin se reaplica en cada join, pero si `gabo` lo cambia manualmente en
  `/skin`, el siguiente join lo vuelve a poner en Enderman.
- El nametag-hide aplica a **todos** los espectadores (Luanti no soporta
  nametag per-viewer). `gabo` tampoco ve su propio nombre sobre la cabeza.
- Si `gabo` usa `/nick` para cambiar su nombre visible, eso pisa nuestro
  `set_nametag_attributes`. Pero como `gabo` es admin, es poco probable.
- El nametag se reaplica en `on_respawnplayer` con 0.1s de delay. Si en ese
  intervalo un jugador mira justo el momento del respawn, puede llegar a ver
  "gabo" por un instante. Aceptable.
