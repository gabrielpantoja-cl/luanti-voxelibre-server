# 🏟️ PVP Arena Mod - Sistema de Zonas de Combate

**Versión**: 1.1.0
**Estado**: ✅ Producción
**Servidor**: Wetlands 🌱 Luanti/VoxeLibre

---

## 📖 Descripción

Mod que permite PvP en zonas específicas delimitadas mientras mantiene el resto del servidor pacífico.

**Características principales**:
- ✅ Detección automática de entrada/salida de arenas
- ✅ Gestión automática del privilegio `creative`
- ✅ Zonas circulares en 3D (altura + radio)
- ✅ Múltiples arenas configurables
- ✅ Comandos para jugadores y administradores
- ✅ Sistema de mensajes visuales

---

## 🚀 Inicio Rápido

### Para Jugadores

```lua
/arena_lista          # Ver arenas disponibles
/arena_donde          # Distancia a arena más cercana
/salir_arena          # Teleport al spawn
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
├── mod.conf         # Metadatos
├── init.lua         # Lógica principal (266 líneas)
├── commands.lua     # Comandos del chat (310 líneas)
└── README.md        # Este archivo
```

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
