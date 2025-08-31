# 📖 Guía de Desarrollo de Mods

Esta guía contiene toda la información técnica necesaria para desarrollar, modificar y mantener mods para el servidor Vegan Wetlands. Está dirigida a programadores familiarizados con Lua y el entorno de Minetest/Luanti.

---

## 1. Filosofía de Desarrollo

Todo mod desarrollado para este servidor debe adherirse a tres principios básicos:

1.  **Compasivo y Pacífico:** El código no debe incluir mecánicas de violencia, caza o explotación animal. El foco es el cuidado, la protección y la cooperación.
2.  **Educativo:** Cada mod debe tener un componente de aprendizaje, ya sea sobre compasión, sostenibilidad o habilidades técnicas como la programación.
3.  **Rendimiento y Calidad:** El código debe ser limpio, eficiente y estar bien documentado para asegurar la estabilidad del servidor y facilitar futuras colaboraciones.

---

## 2. Arquitectura de Mods para VoxeLibre (¡Crítico!)

Nuestra base es VoxeLibre (MineClone2), que tiene una forma muy específica de gestionar los mods. Ignorar esto es la causa número 1 de fallos.

**La Regla de Oro:** VoxeLibre ignora el directorio `/mods` estándar. Solo carga mods desde su propia estructura de carpetas categorizadas.

### 2.1. Estructura de Directorios y Mapeo en Docker

Para que un mod cargue, su carpeta debe ser mapeada en `docker-compose.yml` a la categoría correcta dentro de `/config/.minetest/games/mineclone2/mods/`.

**Ejemplo de `docker-compose.yml`:**
```yaml
services:
  luanti-server:
    volumes:
      # Mapeo de mods a sus categorías correctas en VoxeLibre:
      - ./server/mods/vegan_foods:/config/.minetest/games/mineclone2/mods/ITEMS/vegan_foods
      - ./server/mods/animal_sanctuary:/config/.minetest/games/mineclone2/mods/ENTITIES/animal_sanctuary
      - ./server/mods/education_blocks:/config/.minetest/games/mineclone2/mods/HELP/education_blocks
```

**Categorías Comunes:**
*   `ITEMS`: Comida, herramientas, bloques crafteables.
*   `ENTITIES`: Animales, NPCs, mobs pacíficos.
*   `HELP`: Mods educativos, guías.
*   `CORE`: Funcionalidad central.

### 2.2. Dependencias y API de VoxeLibre (`mcl_*`)

Dentro del código de tus mods, **nunca** debes usar las dependencias del juego base de Minetest (`default`, `farming`, etc.). Debes usar los paquetes de VoxeLibre, que casi siempre empiezan con `mcl_`.

**Ejemplos de Conversión:**

| Luanti Estándar (Incorrecto) | VoxeLibre (Correcto) |
|---|---|
| `depends = default, farming` | `depends = mcl_core, mcl_farming` |
| `default:apple` | `mcl_core:apple` |
| `default.node_sound_wood_defaults()` | `mcl_sounds.node_sound_wood_defaults()` |
| `bucket:bucket_water` | `mcl_buckets:bucket_water` |

---

## 3. Mods Actuales (Como Referencia)

### 🐾 `animal_sanctuary`
*   **Categoría:** `ENTITIES`
*   **Funcionalidad:** Reemplaza las mecánicas de violencia por herramientas de cuidado (cepillos, kits médicos). Introduce el concepto de santuario.
*   **Comandos:** `/santuario`, `/filosofia`.

### 🍎 `vegan_foods`
*   **Categoría:** `ITEMS`
*   **Funcionalidad:** Añade recetas para craftear comida a base de plantas nutritiva usando ingredientes del mod de agricultura de VoxeLibre.
*   **Dependencias:** `mcl_core`, `mcl_farming`.

### 📚 `education_blocks`
*   **Categoría:** `HELP`
*   **Funcionalidad:** Provee bloques interactivos que muestran mensajes educativos sobre alimentación consciente, nutrición y respeto animal al ser usados.

---

## 4. Plan de Desarrollo Futuro (Roadmap)

Buscamos contribuciones en las siguientes áreas. ¡Elige una y empieza a programar!

### Prioridad Alta:
1.  **`animal_sanctuary_v2`:** Sistema avanzado de rescate y adopción de animales, con seguimiento individual de su bienestar.
2.  **`compassion_system`:** Un sistema de puntos y rangos que recompense a los jugadores por realizar actos compasivos (cuidar animales, plantar árboles, ayudar a otros).
3.  **`coding_blocks`:** ¡El más ambicioso! Un mod de programación visual tipo Scratch para que los niños aprendan lógica de programación controlando robots o eventos en el juego.
4.  **`robot_companion`:** Un robot programable que sigue al jugador y puede ser controlado con los `coding_blocks` para realizar tareas de agricultura o construcción.

### Prioridad Media:
*   **`climate_science`:** Mods que enseñen sobre el cambio climático y el impacto positivo de una alimentación consciente.
*   **`sustainable_farming`:** Introducir conceptos de permacultura, compostaje y agricultura sostenible.
*   **`community_projects`:** Mecánicas que incentiven la construcción de grandes proyectos en equipo.

---

## 5. Convenciones y Buenas Prácticas

*   **Idioma:** Todo el texto visible para el jugador (descripciones, mensajes de chat) y los comentarios en el código deben estar en **español**.
*   **Nomenclatura:**
    *   Variables y funciones: `snake_case` (ej: `cuidar_animal`).
    *   Nombres de items y nodos: `modname:item_name` (ej: `animal_sanctuary:cepillo_animales`).
*   **Estructura de Archivos:** Sigue la estructura estándar de mods de Minetest (`mod.conf`, `init.lua`, `textures/`, `sounds/`, etc.).
*   **Logging:** Usa `minetest.log("action", "[NombreMod] Mensaje de log.")` para registrar acciones importantes que ayuden a depurar.
*   **Git:** Usa commits descriptivos y claros.