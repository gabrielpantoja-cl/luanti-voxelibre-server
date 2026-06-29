# ⚙️ Server Configuration Documentation

**Última actualización**: 2026-01-16
**Servidor**: Wetlands Luanti/VoxeLibre (`luanti.gabrielpantoja.cl:30000`)
**Mantenedor**: Gabriel Pantoja (gabo)

---

## 📋 Índice de Documentación

Todos los documentos están ordenados por **orden de importancia** con prefijos numéricos (01-07).

### 🎯 Configuración Crítica (01-02)

| # | Archivo | Descripción | Prioridad |
|---|---------|-------------|-----------|
| **01** | [CONFIGURATION_HIERARCHY.md](01-CONFIGURATION_HIERARCHY.md) | **Jerarquía de configuración en cascada** - Entender cómo se sobrescriben configs (luanti-original.conf > world.mt > mods) | 🔴 CRÍTICO |
| **02** | [NUCLEAR_CONFIG.md](02-NUCLEAR_CONFIG.md) | **Configuración nuclear anti-mobs** - Modificaciones fuera del repositorio para eliminar monstruos hostiles | 🔴 CRÍTICO |

### ⭐ Configuración Importante (03-04)

| # | Archivo | Descripción | Prioridad |
|---|---------|-------------|-----------|
| **03** | [MIXED_GAMEMODE.md](03-MIXED_GAMEMODE.md) | **Modos de juego mixtos** - Sistema para tener jugadores en creativo Y supervivencia simultáneamente. Incluye caso de estudio: migración pepelomo | ⚠️ IMPORTANTE |
| **04** | [VOXELIBRE_SYSTEM.md](04-VOXELIBRE_SYSTEM.md) | **Sistema VoxeLibre completo** - Arquitectura interna, sistema de mods, troubleshooting y optimización de rendimiento | ⚠️ IMPORTANTE |

### 🛠️ Configuración Funcional (05-08)

| # | Archivo | Descripción | Prioridad |
|---|---------|-------------|-----------|
| **05** | [BLOCK_PROTECTION.md](05-BLOCK_PROTECTION.md) | **Sistema de protección de bloques** - Guía completa del sistema anti-griefing con bloques protectores | ℹ️ FUNCIONAL |
| **06** | [RULES_SYSTEM.md](06-RULES_SYSTEM.md) | **Sistema de reglas automáticas** - Configuración de comandos `/reglas`, `/filosofia`, mensajes automáticos | ℹ️ FUNCIONAL |
| **07** | [CUSTOM_SKINS.md](07-CUSTOM_SKINS.md) | **Skins personalizados** - Instalación y configuración de mods para skins de jugadores | ℹ️ FUNCIONAL |
| **08** | [CREATIVE_NATIVE_MODE.md](08-CREATIVE_NATIVE_MODE.md) | **Modo creativo nativo** - Inventario infinito VoxeLibre sin bugs de persistencia (CONFIGURACIÓN ACTUAL) | ⚠️ IMPORTANTE |

---

## 🚨 ¿Qué Leer Primero?

### Si eres nuevo en el servidor:
1. **Empieza por**: [01-CONFIGURATION_HIERARCHY.md](01-CONFIGURATION_HIERARCHY.md)
2. **Luego lee**: [02-NUCLEAR_CONFIG.md](02-NUCLEAR_CONFIG.md) para entender la configuración anti-mobs
3. **Después revisa**: [04-VOXELIBRE_SYSTEM.md](04-VOXELIBRE_SYSTEM.md) para troubleshooting de mods

### Si necesitas cambiar modos de juego:
→ **Configuración actual**: [08-CREATIVE_NATIVE_MODE.md](08-CREATIVE_NATIVE_MODE.md) - Modo creativo nativo (RECOMENDADO)
→ **Sistema legacy**: [03-MIXED_GAMEMODE.md](03-MIXED_GAMEMODE.md) - Modos mixtos con creative_force (DEPRECADO)

### Si tienes problemas con mods:
→ **Revisa**: [04-VOXELIBRE_SYSTEM.md](04-VOXELIBRE_SYSTEM.md) → Sección 2: Sistema de Mods Técnico

### Si necesitas proteger construcciones:
→ **Consulta**: [05-BLOCK_PROTECTION.md](05-BLOCK_PROTECTION.md)

---

## 📖 Guía Rápida por Tema

### 🎮 Configuración del Juego

- **Jerarquía de configs**: [01-CONFIGURATION_HIERARCHY.md](01-CONFIGURATION_HIERARCHY.md)
- **Eliminar monstruos**: [02-NUCLEAR_CONFIG.md](02-NUCLEAR_CONFIG.md)
- **Modos creativo/survival**: [03-MIXED_GAMEMODE.md](03-MIXED_GAMEMODE.md)

### 🔧 Sistema Técnico

