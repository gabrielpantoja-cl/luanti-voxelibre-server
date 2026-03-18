# Sistema de Protección de Áreas - VoxeLibre

**Fecha**: 2025-11-15
**Mod principal**: `areas` (instalado en `/config/.minetest/mods/areas/`)

## 🚨 PROBLEMA IDENTIFICADO

### El Issue con "casaloxos"

**Situación actual**:
- Área protegida: `casaloxos`
- Propietarios autorizados: `gabo` y `loxos`
- **PROBLEMA**: `pepelomo` puede romper bloques en esta área protegida

### Causa Raíz

El mod `areas` tiene un sistema de **bypass de protección** basado en privilegios:

```lua
function areas:canInteract(pos, name)
    if minetest.check_player_privs(name, self.adminPrivs) then
        return true  -- ¡BYPASS COMPLETO!
    end
    -- ... resto de la lógica de verificación de propietarios
end
```

Donde `self.adminPrivs = {areas=true}`

**Esto significa: cualquier usuario con el privilegio "areas" puede ignorar TODAS las protecciones de áreas.**

---

## Análisis de Privilegios Problemáticos

### Usuarios con Privilegios de Bypass

| Usuario | Privilegio `areas` | Privilegio `protection_bypass` | ¿Puede bypasear "casaloxos"? |
|---------|-------------------|-------------------------------|------------------------------|
| **gabo** | ✅ SÍ | ✅ SÍ | ✅ SÍ (Super Admin - esperado) |
| **pepelomo** | ✅ SÍ | ✅ SÍ | ✅ SÍ (PROBLEMA) |
| **gaelsin** | ✅ SÍ | ✅ SÍ | ✅ SÍ (PROBLEMA) |
| **loxos** | ❌ NO | ✅ SÍ | ⚠️ SÍ (por `protection_bypass`) |
| **gapi** | ❌ NO | ❌ NO | ❌ NO |

### Privilegios Críticos Identificados

#### 1. `areas` (Administrador de Áreas)
**Descripción**: "Can administer areas"

**Permite**:
- Crear/eliminar/modificar áreas protegidas
- Listar todas las áreas
- **¡BYPASS COMPLETO de todas las protecciones de áreas!**

**Usuarios que lo tienen**:
- `gabo` ✅ (Super Admin - correcto)
- `pepelomo` ❌ (No debería tenerlo)
- `gaelsin` ❌ (No debería tenerlo)

#### 2. `areas_high_limit` (Límite Alto de Áreas)
**Descripción**: "Can protect more, bigger areas"

**Permite**:
- Crear áreas más grandes
- Proteger más áreas simultáneamente

**No permite bypass de protección** (este privilegio es seguro)

**Usuarios que lo tienen**:
- `pepelomo` ✅
- `gaelsin` ✅

#### 3. `protection_bypass` (Bypass General de Protección)
**Descripción**: Bypass de sistema de protección general de VoxeLibre

**Permite**:
- Ignorar protecciones de spawn
- Ignorar protecciones de bloques individuales
- **Posiblemente bypass de áreas protegidas** (depende de la implementación)

**Usuarios que lo tienen**:
- `gabo` ✅ (Super Admin - correcto)
- `pepelomo` ❌ (Peligroso)
- `gaelsin` ❌ (Peligroso)
- `loxos` ❌ (Peligroso)

---

## Cómo Funciona el Mod `areas`

### Estructura de Verificación

1. **Verificación de privilegio admin**:
   ```lua
   if minetest.check_player_privs(name, {areas=true}) then
       return true  -- Acceso total
   end
   ```

2. **Verificación de propietario/permisos**:
   ```lua
   for _, area in pairs(areas_list) do
       if area.owner == name or area.open then
           return true
       end
       -- ... verificación de facciones
   end
   ```

3. **Denegación**:
   ```lua
   return false  -- Protegido
   ```

### Archivo de Datos

**Ubicación**: `/config/.minetest/worlds/world/areas.dat`

**Formato**: JSON o Serializado Lua

**Contiene**:
- ID de área
- Coordenadas (pos1, pos2)
- Propietario (owner)
- Nombre del área
- Permisos especiales (open, faction_open)

### Comandos Disponibles (con privilegio `areas`)

```
/list_areas               - Listar todas las áreas
/areas_cleanup            - Limpiar áreas huérfanas
/area_open <ID>           - Abrir área para todos
/recreate_areas           - Recrear caché de áreas
/remove_area <ID>         - Eliminar área
/change_owner <ID> <name> - Cambiar propietario
```

---

## 🛠️ SOLUCIÓN RECOMENDADA

### Opción 1: Remover Privilegios Peligrosos (RECOMENDADO)

Remover los privilegios que permiten bypass a usuarios que no deberían tenerlos:

```bash
# Conectar al servidor
ssh gabriel@<IP_VPS_ANTERIOR>

# Entrar al contenedor
cd /home/gabriel/luanti-voxelibre-server
docker compose exec luanti-server /bin/bash

# Remover privilegio 'areas' de pepelomo
sqlite3 /config/.minetest/worlds/world/auth.sqlite "DELETE FROM user_privileges WHERE id=(SELECT id FROM auth WHERE name='pepelomo') AND privilege='areas';"

# Remover privilegio 'areas' de gaelsin
sqlite3 /config/.minetest/worlds/world/auth.sqlite "DELETE FROM user_privileges WHERE id=(SELECT id FROM auth WHERE name='gaelsin') AND privilege='areas';"

# Remover 'protection_bypass' de pepelomo
sqlite3 /config/.minetest/worlds/world/auth.sqlite "DELETE FROM user_privileges WHERE id=(SELECT id FROM auth WHERE name='pepelomo') AND privilege='protection_bypass';"

# Remover 'protection_bypass' de gaelsin
sqlite3 /config/.minetest/worlds/world/auth.sqlite "DELETE FROM user_privileges WHERE id=(SELECT id FROM auth WHERE name='gaelsin') AND privilege='protection_bypass';"

# Remover 'protection_bypass' de loxos
sqlite3 /config/.minetest/worlds/world/auth.sqlite "DELETE FROM user_privileges WHERE id=(SELECT id FROM auth WHERE name='loxos') AND privilege='protection_bypass';"

# Salir del contenedor
exit

# IMPORTANTE: Reiniciar servidor (cuando no haya jugadores)
# docker compose restart luanti-server
```

