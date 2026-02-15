# Registro de NPCs - Wetlands Server

> Documento de control para el spawn manual y ubicacion de cada NPC del servidor.
> Cada NPC se coloca manualmente con `/spawn_npc <tipo>` y se documenta aqui.

**Ultima actualizacion**: 2026-02-15
**Version del mod**: wetlands_npcs v2.0.0 (11 NPCs registrados)
**Spawn del mundo**: (0, 15, 0)

---

## NPCs Colocados

| # | NPC | Tipo | Modelo | Coordenadas | Zona | Fecha | Estado |
|---|-----|------|--------|-------------|------|-------|--------|
| 1 | Sensei Wu | sensei_wu | humano (64x32) | (-0.4, 14.5, -6.4) | Spawn principal | 2026-02-15 | Activo |
| 2 | Maestro Splinter | splinter | humano (64x32) | pendiente | Spawn principal | - | Por colocar |
| 3 | Luke Skywalker | luke | humano (64x32) | pendiente | - | - | Por colocar |
| 4 | Anakin Skywalker | anakin | humano (64x32) | pendiente | - | - | Por colocar |
| 5 | Baby Yoda | yoda | humano (64x32) | pendiente | - | - | Por colocar |
| 6 | Mandalorian | mandalorian | humano (64x32) | pendiente | - | - | Por colocar |
| 7 | Princess Leia | leia | humano (64x32) | pendiente | - | - | Por colocar |
| 8 | Agricultor | farmer | villager (64x64) | pendiente | - | - | Por colocar |
| 9 | Bibliotecario | librarian | villager (64x64) | pendiente | - | - | Por colocar |
| 10 | Maestro | teacher | villager (64x64) | pendiente | - | - | Por colocar |
| 11 | Explorador | explorer | villager (64x64) | pendiente | - | - | Por colocar |

---

## Descripcion de Personajes

### Sabios del Spawn (NPCs estaticos, punto fijo)

**Sensei Wu** - Maestro ninja de Ninjago. Sabio anciano con tunica dorada y negra. Entreno a Kai, Jay, Zane, Cole y Lloyd. Ofrece sabiduria sobre disciplina, trabajo en equipo y honor. Comportamiento: 50% idle, casi no se mueve. Ubicacion: spawn principal.

**Maestro Splinter** - Rata sensei de las Tortugas Ninja (TMNT). Maestro de artes marciales que ensena compasion y disciplina. Entreno a Leonardo, Rafael, Donatello y Miguel Angel. Comportamiento: 55% idle, casi no se mueve. Ubicacion: spawn principal, junto a Sensei Wu.

### Star Wars (NPCs con modelo humano)

**Luke Skywalker** - Caballero Jedi. Heroe de la Alianza Rebelde. Ensena sobre el lado luminoso de la Fuerza, valentía y esperanza.

**Anakin Skywalker** - Piloto legendario y Jedi. El "Elegido" de la profecia. Ensena sobre las consecuencias de las decisiones y la redencion.

**Baby Yoda (Grogu)** - Pequeno ser poderoso en la Fuerza. Contemplativo y misterioso. Ensena sobre paciencia y el poder interior.

**Mandalorian (Din Djarin)** - Cazarrecompensas con armadura de beskar. Protector de Grogu. Ensena sobre lealtad, honor y proteger a los debiles.

**Princess Leia** - Lider de la Rebelion. Diplomatica y valiente. Ensena sobre liderazgo, diplomacia y luchar por la justicia.

### Clasicos (NPCs con modelo villager)

**Agricultor** - Cultiva vegetales y alimentos. Ensena sobre agricultura sostenible y nutricion vegetal.

**Bibliotecario** - Guarda y comparte conocimiento. Ensena sobre la importancia de la lectura y la educacion.

**Maestro** - Educador de ciencia y compasion. Ensena sobre respeto animal, ciencia y naturaleza.

**Explorador** - Viajero y estudioso de biomas. Ensena sobre biodiversidad y conservacion ambiental.

---

## Sistema de Comportamiento

Todos los NPCs tienen el sistema de **home tether**:
- Se mueven dentro de un radio de **15 bloques** desde donde fueron spawneados
- Si se alejan mas de **20 bloques**, se fuerza el retorno
- Los sabios del spawn (Splinter, Wu) tienen 50-55% idle = casi estaticos

---

## Proceso de Limpieza (2026-02-15)

### Problema
El servidor tenia **75 NPCs duplicados** por spawns manuales sin control previo.

### Acciones realizadas
1. Se agrego comando `/npc_removeall confirm` para eliminacion masiva
2. Se agrego sistema **home tether** para evitar drift de NPCs
3. Primera limpieza: 16 NPCs eliminados (zona de juego activa)
4. Segunda limpieza: 25 NPCs eliminados (zona spawn, ampliando radio)
5. Tercera verificacion: "No hay NPCs de Wetlands en zonas activas"
6. Scan de map.sqlite: 0 NPCs encontrados en 2,257,422 mapblocks

### Zona pendiente de verificar
- **Far West** (-1770, 3, 902): Nueva Ciudad. Puede tener NPCs remanentes.
  - Comando: `/teleport gabo -1770 20 930`
  - Verificar: `/npc_census`
  - Limpiar: `/npc_removeall confirm`

### Total eliminados: ~41 NPCs

---

## Comandos de Referencia

```
/spawn_npc <tipo>        -- Spawnear NPC en tu posicion
/npc_removeall confirm   -- Eliminar TODOS los NPCs
/npc_remove [radio]      -- Eliminar el NPC mas cercano
/npc_census              -- Contar NPCs activos
/npc_cleanup confirm     -- Eliminar duplicados (deja 1 por tipo)
/npc_info                -- Lista de NPCs disponibles
```

---

## Skins Disponibles (sin usar)

Estos skins estan en `raw_skins/` listos para convertir y registrar como NPCs futuros:

| Skin | Archivo | Descripcion |
|------|---------|-------------|
| Darth Vader | raw_darth_vader.png | Villano Star Wars |
| Obi-Wan Kenobi | raw_obiwan_kenobi.png | Maestro Jedi |
| Ancient Druid | raw_ancient_druid.png | Druida anciano |
| Forest Druid Gerald | raw_forest_druid_gerald.png | Druida del bosque |
| Medieval Merchant Girl | raw_medieval_merchant_girl.png | Mercader medieval |
| Merlin Wizard | raw_merlin_wizard.png | Mago Merlin |
| Ophelia Merchant | raw_ophelia_merchant.png | Mercader Ophelia |

**IMPORTANTE**: Al convertir skins 64x64 a 64x32, usar composite de overlay layers, NO crop simple. Ver script en `tools/generate_textures.py`.
