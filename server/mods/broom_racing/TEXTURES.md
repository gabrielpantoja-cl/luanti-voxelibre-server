# 🎨 Texturas del Mod Broom Racing

## Resumen

Todas las texturas han sido generadas usando Python + PIL (Pillow) con pixel art de 16x16 y 8x8 píxeles.

**Total**: 8 archivos PNG (1,193 bytes)
**Formato**: PNG RGBA con transparencia
**Generador**: `scripts/generate_broom_textures.py`

---

## 🧹 Texturas de Escobas (Items)

### 1. `broom_basic.png` - Escoba Básica
- **Tamaño**: 16x16 píxeles (135 bytes)
- **Colores**: Marrón (#654321) y Paja (#F5DEB3)
- **Diseño**:
  - Mango vertical marrón (columnas 7-8, filas 2-13)
  - Paja en la base (filas 10-15) con patrón cuadriculado
  - Detalles oscuros en el tope del mango
- **Estilo**: Simple y rústico, perfecto para principiantes

### 2. `broom_fast.png` - Escoba Rápida
- **Tamaño**: 16x16 píxeles (182 bytes)
- **Colores**: Dorado (#FFD700) y Naranja (#FF8C00)
- **Diseño**:
  - Mango dorado brillante con gradiente
  - Paja dorada/naranja en patrón alternado
  - Efectos de velocidad (líneas a los lados)
  - Detalles brillantes adicionales
- **Estilo**: Dinámico y elegante, velocidad media

### 3. `broom_magic.png` - Escoba Mágica Suprema
- **Tamaño**: 16x16 píxeles (166 bytes)
- **Colores**: Púrpura (#8A2BE2), Magenta (#FF00FF), Cian (#00FFFF)
- **Diseño**:
  - Mango con patrón alternado púrpura/magenta
  - Paja mágica con 3 colores místicos rotando
  - Estrellas blancas alrededor (píxeles brillantes)
  - Partículas mágicas en los bordes
- **Estilo**: Místico y poderoso, velocidad máxima

---

## 🏁 Texturas de Checkpoints (Bloques)

### 4. `checkpoint_top.png` - Parte Superior
- **Tamaño**: 16x16 píxeles (154 bytes)
- **Colores**: Dorado (#FFD700), Amarillo Claro (#FFFF80)
- **Diseño**:
  - Patrón circular concéntrico dorado
  - Cuadrícula alternada oro/amarillo claro
  - Estrella blanca en el centro (cruz de 5 píxeles)
  - Borde oscuro en el perímetro exterior
- **Uso**: Cara superior del bloque checkpoint

### 5. `checkpoint_bottom.png` - Parte Inferior
- **Tamaño**: 16x16 píxeles (113 bytes)
- **Colores**: Oro Oscuro (#B8860B), Marrón (#654321)
- **Diseño**:
  - Patrón cuadriculado simple (2x2 píxeles)
  - Alternancia oro oscuro/marrón
  - Efecto de base sólida y estable
- **Uso**: Cara inferior del bloque checkpoint

### 6. `checkpoint_side.png` - Laterales
- **Tamaño**: 16x16 píxeles (210 bytes)
- **Colores**: Dorado (#FFD700), Amarillo (#FFFF00), Amarillo Claro (#FFFF80)
- **Diseño**:
  - Efecto de portal mágico con ondas concéntricas
  - 3 colores rotando según distancia del centro
  - Bordes blancos brillantes (1 píxel de grosor)
  - Apariencia de energía fluyendo
- **Uso**: Caras laterales del bloque checkpoint (4 lados)

---

## ✨ Texturas de Partículas (Efectos)

### 7. `broom_particle_trail.png` - Estela de Escoba
- **Tamaño**: 8x8 píxeles (107 bytes)
- **Colores**: Blanco (#FFFFFF), Amarillo Claro (#FFFF80)
- **Diseño**:
  - Estrella de 8 puntas (cruz + X)
  - Cruz principal en blanco brillante
  - Diagonales en amarillo claro
  - Centro blanco intenso
- **Uso**: Partículas que salen detrás de la escoba mientras vuela
- **Frecuencia**: Cada 0.1 segundos durante el vuelo

### 8. `checkpoint_particle.png` - Efecto Checkpoint
- **Tamaño**: 8x8 píxeles (126 bytes)
- **Colores**: Dorado (#FFD700), Amarillo (#FFFF00), Blanco (#FFFFFF)
- **Diseño**:
  - Estrella dorada grande
  - Cruz dorada principal (vertical + horizontal)
  - Diagonales amarillas (X)
  - Centro blanco brillante (2x2 píxeles)
- **Uso**: Explosión de partículas al pasar por un checkpoint
- **Cantidad**: 50 partículas por checkpoint alcanzado

---

## 🔧 Regenerar Texturas

Si necesitas modificar las texturas, edita el script y ejecuta:

```bash
python3 scripts/generate_broom_textures.py
```

El script incluye:
- Definiciones de colores RGB personalizables
- Funciones independientes por cada textura
- Comentarios detallados del diseño
- Salida con confirmación visual

---

## 🎨 Paleta de Colores

### Escobas
```
Básica:
  - BROWN:       #654321  (Mango)
  - DARK_BROWN:  #4C3219  (Detalles)
  - LIGHT_BROWN: #8B5A2B  (Brillo)
  - WHEAT:       #F5DEB3  (Paja)

Rápida:
  - GOLD:        #FFD700  (Principal)
  - DARK_GOLD:   #B8860B  (Sombra)
  - ORANGE:      #FF8C00  (Efectos)

Mágica:
  - PURPLE:      #8A2BE2  (Principal)
  - MAGENTA:     #FF00FF  (Brillo)
  - CYAN:        #00FFFF  (Místico)
  - WHITE:       #FFFFFF  (Estrellas)
```

### Checkpoints
```
  - GOLD:         #FFD700  (Principal)
  - YELLOW:       #FFFF00  (Medio)
  - LIGHT_YELLOW: #FFFF80  (Claro)
  - DARK_GOLD:    #B8860B  (Oscuro)
  - WHITE:        #FFFFFF  (Detalles)
```

---

## 📊 Especificaciones Técnicas

| Textura | Resolución | Bytes | Tipo | Transparencia |
|---------|-----------|-------|------|---------------|
| broom_basic | 16x16 | 135 | Item | Sí (fondo) |
| broom_fast | 16x16 | 182 | Item | Sí (fondo) |
| broom_magic | 16x16 | 166 | Item | Sí (fondo) |
| checkpoint_top | 16x16 | 154 | Block | No |
| checkpoint_bottom | 16x16 | 113 | Block | No |
| checkpoint_side | 16x16 | 210 | Block | No |
| broom_particle_trail | 8x8 | 107 | Particle | Sí (fondo) |
| checkpoint_particle | 8x8 | 126 | Particle | Sí (fondo) |

**Total**: 1,193 bytes (~1.2 KB)

---

## 🎯 Mejoras Futuras (Opcional)

Si quieres mejorar las texturas, considera:

### Visual
- [ ] Animación de escobas (frames múltiples)
- [ ] Variantes de color para checkpoints
- [ ] Partículas con gradientes suaves
- [ ] Sombras y profundidad mejorada

### Técnico
- [ ] Texturas HD (32x32 opcional)
- [ ] Normal maps para efectos 3D
- [ ] Texturas animadas (sprite sheets)
- [ ] Compatibilidad con texture packs

### Artístico
- [ ] Diseños temáticos (Halloween, Navidad, etc.)
- [ ] Escobas personalizables por jugador
- [ ] Efectos de velocidad más detallados
- [ ] Partículas con múltiples variantes

---

## 📝 Notas

- Todas las texturas usan transparencia RGBA
- El fondo transparente permite integración perfecta en el juego
- Los colores son vibrantes para visibilidad en día y noche
- Las partículas son pequeñas (8x8) para mejor rendimiento
- Compatible con VoxeLibre (MineClone2) y Minetest Game

---

## 🤝 Créditos

- **Generadas con**: Python 3 + PIL (Pillow)
- **Diseño**: Wetlands Team
- **Licencia**: Misma que el mod (libre para modificar)
- **Fecha**: Octubre 2025

---

**¿Quieres modificar las texturas?**
Edita `scripts/generate_broom_textures.py` y ejecuta el script de nuevo. ¡Es fácil y rápido! 🎨✨
