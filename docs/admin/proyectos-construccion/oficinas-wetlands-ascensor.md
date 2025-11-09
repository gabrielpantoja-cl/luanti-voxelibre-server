# 🏢 Proyecto: Edificio "Oficinas Wetlands" - Ascensor de 13 Pisos

**Fecha de Creación**: 2025-11-09
**Última Actualización**: 2025-11-09
**Estado**: En Progreso

Este documento consolida toda la información, diagnósticos y procedimientos para la construcción e instalación de un ascensor funcional de 13 pisos utilizando el mod `celevator`.

---

## 📍 Ubicación Geográfica

- **Pozo del Ascensor (Centro aproximado)**: `(X=88, Z=-43)`
- **Rango Vertical**: `Y=14` (fondo) hasta `Y=77+` (sala de máquinas)
- **Edificio**: Oficinas Wetlands

---

## 📊 Resumen del Estado Actual y Diagnóstico

Tras varios análisis, se identificaron los siguientes puntos clave:

### ✅ Componentes Instalados Correctamente
- **Maquinaria Principal**: `Machine`, `Controller`, y `Drive` están instalados, aunque su posición inicial era incorrecta.
- **Botones de Llamada**: Se han instalado 9 de 13 botones necesarios, sugiriendo una altura de 4 bloques por piso.

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
    - **Number of floors**: `13` (o `14` si finalmente son 14 pisos).
    - **Floor height**: `5` (o `4` si la distancia entre pisos es 4 bloques).
    - **Bottom floor Y**: `15` (la coordenada Y del suelo del primer piso).
    - **Speed**: `5` m/s (o la velocidad que prefieras).
4.  El `controller` ahora debería detectar la `machine` y estar listo para operar.

### **PASO 5: Pruebas Finales**

1.  Ve al primer piso: `/teleport gabo 88 15 -43`.
2.  Presiona el botón de llamada. La puerta debería abrirse y la cabina (si no está ya ahí) debería llegar.
3.  Entra en la cabina y usa los botones internos para viajar a otros pisos.
4.  Verifica que se detenga correctamente en cada nivel.

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

**Configuración Final Recomendada**:
- Machine: `(88, 72, -43)` - NO MOVER después de instalada
- Controller: `(88, 71, -43)`
- Drive: `(89, 71, -43)`

---

## 🛡️ Protección del Área del Ascensor

### **Comandos WorldEdit para Definir Área**

```bash
# PASO 1: Esquina inferior (incluye fondo del pozo)
/teleport gabo 85 14 -46
//pos1

# PASO 2: Esquina superior (incluye sala de máquinas)
/teleport gabo 91 78 -40
//pos2

# PASO 3: Verificar volumen seleccionado
//volume

# PASO 4: Crear protección (si tienes mod 'areas')
/protect oficinas-wetlands-ascensor gabo
```

### **Coordenadas del Área Protegida**
- **Esquina 1**: `(85, 14, -46)`
- **Esquina 2**: `(91, 78, -40)`
- **Volumen Total**: `7x65x7 = 3,185 bloques`
- **Incluye**:
  - Pozo completo (Y=14 a Y=72)
  - Sala de máquinas (Y=72 a Y=78)
  - Margen de seguridad de 3 bloques en X y Z

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
ssh gabriel@<VPS_IP> "cd /home/gabriel/luanti-voxelibre-server && docker-compose logs -f luanti-server"

# Buscar acciones específicas del ascensor
ssh gabriel@<VPS_IP> "cd /home/gabriel/luanti-voxelibre-server && docker-compose logs luanti-server 2>&1 | grep celevator | tail -50"

# Verificar última posición de la machine
ssh gabriel@<VPS_IP> "cd /home/gabriel/luanti-voxelibre-server && docker-compose logs luanti-server 2>&1 | grep 'celevator:machine' | tail -5"
```
