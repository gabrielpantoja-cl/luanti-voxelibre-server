# Wetlands Music Mod - Documentación Completa

## 📖 Descripción General

**wetlands-music** es un mod personalizado para VoxeLibre que introduce discos de música únicos en el servidor Wetlands. El mod se integra perfectamente con el sistema de jukebox nativo de VoxeLibre (`mcl_jukebox`), permitiendo a los jugadores disfrutar de música temática mientras construyen y exploran.

**Filosofía**: La selección musical sigue los valores del servidor Wetlands, promoviendo un ambiente compasivo, educativo y relajante apropiado para niños de 7+ años.

---

## ✨ Características Principales

- ✅ **9 discos de música personalizados** con temáticas variadas
- ✅ **Integración nativa con VoxeLibre** usando la API `mcl_jukebox`
- ✅ **Texturas optimizadas** (16x16 píxeles para rendimiento)
- ✅ **Audio en formato OGG** (compresión eficiente, alta calidad)
- ✅ **Fácil de extender** con nuevas canciones
- ✅ **Sin conflictos** con otros mods de VoxeLibre

---

## 🎵 Discos Disponibles

| # | Nombre del Disco | Artista | Identificador | Textura | Archivo de Sonido |
|---|------------------|---------|---------------|---------|-------------------|
| 1 | Dinosaur Spirit | Wetlands Music Collection | `wetlands_dinosaur_spirit` | ✅ 16x16 | ✅ 2.8MB |
| 2 | Gagaga Song | Wetlands Music Collection | `wetlands_gagaga_song` | ✅ 16x16 | ✅ 1.4MB |
| 3 | Groovy Goblins | Wetlands Music Collection | `wetlands_groovy_goblins` | ✅ 16x16 | ✅ 3.4MB |
| 4 | Princess | Wetlands Music Collection | `wetlands_princess` | ✅ 16x16 | ✅ 5.5MB |
| 5 | Battleship | Patrick de Arteaga | `wetlands_pvp_battle_2` | ✅ 16x16 | ✅ 1.3MB |
| 6 | Chase At Rush Hour | Patrick de Arteaga | `wetlands_pvp_battle_4` | ✅ 16x16 | ✅ 1.7MB |
| 7 | Rock City Ransom | Wetlands Music Collection | `wetlands_rock_city_ransom` | ✅ 16x16 | ✅ 2.9MB |
| 8 | Warp Zone | Wetlands Music Collection | `wetlands_warp_zone` | ✅ 16x16 | ✅ 3.3MB |
| 9 | Youthful Elf | Wetlands Music Collection | `wetlands_youthful_elf` | ✅ 16x16 | ✅ 1.6MB |

**Total de almacenamiento de audio**: ~24MB

---

## 🔧 Estructura del Mod

```
server/mods/wetlands-music/
├── mod.conf                    # Metadatos y dependencias del mod
├── init.lua                    # Código principal de registro de discos
├── sounds/                     # Archivos de audio .ogg
│   ├── wetlands_music_dinosaur_spirit.ogg
│   ├── wetlands_music_gagaga_song.ogg
│   ├── wetlands_music_groovy_goblins.ogg
│   ├── wetlands_music_princess.ogg
│   ├── wetlands_music_pvp_battle_2.ogg
│   ├── wetlands_music_pvp_battle_4.ogg
│   ├── wetlands_music_rock_city_ransom.ogg
│   ├── wetlands_music_warp_zone.ogg
│   └── wetlands_music_youthful_elf.ogg
├── textures/                   # Texturas 16x16 .png
│   ├── wetlands_music_dinosaur_spirit.png
│   ├── wetlands_music_gagaga_song.png
│   ├── wetlands_music_groovy_goblins.png
│   ├── wetlands_music_princess.png
│   ├── wetlands_music_pvp_battle_4.png
│   ├── wetlands_music_record_pvp_battle_2.png
│   ├── wetlands_music_record_pvp_battle_3.png (legacy)
│   ├── wetlands_music_record_pvp_battle_4.png (legacy)
│   ├── wetlands_music_rock_city_ransom.png
│   ├── wetlands_music_warp_zone.png
│   └── wetlands_music_youthful_elf.png
└── docs/                       # Documentación
    └── README.md               # Este archivo
```

