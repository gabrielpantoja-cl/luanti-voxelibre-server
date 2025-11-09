# 🏢 Proyecto: Edificio "Oficinas Wetlands" - Ascensor de 13 Pisos

**Fecha de Creación**: 2025-11-09
**Última Actualización**: 2025-11-09 14:00 UTC (CORRECCIÓN CRÍTICA - Configuración "Builder Dave")
**Estado**: 🚨 **CORRIGIENDO** - Aplicando configuración correcta según video de Luanti Builder Dave

Este documento consolida toda la información, diagnósticos y procedimientos para la construcción e instalación de un ascensor funcional de 13 pisos utilizando el mod `celevator`.

---

## 🚨 CORRECCIÓN CRÍTICA (2025-11-09 14:00 UTC)

**⚠️ DESCUBRIMIENTO IMPORTANTE**: La configuración recomendada anteriormente era **INCORRECTA**.

### ❌ Configuración Anterior (INCORRECTA)
- Machine en Y=72-73 (varios bloques arriba del último piso)
- Controller en Y=71 (2 bloques bajo la machine)
- Drive en Y=71 (mismo nivel que controller)
- **Problema**: Componentes en niveles separados, machine muy arriba

### ✅ Configuración Correcta (según "Luanti Builder Dave")
Basado en video de YouTube de Luanti Builder Dave (hace 2 meses):

**PRINCIPIO FUNDAMENTAL**: Los 3 componentes (machine, controller, drive) van **AL MISMO NIVEL**, justo arriba del techo del último piso, formando una "sala de máquinas" compacta.

**Posiciones Correctas para Oficinas Wetlands**:
```
Y=68: Machine      (89, 68, -43)  ← Centro del pozo
Y=68: Controller   (88, 68, -43)  ← Al lado de la machine
Y=68: Drive        (89, 68, -42)  ← Al lado de la machine
```

**Referencia**:
- Techo del último piso: Y=67
- Sala de máquinas: Y=68 (1 bloque arriba del techo)
- **TODOS los componentes en el MISMO nivel**

**Archivo de corrección**: Ver `COMANDOS_CORRECCION_ASCENSOR.md` en la raíz del proyecto para instrucciones paso a paso.

---

## 📍 Ubicación Geográfica

- **Pozo del Ascensor (Centro)**: `(X=88, Z=-43)`
- **Rango Vertical**: `Y=14` (fondo) hasta `Y=77+` (sala de máquinas)
- **Edificio**: Oficinas Wetlands
- **Altura total por piso**: 5 bloques (3 altura + 1 piso + 1 techo)
- **Pisos instalados**: 13 (puertas desde Y=17 hasta Y=66, separadas cada 4-5 bloques)

---

## 📊 Resumen del Estado Actual y Diagnóstico

Tras varios análisis, se identificaron los siguientes puntos clave:

### ✅ Componentes Instalados Correctamente
- **Maquinaria Principal**: `Machine`, `Controller`, y `Drive` están instalados, aunque su posición inicial era incorrecta.
- **Puertas**: 13 puertas instaladas (Y=17 hasta Y=66).
- **Altura por piso**: 5 bloques totales (3 bloques de espacio habitable + 1 piso + 1 techo).

### ❌ Problemas Críticos Detectados
1.  **Posición de la `Machine` (Motor)**: El problema principal era que la `machine` estaba al mismo nivel o por debajo del `controller` (`Y=69`), cuando **debe estar en el punto más alto del pozo** (`Y=72` o superior).
2.  **Arquitectura Incorrecta**: Se asumió inicialmente que se necesitaban 13 cabinas estáticas. **Esto es incorrecto**. El mod `celevator` utiliza **una sola cabina móvil**.
3.  **Componentes Mal Ubicados**: Se encontraron cabinas y `drives` duplicados en la sala de máquinas, los cuales deben ser eliminados.
4.  **Componentes Faltantes**: Faltan `buffer` (amortiguador) en el fondo, `guide_rails` (rieles) en las paredes, la cabina única en el piso inicial, y varias puertas y botones.

---

## 🏗️ Arquitectura Correcta del Ascensor (Mod `celevator`)

Es **CRÍTICO** entender cómo funciona el mod `celevator`:

- **Una Única Cabina Móvil**: No se colocan 13 cabinas. Se instala **UNA SOLA** cabina (`celevator:car_glassback`) en el piso inferior. El `controller` la mueve programáticamente.
- **Sala de Máquinas Compacta**: Los 3 componentes (machine, controller, drive) van **AL MISMO NIVEL**, justo arriba del techo del último piso, formando una "sala de máquinas" compacta (como en edificios reales).
- **El `Controller` es el Cerebro**: Toda la lógica (pisos, altura, velocidad) se configura en el `controller`.

