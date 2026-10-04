# Roadmap del proyecto Wetlands

Estado del repositorio: **4 de octubre de 2026**.

Este documento cubre las prioridades **transversales** del servidor (operaciones, documentación, mods compartidos). Los pendientes propios de cada mundo viven en su carpeta, con el mismo formato de checklist. El roadmap de la landing page está separado en [`server/landing-page/docs/ROADMAP.md`](server/landing-page/docs/ROADMAP.md).

## Estado actual

| Mundo | Puerto | Base | Estado |
|---|---:|---|---|
| Wetlands | 30000 | VoxeLibre 0.90.1 | Supervivencia dura, sin PvP, identidad compasiva y plant-based |
| Valdivia | 30001 | VoxeLibre + Arnis/OSM | Recreación explorable de Valdivia |
| GAELSIN | 30002 | VoxeLibre 0.90.1 | Supervivencia con PvP y hostiles nocturnos |
| Plano | 30003 | Mineclonia | Mundo totalmente plano, creativo y sin daño (reemplazó CTF el 2026-09-13) |
| Mineclonia | 30004 | Mineclonia 0.123.0 | Supervivencia, daño activo, sin PvP, experiencia fiel a Minecraft |

Los valores operativos deben verificarse primero en `server/config/luanti-<mundo>.conf` y, para mods, en el `world.mt` autoritativo de cada mundo en el VPS.

## Roadmaps por mundo

| Mundo | Roadmap |
|---|---|
| Wetlands (30000) | [`docs/01-ORIGINAL-30000/ROADMAP.md`](docs/01-ORIGINAL-30000/ROADMAP.md) |
| Valdivia (30001) | [`docs/02-VALDIVIA-30001/ROADMAP.md`](docs/02-VALDIVIA-30001/ROADMAP.md) |
| GAELSIN (30002) | [`docs/03-GAELSIN-30002/ROADMAP.md`](docs/03-GAELSIN-30002/ROADMAP.md) |
| Plano (30003) | [`docs/04-PLANO-30003/ROADMAP.md`](docs/04-PLANO-30003/ROADMAP.md) |
| Mineclonia (30004) | [`docs/05-MINECLONIA-30004/ROADMAP.md`](docs/05-MINECLONIA-30004/ROADMAP.md) |

Formato común: `Última revisión`, convención `[ ]`/`[~]`/`[x]` y secciones **1. Verificar en el juego**, **2. Decisiones pendientes**, **3. Deuda técnica y limpieza**, **4. Contenido y experiencia**, más una tabla **Hecho recientemente**. Una sección sin tareas se deja con _Sin pendientes._ en vez de borrarla.

## Prioridad P0: confiabilidad y documentación

- [ ] Mantener sincronizados README, configuración y documentación de cada mundo.
- [ ] Corregir referencias heredadas a `server/worlds/world/`; usar `server/worlds/<mundo>/world.mt`.
- [ ] Documentar claramente qué mods están activos y cuáles son históricos o kill-switches.
- [ ] Añadir una validación automática de coherencia para spawn, puertos, modo de juego, mods y comandos.
- [ ] Mantener un procedimiento de despliegue con backup, comprobación de permisos y revisión de logs posteriores al reinicio.

## Prioridad P1: experiencia de juego

- [ ] Verificar en juego el spawn de cada mundo y registrar coordenadas, superficie segura y punto de retorno.
- [ ] Completar una matriz de compatibilidad de mods por mundo antes de reactivar contenido legado.
- [ ] Resolver o documentar los límites conocidos de daño de proyectiles y otros sistemas de combate.
- [ ] Mejorar las guías de administración para que distingan acciones seguras en producción de acciones destructivas sobre mundos.

## Prioridad P2: contenido y comunidad

- [ ] Publicar una guía corta por mundo: objetivo, reglas, spawn, comandos disponibles y cómo reportar problemas.
- [ ] Mejorar la landing page cuando el volumen de imágenes, visitas o jugadores justifique cada iniciativa de su roadmap específico.

## Decisión pendiente: Wetlands 3.0

La propuesta histórica de fusión (eliminada del repo en el commit `0ab79a14`; consultable con `git show 0ab79a14^:docs/projects/index.md`) proponía fusionar Wetlands y Valdivia mediante una operación SQLite con offset. **No es un proyecto aprobado ni debe ejecutarse en producción**. Mantener los mundos separados es la estrategia actual porque reduce el riesgo sobre mapas, inventarios, permisos y backups.

Antes de considerar la fusión se necesita:

1. decisión explícita del propietario del proyecto;
2. backups verificables y restaurables de ambos mundos;
3. prototipo reproducible sobre copias offline, con el servidor detenido;
4. validación de IDs de nodos, entidades, mod storage, coordenadas y límites del mapa;
5. prueba de rendimiento y plan de rollback.

Hasta cumplir esos requisitos, esa propuesta es solo referencia histórica/técnica, no instrucción operativa.

## Criterios de finalización

Una iniciativa se considera lista cuando la documentación coincide con la configuración vigente, fue probada en el mundo correspondiente, incluye una ruta de recuperación y no requiere editar archivos de producción sin dejar registro.
