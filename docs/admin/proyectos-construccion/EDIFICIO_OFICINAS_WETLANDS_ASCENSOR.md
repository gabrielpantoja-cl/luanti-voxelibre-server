# 🏢 Edificio "Oficinas Wetlands" - Sistema de Ascensor Completo

**Última Actualización**: 2025-11-09
**Estado**: ✅ GUÍA DEFINITIVA - Configuración Validada (Método "Builder Dave")
**Propósito**: Fuente única de verdad para construcción, configuración y troubleshooting del ascensor de 13 pisos

---

## 📋 Índice Rápido

1. [Principios Fundamentales del Mod celevator](#principios-fundamentales)
2. [Configuración de Testeo (3 pisos)](#configuración-de-testeo-rápido)
3. [Orden EXACTO de Instalación](#orden-exacto-de-instalación)
4. [Configuración de Production (13 pisos)](#configuración-de-production)
5. [Troubleshooting](#troubleshooting)
6. [Protección del Área](#protección-del-área)

**🚨 REGLA DE ORO**: La cabina SIEMPRE se coloca AL FINAL, después de machine, controller, drive, puertas y botones.

---

## 🎯 Principios Fundamentales del Mod celevator {#principios-fundamentales}

### ✅ Arquitectura Correcta (Validada Sep 2025)

**Fuente**: Video de Luanti Builder Dave + arquitectura de ascensores reales

```
Y=68: [Machine] [Controller] [Drive]  ← SALA DE MÁQUINAS (mismo nivel)
      ↑         ↑            ↑
      Centro    Al lado      Al lado
      del pozo
Y=67: [Techo del piso 13] ← Bloque sólido
Y=66: [Puerta Piso 13] + [Botones]
...
Y=17: [Puerta Piso 1] + [Botones] + [Cabina ÚNICA]
```

### 🚨 Concepto CRÍTICO: UNA Sola Cabina Móvil

**❌ INCORRECTO**:
- Colocar 13 cabinas (una por piso)
- Cabinas estáticas en cada nivel

**✅ CORRECTO**:
- **UNA SOLA cabina móvil** que el controller mueve programáticamente
- La cabina viaja entre pisos dinámicamente
- El sistema es como un ascensor real

### 🔑 Componentes Principales

| Componente | Cantidad | Ubicación | Función |
|------------|----------|-----------|---------|
| `machine` | 1 | Sala de máquinas (Y=68) | Motor del ascensor (centro del pozo) |
| `controller` | 1 | Sala de máquinas (Y=68) | Cerebro del sistema (al lado de machine) |
| `drive` | 1 | Sala de máquinas (Y=68) | Sistema de tracción (al lado de machine) |
| `car_glassback` | 1 | Piso inicial (Y=17) | Cabina móvil (única) |
| `hwdoor_glass` | N pisos | Cada piso | Puertas automáticas |
| `callbutton_*` | N pisos | Junto a puertas | Botones de llamada |

---

## 🧪 Configuración de Testeo Rápido (3 Pisos) {#configuración-de-testeo-rápido}

### ¿Por Qué Testear con 3 Pisos?

**Razón**: El error más común es **"Hoist Machine Missing"**. Testear con 3 pisos permite:
- ✅ Verificar que machine, controller y drive se detectan correctamente
- ✅ Probar movimiento de cabina en menos de 1 minuto
- ✅ Validar configuración antes de instalar 13 pisos completos
- ✅ Debugging rápido sin esperar recorridos largos

### Configuración del Controller (Modo Testeo)

Cuando abres el controller por primera vez, configura:

```
Car ID: 1
Number of floors: 3          ← Solo 3 pisos para testeo
Floor height: 5              ← Altura total por piso
Bottom floor Y: 17           ← Coordenada Y del piso 1
Speed: 5                     ← m/s (recomendado)
```

### Puertas Mínimas para Testeo

Solo necesitas instalar **3 puertas**:
- Piso 1: Y=17 (puerta + botón UP)
- Piso 2: Y=22 (puerta + botón BOTH)
- Piso 3: Y=27 (puerta + botón DOWN)

### Comandos de Testeo Rápido

```bash
# 1. Ir al piso 1 y llamar cabina
/teleport gabo 88 17 -43
# Presionar botón de llamada → La puerta debe abrirse

# 2. Entrar a cabina y subir a piso 2
# Clic derecho dentro de cabina → Presionar botón "2"
# La cabina debe moverse suavemente a Y=22

# 3. Subir a piso 3
# Presionar botón "3"
# La cabina debe llegar a Y=27

# 4. Regresar a piso 1
# Presionar botón "1"
# La cabina debe bajar a Y=17
```

### ✅ Indicadores de Éxito del Testeo

Si todos estos puntos funcionan, **tu configuración es correcta**:
- ✅ Controller muestra "READY" o "IDLE" (no "FAULT")
- ✅ Botones de llamada abren puertas
- ✅ Cabina se mueve entre 3 pisos sin errores
- ✅ No aparece mensaje "Hoist Machine Missing"

**Ahora puedes escalar a 13 pisos** cambiando solo un parámetro:
```
Number of floors: 13  ← Cambiar de 3 a 13 en controller
```

---

## 🏗️ Orden EXACTO de Instalación {#orden-exacto-de-instalación}

### 🚨 REGLA DE ORO

**NUNCA coloques componentes en este orden incorrecto**:
❌ Cabina → Machine → Controller → Drive (causa "machine missing")

**SIEMPRE sigue este orden**:
✅ Machine → Controller → Drive → Cabina (orden correcto validado)

---

### PASO 1: Obtención de Materiales

```bash
# Componentes principales
/give gabo celevator:machine 1
/give gabo celevator:controller 1
/give gabo celevator:drive 1
/give gabo celevator:car_glassback 1

# Para testeo (3 pisos)
/give gabo celevator:hwdoor_glass 3
/give gabo celevator:callbutton_up 1
/give gabo celevator:callbutton_down 1
/give gabo celevator:callbutton_both 1

# Para production (13 pisos)
/give gabo celevator:hwdoor_glass 13
/give gabo celevator:callbutton_up 1
/give gabo celevator:callbutton_down 1
/give gabo celevator:callbutton_both 11
```

---

### PASO 2: Instalación de MACHINE (PRIMERO)

**⚠️ CRÍTICO**: La machine debe ser el PRIMER componente instalado.

```bash
# Ir a la sala de máquinas (altura libre)
/teleport gabo 88 69 -43

# Verificar que estás en AIRE LIBRE con piso sólido en Y=68
# Colocar la MACHINE mirando hacia abajo
# La machine quedará en Y=68 (sobre el techo del piso 13)
```

**Posición Final de Machine**: `(88, 68, -43)` o `(89, 68, -43)` (centro del pozo)

**🔑 Configuración del Car ID en Machine**:
1. Haz **clic derecho** en la `machine` recién colocada
2. Aparecerá una interfaz con el campo **"Car ID"**
3. Ingresa: `1` (o el número que prefieras, debe ser único)
4. **Guardar** la configuración

**Por qué es importante**: El Car ID conecta la machine con el controller y los botones. Todos deben usar el mismo ID.

---

### PASO 3: Instalación de CONTROLLER (SEGUNDO)

```bash
# Ir al mismo nivel de la machine (Y=68)
/teleport gabo 87 68 -43

# Colocar el CONTROLLER al lado de la machine
# Debe quedar en Y=68 (mismo nivel)
```

**Posición Final de Controller**: `(87, 68, -43)` o `(88, 68, -43)` (al lado de machine)

**🔑 Configuración del Car ID en Controller**:
1. Haz **clic derecho** en el `controller` recién colocado
2. Configurar los siguientes parámetros **EXACTOS**:

**Para Testeo (3 pisos)**:
```
Car ID: 1                    ← DEBE coincidir con machine
Number of floors: 3
Floor height: 5
Bottom floor Y: 17
Speed: 5
```

**Para Production (13 pisos)**:
```
Car ID: 1                    ← DEBE coincidir con machine
Number of floors: 13
Floor height: 5
Bottom floor Y: 17
Speed: 5
```

3. **Guardar** la configuración
4. **Esperar 10 segundos** → El controller debe mostrar "READY"

---

### PASO 4: Instalación de DRIVE (TERCERO)

```bash
# Ir al mismo nivel de machine y controller (Y=68)
/teleport gabo 88 68 -42

# Colocar el DRIVE al lado de la machine
# Debe quedar en Y=68 (mismo nivel)
```

**Posición Final de Drive**: `(88, 68, -42)` o `(89, 68, -42)` (al lado de machine)

**Nota**: El drive NO tiene configuración de Car ID. Se conecta automáticamente al controller.

---

### PASO 5: Instalación de CABINA (ÚLTIMO)

**⚠️ IMPORTANTE**: La cabina se instala AL FINAL, después de machine, controller y drive.

```bash
# Ir al piso 1 (nivel inicial)
/teleport gabo 88 17 -43

# Colocar UNA SOLA cabina car_glassback
# Debe quedar en Y=17 (piso inicial)
```

**Posición Final de Cabina**: `(88, 17, -43)` (centro del pozo, piso 1)

**🚨 Error Común**: Si colocas la cabina ANTES que el controller, aparecerá "machine missing". Solución: excavar cabina, reconfigurar controller, volver a colocar cabina.

---

### PASO 6: Instalación de Puertas y Botones

#### Para Testeo (3 pisos):

**Piso 1 (Y=17)**:
```bash
/teleport gabo 88 17 -43
# Colocar puerta hwdoor_glass frente al pozo
# Colocar callbutton_up al lado de la puerta
# Configurar Car ID = 1 en el botón (clic derecho)
```

**Piso 2 (Y=22)**:
```bash
/teleport gabo 88 22 -43
# Colocar puerta hwdoor_glass
# Colocar callbutton_both
# Configurar Car ID = 1 en el botón
```

**Piso 3 (Y=27)**:
```bash
/teleport gabo 88 27 -43
# Colocar puerta hwdoor_glass
# Colocar callbutton_down
# Configurar Car ID = 1 en el botón
```

**🔑 Configuración del Car ID en Botones**:
1. Haz **clic derecho** en cada botón después de colocarlo
2. Aparecerá una interfaz con el campo **"Car ID"**
3. Ingresa: `1` (DEBE coincidir con machine y controller)
4. **Guardar**

**Por qué es crítico**: Si el botón tiene Car ID diferente, no llamará a la cabina correcta.

---

### PASO 7: Pruebas del Sistema

```bash
# TEST 1: Verificar controller
/teleport gabo 87 68 -43
# Clic derecho en controller → debe mostrar "READY" o "IDLE"

# TEST 2: Llamar cabina desde piso 1
/teleport gabo 88 17 -43
# Presionar callbutton_up
# La puerta debe abrirse
# La cabina debe aparecer (si no está ya ahí)

# TEST 3: Viajar a piso 2
# Entrar a cabina 
# Clic derecho dentro de cabina
# Presionar botón "2"
# La cabina debe moverse suavemente a Y=22

# TEST 4: Viajar a piso 3
# Presionar botón "3"
# La cabina debe subir a Y=27

# TEST 5: Regresar a piso 1
# Presionar botón "1"
# La cabina debe bajar a Y=17
```

---

### 📊 Resumen de Posiciones (Configuración Correcta)

**Sala de Máquinas** (Todos en Y=68):
```
Y=68: Machine (88, 68, -43)      ← Car ID = 1
Y=68: Controller (87, 68, -43)   ← Car ID = 1, Floors = 3 o 13
Y=68: Drive (88, 68, -42)        ← Auto-conecta
```

**Pisos** (Testeo 3 pisos):
```
Y=27: Puerta + Botón DOWN (Car ID = 1)   ← Piso 3
Y=22: Puerta + Botón BOTH (Car ID = 1)   ← Piso 2
Y=17: Puerta + Botón UP (Car ID = 1) + CABINA ÚNICA  ← Piso 1
```

---

## 🏭 Configuración de Production (13 Pisos) {#configuración-de-production}

### Cambios Necesarios desde Testeo

Si ya validaste el sistema con 3 pisos, solo necesitas:

1. **Actualizar Controller**:
```bash
/teleport gabo 87 68 -43
# Clic derecho en controller
# Cambiar: Number of floors: 3 → 13
# Guardar
```

2. **Instalar Puertas y Botones Adicionales**:
```bash
# Piso 4: Y=32
/teleport gabo 88 32 -43
# Puerta + callbutton_both (Car ID = 1)

# Piso 5: Y=37
/teleport gabo 88 37 -43
# Puerta + callbutton_both (Car ID = 1)

# ... repetir hasta Piso 13 (Y=77)
```

### Tabla de Coordenadas Y (13 Pisos)

| Piso | Y | Tipo de Botón | Cálculo |
|------|---|---------------|---------|
| 1 | 17 | UP | 17 + 0×5 = 17 |
| 2 | 22 | BOTH | 17 + 1×5 = 22 |
| 3 | 27 | BOTH | 17 + 2×5 = 27 |
| 4 | 32 | BOTH | 17 + 3×5 = 32 |
| 5 | 37 | BOTH | 17 + 4×5 = 37 |
| 6 | 42 | BOTH | 17 + 5×5 = 42 |
| 7 | 47 | BOTH | 17 + 6×5 = 47 |
| 8 | 52 | BOTH | 17 + 7×5 = 52 |
| 9 | 57 | BOTH | 17 + 8×5 = 57 |
| 10 | 62 | BOTH | 17 + 9×5 = 62 |
| 11 | **67** | BOTH | 17 + 10×5 = **67** |
| 12 | **72** | BOTH | 17 + 11×5 = **72** |
| 13 | **77** | DOWN | 17 + 12×5 = **77** |

**Fórmula**: `Y_piso = Bottom_floor_Y + (piso - 1) × floor_height`
**Nota**: Altura por piso = 5 bloques (3 habitables + 1 piso + 1 techo)
**🚨 IMPORTANTE**: Coordenadas corregidas (pisos 11-13 estaban incorrectos)

---

## 🔧 Troubleshooting {#troubleshooting}

### 🚨 CRÍTICO: Cómo Remover Cabinas Duplicadas

**⚠️ IMPORTANTE**: Las cabinas del mod celevator son bloques **3x3x3** (27 nodos). Cuando colocas una cabina, el mod genera automáticamente 27 bloques con nombres como:
- `celevator:car_glassback` (bloque central)
- `celevator:car_glassback_000`, `_001`, `_002`, ..., `_122` (bloques adicionales)

#### ❌ Problema Común: Cabinas Duplicadas

**Síntomas**:
- Múltiples cabinas visibles en el pozo
- Cabina no responde a comandos
- Sistema muestra errores intermitentes

**Causa**: Colocar la cabina múltiples veces (cada clic crea una cabina 3x3x3 completa)

#### ✅ Método 1: Remover Cabinas Manualmente (Recomendado para 1-2 cabinas)

```bash
# PASO 1: Ir a la ubicación de la cabina duplicada
/teleport gabo 88 17 -43

# PASO 2: Excavar el BLOQUE CENTRAL de la cabina
# Busca el bloque que dice "celevator:car_glassback" (sin números al final)
# Haz CLIC IZQUIERDO en ese bloque

# IMPORTANTE: Al excavar el bloque central, los otros 26 bloques
# se eliminan automáticamente
```

**Cómo identificar el bloque central**:
1. Activa el modo debug: Presiona `F5` varias veces hasta ver información de nodos
2. Apunta a diferentes bloques de la cabina
3. El bloque central mostrará: `celevator:car_glassback` (sin `_000`, `_001`, etc.)
4. Excava solo ese bloque

#### ✅ Método 2: Usar WorldEdit (Recomendado para Múltiples Cabinas)

**⚠️ PELIGRO**: Este método elimina TODAS las cabinas en el área seleccionada.

```bash
# PASO 1: Ir a la esquina inferior del pozo
/teleport gabo 85 14 -45
//pos1  # (o /1)

# PASO 2: Ir a la esquina superior del área a limpiar
# Para limpiar solo los primeros 3 pisos (testeo):
/teleport gabo 91 30 -41
//pos2  # (o /2)

# Para limpiar todo el pozo (13 pisos):
/teleport gabo 91 80 -41
//pos2

# PASO 3: Eliminar TODAS las variantes de cabinas

# 3A. Eliminar Glass-Back Elevator Car (19 variantes)
//replace celevator:car_glassback air
//replace celevator:car_glassback_000 air
//replace celevator:car_glassback_001 air
//replace celevator:car_glassback_002 air
//replace celevator:car_glassback_010 air
//replace celevator:car_glassback_011 air
//replace celevator:car_glassback_012 air
//replace celevator:car_glassback_020 air
//replace celevator:car_glassback_021 air
//replace celevator:car_glassback_022 air
//replace celevator:car_glassback_100 air
//replace celevator:car_glassback_101 air
//replace celevator:car_glassback_102 air
//replace celevator:car_glassback_110 air
//replace celevator:car_glassback_111 air
//replace celevator:car_glassback_112 air
//replace celevator:car_glassback_120 air
//replace celevator:car_glassback_121 air
//replace celevator:car_glassback_122 air

# 3B. Eliminar Basic Elevator Car (19 variantes)
# IMPORTANTE: Si el panel negro persiste, es probable que sea una cabina básica
//replace celevator:car_basic air
//replace celevator:car_basic_000 air
//replace celevator:car_basic_001 air
//replace celevator:car_basic_002 air
//replace celevator:car_basic_010 air
//replace celevator:car_basic_011 air
//replace celevator:car_basic_012 air
//replace celevator:car_basic_020 air
//replace celevator:car_basic_021 air
//replace celevator:car_basic_022 air
//replace celevator:car_basic_100 air
//replace celevator:car_basic_101 air
//replace celevator:car_basic_102 air
//replace celevator:car_basic_110 air
//replace celevator:car_basic_111 air
//replace celevator:car_basic_112 air
//replace celevator:car_basic_120 air
//replace celevator:car_basic_121 air
//replace celevator:car_basic_122 air

# PASO 4: Verificar que el pozo está limpio
/teleport gabo 88 17 -43
# Vuela por el pozo - NO deberías ver ninguna cabina
```

#### ✅ Método 3: Diagnóstico desde VPS (Ver cuántas cabinas hay)

```bash
# Ejecutar desde tu terminal local
ssh gabriel@<IP_VPS_ANTERIOR> "cd /home/gabriel/luanti-voxelibre-server && docker-compose logs luanti-server 2>&1 | grep 'places node celevator:car_glassback at' | tail -20"

# Esto muestra las últimas 20 veces que se colocó una cabina
# Ejemplo de salida:
# gabo places node celevator:car_glassback at (88,17,-43)  ← Cabina en Y=17
# gabo places node celevator:car_glassback at (88,17,-43)  ← Duplicada!
# gabo places node celevator:car_glassback at (84,70,-44)  ← Otra cabina en Y=70 (MAL)
```

#### 🎯 Estrategia Recomendada para Testeo de 3 Pisos

```bash
# 1. LIMPIAR COMPLETAMENTE el pozo de los primeros 3 pisos
//pos1  (en 85,14,-45)
//pos2  (en 91,30,-41)
//replace celevator:car_glassback air

# 2. VERIFICAR que no hay cabinas
/teleport gabo 88 17 -43
/teleport gabo 88 22 -43
/teleport gabo 88 27 -43
# No deberías ver cabinas en ninguno de estos niveles

# 3. COLOCAR UNA SOLA CABINA en el piso 1
/teleport gabo 88 17 -43
# Coloca EXACTAMENTE UNA VEZ la cabina (clic derecho una vez)
# Espera 2 segundos para que el mod genere todos los bloques

# 4. VERIFICAR que solo hay UNA cabina
# Vuela por el pozo Y=17 a Y=27
# Debería haber SOLO UNA cabina en Y=17
```

#### 🐛 Debugging: ¿Por qué se duplican las cabinas?

**Causas comunes**:
1. **Lag del servidor**: Clic derecho múltiples veces porque el servidor no responde de inmediato
2. **Doble clic accidental**: Presionar el botón derecho del mouse dos veces
3. **Reinstalación sin limpiar**: Colocar cabina nueva sin excavar la anterior

**Prevención**:
- ✅ Espera 2 segundos después de colocar la cabina
- ✅ Verifica visualmente que la cabina apareció antes de hacer clic de nuevo
- ✅ Si el servidor tiene lag, espera a que el lag termine
- ✅ Siempre limpia el área ANTES de colocar una cabina nueva

---

### 🎨 Texturas Persistentes (Panel Negro Después de Eliminar)

**Síntoma**: Después de eliminar cabinas con WorldEdit (0 nodos reemplazados), aún se ve un panel negro o textura de cabina en el piso 1.

**Causa**: **Caché de texturas del servidor** no actualizado. Los bloques ya fueron eliminados en el mundo, pero el servidor mantiene la textura en memoria.

**Solución INMEDIATA**:

```bash
# PASO 1: Reiniciar el servidor (MÉTODO RECOMENDADO)
ssh gabriel@<IP_VPS_ANTERIOR> "cd /home/gabriel/luanti-voxelibre-server && docker-compose restart luanti-server"

# PASO 2: Esperar 10 segundos para que el servidor reinicie
# PASO 3: Reconectar al servidor desde el cliente Luanti
# PASO 4: El panel negro debería desaparecer
```

**Soluciones Alternativas (si el panel persiste)**:

**Opción 1: Reconectar Cliente**
```bash
# 1. Desconectar del servidor (en el juego)
# 2. Cerrar completamente el cliente Luanti
# 3. Reabrir Luanti y reconectar
# 4. El caché del cliente se limpiará
```

**Opción 2: Limpiar Caché de Texturas del Cliente**
```bash
# En Linux (cliente local):
rm -rf ~/.minetest/cache/media/*

# En Windows:
# Eliminar: C:\Users\<tu_usuario>\AppData\Roaming\Minetest\cache\media\
```

**Opción 3: Forzar Actualización del Área**
```bash
# En el juego, como admin:
/teleport gabo 88 17 -43

# Colocar y excavar un bloque temporal para forzar actualización
# 1. Coloca un bloque de piedra en el área del panel negro
# 2. Excávalo inmediatamente
# 3. Esto fuerza al servidor a actualizar esa región
```

**🔑 Lección Aprendida**:
- ✅ **Siempre reinicia el servidor** después de usar WorldEdit para eliminar estructuras grandes (como cabinas 3x3x3)
- ✅ Las texturas persistentes NO significan que los bloques siguen ahí
- ✅ Es un problema de caché, no de datos del mundo

---

### Error: "Hoist Machine Missing"

**Síntoma**: Controller muestra "FAULT: Machine Missing"

**Causas Comunes**:
1. ✅ Machine NO está en posición guardada en controller
2. ✅ Machine movida después de configurar controller
3. ✅ Cabina colocada ANTES que controller

**Solución Rápida**:
```bash
# PASO 1: Excavar machine, controller, drive y cabina
/teleport gabo 88 68 -43
# Excavar todos los componentes

# PASO 2: Reinstalar en ORDEN CORRECTO
# Machine → Controller → Drive → Cabina
# (Ver sección "Orden EXACTO de Instalación")

# PASO 3: Reconfigurar controller
# Car ID = 1, Floors = 3, Height = 5, Bottom Y = 17
```

---

### Error: Cabina No Se Mueve

**Síntoma**: Botones funcionan, puertas abren, pero cabina no viaja

**Causas Comunes**:
1. ✅ Car ID diferente entre machine, controller y botones
2. ✅ Drive no detecta machine (más de 500 bloques de distancia)
3. ✅ Múltiples cabinas en el pozo

**Solución**:
```bash
# VERIFICAR Car ID en machine
/teleport gabo 88 68 -43
# Clic derecho en machine → Car ID = 1

# VERIFICAR Car ID en controller
/teleport gabo 87 68 -43
# Clic derecho en controller → Car ID = 1

# VERIFICAR Car ID en botones
/teleport gabo 88 17 -43
# Clic derecho en callbutton_up → Car ID = 1

# VERIFICAR UNA SOLA CABINA
/teleport gabo 88 17 -43
# Debe haber solo 1 cabina. Si hay más, excavar las extras.
```

---

### Error: Controller Muestra "IDLE" pero No Responde

**Síntoma**: Controller no muestra error pero no reacciona a botones

**Causa**: Car ID en botones diferente al del sistema

**Solución**:
```bash
# Reconfigurar TODOS los botones con Car ID = 1
/teleport gabo 88 17 -43
# Clic derecho en cada botón → Car ID = 1
```

---

### Error: Cabina Llega 1 Bloque Abajo/Arriba (Puerta No Se Abre)

**🚨 PROBLEMA CRÍTICO**: Ascensor llega desalineado con la puerta

**Síntoma**:
- Cabina se detiene 1 bloque ABAJO de la puerta (ej. Y=21 en vez de Y=22)
- Puerta no se abre porque la cabina no está alineada
- Jugadores quedan atrapados entre pisos

**Causa Real**: **Floor Table del controller tiene coordenadas Y incorrectas**

**✅ SOLUCIÓN (Sin Reiniciar Servidor)**:

```bash
# PASO 1: Ir al controller
/teleport gabo 87 68 -43

# PASO 2: Abrir controller
# Clic derecho en controller

# PASO 3: Editar Floor Table
# Clic en botón "Edit Floor Table"

# PASO 4: Corregir TODAS las coordenadas Y manualmente
# La tabla debe tener EXACTAMENTE estos valores:
```

**Floor Table Correcta** (copiar estos valores exactos):
```
Floor 1:  Y = 17
Floor 2:  Y = 22
Floor 3:  Y = 27
Floor 4:  Y = 32
Floor 5:  Y = 37
Floor 6:  Y = 42
Floor 7:  Y = 47
Floor 8:  Y = 52
Floor 9:  Y = 57
Floor 10: Y = 62
Floor 11: Y = 67
Floor 12: Y = 72
Floor 13: Y = 77
```

**PASO 5: Guardar**:
1. Clic en "Save" en la ventana de Floor Table
2. Esperar 5 segundos
3. Controller debe mostrar "READY"

**PASO 6: Probar**:
```bash
/teleport gabo 88 17 -43
# Entrar al ascensor
# Ir a cualquier piso
# Verificar que la cabina llegue EXACTAMENTE al nivel de la puerta
```

**🔑 Lección Crítica**:
- ✅ El controller tiene una **Floor Table interna** que sobrescribe los cálculos automáticos
- ✅ Esta tabla se configura solo una vez y persiste en el mundo
- ✅ Si la tabla tiene valores incorrectos, el ascensor NUNCA funcionará bien
- ✅ La tabla debe editarse **manualmente piso por piso**

---

### Error: Cabina Se Queda Atascada Entre Pisos

**Síntoma**: Cabina se detiene en Y intermedia (ej. Y=20 en vez de Y=22)

**Causas Comunes**:
1. ✅ Obstáculos en el pozo (bloques, entidades)
2. ✅ Puertas mal instaladas (bloquean paso)
3. ✅ Floor height incorrecto en controller

**Solución**:
```bash
# VERIFICAR floor height
/teleport gabo 87 68 -43
# Clic derecho en controller → Floor height = 5 (debe coincidir con arquitectura)

# LIMPIAR OBSTRUCCIONES
//pos1 (esquina inferior del pozo)
//pos2 (esquina superior del pozo)
//replace celevator:car_glassback air  (eliminar cabinas extra)
# Verificar visualmente que el pozo está despejado
```

---

## 🛡️ Protección del Área {#protección-del-área}

### Comando Rápido

```bash
# Ir al centro del ascensor
/teleport gabo 88 45 -43

# Proteger 25 bloques de radio
/protect_here 25 oficinas-wetlands-ascensor

# Verificar
/list_areas
```

### Método Manual (Más Preciso)

```bash
# Esquina 1 (fondo del pozo)
/teleport gabo 85 14 -46
/pos1

# Esquina 2 (techo sala de máquinas)
/teleport gabo 91 78 -40
/pos2

# Crear área protegida
/protect_area oficinas-wetlands-ascensor
```

---

## 📊 Checklist de Instalación

### Checklist de Testeo (3 Pisos)

- [ ] Machine instalada en Y=68 (Car ID = 1)
- [ ] Controller instalado en Y=68 (Car ID = 1, Floors = 3)
- [ ] Drive instalado en Y=68
- [ ] Cabina instalada en Y=17 (una sola)
- [ ] 3 puertas instaladas (Y=17, 22, 27)
- [ ] 3 botones instalados (todos Car ID = 1)
- [ ] Controller muestra "READY"
- [ ] Botón de piso 1 abre puerta
- [ ] Cabina sube a piso 2
- [ ] Cabina sube a piso 3
- [ ] Cabina baja a piso 1
- [ ] No aparece "Machine Missing"

### Checklist de Production (13 Pisos)

- [ ] Testeo de 3 pisos completado exitosamente
- [ ] Controller actualizado a Floors = 13
- [ ] 13 puertas instaladas (Y=17 hasta Y=**77**)
- [ ] 13 botones instalados (todos Car ID = 1)
- [ ] Área protegida creada
- [ ] Pruebas de piso 1 → 13 exitosas
- [ ] Pruebas de piso 13 → 1 exitosas
- [ ] Sistema estable sin errores

---

## 📚 Información de Referencia

### Ubicación Geográfica
- **Pozo del Ascensor (Centro)**: `(X=88, Z=-43)`
- **Rango Vertical**: `Y=14` (buffer) hasta `Y=78` (sala de máquinas)
- **Edificio**: Oficinas Wetlands

### Comandos de Debugging

```bash
# Ver logs del servidor
ssh gabriel@<IP_VPS_ANTERIOR> "cd /home/gabriel/luanti-voxelibre-server && docker-compose logs -f luanti-server | grep celevator"

# Verificar última acción de machine
ssh gabriel@<IP_VPS_ANTERIOR> "cd /home/gabriel/luanti-voxelibre-server && docker-compose logs luanti-server 2>&1 | grep 'celevator:machine' | tail -5"
```

### Teleportaciones Clave

```bash
# Sala de máquinas (aire libre)
/teleport gabo 88 69 -43

# Controller
/teleport gabo 87 68 -43

# Piso 1
/teleport gabo 88 17 -43

# Piso 3 (testeo)
/teleport gabo 88 27 -43

# Piso 13 (production)
/teleport gabo 88 77 -43
```

---

**Última Validación**: 2025-11-09
**Configuración Validada**: Método "Builder Dave" (componentes al mismo nivel)
**Tiempo de Instalación**: 10-15 minutos (testeo), 30-45 minutos (production)
**Dificultad**: Media (requiere privilegios de admin)