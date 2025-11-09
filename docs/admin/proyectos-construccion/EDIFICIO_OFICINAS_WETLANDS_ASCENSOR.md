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

# ... repetir hasta Piso 13 (Y=66)
```

### Tabla de Coordenadas Y (13 Pisos)

| Piso | Y | Tipo de Botón |
|------|---|---------------|
| 1 | 17 | UP |
| 2 | 22 | BOTH |
| 3 | 27 | BOTH |
| 4 | 32 | BOTH |
| 5 | 37 | BOTH |
| 6 | 42 | BOTH |
| 7 | 47 | BOTH |
| 8 | 52 | BOTH |
| 9 | 57 | BOTH |
| 10 | 62 | BOTH |
| 11 | 66 | BOTH |
| 12 | 71 | BOTH |
| 13 | 76 | DOWN |

**Nota**: Altura por piso = 5 bloques (3 habitables + 1 piso + 1 techo)

---

## 🔧 Troubleshooting {#troubleshooting}

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
- [ ] 13 puertas instaladas (Y=17 hasta Y=76)
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
ssh gabriel@167.172.251.27 "cd /home/gabriel/luanti-voxelibre-server && docker-compose logs -f luanti-server | grep celevator"

# Verificar última acción de machine
ssh gabriel@167.172.251.27 "cd /home/gabriel/luanti-voxelibre-server && docker-compose logs luanti-server 2>&1 | grep 'celevator:machine' | tail -5"
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
/teleport gabo 88 76 -43
```

---

**Última Validación**: 2025-11-09
**Configuración Validada**: Método "Builder Dave" (componentes al mismo nivel)
**Tiempo de Instalación**: 10-15 minutos (testeo), 30-45 minutos (production)
**Dificultad**: Media (requiere privilegios de admin)