---

## 🎮 Uso en el Juego

### Para Jugadores:

1. **Encontrar discos**:
   - En modo creativo: Busca en el inventario `Music Disc`
   - Todos los discos de Wetlands Music aparecen con sus nombres únicos

2. **Reproducir música**:
   - Coloca un jukebox (crafteable en VoxeLibre)
   - Haz clic derecho en el jukebox con un disco en la mano
   - La música comenzará a reproducirse automáticamente
   - Haz clic derecho nuevamente para detener y recuperar el disco

3. **Comandos**:
   - Este mod no introduce comandos nuevos
   - Toda la interacción es a través de jukeboxes

---

## ⚙️ Integración Técnica con VoxeLibre

### API de mcl_jukebox

El mod utiliza la función `mcl_jukebox.register_record()` de VoxeLibre:

```lua
mcl_jukebox.register_record(
    title,        -- Nombre del disco (string)
    author,       -- Artista/compositor (string)
    identifier,   -- ID único del item (string)
    image,        -- Archivo de textura (string, .png)
    sound         -- Archivo de sonido SIN .ogg (string)
)
```

### Ejemplo de Registro:

```lua
mcl_jukebox.register_record(
    "Dinosaur Spirit",
    "Wetlands Music Collection",
    "wetlands_dinosaur_spirit",
    "wetlands_music_dinosaur_spirit.png",
    "wetlands_music_dinosaur_spirit"
)
```

### Dependencias (mod.conf):

```
name = wetlands_music
title = Wetlands Music Discs
depends = mcl_jukebox
optional_depends = mcl_core
```

**Importante**: `mcl_jukebox` es una dependencia **obligatoria**. El mod no funcionará sin él.

---

## 🎨 Especificaciones de Assets

### Texturas (PNG):
- **Dimensiones requeridas**: 16x16 píxeles
- **Formato**: PNG con transparencia (RGBA)
- **Tamaño recomendado**: <10KB por archivo
- **Convención de nombres**: `wetlands_music_[identificador].png`

### Audio (OGG Vorbis):
- **Formato**: OGG Vorbis (compresión variable)
- **Bitrate recomendado**: 128-192 kbps
- **Canales**: Mono o estéreo
- **Frecuencia de muestreo**: 44.1kHz o 48kHz
- **Duración**: 1-5 minutos (óptimo para gameplay)
- **Convención de nombres**: `wetlands_music_[identificador].ogg`

---

## 📝 Cómo Añadir un Nuevo Disco

### Paso 1: Preparar Archivos

1. **Audio**: Convierte tu archivo a `.ogg` con herramientas como Audacity o `ffmpeg`:
   ```bash
   ffmpeg -i input.mp3 -c:a libvorbis -q:a 5 wetlands_music_mi_cancion.ogg
   ```

2. **Textura**: Crea o redimensiona una imagen a 16x16 píxeles:
   ```bash
   # Con ImageMagick:
   convert input.png -resize 16x16\! wetlands_music_mi_cancion.png

   # O con Python/PIL:
   from PIL import Image
   img = Image.open("input.png")
   img.resize((16, 16), Image.LANCZOS).save("wetlands_music_mi_cancion.png")
   ```

### Paso 2: Añadir Archivos al Mod

```bash
# Copiar archivos
cp wetlands_music_mi_cancion.ogg server/mods/wetlands-music/sounds/
cp wetlands_music_mi_cancion.png server/mods/wetlands-music/textures/
```

### Paso 3: Registrar el Disco en init.lua

Edita `server/mods/wetlands-music/init.lua` y añade:

```lua
-- Disc 10: Mi Nueva Canción
mcl_jukebox.register_record(
    "Mi Nueva Canción",                    -- Título
    "Nombre del Artista",                  -- Artista
    "wetlands_mi_cancion",                 -- Identificador único
    "wetlands_music_mi_cancion.png",       -- Textura
    "wetlands_music_mi_cancion"            -- Sonido (sin .ogg)
)
```

