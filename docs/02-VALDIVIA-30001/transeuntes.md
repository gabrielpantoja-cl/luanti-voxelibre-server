# Transeúntes de Valdivia (puerto 30001)

**Mod:** `server/mods/valdivia_transeuntes` · **Activo desde:** 2026-10-30

Gente que camina por las calles de la ciudad. Hasta ahora Valdivia tenía NPCs
**quietos**: los guías en las plazas y los bailarines del Dreams. Faltaba lo
que hace que una ciudad se sienta habitada — alguien caminando por la vereda
cuando doblas la esquina.

---

## Qué ve el jugador

Caminan por las calles a paso de peatón (1.5 nodos/s; un jugador corre a 4.3),
doblan en las esquinas, se detienen a ratos a mirar. Al apuntarlos sale su
nombre y oficio («Camila — feriante»). Clic derecho y te dicen algo de la
ciudad. No se les puede pegar ni matar.

Son **seis tipos**, dos skins cada uno:

| Tipo | Quién es |
|---|---|
| `vecino` | Vecina o vecino de a pie |
| `escolar` | Escolar con uniforme, siempre atrasado |
| `estudiante` | Estudiante de la Austral |
| `feriante` | Del Mercado Fluvial |
| `pescador` | De impermeable amarillo |
| `turista` | Vino a conocer la ciudad |

Las frases hablan del río, la lluvia, la feria, el Parque Saval, el Torreón:
contenido real de Valdivia, apropiado para niños.

## Cómo aparecen y desaparecen

No están puestos a mano en ningún lado. El mod los **siembra** alrededor de
cada jugador:

- Nacen a **30–45 nodos**, siempre **fuera de la vista** (`line_of_sight`
  falsa), en un punto que pase los tres filtros de calle.
- Hasta **5 por jugador** (la mitad de noche), con un tope global de **15**.
- Se **borran** al quedar a más de 70 nodos de todo jugador conectado.
- No se guardan en el mapa (`static_save = false`): un reinicio no deja
  huérfanos ni hay nada que reconciliar.

## Por qué no se meten a las casas

La prueba clave es el **cielo abierto**:

```
suelo caminable y no líquido
+ dos nodos de aire encima
+ get_natural_light(pos, 0.5) >= 14
```

Se pide la luz natural a **mediodía fijo** aunque sea de noche: la pregunta es
«¿hay cielo encima?», no «¿qué hora es?». Un interior nunca la pasa, ni con la
puerta abierta. Y como no saltan (`jump = false`) y suben a lo más un nodo, no
pueden llegar a un techo ni por una escalera.

Para los techos al momento de **nacer** hay un filtro aparte: bajo una calle
hay tierra, bajo un techo hay el hueco del edificio 2–4 nodos más abajo.

## Problema conocido: los hostiles los persiguen para siempre

**Estado:** pendiente, sin arreglar (anotado el 2026-10-30). Afecta solo a las
noches de Valdivia; de día el sol quema a los zombis y el efecto desaparece.

Un zombi que ve a un transeúnte se le pega y **no lo suelta nunca**. Son dos
piezas de VoxeLibre que se juntan mal con un NPC inmortal:

- `mobs_mc/zombie.lua:104` trae `attack_npcs = true`, y el transeúnte está
  registrado como `type = "npc"` sin ningún filtro, así que el zombi lo elige
  como blanco igual que a un aldeano (`mcl_mobs/combat.lua:342-344`).
- El estado de ataque se suelta solo en tres casos
  (`mcl_mobs/combat.lua`, `do_states_attack`): el blanco sale del rango de
  tracking, queda con `hp <= 0`, o se pierde de vista por 15 s
  (`TIME_TO_FORGET_TARGET`). El transeúnte nunca baja de HP —`do_custom` le
  restituye los 10000 en cada tick— y camina por calle abierta, o sea con línea
  de vista limpia. Ninguna de las tres se cumple nunca.

