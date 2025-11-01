# Wetlands Christmas Decorations 🎄

**Adaptación del mod Christmas Decor para VoxeLibre**

Decoraciones navideñas compasivas y festivas diseñadas específicamente para el servidor Wetlands. Este mod trae la magia de la Navidad a VoxeLibre con luces, dulces, y decoraciones temáticas.

## 🎁 Características

### 🍬 Comida Navideña
- **Bastones de Caramelo**: Decorativos y comestibles (+4 alimento)
- **Galletas de Jengibre**: Deliciosas galletas con forma humana (+6 alimento)
- **Gomitas de Colores**: 6 colores diferentes (rojo, naranja, amarillo, verde, azul, morado) (+2 alimento cada una)
- **Vaso de Leche de Avena**: Perfecto para acompañar galletas (+4 alimento)
- **Bloques Decorativos Comestibles**: Bloques de caramelo, menta y glaseado para construcciones festivas

### 💡 Luces Navideñas
- **Luces Blancas**: Luces navideñas clásicas animadas
- **Luces Blancas Carámbano**: Estilo de luces colgantes
- **Luces Multicolor**: Luces animadas con colores festivos
- **Luces Multicolor Bombilla**: Estilo bombilla de colores
- **Guirnaldas**: Con y sin luces integradas

### 🎨 Decoraciones
- **Muérdago**: Planta navideña tradicional
- **Carámbanos**: Versiones de pared y colgantes con animación brillante
- **Muñeco de Nieve**: Amigable decoración invernal
- **Cascanueces**: Guardián navideño decorativo
- **Calcetín Navideño**: Decoración de pared festiva
- **Arbusto Navideño**: Pequeño arbusto decorado

### 🏗️ Bloques de Construcción
- **Bloque de Bastón de Caramelo**: Patrón rayado rojo y blanco
- **Bloque de Menta**: Diseño espiral de menta
- **Bloque de Glaseado**: Textura suave de glaseado
- **Moldura de Glaseado**: Decoración de pared
- **Línea de Glaseado**: Detalle decorativo delgado

## 🔧 Compatibilidad VoxeLibre

### ✅ Adaptaciones Realizadas
- **APIs reemplazadas**: Todas las llamadas a `default` fueron reemplazadas por `mcl_core`
- **Sistema de sonidos**: Compatible con `mcl_sounds`
- **Grupos de items**: Adaptados a grupos de VoxeLibre (`handy`, `deco_block`, `building_block`)
- **Propiedades de dureza**: Añadidas `_mcl_blast_resistance` y `_mcl_hardness`
- **Sin dependencias obligatorias**: Funciona con instalación base de VoxeLibre

### ❌ Características Removidas del Mod Original
- **Sistema de mobs** (Santa, Mrs. Claus, renos): Incompatible con VoxeLibre (requiere `mobs_redo` API)
- **Armadura 3D** (gorros): Sistema diferente en VoxeLibre
- **LEDs avanzados**: Removida dependencia de `basic_materials`
- **Sistema de recompensas de calcetines**: Simplificado a decoración

## 📦 Instalación

### Método 1: En servidor Wetlands (recomendado)
El mod ya está incluido en el servidor Wetlands. Solo necesitas conectarte y disfrutar.

### Método 2: Instalación manual
```bash
cd server/mods/
git clone <repository_url> wetlands_christmas
# O copiar directamente la carpeta wetlands_christmas/
```

### Método 3: Desarrollo local
```bash
# Clonar repositorio completo de Wetlands
git clone https://github.com/gabrielpantoja-cl/luanti-voxelibre-server.git
cd luanti-voxelibre-server
./scripts/start.sh
```

## 🎮 Uso en el Juego

### Modo Creativo
Todos los items están disponibles en el inventario creativo bajo las categorías:
- **Decoraciones** (`deco_block`)
- **Bloques de Construcción** (`building_block`)
- **Comida** (`food`)

### Craftings Básicos

