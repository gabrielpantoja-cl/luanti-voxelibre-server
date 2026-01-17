# 📋 Custom Villagers - Tareas Pendientes

**Última actualización**: 2026-01-16
**Versión actual**: v2.1.1

---

## ✅ Completado (2026-01-16)

### Fix Crítico: Crash en Click Derecho
- [x] **RESUELTO**: Click derecho en NPCs ya NO crashea el servidor
- [x] Emojis eliminados de mensajes (causaban crashes)
- [x] Validación defensiva en formspecs implementada
- [x] Protección pcall() en pathfinding (6 ubicaciones)
- [x] Logging de errores mejorado
- [x] Documentación completa del parche

**Verificación**: ✅ Confirmado por usuario - "ya no se crashea con el clic derecho"

---

## ⚠️ Tareas Pendientes de Testing y Verificación

### Prioridad Alta - Testing de Funcionalidad Básica

#### 1. Verificar Sistema de Diálogos Interactivos
**Estado**: ⚠️ PENDIENTE DE TESTING
**Descripción**: Confirmar que los NPCs responden correctamente a las opciones del formspec

**Tests requeridos**:
- [ ] Spawnear aldeano: `/spawn_villager farmer`
- [ ] Click derecho abre formspec sin crash ✅ (confirmado)
- [ ] Botón "Saludar" muestra mensaje apropiado en chat
- [ ] Botón "Sobre su trabajo" muestra diálogo educativo
- [ ] Botón "Aprender algo nuevo" muestra contenido educativo
- [ ] Botón "Comerciar" abre formspec de comercio
- [ ] Botón "Cerrar" cierra formspec correctamente

**Comandos de testing**:
```bash
/spawn_villager farmer
/spawn_villager librarian
/spawn_villager teacher
/spawn_villager explorer
```

**Verificar para cada tipo**:
1. Click derecho funciona ✅
2. Mensajes de diálogo aparecen en chat
3. Mensajes son apropiados para la profesión

---

#### 2. Verificar Sistema de Comercio
**Estado**: ⚠️ PENDIENTE DE TESTING
**Descripción**: Confirmar que el sistema de trade funciona correctamente

**Tests requeridos**:
- [ ] Abrir menú de comercio desde aldeano
- [ ] Verificar que muestra items correctos según profesión:
  - **Farmer**: Zanahorias, papas, remolachas, trigo
  - **Librarian**: Libros, papel
  - **Teacher**: Libros educativos, papel
  - **Explorer**: Manzanas, palos
- [ ] Probar intercambio con esmeraldas
- [ ] Verificar que inventario se actualiza correctamente
- [ ] Confirmar mensajes de éxito/fallo

**Notas**:
- Sistema usa mcl_core:emerald como moneda
- Trades definidos en init.lua líneas 129-148

---

#### 3. Verificar Saludos Automáticos (Comportamiento AI)
**Estado**: ⚠️ PENDIENTE DE TESTING
**Descripción**: Confirmar que los aldeanos saludan proactivamente a jugadores cercanos

**Tests requeridos**:
- [ ] Caminar cerca de aldeano (radio 5 bloques)
- [ ] Esperar ~30 segundos
- [ ] Verificar que aldeano saluda en chat
- [ ] Confirmar que saludo NO tiene emojis ✅ (fix aplicado)
- [ ] Verificar cooldown de 30 segundos funciona
- [ ] Probar con diferentes profesiones

**Configuración actual**:
```lua
auto_greet = {
    enabled = true,
    detection_radius = 5,
    greeting_chance = 5%,
    cooldown_seconds = 30,
}
```

**Mensajes esperados** (sin emojis):
- Farmer: "¡Hola, [nombre]! ¡Qué bueno verte!"
- Librarian: "Saludos, [nombre]. ¿Buscas algo de conocimiento?"
- Teacher: "¡Buenos días, [nombre]! ¿Listo para aprender?"
- Explorer: "¡Aventurero [nombre]! ¿Vas a explorar hoy?"

---

#### 4. Verificar Comportamientos AI Tradicional
**Estado**: ⚠️ PENDIENTE DE TESTING
**Descripción**: Confirmar que la máquina de estados (FSM) funciona correctamente

