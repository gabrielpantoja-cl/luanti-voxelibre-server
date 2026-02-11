# Wetlands NPCs - Documentacion

**Mod**: wetlands_npcs v1.0.0
**Servidor**: Wetlands (luanti.gabrielpantoja.cl:30000)
**Ultima actualizacion**: Febrero 2026

---

## NPCs Disponibles

### Star Wars (modelo jugador - mcl_armor_character.b3d)

| NPC | Textura | Formato | Descripcion |
|-----|---------|---------|-------------|
| Luke Skywalker | wetlands_npc_luke.png | 64x32 | Caballero Jedi |
| Anakin Skywalker | wetlands_npc_anakin.png | 64x32 | Jedi de las Guerras Clon |
| Baby Yoda | wetlands_npc_yoda.png | 64x32 | Grogu, pequenio y poderoso |
| Mandalorian | wetlands_npc_mandalorian.png | 64x32 | Din Djarin, cazarrecompensas |

### Clasicos (modelo villager - mobs_mc_villager.b3d)

| NPC | Textura | Formato | Descripcion |
|-----|---------|---------|-------------|
| Agricultor | wetlands_npc_farmer.png | 64x64 | Cultiva vegetales |
| Bibliotecaria | wetlands_npc_librarian.png | 64x64 | Comparte libros |
| Profesora | wetlands_npc_teacher.png | 64x64 | Educacion compasiva |
| Explorador | wetlands_npc_explorer.png | 64x64 | Aventuras y naturaleza |

---

## Sistema de Modelos y Texturas

El mod usa **dos modelos distintos** segun el tipo de NPC:

### Modelo Jugador (Star Wars)
- **Archivo**: `models/wetlands_npc_human.b3d` (copia de `mcl_armor_character.b3d`)
- **Texturas**: 64x32 px (formato player skin de VoxeLibre)
- **Capas**: 3 (skin + blank + blank). Solo la primera capa tiene textura.
- **Pose**: Brazos a los lados, animaciones completas (stand, walk, run, sit)
- **Origen skins**: MinecraftSkins.com, convertidos de 64x64 a 64x32

### Modelo Villager (Clasicos)
- **Archivo**: `mobs_mc_villager.b3d` (modelo de VoxeLibre)
- **Texturas**: 64x64 px (UV villager de Minecraft)
- **Pose**: Brazos cruzados, animaciones basicas (stand, walk)
- **Origen texturas**: Recoloreadas desde la textura base de VoxeLibre

### Conversion de skins de Minecraft

Las skins descargadas de MinecraftSkins.com vienen en formato **64x64** (Minecraft 1.8+).
VoxeLibre usa formato **64x32** para el modelo del jugador. Se debe convertir:

```python
from PIL import Image
img = Image.open('skin_64x64.png')
cropped = img.crop((0, 0, 64, 32))
cropped.save('skin_64x32.png', 'PNG')
```

Tambien puede usarse el convertidor online: https://godly.github.io/minetest-skin-converter/

**IMPORTANTE**: Las skins 64x64 sin convertir se ven distorsionadas en el modelo del jugador.

---

## Comandos

| Comando | Privilegio | Descripcion |
|---------|-----------|-------------|
| `/spawn_npc <tipo>` | server | Spawnea un NPC |
| `/spawn_villager <tipo>` | server | Alias de spawn_npc |

**Tipos disponibles**: luke, anakin, yoda, mandalorian, farmer, librarian, teacher, explorer

---

## Estructura del Mod

