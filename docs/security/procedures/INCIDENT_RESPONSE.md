# 🚨 PROCEDIMIENTOS DE RESPUESTA A INCIDENTES DE SEGURIDAD

**Servidor**: Wetlands (luanti.gabrielpantoja.cl:30000)
**Última Actualización**: 2025-09-22 (Post-Incidente HAKER)

---

## 📋 CLASIFICACIÓN DE INCIDENTES

### **🔴 NIVEL 1 - CRÍTICO**
- Acceso no autorizado con privilegios administrativos
- Modificación de archivos críticos del sistema
- Compromiso masivo de cuentas de usuario
- **Tiempo de Respuesta**: < 10 minutos

### **🟠 NIVEL 2 - ALTO**
- Evasión de medidas de seguridad
- Griefing masivo o destrucción de contenido
- Múltiples intentos de intrusión coordinados
- **Tiempo de Respuesta**: < 30 minutos

### **🟡 NIVEL 3 - MEDIO**
- Actividad sospechosa de usuarios individuales
- Intentos de exploit sin éxito
- Violaciones de políticas del servidor
- **Tiempo de Respuesta**: < 2 horas

### **🔵 NIVEL 4 - BAJO**
- Comportamiento no normativo sin impacto en seguridad
- Reportes de usuarios sin evidencia
- Problemas técnicos menores
- **Tiempo de Respuesta**: < 24 horas

---

## ⚡ RESPUESTA INMEDIATA

### **🚨 CONTENCIÓN INMEDIATA (Primeros 5 minutos)**

#### **1. Evaluación Rápida**:
```bash
# Verificar estado del servidor:
docker-compose ps luanti-server

# Verificar conexiones activas:
docker-compose logs --tail=20 luanti-server | grep -E "(joins|leaves|kick|ban)"

# Identificar actividad anómala:
docker-compose logs --tail=50 luanti-server | grep -E "(dig.*[3-9]\.[0-9]|kick|ban|teleport)"
```

#### **2. Contención Temporal**:
```bash
# Si hay actividad maliciosa confirmada:
# Opción A - Kick del usuario específico (si identificado):
# /kick [username_malicioso]

# Opción B - Detención preventiva del servidor:
docker-compose down

# Crear backup de emergencia:
cp -r server/worlds/world server/worlds/world_EMERGENCY_$(date +%Y%m%d_%H%M%S)
```

#### **3. Preservación de Evidencia**:
```bash
# Capturar logs inmediatos:
docker-compose logs luanti-server > /tmp/incident_logs_$(date +%Y%m%d_%H%M%S).log

# Backup de base de datos auth:
cp server/worlds/world/auth.sqlite server/worlds/world/auth.sqlite.incident_$(date +%Y%m%d_%H%M%S)

# Capturar configuración actual:
cp server/config/luanti.conf server/config/luanti.conf.incident_$(date +%Y%m%d_%H%M%S)
```

---

## 🔍 ANÁLISIS FORENSE

### **Identificación del Atacante**:
```bash
# Extraer todas las conexiones recientes:
docker-compose logs luanti-server | grep -E "joins game|leaves game" | tail -20

# Verificar usuarios con privilegios administrativos:
docker-compose exec -T luanti-server sqlite3 /config/.minetest/worlds/world/auth.sqlite \
"SELECT auth.name, GROUP_CONCAT(user_privileges.privilege)
FROM auth LEFT JOIN user_privileges ON auth.id = user_privileges.id
WHERE user_privileges.privilege IN ('kick','ban','server','privs')
GROUP BY auth.name;"

# Buscar patrones de actividad anómala:
docker-compose logs luanti-server | grep -E "(dig|place|kick|ban)" | tail -50
```

### **Análisis de Privilegios**:
```bash
# Verificar configuración de privilegios por defecto:
grep "default_privs" server/config/luanti.conf

# Auditar todos los usuarios registrados:
docker-compose exec -T luanti-server sqlite3 /config/.minetest/worlds/world/auth.sqlite \
"SELECT name, last_login, datetime(last_login, 'unixepoch') as login_time FROM auth ORDER BY last_login DESC;"
```

