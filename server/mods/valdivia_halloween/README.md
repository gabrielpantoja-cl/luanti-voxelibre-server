# valdivia_halloween — "Valdivia Infectada"

Mega-evento de Halloween para **Valdivia (puerto 30001)** con **interruptor de
admin**. El mod se carga siempre, pero no hace absolutamente nada hasta que
alguien con priv `server` escribe `/halloween on`, y `/halloween off` devuelve
el mundo a como estaba.

Solo Valdivia: `load_mod_valdivia_halloween = true` vive únicamente en
`server/config/luanti-valdivia.conf` (y en el `world.mt` del VPS).

---

## Qué enciende el evento

| Pieza | Qué hace |
|---|---|
| **Noches largas** | La noche pasa 3× más lenta que el día (`noche_factor`). El día queda intacto. |
| **Luna de sangre** | Luna roja enorme, estrellas rojas, cielo y niebla de sangre. Se anuncia por chat al caer la noche. |
| **Edificios ensangrentados** | Manchas de sangre que aparecen en muros, pisos y techos a medida que los jugadores caminan, más telarañas en los rincones. |
| **Infestación** | Zombies que nacen en las calles cerca de cada jugador, fuera de su vista, y se borran al alejarse. |
| **Cacería** | Los zombies persiguen a los transeúntes; los transeúntes pelean o arrancan; el guía del spawn los defiende a golpes. |
| **Infección** | Un transeúnte que pierde toda su vida virtual **no muere**: desaparece entre humo y queda un zombie aldeano en su lugar. |

## Comandos

Todos piden priv `server`.

```
/halloween              estado del evento (manchas, zombies, hora)
/halloween on           enciende todo
/halloween off          apaga todo y limpia la sangre
/halloween sangre       pinta manchas alrededor tuyo ahora mismo
/halloween limpiar      borra solo la sangre, sin apagar el evento
/halloween purga        elimina los zombies del evento, sin apagarlo
```

---

## Tres invariantes de diseño

### A. Todo es reversible

El mapa de Valdivia es un `map.sqlite` de ~420 MB generado con Arnis desde
OpenStreetMap: **no se puede regenerar**. Por eso la sangre se escribe **solo
sobre nodos `air`**, nunca encima de un nodo del mapa, y cada posición queda
anotada en `worldpath/valdivia_halloween.json`. Apagar el evento devuelve cada
una de esas posiciones a `air` y nada más. Si un jugador ya picó una mancha o
construyó encima, esa posición no se toca: su trabajo manda.

El archivo se graba también cada 30 s, no solo al apagar: en este VPS el
contenedor siempre muere con `SIGKILL` y `register_on_shutdown` no alcanza a
correr (ver `AGENTS.md`).

### B. Nada se guarda en el mapa

Los zombies del evento nacen con `static_save = false` y con la marca
`_halloween_zombie`, igual que los transeúntes. Un apagón a mitad del evento no
puede dejar hordas plantadas para siempre en la ciudad, y no hay ningún roster
que reconciliar al arrancar.

### C. Sin pathfinding propio

El A\* de `mcl_mobs` se traba en los patios y escaleras de la ciudad de Arnis
(documentado en `valdivia_policia` y `valdivia_transeuntes`). Aquí se usan los
mismos recursos ya probados:

- **Sondeo de calle** (`es_calle`) para sembrar zombies y para elegir por dónde
  arranca un transeúnte. La prueba de cielo abierto se hace con
  `get_natural_light(p, 0.5)` — mediodía fijo — a propósito: la pregunta es
  *"¿hay cielo encima?"*, no *"¿qué hora es?"*. Sin ese `0.5`, de noche toda la
  ciudad pasaría por interior y no se sembraría un solo zombie.
- **Reubicación** del zombie cerca de su presa cuando lleva 3,5 s sin
  acercarse, como si hubiera dado la vuelta a la manzana.

---

## Cómo persigue un zombie a un NPC

No se reimplementa la persecución: se le **entrega el blanco** a `mcl_mobs` con
su propio `mob:do_attack(objeto)`, que es la vía que usa el propio VoxeLibre
cuando un zombie va por un aldeano. Así la cacería usa las animaciones, los
sonidos y los golpes de siempre. Si esa llamada fallara (otra versión, otro
nombre), se cae a la asignación directa de `self.attack` / `self.state` y se
loguea un `warning` una sola vez.

## Cómo pelea un transeúnte

