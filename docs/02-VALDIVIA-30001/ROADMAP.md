# Roadmap — Valdivia [Chile] (puerto 30001)

Lista **única** de pendientes de Valdivia. Los demás documentos de esta carpeta
describen cómo funciona cada pieza; lo que falta hacer se anota **aquí** (y se
enlaza desde el documento de origen, no se duplica). Las prioridades transversales
viven en el [`ROADMAP.md`](../../ROADMAP.md) de la raíz.

Última revisión: **2026-10-28**.

Convención: `[ ]` pendiente · `[~]` en curso · `[x]` hecho (se mueve a
«Hecho recientemente» y luego se borra; el detalle queda en git y en el
historial de cada doc).

---

## 0. Prioridad ahora (en este orden)

Valdivia recibe visitas de desconocidos (8 ingresos en los últimos 7 días, IPs de
Chile, Argentina, Rumania, Egipto). Casi todos entran una vez y no vuelven. Las
tres cosas de abajo son las que hacen que un recién llegado se vaya; el contenido
nuevo (NPCs, consolas, discoteca) no mueve esa aguja hasta que estén resueltas.

1. **P0 — Monstruos dentro de los edificios a plena luz del día.**
   `mcl_mobs_overworld_threshold = 11` en `luanti-valdivia.conf` (el default de
   VoxeLibre es `0`). La condición real de spawn es
   `art_light <= 11 and sky_light <= 7` (`mcl_mobs/spawning.lua:771`), y
   `sky_light` viene de `get_natural_light()`, que **sí** depende de la hora: al
   mediodía en la calle no spawnea nada, pero **cualquier interior en sombra o
   con antorchas acepta hostiles a cualquier hora**. En una ciudad OSM —toda de
   edificios sin iluminar— eso significa zombis y creepers adentro todo el día.
   Ese `11` se puso el 2026-09-21 para forzar spawning cuando los mobs **no**
   aparecían (bug de bioma, ya resuelto por `valdivia_spawn_fix`): ya cumplió su
   propósito y hoy sobra.
   → Dejar `mcl_mobs_overworld_threshold = 0` y reiniciar. Ver decisión en 2.1.

2. **P1 — Valdivia desaparece de la lista pública de servidores.**
   `servers.luanti.org/announce` responde `409` con «Server
   luanti.gabrielpantoja.cl port 30001 did not respond to ping»: 6 fallos en 24 h.
   Los otros cuatro mundos (30000, 30002, 30003, 30004) tienen **0** fallos en el
   mismo período, así que no es el bug del `--port` hardcodeado (el override de
   `svc-luanti/run` ya está montado) sino alcanzabilidad UDP del 30001 desde
   afuera. Como casi todo el tráfico llega por la lista pública, es tráfico que se
   pierde. → Revisar regla de ingress 30001/UDP (Oracle Security List + iptables
   del host) y comparar con la del 30000. → [`operations/SERVER_LIST_DUPLICATE_BUG.md`](operations/SERVER_LIST_DUPLICATE_BUG.md)

3. **P2 — Caerse por el borde del mapa** (mod `valdivia_borders`, sección 4). En
   supervivencia, caer al vacío = inventario perdido y jugador que no vuelve.

Lo que **no** es prioridad ahora: más mini-juegos, voz del guía, mod de colectivo,
fauna/flora temática. El `wetlands_snes` recién salió y ya está en el mundo; lo que
le falta es documentarlo y probarlo con una segunda cuenta, no agregarle juegos.

---

## 1. Verificar en el juego (cambios recientes sin prueba in-game)

