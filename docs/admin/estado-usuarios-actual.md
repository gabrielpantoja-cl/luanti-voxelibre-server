# Estado de Usuarios - Servidor Wetlands

**Última actualización:** 2025-10-14 20:20 UTC
**Total de usuarios registrados:** 16
**Usuarios activos últimos 30 días:** 14 (87.5%)

---

## 📊 Resumen de Usuarios y Privilegios

**📈 CRECIMIENTO:** +5 nuevos usuarios desde último reporte (45% de crecimiento en 11 días)

### Usuarios con Privilegios Administrativos (2)

#### 1. **gabo** (ID: 1)
- **Último login:** 2025-10-14 19:52:56 UTC
- **Rol:** Administrador Principal
- **Privilegios (35):**
  ```
  advancements, announce, areas, ban, basic_privs, bring, creative,
  debug, fast, fly, give, help_reveal, home, hunger, interact, kick,
  maphack, mute, noclip, password, privs, protect, protection_bypass,
  rollback, rollback_check, server, settime, shout, shutdown, spawn,
  teleport, time, unban, weather_manager, worldedit
  ```
- **Capacidades especiales:**
  - Control total del servidor
  - Gestión de usuarios (ban, kick, mute)
  - Modificación de privilegios
  - Protección bypass completo
  - Worldedit y edición avanzada

#### 2. **lulululuo** (ID: 29)
- **Último login:** 2025-10-03 21:50:21 UTC
- ⚠️ **INACTIVO:** Sin conexión desde hace 11 días
- **Rol:** Usuario con privilegios de protección extendidos
- **Privilegios (6):**
  ```
  areas, areas_high_limit, fly, interact, protection_bypass, shout
  ```
- **Capacidades especiales:**
  - Protección de áreas sin límites
  - Bypass de protecciones
  - Vuelo y interacción básica

---

### Usuarios con Privilegios Creativos Avanzados (4)

#### 3. **pepelomo** (ID: 4)
- **Último login:** 2025-10-14 19:29:36 UTC (hace ~1 hora)
- **Privilegios (19):**
  ```
  advancements, areas, areas_high_limit, basic_privs, bring, creative,
  debug, fast, fly, give, help_reveal, home, hunger, interact, noclip,
  settime, shout, spawn, teleport
  ```

#### 4. **veight** (ID: 5)
- **Último login:** Nunca se ha conectado (-1)
- **Privilegios (19):**
  ```
  advancements, areas, areas_high_limit, basic_privs, bring, creative,
  debug, fast, fly, give, help_reveal, home, hunger, interact, noclip,
  settime, shout, spawn, teleport
  ```

#### 5. **gaelsin** (ID: 17)
- **Último login:** 2025-10-09 21:21:50 UTC (hace ~5 días)
- **Privilegios (17):**
  ```
  advancements, areas, areas_high_limit, basic_privs, creative, debug,
  fast, fly, give, help_reveal, home, hunger, interact, noclip, shout,
  spawn, teleport
  ```

#### 6. **Gapi** (ID: 19)
- **Último login:** 2025-10-09 20:52:35 UTC (hace ~5 días)
- **Privilegios (17):**
  ```
  advancements, areas, areas_high_limit, basic_privs, creative, debug,
  fast, fly, give, help_reveal, home, hunger, interact, noclip, shout,
  spawn, teleport
  ```

---

### Usuarios Nuevos Activos (2)

#### 7. **lulu81** (ID: 33)
- **Último login:** 2025-10-11 22:15:18 UTC (hace ~3 días)
- **Primera sesión:** 2025-10-04 13:33:32
- **Privilegios (3):**
  ```
  interact, shout, fly
  ```
- **Estado:** ✅ ACTIVO - Nuevo usuario con buena retención

#### 8. **julii** (ID: 36)
- **Último login:** 2025-10-11 13:37:01 UTC (hace ~3 días)
- **Primera sesión:** 2025-10-05 19:14:13
- **Privilegios (3):**
  ```
  interact, shout, fly
  ```
- **Estado:** ✅ ACTIVO - Nuevo usuario con buena retención

### Usuarios Básicos con Protección (5)

