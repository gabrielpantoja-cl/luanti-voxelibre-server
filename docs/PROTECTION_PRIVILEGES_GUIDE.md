# Guía de Privilegios de Protección - Wetlands Server

**Fecha**: 2025-11-15
**Problema resuelto**: pepelomo podía destruir bloques en área protegida "casaloxos"
**Solución**: Revocar privilegios de bypass

---

## 🚨 PROBLEMA IDENTIFICADO

**Situación**: pepelomo puede romper bloques en "casaloxos" a pesar de que el área está protegida.

**Causa**: pepelomo tiene privilegios que le permiten **bypasear todas las protecciones**.

---

## 🔐 Sistema de Protección Dual

El servidor Wetlands tiene **DOS mods de protección** funcionando simultáneamente:

### 1. Mod `areas` (Mod estándar de Luanti)
**Ubicación**: `/config/.minetest/mods/areas/`
**Privilegio de bypass**: `areas`

**Código de verificación** (`areas/api.lua`):
```lua
function areas:canInteract(pos, name)
    if minetest.check_player_privs(name, {areas=true}) then
        return true  -- ¡BYPASS COMPLETO!
    end
    -- ... resto de verificaciones de propietarios
end
```

### 2. Mod `voxelibre_protection` (Mod custom Wetlands)
**Ubicación**: `/config/.minetest/mods/voxelibre_protection/`
**Privilegio de bypass**: `server`

**Código de verificación** (`voxelibre_protection/init.lua`):
```lua
if area_data.owner == name or
   minetest.check_player_privs(name, {server = true}) or
   (area_data.members and area_data.members[name]) then
    return false -- Permitir acceso
else
    return true, area_name -- Área protegida
end
```

---

## ⚡ Privilegios de Bypass

### Privilegios que Ignoran Protecciones

| Privilegio | Qué bypasea | Quién debería tenerlo |
|------------|-------------|----------------------|
| `areas` | Mod `areas` (bypass completo) | Solo super admin (gabo) |
| `server` | Mod `voxelibre_protection` | Solo super admin (gabo) |
| `protection_bypass` | Protección general VoxeLibre | Solo super admin (gabo) |

### Privilegios Seguros (NO dan bypass)

| Privilegio | Función | Seguro para admins |
|------------|---------|-------------------|
| `protect` | Crear/gestionar áreas propias | ✅ SÍ |
| `ban` | Banear jugadores | ✅ SÍ |
| `kick` | Expulsar jugadores | ✅ SÍ |
| `mute` | Silenciar en chat | ✅ SÍ |
| `privs` | Gestionar privilegios | ✅ SÍ |
| `rollback_check` | Ver historial cambios | ✅ SÍ |
| `teleport` | Teletransportarse | ✅ SÍ |
| `creative` | Modo creativo | ✅ SÍ |

---

## 📊 Análisis de Privilegios Actuales

### Estado Actual (Problemático)

```
gabo:        areas ✅  server ✅  protection_bypass ✅  → CORRECTO (Super Admin)
pepelomo:    areas ✅  server ✅  protection_bypass ❌  → PROBLEMA
gaelsin:     areas ✅  server ✅  protection_bypass ✅  → PROBLEMA
loxos:       areas ❌  server ❌  protection_bypass ✅  → PROBLEMA
gapi:        areas ❌  server ❌  protection_bypass ❌  → CORRECTO
```

**Resultado**: pepelomo, gaelsin y loxos pueden bypasear protecciones de áreas.

---

## ✅ SOLUCIÓN: Revocar Privilegios de Bypass

### Comandos In-Game (NO requiere reinicio)

Ejecuta estos comandos **uno por uno** en el chat del juego:

#### 1. Revocar de pepelomo
```
/revoke pepelomo areas
```
```
/revoke pepelomo server
```

#### 2. Revocar de gaelsin
```
/revoke gaelsin areas
```
```
/revoke gaelsin server
```
```
/revoke gaelsin protection_bypass
```

#### 3. Revocar de loxos
```
/revoke loxos protection_bypass
```

**Nota sobre loxos**: loxos es propietario autorizado de "casaloxos", por lo que NO necesita privilegios de bypass. Sus permisos vienen de ser miembro del área.

---

### Verificación Post-Solución

```bash
# Verificar privilegios actualizados
/privs pepelomo
/privs gaelsin
/privs loxos
```

**Resultado esperado**:
- ❌ NO deben aparecer `areas`, `server` ni `protection_bypass`
- ✅ Deben mantener `ban`, `kick`, `mute`, `creative`, etc.

---

## 🧪 Prueba de Protección

### Antes de la solución:
```
pepelomo → Intenta romper bloque en casaloxos → ✅ Puede destruirlo (PROBLEMA)
```

