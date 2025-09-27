# Tutorial: Sistema de Protección de Áreas - Servidor Wetlands

## 🚨 DIAGNÓSTICO COMPLETADO (Sep 27, 2025)

### ✅ Estado Actual de Protecciones

**1. `voxelibre_protection` Mod** - Sistema Principal de Protección VoxeLibre
- **Ubicación**: `/config/.minetest/mods/voxelibre_protection/`
- **Estado**: ✅ Activo y FUNCIONANDO
- **Configuración**: ✅ Habilitado en `luanti.conf` con `load_mod_voxelibre_protection = true`
- **Privilegios**: ✅ Usuario `gabo` tiene privilegio `server`
- **Comandos disponibles**: ✅ `/pos1`, `/pos2`, `/protect_area`, `/protect_here`

**2. `areas` Mod** - ❌ NO COMPATIBLE con VoxeLibre
- **Ubicación**: `/config/.minetest/mods/areas/`
- **Estado**: ❌ INACTIVO (incompatible con VoxeLibre)
- **Problema**: Diseñado para Minetest vanilla, no para VoxeLibre
- **Comandos NO funcionan**: ❌ `/area_pos1`, `/area_pos2`, `/protect`

**3. `protector` Mod** - Protección Individual por Bloques
- **Ubicación**: `/config/.minetest/mods/protector/`
- **Estado**: ✅ Activo y FUNCIONANDO
- **Configuración**: ✅ Habilitado en `luanti.conf` con `load_mod_protector = true`
- **Items**: ✅ `/give protector:protect 20` funciona correctamente

**4. `home_teleport` Mod** - Sistema de Spawn y Casa
- **Ubicación**: `/config/.minetest/mods/home_teleport/`
- **Estado**: ✅ Activo
- **Comandos disponibles**: ✅ `/spawn`, `/setspawn`, `/home`, `/sethome`

**5. Sistema Nativo VoxeLibre**
- **Camas (Beds)**: Protección automática alrededor de camas
- **Cofres**: Sistema básico de propiedad
- **Comando de spawn personal**: `/back_to_spawn` (ir a tu cama)

### 🎯 Privilegios de Protección Confirmados