---

## 🛡️ MEDIDAS DE CONTENCIÓN

### **Bloqueo de IP**:
```bash
# Método 1 - ipban.txt (Inmediato):
echo "[IP_MALICIOSA]" >> server/worlds/world/ipban.txt

# Método 2 - luanti.conf (Permanente):
echo "deny_access.[IP_MALICIOSA]" >> server/config/luanti.conf

# Verificar bloqueo:
docker-compose restart luanti-server
docker-compose logs --tail=10 luanti-server | grep -i "denied\|blocked"
```

### **Revocación de Privilegios**:
```bash
# Revocar privilegios administrativos de usuario específico:
docker-compose exec -T luanti-server sqlite3 /config/.minetest/worlds/world/auth.sqlite \
"DELETE FROM user_privileges WHERE id IN (SELECT id FROM auth WHERE name='[USERNAME]')
AND privilege IN ('kick','ban','server','privs','rollback','give','teleport','settime','worldedit','debug');"

# Revocación masiva (preservar solo admin principal):
docker-compose exec -T luanti-server sqlite3 /config/.minetest/worlds/world/auth.sqlite \
"DELETE FROM user_privileges WHERE privilege IN ('kick','ban','server','privs')
AND id NOT IN (SELECT id FROM auth WHERE name='gabo');"
```

### **Cambio de Credenciales**:
```bash
# Cambiar contraseña del administrador principal:
# (Ejecutar in-game o desde consola admin)
# /set_password gabo [NUEVA_CONTRASEÑA_SEGURA]

# Documentar cambio:
echo "$(date): Contraseña de gabo cambiada - Incidente: [ID_INCIDENTE]" >> docs/security/password_changes.log
```

---

## 📊 DOCUMENTACIÓN DEL INCIDENTE

### **Crear Carpeta del Incidente**:
```bash
# Estructura estándar:
INCIDENT_DATE=$(date +%Y-%m-%d)
INCIDENT_NAME="[DESCRIPCION_BREVE]"
mkdir -p docs/security/incidents/${INCIDENT_DATE}_${INCIDENT_NAME}
```

### **Documentos Requeridos**:

#### **1. README.md del Incidente**:
```markdown
# INCIDENTE: [TÍTULO]
- Fecha: [FECHA]
- Severidad: [NIVEL]
- Estado: [EN_PROGRESO/RESUELTO]
- IP Atacante: [IP]
- Resumen: [DESCRIPCIÓN_BREVE]
```

#### **2. TIMELINE.md**:
```markdown
# CRONOLOGÍA DEL INCIDENTE
- HH:MM:SS - [EVENTO_1]
- HH:MM:SS - [EVENTO_2]
- HH:MM:SS - [ACCIÓN_TOMADA]
```

#### **3. EVIDENCE.md**:
```markdown
# EVIDENCIA FORENSE
## Logs Relevantes:
[LOGS_CAPTURADOS]

## Base de Datos:
[ESTADO_AUTH_SQLITE]

## Configuración:
[ARCHIVOS_CONFIGURACION]
```

#### **4. REMEDIATION.md**:
```markdown
# ACCIONES DE REMEDIACIÓN
## Implementadas:
- [ACCIÓN_1] - [FECHA] - [RESPONSABLE]

## Pendientes:
- [ACCIÓN_PENDIENTE] - [FECHA_LIMITE] - [ASIGNADO]
```

---

## 🔄 RECUPERACIÓN Y REINICIO

### **Verificación Pre-Reinicio**:
```bash
# Lista de verificación obligatoria:
echo "Verificando estado pre-reinicio..."

# 1. Configuración segura:
grep "default_privs" server/config/luanti.conf
echo "✅ default_privs verificado"

# 2. IP bloqueada:
grep "[IP_MALICIOSA]" server/worlds/world/ipban.txt
echo "✅ IP bloqueada verificada"

# 3. Backup disponible:
ls -la server/worlds/world_EMERGENCY_* | tail -1
echo "✅ Backup de emergencia confirmado"

# 4. Privilegios corregidos:
docker-compose exec -T luanti-server sqlite3 /config/.minetest/worlds/world/auth.sqlite \
"SELECT COUNT(*) as admin_users FROM auth a JOIN user_privileges up ON a.id = up.id WHERE up.privilege = 'server';"
echo "✅ Privilegios administrativos verificados"
```

