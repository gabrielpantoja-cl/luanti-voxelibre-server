# wetlands_gabo_skin

Skin personal "Enderman" del admin `gabo` en GAELSIN. Se aplica automaticamente al
entrar al mundo; **no aparece en el menu `/skin` del resto de jugadores**.

## Como funciona

| Pieza | Donde vive | En git? |
|---|---|---|
| Logica del mod | `server/mods/wetlands_gabo_skin/init.lua` | Si |
| Textura (referencia) | `server/skins/enderman.png` | Si |
| Textura (en el VPS) | `server/worlds/gaelsin/_world_folder_media/textures/enderman.png` | **No** (la carpeta `worlds/` esta gitignoreada) |
| Activacion | `load_mod_wetlands_gabo_skin = true` en `server/config/luanti-gaelsin.conf` | Si |

La textura es 64x32 RGBA (formato player skin de VoxeLibre). `_world_folder_media`
la sirve al cliente en el handshake, por eso el skin aparece sin que el cliente
tenga que descargar nada extra.

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
[wetlands_gabo_skin] Loaded successfully - skin personal para gabo (world: gaelsin)
```

Al entrar como `gabo`:

```
[wetlands_gabo_skin] Skin 'enderman.png' aplicado a gabo
```

## Cambiar el skin

Para usar otra textura:

1. Edita `SKIN_TEXTURE` en `init.lua` (incluye `.png`).
2. Reemplaza `server/skins/enderman.png` con la nueva imagen (64x32 RGBA).
3. Reemplaza la copia en `_world_folder_media/textures/` en el VPS.
4. Reinicia el container de GAELSIN.

## Limitaciones

- `mcl_skins` necesita la textura registrada en `texture_to_simple_skin` para
  resolver `slim_arms` al renderizar. Por eso el mod SI la registra, pero la
  quita del array `simple_skins` (que es el que recorre el menu `/skin`). El
  trade-off: la textura vive en la memoria del servidor; si el jugador NoSoB
  ve el ID en un debug formspec, lo vera. En juego nadie lo nota.
- El skin se reaplica en cada join, pero si `gabo` lo cambia manualmente en
  `/skin`, el siguiente join lo vuelve a poner en Enderman.