#### 9. **pepelomoomomomo** (ID: 27)
- **Último login:** 2025-10-03 18:23:55 UTC (hace ~11 días)

- **Privilegios (5):**
  ```
  areas, areas_high_limit, fly, interact, shout
  ```

#### 10. **lulu** (ID: 28)
- **Último login:** 2025-10-03 18:26:56 UTC (hace ~11 días)
- **Privilegios (5):**
  ```
  areas, areas_high_limit, fly, interact, shout
  ```

#### 9. **jutaro2010** (ID: 30)
- **Último login:** Nunca se ha conectado (-1)
- **Privilegios (4):**
  ```
  areas, areas_high_limit, interact, shout
  ```

#### 11. **jutaro** (ID: 31)
- **Último login:** 2025-10-03 22:43:23 UTC (hace ~11 días)
- **Privilegios (5):**
  ```
  areas, areas_high_limit, fly, interact, shout
  ```

#### 12. **lulululuo0000** (ID: 32)
- **Último login:** 2025-10-03 23:43:39 UTC (hace ~11 días)
- **Privilegios (5):**
  ```
  areas, areas_high_limit, fly, interact, shout
  ```

---

## 🛡️ Configuración de Protección de Áreas

### Privilegios de Protección Actuales

**✅ TODOS los usuarios ahora tienen privilegios de protección de áreas**

**Privilegios otorgados a todos:**
- ✅ **`areas`** - Permite crear y gestionar áreas protegidas
- ✅ **`areas_high_limit`** - Límite ampliado de áreas protegidas

### Comandos Disponibles para Usuarios

Todos los usuarios pueden usar los siguientes comandos:

```bash
/area_pos1          # Marcar primera esquina del área
/area_pos2          # Marcar segunda esquina del área
/protect <nombre>   # Proteger el área seleccionada
/list_areas         # Ver todas las áreas protegidas propias
/area_open <id>     # Abrir área para que otros puedan interactuar
/area_close <id>    # Cerrar área (solo propietario)
/add_owner <id> <nombre>  # Añadir co-propietario
/remove_owner <id> <nombre>  # Remover co-propietario
```

### Configuración por Defecto (Nuevos Usuarios)

Los nuevos usuarios que se registren automáticamente recibirán:

```
default_privs = interact,shout,creative,give,fly,fast,noclip,home,areas,areas_high_limit
```

**Configurado en:** `server/config/luanti.conf` (línea 27)

---

## 📝 Historial de Cambios

### 🔄 Actualización Masiva de Privilegios (2025-10-03)

**Fecha:** 2025-10-03 21:00 UTC
**Acción:** Otorgamiento masivo de privilegios de protección a TODOS los usuarios

**Usuarios afectados (9):**
- pepelomo (ID: 4)
- veight (ID: 5)
- gaelsin (ID: 17)
- Gapi (ID: 19)
- pepelomoomomomo (ID: 27)
- lulu (ID: 28)
- jutaro2010 (ID: 30)
- jutaro (ID: 31)
- lulululuo0000 (ID: 32)

**Privilegios añadidos:**
- `areas`
- `areas_high_limit`

**Método:** Inserción directa en base de datos SQLite (`auth.sqlite`)

**SQL ejecutado:**
```sql
INSERT OR IGNORE INTO user_privileges (id, privilege) VALUES
(4, 'areas'), (4, 'areas_high_limit'),
(5, 'areas'), (5, 'areas_high_limit'),
(17, 'areas'), (17, 'areas_high_limit'),
(19, 'areas'), (19, 'areas_high_limit'),
(27, 'areas'), (27, 'areas_high_limit'),
(28, 'areas'), (28, 'areas_high_limit'),
(30, 'areas'), (30, 'areas_high_limit'),
(31, 'areas'), (31, 'areas_high_limit'),
(32, 'areas'), (32, 'areas_high_limit');
```

**Configuración por defecto actualizada:**
```conf
# Antes:
default_privs = interact,shout,creative,give,fly,fast,noclip,home

# Ahora:
default_privs = interact,shout,creative,give,fly,fast,noclip,home,areas,areas_high_limit
```

