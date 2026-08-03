# Mineclonia (Puerto 30004)

Mundo creativo puro corriendo [Mineclonia 0.123.0](https://codeberg.org/mineclonia/mineclonia),
fork de VoxeLibre enfocado en clonar Minecraft vanilla. **No usa VoxeLibre** — es un game
independiente de Luanti.

| Aspecto | Valor |
|---------|-------|
| Puerto | 30004/UDP |
| Juego | Mineclonia 0.123.0 (fork de VoxeLibre, no es VoxeLibre) |
| Mapgen | Mineclonia mapgen (Lua, compatible con seeds de Minecraft) |
| Seed | `mineclonia` |
| Creativo | Sí |
| Daño | No |
| PvP | No |
| Mods custom | `wetlands_mineclonia_trampas` (única excepción — bloque trampa amistosa) |
| Mobs | No spawnean |

Documentación completa: [`index.md`](index.md). Instalación del game: [`install.md`](install.md).

## Mod custom habilitado: `wetlands_mineclonia_trampas`

Agregado el 2026-08-03 a pedido del admin para construir regalos/sorpresas en Mineclonia.

**Qué hace**: registra un único nodo `wetlands_mineclonia_trampas:secret_heart` que **se ve idéntico a `mcl_core:stone`** (textura `default_stone.png`, drop `mcl_core:cobble`, sonido de piedra). Cuando un jugador pisa el bloque, ve en el chat el mensaje **`"ME ENCANTA JUGAR CONTIGO ❤️"`** color rosa fuerte, más una lluvia de partículas de corazón. Sin daño, sin knockback, sin romper nada — solo un guiño amistoso.

**Por qué existe**: Mineclonia corre con `creative_mode = true`, `enable_damage = false`, `enable_fire = false`, `enable_tnt = false`. No se pueden usar las mecánicas vanilla de Minecraft (TNT + pressure plates + redstone) para trampas. Este mod provee una alternativa kids-friendly.

**Por qué el mod existe en `server/mods/` (no en `worldmods/`)**: para que sea reproducible desde el repo. La activación se hace vía `load_mod_wetlands_mineclonia_trampas = true` en `luanti-mineclonia.conf` + el `world.mt` del VPS. No se carga en Wetlands/Valdivia/GAELSIN/CTF.

**Implementación técnica**:

- El callback de nodo `on_stand` fue **removido del engine** en Luanti 5.14+. Las pressure plates de vanilla ahora usan polling (`core.register_globalstep` + chequeo de posición cada 0.5s). El mod usa el mismo patrón.
- `core.register_abm` (interval 5s) rescanea el mapa periódicamente para re-poblar la tabla interna `trap_positions` cuando los chunks se cargan del disco tras un restart del servidor.
- Cooldown per-player de 5 segundos para evitar spam si el jugador se queda parado arriba.
- El bloque NO aparece en el inventario creativo por defecto? **Sí aparece** — buscá "Bloque Secreto" o "Trampas". Se coloca como cualquier bloque; al picarlo, dropea cobble normal (no el bloque trampa, así no se pueden farmear infinitas trampas).

**Uso típico**:

1. `/giveme wetlands_mineclonia_trampas:secret_heart` (o buscarlo en el inventario creativo)
2. Colocarlo en un camino, una escalera, o dentro de un piso donde un amigo camina seguido
3. Quedarse cerca para ver el mensaje cuando lo pisen
4. Si querés esconderlo bajo otro bloque de stone (porque se ve igual a `mcl_core:stone`), los jugadores se van a sorprender cuando caigan y aparezca el chat rosa + corazones

**Archivos**:

- `server/mods/wetlands_mineclonia_trampas/init.lua` — código (~60 líneas, autocontenido)
- `server/mods/wetlands_mineclonia_trampas/mod.conf` — `optional_depends = mcl_core, mcl_sounds`
- `server/mods/wetlands_mineclonia_trampas/textures/wetlands_mineclonia_trampas_heart.png` — partícula de corazón (copiada de `mcl_base_textures`)
