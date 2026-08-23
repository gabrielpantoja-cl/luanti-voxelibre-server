# Sistema de Protección de Áreas - VoxeLibre

**Fecha**: 2025-11-15
**Mod principal**: `areas` (instalado en `/config/.minetest/mods/areas/`)

## 🚨 PROBLEMA IDENTIFICADO

### Ejemplo de bypass en un área protegida

**Situación actual**:
- Área protegida: `AREA_A`
- Propietario autorizado: `PLAYER_A`
- **PROBLEMA**: `PLAYER_B` puede romper bloques sin ser propietario

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

| Rol | Privilegio `areas` | Privilegio `protection_bypass` | ¿Puede omitir la protección? |
|---------|-------------------|-------------------------------|------------------------------|
| `ADMIN_A` | SÍ | SÍ | SÍ (esperado) |
| `PLAYER_A` | NO | NO | NO |
| `PLAYER_B` | SÍ | SÍ | SÍ (configuración incorrecta) |

### Privilegios Críticos Identificados

#### 1. `areas` (Administrador de Áreas)
**Descripción**: "Can administer areas"

**Permite**:
- Crear/eliminar/modificar áreas protegidas
- Listar todas las áreas
- **¡BYPASS COMPLETO de todas las protecciones de áreas!**

Debe limitarse a `ADMIN_A`.

#### 2. `areas_high_limit` (Límite Alto de Áreas)
**Descripción**: "Can protect more, bigger areas"

**Permite**:
- Crear áreas más grandes
- Proteger más áreas simultáneamente

**No permite bypass de protección** (este privilegio es seguro)

Puede otorgarse a `PLAYER_A` o `PLAYER_B` sin habilitar bypass.

#### 3. `protection_bypass` (Bypass General de Protección)
**Descripción**: Bypass de sistema de protección general de VoxeLibre

**Permite**:
- Ignorar protecciones de spawn
- Ignorar protecciones de bloques individuales
- **Posiblemente bypass de áreas protegidas** (depende de la implementación)

Debe limitarse a `ADMIN_A`.

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

**Ubicación**: `/config/.minetest/worlds/original/areas.dat`

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
ssh <VPS_USER>@<VPS_IP>

# Entrar al contenedor
cd $PROJECT_PATH
docker compose exec luanti-server /bin/bash

# Repetir para cada cuenta afectada, sustituyendo PLAYER_A al ejecutar
sqlite3 /config/.minetest/worlds/original/auth.sqlite "DELETE FROM user_privileges WHERE id=(SELECT id FROM auth WHERE name='PLAYER_A') AND privilege IN ('areas', 'protection_bypass');"

# Salir del contenedor
exit

# IMPORTANTE: Reiniciar servidor (cuando no haya jugadores)
# docker compose restart luanti-server
```

### Opción 2: Crear Rol de "Moderador" sin Bypass

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
ssh <VPS_USER>@<VPS_IP> 'cd $PROJECT_PATH && docker compose exec -T luanti-server sqlite3 /config/.minetest/worlds/original/auth.sqlite "SELECT GROUP_CONCAT(up.privilege, \", \") FROM auth a LEFT JOIN user_privileges up ON a.id = up.id WHERE a.name = \"PLAYER_A\";"'
```

**Resultado esperado después de aplicar Opción 1**:
- `ADMIN_A`: puede mantener `areas` y `protection_bypass`
- `PLAYER_A` y `PLAYER_B`: no deben tener `areas` ni `protection_bypass`

### Prueba en el juego

1. Conectar con `PLAYER_B`
2. Intentar romper un bloque en `AREA_A`
3. **Resultado esperado**: mensaje de área protegida

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

El mod `areas` se puede configurar en `luanti-original.conf`:

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
Una cuenta no administrativa con estos privilegios puede **omitir todas las protecciones de áreas** debido a:
1. Privilegio `areas` (bypass explícito en el código)
2. Privilegio `protection_bypass` (bypass general de VoxeLibre)

### La Solución
**Remover** los privilegios `areas` y `protection_bypass` de cuentas que no sean `ADMIN_A`.

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
- **Database**: `/config/.minetest/worlds/original/auth.sqlite`
- **Areas data**: `/config/.minetest/worlds/original/areas.dat`
- **Init code**: `init.lua` (define `areas.adminPrivs = {areas=true}`)
- **Interaction code**: `interact.lua` (verifica `canInteract()`)
- **API code**: `api.lua` (lógica de verificación de permisos)

---

**Última actualización**: 2025-11-15
**Estado**: Problema identificado - Pendiente de solución
