# 🏟️ PVP Arena Mod - Sistema de Zonas de Combate con Scoring

**Versión**: 1.2.0 🆕
**Estado**: ✅ Producción
**Servidor**: Wetlands 🌱 Luanti/VoxeLibre

---

## 📖 Descripción

Mod que permite PvP en zonas específicas delimitadas con **sistema de scoring en tiempo real** para competir por el primer lugar.

**Características principales**:
- ✅ Detección automática de entrada/salida de arenas
- ✅ Gestión automática del privilegio `creative`
- ✅ Zonas circulares en 3D (altura + radio)
- ✅ Múltiples arenas configurables
- ✅ **🆕 Scoreboard en tiempo real con Top 10**
- ✅ **🆕 Sistema de Killstreaks (Triple Kill, Rampage, Godlike)**
- ✅ **🆕 Tracking de K/D ratio y estadísticas personales**
- ✅ **🆕 Anuncios automáticos de kills en chat**
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
