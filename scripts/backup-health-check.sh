#!/bin/bash
# ============================================
# BACKUP HEALTH CHECK - VEGAN WETLANDS 🌱
# ============================================
# Verifica la salud del sistema de backup y alerta problemas

set -e

# Configuración
VPS_HOST="gabriel@167.172.251.27"
VPS_BACKUP_PATH="/home/gabriel/Vegan-Wetlands/server/backups"
EXPECTED_BACKUP_INTERVAL_HOURS=6
MAX_BACKUP_AGE_HOURS=8  # Permitir 2h de retraso
MIN_BACKUPS_REQUIRED=3
EXPECTED_WORLD_MIN_SIZE_MB=100  # Mundo debe ser >100MB

# Colores para output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Funciones de utilidad
log_info() { echo -e "${BLUE}ℹ️  $1${NC}"; }
log_success() { echo -e "${GREEN}✅ $1${NC}"; }
log_warning() { echo -e "${YELLOW}⚠️  $1${NC}"; }
log_error() { echo -e "${RED}❌ $1${NC}"; }

# Contadores de problemas
WARNINGS=0
ERRORS=0

echo "🌱 VEGAN WETLANDS - BACKUP HEALTH CHECK"
echo "======================================="
echo "📅 $(date)"
echo ""

# 1. Verificar conectividad SSH
log_info "Verificando conectividad SSH al VPS..."
if ssh -o ConnectTimeout=10 "$VPS_HOST" "echo 'SSH OK'" >/dev/null 2>&1; then
    log_success "Conectividad SSH: OK"
else
    log_error "No se puede conectar al VPS via SSH"
    ((ERRORS++))
    exit 1
fi

# 2. Verificar contenedor de backup
log_info "Verificando contenedor de backup..."
BACKUP_CONTAINER_STATUS=$(ssh "$VPS_HOST" "cd /home/gabriel/Vegan-Wetlands && docker-compose ps -q backup-cron | wc -l" 2>/dev/null || echo "0")

if [ "$BACKUP_CONTAINER_STATUS" = "1" ]; then
    log_success "Contenedor de backup: Activo"

    # Verificar crontab
    CRON_CONFIG=$(ssh "$VPS_HOST" "docker exec vegan-wetlands-backup crontab -l 2>/dev/null || echo 'NO_CRON'")
    if echo "$CRON_CONFIG" | grep -q "0 \*/6 \* \* \*"; then
        log_success "Configuración cron: OK (cada 6 horas)"
    else
        log_error "Configuración cron incorrecta o ausente"
        log_error "Esperado: '0 */6 * * *', Actual: '$CRON_CONFIG'"
        ((ERRORS++))
    fi
else
    log_error "Contenedor de backup no está activo"
    ((ERRORS++))
fi

# 3. Verificar backups recientes
log_info "Verificando backups recientes..."
LATEST_BACKUP=$(ssh "$VPS_HOST" "ls -t $VPS_BACKUP_PATH/vegan_wetlands_backup_*.tar.gz 2>/dev/null | head -1 | xargs basename" 2>/dev/null || echo "")

if [ -n "$LATEST_BACKUP" ]; then
    log_success "Último backup encontrado: $LATEST_BACKUP"

    # Verificar antigüedad del último backup
    BACKUP_TIMESTAMP=$(echo "$LATEST_BACKUP" | grep -o '[0-9]\{8\}-[0-9]\{6\}')
    BACKUP_DATE=$(echo "$BACKUP_TIMESTAMP" | sed 's/\([0-9]\{4\}\)\([0-9]\{2\}\)\([0-9]\{2\}\)-\([0-9]\{2\}\)\([0-9]\{2\}\)\([0-9]\{2\}\)/\1-\2-\3 \4:\5:\6/')
    BACKUP_EPOCH=$(date -d "$BACKUP_DATE" +%s 2>/dev/null || echo "0")
    CURRENT_EPOCH=$(date +%s)
    AGE_HOURS=$(( (CURRENT_EPOCH - BACKUP_EPOCH) / 3600 ))

    if [ "$BACKUP_EPOCH" -gt 0 ]; then
        if [ "$AGE_HOURS" -le "$MAX_BACKUP_AGE_HOURS" ]; then
            log_success "Antigüedad del backup: ${AGE_HOURS}h (OK - dentro de ${MAX_BACKUP_AGE_HOURS}h)"
        else
            log_warning "Backup antiguo: ${AGE_HOURS}h (esperado <${MAX_BACKUP_AGE_HOURS}h)"
            ((WARNINGS++))
        fi
    else
        log_warning "No se pudo calcular la antigüedad del backup"
        ((WARNINGS++))
    fi

    # Verificar tamaño del backup
    BACKUP_SIZE_MB=$(ssh "$VPS_HOST" "du -m $VPS_BACKUP_PATH/$LATEST_BACKUP 2>/dev/null | cut -f1" || echo "0")
    if [ "$BACKUP_SIZE_MB" -ge "$EXPECTED_WORLD_MIN_SIZE_MB" ]; then
        log_success "Tamaño del backup: ${BACKUP_SIZE_MB}MB (OK - >${EXPECTED_WORLD_MIN_SIZE_MB}MB)"
    else
        log_error "Backup demasiado pequeño: ${BACKUP_SIZE_MB}MB (esperado >${EXPECTED_WORLD_MIN_SIZE_MB}MB)"
        ((ERRORS++))
    fi