- **Arquitectura VoxeLibre**: [04-VOXELIBRE_SYSTEM.md](04-VOXELIBRE_SYSTEM.md) → Sección 1
- **Sistema de mods**: [04-VOXELIBRE_SYSTEM.md](04-VOXELIBRE_SYSTEM.md) → Sección 2
- **Optimización**: [04-VOXELIBRE_SYSTEM.md](04-VOXELIBRE_SYSTEM.md) → Sección 3

### 🛡️ Protección y Reglas

- **Anti-griefing**: [05-BLOCK_PROTECTION.md](05-BLOCK_PROTECTION.md)
- **Sistema de reglas**: [06-RULES_SYSTEM.md](06-RULES_SYSTEM.md)

### 🎨 Personalización

- **Skins personalizados**: [07-CUSTOM_SKINS.md](07-CUSTOM_SKINS.md)

---

## 🚨 Configuraciones Críticas

### Nuclear Config Override (02)

**¿Qué es?**: Configuración especial que modifica archivos **FUERA del repositorio** para eliminar completamente el spawning de monstruos hostiles.

**⚠️ Advertencia**: Esta configuración **NO está en Git** y debe aplicarse manualmente en el VPS.

**Cuándo usar**: Si después de reiniciar el servidor aparecen monstruos hostiles a pesar de todas las configuraciones.

**Ver**: [02-NUCLEAR_CONFIG.md](02-NUCLEAR_CONFIG.md)

### Configuration Hierarchy (01)

**¿Qué es?**: Explicación de cómo las diferentes configuraciones se sobrescriben entre sí.

**Orden de autoridad**:
1. `luanti-original.conf` (🎯 MÁXIMA - Sobrescribe todo)
2. `world.mt` (🏠 Media - Config por mundo)
3. Mods (🔧 Baja - Solo si no hay override)

**Ver**: [01-CONFIGURATION_HIERARCHY.md](01-CONFIGURATION_HIERARCHY.md)

---

## 📊 Estructura de Archivos

```
docs/config/
├── README.md                              # 📖 Este archivo - Índice general
├── 01-CONFIGURATION_HIERARCHY.md         # 🎯 CRÍTICO - Jerarquía de configs
├── 02-NUCLEAR_CONFIG.md                  # 🚨 CRÍTICO - Anti-mobs
├── 03-MIXED_GAMEMODE.md                  # 📚 LEGACY - Modos mixtos (deprecado)
├── 04-VOXELIBRE_SYSTEM.md                # ⭐ IMPORTANTE - Sistema completo VoxeLibre
├── 05-BLOCK_PROTECTION.md                # 🛡️ Sistema de protección
├── 06-RULES_SYSTEM.md                    # 📜 Sistema de reglas
├── 07-CUSTOM_SKINS.md                    # 🎨 Skins personalizados
└── 08-CREATIVE_NATIVE_MODE.md            # ⚠️ IMPORTANTE - Modo creativo actual
```

---

## 🔗 Referencias Cruzadas

### Desde Configuración a Mods
- Configuración de mods personalizados → Ver [04-VOXELIBRE_SYSTEM.md](04-VOXELIBRE_SYSTEM.md) Sección 2.4
- Troubleshooting de mods → Ver [04-VOXELIBRE_SYSTEM.md](04-VOXELIBRE_SYSTEM.md) Sección 4.1

### Desde Modos de Juego a Sistema
- Problemas con privilegios → Ver [03-MIXED_GAMEMODE.md](03-MIXED_GAMEMODE.md) Sección 6.3
- Habilitar mods en world.mt → Ver [01-CONFIGURATION_HIERARCHY.md](01-CONFIGURATION_HIERARCHY.md)

### Desde Protección a Reglas
- Comandos de protección → Ver [05-BLOCK_PROTECTION.md](05-BLOCK_PROTECTION.md) Sección 6
- Reglas del servidor → Ver [06-RULES_SYSTEM.md](06-RULES_SYSTEM.md)

---

## 🎓 Casos de Uso Documentados

### Caso 1: Agregar Jugador a Modo Supervivencia
**Documentado en**: [03-MIXED_GAMEMODE.md](03-MIXED_GAMEMODE.md) → Sección 4.1
**Ejemplo real**: Apéndice A - Caso pepelomo

### Caso 2: Resolver "Comandos No Funcionan"
**Documentado en**: [04-VOXELIBRE_SYSTEM.md](04-VOXELIBRE_SYSTEM.md) → Sección 2.2
**Solución**: Incompatibilidades VoxeLibre vs Minetest vanilla

### Caso 3: Servidor Lento o Lagueado
**Documentado en**: [04-VOXELIBRE_SYSTEM.md](04-VOXELIBRE_SYSTEM.md) → Sección 3 y 4.1.2
**Solución**: Optimización de parámetros de rendimiento

### Caso 4: Proteger Construcción de Griefing
**Documentado en**: [05-BLOCK_PROTECTION.md](05-BLOCK_PROTECTION.md) → Sección 2 y 4
**Solución**: Uso de bloques protectores

---

## ⚠️ Advertencias Importantes

### Antes de Modificar Configuraciones

