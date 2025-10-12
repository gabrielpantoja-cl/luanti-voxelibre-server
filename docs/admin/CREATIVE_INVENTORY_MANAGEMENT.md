# Guía de Gestión del Inventario Creativo - Servidor Wetlands

**Última actualización:** 10 de Octubre, 2025
**Propósito:** Controlar qué items aparecen en el inventario creativo para mantener la filosofía vegana y educativa del servidor

---

## 📋 Índice

1. [Introducción](#introducción)
2. [Conceptos Clave](#conceptos-clave)
3. [Cómo Ocultar Items](#cómo-ocultar-items)
4. [Items No Veganos a Ocultar](#items-no-veganos-a-ocultar)
5. [Items Exclusivos de Admin](#items-exclusivos-de-admin)
6. [Ejemplos Prácticos](#ejemplos-prácticos)
7. [Herramientas de Auditoría](#herramientas-de-auditoría)
8. [Mantenimiento](#mantenimiento)

---

## 🎯 Introducción

El inventario creativo en Wetlands debe reflejar nuestra filosofía:
- **Vegano**: Sin items de origen animal (carne, pescado, huevos, etc.)
- **Compasivo**: Sin armas, trampas o items violentos
- **Educativo**: Items que fomenten creatividad y aprendizaje
- **Apropiado para niños**: Sin contenido inadecuado

Esta guía explica cómo controlar qué items están disponibles en el inventario creativo.

---

## 🔑 Conceptos Clave

### 1. Grupos de Items (Groups)

En Luanti/VoxeLibre, cada item tiene "grupos" que definen sus propiedades:

```lua
minetest.register_node("3dforniture:toilet", {
    description = 'Toilet',
    groups = {cracky=3, not_in_creative_inventory=1},
    -- ...
})
```

**Grupos relevantes para control de inventario:**

| Grupo | Efecto | Uso |
|-------|--------|-----|
| `not_in_creative_inventory=1` | Oculta del inventario creativo | Ocultar items no deseados |
| `not_in_creative_inventory=0` | Visible en inventario creativo | Valor por defecto |

### 2. Estados de Items

**Item visible en creativo:**
```lua
groups = {cracky=3}  -- Sin not_in_creative_inventory
```

**Item oculto (solo admin puede dar):**
```lua
groups = {cracky=3, not_in_creative_inventory=1}
```

### 3. Comando de Admin para dar items ocultos

Los admins pueden dar cualquier item, incluso los ocultos:

```
/give <jugador> <itemname> [cantidad]
```

**Ejemplo:**
```
/give gabo mcl_mobitems:beef 10
```

---

## 🚫 Cómo Ocultar Items

### Método 1: Modificar mod existente

**Paso 1:** Localizar archivo de registro del item

```bash
# Buscar donde se registra el item
grep -r "minetest.register_node.*beef" server/mods/
grep -r "minetest.register_craftitem.*beef" server/mods/
```

**Paso 2:** Agregar `not_in_creative_inventory=1` al grupo

```lua
-- ANTES
minetest.register_craftitem("mcl_mobitems:beef", {
    description = "Raw Beef",
    groups = {food=2, eatable=3},
    -- ...
})

-- DESPUÉS
minetest.register_craftitem("mcl_mobitems:beef", {
    description = "Raw Beef",
    groups = {food=2, eatable=3, not_in_creative_inventory=1},
    -- ...
})
```

**Paso 3:** Reiniciar servidor

```bash
docker compose restart luanti-server
```

### Método 2: Crear mod de override

Crear mod que sobrescriba definiciones de items:

**Archivo:** `server/mods/wetlands_inventory_control/init.lua`

```lua
-- Override item para ocultarlo del inventario creativo
minetest.override_item("mcl_mobitems:beef", {
    groups = {food=2, eatable=3, not_in_creative_inventory=1}
})

minetest.override_item("mcl_mobitems:porkchop", {
    groups = {food=2, eatable=3, not_in_creative_inventory=1}
})

minetest.log("action", "[Wetlands Inventory Control] Items no veganos ocultados del inventario creativo")
```

**Archivo:** `server/mods/wetlands_inventory_control/mod.conf`

```conf
name = wetlands_inventory_control
description = Controla qué items aparecen en el inventario creativo de Wetlands
depends = mcl_mobitems
author = Wetlands Team
```

**Ventajas del método 2:**
- No modifica mods de terceros (más mantenible)
- Centraliza todas las modificaciones de inventario
- Fácil de activar/desactivar

---

## 🥩 Items No Veganos a Ocultar

### Items de Comida Animal (VoxeLibre)

**Ubicación:** Mod `mcl_mobitems` y `mcl_fishing`

| Item | Nombre Técnico | Razón |
|------|----------------|-------|
| Carne cruda de vaca | `mcl_mobitems:beef` | Producto animal |
| Carne cocida de vaca | `mcl_mobitems:cooked_beef` | Producto animal |
| Carne de cerdo cruda | `mcl_mobitems:porkchop` | Producto animal |
| Carne de cerdo cocida | `mcl_mobitems:cooked_porkchop` | Producto animal |
| Pollo crudo | `mcl_mobitems:chicken` | Producto animal |
| Pollo cocido | `mcl_mobitems:cooked_chicken` | Producto animal |
| Cordero crudo | `mcl_mobitems:mutton` | Producto animal |
| Cordero cocido | `mcl_mobitems:cooked_mutton` | Producto animal |
| Conejo crudo | `mcl_mobitems:rabbit` | Producto animal |
| Conejo cocido | `mcl_mobitems:cooked_rabbit` | Producto animal |
| Pescado crudo | `mcl_fishing:fish_raw` | Producto animal |
| Pescado cocido | `mcl_fishing:fish_cooked` | Producto animal |
| Salmón crudo | `mcl_fishing:salmon_raw` | Producto animal |
| Salmón cocido | `mcl_fishing:salmon_cooked` | Producto animal |
| Huevo | `mcl_throwing:egg` | Producto animal |
| Leche | `mcl_mobitems:milk_bucket` | Producto animal |
| Miel | `mcl_honey:honey_bottle` | Producto de explotación animal |

### Items Derivados de Animales

| Item | Nombre Técnico | Razón |
|------|----------------|-------|
| Cuero | `mcl_mobitems:leather` | Subproducto de matanza |
| Lana | `mcl_wool:*` | Explotación animal |
| Pluma | `mcl_mobitems:feather` | Producto animal |

### Script para Ocultar Items No Veganos

```lua
-- server/mods/wetlands_inventory_control/hide_non_vegan.lua

local non_vegan_items = {
    -- Carnes
    "mcl_mobitems:beef",
    "mcl_mobitems:cooked_beef",
    "mcl_mobitems:porkchop",
    "mcl_mobitems:cooked_porkchop",
    "mcl_mobitems:chicken",
    "mcl_mobitems:cooked_chicken",
    "mcl_mobitems:mutton",
    "mcl_mobitems:cooked_mutton",
    "mcl_mobitems:rabbit",
    "mcl_mobitems:cooked_rabbit",

    -- Pescados
    "mcl_fishing:fish_raw",
    "mcl_fishing:fish_cooked",
    "mcl_fishing:salmon_raw",
    "mcl_fishing:salmon_cooked",

    -- Productos animales
    "mcl_throwing:egg",
    "mcl_mobitems:milk_bucket",
    "mcl_honey:honey_bottle",
    "mcl_mobitems:leather",
    "mcl_mobitems:feather",
}

-- Ocultar todos los items no veganos
for _, item_name in ipairs(non_vegan_items) do
    -- Verificar si el item existe antes de sobrescribirlo
    if minetest.registered_items[item_name] then
        local current_groups = minetest.registered_items[item_name].groups or {}
        current_groups.not_in_creative_inventory = 1

        minetest.override_item(item_name, {
            groups = current_groups
        })

        minetest.log("action", "[Wetlands] Item no vegano ocultado: " .. item_name)
    end
end

minetest.log("action", "[Wetlands] " .. #non_vegan_items .. " items no veganos ocultados del inventario creativo")
```

---

## 👑 Items Exclusivos de Admin

Items que solo el admin puede otorgar (ej: premios, eventos especiales).

### Casos de Uso

1. **Premios por Eventos:** Items especiales para concursos
2. **Items de Construcción Avanzada:** Bloques decorativos especiales
3. **Herramientas de Moderación:** Items de debug o administración
4. **Items de Eventos Temporales:** Halloween, Navidad, etc.

### Ejemplo: Item Exclusivo de Premio

```lua
-- server/mods/wetlands_rewards/init.lua

minetest.register_node("wetlands_rewards:golden_sanctuary_block", {
    description = "Bloque Dorado de Santuario (Premio Especial)",
    tiles = {"wetlands_golden_sanctuary.png"},
    groups = {
        cracky=1,
        not_in_creative_inventory=1  -- Solo admin puede dar
    },
    sounds = mcl_sounds.node_sound_metal_defaults(),
})

-- Comando admin para dar premio
minetest.register_chatcommand("premio_santuario", {
    description = "Otorgar premio de santuario a jugador",
    params = "<jugador>",
    privs = {server = true},  -- Solo admin
    func = function(name, param)
        local player = minetest.get_player_by_name(param)
        if not player then
            return false, "Jugador no encontrado: " .. param
        end

        local inv = player:get_inventory()
        inv:add_item("main", "wetlands_rewards:golden_sanctuary_block 1")

        minetest.chat_send_all("🏆 ¡" .. param .. " ha recibido un Bloque Dorado de Santuario!")
        return true, "Premio otorgado a " .. param
    end
})
```

---

## 💡 Ejemplos Prácticos

### Ejemplo 1: Ocultar Todas las Armas

```lua
-- server/mods/wetlands_inventory_control/hide_weapons.lua

local weapons = {
    "mcl_tools:sword_wood",
    "mcl_tools:sword_stone",
    "mcl_tools:sword_iron",
    "mcl_tools:sword_gold",
    "mcl_tools:sword_diamond",
    "mcl_bows:bow",
    "mcl_bows:crossbow",
    "mcl_throwing:snowball",  -- Puede ser usado para molestar
}

for _, weapon in ipairs(weapons) do
    if minetest.registered_items[weapon] then
        local groups = minetest.registered_items[weapon].groups or {}
        groups.not_in_creative_inventory = 1
        minetest.override_item(weapon, {groups = groups})
    end
end

minetest.log("action", "[Wetlands] Armas ocultadas del inventario creativo")
```

### Ejemplo 2: Crear Categoría de Items Veganos

```lua
-- server/mods/wetlands_vegan_category/init.lua

-- Marcar items veganos para fácil identificación
local vegan_foods = {
    "mcl_farming:bread",
    "mcl_farming:carrot_item",
    "mcl_farming:potato_item",
    "mcl_core:apple",
    "mcl_farming:melon_item",
    "mcl_farming:pumpkin_pie",
}

for _, food in ipairs(vegan_foods) do
    if minetest.registered_items[food] then
        local groups = minetest.registered_items[food].groups or {}
        groups.vegan = 1  -- Grupo personalizado

        -- Agregar indicador visual en descripción
        local current_desc = minetest.registered_items[food].description

        minetest.override_item(food, {
            description = current_desc .. " 🌱",
            groups = groups
        })
    end
end
```

### Ejemplo 3: Validar Recetas de Crafteo

```lua
-- server/mods/wetlands_crafting_control/init.lua

-- Prevenir craftear items no veganos
minetest.register_on_craft(function(itemstack, player, old_craft_grid, craft_inv)
    local item_name = itemstack:get_name()

    -- Lista de items cuyo crafteo queremos bloquear
    local blocked_items = {
        "mcl_mobitems:leather",
        -- Agregar más items aquí
    }

    for _, blocked in ipairs(blocked_items) do
        if item_name == blocked then
            minetest.chat_send_player(player:get_player_name(),
                "❌ Este item no está disponible en Wetlands (servidor vegano)")
            return ItemStack("")  -- Cancelar crafteo
        end
    end
end)
```

---

## 🔍 Herramientas de Auditoría

### Script 1: Listar Todos los Items en Inventario Creativo

```bash
#!/bin/bash
# scripts/audit-creative-inventory.sh

echo "🔍 Auditando inventario creativo de Wetlands..."
echo "================================================"

# Conectar al servidor y ejecutar comando Lua
docker compose exec -T luanti-server lua -e '
    dofile("/config/.minetest/builtin/init.lua")

    local creative_items = {}
    local hidden_items = {}

    for name, def in pairs(minetest.registered_items) do
        local groups = def.groups or {}
        if groups.not_in_creative_inventory == 1 then
            table.insert(hidden_items, name)
        else
            table.insert(creative_items, name)
        end
    end

    print("Items visibles en creativo: " .. #creative_items)
    print("Items ocultos: " .. #hidden_items)

    print("\nItems ocultos:")
    for _, item in ipairs(hidden_items) do
        print("  - " .. item)
    end
'
```

### Script 2: Buscar Items No Veganos

```bash
#!/bin/bash
# scripts/find-non-vegan-items.sh

echo "🥩 Buscando items potencialmente no veganos..."

# Palabras clave que indican items no veganos
keywords="beef porkchop chicken mutton rabbit fish salmon egg milk leather wool feather meat"

for keyword in $keywords; do
    echo ""
    echo "Buscando: $keyword"
    grep -r "register.*$keyword" server/mods/mcl_*/init.lua 2>/dev/null | \
        grep -v "not_in_creative_inventory" || echo "  (no encontrado o ya oculto)"
done
```

### Comando In-Game para Admins

```lua
-- server/mods/wetlands_admin_tools/inventory_audit.lua

minetest.register_chatcommand("audit_inventory", {
    description = "Auditar inventario creativo",
    privs = {server = true},
    func = function(name)
        local visible = 0
        local hidden = 0
        local non_vegan = 0

        for item_name, def in pairs(minetest.registered_items) do
            local groups = def.groups or {}

            if groups.not_in_creative_inventory == 1 then
                hidden = hidden + 1
            else
                visible = visible + 1
            end

            -- Detectar items potencialmente no veganos
            if item_name:match("beef") or item_name:match("pork") or
               item_name:match("chicken") or item_name:match("fish") then
                if not groups.not_in_creative_inventory then
                    non_vegan = non_vegan + 1
                    minetest.chat_send_player(name, "⚠️ Item no vegano visible: " .. item_name)
                end
            end
        end

        return true, string.format(
            "📊 Inventario:\nVisibles: %d\nOcultos: %d\n⚠️ No veganos visibles: %d",
            visible, hidden, non_vegan
        )
    end
})
```

---

## 🔧 Mantenimiento

### Checklist Mensual de Inventario

**□ Auditar nuevos mods instalados**
```bash
./scripts/audit-creative-inventory.sh > reports/inventory_$(date +%Y%m).txt
```

**□ Verificar items no veganos visibles**
```bash
./scripts/find-non-vegan-items.sh
```

**□ Revisar feedback de jugadores**
- ¿Reportaron items inapropiados?
- ¿Falta algún item vegano importante?

**□ Actualizar lista de items ocultos**
- Nuevas carnes en actualizaciones de VoxeLibre
- Nuevos productos animales

**□ Documentar cambios**
```bash
git commit -m "docs: Actualizar lista de items no veganos ocultos"
```

### Actualización tras Update de VoxeLibre

Cuando se actualiza VoxeLibre, pueden aparecer nuevos items:

```bash
# 1. Hacer backup
./scripts/backup.sh

# 2. Actualizar VoxeLibre
cd server/games/
rm -rf mineclone2
wget https://content.luanti.org/packages/Wuzzy/mineclone2/releases/latest/download/ -O voxelibre.zip
unzip voxelibre.zip -d .
mv mineclone2-* mineclone2

# 3. Auditar nuevos items
./scripts/find-non-vegan-items.sh > new_items_check.txt

# 4. Actualizar mod de control
nano server/mods/wetlands_inventory_control/hide_non_vegan.lua

# 5. Reiniciar y verificar
docker compose restart luanti-server
```

---

## 📚 Recursos Adicionales

### Documentación Oficial

- [Luanti Lua API - Groups](https://minetest.gitlab.io/minetest/groups/)
- [VoxeLibre Item Registry](https://git.minetest.land/VoxeLibre/VoxeLibre/src/branch/master/mods/ITEMS)
- [Minetest Modding Book - Items](https://rubenwardy.com/minetest_modding_book/en/items/)

### Archivos Relacionados

- `/server/mods/wetlands_inventory_control/` - Mod de control de inventario
- `/server/mods/vegan_replacements/` - Reemplazos veganos de items
- `/server/config/luanti.conf` - Configuración general del servidor
- `/docs/VEGAN_PHILOSOPHY.md` - Filosofía vegana del servidor

### Contacto y Soporte

- **Admin del Servidor:** gabo (en juego)
- **Repositorio:** https://github.com/gabrielpantoja-cl/luanti-voxelibre-server
- **Issues:** Reportar items inapropiados como GitHub Issue

---

## 🌱 Filosofía del Inventario Wetlands

> "Cada item en nuestro inventario creativo es una oportunidad educativa. Al ocultar productos animales, no solo reflejamos valores compasivos - también enseñamos a los niños que hay formas mejores y más amables de vivir y crear."

**Principios Guía:**

1. **Transparencia:** Los jugadores deben saber por qué ciertos items no están disponibles
2. **Educación:** Usar la ausencia de items como punto de aprendizaje
3. **Alternativas:** Siempre ofrecer alternativas veganas cuando ocultamos items
4. **Flexibilidad:** Los admins pueden hacer excepciones para fines educativos

**Ejemplo de mensaje educativo:**

```lua
-- Mensaje al intentar craftear item no vegano (si no está oculto el recipe)
minetest.register_on_craft(function(itemstack, player)
    if itemstack:get_name():match("beef") then
        minetest.chat_send_player(player:get_player_name(),
            "🌱 En Wetlands preferimos opciones plant-based. " ..
            "¿Sabías que puedes hacer hamburguesas veganas con soja? " ..
            "Habla con un admin para aprender más!")
    end
end)
```

---

**Última revisión:** 10 de Octubre, 2025
**Versión del servidor:** Luanti 5.13.0 + VoxeLibre 0.90.1
**Mantenido por:** Wetlands Server Team