- [ ] **Transeúntes** (`valdivia_transeuntes`, desplegado el 2026-10-30) — lo
      primero es **calibrar el filtro de calle** con `/transeunte_scan` parado
      en cuatro sitios y comparando: (a) una calle del centro, (b) la Plaza,
      (c) **dentro de una casa** y (d) **sobre un techo**. Lo que tiene que
      pasar: la calle y la Plaza dan `es_calle: true`; la casa da `false` por
      luz natural; el techo da `es_calle: true` pero `suelo macizo: false`. Si
      un techo diera `suelo macizo: true`, los transeúntes pueden nacer
      arriba de los edificios y hay que endurecer ese filtro.
      Después, caminando por el centro: (e) que aparezca gente sola a los
      pocos minutos y **nunca a la vista** (si aparecen de la nada delante,
      subir `dist_min`); (f) que **no entren a las casas** ni se metan al río;
      (g) que no se queden clavados contra un muro; (h) `/transeuntes` para
      ver cuántos hay y si el cupo se respeta; (i) alejarse 100 nodos y
      volver — no deben quedar acumulados. (j) de noche, mirar si se les
      pegan zombis encima: eso ya está diagnosticado como bug, ver sección 3.
      → [`transeuntes.md`](transeuntes.md)
- [ ] **Carabinero anti-grief** (`valdivia_policia`, desplegado el 2026-10-30) —
      con una cuenta **no-admin**: romper un bloque dentro del protector de otro
      → aparece el carabinero, persigue y dispara. Revisar en este orden:
      (a) que **se mueva de verdad** — si solo avanza a saltos cada 4 s es que el
      FSM de `mcl_mobs` está pisando el `set_velocity` de `do_custom` y solo lo
      empuja la reubicación anti-atasco; (b) que los dardos **acierten** a
      distancia media y no atraviesen paredes (`line_of_sight`); (c) que a ≤ 2 HP
      **deje de disparar** (no letal); (d) que un clic sostenido genere **un
      solo** policía (debounce + cooldown); (e) que al desconectarse el
      perseguido el carabinero desaparezca; (f) reiniciar el contenedor a mitad
      de persecución y confirmar que **no queda ningún huérfano** en el mapa.
      Probar primero con `/policia` (no requiere romper nada).
      → [`policia.md`](policia.md)
- [ ] **Consola SNES** (`wetlands_snes`, desplegada el 2026-10-28) — con una
      cuenta **no-admin**: clic derecho a la consola → menú → «Atrapa al Topo»
      (puntaje y cronómetro corren, el topo cambia de hueco) y «Trivia de
      Valdivia» (las preguntas avanzan y el puntaje final aparece). Comprobar que
      dos jugadores en la misma consola no se pisen el estado, y que al salir del
      formspec a medio juego el timer se limpie. Falta además crear
      `docs/02-VALDIVIA-30001/snes.md` y un `README.md` del mod.
- [ ] **Minas subterráneas** (`valdivia_utils`, ya implementado) —
      `/generar_mina 10 5` bajo la ciudad: que rellene solo `air`/vacío, que
      aparezcan las vetas en la proporción esperada y que **nunca** escriba sobre
      `ignore`. Medir cuánto tarda y si lagea con radios grandes.
- [ ] **Panel del NPC guía sin QR** — abrir un guía: Reglas, Lugares, aviso de
      `/gabo` y Cerrar; `/discord` debe responder «comando inválido».
      → [`guia-spawn.md`](guia-spawn.md)
- [ ] **Música de VoxeLibre + discoteca** — de día en la calle suena la música
      de VoxeLibre; al entrar al Hotel Dreams se apaga y queda solo la de la
      fiesta; al salir vuelve a su ritmo normal. → [`discoteca.md`](discoteca.md)
- [ ] **DJ del Dreams** — entrar a la pista: suena el repertorio y sale el
      crédito; clic derecho al DJ → pedir Billie Jean → cambia para todos (probar
      con dos cuentas que queden sincronizadas); segundo pedido antes de 30 s se
      rechaza. → [`discoteca.md`](discoteca.md)
- [ ] **Protector con dos cuentas** — un jugador no-admin coloca un protector
      fuera de la Plaza; otra cuenta no puede romper ahí.
      → [`proteccion.md`](proteccion.md)
