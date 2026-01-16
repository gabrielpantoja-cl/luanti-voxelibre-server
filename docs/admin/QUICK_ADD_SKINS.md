# 🎨 Guía Rápida: Agregar Skins desde MinecraftSkins.com

**Fecha**: 2026-01-15
**Servidor**: Wetlands (luanti.gabrielpantoja.cl:30000)

## 📊 Skins Actuales Instalados

| Skin | Género | Archivo | Estado |
|------|--------|---------|--------|
| wetlands_cuidador_animales | Male | wetlands_cuidador_animales.png | ✅ Configurado |
| wetlands_veterinaria | Female | wetlands_veterinaria.png | ✅ Configurado |
| zombie | Male | zombie.png | ✅ Configurado |
| buddhist_monk | Male | buddhist_monk.png | ✅ Configurado |
| ninja_boxy | Male | ninja_boxy.png | ✅ Configurado |
| panda | Male | panda.png | ✅ Configurado |
| santa_ho_ho_ho | Male | santa_ho_ho_ho.png | ✅ Configurado |

**Total**: 7 skins personalizados disponibles

## 🚀 Proceso Rápido: Agregar Nuevo Skin

### Paso 1: Descargar Skin de MinecraftSkins.com

1. Visita: https://www.minecraftskins.com/
2. Busca el skin que desees (ej: "farmer", "veterinarian", "gardener")
3. Haz clic en "Download" para descargar el archivo PNG
4. El archivo se descargará típicamente como: `minecraftskins_nombre-descripcion-12345.png`

**⚠️ IMPORTANTE**: Los skins de Minecraft son 64x64, pero VoxeLibre requiere 64x32. Nuestro script automáticamente los convierte.

### Paso 2: Usar el Script Automatizado

```bash
# Navegar al directorio del proyecto
cd /home/gabriel/Documentos/luanti-voxelibre-server

# Agregar skin con nombre automático
./scripts/add-skin.sh ~/Downloads/minecraftskins_farmer-12345.png

# O con nombre personalizado y género
./scripts/add-skin.sh ~/Downloads/minecraftskins_farmer-12345.png granjero_vegano male
./scripts/add-skin.sh ~/Downloads/minecraftskins_vet-67890.png veterinaria_emma female
```

### Paso 3: Sincronizar con el VPS

```bash
# Copiar el nuevo skin al servidor
scp server/worlds/world/_world_folder_media/textures/granjero_vegano.png \
    gabriel@167.172.251.27:/home/gabriel/luanti-voxelibre-server/server/worlds/world/_world_folder_media/textures/

# Copiar el skins.txt actualizado
scp server/worlds/world/skins.txt \
    gabriel@167.172.251.27:/home/gabriel/luanti-voxelibre-server/server/worlds/world/

# Reiniciar el servidor
ssh gabriel@167.172.251.27 'cd /home/gabriel/luanti-voxelibre-server && docker-compose restart luanti-server'
```

### Paso 4: Verificar en el Juego

1. Conectar al servidor: `luanti.gabrielpantoja.cl:30000`
2. Usar comando: `/skin`
3. Seleccionar el nuevo skin desde el menú

## 🎯 Ejemplos de Uso del Script

### Ejemplo 1: Agregar Granjero
```bash
# Descargar desde minecraftskins.com: "Vegan Farmer"
# Archivo descargado: minecraftskins_vegan-farmer-98765.png

./scripts/add-skin.sh ~/Downloads/minecraftskins_vegan-farmer-98765.png granjero_vegano male
```

**Resultado**:
- ✅ Convertido de 64x64 a 64x32
- ✅ Guardado como: `granjero_vegano.png`
- ✅ Agregado a `skins.txt` con género "male"

### Ejemplo 2: Agregar Veterinaria
```bash
# Descargar desde minecraftskins.com: "Veterinarian Female"
# Archivo descargado: minecraftskins_vet-female-54321.png

./scripts/add-skin.sh ~/Downloads/minecraftskins_vet-female-54321.png vet_ana female
```

**Resultado**:
- ✅ Convertido de 64x64 a 64x32
- ✅ Guardado como: `vet_ana.png`
- ✅ Agregado a `skins.txt` con género "female"

### Ejemplo 3: Agregar con Nombre Automático
```bash
# Si no especificas nombre, el script lo genera automáticamente
./scripts/add-skin.sh ~/Downloads/minecraftskins_gardener-botanist-11111.png

# Genera automáticamente: minecraftskins_gardener_botanist_11111.png
# (Limpiando caracteres especiales y guiones)
```

## 🌱 Skins Recomendados para Wetlands

### Temática Compasiva y Educativa

**Profesiones de Cuidado**:
- ✅ Veterinaria/o
- ✅ Cuidador de animales (Animal Caretaker)
- ✅ Granjero vegano (Vegan Farmer)
- ✅ Jardinero/Botanista (Gardener/Botanist)
- ✅ Rescatista de vida silvestre (Wildlife Rescuer)

**Personajes Educativos**:
- ✅ Maestro/a (Teacher)
- ✅ Científico/a ambiental (Environmental Scientist)
- ✅ Chef vegano (Vegan Chef)
- ✅ Activista ambiental (Environmental Activist)

