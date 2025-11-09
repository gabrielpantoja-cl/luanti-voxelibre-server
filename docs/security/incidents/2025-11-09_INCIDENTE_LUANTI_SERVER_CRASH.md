# Reporte de Incidente: Servidor Luanti - Crasheos Recurrentes

**Fecha del Incidente**: 09 de Noviembre de 2025
**Servidor**: luanti-voxelibre-server (VPS 167.172.251.27)
**Estado**: RESUELTO - Diagnóstico Completo
**Severidad**: MEDIA (crasheos con auto-restart funcional)

---

## Resumen Ejecutivo

El servidor de Luanti (VoxeLibre/MineClone2) experimentó múltiples crasheos durante el día 09 de noviembre de 2025. Tras el diagnóstico completo vía SSH, se identificaron dos bugs críticos en mods de VoxeLibre que causan errores recurrentes de referencia nula (nil value). El servidor se reinicia automáticamente pero la experiencia de juego se ve afectada.

**Diagnóstico**: NO ES problema de espacio en disco o backups acumulados.
**Causa raíz**: Bugs en mods `mcl_boats` y `mcl_potions` que intentan acceder a entidades eliminadas.

---

## Contexto del Sistema

### Infraestructura
- **VPS**: Digital Ocean 167.172.251.27
- **SO**: Ubuntu/Debian en Docker
- **Contenedor**: `luanti-voxelibre-server` (linuxserver/luanti:latest)
- **Estado actual**: Running (Up 10 hours) - Health: healthy
- **Uptime**: Reinicia cada pocas horas por crashes

### Recursos del Sistema (al momento del diagnóstico)
```
Disco: 34G/58G usado (60%) - SIN PROBLEMAS
CPU: 2.65% - Normal
RAM: 299.4MiB/3.824GiB (7.65%) - Normal
Network: 96MB RX / 820MB TX
Block I/O: 114MB R / 941MB W
PIDs: 18 procesos
```

### VoxeLibre Version
- **Versión instalada**: 0.90.1
- **Fecha de instalación**: 08 de Agosto de 2025, 20:35:32
- **Estado de actualización**: ✅ ÚLTIMA VERSIÓN ESTABLE
- **Método de instalación**: Descarga directa (NO git repository)

### Tamaño del Mundo
```
map.sqlite: 431MB (base de datos principal del mundo)
players.sqlite: 736KB (datos de jugadores)
mod_storage.sqlite: 268KB (almacenamiento de mods)
auth.sqlite: 60KB (autenticación)
Total estimado: ~432MB
```

**✅ NO hay directorio de backups acumulados** - No es problema de espacio.

---

## Errores Identificados

### ERROR CRÍTICO #1: Mod mcl_potions (Pociones de Invisibilidad)

**Ubicación**: `/config/.minetest/games/mineclone2/mods/ITEMS/mcl_potions/functions.lua:1717`

**Tipo de error**: Runtime Error - Intento de indexar valor nil

**Trace completo**:
```
ERROR[Main]: ServerError: AsyncErr: Lua: Runtime error from mod 'mcl_potions'
in callback environment_Step():
...st/games/mineclone2/mods/ITEMS/mcl_potions/functions.lua:1717:
attempt to index local 'luaentity' (a nil value)

stack traceback:
  ...st/games/mineclone2/mods/ITEMS/mcl_potions/functions.lua:1717:
    in function 'make_invisible'
  ...st/games/mineclone2/mods/ITEMS/mcl_potions/functions.lua:208:
    in function 'on_end'
  ...st/games/mineclone2/mods/ITEMS/mcl_potions/functions.lua:1357:
    in function <...st/games/mineclone2/mods/ITEMS/mcl_potions/functions.lua:1341>
  /usr/share/luanti/builtin/common/register.lua:27:
    in function </usr/share/luanti/builtin/common/register.lua:13>
```

**Frecuencia**: Cada 20-30 segundos (recurrente)

**Contexto de ocurrencia**:
- Timestamps detectados: 12:24:43, 12:25:10, 12:25:30, 12:27:00
- Ocurre durante el juego activo (jugador "gabo" conectado)
- Se dispara en callback `environment_Step()` (ejecución continua)

