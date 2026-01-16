# 📚 Custom Villagers - Índice de Documentación

**Mod**: Custom Villagers v1.0.1
**Última actualización**: 2026-01-16
**Estado**: ✅ Crash fix aplicado | ⚠️ Testing de funcionalidad pendiente

---

## 📖 Guía de Documentación

### Para Usuarios del Servidor

#### 🎮 [README.md](README.md) - Documentación Principal
**Propósito**: Guía completa del mod para jugadores y administradores

**Contenido**:
- 📋 Descripción del mod y características
- 🎯 Cómo usar los aldeanos en el juego
- 🛠️ Comandos de administración (`/spawn_villager`, `/villager_info`)
- ⚙️ Configuración en minetest.conf
- 📦 Instrucciones de instalación
- 🎨 Guía de texturas
- 🔧 Troubleshooting básico
- 📝 **CHANGELOG** con crash fix v1.0.1

**Leer si**:
- ✅ Quieres saber qué hace el mod
- ✅ Necesitas spawnear aldeanos
- ✅ Quieres configurar parámetros
- ✅ Tienes problemas básicos

---

### Para Testing y QA

#### 🧪 [TESTING_GUIDE.md](TESTING_GUIDE.md) - Guía de Testing Completa
**Propósito**: Protocolo paso a paso para verificar funcionalidad

**Contenido**:
- 📋 Testing rápido (5 minutos)
  - ✅ Click derecho no crashea (CONFIRMADO)
  - ⚠️ Aldeanos pueden hablar (PENDIENTE)
  - ⚠️ Sistema de comercio funciona (PENDIENTE)
  - ⚠️ Saludos automáticos (PENDIENTE)
- 🔬 Testing completo (30 minutos)
  - 4 tipos de aldeanos individualmente
  - 6 estados de comportamiento AI
  - Tests de escalabilidad (1, 5, 10, 20 NPCs)
- 📊 Checklist de verificación completa
- 🐛 Template de reporte de bugs

**Leer si**:
- ✅ Quieres probar si los NPCs funcionan correctamente
- ✅ Necesitas verificar comportamientos AI
- ✅ Vas a hacer QA del mod
- ✅ Quieres reportar bugs de forma estructurada

---

#### 📋 [TODO.md](TODO.md) - Tareas Pendientes de Verificación
**Propósito**: Lista de tareas y checklist de testing

**Contenido**:
- ✅ Tareas completadas
  - Crash fix aplicado y confirmado
  - Emojis eliminados
  - Validaciones defensivas implementadas
- ⚠️ Tareas pendientes (prioridad alta)
  1. Verificar sistema de diálogos interactivos
  2. Verificar sistema de comercio
  3. Verificar saludos automáticos
  4. Verificar comportamientos AI (6 estados)
- 📝 Tareas de optimización (prioridad media)
  - Resolver warnings de API deprecada
  - Mejorar sistema de partículas
- 🚀 Features futuras (prioridad baja)
- 📊 Criterios de éxito

**Leer si**:
- ✅ Quieres saber qué falta por verificar
- ✅ Estás planificando testing
- ✅ Necesitas priorizar tareas
- ✅ Quieres actualizar checklist de progreso

---

### Para Desarrolladores

#### 🛡️ [CRASH_FIX_PATCH.md](CRASH_FIX_PATCH.md) - Documentación Técnica del Parche
**Propósito**: Detalles técnicos completos del crash fix

**Contenido**:
- 🚨 Problema reportado y diagnóstico
- 🔍 3 causas potenciales identificadas:
  1. Emojis Unicode en mensajes
  2. Falta de validación defensiva en formspecs
  3. Llamadas a mcl_mobs sin validación
- 🛠️ Soluciones implementadas (código antes/después)
- 📊 Impacto del parche
- 🧪 Testing recomendado
- 📝 Notas de versión (v1.0.0 → v1.0.1)
- 🚀 Deployment checklist
- ✅ Post-deployment verification

**Leer si**:
- ✅ Necesitas entender el problema técnico
- ✅ Quieres saber qué código cambió exactamente
- ✅ Estás haciendo code review
- ✅ Necesitas documentar el fix en otro proyecto

---

#### 📚 [docs/AI_BEHAVIORS.md](docs/AI_BEHAVIORS.md) - Sistema de Comportamientos AI
**Propósito**: Documentación completa del sistema AI tradicional (FSM)

**Contenido**:
- 🤖 Arquitectura de la máquina de estados finitos
- 📋 Explicación de cada estado (IDLE, WANDER, WORK, SOCIAL, SLEEP, SEEK_PLAYER)
- ⚙️ Configuración avanzada de pesos y parámetros
- 🔧 Troubleshooting del sistema AI
- 💻 Guía de desarrollo para extender comportamientos

**Leer si**:
- ✅ Quieres entender cómo funciona el AI
- ✅ Necesitas modificar comportamientos
- ✅ Estás desarrollando nuevos estados
- ✅ Quieres optimizar performance del AI

---

#### 🔧 [docs/INTEGRATION_GUIDE.md](docs/INTEGRATION_GUIDE.md) - Integración con VoxeLibre
**Propósito**: Guía de integración paso a paso con VoxeLibre

**Contenido**:
- 📦 Deployment en servidor VoxeLibre
- 🎨 Verificación de texturas
- 🧪 Testing de compatibilidad
- 🐛 Resolución de problemas específicos de VoxeLibre

**Leer si**:
- ✅ Estás instalando el mod por primera vez
- ✅ Tienes problemas de compatibilidad con VoxeLibre
- ✅ Las texturas no aparecen correctamente
- ✅ Necesitas integrar con otros mods de VoxeLibre

---

## 🗂️ Estructura de Archivos