### **Reinicio Seguro**:
```bash
# Secuencia de reinicio con verificaciones:
echo "Iniciando reinicio seguro..."

# 1. Reiniciar servidor:
docker-compose down
sleep 5
docker-compose up -d

# 2. Verificar inicio exitoso:
sleep 10
docker-compose ps luanti-server

# 3. Verificar puerto activo:
ss -tulpn | grep :30000

# 4. Monitorear logs:
docker-compose logs --tail=20 luanti-server

echo "✅ Reinicio completado"
```

### **Monitoreo Post-Incidente**:
```bash
# Script de monitoreo intensivo (ejecutar en background):
#!/bin/bash
# incident_monitor.sh
echo "Iniciando monitoreo post-incidente: $(date)"

docker-compose logs -f luanti-server | \
grep -E "([0-9]+\.[0-9]+\.[0-9]+\.[0-9]+|kick|ban|dig.*[3-9]\.[0-9])" | \
while read line; do
    echo "$(date): SECURITY_MONITOR: $line" | tee -a logs/post_incident_monitor.log

    # Alertas específicas:
    if echo "$line" | grep -q "[IP_MALICIOSA]"; then
        echo "🚨 ALERTA: IP maliciosa detectada: $line"
    fi

    if echo "$line" | grep -E "(kick|ban)"; then
        echo "⚠️ ALERTA: Comando administrativo detectado: $line"
    fi
done
```

---

## 📞 ESCALACIÓN Y CONTACTOS

### **Cadena de Escalación**:

#### **Nivel 1 - Respuesta Automática**:
- **Responsable**: Sistemas automatizados
- **Tiempo**: < 30 segundos
- **Acciones**: Alertas, logging, contención básica

#### **Nivel 2 - Administrador Técnico**:
- **Responsable**: gabriel@<VPS_HOST_IP>
- **Tiempo**: < 10 minutos
- **Acciones**: Análisis técnico, contención avanzada

#### **Nivel 3 - Administrador Principal**:
- **Responsable**: gabo (in-game admin)
- **Tiempo**: < 30 minutos
- **Acciones**: Decisiones administrativas, comunicación

#### **Nivel 4 - Autoridades**:
- **Responsable**: Administración superior
- **Tiempo**: < 24 horas
- **Acciones**: Reporte a ISP, autoridades legales

### **Contactos de Emergencia**:
```
VPS Técnico: gabriel@<VPS_HOST_IP>
Admin Principal: gabo (usuario in-game)
Backup Admin: [POR_DEFINIR]
```

---

## 📚 LECCIONES APRENDIDAS (Post-Incidente HAKER)

### **Configuración**:
- ❌ **NUNCA** incluir `kick`, `ban`, `server` en `default_privs`
- ✅ **SIEMPRE** usar privilegios mínimos por defecto
- ✅ **VERIFICAR** efectividad de bloqueos IP implementados

### **Detección**:
- ⚠️ **MONITOREAR** velocidades de excavación anormales (>3 bloques/segundo)
- ⚠️ **ALERTAR** múltiples reconexiones desde misma IP
- ⚠️ **AUDITAR** comandos administrativos ejecutados

### **Respuesta**:
- ✅ **DOCUMENTAR** evidencia ANTES de tomar acciones
- ✅ **PRESERVAR** backups automáticamente
- ✅ **VERIFICAR** medidas de contención antes de reiniciar

---

**Documento Actualizado**: 2025-09-22 (Post-Incidente HAKER)
**Próxima Revisión**: 2025-10-22
**Clasificación**: 🔒 CONFIDENCIAL - Solo administradores autorizados