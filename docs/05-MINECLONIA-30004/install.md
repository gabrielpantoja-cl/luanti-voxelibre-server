# Instalacion de Mineclonia en el VPS

Mineclonia es un game de Luanti **separado** de VoxeLibre. No viene
en el image `linuxserver/luanti` — hay que clonarlo a
`server/games/mineclonia/` antes de arrancar el container.

## Fuente

- **Codeberg**: https://codeberg.org/mineclonia/mineclonia (repo oficial)
- **ContentDB**: https://content.luanti.org/packages/ryvnf/mineclonia/
- Version objetivo: 0.123.0 (latest estable al 2026-07-18)

## Metodo 1 — Desde Codeberg (recomendado)

Ventaja: repo oficial, version mas fresca, se actualiza con
`git pull` sin descargar todo de nuevo.

```bash
ssh <VPS_USER>@<VPS_IP>
cd /home/<VPS_USER>/luanti-voxelibre-server/server/games

# Clonar el repo. Mineclonia tiene .gitattributes y .luacheckrc,
# asique lo dejamos como copia carboneada (no lo necesitamos en
# git del repo padre, solo los archivos del game).
git clone --depth 1 https://codeberg.org/mineclonia/mineclonia.git mineclonia

# Quitar el .git/ — si lo dejamos, git del repo padre lo trata
# como gitlink/submodulo. Pitfall documentado en AGENTS.local.md.
find mineclonia/.git -delete

# Verificar
ls mineclonia/ | head -20
cat mineclonia/game.conf
```

## Metodo 2 — Desde ContentDB (zip)

Si no podes clonar via HTTPS (ej. Codeberg bloqueado), bajar el zip
desde ContentDB:

```bash
cd /home/<VPS_USER>/luanti-voxelibre-server/server/games
wget -O mineclonia.zip 'https://content.luanti.org/packages/ryvnf/mineclonia/releases/0.123.0/download/'
unzip mineclonia.zip -d mineclonia
rm mineclonia.zip
```

## Verificar que funciona

```bash
# Deberia listar game.conf, mods/, etc.
ls -la /home/<VPS_USER>/luanti-voxelibre-server/server/games/mineclonia/

# Confirmar la version
cat /home/<VPS_USER>/luanti-voxelibre-server/server/games/mineclonia/game.conf
```

Salida esperada de `game.conf`:

```
title = Mineclonia
name = mineclonia
description = Survival sandbox game inspired by Minecraft.
...
```

## Commitear al repo

Mineclonia NO es un git submodule (le borramos el `.git/`). Por eso
**se commitea al repo padre** como carpeta regular. Esto infla el
repo ~50 MB pero es la misma estrategia que usa `server/games/mineclone2/`.

```bash
cd /home/<VPS_USER>/luanti-voxelibre-server
git add server/games/mineclonia/
git status  # confirmar que NO aparece como submodule
git commit -m "feat: add Mineclonia 0.123.0 game base for world 30004"
git push origin main
```

Si `git status` muestra `mineclonia` como "modified submodule" o
similar, es porque no borraste el `.git/`. Repetir:

```bash
find server/games/mineclonia/.git -delete
git rm --cached server/games/mineclonia   # si estaba como submodule
git add server/games/mineclonia/
```

## Arrancar el container

```bash
cd /home/<VPS_USER>/luanti-voxelibre-server
docker compose up -d luanti-mineclonia
docker logs --since='1m' luanti-mineclonia-server 2>&1 | grep -iE 'error|warning|game'
```

Deberia loggear algo como:

```
... ACTION[Server]: world.mt created for world "mineclonia"
... INFO[Server]: Server: game "Mineclonia" active
... INFO[Server]: Server: World seed "mineclonia" loaded
```

## Troubleshooting

### "Failed to load game 'mineclonia'"

- `ls server/games/mineclonia/` debe mostrar `game.conf`, `mods/`, etc.
- Si esta vacio, repetir el clone.
- `cat server/games/mineclonia/game.conf` debe tener `name = mineclonia`.

### "Mod not found for modname='default'"

- Mineclonia es standalone — no necesita mods de `server/mods/`.
- Verificar que `luanti-mineclonia.conf` no tenga `load_mod_*` apuntando
  a mods que NO estan en `server/games/mineclonia/mods/`.

### "Server list duplicate "Mineclonia" en servers.luanti.org"

- El container escucha en 30000 internamente — podria anunciarse
  duplicado junto con Wetlands. Por eso `server_announce = false`
  en luanti-mineclonia.conf. Si queres activarlo, ver AGENTS.md
  → "server_list_duplicate_bug" docs.

### Permisos / chown

- Despues de la primera ejecucion, el container crea archivos
  owned por `opc` (UID 1000) en `server/worlds/mineclonia/`.
- Si intentas `git pull` despues y choca con permisos, aplicar
  el chown preventivo habitual:

```bash
sudo chown -R <VPS_USER>:<VPS_USER> server/worlds/mineclonia
```

**NUNCA** chownear `server/games/` — eso lo dejamos con el UID del
container y no deberia ser necesario.

## Actualizar Mineclonia en el futuro

```bash
cd /home/<VPS_USER>/luanti-voxelibre-server/server/games

# Snapshot por si algo se rompe
cp -r mineclonia mineclonia.bak-$(date +%Y%m%d)

# Re-clonar la ultima version (mas facil que git pull sin .git)
rm -rf mineclonia
git clone --depth 1 https://codeberg.org/mineclonia/mineclonia.git mineclonia
find mineclonia/.git -delete

# Reiniciar container
docker compose restart luanti-mineclonia
```

> **Cuidado**: actualizar Mineclonia puede romper compatibilidad
> con mapas existentes. Si el mundo 30004 ya tiene progreso,
> testear primero en una copia local.
