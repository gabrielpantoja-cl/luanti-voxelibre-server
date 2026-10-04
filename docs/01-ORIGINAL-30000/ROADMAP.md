# Roadmap — Wetlands (puerto 30000)

Lista **única** de pendientes de Wetlands. Los demás documentos de esta carpeta
describen cómo funciona cada pieza; lo que falta hacer se anota **aquí**. Las
prioridades transversales a todos los mundos viven en el
[`ROADMAP.md`](../../ROADMAP.md) de la raíz.

Última revisión: **2026-10-04**.

Convención: `[ ]` pendiente · `[~]` en curso · `[x]` hecho (se mueve a
«Hecho recientemente» y luego se borra; el detalle queda en git).

---

## 1. Verificar en el juego

- [ ] **Texturas tras reactivar `wetlands_christmas`** — confirmar visualmente que
      las texturas afectadas se ven bien; que el mod cargue en los logs no lo
      prueba por sí solo.
- [ ] **Spawn sin protección automática** — con un jugador sin privilegios,
      colocar y romper bloques en el centro del spawn (`protector_spawn = 0`).
- [ ] **Protector con dos cuentas** — un bloque protector puesto por un jugador
      impide que otra cuenta modifique dentro del área.

## 2. Decisiones pendientes

- [ ] **Contenido legado**: decidir si NPCs, música, decoración y vehículos
      vuelven a Wetlands. Cada reactivación requiere prueba local y revisar el
      `world.mt` del VPS.
- [ ] **Actividades educativas** compatibles con supervivencia, sin asumir modo
      creativo ni mods deshabilitados.

## 3. Deuda técnica y limpieza

- [ ] **Si las texturas siguen corruptas**: identificar bloques/texturas concretos
      antes de cambiar el orden de carga o tocar assets. Preservar el backup y no
      cambiar los mappings de Docker.
- [ ] **Guía histórica de Protector** (`config/05-BLOCK_PROTECTION.md`): revisar
      que cada comando y mecánica coincida con la versión instalada.
- [ ] **Primer ingreso**: revisar privilegios, reglas, idioma y supervivencia sin
      kit inicial.

## 4. Contenido y experiencia

- [ ] **Guía corta del mundo** para jugadores: objetivo, reglas, spawn, comandos y
      cómo reportar problemas (`/gabo`).

---

## Hecho recientemente

| Fecha | Qué |
|-------|-----|
| 2026-09-30 | `wetlands_christmas` reactivado (backup previo; carga confirmada en logs) |
| 2026-09-19 | Protección automática del spawn desactivada (`protector_spawn = 0`) |
| 2026-09-16 | Protector Redo activo (radio 20, cuadrícula de área 20 s) |
| 2026-07-31 | Supervivencia dura sin PvP; `pvp_arena` retirado; `gabo` conserva privilegios por whitelist |