**Estados a verificar**:

##### 4.1. Estado IDLE (Parado)
- [ ] Aldeano se queda quieto ocasionalmente
- [ ] Rota la cabeza mirando alrededor
- [ ] Duración: 10-20 segundos

##### 4.2. Estado WANDER (Caminar aleatorio)
- [ ] Aldeano camina hacia posiciones aleatorias
- [ ] Radio de exploración: ~10 bloques
- [ ] Cambia dirección cada ~10 segundos
- [ ] Pathfinding funciona sin crashes ✅ (fix aplicado)

##### 4.3. Estado WORK (Trabajar)
- [ ] **Farmer**: Busca y camina hacia cultivos (wheat, carrot, potato, beetroot)
- [ ] **Librarian**: Busca y se queda cerca de estanterías (mcl_books:bookshelf)
- [ ] **Teacher**: Busca estanterías y papel
- [ ] **Explorer**: Busca árboles, flores, agua
- [ ] Muestra partículas de "trabajo" (burbujas) ocasionalmente
- [ ] Radio de búsqueda POI: 15 bloques

##### 4.4. Estado SOCIAL (Interactuar con otros NPCs)
- [ ] Spawnear 2+ aldeanos cercanos
- [ ] Verificar que se acercan entre ellos
- [ ] Verificar que se miran uno al otro
- [ ] Verificar partículas de corazón ocasionalmente
- [ ] Radio de detección: 10 bloques

##### 4.5. Estado SLEEP (Dormir de noche)
- [ ] Aldeano busca cama de noche (timeofday > 0.8 o < 0.2)
- [ ] Se mueve hacia cama más cercana (radio 20 bloques)
- [ ] Se queda quieto al llegar
- [ ] Muestra partículas de sueño (burbujas)
- [ ] Despierta al amanecer automáticamente

##### 4.6. Estado SEEK_PLAYER (Buscar jugador)
- [ ] Aldeano detecta jugador cercano (5 bloques)
- [ ] Se acerca al jugador
- [ ] Saluda al llegar cerca
- [ ] Respeta cooldown de 30 segundos

**Comandos de debug**:
```bash
/villager_debug on          # Activar logs de estados
/villager_state             # Ver estados de aldeanos cercanos
/villager_config get poi_search_radius
```

---

### Prioridad Media - Optimizaciones y Mejoras

#### 5. Resolver Warnings de API Deprecada
**Estado**: ✅ COMPLETADO (2026-01-16)
**Descripción**: mcl_mobs warnings sobre hp_min/hp_max deprecated - RESUELTO

**Fix aplicado**:
- [x] Movido hp_min, hp_max a initial_properties en register_custom_villager()
- [x] Actualizada definición en init.lua líneas 290-305
- [x] Aldeanos ahora usan API moderna mcl_mobs
- [x] Versión incrementada a v2.1.1

**Código actualizado** (init.lua:295-305):
```lua
initial_properties = {
    hp_max = 20,
    collisionbox = {-0.3, -0.01, -0.3, 0.3, 1.94, 0.3},
    visual = "mesh",
    mesh = "mobs_mc_villager.b3d",
    textures = def.textures or {"mobs_mc_villager.png", "mobs_mc_villager.png"},
    makes_footstep_sound = true,
},
```

**Verificación pendiente**:
- [ ] Confirmar que warnings NO aparecen en logs después de reinicio
- [ ] Verificar que aldeanos siguen teniendo 20 HP correctamente

---

#### 6. Mejorar Sistema de Partículas
**Estado**: 📝 ENHANCEMENT
**Descripción**: Verificar que las partículas visuales funcionan correctamente

**Partículas configuradas**:
- **Trabajo**: bubble.png (burbujas)
- **Social**: heart.png (corazones)
- **Sleep**: bubble.png (burbujas, fallback para zzz.png)

**Tests**:
- [ ] Verificar que partículas aparecen en estado WORK
- [ ] Verificar que partículas aparecen en estado SOCIAL
- [ ] Verificar que partículas aparecen en estado SLEEP
- [ ] Confirmar que no causan lag con 10+ aldeanos

---

