# 🔴 CORRECCIÓN IMPORTANTE - ASCENSOR DE 13 PISOS

**Fecha**: 2025-11-08
**PROBLEMA DETECTADO**: El mod **celevator NO usa "shaft" (ejes)**

---

## ❌ ITEMS QUE **NO EXISTEN** EN CELEVATOR

Los siguientes items que mencionamos **NO EXISTEN** en el mod celevator:

- ❌ `celevator:shaft` - **NO EXISTE**
- ❌ `celevator:guide_rail` - **SÍ existe, pero se llama diferente**

---

## ✅ ITEMS QUE **SÍ EXISTEN** EN CELEVATOR

Basado en el archivo `crafts.lua`, estos son los items reales que puedes usar:

### Componentes de Control
- ✅ `celevator:controller` - Controlador principal
- ✅ `celevator:drive` - Unidad de control
- ✅ `celevator:machine` - Motor
- ✅ `celevator:governor` - Gobernador de velocidad
- ✅ `celevator:dispatcher` - Dispatcher (opcional, para grupos)

### Cabinas (Cars)
- ✅ `celevator:car_standard` - Cabina estándar (metálica)
- ✅ `celevator:car_glassback` - Cabina con vidrio trasero ⭐ **LA QUE ESTÁS USANDO**
- ✅ `celevator:car_metal` - Cabina metálica reforzada
- ✅ `celevator:car_metal_glassback` - Cabina metálica con vidrio

### Puertas
- ✅ `celevator:hwdoor_glass` - Puerta de vidrio
- ✅ `celevator:hwdoor_steel` - Puerta metálica

### Botones de Llamada
- ✅ `celevator:callbutton_both` - Botón arriba/abajo
- ✅ `celevator:callbutton_up` - Solo botón arriba
- ✅ `celevator:callbutton_down` - Solo botón abajo

### Componentes Estructurales
- ✅ `celevator:buffer_oil` - Amortiguador de aceite
- ✅ `celevator:buffer_rubber` - Amortiguador de goma
- ✅ `celevator:guide_rail` - Rieles guía (10 unidades por crafting)
- ✅ `celevator:guide_rail_bracket` - Soporte para rieles

### Decorativos (Opcionales)
- ✅ `celevator:lantern_up` - Indicador de dirección arriba
- ✅ `celevator:lantern_down` - Indicador de dirección abajo
- ✅ `celevator:lantern_both` - Indicador bidireccional
- ✅ `celevator:tape` - Cinta magnética (para sistemas antiguos)
- ✅ `celevator:pi` - Indicador de posición

---

## 🚨 CÓMO FUNCIONA REALMENTE CELEVATOR

**IMPORTANTE**: celevator **NO requiere shaft físico**. El sistema funciona de manera diferente:

### Arquitectura Real de celevator:

1. **Una sola cabina física en la parte SUPERIOR** (máquina de tracción)
2. **El ascensor se MUEVE ENTRE PISOS** de forma programática
3. **NO necesitas 13 cabinas**, solo necesitas:
   - 1 cabina (car_glassback)
   - 1 machine (motor)
   - 1 controller
   - 1 drive
   - 13 puertas (una por piso)
   - 13 botones de llamada

### Sistema de Movimiento:

La cabina **NO es un bloque estático**, es una **entidad animada** que se mueve verticalmente entre pisos. El mod maneja la física y el movimiento automáticamente.

---

## 📋 LISTA CORRECTA DE ITEMS NECESARIOS

Para un ascensor de 13 pisos, gabo necesita:

```
/give gabo celevator:car_glassback 1
/give gabo celevator:machine 1
/give gabo celevator:controller 1
/give gabo celevator:drive 1
/give gabo celevator:governor 1
/give gabo celevator:buffer_oil 2
/give gabo celevator:hwdoor_glass 13
/give gabo celevator:callbutton_both 11
/give gabo celevator:callbutton_up 1
/give gabo celevator:callbutton_down 1
/give gabo celevator:guide_rail 99
```

