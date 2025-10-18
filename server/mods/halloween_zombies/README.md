# 🧟 Halloween Zombies Mod

Mod de zombies amigables para evento de Halloween en servidor Wetlands (modo pacífico).

## Características

### 🎃 Zombies Amigables
- **Modo Pacífico**: Los zombies NO hacen daño a los jugadores
- **Visuales Espeluznantes**: Movimiento tambaleante y efectos de partículas
- **Recompensas**: Al derrotarlos, sueltan comida (manzanas, zanahorias, papas, remolacha)
- **Sonidos Temáticos**: Gruñidos ocasionales para atmósfera de Halloween
- **Auto-Despawn**: Desaparecen automáticamente después de 5 minutos

### 📍 Sistema de Spawn
- **Ubicación Principal**: Coordenadas `123, 25, -204` (configurada para zona específica)
- **Radio de Spawn**: 15 bloques alrededor del punto central
- **Spawn Automático**: Solo activo en Octubre (temporada Halloween)
- **Límite**: Máximo 10 zombies activos simultáneamente
- **Intervalo**: Un nuevo zombie cada 30 segundos (si no se alcanza el límite)

### 🎮 Comandos de Admin

#### `/invocar_zombie`
Invoca un zombie en la posición actual del jugador.
- **Privilegio requerido**: `server`
- **Uso**: `/invocar_zombie`

#### `/invasion_zombies <cantidad>`
Inicia una invasión masiva de zombies.
- **Privilegio requerido**: `server`
- **Parámetro**: cantidad (1-10)
- **Uso**: `/invasion_zombies 5`
- **Ejemplo**: `/invasion_zombies 10` (invasión máxima)

#### `/limpiar_zombies`
Elimina todos los zombies activos del servidor.
- **Privilegio requerido**: `server`
- **Uso**: `/limpiar_zombies`

#### `/estado_zombies`
Muestra información sobre zombies activos.
- **Privilegio requerido**: ninguno (todos pueden usar)
- **Uso**: `/estado_zombies`
- **Información mostrada**:
  - Zombies activos / máximo
  - Zona de spawn
  - Radio de spawn
  - Estado de temporada Halloween
  - Intervalo de spawn

### 🏚️ Bloque Decorativo: Tumba Zombie

**Item**: `halloween_zombies:zombie_grave`

Tumba decorativa de Halloween con mecánica interactiva:
- **Interacción**: Click derecho para activar
- **Efecto Aleatorio** (20% de probabilidad):
  - Spawns un zombie desde la tumba
  - Efectos de partículas (humo/miasma)
  - Mensaje temático
- **Decoración**: Perfecto para crear cementerios de Halloween

## Compatibilidad

- **Motor**: Luanti (Minetest) 5.13+
- **Juego Base**: VoxeLibre (MineClone2) v0.90.1
- **Modo de Juego**: Creative & Peaceful
- **Dependencias**: Ninguna (funciona standalone)
- **Opcional**: mcl_core, mcl_mobs, mcl_farming (para items de recompensa)

## Configuración

Puedes modificar estas variables en `init.lua`:

```lua
-- Ubicación de spawn principal
local ZOMBIE_SPAWN_POS = {x = 123, y = 25, z = -204}

-- Radio de spawn alrededor del punto central
local SPAWN_RADIUS = 15

-- Máximo de zombies activos simultáneamente
local MAX_ZOMBIES = 10

-- Segundos entre spawns automáticos
local SPAWN_INTERVAL = 30

-- Tiempo de vida del zombie antes de auto-despawn (segundos)
local ZOMBIE_LIFETIME = 300  -- 5 minutos
```

## Texturas Requeridas

El mod requiere las siguientes texturas en `textures/`:

**Zombie Entity**:
- `halloween_zombie_top.png` (cabeza)
- `halloween_zombie_bottom.png` (pies)
- `halloween_zombie_side.png` (costados)
- `halloween_zombie_front.png` (frente)
- `halloween_zombie_back.png` (espalda)

**Efectos**:
- `halloween_zombie_particle.png` (partículas al eliminar)
- `halloween_zombie_smoke.png` (efecto de humo/miasma)

**Tumba**:
- `halloween_grave_top.png`
- `halloween_grave_bottom.png`
- `halloween_grave_side.png`
- `halloween_grave_front.png`

### Crear Texturas

Para crear texturas rápidas, puedes usar:
1. **GIMP/Photoshop**: Crear texturas 16x16 o 32x32 píxeles
2. **Pixel Art Tools**: Aseprite, Piskel.app
3. **Generadores Online**: OpenGameArt.org, itch.io

**Colores Sugeridos para Zombie**:
- Verde/Gris para piel zombie
- Ropa rasgada (marrón, gris oscuro)
- Ojos brillantes (rojo/amarillo) para efecto glow

## Integración con Otros Mods de Halloween

El mod está diseñado para trabajar en conjunto con:

- **halloween_ghost**: Fantasmas amigables que sueltan regalos
- **broom_racing**: Sistema de escobas voladoras y carreras mágicas

Todos los mods de Halloween comparten:
- Modo pacífico (sin daño real)
- Temática educativa y apropiada para niños (7+)
- Recompensas positivas (comida, items útiles)
- Efectos visuales y atmósfera festiva

## Sistema de Temporada

El mod detecta automáticamente el mes actual:
- **Octubre (Mes 10)**: Sistema de spawn automático ACTIVO
- **Otros meses**: Solo spawn manual vía comandos de admin

Esto permite tener el mod instalado todo el año sin saturar el servidor fuera de temporada.

## Comportamiento del Zombie

### Movimiento
- Velocidad lenta (0.5 unidades)
- Movimiento tambaleante (zigzag simulado con ondas sinusoidales)
- Cambio de dirección cada 3-5 segundos
- Sujeto a gravedad (cae y camina por el suelo)

### Interacción
- **Al golpear**: Suelta 1-3 items de comida aleatoria
- **Partículas**: Explosión de partículas verdes al ser eliminado
- **Mensajes**: Texto temático en el chat del jugador
- **Sonidos**: Gruñidos ocasionales (simulados vía chat para jugadores cercanos)

### Efectos Visuales
- Brillo tenue (glow = 3) para visibilidad nocturna
- Partículas de humo/miasma ocasionales
- Texturas cúbicas con rotación hacia dirección de movimiento

## Troubleshooting

### Los zombies no aparecen
1. Verifica que estemos en Octubre: `/estado_zombies`
2. Comprueba el límite de zombies activos
3. Usa spawn manual: `/invocar_zombie` o `/invasion_zombies 5`

### Demasiados zombies
- Usa `/limpiar_zombies` para resetear
- Ajusta `MAX_ZOMBIES` en `init.lua`
- Aumenta `ZOMBIE_LIFETIME` para que duren menos

### Texturas faltantes
- Verifica que todas las texturas .png existen en `textures/`
- Reinicia el servidor después de agregar texturas
- Revisa logs del servidor para errores de carga

## Créditos

- **Desarrollado por**: Wetlands Team
- **Servidor**: Wetlands (luanti.gabrielpantoja.cl)
- **Licencia**: GPL v3.0 (compatible con VoxeLibre)
- **Versión**: 1.0.0

## Contacto y Contribuciones

Este mod es parte del proyecto Wetlands, un servidor educativo y compasivo para niños.

Para reportar bugs o sugerir mejoras, contacta al equipo de Wetlands.

---

**¡Feliz Halloween! 🎃🧟👻**