**Galletas de Jengibre:**
```
Cortador de Galletas + Masa de Jengibre → 5 Galletas Crudas
Hornear Galleta Cruda → Galleta de Jengibre
```

**Luces Navideñas Blancas:**
```
LED × 6 + Cable × 3 → 6 Luces Blancas
```

**Guirnalda con Luces:**
```
Guirnalda + LED Blanco × 3 → Guirnalda con Luces
```

**Decoraciones de Glaseado:**
```
Bloque de Glaseado × 4 → 6 Molduras de Glaseado
Bloque de Glaseado × 3 → 6 Líneas de Glaseado
```

## 🛠️ Desarrollo

### Estructura del Mod
```
wetlands_christmas/
├── mod.conf                # Metadatos del mod
├── init.lua               # Cargador principal
├── food.lua               # Items de comida
├── lights.lua             # Luces navideñas
├── misc.lua               # Decoraciones misceláneas
├── textures/              # 60+ texturas
├── models/                # Modelos 3D (.obj, .b3d)
└── README.md              # Este archivo
```

### Dependencias Opcionales
```
mcl_core, mcl_farming, mcl_stairs, mcl_sounds, mcl_dye, mcl_buckets
```

Todas son opcionales - el mod funciona sin ninguna dependencia.

### Añadir Nuevos Items
1. Editar el archivo correspondiente (`food.lua`, `lights.lua`, `misc.lua`)
2. Usar la función `get_sound()` para sonidos compatibles
3. Añadir grupos VoxeLibre apropiados
4. Incluir propiedades `_mcl_blast_resistance` y `_mcl_hardness`
5. Testear en servidor local antes de deployment

## 📝 Créditos

### Mod Original
- **Autor Original**: GreenXenith
- **Nombre**: christmas_decor
- **Repositorio**: https://github.com/GreenXenith/christmas_decor
- **ContentDB**: https://content.luanti.org/packages/GreenXenith/christmas_decor/
- **Licencia**: MIT

### Adaptación VoxeLibre
- **Adaptador**: gabrielpantoja-cl (Gabriel Pantoja)
- **Proyecto**: Wetlands Luanti Server
- **Fecha**: 2025-01-11
- **Licencia**: MIT (mantiene licencia original)

### Texturas y Modelos
Todos los assets (texturas y modelos 3D) son obra de GreenXenith y están licenciados bajo MIT.

### Cambios Principales
1. Eliminación de sistema de mobs (`mobs_redo` incompatible)
2. Reemplazo de APIs `default` por `mcl_core`
3. Adaptación de sistema de sonidos a `mcl_sounds`
4. Simplificación de craftings (eliminadas dependencias complejas)
5. Traducción de descripciones al español
6. Añadidos metadatos de dureza de VoxeLibre

## 🌟 Filosofía del Servidor Wetlands

Este mod se alinea con los valores de Wetlands:
- **Educativo**: Enseña sobre tradiciones navideñas
- **Compasivo**: Sin violencia (mobs removidos)
- **Creativo**: Fomenta la construcción festiva
- **Inclusivo**: Leche de **avena** (plant-based)
- **Apropiado para niños 7+**

## 📄 Licencia

MIT License (mantiene licencia del mod original)

Copyright (c) 2024 GreenXenith (mod original)
Copyright (c) 2025 gabrielpantoja-cl (adaptación VoxeLibre)

Se permite el uso, copia, modificación y distribución de este software bajo los términos de la licencia MIT.

## 🐛 Reporte de Bugs

Reportar problemas en:
- **Repositorio**: https://github.com/gabrielpantoja-cl/luanti-voxelibre-server
- **Issues**: https://github.com/gabrielpantoja-cl/luanti-voxelibre-server/issues

## 🎄 ¡Felices Fiestas!

Que disfrutes decorando tu mundo de VoxeLibre con estas hermosas decoraciones navideñas.

**Servidor oficial**: `luanti.gabrielpantoja.cl:30000`