**TOTAL**: Solo 1 cabina, no 13.

---

## 🛠️ INSTALACIÓN CORRECTA (SIMPLIFICADA)

### Paso 1: Fondo del Pozo (Y=14)
```
/teleport gabo 88 14 -43
```
- Colocar 1 `celevator:buffer_oil`

### Paso 2: Instalar Guide Rails (Rieles Guía)
Los guide rails se colocan en las PAREDES del pozo, desde Y=14 hasta Y=77.

**Usando WorldEdit**:
```
/teleport gabo 87 14 -43
/1
/teleport gabo 87 77 -43
/2
//set celevator:guide_rail
```

Repetir para otras paredes si es necesario.

### Paso 3: Instalar Maquinaria Superior (Y=77)
```
/teleport gabo 88 77 -43
```
- Colocar `celevator:machine` (motor)
- Colocar `celevator:controller` al lado
- Colocar `celevator:drive` al lado

### Paso 4: Instalar UNA SOLA Cabina
```
/teleport gabo 88 75 -43
```
- Colocar 1 `celevator:car_glassback`

**IMPORTANTE**: Solo necesitas colocar UNA cabina. El sistema la moverá automáticamente entre todos los pisos.

### Paso 5: Instalar Puertas en Cada Piso
```
/teleport gabo 90 15 -43
Colocar celevator:hwdoor_glass

/teleport gabo 90 20 -43
Colocar celevator:hwdoor_glass

# ... (continuar para los 13 pisos)
```

### Paso 6: Configurar el Controller
```
/teleport gabo 88 77 -43
```
- Clic derecho en el `controller`
- Configurar:
  - **Number of floors**: 13
  - **Floor height**: 5 (bloques entre pisos)
  - **Speed**: 5 m/s
  - **Bottom floor Y**: 15 (coordenada Y del piso 1)

### Paso 7: Instalar Botones de Llamada
En cada piso, al lado de la puerta, colocar botones de llamada.

---

## 🔍 DIFERENCIAS CLAVE CON LAS INSTRUCCIONES ANTERIORES

| Instrucciones Anteriores (INCORRECTAS) | Realidad de celevator (CORRECTAS) |
|----------------------------------------|-----------------------------------|
| Necesitas 13 cabinas                   | Solo necesitas 1 cabina           |
| Necesitas shaft (ejes verticales)      | NO existe shaft en celevator      |
| Cabinas estáticas en cada piso         | Cabina es una entidad móvil       |
| Colocar shaft con WorldEdit            | NO APLICABLE                      |

---

## 📖 DOCUMENTACIÓN OFICIAL

La documentación completa está en:
```
server/mods/celevator/docs/celevator_controller_manual.pdf
```

**RECOMENDACIÓN**: Revisar el PDF antes de continuar. Es la fuente de verdad sobre cómo funciona celevator.

---

## 🎯 PRÓXIMOS PASOS CORREGIDOS

1. **BORRAR** todas las cabinas que gabo ha colocado
2. **LEER** la documentación oficial (PDF)
3. **INSTALAR** solo 1 cabina en la parte superior
4. **CONFIGURAR** el controller con los parámetros correctos
5. **INSTALAR** puertas en cada piso
6. **TESTEAR** el ascensor

---

## 💡 CONCLUSIÓN

El error principal fue asumir que celevator funciona como ascensores en otros mods (con ejes físicos y múltiples cabinas). En realidad:

✅ **celevator es un sistema de ascensor REALISTA**
✅ **Una sola cabina se mueve entre pisos**
✅ **El controller maneja toda la lógica**
✅ **Las puertas se abren/cierran automáticamente**

**DISCULPAS POR LA CONFUSIÓN INICIAL**. Las instrucciones anteriores estaban basadas en un mod diferente.

---

**Creado por**: Claude Code
**Fecha**: 2025-11-08
**Estado**: Corrección crítica de arquitectura