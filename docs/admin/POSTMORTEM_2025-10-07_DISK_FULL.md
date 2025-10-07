# Postmortem: Falla Crítica por Disco Lleno en VPS

**Fecha del Incidente:** 2025-10-07
**Hora del Crash:** ~14:34 UTC
**Duración del Incidente:** ~45 minutos (14:34 - 15:19 UTC)
**Severidad:** Crítica (PostgreSQL en modo recovery, servicios degradados)
**Autor:** Gabriel Pantoja
**Última Actualización:** 2025-10-07 15:19:04 UTC

---

## Estado del Sistema (Post-Recuperación)

### Monitoreo Actual - 2025-10-07 15:19:04 UTC

```bash
# Disco
Filesystem      Size  Used Avail Use% Mounted on
/dev/vda1        58G   42G   16G  74% /

# Sistema
Uptime: 62 días, 9:23 horas
Load Average: 0.12, 0.31, 1.83

# Memoria
Total:        3.8Gi
Usado:        1.4Gi
Disponible:   2.4Gi
Swap Usado:   279Mi / 2.0Gi

# Servicios Docker (8 contenedores activos)
✅ n8n-db           Up 17 minutes (healthy)
✅ degux-web        Up 11 hours (healthy)
✅ n8n              Up 12 hours (healthy)
✅ n8n-redis        Up 14 hours (healthy)
✅ nginx-proxy      Up 5 days
✅ vegan-wetlands-backup   Up 2 weeks
✅ vegan-wetlands-server   Up 41 hours (healthy)
✅ portainer        Up 11 days
```

---

## Resumen Ejecutivo

El VPS de producción (167.172.251.27) alcanzó el 100% de capacidad de disco, causando que PostgreSQL (n8n-db) crasheara con error `could not write init file: No space left on device`. La base de datos entró en modo recovery automático, dejando inaccesibles los servicios de degux.cl y N8N.

**Espacio Liberado Total:** 17.29 GB
**Estado Final:** 74% de uso (42GB/58GB)

---

## Cronología del Incidente

| Hora (UTC) | Evento |
|------------|--------|
| 14:29:42 | Primeros errores PostgreSQL: `FATAL: could not write init file` |
| 14:34:01 | PostgreSQL PANIC: `could not write to file "pg_logical/replorigin_checkpoint.tmp": No space left on device` |
| 14:34:02 | PostgreSQL entra en recovery mode |
| 14:34:02 | Todos los servicios que dependen de BD (degux.cl, N8N) se vuelven inaccesibles |
| 15:00:00 | Usuario reporta errores `PrismaClientInitializationError: Server has closed the connection` |
| 15:05:00 | Inicio del diagnóstico |
| 15:08:00 | Confirmación: disco al 100% (`/dev/vda1: 58G used, 0G available`) |
| 15:10:00 | Limpieza Docker: `docker system prune -af --volumes` → 16.29GB liberados |
| 15:12:00 | Reinicio contenedor `n8n-db` |
| 15:15:00 | PostgreSQL restaurado y funcional |
| 15:19:00 | Limpieza adicional de archivos temporales → 1GB liberado |

---

## Análisis de Causa Raíz

### 1. Consumidores Principales de Espacio

#### 🔴 CRÍTICO: Luanti Server Backups - 22GB

```
/home/gabriel/Vegan-Wetlands/server/backups/  22GB
├── (múltiples backups automáticos del mundo)

/home/gabriel/Vegan-Wetlands/server/worlds/   418MB (mundo actual)
├── worlds_HALLOWEEN_BACKUP_20251003_215440   356MB
├── worlds_BACKUP_20250909_221534             175MB
└── worlds_EMERGENCY_BACKUP_20250909_205401   174MB
```

**Problema:** Los backups automáticos de Luanti no tienen política de retención. Se acumularon 22GB de backups sin rotación automática.

**Mundo Actual:** Solo 418MB (0.7GB con backups manuales incluidos)
**Backups Acumulados:** 22GB (52x el tamaño del mundo actual)

#### 🟡 Docker System - 16.29GB Liberables

