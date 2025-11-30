# 🏢 Edificio de Administradores - Construcción con WorldEdit

## 📋 Información del Proyecto
- **Altura**: 100 pisos
- **Ascensor**: Cristal 3x2 (pozo central)
- **Herramienta**: WorldEdit commands
- **Usuario**: Gapi (admin)

---

## 🎯 Preparación Inicial

### Paso 1: Posicionarse en el punto de construcción
```
/spawn
```
Ubícate en el punto donde quieres que esté la base del edificio.

### Paso 2: Verificar privilegios WorldEdit
```
/privs
```
Debes tener: `worldedit`, `server`, `creative`, `fly`, `noclip`

---

## 🏗️ Comandos de Construcción Paso a Paso

### FASE 1: BASE DEL EDIFICIO (Planta Baja)

#### 1.1 Marcar posición inicial (esquina inferior)
Párate en la esquina donde comenzará el edificio y ejecuta:
```
//1
```

#### 1.2 Marcar posición final (esquina superior de la base)
Muévete 20 bloques al frente y 20 bloques al lado (edificio 20x20), luego:
```
//2
```

#### 1.3 Crear la base de piedra
```
//set mcl_core:stone
```

---

### FASE 2: ESTRUCTURA PRINCIPAL (100 pisos)

#### 2.1 Marcar área vertical completa
Párate en una esquina de la base:
```
//1
```

Vuela hacia arriba 400 bloques (100 pisos × 4 bloques por piso) y muévete a la esquina opuesta:
```
//2
```

#### 2.2 Crear paredes exteriores
```
//walls mcl_core:stonebrick
```

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
//set mcl_core:wood
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
//set mcl_core:wood
```

Ahora copia y pega hacia arriba 100 veces:
```
//copy
//stack 100 up 4
```

---

### FASE 3: ASCENSOR CENTRAL DE CRISTAL (3x2)

#### 3.1 Calcular posición central
Si tu edificio es 20x20, el centro está en X+10, Z+10 desde la esquina inicial.

#### 3.2 Limpiar el pozo del ascensor (3x2 × 400 bloques alto)
Párate en el centro del edificio, base (Y=0):
```
//1
```

Muévete 3 bloques en X, 2 bloques en Z, y 400 bloques arriba (Y=400):
```
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

#### 4.1 Ventanas en cada piso
Para cada piso, selecciona la pared exterior y reemplaza algunos bloques:
```
//replace mcl_core:stonebrick mcl_core:glass 30%
```
Esto reemplaza 30% de las paredes con ventanas.

#### 4.2 Techo del edificio
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
//set mcl_core:stonebrick
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
/tp 0 100 0

// BASE (20x20)
//1
// Muévete manualmente a +20,+0,+20
//2
//set mcl_core:stone

// ESTRUCTURA VERTICAL (400 bloques alto = 100 pisos)
//1
// Muévete a +20,+400,+20
//2
//walls mcl_core:stonebrick

// PISOS INTERNOS
// Crea primer piso en Y=4
//1
// Muévete a +20,+4,+20
//2
//set mcl_core:wood
//copy
//stack 99 up 4

// POZO DEL ASCENSOR (centro: +10,0,+10, tamaño 3x2)
// Párate en +10,0,+10
//1
// Muévete a +13,+400,+12
//2
//set air
//walls mcl_core:glass

// PLATAFORMAS DE CRISTAL EN ASCENSOR
// Párate en +10,4,+10 (primer piso)
//1
// Muévete a +13,4,+12
//2
//set mcl_core:glass
//copy
//stack 99 up 4

// VENTANAS (30% de paredes)
//1
// Selecciona todo el edificio nuevamente
//2
//replace mcl_core:stonebrick mcl_core:glass 30%

// TECHO
// Párate en +0,400,+0
//1
// Muévete a +20,400,+20
//2
//set mcl_core:stonebrick

// ILUMINACIÓN
//1
// Selecciona todo el interior
//2
//replace air mcl_torches:torch_floor 2%
```

---

## 📐 Dimensiones Finales

- **Base**: 20×20 bloques
- **Altura total**: 400 bloques (100 pisos × 4 bloques/piso)
- **Ascensor**: 3×2 bloques, cristal transparente
- **Ventanas**: 30% de las paredes exteriores
- **Material principal**: Ladrillos de piedra (mcl_core:stonebrick)
- **Pisos**: Madera (mcl_core:wood)
- **Ascensor**: Cristal (mcl_core:glass)

---

## ⚠️ Notas Importantes

1. **Rendimiento**: Construcción masiva puede causar lag temporal
2. **Backups**: El sistema hace backup automático cada 12 horas
3. **Comandos cortos**: Puedes usar `/1` y `/2` en lugar de `//1` y `//2` si worldedit_shortcommands está activo
4. **Correcciones**: Usa `//undo` para deshacer el último comando
5. **Guardar progreso**: El servidor guarda automáticamente cada 5 minutos

---

## 🎨 Variaciones Opcionales

### Edificio más ancho (30×30):
Cambia las dimensiones en los comandos de selección a +30 en lugar de +20

### Más pisos por nivel (5 bloques):
Cambia `//stack 99 up 4` a `//stack 99 up 5`

### Ascensor más grande (5×5):
Cambia las dimensiones del pozo de 3×2 a 5×5

### Paredes de cristal completo:
```
//replace mcl_core:stonebrick mcl_core:glass
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
- [ ] Crear base 20×20
- [ ] Construir paredes exteriores (400 bloques alto)
- [ ] Crear pisos internos (stack ×100)
- [ ] Vaciar pozo del ascensor (3×2)
- [ ] Instalar paredes de cristal en ascensor
- [ ] Crear plataformas de cristal (stack ×100)
- [ ] Añadir ventanas (30%)
- [ ] Construir techo
- [ ] Iluminación interior
- [ ] Verificar estructura completa
- [ ] Tomar screenshot del edificio terminado

---

**Tiempo estimado de construcción**: 15-20 minutos
**Fecha de creación**: 2025-11-29
**Creado para**: Gapi (Administrador Wetlands)
