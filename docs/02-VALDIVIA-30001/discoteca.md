# Discoteca del Hotel Dreams — Valdivia

Discoteca interactiva en el Hotel Dreams, cerca del spawn de Valdivia.
Implementada con el mod `valdivia_discoteca` (puerto 30001).

Cuando un jugador entra a la zona configurada:
- La música arranca automáticamente (stream per-player a volumen constante en todo el salón)
- Luces de colores ciclan desde el techo cada 2 segundos
- El DJ y los bailarines animan la pista con coreografías

### Detección de zona (fix 2026-07-04)

La zona es un AABB, pero el chequeo vertical usa un **colchón**: `zona_min.y − 2`
a `zona_max.y + 3`. Motivo: `get_pos()` devuelve los *pies* del jugador, que al
caminar por el piso quedan ~0.5 nodos por debajo del `y` redondeado que guardó
`/discoteca zona_min` — por eso antes había que saltar o subirse a la mesa del
DJ para activar la música. Con el colchón, la música arranca al cruzar la
puerta y no se corta al saltar. El poll de posición corre cada 0.5 s
(constantes `ZONE_Y_PAD_BELOW`, `ZONE_Y_PAD_ABOVE`, `POLL_INTERVAL` en `init.lua`).

---

## Coordenadas y zona

| Campo | Coordenadas | Comando usado |
|-------|-------------|---------------|
| `zona_min` (esquina inferior) | `(3731, -7, -2965)` | `/discoteca zona_min` |
| `zona_max` (esquina superior) | `(3751, -3, -2948)` | `/discoteca zona_max` |
| `dj_pos` (emisor de audio + DJ) | `(3748, -7, -2954)` | `/discoteca dj_pos` |

## Setup in-game — completado ✓

- [x] `zona_min` fijada en `(3731, -7, -2965)`
- [x] `zona_max` fijada en `(3751, -3, -2948)`
- [x] `dj_pos` fijada en `(3748, -7, -2954)` — esquina cabina DJ, Hotel Dreams
- [x] DJ colocado con `/discoteca dj`
- [ ] Bailarines — en progreso (`/discoteca bailarin` ×4-6)

---

## Comandos de administración

```
/discoteca info          — muestra zona, emisor, jugadores dentro, estado música
/discoteca limpiar       — borra DJ y bailarines en 30m (para reposicionar)
/discoteca zona_min      — fija esquina mínima de la zona en tu posición actual
/discoteca zona_max      — fija esquina máxima de la zona en tu posición actual
/discoteca dj_pos        — fija el punto de emisión de audio en tu posición
/discoteca dj            — coloca el DJ mirando en tu dirección
/discoteca bailarin [estilo] — coloca un bailarín (skin aleatorio; estilo aleatorio u obligado)
```

Requiere privilegio `server`.

---

## Coreografías de baile (2026-07-04)

Cada bailarín ejecuta en bucle una rutina de pasos que combina: frames del
modelo (stand/walk/mine/walk_mine/sit), poses por hueso vía `set_bone_override`
(agacharse = torso inclinado, brazos arriba — el mismo mecanismo que usa
VoxeLibre para el sneak del jugador), pasos laterales reales (velocidad hacia
un punto relativo al anclaje, autocorrige deriva) y saltos (arco balístico).

| Estilo | Descripción |
|--------|-------------|
| `agachadito` | Paso agachado a la izquierda → se para con brazos arriba → paso agachado a la derecha (la idea original de Gabriel) |
| `saltarin` | Salta levantando una mano, alternando derecha/izquierda |
| `girador` | Gira en cuartos de vuelta dando pasitos, cierra el giro con salto y brazos arriba |
| `vaiven` | Adelante y atrás, pasando agachado por el centro |
| `manos_arriba` | Dos saltos con ambas manos arriba y una bajadita agachado |

- `/discoteca bailarin` asigna estilo aleatorio; `/discoteca bailarin girador` lo fuerza.
- Las rutinas con desplazamiento (`agachadito`, `vaiven`) necesitan **~1 nodo
  libre** alrededor del bailarín (son `physical = false`: no chocan, atraviesan
  muebles/paredes si se colocan pegados a ellos).
- Los bailarines ya colocados en producción conservan skin y orientación; su
  índice de estilo viejo (1-3) mapea a las 3 primeras rutinas nuevas.
- Ajustes finos en `init.lua`: `BODY_CROUCH` (si el torso se inclina hacia
  atrás en vez de adelante, invertir el signo de `x`), `ARM_UP_R/L`,
  `JUMP_GRAVITY`, y la tabla `DANCE_ROUTINES` para crear rutinas nuevas.

---

## Música

Track actual: `wetlands_music_groovy_goblins` (placeholder).

Para reemplazarlo por música rave 8-bit real:
1. Descargar un `.ogg` CC0 (OpenGameArt.org, FreeMusicArchive)
2. Copiarlo a `server/mods/valdivia_discoteca/sounds/valdivia_discoteca_rave.ogg`
3. Cambiar `MUSIC_TRACK` en la línea 21 de `server/mods/valdivia_discoteca/init.lua`
4. Push + pull en VPS + restart del contenedor Valdivia

---

## Historial

| Fecha | Evento |
|-------|--------|
| 2026-07-03 | Mod `valdivia_discoteca` desplegado en producción |
| 2026-07-03 | `zona_min` fijada en `(3731, -7, -2965)` — Hotel Dreams |
| 2026-07-03 | `zona_max` fijada en `(3751, -3, -2948)` |
| 2026-07-03 | `dj_pos` fijada en `(3748, -7, -2954)`, DJ colocado |
| 2026-07-03 | `valdivia_music` deshabilitado — silencio en la calle, música solo en la disco |
| 2026-07-03 | Skins de bailarines ampliados a 12 (rave, festivos, hipster, clásicos) |
| 2026-07-04 | Fix detección de zona: colchón vertical (−2/+3) — la música ya no exige saltar ni subirse a la mesa del DJ; poll a 0.5 s |
| 2026-07-04 | Coreografías de baile: 5 rutinas con pasos laterales, saltos, agachadas y brazos arriba; `/discoteca bailarin [estilo]` |
