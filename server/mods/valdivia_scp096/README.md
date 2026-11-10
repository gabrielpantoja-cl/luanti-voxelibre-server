# valdivia_scp096 — SCP-096, "el Tímido"

Solo Valdivia (30001). Criatura alta y pálida que aparece **de noche** sentada
en alguna calle, llorando. Mientras nadie le vea la cara, es inofensiva.

## Reglas

- **Verle la cara** = mirarla de frente: tu mirada apunta a su cabeza (~20°),
  ella está más o menos de cara a ti y no hay paredes en medio, a ≤48 nodos.
  Verla de espaldas no cuenta. **Pegarle** también la enfurece.
- Se pone de pie y grita 5 s sacudiendo la cabeza; luego **corre a 6,5 n/s**
  (más rápido que un jugador corriendo) tras quien la vio. Con vista directa
  va en línea recta; si hay edificios de por medio usa `minetest.find_path`
  (A* del motor) y salta lo que se le cruce.
- Solo si lleva 8 s sin acortar distancia (o estás a más de 60 nodos) **y no
  la estás mirando**, reaparece escondida a 12–20 nodos. Nunca aparece al lado.
- Al alcanzarte da un zarpazo y **te mata** (`valdivia_scp096_letal = 0` → te
  deja con medio corazón), se vuelve a sentar a llorar y se esfuma a los 6 s.
  Si en 120 s no te alcanza, se rinde.

## Física y silueta (lecciones)

- **`mcl_mobs` frena la velocidad horizontal ×0,7 en cada paso**, antes de
  `do_custom` (`check_death_and_slow_mob`, `physics.lua:247`). Si aceleras
  leyendo `get_velocity()`, el tope real queda muy por debajo del pedido
  (6,5 → ~4,2 n/s). Aquí la velocidad se lleva en `_vx/_vz` y se reescribe
  entera cada paso. `valdivia_policia` tiene el mismo problema.
- Silueta con `set_bone_override` sobre `mcl_armor_character.b3d`: piernas
  ×1,45, brazos ×1,8 y más delgados, torso ×0,8 de ancho, cabeza ×1,15 de
  alto. De pie, la cadera (`Body_Control`, 6,75 u) sube 6,75·0,45 u para que
  las piernas no se entierren; sentado vuelve a 0. Clientes < 5.9 la ven normal.
- Es inmortal, no suelta nada, `static_save = false` (un reinicio no deja
  ninguno en el mapa). Sentada más de 5 min o sin jugadores a 90 nodos, se esfuma.

## Aparición

Cada 45 s, de noche, si no hay otra viva: 20 % de probabilidad de que aparezca
a 20–34 nodos de un jugador al azar, **en la calle** (cielo abierto, luz
natural ≥ 14 a mediodía) y **fuera de su vista**. A la misma víctima no le
vuelve a aparecer por 10 min.

## Admin (`server`)

| Comando | Qué hace |
|---|---|
| `/scp096 [jugador]` | La hace aparecer a 8–14 nodos, **de espaldas** al jugador |
| `/scp096 limpiar` | Retira todas |
| `/scp096 auto on\|off` | Aparición nocturna (persiste en mod_storage) |
| `/scp096 info` | Vivas, auto, letal, si es de noche |

Ajustes (`valdivia_scp096_*` en `luanti-valdivia.conf`): `letal`, `auto`,
`prob`, `velocidad`, `furia`, `caza_max`, `intervalo`, `vida`, `max`, `cooldown`.

## Recursos

- Skin: `mcs:scp-096-crying-6559da` (mc-skins.net), fila `scp096` en
  `server/skins/skins.json`, original en `server/skins/raw/scp096.png`.
- Partículas: `tools/generate_textures.py`.
- Sonidos: de `mobs_mc` (enderman: `random` = llanto, `death` = grito,
  `teleport_src` = reaparición), con tono bajado.
