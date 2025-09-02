# 🌱 Sistema de Backups - Vegan Wetlands

## Guía Completa de Backup y Recuperación

Esta documentación proporciona información exhaustiva sobre el sistema de backups automatizado, procedimientos de verificación, troubleshooting y recuperación ante desastres.

---

## 📋 Resumen Ejecutivo

**Estado Actual**: ✅ **COMPLETAMENTE FUNCIONAL**
- **Frecuencia**: Cada 6 horas automáticamente
- **Retención**: 10 backups más recientes
- **Ubicación**: `server/backups/`
- **Método**: Compresión tar.gz del directorio worlds
- **Tamaño Típico**: ~43MB por backup
- **Implementación**: Contenedor Alpine con loop de sleep

---

## 🛠️ Arquitectura del Sistema

### Componentes

1. **Contenedor Principal**: `vegan-wetlands-server` (Luanti)
2. **Contenedor Backup**: `vegan-wetlands-backup` (Alpine Linux)
3. **Script de Backup**: `/scripts/backup.sh`
4. **Almacenamiento**: Volume persistente `./server/backups`

### Configuración Docker

```yaml
# Contenedor de backup actual (método funcional)
backup-cron:
  image: alpine:latest
  container_name: vegan-wetlands-backup
  restart: unless-stopped
  volumes:
    - ./server/worlds:/worlds:ro
    - ./server/backups:/backups
    - ./scripts:/scripts:ro
  environment:
    - TZ=America/Santiago
  command: >
    sh -c "
      apk add --no-cache tar gzip &&
      while true; do 
        sleep 21600; 
        sh /scripts/backup.sh; 
      done
    "
```

---

## 🔍 Procedimientos de Verificación

### 1. Verificación Rápida (Estado General)

```bash
# Conectar al VPS
ssh gabriel@167.172.251.27

# Navegar al proyecto
cd /home/gabriel/Vegan-Wetlands

# Verificar backups existentes
ls -lh server/backups/

# Verificar contenedores funcionando
docker ps | grep vegan-wetlands
```

**Resultado Esperado**:
- Al menos un backup con menos de 6 horas de antigüedad
- Ambos contenedores (`vegan-wetlands-server` y `vegan-wetlands-backup`) en estado "Up"

### 2. Verificación Detallada (Salud del Sistema)

```bash
# Verificar logs del contenedor backup
docker logs vegan-wetlands-backup --tail 50

# Verificar logs del servidor Luanti
docker logs vegan-wetlands-server --tail 50

# Verificar conectividad del servidor
ss -tulpn | grep :30000

# Verificar salud del contenedor
docker inspect vegan-wetlands-server | grep -A5 '"Health"'
```

### 3. Test Manual de Backup

```bash
# Ejecutar backup manual para verificar funcionamiento
docker exec -t vegan-wetlands-backup sh /scripts/backup.sh

# Verificar que se creó el nuevo backup
ls -lht server/backups/ | head -3

# Verificar integridad del backup
tar -tzf server/backups/vegan_wetlands_backup_YYYYMMDD-HHMMSS.tar.gz | head -10
```

---

## 🚨 Historial de Problemas y Soluciones

### Problema #1: Backups Automáticos Fallando (Sept 2025)

**Síntomas Detectados:**
- Directorio `server/backups/` completamente vacío
- Logs mostrando `exit status 127` en cron
- Contenedor backup reiniciándose constantemente

**Diagnóstico:**
```bash
# Los logs mostraban:
"exit status 127 from user root /scripts/backup.sh"
"setpgid: Operation not permitted"
```

**Causa Raíz:**
1. **Error de intérprete**: Cron ejecutaba `/scripts/backup.sh` directamente sin especificar `sh`
2. **Permisos de cron**: dcron en Alpine requiere permisos especiales para setpgid
3. **Configuración obsoleta**: Referencias a mods eliminados en docker-compose.yml

**Solución Implementada:**
1. **Método alternativo**: Reemplazamos cron con sleep loop simple
2. **Script corregido**: Ejecutar con `sh /scripts/backup.sh` explícitamente
3. **Limpieza**: Eliminamos referencias a mods inexistentes
4. **Implementación manual**: Usamos `docker run` directo por problemas de metadata

**Comando de Solución Final:**
```bash
docker run -d --name vegan-wetlands-backup \
  --restart unless-stopped \
  --network vegan-wetlands_luanti-network \
  -v ./server/worlds:/worlds:ro \
  -v ./server/backups:/backups \
  -v ./scripts:/scripts:ro \
  -e TZ=America/Santiago \
  alpine:latest \
  sh -c 'apk add --no-cache tar gzip && while true; do sleep 21600; sh /scripts/backup.sh; done'
```

