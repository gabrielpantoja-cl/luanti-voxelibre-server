# Documentación de Mods - Wetlands Valdivia

Esta carpeta contiene la documentación completa de todos los mods personalizados del servidor Wetlands Valdivia.

## 📚 Índice de Documentación

### Documentación General
- **[Sistema de Mods VoxeLibre](../VOXELIBRE_MOD_SYSTEM.md)** - Guía técnica completa sobre compatibilidad y troubleshooting

### Mods Personalizados

#### 🎮 Mods Activos y Funcionando

| Mod | Descripción | Documentación | Estado |
|-----|-------------|---------------|---------|
| **server_rules** | Sistema de reglas automático y comandos | [📋 SERVER_RULES_MOD_V2.md](SERVER_RULES_MOD_V2.md) | ✅ Operativo |
| **education_blocks** | Bloques educativos interactivos | [📚 EDUCATION_BLOCKS_MOD.md](EDUCATION_BLOCKS_MOD.md) | ✅ Operativo |
| **vegan_food** | Alimentos plant-based | [Documentación Externa](https://content.luanti.org/packages/Daenvil/vegan_food/) | ✅ Operativo |
| **back_to_spawn** | Teleportación a spawn personal | [Documentación Externa](https://content.luanti.org/packages/Alex5002/mcl_back_to_spawn/) | ✅ Operativo |
| **halloween_ghost** | Evento especial de Halloween | - | ✅ Operativo (temporal) |
| **voxelibre_protection** | Sistema de protección compatible | [📄 voxelibre_protection.md](voxelibre_protection.md) | ✅ Operativo |
| **protector** | Protección de áreas | [Documentación Externa](https://content.luanti.org/packages/TenPlus1/protector/) | ✅ Operativo |
| **areas** | Gestión de áreas protegidas | [Documentación Externa](https://content.luanti.org/packages/ShadowNinja/areas/) | ✅ Operativo |
| **creative_force** | Modo creativo forzado | - | ✅ Operativo |
| **vegan_replacements** | Reemplazos veganos en recetas | - | ✅ Operativo |
| **wetland_city** | Estructuras y ciudad del servidor | - | ✅ Operativo |
| **sethome** | Sistema de homes personales | - | ✅ Operativo |
| **worldedit** | Suite completa de edición | [Documentación Externa](https://github.com/Uberi/Minetest-WorldEdit) | ✅ Operativo (4 mods) |

#### 🔧 Comandos Disponibles

| Comando | Función | Mod Responsable |
|---------|---------|-----------------|
| `/reglas` | Muestra reglas completas del servidor | server_rules |
| `/r` | Reglas rápidas | server_rules |
| `/santuario` | Info sobre cuidado de animales | server_rules |
| `/filosofia` | Filosofía del servidor | education_blocks |
| `/back_to_spawn` | Teletransporte a spawn | back_to_spawn |

## 🛠️ Guías de Desarrollo

### Para Crear Nuevos Mods
1. **Leer primero**: [Sistema de Mods VoxeLibre](../VOXELIBRE_MOD_SYSTEM.md)
2. **Verificar compatibilidad**: Usar items `mcl_*` en lugar de `default:*`
3. **Evitar dependencias problemáticas**: No usar `mcl_sounds`, `default`, `farming`
4. **Crear documentación**: Seguir el formato de los mods existentes

### Estructura de Documentación de Mod
Cada mod debe tener su documentación que incluya:
- 📋 **Información General**: Nombre, propósito, autor
- 🎯 **Funcionalidades**: Comandos, bloques, mecánicas
- 🛠️ **Implementación Técnica**: APIs, compatibilidad, recetas
- 🧪 **Testing**: Cómo verificar que funciona
- 🚨 **Troubleshooting**: Problemas comunes y soluciones

## 🚨 Problemas Resueltos (Historial)

### Octubre 3, 2025 - Limpieza de Mods Incompatibles
**Problema**: Mods legacy y incompatibles causando riesgo de corrupción de texturas
**Causa**:
- Mods incompatibles con VoxeLibre (biofuel, mobkit, motorboat)
- Mods duplicados (animal_sanctuary.disabled, vegan_foods, motorboat.disabled)
- Archivos sueltos de WorldEdit en directorio root de mods
- Inconsistencia entre VPS y repositorio local

**Solución**:
- ✅ Eliminados 5 mods incompatibles: biofuel, mobkit, motorboat (+ versiones .disabled)
- ✅ Eliminados 3 mods duplicados/legacy: animal_sanctuary.disabled, vegan_foods, home_teleport
- ✅ Limpiados 7 archivos sueltos de documentación WorldEdit
- ✅ Actualizada configuración luanti.conf (deshabilitados mods eliminados)
- ✅ Sincronizado VPS y repositorio local

**Resultado**:
- 🎯 De 26 mods a 18 mods (reducción de 8 directorios)
- ✅ Eliminado riesgo de corrupción de texturas
- ✅ Consistencia 100% entre VPS y local
- ✅ Servidor funcionando correctamente

### Septiembre 21, 2025 - Fix Comandos del Servidor
**Problema**: Comandos `/reglas`, `/filosofia`, `/santuario` no funcionaban
**Causa**:
- Conflictos entre `education_blocks` y `education_blocks.disabled`
- Dependencias incorrectas en `mod.conf`
- Items de Minetest vanilla en recetas

**Solución**:
- Eliminado archivos `.disabled`
- Actualizado dependencies para VoxeLibre
- Convertido recetas a items `mcl_*`
- Implementado sistema de reglas automáticas

**Resultado**: ✅ Todos los comandos funcionando correctamente

## 📊 Estadísticas del Sistema

### Mods Cargados Actualmente (Oct 2025)
- **Total de mods activos**: 18 mods
- **Mods del ContentDB**: 4 (vegan_food, back_to_spawn, protector, areas)
- **Mods desarrollados localmente**: 6 (server_rules, education_blocks, halloween_ghost, voxelibre_protection, creative_force, vegan_replacements, wetland_city)
- **Suite WorldEdit**: 4 mods (worldedit, worldedit_brush, worldedit_commands, worldedit_gui, worldedit_shortcommands)
- **Sistema de homes**: sethome
- **Comandos disponibles**: 5+
- **Bloques educativos**: 3

### Compatibilidad
- ✅ **VoxeLibre v0.90.1**: Totalmente compatible
- ✅ **Luanti 5.13+**: Funcionando
- ✅ **Docker linuxserver/luanti**: Optimizado
- ✅ **Sin mods incompatibles**: Limpieza Oct 2025 completa

## 🔮 Roadmap de Mods

### Próximas Mejoras
- [ ] **animal_sanctuary**: Reactivar con compatibilidad VoxeLibre completa
- [ ] **Nuevos bloques educativos**: Reciclaje, energías renovables, compostaje
- [ ] **Sistema de quests**: Misiones educativas sobre compasión animal
- [ ] **Mejoras halloween_ghost**: Más eventos temporales educativos

### Mods en Consideración
- [ ] **quests_compassion**: Sistema de misiones educativas
- [ ] **sustainable_farming**: Agricultura sostenible avanzada
- [ ] **animal_behavior**: Comportamientos realistas de animales del santuario
- [ ] **renewable_energy**: Energías renovables en el juego

### ❌ Mods Descartados (Incompatibles)
- ❌ **biofuel**: Incompatible con VoxeLibre (corrupción de texturas)
- ❌ **mobkit**: Incompatible con VoxeLibre (corrupción de texturas)
- ❌ **motorboat**: Incompatible con VoxeLibre (corrupción de texturas)

## 📞 Soporte y Contribuciones

### Reportar Problemas con Mods
1. **Verificar documentación**: Consultar este directorio primero
2. **Revisar logs**: `docker compose logs luanti-server`
3. **Seguir troubleshooting**: Usar guías de cada mod
4. **Crear issue**: En el repositorio GitHub con logs completos

### Contribuir Nuevos Mods
1. **Fork del repositorio**: Crear rama para nuevo mod
2. **Seguir estándares**: Compatibilidad VoxeLibre obligatoria
3. **Crear documentación**: Seguir formato establecido
4. **Testing completo**: Verificar en servidor de prueba
5. **Pull request**: Con documentación completa

---
**Última actualización**: 2025-10-03 (Limpieza de mods incompatibles)
**Responsable**: Equipo Wetlands Valdivia
**Próxima revisión**: Al agregar nuevos mods

## 📋 Lista Completa de Mods Activos

```
server/mods/
├── animal_sanctuary/          # Santuarios de animales (deshabilitado temporalmente)
├── areas/                     # Gestión de áreas protegidas
├── back_to_spawn/            # Teleportación a spawn personal
├── creative_force/           # Modo creativo forzado
├── education_blocks/         # Bloques educativos interactivos
├── halloween_ghost/          # Evento especial Halloween 2025
├── protector/                # Protección de áreas (TenPlus1)
├── server_rules/             # Sistema de reglas automáticas
├── sethome/                  # Sistema de homes personales
├── vegan_food/               # Alimentos plant-based
├── vegan_replacements/       # Reemplazos veganos en recetas
├── voxelibre_protection/     # Protección compatible VoxeLibre
├── wetland_city/             # Estructuras y ciudad
├── worldedit/                # Editor de mundos (core)
├── worldedit_brush/          # Herramientas de pincel
├── worldedit_commands/       # Comandos adicionales
├── worldedit_gui/            # Interfaz gráfica
└── worldedit_shortcommands/  # Comandos abreviados
```

**Total**: 18 directorios de mods activos