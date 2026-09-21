# Roadmap — Valdivia [Chile] (puerto 30001)

Lista **única** de pendientes de Valdivia. Los demás documentos de esta carpeta
describen cómo funciona cada pieza; lo que falta hacer se anota **aquí** (y se
enlaza desde el documento de origen, no se duplica).

Última revisión: **2026-09-16**.

Convención: `[ ]` pendiente · `[~]` en curso · `[x]` hecho (se mueve a
«Hecho recientemente» y luego se borra; el detalle queda en git y en el
historial de cada doc).

---

## 1. Verificar en el juego (cambios recientes sin prueba in-game)

- [ ] **Panel del NPC guía sin QR** — abrir un guía: Reglas, Lugares, aviso de
      `/gabo` y Cerrar; `/discord` debe responder «comando inválido».
      → [`guia-spawn.md`](guia-spawn.md)
- [ ] **Música de VoxeLibre + discoteca** — de día en la calle suena la música
      de VoxeLibre; al entrar al Hotel Dreams se apaga y queda solo la de la
      fiesta; al salir vuelve a su ritmo normal. → [`discoteca.md`](discoteca.md)
- [ ] **Protector con dos cuentas** — un jugador no-admin coloca un protector
      fuera de la Plaza; otra cuenta no puede romper ahí; ninguno puede colocar
      uno dentro de la Plaza. → [`proteccion.md`](proteccion.md)
- [ ] **Aviso de entrada** — con dos cuentas: al entrar la segunda, la primera ve
      `<nombre> entrando...` arriba a la izquierda sin tapar el chat; se va a los
      6 s. Si choca con el chat en celular o PC, ajustar `POSITION.y` en
      `valdivia_aviso_entrada/init.lua`.
- [ ] **Texturas de stairs/slabs** tras el remapeo v2 (`mcl_stairs:stair_oak` y
      similares). → [`current.md`](current.md)

## 2. Decisiones pendientes

- [ ] **Radio de Protector para una ciudad pública.** Hoy 20 (cubo de 41). Con
      ese radio un jugador puede bloquear un edificio emblemático o una calle.
      Opciones: dejarlo y moderar con `/protector_remove`, o bajarlo a 8–10.
      → [`proteccion.md`](proteccion.md)
- [ ] **`valdivia_teleporter` (`/ir`)**: está deshabilitado con coordenadas
      desactualizadas y el menú «Lugares» del guía ya lo reemplaza. Decidir entre
      borrarlo o marcarlo `DEPRECATED` (ya no tiene sentido «re-habilitarlo»).
- [ ] **`valdivia_music`**: deshabilitado desde 2026-07-03 y ahora redundante con
      la música de VoxeLibre. Decidir entre borrarlo o marcarlo `DEPRECATED`.

## 3. Deuda técnica y limpieza

- [ ] **`/ayuda` de `server_rules` en Valdivia** menciona `/discord` (ya no
      existe en Valdivia) y comandos de Wetlands (`/arena_tp`, `/pos1`,
      `/protect_area`, santuarios). Hacer una versión propia de Valdivia (que
      apunte a `/gabo`, `/lugares` y al bloque protector).
- [ ] **Warning `Undeclared global variable "pvp_arena"`** en
      `voxelibre_protection/init.lua:697` (en Valdivia no se carga `pvp_arena`).
      Arreglo: `rawget(_G, "pvp_arena")`.
- [ ] **Warnings `Overriding item mcl_chests:chest … after server startup`** de
      los «Chest protection hooks» de `voxelibre_protection`. Luanti avisa que
      puede causar inconsistencias; evaluar mover el override a la carga del mod.
- [ ] **Nodos desconocidos restantes** del mapa Arnis: el scanner detecta mods
      faltantes, pero no renombres dentro de mods existentes.
      → [`operations/ARNIS_UNKNOWN_NODES.md`](operations/ARNIS_UNKNOWN_NODES.md)

## 4. Mundo y navegación

- [ ] **Mod `valdivia_borders`**: los bordes del área generada son vacío y los
      jugadores pueden caer. Detectar la cercanía al límite y devolverlos con un
      mensaje. → [`current.md`](current.md) (Fase 4.1)
- [ ] **Más destinos en «Lugares»** con `/lugar_guardar`: Mercado Fluvial,
      Costanera, Los Fundadores, Feria Fluvial, Universidad Austral, Puente Pedro
      de Valdivia. → [`guia-spawn.md`](guia-spawn.md)