Por qué importa, de lo más grave a lo menos:

1. **El zombi deja de despawnear.** `mcl_mobs/spawning.lua:1252` lo dice
   explícito: `despawn_allowed({can_despawn = true, state = "attack"}) == false`.
   Un hostil enganchado queda inmune a la purga natural, así que en una noche de
   juego los zombis se van **acumulando** en el centro en vez de rotar.
2. **Los transeúntes funcionan de señuelo invencible.** `monster_attack` elige
   el blanco más cercano entre jugador y NPC; con 5–15 transeúntes sembrados a
   30–45 nodos del jugador, buena parte de los hostiles se queda pegada al
   figurante y nunca llega al jugador. La noche deja de ser peligrosa sin que
   nadie lo haya decidido.
3. **Rompe la caminata.** El zombi corre a 1.8 y el transeúnte va a 1.5: lo
   alcanza, lo golpea y lo empuja fuera de su ruta de sondeo — puede terminar
   metido en una casa o en el río, justo lo que los filtros de calle buscan
   evitar.

Se auto-limita en dos casos y por eso no es un incendio: de día los zombis se
queman, y si el jugador se aleja más de 70 nodos el transeúnte se borra y el
zombi hace `clear_aggro`.

### Arreglo propuesto

Apagar `attack_npcs` en los hostiles del mundo, después de que cargue
`mobs_mc` — una línea por mob, costo cero en runtime y sin estado de ataque que
limpiar:

```lua
for _, nombre in ipairs({"zombie", "baby_zombie", "husk", "drowned"}) do
    local def = minetest.registered_entities["mobs_mc:" .. nombre]
    if def then def.attack_npcs = false end
end
```

En Valdivia no hay aldeanos ni golems, así que no se pierde ninguna
interacción legítima. La alternativa —barrer las entidades vecinas en cada paso
buscando `.attack == self.object` y limpiarles el aggro— es más quirúrgica pero
cuesta en cada tick y el zombi se vuelve a enganchar al instante.

### Hallazgo vecino (no es el mismo bug)

`count_mobs_all` (`mcl_mobs/spawning.lua:144`) cuenta los mobs por
`spawn_class`, y los transeúntes son `passive`: los 15 ocupan el cupo
`mcl_mob_cap_animal` (10 cerca del jugador). Hoy da igual porque
`valdivia_spawn_fix` solo registra hostiles, pero si algún día se quieren
animales en la ciudad, los transeúntes se los comen.

## Comandos de admin

| Comando | Qué hace |
|---|---|
| `/transeunte [tipo]` | Coloca uno donde estás parado |
| `/transeuntes` | Cuántos hay vivos, quiénes y dónde |
| `/transeuntes limpiar` | Los borra a todos |
| `/transeunte_scan` | Diagnostica si ese punto cuenta como calle |

## Ajustes (`luanti-valdivia.conf`)

`valdivia_transeuntes_max` (15), `_por_jugador` (5), `_dist_min` (30),
`_dist_max` (45), `_dist_borrar` (70), `_velocidad` (1.5), `_intervalo` (5),
`_luz_min` (14).

Si la ciudad se siente vacía, sube `_por_jugador` y `_max`. Si lagea o se ve
demasiada gente para una ciudad chica, bájalos. Se pueden cambiar en caliente
editando el `.conf` y reiniciando el contenedor.

## Pendiente de verificar en el juego

Seguimiento en [`ROADMAP.md`](ROADMAP.md).

## Detalle técnico

Arquitectura, pitfalls y el porqué de cada filtro:
[`server/mods/valdivia_transeuntes/README.md`](../../server/mods/valdivia_transeuntes/README.md).
Origen y conversión de las skins:
[`SKINS.md`](../../server/mods/valdivia_transeuntes/SKINS.md) y la procedencia
de cada skin en [`server/skins/skins.json`](../../server/skins/skins.json).
