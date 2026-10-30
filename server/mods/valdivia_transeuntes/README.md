# valdivia_transeuntes

Gente que camina por las calles de Valdivia (puerto **30001**). No son guías ni
comerciantes: son **figurantes**. Aparecen solos cerca de cada jugador, caminan
por la calle, se detienen a mirar, y se borran cuando ya no hay nadie cerca.

Solo Valdivia. `load_mod_valdivia_transeuntes = true` en
`server/config/luanti-valdivia.conf` **y** en el `world.mt` del VPS.

---

## Las tres decisiones que explican el mod

### 1. No hay pathfinding: siguen la calle por sondeo

El A\* de `mcl_mobs` se traba en los patios y escaleras de la ciudad generada
con Arnis — ya nos pasó con `valdivia_policia`, que terminó resolviéndolo
reubicando al policía en vez de buscarle ruta. Un peatón no puede hacer eso: un
vecino que se teletransporta se ve como un bug.

En vez de calcular una ruta, el transeúnte mira lo que tiene adelante y decide:

1. Sondea 1.6 nodos adelante en su rumbo. Si se puede pisar → sigue recto.
2. Si no → prueba los ocho rumbos y toma el **giro más pequeño** que sirva.
   Entre izquierda y derecha empatadas, sortea.
3. Con 10 % de probabilidad dobla igual aunque el frente esté libre — así
   dobla en las esquinas en vez de caminar en línea recta eternamente.
4. Con 4 % se queda pausado 2–6 s mirando.
5. Si **ningún** rumbo sirve (lo encerraron, le taparon la calle), se borra en
   vez de quedar vibrando contra un muro.

La pregunta «¿esto es calle?» se responde sin conocer con qué nodos Arnis
pavimentó la ciudad:

```lua
suelo caminable y no líquido
+ dos nodos de aire encima
+ get_natural_light(p, 0.5) >= 14      -- ¿hay cielo?
```

Ese `0.5` (mediodía) es deliberado: la pregunta es «¿hay cielo encima?», no
«¿qué hora es?». Sin fijarlo, de noche toda la ciudad pasaría el filtro y los
transeúntes se meterían a las casas.

### 2. Son efímeros

`static_save = false`: nunca se escriben en el mapblock. Nacen, caminan, se
borran. No hay roster que reconciliar ni huérfanos que limpiar después de un
apagón — y acá `docker stop` **siempre** termina en SIGKILL, así que nada que
dependa de un guardado limpio es confiable.

### 3. Cada uno es alguien

No hay "tipos" con skins intercambiables. Hay un **elenco de 60 personas**, y
cada una tiene su nombre, su oficio, su textura y sus frases. El mod lleva un
registro de quién está en la calle y nunca deja repetida a la misma persona,
así que dos transeúntes jamás se ven iguales ni dicen lo mismo.

---

## Dónde nacen

Tres filtros y dos reglas de aparición. Los tres filtros son necesarios:

| Filtro | Qué descarta |
|---|---|
| `es_calle` | interiores, agua, nodos no caminables |
| `tiene_suelo_macizo` | **techos** — un techo plano es caminable y tiene cielo; lo delata el hueco (el interior del edificio) 2–4 nodos más abajo |
| `es_calle_ancha` (≥3 de 4 vecinos) | patios de un nodo, cornisas, la orilla del río |

Y las dos reglas de aparición:

- Nacen a **22–45 nodos** del jugador.
- Solo donde `line_of_sight` del jugador al candidato es **falsa**: no aparecen
  delante de sus ojos.

De noche (antes de 0.25 o después de 0.78) el cupo por jugador baja a la mitad.

## Rendimiento

Un solo `globalstep` para todo el mod, cada 3 s, que siembra, borra y rota la
caché. Las decisiones de rumbo corren cada 0.4 s por NPC, no cada tick (serían
8 sondeos 20 veces por segundo). Un NPC solo está vivo si su mapblock está
activo, o sea a ≤ 64 nodos de un jugador (`active_block_range = 4`).

Si el jugador está bajo tierra o encerrado (luz natural < 8) ni se intenta
sembrar: los 25 sondeos serían puro gasto.

Dos mecanismos son los que permiten tener **40 en la calle** en vez de 15:

**Caché generacional de calle.** `es_calle` cuesta cuatro llamadas al motor
(tres `get_node` y un `get_natural_light`), y en el peor caso una sola decisión
de rumbo hace ~190 de esas llamadas. Con decenas de NPC sondeando los mismos
nodos de la misma vereda, la respuesta se repite miles de veces por minuto. La
ciudad es prácticamente estática, así que se guarda.