**Resultado:**
- ✅ 100% de usuarios tienen privilegios de protección
- ✅ Nuevos usuarios automáticamente recibirán estos privilegios
- ✅ Sin necesidad de reiniciar servidor (cambios aplicados en vivo)

---

### 🚨 INCIDENTE DE SEGURIDAD (20-09-2025)

**Período del Ataque**: 20 de septiembre 2025, 19:23-19:31 UTC
**Duración**: 9 minutos, 42 segundos
**Estado del Servidor**: 🔴 **DETENIDO POR SEGURIDAD**

#### Cuentas Maliciosas Identificadas (5 usuarios)
| Usuario | IP | Actividad | Estado |
|---------|-----|-----------|--------|
| `HAKER` | <BROMA_IP> | Excavación sistemática | 🚨 BLOQUEADO |
| `gdfgd` | <BROMA_IP> | Evasión #1 | 🚨 BLOQUEADO |
| `gdfgddddd` | <BROMA_IP> | Evasión #2 | 🚨 BLOQUEADO |
| `gdfiiiigddddd` | <BROMA_IP> | Evasión #3 | 🚨 BLOQUEADO |
| `fgkfkydkcdgi` | <BROMA_IP> | Evasión #4 | 🚨 BLOQUEADO |

#### Medidas Implementadas
- ✅ IP <BROMA_IP> bloqueada permanentemente
- ✅ Todas las cuentas asociadas eliminadas
- ✅ Servidor detenido preventivamente
- ✅ Documentación forense completa

---

### 🔧 Limpieza de Usuarios de Prueba (05-09-2025)

**Usuarios eliminados (13):**
`creative`, `creative11`, `gabo111`, `gabo2121`, `gabo2121654`, `gabo2121iuh`, `gabo32`, `gabo44`, `gabo5`, `gabo55`, `gabo61`, `gabox`, `pepelomo2`

---

### 🔐 Restricción de Privilegios Administrativos (22-27-09-2025)

#### Restricción de `veight` (22-09-2025)
**Privilegios removidos (10):**
- `server`, `ban`, `kick`, `privs`, `password`, `rollback`, `protection_bypass`, `maphack`, `announce`, `weather_manager`, `mute`

#### Restricción de `pepelomo` (27-09-2025)
**Privilegios removidos (14):**
- `server`, `privs`, `ban`, `kick`, `mute`, `unban`, `password`, `protection_bypass`, `rollback`, `rollback_check`, `shutdown`, `announce`, `maphack`, `weather_manager`

**Motivo:** Mantener solo a `gabo` como administrador único del servidor

---

## 🔍 Información Técnica

### Base de Datos de Autenticación

**Ubicación en host:** `server/worlds/world/auth.sqlite`
**Ubicación en contenedor:** `/config/.minetest/worlds/world/auth.sqlite`

### Estructura de Tablas

#### Tabla `auth`
```sql
CREATE TABLE `auth` (
  `id` INTEGER PRIMARY KEY AUTOINCREMENT,
  `name` TEXT UNIQUE NOT NULL,
  `password` TEXT NOT NULL,
  `last_login` INTEGER NOT NULL DEFAULT 0
);
```

#### Tabla `user_privileges`
```sql
CREATE TABLE `user_privileges` (
  `id` INTEGER,
  `privilege` TEXT,
  PRIMARY KEY (id, privilege),
  CONSTRAINT fk_id FOREIGN KEY (id) REFERENCES auth (id) ON DELETE CASCADE
);
```

---

## 📋 Comandos de Administración

### Otorgar Privilegios vía Chat (Recomendado)

**Sin reinicio del servidor:**
```bash
/grant <usuario> areas
/grant <usuario> areas_high_limit
/grant <usuario> areas,areas_high_limit
```

**Verificar privilegios:**
```bash
/privs <usuario>
```

### Otorgar Privilegios vía SSH + SQLite

