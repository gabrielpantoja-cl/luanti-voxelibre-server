# Documentación Wetlands — Servidor Luanti

Documentación técnica del servidor educativo Wetlands, con 4 mundos activos + 1 planeado.

## Mundos

| Puerto | Mundo | Juego | Tipo | Creativo |
|--------|-------|-------|------|----------|
| 30000 | [Wetlands](01-ORIGINAL-30000/) | VoxeLibre | Creativo / Educación | Sí |
| 30001 | [Valdivia](02-VALDIVIA-30001/) | VoxeLibre | Ciudad OSM / Exploración | Sí |
| 30002 | [GAELSIN](03-GAELSIN-30002/) | VoxeLibre | Survival / PvP | No |
| 30003 | [CTF](04-CTF-30003/) | CTF Game | Capture the Flag | No |
| 30004 | [Fútbol](05-FUTBOL/) | Minetest Game | Deportes (planeado) | Sí |

## Documentación compartida ([00-SHARED/](00-SHARED/))

Solo mecánica del motor, técnicas y operaciones **agnósticas al mundo**. Ver el
[README de 00-SHARED](00-SHARED/README.md) para la nota de aplicabilidad por mundo (no todos comparten
la filosofía "sin violencia": GAELSIN y CTF son mundos de combate).

- [Inicio rápido](00-SHARED/quickstart/) — Cómo conectarse
- [Admin](00-SHARED/admin/) — Comandos, skins, troubleshooting
- [Config](00-SHARED/config/) — Jerarquía de config y mecánica de VoxeLibre
- [Mods](00-SHARED/mods/) — Desarrollo y guías de mods
- [Operaciones](00-SHARED/operations/) — Backups, clonar mundo, MCP
- [Web](00-SHARED/web/) — Landing page, API, nginx
- [Proyectos multi-mundo](PROYECTOS/) — Iniciativas que cruzan varios mundos

## Enlaces útiles

- `luanti.gabrielpantoja.cl:30000` — Wetlands
- `luanti.gabrielpantoja.cl:30001` — Valdivia [Chile]
- `luanti.gabrielpantoja.cl:30002` — GAELSIN
- `luanti.gabrielpantoja.cl:30003` — CTF
