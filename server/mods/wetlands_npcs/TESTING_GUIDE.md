# 🧪 Custom Villagers - Guía de Testing

**Versión**: v1.0.1
**Última actualización**: 2026-01-16
**Estado**: Crash fix aplicado ✅ - Testing de funcionalidad pendiente ⚠️

---

## 🎯 Objetivo del Testing

Verificar que los NPCs aldeanos funcionan como **NPCs especiales interactivos** que pueden:
1. ✅ **No crashear** al hacer click derecho (CONFIRMADO)
2. ⚠️ **Hablar** mediante sistema de diálogos (PENDIENTE VERIFICAR)
3. ⚠️ **Comerciar** items por esmeraldas (PENDIENTE VERIFICAR)
4. ⚠️ **Comportarse inteligentemente** con AI tradicional (PENDIENTE VERIFICAR)

---

## 📋 Testing Rápido (5 minutos)

### Test 1: Click Derecho No Crashea ✅
```bash
# En el juego:
/spawn_villager farmer

# Hacer click derecho en el aldeano
# Resultado esperado: Formspec se abre SIN crash del servidor
```

**Estado**: ✅ CONFIRMADO (2026-01-16)

---

### Test 2: Aldeano Puede "Hablar" ⚠️
```bash
# Después de abrir formspec con click derecho:

1. Click en botón "Saludar"
   → Esperado: Mensaje en chat del aldeano

2. Click en botón "Sobre su trabajo"
   → Esperado: Mensaje educativo sobre la profesión

3. Click en botón "Aprender algo nuevo"
   → Esperado: Contenido educativo en chat
```

**Estado**: ⚠️ PENDIENTE DE VERIFICAR

**Mensajes esperados** (ejemplos):

**Farmer** (Saludar):
```
[Aldeano] ¡Hola! Cultivo vegetales frescos y saludables para la comunidad.
```

**Farmer** (Sobre su trabajo):
```
[Aldeano] Trabajo la tierra cada día. Las plantas necesitan agua, luz y cuidado.
```

**Farmer** (Educación):
```
[Aldeano] ¿Sabías que las plantas necesitan nutrientes del suelo? Por eso rotamos cultivos.
```

---

### Test 3: Sistema de Comercio ⚠️
```bash
# Conseguir esmeraldas primero:
/giveme mcl_core:emerald 10

# Abrir formspec de aldeano → Click "Comerciar"
# Esperado: Lista de intercambios disponibles

# Ejemplo con Farmer:
- 5 Zanahorias ← 1 Esmeralda
- 5 Papas ← 1 Esmeralda
- 5 Remolachas ← 1 Esmeralda
- 10 Trigo ← 2 Esmeraldas

# Intentar un intercambio
# Esperado: Items se intercambian, mensaje de éxito
```

**Estado**: ⚠️ PENDIENTE DE VERIFICAR

---

### Test 4: Saludo Automático ⚠️
```bash
# Spawnear aldeano:
/spawn_villager teacher

# Caminar cerca del aldeano (5 bloques de distancia)
# Esperar ~30 segundos
# Esperado: Aldeano te saluda en chat

# Mensaje esperado:
[Aldeano] ¡Buenos días, [tu_nombre]! ¿Listo para aprender?
```

**Estado**: ⚠️ PENDIENTE DE VERIFICAR

**NOTA**: Mensajes NO deben tener emojis (fix aplicado)

---

## 🔬 Testing Completo (30 minutos)

### Preparación
```bash
# Activar modo debug
/villager_debug on

# Esto mostrará logs de cambios de estado en consola del servidor
```

---

### Test Completo: Los 4 Tipos de Aldeanos

#### 1. Agricultor (Farmer)
```bash
/spawn_villager farmer

# Verificar:
- [ ] Click derecho abre formspec ✅
- [ ] "Saludar" muestra mensaje sobre agricultura
- [ ] "Sobre su trabajo" habla de cultivos
- [ ] "Educación" enseña sobre plantas
- [ ] "Comerciar" ofrece: zanahorias, papas, remolachas, trigo
- [ ] En estado WORK busca cultivos cercanos
- [ ] Camina hacia bloques de farming
```

#### 2. Bibliotecario (Librarian)
```bash
/spawn_villager librarian

# Verificar:
- [ ] Click derecho abre formspec ✅
- [ ] "Saludar" habla sobre conocimiento
- [ ] "Sobre su trabajo" explica importancia de libros
- [ ] "Educación" enseña sobre lectura
- [ ] "Comerciar" ofrece: libros, papel
- [ ] En estado WORK busca estanterías (mcl_books:bookshelf)
```

