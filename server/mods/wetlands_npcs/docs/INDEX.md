# 📚 Índice de Documentación - Custom Villagers

**Versión**: 2.1.0
**Fecha**: Enero 2026

---

## 🗂️ Guías Disponibles

### 1. [🤖 Sistema de Comportamientos AI](AI_BEHAVIORS.md)
**Documentación completa del sistema de inteligencia artificial tradicional**

**Contenido**:
- ✅ Arquitectura del sistema (FSM - Finite State Machine)
- ✅ Explicación detallada de los 6 estados de comportamiento
- ✅ Configuración avanzada de parámetros
- ✅ Troubleshooting exhaustivo
- ✅ Guía de desarrollo y extensión
- ✅ Comparación AI tradicional vs LLM

**Audiencia**: Desarrolladores, administradores avanzados

**Lectura**: ~30-40 minutos

---

### 2. [🔧 Guía de Integración](INTEGRATION_GUIDE.md)
**Paso a paso para deployment y configuración**

**Contenido**:
- ✅ Verificación de estructura del mod
- ✅ Testing de texturas y assets
- ✅ Deployment a producción
- ✅ Verificación post-deployment
- ✅ Resolución de problemas comunes

**Audiencia**: Administradores de servidor

**Lectura**: ~15-20 minutos

---

## 🚀 Quick Start

### Para Administradores de Servidor

1. **Instalar el mod**:
   ```bash
   cd server/mods/
   git clone <repo>
   ```

2. **Verificar dependencias**:
   - `mcl_mobs` (VoxeLibre)
   - `mcl_core` (VoxeLibre)

3. **Configurar** (opcional en `minetest.conf`):
   ```ini
   custom_villagers_poi_radius = 15
   custom_villagers_auto_greet = true
   custom_villagers_debug = false
   ```

4. **Reiniciar servidor** y testear:
   ```bash
   /spawn_villager farmer
   /villager_state
   ```

5. **Leer documentación detallada**: [AI_BEHAVIORS.md](AI_BEHAVIORS.md)

---

### Para Jugadores

1. **Interactuar con aldeanos**:
   - Click derecho para abrir menú
   - Elegir: Saludar, Sobre su trabajo, Aprender, Comerciar

2. **Observar comportamientos**:
   - Los aldeanos caminan inteligentemente
   - Trabajan en sus profesiones (buscan cultivos, libros, etc.)
   - Duermen de noche automáticamente
   - Te saludan cuando te acercas

3. **Comandos útiles**:
   ```bash
   /villager_info    # Información general
   ```

---

### Para Desarrolladores