### Opción 2: Mantener Privilegios y Confiar en los Admins

Si confías en pepelomo y gaelsin para no abusar de sus privilegios, puedes mantener la configuración actual. Sin embargo, ten en cuenta que **PUEDEN** modificar áreas protegidas.

### Opción 3: Crear Rol de "Moderador" sin Bypass

Definir un nuevo conjunto de privilegios para moderadores que **NO incluya**:
- `areas`
- `protection_bypass`
- `shutdown`

Pero **SÍ incluya**:
- `kick`, `mute`, `ban` (moderación)
- `rollback_check` (investigación)
- `teleport`, `bring` (gestión de jugadores)

---

## Verificación Post-Solución

### Comando para verificar privilegios actualizados

```bash
ssh gabriel@<IP_VPS_ANTERIOR> 'cd /home/gabriel/luanti-voxelibre-server && docker compose exec -T luanti-server sqlite3 /config/.minetest/worlds/world/auth.sqlite "SELECT a.name, GROUP_CONCAT(up.privilege, \", \") FROM auth a LEFT JOIN user_privileges up ON a.id = up.id WHERE a.name IN (\"gabo\", \"pepelomo\", \"gaelsin\", \"loxos\") GROUP BY a.name;"'
```

**Resultado esperado después de aplicar Opción 1**:
- `gabo`: Debe mantener `areas` y `protection_bypass` (Super Admin)
- `pepelomo`: No debe tener `areas` ni `protection_bypass`
- `gaelsin`: No debe tener `areas` ni `protection_bypass`
- `loxos`: No debe tener `protection_bypass` (pero puede ser propietario de "casaloxos")

### Prueba en el juego

1. Conectar con usuario `pepelomo`
2. Intentar romper un bloque en área "casaloxos"
3. **Resultado esperado**: Mensaje de error "casaloxos is protected by gabo, loxos"

---

## Comandos Útiles para Gestión de Áreas

### Ver todas las áreas (in-game, requiere privilegio `areas`)

```
/list_areas
```

### Crear nueva área protegida

```
// Seleccionar primera posición
/area_pos1

// Seleccionar segunda posición
/area_pos2

// Crear área con nombre
/protect <nombre_area>
```

### Agregar usuario a área existente

```
/add_owner <ID_area> <nombre_usuario>
```

### Ver información de área específica

```
/area_info <ID_area>
```

### Abrir área para todos

```
/area_open <ID_area>
```

---

## Configuración del Mod (settingtypes.txt)

El mod `areas` se puede configurar en `luanti.conf`:

```ini
# Tamaño máximo de área para usuarios normales
areas.self_protection_max_size (Maximum area size) float 32.0 0.0

# Número máximo de áreas por usuario normal
areas.self_protection_max_areas (Maximum number of areas) int 4 1

# Límites más altos para usuarios con 'areas_high_limit'
areas.self_protection_max_size_high (Maximum area size for players with high limit) float 128.0 0.0
areas.self_protection_max_areas_high (Maximum number of areas for players with high limit) int 32 1

# Privilegio requerido para auto-protección
areas.self_protection_privilege (Self protection privilege) string protect
```

---

## Resumen Ejecutivo

### El Problema
pepelomo y gaelsin tienen privilegios que les permiten **bypasear todas las protecciones de áreas**, incluyendo "casaloxos", debido a:
1. Privilegio `areas` (bypass explícito en el código)
2. Privilegio `protection_bypass` (bypass general de VoxeLibre)

### La Solución
**Remover** los privilegios `areas` y `protection_bypass` de usuarios que no sean Super Admins (solo gabo debería tenerlos).

### El Impacto
- ✅ Las áreas protegidas funcionarán correctamente
- ✅ Solo los propietarios autorizados pueden modificar sus áreas
- ✅ Los admins aún pueden moderar (kick, ban, mute)
- ❌ Los admins no podrán crear/gestionar áreas protegidas (eso es lo que queremos)

### Próximos Pasos
1. Decidir si aplicar Opción 1 (remover privilegios)
2. Ejecutar comandos SQL para actualizar privilegios
3. Reiniciar servidor cuando no haya jugadores
4. Verificar funcionamiento con prueba en el juego
5. Actualizar documentación `USER_PRIVILEGES.md`

---

## Referencias Técnicas

- **Mod source**: `/config/.minetest/mods/areas/`
- **Database**: `/config/.minetest/worlds/world/auth.sqlite`
- **Areas data**: `/config/.minetest/worlds/world/areas.dat`
- **Init code**: `init.lua` (define `areas.adminPrivs = {areas=true}`)
- **Interaction code**: `interact.lua` (verifica `canInteract()`)
- **API code**: `api.lua` (lógica de verificación de permisos)

---

**Última actualización**: 2025-11-15
**Estado**: Problema identificado - Pendiente de solución
