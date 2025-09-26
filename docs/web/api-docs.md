# 🔌 API Documentation

Documentación para futuras implementaciones de APIs del servidor Wetlands Valdivia.

## 🚧 Estado Actual

**En Desarrollo**: Las APIs están planificadas pero no implementadas aún.

## 🎯 APIs Planificadas

### 1. Server Status API
**Endpoint**: `/api/status`
**Método**: GET
**Propósito**: Estado en tiempo real del servidor

```json
{
  "online": true,
  "players": {
    "current": 3,
    "max": 20
  },
  "uptime": "2d 14h 32m",
  "version": "VoxeLibre 0.90.1",
  "last_update": "2025-09-21T15:30:00Z"
}
```

### 2. Player Statistics API
**Endpoint**: `/api/players/stats`
**Método**: GET
**Propósito**: Estadísticas generales de jugadores (sin información personal)

```json
{
  "total_players": 45,
  "active_today": 8,
  "average_session": "45m",
  "most_active_hour": "16:00-17:00"
}
```

### 3. World Information API
**Endpoint**: `/api/world/info`
**Método**: GET
**Propósito**: Información básica del mundo del servidor

```json
{
  "world_name": "Wetlands Valdivia",
  "seed": "compassion2025",
  "spawn_point": [0, 15, 0],
  "world_size": "2.1 GB",
  "created": "2025-08-01T00:00:00Z"
}
```

## 🛠️ Implementación Futura

### Tecnologías Propuestas
- **Framework**: FastAPI (Python) o Express.js (Node.js)
- **Base de Datos**: SQLite (reutilizar DB del servidor) + Redis (cache)
- **Autenticación**: API Keys para endpoints administrativos
- **Documentación**: OpenAPI/Swagger

### Arquitectura Propuesta
```
nginx → API Gateway → FastAPI/Express → SQLite/Redis
                   ↘ WebSocket → Real-time updates
```

### Consideraciones de Seguridad
- **Rate Limiting**: Máximo 100 requests/minuto por IP
- **CORS**: Configuración restrictiva para dominios autorizados
- **Authentication**: JWT tokens para endpoints sensibles
- **Validation**: Sanitización de todos los inputs

## 📊 Métricas a Exponer

### Públicas (Sin autenticación)
- Estado del servidor (online/offline)
- Número de jugadores conectados
- Uptime del servidor
- Versión del juego

### Administrativas (Requieren autenticación)
- Logs del servidor
- Estadísticas detalladas de jugadores
- Métricas de rendimiento
- Configuración del servidor

## 🎮 Integración con Luanti

### Posibles Integraciones
1. **Mod de Statistics**: Recopilar datos desde el juego
2. **Database Queries**: Acceso directo a auth.sqlite
3. **Log Parsing**: Análisis de logs en tiempo real
4. **Docker Stats**: Métricas del contenedor

### Ejemplo de Mod para Estadísticas
```lua
-- stats_api.lua
local http = minetest.request_http_api()

local function update_player_stats(player_name, action)
    if http then
        http.fetch({
            url = "http://localhost:8080/api/internal/player-action",
            method = "POST",
            data = minetest.write_json({
                player = player_name,
                action = action,
                timestamp = os.time()
            })
        }, function(result) end)
    end
end

minetest.register_on_joinplayer(function(player)
    update_player_stats(player:get_player_name(), "join")
end)
```

## 🔄 Roadmap de Desarrollo

### Fase 1: MVP (Q4 2025)
- API básica de estado del servidor
- Endpoint de estadísticas públicas
- Documentación con Swagger

### Fase 2: Características Avanzadas (Q1 2026)
- WebSocket para updates en tiempo real
- Dashboard web administrativo
- Integración con mods del servidor

### Fase 3: Características Premium (Q2 2026)
- API de gestión de jugadores
- Sistema de eventos y notificaciones
- Métricas avanzadas y analytics

## 📚 Referencias Técnicas

### APIs Similares de Referencias
- **Minecraft Server Status**: https://api.mcsrvstat.us/
- **Steam Web API**: Para estructura de respuestas
- **Discord API**: Para sistema de rate limiting

### Documentación Técnica
- Luanti Lua API: https://github.com/minetest/minetest/blob/master/doc/lua_api.md
- SQLite Python: https://docs.python.org/3/library/sqlite3.html
- FastAPI Documentation: https://fastapi.tiangolo.com/