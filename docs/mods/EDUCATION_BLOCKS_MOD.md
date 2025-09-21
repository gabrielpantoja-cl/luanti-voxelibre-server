# Education Blocks Mod - Documentación

## 📚 Información General

- **Nombre**: `education_blocks`
- **Descripción**: Bloques educativos sobre compasión y sostenibilidad
- **Autor**: Equipo Wetlands
- **Propósito**: Enseñar sobre alimentación consciente y cuidado animal
- **Ubicación**: `server/mods/education_blocks/`

## 🎯 Funcionalidades

### Comando `/filosofia`
- **Descripción**: Muestra la filosofía del servidor
- **Mensaje**:
  > "Nuestra filosofía es simple: aprender, crear y explorar con respeto por todos los seres vivos y nuestro planeta. Fomentamos la compasión, la curiosidad y la colaboración. ¡Construyamos un mundo mejor juntos!"
- **Uso**: Disponible para todos los jugadores

### Bloques Educativos Interactivos

#### 🏷️ Cartel Educativo (`education_blocks:sign`)
- **Función**: Muestra datos educativos aleatorios al hacer clic derecho
- **Textura**: Tablón de madera con símbolo educativo
- **Contenido educativo**:
  - "🌱 Los animales son seres sintientes que merecen nuestro respeto."
  - "💚 Una alimentación consciente y basada en plantas es saludable y sostenible."
  - "🌍 Cuidar el planeta es responsabilidad de todos."
  - "🐮 En este mundo, los animales viven libres y en paz."
  - "🌾 Las plantas nos dan todo lo que necesitamos para estar sanos."

#### 🥗 Bloque Nutricional (`education_blocks:nutrition_block`)
- **Función**: Enseña sobre nutrición basada en plantas
- **Textura**: Bloque especializado con gráficos nutricionales
- **Contenido educativo**:
  - "🥬 Las verduras de hoja verde son una gran fuente de hierro."
  - "🥜 Los frutos secos son ricos en proteínas y grasas saludables."
  - "🌾 Los cereales integrales nos dan energía duradera."
  - "🍓 Las frutas están llenas de vitaminas y antioxidantes."
  - "🫘 Las legumbres son una base nutritiva y versátil para muchas comidas."

#### 🐰 Bloque de Datos de Animales (`education_blocks:animal_facts`)
- **Función**: Comparte datos curiosos sobre animales
- **Textura**: Bloque con iconografía animal
- **Contenido educativo**:
  - "🐮 Las vacas tienen mejores amigas y se estresan si las separan."
  - "🐷 Los cerdos son considerados uno de los animales más inteligentes."
  - "🐔 Las gallinas tienen complejas estructuras sociales y pueden reconocer más de 100 caras."
  - "🐰 Los conejos expresan felicidad saltando y girando en el aire."
  - "🐐 Las cabras tienen diferentes 'acentos' en sus balidos según su grupo social."

## 🛠️ Implementación Técnica

### Estructura de Archivos
```
server/mods/education_blocks/
├── mod.conf    # Configuración del mod (sin dependencias problemáticas)
└── init.lua    # Lógica de bloques y comando
```

### mod.conf (Actualizado para VoxeLibre)
```ini
name = education_blocks
description = Bloques y comandos educativos sobre compasión y sostenibilidad.
depends =
optional_depends = mcl_core, mcl_farming
```

### APIs y Compatibilidad VoxeLibre

#### ✅ Items Compatibles con VoxeLibre
| Función | Minetest Vanilla | VoxeLibre |
|---------|------------------|-----------|
| Libros | `default:book` | `mcl_books:book` |
| Palos | `default:stick` | `mcl_core:stick` |
| Manzanas | `default:apple` | `mcl_core:apple` |
| Trigo | `farming:wheat` | `mcl_farming:wheat_item` |
| Piedra | `default:stone` | `mcl_core:stone` |

#### 🚫 APIs Problemáticas Removidas
- `mcl_sounds` - No existe en VoxeLibre, comentado en código
- `default` - Reemplazado por `mcl_core`
- `farming` - Reemplazado por `mcl_farming`

### Recetas de Crafteo (VoxeLibre Compatible)

#### Cartel Educativo
```lua
core.register_craft({
    output = "education_blocks:sign",
    recipe = {
        {"group:wood", "group:wood", "group:wood"},
        {"group:wood", "mcl_books:book", "group:wood"},
        {"", "mcl_core:stick", ""}
    }
})
```

