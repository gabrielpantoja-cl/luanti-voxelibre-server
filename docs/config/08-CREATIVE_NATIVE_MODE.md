# 08 - MODO CREATIVO NATIVO: Inventario Infinito VoxeLibre

**Autor**: Gabriel Pantoja
**Fecha de Implementación**: 2026-01-16
**Versión**: 1.0.0
**Servidor**: Wetlands Luanti/VoxeLibre
**Estado**: ✅ PRODUCCIÓN ACTIVA

---

## 📋 Tabla de Contenidos

1. [Descripción General](#1-descripción-general)
2. [Problema Resuelto](#2-problema-resuelto)
3. [Implementación](#3-implementación)
4. [Configuración Actual](#4-configuración-actual)
5. [Comparación: Antes vs Después](#5-comparación-antes-vs-después)
6. [Deployment](#6-deployment)
7. [Verificación](#7-verificación)
8. [Troubleshooting](#8-troubleshooting)
9. [Historia del Cambio](#9-historia-del-cambio)

---

# 1. Descripción General

El servidor Wetlands ahora opera en **modo creativo nativo de VoxeLibre** con inventario infinito completo para todos los jugadores.

## 1.1. Características Principales

- ✅ **Inventario infinito nativo**: Acceso a TODOS los items de VoxeLibre vía inventario creativo
- ✅ **Persistencia del inventario**: Los items en el inventario se mantienen entre sesiones
- ✅ **Sin items iniciales forzados**: No se llenan espacios con bloques predefinidos
- ✅ **Buscador integrado**: Búsqueda rápida de items en el inventario creativo
- ✅ **Experiencia fluida**: Sin bugs de reseteo de inventarios

## 1.2. Beneficios

| Beneficio | Descripción |
|-----------|-------------|
| **Simplicidad** | Usa el sistema nativo de VoxeLibre sin mods complejos |
| **Confiabilidad** | Sin bugs de persistencia de inventarios |
| **Educativo** | Niños aprenden a usar el inventario creativo estándar |
| **Mantenibilidad** | Menos código personalizado = menos puntos de fallo |

---

# 2. Problema Resuelto

## 2.1. Bug del Inventario Lleno

**Síntoma**: Jugadores iniciaban cada sesión con el inventario lleno de 36 bloques predefinidos, perdiendo su inventario anterior.

**Causa Raíz**: El mod `creative_force` tenía una función `give_all_items_to_player()` que:
1. Limpiaba el inventario: `inv:set_list("main", {})`
2. Llenaba con ~36 items predefinidos
3. Usaba una tabla en RAM `players_with_kit` que se perdía al reiniciar servidor
4. Consideraba a TODOS como "nuevos jugadores" tras cada reinicio

**Impacto**:
- ❌ Jugadores perdían items personalizados al reconectar
- ❌ Inventario siempre lleno con bloques no deseados
- ❌ Experiencia frustrante para los niños

## 2.2. Configuración Previa Problemática

**Modo**: Survival con mod `creative_force` simulando creatividad

```conf
creative_mode = false             # ❌ Survival mode
mcl_enable_creative_mode = false  # ❌ VoxeLibre creative disabled
give_initial_stuff = true         # ❌ Daba items iniciales
load_mod_creative_force = true    # ❌ Mod bugueado
```

**Problemas**:
- Sin inventario infinito real
- Dependencia de mod personalizado con bugs
- Complejidad innecesaria

---

# 3. Implementación

## 3.1. Cambios en luanti.conf

**Archivo**: `server/config/luanti.conf`

### 3.1.1. Sección: Configuración del Juego

**Antes**:
```conf
# Configuración del juego - MODO SURVIVAL CON PVP EN ARENAS ⚔️
creative_mode = false
enable_damage = true
enable_pvp = true
enable_fire = false
enable_tnt = false
enable_rollback_recording = true

# DAÑO HABILITADO TEMPORALMENTE PARA PVP
damage_enabled = true
player_transfer_distance = 0
item_entity_ttl = 0

# VoxeLibre: Modo survival con privilegios creativos opcionales
mcl_enable_creative_mode = false
mcl_creative_is_survival_like = false
give_initial_stuff = true
initial_stuff = mcl_core:apple 10,mcl_core:bread 10
```

**Después**:
```conf
# Configuración del juego - MODO CREATIVO NATIVO CON INVENTARIO INFINITO 🎨
creative_mode = true
enable_damage = false
enable_pvp = false
enable_fire = false
enable_tnt = false
enable_rollback_recording = true

# Modo creativo sin dar items iniciales (inventario infinito disponible)
damage_enabled = false
player_transfer_distance = 0
item_entity_ttl = 0

# VoxeLibre: Modo creativo nativo con inventario infinito
mcl_enable_creative_mode = true
mcl_creative_is_survival_like = false
give_initial_stuff = false
initial_stuff =
```

### 3.1.2. Sección: Mods

**Antes**:
```conf
load_mod_creative_force = true
```

**Después**:
```conf
load_mod_creative_force = false  # DESHABILITADO - Usando modo creativo nativo de VoxeLibre
```

## 3.2. Deshabilitación del Mod creative_force

**Ubicación Anterior**: `server/mods/creative_force/`
**Ubicación Nueva**: `server/mods_backup/creative_force/`
**Acción**: Movido fuera de la carpeta de mods activos

**Razón**: Evitar que el mod interfiera con el modo creativo nativo.

---

# 4. Configuración Actual

## 4.1. Parámetros Críticos

| Parámetro | Valor | Función |
|-----------|-------|---------|
| `creative_mode` | `true` | Activa modo creativo global |
| `mcl_enable_creative_mode` | `true` | Activa inventario creativo VoxeLibre |
| `enable_damage` | `false` | Jugadores no reciben daño |
| `enable_pvp` | `false` | Sin combate jugador vs jugador |
| `give_initial_stuff` | `false` | No dar items al inicio |
| `initial_stuff` | (vacío) | Sin lista de items iniciales |
| `load_mod_creative_force` | `false` | Mod personalizado deshabilitado |

## 4.2. Privilegios por Defecto

```conf
default_privs = interact,shout,give,fly,fast,noclip,home,areas,areas_high_limit,protect
```

**Nota**: Ya no se necesita otorgar `creative` manualmente, el modo creativo nativo lo maneja.

---

# 5. Comparación: Antes vs Después

## 5.1. Experiencia del Jugador

| Aspecto | Antes (creative_force) | Después (nativo) |
|---------|------------------------|------------------|
| **Inventario al inicio** | 36 bloques predefinidos | Vacío + acceso a inventario infinito |
| **Persistencia** | ❌ Se reseteaba al reiniciar | ✅ Se mantiene entre sesiones |
| **Acceso a items** | Solo ~36 items iniciales | ✅ TODOS los items de VoxeLibre |
| **Búsqueda de items** | ❌ No disponible | ✅ Barra de búsqueda integrada |
| **Complejidad** | Confuso (¿por qué estos bloques?) | Intuitivo (inventario creativo estándar) |

## 5.2. Mantenibilidad Técnica

| Aspecto | Antes | Después |
|---------|-------|---------|
| **Código personalizado** | ~300 líneas de Lua | 0 líneas (nativo) |
| **Puntos de fallo** | Mod con bugs de persistencia | Sistema probado de VoxeLibre |
| **Dependencias** | Mod custom + survival mode | Solo VoxeLibre nativo |
| **Debugging** | Complejo (logs de mod) | Simple (configuración estándar) |
| **Actualizaciones** | Mantener mod compatible | Automático con VoxeLibre |

---

# 6. Deployment

## 6.1. Proceso Ejecutado (2026-01-16)

### Paso 1: Modificar Configuración Local

```bash
# Editar server/config/luanti.conf
# Cambiar creative_mode, mcl_enable_creative_mode, give_initial_stuff, load_mod_creative_force
```

### Paso 2: Copiar a Producción

```bash
scp /home/gabriel/Documentos/luanti-voxelibre-server/server/config/luanti.conf \
  gabriel@<IP_VPS_ANTERIOR>:/home/gabriel/luanti-voxelibre-server/server/config/luanti.conf
```

### Paso 3: Deshabilitar Mod en VPS

```bash
ssh gabriel@<IP_VPS_ANTERIOR> "cd /home/gabriel/luanti-voxelibre-server && \
  mkdir -p server/mods_backup && \
  mv server/mods/creative_force.disabled server/mods_backup/creative_force"
```

### Paso 4: Reiniciar Servidor

```bash
ssh gabriel@<IP_VPS_ANTERIOR> "cd /home/gabriel/luanti-voxelibre-server && \
  docker-compose restart luanti-server"
```

**Downtime**: ~20 segundos
**Pérdida de datos**: 0 (mundo intacto)

## 6.2. Deployment Futuro

Para replicar estos cambios en otro servidor:

```bash
# 1. Clonar repositorio
git clone https://github.com/gabrielpantoja-cl/luanti-voxelibre-server.git
cd luanti-voxelibre-server

# 2. Verificar configuración
grep "creative_mode" server/config/luanti.conf
grep "mcl_enable_creative_mode" server/config/luanti.conf
grep "load_mod_creative_force" server/config/luanti.conf

# 3. Asegurar que creative_force está deshabilitado
test ! -d server/mods/creative_force || mv server/mods/creative_force server/mods_backup/

# 4. Iniciar servidor
docker-compose up -d
```

---

# 7. Verificación

## 7.1. Verificar Configuración en Producción

### 7.1.1. Desde Terminal

```bash
ssh gabriel@<IP_VPS_ANTERIOR> "cd /home/gabriel/luanti-voxelibre-server && \
  docker-compose exec -T luanti-server grep -E '^creative_mode|^mcl_enable_creative_mode|^give_initial_stuff' /config/.minetest/minetest.conf"
```

**Resultado Esperado**:
```
creative_mode = true
mcl_enable_creative_mode = true
give_initial_stuff = false
```

### 7.1.2. Verificar Mod Deshabilitado

```bash
ssh gabriel@<IP_VPS_ANTERIOR> "cd /home/gabriel/luanti-voxelibre-server && \
  ls -la server/mods/ | grep creative_force"
```

**Resultado Esperado**: Sin output (mod no presente en mods/)

## 7.2. Verificar en el Juego

### 7.2.1. Test de Inventario Creativo

1. **Conectar al servidor**: `luanti.gabrielpantoja.cl:30000`
2. **Presionar `E`**: Abrir inventario
3. **Verificar pestaña creativa**: Debe aparecer icono con todos los items
4. **Buscar item**: Usar barra de búsqueda (ej: "diamond")
5. **Tomar item**: Arrastrar a inventario principal

**Resultado Esperado**: ✅ Inventario creativo completo funcional

### 7.2.2. Test de Persistencia

1. **Agregar items**: Tomar algunos items del inventario creativo
2. **Desconectar**: Salir del servidor
3. **Reconectar**: Volver a entrar
4. **Verificar inventario**: Los items deben permanecer

**Resultado Esperado**: ✅ Inventario persistente

## 7.3. Verificar Logs

```bash
ssh gabriel@<IP_VPS_ANTERIOR> "cd /home/gabriel/luanti-voxelibre-server && \
  docker-compose logs --tail=50 luanti-server | grep -i 'creative\|started\|listening'"
```

**Logs Correctos**:
```
Server for gameid="mineclone2" listening on [::]:30000.
```

**Logs Incorrectos** (no deben aparecer):
```
[creative_force] Player X joined
[creative_force] Granted privilege 'creative'
[creative_force] Filled inventory with XX items
```

---

# 8. Troubleshooting

## 8.1. Problema: Inventario Creativo No Aparece

**Síntomas**:
- Al presionar `E`, solo aparece inventario normal
- Sin pestaña de inventario creativo

**Diagnóstico**:
```bash
ssh gabriel@<IP_VPS_ANTERIOR> "cd /home/gabriel/luanti-voxelibre-server && \
  docker-compose exec -T luanti-server cat /config/.minetest/minetest.conf | grep mcl_enable_creative"
```

**Solución**:
```bash
# Verificar que esté en true
ssh gabriel@<IP_VPS_ANTERIOR> "cd /home/gabriel/luanti-voxelibre-server && \
  sed -i 's/mcl_enable_creative_mode = false/mcl_enable_creative_mode = true/' server/config/luanti.conf && \
  docker-compose restart luanti-server"
```

## 8.2. Problema: Jugadores Siguen Recibiendo Items Iniciales

**Síntomas**: Al conectar, aparecen 10 manzanas y 10 panes en el inventario

**Diagnóstico**:
```bash
ssh gabriel@<IP_VPS_ANTERIOR> "cd /home/gabriel/luanti-voxelibre-server && \
  docker-compose exec -T luanti-server cat /config/.minetest/minetest.conf | grep give_initial"
```

**Solución**:
```bash
ssh gabriel@<IP_VPS_ANTERIOR> "cd /home/gabriel/luanti-voxelibre-server && \
  sed -i 's/give_initial_stuff = true/give_initial_stuff = false/' server/config/luanti.conf && \
  sed -i 's/initial_stuff = .*/initial_stuff =/' server/config/luanti.conf && \
  docker-compose restart luanti-server"
```

## 8.3. Problema: Mod creative_force Sigue Activo

**Síntomas**: Logs muestran mensajes de `[creative_force]`

**Diagnóstico**:
```bash
ssh gabriel@<IP_VPS_ANTERIOR> "cd /home/gabriel/luanti-voxelibre-server && \
  docker-compose logs --tail=30 luanti-server | grep creative_force"
```

**Solución**:
```bash
# Mover mod fuera de directorio activo
ssh gabriel@<IP_VPS_ANTERIOR> "cd /home/gabriel/luanti-voxelibre-server && \
  mkdir -p server/mods_backup && \
  mv server/mods/creative_force* server/mods_backup/ && \
  docker-compose restart luanti-server"
```

## 8.4. Problema: Jugadores Reciben Daño

**Síntomas**: Jugadores mueren al caer desde altura

**Diagnóstico**:
```bash
ssh gabriel@<IP_VPS_ANTERIOR> "cd /home/gabriel/luanti-voxelibre-server && \
  docker-compose exec -T luanti-server cat /config/.minetest/minetest.conf | grep enable_damage"
```

**Solución**:
```bash
ssh gabriel@<IP_VPS_ANTERIOR> "cd /home/gabriel/luanti-voxelibre-server && \
  sed -i 's/enable_damage = true/enable_damage = false/' server/config/luanti.conf && \
  sed -i 's/damage_enabled = true/damage_enabled = false/' server/config/luanti.conf && \
  docker-compose restart luanti-server"
```

---

# 9. Historia del Cambio

## 9.1. Cronología

| Fecha | Evento |
|-------|--------|
| **2025-09-XX** | Implementación inicial de `creative_force` mod |
| **2025-10-XX** | Detección de bugs de persistencia de inventarios |
| **2026-01-15** | Experimento con modo survival mixto (pepelomo) |
| **2026-01-16** | **Bug crítico reportado**: Inventarios se resetean |
| **2026-01-16** | **Migración a modo creativo nativo** |
| **2026-01-16** | Documentación completa del cambio |

## 9.2. Razones del Cambio

### 9.2.1. Técnicas

- ✅ **Eliminar bugs de persistencia**: creative_force tenía memoria en RAM que se perdía
- ✅ **Simplificar arquitectura**: Reducir dependencias de código personalizado
- ✅ **Mejorar confiabilidad**: Usar sistema nativo probado de VoxeLibre
- ✅ **Facilitar mantenimiento**: Menos código = menos bugs potenciales

### 9.2.2. Experiencia del Usuario

- ✅ **Mejor UX**: Inventario creativo nativo es más intuitivo
- ✅ **Más items disponibles**: Acceso a TODOS los items, no solo 36
- ✅ **Sin frustraciones**: No más inventarios reseteados
- ✅ **Búsqueda rápida**: Barra de búsqueda integrada

## 9.3. Lecciones Aprendidas

### 9.3.1. No Reinventar la Rueda

**Antes**: Creamos un mod complejo para simular creatividad en modo survival.

**Lección**: VoxeLibre ya tiene un excelente modo creativo nativo. Usarlo directamente es:
- Más simple
- Más confiable
- Mejor documentado
- Mejor mantenido

### 9.3.2. Persistencia en RAM vs Disco

**Problema**: `players_with_kit` estaba en memoria RAM del servidor.

**Lección**: Cualquier estado crítico debe persistirse en disco (DB, archivos) o calcularse de forma determinística, nunca depender de memoria volátil.

### 9.3.3. Testear con Reinicio de Servidor

**Problema**: Bug solo aparecía al reiniciar servidor, no en uso continuo.

**Lección**: Siempre probar ciclos completos de reinicio en desarrollo antes de deployment.

---

## Referencias Internas

- **03-MIXED_GAMEMODE.md** - Documentación del sistema anterior (survival mixto)
- **04-VOXELIBRE_SYSTEM.md** - Sistema completo de VoxeLibre
- **CLAUDE.md** - Documentación principal del proyecto

---

## Referencias Externas

- **VoxeLibre Creative Mode**: https://git.minetest.land/VoxeLibre/VoxeLibre/wiki/Creative-Mode
- **Luanti Configuration**: https://wiki.minetest.net/Server_configuration

---

# 10. Conflicto Resuelto: Mod pvp_arena (2026-01-16)

## 10.1. Problema Detectado

Después de configurar el modo creativo nativo, los jugadores **seguían sin ver el inventario creativo**.

**Diagnóstico**: El mod `pvp_arena` tenía un `register_on_joinplayer` que:
1. Establecía `gamemode = "survival"` para TODOS los jugadores al conectar
2. REMOVÍA el privilegio `creative` de los jugadores

Esto sobrescribía toda la configuración de modo creativo.

## 10.2. Código Problemático (ANTES)

```lua
-- En server/mods/pvp_arena/init.lua (líneas 251-286)
minetest.register_on_joinplayer(function(player)
    local name = player:get_player_name()
    local meta = player:get_meta()
    local in_arena = pvp_arena.is_player_in_arena(name)

    if not in_arena then
        meta:set_string("gamemode", "survival")  -- ❌ FORZABA SURVIVAL

        local privs = minetest.get_player_privs(name)
        if privs.creative then
            privs.creative = nil  -- ❌ REMOVÍA CREATIVE
            minetest.set_player_privs(name, privs)
        end
    end
end)
```

## 10.3. Solución Aplicada (DESPUÉS)

```lua
-- En server/mods/pvp_arena/init.lua (líneas 251-282)
minetest.register_on_joinplayer(function(player)
    local name = player:get_player_name()
    local meta = player:get_meta()
    local in_arena = pvp_arena.is_player_in_arena(name)

    if not in_arena then
        meta:set_string("gamemode", "creative")  -- ✅ MODO CREATIVO

        local privs = minetest.get_player_privs(name)
        if not privs.creative then
            privs.creative = true  -- ✅ ASEGURA CREATIVE
            minetest.set_player_privs(name, privs)
        end
    end
end)
```

## 10.4. Lección Aprendida

**Los mods pueden interferir entre sí y con la configuración global.**

Para modo creativo completo en VoxeLibre se necesita:

| Componente | Configuración Requerida |
|------------|------------------------|
| `luanti.conf` | `creative_mode = true`, `mcl_enable_creative_mode = true` |
| `world.mt` | `creative_mode = true` |
| `default_privs` | Incluir `creative` |
| **Todos los mods** | NO establecer `gamemode = "survival"` al conectar |
| **Base de datos** | `user_privileges` debe incluir `creative` |
| **Player metadata** | `gamemode = "creative"` |

## 10.5. Verificación Rápida

Si el modo creativo no funciona, verificar:

```bash
# 1. Verificar privilegios del jugador
ssh gabriel@<IP_VPS_ANTERIOR> "cd /home/gabriel/luanti-voxelibre-server && \
  docker-compose exec -T luanti-server sqlite3 /config/.minetest/worlds/world/auth.sqlite \
  'SELECT privilege FROM user_privileges WHERE id=(SELECT id FROM auth WHERE name=\"JUGADOR\");'" | grep creative

# 2. Verificar gamemode en metadata
ssh gabriel@<IP_VPS_ANTERIOR> "cd /home/gabriel/luanti-voxelibre-server && \
  docker-compose exec -T luanti-server sqlite3 /config/.minetest/worlds/world/players.sqlite \
  'SELECT value FROM player_metadata WHERE player=\"JUGADOR\" AND metadata=\"gamemode\";'"

# 3. Buscar mods que establezcan survival
grep -r "gamemode.*survival" server/mods/*/init.lua
```

---

**Última actualización**: 2026-01-16
**Estado**: ✅ PRODUCCIÓN - Sistema estable y funcionando perfectamente
**Responsable**: Gabriel Pantoja (gabo)
**Servidor**: luanti.gabrielpantoja.cl:30000
