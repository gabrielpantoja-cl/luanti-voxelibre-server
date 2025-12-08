# 🌱 Vegan Replacements - Eliminación de Items No Veganos

**Versión**: 1.0  
**Autor**: Wetlands Team  
**Compatibilidad**: VoxeLibre v0.90.1

## 📖 Descripción

Mod que elimina completamente todos los items no veganos del servidor y los reemplaza con alternativas basadas en plantas. Garantiza que el servidor sea 100% vegano, bloqueando carnes, cuero y otros productos de origen animal.

## 🎯 Propósito

Este mod es fundamental para:
- **Eliminar items no veganos** del servidor completamente
- **Reemplazar con alternativas** basadas en plantas
- **Mantener filosofía vegana** del servidor
- **Educar jugadores** sobre alternativas veganas
- **Prevenir consumo** de productos animales

## 🚀 Características

### Items Eliminados

El mod elimina completamente:

#### Carnes Crudas
- `mcl_mobitems:rotten_flesh` → Reemplazado con `mcl_core:apple`
- `mcl_mobitems:mutton` → Reemplazado con `mcl_farming:potato_item`
- `mcl_mobitems:beef` → Reemplazado con `mcl_farming:carrot_item`
- `mcl_mobitems:chicken` → Reemplazado con `mcl_farming:beetroot_item`
- `mcl_mobitems:porkchop` → Reemplazado con `mcl_farming:potato_item`
- `mcl_mobitems:rabbit` → Reemplazado con `mcl_farming:carrot_item`

#### Carnes Cocidas
- `mcl_mobitems:cooked_mutton` → Reemplazado con `mcl_farming:potato_item_baked`
- `mcl_mobitems:cooked_beef` → Reemplazado con `mcl_farming:carrot_item`
- `mcl_mobitems:cooked_chicken` → Reemplazado con `mcl_farming:beetroot_soup`
- `mcl_mobitems:cooked_porkchop` → Reemplazado con `mcl_farming:potato_item_baked`
- `mcl_mobitems:cooked_rabbit` → Reemplazado con `mcl_farming:carrot_item`

#### Derivados Animales
- `mcl_mobitems:leather` → Reemplazado con `mcl_core:paper`
- `mcl_mobitems:leather_piece` → Reemplazado con `mcl_core:paper`
- `mcl_mobitems:rabbit_stew` → Reemplazado con `mcl_farming:beetroot_soup`

### Funcionalidades

1. **Eliminación de Items**: Los items no veganos se eliminan completamente del juego
2. **Reemplazo Automático**: Si un jugador intenta obtener un item no vegano, recibe la alternativa vegana
3. **Bloqueo de Comandos**: El comando `/give` bloquea items no veganos
4. **Interceptación de Consumo**: Previene el consumo de items no veganos
5. **Modificación de Drops**: Cambia los drops de entidades para que no den items no veganos

### Comandos Administrativos

| Comando | Descripción | Privilegios |
|---------|-------------|-------------|
| `/vegancheck <item>` | Verifica si un item es vegano | `server` |
| `/listveganbans` | Lista todos los items no veganos eliminados | `server` |

## 🔧 Configuración

### Dependencias

```lua
depends =
```

No tiene dependencias obligatorias, pero funciona mejor con:
- `mcl_core` (para items base de reemplazo)
- `mcl_farming` (para alternativas vegetales)
- `mcl_mobitems` (para identificar items a eliminar)

### Habilitar el Mod

Agregar en `server/config/luanti.conf`:
```ini
load_mod_vegan_replacements = true
```

O en `server/worlds/world/world.mt`:
```ini
load_mod_vegan_replacements = true
```

## 🔄 Funcionamiento Técnico

### Sistema de Eliminación

1. **Al cargar el mod**: Identifica todos los items no veganos
2. **Sobrescribe items**: Cambia la definición para hacerlos inutilizables
3. **Oculta del inventario**: Los items no aparecen en inventario creativo
4. **Bloquea uso**: Previene cualquier interacción con los items

### Sistema de Reemplazo

1. **Intercepta `/give`**: Detecta intentos de dar items no veganos
2. **Reemplaza automáticamente**: Da la alternativa vegana
3. **Notifica al jugador**: Informa sobre el reemplazo

### Sistema de Drops

1. **Modifica entidades**: Cambia los drops de entidades problemáticas
2. **Reemplaza drops**: Los items no veganos se reemplazan en los drops

## 📝 Tabla de Reemplazos

| Item No Vegano | Alternativa Vegana | Razón |
|----------------|-------------------|-------|
| Carne podrida | Manzana | Menos dañina, alimento básico |
| Carne cruda | Vegetales | Nutrición similar, sin crueldad |
| Carne cocida | Vegetales horneados | Preparación similar, sabor comparable |
| Cuero | Papel | Material similar, sin animales |
| Estofado de conejo | Sopa de remolacha | Comida completa, nutrición similar |

## 🔗 Integración con Otros Mods

Este mod complementa:
- **`vegan_food`**: Agrega más alternativas veganas
- **`creative_force`**: Asegura que el kit de inicio sea vegano
- **`server_rules`**: Refuerza la filosofía vegana del servidor

## ⚠️ Advertencias

### Impacto en Gameplay

- Los jugadores **no pueden** obtener items no veganos
- Los comandos `/give` con items no veganos son bloqueados
- Los drops de entidades se modifican automáticamente

### Compatibilidad

- ✅ Funciona con `vegan_food` (agrega más opciones)
- ✅ Funciona con `creative_force` (kit vegano)
- ⚠️ Puede interferir con mods que dependen de items no veganos
- ⚠️ Algunos mods de terceros pueden intentar dar items no veganos

## 🐛 Troubleshooting

### Los items no veganos siguen apareciendo

1. Verificar que el mod está habilitado:
   ```bash
   docker-compose exec -T luanti-server cat /config/.minetest/worlds/world/world.mt | grep vegan_replacements
   ```

2. Verificar logs:
   ```bash
   docker-compose logs luanti-server | grep "Vegan Replacements"
   ```

3. El mod se carga después de otros mods, puede haber un delay

### El comando `/give` no bloquea items no veganos

1. Verificar que el mod está cargado:
   ```bash
   docker-compose logs luanti-server | grep "vegan_replacements"
   ```

2. El sistema intercepta comandos, pero puede haber casos edge

### Los drops de entidades siguen dando items no veganos

1. Verificar que las entidades están en la lista de modificación
2. Algunas entidades pueden no estar cubiertas
3. Reportar entidades problemáticas para agregarlas

## 📊 Estadísticas

Al cargar, el mod elimina:
- **13 items no veganos** principales
- **Múltiples variantes** de cada item
- **Drops de entidades** modificados

## 🔄 Expansiones Futuras

Posibles mejoras:
- [ ] Más items no veganos identificados y eliminados
- [ ] Sistema de recetas veganas alternativas
- [ ] Notificaciones educativas al intentar usar items no veganos
- [ ] Integración con `vegan_food` para más alternativas

## 📚 Documentación Adicional

- Ver documentación general en `docs/mods/README.md`
- Ver mod `vegan_food` para más alternativas veganas

---

**Última actualización**: Diciembre 7, 2025  
**Mantenedor**: Equipo Wetlands  
**Licencia**: GPL-3.0  
**🌱 Mod Crítico**: Fundamental para mantener filosofía vegana