**Personajes Creativos**:
- ✅ Artista de la naturaleza (Nature Artist)
- ✅ Fotógrafo de vida silvestre (Wildlife Photographer)
- ✅ Constructor ecológico (Eco-Builder)

### ❌ Evitar

- ❌ Personajes con armas
- ❌ Skins de terror o monstruos violentos
- ❌ Contenido inapropiado para niños 7+
- ❌ Personajes de guerra o violencia

## 🔍 Búsquedas Sugeridas en MinecraftSkins.com

```
farmer
veterinarian
gardener
botanist
chef
scientist
teacher
wildlife rescuer
nature lover
eco warrior
animal caretaker
plant scientist
```

## 🛠️ Opciones del Script

### Sintaxis Completa
```bash
./scripts/add-skin.sh <archivo_skin.png> [nombre_limpio] [genero]
```

### Parámetros

| Parámetro | Descripción | Requerido | Valores | Ejemplo |
|-----------|-------------|-----------|---------|---------|
| `archivo_skin.png` | Ruta al archivo del skin | ✅ Sí | Ruta válida | `~/Downloads/skin.png` |
| `nombre_limpio` | Nombre simple sin espacios | ❌ No | Sin guiones/espacios | `granjero_vegano` |
| `genero` | Género del personaje | ❌ No | `male` o `female` | `female` |

### Ayuda del Script
```bash
./scripts/add-skin.sh --help
```

## 📋 Checklist de Verificación

Antes de sincronizar con el VPS:

- [ ] ✅ Skin descargado de minecraftskins.com
- [ ] ✅ Script ejecutado sin errores
- [ ] ✅ Archivo PNG generado en `server/worlds/world/_world_folder_media/textures/`
- [ ] ✅ Dimensiones verificadas: 64x32
- [ ] ✅ `skins.txt` actualizado con nueva entrada
- [ ] ✅ Nombre del skin no contiene guiones ni espacios
- [ ] ✅ Género especificado correctamente (male/female)

Después de sincronizar con VPS:

- [ ] ✅ Archivo copiado al servidor con `scp`
- [ ] ✅ `skins.txt` copiado al servidor
- [ ] ✅ Servidor reiniciado
- [ ] ✅ Skin visible en el juego con comando `/skin`

## 🔧 Troubleshooting

### Problema: Script no encuentra ImageMagick
**Solución**:
```bash
sudo apt update
sudo apt install imagemagick
```

### Problema: Skin no aparece en el juego
**Verificar**:
1. Dimensiones del archivo: `identify nombre.png` (debe ser 64x32)
2. Nombre en `skins.txt` **sin extensión** `.png`
3. Servidor reiniciado después de agregar el skin
4. Cliente Luanti actualizado (cierra y reabre el juego)

### Problema: Skin se ve corrupto
**Causa**: Probablemente no se convirtió de 64x64 a 64x32

**Solución**: Re-ejecutar el script, él hace la conversión automáticamente

### Problema: Error "Name does not follow naming conventions"
**Causa**: Nombre de archivo con guiones o caracteres especiales

**Solución**: El script automáticamente limpia los nombres, pero si persiste:
```bash
# Renombrar manualmente
cd server/worlds/world/_world_folder_media/textures/
mv "nombre-con-guiones.png" "nombre_limpio.png"
# Actualizar skins.txt con el nuevo nombre
```

## 📊 Estado del Sistema

### Ubicaciones de Archivos

```
luanti-voxelibre-server/
├── scripts/
│   └── add-skin.sh                     # 🔧 Script automatizado
├── server/
│   └── worlds/
│       └── world/
│           ├── _world_folder_media/
│           │   └── textures/           # 🎨 Archivos PNG de skins (64x32)
│           └── skins.txt               # 📋 Configuración de skins
└── docs/
    ├── CUSTOM_SKINS_SETUP.md           # 📖 Guía completa
    └── QUICK_ADD_SKINS.md              # 🚀 Esta guía rápida
```

### Mods Instalados

- ✅ `_world_folder_media` v2023-01-14 (MisterE)
- ✅ `mcl_custom_world_skins` v2024-12-22 (covertiii)

### Configuración Activa

**Archivo**: `server/config/luanti.conf`
```ini
load_mod__world_folder_media = true
load_mod_mcl_custom_world_skins = true
```

**Archivo**: `server/worlds/world/world.mt` (no versionado en Git)
```ini
load_mod__world_folder_media = true
load_mod_mcl_custom_world_skins = true
```

## 📚 Referencias

- **MinecraftSkins.com**: https://www.minecraftskins.com/
- **Convertidor Online**: https://godly.github.io/minetest-skin-converter/
- **Mod World Folder Media**: https://content.luanti.org/packages/MisterE/_world_folder_media/
- **Mod Custom Skins**: https://content.luanti.org/packages/covertiii/mcl_custom_world_skins/
- **VoxeLibre Docs**: https://git.minetest.land/VoxeLibre/VoxeLibre

---

**Mantenedor**: Gabriel Pantoja
**Servidor**: Wetlands (luanti.gabrielpantoja.cl:30000)
**Última actualización**: 2026-01-15
