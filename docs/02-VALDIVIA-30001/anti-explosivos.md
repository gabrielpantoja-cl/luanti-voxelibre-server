# Anti-explosivos / Anti-grief — Valdivia

Valdivia (puerto 30001) **no tiene protección de área**: cualquiera puede editar
cualquier parte. El objetivo es que la gente construya y embellezca la ciudad,
no que la destruya. Por eso se bloquea todo tipo de explosión y de incendio.

Estado: **en producción** desde 2026-07-05.

## Dos capas

### Capa 1 — `mcl_explosions_griefing = false` (la garantía)
En `server/config/luanti-valdivia.conf`. En VoxeLibre **todas** las explosiones
pasan por `mcl_explosions.explode()`, que sólo destruye nodos si este flag es
`true`. Ponerlo en `false` neutraliza el daño a nodos de **todas** las fuentes
de una sola vez:

- TNT y vagoneta con TNT
- Creeper (aunque en Valdivia `mobs_spawn = false`, un huevo creativo tampoco daña)
- Bola de fuego de Ghast
- Cristal del End
- Camas al usarse fuera del Overworld
- Respawn anchor fuera del End
- Explosión del Wither

> Es el equivalente al `wetlands_no_creeper` de Wetlands pero mucho más amplio:
> no depende de bloquear cada mob/ítem, sino de cortar el mecanismo común.

### Capa 2 — mod `valdivia_no_explosions` (la política)
En `server/mods/valdivia_no_explosions/`. Complementa la Capa 1:

1. **Oculta del inventario creativo** los ítems explosivos/incendiarios
   (`not_in_creative_inventory`, preservando el resto de sus groups):
   `mcl_tnt:tnt`, `mcl_minecarts:tnt_minecart`, `mcl_end:crystal`,
   `mcl_fire:fire_charge`, `mcl_fire:flint_and_steel`, `mcl_beds:respawn_anchor`.
   Los jugadores no-admin **no tienen priv `give`**, así que ocultarlos del
   creativo los deja efectivamente fuera de alcance.
2. **Deja el TNT inerte**: sobreescribe `on_blast`, `_on_ignite`, `_on_burn` y
   `mesecons` de `mcl_tnt:tnt` a no-op, para que ni con mechero, fuego, redstone
   o reacción en cadena haga nada (ni el destello).

Ocultar el mechero (`flint_and_steel`) y la carga de fuego además corta la vía
principal para **incendiar construcciones** en modo creativo.

## Despliegue (ya aplicado)

1. `mcl_explosions_griefing = false` + `load_mod_valdivia_no_explosions = true`
   en `luanti-valdivia.conf` (git).
2. `load_mod_valdivia_no_explosions = true` en el `world.mt` de Valdivia del VPS
   (sudo; `world.mt` gana sobre el `.conf`).
3. `docker compose restart luanti-valdivia`.

## Verificación

- Log al arrancar: `[valdivia_no_explosions] Loaded successfully` sin errores.
- En creativo, buscar "tnt" / "flint" en el inventario → no deben aparecer.
- Como admin (`/giveme mcl_tnt:tnt`), colocar y encender con mechero → **no
  destruye nada** (ni el bloque de al lado).

## Fuera de alcance (posibles siguientes pasos)

- **Lava creativa**: colocar lava sigue pudiendo quemar/derretir. Si molesta,
  se puede ocultar el balde de lava del creativo o bloquear su colocación.
- **Propagación de fuego** en general (`fire_spreads`): hoy se corta la vía de
  ignición (mechero/carga ocultos), pero no se deshabilita el fuego a nivel
  motor. Evaluar si hace falta.
- **Protección de área real** (WorldEdit/areas) si se quiere impedir también el
  picado manual de construcciones ajenas.