**Antes del incidente:**
```
Images:         18.08GB (15.59GB reclaimables - 86%)
Build Cache:    29.84MB (100% reclaimable)
Volumes:        575.3MB (478.9MB reclaimables - 83%)
```

**Imágenes Docker sin uso:**
- postgres:15-alpine (606MB) - imagen antigua
- certbot/certbot (múltiples layers sin uso)
- Múltiples imágenes intermedias de builds

#### 🟡 Archivos Temporales - 1GB

```
/tmp/world                346MB (extracción temporal de backup Luanti)
/tmp/backup_extract       346MB (duplicado)
/tmp/backup_20250920      346MB (backup antiguo)
/tmp/luanti-landing       6.0MB
```

**Problema:** Archivos temporales de restauración de backups de Luanti quedaron sin limpiar.

#### 🟢 Servicios Normales

| Servicio | Espacio | Estado |
|----------|---------|--------|
| **degux.cl** | 1.6GB | Normal (código + node_modules) |
| **Docker degux-web** | 1.94GB | Normal (imagen Next.js) |
| **N8N** | 1.03GB | Normal (imagen base) |
| **N8N Database** | 17MB | Excelente (degux + n8n en mismo container) |
| **PostgreSQL Container** | 603MB | Normal (PostGIS + PostgreSQL 15) |
| **Luanti Landing Page** | 11MB | Normal |
| **Portainer** | 268MB | Normal |

---

## Eliminaciones Realizadas

### Durante Recuperación (docker system prune)

```bash
docker system prune -af --volumes

Eliminado:
- 20+ volúmenes Docker huérfanos (478.9MB)
- 31 imágenes Docker sin uso (15.59GB)
- 72 objetos de build cache (29.84MB)
- Red docker vps-do_default (sin uso)

Total liberado: 16.29GB
```

**Qué se eliminó:**
1. **Imágenes Docker obsoletas:** postgres:15-alpine, certbot layers antiguos
2. **Volúmenes huérfanos:** volúmenes de contenedores eliminados hace meses
3. **Build cache:** cache de builds de Next.js y N8N acumulados
4. **Redes sin uso:** red docker antigua

**Qué NO se eliminó:**
- ✅ Imágenes de servicios activos (degux-web, n8n, n8n-db, nginx-proxy, luanti, portainer)
- ✅ Volúmenes activos (n8n_db_data, n8n_files, nginx_logs, portainer_data)
- ✅ Datos de aplicaciones

### Limpieza Adicional Post-Recuperación

```bash
# Archivos temporales Luanti
rm -rf /tmp/world /tmp/backup_extract /tmp/backup_20250920
Liberado: ~1GB

# Directorio obsoleto vacío
rm -rf /home/gabriel/vps-do/websites/pitutito.cl
Liberado: 4KB (negligible)
```

---

## Configuración de Base de Datos N8N

### Arquitectura Actual

```
PostgreSQL Container: n8n-db (postgis/postgis:15-3.4)
├── Puerto: 5432 (interno Docker)
├── Usuario: n8n
└── Bases de Datos:
    ├── degux       17MB (aplicación degux.cl)
    ├── n8n         13MB (workflows N8N)
    ├── postgres    7.3MB (BD administrativa)
    ├── template0   7.3MB (template)
    └── template1   7.4MB (template)

Total Disk Usage: 603MB (imagen base) + 52MB (datos)
```

**Importante:** La BD de degux.cl y N8N comparten el mismo contenedor PostgreSQL, pero están aisladas en bases de datos separadas. Esto es eficiente en recursos y simplifica backups.

---

## Luanti Server (Vegan-Wetlands)

### Desglose de Espacio

| Componente | Tamaño | Descripción |
|------------|--------|-------------|
| **Backups automáticos** | 22GB | ⚠️ PROBLEMA PRINCIPAL |
| **Mundo actual** | 418MB | Mundo activo del servidor |
| **Backups manuales** | 705MB | 3 backups de seguridad |
| **Mods** | 4.8MB | Mods instalados |
| **Games** | 98MB | Minetest Game base |
| **Landing page** | 11MB | Sitio web del servidor |
| **Repositorio git** | 567MB | .git completo |
| **TOTAL** | 24GB | |

