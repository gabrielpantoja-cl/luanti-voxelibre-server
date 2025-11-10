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

### Panel Negro Persistente

**Solución**:
```bash
# Reiniciar el servidor
ssh gabriel@<VPS_IP> "cd /home/gabriel/luanti-voxelibre-server && docker compose restart luanti-server"

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

**Completar durante la instalación**:

```
SALA DE MÁQUINAS:
- Machine: (X=___, Y=___, Z=___)
- Controller: (X=___, Y=___, Z=___)
- Drive: (X=___, Y=___, Z=___)

PISOS:
- Piso 3: (X=___, Y=___, Z=___)
- Piso 2: (X=___, Y=___, Z=___)
- Piso 1: (X=___, Y=___, Z=___)

CONFIGURACIÓN:
- Car ID: 1
- Number of floors: 3
- Floor height: 5
- Bottom floor Y: ___
- Speed: 5
```

---

**Última Actualización**: 2025-11-10
**Tiempo de instalación**: 15 minutos
**Dificultad**: Básica