**Estado Post-Solución:**
- ✅ Backup manual funcionando (43MB generados exitosamente)
- ✅ Contenedor estable sin reinicios
- ✅ Servidor Luanti no interrumpido durante la reparación
- ✅ Próximo backup automático en <6 horas

---

## 📊 Monitoreo y Alertas

### Indicadores Clave de Salud

1. **Frecuencia de Backups**: Máximo 6 horas entre backups
2. **Tamaño de Backup**: Rango normal 40-50MB
3. **Estado de Contenedores**: Ambos "Up" sin reinicios frecuentes
4. **Espacio en Disco**: >500MB libres en `/backups`
5. **Retención**: Máximo 10 archivos en directorio backups

### Script de Monitoreo Automático

```bash
#!/bin/bash
# Script: monitor-backups.sh
# Uso: Ejecutar desde el directorio del proyecto

echo "🌱 === MONITOR DE BACKUPS - VEGAN WETLANDS ==="
echo "Fecha: $(date)"

# Verificar último backup
LAST_BACKUP=$(ls -t server/backups/vegan_wetlands_backup_*.tar.gz 2>/dev/null | head -1)
if [ -z "$LAST_BACKUP" ]; then
    echo "❌ ERROR: No se encontraron backups"
    exit 1
fi

# Calcular antigüedad del último backup
BACKUP_AGE=$(find "$LAST_BACKUP" -mmin +360 2>/dev/null)
if [ -n "$BACKUP_AGE" ]; then
    echo "⚠️  ADVERTENCIA: Último backup tiene más de 6 horas"
    ls -lh "$LAST_BACKUP"
else
    echo "✅ Último backup reciente:"
    ls -lh "$LAST_BACKUP"
fi

# Verificar contenedores
echo ""
echo "📊 Estado de contenedores:"
docker ps --filter name=vegan-wetlands --format "table {{.Names}}\t{{.Status}}\t{{.Ports}}"

# Contar backups
BACKUP_COUNT=$(ls server/backups/vegan_wetlands_backup_*.tar.gz 2>/dev/null | wc -l)
echo ""
echo "📦 Backups totales: $BACKUP_COUNT/10"

echo ""
echo "🌱 === FIN DEL REPORTE ==="
```

---

## 🔧 Procedimientos de Recuperación

### Recuperación Completa del Mundo

**Precondiciones:**
- Acceso SSH al VPS
- Backup válido disponible
- Servidor detenido

**Procedimiento:**

```bash
# 1. Detener servicios
cd /home/gabriel/Vegan-Wetlands
docker stop vegan-wetlands-server vegan-wetlands-backup

# 2. Backup del estado actual (por seguridad)
mv server/worlds server/worlds_CORRUPTED_$(date +%Y%m%d_%H%M%S)

# 3. Crear directorio limpio
mkdir -p server/worlds

# 4. Restaurar desde backup
BACKUP_FILE=$(ls -t server/backups/vegan_wetlands_backup_*.tar.gz | head -1)
tar -xzf "$BACKUP_FILE" -C server/worlds/

# 5. Verificar restauración
ls -la server/worlds/

# 6. Reiniciar servicios
docker start vegan-wetlands-server
sleep 10
docker start vegan-wetlands-backup

# 7. Verificar funcionamiento
docker ps | grep vegan-wetlands
ss -tulpn | grep :30000
```

### Recuperación Parcial (Archivos Específicos)

```bash
# Extraer backup temporal para inspección
mkdir /tmp/backup_extract
tar -xzf server/backups/BACKUP_DESEADO.tar.gz -C /tmp/backup_extract/

# Copiar archivos específicos
cp /tmp/backup_extract/world/specific_file server/worlds/world/

# Limpiar temporal
rm -rf /tmp/backup_extract
```

---

## 🧪 Testing y Validación

### Test de Integridad de Backup

```bash
#!/bin/bash
# Script de test de integridad

BACKUP_FILE="$1"
if [ -z "$BACKUP_FILE" ]; then
    echo "Uso: $0 <archivo_backup.tar.gz>"
    exit 1
fi

echo "🔍 Testing backup: $BACKUP_FILE"

# Test 1: Integridad del archivo
if tar -tzf "$BACKUP_FILE" >/dev/null 2>&1; then
    echo "✅ Integridad del archivo tar.gz: OK"
else
    echo "❌ ERROR: Archivo corrupto o inválido"
    exit 1
fi

# Test 2: Contenido esperado
if tar -tzf "$BACKUP_FILE" | grep -q "world/world.mt"; then
    echo "✅ Contenido del mundo: OK"
else
    echo "❌ ERROR: No se encontró world.mt"
    exit 1
fi

# Test 3: Tamaño razonable
SIZE=$(stat -c%s "$BACKUP_FILE")
if [ $SIZE -gt 10000000 ]; then  # >10MB
    echo "✅ Tamaño del archivo: ${SIZE} bytes (razonable)"
else
    echo "⚠️  ADVERTENCIA: Archivo muy pequeño (${SIZE} bytes)"
fi

echo "✅ Test de integridad completado"
```