**🎯 Configuración Correcta Validada**:
```
Y=68: [Machine] [Controller] [Drive]  ← Sala de máquinas (mismo nivel)
Y=67: [Techo del piso 13]
Y=66: [Puerta Piso 13]
```

**Fuente**: Basado en video de "Luanti Builder Dave" y arquitectura de ascensores reales.

---

## 📋 Plan de Acción: Instalación Definitiva

Sigue estos pasos en orden para una instalación limpia y funcional.

### **PASO 1: Limpieza Completa del Pozo**

Antes de instalar nada nuevo, debemos asegurarnos de que el área esté completamente libre de componentes antiguos y mal puestos.

**1. Definir el Área de Limpieza con WorldEdit:**
   - Ve a la esquina inferior: `/teleport gabo 85 14 -45`
   - Marca la primera posición: `//pos1` (o `/1`)
   - Ve a la esquina superior opuesta: `/teleport gabo 91 77 -41`
   - Marca la segunda posición: `//pos2` (o `/2`)
   - (Opcional) Verifica el volumen: `//volume` (o `/v`)

**2. Ejecutar Comandos de Eliminación (Copiar y pegar el bloque completo):**

   - **Eliminar TODAS las cabinas:**
     ```
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
     ```

   - **Eliminar TODAS las puertas:**
     ```
     //replace celevator:hwdoor_glass air
     //replace celevator:hwdoor_fast_glass_top air
     //replace celevator:hwdoor_fast_glass_bottom air
     //replace celevator:hwdoor_slow_glass_top air
     //replace celevator:hwdoor_slow_glass_bottom air
     ```

**3. Verificación Visual:**
   - Vuela por todo el pozo (`Y=14` a `Y=77`) y asegúrate de que no quede **ninguna cabina ni puerta**.
   - Los componentes como `controller`, `drive` y botones pueden permanecer si están fuera del área de limpieza, pero es mejor eliminarlos también para una instalación 100% limpia.

### **PASO 2: Obtención de Materiales**

Estos son todos los items necesarios para un ascensor de 13 pisos. Pídele a un admin que te los dé con estos comandos:

```
# Componentes Principales (1 ascensor)
/give gabo celevator:machine 1
/give gabo celevator:controller 1
/give gabo celevator:drive 1
/give gabo celevator:governor 1
/give gabo celevator:car_glassback 1

# Componentes Estructurales
/give gabo celevator:buffer_oil 2
/give gabo celevator:guide_rail 99

# Puertas y Botones (para 13 pisos)
/give gabo celevator:hwdoor_glass 13
/give gabo celevator:callbutton_up 1
/give gabo celevator:callbutton_down 1
/give gabo celevator:callbutton_both 11
```

### **PASO 3: Instalación de Componentes (En Orden)**

**1. Fondo del Pozo (Y=14):**
   - `/teleport gabo 88 14 -43`
   - Coloca 1 o 2 `celevator:buffer_oil` en el suelo.

**2. Rieles Guía (Guide Rails):**
   - Instala `celevator:guide_rail` en las paredes interiores del pozo, desde `Y=14` hasta el nivel de la sala de máquinas (`~Y=77`).
   - **Método con WorldEdit (recomendado):**
     ```
     # Pared Oeste
     /teleport gabo 87 14 -43
     /1
     /teleport gabo 87 77 -43
     /2
     //set celevator:guide_rail

     # Pared Este
     /teleport gabo 89 14 -43
     /1
     /teleport gabo 89 77 -43
     /2
     //set celevator:guide_rail
     ```

**3. Sala de Máquinas (Nivel Superior, Y > 70):**
   - **CRÍTICO**: La `machine` debe estar en el punto más alto y centrada en el pozo.
   - **Instalar Machine (Motor)**:
     - `/teleport gabo 88 74 -43` (aire libre, piso sólido en Y=72)
     - Coloca la `celevator:machine` en Y=73 (un bloque abajo de donde apareces).
   - **Instalar Controller**:
     - `/teleport gabo 88 71 -43` (o al lado de la machine)
     - Coloca el `celevator:controller`.
   - **Instalar Drive**:
     - `/teleport gabo 89 71 -43` (o al lado del controller)
     - Coloca el `celevator:drive`.

**4. Instalar la Cabina ÚNICA:**
   - Ve al piso más bajo.
   - `/teleport gabo 88 15 -43`
   - Coloca **UNA SOLA** `celevator:car_glassback`.

**5. Instalar Puertas y Botones:**
   - Ve a cada uno de los 13 pisos.
   - En cada piso, coloca una `celevator:hwdoor_glass` frente al pozo.
   - Al lado de cada puerta, coloca el botón de llamada correspondiente (`callbutton_up` en el primer piso, `callbutton_down` en el último, y `callbutton_both` en los intermedios).

