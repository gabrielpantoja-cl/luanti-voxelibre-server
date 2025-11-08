# Análisis de Mods de Ascensor para Wetlands

**Fecha de Análisis**: 2025-11-08
**Mods Analizados**: celevator, realtime_elevator (elevator)
**Objetivo**: Encontrar un mod de ascensor compatible con VoxeLibre o adaptar uno existente

---

## Resumen Ejecutivo

Se analizaron dos mods principales de ascensor disponibles en la comunidad de Luanti:

1. **Realtime Elevator** - ✅ **RECOMENDADO** - Compatible con VoxeLibre
2. **celevator** - ⚠️ Requiere adaptación - Texturas reutilizables

---

## 1. Realtime Elevator (elevator)

### Información General
- **Autor**: shacknetisp
- **Repositorio**: https://github.com/shacknetisp/elevator.git
- **Licencia**: Revisar LICENSE.txt
- **Tamaño**: ~28KB (muy ligero)
- **Compatibilidad**: ✅ **VoxeLibre/MineClone2 NATIVO**

### Características Principales
- Sistema de transporte vertical en tiempo real (no teletransporte instantáneo)
- Requiere motor en la parte superior, ejes y al menos dos ascensores
- Movimiento realista con física de entidades
- Configuración simple y directa

### Compatibilidad con VoxeLibre

El mod detecta automáticamente si `mcl_core` está presente y adapta:

**Texturas Específicas MCL**:
- `elevator_box_mcl.png` - Caja del ascensor (16x16)
- `elevator_motor_mcl.png` - Motor del ascensor (16x16)
- `elevator_shaft_mcl.png` - Eje del ascensor (16x16)

**Grupos de Items MCL**:
```lua
{pickaxey=1, axey=1, handy=1, swordy=1, transport=1, dig_by_piston=1}
```

**Sonidos MCL**:
```lua
mcl_sounds.node_sound_stone_defaults()
```

**Recetas de Crafteo MCL** (desde `crafts.lua:8-33`):

**Ascensor** (elevator:elevator_off):
```
[hierro] [papel] [hierro]
[hierro] [oro]   [hierro]
[arcilla][vidrio][arcilla]
```

**Eje** (elevator:shaft):
```
[hierro] [madera]
[madera] [hierro]
```

**Motor** (elevator:motor):
```
[oro]    [hierro]      [oro]
[bloque_hierro][horno][bloque_hierro]
[papel]  [oro]         [papel]
```

### Estructura de Archivos
```
realtime_elevator/
├── init.lua              # Lógica principal del ascensor
├── components.lua        # Definición de nodos (shaft, motor, elevator)
├── crafts.lua            # Recetas compatibles con MCL
├── formspecs.lua         # Interfaces de usuario
├── helpers.lua           # Funciones auxiliares
├── hooks.lua             # Hooks de eventos
├── storage.lua           # Persistencia de datos
├── mod.conf              # Configuración del mod
├── settingtypes.txt      # Configuraciones personalizables
└── textures/
    ├── elevator_box_mcl.png
    ├── elevator_motor_mcl.png
    └── elevator_shaft_mcl.png
```

### Configuraciones Disponibles (settingtypes.txt)
- `elevator_speed` - Velocidad inicial del ascensor (default: 10)
- `elevator_accel` - Aceleración (default: 0.1)
- `elevator_time` - Timeout máximo sin jugadores (default: 120s)
- `elevator_slow_dist` - Distancia para desacelerar (default: 16)
- `elevator_slow_speed_factor` - Factor de velocidad lenta (default: 0.11)

### Ventajas
✅ Compatible con VoxeLibre sin modificaciones
✅ Sistema ligero y eficiente
✅ Movimiento realista en tiempo real
✅ Texturas específicas para MCL incluidas
✅ Recetas balanceadas para modo creativo/survival
✅ Configuración flexible vía settings

### Desventajas
❌ Menos realista que celevator
❌ No tiene sonidos de ascensor (puertas, campanas, etc.)
❌ Texturas simples (16x16)
❌ Sin puertas animadas ni controles avanzados

### Instalación y Uso

**1. El mod ya está instalado en**:
```
server/mods/realtime_elevator/
```

**2. Habilitar en `server/config/luanti.conf`**:
```ini
load_mod_realtime_elevator = true
```

**3. Construcción Básica**:
```
[Motor]           <- Tope superior
[Eje]
[Eje]
[Ascensor Piso 2]
[Eje]
[Eje]
[Ascensor Piso 1] <- Base
```

**4. Uso en el Juego**:
- Clic derecho en un ascensor para ver lista de pisos
- Seleccionar piso destino
- El ascensor se mueve en tiempo real hasta el destino

---

## 2. celevator (Realistic Elevators)

### Información General
- **Autor**: cheapie
- **Repositorio**: https://cheapiesystems.com/git/celevator
- **Licencia**: The Unlicense (dominio público)
- **Tamaño**: ~3.5MB (incluye manual PDF y muchos assets)
- **Compatibilidad**: ⚠️ Minetest vanilla (NO VoxeLibre nativo)

