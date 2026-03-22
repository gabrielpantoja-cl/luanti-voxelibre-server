# Estado del Sistema de Backups - Wetlands Server

## Diagnostico (22 marzo 2026)

### Arquitectura actual

```
docker-compose.yml
  backup-cron (alpine + dcron)
    ├── Monta: ./server/worlds -> /worlds (read-only)
    ├── Monta: ./server/backups -> /backups
    ├── Monta: ./scripts -> /scripts (read-only)
    ├── Cron 1: cada 12h -> backup.sh (tar.gz de /worlds)
    └── Cron 2: 03:00 diario -> rotate-backups-container.sh
```

### Lo bueno

- Backups automatizados cada 12 horas (00:00 y 12:00)
- Contenedor dedicado, independiente del servidor de juego
- Rotacion automatica: mantiene ultimos 8 backups (4 dias)
- Incluye AMBOS mundos (Wetlands + Valdivia) en un solo tar.gz
- Disco VPS con 159 GB libres (sin presion de espacio)
- Backups consistentes en tamano (~1 GB cada uno, ~1.2 GB con Valdivia)

### Lo malo

| Problema | Riesgo | Severidad |
|----------|--------|-----------|
| **Sin backup offsite** | Si el VPS de Oracle muere, se pierde TODO (mundo, auth, config) | CRITICO |
| **SQLite hot-copy inseguro** | `tar` comprime mientras el servidor escribe en map.sqlite/auth.sqlite -- puede generar backups corruptos | ALTO |
| **Sin verificacion de integridad** | No se valida que el tar.gz sea legible ni que los .sqlite sean consistentes | MEDIO |
| **Sin notificacion de fallos** | Si el backup falla, nadie se entera (WEBHOOK_URL no configurado) | MEDIO |
| **Retencion corta** | Solo 4 dias de historia; un problema no detectado a tiempo se pierde | BAJO |

## Plan de mejora

### Prioridad 1: Backup offsite (CRITICO)

Enviar backups automaticamente a un almacenamiento externo al VPS.

#### Opcion A: Google Drive via rclone (RECOMENDADA)

[rclone](https://rclone.org/) es la herramienta CLI estandar para sincronizar archivos con servicios cloud. Soporta Google Drive, S3, Backblaze, etc. Es mas maduro y mantenido que alternativas como gdrive o oclaw.

**Ventajas:**
- Open source, muy estable, ampliamente usado en servidores Linux
- Soporta Google Drive con autenticacion OAuth2
- Puede encriptar backups antes de subir
- Soporta bandwidth limit para no saturar la red del VPS
- Comando simple: `rclone copy /backups gdrive:wetlands-backups/`

**Setup:**
```bash
# 1. Instalar rclone en el VPS
curl https://rclone.org/install.sh | sudo bash

# 2. Configurar Google Drive (requiere OAuth2, interactivo la primera vez)
rclone config
# -> New remote -> google drive -> seguir instrucciones OAuth

# 3. Probar
rclone ls gdrive:

# 4. Agregar al script de backup
rclone copy /backups/ultimo_backup.tar.gz gdrive:wetlands-backups/ \
  --bwlimit 5M --log-file=/var/log/rclone-backup.log
```

**Autenticacion headless (VPS sin browser):**
- Opcion 1: Configurar rclone en la maquina local (con browser) y copiar el rclone.conf al VPS
- Opcion 2: Usar `rclone authorize` en local y pegar el token en el VPS

#### Opcion B: Backblaze B2 (alternativa economica)

- 10 GB gratis, luego $0.005/GB/mes
- rclone tambien lo soporta nativamente
- Sin limites de API como Google Drive
- Mas predecible para automatizacion

#### Opcion C: rsync a segundo VPS

- Si hubiera un segundo servidor disponible
- No aplica actualmente (solo tenemos Oracle Cloud)

#### Opcion D: GitHub Releases (emergencia)

- Subir backups comprimidos como releases del repo
- Limite: 2 GB por archivo
- No ideal pero funciona como ultimo recurso

**Decision:** Opcion A (Google Drive via rclone) es la mas practica. Gabriel ya tiene Google Drive, no tiene costo adicional, y rclone es la herramienta correcta para el trabajo.

### Prioridad 2: Safe SQLite backup (ALTO)

Reemplazar `tar` directo por `sqlite3 .backup` para copias consistentes:

```bash
# Antes (inseguro):
tar -czf backup.tar.gz -C /worlds .

# Despues (seguro):
# 1. Copiar SQLite de forma segura
sqlite3 /worlds/world/map.sqlite ".backup /tmp/world_map.sqlite"
sqlite3 /worlds/world/auth.sqlite ".backup /tmp/world_auth.sqlite"
sqlite3 /worlds/valdivia/map.sqlite ".backup /tmp/valdivia_map.sqlite"

# 2. Comprimir las copias seguras + resto de archivos
tar -czf backup.tar.gz -C /tmp world_map.sqlite world_auth.sqlite valdivia_map.sqlite
```

**Requisito:** Instalar `sqlite3` en el contenedor de backup (`apk add sqlite`).

### Prioridad 3: Verificacion de integridad (MEDIO)

Despues de crear el backup, verificar:

```bash
# Verificar que el tar.gz es valido
tar -tzf backup.tar.gz > /dev/null 2>&1 || echo "BACKUP CORRUPTO"

# Verificar integridad SQLite (antes de comprimir)
sqlite3 /tmp/world_map.sqlite "PRAGMA integrity_check;" | grep -q "ok"
```

### Prioridad 4: Notificaciones (MEDIO)

Configurar DISCORD_WEBHOOK_URL en el .env del VPS para recibir notificaciones de:
- Backup exitoso (con tamano y duracion)
- Backup fallido (con error)
- Upload offsite exitoso/fallido

### Prioridad 5: Retencion extendida offsite (BAJO)

- Local (VPS): mantener 8 backups (4 dias) -- actual, suficiente
- Offsite (Google Drive): mantener 30 dias, eliminar automaticamente los mas antiguos
- Estructura en Drive:
  ```
  wetlands-backups/
    daily/        # ultimos 30 dias
    monthly/      # primer backup de cada mes, mantener 6 meses
  ```

## Workflow de backup mejorado (futuro)

```
[Cada 12 horas]
  1. sqlite3 .backup de map.sqlite y auth.sqlite (ambos mundos)
  2. PRAGMA integrity_check en las copias
  3. tar.gz de las copias + world.mt + configs
  4. Guardar en /backups/ local (rotacion 8)
  5. rclone copy a Google Drive (con bandwidth limit)
  6. Verificar tar.gz valido
  7. Notificar via Discord webhook (exito/fallo)
```

## Ejecucion

Este plan se ejecutara en fases:
1. Primero: instalar rclone y configurar Google Drive (requiere sesion interactiva)
2. Segundo: modificar backup.sh para usar sqlite3 .backup
3. Tercero: agregar verificacion + notificaciones
4. Cuarto: configurar retencion offsite

---

*Ultima actualizacion: 22 marzo 2026*
*Estado: DIAGNOSTICADO - Plan definido, pendiente ejecucion*
