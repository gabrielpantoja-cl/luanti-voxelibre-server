# 🛡️ POLÍTICA DE SEGURIDAD DEL SERVIDOR WETLANDS

**Servidor**: luanti.gabrielpantoja.cl:30000
**Versión**: 1.0 (Post-Incidente HAKER)
**Fecha**: 2025-09-22
**Estado**: ✅ **ACTIVA**

---

## 📋 PRINCIPIOS DE SEGURIDAD

### **1. Principio de Menor Privilegio**
- **Regla**: Los usuarios deben recibir ÚNICAMENTE los privilegios mínimos necesarios
- **Aplicación**: `default_privs = interact,shout,creative,home`
- **Prohibido**: Otorgar `kick`, `ban`, `server`, `privs` automáticamente

### **2. Defensa en Profundidad**
- **Múltiples capas**: Configuración + Bloqueo IP + Monitoreo + Procedimientos
- **Redundancia**: Backup automático + Manual + Forense
- **Verificación**: Todas las medidas deben ser probadas y verificadas

### **3. Monitoreo Continuo**
- **Logging**: Todas las acciones administrativas deben ser registradas
- **Alertas**: Patrones anómalos deben generar notificaciones inmediatas
- **Auditorías**: Revisión regular de privilegios y configuraciones

### **4. Respuesta Rápida**
- **Detección**: < 5 minutos para actividad crítica
- **Contención**: < 10 minutos para amenazas confirmadas
- **Documentación**: Evidencia forense preservada inmediatamente

---

## 🔧 CONFIGURACIONES DE SEGURIDAD OBLIGATORIAS

### **Privilegios por Defecto**:
```conf
# server/config/luanti.conf - CONFIGURACIÓN SEGURA OBLIGATORIA:
default_privs = interact,shout,creative,home

# PROHIBIDO incluir:
# kick, ban, server, privs, rollback, give, teleport, settime, worldedit, debug, fast, fly, noclip
```

### **Configuraciones de Red**:
```conf
# Límites de conexión:
max_users_per_ip = 2
client_timeout = 10

# Logging y monitoreo:
log_level = action
log_timestamp = true
debug_log_level = action
```

---

**Política Aprobada por**: gabo (Administrador Principal)
**Fecha de Aprobación**: 2025-09-22
**Vigencia**: Indefinida (sujeta a revisiones regulares)
**Próxima Revisión**: 2025-10-22
**Clasificación**: 🔒 CONFIDENCIAL - Solo administradores autorizados