```
server/mods/custom_villagers/
├── README.md                    # 📖 Documentación principal (usuarios)
├── DOCS_INDEX.md               # 📚 Este archivo (índice de docs)
├── TODO.md                     # 📋 Tareas pendientes de verificación
├── TESTING_GUIDE.md            # 🧪 Guía de testing completa
├── CRASH_FIX_PATCH.md          # 🛡️ Documentación técnica del fix
│
├── init.lua                    # ⚙️ Código principal (registros de mobs)
├── ai_behaviors.lua            # 🤖 Sistema de comportamientos AI
├── config.lua                  # ⚙️ Configuración centralizada
├── mod.conf                    # 📦 Metadatos del mod
│
├── docs/
│   ├── AI_BEHAVIORS.md         # 🤖 Sistema AI tradicional (FSM)
│   └── INTEGRATION_GUIDE.md    # 🔧 Integración VoxeLibre
│
├── textures/                   # 🎨 (Usa texturas de VoxeLibre)
├── sounds/                     # 🔊 (Futuro)
└── locale/                     # 🌍 (Futuro)
```

---

## 🎯 Flujo de Trabajo Recomendado

### Si eres usuario nuevo del mod:
1. Lee [README.md](README.md) para entender qué hace
2. Usa comandos `/spawn_villager` y `/villager_info`
3. Si tienes problemas, revisa Troubleshooting en README

### Si estás probando el mod:
1. Empieza con [TESTING_GUIDE.md](TESTING_GUIDE.md) - Test rápido (5 min)
2. Si quieres testing completo, sigue la guía completa (30 min)
3. Marca tareas completadas en [TODO.md](TODO.md)
4. Reporta bugs usando template en TESTING_GUIDE

### Si estás desarrollando/debuggeando:
1. Lee [CRASH_FIX_PATCH.md](CRASH_FIX_PATCH.md) para entender cambios recientes
2. Revisa [docs/AI_BEHAVIORS.md](docs/AI_BEHAVIORS.md) para sistema AI
3. Consulta [docs/INTEGRATION_GUIDE.md](docs/INTEGRATION_GUIDE.md) para VoxeLibre
4. Actualiza [TODO.md](TODO.md) cuando completes tareas

---

## 📊 Estado Actual del Mod (2026-01-16)

| Componente | Estado | Archivo de Referencia |
|------------|--------|----------------------|
| **Crash Fix** | ✅ APLICADO | CRASH_FIX_PATCH.md |
| **Click Derecho** | ✅ CONFIRMADO | TESTING_GUIDE.md → Test 1 |
| **Sistema de Diálogos** | ⚠️ PENDIENTE | TODO.md → Tarea 1 |
| **Sistema de Comercio** | ⚠️ PENDIENTE | TODO.md → Tarea 2 |
| **Saludos Automáticos** | ⚠️ PENDIENTE | TODO.md → Tarea 3 |
| **Comportamientos AI** | ⚠️ PENDIENTE | TODO.md → Tarea 4 |
| **Performance** | ✅ ESTABLE | CRASH_FIX_PATCH.md |

---

## 🔗 Enlaces Rápidos

### Comandos de Admin
```bash
/spawn_villager <tipo>         # Spawnear aldeano (farmer, librarian, teacher, explorer)
/villager_info                 # Info del sistema
/villager_debug on             # Activar debug de AI
/villager_state                # Ver estados de aldeanos cercanos
/villager_config get <param>   # Ver configuración
```

### Archivos de Configuración
- `config.lua` - Configuración centralizada del mod
- `server/config/luanti.conf` - Configuración del servidor (custom_villagers_*)

### Recursos Externos
- [Luanti API Docs](https://api.luanti.org/)
- [VoxeLibre GitHub](https://github.com/VoxeLibre/VoxeLibre)
- [mcl_mobs Documentation](https://github.com/VoxeLibre/VoxeLibre/tree/master/mods/ENTITIES/mcl_mobs)

---

## 🆘 Ayuda Rápida

### ¿Click derecho crashea?
✅ **RESUELTO** (v1.0.1) - Ver [CRASH_FIX_PATCH.md](CRASH_FIX_PATCH.md)

### ¿Aldeanos no hablan?
⚠️ **TESTING PENDIENTE** - Ver [TODO.md](TODO.md) → Tarea 1
Seguir protocolo: [TESTING_GUIDE.md](TESTING_GUIDE.md) → Test 2

### ¿Comercio no funciona?
⚠️ **TESTING PENDIENTE** - Ver [TODO.md](TODO.md) → Tarea 2
Seguir protocolo: [TESTING_GUIDE.md](TESTING_GUIDE.md) → Test 3

### ¿Aldeanos no se mueven?
🔍 **Debug**: Ver [docs/AI_BEHAVIORS.md](docs/AI_BEHAVIORS.md)
Usar: `/villager_debug on` y `/villager_state`

### ¿Warnings en logs?
📝 **No crítico** - Ver [TODO.md](TODO.md) → Tarea 5 (hp_min/hp_max deprecated)

---

## 📝 Contribuir a la Documentación

Si encuentras errores o quieres mejorar la documentación:

1. Edita el archivo correspondiente
2. Actualiza este índice si es necesario
3. Commit con mensaje descriptivo
4. Push a GitHub

**Formato de commits**:
```
📝 Docs: [descripción breve]

- Cambio 1
- Cambio 2
```

---

## 🌟 Créditos

**Desarrollo Original**: Wetlands Team
**Crash Fix Patch**: Gabriel Pantoja + Claude Code
**Documentación**: Gabriel Pantoja + Claude Code
**Servidor**: Wetlands (luanti.gabrielpantoja.cl:30000)

---

**Última actualización**: 2026-01-16 20:36 ART
**Versión de este índice**: 1.0.0
