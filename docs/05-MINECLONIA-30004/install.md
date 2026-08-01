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

## ⚠️ Pitfall: world.mt faltante en Luanti 5.16+

Cuando se crea un mundo nuevo en Luanti 5.16+ (image
`linuxserver/luanti` 5.16.1+), el contenedor espera que el directorio
del mundo ya tenga un `world.mt` con `gameid` y `world_name`. Si el
dir está vacío, Luanti arranca pero crea el mundo en `worlds/world/`
(un path NO bind-mounted a host) y los datos se pierden en cada reinicio.

**Solución**: crear el `world.mt` en el host antes del primer start:

```bash
ssh <VPS_USER>@<VPS_IP>
# El bind-mount expone server/worlds/mineclonia → /config/.minetest/worlds/mineclonia
mkdir -p /home/<VPS_USER>/luanti-voxelibre-server/server/worlds/mineclonia
sudo chown -R <VPS_USER>:<VPS_USER> \
    /home/<VPS_USER>/luanti-voxelibre-server/server/worlds/mineclonia

cat > /home/<VPS_USER>/luanti-voxelibre-server/server/worlds/mineclonia/world.mt <<'EOF'
gameid = mineclonia
world_name = mineclonia
EOF

# Recién ahora arrancar el container
cd /home/<VPS_USER>/luanti-voxelibre-server
docker compose up -d luanti-mineclonia
```

Luegodel primer arranque exitoso, Luanti completa el world.mt con
backend (sqlite3, etc.) y demás. **No hace falta volver a tocarlo**.

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

## Regenerar el mundo (rotar la seed o cambiar mapgen)

Si querés regenerar el mundo desde cero (después de un cambio de seed,
de mapgen, o simplemente para empezar limpio), el procedimiento es:

```bash
ssh <VPS_USER>@<VPS_IP>
cd /home/<VPS_USER>/luanti-voxelibre-server

# 1. Detener el container
docker compose stop luanti-mineclonia

# 2. Borrar TODO el contenido del directorio de mundo (mantener dir)
sudo rm -rf server/worlds/mineclonia/*

# 3. Restaurar permisos para que gabriel pueda escribir el world.mt
sudo chown -R gabriel:gabriel server/worlds/mineclonia

# 4. Re-crear el world.mt con el gameid correcto
cat > server/worlds/mineclonia/world.mt <<'EOF'
gameid = mineclonia
world_name = mineclonia
EOF

# 5. Levantar el container (regenera el mundo con la seed actual)
docker compose up -d luanti-mineclonia

# 6. Verificar
docker logs --since='1m' luanti-mineclonia-server 2>&1 \
  | grep -iE 'action|error|server for'
```

### ¿Por qué `mg_name = singlenode`?

El mod `mcl_levelgen` (que da el terreno Minecraft-fiel) está
**registrado bajo el mapgen `singlenode`** — NO bajo `mcl_levelgen`
ni `v7`. Si se omite `mg_name`, Luanti 5.16 hace fallback a `v7`
(el mapgen genérico de Minetest), que **no** es Minecraft-fiel.

Ver `mods/MAPGEN/mcl_levelgen/README.txt` en el game base para el
detalle:
> This mod is enabled by selecting the mapgen "singlenode".

Pitfall encontrado el 2026-08-01:
> `mg_name = mcl_levelgen` da error `EmergeManager: mapgen 'mcl_levelgen'
> not valid; falling back to v7`. El nombre correcto es `singlenode`.