#### 3. Maestro (Teacher)
```bash
/spawn_villager teacher

# Verificar:
- [ ] Click derecho abre formspec ✅
- [ ] "Saludar" saluda como educador
- [ ] "Sobre su trabajo" habla de enseñanza
- [ ] "Educación" enseña sobre compasión animal
- [ ] "Comerciar" ofrece: libros educativos, papel
- [ ] Saludo automático: "¡Buenos días, [nombre]! ¿Listo para aprender?"
```

#### 4. Explorador (Explorer)
```bash
/spawn_villager explorer

# Verificar:
- [ ] Click derecho abre formspec ✅
- [ ] "Saludar" habla sobre viajes
- [ ] "Sobre su trabajo" explica exploración de biomas
- [ ] "Educación" enseña sobre biodiversidad
- [ ] "Comerciar" ofrece: manzanas, palos
- [ ] En estado WORK busca: árboles, flores, agua
- [ ] Estado WANDER más frecuente (60% del tiempo)
```

---

### Test de Comportamientos AI

#### Estado: IDLE (Parado)
```bash
# Observar aldeano durante 1-2 minutos
# Verificar:
- [ ] Aldeano se queda quieto ocasionalmente
- [ ] Rota la cabeza mirando alrededor
- [ ] Permanece en IDLE por 10-20 segundos

# Ver estado actual:
/villager_state
```

#### Estado: WANDER (Caminar aleatorio)
```bash
# Observar aldeano caminando
# Verificar:
- [ ] Camina hacia posiciones aleatorias
- [ ] No se aleja más de ~10 bloques de spawn
- [ ] Cambia dirección cada ~10 segundos
- [ ] NO crashea durante pathfinding ✅ (fix aplicado)

# Debug:
/villager_state
# Debería mostrar: "wander (Xs)" donde X es tiempo en estado
```

#### Estado: WORK (Trabajar)
```bash
# Plantar cultivos cerca de un Farmer
/giveme mcl_farming:wheat_item 10
# (Plantar trigo cerca del farmer)

# Observar durante 2-3 minutos
# Verificar:
- [ ] Farmer busca y camina hacia cultivos
- [ ] Se queda cerca del cultivo
- [ ] Muestra partículas de burbujas ocasionalmente
- [ ] Cambia de cultivo después de ~10 segundos

# Debug:
/villager_state
# Debería mostrar: "work (Xs)"
```

#### Estado: SOCIAL (Interactuar con otros NPCs)
```bash
# Spawnear 2 aldeanos cercanos
/spawn_villager farmer
/spawn_villager teacher

# Esperar 1-2 minutos
# Verificar:
- [ ] Aldeanos se acercan entre ellos
- [ ] Se miran uno al otro (cara a cara)
- [ ] Muestran partículas de corazón ocasionalmente
- [ ] Permanecen cerca ~15 segundos

# Debug:
/villager_state
# Uno debería mostrar: "social (Xs)"
```

#### Estado: SLEEP (Dormir)
```bash
# Cambiar hora a noche
/time 20000

# Observar aldeanos
# Verificar:
- [ ] Aldeanos buscan camas cercanas
- [ ] Caminan hacia cama más cercana
- [ ] Se quedan quietos al llegar
- [ ] Muestran partículas de burbujas (sueño)

# Al amanecer:
/time 1000

# Verificar:
- [ ] Aldeanos despiertan automáticamente
- [ ] Retoman comportamientos normales (IDLE, WANDER, WORK)

# Debug:
/villager_state
# De noche debería mostrar: "sleep (Xs)"
```

#### Estado: SEEK_PLAYER (Buscar jugador)
```bash
# Caminar cerca de aldeano (5 bloques)
# Esperar ~30 segundos

# Verificar:
- [ ] Aldeano detecta jugador
- [ ] Camina hacia el jugador
- [ ] Saluda al llegar cerca
- [ ] NO vuelve a saludar por 30 segundos (cooldown)

# Mensajes esperados (sin emojis):
- Farmer: "¡Hola, [nombre]! ¡Qué bueno verte!"
- Librarian: "Saludos, [nombre]. ¿Buscas algo de conocimiento?"
- Teacher: "¡Buenos días, [nombre]! ¿Listo para aprender?"
- Explorer: "¡Aventurero [nombre]! ¿Vas a explorar hoy?"

# Debug:
/villager_state
# Debería mostrar: "seek_player (Xs)"
```

---

### Test de Escalabilidad

