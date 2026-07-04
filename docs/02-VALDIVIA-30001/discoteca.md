# Discoteca del Hotel Dreams — Valdivia

Discoteca interactiva en el Hotel Dreams, cerca del spawn de Valdivia.
Implementada con el mod `valdivia_discoteca` (puerto 30001).

Cuando un jugador entra a la zona configurada:
- La música arranca automáticamente (posicional, todos la escuchan)
- Luces de colores ciclan desde el techo cada 2 segundos
- El DJ y los bailarines animan la pista

---

## Coordenadas y zona

| Campo | Coordenadas | Comando usado |
|-------|-------------|---------------|
| `zona_min` (esquina inferior) | `(3731, -7, -2965)` | `/discoteca zona_min` |
| `zona_max` (esquina superior) | `(3751, -3, -2948)` | `/discoteca zona_max` |
| `dj_pos` (emisor de audio) | pendiente | `/discoteca dj_pos` |

---

## Setup in-game (completar como admin)

Pasos pendientes para terminar la configuración:

1. Ir a la esquina superior opuesta del interior del edificio y ejecutar:
   ```
   /discoteca zona_max
   ```
2. Pararse en la posición de la cabina del DJ y ejecutar:
   ```
   /discoteca dj_pos
   ```
3. Mirando hacia la pista, invocar al DJ:
   ```
   /discoteca dj
   ```
4. Repetir 4-6 veces en distintos puntos de la pista:
   ```
   /discoteca bailarin
   ```
5. Salir y volver a entrar — verificar que suena música + luces + animaciones.

---

## Comandos de administración

```
/discoteca info          — muestra zona, emisor, jugadores dentro, estado música
/discoteca limpiar       — borra DJ y bailarines en 30m (para reposicionar)
/discoteca zona_min      — fija esquina mínima de la zona en tu posición actual
/discoteca zona_max      — fija esquina máxima de la zona en tu posición actual
/discoteca dj_pos        — fija el punto de emisión de audio en tu posición
/discoteca dj            — coloca el DJ mirando en tu dirección
/discoteca bailarin      — coloca un bailarín (skin y estilo aleatorios)
```

Requiere privilegio `server`.

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
