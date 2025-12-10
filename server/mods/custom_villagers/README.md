# 🏘️ Custom Villagers - Aldeanos Interactivos de Wetlands

**Versión**: 1.0.0
**Autor**: Wetlands Team
**Licencia**: GPL v3
**Compatible con**: VoxeLibre (MineClone2) v0.90.1+

---

## 📖 Descripción

Mod de NPCs (aldeanos) interactivos con sistema de diálogos, comercio educativo y rutinas diarias. Diseñado para el servidor Wetlands con contenido apropiado para niños 7+ años.

### ✨ Características Principales

- 👥 **4 tipos de aldeanos**: Agricultor, Bibliotecario, Maestro, Explorador
- 💬 **Sistema de diálogos**: Conversaciones educativas contextuales
- 🛒 **Comercio educativo**: Intercambio de items útiles por esmeraldas
- 🚶 **Pathfinding básico**: Los aldeanos caminan cerca de su hogar
- ⏰ **Rutinas día/noche**: Activos de día, duermen de noche
- 🛡️ **Pacíficos**: No se pueden lastimar (apropiado para servidor compasivo)

---

## 🎮 Uso en el Juego

### Interacción con Aldeanos

1. **Click derecho** en un aldeano para abrir menú de interacción
2. **Opciones disponibles**:
   - 👋 **Saludar**: Recibe un saludo amistoso
   - 💼 **Preguntar sobre trabajo**: Aprende sobre su profesión
   - 📚 **Aprender algo nuevo**: Recibe educación temática
   - 🛒 **Comerciar**: Intercambia esmeraldas por items (si está habilitado)

### Tipos de Aldeanos

#### 🌾 Agricultor (Farmer)
- **Profesión**: Cultiva vegetales y alimentos de origen vegetal
- **Enseña sobre**: Agricultura sostenible, nutrición vegetal
- **Comercia**: Zanahorias, papas, remolachas, trigo

#### 📚 Bibliotecario (Librarian)
- **Profesión**: Guarda y comparte conocimiento
- **Enseña sobre**: Importancia de la lectura, preservación del conocimiento
- **Comercia**: Libros, papel

#### 🎓 Maestro (Teacher)
- **Profesión**: Educador de ciencias y valores
- **Enseña sobre**: Compasión animal, ciencia, pensamiento crítico
- **Comercia**: Libros educativos, papel

#### 🗺️ Explorador (Explorer)
- **Profesión**: Viajero y estudioso de biomas
- **Enseña sobre**: Biodiversidad, ecosistemas, conservación
- **Comercia**: Manzanas, palos (recursos de viajes)

---

## 🛠️ Comandos de Administración

### `/spawn_villager <tipo>`
**Privilegio requerido**: `server`

Spawea un aldeano en tu posición actual.

**Tipos válidos**:
- `farmer` - Agricultor
- `librarian` - Bibliotecario
- `teacher` - Maestro
- `explorer` - Explorador

**Ejemplo**:
```
/spawn_villager farmer
```

### `/villager_info`
**Privilegio requerido**: Ninguno

Muestra información sobre el sistema de aldeanos.

---

## ⚙️ Configuración (minetest.conf)

```ini
# Número máximo de aldeanos por área (default: 5)
custom_villagers_max_villagers = 5

# Radio de spawn natural (default: 20)
custom_villagers_spawn_radius = 20

# Habilitar modo debug (default: false)
custom_villagers_debug = false

# Habilitar sistema de comercio (default: true)
custom_villagers_enable_trading = true

# Habilitar horarios/rutinas (default: true)
custom_villagers_enable_schedules = true
```

---

## 📦 Instalación

### Opción 1: Desarrollo Local y Git Push (Recomendado)

```bash
# 1. Navegar al directorio de mods
cd /home/gabriel/Documentos/luanti-voxelibre-server/server/mods/

# 2. El mod ya está creado en custom_villagers/

# 3. Agregar texturas (ver sección Texturas)

# 4. Commit y push
cd /home/gabriel/Documentos/luanti-voxelibre-server/
git add server/mods/custom_villagers/
git commit -m "🏘️ Add: Custom Villagers mod v1.0.0 - Interactive NPCs with dialogue and trading"
git push origin main
```

### Opción 2: Deployment en VPS

```bash
# 1. SSH al VPS
ssh gabriel@167.172.251.27

# 2. Pull cambios
cd /home/gabriel/luanti-voxelibre-server
git pull origin main

# 3. Habilitar mod en world.mt
docker-compose exec -T luanti-server sh -c 'echo "load_mod_custom_villagers = true" >> /config/.minetest/worlds/world/world.mt'

# 4. Reiniciar servidor
docker-compose restart luanti-server

# 5. Verificar logs
docker-compose logs --tail=30 luanti-server | grep custom_villagers
```

---

## 🎨 Texturas

El mod utiliza texturas en formato **cube** (6 caras). Debes crear imágenes PNG de 16x16 o 32x32 píxeles para cada cara de cada tipo de aldeano.

### Archivos de Textura Requeridos