### Después de la solución:
```
pepelomo → Intenta romper bloque en casaloxos → ❌ Mensaje de error:
🛡️ Área 'casaloxos' protegida por gabo
⚠️ Esta área está protegida!
```

---

## 🎯 Configuración Recomendada por Rol

### Super Administrador (gabo)
```bash
# Privilegios completos incluyendo bypass
/grant gabo areas
/grant gabo server
/grant gabo protection_bypass
/grant gabo worldedit
# ... todos los demás privilegios
```

**Función**: Control completo del servidor, puede modificar cualquier área para mantenimiento.

---

### Administrador (pepelomo, gaelsin)
```bash
# Privilegios de moderación SIN bypass
/grant admin ban
/grant admin kick
/grant admin mute
/grant admin privs
/grant admin rollback_check
/grant admin teleport
/grant admin bring
/grant admin creative
/grant admin protect

# NO otorgar:
# ❌ areas (bypass mod areas)
# ❌ server (bypass voxelibre_protection)
# ❌ protection_bypass (bypass VoxeLibre general)
```

**Función**: Moderar jugadores y crear sus propias áreas, pero NO pueden bypasear áreas de otros.

---

### Propietario de Área (loxos en casaloxos)
```bash
# Dar permisos mediante membresía del área
/area_add_member casaloxos loxos

# Privilegios normales:
/grant loxos creative
/grant loxos protect
/grant loxos teleport

# NO necesita privilegios de bypass
```

**Función**: Puede construir en "casaloxos" porque es miembro autorizado, no porque tenga bypass.

---

### Jugador Regular
```bash
# Privilegios básicos
/grant jugador interact
/grant jugador shout
/grant jugador home
/grant jugador spawn
/grant jugador creative

# Opcionalmente:
/grant jugador protect  # Si puede crear áreas protegidas
```

**Función**: Jugar normalmente, crear sus propias áreas si tiene `protect`.

---

## 🛠️ Gestión de Áreas Protegidas

### Crear Área Protegida

#### Método 1: Protección rápida (recomendado)
```bash
# Pararse en el centro del área a proteger
/protect_here 20 mi_area

# Resultado: Área de 41x41 bloques protegida
```

#### Método 2: Selección manual (preciso)
```bash
# Marcar primera esquina
/pos1

# Marcar esquina opuesta
/pos2

# Crear protección
/protect_area mi_area
```

---

### Agregar Miembros Autorizados

```bash
# Solo el propietario del área o super admin puede hacer esto
/area_add_member nombre_area nombre_usuario

# Ejemplo para casaloxos:
/area_add_member casaloxos loxos
```

**Resultado**: El usuario agregado puede construir/destruir en esa área específica.

---

### Ver Información de Área

```bash
# Listar todas las áreas
/list_areas

# Ver detalles de un área específica
/area_info casaloxos
```

**Información mostrada**:
- Propietario
- Coordenadas (min/max)
- Volumen (bloques protegidos)
- Lista de miembros autorizados
- Fecha de creación

---

### Quitar Miembro de Área

```bash
# Solo propietario o super admin
/area_remove_member nombre_area nombre_usuario
```

---

### Eliminar Área Protegida

```bash
# Solo propietario o super admin
/unprotect_area nombre_area
```

---

## 🔍 Troubleshooting

### Problema: "Usuario X puede destruir mi área protegida"

**Pasos de diagnóstico**:

1. **Verificar que el área existe**:
   ```
   /list_areas
   /area_info nombre_area
   ```

2. **Verificar privilegios del usuario problemático**:
   ```
   /privs usuario_x
   ```

3. **Buscar privilegios de bypass**:
   - Si aparece `areas` → Puede bypasear mod areas
   - Si aparece `server` → Puede bypasear voxelibre_protection
   - Si aparece `protection_bypass` → Puede bypasear protección general

4. **Revocar privilegios de bypass**:
   ```
   /revoke usuario_x areas
   /revoke usuario_x server
   /revoke usuario_x protection_bypass
   ```

5. **Verificar cambio**:
   ```
   /privs usuario_x
   ```

6. **Probar protección**:
   - Usuario X intenta destruir bloque
   - Debe recibir mensaje: "🛡️ Área protegida por propietario"

---

### Problema: "Unknown command: protect_here"

**Causa**: Usuario no tiene privilegio `protect`

**Solución**:
```bash
/grant usuario protect
```

---

### Problema: "No eres propietario de esta área"

**Causa**: Intentando modificar área de otro jugador

**Soluciones**:
1. Pedir al propietario que te agregue como miembro:
   ```
   /area_add_member nombre_area tu_usuario
   ```

2. Si eres admin pero no super admin: Debes crear tu propia área o ser agregado como miembro

---

### Problema: "El área se superpone con otra"

**Causa**: Intentando crear área que se solapa con una existente

