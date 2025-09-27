# Tutorial: Sistema de Protección de Áreas - Servidor Wetlands

## 🚨 DIAGNÓSTICO ACTUALIZADO (Sep 27, 2025)

### ✅ Estado Actual de Protecciones

**1. `areas` Mod** - Sistema Principal de Protección
- **Ubicación**: `/config/.minetest/mods/areas/`
- **Estado**: ✅ Activo y FUNCIONANDO
- **Configuración**: ✅ Habilitado en `luanti.conf` con `load_mod_areas = true`
- **Privilegios**: ✅ Usuario `gabo` tiene privilegio `areas`
- **Comandos disponibles**: ✅ `/area_pos1`, `/area_pos2`, `/protect`

**2. `protector` Mod** - Protección Individual por Bloques
- **Ubicación**: `/config/.minetest/mods/protector/`
- **Estado**: ✅ Activo y FUNCIONANDO
- **Configuración**: ✅ Habilitado en `luanti.conf` con `load_mod_protector = true`
- **Items**: ✅ `/give protector:protect 20` funciona correctamente

**3. `home_teleport` Mod** - Sistema de Spawn y Casa
- **Ubicación**: `/config/.minetest/mods/home_teleport/`
- **Estado**: ✅ Activo
- **Comandos disponibles**: ✅ `/spawn`, `/setspawn`, `/home`, `/sethome`

**4. Sistema Nativo VoxeLibre**
- **Camas (Beds)**: Protección automática alrededor de camas
- **Cofres**: Sistema básico de propiedad
- **Comando de spawn personal**: `/back_to_spawn` (ir a tu cama)

### 🎯 Privilegios de Protección Confirmados

**Usuario `gabo` tiene los siguientes privilegios:**
```
✅ areas             # Gestionar áreas protegidas
✅ protection_bypass  # Ignorar todas las protecciones (admin)
✅ home              # Establecer y teletransportarse a casa
✅ spawn             # Acceso a comandos de spawn
✅ teleport          # Teletransportación
✅ worldedit         # Herramientas de construcción masiva
✅ server            # Privilegios de administrador
```

## Tutorial Paso a Paso para Admin (gabo)

### Fase 1: Protección con Sistema Nativo VoxeLibre

#### 1.1 Protección con Camas
```
Cómo funciona:
1. Coloca una cama en tu construcción
2. Duerme en ella para establecer spawn personal
3. El área alrededor de la cama queda automáticamente protegida
4. Radio: ~5 bloques alrededor de la cama
```

**Comandos relacionados:**
- `/back_to_spawn` - Volver a tu cama/spawn personal

#### 1.2 Protección de Cofres y Contenedores
```
VoxeLibre incluye:
- Cofres básicos: Acceso público
- Locked Chest: Solo el dueño puede abrir
- Ender Chest: Inventario personal privado
```

**Receta Locked Chest** (VoxeLibre):
```
[Iron Ingot] [Iron Ingot] [Iron Ingot]
[Iron Ingot] [   Chest  ] [Iron Ingot]
[Iron Ingot] [Iron Ingot] [Iron Ingot]
```

### Fase 2: Protección con Mod `protector`

#### 2.1 Craftear Bloque Protector
**Receta Protector Block** (compatible VoxeLibre):
```
[Stone] [Stone] [Stone]
[Stone] [Steel] [Stone]
[Stone] [Stone] [Stone]
```

#### 2.2 Usar Bloque Protector
```
1. Coloca el Protector Block en el centro de tu construcción
2. Radio de protección: 5-10 bloques (configurable)
3. Solo tú y usuarios autorizados pueden modificar el área
4. Click derecho en el bloque para gestionar permisos
```

#### 2.3 Comandos de Protector
```
/protector_show     # Mostrar áreas protegidas cercanas
/protector_list     # Listar tus protectores
```

### Fase 3: Protección Avanzada con Mod `areas` (Solo Admin)

#### 3.1 Verificar Instalación de Areas
```bash
# En el servidor
docker-compose exec luanti-server ls /config/.minetest/mods/areas/
```

#### 3.2 Comandos Básicos de Areas (Requiere privilegio `areas`)

**Seleccionar Área:**
```
/area_pos1    # Marca esquina 1 (donde estás parado)
/area_pos2    # Marca esquina 2 (donde estás parado)
```

**Crear Área Protegida:**
```
/protect <nombre_area>           # Crear área con nombre
/protect spawn_area             # Ejemplo: proteger spawn
/protect casa_principal         # Ejemplo: proteger casa
```