### **PASO 4: Configuración del Controlador**

1.  Ve a la sala de máquinas: `/teleport gabo 88 71 -43`
2.  Haz clic derecho en el `celevator:controller`.
3.  En la interfaz, configura los siguientes parámetros:
    - **Number of floors**: `13`
    - **Floor height**: `5` (altura total: 3 bloques habitables + 1 piso + 1 techo)
    - **Bottom floor Y**: `17` (la coordenada Y del piso 1, donde está la primera puerta)
    - **Speed**: `5` m/s (o la velocidad que prefieras).
4.  El `controller` ahora debería detectar la `machine` y estar listo para operar.

**⚠️ IMPORTANTE - Configuración basada en arquitectura real**:
- Se confirmó que hay **13 pisos** instalados
- La altura por piso es **5 bloques totales** (3 altura + 1 piso + 1 techo)
- El primer piso está en **Y=17** (coordenada de la primera puerta)
- Estas coordenadas fueron verificadas desde los logs del servidor

### **PASO 5: Pruebas Finales**

1.  Ve al primer piso: `/teleport gabo 88 15 -43`.
2.  Presiona el botón de llamada. La puerta debería abrirse y la cabina (si no está ya ahí) debería llegar.
3.  Entra en la cabina y usa los botones internos para viajar a otros pisos.
4.  Verifica que se detenga correctamente en cada nivel.

---

## 🚨 SOLUCIÓN RÁPIDA AL PROBLEMA ACTUAL

**Problema detectado**: El ascensor no funciona porque la `machine` está en Y=69, que es el límite mínimo absoluto. El mod requiere al menos 3 bloques de margen.

### **Pasos para Solucionar (Orden Crítico)**

```bash
# PASO 1: Ir a la sala de máquinas
/teleport gabo 89 69 -43

# PASO 2: Excavar la machine actual (posición incorrecta)
# Haz clic izquierdo en la machine para excavarla

# PASO 3: Excavar el controller y drive actuales
/teleport gabo 83 66 -43
# Excava el controller

/teleport gabo 82 66 -42
# Excava el drive

# PASO 4: Colocar la machine en la posición CORRECTA (Y=73)
/teleport gabo 88 74 -43
# Coloca la machine en Y=73 (un bloque abajo, CRÍTICO: NO MOVERLA DESPUÉS)

# PASO 5: Colocar el controller justo debajo
/teleport gabo 88 71 -43
# Coloca el controller

# PASO 6: Colocar el drive al lado del controller
/teleport gabo 89 71 -43
# Coloca el drive

# PASO 7: Verificar que la cabina esté en el piso 1
/teleport gabo 88 17 -43
# Debería haber UNA cabina aquí. Si no, colócala.

# PASO 8: Configurar el controller
/teleport gabo 88 71 -43
# Clic derecho en el controller y configura:
# - Number of floors: 13
# - Floor height: 5
# - Bottom floor Y: 17
# - Speed: 5

# PASO 9: Probar el ascensor
/teleport gabo 88 17 -43
# Usa el botón de llamada y prueba subir a diferentes pisos
```

**Verificación Post-Instalación**:
```bash
# Ver logs en tiempo real para verificar que no hay errores
ssh gabriel@167.172.251.27 "cd /home/gabriel/luanti-voxelibre-server && docker-compose logs -f luanti-server | grep celevator"
```

**Si aún no funciona**:
1. Verifica que la machine esté exactamente en `(88, 72, -43)`
2. Verifica que el controller esté conectado (no debe haber mensajes de "machine missing")
3. Asegúrate de que NO moviste la machine después de configurar el controller

---

## 🔬 Diagnóstico Técnico y Solución de Problemas

### **Error: "Hoist Machine Missing"**

**Causa Raíz**: El mod `celevator` guarda la posición de la `machine` cuando conectas la cabina. Si mueves la `machine` después, el sistema sigue buscándola en la posición antigua.

**Código de Verificación** (de `drive_entity.lua:659`):
```lua
if not (carinfo and carinfo.machinepos and
        celevator.get_node(carinfo.machinepos).name == "celevator:machine") then
    meta:set_string("fault","nomachine")
    return
end
```

**Requisitos Técnicos del Mod**:
1. La `machine` debe estar en `carinfo.machinepos` (posición guardada en metadata)
2. La `machine` debe estar **al menos 3 bloques por encima** del punto más alto del recorrido
3. La verificación es: `origin.y + target > (carinfo.machinepos.y - 3)`
4. El `controller` debe poder "ver" el `drive` (mismo ID de cabina)
5. El `drive` debe poder "ver" la `machine` (máximo 500 bloques de distancia)

**Solución General**:
1. **NUNCA mover la machine** después de conectar la cabina
2. Si ya la moviste, debes **reconectar todo el sistema** siguiendo el protocolo de reinstalación completo

