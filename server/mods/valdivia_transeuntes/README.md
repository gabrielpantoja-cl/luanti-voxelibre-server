# valdivia_transeuntes

Gente que camina por las calles de Valdivia (puerto **30001**). No son guías ni
comerciantes: son **figurantes**. Aparecen solos cerca de cada jugador, caminan
por la calle, se detienen a mirar, y se borran cuando ya no hay nadie cerca.

Solo Valdivia. `load_mod_valdivia_transeuntes = true` en
`server/config/luanti-valdivia.conf` **y** en el `world.mt` del VPS.

---

## Las dos decisiones que explican el mod

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

---

## Dónde nacen

Tres filtros y dos reglas de aparición. Los tres filtros son necesarios:

| Filtro | Qué descarta |
|---|---|
| `es_calle` | interiores, agua, nodos no caminables |
| `tiene_suelo_macizo` | **techos** — un techo plano es caminable y tiene cielo; lo delata el hueco (el interior del edificio) 2–4 nodos más abajo |
| `es_calle_ancha` (≥3 de 4 vecinos) | patios de un nodo, cornisas, la orilla del río |

Y las dos reglas de aparición:

- Nacen a **30–45 nodos** del jugador.
- Solo donde `line_of_sight` del jugador al candidato es **falsa**: no aparecen
  delante de sus ojos.

De noche (antes de 0.25 o después de 0.78) el cupo por jugador baja a la mitad.

## Rendimiento

Un solo `globalstep` para todo el mod, cada 5 s, que siembra y borra. Las
decisiones de rumbo corren cada 0.4 s por NPC, no cada tick (serían 8 sondeos
20 veces por segundo). Un NPC solo está vivo si su mapblock está activo, o sea
a ≤ 64 nodos de un jugador (`active_block_range = 4`).

Si el jugador está bajo tierra o encerrado (luz natural < 8) ni se intenta
sembrar: los 25 sondeos serían puro gasto.

## Comandos (admin, priv `server`)

| Comando | Qué hace |
|---|---|
| `/transeunte [tipo]` | Coloca uno en tu posición. Sin argumento, al azar. |
| `/transeuntes` | Cuántos hay vivos, quiénes y dónde. |
| `/transeuntes limpiar` | Los borra a todos. |
| `/transeunte_scan` | Explica si donde estás parado cuenta como calle. |

`/transeunte_scan` es la herramienta de calibración: párate en una calle, en la
Plaza, **dentro de una casa** y **sobre un techo**, y compara las cuatro
salidas. Si un techo da `suelo macizo: true`, hay que endurecer ese filtro.

## Los seis tipos

`vecino`, `escolar`, `estudiante`, `feriante`, `pescador`, `turista` — dos
skins cada uno, nombre chileno al azar, y una frase por tipo al hacerle clic
derecho. El nombre y el oficio salen en el `infotext` al apuntarlos.

Las skins vienen de mc-skins.net, convertidas a 64×32 con
`tools/convert_skin.py` (hornea la capa de overlay antes de recortar, que es lo
que el recorte simple borra). Detalle y fuentes en
[`raw_skins/FUENTES.md`](raw_skins/FUENTES.md).

## Ajustes

Todos en `luanti-valdivia.conf` con prefijo `valdivia_transeuntes_`:
`max` (15), `por_jugador` (5), `dist_min` (30), `dist_max` (45),
`dist_borrar` (70), `velocidad` (1.5), `intervalo` (5), `luz_min` (14).

## Pitfalls que ya están resueltos acá

- **`walk_chance = 0`** es obligatorio, o el FSM de `mcl_mobs` pisa nuestro
  `set_velocity` y el NPC avanza a tirones.
- **`collisionbox` va en `initial_properties` Y en la raíz**, o VoxeLibre
  loguea `Mob without collisionbox` al activarse.
- **`jump = false`**: con salto se treparían a los techos y a los autos.
- **El tipo se asigna después de `add_entity`**, así que `on_activate` no puede
  dar por sentado que ya existe. Un NPC sin tipo se borra recién al segundo de
  vida, no al instante.
- **Inmortales** (`armor_groups.immortal`, `do_punch` devuelve `false`): la
  ciudad es pública y un figurante matable sería un blanco.

→ Documentación de usuario: [`docs/02-VALDIVIA-30001/transeuntes.md`](../../../docs/02-VALDIVIA-30001/transeuntes.md)