- [ ] **Decidir qué protege la Plaza Chile.** `voxelibre_protection` salió del
      `world.mt` el 2026-10-12 y `protector_spawn = 0`: el área
      `spawn_plaza_chile` (Plaza + Hotel Dreams/Discoteca) **ya no se aplica**.
      Opciones: (a) subir `protector_spawn` a ~110 — cubre el cubo pero
      `protector` **no** tiene la excepción de «usar con la mano vacía», así que
      podría trabar botones y puertas de la Plaza y la discoteca; (b) volver a
      habilitar `voxelibre_protection` solo para esa área; (c) tapar la Plaza con
      protectores propios del admin. Verificar primero in-game si de verdad se
      puede romper algo ahí. → [`proteccion.md`](proteccion.md)
- [ ] **Aviso de entrada** — con dos cuentas: al entrar la segunda, la primera ve
      `<nombre> entrando...` arriba a la izquierda sin tapar el chat; se va a los
      6 s. Si choca con el chat en celular o PC, ajustar `POSITION.y` en
      `valdivia_aviso_entrada/init.lua`.
- [ ] **Pestaña «Mi casa»** (`valdivia_home`) — con una cuenta no-admin: abrir
      el inventario, pestaña de la cama: fijar casa, ir a casa (3 s quieto; moverse
      cancela), ir al spawn; pausa de 30 s entre viajes; no deja fijar casa en el
      área protegida de otro.
- [ ] **Cabina TP** (`valdivia_cabina`) — como admin: `/cabina`, colocar mirando
      hacia la puerta, ponerle nombre; con una cuenta no-admin: clic derecho →
      menú (solo las demás cabinas, sin duplicados ni `[TP]`) → viajar (3 s
      quieto) y llegar frente a la puerta mirando la cabina; el guía ya no
      ofrece viajes, solo conversa. Revisar que las texturas se vean como el
      dibujo de Gaspi. → [`cabina-tp.md`](cabina-tp.md)
- [ ] **Texturas de stairs/slabs** tras el remapeo v2 (`mcl_stairs:stair_oak` y
      similares). → [`current.md`](current.md)

## 2. Decisiones pendientes

### 2.1 Cuán hostil debe ser la ciudad (decidir junto al P0)

- [ ] **`mcl_mobs_overworld_threshold`: volver a `0`.** Recomendado. Deja el
      comportamiento de Minecraft: hostiles solo donde está realmente oscuro, y
      una antorcha basta para limpiar una casa. Quita el caso raro de zombis al
      mediodía adentro.
- [ ] **Creepers en una ciudad recreada.** `load_mod_wetlands_no_creeper = false`
      y `valdivia_spawn_fix` registra `mobs_mc:stalker` con `chance = 400` (el
      segundo más frecuente). `valdivia_no_explosions` impide que la explosión
      rompa nodos, pero **sí** hace daño al jugador, y un creeper dentro de una
      casa es la forma más rápida de que alguien pierda el inventario sin
      entender por qué. Opciones: activar `wetlands_no_creeper` en Valdivia, o
      sacar `stalker` de la lista de `valdivia_spawn_fix`.
- [ ] **Tasa de spawn global.** `valdivia_spawn_fix` usa los `chance` del juego
      base (zombie 1500, skeleton 800, spider 1000, stalker 400) pero **sin**
      restricción de bioma, así que spawnean en toda la ciudad por igual. Falta
      medir en juego si la cantidad resultante es razonable o excesiva.

### 2.2 Otras

- [ ] **Quitar el priv `teleport` a los jugadores.** Con él pueden `/teleport` a
      cualquier coordenada o junto a otro jugador al instante, lo que anula la
      espera/pausa de `/home` en supervivencia y deja aparecerse junto a
      cualquiera sin invitación. Los viajes quedan cubiertos por «Mi casa» y las
      cabinas TP. Cambio: quitar `teleport` de `PRIVS` en
      `valdivia_newplayer/init.lua`.