---

### **🔍 DIAGNÓSTICO COMPLETO (2025-11-09 12:30 UTC)**

#### **Análisis de Logs del Servidor**

Ejecuta este comando para ver el historial completo de cambios:
```bash
ssh gabriel@167.172.251.27 "cd /home/gabriel/luanti-voxelibre-server && docker-compose logs luanti-server 2>&1 | grep -E '(celevator|machine|drive|controller)' | tail -30"
```

#### **Historial Cronológico de Cambios (Verificado desde Logs)**

```
2025-11-09 04:34:16: gabo digs controller at (84,74,-43)
2025-11-09 04:34:17: gabo digs drive at (84,75,-42)
2025-11-09 04:36:01: gabo digs machine at (89,74,-43)
2025-11-09 04:37:52: gabo places machine at (88,73,-43)    ← ✅ Altura CORRECTA (Y=73)
2025-11-09 04:38:32: gabo digs machine at (88,73,-43)
2025-11-09 04:38:34: gabo places machine at (89,73,-43)    ← ✅ Altura CORRECTA (Y=73)
2025-11-09 04:39:12: gabo places controller at (84,73,-43)
2025-11-09 04:39:30: gabo places drive at (84,74,-42)
2025-11-09 04:43:28: gabo digs controller at (84,73,-43)
2025-11-09 04:43:28: gabo digs drive at (85,74,-43)
2025-11-09 04:57:11: gabo digs machine at (89,73,-43)
2025-11-09 04:58:22: gabo places machine at (89,69,-43)    ← ❌ ERROR: Bajó a Y=69 (límite mínimo)
2025-11-09 04:59:41: gabo places controller at (84,69,-43)
2025-11-09 04:59:45: gabo places drive at (84,70,-42)
2025-11-09 05:00:38: gabo places drive at (85,70,-43)
2025-11-09 05:00:40: gabo digs drive at (85,70,-43)
```

#### **📊 Posiciones ACTUALES Confirmadas (2025-11-09)**

**Componentes Instalados:**
- ❌ **Machine**: `(89, 69, -43)` - **CRÍTICO: Demasiado baja**
  - Altura actual: Y=69
  - Altura mínima requerida: Y=69 (último piso Y=66 + 3)
  - Altura recomendada: **Y=72 o superior** (margen seguro de 6 bloques)
  - Estado: **EN LÍMITE MÍNIMO ABSOLUTO** ⚠️

- ❌ **Controller**: `(84, 69, -43)` - Inconsistente con machine
  - Debería estar cerca de la machine
  - Posición actual muy alejada en X (diferencia de 5 bloques)

- ❌ **Drive**: `(84, 70, -42)` - Múltiples problemas
  - Está POR ENCIMA del controller (Y=70 > Y=69) ← Arquitectura incorrecta
  - Muy alejado de la machine en X y Z
  - Última acción: Eliminado drive duplicado en (85, 70, -43)

- ✅ **Puertas**: 13 puertas instaladas correctamente
  - Rango: Y=17 (piso 1) hasta Y=66 (piso 13)
  - Separación: 4-5 bloques por piso

#### **🚨 Problemas Identificados**

1. **Machine en altura mínima (Y=69):**
   - Solo 3 bloques sobre el último piso (Y=66)
   - Cualquier vibración o error de cálculo puede causar "machine missing"
   - Recomendación: Subir a **Y=72 mínimo** (margen de 6 bloques)

2. **Componentes desalineados:**
   - Machine en X=89, Controller/Drive en X=84 (5 bloques de separación)
   - El mod prefiere componentes cercanos verticalmente
   - Puede causar problemas de detección de señales

3. **Drive por encima del controller:**
   - Arquitectura no estándar (drive normalmente va al lado o debajo)
   - Puede confundir el sistema de verificación

4. **Machine movida después de configuración inicial:**
   - Machine estuvo en Y=73 (correcto) a las 04:38:34
   - Machine bajó a Y=69 (incorrecto) a las 04:58:22
   - El sistema guardó la posición antigua (Y=73) pero la machine está en Y=69
   - **Esto es la causa raíz del error "Hoist Machine Missing"**

#### **✅ Configuración CORRECTA Recomendada**

**Posiciones ideales (todas en la misma columna vertical X=88, Z=-43):**
```
Y=73: Machine (motor) ← 7 bloques sobre último piso
Y=71: Controller      ← 2 bloques bajo la machine
Y=72: Drive          ← Entre machine y controller, o al lado
```

**Alternativa con separación lateral:**
```
Y=73: Machine at (88, 73, -43)
Y=71: Controller at (88, 71, -43) o (89, 71, -43)
Y=71: Drive at (89, 71, -43) o (88, 71, -42)
```

