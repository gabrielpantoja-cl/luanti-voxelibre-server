# Incidente: Fallo de Spawning de Monstruos en Valdivia

**ID:** INC-2026-09-21-001
**Severidad:** SEV-1 (Servicio degradado — gameplay afectado)
**Estado:** Investigando
**Inicio:** 2026-09-21
**Servidor:** Valdivia (puerto 30001)

## Resumen Ejecutivo

Los monstruos hostiles no aparecen en Valdivia a pesar de que todas las configuraciones conocidas son correctas. Investigación actual se centra en **restricción de bioma** y **saturación de mob cap**.

## Checklist de Configuración (✅ TODOS OK)

| Parámetro | Estado | Valor | Fuente |
|-----------|--------|-------|--------|
| `doMobSpawning` | ✅ OK | `true` | `mod_storage.sqlite` (gamerule) |
| `damage_enabled` | ✅ OK | `true` | `mod_storage.sqlite` (gamerule) |
| `only_peaceful_mobs` | ✅ OK | `false` | `mod_storage.sqlite` (gamerule) |
| `mcl_difficulty` | ✅ OK | `normal` | `luanti-valdivia.conf` |
| `mcl_mobs_overworld_threshold` | ✅ OK | `11` | `luanti-valdivia.conf` |
| `mcl_mobs_overworld_sky_threshold` | ✅ OK | `7` | `luanti-valdivia.conf` |
| Terreno (bloque bajo) | ✅ OK | `dirt_with_grass` (solid) | Diagnóstico in-game |
| Luz artificial | ✅ OK | `0` | Diagnóstico in-game |
| Luz natural | ✅ OK | `0` (medianoche) | Diagnóstico in-game |
| Resultado diagnóstico | ✅ OK | "Podría spawnear hostiles: SI" | `/diagnosticar_spawn` |

## Hipótesis Activas

### H1: Restricción de Bioma (PRIORIDAD ALTA)
- **Teoría:** El mapa de Valdivia usa un bioma personalizado (ej. `valdivia_city`) o un bioma pacífico que no está en la lista de biomas permitidos para spawning de monstruos en `mcl_mobs`.
- **Evidence:** VoxeLibre restringe el spawning de hostiles a biomas específicos definidos en cada entidad mob.
- **Verificación:** Leer `minetest.get_biome_data(pos).biome` y cruzar con las `spawn_biomes` del zombi.

### H2: Saturación del Mob Cap (PRIORIDAD MEDIA)
- **Teoría:** El límite de entidades del servidor está saturado por mobs pasivos, vehículos, o entidades invisibles generadas por la ciudad.
- **Evidence:** Valdivia tiene infrastructure extensa (carreteras, edificios) que puede generar entidades passivas.
- **Verificación:** Contar entidades en radio de 64 nodos con `minetest.get_objects_inside_radius()`.

### H3: Mod de Ciudad Bloqueando (PRIORIDAD BAJA)
- **Teoría:** Algún mod de Valdivia está registrando callbacks que interfieren con el spawn cycle de `mcl_mobs`.
- **Verificación:** Revisar logs del server para ver si hay algún mod interceptando spawns.

## Cambios Recientes

| Commit | Cambio | Efecto |
|--------|--------|--------|
| `bdab1cdb` | Thresholds 11/7 en config | Debería permitir spawning urbano |
| `1fbb0fd3` | `valdivia_mobs_override` | Override de `mob_light_lvl()` (INEFECTIVO — no se usa en spawn real) |
| `702200bf` | Hotfix crash diagnóstico | `/diagnosticar_spawn` ahora no crashea |

## Solución Aplicada

**Commit:** `e348bd2c` — `fix(spawning): corregir sintaxis de metodo - usar : en vez de .`

**Mod `valdivia_spawn_fix`:** Re-registra los 5 monstruos principales SIN restricción de biomas:
- `mobs_mc:zombie` (chance=1500)
- `mobs_mc:baby_zombie` (chance=50)
- `mobs_mc:skeleton` (chance=800)
- `mobs_mc:spider` (chance=1000)
- `mobs_mc:stalker` (creeper, chance=400)

**Mecanismo técnico:** El chequeo en `spawning.lua:583` es:
```lua
if spawn_def.biomes and not spawn_def.biomes_lookup[state.biome] then return false end
```
Si `biomes` es `nil`, el chequeo se salta completamente. El mod llama `mcl_mobs:spawn_setup()` sin el campo `biomes`, creando entradas adicionales en `spawn_dictionary` que aceptan cualquier bioma.

**Resultado en logs:**
```
[valdivia_spawn_fix] Registrado mobs_mc:zombie sin restriccion de bioma (chance=1500)
[valdivia_spawn_fix] Registrado mobs_mc:baby_zombie sin restriccion de bioma (chance=50)
[valdivia_spawn_fix] Registrado mobs_mc:skeleton sin restriccion de bioma (chance=800)
[valdivia_spawn_fix] Registrado mobs_mc:spider sin restriccion de bioma (chance=1000)
[valdivia_spawn_fix] Registrado mobs_mc:stalker sin restriccion de bioma (chance=400)
[valdivia_spawn_fix] Completado: 5 registrados, 0 omitidos
```

## Próximos Pasos

1. **Inmediato:** Probar en-game — encontrar monstruos a medianoche en las calles de Valdivia
2.<think>**Corto plazo:** Si el spawning funciona, actualizar `valdivia_mob_debug` con `/diagnosticar_spawn` v2 para confirmar bioma y entidades
3. **Medio plazo:** Evaluar si la tasa de spawning es adecuada (chance values son los mismos que el juego base)
4. **Largo plazo:** Considerar eliminar `valdivia_mobs_override` (ya no tiene efecto útil)

## Log del Incidente

### 2026-09-21 — RESOLUCIÓN
- [22:14] Hotfix crash diagnóstico: `get_artificial_light(node_here.param1)` (commit `702200bf`)
- [22:29] Sonda v2 desplegada: bioma + conteo entidades (commit `005787b7`)
- [22:46] **H1 CONFIRMADA**: Bioma de Valdivia (singlenode/Arnis) no coincide con `spawn_biomes` de mobs
- [22:48] Creado `valdivia_spawn_fix` — re-registra mobs sin biomes (commit `8717f517`)
- [22:48] **ERROR**: `mcl_mobs.spawn_setup()` con `.` en vez de `:` — Missing spawn definition
- [22:49] **FIX**: Corregido a `mcl_mobs:spawn_setup()` (commit `e348bd2c`)
- [22:49] **ÉXITO**: 5/5 monstruos registrados sin restricción de bioma
- [22:50] **Servidor listo para prueba en-game**

---
*Documento mantenido por SRE — Última actualización: 2026-09-21 22:50*
