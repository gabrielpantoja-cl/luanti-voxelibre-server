# 🔧 REINICIAR SERVIDOR PARA ACTIVAR PVP EN ARENAS

**Estado**: ✅ Fix aplicado - Solo falta reiniciar
**Fecha**: 2025-10-12
**Problema resuelto**: creative_mode global bloqueaba PVP

---

## 📋 Cambios Aplicados

### 1. Configuración del Servidor (`luanti.conf`)
- ✅ `creative_mode = false` (era `true`)
- ✅ `mcl_enable_creative_mode = false` (era `true`)
- ✅ `enable_damage = true` (ya estaba)
- ✅ `enable_pvp = true` (ya estaba)

### 2. Mod PVP Arena v1.1.0 (`pvp_arena/init.lua`)
- ✅ Manejo automático de privilegio `creative`
- ✅ Al entrar a arena: Remueve `creative` temporalmente
- ✅ Al salir de arena: Restaura `creative` si lo tenía
- ✅ Invulnerabilidad fuera de arenas (`fleshy = 0`)
- ✅ Vulnerabilidad dentro de arenas (`fleshy = 100`)

---

## 🚀 Cómo Reiniciar (Cuando Terminen de Jugar)

### Opción A: Desde VPS (Recomendado)

```bash
# 1. Conectar al VPS
ssh gabriel@<VPS_IP>

# 2. Ir al directorio del servidor
cd /home/gabriel/luanti-voxelibre-server

# 3. Reiniciar el servidor
docker-compose restart luanti-server

# 4. Verificar que levantó correctamente
docker-compose logs luanti-server --tail=50
```

### Opción B: Desde Local

```bash
# Reiniciar servidor remoto desde local
ssh gabriel@<VPS_IP> "cd /home/gabriel/luanti-voxelibre-server && docker-compose restart luanti-server"

# Ver logs
ssh gabriel@<VPS_IP> "cd /home/gabriel/luanti-voxelibre-server && docker-compose logs luanti-server --tail=50"
```

---

## ✅ Verificación Post-Reinicio

### 1. Verificar logs del mod PVP Arena

```bash
ssh gabriel@<VPS_IP> "cd /home/gabriel/luanti-voxelibre-server && docker-compose logs luanti-server | grep 'PVP Arena'"
```

**Logs esperados:**
```
[PVP Arena] Mod loaded successfully with 1 arenas
[PVP Arena] Loaded arena: Arena Principal
[PVP Arena] Commands registered successfully
```

### 2. Verificar en el juego

**Como jugador normal:**
```lua
/arena_lista
# Debería mostrar: Arena Principal en (41, 23, 232)

# Ir a la arena (41, 23, 232)
# Deberías ver el mensaje de entrada
```

**Probar combate:**
1. Ambos jugadores entran a la arena
2. Deberían ver: `⚔️ ENTRASTE A ARENA PRINCIPAL ⚔️`
3. Intentar atacarse → **Ahora debería funcionar el daño**
4. Salir de la arena → Ver mensaje `✅ Has salido de la Arena PVP`
5. Fuera de arena → Ya no se pueden atacar (mundo pacífico)

---

## 🎮 Funcionamiento del Sistema

### Dentro de la Arena (41, 23, 232)
- ✅ PVP habilitado
- ✅ Daño entre jugadores permitido
- ✅ Privilegio `creative` removido temporalmente
- ⚔️ Pueden atacarse y hacerse daño

### Fuera de la Arena
- ✅ PVP deshabilitado
- ✅ Daño entre jugadores bloqueado
- ✅ Privilegio `creative` restaurado automáticamente
- 🌱 Mundo completamente pacífico

### Manejo de Privilegio Creative
El sistema **maneja automáticamente** el privilegio creative:

