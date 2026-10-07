# Cabina TP — red de transporte de Valdivia (`valdivia_cabina`)

Bloque rojo de 1×2 diseñado por **Gaspi** (sobrino del admin) a partir de un
dibujo en pizarra: cabina roja con techo rayado, letrero blanco **TP**, puerta
blanca con manilla y pilares rayados. Es el punto físico de la red de transporte
público de Valdivia (puerto 30001) y **la única forma de viajar** entre lugares:
los NPC guía solo conversan (explican las reglas y que se viaja en cabina).

Estado: **implementado 2026-10-07**.

## Qué hace

| Elemento | Detalle |
|---|---|
| Cabina | Dos nodos (`valdivia_cabina:cabina` abajo + `cabina_arriba`, que se crea sola). Brilla un poco (luz 5) para encontrarla de noche. Indestructible: no se rompe a golpes, con pistones ni con explosiones (grupos `unbreakable`/`indestructible` + `can_dig = false`; `diggable = false` solo **no** basta en VoxeLibre, ver `AGENTS.md`). |
| Clic derecho | Abre el menú **«Cabina TP <nombre>: ¿a dónde vamos?»** con **las demás cabinas** por su nombre, en orden alfabético y en varias columnas si son muchas. La cabina donde estás no aparece. |
| Viaje | Igual que «Mi casa»: **3 s quieto** (moverse o recibir daño cancela) y **30 s** entre viajes; el admin (`server`) viaja al instante. Se llega **frente a la puerta**, mirando la cabina. |
| Destinos | **Solo cabinas.** Cada cabina que coloca el admin se registra sola como destino; quitarla la saca del menú. Para agregar un lugar a la red, se pone una cabina ahí. |

## Comandos (admin, priv `server`)

| Comando | Uso |
|---|---|
| `/cabina` | Te da una cabina. Colócala **mirando hacia donde quieres la puerta**; necesita 2 bloques de alto libres. Al colocarla pide un nombre (ej. «Costanera»). |
| `/cabina nombre [nuevo]` | Renombra la cabina más cercana (5 bloques); sin texto abre el formulario. |
| `/cabina quitar` | Quita la cabina más cercana (5 bloques) y la saca del menú. |
| `/lugares` | Lista las cabinas con su posición (cualquiera puede usarlo). |

## Arquitectura: núcleo compartido

`valdivia_cabina` es también el **núcleo de viajes** de Valdivia (API global
`valdivia_cabina`):

| Función | Para qué |
|---|---|
| `get_lugares()`, `get_lugar(id)`, `set_lugar(id, nombre, pos, extra)`, `remove_lugar(id)` | Lista de cabinas en `worldpath/valdivia_lugares.json` |
| `show_menu(name, {titulo, excluir})` | Menú de cabinas (`excluir` = id de la cabina desde donde se abre) |
| `request(player, pos, label, {yaw})` | Viaje con espera y pausa |

Quién lo usa:

- **Cabina TP** (`cabina.lua`).
- **«Mi casa»** (`valdivia_home`): ir a casa / ir al spawn usan `request`.

`valdivia_home` declara `optional_depends = valdivia_cabina` para cargar después
del núcleo.

### Limpieza 2026-10-07 (sin duplicados)

La primera versión mezclaba en el menú los 4 lugares fijos heredados del guía
(Plaza, Catrico, Santa Elena, Huachocopihue) **y** las cabinas puestas en esos
mismos sitios, con prefijo `[TP]`: cada lugar salía dos veces. Ahora:

- Los destinos son **solo cabinas**; se retiraron `DEFAULT_LUGARES`,
  `/lugar_guardar` y `/lugar_borrar`.
- Al cargar, el núcleo descarta del JSON las entradas que no son cabina y quita
  el prefijo viejo `Cabina ` de los nombres (entradas sin `v = 2`).
- Los botones muestran solo el nombre (sin `[TP]`).
- El NPC guía ya no teletransporta: solo conversa.

## Modelo y texturas

- **Dos nodos** en vez de un nodebox de 2 de alto: un nodebox alto repite la
  textura de 16×16 dos veces por cara, y el dibujo saldría duplicado.
- Nodebox: zócalo y cornisa a ancho completo; cuerpo 1 px hacia adentro.
- Texturas 16×16 en `textures/valdivia_cabina_*.png`, generadas con
  `tools/generate_textures.py` (pixel art reproducible: editar ahí y
  re-ejecutar). Con `--preview salida.png --dibujo foto.jpg` arma una vista
  previa junto al dibujo original.

| Textura | Contenido |
|---|---|
| `frente_arriba` | Cornisa rayada, letrero blanco «TP», parte alta de la puerta |
| `frente_abajo` | Puerta blanca con manilla, pilares rayados, zócalo |
| `lado_arriba` / `lado_abajo` | Rojo rayado (como el sombreado a mano del dibujo) |
| `techo` / `base` | Techo rayado con borde / rojo oscuro |

## Reemplaza a `valdivia_teleporter`

El viejo pedestal `/ir` (`valdivia_teleporter`, deshabilitado desde la
regeneración con Arnis por coordenadas obsoletas) se **eliminó** el 2026-10-07;
queda en el historial de git. `valdivia_cabina` registra el alias
`valdivia_teleporter:pad → air` por si algún pedestal sobrevivía en el mapa.

## Despliegue

1. `load_mod_valdivia_cabina = true` en `luanti-valdivia.conf` **y** en el
   `world.mt` de Valdivia del VPS.
2. Reiniciar `luanti-valdivia`.
3. In-game, como admin: `/cabina`, colocar en cada punto de la red y ponerle nombre.
