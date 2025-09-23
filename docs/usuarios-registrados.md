# Usuarios Registrados - Servidor Vegan Wetlands

## Estado Actual (22-09-2025)

### Usuarios Activos
Total de usuarios registrados: **5 usuarios**

| Usuario | Identificación | Rol | Privilegios | Estado |
|---------|----------------|-----|-------------|--------|
| `gabo` | Admin Principal | Administrador | **COMPLETOS** (33 privilegios) | ✅ Activo |
| `pepelomo` | Luciano | Moderador | **ADMIN** (29 privilegios) | ✅ Activo |
| `veight` | Karu | Jugador | **LIMITADOS** (17 privilegios) | ✅ Activo |
| `gaelsin` | Gael (Sobrino) | Jugador | **BÁSICOS** (8 privilegios) | ⚠️ Supervisado |
| `Gapi` | Gapi | Jugador | **BÁSICOS** (8 privilegios) | ✅ Activo |

### Detalle de Privilegios por Usuario

**🔑 gabo** (Admin Principal - 33 privilegios):
`advancements, announce, ban, basic_privs, bring, creative, debug, fast, fly, give, help_reveal, home, hunger, interact, kick, maphack, mute, noclip, password, privs, protection_bypass, rollback, rollback_check, server, settime, shout, shutdown, spawn, teleport, time, unban, weather_manager, worldedit`

**👮 pepelomo** (Moderador - 29 privilegios):
`advancements, announce, ban, basic_privs, bring, creative, debug, fast, fly, give, help_reveal, home, hunger, interact, kick, maphack, noclip, password, privs, protection_bypass, rollback, server, settime, shout, spawn, teleport, weather_manager`

**🎮 veight** (Jugador Limitado - 17 privilegios):
`advancements, basic_privs, bring, creative, debug, fast, fly, give, help_reveal, home, hunger, interact, noclip, settime, shout, spawn, teleport`
*Nota: Se removieron privilegios peligrosos (server, ban, kick, privs, password, rollback, protection_bypass, maphack, announce, weather_manager)*

**👤 gaelsin** (Supervisado - 8 privilegios):
`advancements, basic_privs, fast, fly, help_reveal, hunger, interact, shout`

**👤 Gapi** (Jugador Básico - 8 privilegios):
`advancements, basic_privs, fast, fly, help_reveal, hunger, interact, shout`

## 🚨 INCIDENTE DE SEGURIDAD (20-09-2025)

### **ATAQUE COORDINADO DESDE IP <BROMA_IP>**

**Período del Ataque**: 20 de septiembre 2025, 19:23-19:31 UTC
**Duración**: 9 minutos, 42 segundos
**Estado del Servidor**: 🔴 **DETENIDO POR SEGURIDAD**

#### **Cuentas Maliciosas Identificadas (5 usuarios)**
| Usuario | Fecha/Hora Registro | IP | Actividad Principal | Estado |
|---------|-------------------|-----|-------------------|--------|
| `HAKER` | 2025-09-20 19:23:53 | <BROMA_IP> | Excavación sistemática, pociones invisibilidad | 🚨 BLOQUEADO |
| `gdfgd` | 2025-09-20 19:30:54 | <BROMA_IP> | Evasión #1, excavación cerca spawn | 🚨 BLOQUEADO |
| `gdfgddddd` | 2025-09-20 19:31:35 | <BROMA_IP> | Evasión #2, conexión activa al cierre | 🚨 BLOQUEADO |
| `gdfiiiigddddd` | 2025-09-20 (posterior) | <BROMA_IP> | Evasión #3 (post-cierre) | 🚨 BLOQUEADO |
| `fgkfkydkcdgi` | 2025-09-20 (posterior) | <BROMA_IP> | Evasión #4 (post-cierre) | 🚨 BLOQUEADO |

