# 📚 Education Blocks - Bloques Educativos Interactivos

**Versión**: 1.0  
**Autor**: Wetlands Team  
**Compatibilidad**: VoxeLibre v0.90.1

## 📖 Descripción

Sistema de bloques educativos interactivos que enseñan sobre compasión animal, sostenibilidad y alimentación consciente. Los jugadores pueden interactuar con estos bloques para aprender valores éticos mientras juegan.

## 🎯 Propósito

Este mod es fundamental para:
- **Educar jugadores** sobre compasión y sostenibilidad
- **Enseñar valores éticos** de forma natural e interactiva
- **Promover alimentación consciente** y respeto por los animales
- **Crear puntos educativos** en el mundo del juego

## 🚀 Características

### Bloques Disponibles

#### 1. Cartel Educativo (`education_blocks:sign`)

**Descripción**: Cartel que muestra información educativa aleatoria al hacer clic derecho.

**Hechos educativos**:
- 🌱 Los animales son seres sintientes que merecen nuestro respeto
- 💚 Una alimentación consciente y basada en plantas es saludable y sostenible
- 🌍 Cuidar el planeta es responsabilidad de todos
- 🐮 En este mundo, los animales viven libres y en paz
- 🌾 Las plantas nos dan todo lo que necesitamos para estar sanos

**Uso**: Colocar el cartel y hacer clic derecho para ver un hecho aleatorio.

#### 2. Bloque Nutricional (`education_blocks:nutrition_block`)

**Descripción**: Bloque que muestra datos sobre nutrición y alimentación saludable.

**Datos nutricionales**:
- 🥬 Las verduras de hoja verde son una gran fuente de hierro
- 🥜 Los frutos secos son ricos en proteínas y grasas saludables
- 🌾 Los cereales integrales nos dan energía duradera
- 🥕 Las frutas y verduras son ricas en vitaminas y antioxidantes
- 💧 Mantenerse hidratado es esencial para la salud

**Uso**: Colocar el bloque y hacer clic derecho para ver información nutricional.

### Comandos

| Comando | Descripción | Uso |
|---------|-------------|-----|
| `/filosofia` | Muestra la filosofía del juego | `/filosofia` |

**Nota**: El comando `/filosofia` también está disponible en `server_rules`. Este mod mantiene una versión independiente para compatibilidad.

## 🔧 Configuración

### Dependencias

```lua
depends =
```

No tiene dependencias obligatorias, pero funciona mejor con:
- `mcl_core` (para bloques base)
- `mcl_sounds` (para sonidos, actualmente deshabilitado por problemas de compatibilidad)

### Habilitar el Mod

Agregar en `server/config/luanti.conf`:
```ini
load_mod_education_blocks = true
```

O en `server/worlds/world/world.mt`:
```ini
load_mod_education_blocks = true
```

## 🎨 Texturas

El mod requiere texturas personalizadas:
- `education_sign.png` - Textura para el cartel educativo
- `education_nutrition_top.png` - Parte superior del bloque nutricional
- `education_nutrition_bottom.png` - Parte inferior del bloque nutricional
- `education_nutrition_side.png` - Lados del bloque nutricional

**Ubicación**: `server/mods/education_blocks/textures/`

## 🔗 Integración con Otros Mods

Este mod complementa:
- **`server_rules`**: Proporciona contexto educativo adicional
- **`vegan_food`**: Enseña sobre alimentación basada en plantas
- **`voxelibre_protection`**: Puede usarse en áreas educativas protegidas

## 📝 Uso en el Juego

### Para Jugadores

1. **Obtener bloques educativos**:
   - Buscar en el inventario creativo: `education_blocks:sign` o `education_blocks:nutrition_block`
   - O usar `/give nombre_jugador education_blocks:sign`

2. **Colocar bloques**:
   - Colocar el bloque en cualquier ubicación
   - Idealmente en áreas educativas o santuarios

3. **Interactuar**:
   - Hacer clic derecho en el bloque
   - Leer el mensaje educativo que aparece en el chat

### Para Administradores

1. **Crear áreas educativas**:
   - Usar `voxelibre_protection` para proteger áreas educativas
   - Colocar múltiples bloques educativos en un área

2. **Personalizar mensajes**:
   - Editar `init.lua` para agregar nuevos hechos educativos
   - Mantener el tono apropiado para niños 7+

## 🔄 Expansiones Futuras

Posibles mejoras:
- [ ] Más tipos de bloques educativos
- [ ] Sistema de partículas al interactuar
- [ ] Sonidos educativos (cuando se resuelva compatibilidad)
- [ ] Bloques temáticos (compasión, sostenibilidad, programación)
- [ ] Sistema de logros educativos

## 🐛 Troubleshooting

### Los bloques no aparecen en el inventario

1. Verificar que el mod está habilitado:
   ```bash
   docker-compose exec -T luanti-server cat /config/.minetest/worlds/world/world.mt | grep education_blocks
   ```

2. Verificar que estás en modo creativo:
   - El mod `creative_force` debería otorgar privilegios creativos automáticamente

3. Buscar manualmente:
   - Usar `/give nombre_jugador education_blocks:sign`

### Las texturas no se ven

1. Verificar que las texturas existen:
   ```bash
   ls -la server/mods/education_blocks/textures/
   ```

2. Verificar nombres de archivos (case-sensitive):
   - Los nombres deben coincidir exactamente con el código

### Los mensajes no aparecen al hacer clic

1. Verificar logs:
   ```bash
   docker-compose logs luanti-server | grep education_blocks
   ```

2. Verificar que el bloque está correctamente colocado:
   - Debe estar en el mundo, no en el inventario

## 📚 Documentación Adicional

- Ver documentación general en `docs/mods/README.md`
- Ver guía de desarrollo en `docs/mods/MODDING_GUIDE.md`

---

**Última actualización**: Diciembre 7, 2025  
**Mantenedor**: Equipo Wetlands  
**Licencia**: GPL-3.0

