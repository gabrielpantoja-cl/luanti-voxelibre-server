# Roadmap GAELSIN

Estado del mundo: **agosto de 2026**, supervivencia pura, seed `GAELSIN`, puerto 30002. Documento de planificación — no describe cambios ya ejecutados ni configuración vigente (la fuente real es `server/config/luanti-gaelsin.conf`).

## Visión

GAELSIN es el mundo de supervivencia "adulto" del servidor. Comparte base con los demás mundos (VoxeLibre, puerto dedicado, sidecar Discord), pero su objetivo es ofrecer la experiencia canónica del modo supervivencia: noche peligrosa, decisiones de combate con peso, progresión por mérito y PvP global sin arenas separadas.

La idea no es acumular contenido: es sostener una experiencia limpia donde lo importante sea la semilla, el mapa generado y las decisiones de los jugadores.

## Principios

- **Supervivencia canónica**: `creative_mode = false`, daño y fuego activos, hunger, mobs hostiles de noche.
- **Diferenciación respetada**: GAELSIN no es Wetlands ni Valdivia. La identidad compasiva y plant-based no se aplica aquí.
- **Decisiones reales**: PvP activo en todo el mundo, sin arena opt-in. La presión PvP forma parte del diseño.
- **Cero creepers por seguridad**: política vigente del servidor para todos los mundos, mantenida aquí.
- **Mínima intervención técnica**: pocos mods, todos con propósito claro (PvP, lastpos, ayuda minera, skins).

## Estado de hoy (referencia, no fuente de verdad)

- **Puerto y contenedor**: 30002/UDP, `luanti-gaelsin-server`.
- **Modo**: supervivencia dura.
- **Seed**: `GAELSIN`, mapgen `v7`.
- **Jugadores nuevos**: privilegios mínimos (`interact`, `shout`) vía `wetlands_gaelsin_newplayer`.
- **PvP**: activo, sin arena.
- **Mobs**: hostiles de noche, creepers bloqueados.
- **Ayuda minera**: Oretracker (`orehud` + `xray`) como herramienta opt-in.
- **Protección de áreas**: desactivada.
- **Sidecar Discord**: `luanti-discord-notifier-gaelsin` con label `GAELSIN ⚔️ (:30002)`.

## Iniciativas en consideración

### Corto plazo

- Documentar experiencias de juego reales (encuentros PvP, expediciones al Nether, progresión de armaduras) para detectar fricciones de diseño.
- Revisar periódicamente los logs del contenedor para detectar exploits, lag y desbalances de mobs.
- Ajustar parámetros de spawn de mobs y densidades de minerales si los jugadores detectan escasez o exceso.
- Mantener Oretracker como ayuda opt-in, con seguimiento cercano de sus pitfalls conocidos.

### Mediano plazo

- Evaluar un reset de temporada cuando el mapa se sienta demasiado explorado, documentando los criterios de decisión.
- Considerar reglas opcionales por evento (torneos PvP con marcadores, ventanas de saqueo, cacerías de Elytra) sin convertirlas en contenido permanente.
- Explorar integraciones con el mundo CTF (30003) y Mineclonia (30004) si surgen oportunidades de colaboración técnica (por ejemplo, compartir listas de jugadores o marcadores).

### Largo plazo

- Decidir si GAELSIN se mantiene como supervivencia indefinida, o si entra en una rotación con otros seeds / mapgens.
- Evaluar la introducción de un mod de temporadas o climas que cambie el ritmo del mundo sin tocar reglas duras.
- Considerar la publicación de estadísticas agregadas (kills, muertes, jugadores únicos por mes) si el volumen de jugadores lo justifica.

## Decisiones explícitas que no se van a tomar

- **No** reintroducir modos creativos ni inventario creativo global. Sería un cambio de identidad.
- **No** añadir NPCs ni vehículos temáticos. El mundo es supervivencia, no ambientación.
- **No** mover a los jugadores a otro mundo automáticamente. La salida de GAELSIN debe ser decisión del jugador.
- **No** superponer las reglas de Wetlands (compasivo, plant-based, sin daño) sobre GAELSIN.

## Alineación con el resto del servidor

GAELSIN se planifica junto con los otros mundos según la arquitectura documentada en `AGENTS.md` y los principios del roadmap general (`ROADMAP.md` en la raíz):

| Mundo | Puerto | Modo | Rol |
|---|---:|---|---|
| Wetlands | 30000 | Supervivencia compasiva | Identidad del servidor, plant-based, daño activo, sin PvP |
| Valdivia | 30001 | Exploración / OSM | Recreación real, contención de mobs selectiva |
| GAELSIN | 30002 | Supervivencia pura | PvP global, noche peligrosa, progresión dura |
| CTF | 30003 | Combate por equipos | Round-based, armas, sin vínculo directo con supervivencia |
| Mineclonia | 30004 | Creativo | Experiencia Minecraft fiel, sin daño |

Las decisiones de GAELSIN deben coordinarse con las decisiones que afecten el servidor completo: actualizaciones de VoxeLibre, cambios de Luanti, parámetros de seguridad CSM, eventos globales (Halloween, Navidad) y límites de uso del VPS.

## Criterios de finalización

Una iniciativa se considera lista cuando:

- está documentada en `docs/03-GAELSIN-30002/` o en este roadmap;
- es verificable in-game (qué comando, qué lugar, qué regla);
- no rompe la separación con Wetlands ni con Valdivia;
- si requiere cambios de configuración, primero el `.conf` local y luego el `world.mt` autoritativo del VPS.

> Este documento no es un plan operativo: registrar cambios reales en `docs/03-GAELSIN-30002/index.md` y mantener `server/config/luanti-gaelsin.conf` como fuente de verdad.
