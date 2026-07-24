# 🌱 Filosofía Plant-Based de Wetlands

**Última Actualización**: 2026-07-24
**Estado**: ✅ Documento oficial — describe el compromiso plant-based del servidor Wetlands
**Propósito**: Ser la fuente única de verdad sobre qué significa "plant-based" en Wetlands, qué lo implementa, y qué se mantiene igual por decisión consciente.

---

## 📋 TL;DR

Wetlands es un servidor **compassivo y plant-based** en Luanti (puerto 30000). Esto significa:

1. **Items de origen animal reemplazados** — 13 items como carne cruda, carne cocida, cuero, etc. están eliminados del juego y reemplazados automáticamente con alternativas vegetales (manzana, papa, etc.).
2. **Recetas plant-based disponibles** — Tofu, seitan, "notfish" (filete vegetal), leche de plantas, siropes — todo crafteable in-game.
3. **Educación activa** — Mod educativo con bloques y comandos sobre compasión y sostenibilidad.
4. **Transparencia sobre lo que NO se cambió** — los mobs animales y hostiles siguen spawneando (decisión consciente para no romper el gameplay).

---

## 🤔 ¿Por qué "compassivo y plant-based" (no "vegano radical")?

Decidimos un enfoque **suave y transparente**:

- **El servidor es plant-based por diseño de mods**, no por restricciones de gameplay absolutas.
- **No escondemos que hay mobs animales** — siguen en el mundo. Lo que cambia es lo que *puedes obtener* de ellos.
- **El branding es informativo**, no militante. Decimos "compassivo y plant-based" en vez de "100% libre de crueldad" porque eso último no sería verdad.

Si querés un servidor 100% vegano radical (sin mobs animales, sin hostiles), eso es un proyecto distinto. Acá en Wetlands somos **creativos, familiares, y plant-based dentro de lo razonable**.

---

## 🔧 Implementación técnica

### Mods que hacen el trabajo pesado

| Mod | Qué hace |
|---|---|
| `vegan_food` | Registra ~13 items plant-based: tofu, seitan (raw/cooked), seitan_stew, notfish (raw/cooked), plant milk, siropes (apple/flower), y agrupa items vegetales (`food_plant_milk`, `gluten_source`, `milkable_plant`, `vegan_soup`) para que las recetas de VoxeLibre los usen |
| `vegan_replacements` | **El mod crítico**. Sobrescribe la definición de 13 items `mcl_mobitems:*` (carne cruda, carne cocida, cuero, estofado de conejo) para que aparezcan como "Item No Vegano - Eliminado" en inventario, intercepta el comando `/give` para reemplazarlos automáticamente, y modifica los drops de entidades hostiles (zombie, piglin, horse) |
| `education_blocks` | Bloques y comandos con mensajes sobre compasión y sostenibilidad (menciona `vegan_food` como ejemplo) |
| `wetlands_no_creeper` | Bloquea creepers para mantener la paz nocturna (los creepers destruyen bloques — contrario al espíritu compasivo) |
| `automobiles_pck` (con `vegan_food`) | Los vehículos usan `cooking_oil` plant-based como combustible (en vez de combustible animal) |

### Cómo se interceptan los items no veganos

`vegan_replacements` (en `server/mods/vegan_replacements/init.lua`) hace 4 cosas:

1. **`override_item()`** en cada item no vegano: cambia su inventario a blank, lo marca como `not_in_creative_inventory`, y muestra "🌱 Item no vegano eliminado" si alguien intenta usarlo.
2. **`register_on_chatcommand`**: cuando alguien hace `/give <jugador> mcl_mobitems:beef`, el mod intercepta y da una papa (`mcl_farming:potato_item`) en su lugar.
3. **`register_on_item_eat`**: si alguien logra tener un item no vegano e intenta comerlo, se cancela el consumo y se le da la alternativa vegana.
4. **Modificación de drops de entidades**: `mobs_mc:zombie`, `mobs_mc:villager_zombie`, `mobs_mc:piglin`, `mobs_mc:horse` — sus drops problemáticos se reemplazan con vegetales.

### Tabla de reemplazos completa

| Item original (no vegano) | → Reemplazo plant-based |
|---|---|
| `mcl_mobitems:rotten_flesh` | `mcl_core:apple` |
| `mcl_mobitems:mutton` | `mcl_farming:potato_item` |
| `mcl_mobitems:beef` | `mcl_farming:carrot_item` |
| `mcl_mobitems:chicken` | `mcl_farming:beetroot_item` |
| `mcl_mobitems:porkchop` | `mcl_farming:potato_item` |
| `mcl_mobitems:rabbit` | `mcl_farming:carrot_item` |
| `mcl_mobitems:cooked_mutton` | `mcl_farming:potato_item_baked` |
| `mcl_mobitems:cooked_beef` | `mcl_farming:carrot_item` |
| `mcl_mobitems:cooked_chicken` | `mcl_farming:beetroot_soup` |
| `mcl_mobitems:cooked_porkchop` | `mcl_farming:potato_item_baked` |
| `mcl_mobitems:cooked_rabbit` | `mcl_farming:carrot_item` |
| `mcl_mobitems:leather` | `mcl_core:paper` |
| `mcl_mobitems:leather_piece` | `mcl_core:paper` |
| `mcl_mobitems:rabbit_stew` | `mcl_farming:beetroot_soup` |

---

## ⚖️ Lo que SÍ se mantiene (decisión consciente)

Esto es importante para que no haya expectativas erróneas:

