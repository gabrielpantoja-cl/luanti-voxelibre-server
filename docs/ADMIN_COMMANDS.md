# Comandos de Administración - Vegan Wetlands

## 🚀 Comandos de Teletransporte

### Traer Jugador a tu Posición
```
/teleport <nombre_jugador> <tu_nombre>
```
**Ejemplo**: `/teleport Juan gabriel_admin`

**Nota**: También funciona la forma corta:
```
/tp <nombre_jugador> <tu_nombre>
```

### Teletransportar Jugador a Otro Jugador
```
/teleport <jugador1> <jugador2>
```

### Ir a la Posición de un Jugador
```
/teleport <tu_nombre> <nombre_jugador>
```

## 🔧 Comandos de Gestión de Usuarios

### Ver Privilegios de un Jugador
```
/privs <nombre_jugador>
```

### Otorgar Privilegios
```
/grant <nombre_jugador> <privilegio>
```

### Revocar Privilegios
```
/revoke <nombre_jugador> <privilegio>
```

### Expulsar Jugador
```
/kick <nombre_jugador> [razón]
```

### Banear Jugador
```
/ban <nombre_jugador>
```

### Desbanear Jugador
```
/unban <nombre_jugador>
```

## 🛠️ Comandos de Servidor

### Ver Estado del Servidor
```
/status
```

### Establecer Hora del Día
```
/set time <hora>
```
**Valores**: 0-24000 (0=amanecer, 6000=mediodía, 12000=atardecer, 18000=noche)

### Dar Items a Jugador
```
/give <nombre_jugador> <item> [cantidad]
```
**Ejemplo**: `/give Juan mcl_core:dirt 64`

### Cambiar Modo de Juego
```
/grantme creative
```
```
/revoke <jugador> creative
```

## 📊 Comandos de Información

### Ver Lista de Jugadores Conectados
```
/status
```

### Ver Posición Actual
```
/whereami
```

### Ver Información del Mundo
```
/last-login <nombre_jugador>
```

## 🏠 Comandos de Spawn y Hogar

### Teletransporte a Spawn Personal
```
/back_to_spawn
```

### Establecer Spawn de Jugador (requiere cama)
Los jugadores deben dormir en una cama para establecer su spawn personal.

## 🎮 Comandos Específicos del Servidor

### Información del Santuario
```
/santuario
```

### Filosofía del Servidor
```
/filosofia
```

### Sentarse
```
/sit
```

### Acostarse
```
/lay
```

## 🔍 Comandos de Depuración (Admin)

### Encontrar y Teletransportarse a Bioma
```
/findbiome <nombre_bioma>
```
**Requiere**: privilegios `debug` y `teleport`

### Rollback (Revertir Cambios)
```
/rollback_check <posición> <radio> <tiempo>
```

## 📋 Privilegios Importantes

### Privilegios de Administrador
- `server` - Acceso a comandos de servidor
- `privs` - Gestionar privilegios de otros jugadores
- `teleport` - Comandos de teletransporte
- `ban` - Banear/desbanear jugadores
- `kick` - Expulsar jugadores
- `give` - Dar items a jugadores
- `worldedit` - Edición de mundo
- `debug` - Comandos de depuración
- `rollback_check` - Revisar y revertir cambios

### Privilegios de Jugador Estándar
- `interact` - Interactuar con el mundo
- `shout` - Hablar en el chat
- `home` - Comandos de hogar
- `spawn` - Acceso a spawn
- `creative` - Modo creativo

## ⚠️ Notas Importantes

1. **Nombres de usuario**: Usar nombres exactos, sensibles a mayúsculas
2. **Privilegios necesarios**: Algunos comandos requieren privilegios específicos
3. **Base de datos**: Los privilegios se almacenan en SQLite (`auth.sqlite`)
4. **Reinicio**: Algunos cambios pueden requerir reinicio del servidor

## 🔗 Comandos de Conexión Rápida

Para consultar usuarios registrados:
```bash
# Desde VPS
docker-compose exec -T luanti-server sqlite3 /config/.minetest/worlds/world/auth.sqlite 'SELECT name FROM auth;'
```

Para otorgar privilegios admin desde base de datos (emergencia):
```bash
# Ver ID del usuario
sqlite3 auth.sqlite "SELECT id FROM auth WHERE name='username';"

# Otorgar todos los privilegios admin
sqlite3 auth.sqlite "INSERT OR IGNORE INTO user_privileges (id, privilege) VALUES 
(1, 'server'), (1, 'privs'), (1, 'teleport'), (1, 'ban'), (1, 'give');"
```