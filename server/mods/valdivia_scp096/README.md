# valdivia_scp096 — SCP-096, "el Tímido"

Solo Valdivia (30001). Criatura alta y pálida que aparece **de noche** sentada
en alguna calle, llorando. Mientras nadie le vea la cara, es inofensiva.

## Reglas

- **Verle la cara** = mirarla de frente: tu mirada apunta a su cabeza (~20°),
  ella está más o menos de cara a ti y no hay paredes en medio, a ≤48 nodos.
  Verla de espaldas no cuenta. **Pegarle** también la enfurece.
- Grita 5 s (brazos agitándose, partículas rojas) y luego **corre a 6,5 n/s**
  (más rápido que un jugador corriendo) tras quien la vio. Si se traba o
  quedas a más de 30 nodos, **reaparece a tu lado**: nada la detiene.
- Al alcanzarte **te mata** (`valdivia_scp096_letal = 0` → te deja con medio
  corazón) y desaparece. Si en 120 s no te alcanza, se rinde.
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