### Test de Restauración (Simulacro)

```bash
#!/bin/bash
# Script de simulacro de restauración

echo "🎭 SIMULACRO DE RESTAURACIÓN"
echo "Este script simula una restauración SIN modificar el servidor real"

# Crear ambiente de test temporal
TEST_DIR="/tmp/vegan_wetlands_restore_test"
rm -rf "$TEST_DIR"
mkdir -p "$TEST_DIR"

# Copiar backup más reciente
LATEST_BACKUP=$(ls -t server/backups/vegan_wetlands_backup_*.tar.gz | head -1)
echo "📦 Usando backup: $(basename $LATEST_BACKUP)"

# Extraer en ambiente de test
tar -xzf "$LATEST_BACKUP" -C "$TEST_DIR/"

# Verificar contenido crítico
echo "🔍 Verificando contenido restaurado:"
echo "- world.mt: $([ -f "$TEST_DIR/world/world.mt" ] && echo "✅" || echo "❌")"
echo "- auth.sqlite: $([ -f "$TEST_DIR/world/auth.sqlite" ] && echo "✅" || echo "❌")"
echo "- map.sqlite: $([ -f "$TEST_DIR/world/map.sqlite" ] && echo "✅" || echo "❌")"

# Verificar tamaño de archivos críticos
echo "📊 Tamaños de archivos:"
du -h "$TEST_DIR/world/"*.sqlite 2>/dev/null || echo "No se encontraron archivos .sqlite"

# Limpiar
rm -rf "$TEST_DIR"
echo "✅ Simulacro completado exitosamente"
```

---

## 📱 Automatización y Webhooks

### Notificaciones (Opcional)

El script de backup soporta webhooks para notificaciones:

```bash
# En el contenedor backup, definir variable de ambiente
export WEBHOOK_URL="https://tu-webhook-url.com/endpoint"

# El script enviará automáticamente:
# - Notificación de backup exitoso
# - Notificación de error (si falla)
```

### Integración con n8n

Para integrar con el sistema n8n existente en el VPS:

1. Crear webhook en n8n que reciba notificaciones de backup
2. Configurar alertas por Discord/email si backup falla
3. Dashboard de monitoreo visual del estado de backups

---

## 🎯 Checklist de Verificación Diaria

**Para Administradores: Revisión Diaria Recomendada**

```bash
# Ejecutar desde /home/gabriel/Vegan-Wetlands en el VPS

# ✅ 1. Verificar último backup (debe ser <6h)
ls -lht server/backups/ | head -2

# ✅ 2. Verificar contenedores activos
docker ps | grep vegan-wetlands

# ✅ 3. Verificar servidor accesible
nc -u -z -w3 localhost 30000 && echo "✅ Puerto 30000 OK" || echo "❌ Puerto 30000 FAIL"

# ✅ 4. Verificar espacio en disco
df -h . | tail -1

# ✅ 5. Verificar logs recientes (sin errores)
docker logs vegan-wetlands-backup --tail 10 --since="1h"
```

**Frecuencia**: Diaria (recomendado)
**Tiempo estimado**: 2-3 minutos
**Acción si falla**: Consultar sección de troubleshooting

---

## 🆘 Contacto de Emergencia

**En caso de problemas críticos:**

1. **Problema de backup**: El mundo está SIEMPRE seguro mientras el servidor funcione
2. **Backup manual**: Usar `docker exec -t vegan-wetlands-backup sh /scripts/backup.sh`
3. **Servidor caído**: Usar `docker start vegan-wetlands-server`
4. **Documentación**: Revisar `CLAUDE.md` y `docs/2-guia-de-administracion.md`

**⚠️ NUNCA hacer:**
- Eliminar directorio `server/worlds` sin backup
- Detener servidor durante horario de juego sin aviso
- Modificar archivos .sqlite directamente sin detener servidor
- Ejecutar comandos destructivos sin verificar backups primero

---

**📅 Última Actualización**: Septiembre 2, 2025  
**✍️ Autor**: Sistema de Documentación Automática  
**🔄 Versión**: 1.0 - Post-Recuperación de Sistema de Backups