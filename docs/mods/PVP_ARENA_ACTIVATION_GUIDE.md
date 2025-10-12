# 🚀 Guía de Activación: Mod PVP Arena

**Estado**: ✅ Mod completamente desarrollado y listo para deployment
**Fecha**: 2025-10-12
**Autor**: gabo (Gabriel Pantoja)

## 📦 Resumen del Desarrollo

Se ha creado un sistema completo de zonas PVP para Wetlands que:

- ✅ **Detecta automáticamente** entrada/salida de arenas
- ✅ **Activa PVP solo en zonas específicas** (resto del servidor pacífico)
- ✅ **Protección 3D completa** (incluye altura y profundidad)
- ✅ **Comandos intuitivos** para jugadores y admins
- ✅ **Sistema de mensajes coloridos** y claros
- ✅ **Arena pre-configurada** en coordenadas (41, 23, 232)

## 📂 Archivos Creados

```
server/mods/pvp_arena/
├── mod.conf                      # Metadatos del mod
├── init.lua                      # Lógica principal (242 líneas)
├── commands.lua                  # Comandos de chat (280 líneas)
├── README.md                     # Documentación completa
└── pvp_arenas.example.txt        # Archivo de configuración de ejemplo

scripts/
└── deploy-pvp-arena.sh           # Script automatizado de deployment

docs/mods/
├── PVP_ARENA_MOD.md              # Documentación técnica completa
└── PVP_ARENA_ACTIVATION_GUIDE.md # Esta guía
```

## 🏟️ Arena Pre-Configurada

**Arena Principal** - Basada en tu construcción existente:

- **Centro**: `(41, 23, 232)` - Coordenadas de la zona de piedra y antorchas
- **Radio horizontal**: 25 bloques
- **Área total**: 51x51 bloques
- **Altura**: ±50 bloques desde el centro (permite combate en altura y bajo tierra)
- **Estado inicial**: Activa por defecto

## 🎯 Paso a Paso: Activación del Mod

### PASO 1: Ejecutar Script de Deployment (Local)

```bash
cd /home/gabriel/Documentos/luanti-voxelibre-server
./scripts/deploy-pvp-arena.sh
```

Este script:
- ✅ Verifica que todos los archivos del mod existan
- ✅ Agrega `load_mod_pvp_arena = true` a `luanti.conf`
- ✅ Crea backup de configuración
- ⚠️ NO reinicia el servidor (para proteger jugadores conectados)

### PASO 2: Avisar a los Jugadores

Antes de reiniciar el servidor, avisa en el chat:

```
🏟️ En 5 minutos vamos a reiniciar el servidor para activar
un nuevo sistema de Arena PVP. ¡Prepárense!

La arena estará en las coordenadas (41, 23, 232)
```

### PASO 3: Reiniciar el Servidor

**Opción A - Localmente** (si estás trabajando en local):
```bash
docker-compose restart luanti-server
```

**Opción B - En el VPS** (producción):
```bash
ssh gabriel@<VPS_IP>
cd /home/gabriel/luanti-voxelibre-server
docker-compose restart luanti-server
```

### PASO 4: Verificar Carga del Mod

Revisa los logs para confirmar que el mod se cargó correctamente:

```bash
# Local
docker-compose logs luanti-server | grep "PVP Arena"

# VPS
ssh gabriel@<VPS_IP> "cd /home/gabriel/luanti-voxelibre-server && docker-compose logs luanti-server | grep 'PVP Arena'"
```

**Logs esperados**:
```
[PVP Arena] Mod loaded successfully with 1 arenas
[PVP Arena] Loaded arena: Arena Principal
[PVP Arena] Commands registered successfully
[PVP Arena] Mod initialization complete
```

### PASO 5: Otorgar Privilegios de Admin

Conéctate al servidor y ejecuta:

```lua
/grant gabo arena_admin
/grant pepelomo arena_admin
```

### PASO 6: Probar el Sistema

#### Prueba básica de jugador:

```lua
/arena_lista
# Debería mostrar: Arena Principal en (41, 23, 232)

/arena_donde
# Debería mostrar tu distancia a la arena

# Caminar hacia (41, 23, 232)
# Deberías ver el mensaje de entrada a la arena
```

#### Prueba de combate:

1. **Dos jugadores entran a la arena** (41, 23, 232)
   - Ambos ven el mensaje: `⚔️  ENTRASTE A ARENA PRINCIPAL  ⚔️`
   - PVP activado para ambos

2. **Intentan atacarse**
   - ✅ Dentro de arena: Daño permitido
   - ❌ Fuera de arena: Daño bloqueado con mensaje de error

3. **Un jugador sale de la arena**
   - Ve mensaje: `✅ Has salido de la Arena PVP`
   - PVP desactivado automáticamente

#### Prueba de comandos admin:

```lua
# Información de la arena
/arena_info

# Estadísticas
/arena_stats

# Teleportar a la arena
/arena_tp Arena_Principal

# Crear una arena nueva (opcional)
/crear_arena Arena_Prueba 20

# Desactivar temporalmente
/arena_toggle Arena_Principal
```

## 🎮 Comandos Disponibles

### Para Todos los Jugadores

| Comando | Descripción | Ejemplo |
|---------|-------------|---------|
| `/arena_lista` | Lista todas las arenas | `/arena_lista` |
| `/arena_info` | Info de arena actual | `/arena_info` |
| `/arena_donde` | Distancia a arena más cercana | `/arena_donde` |
| `/salir_arena` | Teleport al spawn | `/salir_arena` |

