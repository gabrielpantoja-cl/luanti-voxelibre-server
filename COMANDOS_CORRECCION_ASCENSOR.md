# 🔧 Comandos de Corrección del Ascensor - Configuración "Builder Dave"

**Fecha**: 2025-11-09
**Problema**: Machine, Controller y Drive en posiciones incorrectas
**Solución**: Configuración correcta según video de Luanti Builder Dave

---

## 📊 Análisis de Posiciones Actuales

**Estado Actual** (según logs del servidor):
- Machine: `(89, 73, -43)` ← **2 nodos muy arriba**
- Controller: `(83, 71, -43)` ← **3 nodos muy abajo y 6 bloques separado en X**
- Drive: `(83, 72, -42)` ← **4 nodos muy abajo y desalineado**

**Edificio**:
- Último piso (Piso 13): Y=66 (puerta)
- Techo del último piso: Y=67
- Sala de máquinas debe estar en: **Y=68**

---

## ✅ Configuración Correcta (Método "Builder Dave")

En ascensores reales y según el video de YouTube:

**Principio**: Los 3 componentes (machine, controller, drive) van **AL MISMO NIVEL**, justo arriba del techo del último piso.

**Posiciones Correctas**:
```
Y=68: Machine      (89, 68, -43)  ← Centro del pozo
Y=68: Controller   (88, 68, -43)  ← Al lado de la machine
Y=68: Drive        (89, 68, -42)  ← Al lado de la machine
```

**Razón**: Forman una "sala de máquinas" compacta en el mismo nivel, como en edificios reales.

---

## 🚀 COMANDOS A EJECUTAR (En orden)

**⚠️ IMPORTANTE**: Ejecuta estos comandos **UNO POR UNO** en el chat del juego.

### PASO 1: Excavación de Componentes Actuales

```bash
# Ir a la machine actual (posición incorrecta)
/teleport gabo 89 73 -43

# Excavar la machine (clic izquierdo)
# ⚠️ MANUAL: Haz clic izquierdo en la machine

# Ir al controller actual
/teleport gabo 83 71 -43

# Excavar el controller (clic izquierdo)
# ⚠️ MANUAL: Haz clic izquierdo en el controller

# Ir al drive actual
/teleport gabo 83 72 -42

# Excavar el drive (clic izquierdo)
# ⚠️ MANUAL: Haz clic izquierdo en el drive
```

---

### PASO 2: Verificación del Nivel de la Sala de Máquinas

```bash
# Ir al nivel donde debe estar la sala de máquinas
/teleport gabo 88 68 -43

# Verificar que hay un piso sólido en Y=67 (un bloque abajo)
# Si no hay piso, coloca bloques de madera o piedra en Y=67
```

---

### PASO 3: Instalación en Configuración Correcta

**CRÍTICO**: Los 3 componentes van **AL MISMO NIVEL (Y=68)**, formando una sala de máquinas compacta.

```bash
# INSTALAR MACHINE (Centro del pozo, Y=68)
/teleport gabo 89 68 -43
# ⚠️ MANUAL: Coloca la machine donde apareces (Y=68)

# INSTALAR CONTROLLER (Al lado de la machine, Y=68)
/teleport gabo 88 68 -43
# ⚠️ MANUAL: Coloca el controller donde apareces (Y=68)

# INSTALAR DRIVE (Al otro lado de la machine, Y=68)
/teleport gabo 89 68 -42
# ⚠️ MANUAL: Coloca el drive donde apareces (Y=68)
```

---

### PASO 4: Verificación de la Cabina

```bash
# Ir al piso 1 donde debe estar la cabina
/teleport gabo 88 17 -43

# Verificar que hay UNA SOLA cabina
# Si no hay cabina, coloca una:
/give gabo celevator:car_glassback 1
# ⚠️ MANUAL: Coloca la cabina en (88, 17, -43)

# Si hay MÚLTIPLES cabinas, elimina las extras
# Deja solo UNA cabina en el piso 1
```

---

### PASO 5: Configuración del Controller