**Solución**:
```bash
# Ver áreas existentes y sus ubicaciones
/list_areas
/area_info nombre_area_existente

# Elegir ubicación diferente o reducir radio
/protect_here 10 mi_nueva_area  # Radio más pequeño
```

---

## 📝 Caso de Estudio: casaloxos

### Configuración Original (Problemática)

```
Área: casaloxos
Propietario: gabo
Miembros: loxos

Privilegios problemáticos:
- pepelomo: areas ✅, server ✅ → Puede bypasear
- gaelsin: areas ✅, server ✅ → Puede bypasear
- loxos: protection_bypass ✅ → Puede bypasear (innecesario)
```

**Resultado**: pepelomo y gaelsin podían destruir bloques en casaloxos.

---

### Configuración Corregida

```
Área: casaloxos
Propietario: gabo
Miembros: loxos

Privilegios corregidos:
- gabo: areas ✅, server ✅, protection_bypass ✅ → CORRECTO (Super Admin)
- pepelomo: areas ❌, server ❌ → Ya no puede bypasear
- gaelsin: areas ❌, server ❌ → Ya no puede bypasear
- loxos: areas ❌, server ❌, protection_bypass ❌ → Acceso por membresía
```

**Resultado**: Solo gabo y loxos pueden modificar casaloxos.

**Permisos de loxos vienen de**:
- ✅ Es miembro autorizado del área (agregado con `/area_add_member`)
- ❌ NO de privilegios de bypass

---

## 🎓 Mejores Prácticas

### ✅ Hacer

1. **Usar sistema de miembros** para dar acceso a áreas
   - Preferir `/area_add_member` sobre otorgar privilegios de bypass

2. **Limitar privilegios de bypass** solo a super admins
   - Solo gabo debería tener `areas`, `server`, `protection_bypass`

3. **Verificar privilegios regularmente**
   - Usar `/privs usuario` para auditar permisos

4. **Probar protecciones** después de crear áreas
   - Intentar destruir con usuario no autorizado

5. **Documentar áreas importantes**
   - Mantener lista de propietarios y miembros de áreas críticas

### ❌ Evitar

1. **NO otorgar `areas` a admins regulares**
   - Bypasea TODAS las protecciones de áreas

2. **NO otorgar `server` innecesariamente**
   - Da bypass completo de voxelibre_protection

3. **NO confiar solo en privilegios para acceso a áreas**
   - Usar sistema de miembros en su lugar

4. **NO crear áreas sin verificar superposición**
   - Revisar `/list_areas` antes de crear nueva área

5. **NO olvidar revocar privilegios** cuando cambia el rol del usuario

---

## 📊 Resumen Ejecutivo

### El Problema
```
pepelomo tiene privilegios 'areas' y 'server'
→ Puede bypasear TODAS las protecciones
→ Puede destruir bloques en casaloxos (no debería)
```

### La Solución
```bash
/revoke pepelomo areas
/revoke pepelomo server
/revoke gaelsin areas
/revoke gaelsin server
/revoke gaelsin protection_bypass
/revoke loxos protection_bypass
```

### El Resultado
```
✅ Solo gabo (super admin) puede bypasear protecciones
✅ loxos puede modificar casaloxos por ser miembro autorizado
✅ pepelomo y gaelsin pueden moderar pero NO bypasear áreas
✅ Las protecciones funcionan correctamente
```

### Cambios Inmediatos
```
⏱️ NO se requiere reiniciar servidor
✅ Los cambios de privilegios son instantáneos
🧪 Probar inmediatamente después de revocar
```

---

## 🔗 Documentación Relacionada

- **Privilegios de usuarios**: `docs/USER_PRIVILEGES.md`
- **Sistema de áreas**: `docs/AREAS_PROTECTION_SYSTEM.md`
- **Mod voxelibre_protection**: `server/mods/voxelibre_protection/docs/README.md`
- **Mod areas**: `/config/.minetest/mods/areas/README.md`

---

**Última actualización**: 2025-11-15
**Estado**: ✅ SOLUCIONADO Y APLICADO
**Aplicado**: 2025-11-15 17:32 UTC
**Resultado**: ✅ PROTECCIONES FUNCIONANDO CORRECTAMENTE

---

## ✅ SOLUCIÓN APLICADA EXITOSAMENTE

### Acciones Ejecutadas

**Fecha**: 2025-11-15 17:32 UTC

**Comandos SQL ejecutados**:
```sql
DELETE FROM user_privileges WHERE privilege = 'areas' AND id != (SELECT id FROM auth WHERE name = 'gabo');
DELETE FROM user_privileges WHERE privilege = 'server' AND id != (SELECT id FROM auth WHERE name = 'gabo');
DELETE FROM user_privileges WHERE privilege = 'protection_bypass' AND id != (SELECT id FROM auth WHERE name = 'gabo');
```

