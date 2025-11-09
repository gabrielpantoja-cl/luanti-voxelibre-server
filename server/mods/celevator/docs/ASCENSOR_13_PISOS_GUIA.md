# Guía para Completar el Ascensor de 13 Pisos - Wetlands

**Fecha**: 2025-11-08
**Ubicación**: Edificio de Oficinas en (88,15-70,-43)
**Problema Identificado**: Componentes parcialmente instalados, falta configuración y componentes críticos

---

## 📊 Diagnóstico Actual

### ✅ Componentes Instalados
- **Controller** (Controlador): Y=70-71
- **Drive** (Unidad de control): Y=71
- **Machine** (Motor): Y=70
- **Algunas cabinas** (car_glassback): Y=15-19 (removidas múltiples veces)

### ❌ Componentes Faltantes Críticos
1. **Shaft** (Ejes verticales) - Conectan motor con cabinas
2. **Guide Rails** (Rieles guía) - Guían la cabina verticalmente
3. **Buffers** (Amortiguadores) - En el fondo del pozo (seguridad)
4. **Cabinas completas** - 13 cabinas alineadas (una por piso)
5. **Doors** (Puertas) - 13 puertas (una frente a cada cabina)
6. **Call Buttons** (Botones de llamada) - En cada piso
7. **Governor** (Gobernador de velocidad) - Control de seguridad

---

## 🎯 Plan de Acción: Completar el Ascensor

### Paso 1: Calcular las Coordenadas Y de Cada Piso

Para un edificio de 13 pisos con **5 bloques por piso**:

```
Piso 1 (PB):  Y = 15
Piso 2:       Y = 20
Piso 3:       Y = 25
Piso 4:       Y = 30
Piso 5:       Y = 35
Piso 6:       Y = 40
Piso 7:       Y = 45
Piso 8:       Y = 50
Piso 9:       Y = 55
Piso 10:      Y = 60
Piso 11:      Y = 65
Piso 12:      Y = 70
Piso 13 (Azotea): Y = 75

Motor/Controller: Y = 77-80 (parte superior del pozo)
Amortiguadores: Y = 14 (fondo del pozo)
```

**IMPORTANTE**: Todas las cabinas deben tener las **MISMAS coordenadas X y Z**, solo cambia Y.

---

### Paso 2: Craftear los Componentes Faltantes

#### 2.1. Shaft (Ejes Verticales)
**Cantidad Necesaria**: ~65 bloques (conectan todo el pozo)
**Receta MCL**:
```
[barra_acero] [hierro] [barra_acero]
[barra_acero] [hierro] [barra_acero]
[barra_acero] [hierro] [barra_acero]
```
Output: 10 shaft por crafting

#### 2.2. Guide Rails (Rieles Guía)
**Cantidad Necesaria**: ~65 bloques (a lo largo del pozo)
**Receta MCL**:
```
[tira_acero] [hierro] [tira_acero]
[tira_acero] [hierro] [tira_acero]
[tira_acero] [hierro] [tira_acero]
```
Output: 10 guide rails por crafting

#### 2.3. Buffers (Amortiguadores)
**Cantidad Necesaria**: 1-2 bloques (fondo del pozo)
**Receta Buffer de Aceite**:
```
             [barra_acero]
[hierro] [cubo_vacío] [hierro]
[hierro] [hierro]     [hierro]
```

#### 2.4. Cabinas (car_glassback)
**Cantidad Necesaria**: 13 cabinas (una por piso)
**Receta MCL**:
```
[hierro]  [hierro]       [hierro]
[botón]   [puerta_vidrio][vidrio]
[palanca] [hierro]       [hierro]
```

#### 2.5. Puertas (hwdoor_glass)
**Cantidad Necesaria**: 13 puertas (una por piso)
**Receta MCL**:
```
[barra_acero] [barra_acero] [barra_acero]
[vidrio]      [barra_acero] [vidrio]
[barra_acero] [barra_acero] [barra_acero]
```

#### 2.6. Botones de Llamada
**Cantidad Necesaria**:
- 11 botones "both" (pisos 2-12)
- 1 botón "up" (piso 1)
- 1 botón "down" (piso 13)

**Receta Call Button Both**:
```
[tira_acero] [luz_azul] [botón]
[tira_acero] [luz_extra]
[tira_acero] [luz_azul] [botón]
```

#### 2.7. Governor (Gobernador)
**Cantidad Necesaria**: 1
**Receta MCL**:
```
[tira_acero] [barra_acero] [botón]
[tira_acero] [engranaje]   [tira_acero]
```

