# 🧹 Broom Racing - Carreras de Escobas Mágicas

Mod de carreras de escobas voladoras para eventos de Halloween en Wetlands.

## 🎯 Características

### 3 Tipos de Escobas
1. **Escoba Básica** 🧹
   - Velocidad: Baja
   - Crafteo: Palos + Trigo
   - Perfecta para principiantes

2. **Escoba Rápida** 🧹✨
   - Velocidad: Media
   - Crafteo: Escoba Básica + Plumas + Oro
   - Mayor control y velocidad

3. **Escoba Mágica Suprema** 🧹⭐
   - Velocidad: Máxima
   - Crafteo: Escoba Rápida + Diamantes + Ender Pearl
   - ¡Velocidad extrema!

### Sistema de Carreras
- **Checkpoints personalizables**: Crea circuitos únicos
- **Cronometraje automático**: Tiempos precisos
- **Tabla de récords**: Top 10 mejores tiempos por carrera
- **Efectos visuales**: Partículas mágicas y efectos de checkpoint

## 🎮 Cómo Usar

### Montar una Escoba
1. Craftea o recibe una escoba
2. Equípala en tu mano
3. **Click derecho** para montar/desmontar
4. Controles:
   - **Arriba (W)**: Acelerar
   - **Salto (Espacio)**: Subir altura
   - **Agacharse (Shift)**: Bajar altura
   - **Ratón**: Dirección del vuelo

### Crear un Circuito de Carreras

1. **Craftea Checkpoints**:
   ```
   Receta: Palos + Lingotes de Oro + Bloque de Oro
   Resultado: 2 Checkpoints
   ```

2. **Coloca los Checkpoints**:
   - Coloca el primer checkpoint en la línea de salida
   - Coloca checkpoints adicionales a lo largo del circuito
   - El último checkpoint será la meta

3. **Configura cada Checkpoint**:
   - Click derecho en el checkpoint
   - Asigna número de checkpoint (1, 2, 3, etc.)
   - Dale un nombre a la carrera (ej: "Carrera del Bosque")
   - Guarda la configuración

4. **¡Listo para Competir!**:
   - Pasa por el checkpoint #1 para iniciar el cronómetro
   - Completa todos los checkpoints en orden
   - ¡El último checkpoint registra tu tiempo!

## 📋 Comandos

### Para Jugadores
- `/mejores_tiempos [carrera]`: Ver récords de una carrera
  - Sin parámetro: Lista carreras disponibles
  - Con nombre: Muestra top 10 de esa carrera

- `/reset_carrera`: Reinicia tu carrera actual

### Para Admins
- `/dar_escoba <jugador> <tipo>`: Da una escoba a un jugador
  - Tipos: `basic`, `fast`, `magic`
  - Ejemplo: `/dar_escoba Pedro magic`

- `/evento_carreras`: Anuncia evento de carreras al servidor

## 🎨 Texturas

El mod incluye texturas placeholder. Para mejorar la experiencia visual:

1. Reemplaza los archivos en `textures/` con imágenes PNG de 16x16:
   - `broom_basic.png`: Escoba marrón simple
   - `broom_fast.png`: Escoba dorada/naranja
   - `broom_magic.png`: Escoba púrpura con brillos
   - `broom_particle_trail.png`: Partícula de estela (8x8)
   - `checkpoint_top.png`: Parte superior del checkpoint
   - `checkpoint_bottom.png`: Parte inferior del checkpoint
   - `checkpoint_side.png`: Laterales del checkpoint (efecto portal)
   - `checkpoint_particle.png`: Partícula de checkpoint (8x8)

## 🏁 Ejemplo de Circuito

### Carrera Básica (3 checkpoints)
1. **Checkpoint #1** - Salida (coords: 0, 20, 0)
2. **Checkpoint #2** - Punto Medio (coords: 50, 30, 50)
3. **Checkpoint #3** - Meta (coords: 100, 20, 0)

### Consejos para Diseñar Circuitos
- Espacia checkpoints a 30-50 bloques de distancia
- Varía las alturas para mayor desafío
- Usa obstáculos naturales (árboles, montañas)
- Crea atajos arriesgados para pilotos experimentados
- Coloca checkpoints en lugares visualmente atractivos

## 🔧 Información Técnica

### Dependencias
- VoxeLibre (MineClone2) compatible
- Opcional: mcl_core, mcl_mobitems, mcl_dye

### Física del Vuelo
- Gravedad reducida al montar (0.3-0.1 según escoba)
- Velocidad máxima: 15 unidades/s
- Aceleración gradual con inercia
- Drag (fricción de aire): 0.95

### Sistema de Detección
- Radio de detección de checkpoint: 2 bloques
- Validación de orden de checkpoints
- Prevención de checkpoint duplicado
- Persistencia de mejores tiempos en memoria

## 🎃 Integración con Halloween

Este mod funciona perfectamente con:
- `halloween_ghost`: Fantasmas pueden aparecer durante carreras
- Decoraciones de Halloween en el circuito
- Eventos especiales de octubre

## 📝 Notas

- Las escobas no consumen durabilidad
- No hay daño de caída mientras estás montado
- Los tiempos se resetean al reiniciar el servidor (futuro: guardar en archivo)
- Compatible con modo creativo

## 🐛 Troubleshooting

**Problema**: No puedo acelerar
- **Solución**: Presiona y mantén la tecla W (Arriba)

**Problema**: La escoba no vuela
- **Solución**: Asegúrate de hacer click derecho para montar primero

**Problema**: No detecta checkpoints
- **Solución**: Verifica que el nombre de carrera sea exacto en todos los checkpoints

**Problema**: Física extraña al desmontar
- **Solución**: Usa `/reset_carrera` o desconecta y reconecta

## 💡 Futuras Mejoras (Roadmap)

- [ ] Persistencia de tiempos en archivo JSON
- [ ] Modos de carrera (individual, versus, equipos)
- [ ] Power-ups en el circuito (boost, escudo, etc.)
- [ ] Ranking global del servidor
- [ ] Achievements por récords
- [ ] Integración con economía del servidor
- [ ] Replays de las mejores carreras
- [ ] Circuitos pre-diseñados incluidos

## 🤝 Créditos

- **Desarrollado por**: Wetlands Team
- **Para**: Servidor Wetlands - Educativo y Compasivo
- **Versión**: 1.0.0
- **Fecha**: Octubre 2025

---

¡Disfruta de las carreras de escobas mágicas! 🧹✨🏁