### Solo para Administradores (requiere `arena_admin`)

| Comando | Descripción | Ejemplo |
|---------|-------------|---------|
| `/crear_arena <nombre> <radio>` | Crea arena nueva | `/crear_arena Arena_Halloween 40` |
| `/eliminar_arena <nombre>` | Elimina arena | `/eliminar_arena Arena_Prueba` |
| `/arena_tp <nombre>` | Teleport a arena | `/arena_tp Arena_Principal` |
| `/arena_toggle <nombre>` | Activa/desactiva | `/arena_toggle Arena_Principal` |
| `/arena_stats` | Estadísticas de uso | `/arena_stats` |

## 🐛 Troubleshooting

### Problema: El mod no carga

**Síntomas**: No aparece en los logs

**Solución**:
```bash
# Verificar que está en luanti.conf
grep "load_mod_pvp_arena" server/config/luanti.conf

# Debería mostrar: load_mod_pvp_arena = true

# Verificar archivos del mod
ls -la server/mods/pvp_arena/

# Revisar logs de error
docker-compose logs luanti-server | grep -i error
```

### Problema: Comandos no funcionan

**Síntomas**: `/arena_lista` muestra "invalid command"

**Solución**:
```bash
# Verificar que commands.lua se cargó
docker-compose logs luanti-server | grep "Commands registered"

# Reintentar carga del mod
docker-compose restart luanti-server
```

### Problema: PVP no funciona en la arena

**Síntomas**: Los jugadores no pueden atacarse dentro de la arena

**Verificar**:
1. Que `enable_pvp = true` en `luanti.conf` (línea 34)
2. Que ambos jugadores están dentro de la arena: `/arena_info`
3. Revisar logs: `docker-compose logs luanti-server | grep "PVP Arena"`

**Solución**:
```lua
# Como admin, verificar estado
/arena_stats

# Ver si los jugadores están registrados en la arena
/lua minetest.chat_send_all(dump(pvp_arena.players_in_arena))
```

### Problema: Los jugadores se atacan fuera de la arena

**Síntomas**: PVP funciona en todo el servidor

**Causa probable**: El mod no se cargó correctamente

**Solución**:
```bash
# Verificar carga del mod
docker-compose logs luanti-server | grep "PVP Arena"

# Debe mostrar: "Mod loaded successfully with 1 arenas"

# Si no aparece, revisar sintaxis Lua
docker-compose exec luanti-server luac -p /config/.minetest/mods/pvp_arena/init.lua
docker-compose exec luanti-server luac -p /config/.minetest/mods/pvp_arena/commands.lua
```

## 📊 Monitoreo Post-Activación

### Verificar Estado del Servidor

```bash
# Estado general
docker-compose ps

# Logs en tiempo real
docker-compose logs -f luanti-server

# Filtrar logs del mod
docker-compose logs luanti-server | grep "PVP Arena"
```

### Verificar Uso de la Arena

Como admin en el juego:

```lua
# Ver estadísticas
/arena_stats

# Ver jugadores en arenas
/lua for name, arena in pairs(pvp_arena.players_in_arena) do
    minetest.chat_send_all(name .. " está en " .. arena)
end
```

## 🎉 Después de la Activación

1. **Anunciar en el chat**:
   ```
   🏟️ ¡Sistema de Arena PVP activado!

   📍 Arena Principal: (41, 23, 232)
   ⚔️ Solo pueden atacarse dentro de la arena
   🌱 Fuera de la arena todo es pacífico

   Comandos útiles:
   /arena_lista - Ver arenas
   /arena_donde - Ver distancia
   /salir_arena - Salir rápido
   ```

2. **Guiar a los jugadores**:
   - Llevarlos a la arena: `/arena_tp Arena_Principal`
   - Mostrarles los límites de la zona
   - Explicar que pueden salir en cualquier momento

3. **Crear eventos**:
   - Torneos 1v1 los fines de semana
   - Combates por equipos
   - Eventos especiales con premios

## 📝 Notas Importantes

- ⚠️ **No elimines archivos del mod mientras el servidor esté corriendo**
- ⚠️ **Haz backup antes de modificar `pvp_arenas.txt`**
- ⚠️ **El archivo `pvp_arenas.txt` se crea automáticamente en el primer inicio**
- ✅ **El mod es 100% compatible con modo creativo**
- ✅ **Las arenas funcionan en 3D completo** (altura y profundidad)
- ✅ **El sistema se limpia automáticamente al desconectar jugadores**

## 🔄 Desactivación Temporal (Si Necesario)

Si necesitas desactivar el mod temporalmente:

```bash
# Editar luanti.conf
# Cambiar: load_mod_pvp_arena = true
# Por:     load_mod_pvp_arena = false

# Reiniciar servidor
docker-compose restart luanti-server
```

## 📞 Soporte

Para problemas o dudas:

1. Revisar esta guía completa
2. Consultar `server/mods/pvp_arena/README.md`
3. Revisar `docs/mods/PVP_ARENA_MOD.md`
4. Revisar logs: `docker-compose logs luanti-server`

---

**Última actualización**: 2025-10-12
**Autor**: gabo (Gabriel Pantoja)
**Estado**: ✅ Listo para producción
