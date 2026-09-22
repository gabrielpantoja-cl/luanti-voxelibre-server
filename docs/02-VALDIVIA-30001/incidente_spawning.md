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

## Próximos Pasos

1. **Inmediato:** Actualizar `/diagnosticar_spawn` para reportar bioma y conteo de entidades
2. **Corto plazo:** Ejecutar diagnóstico mejorado y analizar resultados
3. **Medio plazo:** Si bioma es el problema, crear mod compat que registre `valdivia_city` como bioma válido para hostile spawns
4. **Largo plazo:** Re-evaluar si `valdivia_mobs_override` debe ser eliminado (ya no tiene efecto)

## Log del Incidente

### 2026-09-21 — FASE INICIAL
- [21:30] Investigación inicial: configuraciones revisadas, todas OK
- [22:00] Desplegado `valdivia_mob_debug` con `/diagnosticar_spawn`
- [22:09] **CRASH** — Error Lua: `get_artificial_light()` recibió tabla en vez de número
- [22:14] Hotfix deployed: `pcall()` + `param1` correcto
- [22:15] **Siguiente:** Ejecutar diagnóstico mejorado (bioma + mob cap)

---
*Documento mantenido por SRE — Última actualización: 2026-09-21 22:15*