### Servicios Docker Luanti

```
vegan-wetlands-server   51.7MB  (imagen linuxserver/luanti)
vegan-wetlands-backup   9.65MB  (imagen alpine + scripts)
```

**Servidor activo 24/7:** ✅ Sí (Up 41 hours en última revisión)
**Landing page activa:** ✅ Sí (accesible en luanti.gabrielpantoja.cl)

### Problema de Backups

El servidor Luanti tiene un sistema de backup automático que NO implementa rotación. Los backups se acumulan indefinidamente en `/home/gabriel/Vegan-Wetlands/server/backups/` hasta llenar el disco.

**Mundo actual:** 418MB
**Backups acumulados:** 22GB (52 veces el tamaño del mundo)

---

## Impacto del Incidente

### Servicios Afectados

| Servicio | Estado Durante Incidente | Impacto |
|----------|-------------------------|---------|
| **degux.cl** | ❌ Offline | No se podía acceder a la aplicación Next.js (errors PrismaClientInitializationError) |
| **N8N** | ❌ Degradado | Workflows detenidos, UI inaccesible |
| **PostgreSQL** | ❌ Recovery Mode | Base de datos en recovery, conexiones rechazadas |
| **Luanti Server** | ✅ Sin impacto | Servidor de juego continuó funcionando (no depende de PostgreSQL) |
| **Nginx** | ✅ Sin impacto | Proxy reverso funcionando |
| **Portainer** | ✅ Sin impacto | UI de gestión Docker accesible |

### Datos Perdidos

**Ninguno.** La base de datos completó el recovery exitosamente sin pérdida de datos. Todos los logs de PostgreSQL indican recovery limpio:

```
2025-10-07 14:34:02.399 UTC [11466] LOG:  database system was not properly shut down; automatic recovery in progress
2025-10-07 14:34:02.402 UTC [11466] LOG:  redo starts at 0/D661B20
2025-10-07 14:34:02.405 UTC [11466] LOG:  redo done at 0/D69BB80
```

---

## Medidas Preventivas Implementadas

### 1. Documentación

✅ Este documento postmortem
✅ Registro de consumo de espacio por servicio
✅ Procedimientos de limpieza documentados

### Pendiente: Implementar Medidas Preventivas

#### 🔴 URGENTE: Rotación de Backups Luanti

**Acción requerida:** Configurar política de retención en `/home/gabriel/Vegan-Wetlands/server/backups/`

**Recomendación:**
```bash
# Política de retención sugerida:
- Últimos 7 días:     backups diarios (7 x 418MB = ~3GB)
- Últimas 4 semanas:  backups semanales (4 x 418MB = ~1.6GB)
- Últimos 6 meses:    backups mensuales (6 x 418MB = ~2.5GB)

Total estimado: ~7GB (vs 22GB actual)
Ahorro: 15GB
```

**Implementar script:**
```bash
#!/bin/bash
# /home/gabriel/Vegan-Wetlands/scripts/rotate-backups.sh

BACKUP_DIR="/home/gabriel/Vegan-Wetlands/server/backups"

# Eliminar backups mayores a 30 días
find "$BACKUP_DIR" -name "*.tar.gz" -mtime +30 -delete

# Mantener solo últimos 10 backups
ls -t "$BACKUP_DIR"/*.tar.gz | tail -n +11 | xargs -r rm
```

**Configurar cron:**
```cron
# Ejecutar rotación diariamente a las 4 AM
0 4 * * * /home/gabriel/Vegan-Wetlands/scripts/rotate-backups.sh
```

#### 🟡 Monitoreo de Disco

**Acción requerida:** Configurar alertas de espacio en disco

**Herramientas sugeridas:**
1. **Script local con cron:**
```bash
#!/bin/bash
# /home/gabriel/vps-do/scripts/disk-monitor.sh

THRESHOLD=80
USAGE=$(df / | tail -1 | awk '{print $5}' | sed 's/%//')

if [ $USAGE -gt $THRESHOLD ]; then
  # Enviar alerta (email, Discord webhook, etc)
  echo "ALERTA: Disco al $USAGE%" | mail -s "VPS Disk Alert" gabriel@example.com
fi
```