---

### Paso 3: Instalación Paso a Paso

#### 3.1. Preparar el Fondo del Pozo (Y=14)
1. Ir a coordenadas (89, 14, -43)
2. Colocar **Buffer** (amortiguador)
3. Verificar que el piso esté nivelado

#### 3.2. Instalar Shaft (Ejes Verticales)
1. Desde Y=14 hasta Y=76 (altura del motor)
2. Colocar **Shaft** verticalmente en el centro del pozo
3. Los shaft deben estar **alineados verticalmente**

**Comando rápido con WorldEdit**:
```
//pos1
//pos2 ~ ~62 ~
//set celevator:shaft
```

#### 3.3. Instalar Guide Rails (Rieles Guía)
1. En las paredes del pozo
2. Desde Y=14 hasta Y=76
3. Colocar guide rails en 2-3 paredes diferentes

**Patrón recomendado**:
- Pared norte: Guide rails cada 2 bloques
- Pared este: Guide rails cada 2 bloques

#### 3.4. Instalar Cabinas en Cada Piso
**CRÍTICO**: Todas las cabinas deben estar en **LA MISMA posición X,Z**, solo cambia Y.

**Ubicación sugerida**: (89, Y, -43)

```bash
# Piso 1:  /teleport gabo 89 15 -43
# Piso 2:  /teleport gabo 89 20 -43
# Piso 3:  /teleport gabo 89 25 -43
# ... (continuar para todos los pisos)
# Piso 13: /teleport gabo 89 75 -43
```

En cada coordenada, colocar **1 cabina car_glassback**.

#### 3.5. Instalar Puertas Frente a Cada Cabina
- Las puertas van **delante** de cada cabina
- Ubicación sugerida: (90, Y, -43) o (88, Y, -43)
- Deben estar orientadas hacia la cabina

#### 3.6. Configurar Maquinaria Superior (Y=77-80)

**Ubicaciones recomendadas**:
```
Controller: (84, 77, -43)
Drive:      (85, 77, -43)
Machine:    (89, 77, -43)
Governor:   (84, 78, -43)
```

**Verificar que**:
- Machine (motor) esté en la parte MÁS ALTA del shaft
- Controller esté accesible para configuración
- Todos estén cerca entre sí

#### 3.7. Instalar Botones de Llamada
En cada piso, **fuera de la cabina**, colocar botones:

```
Piso 1:  callbutton_up   (solo botón arriba)
Piso 2-12: callbutton_both (ambos botones)
Piso 13: callbutton_down (solo botón abajo)
```

---

### Paso 4: Configurar el Controller

Una vez todo instalado:

1. **Hacer clic derecho** en el Controller
2. Se abrirá la interfaz GUI
3. **Configurar**:
   - **Number of floors**: 13
   - **Floor names**: PB, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, Azotea
   - **Speed**: 5 m/s (recomendado para multiplayer)
   - **Mode**: Selective Collective (modo estándar)
4. **Guardar configuración**
5. **Activar el sistema** (switch en el controller)

---

### Paso 5: Testing y Verificación

#### 5.1. Test Básico
1. Ir al Piso 1
2. Presionar botón "UP"
3. Esperar que la cabina llegue
4. Entrar a la cabina
5. Presionar botón de Piso 13
6. Verificar:
   - ✅ Cabina se mueve suavemente
   - ✅ Puertas abren/cierran automáticamente
   - ✅ Sonidos funcionan correctamente
   - ✅ Cabina para en el piso correcto

#### 5.2. Test de Todos los Pisos
Probar el ascensor desde:
- Piso 1 → Piso 13
- Piso 13 → Piso 1
- Piso 5 → Piso 10 (viaje intermedio)

#### 5.3. Test de Múltiples Llamadas
1. Presionar botón en Piso 3
2. Mientras la cabina viene, presionar botón en Piso 7
3. Verificar que el ascensor atienda ambas llamadas

---

## 🚨 Troubleshooting: Problemas Comunes

### Problema 1: "Cabina no se mueve"
**Causas**:
- Falta shaft (ejes) conectando motor con cabinas
- Controller no configurado correctamente
- Machine (motor) no está en la parte superior

**Solución**:
1. Verificar que hay shaft desde Y=14 hasta Y=77
2. Abrir Controller GUI y verificar configuración
3. Asegurar que Machine esté en Y=77 o superior

### Problema 2: "Cabina se detiene en posiciones incorrectas"
**Causas**:
- Cabinas no están alineadas verticalmente
- Distancia entre pisos no es uniforme

