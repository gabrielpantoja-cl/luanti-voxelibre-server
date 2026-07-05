# Estado del Sistema de Backups — Wetlands Server

**Estado: OPERATIVO** — backups locales cada 12h + offsite diario a Cloudflare R2.
Verificado el 2026-07-05.

Este documento describe el sistema **real en producción**. El plan de mejora
original (marzo 2026, que proponía Google Drive) ya se ejecutó; se implementó
sobre **Cloudflare R2** en vez de Drive. La sección histórica está al final.

## Arquitectura actual

```
[VPS Oracle Cloud]
│
├─ Contenedor  luanti-voxelibre-backup   (definido en docker-compose.yml de este repo)
│    Alpine + dcron + sqlite + rsync
│    ├─ Monta ./server/worlds  -> /worlds  (ro)
│    ├─ Monta ./server/backups -> /backups
│    ├─ Cron cada 12h (00:00 y 12:00) -> scripts/backup.sh
│    │     · sqlite3 .backup (snapshot consistente) de map/auth de los 3 mundos
│    │     · rsync del resto excluyendo copias .sqlite.* y artefactos -wal/-shm
│    │     · tar.gz -> server/backups/luanti_worlds_backup_<fecha>.tar.gz  (~1.7 GB)
│    │     · rotación local inline: conserva los últimos 8 (≈4 días)
│    └─ Cron 03:00 -> rotate-backups-container.sh
│
└─ Cron del host (usuario gabriel, 08:00 UTC diario)
     ~/vps-do/scripts/backup-luanti-offsite.sh   (vive en el repo infra/vps-oracle)
       · toma el tar.gz más reciente de server/backups/
       · rclone copy -> r2-backup:vps-backups-oracle/luanti/
       · retención R2: borra objetos > 6 días
       · notifica a Telegram ([OK] / ERROR con tail del log)
       · logs en ~/backups/luanti/  (cron.log + offsite-<fecha>.log)
```

**Mundos incluidos:** `original` (Wetlands), `valdivia` y `gaelsin`, todos en el
mismo tarball. Valdivia entra como `./valdivia/map.sqlite` + `auth.sqlite`.

## Qué se implementó (vs. el plan de marzo)

| Prioridad (marzo) | Estado | Cómo quedó |
|-------------------|--------|-----------|
| P1 · Backup offsite | ✅ HECHO | **Cloudflare R2** (no Google Drive) vía rclone. |
| P2 · SQLite seguro | ✅ HECHO | `sqlite3 .backup` con `.timeout 60000`, fallback a `cp`. |
| P4 · Notificaciones | ✅ HECHO | **Telegram** (no Discord webhook) en el script offsite. |
| P5 · Retención offsite | ✅ HECHO | R2: 6 días (cabe en el plan gratuito de 10 GB). |
| P3 · Verificación integridad | ⏳ PENDIENTE | Falta `tar -tzf` + `PRAGMA integrity_check` post-backup. |
| P5 · Retención mensual | ⏳ PENDIENTE | Solo hay retención diaria (6d local-offsite); sin snapshots mensuales. |

## Coordenadas del offsite (R2)

| Elemento | Valor |
|----------|-------|
| Remoto rclone | `r2-backup:` (también existe `r2:`) |
| Bucket | `vps-backups-oracle` |
| Prefijo | `luanti/` |
| Retención | 6 días (`rclone delete --min-age 6d`) |
| Tamaño por objeto | ~1.7 GB |
| Uso del bucket | ~10.6 GB (≈6 objetos) |
| Credenciales | `~/.backup-credentials` (tokens R2 + Telegram) — **no** en git |
| Config rclone | `~/.config/rclone/rclone.conf` |
| Script | `~/vps-do/scripts/backup-luanti-offsite.sh` (repo `infra/vps-oracle`) |

## Cómo verificar que está funcionando

```bash
# 1. Tarballs locales recientes (deben aparecer cada 12h)
ssh gabriel@<VPS_IP> "ls -lht /home/gabriel/luanti-voxelibre-server/server/backups/*.tar.gz | head"

# 2. Log del offsite diario (busca 'Upload R2 OK' y 'FIN')
ssh gabriel@<VPS_IP> "tail -n 20 /home/gabriel/backups/luanti/cron.log"

# 3. Objetos en R2 (últimos ~6 días)
ssh gabriel@<VPS_IP> "rclone lsl r2-backup:vps-backups-oracle/luanti/ \
  --config /home/gabriel/.config/rclone/rclone.conf"

# 4. Confirmar que el tarball CONTIENE Valdivia (no solo que existe)
ssh gabriel@<VPS_IP> "L=\$(ls -t .../server/backups/*.tar.gz | head -1); \
  tar tzf \"\$L\" | grep -E 'valdivia/(map|auth)\.sqlite'"
```

## Quirks conocidos

- **rclone + R2 `501 NotImplemented` en el intento 1/3, éxito en el 2/3.** Es un
  comportamiento conocido de esta versión de rclone con la API de R2: reintenta
  con otra operación y el upload **sí** se completa. El log se ve alarmante pero
  no es una falla real. (`rclone v1.60.1-DEV` en el VPS.)

## Limpieza 2026-07-05 (causa raíz de tarballs inflados)

El world dir `server/worlds/valdivia/` acumulaba ~2.2 GB de copias manuales
viejas de SQLite (`map.sqlite.backup-before-remap`, `.v4`, `.backup-20260629`,
`.backup-before-cherry-fix`, etc.). Se colaban en **cada** tarball porque el
`rsync` de `backup.sh` sólo excluía `*.sqlite.backup.*` (con punto) y estas eran
`.backup-*` (con guion). Acciones:

1. **Borradas** del world dir (valdivia: 2.7 GB → 526 MB). Los archivos vivos
   `map.sqlite` / `auth.sqlite` quedaron intactos. No se tocó el ownership
   (`opc:opc`), sólo `sudo rm`.
2. **`backup.sh` endurecido**: los excludes ahora usan `*.sqlite.*` y
   `*.sqlite-*`, que cubren cualquier copia/versión futura. Así los próximos
   tarballs suben más limpios a R2.

> Regla operativa: **no dejar copias manuales de `.sqlite` dentro de
> `server/worlds/`**. Si necesitas un snapshot puntual, ponlo en
> `server/backups/` o fuera del repo; el world dir solo debe tener los `.sqlite`
> vivos.

## Pendientes (prioridad baja)

- Verificación de integridad post-backup (`tar -tzf` + `PRAGMA integrity_check`).
- Retención mensual en R2 (guardar el 1º de cada mes por 6 meses).

---

<details>
<summary>Histórico — diagnóstico original (22 marzo 2026)</summary>

En marzo el sistema hacía solo backups locales (sin offsite), con `tar` directo
sobre SQLite en caliente y sin notificaciones. El riesgo crítico era "si el VPS
de Oracle muere, se pierde todo". El plan propuso Google Drive vía rclone como
opción recomendada; en la ejecución se eligió Cloudflare R2 (S3-compatible, plan
gratuito 10 GB, sin los límites de API de Drive) y Telegram para notificar.

</details>

*Última actualización: 2026-07-05 — sistema operativo y verificado.*