else
    log_error "No se encontraron backups"
    ((ERRORS++))
fi

# 4. Contar backups totales
log_info "Verificando cantidad de backups..."
TOTAL_BACKUPS=$(ssh "$VPS_HOST" "ls -1 $VPS_BACKUP_PATH/vegan_wetlands_backup_*.tar.gz 2>/dev/null | wc -l" || echo "0")

if [ "$TOTAL_BACKUPS" -ge "$MIN_BACKUPS_REQUIRED" ]; then
    log_success "Total de backups: $TOTAL_BACKUPS (OK - >=$MIN_BACKUPS_REQUIRED)"
else
    log_warning "Pocos backups disponibles: $TOTAL_BACKUPS (recomendado >=$MIN_BACKUPS_REQUIRED)"
    ((WARNINGS++))
fi

# 5. Verificar integridad del mundo actual
log_info "Verificando mundo actual..."
CURRENT_WORLD_SIZE_MB=$(ssh "$VPS_HOST" "du -m /home/gabriel/Vegan-Wetlands/server/worlds 2>/dev/null | cut -f1" || echo "0")
AUTH_DB_EXISTS=$(ssh "$VPS_HOST" "[ -f /home/gabriel/Vegan-Wetlands/server/worlds/world/auth.sqlite ] && echo 'YES' || echo 'NO'")

if [ "$CURRENT_WORLD_SIZE_MB" -ge "$EXPECTED_WORLD_MIN_SIZE_MB" ]; then
    log_success "Tamaño del mundo actual: ${CURRENT_WORLD_SIZE_MB}MB (OK)"
else
    log_error "Mundo actual demasiado pequeño: ${CURRENT_WORLD_SIZE_MB}MB"
    ((ERRORS++))
fi

if [ "$AUTH_DB_EXISTS" = "YES" ]; then
    log_success "Base de datos de usuarios: Presente"

    # Verificar usuarios en DB
    USER_COUNT=$(ssh "$VPS_HOST" "sqlite3 /home/gabriel/Vegan-Wetlands/server/worlds/world/auth.sqlite 'SELECT COUNT(*) FROM auth;' 2>/dev/null" || echo "0")
    if [ "$USER_COUNT" -gt 0 ]; then
        log_success "Usuarios registrados: $USER_COUNT"
    else
        log_warning "No hay usuarios registrados"
        ((WARNINGS++))
    fi
else
    log_error "Base de datos de usuarios ausente"
    ((ERRORS++))
fi

# 6. Verificar espacio en disco
log_info "Verificando espacio en disco..."
DISK_USAGE=$(ssh "$VPS_HOST" "df -h $VPS_BACKUP_PATH | tail -1 | awk '{print \$5}' | sed 's/%//'" 2>/dev/null || echo "0")

if [ "$DISK_USAGE" -lt 80 ]; then
    log_success "Uso de disco: ${DISK_USAGE}% (OK)"
elif [ "$DISK_USAGE" -lt 90 ]; then
    log_warning "Uso de disco alto: ${DISK_USAGE}%"
    ((WARNINGS++))
else
    log_error "Uso de disco crítico: ${DISK_USAGE}%"
    ((ERRORS++))
fi

# 7. Resumen final
echo ""
echo "======================================="
echo "🏥 RESUMEN DE SALUD DEL SISTEMA"
echo "======================================="

if [ "$ERRORS" -eq 0 ] && [ "$WARNINGS" -eq 0 ]; then
    log_success "Sistema de backup: PERFECTO ✨"
    echo "   🎯 Todos los checks pasaron exitosamente"
elif [ "$ERRORS" -eq 0 ]; then
    log_warning "Sistema de backup: BUENO (con advertencias)"
    echo "   ⚠️  $WARNINGS advertencia(s) encontrada(s)"
else
    log_error "Sistema de backup: REQUIERE ATENCIÓN"
    echo "   ❌ $ERRORS error(es) crítico(s)"
    echo "   ⚠️  $WARNINGS advertencia(s)"
fi

echo ""
echo "📊 Estadísticas:"
echo "   📦 Total backups: $TOTAL_BACKUPS"
echo "   🌍 Tamaño mundo: ${CURRENT_WORLD_SIZE_MB}MB"
echo "   👥 Usuarios: $USER_COUNT"
echo "   💽 Uso disco: ${DISK_USAGE}%"
echo ""
echo "📅 Última verificación: $(date)"

# Exit code basado en severidad
if [ "$ERRORS" -gt 0 ]; then
    exit 2
elif [ "$WARNINGS" -gt 0 ]; then
    exit 1
else
    exit 0
fi