```
wetlands_npcs/
├── mod.conf                    # Configuracion del mod
├── init.lua                    # Logica principal (NPCs, dialogos, comercio)
├── config.lua                  # Sistema de configuracion centralizado
├── ai_behaviors.lua            # Sistema AI (FSM con 6 estados)
├── models/
│   └── wetlands_npc_human.b3d  # Modelo jugador (Star Wars NPCs)
├── textures/
│   ├── wetlands_npc_luke.png       # 64x32 - Luke Skywalker
│   ├── wetlands_npc_anakin.png     # 64x32 - Anakin Skywalker
│   ├── wetlands_npc_yoda.png       # 64x32 - Baby Yoda
│   ├── wetlands_npc_mandalorian.png # 64x32 - Mandalorian
│   ├── wetlands_npc_farmer.png     # 64x64 - Agricultor
│   ├── wetlands_npc_librarian.png  # 64x64 - Bibliotecaria
│   ├── wetlands_npc_teacher.png    # 64x64 - Profesora
│   ├── wetlands_npc_explorer.png   # 64x64 - Explorador
│   └── raw_skins/                  # Skins originales sin convertir
├── sounds/                     # Voces OGG (greet + talk por NPC)
├── tools/
│   ├── generate_textures.py    # Generador de texturas villager
│   └── generate_sounds.py      # Generador de voces TTS
├── docs/
│   ├── INDEX.md                # Este archivo
│   ├── AI_BEHAVIORS.md         # Documentacion del sistema AI
│   ├── INTEGRATION_GUIDE.md    # Guia de deployment
│   ├── CHANGELOG.md            # Historial de cambios
│   ├── CRASH_FIX_PATCH.md      # Parche de crash fix v1.0.1
│   ├── DEPLOYMENT_NOTES_v2.1.1.md # Notas de deployment v2.1.1
│   ├── MIGRATION_NOTES.md      # Notas de migracion custom_villagers -> wetlands_npcs
│   ├── README_MEJORAS.md       # Ideas de mejoras
│   ├── TESTING_GUIDE.md        # Guia de testing
│   ├── TODO.md                 # Tareas pendientes
│   └── VOICE_MAP.md            # Mapa de voces por NPC
└── locale/
    └── template.txt            # Traducciones
```

---

## Guias Disponibles

### [AI_BEHAVIORS.md](AI_BEHAVIORS.md)
Sistema de inteligencia artificial: FSM con 6 estados, pathfinding, saludos automaticos, rutinas dia/noche.

### [INTEGRATION_GUIDE.md](INTEGRATION_GUIDE.md)
Guia paso a paso para deployment, verificacion y troubleshooting.

### [CHANGELOG.md](CHANGELOG.md)
Historial de cambios del mod.

### [MIGRATION_NOTES.md](MIGRATION_NOTES.md)
Notas de migracion desde custom_villagers a wetlands_npcs.

### [TESTING_GUIDE.md](TESTING_GUIDE.md)
Guia de testing manual en el servidor.

### [VOICE_MAP.md](VOICE_MAP.md)
Mapa de archivos de voz por NPC.

### [TODO.md](TODO.md)
Tareas pendientes y mejoras planificadas.

### [CRASH_FIX_PATCH.md](CRASH_FIX_PATCH.md)
Documentacion del parche de crash fix v1.0.1.

### [DEPLOYMENT_NOTES_v2.1.1.md](DEPLOYMENT_NOTES_v2.1.1.md)
Notas de deployment version 2.1.1.

### [README_MEJORAS.md](README_MEJORAS.md)
Ideas y propuestas de mejoras.

---

## Agregar Nuevos NPCs Star Wars

1. **Descargar skin** de MinecraftSkins.com (64x64)
2. **Guardar raw skin** en `textures/raw_skins/raw_nombre.png`
3. **Convertir a 64x32**: crop mitad superior con PIL o convertidor online
4. **Guardar como** `textures/wetlands_npc_nombre.png`
5. **Agregar en init.lua**:
   - Dialogos en `wetlands_npcs.dialogues`
   - Trades en `wetlands_npcs.trades`
   - Display name en `wetlands_npcs.display_names`
   - Registro: `register_npc("nombre", { description = S("Nombre"), textures = {{"wetlands_npc_nombre.png"}} })`
6. **Agregar sonidos** en `sounds/` (wetlands_npc_greet_nombre1.ogg, etc.)

## Agregar Nuevos NPCs Clasicos (villager)

1. **Recolorear** la textura base del villager (64x64) con `tools/generate_textures.py`
2. **Guardar como** `textures/wetlands_npc_nombre.png`
3. **Agregar en init.lua** usando `register_classic_npc()`

---

**Mantenedor**: Wetlands Team
**Licencia**: GPL v3