### Características Principales
- Sistema de ascensor MUY realista
- Puertas animadas con sonidos
- Sistema de llamada por piso con botones
- Panel de control dentro del ascensor
- Campanas de dirección (arriba/abajo)
- Sistema de frenos, gobernador, poleas
- Manual PDF incluido (docs/celevator_controller_manual.pdf)
- Múltiples estilos de cabinas (estándar, metal, vidrio)

### Análisis de Compatibilidad VoxeLibre

**Dependencias** (desde `mod.conf:3`):
```
optional_depends = laptop, mesecons, digilines, xcompat,
                   mesecons_lightstone, mesecons_button
```

❌ **NO menciona compatibilidad con mcl_core o MineClone2**
❌ **NO tiene texturas _mcl.png**
❌ **NO tiene recetas MCL**
❌ **Diseñado para Minetest vanilla (default mod)**

### Estructura de Archivos (Simplificada)
```
celevator/
├── init.lua                # Registro principal
├── car.lua                 # Lógica de la cabina
├── doors.lua               # Sistema de puertas
├── callbuttons.lua         # Botones de llamada
├── controller.lua          # Controlador del ascensor
├── motor.lua               # Motor y maquinaria
├── sounds/                 # 21 archivos .ogg
│   ├── celevator_door_open.ogg
│   ├── celevator_door_close.ogg
│   ├── celevator_chime_up.ogg
│   ├── celevator_chime_down.ogg
│   ├── celevator_motor_run.ogg
│   └── ...
├── textures/               # 238+ archivos PNG
│   ├── celevator_car_*.png
│   ├── celevator_door_*.png
│   ├── celevator_button_*.png
│   ├── celevator_motor_*.png
│   └── ...
└── docs/
    └── celevator_controller_manual.pdf
```

### Texturas Destacadas (Reutilizables)

**Puertas y Controles**:
- `celevator_door_glass_*.png` - Puertas de vidrio
- `celevator_door_metal.png` - Puertas metálicas
- `celevator_callbutton_*.png` - Botones de llamada
- `celevator_button_rect_*.png` - Botones rectangulares
- `celevator_cop.png` - Panel de control

**Cabinas**:
- `celevator_car_floor.png` - Piso de cabina
- `celevator_car_ceiling.png` - Techo de cabina
- `celevator_car_glass.png` - Paredes de vidrio
- `celevator_car_metal_*.png` - Variantes metálicas

**Indicadores**:
- `celevator_lantern_up.png` - Indicador subiendo
- `celevator_lantern_down.png` - Indicador bajando
- `celevator_pi_*.png` - Indicadores de piso (caracteres 0-9, A-Z)

**Maquinaria**:
- `celevator_motor_*.png` - Motor del ascensor
- `celevator_sheave_*.png` - Poleas
- `celevator_guide_rail*.png` - Rieles guía

### Ventajas
✅ Sistema extremadamente realista
✅ 21 sonidos profesionales de ascensor
✅ 238+ texturas de alta calidad
✅ Manual PDF completo
✅ Múltiples estilos de cabinas
✅ Sistema de control avanzado
✅ Integración con mesecons/digilines

### Desventajas
❌ NO compatible con VoxeLibre sin adaptación
❌ Muy complejo (curva de aprendizaje alta)
❌ Tamaño grande (3.5MB)
❌ Requiere muchos nodos para construcción
❌ Diseñado para `default` mod (vanilla Minetest)

### Estrategia de Adaptación para VoxeLibre

**Opción 1: Adaptación Completa del Código** (Trabajo Alto)
1. Crear `crafts_mcl.lua` con recetas MCL
2. Modificar `init.lua` para detectar `mcl_core`
3. Agregar grupos MCL a todos los nodos
4. Reemplazar sonidos `default` por `mcl_sounds`
5. Testing exhaustivo

**Opción 2: Reutilización de Assets** (Recomendado)
1. Extraer texturas más útiles (puertas, botones, indicadores)
2. Extraer sonidos (door_open, door_close, chimes)
3. Crear mod simple compatible con VoxeLibre
4. Usar lógica de `realtime_elevator` como base
5. Mejorar con assets de `celevator`

---

## 3. Recomendaciones

### Para Uso Inmediato: Realtime Elevator ✅

**Justificación**:
- Compatible con VoxeLibre sin modificaciones
- Funcional y probado en MineClone2
- Ligero y eficiente
- Fácil de configurar

**Pasos de Implementación**:
```bash
# 1. Ya está copiado en server/mods/realtime_elevator/

# 2. Habilitar en luanti.conf
echo "load_mod_realtime_elevator = true" >> server/config/luanti.conf

# 3. Reiniciar servidor
docker-compose restart luanti-server

# 4. Probar en el juego
# Craftear: motor, ejes, ascensores
# Construir: torre vertical con motor en tope
```

### Para Mejorar a Futuro: Mod Híbrido Customizado

**Concepto**: Combinar lo mejor de ambos mods

**Base Técnica**: `realtime_elevator`
- Compatibilidad VoxeLibre nativa
- Lógica de movimiento probada
- Sistema de detección de pisos funcional

