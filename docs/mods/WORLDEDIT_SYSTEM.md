# 🛠️ WorldEdit System - Documentación Completa

**Servidor**: Wetlands 🌱 Luanti/VoxeLibre
**Fecha**: 26 de Octubre 2025
**Autor**: Gabriel Pantoja (gabo)

---

## 📋 Índice

1. [Arquitectura del Sistema WorldEdit](#-arquitectura-del-sistema-worldedit)
2. [Interacción Entre Mods](#-interacción-entre-mods)
3. [Comandos Esenciales](#-comandos-esenciales)
4. [Uso Específico: Arena PVP](#-uso-específico-arena-pvp)
5. [Troubleshooting](#-troubleshooting)

---

## 🏗️ Arquitectura del Sistema WorldEdit

WorldEdit está compuesto por **5 mods modulares** que trabajan en conjunto:

```
worldedit (mod base)
    ├── worldedit_commands (comandos de chat)
    │   ├── worldedit_shortcommands (atajos)
    │   └── worldedit_gui (interfaz gráfica)
    └── worldedit_brush (pinceles)
```

### 1. `worldedit` - Mod Base (Core API)

**Responsabilidad**: Proporciona la API central y funcionalidades básicas

**Ubicación**: `server/mods/worldedit/`

**Características**:
- API de manipulación de regiones
- Sistema de selección de posiciones
- Funciones geométricas (esferas, cilindros, etc.)
- Sistema de deshacer/rehacer
- Serialización y deserialización de regiones

**Dependencias**: Ninguna (mod independiente)

**mod.conf**:
```ini
name = worldedit
description = WorldEdit main functionality & API
```

### 2. `worldedit_commands` - Comandos de Chat

**Responsabilidad**: Implementa todos los comandos de chat (`//pos1`, `//set`, etc.)

**Ubicación**: `server/mods/worldedit_commands/`

**Características**:
- Comandos de selección (`//pos1`, `//pos2`)
- Comandos de modificación (`//set`, `//replace`)
- Comandos de formas (`//sphere`, `//cylinder`)
- Comandos de copiar/pegar (`//copy`, `//paste`)
- Comandos de utilidades (`//undo`, `//redo`)

**Dependencias**: `worldedit` (mod base)

**mod.conf**:
```ini
name = worldedit_commands
description = WorldEdit chat commands
depends = worldedit
```

### 3. `worldedit_shortcommands` - Atajos de Comandos

**Responsabilidad**: Proporciona atajos más cortos para comandos frecuentes

**Ubicación**: `server/mods/worldedit_shortcommands/`

**Características**:
- `/1` = `//pos1`
- `/2` = `//pos2`
- `/set` = `//set`
- `/cylinder` = `//cylinder`
- `/hollowcylinder` = `//hollowcylinder`

**Dependencias**: `worldedit_commands`

**mod.conf**:
```ini
name = worldedit_shortcommands
description = WorldEdit command short aliases
depends = worldedit_commands
```

**✅ IMPORTANTE**: En Wetlands usamos `worldedit_shortcommands`, por lo tanto los comandos llevan **una sola barra** (`/`) en vez de doble (`//`).

### 4. `worldedit_gui` - Interfaz Gráfica

**Responsabilidad**: Proporciona interfaz gráfica para WorldEdit (solo clientes locales)

**Ubicación**: `server/mods/worldedit_gui/`

**Características**:
- Menú de formspec para seleccionar operaciones
- Interfaz visual para configurar parámetros
- Integración con inventarios (`unified_inventory`, `sfinv`)

**Dependencias**: `worldedit`, `worldedit_commands`

**Dependencias Opcionales**: `unified_inventory`, `inventory_plus`, `sfinv`, `creative`, `smart_inventory`

**mod.conf**:
```ini
name = worldedit_gui
description = WorldEdit GUI
depends = worldedit, worldedit_commands
optional_depends = unified_inventory, inventory_plus, sfinv, creative, smart_inventory
```

**Estado en Wetlands**: ❌ **Deshabilitado** (no es necesario para servidor sin GUI)

### 5. `worldedit_brush` - Pinceles de Edición

**Responsabilidad**: Herramientas de pincel para editar el mundo

**Ubicación**: `server/mods/worldedit_brush/`

**Características**:
- Pinceles de esfera (brush sphere)
- Pinceles de cilindro (brush cylinder)
- Pinceles de cubo (brush cube)

**Dependencias**: `worldedit`, `worldedit_commands`

**mod.conf**:
```ini
name = worldedit_brush
description = WorldEdit brush
depends = worldedit, worldedit_commands
```

---

## 🔗 Interacción Entre Mods

### Diagrama de Dependencias

```
┌─────────────────────────────────────┐
│        worldedit (API Base)         │
│  • Funciones geométricas            │
│  • Sistema de selección             │
│  • Deshacer/rehacer                 │
└──────────────┬──────────────────────┘
               │
               ├──────────────┬──────────────┐
               │              │              │
               ▼              ▼              ▼
┌──────────────────┐  ┌──────────────┐  ┌──────────────┐
│ worldedit_       │  │ worldedit_   │  │ worldedit_   │
│ commands         │  │ brush        │  │ gui          │
│ • //pos1        │  │ • Pinceles   │  │ • Formspec   │
│ • //set         │  │ • Tools      │  │ • UI visual  │
└────────┬─────────┘  └──────────────┘  └──────────────┘
         │
         ▼
┌──────────────────┐
│ worldedit_       │
│ shortcommands    │
│ • /1 = //pos1   │
│ • /2 = //pos2   │
└──────────────────┘
```

### Flujo de Ejecución de un Comando

**Ejemplo**: Ejecutar `/set mcl_core:sandstone`

```
1. Jugador: /set mcl_core:sandstone
             ↓
2. worldedit_shortcommands: Intercepta comando "/set"
             ↓
3. worldedit_shortcommands: Traduce a "//set mcl_core:sandstone"
             ↓
4. worldedit_commands: Procesa comando "//set"
             ↓
5. worldedit_commands: Valida selección de región
             ↓
6. worldedit (API): worldedit.set(pos1, pos2, "mcl_core:sandstone")
             ↓
7. worldedit (API): Modifica bloques en el mundo
             ↓
8. worldedit (API): Guarda en historial para //undo
             ↓
9. Jugador: Recibe confirmación en chat
```

### Comunicación Entre Mods

**API Pública de `worldedit`**:
```lua
-- Desde worldedit_commands o cualquier otro mod
worldedit.pos1[player_name] = {x=41, y=22, z=232}
worldedit.pos2[player_name] = {x=66, y=22, z=257}

worldedit.set(pos1, pos2, "mcl_core:sandstone")
worldedit.cylinder(pos, axis, length, radius, nodename)
worldedit.hollow_cylinder(pos, axis, length, radius, nodename)
```

**Registro de Comandos**:
```lua
-- worldedit_commands/init.lua
worldedit.register_command("set", {
    params = "<node>",
    description = "Set all nodes in the region",
    privs = {worldedit=true},
    func = function(name, param)
        -- Lógica del comando
    end
})

-- worldedit_shortcommands/init.lua
minetest.register_chatcommand("/set", {
    params = "<node>",
    func = function(name, param)
        return minetest.registered_chatcommands["//set"].func(name, param)
    end
})
```

---

## 🎯 Comandos Esenciales

### Sintaxis General

**Con worldedit_shortcommands** (activado en Wetlands):
```lua
/comando <parámetros>
```

**Sin worldedit_shortcommands** (vanilla):
```lua
//comando <parámetros>
```

### Comandos de Selección

| Comando | Descripción | Ejemplo |
|---------|-------------|---------|
| `/1` | Marcar posición 1 (donde estás) | `/1` |
| `/2` | Marcar posición 2 (donde estás) | `/2` |
| `/1 <x,y,z>` | Marcar posición 1 en coordenadas | `/1 41,22,232` |
| `/2 <x,y,z>` | Marcar posición 2 en coordenadas | `/2 66,22,257` |
| `/volume` | Ver volumen de región seleccionada | `/volume` |

### Comandos de Modificación

| Comando | Descripción | Ejemplo |
|---------|-------------|---------|
| `/set <nodo>` | Rellenar región con un bloque | `/set mcl_core:sandstone` |
| `/replace <viejo> <nuevo>` | Reemplazar bloques | `/replace mcl_core:stone mcl_core:cobble` |
| `/set air` | Vaciar región (eliminar bloques) | `/set air` |

### Comandos de Formas Geométricas

| Comando | Descripción | Sintaxis |
|---------|-------------|----------|
| `/cylinder` | Cilindro sólido | `/cylinder <eje> <altura> <radio> <nodo>` |
| `/hollowcylinder` | Cilindro hueco | `/hollowcylinder <eje> <altura> <radio> <nodo>` |
| `/sphere` | Esfera sólida | `/sphere <radio> <nodo>` |
| `/hollowsphere` | Esfera hueca | `/hollowsphere <radio> <nodo>` |

**Ejes válidos**: `x`, `y`, `z`
- `y` = eje vertical (círculo horizontal)
- `x` = eje horizontal este-oeste (círculo vertical)
- `z` = eje horizontal norte-sur (círculo vertical)

### Comandos de Utilidades

| Comando | Descripción |
|---------|-------------|
| `/undo` | Deshacer última operación |
| `/redo` | Rehacer operación deshecha |
| `/clearhistory` | Limpiar historial de cambios |

---

## ⚔️ Uso Específico: Arena PVP

### Información de la Arena Principal

**Coordenadas del Centro**: `(41, 23, 232)`
**Radio**: 25 bloques
**Área**: 51x51 bloques (2,601 bloques²)

### Regenerar Suelo de Arenisca

**Objetivo**: Crear un piso uniforme de arenisca en la arena de combate

**✅ COMANDOS VERIFICADOS** (26 Octubre 2025):

```lua
# 1. Teleportarse al centro de la arena
/teleport 41 23 232

# 2. Marcar posición en el nivel del suelo (Y=22)
/1 41 22 232

# 3. Crear cilindro de arenisca (eje Y, altura 1, radio 24)
/cylinder y 1 24 mcl_core:sandstone
```

**Resultado**: Piso circular de arenisca de 24 bloques de radio (dentro del perímetro de vallas)

### Variaciones del Suelo

**Arenisca hasta el borde de las vallas** (radio 25):
```lua
/cylinder y 1 25 mcl_core:sandstone
```

**Arenisca roja** (más dramático):
```lua
/cylinder y 1 24 mcl_core:redsandstone
```

**Arenisca lisa** (más refinado):
```lua
/cylinder y 1 24 mcl_core:sandstonesmooth
```

**Piedra pulida**:
```lua
/cylinder y 1 24 mcl_core:stonebrickcarved
```

**Arena del desierto**:
```lua
/cylinder y 1 24 mcl_core:sand
```

### Crear Múltiples Capas de Profundidad

Si quieres un piso más sólido (3 bloques de profundidad):

```lua
# Capa 1 (Y=22, superficie)
/1 41 22 232
/cylinder y 1 24 mcl_core:sandstone

# Capa 2 (Y=21, debajo)
/1 41 21 232
/cylinder y 1 24 mcl_core:sandstone

# Capa 3 (Y=20, base)
/1 41 20 232
/cylinder y 1 24 mcl_core:stone
```

### Deshacer Cambios

Si no te gusta el resultado:
```lua
/undo
```

---

## 🐛 Troubleshooting

### Problema 1: Comando No Reconocido

**Síntoma**: `Unknown command: /1`

**Causa**: `worldedit_shortcommands` no está cargado

**Solución**: Usar sintaxis con doble barra
```lua
//pos1
//pos2
//cylinder y 1 24 mcl_core:sandstone
```

### Problema 2: "You don't have permission"

**Síntoma**: `You don't have permission to run this command`

**Causa**: Falta privilegio `worldedit`

**Solución**: Otorgar privilegio
```bash
# Desde el VPS
ssh gabriel@<VPS_IP>
cd /home/gabriel/luanti-voxelibre-server
docker compose exec -T luanti-server sqlite3 /config/.minetest/worlds/world/auth.sqlite \
"INSERT OR IGNORE INTO user_privileges (id, privilege)
SELECT id, 'worldedit' FROM auth WHERE name='gabo';"

# Reiniciar servidor
docker compose restart luanti-server
```

### Problema 3: "No region selected"

**Síntoma**: `No region selected`

**Causa**: No has marcado posiciones con `/1` y `/2`

**Solución**: Marcar al menos `/1` para comandos de forma
```lua
/1 41 22 232
/cylinder y 1 24 mcl_core:sandstone
```

### Problema 4: Bloque No Existe

**Síntoma**: `Invalid node name: default:sandstone`

**Causa**: Nombre de bloque incorrecto (Minetest vanilla vs VoxeLibre)

**Solución**: Usar nombres VoxeLibre
```lua
# ❌ Incorrecto (Minetest vanilla)
/set default:sandstone

# ✅ Correcto (VoxeLibre)
/set mcl_core:sandstone
```

### Problema 5: Operación Muy Lenta

**Síntoma**: Servidor se congela durante varios segundos

**Causa**: Operación muy grande (>100,000 bloques)

**Solución**:
1. Esperar a que termine (puede tomar 30-60 segundos)
2. Dividir en operaciones más pequeñas
3. Usar máscaras para reducir bloques afectados

```lua
# En vez de área 100x100x100 (1,000,000 bloques)
# Hacer 10 operaciones de 100x100x10 (100,000 bloques cada una)
```

---

## 📚 Bloques Comunes de VoxeLibre

### Construcción
```lua
mcl_core:stone              # Piedra
mcl_core:cobble             # Piedra labrada
mcl_core:stonebrick         # Ladrillo de piedra
mcl_core:stonebrickcarved   # Ladrillo de piedra tallado
mcl_core:sandstone          # Arenisca
mcl_core:redsandstone       # Arenisca roja
mcl_core:sandstonesmooth    # Arenisca lisa
```

### Vallas y Cercados
```lua
mcl_fences:fence                    # Valla de madera
mcl_fences:nether_brick_fence       # Valla de ladrillo del Nether
mcl_fences:fence_gate               # Puerta de valla
```

### Iluminación
```lua
mcl_torches:torch               # Antorcha
mcl_lanterns:lantern_floor      # Farol de suelo
mcl_core:glowstone              # Piedra luminosa
```

### Vidrio (Decoración)
```lua
mcl_core:glass          # Vidrio transparente
mcl_core:glass_red      # Vidrio rojo
mcl_core:glass_orange   # Vidrio naranja
mcl_core:glass_yellow   # Vidrio amarillo
mcl_core:glass_black    # Vidrio negro
```

### Terreno
```lua
mcl_core:dirt           # Tierra
mcl_core:grass          # Césped
mcl_core:sand           # Arena
mcl_core:gravel         # Grava
```

### Utilidades
```lua
air                     # Aire (eliminar bloques)
```

---

## 🔧 Configuración del Servidor

### Habilitar WorldEdit

**Archivo**: `server/config/luanti.conf`

```ini
# WorldEdit - Sistema de Edición de Mundos
load_mod_worldedit = true
load_mod_worldedit_commands = true
load_mod_worldedit_shortcommands = true
load_mod_worldedit_brush = true
# load_mod_worldedit_gui = false  # Solo para clientes locales

# Tamaño del historial de deshacer/rehacer
worldedit_history_size = 50

# Mods confiables (para operaciones de archivos)
secure.trusted_mods = worldedit
```

### Otorgar Privilegios Automáticamente

**Archivo**: `server/config/luanti.conf`

```ini
# Privilegios de administrador (incluye worldedit)
admin_privs = server,privs,ban,kick,teleport,give,settime,worldedit,fly,fast,noclip,debug,password,rollback_check
```

---

## 📖 Referencias

- **WorldEdit GitHub**: https://github.com/Uberi/Minetest-WorldEdit
- **WorldEdit Wiki**: https://github.com/Uberi/Minetest-WorldEdit/wiki
- **VoxeLibre ContentDB**: https://content.luanti.org/packages/Wuzzy/mineclone2/
- **Luanti Mod API**: https://github.com/minetest/minetest/blob/master/doc/lua_api.txt

---

**Última Actualización**: 26 de Octubre 2025
**Versión**: 1.0.0
**Autor**: Gabriel Pantoja (gabo)
**Licencia**: MIT