# 🏟️ Construcción de Arena PVP con WorldEdit - Guía Completa

**Servidor**: Wetlands 🌱 Luanti/VoxeLibre
**Arena**: Arena Principal
**Coordenadas**: Centro (41, 23, 232)
**Radio**: 25 bloques
**Fecha**: 26 de Octubre 2025
**Autor**: Gabriel Pantoja (gabo)

---

## 📋 Índice

1. [Especificaciones de la Arena](#-especificaciones-de-la-arena)
2. [Regenerar Suelo de Arenisca](#-regenerar-suelo-de-arenisca)
3. [Construcción Completa desde Cero](#-construcción-completa-desde-cero)
4. [Mantenimiento y Reparaciones](#-mantenimiento-y-reparaciones)
5. [Variaciones Estéticas](#-variaciones-estéticas)

---

## 📐 Especificaciones de la Arena

### Información Técnica

**Arena Principal** (documentada en `server/mods/pvp_arena/init.lua`):

```lua
{
    name = "Arena Principal",
    center = {x = 41, y = 23, z = 232},
    radius = 25,  -- Radio de 25 bloques = 51x51 área
    enabled = true,
    created_by = "gabo",
    created_at = os.time()
}
```

### Dimensiones

| Propiedad | Valor |
|-----------|-------|
| **Centro** | (41, 23, 232) |
| **Radio detección PVP** | 25 bloques |
| **Radio piso arenisca** | 24 bloques (recomendado) |
| **Área total** | 51×51 bloques (2,601 bloques²) |
| **Altura detección** | ±50 bloques desde Y=23 |

### Capas por Nivel Y

| Y | Descripción | Bloque |
|---|-------------|--------|
| **Y=24-26** | Vallas perimetrales (opcional) | `mcl_fences:fence` |
| **Y=23** | Nivel de spawn, superficie | `mcl_core:sandstone` |
| **Y=22** | **Piso principal** (suelo visible) | `mcl_core:sandstone` |
| **Y=21** | Capa intermedia (opcional) | `mcl_core:sandstone` |
| **Y=20** | Base sólida (opcional) | `mcl_core:stone` |

---

## 🎯 Regenerar Suelo de Arenisca

### Comando Básico (Más Común)

**Objetivo**: Regenerar solo el piso de arenisca sin tocar nada más

**✅ COMANDOS VERIFICADOS** (26 Oct 2025):

```lua
# 1. Teleportarse al nivel del suelo
/teleport 41 22 232

# 2. Marcar posición 1 (donde estás parado)
//pos1

# 3. Crear cilindro de arenisca (eje Y, altura 1, radio 24)
//cylinder y 1 24 mcl_core:sandstone
```

**Sintaxis**: `//cylinder <eje> <altura> <radio> <bloque>`
- `y` = eje vertical (círculo horizontal)
- `1` = altura en bloques
- `24` = radio desde pos1
- `mcl_core:sandstone` = tipo de bloque

**Tiempo**: ~5 segundos
**Bloques modificados**: ~1,810 bloques
**Resultado**: Piso circular uniforme de arenisca

### Variantes del Piso

**Piso hasta el borde de las vallas** (radio 25):
```lua
/teleport 41 22 232
//pos1
//cylinder y 1 25 mcl_core:sandstone
```

**Piso con múltiples capas** (más sólido):
```lua
# Superficie (Y=22)
/teleport 41 22 232
//pos1
//cylinder y 1 24 mcl_core:sandstone

# Capa inferior (Y=21)
/teleport 41 21 232
//pos1
//cylinder y 1 24 mcl_core:sandstone

# Base de piedra (Y=20)
/teleport 41 20 232
//pos1
//cylinder y 1 24 mcl_core:stone
```

---

## 🏗️ Construcción Completa desde Cero

### Fase 1: Limpiar Terreno

**Objetivo**: Eliminar todo en el área para empezar desde cero

```lua
# 1. Teleportarse al centro
/teleport 41 23 232

# 2. Marcar región cúbica grande (30 bloques radio, 50 bloques altura)
/1 11,0,202
/2 71,50,262

# 3. Limpiar TODO (convertir a aire)
/set air
```

**Advertencia**: Esto eliminará TODOS los bloques en el área, incluyendo construcciones existentes.

### Fase 2: Crear Piso Base

```lua
# Capa de piedra (base sólida, Y=20)
/1 41 20 232
/cylinder y 1 27 mcl_core:stone

# Capa de tierra (Y=21)
/1 41 21 232
/cylinder y 1 27 mcl_core:dirt

# Capa de césped (Y=22, fuera de la arena)
/1 41 22 232
/cylinder y 1 27 mcl_core:grass
```

### Fase 3: Piso de Arena (Arenisca)

```lua
# Piso distintivo de arenisca (radio 24, dentro del área PVP)
/1 41 22 232
/cylinder y 1 24 mcl_core:sandstone
```

### Fase 4: Delimitación Visual (Opcional)

**Línea de vidrio rojo** (marca el límite exacto):
```lua
/1 41 22 232
/hollowcylinder y 1 25 mcl_core:glass_red
```

**Vallas perimetrales** (3 bloques de altura):
```lua
/1 41 23 232
/hollowcylinder y 3 25 mcl_fences:fence
```

**Iluminación perimetral**:
```lua
/1 41 24 232
/hollowcylinder y 1 25 mcl_torches:torch
```

### Fase 5: Detalles Decorativos (Opcional)

**Postes en puntos cardinales**:

```lua
# Norte (Z=207)
/1 41 23 207
/cylinder y 5 1 mcl_fences:fence

# Sur (Z=257)
/1 41 23 257
/cylinder y 5 1 mcl_fences:fence

# Este (X=66)
/1 66 23 232
/cylinder y 5 1 mcl_fences:fence

# Oeste (X=16)
/1 16 23 232
/cylinder y 5 1 mcl_fences:fence
```

**Faroles en lo alto de los postes**:
```lua
/1 41 28 207
/set mcl_lanterns:lantern_floor

/1 41 28 257
/set mcl_lanterns:lantern_floor

/1 66 28 232
/set mcl_lanterns:lantern_floor

/1 16 28 232
/set mcl_lanterns:lantern_floor
```

---

## 🔧 Mantenimiento y Reparaciones

### Reparar Griefing en el Piso

**Problema**: Jugadores han destruido bloques del piso

**Solución Rápida**:
```lua
/teleport 41 23 232
/1 41 22 232
/cylinder y 1 24 mcl_core:sandstone
```

### Rellenar Agujeros Específicos

**Método 1: Manual** (para agujeros pequeños)
- Volar al agujero
- Colocar bloques de arenisca manualmente (modo creativo)

**Método 2: WorldEdit** (para áreas grandes)
```lua
# Marcar área afectada
/1 <esquina1>
/2 <esquina2>

# Rellenar solo bloques de aire (no sobrescribir otros bloques)
/replace air mcl_core:sandstone
```

### Cambiar Material del Piso

**De arenisca a arena del desierto**:
```lua
/1 41 22 232
/cylinder y 1 24 mcl_core:sand
```

**De arenisca a netherrack** (dramático):
```lua
/1 41 22 232
/cylinder y 1 24 mcl_nether:netherrack
```

**De arenisca a piedra pulida**:
```lua
/1 41 22 232
/cylinder y 1 24 mcl_core:stonebrickcarved
```

### Reparar Vallas Perimetrales

**Regenerar vallas completas**:
```lua
/1 41 23 232
/hollowcylinder y 3 25 mcl_fences:fence
```

**Solo reparar vallas rotas** (preservar otras):
```lua
# Marcar área de vallas
/1 16 23 207
/2 66 26 257

# Reemplazar solo bloques de aire por vallas
/replace air mcl_fences:fence
```

### Limpiar Bloques No Deseados

**Eliminar TNT colocado**:
```lua
/1 16 22 207
/2 66 26 257
/replace mcl_tnt:tnt air
```

**Eliminar bloques de jugadores** (dejar solo arenisca):
```lua
/1 41 22 232
/2 41 22 232
/cylinder y 1 24 mcl_core:sandstone
# Esto sobrescribe TODO con arenisca
```

---

## 🎨 Variaciones Estéticas

### Opción 1: Arena Clásica (Arenisca Amarilla)

```lua
/1 41 22 232
/cylinder y 1 24 mcl_core:sandstone
```

**Características**:
- Color amarillo/beige claro
- Tema clásico de arena de combate
- Alta visibilidad

### Opción 2: Arena del Desierto (Arena)

```lua
/1 41 22 232
/cylinder y 1 24 mcl_core:sand
```

**Características**:
- Color amarillo arena natural
- Más suave visualmente
- Tema desértico

### Opción 3: Arena Roja (Arenisca Roja)

```lua
/1 41 22 232
/cylinder y 1 24 mcl_core:redsandstone
```

**Características**:
- Color rojo/naranja
- Más dramático y llamativo
- Tema de cañón/desierto rojo

### Opción 4: Arena del Nether (Netherrack)

```lua
/1 41 22 232
/cylinder y 1 24 mcl_nether:netherrack
```

**Características**:
- Color rojo oscuro/carmesí
- Muy dramático y agresivo
- Tema infernal/épico

### Opción 5: Arena de Piedra Pulida

```lua
/1 41 22 232
/cylinder y 1 24 mcl_core:stonebrickcarved
```

**Características**:
- Color gris con detalles tallados
- Aspecto profesional y refinado
- Tema de coliseo romano

### Opción 6: Patrón Ajedrezado (Avanzado)

**Paso 1: Crear base de arenisca**
```lua
/1 41 22 232
/cylinder y 1 24 mcl_core:sandstone
```

**Paso 2: Reemplazar 50% con otro material**
```lua
/1 41 22 232
/2 65 22 256
/replace mcl_core:sandstone 50% mcl_core:redsandstone
```

**Resultado**: Patrón aleatorio de arenisca amarilla y roja

### Opción 7: Anillos Concéntricos

**Anillo exterior** (radio 24):
```lua
/1 41 22 232
/cylinder y 1 24 mcl_core:sandstone
```

**Anillo medio** (radio 18):
```lua
/1 41 22 232
/cylinder y 1 18 mcl_core:redsandstone
```

**Centro** (radio 10):
```lua
/1 41 22 232
/cylinder y 1 10 mcl_core:stonebrickcarved
```

**Resultado**: Tres anillos concéntricos de diferentes materiales

---

## 🛠️ Comandos de Referencia Rápida

### Regeneración Básica

```lua
# Teleportarse a la arena
/teleport 41 23 232

# Solo regenerar piso
/1 41 22 232
/cylinder y 1 24 mcl_core:sandstone
```

### Construcción Completa Rápida

```lua
# Limpiar área
/1 11,0,202
/2 71,50,262
/set air

# Base de piedra
/1 41 20 232
/cylinder y 1 27 mcl_core:stone

# Tierra
/1 41 21 232
/cylinder y 1 27 mcl_core:dirt

# Césped
/1 41 22 232
/cylinder y 1 27 mcl_core:grass

# Piso de arenisca
/1 41 22 232
/cylinder y 1 24 mcl_core:sandstone

# Línea de vidrio rojo
/1 41 22 232
/hollowcylinder y 1 25 mcl_core:glass_red

# Vallas
/1 41 23 232
/hollowcylinder y 3 25 mcl_fences:fence

# Antorchas
/1 41 24 232
/hollowcylinder y 1 25 mcl_torches:torch
```

### Deshacer Cambios

```lua
# Deshacer última operación
/undo

# Deshacer múltiples operaciones
/undo
/undo
/undo
```

---

## 📊 Materiales Necesarios

### Construcción Completa

| Material | Cantidad Aproximada |
|----------|---------------------|
| **Piedra** | ~2,290 bloques |
| **Tierra** | ~2,290 bloques |
| **Césped** | ~2,290 bloques |
| **Arenisca** | ~1,810 bloques |
| **Vidrio Rojo** | ~157 bloques |
| **Vallas** | ~471 bloques (3 capas) |
| **Antorchas** | ~157 unidades |
| **Faroles** | 4 unidades (postes) |

### Solo Piso

| Material | Cantidad |
|----------|----------|
| **Arenisca** | ~1,810 bloques |

**Nota**: En modo creativo, no necesitas recolectar materiales manualmente.

---

## 🚨 Advertencias Importantes

### Antes de Limpiar el Área

⚠️ **ADVERTENCIA**: El comando `/set air` eliminará **TODOS** los bloques en la región seleccionada, incluyendo:
- Construcciones de jugadores
- Items en cofres
- Decoraciones existentes
- Vallas, antorchas, señales

**Recomendación**: Siempre hacer backup antes de limpiar:
```bash
# En el VPS
cd $PROJECT_PATH
./scripts/backup.sh
```

### Lag del Servidor

⚠️ **ADVERTENCIA**: Operaciones muy grandes pueden causar lag temporal

**Operación segura**: <10,000 bloques (sin lag notable)
**Operación grande**: 10,000-50,000 bloques (lag leve 2-5s)
**Operación masiva**: >50,000 bloques (lag severo 10-30s)

**Recomendación**: Avisar a jugadores antes de operaciones grandes:
```lua
/announce Realizando mantenimiento de arena, puede haber lag breve
```

### Privilegios Necesarios

Para usar WorldEdit necesitas el privilegio `worldedit`:

```lua
# Verificar privilegios
/privs

# Si no tienes worldedit, otorgarlo
/grant gabo worldedit
```

---

## 📖 Referencias

- **Mod PVP Arena**: `server/mods/pvp_arena/`
- **Documentación WorldEdit**: `docs/mods/WORLDEDIT_SYSTEM.md`
- **Comandos de Arena**: `server/mods/pvp_arena/commands.lua`
- **Configuración Arena**: `server/mods/pvp_arena/init.lua`

---

**Última Actualización**: 26 de Octubre 2025
**Versión**: 1.0.0
**Autor**: Gabriel Pantoja (gabo)
**Licencia**: MIT