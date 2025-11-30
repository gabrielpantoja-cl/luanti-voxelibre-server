# 🏢 Edificio de Administradores - Construcción con WorldEdit

## 📋 Información del Proyecto
- **Altura**: 100 pisos
- **Material**: 🔮 **100% CRISTAL** (paredes, pisos, base, techo)
- **Ascensor**: Cristal 3x2 (pozo central transparente)
- **Herramienta**: WorldEdit commands
- **Usuario**: Gapi (admin)
- **Estilo**: Edificio completamente transparente y futurista

---

## 🎯 Preparación Inicial

### Paso 1: Posicionarse en el punto de construcción

**📍 UBICACIÓN EXACTA DEL EDIFICIO:**
```
/teleport 50.7 22.5 21.8
```
Esta posición te coloca **mirando directamente a la puerta del ascensor**.

**🔷 LAS 4 ESQUINAS EXACTAS DEL PISO BASE (Y=22.5):**
1. **Esquina Noreste (NE)**: `60.1, 22.5, 31`
2. **Esquina Noroeste (NO)**: `40, 22.5, 31`
3. **Esquina Suroeste (SO)**: `40.2, 22.5, 11.2`
4. **Esquina Sureste (SE)**: `59.8, 22.5, 11.1`

**Coordenadas de referencia:**
- **Entrada del ascensor**: X=50.7, Y=22.5, Z=21.8
- **Orientación**: Mirando hacia la puerta del ascensor
- **Altura base**: Y=22.5 (nivel del piso de entrada)

### Paso 2: Verificar privilegios WorldEdit
```
/privs
```
Debes tener: `worldedit`, `server`, `creative`, `fly`, `noclip`

---

## 🏗️ Comandos de Construcción Paso a Paso

### FASE 1: BASE DEL EDIFICIO (Planta Baja)

#### 1.1 Marcar primera esquina (Suroeste)
```
/teleport 40.2 22.5 11.2
//1
```
Esta es la **esquina SUROESTE** del edificio.

#### 1.2 Marcar segunda esquina (Noreste)
```
/teleport 60.1 22.5 31
//2
```
Esta es la **esquina NORESTE** del edificio.

#### 1.3 Crear la base de cristal
```
//set mcl_core:glass
```
Esto crea el piso base completo de cristal.

---

### FASE 2: PAREDES DE CRISTAL (100 pisos = 400 bloques altura)

#### 2.1 PASO 1: Crear cubo SÓLIDO de cristal (todo lleno)

**Marcar esquina SUROESTE inferior:**
```
/teleport 40.2 22.5 11.2
//1
```

**Marcar esquina NORESTE superior (400 bloques arriba):**
```
/teleport 60.1 422.5 31
//2
```
*Nota: 422.5 = 22.5 (base) + 400 (altura de 100 pisos)*

**Llenar TODO de cristal:**
```
//set mcl_core:glass
```
⏳ *Esto puede tomar 30-60 segundos. Espera a que termine.*

---

#### 2.2 PASO 2: Vaciar el interior (dejar solo las paredes)

**Marcar esquina SUROESTE interior (1 bloque hacia adentro):**
```
/teleport 41.2 23.5 12.2
//1
```

**Marcar esquina NORESTE interior (1 bloque hacia adentro):**
```
/teleport 59.1 421.5 30
//2
```

**Vaciar el interior:**
```
//set air
```
⏳ *Esto puede tomar 30-60 segundos. Espera a que termine.*

✅ **¡Ahora tienes un edificio hueco con paredes de cristal de 1 bloque de grosor!**

#### 2.3 Crear pisos internos (cada 4 bloques)
Para cada piso, necesitas repetir este patrón. Ejemplo para piso 1:
```
//1
```
(Marca la esquina en Y=4)

```
//2
```
(Marca la esquina opuesta en Y=4)

```
//set mcl_core:glass
```

**Automatización con WorldEdit Stack** (más eficiente):

Primero crea un piso modelo:
```
//1
```
(Esquina inferior del primer piso en Y=4)

```
//2
```
(Esquina superior del primer piso en Y=4)

```
//set mcl_core:glass
```

Ahora copia y pega hacia arriba 100 veces:
```
//copy
//stack 100 up 4
```

---

### FASE 3: ASCENSOR CENTRAL DE CRISTAL (3x2)

