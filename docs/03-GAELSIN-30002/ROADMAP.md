# Roadmap — GAELSIN (puerto 30002)

Lista **única** de pendientes de GAELSIN, el mundo de supervivencia pura (seed
`GAELSIN`, mapgen v7). Cómo funciona el mundo está en [`index.md`](index.md) y la
configuración real en `server/config/luanti-gaelsin.conf`; lo que falta hacer se
anota **aquí**. Las prioridades transversales viven en el
[`ROADMAP.md`](../../ROADMAP.md) de la raíz.

Última revisión: **2026-10-04**.

Convención: `[ ]` pendiente · `[~]` en curso · `[x]` hecho (se mueve a
«Hecho recientemente» y luego se borra; el detalle queda en git).

Principios: supervivencia canónica (noche peligrosa, hambre, fuego), PvP en todo
el mundo sin arena, cero creepers, y **pocos mods**, cada uno con propósito claro.
GAELSIN no es Wetlands ni Valdivia: la identidad compasiva y plant-based no aplica.

---

## 1. Verificar en el juego

- [ ] **Protector con dos cuentas** — un jugador coloca un protector; otra cuenta
      no puede romper ni construir dentro del área (radio 20).
- [ ] **`/gabo`** llega al admin por Telegram desde GAELSIN.

## 2. Decisiones pendientes

- [ ] **Reset de temporada**: definir criterios (mapa demasiado explorado, pocos
      jugadores activos) antes de que haga falta.
- [ ] **Futuro del mundo**: supervivencia indefinida o rotación con otros seeds /
      mapgens.
- [ ] **Eventos opcionales** (torneos PvP con marcadores, cacerías de Elytra) sin
      convertirlos en contenido permanente.

## 3. Deuda técnica y limpieza

- [ ] **Revisión periódica de logs** del contenedor: exploits, lag, desbalance de
      mobs.
- [ ] **Oretracker** (`orehud` + `xray`): seguir sus pitfalls conocidos →
      [`oretracker.md`](oretracker.md).
- [ ] **Spawn de mobs y densidad de minerales**: ajustar solo si los jugadores
      reportan escasez o exceso.

## 4. Contenido y experiencia (ideas, no comprometidas)

- [ ] Registrar experiencias de juego reales (PvP, Nether, progresión de
      armaduras) para detectar fricciones de diseño.
- [ ] Mod de temporadas o climas que cambie el ritmo sin tocar reglas duras.
- [ ] Estadísticas agregadas (muertes, jugadores únicos por mes) si el volumen lo
      justifica.

## Lo que no se va a hacer

- **No** modo creativo ni inventario creativo global.
- **No** NPCs ni vehículos temáticos.
- **No** mover jugadores a otro mundo automáticamente.
- **No** aplicar las reglas de Wetlands (compasivo, plant-based) sobre GAELSIN.
- **No** `voxelibre_protection` (obsoleto); se usa `protector` (Protector Redo).

---

## Hecho recientemente

| Fecha | Qué |
|-------|-----|
| 2026-09-20 | Protector Redo (`protector`, radio 20) activo |
| 2026-09-20 | `/gabo <mensaje>` → Telegram (`wetlands_contact`) activo |
