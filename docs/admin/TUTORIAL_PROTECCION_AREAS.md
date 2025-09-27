# Tutorial: Sistema de Protección de Áreas - Servidor Wetlands

## Diagnóstico Actual del Sistema

### 🔍 Mods de Protección Instalados

**1. `areas` Mod** - Sistema Principal de Protección
- **Ubicación**: `/config/.minetest/mods/areas/`
- **Estado**: ✅ Activo
- **Función**: Protección de áreas grandes mediante comandos de admin
- **Compatibilidad**: Universal (Minetest/VoxeLibre)

**2. `protector` Mod** - Protección Individual por Bloques
- **Ubicación**: `/config/.minetest/mods/protector/`
- **Estado**: ✅ Activo
- **Función**: Bloques protectores que los jugadores pueden colocar
- **Compatibilidad**: ✅ VoxeLibre/MineClone2 compatible
- **Radio**: Protege área alrededor del bloque

**3. `voxelibre_protection` Mod** - Protección Nativa VoxeLibre
- **Ubicación**: `/config/.minetest/mods/voxelibre_protection/`
- **Estado**: ✅ Activo
- **Autor**: Claude (mod personalizado)
- **Función**: Integración con sistema nativo de VoxeLibre

**4. Sistema Nativo VoxeLibre**
- **Camas (Beds)**: Protección automática alrededor de camas
- **Cofres**: Sistema básico de propiedad
- **Spawn Protection**: Protección automática del spawn

### 🎯 Privilegios de Protección Disponibles

**Privilegios actuales relacionados con protección:**
```
protection_bypass  # Ignorar todas las protecciones (solo admin)
home              # Establecer y teletransportarse a casa
spawn             # Acceso a comandos de spawn
teleport          # Teletransportación
worldedit         # Herramientas de construcción masiva
```

**Privilegios faltantes** (no disponibles actualmente):
- `areas` - Para gestionar áreas protegidas
- `areas_admin` - Administración de áreas
- `protector` - Usar bloques protectores

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

#### 4.2 Proteger Área de Spawn
```
1. Ir al spawn: /spawn
2. Caminar 50 bloques al noreste: /area_pos1
3. Caminar 50 bloques al suroeste: /area_pos2
4. Crear protección: /protect spawn_principal
5. Verificar: /area_info
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

## Estado Actual de Protecciones

❌ **Spawn sin protección** - Vulnerable a griefing
❌ **Admin sin privilegio `areas`** - No puede crear protecciones
✅ **Protector mod activo** - Jugadores pueden usar bloques protectores
✅ **Sistema VoxeLibre básico** - Camas y cofres funcionan
❌ **Áreas administrativas sin definir** - Zonas importantes desprotegidas

**CRÍTICO**: Se necesita configurar protecciones inmediatamente para evitar griefing del spawn y áreas importantes.