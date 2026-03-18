# 🎨 Custom Skins System Setup - Wetlands Server

**Fecha de instalación**: 2025-12-07
**Mods instalados**: `_world_folder_media` + `mcl_custom_world_skins`

## 📦 Mods Instalados

### 1. World Folder Media
- **Autor**: MisterE
- **Versión**: 2023-01-14
- **Propósito**: Permite cargar texturas y sonidos desde la carpeta del mundo
- **Ubicación**: `server/mods/_world_folder_media/`
- **ContentDB**: https://content.luanti.org/packages/MisterE/_world_folder_media/

### 2. VoxeLibre Custom World Skins
- **Autor**: covertiii
- **Versión**: 2024-12-22
- **Propósito**: Sistema de skins personalizadas para VoxeLibre
- **Ubicación**: `server/mods/mcl_custom_world_skins/`
- **ContentDB**: https://content.luanti.org/packages/covertiii/mcl_custom_world_skins/
- **Dependencias**: `_world_folder_media`, `mcl_player`, `mcl_skins`

## ⚙️ Configuración Aplicada

### Archivo: `server/config/luanti.conf`
```ini
# === SISTEMA DE SKINS PERSONALIZADOS - Dec 7, 2025 ===
# Permite agregar skins customizados desde la carpeta del mundo
load_mod__world_folder_media = true
load_mod_mcl_custom_world_skins = true
```

### Archivo: `server/worlds/world/world.mt` ⚠️
**NOTA**: Este archivo NO está en Git (`.gitignore`). Debe actualizarse manualmente en VPS y local.

```ini
# Agregar estas líneas al final del archivo
load_mod__world_folder_media = true
load_mod_mcl_custom_world_skins = true
```

### Estructura de Directorios Creada

```
server/worlds/world/
├── _world_folder_media/           # Directorio de medios del mundo
│   └── textures/                  # Texturas de skins (PNG 64x32)
│       └── README.md              # Guía de uso
└── skins.txt                      # Configuración de skins
```

## 📝 Configuración de Skins (skins.txt)

**Ubicación**: `server/worlds/world/skins.txt`

```lua
-- Ejemplo de configuración
return {
  {
    texture = "wetlands_cuidador_animales",
    gender = "male"
  },
  {
    texture = "wetlands_veterinaria",
    gender = "female"
  },
}
```

## 🎨 Cómo Agregar Nuevas Skins

### Paso 1: Preparar la Textura
1. Obtener/crear skin PNG de **64x32 píxeles** (⚠️ CRÍTICO: VoxeLibre solo soporta 64x32, NO 64x64)
2. Si es de Minecraft (64x64), **DEBES convertir** usando:
   - **Opción 1 (Recomendada)**: https://godly.github.io/minetest-skin-converter/
   - **Opción 2 (Local)**: Usar ImageMagick o Python PIL para convertir
3. Nombrar apropiadamente: `wetlands_nombre_descriptivo.png` (sin guiones ni caracteres especiales)

**⚠️ IMPORTANTE**: Si usas una textura 64x64 sin convertir, se verá **corrupta o distorsionada** en el juego.

### Paso 2: Subir al Servidor (VPS)

```bash
# Copiar textura al servidor
scp mi_skin.png gabriel@<IP_VPS_ANTERIOR>:/home/gabriel/luanti-voxelibre-server/server/worlds/world/_world_folder_media/textures/

# O via SSH
ssh gabriel@<IP_VPS_ANTERIOR>
cd /home/gabriel/luanti-voxelibre-server/server/worlds/world/_world_folder_media/textures/
# Subir archivo aquí
```

### Paso 3: Actualizar skins.txt

```bash
ssh gabriel@<IP_VPS_ANTERIOR>
cd /home/gabriel/luanti-voxelibre-server/server/worlds/world
nano skins.txt
# Agregar entrada de skin según formato
```

### Paso 4: Reiniciar Servidor

```bash
ssh gabriel@<IP_VPS_ANTERIOR>
cd /home/gabriel/luanti-voxelibre-server
docker-compose restart luanti-server
```

## 🎮 Uso en el Juego

Los jugadores pueden cambiar su skin usando el comando:
```
/skin
```

Esto abrirá el menú de personalización donde pueden:
- Seleccionar skins predeterminadas de VoxeLibre
- Seleccionar skins personalizadas de Wetlands
- Personalizar color de cabello, ropa, ojos, etc.

## 🌱 Temática Wetlands

### Skins Recomendadas:
- ✅ Cuidadores de animales
- ✅ Veterinarios/as
- ✅ Granjeros veganos
- ✅ Rescatistas de vida silvestre
- ✅ Jardineros y botanistas
- ✅ Personajes con ropa natural (verdes, marrones)

