# Guía de Construcción con celevator - Dimensiones Óptimas

**Fecha**: 2025-11-08
**Para**: Servidor Wetlands - VoxeLibre

---

## 📐 Dimensiones de la Cabina del Ascensor

### Cabina Estándar (car_standard)
```
Dimensiones: 2 (ancho) x 3 (alto) x 3 (profundo) bloques
```

**Vista Frontal**:
```
┌─────┬─────┐
│     │     │  ← 3 bloques alto (cabina)
│     │     │
│     │     │
└─────┴─────┘
  2 bloques ancho
```

**Vista Lateral (profundidad)**:
```
┌─────────┐
│         │
│         │  ← 3 bloques profundo
│         │
└─────────┘
```

---

## 🏗️ Altura Óptima por Piso

### Recomendación Estándar: **5 bloques por piso**

Esta es la configuración más común y cómoda:

```
Piso 2: Y=10 ┌─────────────┐ ← Techo (1 bloque)
             │             │ ← Espacio aéreo (3 bloques)
             │   Jugador   │
             │             │
             └─────────────┘ ← Piso (1 bloque)

Piso 1: Y=5  ┌─────────────┐ ← Techo (1 bloque)
             │             │ ← Espacio aéreo (3 bloques)
             │   Jugador   │
             │             │
             └─────────────┘ ← Piso (1 bloque)

Total: 5 bloques de separación entre pisos
```

### Otras Configuraciones

#### **Configuración Compacta: 4 bloques**
- ✅ Ahorra espacio vertical
- ⚠️ Techo más bajo (puede sentirse claustrofóbico)
- 🎯 Ideal para: Edificios industriales, almacenes

```
Separación: 4 bloques
Y+4 = Piso superior
Y+0 = Piso inferior
```

#### **Configuración Lujosa: 6 bloques**
- ✅ Techos altos, sensación de amplitud
- ⚠️ Edificios más altos
- 🎯 Ideal para: Hoteles, edificios corporativos, lobbies

```
Separación: 6 bloques
Y+6 = Piso superior
Y+0 = Piso inferior
```

#### **Configuración de Doble Altura: 8-10 bloques**
- ✅ Lobbies impresionantes
- ⚠️ Solo para pisos especiales (planta baja, áticos)
- 🎯 Ideal para: Entradas principales, áticos de lujo

```
Separación: 8-10 bloques
Y+8 o Y+10 = Piso superior
Y+0 = Piso inferior
```

---

## 🏢 Ejemplos de Edificios Completos

### Edificio Pequeño (3 pisos)
```
Configuración: 5 bloques/piso

Piso 3 (Ático): Y=10        ┌─────┐ ← Motor del ascensor
                            │ ### │
Piso 2: Y=5                 │ Car │ ← Cabina (3 bloques alto)
                            │ ### │
Piso 1 (PB): Y=0            └─────┘ ← Amortiguador

Altura total del pozo: 10 bloques + 3 (motor) = 13 bloques
```

### Edificio Mediano (5 pisos)
```
Configuración: 5 bloques/piso

Piso 5 (Terraza): Y=20      ┌─────┐ ← Motor
Piso 4: Y=15                │     │
Piso 3: Y=10                │ Car │
Piso 2: Y=5                 │     │
Piso 1 (PB): Y=0            └─────┘ ← Amortiguador

Altura total del pozo: 20 bloques + 3 (motor) = 23 bloques
```

### Rascacielos (10 pisos)
```
Configuración: 5 bloques/piso

Piso 10 (Penthouse): Y=45   ┌─────┐ ← Motor
Piso 9: Y=40                │     │
Piso 8: Y=35                │     │
Piso 7: Y=30                │     │
Piso 6: Y=25                │ Car │
Piso 5: Y=20                │     │
Piso 4: Y=15                │     │
Piso 3: Y=10                │     │
Piso 2: Y=5                 │     │
Piso 1 (PB): Y=0            └─────┘ ← Amortiguador

Altura total del pozo: 45 bloques + 3 (motor) = 48 bloques
```

---

