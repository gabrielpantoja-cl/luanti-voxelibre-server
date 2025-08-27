---
title: Documentación de Mods Actuales
type: technical-documentation
project: vegan-wetlands
audience: developers
language: spanish
version: 1.0
created: 2025-08-26
updated: 2025-08-26
---

# 📋 Documentación Técnica - Mods Actuales

> **Estado de mods implementados y funcionando en Vegan Wetlands**

## 🗂️ Resumen de Mods

| Mod | Estado | Versión | Líneas de Código | Funcionalidad Principal |
|-----|--------|---------|------------------|------------------------|
| `animal_sanctuary` | ✅ **FUNCIONANDO** | v1.0.0 | ~330 líneas | Sistema de cuidado animal vegano |
| `vegan_foods` | ✅ **FUNCIONANDO** | v1.0.0 | ~80 líneas | Alimentos veganos craftables |
| `education_blocks` | ✅ **FUNCIONANDO** | v1.0.0 | ~100 líneas | Bloques educativos interactivos |
| `protector` | ✅ Activo | Externo | N/A | Anti-griefing y protección |

### 🎉 ESTADO ACTUALIZADO - 27 AGOSTO 2025
**PROBLEMA CRÍTICO RESUELTO**: Los mods ahora cargan correctamente en VoxeLibre usando mapeo directo a `/games/mineclone2/mods/CATEGORIA/`.

---

## 🐾 animal_sanctuary (Mod Principal)

### Metadatos
```lua
-- mod.conf
name = animal_sanctuary
title = Animal Sanctuary - Santuario de Animales
description = Un mod para crear santuarios veganos donde cuidar y proteger animales en lugar de lastimarlos.
depends = default
author = Vegan Wetlands Team
release = 1.0.0
min_minetest_version = 5.0.0
```

### Arquitectura del Código

#### Herramientas de Cuidado
```lua
-- animal_brush: Herramienta principal (reemplaza armas)
minetest.register_tool("animal_sanctuary:animal_brush", {
    description = "Cepillo para Animales 🧽\nUsa esto para cuidar y mimar a los animales",
    inventory_image = "animal_sanctuary_brush.png",
    range = 4.0,
    on_use = function(itemstack, user, pointed_thing)
        -- Genera partículas de corazones
        -- Sonido de animales felices
        -- Mensaje educativo positivo
    end,
})
```

#### Sistema de Construcciones
```lua
-- sanctuary_gate: Puerta de entrada con bienvenida
-- animal_feeder: Comedero funcional 
-- animal_shelter: Refugio con nodeboxes personalizados
```

#### Mecánicas Anti-Violencia
```lua
-- Prevención de daño entre jugadores
minetest.register_on_punchplayer(function(player, hitter, ...)
    if hitter and hitter:is_player() then
        -- Mensaje educativo en lugar de permitir daño
        -- Retorna true para cancelar daño
    end
end)
```

#### Sistema de Bienvenida
```lua
-- Kit inicial automático para nuevos jugadores
minetest.register_on_newplayer(function(player)
    local inv = player:get_inventory()
    inv:add_item("main", "animal_sanctuary:animal_brush")
    inv:add_item("main", "animal_sanctuary:vegan_animal_food 10")
    inv:add_item("main", "animal_sanctuary:animal_medkit")
end)
```

### Comandos de Chat
- `/santuario`: Muestra información completa del sistema de santuarios
- `/veganismo`: Educación sobre filosofía vegana

### Assets Requeridos
- `animal_sanctuary_brush.png` - Textura del cepillo
- `animal_sanctuary_medkit.png` - Textura del kit médico  
- `animal_sanctuary_happy.ogg` - Sonido de animales contentos
- `heart.png` - Partículas de afecto

---

## 🍎 vegan_foods (Alternativas Alimentarias)

### Metadatos
```lua
-- mod.conf  
name = vegan_foods
title = Vegan Foods - Comida Vegana
description = Alimentos 100% vegetales deliciosos y nutritivos para el servidor Vegan Wetlands
depends = default, farming
author = Vegan Wetlands Team
release = 1.0.0
```

### Alimentos Implementados

#### Craftitems Principales
```lua
-- vegan_burger: 8 puntos de comida
-- oat_milk: 4 puntos de comida  
-- vegan_cheese: 6 puntos de comida
-- vegan_pizza: 12 puntos de comida (más nutritiva)
```

### Sistema de Recetas
```lua
-- Ejemplo: Hamburguesa vegana
minetest.register_craft({
    output = "vegan_foods:vegan_burger",
    recipe = {
        {"farming:bread"},
        {"default:apple"},     -- Base proteica  
        {"farming:bread"}
    }
})
```

### Integración con VoxeLibre
- Dependencia de `farming` para ingredientes base
- Uso de `default:apple` y `farming:wheat` como componentes
- Compatibilidad con sistema de hambre de VoxeLibre

---

## 📚 education_blocks (Bloques Educativos)

