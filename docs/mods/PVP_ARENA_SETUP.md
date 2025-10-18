# 🏟️ Sistema de Arenas PVP - Guía Completa de Configuración y Uso

**Estado**: ✅ Sistema implementado y funcional
**Versión del mod**: PVP Arena v1.1.0
**Última actualización**: 2025-10-12

---

## 📋 Índice

1. [Descripción General](#descripción-general)
2. [Activación Rápida (5 Pasos)](#activación-rápida-5-pasos)
3. [Configuración del Servidor](#configuración-del-servidor)
4. [Funcionamiento del Sistema](#funcionamiento-del-sistema)
5. [Comandos Disponibles](#comandos-disponibles)
6. [Arena Configurada](#arena-configurada)
7. [Verificación y Testing](#verificación-y-testing)
8. [Troubleshooting](#troubleshooting)
9. [Rollback y Desactivación](#rollback-y-desactivación)

---

## 📖 Descripción General

El sistema de Arenas PVP permite crear zonas específicas donde los jugadores pueden combatir entre sí, mientras mantienen el resto del mundo completamente pacífico. El sistema gestiona automáticamente los privilegios y la vulnerabilidad de los jugadores.

### Características Principales

- ✅ **Zonas PVP delimitadas**: Combate solo dentro de arenas específicas
- ✅ **Gestión automática de privilegios**: Remueve/restaura `creative` automáticamente
- ✅ **Mundo pacífico**: Fuera de arenas, los jugadores son invulnerables
- ✅ **Múltiples arenas**: Soporta varias arenas configurables
- ✅ **Sistema de privilegios**: Control de admin con `arena_admin`
- ✅ **Mensajes visuales**: Notificaciones claras al entrar/salir de arenas

---

## 🚀 Activación Rápida (5 Pasos)

**Estado actual**: ✅ Mod desarrollado y commiteado
**Servidor**: ⚠️ Requiere reinicio para aplicar cambios

### 1️⃣ Preparar Configuración (Local)

```bash
cd /home/gabriel/Documentos/luanti-voxelibre-server
./scripts/deploy-pvp-arena.sh
```

Este script agrega `load_mod_pvp_arena = true` a `luanti.conf` sin reiniciar.

---

### 2️⃣ Avisar a los Jugadores (En el juego)

```
🏟️ En 5 minutos vamos a reiniciar el servidor
para activar el nuevo sistema de Arena PVP.

Arena Principal: (41, 23, 232)
¡Nos vemos pronto!
```

---

### 3️⃣ Reiniciar Servidor (Después de 5 min)

```bash
# Opción A: Local
docker-compose restart luanti-server

# Opción B: VPS (producción)
ssh gabriel@167.172.251.27 "cd /home/gabriel/luanti-voxelibre-server && docker-compose restart luanti-server"
```

---

### 4️⃣ Verificar Carga del Mod

```bash
# Ver logs del mod
docker-compose logs luanti-server | grep "PVP Arena"

# Logs esperados:
# [PVP Arena] Mod loaded successfully with 1 arenas
# [PVP Arena] Loaded arena: Arena Principal
# [PVP Arena] Commands registered successfully
```

---

### 5️⃣ Configurar Privilegios (En el juego)

```lua
/grant gabo arena_admin
/grant pepelomo arena_admin
```

---

## ⚙️ Configuración del Servidor

### Cambios en `luanti.conf`

Para que el sistema funcione correctamente, la configuración debe ser:

```ini
# Configuración PVP Arena (Aplicada)
creative_mode = false              # ✅ Deshabilitado globalmente
mcl_enable_creative_mode = false   # ✅ VoxeLibre creative mode off
enable_damage = true               # ✅ Daño habilitado
enable_pvp = true                  # ✅ PVP habilitado

# Cargar mod PVP Arena
load_mod_pvp_arena = true
```

### Cambios Aplicados vs Antes

| Configuración | Antes (No funcionaba) | Después (Funciona) |
|---------------|----------------------|-------------------|
| `creative_mode` | `true` (todos invulnerables) | `false` (daño habilitado) |
| `mcl_enable_creative_mode` | `true` | `false` |
| Privilegio `creative` | Siempre activo | Se remueve en arenas |
| `armor_groups.fleshy` | No respetado | `100` (vulnerable) en arenas |

**⚠️ Importante**: Se creó backup automático en `server/config/luanti.conf.backup_[timestamp]`

---

## 🎮 Funcionamiento del Sistema

### Dentro de la Arena (41, 23, 232)

- ✅ PVP habilitado
- ✅ Daño entre jugadores permitido
- ✅ Privilegio `creative` removido temporalmente
- ⚔️ Pueden atacarse y hacerse daño

**Mensaje de entrada:**
```
╔═══════════════════════════════════╗
║  ⚔️  ENTRASTE A ARENA PRINCIPAL ⚔️ ║
║  • El combate está habilitado     ║
║  • Sal cuando quieras para paz    ║
╚═══════════════════════════════════╝
```

### Fuera de la Arena

- ✅ PVP deshabilitado
- ✅ Daño entre jugadores bloqueado
- ✅ Privilegio `creative` restaurado automáticamente
- 🌱 Mundo completamente pacífico

**Mensaje de salida:**
```
✅ Has salido de la Arena PVP
```

### Manejo Automático de Privilegio Creative

El sistema gestiona el privilegio `creative` de forma transparente:

| Acción | Privilegio Creative | Vulnerable al Daño |
|--------|-------------------|-------------------|
| Entrar a arena | Se remueve automáticamente | ✅ Sí |
| Salir de arena | Se restaura automáticamente | ❌ No (invulnerable) |
| Desconexión en arena | Se restaura antes de salir | N/A |

**Nota**: Los jugadores conservan todos los otros privilegios (`fly`, `fast`, `noclip`, etc.)

---

## 🎮 Comandos Disponibles

### Comandos para Jugadores

| Comando | Descripción |
|---------|-------------|
| `/arena_lista` | Ver todas las arenas disponibles |
| `/arena_donde` | Ver distancia a la arena más cercana |
| `/salir_arena` | Teleportarse al spawn (salida de emergencia) |

**Ejemplo de uso:**
```lua
/arena_lista
# Salida: Arena Principal en (41, 23, 232) - Radio: 25 bloques

/arena_donde
# Salida: Estás a 145 bloques de Arena Principal
```

### Comandos para Administradores (requiere `arena_admin`)

| Comando | Sintaxis | Descripción |
|---------|----------|-------------|
| `/crear_arena` | `/crear_arena <nombre> <radio>` | Crear nueva arena en posición actual |
| `/arena_tp` | `/arena_tp <nombre>` | Teleportarse a una arena específica |
| `/arena_stats` | `/arena_stats` | Ver estadísticas de uso |
| `/arena_info` | `/arena_info` | Información detallada de la arena |

**Ejemplos:**
```lua
# Crear nueva arena
/crear_arena Arena_Norte 30
# Crea una arena de 30 bloques de radio en tu posición actual

# Teleportarse
/arena_tp Arena_Principal

# Ver estadísticas
/arena_stats
# Muestra: jugadores actuales, total de entradas, última actividad
```

---

## 📍 Arena Configurada

### Arena Principal

- **Nombre**: Arena Principal
- **Centro**: `(41, 23, 232)`
- **Radio**: 25 bloques (área de 51x51)
- **Altura**: ±50 bloques
- **Estado**: Activa por defecto
- **Tipo**: PVP con respawn automático

### Cómo Llegar

1. Usa el comando `/arena_donde` para ver tu distancia
2. Dirígete a las coordenadas `(41, 23, 232)`
3. Al entrar, verás el mensaje de bienvenida
4. El sistema removerá temporalmente tu privilegio `creative`

---

## ✅ Verificación y Testing

### Post-Reinicio: Verificar Logs

```bash
# Conectar al VPS
ssh gabriel@167.172.251.27

# Verificar logs del mod
cd /home/gabriel/luanti-voxelibre-server
docker-compose logs luanti-server | grep "PVP Arena"
```

**Logs esperados:**
```
[PVP Arena] Mod loaded successfully with 1 arenas
[PVP Arena] Loaded arena: Arena Principal
[PVP Arena] Commands registered successfully
```

### En el Juego: Probar Funcionalidad

#### Como Jugador Normal

1. **Ver arenas disponibles:**
   ```lua
   /arena_lista
   ```

2. **Caminar a (41, 23, 232)**
   Deberías ver el mensaje de entrada a la arena

3. **Intentar combate con otro jugador**
   El daño debe funcionar dentro de la arena

4. **Salir caminando**
   Deberías ver el mensaje de salida y recuperar invulnerabilidad

#### Como Admin

1. **Ver estadísticas:**
   ```lua
   /arena_stats
   ```

2. **Verificar información:**
   ```lua
   /arena_info
   ```

3. **Teleportarse:**
   ```lua
   /arena_tp Arena_Principal
   ```

### Prueba Completa de Combate

**Pasos para dos jugadores:**

1. Ambos jugadores entran a la arena (41, 23, 232)
2. Deberían ver: `⚔️ ENTRASTE A ARENA PRINCIPAL ⚔️`
3. Intentar atacarse → **El daño debe funcionar**
4. Salir de la arena → Ver mensaje `✅ Has salido de la Arena PVP`
5. Fuera de arena → Ya no se pueden atacar (mundo pacífico)

---

## 🐛 Troubleshooting

### Problema 1: Mod No Carga

**Síntomas**: No aparecen comandos, no hay mensajes de arena

**Solución:**
```bash
# Verificar configuración
grep "load_mod_pvp_arena" server/config/luanti.conf
# Debe mostrar: load_mod_pvp_arena = true

# Revisar errores
docker-compose logs luanti-server | grep -i error

# Reiniciar servidor
docker-compose restart luanti-server
```

---

### Problema 2: Comandos No Funcionan

**Síntomas**: Comandos `/arena_*` no se reconocen

**Solución:**
```bash
# Verificar logs de registro de comandos
docker-compose logs luanti-server | grep "Commands registered"

# Reiniciar servidor
docker-compose restart luanti-server

# Verificar en juego
/help arena
```

---

### Problema 3: PVP No Funciona (No Hay Daño)

**Síntomas**: Jugadores no pueden dañarse en la arena

**Verificación:**
```bash
# 1. Confirmar creative_mode en false
ssh gabriel@167.172.251.27 "cd /home/gabriel/luanti-voxelibre-server && grep '^creative_mode' server/config/luanti.conf"
# Debe mostrar: creative_mode = false

# 2. Verificar logs de entrada a arena
docker-compose logs luanti-server | grep "Removed creative"
# Debe mostrar: [PVP Arena] Removed creative from [nombre] (arena entry)
```

**Verificar en juego:**
```lua
# Como admin, verificar configuración
/lua minetest.settings:get("creative_mode")
# Debe devolver: false

# Verificar que estás en la arena
/arena_info
```

**Solución si persiste:**
- Asegúrate de que ambos jugadores estén dentro del radio de la arena
- Verifica que el mod cargó correctamente (ver logs)
- Confirma que `enable_pvp = true` en `luanti.conf`

---

### Problema 4: No Se Restaura Creative al Salir

**Síntomas**: Jugadores no recuperan privilegio `creative` al salir

**Verificar logs:**
```bash
docker-compose logs luanti-server | grep "Restored creative"
```

**Restaurar manualmente:**
```lua
/grant gabo creative
/grant pepelomo creative
```

---

### Problema 5: Mensajes de Arena No Aparecen

**Síntomas**: No se muestran mensajes al entrar/salir

**Verificar:**
```bash
# Confirmar que el mod cargó
docker-compose logs luanti-server | grep "PVP Arena.*loaded"

# Verificar área de arena
/arena_info
```

**Causas posibles:**
- El jugador está fuera del radio de la arena
- El mod no cargó correctamente
- Problema con coordenadas de la arena

---

## 🔄 Rollback y Desactivación

### Desactivar Mod Temporalmente

Si necesitas desactivar el sistema PVP sin eliminar el mod:

```bash
# Opción A: Editar configuración
nano server/config/luanti.conf

# Cambiar:
load_mod_pvp_arena = true
# Por:
load_mod_pvp_arena = false

# Reiniciar
docker-compose restart luanti-server
```

```bash
# Opción B: Usar script de desactivación
./scripts/disable-pvp-arena.sh
```

---

### Revertir Configuración Completa

Si algo sale mal, puedes revertir todos los cambios:

```bash
# 1. Restaurar backup de luanti.conf
ssh gabriel@167.172.251.27 "cd /home/gabriel/luanti-voxelibre-server && cp server/config/luanti.conf.backup_* server/config/luanti.conf"

# 2. Reiniciar servidor
ssh gabriel@167.172.251.27 "cd /home/gabriel/luanti-voxelibre-server && docker-compose restart luanti-server"

# 3. Verificar estado
ssh gabriel@167.172.251.27 "cd /home/gabriel/luanti-voxelibre-server && docker-compose logs luanti-server --tail=50"
```

**Backup disponible en:**
```
server/config/luanti.conf.backup_[timestamp]
```

---

### Eliminar Mod Completamente

Si necesitas eliminar el mod por completo:

```bash
# 1. Desactivar en configuración
sed -i 's/load_mod_pvp_arena = true/load_mod_pvp_arena = false/' server/config/luanti.conf

# 2. Opcional: Eliminar directorio del mod
rm -rf server/mods/pvp_arena

# 3. Reiniciar servidor
docker-compose restart luanti-server
```

---

## 🎯 Próximos Pasos Opcionales

### Crear Más Arenas

```lua
# Como admin con privilegio arena_admin:
/crear_arena Arena_Norte 30
# Crea una arena de 30 bloques de radio en tu posición actual

/crear_arena Arena_Sur 40
# Crea una arena más grande

/arena_lista
# Ver todas las arenas disponibles
```

### Restaurar Privilegios Creative Manualmente

Si prefieres que los jugadores tengan creative todo el tiempo:

```lua
# Como admin en el juego:
/grant gabo creative
/grant pepelomo creative
```

**Nota**: El mod los removerá automáticamente al entrar a arena y los restaurará al salir.

---

## 📖 Documentación Adicional

- **Documentación técnica del mod**: `docs/mods/PVP_ARENA_MOD.md`
- **README del mod**: `server/mods/pvp_arena/README.md`
- **Guía de desarrollo de mods**: `docs/mods/MOD_DEVELOPMENT.md`

---

## 📊 Resumen Técnico

### Arquitectura del Sistema

```
┌─────────────────────────────────────┐
│  Mundo Pacífico (creative_mode=false)│
│  ┌───────────────────────────┐      │
│  │  Arena PVP (41,23,232)    │      │
│  │  ┌─────────────────────┐  │      │
│  │  │ PVP Habilitado      │  │      │
│  │  │ creative removido   │  │      │
│  │  │ fleshy = 100        │  │      │
│  │  └─────────────────────┘  │      │
│  └───────────────────────────┘      │
│  Fuera: fleshy = 0 (invulnerable)   │
└─────────────────────────────────────┘
```

### Gestión de Estado

| Evento | Acción del Sistema |
|--------|-------------------|
| Jugador entra a arena | Remover `creative`, setear `fleshy=100`, mostrar mensaje |
| Jugador sale de arena | Restaurar `creative`, setear `fleshy=0`, mostrar mensaje |
| Jugador se desconecta en arena | Restaurar `creative` antes de logout |
| Servidor reinicia | Cargar arenas desde configuración persistente |

---

## 🎉 Después del Reinicio

Una vez reiniciado correctamente, el sistema funciona así:

1. **Jugadores se mueven por el mundo** → Pacífico, sin daño
2. **Entran a Arena Principal (41, 23, 232)** → PVP activado, pueden pelear
3. **Salen de la arena** → Vuelven a modo pacífico automáticamente

**¡Sistema PVP en Arenas Listo!** ⚔️🌱

---

**Última actualización**: 2025-10-18
**Versión del mod**: PVP Arena v1.1.0
**Estado**: ✅ Listo para producción
**Commit**: `702fd0f` - "feat: Implementar sistema completo de zonas PVP"