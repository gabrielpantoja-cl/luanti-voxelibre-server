# 🎨 Inventario de Skins - Wetlands Server

**Fecha de actualización**: 2026-01-16
**Servidor**: luanti.gabrielpantoja.cl:30000
**Sistema**: VoxeLibre Custom Skins

## 📊 Resumen

| Categoría | Cantidad | Estado |
|-----------|----------|--------|
| Skins Wetlands Originales | 2 | ⚠️ Pendiente crear texturas |
| Villagers VoxeLibre | 3 | ✅ Convertidos y listos |
| Personajes Diversos | 5 | ✅ Configurados |
| **TOTAL** | **10** | **80% Listo** |

## 🎭 Catálogo Completo de Skins

### 🌱 Skins Temáticas Wetlands (Originales)

| # | Nombre | Género | Archivo | Dimensiones | Estado |
|---|--------|--------|---------|-------------|--------|
| 1 | wetlands_cuidador_animales | Male | wetlands_cuidador_animales.png | - | ⚠️ Archivo faltante |
| 2 | wetlands_veterinaria | Female | wetlands_veterinaria.png | - | ⚠️ Archivo faltante |

**Estado**: Configurados en `skins.txt` pero sin archivo PNG. Necesitan ser creados o descargados.

---

### 🧑‍🌾 Villagers VoxeLibre (Convertidos de Mobs)

| # | Nombre | Género | Archivo | Dimensiones | Estado |
|---|--------|--------|---------|-------------|--------|
| 3 | granjero_aldeano | Male | granjero_aldeano.png | 64x32 | ✅ Listo |
| 4 | bibliotecario_aldeano | Male | bibliotecario_aldeano.png | 64x32 | ✅ Listo |
| 5 | sacerdote_aldeano | Male | sacerdote_aldeano.png | 64x32 | ✅ Listo |

**Origen**: Texturas de mobs de VoxeLibre convertidas de 64x64 a 64x32
**Características**:
- **Granjero**: Sombrero de paja, ropa marrón, perfecto para temática agrícola
- **Bibliotecario**: Gafas, ropa púrpura, ideal para personajes educativos
- **Sacerdote**: Ropa morada, personaje espiritual/meditativo

---

### 🎭 Personajes Diversos

| # | Nombre | Género | Archivo | Dimensiones | Estado |
|---|--------|--------|---------|-------------|--------|
| 6 | zombie | Male | zombie.png | 64x32 | ✅ Listo |
| 7 | buddhist_monk | Male | buddhist_monk.png | 64x32 | ✅ Listo |
| 8 | ninja_boxy | Male | ninja_boxy.png | 64x32 | ✅ Listo |
| 9 | panda | Male | panda.png | 64x32 | ✅ Listo |
| 10 | santa_ho_ho_ho | Male | santa_ho_ho_ho.png | 64x32 | ✅ Listo |

**Origen**: MinecraftSkins.com y fuentes diversas
**Características**:
- **Zombie**: Skin clásico de Minecraft, convertido de 64x64
- **Buddhist Monk**: Monje budista, temática de paz y meditación
- **Ninja Boxy**: Personaje ninja con estética pixelada
- **Panda**: Disfraz de panda, lúdico y amigable
- **Santa**: Temática navideña, festivo

---

## 📁 Estructura de Archivos

```
server/worlds/world/
├── _world_folder_media/
│   └── textures/
│       ├── granjero_aldeano.png          # ✅ 64x32
│       ├── bibliotecario_aldeano.png     # ✅ 64x32
│       ├── sacerdote_aldeano.png         # ✅ 64x32
│       ├── zombie.png                    # ✅ 64x32
│       ├── buddhist_monk.png             # ✅ 64x32
│       ├── ninja_boxy.png                # ✅ 64x32
│       ├── panda.png                     # ✅ 64x32
│       ├── santa_ho_ho_ho.png            # ✅ 64x32
│       ├── wetlands_cuidador_animales.png  # ⚠️ FALTANTE
│       └── wetlands_veterinaria.png        # ⚠️ FALTANTE
└── skins.txt                             # ✅ Configuración completa
```

---

## 🚀 Últimas Adiciones (2026-01-16)

### Skins Agregados Hoy

1. **zombie** (19:19) - Convertido de 64x64 a 64x32 ✅
2. **granjero_aldeano** (19:25) - Desde villager farmer de VoxeLibre ✅
3. **bibliotecario_aldeano** (19:25) - Desde villager librarian de VoxeLibre ✅
4. **sacerdote_aldeano** (19:25) - Desde villager priest de VoxeLibre ✅