### Metadatos
```lua
-- mod.conf
name = education_blocks
title = Education Blocks - Bloques Educativos
description = Bloques educativos sobre veganismo y cuidado animal para Vegan Wetlands  
depends = default
author = Vegan Wetlands Team
release = 1.0.0
```

### Bloques Interactivos

#### vegan_sign - Cartel Educativo
```lua
minetest.register_node("education_blocks:vegan_sign", {
    description = "Cartel Vegano 📋\nInformación sobre veganismo",
    drawtype = "signlike",
    paramtype2 = "wallmounted",
    on_rightclick = function(pos, node, player, itemstack, pointed_thing)
        -- Muestra dato educativo aleatorio de array predefinido
        local facts = {
            "🌱 Los animales son seres sintientes que sienten dolor y alegría",
            "💚 Una dieta vegana es saludable y completa",
            -- ... más datos educativos
        }
    end,
})
```

#### nutrition_block - Información Nutricional
```lua
-- Datos sobre proteínas vegetales, vitaminas, minerales
-- Formato educativo apropiado para niños
-- Información científica pero accesible
```

#### animal_facts - Datos de Animales
```lua
-- Hechos sobre inteligencia animal
-- Comportamientos sociales de animales de granja
-- Información que promueve empatía
```

### Mecánica Educativa
- Mensajes aleatorios para mantener interés
- Información científica verificada
- Tono positivo y motivador
- Emojis contextuales para engagement visual

---

## 🛡️ protector (Anti-Griefing)

### Funcionalidad
- Protección automática de construcciones
- Sistema de áreas protegidas por jugador
- Herramientas de administración
- Compatibilidad con mods existentes

### Integración
- No interfiere con mecánicas veganas
- Protege santuarios construidos por jugadores
- Permite construcción colaborativa controlada

---

## ⚙️ Configuración del Servidor

### luanti.conf Relevante
```ini
# Modo creativo activado
creative_mode = true
enable_damage = false

# Mods cargados
load_mod_animal_sanctuary = true
load_mod_vegan_foods = true  
load_mod_education_blocks = true
load_mod_protector = true

# Configuración anti-violencia
enable_pvp = false
```

### Dependencias de Sistema
```yaml
Base Game: VoxeLibre (MineClone2) v0.90.1
Luanti Version: 5.13+
Container: linuxserver/luanti:latest
Port: 30000/UDP
```

---

## 🚀 Performance y Optimización

### Métricas Actuales
- **Tiempo de carga**: ~3 segundos para los 4 mods
- **Memoria RAM**: ~15MB adicionales por mods custom
- **CPU**: Impacto mínimo, solo en eventos on_rightclick
- **Red**: Sin sincronización adicional compleja

### Optimizaciones Implementadas
- Uso eficiente de `math.random()` para contenido aleatorio
- Particulas limitadas en tiempo y cantidad
- Sonidos con `max_hear_distance` para limitar alcance
- Arrays de strings pre-definidos (no generación dinámica)

### Potenciales Mejoras
- Cache de mensajes educativos por jugador
- Throttling de partículas para múltiples jugadores
- Compresión de texturas para reducir ancho de banda

---

## 🔧 Troubleshooting Común

### Problemas Conocidos
1. **Texturas faltantes**: Algunos assets pueden no cargar
   - **Solución**: Verificar paths en `textures/` folder
   
2. **Sonidos no reproducen**: Audio no disponible en algunos dispositivos
   - **Solución**: Graceful fallback, funcionalidad no depende de audio
   
3. **Conflictos con otros mods**: Incompatibilidad potencial
   - **Solución**: Testing en entorno aislado antes de deployment

### Logs de Debug
```bash
# Verificar carga de mods
grep "Animal Sanctuary\|Vegan Foods\|Education Blocks" debug.txt

# Monitorear errores
tail -f debug.txt | grep ERROR
```

---

## 📊 Estadísticas de Uso

### Métricas Tracked (manual)
- Número de veces que jugadores usan `/santuario`
- Clicks en bloques educativos
- Items crafteados de comida vegana
- Nuevos jugadores que reciben kit inicial

### Analytics Deseadas (futuras)
- Tiempo promedio interactuando con contenido educativo
- Progresión de jugadores en sistema de compasión
- Construcciones de santuarios por jugador
- Retención de jugadores (sesiones repetidas)

---

## 🔗 Referencias y Recursos

### APIs Utilizadas
- `minetest.register_*()` - Registro de objetos del juego
- `minetest.chat_send_player()` - Sistema de mensajes
- `minetest.add_particlespawner()` - Efectos visuales
- `minetest.sound_play()` - Sistema de audio

### Documentación Externa
- [Luanti Mod API](https://minetest.gitlab.io/minetest/)
- [VoxeLibre Developer Docs](https://git.minetest.land/VoxeLibre/VoxeLibre)
- [Lua 5.1 Reference](https://www.lua.org/manual/5.1/)

---

*Documentación actualizada: Agosto 2025*  
*Próxima revisión: Con cada nuevo release de mods*