# Guia de Integracion - Wetlands NPCs

**Mod**: wetlands_npcs v1.0.0
**Servidor**: Wetlands VoxeLibre
**Ultima actualizacion**: Febrero 2026

---

## Requisitos

- Luanti 5.4.0+
- VoxeLibre (MineClone2) v0.90.1+
- Mods disponibles: mcl_core, mcl_mobs, mcl_farming, mcl_books

---

## Deployment

### 1. Habilitar el mod

**luanti.conf** (ya configurado en el repo):
```ini
load_mod_wetlands_npcs = true
```

**world.mt en VPS** (ambos: host y contenedor):
```bash
ssh gabriel@167.172.251.27 "echo 'load_mod_wetlands_npcs = true' >> /home/gabriel/luanti-voxelibre-server/server/worlds/world/world.mt"
ssh gabriel@167.172.251.27 "docker exec luanti-voxelibre-server sh -c 'echo \"load_mod_wetlands_npcs = true\" >> /config/.minetest/worlds/world/world.mt'"
```

### 2. Push y deploy

```bash
git push origin main
ssh gabriel@167.172.251.27 "cd /home/gabriel/luanti-voxelibre-server && git pull origin main"
ssh gabriel@167.172.251.27 "cd /home/gabriel/luanti-voxelibre-server && docker-compose restart luanti-server"
```

### 3. Verificar

```bash
ssh gabriel@167.172.251.27 "docker logs --since='2m' luanti-voxelibre-server 2>&1 | grep wetlands_npcs"
```

**Salida esperada**:
```
[wetlands_npcs] Configuration loaded and validated successfully
[wetlands_npcs] AI Behaviors system v1.0.0 loaded successfully
[wetlands_npcs] Wetlands NPCs v1.0.0 loaded successfully!
[wetlands_npcs] 8 NPCs: Luke, Anakin, Yoda, Mandalorian + Farmer, Librarian, Teacher, Explorer
```

---

## Testing en el Juego

### Spawnear NPCs

```
/spawn_npc luke
/spawn_npc anakin
/spawn_npc yoda
/spawn_npc mandalorian
/spawn_npc farmer
/spawn_npc librarian
/spawn_npc teacher
/spawn_npc explorer
```

Requiere privilegio `server`.

### Verificar funcionalidad

- [ ] NPCs aparecen con texturas correctas
- [ ] Star Wars: pose de jugador (brazos a los lados)
- [ ] Clasicos: pose de villager (brazos cruzados)
- [ ] Click derecho abre menu de interaccion
- [ ] Dialogos funcionan (Saludar, Trabajo, Educacion)
- [ ] Comercio funciona (esmeraldas)
- [ ] Voces suenan al interactuar
- [ ] NPCs caminan y tienen comportamiento AI
- [ ] NPCs son inmortales (no se pueden matar)

---

## Sistema de Texturas

### Star Wars (modelo jugador)

| Paso | Detalle |
|------|---------|
| Fuente | MinecraftSkins.com |
| Formato original | 64x64 px (Minecraft 1.8+) |
| Formato requerido | **64x32 px** (crop mitad superior) |
| Modelo 3D | `wetlands_npc_human.b3d` (= mcl_armor_character.b3d) |
| Capas textura | 3: {skin.png, blank.png, blank.png} |

**Conversion**:
```python
from PIL import Image
img = Image.open('raw_skin_64x64.png')
img.crop((0, 0, 64, 32)).save('wetlands_npc_nombre.png', 'PNG')
```

### Clasicos (modelo villager)

| Paso | Detalle |
|------|---------|
| Fuente | Recolor de textura base VoxeLibre |
| Formato | 64x64 px (UV villager Minecraft) |
| Modelo 3D | `mobs_mc_villager.b3d` (de VoxeLibre) |
| Herramienta | `tools/generate_textures.py` |

**NUNCA dibujar texturas villager desde cero** - el UV map del villager es complejo.
Siempre recolorear la base: `server/games/mineclone2/textures/mobs_mc_villager.png`

---

## Troubleshooting

### NPCs Star Wars se ven distorsionados
**Causa**: Textura 64x64 sin convertir a 64x32.
**Solucion**: Convertir con PIL crop o convertidor online.

### NPCs aparecen como cubos negros
**Causa**: Textura faltante o nombre incorrecto.
**Verificar**: `ls server/mods/wetlands_npcs/textures/wetlands_npc_*.png`

### Mod no carga
**Verificar**:
1. `load_mod_wetlands_npcs = true` en luanti.conf
2. `load_mod_wetlands_npcs = true` en world.mt (host + contenedor)
3. Logs: `docker logs --since='2m' luanti-voxelibre-server 2>&1 | grep -i error`

### Voces no suenan
**Verificar**: Archivos OGG en `sounds/` con formato `wetlands_npc_greet_<tipo>1.ogg`

### Entidades legacy (custom_villagers:*)
El mod registra entidades de migracion para el nombre antiguo `custom_villagers`.
Los NPCs spawneados con el nombre viejo se auto-reemplazan al cargar el mundo.

---

**Mantenedor**: Wetlands Team
**Repositorio**: github.com/gabrielpantoja-cl/luanti-voxelibre-server