### Paso 4: Reiniciar el Servidor

```bash
docker compose restart luanti-server
```

### Paso 5: Verificar en el Juego

1. Únete al servidor en modo creativo
2. Abre el inventario y busca "Mi Nueva Canción"
3. Coloca un jukebox y prueba el disco

---

## 🐛 Troubleshooting

### ❌ El disco no aparece en el inventario

**Causas posibles**:
- Error de sintaxis en `init.lua`
- Identificador duplicado
- Mod no activado en `world.mt`

**Soluciones**:
1. Revisa logs del servidor:
   ```bash
   docker compose logs luanti-server | grep wetlands_music
   ```

2. Verifica que el mod esté activo:
   ```bash
   grep "load_mod_wetlands_music" server/worlds/world/world.mt
   ```
   Debe mostrar: `load_mod_wetlands_music = true`

3. Verifica sintaxis Lua:
   ```bash
   luac -p server/mods/wetlands-music/init.lua
   ```

### ❌ La música no se reproduce

**Causas posibles**:
- Archivo `.ogg` faltante o corrupto
- Nombre de archivo incorrecto en `init.lua`
- Volumen del cliente en 0

**Soluciones**:
1. Verifica que el archivo existe:
   ```bash
   ls -lh server/mods/wetlands-music/sounds/wetlands_music_*.ogg
   ```

2. Verifica que el nombre en `init.lua` coincide (SIN extensión .ogg):
   ```lua
   "wetlands_music_mi_cancion"  -- ✅ Correcto
   "wetlands_music_mi_cancion.ogg"  -- ❌ Incorrecto
   ```

3. Prueba el archivo `.ogg` manualmente:
   ```bash
   ffprobe server/mods/wetlands-music/sounds/wetlands_music_mi_cancion.ogg
   ```

### ❌ La textura se ve incorrecta

**Causas posibles**:
- Dimensiones incorrectas (no es 16x16)
- Archivo PNG corrupto
- Nombre incorrecto en `init.lua`

**Soluciones**:
1. Verifica dimensiones:
   ```bash
   file server/mods/wetlands-music/textures/wetlands_music_*.png
   ```

2. Redimensiona si es necesario:
   ```python
   from PIL import Image
   img = Image.open("wetlands_music_mi_cancion.png")
   img.resize((16, 16), Image.LANCZOS).save("wetlands_music_mi_cancion.png")
   ```

### ❌ Error: "mcl_jukebox not found"

**Causa**: Dependencia faltante

**Solución**: Verifica que VoxeLibre está instalado correctamente:
```bash
ls -la server/games/mineclone2/mods/ | grep jukebox
```

---

## 🔐 Configuración del Servidor

### Activación del Mod

El mod se activa automáticamente al estar presente en `server/mods/wetlands-music/`. Para desactivarlo temporalmente:

```bash
# Renombrar el directorio
mv server/mods/wetlands-music server/mods/wetlands-music.disabled

# O editar world.mt
echo "load_mod_wetlands_music = false" >> server/worlds/world/world.mt

# Reiniciar
docker compose restart luanti-server
```

### Configuración de world.mt

Archivo: `server/worlds/world/world.mt`

```
gameid = mineclone2
load_mod_wetlands_music = true
```

---

## 📊 Rendimiento

### Impacto en el Servidor

- **CPU**: Mínimo (solo registro de items)
- **RAM**: ~25MB para archivos de audio cargados
- **Disco**: ~24MB para archivos .ogg
- **Red**: Transferencia bajo demanda (solo cuando jugadores se conectan)

### Optimizaciones Aplicadas

1. **Texturas 16x16**: Reducción de 1024x1024 a 16x16 ahorró ~1.8MB
2. **Formato OGG**: Compresión Vorbis reduce tamaño vs WAV sin pérdida de calidad perceptible
3. **Carga bajo demanda**: Audio solo se carga cuando se reproduce

---

## 📜 Licencia y Créditos

