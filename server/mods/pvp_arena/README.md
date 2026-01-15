# 🏟️ PVP Arena Mod - Sistema de Zonas de Combate con Scoring

**Versión**: 1.4.0 🆕 (Sistema de Modos Mixtos)
**Estado**: ✅ Producción
**Servidor**: Wetlands 🌱 Luanti/VoxeLibre

---

## 📖 Descripción

Mod que permite PvP en zonas específicas delimitadas con **sistema de scoring en tiempo real** para competir por el primer lugar.

**Características principales**:
- ✅ Detección automática de entrada/salida de arenas
- ✅ Gestión automática del privilegio `creative`
- ✅ **🆕 v1.4: Soporte de modos mixtos (Creativo + Supervivencia)**
- ✅ Zonas circulares en 3D (altura + radio)
- ✅ Múltiples arenas configurables
- ✅ Scoreboard en tiempo real con Top 10
- ✅ Sistema de Killstreaks (Triple Kill, Rampage, Godlike)
- ✅ Tracking de K/D ratio y estadísticas personales
- ✅ Anuncios automáticos de kills en chat
- ✅ Ghost Mode estilo LoL al morir (invisible, fly, espectador)
- ✅ Countdown regresivo de respawn (5, 4, 3, 2, 1...)
- ✅ Scoreboard mejorado (nombres hasta 18 caracteres)
- ✅ Sistema de mensajes visuales

---

## 🚀 Inicio Rápido

### Para Jugadores

```lua
/arena_lista          # Ver arenas disponibles
/arena_donde          # Distancia a arena más cercana
/salir_arena          # Teleport al spawn

# 🆕 Comandos de Scoring
/arena_score          # Ver scoreboard completo (Top 10)
/mis_stats            # Ver tus estadísticas PVP personales
```

### Para Administradores

```lua
/crear_arena <nombre> <radio>    # Crear nueva arena
/arena_tp <nombre>                # Teleport a arena
/arena_stats                      # Ver estadísticas
```

---

## 🆕 Sistema de Modos Mixtos (v1.4.0)

Este mod trabaja en conjunto con `creative_force` para soportar **modos mixtos** donde jugadores en supervivencia y creativo coexisten.

### Configuración de Excepciones

**Ubicación**: Líneas 5-9 de `init.lua`

```lua
-- ⚠️ SURVIVAL MODE EXCEPTIONS - Players who should NOT get creative privileges
local survival_players = {
    ["pepelomo"] = true,  -- Jugador en modo supervivencia
    -- Agregar más jugadores aquí
}
```

### Comportamiento por Modo

**Jugadores en Creativo**:
- Al conectar: Reciben privilegio `creative` automáticamente
- Al entrar a arena: Pierden `creative` temporalmente
- Al salir de arena: Recuperan `creative`

**Jugadores en Supervivencia**:
- Al conectar: NO reciben privilegio `creative` (respetando excepción)
- Al entrar a arena: Modo supervivencia se mantiene
- Al salir de arena: Modo supervivencia se mantiene
- **Logs**: `[PVP Arena] Player pepelomo is in SURVIVAL mode - skipping creative`

### Sincronización con creative_force

**IMPORTANTE**: Este mod **debe tener la misma lista** `survival_players` que el mod `creative_force` para evitar conflictos.

Si un jugador está en la lista de supervivencia en `creative_force` pero NO en `pvp_arena`, puede recibir creative al reconectar.

### Verificación de Configuración

```bash
# Ver logs de jugador en supervivencia
docker-compose logs luanti-server | grep -i "pepelomo\|survival"

# Debe mostrar:
# [PVP Arena] Player pepelomo is in SURVIVAL mode - skipping creative
```

### Troubleshooting Modos Mixtos

**Problema**: Jugador en supervivencia recibe creative al reconectar

**Causa**: Lista `survival_players` no sincronizada entre mods

**Solución**:
1. Verificar que AMBOS mods (`creative_force` y `pvp_arena`) tienen la lista actualizada
2. Reiniciar servidor
3. Jugador debe reconectar

**Documentación completa**: `docs/MIXED_GAMEMODE_CONFIGURATION.md`

---

## 📚 Documentación Completa

👉 **Ver**: `docs/mods/PVP_ARENA_COMPLETE_GUIDE.md`

Esta guía incluye:
- Instalación y activación
- Configuración avanzada
- Todos los comandos disponibles
- Troubleshooting completo
- Arquitectura técnica
- Roadmap de mejoras futuras

---

## 📂 Estructura

```
server/mods/pvp_arena/
├── mod.conf         # Metadatos (v1.2.0)
├── init.lua         # Lógica principal + hooks de combate
├── scoring.lua      # 🆕 Sistema de puntuación en tiempo real
├── commands.lua     # Comandos del chat (incluye /arena_score y /mis_stats)
├── docs/
│   └── SCORING_SYSTEM.md  # 🆕 Documentación completa del scoring
└── README.md        # Este archivo
```

## 🎮 Sistema de Scoring (v1.2.0)

### Estadísticas Rastreadas
- **Kills**: Número de jugadores eliminados
- **Deaths**: Veces que moriste
- **K/D Ratio**: Proporción kills/deaths (indicador de habilidad)
- **Current Streak**: Kills consecutivas actuales
- **Best Streak**: Mejor racha histórica

### Killstreaks Especiales
```
3 kills  → 🔶 ¡TRIPLE KILL!
5 kills  → 🔥 ¡KILLING SPREE!
7 kills  → 🔴 ¡RAMPAGE!
10 kills → 💀 ¡UNSTOPPABLE!
15 kills → ⭐ ¡GODLIKE!
20 kills → 👑 ¡LEGENDARY!
```

### Scoreboard en Tiempo Real
El scoreboard se muestra automáticamente en el chat después de cada kill, mostrando:
- Top 10 jugadores ordenados por kills
- Medallas para Top 3 (🥇🥈🥉)
- Colores diferenciados por posición
- Estadísticas completas (K, D, K/D, Streak)

👉 **Documentación completa**: `docs/SCORING_SYSTEM.md`

---

## 🎯 Arena Principal

- **Centro**: (41, 23, 232)
- **Radio**: 25 bloques
- **Área**: 51x51 bloques
- **Estado**: Activa

---

## 🔧 Dependencias

```ini
depends = mcl_core, mcl_player
optional_depends = areas, worldedit
```

---

## 🐛 Soporte

**Problemas comunes**:
1. **Mod no carga**: Verificar `load_mod_pvp_arena = true` en luanti.conf
2. **PVP no funciona**: Verificar `creative_mode = false` y `enable_pvp = true`
3. **Creative no se restaura**: Usar `/grant nombre creative` manualmente

**Logs del mod**:
```bash
docker-compose logs luanti-server | grep "PVP Arena"
```

---

## 📝 Licencia

MIT License - Libre para usar y modificar

---

## 👤 Autor

Gabriel Pantoja (gabo) - Servidor Wetlands

---

**Última actualización**: Enero 15, 2026
**Versión**: 1.4.0 (Sistema de Modos Mixtos)
**Mantenedor**: Equipo Wetlands
**📚 Documentación adicional**: `docs/MIXED_GAMEMODE_CONFIGURATION.md`