**Mejoras con Assets de `celevator`**:
- Agregar sonidos profesionales (21 archivos .ogg)
- Mejorar texturas (puertas, botones, indicadores)
- Agregar puertas animadas (opcional)
- Agregar indicadores de dirección (flechas arriba/abajo)

**Creación del Mod Híbrido**:
```
server/mods/wetlands_elevator/
├── init.lua                    # Base de realtime_elevator
├── components.lua              # Modificado con nuevas texturas
├── doors.lua                   # Nuevo: puertas animadas
├── sounds.lua                  # Nuevo: sistema de sonidos
├── mod.conf                    # depends = mcl_core
├── textures/
│   ├── wetlands_elevator_box.png          # De celevator
│   ├── wetlands_elevator_door_*.png       # De celevator
│   ├── wetlands_elevator_button_*.png     # De celevator
│   └── wetlands_elevator_indicator_*.png  # De celevator
└── sounds/
    ├── wetlands_elevator_door_open.ogg    # De celevator
    ├── wetlands_elevator_door_close.ogg   # De celevator
    ├── wetlands_elevator_chime_up.ogg     # De celevator
    └── wetlands_elevator_chime_down.ogg   # De celevator
```

---

## 4. Assets Específicos Recomendados de celevator

### Sonidos (Copiar desde `celevator/sounds/`)
```
Priority 1 (Esenciales):
- celevator_door_open.ogg
- celevator_door_close.ogg
- celevator_chime_up.ogg
- celevator_chime_down.ogg

Priority 2 (Realismo):
- celevator_car_run.ogg
- celevator_car_start.ogg
- celevator_car_stop.ogg
- celevator_motor_accel.ogg
- celevator_motor_decel.ogg
```

### Texturas (Copiar desde `celevator/textures/`)
```
Priority 1 (Visuales Clave):
- celevator_door_glass_*.png (puertas de vidrio)
- celevator_door_metal.png (puerta metálica)
- celevator_callbutton_*.png (botones de llamada)
- celevator_lantern_up.png (indicador subiendo)
- celevator_lantern_down.png (indicador bajando)

Priority 2 (Mejora Estética):
- celevator_car_floor.png
- celevator_car_ceiling.png
- celevator_car_glass.png
- celevator_button_rect_*.png
- celevator_cop.png (panel de control)

Priority 3 (Indicadores de Piso):
- celevator_pi_30.png (0)
- celevator_pi_31.png (1)
- celevator_pi_32.png (2)
- ... (números del 0-9)
```

---

## 5. Documentación Adicional

### Ubicación de Mods Descargados
```
Local (temporal): /tmp/elevator_mods/
- celevator/
- realtime_elevator/

Servidor (permanente): server/mods/
- celevator/
- realtime_elevator/
```

### Recursos Externos
- **celevator ContentDB**: https://content.luanti.org/packages/cheapie/celevator/
- **celevator Git**: https://cheapiesystems.com/git/celevator
- **Realtime Elevator ContentDB**: https://content.luanti.org/packages/shacknetisp/elevator/
- **Realtime Elevator GitHub**: https://github.com/shacknetisp/elevator.git

### Manual PDF de celevator
```
server/mods/celevator/docs/celevator_controller_manual.pdf
```

---

## 6. Próximos Pasos

### Fase 1: Testing de Realtime Elevator (Hoy)
- [ ] Habilitar mod en luanti.conf
- [ ] Reiniciar servidor
- [ ] Probar crafteo de componentes
- [ ] Construir ascensor de prueba (3 pisos)
- [ ] Verificar movimiento y física
- [ ] Documentar experiencia de uso

### Fase 2: Extracción de Assets de celevator (Mañana)
- [ ] Identificar sonidos específicos a usar
- [ ] Identificar texturas específicas a usar
- [ ] Copiar assets seleccionados a directorio temporal
- [ ] Renombrar con convención `wetlands_elevator_*`

### Fase 3: Creación de Mod Híbrido (Próxima semana)
- [ ] Crear estructura `wetlands_elevator/`
- [ ] Adaptar código base de `realtime_elevator`
- [ ] Integrar sonidos de celevator
- [ ] Integrar texturas mejoradas
- [ ] Crear recetas MCL balanceadas
- [ ] Testing completo en servidor local
- [ ] Deployment a producción

---

## 7. Conclusiones

**Realtime Elevator** es la solución inmediata perfecta para Wetlands:
- Compatible con VoxeLibre sin modificaciones
- Funcional y probado
- Fácil de usar para niños 7+ años

**celevator** es una excelente fuente de assets:
- Texturas profesionales y detalladas
- Sonidos realistas que mejoran inmersión
- Sistema complejo que puede simplificarse

**Estrategia Recomendada**:
1. Implementar `realtime_elevator` ahora
2. Extraer assets de `celevator`
3. Crear `wetlands_elevator` híbrido en el futuro

Esta estrategia permite tener funcionalidad inmediata mientras se trabaja en una versión mejorada con mejor estética y sonidos.

---

**Análisis realizado por**: Claude Code
**Fecha**: 2025-11-08
**Próxima revisión**: Después de testing de realtime_elevator