| Feature | Estado | Por qué |
|---|---|---|
| `mobs_spawn = true` | ✅ Activo | Mantener vida en el mundo (pollos, vacas, ovejas pastan) |
| `only_peaceful_mobs = false` | ✅ Activo | Mantener el ciclo día/noche con zombies/spiders de noche |
| `mcl_mob_cap_animal = 10` | ✅ Activo | Mobs animales siguen existiendo, pero sus drops están reemplazados |
| `mcl_mob_cap_hostile = 300` | ✅ Activo | Hostiles de noche (zombies, spiders), con drops reemplazados |
| `halloween_ghost` | ✅ Cargado | Variedad temática Halloween |
| `halloween_zombies` | ✅ Cargado | Variedad temática Halloween |
| `wetlands_supreme_zombie` | ✅ Cargado | Variedad temática Halloween |
| `mobs_griefing = false` | ✅ Activo | Mobs no destruyen bloques (incluyendo creepers vía `wetlands_no_creeper`) |
| `enable_pvp = false` | ✅ Activo | Sin PvP, coherente con la filosofía |

**Razón**: Preferimos que los jugadores experimenten el mundo completo de VoxeLibre (mobs, ciclo día/noche) sin que la filosofía plant-based sea una jaula. Los mods `vegan_replacements` y `vegan_food` se encargan de que la **experiencia del jugador** sea plant-based, aunque el ecosistema del mundo siga siendo "natural".

---

## 🎮 In-game: cómo experimentar el compromiso

Al entrar al servidor (cada vez, no solo la primera), el jugador recibe:

```
🌱 ¡Bienvenid@ a Wetlands!
   Servidor compassivo y plant-based.
   Construimos un mundo basado en plantas, sin items de origen animal.
   Tip: /reglas para las reglas, /veganinfo para ver los mods activos.
```

Comandos relacionados:

- `/reglas` — ve las reglas del servidor (regla 5 incluye el compromiso plant-based)
- `/r` — reglas rápidas ("1) No molestar 2) Nombre apropiado 3) Respeto 4) Chat limpio 5) Plant-based")
- `/veganinfo` — lista de mods plant-based activos con descripción de cada uno
- `/give <jugador> mcl_mobitems:beef 5` — el mod lo intercepta y da `mcl_farming:potato_item 5` (papa)
- Intentar comer un item no vegano (si lograste obtenerlo) — el mod cancela el consumo y da la alternativa

---

## 🌐 Para construir (recetas plant-based)

Con `vegan_food` instalado, podes craftear:

- **Tofu**: soja + agua (recipe plant-based clásica)
- **Seitan** (raw/cooked/stew): trigo glutenoso + agua
- **Notfish** (raw/cooked): alternativa vegetal al pescado
- **Plant milk**: leche de plantas (de soybeans, almonds, oats, etc.)
- **Apple syrup**, **flower syrup**: siropes dulces
- **Beetroot soup**, **potato baked**, etc. — vegetales clásicos de VoxeLibre ya disponibles

Para ver los grupos, ejecuta:
- `/veganinfo` — descripción general
- (No hay un comando para listar todas las recetas plant-based, pero `/veganinfo` menciona los mods)

---

## 🛠️ Para admins

- `secure.trusted_mods` en `luanti-original.conf` incluye: `animal_sanctuary,vegan_food,education_blocks,areas,vegan_replacements,home_teleport` (los mods veganos son de confianza)
- `/vegancheck <item>` — verifica si un item es vegano (admin)
- `/listveganbans` — lista los items no veganos eliminados (admin)
- Para debugging: `docker logs <container> | grep -i vegan`
- Para ver el código del mod: `server/mods/vegan_replacements/init.lua`
- Para ver la doc del mod: `server/mods/vegan_replacements/README.md`

---

## 🔗 Referencias cruzadas

- [`server/mods/vegan_replacements/README.md`](../../server/mods/vegan_replacements/README.md) — doc del mod
- [`server/mods/vegan_food/`](../../server/mods/vegan_food/) — mod de recetas plant-based
- [`server/mods/server_rules/init.lua`](../../server/mods/server_rules/init.lua) — reglas del servidor (regla 5 incluye plant-based)
- [`server/mods/wetlands_newplayer/init.lua`](../../server/mods/wetlands_newplayer/init.lua) — bienvenida + comando `/veganinfo`
- [`../00-SHARED/mods/MODDING_GUIDE.md`](../00-SHARED/mods/MODDING_GUIDE.md) — guía general de mods (jerarquía de config, mod.conf, etc.)
- [server_rules/init.lua línea 40-46](../../server/mods/server_rules/init.lua) — el texto exacto de la regla 5
- [Luanti/VoxeLibre en general](https://www.luanti.org/) — el motor de juego base

---

## 🤝 Cómo contribuir a la filosofía

- **Discutir**: Discord del servidor (link en la landing page), abrir un issue en este repo
- **Reportar items no veganos faltantes**: usar `scripts/find-non-vegan-items.sh` (existe como doc en `admin/CREATIVE_INVENTORY_MANAGEMENT.md`) o reportar manualmente
- **Proponer mejoras al mod**: editar `server/mods/vegan_replacements/init.lua` y abrir PR
- **Discutir la filosofía**: este doc es vivo, se puede editar

---

## 📜 Historial de cambios

- **2026-07-24**: Creación de este doc. Mensaje de bienvenida plant-based en cada join. Comando `/veganinfo` agregado. Regla 5 de `/reglas` actualizada. Branding suave en `luanti-original.conf` y landing page.
- **2025-12-07**: Mods `vegan_food`, `vegan_replacements`, `education_blocks` agregados al servidor (commit histórico — ver git log)
- **Wetlands initial**: Servidor lanzado con enfoque creativo + educativo + apto para niños (ver `README.md` principal)

---

> 🌱 "No pretendemos ser perfectos. Pretendemos ser mejores cada día — y dar a los jugadores herramientas para elegir."