**Ventajas de esta configuración:**
- Machine a 7 bloques sobre último piso (margen doble del mínimo)
- Componentes alineados verticalmente
- Drive al mismo nivel del controller (arquitectura estándar)
- Fácil mantenimiento y diagnóstico

---

### **🛠️ COMANDOS DE SOLUCIÓN PASO A PASO**

**IMPORTANTE**: Ejecuta estos comandos **UNO POR UNO** en el chat del juego. No copies todo de una vez.

#### **FASE 1: Verificación de Estado Actual**

```bash
# Ver si tienes privilegios de admin
/privs

# Verificar que tienes fly y noclip (necesarios para trabajar en altura)
/grant gabo fly
/grant gabo noclip

# Activar fly mode
/fly 1

# Ir a la posición actual de la machine
/teleport gabo 89 69 -43
```

**🔍 Verifica visualmente:**
- ¿Hay una machine en (89, 69, -43)?
- ¿Puedes ver el controller y drive desde aquí?
- Anota cualquier diferencia con lo documentado

#### **FASE 2: Excavación de Componentes Incorrectos**

```bash
# PASO 1: Ir a la machine actual (posición incorrecta)
/teleport gabo 89 69 -43
# Haz clic izquierdo (excavar) en la machine
# Confirma que la excavaste (deberías tener el item en tu inventario)

# PASO 2: Ir al controller actual
/teleport gabo 84 69 -43
# Haz clic izquierdo (excavar) en el controller
# Confirma que lo excavaste

# PASO 3: Ir al drive actual
/teleport gabo 84 70 -42
# Haz clic izquierdo (excavar) en el drive
# Confirma que lo excavaste

# PASO 4: Verificar que todo está limpio
/teleport gabo 88 71 -43
# Mira alrededor - no debería haber machine, controller ni drive visibles
```

#### **FASE 3: Preparación del Área (Opcional pero Recomendado)**

```bash
# Crear un piso sólido para la sala de máquinas si no existe
/teleport gabo 88 72 -43
# Verifica que hay un bloque sólido en Y=72 (usa //inspect si es necesario)
# Si no hay piso, coloca bloques de madera o piedra en Y=72

# Crear espacio libre arriba para trabajar
/teleport gabo 88 74 -43
# Deberías aparecer en aire libre - este es tu espacio de trabajo
```

#### **FASE 4: Instalación en Posiciones CORRECTAS**

```bash
# PASO 1: Instalar la MACHINE en posición CORRECTA (Y=73)
/teleport gabo 88 74 -43
# Apunta HACIA ABAJO (mira al suelo)
# Haz clic derecho (colocar) con la machine seleccionada
# La machine se colocará en Y=73 (un bloque abajo de ti)
# ⚠️ CRÍTICO: Verifica que está en Y=73, NO en Y=72

# PASO 2: Instalar el CONTROLLER (Y=71)
/teleport gabo 88 71 -43
# Coloca el controller en el bloque de aire donde apareces
# Confirma que está en Y=71

# PASO 3: Instalar el DRIVE (Y=71, al lado del controller)
/teleport gabo 89 71 -43
# Coloca el drive aquí (misma altura que el controller)
# Confirma que está en Y=71

# PASO 4: Verificar posiciones finales
/teleport gabo 88 74 -43
# Desde aquí puedes ver los 3 componentes:
# - Machine abajo en Y=73 (centro del pozo)
# - Controller en Y=71 (2 bloques más abajo)
# - Drive en Y=71 (al lado del controller)
```

#### **FASE 5: Verificación de la Cabina**

```bash
# Ir al piso 1 donde debe estar la cabina
/teleport gabo 88 17 -43

# Verificar que hay UNA cabina (car_glassback)
# Si NO hay cabina, coloca una nueva:
/give gabo celevator:car_glassback 1
# Coloca la cabina en (88, 17, -43)

# Si hay MÚLTIPLES cabinas (error común), elimina las extras
# Deja solo UNA cabina en el piso 1
```

#### **FASE 6: Configuración del Controller**

```bash
# Ir al controller
/teleport gabo 88 71 -43

# Haz clic DERECHO en el controller para abrir su interfaz
# Configura estos parámetros EXACTOS:
# - Car ID: 1 (o el ID que prefieras, debe ser único)
# - Number of floors: 13
# - Floor height: 5 (altura total por piso)
# - Bottom floor Y: 17 (coordenada Y del piso 1)
# - Speed: 5 (m/s, recomendado)

# IMPORTANTE: Después de guardar la configuración
# El controller debería mostrar "READY" o "IDLE"
# Si muestra "FAULT: Machine Missing", espera 10 segundos y verifica de nuevo
# El sistema tarda unos segundos en detectar componentes
```

#### **FASE 7: Pruebas del Sistema**