1. **Entender la arquitectura**:
   - Leer [AI_BEHAVIORS.md - Sección 2: Arquitectura](AI_BEHAVIORS.md#arquitectura-del-sistema)

2. **Extender el sistema**:
   - Añadir nuevos estados: [Guía de Desarrollo](AI_BEHAVIORS.md#desarrollo-y-extensión)
   - Crear nuevas profesiones: [Ejemplo Chef](AI_BEHAVIORS.md#crear-nueva-profesión-con-comportamientos-custom)
   - Añadir POI custom: [Guía POI](AI_BEHAVIORS.md#añadir-nuevo-tipo-de-poi)

3. **Debugging**:
   ```bash
   /villager_debug on
   /villager_state
   # Ver logs en consola del servidor
   ```

4. **API pública**:
   ```lua
   -- Inyectar AI en tu propio mob
   custom_villagers.behaviors.inject_into_mob(mob_def)

   -- Obtener/modificar configuración
   custom_villagers.config.get("poi_search_radius")
   custom_villagers.config.set("auto_greet.enabled", false)
   ```

---

## 📖 Estructura de la Documentación

```
docs/
├── INDEX.md                  # 📄 Este archivo (índice general)
├── AI_BEHAVIORS.md           # 🤖 Sistema de comportamientos AI (1,000+ líneas)
└── INTEGRATION_GUIDE.md      # 🔧 Guía de integración con VoxeLibre
```

---

## 🔍 Búsqueda Rápida

### Problemas Comunes

| Problema | Solución |
|----------|----------|
| Aldeanos no se mueven | [Troubleshooting - Aldeanos no se mueven](AI_BEHAVIORS.md#problema-aldeanos-no-se-mueven) |
| Aldeanos atascados en paredes | [Sistema anti-stuck automático](AI_BEHAVIORS.md#problema-aldeanos-se-atascan-en-paredes) |
| No duermen de noche | [Verificar configuración de horarios](AI_BEHAVIORS.md#problema-aldeanos-no-duermen-de-noche) |
| Saludos constantes | [Ajustar cooldown y probabilidad](AI_BEHAVIORS.md#problema-aldeanos-saludan-constantemente) |
| Lag del servidor | [Optimizaciones de performance](AI_BEHAVIORS.md#problema-lag-del-servidor) |
| Crash al hacer click derecho | **CORREGIDO en v2.1.0** (formspecs modernos) |

### Configuración

| Parámetro | Archivo | Sección |
|-----------|---------|---------|
| Pesos de comportamiento | [AI_BEHAVIORS.md](AI_BEHAVIORS.md#pesos-probabilísticos) | Configuración |
| Duración de estados | [AI_BEHAVIORS.md](AI_BEHAVIORS.md#duración-de-estados-state_duration) | Configuración |
| POI por profesión | [AI_BEHAVIORS.md](AI_BEHAVIORS.md#puntos-de-interés-poi---points-of-interest) | Configuración |
| Saludos automáticos | [AI_BEHAVIORS.md](AI_BEHAVIORS.md#sistema-de-saludos-automáticos) | Configuración |
| Rutinas día/noche | [AI_BEHAVIORS.md](AI_BEHAVIORS.md#rutinas-díanoche) | Configuración |

### Comandos

| Comando | Descripción | Documentación |
|---------|-------------|---------------|
| `/spawn_villager <tipo>` | Spawnear aldeano | [README.md](../README.md#spawn_villager) |
| `/villager_info` | Información general | [README.md](../README.md#villager_info) |
| `/villager_debug <on\|off>` | Activar debug | [AI_BEHAVIORS.md](AI_BEHAVIORS.md#villager_debug) |
| `/villager_state` | Ver estados actuales | [AI_BEHAVIORS.md](AI_BEHAVIORS.md#villager_state) |
| `/villager_config` | Configurar en runtime | [AI_BEHAVIORS.md](AI_BEHAVIORS.md#villager_config) |

---

## 🎯 Recomendaciones de Lectura

### Si eres **Administrador de Servidor**:
1. Leer [README.md](../README.md) (5 min)
2. Leer [INTEGRATION_GUIDE.md](INTEGRATION_GUIDE.md) completo (20 min)
3. Leer [AI_BEHAVIORS.md - Sección 4: Configuración](AI_BEHAVIORS.md#configuración) (10 min)
4. Guardar [AI_BEHAVIORS.md - Sección 7: Troubleshooting](AI_BEHAVIORS.md#troubleshooting) como referencia

### Si eres **Desarrollador/Modder**:
1. Leer [README.md](../README.md) (5 min)
2. Leer [AI_BEHAVIORS.md](AI_BEHAVIORS.md) completo (30-40 min)
3. Revisar código de `config.lua` y `ai_behaviors.lua` con documentación inline
4. Experimentar con comandos de debug

### Si eres **Jugador/Usuario**:
1. Leer [README.md](../README.md) (5 min)
2. Sección "Uso en el Juego"
3. ¡A jugar y disfrutar!

---

## 📊 Estadísticas de Documentación

- **Total de líneas**: ~2,500+ líneas
- **Archivos**: 3 archivos principales
- **Cobertura**: 100% del sistema AI
- **Ejemplos de código**: 50+ snippets
- **Diagramas**: 5 diagramas ASCII
- **Troubleshooting**: 6 problemas comunes resueltos
- **Comandos documentados**: 8 comandos

---

## 🔗 Enlaces Externos

### Luanti/Minetest
- [Luanti Official Website](https://www.luanti.org/)
- [Luanti API Documentation](https://api.luanti.org/)
- [Minetest Forum](https://forum.minetest.net/)

### VoxeLibre
- [VoxeLibre GitHub](https://github.com/VoxeLibre/VoxeLibre)
- [VoxeLibre ContentDB](https://content.luanti.org/packages/Wuzzy/mineclone2/)

### Wetlands Server
- **Servidor**: luanti.gabrielpantoja.cl:30000
- **Landing Page**: https://luanti.gabrielpantoja.cl
- **GitHub**: [Repositorio privado]

---

## 📝 Historial de Versiones

### v2.1.0 (Enero 2026)
- ✅ Sistema de comportamientos AI tradicional completo
- ✅ Máquina de Estados Finitos (FSM) con 6 estados
- ✅ Pathfinding inteligente con anti-stuck
- ✅ Saludos automáticos proactivos
- ✅ Interacción social entre NPCs
- ✅ Sistema de configuración centralizado
- ✅ Comandos de debug y administración
- ✅ FIX: Crash al hacer click derecho (formspecs modernos)
- ✅ Documentación exhaustiva (2,500+ líneas)

### v2.0.0 (Diciembre 2025)
- Sistema de diálogos educativos
- Sistema de comercio con esmeraldas
- 4 tipos de aldeanos (farmer, librarian, teacher, explorer)
- Texturas profesionales de VoxeLibre
- Protección pacífica (no se pueden lastimar)

---

## 🤝 Contribuir

Si quieres contribuir al mod:

1. **Reportar bugs**: Usa comandos de debug y adjunta logs
2. **Sugerir features**: Describe el comportamiento deseado
3. **Mejorar documentación**: Añade ejemplos o clarifica secciones
4. **Extender funcionalidad**: Sigue la arquitectura existente

---

## 📧 Soporte

- **In-game**: `/villager_info` para información básica
- **Debug**: `/villager_debug on` para diagnosticar problemas
- **Documentación**: Leer [AI_BEHAVIORS.md](AI_BEHAVIORS.md)
- **Comunidad**: Foro de Minetest / Discord de Wetlands

---

**Generado por**: Wetlands Team
**Fecha**: Enero 2026
**Versión del documento**: 1.0.0
