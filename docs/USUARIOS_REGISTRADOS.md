# Usuarios Registrados - Servidor Vegan Wetlands

## Estado Actual (12-09-2025)

### Usuarios Activos
Total de usuarios registrados: **4 usuarios**

| Usuario | Identificación | Rol | Notas |
|---------|----------------|-----|-------|
| `gabo` | Admin Principal | Administrador | Usuario principal del servidor |
| `pepelomo` | Luciano | Jugador | Usuario registrado |
| `veight` | Karu | Jugador | Usuario registrado |
| `gaelsin` | Gael (Sobrino) | Jugador | Sobrino del administrador |

### Historial de Limpieza

**Fecha**: 05 de septiembre de 2025  
**Acción**: Limpieza masiva de usuarios de prueba

**Usuarios eliminados (13 usuarios de prueba)**:
- `creative`
- `creative11`
- `gabo111`
- `gabo2121`
- `gabo2121654`
- `gabo2121iuh`
- `gabo32`
- `gabo44`
- `gabo5`
- `gabo55`
- `gabo61`
- `gabox`
- `pepelomo2`

### Información Técnica

**Base de datos**: SQLite (`server/worlds/world/auth.sqlite`)  
**Ubicación en contenedor**: `/config/.minetest/worlds/world/auth.sqlite`  
**Método de consulta**:
```bash
docker-compose exec -T luanti-server sqlite3 /config/.minetest/worlds/world/auth.sqlite 'SELECT name FROM auth;'
```

### Privilegios Administrativos

**Usuario con privilegios de admin**: `gabo`  
Para otorgar privilegios administrativos a otros usuarios, consultar la sección "Admin Privilege Management" en `CLAUDE.md`.

---
*Última actualización: 12 de septiembre de 2025*  
*Servidor: luanti.gabrielpantoja.cl:30000*