- [ ] **Radio de Protector para una ciudad pública.** Hoy 20 (cubo de 41). Con
      ese radio un jugador puede bloquear un edificio emblemático o una calle.
      Opciones: dejarlo y moderar con `/protector_remove`, o bajarlo a 8–10.
      → [`proteccion.md`](proteccion.md)
- [ ] **`valdivia_music`**: deshabilitado desde 2026-07-03 y ahora redundante con
      la música de VoxeLibre. Decidir entre borrarlo o marcarlo `DEPRECATED`.

## 3. Deuda técnica y limpieza

- [ ] **Los hostiles persiguen eternamente a un transeúnte inmortal**
      (`valdivia_transeuntes`, detectado el 2026-10-30). `mobs_mc:zombie` trae
      `attack_npcs = true` y el transeúnte es `type = "npc"`: el zombi lo elige
      como blanco y nunca lo suelta, porque el ataque solo termina si el blanco
      muere, sale de rango o se pierde de vista 15 s — y un inmortal que camina
      por calle abierta no cumple ninguna. Consecuencias: el zombi **deja de
      despawnear** (`spawning.lua:1252`, `state == "attack"` lo bloquea) y se
      acumulan de noche; los transeúntes actúan de señuelo invencible y absorben
      la agresión que iba al jugador; y el empujón los saca de su ruta. Arreglo
      propuesto: poner `attack_npcs = false` en los hostiles al cargar el mundo
      (en Valdivia no hay aldeanos ni golems que lo necesiten).
      → [`transeuntes.md`](transeuntes.md)
- [ ] **`valdivia_spawn_fix` no está en `luanti-valdivia.conf`.** Vive solo en el
      `world.mt` del VPS (línea 64), así que el `.conf` de git no refleja que el
      mod está activo y un mundo recreado desde el `.conf` nacería sin monstruos.
      Agregar `load_mod_valdivia_spawn_fix = true` al `.conf` con el comentario de
      por qué existe. Mismo chequeo para `valdivia_mob_debug`.
- [ ] **`/ayuda` de `server_rules` en Valdivia** menciona `/discord` (ya no
      existe en Valdivia) y comandos de Wetlands (`/arena_tp`, `/pos1`,
      `/protect_area`, santuarios). Hacer una versión propia de Valdivia (que
      apunte a `/gabo`, `/lugares`, las cabinas y el bloque protector).
- [ ] **Warning de `automobiles_lib`**: `Value passed to set_string is nil` en
      `automobiles_lib/inventory_management.lua:137`, repetido en los logs.
      Inofensivo hoy, pero Luanti avisa que será error en el futuro.
- [ ] **Restos de `voxelibre_protection` en `luanti-valdivia.conf`** (líneas
      211-216): el mod ya no se carga ni en el `.conf` ni en el `world.mt`
      (quitado del `world.mt` el 2026-10-12, commit `cb057827`). Dejar solo una
      línea de historia y borrar sus settings huérfanos
      (`voxelibre_protection_max_radius`, `_default_height`).
- [ ] **Nodos desconocidos restantes** del mapa Arnis: el scanner detecta mods
      faltantes, pero no renombres dentro de mods existentes.
      → [`operations/ARNIS_UNKNOWN_NODES.md`](operations/ARNIS_UNKNOWN_NODES.md)
- [ ] **Cerrar el incidente `incidente_spawning.md`** — sigue en estado
      «Investigando» con la resolución ya escrita al final (H1 confirmada,
      `valdivia_spawn_fix` desplegado y cargando 5/5 mobs en cada arranque).
      Marcarlo **Resuelto**.

## 4. Mundo y navegación

- [ ] **Mod `valdivia_borders`** (P2, ver sección 0): los bordes del área generada
      son vacío y los jugadores pueden caer. Detectar la cercanía al límite y
      devolverlos con un mensaje. → [`current.md`](current.md) (Fase 4.1)
