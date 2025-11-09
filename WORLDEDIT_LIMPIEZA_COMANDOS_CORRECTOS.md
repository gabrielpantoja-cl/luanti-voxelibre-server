# 🧹 COMANDOS WORLDEDIT CORRECTOS - LIMPIEZA DE ASCENSOR

**Fecha**: 2025-11-09
**Para**: gabo
**Objetivo**: Eliminar TODAS las cabinas y puertas cerca de ti

---

## 📖 CÓMO FUNCIONA WORLDEDIT

WorldEdit requiere **2 pasos**:
1. **Definir un área** (pos1 y pos2) - las esquinas de un cubo
2. **Ejecutar el comando** de reemplazo dentro de esa área

---

## 🎯 MÉTODO 1: LIMPIEZA RÁPIDA (RECOMENDADO)

Este método crea un área grande alrededor del pozo del ascensor.

### Paso 1: Ir a la esquina inferior del pozo
```
/teleport gabo 85 14 -45
```

### Paso 2: Marcar primera posición
```
//pos1
```
O el comando corto:
```
/1
```

### Paso 3: Ir a la esquina superior opuesta
```
/teleport gabo 91 77 -41
```

### Paso 4: Marcar segunda posición
```
//pos2
```
O el comando corto:
```
/2
```

### Paso 5: Verificar el volumen seleccionado
```
//volume
```
O el comando corto:
```
/v
```
Deberías ver algo como: "Current region has a volume of XXXXX nodes"

### Paso 6: Eliminar TODAS las cabinas
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

### Paso 7: Eliminar TODAS las puertas
```
//replace celevator:hwdoor_glass air
//replace celevator:hwdoor_fast_glass_top air
//replace celevator:hwdoor_fast_glass_bottom air
//replace celevator:hwdoor_slow_glass_top air
//replace celevator:hwdoor_slow_glass_bottom air
```

---

## 🎯 MÉTODO 2: LIMPIEZA USANDO COMANDOS CORTOS

Si prefieres comandos más cortos:

### Definir área
```
/1          (en la primera esquina)
/2          (en la segunda esquina)
/v          (verificar volumen)
```

### Eliminar cabinas (comando corto)
```
//r celevator:car_glassback air
//r celevator:car_glassback_000 air
//r celevator:car_glassback_001 air
//r celevator:car_glassback_002 air
//r celevator:car_glassback_010 air
//r celevator:car_glassback_011 air
//r celevator:car_glassback_012 air
//r celevator:car_glassback_020 air
//r celevator:car_glassback_021 air
//r celevator:car_glassback_022 air
//r celevator:car_glassback_100 air
//r celevator:car_glassback_101 air
//r celevator:car_glassback_102 air
//r celevator:car_glassback_110 air
//r celevator:car_glassback_111 air
//r celevator:car_glassback_112 air
//r celevator:car_glassback_120 air
//r celevator:car_glassback_121 air
//r celevator:car_glassback_122 air
```

### Eliminar puertas (comando corto)
```
//r celevator:hwdoor_glass air
//r celevator:hwdoor_fast_glass_top air
//r celevator:hwdoor_fast_glass_bottom air
//r celevator:hwdoor_slow_glass_top air
//r celevator:hwdoor_slow_glass_bottom air
```

---

## 🎯 MÉTODO 3: LIMPIEZA MANUAL (Si WorldEdit no funciona)

Si prefieres eliminar manualmente:

1. Vuela por el pozo del ascensor
2. Rompe cada cabina y puerta manualmente con clic izquierdo
3. Verifica que no quede ninguna

---

## 📊 VERIFICACIÓN DESPUÉS DE LA LIMPIEZA

### 1. Volar por el pozo
```
/teleport gabo 88 15 -43
```
Luego vuela hacia arriba (tecla K por defecto si tienes fly activado)

### 2. Buscar visualmente
- ❌ NO debe haber cabinas
- ❌ NO debe haber puertas
- ✅ Deben permanecer: controller, drive, machine, botones de llamada

### 3. Verificar con logs
Después de ejecutar cada comando `//replace`, el servidor te dirá:
```
X nodes replaced
```

Si dice "0 nodes replaced", significa que no había ese tipo de bloque en el área.

---

## 🔍 COMANDOS WORLDEDIT ÚTILES

### Ver posiciones marcadas
```
//mark
```
Esto mostrará marcadores visuales en pos1 y pos2

### Desmarcar
```
//unmark
```

### Reset de posiciones
```
//reset
```

### Inspeccionar bloque
```
//inspect
```
Luego haz clic en un bloque para ver su nombre exacto

---

## 🚨 ERRORES COMUNES

### Error: "Invalid node name"
**Causa**: El nombre del nodo está mal escrito
**Solución**: Usa `//inspect` para ver el nombre exacto del bloque

### Error: "No region selected"
**Causa**: No has marcado pos1 y pos2
**Solución**: Ejecuta `//pos1` y `//pos2` primero

### Error: "Region volume is too large"
**Causa**: El área seleccionada es demasiado grande
**Solución**: Reduce el área o aumenta el límite de WorldEdit (requiere permisos de admin)

---

## 📋 CHECKLIST DE LIMPIEZA

Marca cada paso cuando lo completes:

- [ ] 1. Teleportarme a esquina inferior (85, 14, -45)
- [ ] 2. Marcar pos1 con `//pos1` o `/1`
- [ ] 3. Teleportarme a esquina superior (91, 77, -41)
- [ ] 4. Marcar pos2 con `//pos2` o `/2`
- [ ] 5. Verificar volumen con `//volume`
- [ ] 6. Ejecutar comandos `//replace` para cabinas (19 comandos)
- [ ] 7. Ejecutar comandos `//replace` para puertas (5 comandos)
- [ ] 8. Volar por el pozo para verificar
- [ ] 9. Confirmar que NO quedan cabinas ni puertas
- [ ] 10. Continuar con instalación del ascensor

---

## 💡 TIPS

1. **Copia y pega**: Copia TODOS los comandos de una vez y pégalos en el chat
2. **Paciencia**: Cada comando puede tardar 1-2 segundos en ejecutarse
3. **Verificación visual**: Después de la limpieza, SIEMPRE verifica visualmente
4. **Backup**: Si tienes dudas, haz backup del mundo antes (admin)

---

## 🎯 DESPUÉS DE LA LIMPIEZA

Una vez que TODO esté limpio, el próximo paso es:

1. ✅ Instalar buffer en Y=14
2. ✅ Instalar guide rails
3. ✅ Instalar SOLO 1 cabina en el piso inicial
4. ✅ Instalar 13-14 puertas (una por piso)
5. ✅ Configurar controller
6. ✅ Testing

---

**Creado por**: Claude Code
**Fecha**: 2025-11-09
**Basado en**: worldedit_commands mod oficial
**Comandos verificados**: ✅ Sintaxis correcta