#### 7. Testing de Escalabilidad
**Estado**: 📝 NICE TO HAVE
**Descripción**: Probar rendimiento con múltiples aldeanos

**Tests de rendimiento**:
- [ ] Spawnear 5 aldeanos → verificar performance
- [ ] Spawnear 10 aldeanos → verificar performance
- [ ] Spawnear 20 aldeanos (max_total_villagers) → verificar límite
- [ ] Verificar CPU/RAM del servidor
- [ ] Confirmar que pathfinding no causa lag

**Configuración actual**:
```lua
spawning = {
    max_per_area = 3,          -- Máx 3 del mismo tipo en 50 bloques
    area_radius = 50,
    max_total_villagers = 20,  -- Máx 20 en todo el servidor
}
```

---

### Prioridad Baja - Features Futuras

#### 8. Mejoras de Interacción
- [ ] Agregar sonidos de voz (sounds/)
- [ ] Agregar modelos 3D con animaciones (.b3d meshes)
- [ ] Sistema de reputación con aldeanos
- [ ] Misiones/quests educativas
- [ ] Más tipos de aldeanos (artesano, cocinero, etc.)

#### 9. Integración con Otros Mods
- [ ] Verificar compatibilidad con WorldEdit
- [ ] Verificar compatibilidad con PVP Arena
- [ ] Verificar compatibilidad con Creative Force

---

## 🧪 Plan de Testing Recomendado

### Fase 1: Testing Básico (15-20 minutos)
1. Spawnear 1 aldeano de cada tipo (farmer, librarian, teacher, explorer)
2. Click derecho en cada uno ✅
3. Probar cada botón del formspec
4. Verificar mensajes en chat
5. Probar comercio con esmeraldas

### Fase 2: Testing de AI (30 minutos)
1. Activar debug: `/villager_debug on`
2. Observar comportamientos durante 5 minutos
3. Verificar transiciones de estados: `/villager_state`
4. Probar saludos automáticos
5. Verificar pathfinding (no crashes)
6. Probar ciclo día/noche (sleep)

### Fase 3: Testing de Escalabilidad (15 minutos)
1. Spawnear 10 aldeanos en área pequeña
2. Verificar performance del servidor
3. Probar interacciones masivas
4. Verificar límites de spawning

---

## 📊 Criterios de Éxito

### Mínimo Viable (Debe funcionar)
- [x] Click derecho NO crashea ✅
- [ ] Formspec se abre correctamente
- [ ] Al menos 1 opción de diálogo funciona
- [ ] Aldeanos se mueven (pathfinding funcional)

### Completamente Funcional
- [ ] Todos los diálogos funcionan
- [ ] Sistema de comercio operativo
- [ ] Saludos automáticos funcionan
- [ ] Los 6 estados de AI funcionan correctamente
- [ ] Ciclo día/noche funciona (sleep)

### Producción-Ready
- [ ] Sin warnings en logs
- [ ] Performance estable con 20 aldeanos
- [ ] Documentación completa
- [ ] Testing exhaustivo completado

---

## 🔗 Referencias

- **Documentación Principal**: README.md
- **Crash Fix Patch**: CRASH_FIX_PATCH.md
- **Sistema AI**: docs/AI_BEHAVIORS.md
- **Integración VoxeLibre**: docs/INTEGRATION_GUIDE.md

---

## 📝 Notas Adicionales

### Problemas Conocidos Resueltos
1. ✅ Crash al click derecho - RESUELTO (2026-01-16)
2. ✅ Emojis causaban crashes - RESUELTO (eliminados)
3. ✅ Pathfinding sin validación - RESUELTO (pcall agregado)

### Próximos Pasos Sugeridos
1. **URGENTE**: Testing básico de diálogos (Fase 1)
2. **IMPORTANTE**: Verificar comportamientos AI (Fase 2)
3. **OPCIONAL**: Resolver warnings de hp_min/hp_max
4. **FUTURO**: Features avanzadas (sonidos, modelos 3D)

---

**Actualizar este archivo** cuando se completen tareas. Marcar con [x] cuando esté verificado.

**Última verificación**: Click derecho funciona ✅ (confirmado por usuario)
**Próxima tarea**: Testing de sistema de diálogos