2. **Portainer Alerts** (ya instalado)
3. **Digital Ocean Monitoring** (available en panel)

**Umbrales recomendados:**
- ⚠️ Warning: 80% (46GB/58GB)
- 🔴 Critical: 90% (52GB/58GB)
- 🚨 Emergency: 95% (55GB/58GB)

#### 🟡 Limpieza Automática Docker

**Acción requerida:** Configurar limpieza periódica de Docker

```bash
# Agregar a crontab
# Limpieza semanal de Docker (domingos 3 AM)
0 3 * * 0 docker system prune -f --volumes >> /var/log/docker-prune.log 2>&1
```

Esto eliminará:
- Contenedores detenidos
- Redes sin uso
- Imágenes sin uso
- Build cache

**NO eliminará:**
- Contenedores en ejecución
- Imágenes con contenedores activos
- Volúmenes con contenedores activos

#### 🟡 Limpieza de Archivos Temporales

```bash
# Agregar a crontab
# Limpiar /tmp semanalmente (lunes 2 AM)
0 2 * * 1 find /tmp -type f -mtime +7 -delete

# Limpiar npm cache mensualmente
0 2 1 * * npm cache clean --force
```

---

## Espacio por Servicio (Estado Final)

| Servicio/Directorio | Tamaño | % del Total | Estado |
|---------------------|--------|-------------|--------|
| **Vegan-Wetlands (Luanti)** | 24GB | 57% | ⚠️ Requiere rotación backups |
| **Docker Images** | 2.51GB | 6% | ✅ Normal (limpiado) |
| **degux.cl** | 1.6GB | 4% | ✅ Normal |
| **System (/var)** | 3.8GB | 9% | ✅ Normal |
| **Logs (/var/log)** | 2.8GB | 7% | ✅ Normal |
| **Temp files (/tmp)** | 837MB | 2% | ✅ Limpiado |
| **NPM cache** | 1.3GB | 3% | ✅ Normal |
| **Otros** | 5.1GB | 12% | ✅ Normal |
| **Total Usado** | 42GB | 72% | ✅ Saludable |
| **Disponible** | 16GB | 28% | ✅ Suficiente |

---

## Lecciones Aprendidas

### ✅ Lo que Funcionó Bien

1. **PostgreSQL Recovery Automático:** La BD se recuperó exitosamente sin intervención manual ni pérdida de datos
2. **Aislamiento de Servicios:** Luanti y otros servicios continuaron funcionando durante el incidente
3. **Docker System Prune:** Herramienta efectiva para recuperar espacio rápidamente
4. **Documentación Clara:** Los logs de PostgreSQL proporcionaron información exacta del problema

### ❌ Lo que Falló

1. **Sin Monitoreo Proactivo:** No había alertas configuradas para espacio en disco
2. **Backups Sin Rotación:** Luanti acumuló 22GB de backups sin política de retención
3. **Sin Limpieza Automática:** Docker y archivos temporales se acumularon sin limpieza programada
4. **Sin Visibilidad:** No se detectó el crecimiento gradual del disco hasta llegar al 100%

### 🎯 Acciones Correctivas

| Acción | Prioridad | Estado | Responsable | Fecha Límite |
|--------|-----------|--------|-------------|--------------|
| Implementar rotación backups Luanti | 🔴 Crítica | ⏳ Pendiente | Gabriel | 2025-10-10 |
| Configurar alertas disco (>80%) | 🟡 Alta | ⏳ Pendiente | Gabriel | 2025-10-14 |
| Automatizar limpieza Docker (semanal) | 🟡 Alta | ⏳ Pendiente | Gabriel | 2025-10-14 |
| Documentar runbook recuperación | 🟢 Media | ✅ Completo | Gabriel | 2025-10-07 |
| Configurar limpieza /tmp automática | 🟢 Media | ⏳ Pendiente | Gabriel | 2025-10-21 |
| Revisar capacidad VPS (¿upgrade a 80GB?) | 🟢 Baja | ⏳ Pendiente | Gabriel | 2025-11-01 |