#### Bloque Nutricional
```lua
core.register_craft({
    output = "education_blocks:nutrition_block",
    recipe = {
        {"mcl_core:stone", "mcl_core:apple", "mcl_core:stone"},
        {"mcl_farming:wheat_item", "mcl_books:book", "mcl_farming:wheat_item"},
        {"mcl_core:stone", "mcl_core:apple", "mcl_core:stone"}
    }
})
```

#### Bloque de Datos de Animales
```lua
core.register_craft({
    output = "education_blocks:animal_facts",
    recipe = {
        {"mcl_core:stone", "mcl_core:stone", "mcl_core:stone"},
        {"mcl_core:stone", "mcl_books:book", "mcl_core:stone"},
        {"mcl_core:stone", "mcl_core:stone", "mcl_core:stone"}
    }
})
```

## 🎮 Mecánicas de Juego

### Interacción con Bloques
- **Método**: Clic derecho en cualquier bloque educativo
- **Resultado**: Mensaje educativo aleatorio en chat del jugador
- **Frecuencia**: Sin límite, cada clic muestra un dato diferente
- **Accesibilidad**: Disponible para todos los jugadores

### Integración con Filosofía del Servidor
- Los bloques refuerzan el mensaje de compasión y sostenibilidad
- Educación pasiva a través del gameplay
- Fomenta la curiosidad y el aprendizaje voluntario

## 🧪 Testing y Verificación

### Verificar Comando
```bash
# En el juego
/filosofia    # Debe mostrar mensaje de filosofía
```

### Verificar Bloques
1. **Crear los bloques** usando las recetas de crafteo
2. **Colocar bloques** en el mundo
3. **Hacer clic derecho** en cada bloque
4. **Verificar** que aparecen mensajes educativos aleatorios

### Verificar Recetas
```bash
# En modo creativo, buscar en inventario:
# - education_blocks:sign
# - education_blocks:nutrition_block
# - education_blocks:animal_facts
```

## 🔧 Historial de Problemas y Soluciones

### Problema: Dependencias Incorrectas (Sep 2025)
**Síntomas**:
```
ERROR[Main]: education_blocks is missing: farming default
```

**Causa**: mod.conf contenía dependencias de Minetest vanilla inexistentes en VoxeLibre

**✅ Solución**:
```ini
# Antes (problemático)
depends = mcl_sounds, default, farming

# Después (funcionando)
depends =
optional_depends = mcl_core, mcl_farming
```

### Problema: Recetas Incompatibles
**Síntomas**: Recetas no aparecían en el crafteo

**Causa**: Items de Minetest vanilla en recetas

**✅ Solución**: Reemplazar todos los items por equivalentes VoxeLibre

### Problema: Mod en Conflicto con .disabled
**Síntomas**: `Mod name conflict detected: "education_blocks"`

**Causa**: Existían ambos `education_blocks/` y `education_blocks.disabled/`

**✅ Solución**: Eliminar directorio `.disabled`

## 📊 Contenido Educativo

### Temas Cubiertos
- **Nutrición Basada en Plantas**: Información sobre vitaminas, proteínas, hierro
- **Bienestar Animal**: Datos sobre inteligencia y emociones animales
- **Sostenibilidad**: Impacto ambiental de las decisiones alimentarias
- **Compasión**: Respeto hacia todos los seres vivos

### Enfoque Pedagógico
- **Aprendizaje Lúdico**: Educación integrada en el gameplay
- **Descubrimiento**: Los jugadores encuentran información por curiosidad
- **Repetición Positiva**: Mensajes refuerzan conceptos compasivos
- **Edad Apropiada**: Contenido adecuado para niños 7+ años

## 🔮 Futuras Mejoras

- [ ] Más bloques educativos especializados
- [ ] Sistema de recompensas por aprendizaje
- [ ] Bloques con animaciones y efectos visuales
- [ ] Integración con quests educativos
- [ ] Contenido estacional sobre biodiversidad
- [ ] Bloques multiidioma

## 🚨 Troubleshooting

### Problema: Comando /filosofia no funciona
**Solución**:
1. Verificar que `load_mod_education_blocks = true` en `luanti.conf`
2. Verificar que no hay archivos `.disabled`
3. Reiniciar servidor

### Problema: Bloques no aparecen en crafteo
**Solución**:
1. Verificar recetas usando items VoxeLibre
2. Comprobar que el mod está cargado
3. Verificar modo creativo activado

### Problema: Mensajes no aparecen al hacer clic
**Solución**:
1. Verificar función `on_rightclick` en `init.lua`
2. Comprobar que no hay errores de Lua en logs
3. Verificar arrays de mensajes están correctos

---
**Última actualización**: 2025-09-21
**Estado**: Funcionando correctamente con VoxeLibre
**Próxima revisión**: Al agregar nuevos bloques educativos