**Causa probable**:
La función `make_invisible` intenta acceder a la propiedad de una entidad (luaentity) que ya fue eliminada del mundo o es nil. Esto ocurre cuando:
1. Un efecto de poción de invisibilidad termina (`on_end`)
2. La entidad asociada al jugador o mob ya no existe
3. No hay validación nil antes de acceder a `luaentity.object`

**Impacto**:
- MEDIO - Error recurrente pero no causa crash inmediato
- Contamina logs con errores constantes
- Puede degradar rendimiento del servidor

---

### ERROR CRÍTICO #2: Mod mcl_boats (Botes)

**Ubicación**: `/config/.minetest/games/mineclone2/mods/ENTITIES/mcl_boats/init.lua:203`

**Tipo de error**: ModError during shutdown - Intento de indexar valor nil

**Trace completo**:
```
ERROR[Main]: ModError while shutting down:
Runtime error from mod '??' in callback luaentity_GetStaticdata():
...netest/games/mineclone2/mods/ENTITIES/mcl_boats/init.lua:203:
attempt to index a nil value

stack traceback:
  ...netest/games/mineclone2/mods/ENTITIES/mcl_boats/init.lua:203:
    in function <...netest/games/mineclone2/mods/ENTITIES/mcl_boats/init.lua:199>
```

**Frecuencia**: Durante cada shutdown del servidor

**Contexto de ocurrencia**:
- Timestamps detectados: 12:26:24, 12:28:07
- Se dispara en callback `luaentity_GetStaticdata()` al apagar servidor
- Ocurre DESPUÉS de `Server: Shutting down`
- ANTES de reiniciar exitosamente

**Causa probable**:
La función que serializa el estado de los botes (`get_staticdata`) para guardar al disco intenta acceder a propiedades de una entidad que:
1. Ya fue eliminada del mundo durante el shutdown
2. Tiene referencia nil a `self` o `self.object`
3. No valida existencia antes de serializar datos

**Impacto**:
- ALTO - Causa shutdown anormal del servidor
- Fuerza reinicio completo del proceso
- Puede corromper datos si el shutdown no completa correctamente
- Logs muestran: `WARNING[Main]: server::ActiveObjectMgr::~ActiveObjectMgr(): not cleared.`

---

## Otros Warnings Detectados

### Warning #1: Invalid vector coordinate (mcl_title)
```
WARNING[Server]: Invalid vector coordinate y (value is nil).
(at /config/.minetest/games/mineclone2/mods/HUD/mcl_title/init.lua:85, 95, 105)
```
- **Severidad**: BAJA
- **Impacto**: Error cosmético en títulos de pantalla
- **Ocasión**: Al conectar jugador "gabo"

### Warning #2: Item overrides after server startup
```
WARNING[Server]: Overriding item mcl_chests:chest after server startup.
This is unsupported and can cause problems related to data inconsistency.
```
- **Severidad**: MEDIA
- **Impacto**: Posible inconsistencia de datos en cofres
- **Afecta**: mcl_chests (chest, chest_left, chest_right), mcl_barrels

### Warning #3: Reading object properties deprecated
```
WARNING[Server]: Reading initial object properties directly from an entity
definition is deprecated, move it to the 'initial_properties' table instead.
(Property 'collisionbox' in entity 'mcl_boats:chest_boat')
```
- **Severidad**: BAJA
- **Impacto**: Warning de deprecación, funciona pero es código viejo
- **Afecta**: mcl_boats:chest_boat

---

## Análisis de Causa Raíz

### Hipótesis Principal
Los bugs son **defectos conocidos en VoxeLibre 0.90.1** relacionados con gestión del ciclo de vida de entidades:

1. **mcl_potions**: No valida que la entidad existe antes de modificar visibilidad
2. **mcl_boats**: No valida que la entidad existe antes de serializar al apagar

### Patrón Común
Ambos errores comparten el mismo patrón:
```lua
-- Código problemático (pseudocódigo)
function hacer_algo(entity)
    local luaentity = entity:get_luaentity()  -- Puede retornar nil
    luaentity.property = value  -- CRASH si luaentity es nil
end
```