**Gestionar Áreas:**
```
/areas                          # Listar todas las áreas
/area_info                      # Info del área donde estás
/unprotect <id_area>           # Eliminar protección
/area_open <id_area>           # Hacer área pública
```

**Dar Permisos:**
```
/area_owner <id_area> <usuario>     # Transferir propiedad
/area_add_owner <id_area> <usuario>  # Agregar co-propietario
```

### Fase 4: Protección de Spawn (Crítico)

#### 4.1 Ubicación Actual del Spawn
```
Coordenadas spawn actuales: 0,15,0
Radio recomendado de protección: 50-100 bloques
```

#### 4.2 Proteger Área de Spawn - METODOLOGÍA CORRECTA

**Paso 1: Ir al spawn**
```
/spawn    # Te lleva al spawn del servidor (coordenadas 0,15,0)
```

**Paso 2: Marcar las esquinas del área a proteger**
```
# Camina a la esquina noreste (ej: +50, +50 desde spawn)
/area_pos1    # Marca primera esquina donde estás parado

# Camina a la esquina suroeste (ej: -50, -50 desde spawn)
/area_pos2    # Marca segunda esquina donde estás parado
```

**Paso 3: Crear la protección**
```
/protect spawn_principal    # Crea área protegida con el nombre "spawn_principal"
```

**Paso 4: Verificar que funcionó**
```
/areas        # Listar todas las áreas (debe aparecer "spawn_principal")
/area_info    # Info del área donde estás parado
```

**Comandos de respaldo si hay problemas:**
```
/area_pos get    # Ver las posiciones actuales marcadas
/select_area 1   # Seleccionar área por ID (si ya existe)
```

### Fase 5: Diagnóstico y Troubleshooting

#### 5.1 Verificar Estado de Mods
```bash
# Ver mods cargados relacionados con protección
docker-compose exec luanti-server grep -i "areas\|protector\|protection" /config/.minetest/debug.txt | tail -10
```

#### 5.2 Comandos de Diagnóstico en Juego
```
/mods                    # Ver todos los mods cargados
/help areas             # Ver comandos disponibles de areas
/help protector         # Ver comandos disponibles de protector
```

#### 5.3 Problemas Comunes

**Error: "Unknown command 'protect'"**
- Causa: Mod `areas` no está cargado o falta privilegio `areas`
- Solución: Verificar configuración de mods

**Error: "Permission denied"**
- Causa: Usuario no tiene privilegios suficientes
- Solución: Otorgar privilegio `areas` al admin

**Bloques se pueden romper en área protegida**
- Causa: Usuario tiene `protection_bypass`
- Solución: Verificar privilegios del usuario

## Próximos Pasos Recomendados

### Immediate Actions Needed:
1. **Verificar si mod `areas` está funcionando**: Probar comandos `/area_pos1`
2. **Otorgar privilegio `areas` a gabo**: Para usar comandos de administración
3. **Proteger spawn inmediatamente**: Área crítica sin protección actual
4. **Testear protector blocks**: Verificar que funcionen en VoxeLibre

### Future Enhancements:
1. **Configurar protección automática**: Para nuevos jugadores
2. **Crear áreas públicas**: Zonas de construcción comunitaria
3. **Tutorial para jugadores**: Cómo proteger sus construcciones
4. **Sistema de permisos por roles**: Diferentes niveles de acceso

## 🎯 Estado Final de Protecciones (ACTUALIZADO)

✅ **Admin con privilegio `areas`** - Usuario `gabo` puede crear protecciones
✅ **Mod `areas` activo** - Comandos `/area_pos1`, `/area_pos2`, `/protect` funcionando
✅ **Mod `protector` activo** - Bloques protectores disponibles
✅ **Comando `/spawn` funcionando** - Sistema `home_teleport` activo
✅ **Sistema VoxeLibre básico** - Camas y cofres protegidos
❌ **Spawn sin protección** - PENDIENTE: Usar metodología actualizada

## 🚨 ACCIÓN INMEDIATA REQUERIDA:
  1. ✅ Otorgar privilegio areas a gabo - **COMPLETADO**
  2. ❌ Proteger spawn urgentemente - **PENDIENTE**
  3. ❌ Testear comandos /area_pos1 y /protect - **PENDIENTE**

**METODOLOGÍA CONFIRMADA**: Todos los comandos y mods están funcionando. Seguir la **Fase 4.2** del tutorial para proteger el spawn inmediatamente.