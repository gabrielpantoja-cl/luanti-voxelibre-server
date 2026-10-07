# Cabina TP — red de transporte de Valdivia (`valdivia_cabina`)

Bloque rojo de 1×2 diseñado por **Gaspi** (sobrino del admin) a partir de un
dibujo en pizarra: cabina roja con techo rayado, letrero blanco **TP**, puerta
blanca con manilla y pilares rayados. Es el punto físico de la red de transporte
público de Valdivia (puerto 30001); los NPC guía siguen funcionando con el mismo
menú.

Estado: **implementado 2026-10-07**.

## Qué hace

| Elemento | Detalle |
|---|---|
| Cabina | Dos nodos (`valdivia_cabina:cabina` abajo + `cabina_arriba`, que se crea sola). Brilla un poco (luz 5) para encontrarla de noche. Indestructible: no se rompe a golpes, con pistones ni con explosiones. |
| Clic derecho | Abre el menú **«Cabina TP <nombre>: ¿a dónde vamos?»** con **todos** los destinos de la ciudad, en varias columnas si son muchos. Oculta el destino donde ya estás (radio 20). Las cabinas aparecen como `[TP] Cabina <nombre>`. |
| Viaje | Igual que «Mi casa»: **3 s quieto** (moverse o recibir daño cancela) y **30 s** entre viajes; el admin (`server`) viaja al instante. Se llega **frente a la puerta**, mirando la cabina. |
| Destinos | Cada cabina que coloca el admin se registra sola como destino. Más los lugares fijos y los guardados con `/lugar_guardar`. |

## Comandos (admin, priv `server`)

| Comando | Uso |
|---|---|
| `/cabina` | Te da una cabina. Colócala **mirando hacia donde quieres la puerta**; necesita 2 bloques de alto libres. Al colocarla pide un nombre (ej. «Costanera»). |
| `/cabina nombre [nuevo]` | Renombra la cabina más cercana (5 bloques); sin texto abre el formulario. |
| `/cabina quitar` | Quita la cabina más cercana (5 bloques) y la saca del menú. |
| `/lugar_guardar <id> <nombre>` | Guarda tu posición (y hacia dónde miras) como destino. |
| `/lugar_borrar <id>` | Quita un destino guardado (no cabinas). |
| `/lugares` | Lista todos los destinos (cualquiera puede usarlo). |

## Arquitectura: núcleo compartido

`valdivia_cabina` es también el **núcleo de viajes** de Valdivia (API global
`valdivia_cabina`):

| Función | Para qué |
|---|---|
| `get_lugares()`, `get_lugar(id)`, `set_lugar(id, nombre, pos, extra)`, `remove_lugar(id)` | Lista de destinos: `DEFAULT_LUGARES` + `worldpath/valdivia_lugares.json` |
| `show_menu(name, {titulo, on_back})` | Menú de destinos (el guía pasa `on_back` para su botón «Volver») |
| `request(player, pos, label, {yaw})` | Viaje con espera y pausa |

Quién lo usa:

- **Cabina TP** (`cabina.lua`).
- **NPC guía** (`valdivia_spawn_npc`): su botón «Lugares de Valdivia» abre `show_menu`.
  Antes tenía su propia copia de destinos, menú y `set_pos` sin espera.
- **«Mi casa»** (`valdivia_home`): ir a casa / ir al spawn usan `request`.

Un destino nuevo aparece en guías y cabinas a la vez, y hay una sola regla de
espera/pausa para todos los viajes. Ambos mods declaran
`optional_depends = valdivia_cabina` para cargar después del núcleo.

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
