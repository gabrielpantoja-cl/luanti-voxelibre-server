# Versión de Luanti en el VPS: upgrade y rollback

La imagen `linuxserver/luanti` está **fijada por tag** en los 5 servicios `luanti-*` de
`docker-compose.yml`. No se usa `:latest`: así un `docker compose pull` no cambia la
versión sin que nadie lo decida, y volver atrás es cambiar una línea.

| Fecha | De | A | Notas |
|---|---|---|---|
| 2026-11-15 | `latest` = `5.16.1-ls38` (build 2026-05-10) | `5.18.0-ls52` (2026-11-09) | Un crash en `wetlands_contact` (ver abajo); los 5 mundos OK |

## Upgrade 2026-11-15 (5.16.1 → 5.18.0)

Hecho en este orden:

1. **Comparar el script de arranque de la imagen nueva** con el override
   `server/container-overrides/svc-luanti/run` (Valdivia lo monta para no abrir el
   puerto 30000 además del suyo):
   ```bash
   docker pull linuxserver/luanti:<tag>
   docker run --rm --entrypoint cat linuxserver/luanti:<tag> /etc/s6-overlay/s6-rc.d/svc-luanti/run
   ```
   En `5.18.0-ls52` era idéntico al de 5.16.1, así que el override siguió sirviendo.
2. **Etiquetar la imagen vieja** para poder volver sin depender de Docker Hub:
   `docker tag linuxserver/luanti:latest linuxserver/luanti:5.16.1-ls38-local`.
3. **Backup fresco**: `docker exec luanti-voxelibre-backup bash /scripts/backup.sh`
   → `server/backups/luanti_worlds_backup_20261115-191418.tar.gz` (Wetlands, Valdivia,
   GAELSIN, Mineclonia; Plano no entra en el backup automático).
4. Cambiar el tag en `docker-compose.yml`, push, pull en el VPS.
5. Actualizar **un mundo primero** y revisar logs con un jugador adentro; después el resto.

### Trampa: `up -d <servicio>` arrastra a Wetlands
Todos los `luanti-*` tienen `depends_on: luanti-server`, así que
`docker compose up -d luanti-mineclonia` **también recrea Wetlands** con la imagen nueva.
Para tocar un solo mundo: `docker compose up -d --no-deps <servicio>`.

### Lo que se rompió: vectores incompletos ahora tumban el servidor
En 5.16 un vector al que le falta una coordenada era un `WARNING` (`Invalid vector
coordinate y (value is nil)`). **En 5.18 es un error Lua** y, dentro de un callback,
`ServerError: AsyncErr` → **el servidor se cae**. `wetlands_contact` pasaba
`size = {x = 1.5}` a `hud_add` 5 s después de cada ingreso: Mineclonia se cayó 5 veces
seguidas al entrar un jugador hasta que se corrigió a `{x = 1.5, y = 0}`.

Regla: **todo vector que llegue a una API del motor** (`hud_add`, `set_velocity`,
`add_particlespawner`, `set_properties`, ...) lleva `x` e `y` (y `z` si es 3D). Las tablas
`{x = .., z = ..}` usadas solo para cálculos en Lua no importan. Auditoría usada:
```bash
grep -rnoE "\{\s*[xyz]\s*=[^{}]*\}" server/mods --include=*.lua \
  | grep -vE "x\s*=.*y\s*=|y\s*=.*x\s*="
```

### Avisos que aparecen y no son problema
- Valdivia: muchos `get_biome_list: failed to get biome '...'` (mapgen `singlenode`, sin biomas).
- `Node 'light_source' value exceeds maximum` (3dforniture), `Decoration registered after
  mapgen core initialization` (mcl_structures), aliases duplicados de `mcl_decor`/`mcl_ocean`.
- Plano: aviso de backend `files` deprecado para mod storage.

## Rollback

1. En `docker-compose.yml`, volver los 5 `image:` a la versión anterior
   (`linuxserver/luanti:5.16.1-ls38`; en el VPS también existe la copia local
   `linuxserver/luanti:5.16.1-ls38-local`). Commit + push + pull en el VPS.
2. `docker compose up -d luanti-server luanti-valdivia luanti-gaelsin luanti-plano luanti-mineclonia`
3. Revisar logs con `--since`. **Ojo:** los mapblocks que 5.18 haya escrito podrían no
   leerse en una versión anterior (no verificado). Si aparecen errores de
   deserialización o bloques vacíos, parar el mundo afectado y restaurar su carpeta desde
   el backup del paso 3 (se pierde lo jugado desde entonces).
4. El fix de `wetlands_contact` es compatible con 5.16; no hay que revertirlo.