### Evitar:
- ❌ Skins violentas o con armas
- ❌ Personajes de terror
- ❌ Contenido inapropiado para niños 7+

## 🔧 Troubleshooting

### Las skins no aparecen
1. Verificar que el archivo PNG sea **64x32** (no 64x64) - usar `identify nombre.png` o `file nombre.png`
2. Verificar nombre sin espacios ni caracteres especiales
3. Verificar que esté registrado en `skins.txt` SIN la extensión `.png`
4. Reiniciar el servidor

### ⚠️ La skin se ve corrupta o distorsionada
**Problema**: La textura se ve mal, pixelada o con partes faltantes en el juego.

**Causa más común**: La textura es **64x64** en lugar de **64x32**.

**Solución**:
1. **Verificar tamaño de la textura**:
   ```bash
   identify server/worlds/world/_world_folder_media/textures/panda.png
   # Debe mostrar: PNG 64x32
   ```

2. **Convertir de 64x64 a 64x32**:
   ```bash
   # Opción 1: Usar ImageMagick
   convert panda.png -resize 64x32! panda_64x32.png
   
   # Opción 2: Usar Python PIL (copia mitad superior)
   python3 << 'PYTHON'
   from PIL import Image
   img = Image.open('panda.png')
   new_img = Image.new('RGBA', (64, 32))
   new_img.paste(img.crop((0, 0, 64, 32)), (0, 0))
   new_img.save('panda.png', 'PNG')
   PYTHON
   ```

3. **Subir al servidor y reiniciar**:
   ```bash
   scp panda.png gabriel@<IP_VPS_ANTERIOR>:/home/gabriel/luanti-voxelibre-server/server/worlds/world/_world_folder_media/textures/
   ssh gabriel@<IP_VPS_ANTERIOR> "cd /home/gabriel/luanti-voxelibre-server && docker-compose restart luanti-server"
   ```

4. **Limpiar caché del cliente** (si es necesario):
   - Cerrar completamente el cliente Luanti
   - Eliminar caché de texturas del cliente
   - Reconectar al servidor

### Error al cargar mod
1. Verificar que ambos mods estén en `server/mods/`
2. Verificar configuración en `luanti.conf` y `world.mt`
3. Revisar logs: `docker-compose logs luanti-server | grep -i skin`

### ⚠️ Error: "Name does not follow naming conventions" (mcl_maps)
**Problema**: Cuando se agregan skins desde MinecraftSkins.com, los nombres de archivo pueden contener guiones y caracteres especiales (ej: `minecraftskins_panda-panda-23030559.png`) que causan que el mod `mcl_maps` falle al intentar registrar nodos.

**Síntomas**:
- El servidor no puede iniciar completamente
- Errores repetidos en logs: `ModError: Failed to load and run script from mcl_maps/init.lua`
- Error: `Name does not follow naming conventions: contains unallowed characters`
- Los clientes no pueden conectarse (timeout)

**Solución correcta**:
1. **Renombrar el archivo del skin** a un nombre simple sin guiones ni caracteres especiales:
   ```bash
   # En el servidor VPS
   ssh gabriel@<IP_VPS_ANTERIOR>
   cd /home/gabriel/luanti-voxelibre-server
   docker-compose exec -T luanti-server sh -c 'cd /config/.minetest/worlds/world/_world_folder_media/textures/ && mv minecraftskins_panda-panda-23030559.png panda.png'
   ```

2. **Actualizar `skins.txt`** para usar el nuevo nombre:
   ```lua
   -- ❌ Incorrecto
   texture = "minecraftskins_panda-panda-23030559"
   
   -- ✅ Correcto
   texture = "panda"
   ```

3. **Reiniciar el servidor**:
   ```bash
   docker-compose restart luanti-server
   ```

**Prevención futura**:
- **SIEMPRE** renombrar archivos de skins a nombres simples sin guiones ni caracteres especiales
- Usar nombres descriptivos y cortos (ej: `panda.png`, `veterinaria.png`, `granjero.png`)
- En `skins.txt`, usar solo el nombre del archivo SIN la extensión `.png`
- Ejemplo correcto: `texture = "panda"` en lugar de `texture = "minecraftskins_panda-panda-23030559"`

## 📚 Referencias

- **Mod World Folder Media**: https://content.luanti.org/packages/MisterE/_world_folder_media/
- **Mod Custom Skins**: https://content.luanti.org/packages/covertiii/mcl_custom_world_skins/
- **Convertidor de Skins**: https://godly.github.io/minetest-skin-converter/
- **Skins de Minecraft**: https://www.minecraftskins.com/
- **VoxeLibre Docs**: https://git.minetest.land/VoxeLibre/VoxeLibre

---
**Mantenedor**: Gabriel Pantoja
**Servidor**: Wetlands (luanti.gabrielpantoja.cl:30000)
**Última actualización**: 2025-12-07
