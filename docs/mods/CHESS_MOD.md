# Chess Mod Documentation

## Overview

El mod de ajedrez permite a los jugadores jugar ajedrez en un tablero real dentro del mundo de Wetlands. Este es un mod comunitario perfecto para promover el pensamiento estratégico y la socialización entre jugadores.

## Información del Mod

- **Nombre**: Chess
- **Autor Original**: LissoBone
- **Versión**: Chess-2221 (2023-02-12)
- **Licencia**: GPL-3.0-or-later (código), CC-BY-4.0 (media)
- **Fuente**: [ContentDB - LissoBone/chess](https://content.luanti.org/packages/LissoBone/chess/)
- **Tamaño**: 124 KB
- **Estado**: Beta - Adaptado para VoxeLibre

## Características

### ✅ Implementado
- **Tablero de ajedrez real**: Tablero 8x8 con coordenadas (a-h, 1-8)
- **Todas las piezas**: Rey, Reina, Torres, Alfiles, Caballos, Peones (blancas y negras)
- **Sistema de ownership**: El jugador que coloca el tablero es el dueño
- **Modo libre**: Sin reglas programadas, los jugadores mueven las piezas manualmente
- **Reset del tablero**: Golpear el bloque de spawn resetea las piezas
- **Multiplayer**: Diseñado para juego competitivo entre jugadores
- **Texturas visuales**: Tablero con colores blanco/negro y piezas diferenciadas

### ⚠️ Limitaciones
- **Sin reglas automáticas**: No valida movimientos legales de ajedrez
- **Sin detección de jaque/jaque mate**: Los jugadores deben administrar las reglas
- **Requiere moderación**: Ideal para juego supervisado o entre amigos de confianza

## Crafting

### Tablero de Ajedrez (Chess Board Spawner)

**VoxeLibre Recipe**:
```
[Madera] [Tronco]  [Madera]
[Tronco] [Madera]  [Tronco]
[Madera] [Tronco]  [Madera]
```

**Items necesarios**:
- 5x Cualquier tipo de madera (`group:wood`) - planks de roble, abeto, etc.
- 4x Tronco de árbol (`mcl_core:tree`) - oak log

**Nota**: También funciona con items de Minetest vanilla (`default:wood`, `default:tree`)

## Cómo Jugar

### Paso 1: Colocar el Tablero
1. Craftea el "Chess Board" usando la receta anterior
2. Encuentra un espacio abierto de **10x10 bloques** (9x9 tablero + borde)
3. Coloca el bloque Chess Board en el suelo
4. El tablero se generará automáticamente con todas las piezas en posición inicial

### Paso 2: Configurar el Juego
- El jugador que colocó el tablero es el **owner** (propietario)
- Se muestra un mensaje global: `[Chess] <nombre> placed chessboard, hit king to select color`
- Solo el owner puede destruir el tablero

### Paso 3: Jugar
- **Mover piezas**: Click derecho en una pieza para tomarla, click derecho en el espacio destino para colocarla
- **Capturar piezas**: Coloca tu pieza en el espacio de la pieza enemiga (la pieza capturada va al inventario)
- **Resetear tablero**: Golpea (punch) el bloque Chess Board spawner para restaurar todas las piezas a la posición inicial
- **Administrar reglas**: Los jugadores deben conocer y seguir las reglas del ajedrez manualmente

### Paso 4: Terminar la Partida
- **Destruir tablero**: Solo el owner puede romper el Chess Board spawner
- Al destruir el spawner, todo el tablero (9x9) y las piezas se eliminan automáticamente

## Comandos

Este mod no agrega comandos de chat. Toda la interacción es mediante bloques del mundo.

## Configuración

### Habilitar/Deshabilitar el Mod

**En `luanti.conf`**:
```ini
load_mod_chess = true
```

**En `world.mt`**:
```ini
load_mod_chess = true
```

## Compatibilidad

### ✅ Compatible con:
- **VoxeLibre** (MineClone2) - Totalmente adaptado
- **Luanti** 5.13.0+ (antes Minetest)
- **Minetest** 0.4.16+ (vanilla)
- **Modo creativo**: Sí
- **Modo survival**: Sí

### ⚠️ Dependencias:
- `mcl_core` (opcional) - Para VoxeLibre
- `default` (opcional) - Para Minetest vanilla

## Adaptaciones para VoxeLibre

Este mod fue originalmente diseñado para Minetest vanilla. Las siguientes adaptaciones fueron realizadas:

### Cambios en `mod.conf`:
```lua
depends =
optional_depends = mcl_core, default
```

### Cambios en `init.lua`:
1. **Dual crafting recipe**: Agregada receta compatible con VoxeLibre usando `group:wood` y `mcl_core:tree`
2. **Fallback recipe**: Mantenida receta original para compatibilidad con Minetest vanilla

### Issues Conocidos:
- **Warning: `indestructable` variable**: No crítico, no afecta funcionalidad
- El mod usa `indestructable` en lugar de `indestructible` (typo del mod original)

## Troubleshooting

### El tablero no aparece cuando lo coloco
**Causa**: No hay suficiente espacio (necesitas 10x10 bloques libres)
**Solución**: Limpia un área de 10x10 antes de colocar el Chess Board spawner

### No puedo destruir el tablero
**Causa**: Solo el owner (quien lo colocó) puede destruirlo
**Solución**: El owner debe romper el Chess Board spawner

### Las piezas están desordenadas
**Causa**: Jugadores movieron piezas incorrectamente
**Solución**: El owner puede golpear (punch) el Chess Board spawner para resetear todas las piezas

### El crafting no funciona
**Causa**: Items incorrectos o mod no cargado
**Solución**:
1. Verifica que `load_mod_chess = true` en configuración
2. Usa madera (planks) y troncos (logs) de VoxeLibre
3. Reinicia el servidor después de instalar el mod

## Recomendaciones de Uso

### Para Wetlands (Niños 7+ años)
- ✅ **Excelente herramienta educativa** para enseñar ajedrez
- ✅ **Promueve pensamiento estratégico** y paciencia
- ✅ **Fomenta socialización** entre jugadores
- ⚠️ **Requiere supervisión**: Sin reglas automáticas, los niños deben conocer las reglas del ajedrez
- ⚠️ **Espacio dedicado**: Considera crear un "área de ajedrez" en el spawn para que todos puedan jugar

### Ideas de Uso Creativo
1. **Torneo de ajedrez**: Organiza torneos con premios in-game
2. **Área de juegos**: Crea múltiples tableros en un espacio dedicado
3. **Clases de ajedrez**: Usa el tablero para enseñar movimientos básicos
4. **Decoración**: Los tableros se ven bien en bibliotecas o salas de juegos

## Archivos del Mod

```
server/mods/chess/
├── init.lua              # Lógica principal (tablero, spawn block)
├── pieces.lua            # Definiciones de todas las piezas
├── rules.lua             # Sistema de reglas (vacío actualmente)
├── ownership.lua         # Sistema de propiedad del tablero
├── mod.conf              # Metadata del mod
├── LICENSE               # GPL-3.0-or-later
├── MEDIA_LICENSE         # CC-BY-4.0
├── README.md             # Documentación original
├── textures/             # Texturas de piezas y tablero
│   ├── chess_board_white.png
│   ├── chess_board_black.png
│   ├── chess_piece_white.png
│   ├── chess_piece_black.png
│   ├── chess_border_*.png (a-h, 1-8)
│   └── chess_border_spawn.png
└── template/             # Plantillas adicionales
```

## Código Importante

### Chess Board Spawner (init.lua:85-181)
```lua
minetest.register_node("chess:spawn",{
    description = "Chess Board",
    -- Al colocar: genera tablero 9x9 con piezas
    -- Al golpear: resetea piezas a posición inicial
    -- Al destruir: elimina todo el tablero
})
```

### Piezas (pieces.lua)
- `chess:king_white` / `chess:king_black`
- `chess:queen_white` / `chess:queen_black`
- `chess:rook_white` / `chess:rook_black`
- `chess:bishop_white` / `chess:bishop_black`
- `chess:knight_white` / `chess:knight_black`
- `chess:pawn_white` / `chess:pawn_black`

## Créditos

- **Mod Original**: Chess mod (2012) - Revivido por LissoBone en 2023
- **Licencia Código**: GPL-3.0-or-later
- **Licencia Media**: CC-BY-4.0
- **Adaptación VoxeLibre**: Gabriel Pantoja (Wetlands Project)
- **Fuente**: https://content.luanti.org/packages/LissoBone/chess/

## Versión

- **Última actualización de este documento**: 2025-11-22
- **Versión del mod**: Chess-2221 (2023-02-12)
- **Servidor**: Wetlands 🌱 | luanti.gabrielpantoja.cl:30000