---

## Runbook de Recuperación

### Si el Disco Vuelve a Llenarse (100%)

```bash
# 1. Verificar estado del disco
ssh gabriel@167.172.251.27
df -h /

# 2. Identificar consumidores principales
du -h --max-depth=1 /home/gabriel | sort -hr | head -10

# 3. Limpieza inmediata de Docker (recupera ~15-20GB)
docker system prune -af --volumes

# 4. Verificar espacio liberado
df -h /

# 5. Si PostgreSQL está en recovery, reiniciar contenedor
docker restart n8n-db
sleep 10
docker logs n8n-db | tail -30

# 6. Verificar conectividad BD
docker exec n8n-db pg_isready -U n8n

# 7. Limpieza adicional si es necesario
rm -rf /tmp/world /tmp/backup_extract /tmp/backup_*
find /home/gabriel/Vegan-Wetlands/server/backups -name "*.tar.gz" -mtime +30 -delete

# 8. Regenerar cliente Prisma (si está en desarrollo local)
cd /home/gabriel/Documentos/degux.cl
npx prisma generate
```

### Contactos de Emergencia

- **Administrador VPS:** Gabriel Pantoja
- **VPS Provider:** Digital Ocean
- **IP VPS:** 167.172.251.27
- **Portainer UI:** https://167.172.251.27:9443

---

## Referencias

- **Logs PostgreSQL:** `docker logs n8n-db`
- **Monitoreo Docker:** https://167.172.251.27:9443 (Portainer)
- **Digital Ocean Panel:** https://cloud.digitalocean.com/
- **Repositorio degux.cl:** https://github.com/gabrielpantoja-cl/degux.cl
- **Repositorio Luanti:** https://github.com/gabrielpantoja-cl/Vegan-Wetlands

---

## Apéndice: Logs del Incidente

### PostgreSQL Crash Logs

```
2025-10-07 14:29:42.651 UTC [11449] FATAL:  could not write init file
2025-10-07 14:29:53.649 UTC [11457] FATAL:  could not write init file
2025-10-07 14:30:33.942 UTC [11459] FATAL:  could not write init file
2025-10-07 14:31:33.971 UTC [11461] FATAL:  could not write init file
2025-10-07 14:32:34.002 UTC [11463] FATAL:  could not write init file
2025-10-07 14:33:34.041 UTC [11465] FATAL:  could not write init file
2025-10-07 14:34:01.849 UTC [26] PANIC:  could not write to file "pg_logical/replorigin_checkpoint.tmp": No space left on device
2025-10-07 14:34:02.063 UTC [1] LOG:  checkpointer process (PID 26) was terminated by signal 6: Aborted
2025-10-07 14:34:02.063 UTC [1] LOG:  terminating any other active server processes
2025-10-07 14:34:02.075 UTC [1] LOG:  all server processes terminated; reinitializing
2025-10-07 14:34:02.115 UTC [11466] LOG:  database system was interrupted; last known up at 2025-10-07 13:34:04 UTC
2025-10-07 14:34:02.399 UTC [11466] LOG:  database system was not properly shut down; automatic recovery in progress
2025-10-07 14:34:02.402 UTC [11466] LOG:  redo starts at 0/D661B20
2025-10-07 14:34:02.405 UTC [11466] LOG:  invalid record length at 0/D69BBB8: wanted 24, got 0
2025-10-07 14:34:02.405 UTC [11466] LOG:  redo done at 0/D69BB80
```

### Docker System Prune Output

```
Deleted Networks:
vps-do_default

Deleted Volumes: 20 volumes

Deleted Images: 31 images (including postgres:15-alpine, certbot/certbot, etc.)

Deleted build cache objects: 72 objects

Total reclaimed space: 16.29GB
```

---

**Documento Generado:** 2025-10-07 15:19:04 UTC
**Autor:** Gabriel Pantoja / Claude Code
**Versión:** 1.0
**Estado:** ✅ Incidente Resuelto - Medidas Preventivas Pendientes