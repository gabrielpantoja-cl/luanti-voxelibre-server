# VoxeLibre Protection System v1.0.0

Sistema de protección de áreas compatible con VoxeLibre para el servidor Wetlands. Permite proteger construcciones y áreas específicas con almacenamiento persistente y gestión avanzada de permisos.

## Características Principales

### 🛡️ Protección Robusta
- **Almacenamiento persistente**: Las áreas protegidas se guardan automáticamente
- **Sistema de miembros**: Permite agregar usuarios autorizados a las áreas
- **Detección de superposición**: Previene conflictos entre áreas protegidas
- **Efectos visuales**: Partículas cuando se intenta acceder a área protegida

### 🎮 Compatible con Wetlands
- **Integración VoxeLibre**: Compatible con todas las APIs de VoxeLibre
- **Privilegios personalizados**: Sistema de permisos `protect` independiente
- **Mensajes en español**: Interfaz completamente traducida
- **Sin conflictos**: No interfiere con otros sistemas de protección

## Comandos Disponibles

### Comandos Básicos (Requiere privilegio `protect`)

#### Selección de Área Manual
```
/pos1              # Marca la primera esquina del área (posición actual)
/pos2              # Marca la segunda esquina del área (posición actual)
/protect_area <nombre>  # Crea área protegida entre pos1 y pos2
```

#### Protección Rápida (Recomendado)
```
/protect_here <radio> <nombre>  # Protege área alrededor del jugador
```
Ejemplos:
- `/protect_here 20 mi_casa` - Protege 20 bloques alrededor
- `/protect_here 50 spawn_principal` - Protege 50 bloques para el spawn

### Gestión de Áreas
```
/list_areas                        # Lista todas las áreas protegidas
/unprotect_area <nombre>           # Elimina protección (solo propietario)
/area_info <nombre>                # Información detallada del área
```

### Gestión de Miembros
```
/area_add_member <area> <jugador>     # Añade miembro al área
/area_remove_member <area> <jugador>  # Quita miembro del área
```

## Ejemplos de Uso

### Proteger Spawn del Servidor
```bash
# 1. Ir al spawn
/spawn

# 2. Crear protección de 50 bloques alrededor
/protect_here 50 spawn_principal

# 3. Verificar que se creó
/list_areas
```

### Proteger Casa Personal
```bash
# 1. Ir a una esquina de tu casa
/pos1

# 2. Ir a la esquina opuesta
/pos2

# 3. Crear la protección
/protect_area mi_casa

# 4. Añadir un amigo
/area_add_member mi_casa amigo123
```

### Protección Rápida de Construcción
```bash
# Parado en el centro de tu construcción
/protect_here 15 castillo_medieval
```

## Configuración Avanzada

### Variables de Configuración
Añadir a `luanti.conf`:
```ini
# Radio máximo permitido para protección
voxelibre_protection_max_radius = 50

# Altura por defecto para protect_here
voxelibre_protection_default_height = 30

# Permitir superposición de áreas (no recomendado)
voxelibre_protection_allow_overlap = false

# Efectos de partículas al violar protección
voxelibre_protection_enable_particles = true
```

## Privilegios

### Privilegio `protect`
- **Descripción**: Permite crear y gestionar protección de áreas
- **Por defecto**: Solo administradores
- **Otorgar**: `/grant <jugador> protect`

### Privilegio `server`
- **Descripción**: Acceso administrativo completo
- **Funciones**: Puede acceder a cualquier área protegida
- **Gestión**: Puede eliminar cualquier área protegida

## API para Desarrolladores

### Funciones Públicas
```lua
-- Obtener todas las áreas protegidas
local areas = voxelibre_protection.get_areas()

-- Verificar si una posición está protegida
local protected, area_name = voxelibre_protection.is_protected(pos, player_name)

-- Crear área programáticamente
local success, message = voxelibre_protection.add_area(name, min_pos, max_pos, owner)
```

## Troubleshooting

### Comandos No Funcionan
- Verificar que el mod esté habilitado: `load_mod_voxelibre_protection = true`
- Verificar privilegios del usuario: `/privs <jugador>`
- Reiniciar servidor después de cambios de configuración

### Áreas No Se Guardan
- Verificar permisos de escritura en el directorio del mundo
- Comprobar logs del servidor para errores de serialización
- Las áreas se guardan automáticamente cada 5 minutos

### Conflictos con Otros Mods
- El mod es compatible con `protector` y sistemas nativos de VoxeLibre
- No usar junto con `areas` mod (incompatible con VoxeLibre)
- Si hay conflictos, verificar orden de carga en `mod.conf`

## Información Técnica

### Almacenamiento
- **Método**: `minetest.get_mod_storage()` para persistencia
- **Formato**: Serialización nativa de Luanti
- **Ubicación**: `worlds/world/mod_storage/voxelibre_protection`
- **Backup**: Guardado automático cada 5 minutos y al cerrar servidor

### Performance
- **Optimizaciones**: Validación eficiente de posiciones
- **Límites**: Radio máximo configurable para prevenir lag
- **Memory**: Áreas cargadas en memoria para acceso rápido

### Compatibilidad
- **VoxeLibre**: Todas las versiones compatibles
- **Luanti**: 5.4.0 o superior
- **Dependencias**: `mcl_core` (obligatorio)
- **Opcionales**: `mcl_util`, `mcl_vars`

## Créditos

- **Desarrollado para**: Servidor Wetlands - Educación compasiva
- **Basado en**: APIs nativas de Luanti y VoxeLibre
- **Licencia**: GPL v3
- **Autor**: Gabriel Pantoja
- **Versión**: 1.0.0

---

Para más información sobre el servidor Wetlands, visita la documentación completa en `docs/admin/TUTORIAL_PROTECCION_AREAS.md`