# 🏢 Ascensor de 3 Pisos - Guía Simplificada

**Fecha**: 2025-11-10
**Propósito**: Instalación rápida de ascensor de 3 pisos usando mod celevator
**Dificultad**: Básica
**Tiempo estimado**: 15 minutos

---

## 📋 Resumen Ejecutivo

Esta guía te permite instalar un ascensor funcional de 3 pisos en menos de 15 minutos. Si funciona correctamente, puedes escalar a más pisos fácilmente.

---

## 🎯 Requisitos Previos

### 1. Coordenadas del Edificio

**⚠️ IMPORTANTE**: Antes de comenzar, define estas coordenadas:

```
SALA DE MÁQUINAS (Y más alto del edificio):
- Machine: X=___ Y=___ Z=___
- Controller: X=___ Y=___ Z=___ (al lado de machine)
- Drive: X=___ Y=___ Z=___ (al lado de machine)

PISOS (bottom Y + múltiplos de 5):
- Piso 1: X=___ Y=___ Z=___ (nivel más bajo)
- Piso 2: X=___ Y=___ Z=___ (bottom Y + 5)
- Piso 3: X=___ Y=___ Z=___ (bottom Y + 10)
```

### 2. Arquitectura del Edificio

```
Y=___: [Machine] [Controller] [Drive]  ← SALA DE MÁQUINAS
       ↓ (pozo despejado verticalmente)
Y=___: [Puerta] [Botón DOWN] ← Piso 3
Y=___: [Puerta] [Botón BOTH] ← Piso 2
Y=___: [Puerta] [Botón UP] [CABINA] ← Piso 1 (piso inicial)
```

**Reglas de arquitectura**:
- ✅ Pozo vertical despejado (sin bloques en el camino)
- ✅ Machine, Controller y Drive en el MISMO nivel Y
- ✅ Altura entre pisos: 5 bloques exactos
- ✅ Cabina en el piso más bajo (piso 1)

---

## 🚀 Instalación Paso a Paso

### PASO 1: Obtener Materiales

```bash
/give gabo celevator:machine 1
/give gabo celevator:controller 1
/give gabo celevator:drive 1
/give gabo celevator:car_glassback 1
/give gabo celevator:hwdoor_glass 3
/give gabo celevator:callbutton_up 1
/give gabo celevator:callbutton_down 1
/give gabo celevator:callbutton_both 1
```

---

### PASO 2: Instalar Machine (PRIMERO)

```bash
# Ir a la sala de máquinas
/teleport gabo X Y Z

# Colocar la MACHINE en el centro del pozo
# Clic derecho → Configurar Car ID = 1
```

**Posición Final**: `(X=___, Y=___, Z=___)`

**✅ Verificación**: La machine debe mostrar Car ID = 1 cuando la miras.

---

### PASO 3: Instalar Controller (SEGUNDO)

```bash
# Ir al mismo nivel que la machine
/teleport gabo X Y Z

# Colocar el CONTROLLER al lado de la machine
# Clic derecho → Configurar:
```

**Configuración del Controller**:
```
Car ID: 1
Number of floors: 3
Floor height: 5
Bottom floor Y: ___ (coordenada Y del piso 1)
Speed: 5
```

**Posición Final**: `(X=___, Y=___, Z=___)`

**✅ Verificación**:
- Espera 10 segundos
- Controller debe mostrar "READY" o "IDLE"
- Si muestra "FAULT", NO continúes (avisa)

---

### PASO 4: Instalar Drive (TERCERO)

```bash
# Ir al mismo nivel que machine y controller
/teleport gabo X Y Z

# Colocar el DRIVE al lado de la machine
```

**Posición Final**: `(X=___, Y=___, Z=___)`

**✅ Verificación**: Drive no tiene configuración, se conecta automáticamente.

---

### PASO 5: Instalar Puertas y Botones

#### Piso 3 (Más Alto)
```bash
/teleport gabo X Y Z

# 1. Colocar puerta hwdoor_glass frente al pozo
# 2. Colocar callbutton_down al lado de la puerta
# 3. Clic derecho en botón → Car ID = 1
```

#### Piso 2 (Medio)
```bash
/teleport gabo X Y Z

# 1. Colocar puerta hwdoor_glass
# 2. Colocar callbutton_both
# 3. Clic derecho en botón → Car ID = 1
```

#### Piso 1 (Más Bajo)
```bash
/teleport gabo X Y Z

# 1. Colocar puerta hwdoor_glass
# 2. Colocar callbutton_up
# 3. Clic derecho en botón → Car ID = 1
```