```bash
# PRUEBA 1: Ir al piso 1
/teleport gabo 88 17 -43

# Busca el botón de llamada (callbutton_up)
# Si no hay botón, coloca uno:
/give gabo celevator:callbutton_up 1
# Coloca el botón al lado de la puerta

# Presiona el botón de llamada
# La puerta debería abrirse
# La cabina debería aparecer (si no está ya ahí)

# PRUEBA 2: Entrar a la cabina
# Haz clic derecho dentro de la cabina
# Deberías ver el panel de control con botones 1-13

# PRUEBA 3: Viajar a otro piso
# Presiona el botón "7" (piso intermedio)
# La cabina debería moverse suavemente hacia arriba
# Debería detenerse en Y=41-42 (piso 7)
# La puerta del piso 7 debería abrirse

# PRUEBA 4: Viajar al último piso
# Dentro de la cabina, presiona el botón "13"
# La cabina debería subir hasta Y=65-66
# Verifica que no hay errores de "machine missing"

# PRUEBA 5: Regresar al piso 1
# Presiona el botón "1"
# La cabina debería bajar correctamente
```

#### **FASE 8: Verificación desde VPS (Opcional)**

Si quieres ver los logs en tiempo real durante las pruebas:

```bash
# Ejecutar en tu terminal local (fuera del juego)
ssh gabriel@167.172.251.27 "cd /home/gabriel/luanti-voxelibre-server && docker-compose logs -f luanti-server | grep celevator"

# Verás mensajes como:
# - "Controller scanning for drive..."
# - "Drive found at (89, 71, -43)"
# - "Machine found at (88, 73, -43)"
# - "Elevator moving to floor 7"

# Para salir de los logs: Ctrl+C
```

---

### **🐛 Troubleshooting Post-Instalación**

#### **Error: "Machine Missing" persiste después de la instalación**

**Verificar posición exacta de la machine:**
```bash
# Ir a donde DEBERÍA estar la machine
/teleport gabo 88 74 -43
# Mira hacia abajo - ¿ves la machine en Y=73?

# Verificar con inspect (si tienes WorldEdit)
//inspect
# Haz clic en el bloque donde debería estar la machine
# Debería decir "celevator:machine"
```

**Verificar que la machine NO está en posición antigua:**
```bash
# Ir a la posición antigua (Y=69)
/teleport gabo 89 69 -43
# ¿Hay una machine aquí? Si SÍ, excavarla
```

**Resetear el controller:**
```bash
# Excavar el controller
/teleport gabo 88 71 -43
# Excavar controller

# Esperar 5 segundos

# Volver a colocar el controller
# Colocar controller nuevamente

# Reconfigurar desde cero
# Clic derecho → Configurar parámetros de nuevo
```

#### **Error: Cabina no se mueve**

**Verificar conexión drive-machine:**
```bash
# El drive debe poder "ver" la machine
# Distancia máxima: 500 bloques (en este caso, solo 2 bloques)
# Verificar que ambos existen:
/teleport gabo 88 73 -43  # Machine
/teleport gabo 89 71 -43  # Drive
```

**Verificar que hay UNA SOLA cabina:**
```bash
# Buscar cabinas duplicadas en el pozo
/teleport gabo 88 25 -43  # Piso intermedio
# Mira alrededor - no debería haber cabinas flotando

# Si hay cabinas extra, eliminarlas con WorldEdit:
//pos1
//pos2
//replace celevator:car_glassback air
```

#### **Error: Cabina se queda atascada entre pisos**

**Causa común**: Obstáculos en el pozo (bloques, items, entities)

```bash
# Limpiar el pozo completamente
//pos1  (en esquina inferior)
//pos2  (en esquina superior)
//replace celevator:car_glassback air  (eliminar cabinas)
//replace celevator:hwdoor_glass air   (eliminar puertas si es necesario)

# Verificar que el pozo está despejado
/teleport gabo 88 35 -43
# Vuela por el centro del pozo de Y=15 a Y=70
# No debería haber NADA en el camino excepto las puertas
```

#### **Éxito confirmado: ¿Cómo sé que funciona?**

**Indicadores de sistema funcionando:**
1. ✅ Controller muestra "READY" o "IDLE" (no "FAULT")
2. ✅ Botones de llamada abren las puertas
3. ✅ Cabina responde a comandos del panel interno
4. ✅ Cabina se mueve suavemente entre pisos (sin caídas bruscas)
5. ✅ Puertas se abren/cierran automáticamente
6. ✅ No hay mensajes de error en chat

**Si TODOS los indicadores están ✅, tu ascensor está FUNCIONANDO CORRECTAMENTE.**

---

### **⚠️ ACCIÓN REQUERIDA URGENTE**