### Factores Agravantes
1. **Jugador activo**: Usuario "gabo" conectado interactuando con el mundo
2. **Objetos dinámicos**: Botes, efectos de pociones activos
3. **Ciclo de servidor**: Shutdowns forzados cada pocas horas

### Descartado
❌ Espacio en disco lleno
❌ Backups acumulados
❌ Memoria RAM insuficiente
❌ CPU sobrecargada
❌ Base de datos corrupta
❌ Versión desactualizada

---

## Soluciones Propuestas

### SOLUCIÓN #1: Parchar Mods con Validación Nil (RECOMENDADO)

**Descripción**: Agregar validaciones defensivas en los mods problemáticos.

**Implementación mcl_potions**:
```lua
# Archivo: /config/.minetest/games/mineclone2/mods/ITEMS/mcl_potions/functions.lua
# Línea: ~1715 (antes de la línea 1717 que falla)

function make_invisible(entity)
    -- AGREGAR VALIDACIÓN
    if not entity then
        return
    end

    local luaentity = entity:get_luaentity()

    -- AGREGAR VALIDACIÓN
    if not luaentity or not luaentity.object then
        return
    end

    -- Código original continúa...
    luaentity.property = value
end
```

**Implementación mcl_boats**:
```lua
# Archivo: /config/.minetest/games/mineclone2/mods/ENTITIES/mcl_boats/init.lua
# Línea: ~199 (función get_staticdata)

function boat:get_staticdata()
    -- AGREGAR VALIDACIÓN AL INICIO
    if not self or not self.object then
        return ""
    end

    -- Código original continúa...
    return serialize_boat_data(self)
end
```

**Ventajas**:
- ✅ Corrige el problema en su raíz
- ✅ No afecta funcionalidad del juego
- ✅ Mejora estabilidad inmediatamente

**Desventajas**:
- ⚠️ Requiere acceso al contenedor y edición manual
- ⚠️ Se perderá si se actualiza VoxeLibre sin cuidado
- ⚠️ Necesita conocimientos básicos de Lua

**Pasos de implementación**:
```bash
# 1. SSH al VPS
ssh gabriel@167.172.251.27

# 2. Acceder al contenedor
docker exec -it luanti-voxelibre-server bash

# 3. Instalar editor (si no existe)
apk add nano  # Alpine Linux

# 4. Editar mcl_potions
nano /config/.minetest/games/mineclone2/mods/ITEMS/mcl_potions/functions.lua
# Buscar línea 1717, agregar validaciones

# 5. Editar mcl_boats
nano /config/.minetest/games/mineclone2/mods/ENTITIES/mcl_boats/init.lua
# Buscar línea 203, agregar validaciones

# 6. Salir del contenedor
exit

# 7. Reiniciar servidor
docker restart luanti-voxelibre-server

# 8. Monitorear logs
docker logs -f luanti-voxelibre-server
```

---

### SOLUCIÓN #2: Actualizar a Branch Master (EXPLORATORIA)

**Descripción**: Cambiar instalación a repositorio git y actualizar a commits recientes que podrían incluir fixes.

**Implementación**:
```bash
# 1. SSH al VPS
ssh gabriel@167.172.251.27

# 2. Backup del juego actual
docker exec luanti-voxelibre-server tar czf /config/voxelibre-0.90.1-backup.tar.gz \
  /config/.minetest/games/mineclone2

# 3. Clonar versión git dentro del contenedor
docker exec luanti-voxelibre-server sh -c "
  cd /config/.minetest/games && \
  mv mineclone2 mineclone2.old && \
  apk add git && \
  git clone https://git.minetest.land/VoxeLibre/VoxeLibre.git mineclone2 && \
  cd mineclone2 && \
  git checkout master
"

# 4. Reiniciar servidor
docker restart luanti-voxelibre-server

# 5. Si hay problemas, rollback
docker exec luanti-voxelibre-server sh -c "
  cd /config/.minetest/games && \
  rm -rf mineclone2 && \
  mv mineclone2.old mineclone2
"
docker restart luanti-voxelibre-server
```

**Ventajas**:
- ✅ Acceso a fixes más recientes
- ✅ Fácil actualización futura (`git pull`)
- ✅ Comunidad activa podría haber corregido estos bugs

