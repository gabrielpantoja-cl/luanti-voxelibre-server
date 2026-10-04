# Roadmap — Plano (puerto 30003)

Lista **única** de pendientes de Plano, el mundo Mineclonia totalmente plano.
Cómo funciona el mundo está en [`index.md`](index.md); lo que falta hacer se
anota **aquí**. Las prioridades transversales viven en el
[`ROADMAP.md`](../../ROADMAP.md) de la raíz.

Última revisión: **2026-10-04**.

Convención: `[ ]` pendiente · `[~]` en curso · `[x]` hecho (se mueve a
«Hecho recientemente» y luego se borra; el detalle queda en git).

---

## 1. Verificar en el juego

- [ ] **Spawn** en `0,10,0`: el jugador aparece sobre el pasto (suelo en y=8),
      en creativo y sin daño.
- [ ] **`wetlands_mundos`** lista los demás mundos correctamente desde Plano.

## 2. Decisiones pendientes

- [ ] **Mods vestigiales del CTF** (`wetlands_flatworld`, `wetlands_ctf`,
      `ctf_guns`): no se cargan desde el 2026-09-13. Decidir entre borrarlos o
      marcarlos `DEPRECATED` al inicio de cada `init.lua`.
- [ ] **Protección de construcciones**: hoy no hay mod de protección. Decidir si
      hace falta (p. ej. Protector Redo) cuando haya builds que cuidar.

## 3. Deuda técnica y limpieza

_Sin pendientes._

## 4. Contenido y experiencia (ideas, no comprometidas)

- [ ] WorldEdit para admins.
- [ ] Zonas o coordenadas de «showcase» con construcciones destacadas.

---

## Hecho recientemente

| Fecha | Qué |
|-------|-----|
| 2026-09-13 | CTF retirado; el puerto 30003 pasa a servir este mundo plano → [`index.md`](index.md) |