- [ ] **Señalética de calles** (nombres OSM) y mapa con puntos de interés.

## 5. Contenido y experiencia

### 5.0 Minas subterráneas (plan futuro — no prioridad actual)

- [ ] **Mod `valdivia_utils`** con comando `/generar_mina <radio> <profundidad>`:
  - **Objetivo**: rellenar el subsuelo vacío (air/void) bajo la ciudad pre-generada
    con vetas realistas de Deepslate y minerales para modo supervivencia.
  - **Carpeta**: `server/mods/valdivia_utils/`
  - **Archivos**: `mod.conf` (depends = mcl_core) + `init.lua`
  - **Comando**: `minetest.register_chatcommand("/generar_mina")`
    - Requiere privilegio `server` o `give`.
    - Toma posición del jugador, itera caja (pos.x ± radio, pos.y - 1 hasta
      pos.y - profundidad).
    - Solo reemplaza bloques `air` o `mcl_core:void`.
  - **Distribución de minerales** (1000 muestras):
    - 940/1000 → `mcl_core:deepslate`
    - 30/1000 → `mcl_core:deepslate_coal_ore`
    - 20/1000 → `mcl_core:deepslate_iron_ore`
    - 8/1000 → `mcl_core:deepslate_gold_ore`
    - 2/1000 → `mcl_core:deepslate_diamond_ore`
  - **Activar**: `load_mod_valdivia_utils = true` en `world.mt`
  - **Uso**: pararse en el subsuelo → `/generar_mina 10 5`
  - **Estado**: plan documentado, NO implementar hasta que haya tiempo.
    Prioridad baja — el servidor actualmente es exploración urbana, no mineração.
    → [`current.md`](current.md)

- [~] **Bailarines de la discoteca** (`/discoteca bailarin`, meta 4–6).
      → [`discoteca.md`](discoteca.md)
- [ ] **Voz del NPC guía**: reutilizar `play_npc_voice` de `wetlands_npcs`.
      → [`guia-spawn.md`](guia-spawn.md)
- [ ] **Mod de colectivo** que recorra la ciudad por rutas reales.
      → [`guia-spawn.md`](guia-spawn.md)
- [ ] **Hitos con WorldEdit**: Mercado Fluvial, Catedral, Muelle Schuster,
      Torreón del Barro / Los Canelos, Cervecería Kunstmann, campus UACh.
      → [`current.md`](current.md) (Fase 5.1)
- [ ] **Geografía**: Humedal Río Cruces, ríos Calle-Calle y Valdivia, Isla Teja
      separada por el río, puentes. → [`current.md`](current.md) (Fase 5.2)
- [ ] **Detalles urbanos**: casonas de General Lagos, Costanera con bancas y
      faroles. → [`current.md`](current.md) (Fase 5.3)
- [ ] **Mods temáticos** `valdivia_fauna` (coipo, flamenco, pudú, chuncho),
      `valdivia_flora` (coigüe, arrayán, totora, nalca, murta) y
      `valdivia_culture` (quioscos con historia, terremoto de 1960, humedales).
      → [`current.md`](current.md) (Fase 6)

---

## Recordatorios operativos (no son tareas)

- **Si se regenera Valdivia con Arnis**, reaplicar la corrección del worldmod
  `arnis_mapgen` (forzaba el spawn en cada join y daba `fly` a todos) y rehacer
  `spawn_plaza_chile`. → [`current.md`](current.md)
- **Habilitar o deshabilitar un mod**: tocar el `.conf` **y** el `world.mt` del VPS.

## Hecho recientemente

| Fecha | Qué |
|-------|-----|
| 2026-09-16 | Aviso en pantalla `<nombre> entrando...` para los conectados (`valdivia_aviso_entrada`) |
| 2026-09-16 | Protector Redo para jugadores, conviviendo con `voxelibre_protection` → [`proteccion.md`](proteccion.md) |
| 2026-09-16 | Vuelve la música de VoxeLibre; la discoteca la silencia solo adentro → [`discoteca.md`](discoteca.md) |
| 2026-09-10 | QR y `/discord` retirados del guía; los jugadores contactan al admin con `/gabo` → [`guia-spawn.md`](guia-spawn.md) |
| 2026-09-10 | `/gabo` (Telegram, ida y vuelta) activo en Valdivia |
| 2026-09-10 | Fix del error rojo `Don't know how to load file "es.tr"` (locale de `voxelibre_protection`) |