**Estado Actual**: La machine está en Y=69 (límite mínimo absoluto)
**Riesgo**: Alta probabilidad de falla por margen insuficiente
**Solución**: Seguir FASE 2-6 de los comandos arriba para reubicar a Y=73
**Tiempo estimado**: 10-15 minutos
**Dificultad**: Media (requiere privilegios de admin y volar)

### **Detalle de Puertas Instaladas** (Verificado desde logs 2025-11-09)

Las siguientes puertas están instaladas en el pozo principal (X=86-87, Z=-43):

| Piso | Coordenadas Y | Posición Exacta | Estado |
|------|---------------|-----------------|--------|
| Piso 1 | Y=17 | (87,17,-43), (86,17,-43) | ✅ Instaladas |
| Piso 2 | Y=21 | (87,21,-43), (86,21,-43) | ✅ Instaladas |
| Piso 3 | Y=25 | (87,25,-43), (86,25,-43) | ✅ Instaladas |
| Piso 4 | Y=29 | (87,29,-43), (86,29,-43) | ✅ Instaladas |
| Piso 5 | Y=33-34 | (87,33,-43), (86,34,-43) | ✅ Instaladas |
| Piso 6 | Y=37-38 | (87,37,-43), (86,38,-43) | ✅ Instaladas |
| Piso 7 | Y=41-42 | (87,41,-43), (86,42,-43) | ✅ Instaladas |
| Piso 8 | Y=45-46 | (87,45,-43), (86,46,-43) | ✅ Instaladas |
| Piso 9 | Y=49-50 | (87,49,-43), (86,49,-43) | ✅ Instaladas |
| Piso 10 | Y=53-54 | (87,53,-43), (86,54,-43) | ✅ Instaladas |
| Piso 11 | Y=57-58 | (87,57,-43), (86,58,-43) | ✅ Instaladas |
| Piso 12 | Y=61-62 | (87,61,-43), (86,62,-43) | ✅ Instaladas |
| Piso 13 | Y=65-66 | (87,65,-43), (86,66,-43) | ✅ Instaladas |

**Notas**:
- Altura total por piso: **5 bloques** (3 habitables + 1 piso + 1 techo)
- Separación entre puertas: 4-5 bloques (dependiendo de la construcción)
- Último piso (Piso 13): Y=66
- Machine actual: Y=69 (solo 3 bloques arriba, **en el límite mínimo**)
- Machine recomendada: Y=72 (6 bloques arriba, **margen seguro**)

---

## 🛡️ Protección del Área del Ascensor

### **Sistema de Protección VoxeLibre**

El servidor Wetlands utiliza el mod `voxelibre_protection` para proteger áreas. Este sistema es diferente a WorldEdit o el mod `areas` tradicional.

**⚠️ IMPORTANTE - Diferencia entre comandos**:
- **WorldEdit**: `//pos1` y `//pos2` (con doble barra) - Solo para edición de bloques
- **Protección**: `/pos1` y `/pos2` (con una barra) - Para marcar áreas a proteger
- **No son lo mismo**: WorldEdit y el sistema de protección son independientes

### **Método 1: Protección Manual (Recomendado para el Ascensor)**

```bash
# PASO 1: Ir a la esquina inferior (incluye fondo del pozo)
/teleport gabo 85 14 -46
/pos1

# PASO 2: Ir a la esquina superior (incluye sala de máquinas)
/teleport gabo 91 78 -40
/pos2

# PASO 3: Crear el área protegida
/protect_area oficinas-wetlands-ascensor

# PASO 4: Verificar que se creó correctamente
/list_areas
```

### **Método 2: Protección Rápida desde el Centro**

Si prefieres un método más rápido:

```bash
# Ir al centro del ascensor (aproximadamente Y=45, centro vertical)
/teleport gabo 88 45 -43

# Proteger 25 bloques de radio alrededor
/protect_here 25 oficinas-wetlands-ascensor

# Verificar
/list_areas
```

### **Gestión de Miembros (Opcional)**

Si quieres permitir que otros jugadores usen el ascensor:

```bash
# Añadir un jugador al área protegida
/area_add_member oficinas-wetlands-ascensor <nombre_jugador>

# Quitar un jugador del área
/area_remove_member oficinas-wetlands-ascensor <nombre_jugador>

# Ver información del área
/area_info oficinas-wetlands-ascensor
```

### **Coordenadas del Área Protegida**
- **Esquina 1**: `(85, 14, -46)`
- **Esquina 2**: `(91, 78, -40)`
- **Volumen Total**: `7×65×7 = 3,185 bloques`
- **Incluye**:
  - Pozo completo (Y=14 a Y=72)
  - Sala de máquinas (Y=72 a Y=78)
  - Margen de seguridad de 3 bloques en X y Z

### **Troubleshooting de Protección**

