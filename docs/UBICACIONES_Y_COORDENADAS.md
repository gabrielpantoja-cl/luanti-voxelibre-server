# 🗺️ UBICACIONES Y COORDENADAS DEL MUNDO VEGAN WETLANDS

**Fecha de creación**: 10 de Septiembre, 2025  
**Última actualización**: 12 de Septiembre, 2025  
**Estado del mundo**: Activo y estable  

## 📍 UBICACIONES PRINCIPALES CONFIRMADAS

### 🏛️ **CIUDAD PRINCIPAL** ⭐
- **Coordenadas**: `-48, 80, 0` (teleportación aérea)  
- **Coordenadas de superficie**: `-48, ~10-20, 0`  
- **Chunk del mundo**: (-3, -3) a (-2, 3)  
- **Descripción**: Principal área de construcción con alta densidad de bloques  
- **Comando de teleportación**: `/teleport gabo -48 80 0`  
- **Estado**: ✅ **CONFIRMADO ACTIVO** (Sept 10, 2025)

### 🌅 **SPAWN OFICIAL DEL SERVIDOR**
- **Coordenadas**: `0, 15, 0`  
- **Descripción**: Punto de spawn configurado en el servidor  
- **Comando de teleportación**: `/teleport gabo 0 15 0`  
- **Comando alternativo**: `/back_to_spawn` (si no tienes cama personal)

### 🏘️ **SEGUNDA CIUDAD - ALDEA** ⭐⭐
- **Coordenadas**: `57, 33, -3082` (teleportación aérea)  
- **Coordenadas exactas**: `57.1, 32.5, -3081.7`  
- **Descripción**: Segunda ciudad más importante del servidor - Aldea desarrollada  
- **Comando de teleportación**: `/teleport gabo 57 33 -3082`  
- **Estado**: ✅ **CONFIRMADO ACTIVO** (Sept 12, 2025)  
- **Importancia**: Segunda ciudad más importante del mundo

## 🛠️ COMANDOS DE NAVEGACIÓN ESENCIALES

### **Teleportación Directa**
```bash
# Ciudad Principal (CONFIRMADA)
/teleport gabo -48 80 0

# Spawn del Servidor  
/teleport gabo 0 15 0

# Zona Secundaria (por explorar)
/teleport gabo 32 80 -80

# Segunda Ciudad - Aldea (CONFIRMADA)
/teleport gabo 57 33 -3082

# Teleportación a coordenadas específicas
/teleport gabo <x> <y> <z>
```

### **Sistema de Spawn Personal**
```bash
# Volver a tu cama personal (si la tienes)
/back_to_spawn

# Volver al spawn del mundo
/spawn
```

### **Herramientas de Navegación**
```bash
# Obtener brújula para orientación
/giveme mcl_core:compass 1

# Obtener mapa (si está disponible)
/giveme mcl_maps:filled_map 1

# Activar modo vuelo para exploración
/fly
```

## 🗃️ SISTEMA DE BÚSQUEDA DE UBICACIONES PERDIDAS

### **Método 1: Análisis de Base de Datos**
Si te pierdes nuevamente, usa este comando en el servidor para encontrar áreas con construcciones:

```bash
# Conectarse al servidor
ssh gabriel@<VPS_IP> "cd /home/gabriel/Vegan-Wetlands && docker-compose exec -T luanti-server sqlite3 /config/.minetest/worlds/world/map.sqlite \"SELECT x, z, COUNT(*) as block_count FROM blocks GROUP BY x, z HAVING block_count > 1 ORDER BY block_count DESC LIMIT 20;\""
```

**Interpretar resultados:**
- Los números `x, z` son coordenadas de chunk
- Para convertir a coordenadas del mundo: `x_mundo = x_chunk * 16`, `z_mundo = z_chunk * 16`
- Mayor `block_count` = más construcciones en esa área

### **Método 2: Exploración Sistemática**
1. Teleportarse a altura segura: `/teleport gabo 0 100 0`
2. Volar en círculos concéntricos desde el spawn
3. Buscar señales de construcción:
   - Casas con ventanas regulares
   - Caminos hechos a mano
   - Granjas organizadas
   - Áreas deforestadas o modificadas

### **Método 3: Búsqueda por Patrones**
Buscar bloques específicos que indican construcción humana:
- Camas (`mcl_beds`)
- Puertas (`mcl_doors`)
- Antorchas en patrones regulares
- Bloques de construcción (cobblestone, planks)

## 📊 DATOS TÉCNICOS DEL MUNDO

### **Configuración del Servidor**
- **Semilla del mundo**: `12345678901234567890`  
- **Generador de mapas**: `v7`  
- **Spawn estático**: `0, 15, 0`  
- **Juego base**: VoxeLibre (MineClone2)

### **Estadísticas de Actividad**
- **Chunk más activo**: (-3, -3) con 109 bloques  
- **Rango de actividad principal**: (-3, -3) a (-2, 3)  
- **Zona secundaria**: (2, -8) a (2, -3)  
- **Total de chunks con construcciones**: 20+

## 🚨 PROTOCOLO DE EMERGENCIA

### **Si Te Pierdes Completamente**
1. **Paso 1**: Intentar `/back_to_spawn`
2. **Paso 2**: Si no funciona, usar `/teleport gabo 0 80 0` para ir al spawn aéreo
3. **Paso 3**: Desde el spawn, ir a la ciudad principal: `/teleport gabo -48 80 0`
4. **Paso 4**: Si necesitas buscar otras áreas, usar los comandos de la zona secundaria

### **Para Administradores**
Si necesitas acceso completo de administrador:
```bash
# Verificar privilegios actuales
/privs gabo

# Obtener todos los privilegios (ya configurado en luanti.conf)
# El usuario 'gabo' tiene automáticamente todos los privilegios de admin
```

## 📝 REGISTRO DE CAMBIOS

### **12 de Septiembre, 2025**
- ✅ **CONFIRMADO**: Segunda Ciudad - Aldea en coordenadas (57, 33, -3082)
- ✅ Registrada como segunda ciudad más importante del servidor
- ✅ Comando de teleportación agregado al sistema de navegación

### **10 de Septiembre, 2025**
- ✅ **CONFIRMADO**: Ciudad principal en coordenadas (-48, 80, 0)
- ✅ Método de búsqueda por base de datos funcionando correctamente
- ✅ Comandos de teleportación validados
- 🔍 Zona secundaria identificada pero pendiente de explorar

### **Próximas Actualizaciones Necesarias**
- [ ] Explorar y confirmar la zona secundaria (32, 80, -80)
- [ ] Crear sistema de marcadores con `/sethome` si está disponible
- [ ] Documentar construcciones específicas encontradas
- [ ] Añadir coordenadas de puntos de interés (granjas, edificios importantes)

## 💡 CONSEJOS ADICIONALES

### **Prevención**
- Siempre lleva una brújula cuando explores
- Anota coordenadas importantes en el chat: `/me Estoy en <coordenadas>`
- Usa camas para crear spawn points personales
- Construye torres altas o beacons como puntos de referencia

### **Navegación**
- La altura 80 es ideal para teleportación aérea (evita colisiones)
- Las coordenadas Y entre 10-20 suelen ser la superficie
- Usa el modo vuelo (`/fly`) para exploración rápida
- Las coordenadas negativas están al oeste/norte del spawn

---

**⚠️ IMPORTANTE**: Mantén este documento actualizado cada vez que descubras nuevas ubicaciones importantes. ¡Nunca más te perderás en Vegan Wetlands! 🌱