**✅ Verificación**: Todos los botones deben tener Car ID = 1.

---

### PASO 6: Instalar Cabina (ÚLTIMO)

```bash
# Ir al piso 1 (nivel más bajo)
/teleport gabo X Y Z

# Colocar UNA SOLA cabina car_glassback en el centro del pozo
# IMPORTANTE: Solo clic derecho UNA VEZ
# Espera 2 segundos para que aparezca completa
```

**Posición Final**: `(X=___, Y=___, Z=___)`

**✅ Verificación**:
- Debe haber solo UNA cabina
- La cabina debe estar en el piso 1
- Machine debe detectar la cabina (mirar machine con F5)

---

### PASO 7: Pruebas del Sistema

#### Test 1: Verificar Controller
```bash
/teleport gabo X_controller Y_controller Z_controller
# Clic derecho en controller
# Debe mostrar: "READY" o "IDLE"
# Si muestra "FAULT", revisar troubleshooting
```

#### Test 2: Llamar Cabina desde Piso 1
```bash
/teleport gabo X_piso1 Y_piso1 Z_piso1
# Presionar botón UP
# La puerta debe abrirse
# La cabina debe estar visible
```

#### Test 3: Viajar a Piso 2
```bash
# Entrar a la cabina
# Clic derecho dentro de la cabina
# Presionar botón "2"
# La cabina debe moverse suavemente a piso 2
```

#### Test 4: Viajar a Piso 3
```bash
# Presionar botón "3"
# La cabina debe subir a piso 3
```

#### Test 5: Regresar a Piso 1
```bash
# Presionar botón "1"
# La cabina debe bajar a piso 1
```

**✅ Indicadores de Éxito**:
- ✅ Controller muestra "READY" o "IDLE"
- ✅ Botones abren puertas
- ✅ Cabina se mueve entre los 3 pisos
- ✅ No aparece mensaje "Hoist Machine Missing"

---

## 🔧 Troubleshooting Rápido

### Error: "Hoist Machine Missing"

**Solución**:
1. Verificar que Machine, Controller y Drive están en el MISMO nivel Y
2. Verificar que la Cabina está en el nivel correcto (piso 1)
3. Verificar que todos los Car ID = 1

### Error: Cabina No Se Mueve

**Solución**:
1. Verificar Car ID en Machine → debe ser 1
2. Verificar Car ID en Controller → debe ser 1
3. Verificar Car ID en todos los botones → debe ser 1

### Error: Botones No Abren Puertas

**Solución**:
1. Verificar Car ID en botones → debe ser 1
2. Verificar que hay solo UNA cabina en el pozo
3. Verificar que Controller muestra "READY"

### Error: Texturas de la Cabina con Glitch Visual

**Causa**: Al colocar o mover la cabina, a veces sus texturas no cargan bien y se ven negras o incorrectas.
**Solución**: Reiniciar el servidor y reconectar al juego arregla el problema.
```bash
# Reiniciar el servidor
ssh gabriel@<IP_VPS_ANTERIOR> "cd /home/gabriel/luanti-voxelibre-server && docker-compose restart luanti-server"
```

### Panel Negro Persistente

**Solución**:
```bash
# Reiniciar el servidor
ssh gabriel@<IP_VPS_ANTERIOR> "cd /home/gabriel/luanti-voxelibre-server && docker-compose restart luanti-server"

# Reconectar al juego
# El panel debe desaparecer
```

---

## 📊 Checklist de Instalación

- [ ] Coordenadas definidas (sala de máquinas y 3 pisos)
- [ ] Pozo vertical despejado
- [ ] Machine instalada (Car ID = 1)
- [ ] Controller instalado (Car ID = 1, Floors = 3, Bottom Y correcto)
- [ ] Drive instalado
- [ ] Controller muestra "READY"
- [ ] 3 puertas instaladas
- [ ] 3 botones instalados (todos Car ID = 1)
- [ ] UNA SOLA cabina en piso 1
- [ ] Test 1: Botón piso 1 abre puerta ✅
- [ ] Test 2: Cabina sube a piso 2 ✅
- [ ] Test 3: Cabina sube a piso 3 ✅
- [ ] Test 4: Cabina baja a piso 1 ✅

---

## 📈 Próximos Pasos

Una vez que el sistema de 3 pisos funciona correctamente:

1. **Escalar a más pisos**:
   - Clic derecho en Controller
   - Cambiar: `Number of floors: 3` → número deseado
   - Instalar puertas y botones adicionales

2. **Proteger el área**:
   ```bash
   /teleport gabo X_centro Y_centro Z_centro
   /protect_here 25 ascensor-3-pisos
   ```

---

## 📝 Registro de Coordenadas

**✅ EDIFICIOS DETECTADOS EN EL SERVIDOR**:

---

## 🏢 EDIFICIO #1 - Torre Principal (Edificio Original)

### 🏗️ Estructura Completa del Edificio

**Análisis de Base de Datos (map.sqlite)**:
```
Rango de construcción detectado:
- Eje X: 0 a 3 (4 bloques de ancho)
- Eje Z: 14 a 18 (5 bloques de profundidad)
- Eje Y: -1 a 88 (89 bloques de altura total)
- Material: Construcción mixta
```

### 🎯 Componentes Identificados

**SALA DE MÁQUINAS (Techo del Edificio)**:
```
Nivel Y = 73 (identificado por bloques con data_size=147 en Z=18)
Pozo del ascensor: X=2, Z=14
```

**Coordenadas Específicas**:
- **Machine**: (X=2, Y=73, Z=18) - [Bloque especial detectado]
- **Controller**: (X=1 o 3, Y=73, Z=18) - [Adyacente a machine]
- **Drive**: (X=1 o 3, Y=73, Z=18) - [Adyacente a machine]

**POZO DEL ASCENSOR (Columna Central)**:
```
Columna principal: X=2, Z=14 (vertical desde Y=-1 hasta Y=88)
```

**PISOS PRINCIPALES (Bloques especiales en X=2, Z=14)**:

Bloques con data_size diferente a 48 (normales) indican componentes especiales:

- **Y=65**: data_size=145 → Posible botón/puerta
- **Y=47**: data_size=145 → Posible botón/puerta
- **Y=46**: data_size=197 → Componente especial
- **Y=45**: data_size=198 → Componente especial
- **Y=42**: data_size=145 → Posible botón/puerta
- **Y=41**: data_size=202 → Componente especial (posible cabina o controlador)
- **Y=37**: data_size=145 → Posible botón/puerta
- **Y=36**: data_size=150 → Componente especial
- **Y=35**: data_size=145 → Posible botón/puerta
- **Y=33**: data_size=145 → Posible botón/puerta
- **Y=32**: data_size=172 → Componente especial
- **Y=30**: data_size=145 → Posible botón/puerta
- **Y=29**: data_size=152 → Componente especial
- **Y=28**: data_size=145 → Posible botón/puerta
- **Y=27**: data_size=168 → Componente especial
- **Y=23**: data_size=202 → Componente especial (similar a Y=41)
- **Y=20**: data_size=201 → Componente especial

### 📐 Configuración Calculada

**Análisis de Separación de Pisos**:

Basándome en los bloques especiales detectados en el pozo (X=2, Z=14):

**Piso 3 (Más Alto)**: Y=65
- Botón/puerta: (X=2, Y=65, Z=14)

**Piso 2 (Medio)**: Y=47 o Y=42
- Separación desde Piso 3: ~18-23 bloques
- Botón/puerta: (X=2, Y=47, Z=14) o (X=2, Y=42, Z=14)

**Piso 1 (Más Bajo)**: Y=20 o Y=23
- Separación desde Piso 2: ~19-27 bloques
- Botón/puerta: (X=2, Y=20, Z=14) o (X=2, Y=23, Z=14)

### ⚙️ CONFIGURACIÓN ESTIMADA DEL CONTROLLER

```
Car ID: 1
Number of floors: 3
Floor height: 20-23 (altura irregular entre pisos)
Bottom floor Y: 20 (nivel más bajo con componente especial)
Speed: 5
```

### 🚨 OBSERVACIÓN IMPORTANTE

**⚠️ La separación entre pisos NO es estándar (5 bloques)**:
- La distancia entre pisos varía entre 18-27 bloques
- Esto sugiere que el edificio fue construido manualmente sin seguir la convención del mod
- Puede requerir ajuste manual del parámetro `Floor height` en el Controller

### 📊 Techo del Edificio
```
Nivel más alto: Y=88 (techo de vidrio/estructura)
Sala de máquinas: Y=73 (15 bloques debajo del techo)
```

---

**Última Actualización**: 2025-11-10
**Tiempo de instalación**: 15 minutos
**Dificultad**: Básica