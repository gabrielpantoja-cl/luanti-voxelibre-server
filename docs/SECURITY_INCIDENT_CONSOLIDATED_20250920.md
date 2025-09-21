# 🚨 INCIDENTE DE SEGURIDAD CONSOLIDADO - USUARIO HAKER
**Fecha**: 20 de Septiembre, 2025
**Servidor**: luanti.gabrielpantoja.cl:30000
**Estado**: 🔴 **RESUELTO - IP BLOQUEADA**
**Nivel de Amenaza**: 🟠 **MEDIO-ALTO**

---

## 📋 RESUMEN EJECUTIVO

**Atacante**: Usuario "HAKER" y cuentas de evasión desde IP `<BROMA_IP>`
**Actividad Maliciosa**: Evasión sistemática de bans, griefing, uso de herramientas de ocultación
**Duración Total**: 8 minutos, 42 segundos (19:23:53 - 19:31:35 UTC)
**Acciones Tomadas**: IP bloqueada, servidor detenido preventivamente, contraseña admin cambiada

---

## 🎯 IDENTIFICACIÓN DEL ATACANTE

### **IP Origen**: `<BROMA_IP>`
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
1. **IP Bloqueada**: `<BROMA_IP>` añadida a deny_access
2. **Servidor Detenido**: Parada preventiva para análisis
3. **Contraseña Admin Cambiada**:
   - Usuario: `gabo`
   - Nueva contraseña: `<REDACTED_PASSWORD>`
   - Hash SHA1: `<REDACTED_HASH>`
4. **Documentación Completa**: Evidencia preservada
5. **Backup de Seguridad**: Estado del mundo preservado

### 🔧 **Configuración de Bloqueo Activo**:
```bash
# Verificar bloqueo:
ssh gabriel@<VPS_IP> "cd /home/gabriel/Vegan-Wetlands && docker-compose exec -T luanti-server cat /config/.minetest/worlds/world/ipban.txt"

# Resultado esperado: <BROMA_IP>
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
ssh gabriel@<VPS_IP>
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
19:23:53 - HAKER: Primera conexión desde <BROMA_IP>
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
1. ✅ Verificar IP bloqueada: `<BROMA_IP>`
2. ✅ Confirmar nueva contraseña admin: `<REDACTED_PASSWORD>`
3. ⚠️ **PENDIENTE**: Corregir `default_privs` en luanti.conf
4. ⚠️ **PENDIENTE**: Revocar privilegios excesivos de usuarios
5. ⚠️ **PENDIENTE**: Configurar monitoreo automatizado

### **Al Reiniciar**:
```bash
# Comando de reinicio seguro:
ssh gabriel@<VPS_IP> "cd /home/gabriel/Vegan-Wetlands && docker-compose up -d"

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
- **Admin Principal**: gabo (contraseña actualizada: `<REDACTED_PASSWORD>`)
- **Contacto Técnico VPS**: gabriel@<VPS_IP>

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
- Conexiones desde IP <BROMA_IP>
- Intervenciones administrativas

### **Configuración Respaldada**:
- Estado pre-incidente del servidor
- Configuración de privilegios original
- Lista de usuarios registrados

---

## ✅ ESTADO ACTUAL

- 🔴 **IP <BROMA_IP>**: BLOQUEADA PERMANENTEMENTE
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
- IP_TRACKING_REGISTER_<BROMA_IP>.md

**Clasificación**: 🔒 CONFIDENCIAL - Solo administradores autorizados