**Problema**: "You don't have permission to protect here"
- **Solución**: Necesitas el privilegio `protect`. Usa `/privs gabo` para verificar.
- **Otorgar privilegio**: Un admin debe ejecutar `/grant gabo protect`

**Problema**: "Area already exists with that name"
- **Solución**: Ya existe un área con ese nombre. Usa `/list_areas` para verla o elige otro nombre.

**Problema**: "Area overlaps with existing protection"
- **Solución**: El área se superpone con otra protección existente. Usa `/area_info <nombre>` para ver qué área está ahí.

**Verificar privilegios actuales**:
```bash
# Ver tus privilegios
/privs

# Ver privilegios de otro jugador (requiere privs 'privs')
/privs <jugador>
```

**Eliminar protección** (si necesitas recrearla):
```bash
# Solo el propietario puede eliminar
/unprotect_area oficinas-wetlands-ascensor
```

---

## 📚 Apéndice: Comandos de Referencia Rápida

### Limpieza Urgente
- `//unmark` o `/umk`: Oculta las líneas de selección de WorldEdit.
- `//inspect`: Permite hacer clic en un bloque para saber su nombre exacto.
- `//pos1` o `/1`: Marca primera esquina de selección.
- `//pos2` o `/2`: Marca segunda esquina de selección.
- `//volume` o `/v`: Muestra el volumen seleccionado.

### Items de Ascensor
- `/give gabo celevator:car_glassback 1`
- `/give gabo celevator:machine 1`
- `/give gabo celevator:controller 1`
- `/give gabo celevator:hwdoor_glass 13`
- `/give gabo celevator:guide_rail 99`
- `/give gabo celevator:buffer_oil 2`

### Teleportaciones Clave
- Pozo (centro, piso 1): `/teleport gabo 88 15 -43`
- Sala de Máquinas (aire libre): `/teleport gabo 88 74 -43`
- Sala de Máquinas (controller): `/teleport gabo 88 71 -43`
- Esquina de limpieza 1: `/teleport gabo 85 14 -45`
- Esquina de limpieza 2: `/teleport gabo 91 77 -41`
- Esquina protección 1: `/teleport gabo 85 14 -46`
- Esquina protección 2: `/teleport gabo 91 78 -40`

### Depuración del Sistema
```bash
# Ver logs del servidor en tiempo real
ssh gabriel@167.172.251.27 "cd /home/gabriel/luanti-voxelibre-server && docker-compose logs -f luanti-server"

# Buscar acciones específicas del ascensor
ssh gabriel@167.172.251.27 "cd /home/gabriel/luanti-voxelibre-server && docker-compose logs luanti-server 2>&1 | grep celevator | tail -50"

# Verificar última posición de la machine
ssh gabriel@167.172.251.27 "cd /home/gabriel/luanti-voxelibre-server && docker-compose logs luanti-server 2>&1 | grep 'celevator:machine' | tail -5"

# Verificar posición de jugador en base de datos
ssh gabriel@167.172.251.27 "cd /home/gabriel/luanti-voxelibre-server && docker-compose exec -T luanti-server sqlite3 /config/.minetest/worlds/world/players.sqlite \"SELECT name, posX, posY, posZ FROM player WHERE name='gabo';\""
```

---

## 🐛 Problema Diagnosticado: Caída al Teleportarse

### Descripción del Problema
Cuando se usa `/teleport gabo 88 72 -43`, el personaje cae aproximadamente 3-4 bloques después de aparecer.

### Causa Raíz (Diagnosticado 2025-11-09)

**Estructura vertical en X=88, Z=-43:**
- Y=73: `celevator:machine` (bloque sólido)
- Y=72: `mcl_core:junglewood` (bloque sólido de madera)
- Y=71: aire
- Y=70: aire
- Y=69: `celevator:controller` (bloque sólido)
- Y=68: `mcl_core:junglewood` (donde termina gabo después de caer)

**El problema:**
1. El comando teleporta a **Y=72** donde hay un **bloque sólido** de madera
2. El personaje aparece **DENTRO** del bloque
3. Sin `fly` o `noclip`, Luanti expulsa al personaje del bloque sólido
4. El personaje cae hasta Y=68 (aproximadamente 4 bloques)

### Solución
**Usar comandos corregidos:**
```bash
# Para ir a la sala de máquinas (RECOMENDADO)
/teleport gabo 88 74 -43

# Alternativa: un nivel más arriba
/teleport gabo 88 75 -43

# Para trabajar en el nivel del controller
/teleport gabo 88 71 -43
```

**Por qué funciona:**
- Y=74 y Y=75 son **aire libre**
- El piso sólido está en Y=72 (2-3 bloques abajo)
- El personaje aparece de pie sin obstrucciones
- No hay caída porque hay espacio libre con soporte sólido debajo