| Acción | Privilegio Creative | Vulnerable al Daño |
|--------|-------------------|-------------------|
| Entrar a arena | Se remueve automáticamente | ✅ Sí |
| Salir de arena | Se restaura automáticamente | ❌ No (invulnerable) |
| Desconexión en arena | Se restaura antes de salir | N/A |

**Importante**: Los jugadores conservan todos los otros privilegios (`fly`, `fast`, `noclip`, etc.)

---

## 🐛 Troubleshooting

### Problema: Todavía no hay daño en la arena

**Verificar:**
```bash
# 1. Confirmar que creative_mode está en false
ssh gabriel@<VPS_IP> "cd /home/gabriel/luanti-voxelibre-server && grep '^creative_mode' server/config/luanti.conf"
# Debe mostrar: creative_mode = false

# 2. Verificar logs de entrada a arena
ssh gabriel@<VPS_IP> "cd /home/gabriel/luanti-voxelibre-server && docker-compose logs luanti-server | grep 'Removed creative'"
# Debe mostrar: [PVP Arena] Removed creative from [nombre] (arena entry)
```

**Si sigue sin funcionar:**
```lua
# En el juego, como admin:
/lua minetest.settings:get("creative_mode")
# Debe devolver: false

# Verificar que estás en la arena
/arena_info
```

### Problema: No se restaura creative al salir

**Verificar logs:**
```bash
ssh gabriel@<VPS_IP> "cd /home/gabriel/luanti-voxelibre-server && docker-compose logs luanti-server | grep 'Restored creative'"
```

**Restaurar manualmente si es necesario:**
```lua
/grant gabo creative
/grant pepelomo creative
```

### Problema: Mensajes de arena no aparecen

**Verificar que el mod cargó:**
```bash
ssh gabriel@<VPS_IP> "cd /home/gabriel/luanti-voxelibre-server && docker-compose logs luanti-server | grep 'PVP Arena.*loaded'"
```

---

## 📊 Resumen de Cambios Técnicos

### Antes (No funcionaba)
- `creative_mode = true` → Todos invulnerables
- Privilegio `creative` → Inmortales
- `armor_groups.fleshy` no respetado

### Después (Funciona)
- `creative_mode = false` → Daño habilitado
- Privilegio `creative` removido en arenas
- `armor_groups.fleshy = 100` en arenas (vulnerable)
- `armor_groups.fleshy = 0` fuera (invulnerable)

---

## 🎯 Próximos Pasos Opcionales

### Restaurar privilegios creative manualmente

Si prefieres que los jugadores tengan creative todo el tiempo (incluso en arenas):

```lua
# Como admin en el juego:
/grant gabo creative
/grant pepelomo creative
```

**Nota**: El mod los removerá automáticamente al entrar a arena y los restaurará al salir.

### Crear más arenas

```lua
# Como admin con privilegio arena_admin:
/crear_arena Arena_Norte 30
# Crea una arena de 30 bloques de radio en tu posición actual

/arena_lista
# Ver todas las arenas disponibles
```

---

## 📝 Backup Realizado

Se creó un backup de `luanti.conf` antes de los cambios:
```
server/config/luanti.conf.backup_[timestamp]
```

**Para revertir si es necesario:**
```bash
ssh gabriel@<VPS_IP> "cd /home/gabriel/luanti-voxelibre-server && cp server/config/luanti.conf.backup_* server/config/luanti.conf && docker-compose restart luanti-server"
```

---

## 🎉 Después del Reinicio

Una vez reiniciado, el sistema debería funcionar así:

1. **Jugadores se mueven por el mundo** → Pacífico, no hay daño
2. **Entran a Arena Principal (41, 23, 232)** → PVP activado, pueden pelear
3. **Salen de la arena** → Vuelven a modo pacífico automáticamente

**¡Listo para jugar PVP en las arenas!** ⚔️🌱

---

**Última actualización**: 2025-10-12 13:00
**Versión del mod**: PVP Arena v1.1.0
**Estado**: ✅ Listo para reiniciar
