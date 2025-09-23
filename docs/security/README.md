# 🛡️ DOCUMENTACIÓN DE SEGURIDAD - VEGAN WETLANDS

**Servidor**: luanti.gabrielpantoja.cl:30000
**Última Actualización**: 2025-09-22 (Post-Incidente HAKER)

---

## 📁 ESTRUCTURA DE DOCUMENTACIÓN DE SEGURIDAD

### **📋 Documentos Principales**:

#### **🚨 [incidents/](./incidents/)**
- **Incidentes de seguridad documentados**
- **Análisis forense completo**
- **Evidencia y cronologías detalladas**
- **Primer incidente**: [2025-09-20_HAKER_ATTACK](./incidents/2025-09-20_HAKER_ATTACK/)

#### **📖 [procedures/](./procedures/)**
- **Procedimientos de respuesta a incidentes**
- **Protocolos de escalación**
- **Guías de contención y recuperación**

#### **📜 [policies/](./policies/)**
- **Políticas de seguridad del servidor**
- **Configuraciones obligatorias**
- **Gestión de usuarios y privilegios**

#### **📊 [monitoring/](./monitoring/)**
- **Scripts de monitoreo automatizado**
- **Logs de seguridad**
- **Alertas y métricas**

---

## 🚨 INCIDENTES DE SEGURIDAD

### **📊 Resumen de Incidentes**:

| Fecha | Nombre | Severidad | Estado | IP Atacante |
|-------|--------|-----------|--------|-------------|
| 2025-09-20 | [HAKER_ATTACK](./incidents/2025-09-20_HAKER_ATTACK/) | 🔴 ALTA | ✅ RESUELTO | <BROMA_IP> |

### **🎯 Primer Incidente Crítico**:
- **[ATAQUE HAKER - 20 SEPTIEMBRE 2025](./incidents/2025-09-20_HAKER_ATTACK/)**
- **Duración**: 5 horas, 11 minutos
- **Impacto**: Compromiso de privilegios + Evasión de bloqueos
- **Lección**: Configuración `default_privs` vulnerable
- **Estado**: ✅ **DOCUMENTADO Y RESUELTO**

---

## 📋 CONFIGURACIÓN ACTUAL DE SEGURIDAD

### **✅ Medidas Implementadas**:
- Cambio de contraseña administrativa
- Backup de emergencia preservado
- Documentación forense completa
- Procedimientos de respuesta definidos

### **⚠️ Pendientes de Implementación**:
- Corrección de `default_privs` vulnerable
- Revocación masiva de privilegios excesivos
- Verificación de bloqueo IP efectivo
- Sistema de monitoreo automatizado

---

## 🔴 ACCIONES INMEDIATAS REQUERIDAS

### **CRÍTICO - Ejecutar AHORA**:
1. **Corregir default_privs**: `interact,shout,creative,home`
2. **Revocar privilegios masivamente**: Eliminar kick/ban de usuarios no-admin
3. **Verificar bloqueo IP**: Asegurar que <BROMA_IP> no pueda conectar
4. **Eliminar usuario sospechoso**: Usuario 'veight' con privilegios completos

Ver: [COMPLETE_SECURITY_INCIDENT_FINAL_20250920.md](./incidents/2025-09-20_HAKER_ATTACK/COMPLETE_SECURITY_INCIDENT_FINAL_20250920.md)

---

## 📞 CONTACTOS DE SEGURIDAD

### **👑 Administrador Principal**:
- **Usuario**: gabo
- **Responsabilidad**: Decisiones administrativas y cambios de privilegios

### **🔧 Administrador Técnico**:
- **Usuario**: gabriel@<VPS_IP>
- **Responsabilidad**: Gestión VPS y análisis forense

### **📋 Escalación de Emergencia**:
```
Nivel 1: Detección automática (< 30 segundos)
Nivel 2: Administrador técnico (< 10 minutos)
Nivel 3: Administrador principal (< 30 minutos)
Nivel 4: Autoridades externas (< 24 horas)
```

---

## 📊 MÉTRICAS DE SEGURIDAD

### **Estado Actual**:
- **Último Incidente**: 2025-09-20 (RESUELTO)
- **Tiempo Promedio de Respuesta**: 8 minutos, 42 segundos
- **IPs Bloqueadas**: 1 (<BROMA_IP>)
- **Usuarios con Privilegios Admin**: 4 (requiere auditoría)

### **Objetivos de Seguridad**:
- **Tiempo de Detección**: < 5 minutos
- **Tiempo de Contención**: < 10 minutos
- **Disponibilidad del Servidor**: > 99%
- **Zero Compromise**: 0 incidentes exitosos sin contención

---

**Clasificación**: 🔒 CONFIDENCIAL - Solo administradores autorizados
**Próxima Revisión**: 2025-10-22