- [ ] **Colocar la red de cabinas TP** en los puntos clave: Plaza (hecho),
      Catrico, Santa Elena, Huachocopihue, Costanera, Mercado Fluvial, Los
      Fundadores, Feria Fluvial, Universidad Austral, Puente Pedro de Valdivia.
      Sin red colocada, las cabinas no sirven de nada: un recién llegado no tiene
      cómo moverse. → [`cabina-tp.md`](cabina-tp.md)
- [ ] **Señalética de calles** (nombres OSM) y mapa con puntos de interés.

## 5. Contenido y experiencia

_Nada de esta sección es prioridad hasta cerrar la sección 0._

- [~] **Bailarines de la discoteca** (`/discoteca bailarin`, meta 4–6).
      → [`discoteca.md`](discoteca.md)
- [ ] **Voz del NPC guía**: reutilizar `play_npc_voice` de `wetlands_npcs`.
      → [`guia-spawn.md`](guia-spawn.md)
- [ ] **Más preguntas en la Trivia de Valdivia** (`wetlands_snes`), con datos
      reales de la ciudad: terremoto de 1960, Kunstmann, UACh, humedales.
      Barato de hacer y encaja con la identidad educativa.
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
| 2026-10-30 | Transeúntes (`valdivia_transeuntes`): gente que camina por las calles, sembrada sola alrededor de cada jugador y borrada al alejarse; sigue la calle por sondeo (sin pathfinding) usando el cielo abierto para no entrar a las casas → [`transeuntes.md`](transeuntes.md) |
| 2026-10-30 | Carabinero anti-grief (`valdivia_policia`): persigue y dispara con ballesta a quien agrede un área protegida ajena; no letal por defecto → [`policia.md`](policia.md) |
| 2026-10-28 | Consola SNES decorativa con dos mini-juegos (Atrapa al Topo + Trivia de Valdivia), desplegada y activa en el `world.mt` |
| 2026-10-12 | `voxelibre_protection` fuera del `world.mt` de Valdivia: queda solo Protector Redo |
| 2026-10-07 | DJ del Dreams: repertorio con reloj común, Billie Jean (fuera de git) y pedidos de temas que suenan para toda la pista → [`discoteca.md`](discoteca.md) |
| 2026-10-07 | Cabinas (y el pedestal de Wetlands) realmente indestructibles: VoxeLibre ignoraba `diggable = false`; dos jugadores rompieron cabinas |
| 2026-10-07 | Limpieza: los destinos son solo cabinas (sin lugares fijos ni duplicados, sin prefijo `[TP]`); el NPC guía solo conversa |
| 2026-10-07 | Cabina TP (diseño de Gaspi) + núcleo de viajes compartido por cabinas, guías y «Mi casa» (`valdivia_cabina`); `valdivia_teleporter` eliminado → [`cabina-tp.md`](cabina-tp.md) |
| 2026-10-04 | Pestaña «Mi casa» en el inventario (`valdivia_home`): ir a mi casa, ir al spawn, fijar mi casa; `/sethome`, `/home`, `/spawn` |
| 2026-10-04 | Fix: el admin `gabo` recibe todos los privilegios registrados al entrar (`valdivia_newplayer`) |
| 2026-09-21 | Monstruos vuelven a aparecer: `valdivia_spawn_fix` re-registra zombie, baby_zombie, skeleton, spider y stalker **sin** restricción de bioma (el mapa Arnis/singlenode no tiene biomas de VoxeLibre) → [`incidente_spawning.md`](incidente_spawning.md) |
| 2026-09-21 | `/generar_mina <radio> <profundidad>` implementado en `valdivia_utils` (rellena el subsuelo vacío con deepslate y vetas) |
| 2026-09-16 | Aviso en pantalla `<nombre> entrando...` para los conectados (`valdivia_aviso_entrada`) |
| 2026-09-16 | Protector Redo para jugadores, conviviendo con `voxelibre_protection` → [`proteccion.md`](proteccion.md) |
| 2026-09-16 | Vuelve la música de VoxeLibre; la discoteca la silencia solo adentro → [`discoteca.md`](discoteca.md) |