#### 3.1 Posición central del ascensor
**📍 Ubicación exacta del ascensor:**
- **Centro del edificio**: X=50, Z=21
- **Puerta de entrada**: X=50.7, Y=22.5, Z=21.8 (ya conocida)

#### 3.2 Limpiar el pozo del ascensor (3x2 × 400 bloques alto)
**Esquina inferior del pozo:**
```
/teleport 49 22 20
//1
```

**Esquina superior del pozo (400 bloques arriba):**
```
/teleport 52 422 22
//2
```

Vaciar el espacio:
```
//set air
```

#### 3.3 Crear paredes de cristal del ascensor
Seleccionar solo las paredes del pozo:
```
//walls mcl_core:glass
```

#### 3.4 Crear plataformas de cristal en cada piso
Para cada piso (cada 4 bloques), crea una plataforma de vidrio:
```
//1
```
(Centro del pozo, nivel del piso)

```
//2
```
(3x2 en ese nivel)

```
//set mcl_core:glass
```

Repite con stack:
```
//copy
//stack 100 up 4
```

---

### FASE 4: DETALLES Y ACABADOS

#### 4.1 ~~Ventanas en cada piso~~ (No necesario - todo es cristal)
**NOTA**: Este paso se omite porque todo el edificio ya es de cristal transparente.

#### 4.2 Techo del edificio (cristal)
Sube al piso 100 (Y=400):
```
//1
```
(Marca una esquina del techo)

```
//2
```
(Marca la esquina opuesta)

```
//set mcl_core:glass
```

#### 4.3 Iluminación interior
Añadir antorchas en cada piso automáticamente:
```
//replace air mcl_torches:torch_floor 5%
```

---

## 🚀 COMANDOS COMPLETOS - EJECUCIÓN RÁPIDA

### Método Express (Copiar y pegar secuencialmente):

```
// PREPARACIÓN
/fly
/noclip

// ====== UBICACIÓN EXACTA DEL EDIFICIO ======
// Entrada del ascensor: 50.7, 22.5, 21.8
/teleport 50.7 22.5 21.8

// ====== ESQUINAS REALES DEL EDIFICIO ======
// NE: 60.1, 22.5, 31
// NO: 40, 22.5, 31
// SO: 40.2, 22.5, 11.2
// SE: 59.8, 22.5, 11.1

// BASE DE CRISTAL
// Esquina SUROESTE
/teleport 40.2 22.5 11.2
//1
// Esquina NORESTE
/teleport 60.1 22.5 31
//2
//set mcl_core:glass

// ====== PAREDES DE CRISTAL (400 bloques altura) ======

// PASO 1: Crear cubo SÓLIDO de cristal
// Esquina SUROESTE inferior
/teleport 40.2 22.5 11.2
//1
// Esquina NORESTE superior (400 bloques arriba)
/teleport 60.1 422.5 31
//2
//set mcl_core:glass

// PASO 2: Vaciar el interior (dejar solo paredes)
// Esquina SUROESTE interior (1 bloque hacia adentro)
/teleport 41.2 23.5 12.2
//1
// Esquina NORESTE interior (1 bloque hacia adentro)
/teleport 59.1 421.5 30
//2
//set air

// PISOS INTERNOS DE CRISTAL
// Primer piso (Y=26, que es base+4)
/teleport 40 26 11
//1
/teleport 60 26 31
//2
//set mcl_core:glass
//copy
//stack 99 up 4

// POZO DEL ASCENSOR (3x2 en el centro)
// Esquina inferior del pozo (49, 22, 20)
/teleport 49 22 20
//1
// Esquina superior del pozo (52, 422, 22)
/teleport 52 422 22
//2
//set air
//walls mcl_core:glass

// PLATAFORMAS DE CRISTAL EN ASCENSOR
// Primera plataforma (nivel del primer piso)
/teleport 49 26 20
//1
/teleport 52 26 22
//2
//set mcl_core:glass
//copy
//stack 99 up 4

// TECHO DE CRISTAL
/teleport 40 422 11
//1
/teleport 60 422 31
//2
//set mcl_core:glass

// ILUMINACIÓN
/teleport 40 22 11
//1
/teleport 60 422 31
//2
//replace air mcl_torches:torch_floor 2%

// ====== VOLVER A LA ENTRADA ======
/teleport 50.7 22.5 21.8
```

