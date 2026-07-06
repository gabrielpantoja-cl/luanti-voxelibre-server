# Respaldos y restauración — Valdivia

Cómo se respalda el mundo de Valdivia (puerto 30001), **cuánto tiempo hacia atrás
se puede restaurar**, y el procedimiento de restauración **verificado end-to-end**
el 2026-07-05 (bajado de R2, integridad `ok`, levantado en local y confirmado en
juego).

Para el detalle del sistema completo ver
[`../00-SHARED/operations/BACKUP_STATUS.md`](../00-SHARED/operations/BACKUP_STATUS.md).

## ¿Cuántos días hacia atrás puedo restaurar? (IMPORTANTE)

Desde 2026-07-06 el offsite usa **retención escalonada (GFS: diario/semanal/mensual)**
en vez de la vieja de 6 días planos.

| Capa | Retención | Cadencia | Dónde |
|------|-----------|----------|-------|
| Local (VPS) | ~4 días (8 tarballs) | cada 12h | `server/backups/` |
| Offsite R2 — **diario** | últimos **5 días** | 1 por día, 08:00 UTC | `.../luanti/daily/` |
| Offsite R2 — **semanal** | últimas **3 semanas** | lunes | `.../luanti/weekly/` |
| Offsite R2 — **mensual** | últimos **2 meses** | día 1 del mes | `.../luanti/monthly/` |

**Ventana efectiva de recuperación: desde días hasta ~2 meses atrás.**
Config en `scripts/backup-luanti-offsite.sh` del repo `infra/vps-oracle`
(`DAILY_KEEP=5`, `WEEKLY_KEEP=3`, `MONTHLY_KEEP=2` — knobs ajustables). Total
~10 objetos × ~830 MB ≈ 8.3 GB → holgado en el tier gratuito de R2 (10 GB).

### El escenario del grief (la pregunta clave) — ✅ ahora cubierto

> "Si alguien entra, rompe todo, y no me doy cuenta hasta una semana después,
> ¿estoy a tiempo de restaurar?"

**Sí.** Con GFS, aunque descubras el daño una semana (o hasta ~2 meses) después,
hay un snapshot **anterior al daño**:
- El daño ocurre el día 0; lo notas el día 7.
- Los **diarios** (últimos 5 días) ya son post-daño, pero el **semanal** tomado
  antes del día 0 sigue disponible por 3 semanas, y el **mensual** por 2 meses.
- Restauras desde ese semanal/mensual limpio. Antes (retención plana de 6 días)
  esto era imposible.

> La granularidad baja al alejarte (día exacto la última semana, semana el último
> mes, mes los últimos dos), pero **siempre hay un punto de retorno limpio** hasta
> ~2 meses atrás. Aun así, mientras antes lo notes, menos construcción legítima
> se pierde.

## Procedimiento de restauración (verificado 2026-07-05)

### 1. Listar y elegir un respaldo de R2
Los objetos viven en tres subprefijos (GFS): `luanti/daily/`, `luanti/weekly/`,
`luanti/monthly/`. Lista todo recursivo y elige el snapshot **anterior al daño**:
```bash
ssh gabriel@<VPS_IP> "rclone lsl r2-backup:vps-backups-oracle/luanti/ --recursive \
  --config ~/.config/rclone/rclone.conf"
```
Para restaurar a un estado reciente usa `daily/`; para volver semanas/meses atrás
usa `weekly/` o `monthly/`. En los comandos siguientes, `<OBJ>` incluye el
subprefijo (p. ej. `daily/luanti_worlds_backup_YYYYMMDD-000001.tar.gz`).

El panel web de Cloudflare **no** deja bajar objetos > 1 GB; usa siempre `rclone`
(API S3, sin ese límite).

### 2. Verificar integridad SIN descargar (streaming)
```bash
ssh gabriel@<VPS_IP> "rclone cat r2-backup:vps-backups-oracle/luanti/<OBJ> \
  --config ~/.config/rclone/rclone.conf | tar -tz | grep valdivia/map.sqlite"
```
Si `tar` termina sin error y muestra `./valdivia/map.sqlite`, el respaldo está
íntegro y completo.

### 3. Restaurar en local para probar (sin tocar producción)
```bash
# a) Bajar solo el mundo valdivia del respaldo al VPS y traerlo
ssh gabriel@<VPS_IP> "cd /tmp && rclone copy \
  r2-backup:vps-backups-oracle/luanti/<OBJ> /tmp/ --config ~/.config/rclone/rclone.conf \
  && mkdir -p vx && tar xzf /tmp/<OBJ> -C vx ./valdivia \
  && tar czf valdivia_restore.tar.gz -C vx valdivia"
scp gabriel@<VPS_IP>:/tmp/valdivia_restore.tar.gz server/backups/

# b) Preservar el mundo local actual y restaurar
docker compose stop luanti-valdivia
mv server/worlds/valdivia server/worlds/valdivia_PRE_RESTORE_$(date +%Y%m%d_%H%M%S)
tar xzf server/backups/valdivia_restore.tar.gz -C server/worlds/

# c) (opcional) validar el sqlite restaurado
sqlite3 server/worlds/valdivia/map.sqlite 'PRAGMA integrity_check; SELECT count(*) FROM blocks;'

# d) Levantar y verificar
docker compose start luanti-valdivia
docker logs --since=30s luanti-valdivia-server 2>&1 | grep -iE "World at|listening"
```
Conéctate con el cliente a `localhost:30001` para confirmarlo en juego. Los
`ERROR[CurlFetch] ... announce` son inofensivos (la instancia local choca con el
anuncio público del VPS).

### 4. Volver a tu mundo local original
```bash
docker compose stop luanti-valdivia
rm -rf server/worlds/valdivia
mv server/worlds/valdivia_PRE_RESTORE_<TS> server/worlds/valdivia
docker compose start luanti-valdivia
```

## Restaurar en PRODUCCIÓN (VPS) — si el mundo real se dañó

Mismo principio, en el VPS y con cuidado de permisos (`server/worlds` es `1000:1000`):

```bash
ssh gabriel@<VPS_IP>
cd /home/gabriel/luanti-voxelibre-server
docker compose stop luanti-valdivia
sudo mv server/worlds/valdivia server/worlds/valdivia_DANADO_$(date +%Y%m%d_%H%M%S)
rclone copy r2-backup:vps-backups-oracle/luanti/<OBJ_LIMPIO> /tmp/ --config ~/.config/rclone/rclone.conf
sudo tar xzf /tmp/<OBJ_LIMPIO> -C server/worlds/ ./valdivia
sudo chown -R 1000:1000 server/worlds/valdivia          # mantener owner del contenedor
docker compose start luanti-valdivia
docker logs --since=30s luanti-valdivia-server 2>&1 | grep -iE "World at|listening|error"
```
Elige `<OBJ_LIMPIO>` = el snapshot **anterior al daño** (por eso importa la ventana
de retención).
