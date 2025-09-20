# Usuarios Registrados - Servidor Vegan Wetlands

## Estado Actual (20-09-2025)

### Usuarios Activos
Total de usuarios registrados: **13 usuarios**

| Usuario | Identificación | Rol | IP Registrada | Estado |
|---------|----------------|-----|---------------|--------|
| `gabo` | Admin Principal | Administrador | <ADMIN_IP> | ✅ Activo |
| `pepelomo` | Luciano | Jugador | - | ✅ Activo |
| `veight` | Karu | Jugador | - | ✅ Activo |
| `gaelsin` | Gael (Sobrino) | Jugador | <BROMA_IP> | ⚠️ Misma IP atacante |
| `gael` | Gael | Jugador | - | ✅ Activo |
| `Gapi` | Gapi | Jugador | - | ✅ Activo |
| `gabotest` | Cuenta de Prueba | Test | - | 🔄 Pendiente limpieza |
| `gabotest2` | Cuenta de Prueba | Test | - | 🔄 Pendiente limpieza |
| `HAKER` | **ATACANTE** | **BLOQUEADO** | **<BROMA_IP>** | 🚨 **BLOQUEADO** |
| `gdfgd` | **ATACANTE** | **BLOQUEADO** | **<BROMA_IP>** | 🚨 **BLOQUEADO** |
| `gdfgddddd` | **ATACANTE** | **BLOQUEADO** | **<BROMA_IP>** | 🚨 **BLOQUEADO** |
| `gdfiiiigddddd` | **ATACANTE** | **BLOQUEADO** | **<BROMA_IP>** | 🚨 **BLOQUEADO** |
| `fgkfkydkcdgi` | **ATACANTE** | **BLOQUEADO** | **<BROMA_IP>** | 🚨 **BLOQUEADO** |

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

---
*Última actualización: 20 de septiembre de 2025*
*Servidor: luanti.gabrielpantoja.cl:30000*
*Estado: 🔴 DETENIDO POR SEGURIDAD - Ver documentos de incidente*