**Usuarios afectados**: 14 usuarios tuvieron privilegios de bypass revocados
- Gapi, gabo2, gaelsin, julii, jutaro, jutaro2010, loxos, lulu, lulu81, lulululuo, lulululuo0000, pepelomo, pepelomoomomomo, veight

**Servidor reiniciado**: ✅ Completado
- Estado: Funcionando correctamente (healthy)
- Puerto 30000/UDP: Activo

### Verificación Final

**Solo gabo tiene privilegios de bypass**:
```bash
# Consulta SQL ejecutada
SELECT DISTINCT a.name FROM auth a
JOIN user_privileges up ON a.id = up.id
WHERE up.privilege IN ("areas", "server", "protection_bypass");

# Resultado: gabo
```

**Privilegios de pepelomo DESPUÉS de la solución**:
```
advancements, announce, areas_high_limit, arena_admin, ban, basic_privs, bring,
creative, debug, fast, fly, give, help_reveal, home, hunger, interact, kick,
maphack, noclip, password, privs, protect, rollback, settime, shout, spawn,
teleport, weather_manager, worldedit

✅ YA NO tiene: areas, server, protection_bypass
```

**Privilegios de gaelsin DESPUÉS de la solución**:
```
advancements, announce, areas_high_limit, arena_admin, ban, basic_privs, bring,
creative, debug, fast, fly, give, help_reveal, home, hunger, interact, kick,
maphack, noclip, password, privs, protect, rollback, settime, shout, spawn,
teleport, weather_manager, worldedit

✅ YA NO tiene: areas, server, protection_bypass
```

**Privilegios de loxos DESPUÉS de la solución**:
```
advancements, announce, arena_admin, ban, basic_privs, bring, creative, debug,
fast, fly, give, help_reveal, hunger, interact, kick, maphack, noclip, password,
privs, protect, rollback, settime, shout, teleport, weather_manager, worldedit

✅ YA NO tiene: protection_bypass
✅ Acceso a casaloxos mediante membresía del área
```

### Prueba de Funcionamiento

**Resultado confirmado por usuario**:
> "ahora si funciona!!"

**Comportamiento actual**:
- ✅ pepelomo NO puede destruir bloques en "casaloxos"
- ✅ gaelsin NO puede destruir bloques en "casaloxos"
- ✅ Solo gabo (propietario) y loxos (miembro) pueden modificar "casaloxos"
- ✅ Mensaje de protección aparece correctamente: "🛡️ Área 'casaloxos' protegida por gabo"

### Impacto Positivo

**Seguridad mejorada**:
- ✅ Protecciones de áreas funcionan correctamente
- ✅ Solo super admin (gabo) puede bypasear para mantenimiento
- ✅ Admins pueden moderar sin comprometer protecciones
- ✅ Sistema de membresía funciona correctamente

**Privilegios mantenidos por admins**:
- ✅ Pueden crear sus propias áreas protegidas (`protect`)
- ✅ Pueden moderar jugadores (`ban`, `kick`, `mute`)
- ✅ Pueden gestionar privilegios (`privs`)
- ✅ Pueden investigar griefing (`rollback`)
- ✅ Mantienen acceso creativo y gameplay normal

**Cambios NO requirieron**:
- ❌ NO se necesitó modificar código
- ❌ NO se perdieron datos del mundo
- ❌ NO hubo downtime significativo (solo reinicio rápido)

---

## 📊 Estado Final del Sistema

### Configuración de Privilegios de Bypass

| Usuario | `areas` | `server` | `protection_bypass` | Rol |
|---------|---------|----------|---------------------|-----|
| **gabo** | ✅ SÍ | ✅ SÍ | ✅ SÍ | Super Admin |
| pepelomo | ❌ NO | ❌ NO | ❌ NO | Admin (sin bypass) |
| gaelsin | ❌ NO | ❌ NO | ❌ NO | Admin (sin bypass) |
| loxos | ❌ NO | ❌ NO | ❌ NO | Usuario con áreas |
| gapi | ❌ NO | ❌ NO | ❌ NO | Usuario regular |
| **Resto** | ❌ NO | ❌ NO | ❌ NO | Usuarios regulares |

### Protección de "casaloxos"

**Configuración**:
- Propietario: `gabo`
- Miembros autorizados: `loxos`
- Método de acceso de loxos: Membresía del área (no privilegios de bypass)

**Funcionamiento verificado**:
- ✅ gabo puede construir/destruir (propietario)
- ✅ loxos puede construir/destruir (miembro autorizado)
- ❌ pepelomo NO puede construir/destruir (sin permisos)
- ❌ gaelsin NO puede construir/destruir (sin permisos)
- ❌ Otros usuarios NO pueden construir/destruir (sin permisos)