**Usuario `gabo` tiene los siguientes privilegios:**
```
✅ server            # Privilegios de administrador (incluye protección)
✅ protection_bypass  # Ignorar todas las protecciones (admin)
✅ home              # Establecer y teletransportarse a casa
✅ spawn             # Acceso a comandos de spawn
✅ teleport          # Teletransportación
✅ worldedit         # Herramientas de construcción masiva
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

### Fase 3: Protección Avanzada con Mod `voxelibre_protection` (Solo Admin)

#### 3.1 Verificar Instalación de VoxeLibre Protection
```bash
# En el servidor
docker-compose exec luanti-server ls /config/.minetest/mods/voxelibre_protection/
```

#### 3.2 Comandos VoxeLibre Protection (Requiere privilegio `server`)

**Seleccionar Área Manualmente:**
```
/pos1    # Marca esquina 1 (donde estás parado)
/pos2    # Marca esquina 2 (donde estás parado)
```

**Crear Área Protegida:**
```
/protect_area <nombre_area>        # Crear área entre pos1 y pos2
/protect_area spawn_principal      # Ejemplo: proteger spawn
/protect_area casa_gabo           # Ejemplo: proteger casa
```

**Protección Rápida (RECOMENDADO):**
```
/protect_here <radio> <nombre>     # Proteger área alrededor del jugador
/protect_here 50 spawn_principal   # Proteger 50 bloques alrededor del spawn
/protect_here 20 casa_entrada     # Proteger 20 bloques alrededor
```

**Gestionar Áreas:**
```
/list_areas                        # Listar todas las áreas protegidas
/unprotect_area <nombre_area>      # Eliminar protección por nombre
```

### Fase 4: Protección de Spawn (Crítico)

#### 4.1 Ubicación Actual del Spawn
```
Coordenadas spawn actuales: 0,15,0
Radio recomendado de protección: 50-100 bloques
```

#### 4.2 Proteger Área de Spawn - METODOLOGÍA VOXELIBRE

**🎯 MÉTODO RÁPIDO (RECOMENDADO):**

**Paso 1: Ir al spawn**
```
/spawn    # Te lleva al spawn del servidor (coordenadas 0,15,0)
```

**Paso 2: Protección instantánea**
```
/protect_here 50 spawn_principal    # Protege 50 bloques alrededor del spawn
```

**Paso 3: Verificar que funcionó**
```
/list_areas    # Debe aparecer "spawn_principal" en la lista
```

**🔧 MÉTODO MANUAL (Alternativo):**

**Paso 1: Ir al spawn y marcar esquinas**
```
/spawn                # Ir al spawn (0,15,0)
# Caminar a (-50, Y, -50) desde spawn
/pos1                 # Marcar esquina 1
# Caminar a (+50, Y, +50) desde spawn
/pos2                 # Marcar esquina 2
```

**Paso 2: Crear la protección**
```
/protect_area spawn_principal    # Crear área entre pos1 y pos2
```

**Paso 3: Verificar**
```
/list_areas           # Verificar que aparece "spawn_principal"
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
/help pos1              # Ver comandos disponibles de voxelibre_protection
/help protect_area      # Ver comandos de protección de áreas
/help protector         # Ver comandos disponibles de protector
```

#### 5.3 Problemas Comunes

**Error: "Unknown command 'protect'"**
- Causa: Intentando usar comandos del mod `areas` incompatible
- Solución: Usar comandos VoxeLibre: `/protect_area` o `/protect_here`

**Error: "Unknown command 'area_pos1'"**
- Causa: Mod `areas` no compatible con VoxeLibre
- Solución: Usar comandos VoxeLibre: `/pos1` y `/pos2`

**Error: "Permission denied"**
- Causa: Usuario no tiene privilegios suficientes
- Solución: Otorgar privilegio `server` al admin

**Bloques se pueden romper en área protegida**
- Causa: Usuario tiene `protection_bypass`
- Solución: Verificar privilegios del usuario

## Próximos Pasos Recomendados

### Immediate Actions Needed:
1. **✅ COMPLETADO: Mod VoxeLibre Protection funcionando**: Comandos `/pos1`, `/protect_area` activos
2. **✅ COMPLETADO: Usuario gabo tiene privilegios**: Privilegio `server` otorgado
3. **🎯 ACCIÓN INMEDIATA: Proteger spawn**: Usar `/protect_here 50 spawn_principal`
4. **Testear protector blocks**: Verificar que funcionen en VoxeLibre

### Future Enhancements:
1. **Configurar protección automática**: Para nuevos jugadores
2. **Crear áreas públicas**: Zonas de construcción comunitaria
3. **Tutorial para jugadores**: Cómo proteger sus construcciones
4. **Sistema de permisos por roles**: Diferentes niveles de acceso

## 🎯 Estado Final de Protecciones (ACTUALIZADO)

✅ **Admin con privilegio `server`** - Usuario `gabo` puede crear protecciones
✅ **Mod `voxelibre_protection` activo** - Comandos `/pos1`, `/pos2`, `/protect_area`, `/protect_here` funcionando
✅ **Mod `protector` activo** - Bloques protectores disponibles
✅ **Comando `/spawn` funcionando** - Sistema `home_teleport` activo
✅ **Sistema VoxeLibre básico** - Camas y cofres protegidos
❌ **Spawn sin protección** - PENDIENTE: Usar `/protect_here 50 spawn_principal`
❌ **Mod `areas` incompatible** - No funciona con VoxeLibre

## 🚨 ACCIÓN INMEDIATA REQUERIDA:
  1. ✅ Otorgar privilegios a gabo - **COMPLETADO**
  2. ✅ Identificar sistema de protección correcto - **COMPLETADO** (VoxeLibre Protection)
  3. 🎯 **Proteger spawn AHORA** - **Usar: `/protect_here 50 spawn_principal`**

**COMANDOS CORRECTOS PARA VOXELIBRE:**
- `/pos1` y `/pos2` (NO `/area_pos1`)
- `/protect_area <nombre>` (NO `/protect`)
- `/protect_here <radio> <nombre>` (RECOMENDADO para spawn)
- `/list_areas` (NO `/areas`)