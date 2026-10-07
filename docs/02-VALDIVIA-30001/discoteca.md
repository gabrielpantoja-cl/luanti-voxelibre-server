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
- [ ] Bailarines — en progreso (`/discoteca bailarin` ×4-6) — seguimiento en [`ROADMAP.md`](ROADMAP.md)

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

## Repertorio del DJ

Desde 2026-10-07 el DJ toca una **lista de canciones en orden y en bucle**
(tabla `PLAYLIST` en `init.lua`), con un **reloj común**: quien entra escucha la
misma canción y en el mismo punto que los demás (`sound_play` con `start_time`).
Al empezar cada canción aparece su crédito en amarillo. Si la disco queda vacía,
la próxima fiesta parte desde la primera canción.

| # | Pista (`sounds/`) | Se toca | Nota |
|---|---|---|---|
| 1 | `discoteca_shakari.ogg` | 1:26,6 de 1:33 | Completa; el archivo termina con 6,9 s de silencio, que se salta |
| 2 | `discoteca_billie_jean.ogg` | 4:50 de 4:54 | Completa; termina con 4,5 s de silencio. **Fuera de git** (ver abajo) |

### Pedirle un tema al DJ

**Clic derecho en el DJ** abre «DJ del Dreams: ¿qué tema quieres?» con todo el
repertorio (el que suena aparece marcado). Al elegir uno:

- Suena **para todos** los que están en la pista, desde el inicio, y la lista
  sigue desde ese tema. En el chat de la pista aparece quién lo pidió.
- Solo se pide **desde dentro** de la discoteca.
- Pausa común de **30 s** entre pedidos (`PEDIDO_COOLDOWN`), para que nadie
  acapare al DJ. Pedir el tema que ya suena no cuenta.

Funciona moviendo el reloj común del DJ (`dj_epoch`) al inicio de la pista
pedida y relanzando la música de cada jugador en la pista.

### Agregar una canción

1. Convertir a mono 48 kHz Vorbis 96k, con la sonoridad igualada al resto:
   ```bash
   ffmpeg -i entrada.mp3 -map_metadata -1 -vn      -af "loudnorm=I=-16:TP=-3.5:LRA=11,alimiter=limit=0.6:level=false"      -ac 1 -ar 48000 -c:a libvorbis -b:a 96k      server/mods/valdivia_discoteca/sounds/discoteca_<nombre>.ogg
   ```
2. Medir dónde termina el sonido (para `dur`) y la sonoridad (para `gain`):
   ```bash
   ffmpeg -i discoteca_<nombre>.ogg -af silencedetect=n=-45dB:d=0.5 -f null -
   ffmpeg -i discoteca_<nombre>.ogg -af ebur128 -f null -
   ```
3. Agregar la fila a `PLAYLIST` (`sound`, `dur`, `gain`, `titulo`) y reiniciar Valdivia.

**Música comercial = fuera del repo público.** Una grabación comercial completa
no se commitea (el repo es público: sería redistribuirla). Se agrega a
`.gitignore` y se copia al VPS:
```bash
scp server/mods/valdivia_discoteca/sounds/discoteca_<nombre>.ogg   $VPS_USER@$VPS_HOST:~/luanti-voxelibre-server/server/mods/valdivia_discoteca/sounds/
```
El VPS es la única copia en servidor de esos archivos: si se pierde, hay que
volver a convertirlos desde el original.

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
| 2026-10-07 | Repertorio del DJ: lista de canciones con reloj común; se agrega Billie Jean (4:54, fuera de git) y se salta el silencio final de Shakari |
| 2026-10-07 | Pedidos al DJ: clic derecho en el DJ para elegir el tema; suena para toda la pista (pausa de 30 s entre pedidos) |
| 2026-09-16 | Vuelve la música de fondo de VoxeLibre (`mcl_game_music = true`) en toda la ciudad. La discoteca la silencia solo para quien entra (vía `/music off` silencioso, fade ~1 s, re-aplicado cada 5 s) y la devuelve al salir o reconectar; respeta a quien la apagó con `/music off`. `load_mod_mcl_music` no sirve: es mod del juego. |
