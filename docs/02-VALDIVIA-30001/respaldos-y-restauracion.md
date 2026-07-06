# Respaldos y restauración — Valdivia

Cómo se respalda el mundo de Valdivia (puerto 30001), **cuánto tiempo hacia atrás
se puede restaurar**, y el procedimiento de restauración **verificado end-to-end**
el 2026-07-05 (bajado de R2, integridad `ok`, levantado en local y confirmado en
juego).

Para el detalle del sistema completo ver
[`../00-SHARED/operations/BACKUP_STATUS.md`](../00-SHARED/operations/BACKUP_STATUS.md).

## ¿Cuántos días hacia atrás puedo restaurar? (IMPORTANTE)

| Capa | Retención | Cadencia | Dónde |
|------|-----------|----------|-------|
| Local (VPS) | **~4 días** (8 tarballs) | cada 12h | `server/backups/` |
| Offsite (Cloudflare R2) | **~6 días** (6 snapshots) | 1 por día, 08:00 UTC | `r2-backup:vps-backups-oracle/luanti/` |

**Ventana efectiva de recuperación: ~6 días.**

### El escenario del grief (la pregunta clave)

> "Si alguien entra, rompe todo, y no me doy cuenta hasta una semana después,
> ¿estoy a tiempo de restaurar?"

**Con la configuración actual: NO — 7 días es tarde.** Ejemplo:

- El daño ocurre el **día 0**.
- Los respaldos son diarios y se guardan solo 6 días. El día 7, R2 tiene los
  snapshots de los días 1–7 → **todos posteriores al daño**.
- El último respaldo *limpio* (día 0, antes del daño) se borró al cumplir 6 días.
- Resultado: solo podrías restaurar a un estado **ya dañado**.

**Tienes ~6 días para notar el problema y restaurar** a un estado previo al daño.
Pasada esa ventana, el estado limpio se pierde.

### Recomendación

Extender la retención para tolerar descubrir el grief más tarde. Tras la limpieza
de basura (2026-07-05) cada tarball pesa ~830 MB (antes ~1.7 GB), así que hay
espacio para más historia dentro del plan gratuito de R2 (10 GB). Opciones:

- **Simple**: subir `RETENTION_DAYS` en `~/vps-do/scripts/backup-luanti-offsite.sh`
  de 6 a ~10–12 días (≈ 10 GB con objetos de 830 MB).
- **Mejor (escalonada)**: diarios 14 días + un semanal por 8 semanas + un mensual
  por 6 meses. Da meses de cobertura con poco espacio. (Pendiente P5 en
  `BACKUP_STATUS.md`.)

> Mientras no se extienda, la regla operativa es: **revisar el mundo al menos una
> vez cada ~5 días** para estar dentro de la ventana de restauración.

## Procedimiento de restauración (verificado 2026-07-05)

### 1. Listar y elegir un respaldo de R2
```bash
ssh gabriel@<VPS_IP> "rclone lsl r2-backup:vps-backups-oracle/luanti/ \
  --config ~/.config/rclone/rclone.conf"
```
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
