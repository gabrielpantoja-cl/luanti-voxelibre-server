# ⚡ Activar PVP Arena - Guía Rápida

**Estado actual**: ✅ Mod desarrollado y commiteado (local)
**Servidor**: ⚠️ Corriendo con jugadores - NO modificar hasta tu orden

---

## 🚀 Cuando Estés Listo (5 Pasos Rápidos)

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
ssh gabriel@<VPS_IP> "cd /home/gabriel/luanti-voxelibre-server && docker-compose restart luanti-server"
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

## ✅ Probar Sistema

### Como jugador normal:

```lua
/arena_lista          # Ver arenas disponibles
/arena_donde          # Ver distancia a arena
```

Caminar a **(41, 23, 232)** → Deberías ver:

```
╔═══════════════════════════════════╗
║  ⚔️  ENTRASTE A ARENA PRINCIPAL ⚔️ ║
║  • El combate está habilitado     ║
║  • Sal cuando quieras para paz    ║
╚═══════════════════════════════════╝
```

### Como admin:

```lua
/arena_stats          # Ver estadísticas
/arena_info           # Info de la arena
/arena_tp Arena_Principal  # Teleport a la arena
```

---

## 📍 Arena Configurada

- **Nombre**: Arena Principal
- **Centro**: (41, 23, 232)
- **Radio**: 25 bloques (51x51)
- **Altura**: ±50 bloques
- **Estado**: Activa por defecto

---

## 🎮 Comandos Principales

### Jugadores:
- `/arena_lista` - Ver arenas
- `/arena_donde` - Ver distancia
- `/salir_arena` - Salir al spawn

### Admin (requiere `arena_admin`):
- `/crear_arena <nombre> <radio>` - Crear arena
- `/arena_tp <nombre>` - Teleport
- `/arena_stats` - Estadísticas

---

## 🐛 Si Algo Sale Mal

### Mod no carga:
```bash
# Verificar configuración
grep "load_mod_pvp_arena" server/config/luanti.conf

# Revisar errores
docker-compose logs luanti-server | grep -i error
```

### Comandos no funcionan:
```bash
# Reiniciar servidor
docker-compose restart luanti-server

# Verificar logs
docker-compose logs luanti-server | grep "Commands registered"
```

### PVP no funciona:
```lua
# Verificar que ambos jugadores están en arena
/arena_info

# Ver jugadores registrados (admin)
/arena_stats
```

---

## 📖 Documentación Completa

- **Guía de activación**: `docs/mods/PVP_ARENA_ACTIVATION_GUIDE.md`
- **Documentación técnica**: `docs/mods/PVP_ARENA_MOD.md`
- **README del mod**: `server/mods/pvp_arena/README.md`

---

## 🔄 Rollback (Si Necesario)

Para desactivar el mod temporalmente:

```bash
# Editar luanti.conf
nano server/config/luanti.conf

# Cambiar: load_mod_pvp_arena = true
# Por:     load_mod_pvp_arena = false

# Reiniciar
docker-compose restart luanti-server
```

---

**Última actualización**: 2025-10-12
**Commit**: `702fd0f` - "feat: Implementar sistema completo de zonas PVP"
