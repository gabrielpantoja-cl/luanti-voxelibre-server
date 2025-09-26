# Documentación de Mods - Wetlands Valdivia

Esta carpeta contiene la documentación completa de todos los mods personalizados del servidor Wetlands Valdivia.

## 📚 Índice de Documentación

### Documentación General
- **[Sistema de Mods VoxeLibre](../VOXELIBRE_MOD_SYSTEM.md)** - Guía técnica completa sobre compatibilidad y troubleshooting

### Mods Personalizados

#### 🎮 Mods Activos y Funcionando

| Mod | Descripción | Documentación | Estado |
|-----|-------------|---------------|---------|
| **server_rules** | Sistema de reglas automático y comandos | [📋 SERVER_RULES_MOD.md](SERVER_RULES_MOD.md) | ✅ Operativo |
| **education_blocks** | Bloques educativos interactivos | [📚 EDUCATION_BLOCKS_MOD.md](EDUCATION_BLOCKS_MOD.md) | ✅ Operativo |
| **vegan_food** | Alimentos plant-based del ContentDB | [Documentación Externa](https://content.luanti.org/packages/Daenvil/vegan_food/) | ✅ Operativo |
| **back_to_spawn** | Teleportación a spawn personal | [Documentación Externa](https://content.luanti.org/packages/Alex5002/mcl_back_to_spawn/) | ✅ Operativo |

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

### Mods Cargados Actualmente
- **Total de mods personalizados**: 4
- **Mods del ContentDB**: 2 (vegan_food, back_to_spawn)
- **Mods desarrollados localmente**: 2 (server_rules, education_blocks)
- **Comandos disponibles**: 5
- **Bloques educativos**: 3

### Compatibilidad
- ✅ **VoxeLibre v0.90.1**: Totalmente compatible
- ✅ **Luanti 5.13+**: Funcionando
- ✅ **Docker linuxserver/luanti**: Optimizado

## 🔮 Roadmap de Mods

### Próximas Mejoras
- [ ] **animal_sanctuary**: Reactivar con compatibilidad VoxeLibre
- [ ] **wetland_city**: Estructuras urbanas sostenibles
- [ ] **home_teleport**: Sistema de teleportación mejorado
- [ ] **Nuevos bloques educativos**: Reciclaje, energías renovables

### Mods en Consideración
- [ ] **quests_compassion**: Sistema de misiones educativas
- [ ] **sustainable_farming**: Agricultura sostenible avanzada
- [ ] **animal_behavior**: Comportamientos realistas de animales
- [ ] **renewable_energy**: Energías renovables en el juego

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
**Última actualización**: 2025-09-21
**Responsable**: Equipo Wetlands Valdivia
**Próxima revisión**: Al agregar nuevos mods