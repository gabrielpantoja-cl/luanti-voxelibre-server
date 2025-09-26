# 🚨 INCIDENTE DE SEGURIDAD CONSOLIDADO - USUARIO HAKER
**Fecha**: 20 de Septiembre, 2025
**Servidor**: luanti.gabrielpantoja.cl:30000
**Estado**: 🔴 **RESUELTO - IP BLOQUEADA**
**Nivel de Amenaza**: 🟠 **MEDIO-ALTO**

---

## 📋 RESUMEN EJECUTIVO

**Atacante**: Usuario "HAKER" y cuentas de evasión desde IP `200.83.160.80`
**Actividad Maliciosa**: Evasión sistemática de bans, griefing, uso de herramientas de ocultación
**Duración Total**: 8 minutos, 42 segundos (19:23:53 - 19:31:35 UTC)
**Acciones Tomadas**: IP bloqueada, servidor detenido preventivamente, contraseña admin cambiada

---

## 🎯 IDENTIFICACIÓN DEL ATACANTE

### **IP Origen**: `200.83.160.80`
### **Cuentas Utilizadas**:
1. **HAKER** (cuenta original) - EXPULSADO
2. **HAKEr** (intento fallido) - BLOQUEADO por sistema
3. **gdfgd** (evasión #1) - EXPULSADO
4. **gdfgddddd** (evasión #2) - ACTIVA al momento del apagado

### **Actividad Maliciosa Detectada**:
- ✅ Excavación sistemática cerca del spawn
- ✅ Uso de pociones de invisibilidad (herramientas de ocultación)
- ✅ Evasión múltiple de expulsiones administrativas
- ✅ Creación de cuentas con nombres aleatorios
- ✅ Velocidad de excavación anormal (4.5 bloques/segundo)

---

## ⚠️ PROBLEMA DE PRIVILEGIOS IDENTIFICADO

Durante la investigación se descubrió **escalada masiva de privilegios**:

### **Usuarios con Privilegios Administrativos Peligrosos**:
- **gabo** ✅ (legítimo admin)
- **Gapi, gael, gaelsin, pepelomo, veight** ⚠️ (privilegios excesivos)

### **Privilegios Peligrosos Otorgados**:
- `kick`, `ban`, `server` - Control administrativo completo
- `give`, `teleport`, `settime` - Poderes de modificación del servidor
- `worldedit`, `debug`, `noclip` - Herramientas de desarrollo

### **Causa Raíz**:
```conf
# Configuración problemática en server/config/luanti.conf:
default_privs = interact,shout,creative,give,fly,fast,noclip,home
```

---

## 🛠️ MEDIDAS DE CONTENCIÓN IMPLEMENTADAS

### ✅ **Acciones Completadas**:
1. **IP Bloqueada**: `200.83.160.80` añadida a deny_access
2. **Servidor Detenido**: Parada preventiva para análisis
3. **Contraseña Admin Cambiada**:
   - Usuario: `gabo`
   - Nueva contraseña: `VeganSafe2025!`
   - Hash SHA1: `50944d884166b05bbaf42c8eeaf63958fe8bf95e`
4. **Documentación Completa**: Evidencia preservada
5. **Backup de Seguridad**: Estado del mundo preservado

### 🔧 **Métodos de Bloqueo Implementados**:

#### **MÉTODO 1: deny_access en luanti.conf** ⭐ PRINCIPAL
```bash
# Ubicación: server/config/luanti.conf
# Línea añadida: deny_access.200.83.160.80

# Verificar bloqueo:
ssh gabriel@<VPS_HOST_IP> "cd /home/gabriel/Vegan-Wetlands && grep '200.83.160.80' server/config/luanti.conf"
# Resultado: deny_access.200.83.160.80
```

#### **MÉTODO 2: ipban.txt** ⭐ BACKUP
```bash
# Ubicación: /config/.minetest/worlds/world/ipban.txt

# Verificar bloqueo:
ssh gabriel@<VPS_HOST_IP> "cd /home/gabriel/Vegan-Wetlands && docker-compose exec -T luanti-server cat /config/.minetest/worlds/world/ipban.txt"
# Resultado: 200.83.160.80
```

---

## 🔄 PROCEDIMIENTO DE REVERSIÓN (En caso de falso positivo)

### ⚠️ **IMPORTANTE**: Solo ejecutar si se confirma que el bloqueo fue erróneo

#### **PASO 1: Backup de Seguridad Antes de Revertir**
```bash
# Crear backup de configuración actual:
ssh gabriel@<VPS_HOST_IP> "cd /home/gabriel/Vegan-Wetlands && cp server/config/luanti.conf server/config/luanti.conf.backup.before_unblock_$(date +%Y%m%d_%H%M%S)"

# Backup de ipban.txt:
ssh gabriel@<VPS_HOST_IP> "cd /home/gabriel/Vegan-Wetlands && docker-compose exec -T luanti-server cp /config/.minetest/worlds/world/ipban.txt /config/.minetest/worlds/world/ipban.txt.backup.$(date +%Y%m%d_%H%M%S)"
```

#### **PASO 2: Remover de luanti.conf** (MÉTODO PRINCIPAL)
```bash
# Editar archivo de configuración para remover deny_access:
ssh gabriel@<VPS_HOST_IP> "cd /home/gabriel/Vegan-Wetlands && sed -i '/deny_access.200.83.160.80/d' server/config/luanti.conf"

# Verificar que fue removido:
ssh gabriel@<VPS_HOST_IP> "cd /home/gabriel/Vegan-Wetlands && grep '200.83.160.80' server/config/luanti.conf || echo 'IP removida exitosamente de luanti.conf'"
```

#### **PASO 3: Remover de ipban.txt** (MÉTODO BACKUP)
```bash
# Remover IP del archivo ipban.txt:
ssh gabriel@<VPS_HOST_IP> "cd /home/gabriel/Vegan-Wetlands && docker-compose exec -T luanti-server sh -c \"grep -v '200.83.160.80' /config/.minetest/worlds/world/ipban.txt > /tmp/ipban_temp && mv /tmp/ipban_temp /config/.minetest/worlds/world/ipban.txt\""

# Verificar que fue removido:
ssh gabriel@<VPS_HOST_IP> "cd /home/gabriel/Vegan-Wetlands && docker-compose exec -T luanti-server grep '200.83.160.80' /config/.minetest/worlds/world/ipban.txt || echo 'IP removida exitosamente de ipban.txt'"
```

#### **PASO 4: Aplicar Cambios**
```bash
# Reiniciar servidor para aplicar cambios:
ssh gabriel@<VPS_HOST_IP> "cd /home/gabriel/Vegan-Wetlands && docker-compose restart luanti-server"

# Verificar que servidor está activo:
ssh gabriel@<VPS_HOST_IP> "cd /home/gabriel/Vegan-Wetlands && docker-compose ps luanti-server"
```

#### **PASO 5: Verificar Desbloqueo**
```bash
# Desde la IP previamente bloqueada, intentar conectar con cliente Luanti
# La conexión debe ser exitosa

# Verificar logs del servidor:
ssh gabriel@<VPS_HOST_IP> "cd /home/gabriel/Vegan-Wetlands && docker-compose logs --tail=20 luanti-server | grep '200.83.160.80'"
```

#### **PASO 6: Documentar Reversión**
```bash
# Actualizar documentación indicando:
# - Fecha y hora de la reversión
# - Razón del falso positivo
# - Usuario que autorizó la reversión
# - Evidencia de que era legítimo

echo "REVERSIÓN EJECUTADA: $(date) - IP 200.83.160.80 desbloqueada - Autorizado por: [ADMIN_NAME] - Razón: [FALSO_POSITIVO_REASON]" >> docs/IP_UNBLOCK_LOG.md
```

### 🚨 **Script de Emergency Unblock**
```bash
#!/bin/bash
# emergency_unblock.sh
# USO: ./emergency_unblock.sh 200.83.160.80 "razón del desbloqueo"

IP_TO_UNBLOCK="$1"
REASON="$2"

if [ -z "$IP_TO_UNBLOCK" ] || [ -z "$REASON" ]; then
    echo "Uso: $0 <IP_TO_UNBLOCK> \"razón\""
    exit 1
fi

echo "🔄 DESBLOQUEANDO IP: $IP_TO_UNBLOCK"
echo "📝 RAZÓN: $REASON"

# Backup antes de cambios
echo "📦 Creando backup..."
ssh gabriel@<VPS_HOST_IP> "cd /home/gabriel/Vegan-Wetlands && cp server/config/luanti.conf server/config/luanti.conf.backup.unblock_$(date +%Y%m%d_%H%M%S)"

# Remover de luanti.conf
echo "🔧 Removiendo de luanti.conf..."
ssh gabriel@<VPS_HOST_IP> "cd /home/gabriel/Vegan-Wetlands && sed -i '/deny_access.$IP_TO_UNBLOCK/d' server/config/luanti.conf"

# Remover de ipban.txt
echo "🔧 Removiendo de ipban.txt..."
ssh gabriel@<VPS_HOST_IP> "cd /home/gabriel/Vegan-Wetlands && docker-compose exec -T luanti-server sh -c \"grep -v '$IP_TO_UNBLOCK' /config/.minetest/worlds/world/ipban.txt > /tmp/ipban_temp && mv /tmp/ipban_temp /config/.minetest/worlds/world/ipban.txt\""

# Reiniciar servidor
echo "🔄 Reiniciando servidor..."
ssh gabriel@<VPS_HOST_IP> "cd /home/gabriel/Vegan-Wetlands && docker-compose restart luanti-server"

# Documentar
echo "📝 Documentando reversión..."
echo "REVERSIÓN: $(date) - IP $IP_TO_UNBLOCK desbloqueada - Razón: $REASON" >> docs/IP_UNBLOCK_LOG.md

echo "✅ IP $IP_TO_UNBLOCK DESBLOQUEADA EXITOSAMENTE"
echo "⚠️  RECUERDA: Monitorear actividad de esta IP las próximas 24 horas"
```

---

## 🛡️ RECOMENDACIONES DE SEGURIDAD

### **CRÍTICO - Implementar Inmediatamente**:

#### 1. **Corregir Privilegios por Defecto**:
```conf
# CAMBIAR EN server/config/luanti.conf:
# DE:
default_privs = interact,shout,creative,give,fly,fast,noclip,home

# A:
default_privs = interact,shout,creative,home
```

#### 2. **Revocar Privilegios Administrativos Excesivos**:
```bash
# Conectar al VPS y acceder a la base de datos:
ssh gabriel@<VPS_HOST_IP>
cd /home/gabriel/Vegan-Wetlands
docker-compose exec -T luanti-server sqlite3 /config/.minetest/worlds/world/auth.sqlite

# Revocar privilegios peligrosos excepto de gabo:
DELETE FROM user_privileges WHERE privilege IN ('kick','ban','server','privs','rollback','give','teleport','settime','worldedit','debug') AND id NOT IN (SELECT id FROM auth WHERE name='gabo');
```

#### 3. **Implementar Monitoreo de Seguridad**:
```bash
# Script de monitoreo automático:
#!/bin/bash
# monitor_security.sh
docker-compose logs -f luanti-server | grep -E "(200\.83\.160\.80|HAKER|kick|ban)" | tee -a logs/security_monitor.log
```

---

## 📊 CRONOLOGÍA DEL INCIDENTE

```
19:23:53 - HAKER: Primera conexión desde 200.83.160.80
19:25:56 - HAKER: Inicia excavación sistemática
19:27:30 - HAKER: Usa poción de invisibilidad
19:29:39 - gabo: Expulsa a HAKER
19:29:59 - HAKEr: Intento fallido de reconexión
19:30:54 - gdfgd: Primera evasión exitosa
19:31:11 - gabo: Expulsa a gdfgd
19:31:35 - gdfgddddd: Segunda evasión exitosa
19:32:00 - SERVIDOR DETENIDO PREVENTIVAMENTE
```

---

## 🔐 PROTOCOLO DE REINICIO SEGURO

### **Antes del Reinicio**:
1. ✅ Verificar IP bloqueada: `200.83.160.80`
2. ✅ Confirmar nueva contraseña admin: `VeganSafe2025!`
3. ⚠️ **PENDIENTE**: Corregir `default_privs` en luanti.conf
4. ⚠️ **PENDIENTE**: Revocar privilegios excesivos de usuarios
5. ⚠️ **PENDIENTE**: Configurar monitoreo automatizado

### **Al Reiniciar**:
```bash
# Comando de reinicio seguro:
ssh gabriel@<VPS_HOST_IP> "cd /home/gabriel/Vegan-Wetlands && docker-compose up -d"

# Verificar servidor activo:
ss -tulpn | grep :30000

# Monitorear logs en tiempo real:
docker-compose logs -f luanti-server
```

### **Post-Reinicio**:
1. Monitoreo intensivo primeras 2 horas
2. Verificar que IP bloqueada no puede conectar
3. Confirmar que privilegios están corregidos
4. Informar a la comunidad sobre medidas de seguridad

---

## 📞 CONTACTOS Y ESCALACIÓN

### **Administradores**:
- **Admin Principal**: gabo (contraseña actualizada: `VeganSafe2025!`)
- **Contacto Técnico VPS**: gabriel@<VPS_HOST_IP>

### **En Caso de Nueva Actividad Maliciosa**:
```
Nivel 1: Bloqueo automático de nueva IP
Nivel 2: Detención preventiva del servidor
Nivel 3: Contacto con ISP del atacante
Nivel 4: Reporte a autoridades competentes
```

---

## 📄 ARCHIVOS DE EVIDENCIA

### **Logs Preservados**:
- Actividad completa del usuario HAKER
- Conexiones desde IP 200.83.160.80
- Intervenciones administrativas

### **Configuración Respaldada**:
- Estado pre-incidente del servidor
- Configuración de privilegios original
- Lista de usuarios registrados

---

## ✅ ESTADO ACTUAL

- 🔴 **IP 200.83.160.80**: BLOQUEADA PERMANENTEMENTE
- 🟢 **Contraseña Admin**: ACTUALIZADA Y SEGURA
- 🟡 **Privilegios del Sistema**: REQUIERE CORRECCIÓN
- 🟡 **Servidor**: DETENIDO - LISTO PARA REINICIO SEGURO

---

## 📋 PRÓXIMOS PASOS INMEDIATOS

1. **URGENTE**: Corregir `default_privs` en luanti.conf
2. **URGENTE**: Revocar privilegios administrativos excesivos
3. **MEDIO PLAZO**: Reiniciar servidor con configuración segura
4. **CONTINUO**: Monitoreo intensivo de seguridad

---

**Documento Consolidado Generado**: 2025-09-21
**Basado en**:
- SECURITY_INCIDENT_HAKER_20250920.md
- SECURITY_ANALYSIS_PRIVILEGE_ESCALATION_20250920.md
- IP_BLOCKING_MANUAL.md
- IP_TRACKING_REGISTER_200.83.160.80.md

**Clasificación**: 🔒 CONFIDENCIAL - Solo administradores autorizados