### Licencia del Mod
- **Código**: GPL v3.0 (compatible con VoxeLibre)
- **Autor**: Gabriel Pantoja
- **Repositorio**: `luanti-voxelibre-server.git`

### Licencia de Audio

**⚠️ IMPORTANTE**: Verificar que toda la música utilizada tiene licencia compatible:
- Creative Commons (CC BY, CC BY-SA)
- Dominio público
- Licencia comercial adquirida

**Créditos de artistas**:
- Patrick de Arteaga: "Battleship", "Chase At Rush Hour"
- Wetlands Music Collection: Canciones restantes

### Compatibilidad

- **VoxeLibre**: v0.90.1+ (MineClone2)
- **Luanti**: 5.13+ (anteriormente Minetest)
- **API**: `mcl_jukebox` (incluida en VoxeLibre)

---

## 🔄 Historial de Cambios

### v2.0.0 (2025-10-26)
- ✅ **CORRECCIÓN CRÍTICA**: Redimensionadas texturas a 16x16 píxeles
- ✅ Registrados 9 discos (anteriormente solo 4)
- ✅ Añadidos 5 discos nuevos con texturas generadas
- ✅ Corregidos nombres de archivos de sonido en init.lua
- ✅ Documentación completa y troubleshooting guide
- ✅ Eliminado disco "Intergalactic Odyssey" (archivo de sonido faltante)

### v1.0.0 (2025-10-19)
- 🎵 Primer release con 4 discos básicos
- 🎨 Texturas iniciales (algunas 1024x1024, con problemas)
- ⚙️ Integración básica con mcl_jukebox

---

## 🚀 Roadmap Futuro

### Mejoras Planeadas
- [ ] Sistema de crafting para obtener discos (survival mode)
- [ ] Easter eggs: discos ocultos en cofres del mundo
- [ ] Visualizador de música (partículas alrededor del jukebox)
- [ ] Comando `/música` para listar discos disponibles
- [ ] Integración con sistema de logros

### Contenido Musical
- [ ] Playlist temática de estaciones (verano, invierno, etc.)
- [ ] Música ambiental para biomas específicos
- [ ] Discos educativos con narración sobre animales

---

## 📞 Soporte y Contribuciones

### Reportar Problemas
- **GitHub Issues**: `https://github.com/gabrielpantoja-cl/luanti-voxelibre-server/issues`
- **Logs del servidor**: Incluye siempre los logs al reportar bugs

### Contribuir
1. Fork del repositorio
2. Crea branch para tu feature: `git checkout -b feature/nueva-musica`
3. Asegúrate de seguir las especificaciones de assets (16x16, OGG)
4. Pull request con descripción detallada

### Testing Local
```bash
# Clonar repositorio
git clone https://github.com/gabrielpantoja-cl/luanti-voxelibre-server.git
cd luanti-voxelibre-server

# Iniciar servidor local
./scripts/start.sh

# Conectar Luanti client a localhost:30000
```

---

## 📚 Referencias Técnicas

### VoxeLibre API Documentation
- mcl_jukebox: Incluido en VoxeLibre, no documentación pública separada
- Referencia de código: `server/games/mineclone2/mods/ITEMS/mcl_jukebox/`

### Herramientas Recomendadas
- **Audio**: Audacity, ffmpeg, OGG Vorbis encoder
- **Texturas**: GIMP, Aseprite, ImageMagick, Python PIL/Pillow
- **Testing**: Luanti client 5.13+, servidor local con Docker

### Comandos Útiles
```bash
# Ver texturas y sus dimensiones
for f in server/mods/wetlands-music/textures/*.png; do
    echo "$f: $(file $f | grep -o '[0-9]* x [0-9]*')"
done

# Verificar archivos OGG
for f in server/mods/wetlands-music/sounds/*.ogg; do
    ffprobe -hide_banner "$f" 2>&1 | grep Duration
done

# Logs en vivo del servidor
docker compose logs -f luanti-server | grep -i "music\|jukebox"
```

---

**Última actualización**: 2025-10-26
**Mantenido por**: Gabriel Pantoja (@gabrielpantoja-cl)
**Servidor de producción**: luanti.gabrielpantoja.cl:30000