## 📏 Dimensiones del Pozo del Ascensor

### Pozo Mínimo (Sin Decoración)
```
Ancho: 3 bloques (cabina 2 + margen 1)
Profundo: 4 bloques (cabina 3 + puerta 1)
```

### Pozo Estándar (Recomendado)
```
Ancho: 4 bloques
Profundo: 5 bloques

Vista superior:
┌─────────────────┐
│ # # # # # # # # │ ← Pared
│ # ┌───────┐ □ # │ ← □ = Puerta, ┌───┐ = Car
│ # │  Car  │   # │
│ # │       │   # │
│ # └───────┘   # │
│ # # # # # # # # │
└─────────────────┘
```

### Pozo de Lujo (Con Rieles Guía Visibles)
```
Ancho: 5 bloques
Profundo: 6 bloques

Vista superior:
┌───────────────────┐
│ # R # # R # # R # │ ← R = Rieles guía
│ # # ┌───────┐ □ # │
│ # # │  Car  │   # │
│ # # │       │   # │
│ # # └───────┘   # │
│ # R # # R # # R # │
└───────────────────┘
```

---

## ⚡ Rendimiento y Velocidad

### Información del README
- **Pisos soportados**: 2 a 100
- **Velocidad máxima**: 20 m/s (metros por segundo)
- **Velocidad recomendada multiplayer**: ≤ 7.5 m/s

### Tiempo de Viaje Estimado

Con velocidad de **5 m/s** (recomendada para Wetlands):

| Altura | Pisos | Tiempo |
|--------|-------|--------|
| 10 bloques | 2-3 pisos | ~2 segundos |
| 25 bloques | 5-6 pisos | ~5 segundos |
| 50 bloques | 10-11 pisos | ~10 segundos |
| 100 bloques | 20-21 pisos | ~20 segundos |

**Nota**: El ascensor también tiene tiempo de:
- Apertura de puertas: ~2 segundos
- Espera en piso: configurable
- Cierre de puertas: ~2 segundos

---

## 🎯 Casos de Uso Recomendados

### Torre de Apartamentos (5-8 pisos)
```
Configuración: 5 bloques/piso
Pozo: 4x5 bloques
Estilo: Estándar con puertas de vidrio
Altura total: 25-40 bloques
```

### Centro Comercial (3-4 pisos)
```
Configuración: 6 bloques/piso (techos altos)
Pozo: 5x6 bloques (más amplio)
Estilo: Lujo con paredes de vidrio
Altura total: 18-24 bloques
```

### Edificio de Oficinas (8-15 pisos)
```
Configuración: 5 bloques/piso
Pozo: 4x5 bloques
Estilo: Cabina metálica
Altura total: 40-75 bloques
```

### Rascacielos (15+ pisos)
```
Configuración: 5 bloques/piso
Pozo: 4x5 bloques
Estilo: Metal-vidrio premium
Altura total: 75+ bloques
Sistema: Múltiples ascensores (zonas)
```

### Hospital de Santuario (4-6 pisos)
```
Configuración: 6 bloques/piso (espacioso)
Pozo: 5x6 bloques
Estilo: Vidrio panorámico
Altura total: 24-36 bloques
```

---

## 🛠️ Checklist de Construcción

### Antes de Construir
- [ ] Decidir número de pisos (2-100)
- [ ] Calcular altura total: `pisos × altura_por_piso`
- [ ] Marcar coordenadas Y de cada piso
- [ ] Planificar dimensiones del pozo (mínimo 3x4)
- [ ] Elegir tipo de cabina (estándar/vidrio/metal)

### Durante la Construcción
- [ ] Construir pozo completo desde abajo hacia arriba
- [ ] Instalar rieles guía en las paredes
- [ ] Colocar amortiguadores en el fondo
- [ ] Colocar cabinas en cada piso (mismo nivel Y)
- [ ] Instalar puertas frente a cada cabina
- [ ] Colocar motor en la parte superior
- [ ] Instalar controlador junto al motor
- [ ] Colocar botones de llamada en cada piso