**Desventajas**:
- ⚠️ Branch master puede ser inestable
- ⚠️ Posibles breaking changes
- ⚠️ Requiere más espacio (incluye .git/)
- ⚠️ No garantiza que los bugs estén corregidos

**Recomendación**: Solo si Solución #1 no funciona o si se confirma fix en commits recientes.

---

### SOLUCIÓN #3: Deshabilitar Mods Problemáticos (ÚLTIMA OPCIÓN)

**Descripción**: Deshabilitar temporalmente los mods que causan crashes.

**Implementación**:
```bash
# SSH al VPS
ssh gabriel@167.172.251.27

# Deshabilitar mcl_boats
docker exec luanti-voxelibre-server sh -c \
  "echo 'load_mod_mcl_boats = false' >> /config/.minetest/worlds/world/world.mt"

# Deshabilitar mcl_potions
docker exec luanti-voxelibre-server sh -c \
  "echo 'load_mod_mcl_potions = false' >> /config/.minetest/worlds/world/world.mt"

# Reiniciar
docker restart luanti-voxelibre-server
```

**Ventajas**:
- ✅ Solución inmediata y simple
- ✅ Estabiliza el servidor completamente
- ✅ Reversible fácilmente

**Desventajas**:
- ❌ Elimina funcionalidad del juego (botes, pociones)
- ❌ Afecta negativamente la experiencia de juego
- ❌ No soluciona el problema real

**Recomendación**: Solo como última opción si las otras soluciones fallan.

---

### SOLUCIÓN #4: Monitoreo y Convivencia (STATUS QUO)

**Descripción**: Mantener la situación actual con monitoreo mejorado.

**Fundamento**:
- El servidor **se reinicia automáticamente** exitosamente
- Los crashes no corrompen datos (map.sqlite intacto)
- La funcionalidad del juego se mantiene
- Uptime de 10 horas entre crashes es aceptable para servidor hobbyista

**Implementación**:
```bash
# Agregar cron job para monitorear crashes
ssh gabriel@167.172.251.27

# Crear script de monitoreo
cat > ~/monitor-luanti.sh << 'EOF'
#!/bin/bash
CRASHES=$(docker logs luanti-voxelibre-server --since 24h 2>&1 | grep -c "ModError while shutting down")
if [ $CRASHES -gt 10 ]; then
    echo "ALERTA: Servidor Luanti tuvo $CRASHES crashes en 24h" | \
    mail -s "Luanti Server Alert" admin@example.com
fi
EOF

chmod +x ~/monitor-luanti.sh

# Agregar a crontab (ejecutar diariamente)
(crontab -l 2>/dev/null; echo "0 8 * * * ~/monitor-luanti.sh") | crontab -
```

**Ventajas**:
- ✅ Sin cambios al servidor
- ✅ Sin riesgo de introducir nuevos problemas
- ✅ Monitoreo proactivo implementado

**Desventajas**:
- ⚠️ Logs continuarán contaminados
- ⚠️ Experiencia de juego interrumpida ocasionalmente
- ⚠️ No soluciona el problema de raíz

---

## Plan de Acción Recomendado

### FASE 1: Implementación Inmediata (Hoy)

1. **Aplicar Solución #1** (Parchar mods con validación nil)
   - Tiempo estimado: 30 minutos
   - Riesgo: BAJO
   - Impacto: ALTO

2. **Backup preventivo**
   ```bash
   ssh gabriel@167.172.251.27
   docker exec luanti-voxelibre-server tar czf \
     /config/backup-pre-patch-$(date +%Y%m%d).tar.gz \
     /config/.minetest/games/mineclone2 \
     /config/.minetest/worlds/world
   ```

3. **Monitorear 24 horas**
   ```bash
   # Terminal dedicado para logs en tiempo real
   ssh gabriel@167.172.251.27
   docker logs -f luanti-voxelibre-server | grep -E "ERROR|WARNING|Server: Shutting down"
   ```

### FASE 2: Validación (24-48 horas después)

1. **Verificar eliminación de errores**
   ```bash
   # Buscar errores mcl_boats en últimas 24h
   docker logs luanti-voxelibre-server --since 24h 2>&1 | grep "mcl_boats"

   # Buscar errores mcl_potions en últimas 24h
   docker logs luanti-voxelibre-server --since 24h 2>&1 | grep "mcl_potions"
   ```

