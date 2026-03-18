# 🛠️ WorldEdit para VoxeLibre - Guía Completa del Administrador

**Versión**: WorldEdit 1.3+ para Luanti/VoxeLibre
**Fecha**: 20 de Octubre 2025
**Servidor**: Wetlands 🌱 Luanti/VoxeLibre
**Autor**: Gabriel Pantoja (gabo)

---

## 📋 Índice

1. [¿Qué es WorldEdit?](#-qué-es-worldedit)
2. [Instalación y Configuración](#-instalación-y-configuración)
3. [Conceptos Fundamentales](#-conceptos-fundamentales)
4. [Comandos Básicos](#-comandos-básicos)
5. [Comandos Avanzados](#-comandos-avanzados)
6. [Uso Específico para Arena PvP](#-uso-específico-para-arena-pvp)
7. [Compatibilidad con VoxeLibre](#-compatibilidad-con-voxelibre)
8. [Casos de Uso Prácticos](#-casos-de-uso-prácticos)
9. [Troubleshooting](#-troubleshooting)

---

## 🔍 ¿Qué es WorldEdit?

World Edit es una **herramienta poderosa de edición de mundos** para Luanti (Minetest) que permite a los administradores:

✅ **Crear estructuras masivas** en segundos (círculos, esferas, cilindros)
✅ **Modificar grandes áreas** del mundo (copiar, pegar, reemplazar bloques)
✅ **Delimitar zonas** para construcción y protección
✅ **Automatizar tareas repetitivas** de construcción
✅ **Deshacer/rehacer cambios** para experim entar sin miedo

### Casos de Uso en Wetlands

- **Delimitar Arena PvP**: Crear cercados circulares con vallas
- **Cambiar pisos masivamente**: Reemplazar terreno dentro de arena
- **Crear estructuras decorativas**: Torres, murallas, señalización
- **Iluminación perimetral**: Colocar faroles/antorchas en patrones
- **Reparación rápida**: Deshacer griefing o errores de construcción

---

## 📥 Instalación y Configuración

### Instalación del Mod

**Opción 1: Desde ContentDB** (Recomendado)
```bash
# Conectarse al servidor
ssh gabriel@<IP_VPS_ANTERIOR>

# Navegar a directorio de mods
cd /home/gabriel/luanti-voxelibre-server/server/mods/

# Descargar WorldEdit
wget https://content.luanti.org/packages/sfan5/worldedit/releases/latest/download/ -O worldedit.zip

# Extraer
unzip worldedit.zip
mv worldedit-* worldedit

# Limpiar
rm worldedit.zip
```

**Opción 2: Git Clone**
```bash
cd /home/gabriel/luanti-voxelibre-server/server/mods/
git clone https://github.com/Uberi/Minetest-WorldEdit.git worldedit
```

### Habilitar el Mod

Editar `server/config/luanti.conf`:
```ini
# WorldEdit Configuration
load_mod_worldedit = true
load_mod_worldedit_commands = true
load_mod_worldedit_gui = false  # GUI solo para clientes locales

# Mods confiables (necesario para operaciones de archivos)
secure.trusted_mods = worldedit
```

### Otorgar Privilegios

```lua
-- En el juego como admin:
/grant gabo worldedit
/grant Gapi worldedit

-- Verificar privilegios
/privs
# Debe mostrar: worldedit
```

**Privilegio worldedit permite**:
- Usar todos los comandos de WorldEdit (`//` prefix)
- Definir regiones y selecciones
- Modificar el mundo dentro de áreas seleccionadas
- Deshacer/rehacer cambios

### Reiniciar Servidor

```bash
# En el VPS
docker-compose restart luanti-server

# Verificar carga
docker-compose logs luanti-server | grep -i worldedit
```

---

## 💡 Conceptos Fundamentales

### Sistema de Posiciones

WorldEdit trabaja con **dos posiciones** que definen una **región rectangular** (cuboid):

```
     Posición 2 (//pos2)
            ┌────────────┐
            │            │
            │   Región   │
            │            │
            └────────────┘
     Posición 1 (//pos1)
```

**Comandos de posicionamiento**:
- `//pos1`: Establecer posición 1 en tu ubicación actual
- `//pos2`: Establecer posición 2 en tu ubicación actual
- `//pos1 x,y,z`: Establecer posición 1 en coordenadas específicas
- `//pos2 x,y,z`: Establecer posición 2 en coordenadas específicas

### Formas Geométricas

WorldEdit soporta múltiples formas:

| Forma | Comando | Uso |
|-------|---------|-----|
| **Cubo** | `//set` | Rellenar región cúbica |
| **Esfera** | `//sphere` | Crear esfera sólida |
| **Esfera hueca** | `//hollowsphere` | Crear esfera hueca |
| **Cilindro** | `//cyl` | Crear cilindro sólido |
| **Cilindro hueco** | `//hollowcyl` | Crear cilindro hueco |
| **Pirámide** | `//pyramid` | Crear pirámide |
| **Cúpula** | `//dome` | Crear cúpula hemisférica |

### Nombres de Bloques en VoxeLibre

WorldEdit usa nombres técnicos de bloques (item strings):

**Bloques Comunes**:
```lua
-- Construcción
mcl_core:stone         -- Piedra
mcl_core:cobble        -- Piedra labrada
mcl_core:wood          -- Madera de roble
mcl_core:glass         -- Vidrio transparente
mcl_core:glass_red     -- Vidrio rojo
mcl_core:sandstone     -- Arenisca
mcl_nether:netherrack  -- Netherrack

-- Vallas y cercados
mcl_fences:fence       -- Valla de madera
mcl_fences:nether_brick_fence  -- Valla de ladrillo del Nether

-- Iluminación
mcl_torches:torch      -- Antorcha
mcl_lanterns:lantern_floor  -- Farol de suelo

-- Aire (para eliminar bloques)
air                    -- Aire vacío
```

**Encontrar nombres de bloques**:
```lua
-- En el juego:
/lua local item = minetest.get_wielded_item(minetest.get_player_by_name("gabo"))
minetest.chat_send_all(item:get_name())

-- Te muestra el nombre técnico del bloque que tienes en la mano
```

### Máscaras (Masks)

Las máscaras permiten **filtrar qué bloques se afectan**:

```lua
-- Solo modificar bloques de aire
//gmask air

-- Solo modificar bloques de piedra
//gmask mcl_core:stone

-- Modificar múltiples tipos
//gmask mcl_core:stone,mcl_core:cobble

-- Modificar todo EXCEPTO ciertos bloques
//gmask !mcl_core:stone

-- Quitar máscara (modificar todo)
//gmask none
```

---

## 🎨 Comandos Básicos

### Selección de Región

```lua
-- Método 1: Posicionamiento manual
//pos1          -- Marcar posición 1 donde estás parado
//pos2          -- Marcar posición 2 donde estás parado

-- Método 2: Coordenadas específicas
//pos1 100,20,200
//pos2 150,40,250

-- Verificar selección actual
//volume        -- Muestra volumen seleccionado
//size          -- Muestra dimensiones de la región
```

### Rellenar y Vaciar

```lua
-- Rellenar región con un bloque
//set mcl_core:stone

-- Reemplazar un bloque por otro
//replace mcl_core:stone mcl_core:cobble

-- Llenar solo bloques de aire (no sobrescribir)
//gmask air
//set mcl_core:glass

-- Vaciar región (convertir a aire)
//set air
```

### Formas Básicas

```lua
-- Crear esfera sólida de radio 10
//sphere mcl_core:stone 10

-- Crear esfera hueca de radio 10
//hollowsphere mcl_core:glass 10

-- Crear cilindro sólido (radio 5, altura 10)
//cyl mcl_core:cobble 5 10

-- Crear cilindro hueco
//hollowcyl mcl_fences:fence 5 10
```

### Deshacer y Rehacer

```lua
-- Deshacer última operación
//undo

-- Rehacer operación deshecha
//redo

-- Limpiar historial de cambios
//clearhistory
```

---

## 🚀 Comandos Avanzados

### Copiar, Cortar y Pegar

```lua
-- Copiar región seleccionada
//copy

-- Cortar región (copia y borra)
//cut

-- Pegar en ubicación actual
//paste

-- Mover región 10 bloques hacia arriba
//move 10 up

-- Apilar región 5 veces
//stack 5 x
```

### Rotación y Volteo

```lua
-- Rotar región 90 grados
//rotate 90

-- Voltear región horizontalmente
//flip x

-- Voltear región verticalmente
//flip y
```

### Operaciones Especiales

```lua
-- Expandir selección 10 bloques en todas direcciones
//expand 10

-- Reducir selección 5 bloques
//contract 5

-- Expandir hasta el suelo (Y=0)
//expand vert

-- Suavizar terreno (eliminar bordes abruptos)
//smooth
```

### Formas Avanzadas

```lua
-- Crear cúpula (hemisferio)
//dome mcl_core:glass 20

-- Crear pirámide (base 10x10, altura 5)
//pyramid mcl_core:sandstone 5

-- Crear línea entre pos1 y pos2
//line mcl_core:stone
```

---

## ⚔️ Uso Específico para Arena PvP

### Crear Cercado Circular de Vallas

**Objetivo**: Delimitar Arena Principal (radio 25 bloques) con vallas de 3 bloques de altura

**✅ SINTAXIS CORRECTA VERIFICADA** (Octubre 2025):

```lua
-- 1. Teleportarse al centro de la arena
/arena_tp Arena_Principal
# Coordenadas: (41, 23, 232)

-- 2. Marcar posición central
//pos1

-- 3. Crear cilindro hueco de vallas (eje Y, altura 3, radio 25)
//hollowcylinder y 3 25 mcl_fences:fence

-- Resultado: Círculo perfecto de vallas de 25 bloques de radio ✅
```

**Sintaxis**: `//hollowcylinder <eje> <altura> <radio> <bloque>`
- `y` = eje vertical (para círculo horizontal)
- `3` = altura en bloques
- `25` = radio desde el centro
- `mcl_fences:fence` = tipo de bloque

**Variaciones**:
```lua
-- Valla más alta (5 bloques)
//hollowcylinder y 5 25 mcl_fences:fence

-- Valla de ladrillo del Nether (más resistente)
//hollowcylinder y 3 25 mcl_fences:nether_brick_fence

-- Doble perímetro (radio 25 y 24)
//hollowcylinder y 3 25 mcl_fences:fence
//hollowcylinder y 3 24 mcl_fences:fence
```

### Cambiar Piso de la Arena

**Objetivo**: Crear piso distintivo de arenisca dentro de la arena

```lua
-- 1. Teleportarse al centro
/arena_tp Arena_Principal

-- 2. Posicionarse un bloque debajo del centro
//pos1 41,22,232

-- 3. Crear cilindro sólido de 1 bloque de altura
//cyl mcl_core:sandstone 24 1

-- Resultado: Piso circular de arenisca (radio 24, dentro del cercado)
```

**Otras opciones de piso**:
```lua
-- Piso de arena del desierto
//cyl mcl_core:sand 24 1

-- Piso de netherrack (dramático, rojo)
//cyl mcl_nether:netherrack 24 1

-- Piso de piedra pulida
//cyl mcl_core:stonebrickcarved 24 1

-- Patrón alternado (requiere múltiples capas)
//cyl mcl_core:stone 24 1
//replace mcl_core:stone 50% mcl_core:cobble
```

### Iluminación Perimetral

**Objetivo**: Colocar faroles cada 5-10 bloques alrededor del perímetro

```lua
-- Opción 1: Línea continua de faroles
//pos1 41,24,232
//hollowcyl mcl_lanterns:lantern_floor 25 1

-- Opción 2: Faroles espaciados (manual, usar // repeat)
# Colocar manualmente 31 faroles cada ~5 bloques
# Circunferencia = 2 * π * 25 ≈ 157 bloques
# 157 / 5 ≈ 31 faroles
```

**Antorchas en postes**:
```lua
-- Crear postes de 2 bloques con antorchas encima
//hollowcyl mcl_fences:fence 25 2  # Poste
//pos1 41,25,232
//hollowcyl mcl_torches:torch 25 1   # Antorchas encima
```

### Línea de Advertencia (Vidrio Rojo)

**Objetivo**: Crear línea visual clara en el suelo marcando el perímetro

```lua
-- 1. Teleportarse al centro
/arena_tp Arena_Principal

-- 2. Crear círculo de vidrio rojo a nivel del suelo
//pos1 41,22,232
//hollowcyl mcl_core:glass_red 25 1

-- Resultado: Línea roja visible que marca el límite exacto
```

**Variaciones de colores**:
```lua
-- Vidrio naranja (menos dramático)
//hollowcyl mcl_core:glass_orange 25 1

-- Vidrio amarillo (advertencia)
//hollowcyl mcl_core:glass_yellow 25 1

-- Vidrio negro (elegante)
//hollowcyl mcl_core:glass_black 25 1
```

### 🏗️ Construcción COMPLETA desde Cero - Arena Principal Perfecta

**Problema**: El terreno tiene desniveles, piedras, árboles y otros bloques que interfieren

**Solución**: Limpiar completamente el área y construir una arena perfecta profesional

#### Script Maestro - Arena Principal Profesional

**✅ VERIFICADO Y FUNCIONAL** (20 Octubre 2025)

```lua
# ========================================
# FASE 1: LIMPIAR TERRENO EXISTENTE
# ========================================

# 1. Teleportarse al centro de la arena
/arena_tp Arena_Principal

# 2. Marcar posición central
//pos1

# 3. Definir región de limpieza (cilindro de 30 bloques radio, 50 altura)
# Esto limpiará TODA el área incluyendo arriba y abajo
//pos1 41,0,232
//pos2 71,50,262

# 4. LIMPIAR TODO (convertir a aire) - Área grande
//set air

# ========================================
# FASE 2: CREAR PISO PLANO BASE
# ========================================

# 5. Crear piso de césped plano (Y=22, radio 27)
//pos1 41,22,232
//cylinder y 1 27 mcl_core:grass

# 6. Crear capa de tierra debajo (Y=21, para que sea natural)
//pos1 41,21,232
//cylinder y 1 27 mcl_core:dirt

# 7. Opcional: Crear capa de piedra debajo (Y=20, base sólida)
//pos1 41,20,232
//cylinder y 1 27 mcl_core:stone

# ========================================
# FASE 3: DELIMITAR ARENA (decoración)
# ========================================

# 8. PISO DISTINTIVO de arenisca (radio 24, interior arena)
//pos1 41,23,232
//cylinder y 1 24 mcl_core:sandstone

# 9. LÍNEA DE VIDRIO ROJO (perímetro exacto, radio 25)
//pos1 41,22,232
//hollowcylinder y 1 25 mcl_core:glass_red

# 10. CERCADO DE VALLAS (3 bloques altura, radio 25)
//pos1 41,23,232
//hollowcylinder y 3 25 mcl_fences:fence

# 11. ILUMINACIÓN con antorchas (radio 25, Y=24)
//pos1 41,24,232
//hollowcylinder y 1 25 mcl_torches:torch

# ========================================
# FASE 4: DETALLES FINALES (opcional)
# ========================================

# 12. Opcional: Línea de vidrio AMARILLO interna (zona segura, radio 20)
//pos1 41,23,232
//hollowcylinder y 1 20 mcl_core:glass_yellow

# 13. Opcional: Postes decorativos en los 4 puntos cardinales
# Norte (Z=207)
//pos1 41,23,207
//cylinder y 5 1 mcl_fences:fence

# Sur (Z=257)
//pos1 41,23,257
//cylinder y 5 1 mcl_fences:fence

# Este (X=66)
//pos1 66,23,232
//cylinder y 5 1 mcl_fences:fence

# Oeste (X=16)
//pos1 16,23,232
//cylinder y 5 1 mcl_fences:fence

# 14. Opcional: Faroles en lo alto de los postes
//pos1 41,28,207
//set mcl_lanterns:lantern_floor
//pos1 41,28,257
//set mcl_lanterns:lantern_floor
//pos1 66,28,232
//set mcl_lanterns:lantern_floor
//pos1 16,28,232
//set mcl_lanterns:lantern_floor
```

#### Resultado Final:

```
Vista Cenital (desde arriba):

                Norte
                  ↑
                  │
        Poste con Farol (5 bloques altura)
                  │
    ┌─────────────┼─────────────┐
    │             │             │
    │   Vallas (radio 25)       │
    │   ┌─────────┼─────────┐   │
    │   │ Vidrio Rojo       │   │  ← Límite exacto
    │   │  ┌──────┼──────┐  │   │
Oeste│   │  │Arenisca    │  │   │Este
←────┼───┼──┼──(41,23,232)──┼──┼────→
    │   │  │   (radio 24)│  │   │
    │   │  └──────┼──────┘  │   │
    │   │         │         │   │
    │   └─────────┼─────────┘   │
    │             │             │
    └─────────────┼─────────────┘
                  │
        Poste con Farol
                  ↓
                Sur

Capas (vista lateral):

Y=28: Faroles en postes cardinales
Y=24-26: Vallas + Antorchas perimetrales
Y=23: Piso de Arenisca (interior)
Y=22: Césped + Vidrio Rojo (perímetro)
Y=21: Tierra (base natural)
Y=20: Piedra (capa profunda)
```

#### Especificaciones Técnicas:

| Característica | Valor |
|----------------|-------|
| **Radio exterior** | 27 bloques (área limpia) |
| **Radio arena** | 25 bloques (delimitación con vallas) |
| **Radio piso distintivo** | 24 bloques (arenisca) |
| **Altura vallas** | 3 bloques |
| **Iluminación** | Perimetral completa (157 antorchas) |
| **Postes decorativos** | 4 (puntos cardinales, 5 bloques altura) |
| **Tiempo construcción** | 5-7 minutos |
| **Bloques totales** | ~3,500 bloques |

#### Materiales Necesarios (Modo Creativo):

- **Césped**: ~2,290 bloques
- **Arenisca**: ~1,810 bloques
- **Vidrio rojo**: ~157 bloques
- **Vallas**: ~471 bloques (3 capas × 157)
- **Antorchas**: ~157 unidades
- **Piedra/Tierra**: ~2,290 bloques cada una
- **Faroles opcionales**: 4 unidades

#### Ventajas de Este Método:

✅ **Terreno perfectamente plano** - Sin desniveles ni obstáculos
✅ **Arena profesional** - Claramente delimitada y visible
✅ **Múltiples capas de advertencia** - Vidrio rojo + vallas + antorchas
✅ **Base sólida** - Tres capas de terreno (piedra, tierra, césped)
✅ **Iluminación completa** - Visible de día y noche
✅ **Detalles decorativos** - Postes en puntos cardinales
✅ **Reversible** - Todo se puede deshacer con `//undo`

#### Si Algo Sale Mal:

```lua
# Deshacer última operación
//undo

# Deshacer múltiples operaciones
//undo
//undo
//undo

# Limpiar TODO y empezar de nuevo
//pos1 41,0,232
//pos2 71,50,262
//set air
# Luego ejecutar script desde FASE 2
```

---

### Construcción Rápida (Solo Delimitación)

Si ya tienes un terreno aceptable y solo quieres delimitar:

```lua
# 1. TELEPORTARSE AL CENTRO
/arena_tp Arena_Principal

# 2. MARCAR POSICIÓN 1 (centro de la arena)
//pos1

# 3. PISO DE ARENISCA (cilindro sólido, eje Y, altura 1, radio 24)
//cylinder y 1 24 mcl_core:sandstone

# 4. BAJAR UN BLOQUE Y CREAR LÍNEA DE VIDRIO ROJO
//pos1 41,22,232
//hollowcylinder y 1 25 mcl_core:glass_red

# 5. SUBIR A NIVEL 23 Y CREAR VALLAS (altura 3)
//pos1 41,23,232
//hollowcylinder y 3 25 mcl_fences:fence

# 6. ANTORCHAS EN NIVEL 24
//pos1 41,24,232
//hollowcylinder y 1 25 mcl_torches:torch
```

**Tiempo**: 2-3 minutos
**Bloques**: ~2,300

---

## 🎮 Compatibilidad con VoxeLibre

### Bloques VoxeLibre vs Minetest Vanilla

WorldEdit funciona perfectamente con VoxeLibre, pero debes usar **nombres de bloques específicos de VoxeLibre**:

| Item Minetest Vanilla | Item VoxeLibre Equivalente |
|-----------------------|-----------------------------|
| `default:stone` | `mcl_core:stone` |
| `default:wood` | `mcl_core:wood` |
| `default:glass` | `mcl_core:glass` |
| `default:torch` | `mcl_torches:torch` |
| `default:dirt` | `mcl_core:dirt` |
| `farming:wheat` | `mcl_farming:wheat_item` |

### Encontrar Nombres de Bloques VoxeLibre

**Método 1: Comando Lua**
```lua
-- Sostén el bloque en tu mano y ejecuta:
/lua local item = minetest.get_wielded_item(minetest.get_player_by_name("gabo"))
local name = item:get_name()
minetest.chat_send_all("Nombre: " .. name)
```

**Método 2: Inventario Creativo**
- Abre inventario (tecla `I`)
- Busca el bloque que quieres
- El nombre técnico aparece al pasar el mouse sobre el item

**Método 3: Logs del Servidor**
```bash
docker-compose logs luanti-server | grep "register_item"
# Muestra todos los bloques registrados
```

### Limitaciones Conocidas

❌ **No funciona con entidades** (mobs, jugadores, items sueltos)
❌ **No funciona con metadata compleja** (cofres con items dentro)
✅ **Funciona perfecto con bloques estáticos**
✅ **Funciona con signs/carteles** (pero pierden el texto)
✅ **Funciona con bloques decorativos y construcción**

---

## 🛠️ Casos de Uso Prácticos

### Caso 1: Reparar Griefing

**Problema**: Un jugador destruyó parte de una construcción

**Solución**:
```lua
-- 1. Marcar área afectada
//pos1 <esquina1>
//pos2 <esquina2>

-- 2. Deshacer cambios (si el griefing fue reciente)
//undo

-- 3. O restaurar desde backup
//load mi_construccion
//paste
```

### Caso 2: Crear Camino Rápido

**Problema**: Necesitas un camino de 100 bloques de largo

**Solución**:
```lua
-- 1. Marcar inicio y fin del camino
//pos1 <inicio>
//pos2 <fin>

-- 2. Expandir región a 3 bloques de ancho
//expand 1 left
//expand 1 right

-- 3. Rellenar con bloques de camino
//set mcl_core:stonebrick
```

### Caso 3: Limpiar Área Grande

**Problema**: Necesitas limpiar una área para construir

**Solución**:
```lua
-- 1. Marcar área
//pos1 <esquina1>
//pos2 <esquina2>

-- 2. Convertir todo a aire
//set air

-- 3. Crear piso plano
//pos1 <esquina1 Y-1>
//pos2 <esquina2 Y-1>
//set mcl_core:grass
```

### Caso 4: Crear Muralla Defensiva

**Problema**: Necesitas cercar una zona grande

**Solución**:
```lua
-- 1. Marcar perímetro
//pos1 <esquina1>
//pos2 <esquina2>

-- 2. Crear paredes huecas
//faces mcl_core:stonebrick

-- 3. Añadir almenas (opcional)
//expand 1 up
//replace mcl_core:stonebrick 50% air
```

### Caso 5: Replicar Estructura

**Problema**: Necesitas copiar una estructura múltiples veces

**Solución**:
```lua
-- 1. Seleccionar estructura original
//pos1 <esquina1>
//pos2 <esquina2>

-- 2. Copiar
//copy

-- 3. Moverse a nueva ubicación y pegar
//paste

-- 4. O apilar múltiples veces
//stack 10 x  # Replica 10 veces hacia X
```

---

## 🐛 Troubleshooting

### Problema 1: Comandos No Funcionan

**Síntomas**: `//pos1` muestra "invalid command"

**Diagnóstico**:
```lua
-- Verificar privilegios
/privs
# Debe mostrar: worldedit

-- Verificar mod cargado
/lua minetest.get_modpath("worldedit")
# Debe devolver la ruta del mod
```

**Solución**:
```bash
# Otorgar privilegio
/grant gabo worldedit

# Verificar configuración
grep "load_mod_worldedit" server/config/luanti.conf

# Reiniciar servidor
docker-compose restart luanti-server
```

### Problema 2: Operación Muy Lenta

**Síntomas**: Comandos tardan varios segundos en ejecutarse

**Causa**: Operaciones muy grandes (>100,000 bloques) pueden causar lag

**Solución**:
```lua
-- 1. Reducir tamaño de operación
//contract 10  # Reducir selección

-- 2. Dividir en operaciones más pequeñas
# En vez de un cubo de 100x100x100, hacer 10 operaciones de 100x100x10

-- 3. Usar máscaras para afectar menos bloques
//gmask air  # Solo modificar bloques vacíos
```

### Problema 3: Nombres de Bloques No Funcionan

**Síntomas**: `//set default:stone` no funciona

**Causa**: VoxeLibre usa nombres diferentes a Minetest vanilla

**Solución**:
```lua
-- Usar nombres VoxeLibre correctos
//set mcl_core:stone  # ✅ Correcto
# No: //set default:stone  # ❌ Incorrecto

-- Encontrar nombre correcto
/lua local item = minetest.get_wielded_item(minetest.get_player_by_name("gabo"))
minetest.chat_send_all(item:get_name())
```

### Problema 4: Deshacer No Funciona

**Síntomas**: `//undo` no deshace cambios

**Causa**: Historial de deshacer puede llenarse o perderse

**Solución**:
```lua
-- Verificar límite de historial
/lua minetest.settings:get("worldedit_history_size")
# Default: 15 operaciones

-- Aumentar límite (en luanti.conf)
worldedit_history_size = 50

-- Reiniciar servidor para aplicar
```

### Problema 5: Lag Severo Después de Operación

**Síntomas**: Servidor se congela después de gran operación

**Causa**: Operaciones masivas generan muchas actualizaciones de luz y líquidos

**Solución**:
```lua
-- 1. Esperar a que el servidor procese cambios (~30 segundos)

-- 2. Reiniciar servidor si persiste
docker-compose restart luanti-server

-- 3. Evitar operaciones muy grandes (>50,000 bloques)

-- 4. Usar máscaras para reducir cambios
//gmask air  # Solo bloques vacíos
```

### Problema 6: Región No Seleccionada

**Síntomas**: "No region selected" al intentar operación

**Solución**:
```lua
-- Verificar posiciones actuales
//volume

-- Establecer posiciones manualmente
//pos1
//pos2

-- O con coordenadas exactas
//pos1 41,23,232
//pos2 66,48,257
```

---

## 📚 Comandos de Referencia Rápida

### Selección y Región
```lua
//pos1, //pos2           -- Marcar posiciones
//volume, //size         -- Ver selección
//expand <n> [dir]       -- Expandir región
//contract <n> [dir]     -- Reducir región
```

### Modificación Básica
```lua
//set <bloque>           -- Rellenar con bloque
//replace <viejo> <nuevo> -- Reemplazar bloques
//gmask <bloque>         -- Establecer máscara
//clear                  -- Limpiar región (=//set air)
```

### Formas Geométricas
```lua
//sphere <bloque> <radio>
//hollowsphere <bloque> <radio>
//cyl <bloque> <radio> <altura>
//hollowcyl <bloque> <radio> <altura>
//pyramid <bloque> <altura>
//dome <bloque> <radio>
```

### Copiar/Pegar
```lua
//copy                   -- Copiar región
//cut                    -- Cortar región
//paste                  -- Pegar
//rotate <ángulo>        -- Rotar
//flip <eje>             -- Voltear
//stack <n> <dir>        -- Apilar
```

### Deshacer/Utilidades
```lua
//undo                   -- Deshacer
//redo                   -- Rehacer
//clearhistory           -- Limpiar historial
//fixlight               -- Arreglar iluminación
//drain                  -- Vaciar agua/lava
```

---

## 🎓 Conclusión

WorldEdit es una herramienta **imprescindible** para administradores de servidores Luanti/VoxeLibre. Con esta guía, podrás:

✅ **Delimitar eficientemente** la Arena PvP con estructuras visuales claras
✅ **Construir estructuras masivas** en minutos en vez de horas
✅ **Modificar el terreno** para crear zonas personalizadas
✅ **Reparar daños rápidamente** sin perder tiempo
✅ **Experimentar sin miedo** gracias a //undo

### Mejores Prácticas

1. **Siempre usa `//gmask air`** cuando construyas cerca de estructuras existentes
2. **Verifica `//volume`** antes de operaciones grandes
3. **Guarda copias con `//copy`** antes de cambios arriesgados
4. **Divide operaciones grandes** en varias más pequeñas
5. **Documenta tus construcciones** con screenshots y coordenadas

### Recursos Adicionales

- **WorldEdit Wiki**: https://github.com/Uberi/Minetest-WorldEdit/wiki
- **Luanti Mod API**: https://github.com/minetest/minetest/blob/master/doc/lua_api.txt
- **VoxeLibre ContentDB**: https://content.luanti.org/packages/Wuzzy/mineclone2/
- **Servidor Wetlands**: luanti.gabrielpantoja.cl:30000

---

**Última Actualización**: 20 de Octubre 2025
**Versión del Documento**: 1.0.0
**Autor**: Gabriel Pantoja (gabo)
**Licencia**: MIT