#### **Caso Especial: gaelsin**
- **IP**: <BROMA_IP> (misma del atacante)
- **Comportamiento**: Predijo acciones del atacante ("va a hackear el juego yo creo")
- **Estado**: ⚠️ **REQUIERE INVESTIGACIÓN**
- **Relación**: Posible conocimiento previo del atacante

#### **Medidas Implementadas**
- ✅ IP <BROMA_IP> bloqueada permanentemente
- ✅ Todas las cuentas asociadas bloqueadas
- ✅ Servidor detenido preventivamente
- ✅ Documentación forense completa
- ⚠️ Investigación de usuario `gaelsin` pendiente

### Historial de Limpieza

**Fecha**: 05 de septiembre de 2025
**Acción**: Limpieza masiva de usuarios de prueba

**Usuarios eliminados (13 usuarios de prueba)**:
- `creative`
- `creative11`
- `gabo111`
- `gabo2121`
- `gabo2121654`
- `gabo2121iuh`
- `gabo32`
- `gabo44`
- `gabo5`
- `gabo55`
- `gabo61`
- `gabox`
- `pepelomo2`

### Información Técnica

**Base de datos**: SQLite (`server/worlds/world/auth.sqlite`)  
**Ubicación en contenedor**: `/config/.minetest/worlds/world/auth.sqlite`  
**Método de consulta**:
```bash
docker-compose exec -T luanti-server sqlite3 /config/.minetest/worlds/world/auth.sqlite 'SELECT name FROM auth;'
```

### Privilegios Administrativos

**Usuario con privilegios de admin**: `gabo`  
Para otorgar privilegios administrativos a otros usuarios, consultar la sección "Admin Privilege Management" en `CLAUDE.md`.

## 📊 Estadísticas de Registro por IP

### IPs Conocidas
| IP | Usuarios Registrados | Estado | Notas |
|----|---------------------|--------|-------|
| `<ADMIN_IP>` | `gabo` | ✅ Confiable | Admin principal |
| `<BROMA_IP>` | `gaelsin`, `HAKER`, `gdfgd`, `gdfgddddd`, `gdfiiiigddddd`, `fgkfkydkcdgi` | 🚨 **BLOQUEADA** | Incidente de seguridad |
| `[Otras IPs]` | `pepelomo`, `veight`, `gael`, `Gapi`, `gabotest`, `gabotest2` | ✅ Sin información | IPs no rastreadas en logs actuales |

### Análisis de Actividad Semanal (13-20 Sep 2025)
- **Nuevos registros**: 9 usuarios
- **Registros legítimos**: 4 usuarios (gael, Gapi, gabotest, gabotest2)
- **Registros maliciosos**: 5 usuarios (todos desde IP <BROMA_IP>)
- **Casos especiales**: 1 usuario (gaelsin - requiere investigación)

## 🔧 Acciones Realizadas (22-09-2025)

### Limpieza de Seguridad Completada
- ✅ **Usuarios maliciosos eliminados**: 8 cuentas atacantes removidas de la base de datos
- ✅ **Privilegios de veight restringidos**: Removidos 10 privilegios administrativos peligrosos
- ✅ **Total de usuarios activos**: Reducido de 13 a 5 usuarios legítimos
- ✅ **Servidor reiniciado**: Cambios de privilegios aplicados

### Privilegios Removidos de veight
Privilegios administrativos peligrosos eliminados:
- `server` - Control total del servidor
- `ban` / `kick` - Expulsión de jugadores
- `privs` - Gestión de privilegios de otros usuarios
- `password` - Cambio de contraseñas
- `rollback` / `protection_bypass` - Bypass de protecciones
- `maphack` - Visión completa del mapa
- `announce` - Mensajes de servidor
- `weather_manager` - Control del clima
- `mute` - Silenciar jugadores

---
*Última actualización: 22 de septiembre de 2025*
*Servidor: luanti.gabrielpantoja.cl:30000*
*Estado: ✅ ACTIVO - Seguridad reforzada*