1. **🔴 SIEMPRE hacer backup**: Especialmente de `auth.sqlite` y archivos `.lua`
2. **🔄 Reiniciar servidor**: Cambios en código Lua requieren reinicio completo
3. **👤 Jugadores deben reconectar**: Para que cambios de privilegios apliquen
4. **📝 Documentar cambios**: Usar commits Git descriptivos

### Configuraciones que Requieren Acceso VPS

- [02-NUCLEAR_CONFIG.md](02-NUCLEAR_CONFIG.md): Modifica archivos fuera del repositorio
- [01-CONFIGURATION_HIERARCHY.md](01-CONFIGURATION_HIERARCHY.md): Algunos overrides requieren SSH al VPS
- [04-VOXELIBRE_SYSTEM.md](04-VOXELIBRE_SYSTEM.md): Troubleshooting avanzado puede requerir acceso root

### Configuraciones Peligrosas

⚠️ **NUNCA** modificar directamente en producción sin probar localmente:
- Cambios en `luanti-original.conf` que afecten physics o mapgen
- Modificaciones masivas a privilegios en base de datos
- Deshabilitación de mods críticos como `creative_force` o `pvp_arena`

---

## 🆘 Troubleshooting Rápido

| Problema | Solución Rápida | Documentación Completa |
|----------|-----------------|------------------------|
| **Monstruos aparecen de noche** | Aplicar Nuclear Config | [02-NUCLEAR_CONFIG.md](02-NUCLEAR_CONFIG.md) |
| **Comandos `/reglas` no funcionan** | Verificar incompatibilidades VoxeLibre | [04-VOXELIBRE_SYSTEM.md](04-VOXELIBRE_SYSTEM.md) Sección 2.2 |
| **Jugador no puede abrir baúles** | Otorgar privilegio `interact` | [03-MIXED_GAMEMODE.md](03-MIXED_GAMEMODE.md) Sección 6.3 |
| **Servidor lento/lag** | Ajustar parámetros de rendimiento | [04-VOXELIBRE_SYSTEM.md](04-VOXELIBRE_SYSTEM.md) Sección 3 y 4.1.2 |
| **Mod no carga** | Verificar `world.mt` y dependencias | [04-VOXELIBRE_SYSTEM.md](04-VOXELIBRE_SYSTEM.md) Sección 2.3 y 4.1.1 |
| **Cambio de modo no aplica** | Limpiar DB + reiniciar + reconectar | [03-MIXED_GAMEMODE.md](03-MIXED_GAMEMODE.md) Sección 4.3 |

---

## 📚 Documentación Externa Relacionada

### Dentro del Repositorio
- **CLAUDE.md** - Documentación principal del proyecto
- **docs/mods/** - Documentación específica de mods personalizados
- **docs/VOXELIBRE_MOD_SYSTEM.md** - Sistema de mods (versión legacy, ver 04 en su lugar)

### Recursos Externos
- **VoxeLibre Official**: https://git.minetest.land/VoxeLibre/VoxeLibre
- **Luanti Modding Book**: https://rubenwardy.com/minetest_modding_book/
- **ContentDB**: https://content.luanti.org/

---

## 🔄 Historial de Cambios Mayores

| Fecha | Cambio | Documentos Afectados |
|-------|--------|---------------------|
| **2026-01-16** | ✅ **MIGRACIÓN A MODO CREATIVO NATIVO** - Fix bug inventarios | 08-CREATIVE_NATIVE_MODE.md |
| **2026-01-16** | Deprecación de creative_force mod | 03-MIXED_GAMEMODE.md (marcado legacy) |
| **2026-01-16** | Reorganización completa de docs/config/ | Todos |
| **2026-01-16** | Caso de estudio migración pepelomo | 03-MIXED_GAMEMODE.md |
| **2026-01-15** | Sistema de modos mixtos implementado | 03-MIXED_GAMEMODE.md |
| **2025-12-07** | Sistema de custom skins instalado | 07-CUSTOM_SKINS.md |
| **2025-09-25** | Optimización post-incidente HAKER | 04-VOXELIBRE_SYSTEM.md Sección 3 |
| **2025-09-25** | Análisis arquitectura VoxeLibre | 04-VOXELIBRE_SYSTEM.md Sección 1 |
| **2025-09-21** | Sistema de mods VoxeLibre documentado | 04-VOXELIBRE_SYSTEM.md Sección 2 |

---

## 📧 Soporte y Contacto

**Mantenedor**: Gabriel Pantoja (gabo)
**Servidor**: luanti.gabrielpantoja.cl:30000
**Repository**: https://github.com/gabrielpantoja-cl/luanti-voxelibre-server

**Para preguntas o problemas**:
1. Revisar documentación correspondiente en este directorio
2. Consultar `CLAUDE.md` en raíz del proyecto
3. Revisar issues en GitHub

---

**Última actualización**: 2026-01-16
**Archivos totales**: 8 documentos técnicos + README
**Cobertura**: Configuración completa del servidor Wetlands
**Estado**: ✅ Documentación completa y actualizada
**Configuración Actual**: Modo Creativo Nativo (08-CREATIVE_NATIVE_MODE.md)