### Verificación Final
- [ ] Probar movimiento entre todos los pisos
- [ ] Verificar apertura/cierre de puertas
- [ ] Comprobar sonidos funcionando
- [ ] Ajustar velocidad si es necesario
- [ ] Etiquetar pisos con nombres personalizados

---

## 📊 Tabla Rápida de Referencia

| Edificio | Pisos | Bloques/Piso | Altura Pozo | Tiempo Viaje* |
|----------|-------|--------------|-------------|---------------|
| Casa | 2 | 5 | 5 + motor | ~1s |
| Duplex | 2 | 5 | 5 + motor | ~1s |
| Triplex | 3 | 5 | 10 + motor | ~2s |
| Edificio pequeño | 5 | 5 | 20 + motor | ~4s |
| Edificio mediano | 8 | 5 | 35 + motor | ~7s |
| Edificio grande | 12 | 5 | 55 + motor | ~11s |
| Rascacielos | 20 | 5 | 95 + motor | ~19s |

*Tiempo a 5 m/s de velocidad

---

## 💡 Tips Profesionales

### Optimización de Espacio
- **Pisos impares**: Usa 5 bloques/piso para cálculos fáciles
- **Pisos pares**: Considera 6 bloques/piso para más espacio
- **Lobbies**: 8-10 bloques de altura en planta baja

### Estética
- **Vidrio panorámico**: Usa `car_glassback` para vistas
- **Industrial**: Usa `car_metal` con puertas metálicas
- **Moderno**: Usa `car_metal_glassback` para estilo premium

### Múltiples Ascensores
Para edificios grandes:
- **Zona baja**: Ascensor 1 (pisos 1-10)
- **Zona alta**: Ascensor 2 (pisos 11-20)
- **Express**: Ascensor 3 (solo PB y azotea)

### WorldEdit para Construcción Rápida
```lua
// Crear pozo de 4x50x5 bloques
//pos1
//pos2 ~4 ~50 ~5
//set mcl_core:stone

// Vaciar interior
//pos1 ~1 ~1 ~1
//pos2 ~2 ~49 ~3
//set air
```

---

## 🎓 Ejemplos de Coordenadas Reales

### Edificio de 5 Pisos (5 bloques/piso)

```
Y=23: Motor del ascensor
Y=20: Piso 5 (Terraza) - Cabina aquí
Y=15: Piso 4 - Cabina aquí
Y=10: Piso 3 - Cabina aquí
Y=5:  Piso 2 - Cabina aquí
Y=0:  Piso 1 (PB) - Cabina aquí
Y=-1: Amortiguador

Comando para marcar pisos con bloques temporales:
/lua for y=0,20,5 do minetest.set_node({x=X,y=y,z=Z},{name="mcl_core:goldblock"}) end
```

---

## ⚠️ Errores Comunes a Evitar

### ❌ Error 1: Pisos muy juntos (3 bloques)
```
Problema: Jugador choca con el techo
Solución: Mínimo 4 bloques, recomendado 5
```

### ❌ Error 2: Pozo muy estrecho (2x3)
```
Problema: No hay espacio para la cabina
Solución: Mínimo 3x4, recomendado 4x5
```

### ❌ Error 3: No alinear cabinas
```
Problema: Ascensor no detecta todos los pisos
Solución: Todas las cabinas en la misma coordenada X y Z
```

### ❌ Error 4: Olvidar el motor
```
Problema: Ascensor no funciona
Solución: Motor SIEMPRE en la parte superior del pozo
```

### ❌ Error 5: Olvidar los ejes (shaft)
```
Problema: Cabina no se mueve entre pisos
Solución: Ejes conectando motor → cabina superior → ejes → cabina inferior
```

---

## 📞 Referencias

- **Manual completo**: `server/mods/celevator/docs/celevator_controller_manual.pdf`
- **Guía técnica**: `docs/mods/CELEVATOR_VOXELIBRE.md`
- **Recetas**: Ver guía técnica para crafteo de componentes

---

**Creado por**: Claude Code
**Última actualización**: 2025-11-08
**Para**: Wetlands VoxeLibre Server