#### Agricultor (Farmer)
- `custom_villagers_farmer_top.png` - Parte superior (sombrero/cabello)
- `custom_villagers_farmer_bottom.png` - Parte inferior (pies)
- `custom_villagers_farmer_side.png` - Lados (brazos)
- `custom_villagers_farmer_front.png` - Frente (cara)
- `custom_villagers_farmer_back.png` - Espalda

#### Bibliotecario (Librarian)
- `custom_villagers_librarian_top.png`
- `custom_villagers_librarian_bottom.png`
- `custom_villagers_librarian_side.png`
- `custom_villagers_librarian_front.png`
- `custom_villagers_librarian_back.png`

#### Maestro (Teacher)
- `custom_villagers_teacher_top.png`
- `custom_villagers_teacher_bottom.png`
- `custom_villagers_teacher_side.png`
- `custom_villagers_teacher_front.png`
- `custom_villagers_teacher_back.png`

#### Explorador (Explorer)
- `custom_villagers_explorer_top.png`
- `custom_villagers_explorer_bottom.png`
- `custom_villagers_explorer_side.png`
- `custom_villagers_explorer_front.png`
- `custom_villagers_explorer_back.png`

### Ubicación de Texturas
```
server/mods/custom_villagers/textures/
```

### Texturas Placeholder (Desarrollo)

Si no tienes texturas listas, puedes crear **placeholders de colores sólidos** temporales:

**Agricultor**: Verde (#4CAF50)
**Bibliotecario**: Azul (#2196F3)
**Maestro**: Morado (#9C27B0)
**Explorador**: Marrón (#795548)

---

## 🔧 Arquitectura Técnica

### Estructura de Archivos
```
custom_villagers/
├── mod.conf              # Configuración del mod
├── init.lua              # Código principal (todo-in-one)
├── textures/             # Texturas PNG
├── sounds/               # Efectos de sonido (futuro)
├── locale/               # Traducciones (futuro)
└── README.md             # Esta documentación
```

### Sistemas Implementados

1. **Sistema de Diálogos**
   - Base de datos `custom_villagers.dialogues` con mensajes contextuales
   - Categorías: `greetings`, `about_work`, `education`
   - Selección aleatoria de mensajes para variedad

2. **Sistema de Comercio**
   - Base de datos `custom_villagers.trades` con ofertas por tipo
   - Formspecs interactivos para UI de comercio
   - Validación de inventario antes de transacción

3. **Sistema de Entidades**
   - Usa `minetest.register_entity()` para control total
   - Estados: `idle`, `walking`, `sleeping`
   - Pathfinding básico con límite de radio desde hogar

4. **Sistema de Horarios**
   - Verifica `minetest.get_timeofday()`
   - Aldeanos duermen de noche (0.8 - 0.2)
   - Retoman actividades de día

---

## 🚀 Mejoras Futuras (Roadmap)

### Versión 1.1
- [ ] Modelos 3D con animaciones (meshes .b3d)
- [ ] Sonidos de voz/ambiente
- [ ] Más tipos de aldeanos (artesano, cocinero)

### Versión 1.2
- [ ] Sistema de reputación con aldeanos
- [ ] Misiones/quests educativas
- [ ] Aldeanos pueden construir/modificar su entorno

### Versión 2.0
- [ ] Integración con mcl_mobs para AI avanzada
- [ ] Spawn natural en estructuras de aldeas
- [ ] Sistema de comunidad (relaciones entre aldeanos)

---

## 🐛 Troubleshooting

### Problema: Aldeanos no aparecen

**Causa**: Mod no habilitado en world.mt

**Solución**:
```bash
docker-compose exec -T luanti-server sh -c 'echo "load_mod_custom_villagers = true" >> /config/.minetest/worlds/world/world.mt'
docker-compose restart luanti-server
```

### Problema: Texturas faltantes (cubos negros/blancos)

**Causa**: Archivos de textura no encontrados

**Solución**:
1. Verificar que las texturas estén en `server/mods/custom_villagers/textures/`
2. Verificar nombres de archivos exactos (case-sensitive)
3. Crear placeholders temporales si es necesario

### Problema: Comandos no funcionan

**Causa**: Privilegios insuficientes

**Solución**:
```bash
# Dar privilegios de server a un jugador
/grant <nombre_jugador> server
```

---

## 📚 Documentación Relacionada

- [Guía de Desarrollo de Mods Wetlands](../../docs/mods/MODDING_GUIDE.md)
- [Sistema VoxeLibre Mod](../../docs/VOXELIBRE_MOD_SYSTEM.md)
- [Documentación Luanti API](https://api.luanti.org/)

---

## 🤝 Contribución

Este mod es parte del ecosistema Wetlands. Para contribuir:

1. **Reporte bugs** en GitHub Issues
2. **Sugiere mejoras** en Discussions
3. **Envía PR** con nuevas características
4. **Comparte texturas/modelos** comunitarios

---

## 📄 Licencia

GPL v3 - Software Libre

---

## 🌟 Créditos

- **Desarrollo**: Wetlands Team + Claude Code
- **Concepto**: Servidor educativo compasivo Wetlands
- **Motor**: Luanti (Minetest) + VoxeLibre
- **Inspiración**: Minecraft Villagers (reimaginado para educación compasiva)

---

**¡Gracias por usar Custom Villagers!** 🏘️💚