**Total agregados**: 4 skins nuevos
**Método**: Script automatizado `scripts/add-skin.sh`
**Conversión**: Automática de 64x64 → 64x32

---

## ⚠️ Tareas Pendientes

### Alta Prioridad

- [ ] **Crear/descargar texturas faltantes**:
  - [ ] `wetlands_cuidador_animales.png`
  - [ ] `wetlands_veterinaria.png`

### Sugerencias para Nuevos Skins

**Temática Wetlands (Compasiva y Educativa)**:
- [ ] Jardinero/Botanista (gardener)
- [ ] Chef vegano (vegan chef)
- [ ] Científico ambiental (environmental scientist)
- [ ] Rescatista de vida silvestre (wildlife rescuer)
- [ ] Activista ambiental (eco warrior)
- [ ] Veterinario con bata (veterinarian with coat)
- [ ] Agricultor ecológico (organic farmer)

**Dónde buscar**: https://www.minecraftskins.com/
**Búsquedas sugeridas**: `farmer`, `veterinarian`, `gardener`, `botanist`, `chef`, `scientist`

---

## 🛠️ Herramientas Disponibles

### Script: `add-skin.sh`
Agrega skins automáticamente con conversión de formato.

**Uso**:
```bash
./scripts/add-skin.sh <archivo.png> [nombre] [genero]
```

**Ejemplo**:
```bash
./scripts/add-skin.sh ~/Downloads/skin.png jardinero male
```

### Script: `sync-skins-to-vps.sh` 🆕
Sincroniza todos los skins al servidor VPS.

**Uso**:
```bash
./scripts/sync-skins-to-vps.sh
```

**Funciones**:
- ✅ Crea backup automático en VPS
- ✅ Sincroniza texturas vía rsync
- ✅ Actualiza skins.txt
- ✅ Reinicia servidor automáticamente
- ✅ Verifica estado post-sincronización

---

## 📊 Estadísticas de Conversión

| Skin | Original | Convertido | Método | Fecha |
|------|----------|------------|--------|-------|
| zombie | 64x64 | 64x32 | Script | 2026-01-16 |
| granjero_aldeano | 64x64 (mob) | 64x32 | Script | 2026-01-16 |
| bibliotecario_aldeano | 64x64 (mob) | 64x32 | Script | 2026-01-16 |
| sacerdote_aldeano | 64x64 (mob) | 64x32 | Script | 2026-01-16 |
| buddhist_monk | 64x32 | - | Ya correcto | - |
| ninja_boxy | 64x32 | - | Ya correcto | - |
| panda | 64x32 | - | Ya correcto | - |
| santa_ho_ho_ho | 64x32 | - | Ya correcto | - |

---

## 🎮 Uso en el Juego

### Comando de Skins
```
/skin
```

### Menú de Personalización
- ✅ Skins predeterminadas de VoxeLibre
- ✅ Skins personalizadas de Wetlands
- ✅ Personalizar color de cabello, ropa, ojos
- ✅ Vista previa 3D del personaje

---

## 📋 Checklist de Verificación

### Antes de Sincronizar al VPS

- [x] ✅ Todos los skins convertidos a 64x32
- [x] ✅ Nombres sin guiones ni caracteres especiales
- [x] ✅ Género especificado en skins.txt
- [x] ✅ Archivos PNG verificados con `identify`
- [x] ✅ skins.txt actualizado correctamente
- [ ] ⚠️ Texturas faltantes creadas/descargadas

### Después de Sincronizar

- [ ] Archivos copiados al VPS
- [ ] skins.txt copiado al VPS
- [ ] Servidor reiniciado
- [ ] Skins visibles en el juego con `/skin`
- [ ] Sin errores en logs del servidor

---

## 🔗 Enlaces Útiles

- **MinecraftSkins.com**: https://www.minecraftskins.com/
- **Convertidor de Skins**: https://godly.github.io/minetest-skin-converter/
- **VoxeLibre ContentDB**: https://content.luanti.org/packages/Wuzzy/mineclone2/
- **Documentación Completa**: `docs/CUSTOM_SKINS_SETUP.md`
- **Guía Rápida**: `docs/QUICK_ADD_SKINS.md`

---

**Mantenedor**: Gabriel Pantoja
**Servidor**: Wetlands (luanti.gabrielpantoja.cl:30000)
**Última actualización**: 2026-01-16 19:30
