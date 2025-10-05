# VoxeLibre TV Mod

Mod de televisor para VoxeLibre que añade un televisor animado con 3 canales.

## 📺 Características

- **Televisor interactivo**: Haz click para encender/apagar y cambiar canales
- **3 canales animados**: Cada canal muestra contenido diferente con animaciones
- **Iluminación**: El TV emite luz cuando está encendido
- **Crafteable**: Se puede crear con 4 lingotes de hierro

## 🎮 Uso

1. **Crafteo**: Usa 4 lingotes de hierro (`mcl_core:iron_ingot`) en forma de cuadrado 2x2
2. **Colocación**: Coloca el TV donde quieras (se orienta según tu dirección)
3. **Interacción**:
   - Click para encender (muestra Canal 1)
   - Click para cambiar a Canal 2
   - Click para cambiar a Canal 3
   - Click para apagar

## 🔧 Instalación

1. Copia la carpeta `voxelibre_tv` a tu directorio de mods
2. Habilita el mod en tu configuración de servidor/mundo
3. **NO es necesario reiniciar** si tienes recarga en caliente activada

## 🎨 Texturas

El mod incluye texturas placeholder básicas:
- **Carcasa**: Gris oscuro
- **Pantalla apagada**: Negro
- **Canal 1**: Azul (placeholder)
- **Canal 2**: Verde (placeholder)
- **Canal 3**: Rojo (placeholder)

### Personalizar Texturas

Para crear texturas personalizadas, edita los archivos PNG en `textures/`:

- `voxelibre_tv_top.png` - Parte superior/inferior (16x16px)
- `voxelibre_tv_left.png` - Lado izquierdo (16x16px)
- `voxelibre_tv_right.png` - Lado derecho (16x16px)
- `voxelibre_tv_back.png` - Parte trasera (16x16px)
- `voxelibre_tv_off.png` - Pantalla apagada (16x16px)
- `voxelibre_tv_channel_1.png` - Canal 1 animado (16x32px, 2 frames)
- `voxelibre_tv_channel_2.png` - Canal 2 animado (16x32px, 2 frames)
- `voxelibre_tv_channel_3.png` - Canal 3 animado (16x32px, 2 frames)

**Nota**: Las texturas de canales son animadas. Cada frame (16x16) se muestra 1 segundo.

## 🧪 Detalles Técnicos

- **Dependencias**: Ninguna (funciona standalone en VoxeLibre)
- **Dependencias opcionales**: `mcl_core`, `mcl_crafting_table`
- **Grupos**: `choppy=2`, `oddly_breakable_by_hand=2`, `handy=1`
- **Luz**: Level 8 cuando está encendido
- **Resistencia a explosiones**: 3
- **Dureza**: 2

## 📜 Créditos

- **Autor original**: tony-ka ([GitHub](https://github.com/tony-ka/Minetest---TV-Mod))
- **Adaptación VoxeLibre**: gabriel
- **Licencia**: GPL v3 (heredada del mod original)

## 🔄 Cambios desde el original

- Eliminada dependencia de mod `default` (Minetest vanilla)
- Cambiado crafteo de `default:steel_ingot` a `mcl_core:iron_ingot`
- Añadidas propiedades VoxeLibre (`_mcl_blast_resistance`, `_mcl_hardness`)
- Textura placeholder incluidas para uso inmediato
- Nombres de nodos cambiados de `tv:*` a `voxelibre_tv:*`

## 🐛 Problemas conocidos

- Las texturas actuales son placeholders básicos y deben ser reemplazadas con contenido educativo apropiado
- El mod no incluye sonido (puede añadirse en futuras versiones)

## 🎯 Uso en Wetlands

Este mod está diseñado para el servidor Wetlands, donde los canales pueden mostrar:
- **Canal 1**: Contenido educativo sobre animales y santuarios
- **Canal 2**: Información sobre alimentación vegana compasiva
- **Canal 3**: Mensajes sobre respeto y cuidado del planeta

Para personalizar el contenido, reemplaza las texturas de canales con imágenes educativas apropiadas para niños 7+.