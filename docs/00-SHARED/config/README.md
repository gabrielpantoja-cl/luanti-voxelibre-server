# ⚙️ config/ — Configuración y mecánica del motor

Índice completo en [`../README.md`](../README.md). Documentos de esta carpeta:

| # | Archivo | Aplica a | Prioridad |
|---|---------|----------|-----------|
| 01 | [CONFIGURATION_HIERARCHY.md](01-CONFIGURATION_HIERARCHY.md) — `world.mt` vs `luanti-*.conf` | **Todos los mundos** | 🔴 CRÍTICO |
| 02 | [NUCLEAR_CONFIG.md](02-NUCLEAR_CONFIG.md) — desactivar mobs hostiles | Wetlands, Valdivia | ⚠️ técnica |
| 04 | [VOXELIBRE_SYSTEM.md](04-VOXELIBRE_SYSTEM.md) — internals de VoxeLibre | **Todos** | ⚠️ IMPORTANTE |
| 07 | [CUSTOM_SKINS.md](07-CUSTOM_SKINS.md) — skins de jugadores | **Todos** | ℹ️ funcional |
| 08 | [CREATIVE_NATIVE_MODE.md](08-CREATIVE_NATIVE_MODE.md) — modo creativo nativo | Wetlands, Valdivia | ⚠️ técnica |

> **Huecos de numeración (03, 05, 06) intencionales**: eran específicos de Wetlands y se movieron a
> [`../../01-ORIGINAL-30000/config/`](../../01-ORIGINAL-30000/config/) — mixed gamemode, protección de
> bloques y sistema de reglas.

## ¿Qué leer primero?

1. **Siempre**: [01-CONFIGURATION_HIERARCHY.md](01-CONFIGURATION_HIERARCHY.md) — entender por qué
   `world.mt` gana sobre el `.conf` evita el 80% de los bugs de "mi mod no carga / no se apaga".
2. Si trabajas con VoxeLibre a fondo: [04-VOXELIBRE_SYSTEM.md](04-VOXELIBRE_SYSTEM.md).
