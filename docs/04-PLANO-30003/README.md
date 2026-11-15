# Plano (Puerto 30003)

> **RETIRADO 2026-11-15.** El puerto 30003 volvió a servir CTF (`docs/04-CTF-30003/`).
> El mundo quedó guardado en el VPS como `server/worlds/plano_OLD-20261115` y su config
> (`luanti-plano.conf`) sigue en el historial de git (commit anterior a la vuelta del CTF).
> Se conserva este documento por la receta de mapgen flat, que costó encontrar.

Mundo **Mineclonia totalmente plano**: pasto arriba, tierra debajo y roca hasta el
bedrock. Sin cuevas, árboles, lagos ni colinas — un lienzo limpio para construir.

Reemplaza al antiguo mundo **CTF** (`capturetheflag` de rubenwardy), retirado el
2026-09-13.

| Aspecto | Valor |
|---------|-------|
| Puerto | 30003/UDP |
| Juego | Mineclonia (fork de VoxeLibre, **no** es VoxeLibre) |
| Mapgen | `flat` + bioma único `Plains` (ver [`index.md`](./index.md)) |
| Creativo | Sí |
| Daño | No |
| PvP | No |
| Mods custom | Solo `wetlands_mundos` (`/mundos`) |

Detalles completos del mapgen, deploy y troubleshooting: [`index.md`](./index.md).
Pendientes e ideas: [`ROADMAP.md`](./ROADMAP.md).