#### Test 1: 5 Aldeanos
```bash
/spawn_villager farmer
/spawn_villager farmer
/spawn_villager librarian
/spawn_villager teacher
/spawn_villager explorer

# Observar durante 5 minutos
# Verificar:
- [ ] Todos se mueven sin lag
- [ ] Interacciones funcionan correctamente
- [ ] No hay crashes
- [ ] Performance estable
```

#### Test 2: 10 Aldeanos
```bash
# Spawnear 10 aldeanos mezclados
# (5 farmers, 2 librarians, 2 teachers, 1 explorer)

# Verificar:
- [ ] Servidor no se ralentiza
- [ ] Pathfinding funciona para todos
- [ ] Interacciones sociales entre múltiples NPCs
- [ ] No hay crashes con clicks masivos

# Stress test:
- Hacer click derecho rápido en varios aldeanos
- Verificar que formspecs abren correctamente
- No debería crashear ✅
```

#### Test 3: Límite Máximo (20 Aldeanos)
```bash
# Spawnear hasta el límite configurado
# (max_total_villagers = 20)

# Verificar:
- [ ] Sistema limita spawning a 20 aldeanos
- [ ] Performance aceptable con 20 NPCs
- [ ] No hay memory leaks
- [ ] Servidor estable

# Monitorear:
docker-compose logs --tail=50 luanti-server
```

---

## 📊 Checklist de Verificación Completa

### Funcionalidad Básica
- [x] Click derecho NO crashea ✅ (CONFIRMADO)
- [ ] Formspec se abre correctamente
- [ ] Botón "Saludar" funciona
- [ ] Botón "Sobre su trabajo" funciona
- [ ] Botón "Aprender algo nuevo" funciona
- [ ] Botón "Comerciar" funciona
- [ ] Botón "Cerrar" funciona

### Sistema de Diálogos
- [ ] Farmer muestra mensajes apropiados
- [ ] Librarian muestra mensajes apropiados
- [ ] Teacher muestra mensajes apropiados
- [ ] Explorer muestra mensajes apropiados
- [ ] Mensajes son educativos y apropiados para niños 7+
- [ ] NO hay emojis en mensajes ✅ (fix aplicado)

### Sistema de Comercio
- [ ] Formspec de comercio se abre
- [ ] Muestra items correctos por profesión
- [ ] Intercambio funciona con esmeraldas
- [ ] Inventario se actualiza correctamente
- [ ] Mensajes de éxito/fallo aparecen

### Comportamientos AI
- [ ] Estado IDLE funciona
- [ ] Estado WANDER funciona
- [ ] Estado WORK funciona (busca POIs)
- [ ] Estado SOCIAL funciona (interacción NPCs)
- [ ] Estado SLEEP funciona (ciclo día/noche)
- [ ] Estado SEEK_PLAYER funciona (saludos automáticos)
- [ ] Transiciones entre estados fluidas

### Pathfinding
- [ ] Aldeanos caminan sin atascarse
- [ ] Navegan hacia objetivos correctamente
- [ ] NO crashean durante movimiento ✅ (fix aplicado)
- [ ] Anti-stuck funciona (cambian a WANDER si atascados)

### Partículas y Efectos
- [ ] Partículas de trabajo (burbujas)
- [ ] Partículas de social (corazones)
- [ ] Partículas de sueño (burbujas)
- [ ] No causan lag

### Performance y Estabilidad
- [ ] Funciona con 1 aldeano
- [ ] Funciona con 5 aldeanos
- [ ] Funciona con 10 aldeanos
- [ ] Funciona con 20 aldeanos (límite)
- [ ] No hay memory leaks
- [ ] CPU/RAM estables

---

## 🐛 Reporte de Bugs

Si encuentras problemas, documenta:

```
PROBLEMA ENCONTRADO:
- ¿Qué estabas haciendo?
- ¿Qué aldeano(s)?
- ¿Qué sucedió?
- ¿Error en logs?

LOGS:
/villager_state
docker-compose logs --tail=50 luanti-server | grep custom_villagers
```

---

## ✅ Criterios de Éxito

### Mínimo Funcional
- [x] Click derecho funciona ✅
- [ ] Al menos 1 diálogo funciona
- [ ] Aldeanos se mueven

### Completamente Operativo
- [ ] Todos los diálogos funcionan
- [ ] Comercio funciona
- [ ] Los 6 estados AI funcionan
- [ ] Saludos automáticos funcionan

### Listo para Producción
- [ ] Todos los tests pasados
- [ ] Sin crashes reportados
- [ ] Performance óptima
- [ ] Documentación actualizada

---

**Próxima acción sugerida**: Testing de sistema de diálogos (Test 2)

**Documentar resultados en**: TODO.md (marcar checkboxes completados)
