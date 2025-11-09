# 🏢 Proyecto: Edificio "Oficinas Wetlands" - Ascensor de 13 Pisos

**Fecha de Creación**: 2025-11-09
**Última Actualización**: 2025-11-09 (Posiciones verificadas desde logs del servidor)
**Estado**: En Progreso - Machine en posición incorrecta (Y=69, debe estar en Y=72)

Este documento consolida toda la información, diagnósticos y procedimientos para la construcción e instalación de un ascensor funcional de 13 pisos utilizando el mod `celevator`.

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
- **La `Machine` Arriba de Todo**: El motor (`celevator:machine`) debe estar en la parte más alta del pozo, por encima del último piso.
- **El `Controller` es el Cerebro**: Toda la lógica (pisos, altura, velocidad) se configura en el `controller`.

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
     - `/teleport gabo 88 72 -43`
     - Coloca la `celevator:machine` aquí.
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

# PASO 4: Colocar la machine en la posición CORRECTA (Y=72)
/teleport gabo 88 72 -43
# Coloca la machine aquí (CRÍTICO: NO MOVERLA DESPUÉS)

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

**Requisitos Técnicos**:
1. La `machine` debe estar en `carinfo.machinepos` (posición guardada)
2. La `machine` debe estar **al menos 3 bloques por encima** del punto más alto del recorrido
3. La verificación es: `origin.y + target > (carinfo.machinepos.y - 3)`

**Solución**:
1. **NO mover la machine** después de conectar la cabina
2. Si ya la moviste, debes **reconectar todo el sistema**:
   ```bash
   # Excava la cabina actual
   # Excava el controller y drive
   # Coloca la machine en la posición final (Y=72 o superior)
   # Vuelve a colocar controller, drive y cabina
   # Configura el controller nuevamente
   ```

### **Historial de Diagnóstico (2025-11-09)**

**Posiciones Detectadas en Logs**:
- ❌ Machine inicial: `(89, 69, -43)` - Demasiado baja
- ✅ Machine subida: `(89, 73, -43)` - Altura correcta
- ❌ Machine bajada otra vez: `(89, 69, -43)` - Error repetido
- 🔄 Controller movido múltiples veces: `(82-90, 65-70, -43)`

**Problema Identificado**: La `machine` se movió de Y=73 (correcto) de vuelta a Y=69 (incorrecto), lo que causó el error porque el sistema espera la machine 3 bloques por encima del último piso.

**Posiciones ACTUALES en el Servidor** (2025-11-09 - Verificado desde logs):
- ❌ Machine: `(89, 69, -43)` - **INCORRECTA** (demasiado baja, debe estar en Y=72+)
- Controller: `(83, 66, -43)` - Última posición registrada
- Drive: `(82, 66, -42)` - Última posición registrada
- Cabina: `(88, 17, -43)` - Piso 1 (correcta)
- Puertas: 13 instaladas desde Y=17 hasta Y=66 (cada 4 bloques)

**Configuración CORRECTA Recomendada**:
- ✅ Machine: `(88, 72, -43)` - **CRÍTICO**: Debe estar al menos en Y=69 (último piso + 3)
- ✅ Controller: `(88, 71, -43)` o `(89, 71, -43)`
- ✅ Drive: `(89, 71, -43)` o `(88, 70, -43)`

**⚠️ ACCIÓN REQUERIDA**: La machine está actualmente en Y=69 (límite mínimo). Se recomienda subirla a Y=72 para funcionamiento óptimo.

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
- Sala de Máquinas (machine position): `/teleport gabo 88 72 -43`
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
```
