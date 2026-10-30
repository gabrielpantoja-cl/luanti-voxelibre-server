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
[`raw_skins/FUENTES.md`](../../server/mods/valdivia_transeuntes/raw_skins/FUENTES.md).
