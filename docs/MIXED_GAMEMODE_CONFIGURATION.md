# Configuración de Modos de Juego Mixtos (Creativo + Supervivencia)

**Autor**: Gabriel Pantoja
**Fecha**: Enero 15, 2026
**Versión**: 1.0.0
**Servidor**: Wetlands Luanti/VoxeLibre

---

## 📋 Tabla de Contenidos

1. [Descripción General](#descripción-general)
2. [¿Cómo Funciona?](#cómo-funciona)
3. [Configuración Paso a Paso](#configuración-paso-a-paso)
4. [Agregar/Remover Jugadores](#agregarremover-jugadores)
5. [Deployment al Servidor](#deployment-al-servidor)
6. [Verificación y Troubleshooting](#verificación-y-troubleshooting)
7. [Casos de Uso](#casos-de-uso)

---

## Descripción General

Este sistema permite que **diferentes jugadores tengan modos de juego distintos** en el mismo mundo:

- **Modo Creativo**: Inventario infinito, vuelo, sin daño, construcción ilimitada
- **Modo Supervivencia**: Debe recolectar recursos, craftear, sobrevivir

### ✅ Beneficios

- **Coexistencia pacífica**: Jugadores de ambos modos pueden convivir en el mismo mundo
- **Flexibilidad educativa**: Algunos niños construyen libremente, otros aprenden supervivencia
- **Sistema automático**: Los mods detectan automáticamente el modo de cada jugador
- **Persistente**: La configuración se mantiene entre sesiones

---

## ¿Cómo Funciona?

El servidor usa **dos mods modificados** que verifican una **lista de excepciones**:

### 1. **creative_force** (Mod principal)
- Otorga modo creativo a TODOS por defecto
- **EXCEPTO** jugadores en la lista `survival_players`
- Ubicación: `server/mods/creative_force/init.lua`

### 2. **pvp_arena** (Mod secundario)
- También intenta otorgar modo creativo al unirse
- Debe tener la **misma lista** de excepciones
- Ubicación: `server/mods/pvp_arena/init.lua`

### Lista de Excepciones

Ambos mods usan esta estructura al inicio del archivo:

```lua
-- ⚠️ SURVIVAL MODE EXCEPTIONS - Players who should NOT get creative privileges
local survival_players = {
    ["pepelomo"] = true,  -- Requested to play in survival mode
    -- Agregar más jugadores aquí:
    -- ["jugador2"] = true,
    -- ["jugador3"] = true,
}
```

---

## Configuración Paso a Paso

### Paso 1: Modificar creative_force

**Archivo**: `server/mods/creative_force/init.lua`

1. **Agregar lista de excepciones** (línea 5-9):

```lua
-- ⚠️ SURVIVAL MODE EXCEPTIONS - Players who should NOT get creative privileges
local survival_players = {
    ["pepelomo"] = true,  -- Jugador en modo supervivencia
}
```

2. **Modificar función grant_creative_privileges** (línea 27-41):

```lua
local function grant_creative_privileges(player_name)
    -- Check if player is in survival exception list
    if survival_players[player_name] then
        minetest.log("info", "[creative_force] Player " .. player_name .. " is in SURVIVAL mode - skipping creative privileges")
        -- Grant only basic privileges for survival players
        local basic_privs = {"interact", "shout", "home", "spawn"}
        for _, priv in ipairs(basic_privs) do
            if not minetest.check_player_privs(player_name, {[priv] = true}) then
                local privs = minetest.get_player_privs(player_name)
                privs[priv] = true
                minetest.set_player_privs(player_name, privs)
            end
        end
        return false  -- Signal that creative mode was NOT granted
    end

    -- ... resto del código original
    return true  -- Signal that creative mode WAS granted
end
```

3. **Modificar función give_all_items_to_player**:

```lua
local function give_all_items_to_player(player)
    local player_name = player:get_player_name()

    -- Skip if player is in survival mode
    if survival_players[player_name] then
        minetest.log("info", "[creative_force] Player " .. player_name .. " is in SURVIVAL mode - no starter kit given")
        return
    end

    -- ... resto del código original
end
```

4. **Actualizar mensajes de bienvenida**:

```lua
-- Send appropriate welcome message
minetest.after(2.0, function()
    if player and player:is_player() then
        if survival_players[player_name] then
            minetest.chat_send_player(player_name, "⚔️ ¡Bienvenido a Wetlands en MODO SUPERVIVENCIA! Deberás recolectar recursos, craftear herramientas y sobrevivir. ¡Buena suerte!")
        else
            minetest.chat_send_player(player_name, "🌱 ¡Bienvenido a Wetlands! Modo creativo activado - construye, explora y aprende sin límites.")
        end
    end
end)
```

### Paso 2: Modificar pvp_arena

**Archivo**: `server/mods/pvp_arena/init.lua`

1. **Agregar la MISMA lista de excepciones** (línea 5-9):

```lua
-- ⚠️ SURVIVAL MODE EXCEPTIONS - Players who should NOT get creative privileges
local survival_players = {
    ["pepelomo"] = true,  -- Requested to play in survival mode
}
```

2. **Modificar register_on_joinplayer** (línea 250-275):

```lua
minetest.register_on_joinplayer(function(player)
    local name = player:get_player_name()
    local meta = player:get_meta()

    local in_arena = pvp_arena.is_player_in_arena(name)

    if not in_arena then
        -- Check if player is in survival exception list
        if survival_players[name] then
            -- SURVIVAL MODE: No creative privileges
            meta:set_string("gamemode", "survival")
            minetest.log("action", "[PVP Arena] Player " .. name .. " is in SURVIVAL mode - skipping creative")
        else
            -- Creative mode normal
            meta:set_string("gamemode", "creative")

            local privs = minetest.get_player_privs(name)
            if not privs.creative then
                privs.creative = true
                minetest.set_player_privs(name, privs)
                minetest.log("action", "[PVP Arena] Granted creative mode to " .. name)
            end
        end
    end
end)
```

---

## Agregar/Remover Jugadores

### ✅ Agregar Jugador a Modo Supervivencia

**En ambos archivos** (`creative_force/init.lua` y `pvp_arena/init.lua`):

```lua
local survival_players = {
    ["pepelomo"] = true,
    ["nuevo_jugador"] = true,  -- ⬅️ AGREGAR AQUÍ
}
```

### ❌ Remover Jugador de Modo Supervivencia

Simplemente comenta o elimina la línea:

```lua
local survival_players = {
    -- ["pepelomo"] = true,  -- ⬅️ COMENTADO = vuelve a creativo
}
```

### 🔄 Cambiar de Supervivencia a Creativo

1. Remover de la lista `survival_players`
2. Limpiar privilegios en base de datos:

```bash
ssh gabriel@<VPS_IP> "cd /home/gabriel/luanti-voxelibre-server && docker compose exec -T luanti-server sqlite3 /config/.minetest/worlds/world/auth.sqlite 'DELETE FROM user_privileges WHERE id=(SELECT id FROM auth WHERE name=\"jugador\");'"
```

3. Reiniciar servidor
4. El jugador recibirá privilegios creativos al reconectar

---

## Deployment al Servidor

### Opción 1: Deployment Automático (Recomendado)

```bash
# 1. Commit los cambios localmente
git add server/mods/creative_force/init.lua server/mods/pvp_arena/init.lua
git commit -m "feat: Agregar jugador X a modo supervivencia"
git push origin main

# 2. GitHub Actions despliega automáticamente
# Esperar ~2 minutos

# 3. Verificar en VPS
ssh gabriel@<VPS_IP> "cd /home/gabriel/luanti-voxelibre-server && docker compose logs --tail=20 luanti-server | grep -i 'survival\|creative'"
```

### Opción 2: Deployment Manual

```bash
# 1. Copiar creative_force
cat "c:\Users\gabri\Developer\luanti-voxelibre-server\server\mods\creative_force\init.lua" | ssh gabriel@<VPS_IP> "cat > /home/gabriel/luanti-voxelibre-server/server/mods/creative_force/init.lua"

# 2. Copiar pvp_arena
cat "c:\Users\gabri\Developer\luanti-voxelibre-server\server\mods\pvp_arena\init.lua" | ssh gabriel@<VPS_IP> "cat > /home/gabriel/luanti-voxelibre-server/server/mods/pvp_arena/init.lua"

# 3. Limpiar privilegios del jugador en supervivencia
ssh gabriel@<VPS_IP> "cd /home/gabriel/luanti-voxelibre-server && docker compose exec -T luanti-server sqlite3 /config/.minetest/worlds/world/auth.sqlite 'DELETE FROM user_privileges WHERE id=(SELECT id FROM auth WHERE name=\"pepelomo\");'"

# 4. Reiniciar servidor
ssh gabriel@<VPS_IP> "cd /home/gabriel/luanti-voxelibre-server && docker compose restart luanti-server"
```

---

## Verificación y Troubleshooting

### ✅ Verificar Privilegios de Jugador

**Opción 1: En el juego (como admin)**

```
/privs pepelomo
```

**Resultado esperado (Supervivencia)**:
```
interact, shout, home, spawn
```

**Resultado esperado (Creativo)**:
```
interact, shout, home, spawn, creative, give, fly, fast, noclip, teleport, ...
```

**Opción 2: Desde terminal**

```bash
ssh gabriel@<VPS_IP> "cd /home/gabriel/luanti-voxelibre-server && docker compose exec -T luanti-server sqlite3 /config/.minetest/worlds/world/auth.sqlite 'SELECT privilege FROM user_privileges WHERE id=(SELECT id FROM auth WHERE name=\"pepelomo\");'"
```

### 🔍 Revisar Logs del Servidor

```bash
ssh gabriel@<VPS_IP> "cd /home/gabriel/luanti-voxelibre-server && docker compose logs --tail=50 luanti-server | grep -i 'pepelomo\|survival\|creative_force\|pvp.*arena'"
```

**Logs correctos para jugador en supervivencia**:
```
[creative_force] Player pepelomo is in SURVIVAL mode - skipping creative privileges
[PVP Arena] Player pepelomo is in SURVIVAL mode - skipping creative
```

### 🚨 Problemas Comunes

#### Problema 1: Jugador sigue en creativo

**Causa**: Los mods siguen otorgando creative

**Solución**:
1. Verificar que la lista `survival_players` está en **AMBOS** mods
2. Limpiar privilegios en base de datos:
```bash
ssh gabriel@<VPS_IP> "cd /home/gabriel/luanti-voxelibre-server && docker compose exec -T luanti-server sqlite3 /config/.minetest/worlds/world/auth.sqlite 'DELETE FROM user_privileges WHERE id=(SELECT id FROM auth WHERE name=\"jugador\");'"
```
3. Reiniciar servidor
4. Pedir al jugador que se desconecte y vuelva a entrar

#### Problema 2: Jugador no puede interactuar

**Causa**: Privilegios no configurados correctamente

**Solución**: Otorgar privilegios básicos manualmente
```
/grant jugador interact
/grant jugador shout
/grant jugador home
/grant jugador spawn
```

#### Problema 3: Cambios no aplican

**Causa**: Código Lua no se recargó

**Solución**: Siempre reiniciar el servidor después de modificar archivos `.lua`:
```bash
ssh gabriel@<VPS_IP> "cd /home/gabriel/luanti-voxelibre-server && docker compose restart luanti-server"
```

---

## Casos de Uso

### Caso 1: Maestro + Estudiantes

**Escenario**: Profesor quiere construir libremente, estudiantes deben recolectar recursos

```lua
local survival_players = {
    ["estudiante1"] = true,
    ["estudiante2"] = true,
    ["estudiante3"] = true,
    -- profesor NO está en la lista = modo creativo
}
```

### Caso 2: Builders + Survival Players

**Escenario**: Algunos niños construyen la ciudad, otros sobreviven en ella

```lua
local survival_players = {
    ["aventurero1"] = true,
    ["explorador2"] = true,
    -- builders NO están en la lista = modo creativo
}
```

### Caso 3: Desafío de Supervivencia

**Escenario**: Un niño pide desafío de supervivencia temporalmente

```lua
local survival_players = {
    ["pepelomo"] = true,  -- Desafío por 1 semana
}
```

Después de una semana:
```lua
local survival_players = {
    -- ["pepelomo"] = true,  -- ⬅️ COMENTADO = vuelve a creativo
}
```

### Caso 4: Modo Creativo por Defecto

**Escenario**: TODOS en creativo EXCEPTO algunos jugadores específicos (configuración actual)

```lua
-- Lista vacía = TODOS en creativo
local survival_players = {}

-- O con excepciones
local survival_players = {
    ["jugador_especial"] = true,  -- Solo este jugador en supervivencia
}
```

---

## Resumen de Archivos Críticos

### 1. creative_force/init.lua
- **Líneas clave**: 5-9 (lista de excepciones), 27-53 (grant_creative_privileges), 55-67 (give_all_items_to_player)
- **Función**: Otorga privilegios creativos a nuevos jugadores
- **Frecuencia de cambio**: Cada vez que se agrega/remueve jugador de supervivencia

### 2. pvp_arena/init.lua
- **Líneas clave**: 5-9 (lista de excepciones), 250-280 (register_on_joinplayer)
- **Función**: Previene que PVP Arena otorgue creative
- **Frecuencia de cambio**: Debe cambiar junto con creative_force

### 3. Base de datos SQLite
- **Ubicación**: `server/worlds/world/auth.sqlite`
- **Tabla**: `user_privileges`
- **Función**: Almacena privilegios persistentes de cada jugador
- **Cuándo limpiar**: Al cambiar un jugador de modo supervivencia a creativo

---

## Notas Importantes

1. **⚠️ SIEMPRE modificar AMBOS mods**: creative_force Y pvp_arena deben tener la misma lista
2. **🔄 Reiniciar servidor**: Los cambios en código Lua requieren reinicio del servidor
3. **👤 Jugador debe reconectar**: Para que los cambios apliquen, el jugador debe desconectarse y volver a entrar
4. **💾 Backup antes de cambios**: Siempre hacer backup de la base de datos antes de modificar privilegios masivamente
5. **📝 Documentar cambios**: Anotar en commits de Git qué jugadores cambiaron de modo y por qué

---

## Checklist de Deployment

Usa esta checklist cada vez que agregues/remuevas un jugador:

- [ ] Modificar `creative_force/init.lua` con la lista actualizada
- [ ] Modificar `pvp_arena/init.lua` con la MISMA lista
- [ ] Limpiar privilegios del jugador en base de datos (si cambió de survival a creative)
- [ ] Commit y push a repositorio
- [ ] Esperar deployment automático O hacer deployment manual
- [ ] Reiniciar servidor
- [ ] Pedir al jugador que se desconecte y vuelva a entrar
- [ ] Verificar privilegios con `/privs jugador`
- [ ] Revisar logs del servidor para confirmar modo correcto
- [ ] Notificar al jugador sobre su nuevo modo de juego

---

## Contacto y Soporte

**Autor**: Gabriel Pantoja (gabo)
**Servidor**: luanti.gabrielpantoja.cl:30000
**Repository**: https://github.com/gabrielpantoja-cl/luanti-voxelibre-server

Para preguntas o problemas, revisar:
- `docs/VOXELIBRE_MOD_SYSTEM.md` - Sistema de mods de VoxeLibre
- `docs/mods/MODDING_GUIDE.md` - Guía general de modding
- `CLAUDE.md` - Documentación principal del proyecto

---

**Última actualización**: Enero 15, 2026
**Estado**: ✅ Sistema probado y funcionando en producción con pepelomo en modo supervivencia