```bash
# Conectar al VPS
ssh gabriel@<VPS_IP>

# Ver ID del usuario
cd /home/gabriel/Vegan-Wetlands
docker compose exec -T luanti-server sqlite3 /config/.minetest/worlds/world/auth.sqlite "SELECT id FROM auth WHERE name='usuario';"

# Otorgar privilegio
docker compose exec -T luanti-server sqlite3 /config/.minetest/worlds/world/auth.sqlite "INSERT OR IGNORE INTO user_privileges (id, privilege) VALUES (<ID>, 'areas');"

# Reiniciar servidor (SOLO si es necesario)
docker compose restart luanti-server
```

### Listar Todos los Usuarios

```bash
ssh gabriel@<VPS_IP> "cd /home/gabriel/Vegan-Wetlands && docker compose exec -T luanti-server sqlite3 /config/.minetest/worlds/world/auth.sqlite 'SELECT id, name, last_login FROM auth ORDER BY id;'"
```

### Ver Privilegios de Todos los Usuarios

```bash
ssh gabriel@<VPS_IP> "cd /home/gabriel/Vegan-Wetlands && docker compose exec -T luanti-server sqlite3 /config/.minetest/worlds/world/auth.sqlite 'SELECT auth.id, auth.name, GROUP_CONCAT(user_privileges.privilege, \",\") FROM auth LEFT JOIN user_privileges ON auth.id = user_privileges.id GROUP BY auth.id ORDER BY auth.id;'"
```

---

## 📊 Estadísticas del Servidor

### Actividad de Usuarios
- **Usuarios activos (última semana):** 7/11 (63.6%)
- **Usuarios activos (último mes):** 9/11 (81.8%)
- **Usuarios nunca conectados:** 2/11 (18.2%)
  - veight (ID: 5)
  - jutaro2010 (ID: 30)

### Distribución de Privilegios
- **Con privilegios administrativos completos:** 1/11 (9.1%) - gabo
- **Con protection_bypass:** 2/11 (18.2%) - gabo, lulululuo
- **Con privilegios creativos avanzados:** 4/11 (36.4%)
- **Con privilegios de protección (areas):** 11/11 (100%) ✅

### Última Conexión por Usuario
1. **lulululuo0000** - 2025-10-03 20:30:39 UTC (más reciente)
2. **gabo** - 2025-10-03 20:30:25 UTC
3. **pepelomo** - 2025-10-03 20:29:47 UTC
4. **lulululuo** - 2025-10-03 18:57:01 UTC
5. **jutaro** - 2025-10-03 16:03:23 UTC
6. **lulu** - 2025-10-03 14:39:56 UTC
7. **pepelomoomomomo** - 2025-10-03 14:36:55 UTC
8. **gaelsin** - 2025-10-02 18:58:07 UTC
9. **Gapi** - 2025-09-21 06:02:27 UTC
10. **veight** - Nunca
11. **jutaro2010** - Nunca

---

## ⚠️ Notas de Seguridad

### Privilegios Sensibles

**`protection_bypass`** - Solo poseen:
- gabo (admin principal)
- lulululuo (usuario especial)

⚠️ **Este privilegio permite ignorar todas las protecciones. Usar con extrema precaución.**

### IPs Bloqueadas

- **<BROMA_IP>** - Bloqueo permanente por incidente del 20-09-2025

---

## 🎯 Próximos Pasos Recomendados

1. **✅ COMPLETADO: Protección universal**
   - Todos los usuarios pueden proteger sus casas y construcciones
   - Nuevos usuarios reciben privilegios automáticamente

2. **📝 Tutorial en el juego**
   - Crear comando `/ayuda_proteccion` con guía paso a paso
   - Añadir carteles en el spawn con instrucciones

3. **📊 Monitoreo de áreas**
   - Revisar periódicamente qué áreas están siendo protegidas
   - Verificar conflictos entre usuarios

4. **🔍 Auditoría mensual**
   - Revisar usuarios inactivos (>30 días)
   - Limpiar cuentas sin uso prolongado (>90 días)

5. **🛡️ Establecer límites de protección**
   - Definir número máximo de áreas por usuario
   - Establecer tamaño máximo de áreas protegidas

---

**Documento generado automáticamente**
**Fuente de datos:** Base de datos SQLite del servidor Luanti
**Servidor:** luanti.gabrielpantoja.cl:30000
**Estado:** ✅ ACTIVO - Sistema de protección habilitado para todos