Son **dos generaciones** y no un timestamp por entrada a propósito: invalidar
al cavar o construir obligaría a borrar una caja entera alrededor de cada nodo
tocado (la luz se propaga), y un jugador construyendo haría trizas la caché.
En vez de eso, cada 25 s la generación actual pasa a ser la vieja y se abre una
nueva: lo consultado seguido se promueve solo, lo que no se usa se cae, y un
cambio en el mapa se nota a más tardar en dos ciclos. Para peatones de fondo
ese retardo es invisible y la memoria queda acotada sola.

**LOD por distancia.** Si nadie tiene al NPC a menos de 36 nodos, decide rumbo
cada 2 s en vez de cada 0.4 s. Sigue caminando a la misma velocidad: solo
piensa cinco veces menos seguido, y nadie lo está viendo doblar.

## Comandos (admin, priv `server`)

| Comando | Qué hace |
|---|---|
| `/transeunte [nombre]` | Coloca a alguien en tu posición. Sin argumento, uno libre al azar. Si esa persona ya anda en la calle, lo dice y no la clona. |
| `/transeuntes` | Quiénes andan en la calle ahora y dónde. |
| `/transeuntes lista` | El elenco completo, marcando con `*` a los que están en la calle. |
| `/transeuntes limpiar` | Los borra a todos. |
| `/transeunte_scan` | Explica si donde estás parado cuenta como calle (y cuántos nodos lleva la caché). |

`/transeunte_scan` es la herramienta de calibración: párate en una calle, en la
Plaza, **dentro de una casa** y **sobre un techo**, y compara las cuatro
salidas. Si un techo da `suelo macizo: true`, hay que endurecer ese filtro.

## El elenco

**60 personas, cada una distinta.** No hay "tipos" con skins intercambiables:
cada fila de `PERSONAJES` (en `init.lua`) es alguien con su nombre, su oficio,
**su** textura y **sus** tres frases. El mod lleva un registro `en_uso` y jamás
deja a la misma persona aparecer dos veces al mismo tiempo, así que dos
transeúntes nunca se ven iguales ni dicen lo mismo.

La textura se deduce del nombre: `valdivia_transeunte_<nombre en minúscula>.png`.
Sumar a alguien es bajar un skin, dejar el PNG con ese nombre y agregar la fila.

Oficios representados: bombero, cocinero, panadera, doctora, enfermera,
oficinista, obrero, campesino, jardinera, deportista, jubilado, guardaparques,
pescador, feriante, escolar, estudiante, turista y vecinos del barrio.

**Regla de las marcas**: si un skin trae algo que lo identifica, el nombre se
amarra a esa marca. La polera de Hugo lleva una **"H"** dibujada, y una de sus
frases es justamente explicarla — ese skin es suyo y de nadie más. Lo mismo
aplica a cualquier skin futuro con inicial, número o nombre visible.

Las skins vienen de mc-skins.net. Los originales 64×64 viven en
`server/skins/raw/` y la procedencia de cada uno en `server/skins/skins.json`
— la fuente única de todos los skins humanoides de Valdivia. Los 64×32 se
regeneran con `python scripts/rebuild-skins.py`. Reglas del elenco en
[`SKINS.md`](SKINS.md); de dónde bajar más, en
`docs/00-SHARED/mods/SKIN_SOURCES.md`.

## Ajustes

Todos en `luanti-valdivia.conf` con prefijo `valdivia_transeuntes_`:
`max` (40), `por_jugador` (12), `dist_min` (22), `dist_max` (45),
`dist_borrar` (70), `velocidad` (1.5), `intervalo` (3), `luz_min` (14),
`dist_cerca` (36, umbral del LOD).

`max` no puede pasar del tamaño del elenco (60): más allá de eso no quedaría
nadie libre que sembrar.

## Pitfalls que ya están resueltos acá

- **`walk_chance = 0`** es obligatorio, o el FSM de `mcl_mobs` pisa nuestro
  `set_velocity` y el NPC avanza a tirones.
- **`collisionbox` va en `initial_properties` Y en la raíz**, o VoxeLibre
  loguea `Mob without collisionbox` al activarse.
- **`jump = false`**: con salto se treparían a los techos y a los autos.
- **El personaje se asigna después de `add_entity`**, así que `on_activate` no
  puede dar por sentado que ya existe. Un NPC sin personaje se borra recién al
  segundo de vida, no al instante.
- **La pausa del clic derecho se fija, no se acumula** (`math.max`, no `=`).
  Mirándolos en producción, un jugador clickeó 20 veces en 17 s y cada clic
  reiniciaba los 4 s de pausa: el NPC quedó clavado en el mismo nodo todo ese
  rato. Por lo mismo hablar y reclamar tienen cooldown propio (3 s y 5 s), o
  son veinte líneas de chat idénticas.
- **Inmortales** (`armor_groups.immortal`, `do_punch` devuelve `false`): la
  ciudad es pública y un figurante matable sería un blanco.

→ Documentación de usuario: [`docs/02-VALDIVIA-30001/transeuntes.md`](../../../docs/02-VALDIVIA-30001/transeuntes.md)