---

## 📐 Dimensiones y Coordenadas Finales

### 🎯 Ubicación en el Mundo
- **📍 Entrada del ascensor**: X=50.7, Y=22.5, Z=21.8
- **Esquina suroeste**: X=40, Y=22, Z=11
- **Esquina noreste**: X=60, Y=22, Z=31
- **Centro del edificio**: X=50, Z=21
- **Altura del techo**: Y=422 (400 bloques sobre la base)

### 📏 Dimensiones Físicas
- **Base**: 20×20 bloques de cristal
- **Altura total**: 400 bloques (100 pisos × 4 bloques/piso)
- **Ascensor**: 3×2 bloques (X: 49-52, Z: 20-22)
- **Material**: 🔮 **100% CRISTAL** (mcl_core:glass)
- **Paredes**: Cristal transparente
- **Pisos**: Cristal transparente
- **Techo**: Cristal transparente
- **Estilo**: Edificio completamente transparente y futurista

### 🗺️ Mapa de Coordenadas Clave
```
Edificio 20×20:
  Esquina NE (60, 22, 31) ────────────┐
                                      │
                                      │ 20 bloques
                                      │
  Esquina SO (40, 22, 11) ────────────┘
         └──── 20 bloques ────┘

Ascensor 3×2 (centro del edificio):
  - Esquina inferior: (49, 22, 20)
  - Esquina superior: (52, 422, 22)
  - Puerta de entrada: (50.7, 22.5, 21.8)
```

---

## ⚠️ Notas Importantes

1. **Rendimiento**: Construcción masiva puede causar lag temporal
2. **Backups**: El sistema hace backup automático cada 12 horas
3. **Comandos cortos**: Puedes usar `/1` y `/2` en lugar de `//1` y `//2` si worldedit_shortcommands está activo
4. **Correcciones**: Usa `//undo` para deshacer el último comando
5. **Guardar progreso**: El servidor guarda automáticamente cada 5 minutos
6. **🔮 Edificio de cristal**: Todo el edificio es transparente, por lo que verás a través de todas las paredes y pisos. ¡Efecto visual espectacular!

---

## 🎨 Variaciones Opcionales

### Edificio más ancho (30×30):
Cambia las dimensiones en los comandos de selección a +30 en lugar de +20

### Más pisos por nivel (5 bloques):
Cambia `//stack 99 up 4` a `//stack 99 up 5`

### Ascensor más grande (5×5):
Cambia las dimensiones del pozo de 3×2 a 5×5

### Cristal de colores (opcional):
Puedes usar variantes de cristal coloreado:
```
//set mcl_core:glass_cyan        # Cristal cian
//set mcl_core:glass_light_blue  # Cristal azul claro
//set mcl_core:glass_blue        # Cristal azul
//set mcl_core:glass_white       # Cristal blanco
```

---

## 🛠️ Troubleshooting

**Error: "Not enough privileges"**
```
/grant Gapi worldedit
/grant Gapi server
```

**Error: "Too many blocks selected"**
- Divide la construcción en secciones más pequeñas
- Construye 25 pisos a la vez en lugar de 100

**Lag durante construcción**
- Normal, espera 30 segundos después de comandos grandes
- Reduce el área de selección

**Ascensor no funciona**
- Este método solo construye la estructura visual
- Para ascensor funcional, necesitas el mod `mesecons_elevator` o similar

---

## 📝 Checklist de Construcción

- [ ] Verificar privilegios WorldEdit
- [ ] Activar `/fly` y `/noclip`
- [ ] Crear base de cristal 20×20
- [ ] Construir paredes exteriores de cristal (400 bloques alto)
- [ ] Crear pisos internos de cristal (stack ×100)
- [ ] Vaciar pozo del ascensor (3×2)
- [ ] Instalar paredes de cristal en ascensor
- [ ] Crear plataformas de cristal en ascensor (stack ×100)
- [ ] Construir techo de cristal
- [ ] Iluminación interior (antorchas)
- [ ] Verificar estructura completamente transparente
- [ ] Tomar screenshot del edificio de cristal terminado (¡se verá espectacular!)

---

**Tiempo estimado de construcción**: 15-20 minutos
**Fecha de creación**: 2025-11-29
**Creado para**: Gapi (Administrador Wetlands)
