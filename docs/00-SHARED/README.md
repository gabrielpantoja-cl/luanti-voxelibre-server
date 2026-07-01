# 📚 Documentación compartida (00-SHARED)

Documentación **transversal a los 4 mundos** del servidor: mecánica del motor Luanti/VoxeLibre,
técnicas de configuración, guías de mods reutilizables, operaciones e infraestructura web.

> ⚠️ **Qué NO va aquí.** Esto es documentación **agnóstica al mundo**. La filosofía, las reglas y la
> configuración específicas de cada mundo viven en su carpeta (`01-ORIGINAL-30000/`, `02-VALDIVIA-30001/`,
> `03-GAELSIN-30002/`, `04-CTF-30003/`). En particular, **no todos los mundos comparten la filosofía
> "sin violencia / compasión"**: Wetlands (30000) y Valdivia (30001) son pacíficos, pero **GAELSIN
> (30002) es survival PvP con mobs hostiles** y **Llanura CTF (30003) es captura-la-bandera con armas**.
> Cuando un documento aquí solo aplica a algunos mundos, lo indica en una nota al inicio.

## Los 4 mundos (documentación específica en su carpeta)

| Puerto | Mundo | Tipo | Carpeta |
|--------|-------|------|---------|
| 30000 | Wetlands | Creativo / educativo / pacífico | [`../01-ORIGINAL-30000/`](../01-ORIGINAL-30000/) |
| 30001 | Valdivia [Chile] | Ciudad OSM / exploración / pacífico | [`../02-VALDIVIA-30001/`](../02-VALDIVIA-30001/) |
| 30002 | GAELSIN | Survival / **PvP** / mobs hostiles | [`../03-GAELSIN-30002/`](../03-GAELSIN-30002/) |
| 30003 | Llanura CTF | Captura la bandera / **armas** | [`../04-CTF-30003/`](../04-CTF-30003/) |

## Contenido de esta carpeta

### ⚙️ [config/](config/) — Configuración y mecánica del motor
| Archivo | Aplica a | Descripción |
|---------|----------|-------------|
| [01-CONFIGURATION_HIERARCHY.md](config/01-CONFIGURATION_HIERARCHY.md) | **Todos** | Jerarquía `world.mt` vs `luanti-*.conf` — el pitfall #1 de "por qué no carga mi mod" |
| [02-NUCLEAR_CONFIG.md](config/02-NUCLEAR_CONFIG.md) | Wetlands, Valdivia | Técnica para desactivar mobs hostiles (los mundos PvP NO la usan) |
| [04-VOXELIBRE_SYSTEM.md](config/04-VOXELIBRE_SYSTEM.md) | **Todos** | Arquitectura interna de VoxeLibre, sistema de mods, rendimiento |
| [07-CUSTOM_SKINS.md](config/07-CUSTOM_SKINS.md) | **Todos** | Sistema de skins de jugadores (`server/skins/` es compartido) |
| [08-CREATIVE_NATIVE_MODE.md](config/08-CREATIVE_NATIVE_MODE.md) | Wetlands, Valdivia | Modo creativo nativo VoxeLibre (los mundos survival/CTF NO lo usan) |

> Nota: los números 03, 05 y 06 se movieron a `01-ORIGINAL-30000/config/` por ser específicos de
> Wetlands (mixed gamemode, protección de bloques, sistema de reglas). Los huecos en la numeración
> son intencionales.

### 👨‍💼 [admin/](admin/) — Administración
| Archivo | Aplica a | Descripción |
|---------|----------|-------------|
| [comandos-admin.md](admin/comandos-admin.md) | **Todos** | Comandos administrativos de Luanti/VoxeLibre |
| [VOXELIBRE_SERVER_SETTINGS.md](admin/VOXELIBRE_SERVER_SETTINGS.md) | **Todos** | Configuración del servidor desde la interfaz del cliente |
| [QUICK_ADD_SKINS.md](admin/QUICK_ADD_SKINS.md) | **Todos** | Workflow rápido para agregar skins |
| [SKINS_INVENTORY.md](admin/SKINS_INVENTORY.md) | **Todos** | Catálogo de skins disponibles |
| [TROUBLESHOOTING_MCL_POTIONS_BUG.md](admin/TROUBLESHOOTING_MCL_POTIONS_BUG.md) | **Todos** | Bug de `mcl_potions` de VoxeLibre y su fix |
| [agentes-claude.md](admin/agentes-claude.md) | Repo | Agentes especializados de Claude para este repositorio |

### 🧩 [mods/](mods/) — Guías de mods reutilizables
| Archivo | Aplica a | Descripción |
|---------|----------|-------------|
| [MODDING_GUIDE.md](mods/MODDING_GUIDE.md) | **Todos** | Guía general de desarrollo de mods para VoxeLibre |
| [WORLDEDIT_GUIDE.md](mods/WORLDEDIT_GUIDE.md) | **Todos** | Uso de WorldEdit |
| [CHESS_MOD.md](mods/CHESS_MOD.md) | Donde esté cargado | Mod de ajedrez |
| [AREAS_PROTECTION_SYSTEM.md](mods/AREAS_PROTECTION_SYSTEM.md) | Donde esté cargado | Mod `areas` de protección (incluye caso de estudio de Wetlands) |

### 🔧 [operations/](operations/) — Operaciones e infraestructura
| Archivo | Descripción |
|---------|-------------|
| [BACKUP_STATUS.md](operations/BACKUP_STATUS.md) | Estado y plan del sistema de backups |
| [clonar-mundo-produccion-local.md](operations/clonar-mundo-produccion-local.md) | Descargar un backup del VPS y correrlo localmente |
| [MCP_SERVERS.md](operations/MCP_SERVERS.md) | Servidores MCP disponibles |

> Deploy, texture-recovery y troubleshooting profundos viven en el **repo privado**
> `infra/privado/luanti/operations/` (contienen credenciales y datos sensibles).

### 🌐 [web/](web/) — Landing page e infraestructura web
| Archivo | Descripción |
|---------|-------------|
| [landing-page.md](web/landing-page.md) | Arquitectura y deploy de `luanti.gabrielpantoja.cl` (cubre todos los mundos) |
| [api-docs.md](web/api-docs.md) | Documentación de futuras APIs |
| [nginx/](web/nginx/) | Configuración nginx de referencia |

### 🚀 [quickstart/](quickstart/) — Conexión inicial
| Archivo | Descripción |
|---------|-------------|
| [conexion-basica.md](quickstart/conexion-basica.md) | Descargar Luanti y conectarse a cualquiera de los servidores |
| [Semillas Voxelibre_ Mejores Generaciones de Mapas.md](quickstart/Semillas%20Voxelibre_%20Mejores%20Generaciones%20de%20Mapas.md) | Semillas recomendadas de VoxeLibre |

> El tutorial de primeros pasos con la filosofía de Wetlands se movió a
> [`../01-ORIGINAL-30000/quickstart/primeros-pasos.md`](../01-ORIGINAL-30000/quickstart/primeros-pasos.md).