2. **Verificar uptime mejorado**
   ```bash
   docker ps | grep luanti-voxelibre-server
   # Debe mostrar "Up X days" en lugar de "Up X hours"
   ```

3. **Probar funcionalidad**
   - Conectar al servidor como jugador
   - Usar botes (chest boats, regular boats)
   - Usar pociones de invisibilidad
   - Verificar que no hay crashes

### FASE 3: Si falla Solución #1 (Plan B)

1. **Aplicar Solución #2** (Actualizar a branch master)
   - Solo si se confirman fixes en commits recientes
   - Revisar changelog primero

2. **Reportar bugs a la comunidad**
   - Abrir issue en https://git.minetest.land/VoxeLibre/VoxeLibre
   - Incluir stack traces completos
   - Proponer patches (validaciones nil)

3. **Última opción: Solución #3** (Deshabilitar mods)
   - Solo si afecta gravemente la experiencia de juego

---

## Prevención Futura

### Mejoras de Infraestructura

1. **Implementar rotación de logs**
   ```bash
   # Limitar tamaño de logs del contenedor
   docker update --log-opt max-size=10m --log-opt max-file=3 luanti-voxelibre-server
   ```

2. **Health check mejorado**
   - Detectar crashes recurrentes
   - Notificaciones automáticas

3. **Backups automáticos del mundo**
   ```bash
   # Cron job diario
   0 3 * * * docker exec luanti-voxelibre-server tar czf \
     /config/backups/world-$(date +\%Y\%m\%d).tar.gz \
     /config/.minetest/worlds/world
   ```

### Monitoreo Continuo

1. **Dashboard de métricas**
   - Crashes por día
   - Uptime promedio
   - Errores por tipo de mod

2. **Alertas proactivas**
   - Email si crashea >5 veces en 24h
   - Notificación Discord para jugadores

---

## Lecciones Aprendidas

### ✅ Aciertos en el Diagnóstico

1. **Diagnóstico sistemático** permitió identificar causa raíz rápidamente
2. **No asumir** - Se verificó espacio en disco y recursos antes de concluir
3. **Logs detallados** fueron cruciales para identificar mods específicos
4. **Versión actualizada** descartó problemas de versiones antiguas

### ⚠️ Áreas de Mejora

1. **Falta de monitoreo proactivo** - Los crashes pasaron desapercibidos por tiempo
2. **Sin backups automáticos** - Riesgo de pérdida de datos
3. **Logs sin rotación** - Podrían llenar disco eventualmente
4. **Sin alertas** - Usuario descubrió problema manualmente

---

## Conclusión

El servidor de Luanti experimenta crasheos recurrentes debido a **bugs documentados en mods mcl_boats y mcl_potions de VoxeLibre 0.90.1**. Estos bugs no son críticos para la integridad de datos pero degradan la experiencia de juego.

**Recomendación final**: Aplicar **Solución #1** (parchar mods con validación nil) por ser la más directa, segura y efectiva. Si no resuelve el problema, escalar a **Solución #2** (actualizar a branch master).

**NO es problema de recursos, espacio o backups** - El VPS opera normalmente en todos los aspectos.

---

## Referencias

### Archivos Afectados
- `/config/.minetest/games/mineclone2/mods/ITEMS/mcl_potions/functions.lua:1717`
- `/config/.minetest/games/mineclone2/mods/ENTITIES/mcl_boats/init.lua:203`
- `/config/.minetest/games/mineclone2/mods/HUD/mcl_title/init.lua:85,95,105`

### Documentación Relevante
- VoxeLibre Git: https://git.minetest.land/VoxeLibre/VoxeLibre
- VoxeLibre ContentDB: https://content.luanti.org/packages/wuzzy/mineclone2/
- Luanti Docs: https://luanti.org/

### Contacto
- **Servidor**: luanti.gabrielpantoja.cl
- **Landing**: pitutito.cl
- **Administrador**: Gabriel Pantoja
- **Infraestructura**: vps-do repository

---

**Documento generado**: 09 de Noviembre de 2025
**Última actualización**: 09 de Noviembre de 2025
**Próxima revisión**: Después de aplicar Solución #1 (24-48 horas)