```bash
# Ir al controller
/teleport gabo 88 68 -43

# Haz clic DERECHO en el controller para abrir su interfaz
# ⚠️ MANUAL: Configura estos parámetros EXACTOS:
# - Car ID: 1 (o el ID que prefieras)
# - Number of floors: 13
# - Floor height: 5 (altura total por piso)
# - Bottom floor Y: 17 (coordenada Y del piso 1)
# - Speed: 5 (m/s, recomendado)

# IMPORTANTE: Después de guardar, espera 10 segundos
# El controller debería mostrar "READY" o "IDLE"
```

---

### PASO 6: Pruebas del Sistema

```bash
# PRUEBA 1: Ir al piso 1
/teleport gabo 88 17 -43

# Busca el botón de llamada y presiónalo
# La puerta debería abrirse
# La cabina debería aparecer (si no está ya ahí)

# PRUEBA 2: Entrar a la cabina y usar el panel interno
# Presiona botón "7" para ir al piso intermedio
# La cabina debería moverse suavemente

# PRUEBA 3: Viajar al último piso
# Presiona botón "13"
# La cabina debería subir hasta Y=66
# Verifica que no hay errores
```

---

## 📐 Esquema Visual de la Configuración

```
Y=68: [Machine] [Controller] [Drive]  ← SALA DE MÁQUINAS (mismo nivel)
Y=67: [Techo del piso 13]
Y=66: [Puerta Piso 13]
Y=65: [Espacio habitable Piso 13]
Y=64: [Espacio habitable Piso 13]
...
Y=17: [Puerta Piso 1] + [Cabina ÚNICA]
Y=16: [Espacio habitable Piso 1]
Y=15: [Piso]
Y=14: [Buffer]
```

---

## 🔍 Diferencia con Recomendación Anterior (Incorrecta)

**Mi recomendación anterior (INCORRECTA)**:
- Machine en Y=73 (7 bloques arriba del último piso) ← **Demasiado alto**
- Controller en Y=71 (2 bloques bajo la machine) ← **Niveles separados**
- Drive en Y=71 (mismo nivel que controller) ← **Alejado de machine**

**Configuración correcta según "Builder Dave"**:
- Machine en Y=68 (1 bloque arriba del techo) ← **Justo arriba del edificio**
- Controller en Y=68 (mismo nivel que machine) ← **Sala de máquinas compacta**
- Drive en Y=68 (mismo nivel que machine) ← **Todos juntos**

**Ventajas de la configuración correcta**:
1. ✅ Realismo arquitectónico (como edificios reales)
2. ✅ Componentes compactos y fáciles de mantener
3. ✅ Menor distancia de recorrido (más eficiente)
4. ✅ Configuración estándar del mod celevator

---

## 🐛 Troubleshooting

**Si después de estos cambios el ascensor no funciona**:

1. **Verificar posiciones exactas**:
   ```bash
   # Verificar que machine está en Y=68
   /teleport gabo 89 68 -43
   # Deberías ver la machine aquí

   # Verificar que controller está en Y=68
   /teleport gabo 88 68 -43
   # Deberías ver el controller aquí

   # Verificar que drive está en Y=68
   /teleport gabo 89 68 -42
   # Deberías ver el drive aquí
   ```

2. **Verificar logs del servidor**:
   ```bash
   # Desde tu terminal local
   ssh gabriel@167.172.251.27 "cd /home/gabriel/luanti-voxelibre-server && docker-compose logs -f luanti-server | grep celevator"
   ```

3. **Resetear el controller**:
   ```bash
   # Excavar y volver a colocar el controller
   /teleport gabo 88 68 -43
   # Excavar controller, esperar 5 segundos, volver a colocar
   # Reconfigurar parámetros
   ```

---

## ✅ Indicadores de Éxito

Después de aplicar estos cambios, deberías ver:

1. ✅ Los 3 componentes visibles en el mismo nivel (Y=68)
2. ✅ Controller muestra "READY" o "IDLE" (no "FAULT")
3. ✅ Botones de llamada funcionan
4. ✅ Cabina se mueve suavemente entre pisos
5. ✅ No hay mensajes de error en chat
6. ✅ Puertas se abren/cierran automáticamente

---

**Tiempo estimado**: 10-15 minutos
**Dificultad**: Fácil (solo requiere seguir los pasos en orden)
**Resultado esperado**: Ascensor 100% funcional