**Solución**:
1. Verificar que TODAS las cabinas tienen la misma X y Z
2. Verificar que la distancia entre pisos es exactamente 5 bloques

### Problema 3: "Puertas no abren/cierran"
**Causas**:
- Puertas no están frente a las cabinas
- Puertas no están orientadas correctamente

**Solución**:
1. Colocar puertas exactamente delante de cada cabina
2. Verificar orientación de las puertas

### Problema 4: "Controller no tiene GUI"
**Causas**:
- Controller no está completamente instalado
- Falta drive o machine

**Solución**:
1. Remover y volver a colocar el controller
2. Asegurar que drive y machine estén instalados
3. Reiniciar el servidor si es necesario

---

## 📋 Checklist Final

Antes de declarar el ascensor "completo", verificar:

- [ ] Amortiguadores instalados en Y=14
- [ ] Shaft instalado desde Y=14 hasta Y=77 (vertical continuo)
- [ ] Guide rails instalados en las paredes del pozo
- [ ] 13 cabinas instaladas en Y=15, 20, 25, 30, 35, 40, 45, 50, 55, 60, 65, 70, 75
- [ ] Todas las cabinas tienen la MISMA coordenada X y Z
- [ ] 13 puertas instaladas frente a cada cabina
- [ ] Machine instalado en Y=77
- [ ] Controller instalado y configurado en Y=77
- [ ] Drive instalado en Y=77
- [ ] Governor instalado en Y=78
- [ ] 13 botones de llamada instalados (1 por piso)
- [ ] Controller configurado: 13 pisos, 5 m/s, nombres de pisos
- [ ] Test completo: viaje desde piso 1 a piso 13
- [ ] Test de botones en todos los pisos
- [ ] Test de sonidos (puertas, motor, campanas)

---

## 🎓 Comandos Útiles para Testing

### Teleportarse a Cada Piso
```
/teleport gabo 89 15 -43   # Piso 1
/teleport gabo 89 20 -43   # Piso 2
/teleport gabo 89 25 -43   # Piso 3
/teleport gabo 89 30 -43   # Piso 4
/teleport gabo 89 35 -43   # Piso 5
/teleport gabo 89 40 -43   # Piso 6
/teleport gabo 89 45 -43   # Piso 7
/teleport gabo 89 50 -43   # Piso 8
/teleport gabo 89 55 -43   # Piso 9
/teleport gabo 89 60 -43   # Piso 10
/teleport gabo 89 65 -43   # Piso 11
/teleport gabo 89 70 -43   # Piso 12
/teleport gabo 89 75 -43   # Piso 13
/teleport gabo 89 77 -43   # Sala de máquinas
```

### Comandos de Ascensor (si configurado)
```
/carcall 1 1    # Llamar cabina 1 al piso 1
/upcall 1 5     # Llamada arriba en piso 5
/downcall 1 10  # Llamada abajo en piso 10
```

### WorldEdit para Construcción Rápida
```
//pos1           # Marcar posición 1
//pos2 ~0 ~62 ~0 # Marcar 62 bloques arriba
//set celevator:shaft  # Crear shaft vertical
```

---

## 💡 Tips Adicionales

### Usar Creative Mode
Si no tienes todos los materiales:
```
/grant gabo creative
/give gabo celevator:shaft 64
/give gabo celevator:guide_rail 64
/give gabo celevator:buffer_oil 2
/give gabo celevator:car_glassback 13
/give gabo celevator:hwdoor_glass 13
/give gabo celevator:callbutton_both 11
/give gabo celevator:callbutton_up 1
/give gabo celevator:callbutton_down 1
/give gabo celevator:governor 1
```

### Backup del Mundo
Antes de hacer cambios grandes:
```bash
ssh gabriel@167.172.251.27 "cd /home/gabriel/luanti-voxelibre-server && ./scripts/backup.sh"
```

---

## 📞 Documentación de Referencia

- **Manual completo**: `server/mods/celevator/docs/celevator_controller_manual.pdf`
- **Guía técnica VoxeLibre**: `docs/mods/CELEVATOR_VOXELIBRE.md`
- **Guía de construcción**: `docs/mods/CELEVATOR_BUILDING_GUIDE.md`

---

**Creado por**: Claude Code
**Fecha**: 2025-11-08
**Estado**: Guía de diagnóstico y solución

**PRÓXIMO PASO**: Implementar los pasos 3.1 a 3.7 para completar la instalación del ascensor.