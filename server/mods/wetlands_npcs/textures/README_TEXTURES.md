# 🎨 Guía de Texturas para Custom Villagers

## 📋 Archivos de Textura Requeridos

### Formato
- **Resolución**: 16x16 o 32x32 píxeles (16x16 recomendado para rendimiento)
- **Formato**: PNG con transparencia (alpha channel)
- **Naming**: Case-sensitive, seguir convención exacta

### Estructura de Nombres

```
custom_villagers_<tipo>_<cara>.png
```

Donde:
- `<tipo>` = farmer, librarian, teacher, explorer
- `<cara>` = top, bottom, side, front, back

---

## 🖼️ Lista Completa de Texturas Necesarias

### Agricultor (Farmer) - Color sugerido: Verde #4CAF50
```
custom_villagers_farmer_top.png       # Sombrero de paja / cabeza
custom_villagers_farmer_bottom.png    # Pies / botas
custom_villagers_farmer_side.png      # Brazos / lados
custom_villagers_farmer_front.png     # Cara / overol
custom_villagers_farmer_back.png      # Espalda
```

### Bibliotecario (Librarian) - Color sugerido: Azul #2196F3
```
custom_villagers_librarian_top.png
custom_villagers_librarian_bottom.png
custom_villagers_librarian_side.png
custom_villagers_librarian_front.png
custom_villagers_librarian_back.png
```

### Maestro (Teacher) - Color sugerido: Morado #9C27B0
```
custom_villagers_teacher_top.png
custom_villagers_teacher_bottom.png
custom_villagers_teacher_side.png
custom_villagers_teacher_front.png
custom_villagers_teacher_back.png
```

### Explorador (Explorer) - Color sugerido: Marrón #795548
```
custom_villagers_explorer_top.png
custom_villagers_explorer_bottom.png
custom_villagers_explorer_side.png
custom_villagers_explorer_front.png
custom_villagers_explorer_back.png
```

---

## 🚀 Opción Rápida: Crear Placeholders con ImageMagick

Si tienes ImageMagick instalado, puedes generar placeholders de colores sólidos:

```bash
# Navegar al directorio de texturas
cd /home/gabriel/Documentos/luanti-voxelibre-server/server/mods/custom_villagers/textures/

# Agricultor (Verde)
convert -size 16x16 xc:#4CAF50 custom_villagers_farmer_top.png
convert -size 16x16 xc:#4CAF50 custom_villagers_farmer_bottom.png
convert -size 16x16 xc:#4CAF50 custom_villagers_farmer_side.png
convert -size 16x16 xc:#4CAF50 custom_villagers_farmer_front.png
convert -size 16x16 xc:#4CAF50 custom_villagers_farmer_back.png

# Bibliotecario (Azul)
convert -size 16x16 xc:#2196F3 custom_villagers_librarian_top.png
convert -size 16x16 xc:#2196F3 custom_villagers_librarian_bottom.png
convert -size 16x16 xc:#2196F3 custom_villagers_librarian_side.png
convert -size 16x16 xc:#2196F3 custom_villagers_librarian_front.png
convert -size 16x16 xc:#2196F3 custom_villagers_librarian_back.png

# Maestro (Morado)
convert -size 16x16 xc:#9C27B0 custom_villagers_teacher_top.png
convert -size 16x16 xc:#9C27B0 custom_villagers_teacher_bottom.png
convert -size 16x16 xc:#9C27B0 custom_villagers_teacher_side.png
convert -size 16x16 xc:#9C27B0 custom_villagers_teacher_front.png
convert -size 16x16 xc:#9C27B0 custom_villagers_teacher_back.png

# Explorador (Marrón)
convert -size 16x16 xc:#795548 custom_villagers_explorer_top.png
convert -size 16x16 xc:#795548 custom_villagers_explorer_bottom.png
convert -size 16x16 xc:#795548 custom_villagers_explorer_side.png
convert -size 16x16 xc:#795548 custom_villagers_explorer_front.png
convert -size 16x16 xc:#795548 custom_villagers_explorer_back.png

# Verificar
ls -lh
```

---

## 🎨 Opción Avanzada: Texturas Personalizadas con GIMP/Krita

### Recomendaciones de Diseño

#### Cara Frontal (front.png)
- Diseña una cara simple y amigable
- Ojos grandes para aspecto child-friendly
- Expresión neutral o sonriente
- Puede incluir detalles de profesión (ej: gafas para bibliotecario)

#### Cara Superior (top.png)
- Sombrero o cabello distintivo
- Agricultor: sombrero de paja
- Bibliotecario: cabello formal
- Maestro: gorra o cabello ordenado
- Explorador: sombrero de aventurero

#### Lados (side.png)
- Brazos o ropa lateral
- Mantener colores consistentes con el tema

#### Cara Trasera (back.png)
- Espalda de la ropa
- Puede ser simétrica con el frente

#### Cara Inferior (bottom.png)
- Pies o base
- Normalmente más oscuro que el resto

---

## 📦 Recursos de Texturas Gratuitas

### Sitios con Texturas Pixel Art
- **OpenGameArt.org**: Texturas CC0/CC-BY
- **itch.io**: Packs de pixel art gratuitos
- **Kenney.nl**: Assets de juegos gratuitos

### Herramientas de Edición
- **GIMP**: Editor gratuito (gimp.org)
- **Krita**: Especializado en arte digital (krita.org)
- **Aseprite**: Pixel art (aseprite.org - pago)
- **Piskel**: Editor online gratuito (piskelapp.com)

---

## ✅ Checklist de Validación

Antes de usar las texturas, verifica:

- [ ] Todas las 20 texturas están presentes (4 tipos × 5 caras)
- [ ] Resolución correcta (16x16 o 32x32)
- [ ] Formato PNG
- [ ] Nombres exactos (case-sensitive)
- [ ] Colores distintivos entre tipos de aldeanos
- [ ] Estilo consistente y child-friendly

---

## 🔧 Testing de Texturas

1. **Crear placeholders temporales**
2. **Spawnear aldeano en el juego**: `/spawn_villager farmer`
3. **Verificar visualización**: Si aparecen correctamente, las texturas funcionan
4. **Iterar**: Reemplazar con texturas mejoradas gradualmente

---

## 🎓 Tutorial Paso a Paso: Primera Textura

### Ejemplo: Crear textura frontal del agricultor con GIMP

1. Abrir GIMP
2. Crear nueva imagen: 16x16 píxeles
3. Rellenar fondo con verde (#4CAF50)
4. Con herramienta lápiz (1px), dibujar:
   - 2 píxeles negros para ojos (posición 6,5 y 10,5)
   - 3 píxeles negros para boca sonriente (posición 6-7-8, altura 9)
5. Exportar como PNG: `custom_villagers_farmer_front.png`
6. Colocar en directorio `textures/`

---

**¡Con estas texturas, tus aldeanos cobrarán vida!** 🎨✨