`valdivia_transeuntes` **no tiene combate y no se le metió uno**: ese mod tiene
que seguir funcionando igual con el evento apagado. Lo que hace este mod es
**tomarle el control** mientras dura la pelea.

El único cambio en `valdivia_transeuntes/init.lua` son dos líneas al principio
de su `do_custom`:

```lua
if self._halloween then return end
```

Con el evento apagado esa marca no existe nunca, así que el costo es una
comparación por tick. Mientras la marca está puesta, este mod le maneja la
velocidad, el giro y la animación; al soltarlo, el transeúnte retoma su
caminata como si nada.

## Por qué la vida de los transeúntes es virtual

Los transeúntes son inmortales de verdad (`armor_groups = {immortal = 1}`,
HP 10000), y eso **no se toca**: es lo que impide que un jugador los mate a
golpes. La "vida" frente a los zombies la lleva este mod en
`_hw_hp`, y la mordida se resuelve por cercanía y reloj, no detectando el
`punch` — `mcl_mobs` golpea cuando quiere y el golpe real no deja rastro
legible en un mob inmortal.

Al llegar a cero el transeúnte **no muere**: se infecta. Nadie ve morir a
nadie, que es lo que corresponde en un servidor para chicos de 7+, y el susto
queda igual.

---

## Qué NO hace

- **No le hace daño a los jugadores.** En Valdivia los jugadores tienen
  `mcl_enable_creative_mode = true`, y VoxeLibre anula el `punch` contra un
  jugador en modo creativo (es lo mismo que documentó `valdivia_policia` el
  2026-10-30). Los zombies los persiguen y los asustan, pero el daño real va
  contra los transeúntes.
- **No toca `time_speed`.** Ese ajuste se lee al arrancar, cambiarlo en caliente
  no es fiable entre versiones, y además alargaría también el día. La noche se
  alarga devolviendo el reloj hacia atrás una vez por segundo, y solo de noche.
- **No reparte sangre por el inventario creativo.** Los nodos de mancha están en
  `not_in_creative_inventory`: sangre colocada a mano sería sangre que
  `/halloween off` no sabe borrar.

## Texturas

Las genera `tools/generate_textures.py` (Pillow, semilla fija para que dos
corridas den el mismo PNG):

```bash
python tools/generate_textures.py
python tools/generate_textures.py --preview /tmp/lamina.png
```

- `valdivia_halloween_sangre1..3.png` — 16×16, calcomanías con fondo
  transparente y borde irregular. Se dibujan con `drawtype = "signlike"` +
  `paramtype2 = "wallmounted"`, o sea una lámina plana pegada a la cara del nodo
  sólido vecino: una misma mancha sirve para piso, pared o techo según su
  `param2`.
- `valdivia_halloween_luna.png` — 64×64, la luna de sangre.
- `valdivia_halloween_particula.png` — 8×8, la gota de los particlespawner.

## Ajustes (`luanti-valdivia.conf`)

| Ajuste | Por defecto | Qué controla |
|---|---|---|
| `valdivia_halloween_noche_factor` | 3 | cuántas veces más larga es la noche |
| `valdivia_halloween_zombies_max` | 45 | tope global de zombies del evento |
| `valdivia_halloween_zombies_por_jugador` | 8 | cuántos rondan a cada jugador de noche (⅓ de día) |
| `valdivia_halloween_max_manchas` | 2500 | tope de manchas colocadas |
| `valdivia_halloween_decor_intervalo` | 6 | segundos entre rondas del pintor |
| `valdivia_halloween_decor_por_ronda` | 4 | manchas por ronda y jugador |
| `valdivia_halloween_peaton_hp` | 20 | vida virtual del transeúnte |
| `valdivia_halloween_peaton_danio` | 3 | lo que pega un transeúnte |
| `valdivia_halloween_zombie_danio` | 3 | lo que muerde un zombie |
| `valdivia_halloween_miedo` | 0.4 | probabilidad de arrancar en vez de pelear |
| `valdivia_halloween_luz_min` | 14 | luz natural a mediodía para contar como calle |

## Archivos

```
init.lua       estado, persistencia, sondeo de calle, ganchos y /halloween
nodes.lua      los tres nodos de mancha + la partícula de gota
cielo.lua      luna de sangre, cielo/niebla rojos y la noche larga
decor.lua      el pintor de edificios y el limpiador por tandas
zombies.lua    la infestación (sembrado, censo, purga)
combate.lua    el director: cacería, pelea, huida e infección
```
