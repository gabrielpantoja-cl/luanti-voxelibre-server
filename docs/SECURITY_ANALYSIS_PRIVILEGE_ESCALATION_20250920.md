# 🚨 REPORTE DE SEGURIDAD: ESCALADA DE PRIVILEGIOS MASIVA
**Fecha**: 20 de Septiembre, 2025
**Severidad**: **CRÍTICA**
**Estado**: **ACTIVO - REQUIERE ACCIÓN INMEDIATA**

## 📋 RESUMEN EJECUTIVO

Se ha detectado una **escalada masiva de privilegios** en el servidor Vegan Wetlands que permite a usuarios regulares tener **control administrativo completo**, incluyendo la capacidad de expulsar (KICK) y banear otros jugadores.

## 🔍 HALLAZGOS CRÍTICOS

### Usuarios con Privilegios Administrativos Completos:
- **Gapi** ⚠️ (25 privilegios admin incluyendo kick, ban, server)
- **gabo** ⚠️ (36 privilegios admin incluyendo kick, ban, server, shutdown)
- **gael** ⚠️ (25 privilegios admin incluyendo kick, ban, server)
- **gaelsin** ⚠️ (25 privilegios admin incluyendo kick, ban, server)
- **pepelomo** ⚠️ (30 privilegios admin incluyendo kick, ban, server)
- **veight** ⚠️ (30 privilegios admin incluyendo kick, ban, server)

### Usuarios con Privilegios Normales (Correcto):
- **HAKER** ✅ (3 privilegios: fly, interact, shout)
- **fgkfkydkcdgi** ✅ (3 privilegios: fly, interact, shout)
- **gabotest** ✅ (3 privilegios: fly, interact, shout)
- **gabotest2** ✅ (3 privilegios: fly, interact, shout)
- **gdfgd** ✅ (3 privilegios: fly, interact, shout)
- **gdfgddddd** ✅ (3 privilegios: fly, interact, shout)
- **gdfiiiigddddd** ✅ (3 privilegios: fly, interact, shout)

## ⚠️ PRIVILEGIOS PELIGROSOS OTORGADOS

Los usuarios comprometidos tienen acceso a:

### 🚫 Privilegios de Moderación Peligrosos:
- `kick` - Expulsar jugadores del servidor
- `ban` - Banear jugadores permanentemente
- `server` - Control total del servidor
- `privs` - Otorgar/revocar privilegios a otros usuarios
- `rollback` - Revertir cambios en el mundo

### 🛠️ Privilegios Administrativos:
- `give` - Crear items infinitos
- `teleport` - Teletransportar jugadores
- `settime` - Cambiar hora del servidor
- `weather_manager` - Controlar clima
- `shutdown` - Apagar el servidor (solo gabo)

### 🔧 Privilegios de Desarrollo:
- `worldedit` - Edición masiva del mundo (solo gabo)
- `debug` - Acceso a herramientas de depuración
- `noclip` - Atravesar bloques
- `protection_bypass` - Ignorar protecciones

## 🔧 CAUSA RAÍZ IDENTIFICADA

**Archivo**: `server/config/luanti.conf`
**Línea problemática**:
```conf
default_privs = interact,shout,creative,give,fly,fast,noclip,home
```

### Problema:
La configuración `default_privs` otorga privilegios peligrosos (`give`, `fly`, `fast`, `noclip`) a **TODOS** los nuevos usuarios. Sin embargo, algunos usuarios han recibido privilegios adicionales de administración através de otros mecanismos.

## 📊 ANÁLISIS DE COMPORTAMIENTO

### Usuario HAKER:
- **Estado**: Privilegios correctos (limitados)
- **Comportamiento**: No se detectó actividad maliciosa en logs recientes
- **Privilegios**: Solo `fly`, `interact`, `shout` (configuración correcta)

### Actividad del Servidor (Últimas horas):
- **19:52**: `gabo` se conecta desde IP <ADMIN_IP>
- **20:03**: `pepelomo` se conecta desde misma IP
- **20:03**: `pepelomo` usa armas (spear_netherite) - comportamiento normal
- **No se detectaron** comandos administrativos maliciosos en logs recientes

## 🚨 RIESGO DE SEGURIDAD

### Impacto Inmediato:
- **6 usuarios** pueden **expulsar/banear** jugadores legítimos
- **6 usuarios** pueden **crear items infinitos** (give)
- **6 usuarios** pueden **modificar el servidor** (settime, weather)
- **1 usuario** (gabo) puede **apagar el servidor** completamente

### Riesgo para Niños (Edad 7+):
- Usuarios maliciosos pueden **expulsar niños** del servidor
- Pueden **arruinar la experiencia educativa** con poderes excesivos
- **Griefing administrativo** sin supervisión apropiada

## 🛠️ SOLUCIONES RECOMENDADAS

### 1. ACCIÓN INMEDIATA - Corregir default_privs:
```conf
# CAMBIAR DE:
default_privs = interact,shout,creative,give,fly,fast,noclip,home

# CAMBIAR A:
default_privs = interact,shout,creative,home
```

### 2. Revocar privilegios administrativos excepto administradores legítimos:
```sql
-- Mantener solo gabo como administrador
-- Revocar privilegios peligrosos de otros usuarios
DELETE FROM user_privileges WHERE privilege IN ('kick','ban','server','privs','rollback') AND id NOT IN (SELECT id FROM auth WHERE name='gabo');
```

### 3. Implementar privilegios escalados:
- **Nivel 1** (Niños): `interact`, `shout`, `creative`, `home`
- **Nivel 2** (Moderadores): Añadir `fly`, `fast`, `teleport`
- **Nivel 3** (Administradores): Añadir `kick`, `ban`, `server`, `privs`

## 🔐 ESTADO ACTUAL

- ❌ **Vulnerabilidad activa**: 6 usuarios con privilegios de kick/ban
- ❌ **Configuración insegura**: default_privs otorga poderes excesivos
- ✅ **Usuario HAKER**: Privilegios correctos, sin actividad maliciosa detectada
- ✅ **Servidor estable**: Sin signos de abuso administrativo reciente

## 📋 PRÓXIMOS PASOS

1. **URGENTE**: Actualizar `default_privs` en `luanti.conf`
2. **URGENTE**: Revocar privilegios administrativos de usuarios no autorizados
3. **MEDIO PLAZO**: Implementar sistema de roles escalados
4. **MONITOREO**: Auditar logs regularmente para detectar abuso de privilegios

---
**Analista de Seguridad**: Claude Code
**Servidor**: luanti.gabrielpantoja.cl:30000
**Revisión requerida**: Administrador del sistema