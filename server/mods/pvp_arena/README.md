# 🏟️ PVP Arena - Zonas de Combate para Wetlands

**Versión**: 1.0.0
**Autor**: gabo (Gabriel Pantoja)
**Servidor**: Wetlands 🌱 Luanti/VoxeLibre
**Licencia**: MIT

## 📖 Descripción

Mod que permite **PvP en zonas específicas** del servidor Wetlands mientras mantiene el resto como **zona pacífica**. Perfecto para un servidor compasivo que quiere ofrecer combate consensual.

### ✨ Características Principales

- ✅ **Detección automática** de entrada/salida de arena
- ✅ **Mensajes visuales** claros y coloridos
- ✅ **Múltiples arenas** soportadas
- ✅ **PvP consensual** - solo dentro de arena
- ✅ **Comandos intuitivos** para jugadores y admins
- ✅ **Sistema 3D completo** - incluye altura y profundidad

## 🎮 Arena por Defecto

**Arena Principal** (configurada para Wetlands):
- **Centro**: (41, 23, 232) - Coordenadas de la construcción existente
- **Radio**: 25 bloques (área de 51x51)
- **Altura**: ±50 bloques desde el centro
- **Estado**: Activa por defecto

## 🕹️ Comandos para Jugadores

| Comando | Descripción |
|---------|-------------|
| `/arena_lista` | Lista todas las arenas disponibles |
| `/arena_info` | Info de la arena donde estás |
| `/arena_donde` | Muestra distancia a arena más cercana |
| `/salir_arena` | Teleport inmediato al spawn |

## 👨‍💼 Comandos de Administrador

Requieren privilegio `arena_admin`

| Comando | Descripción | Ejemplo |
|---------|-------------|---------|
| `/crear_arena <nombre> <radio>` | Crea arena en posición actual | `/crear_arena Arena_Halloween 40` |
| `/eliminar_arena <nombre>` | Elimina una arena | `/eliminar_arena Arena_Halloween` |
| `/arena_tp <nombre>` | Teleporta al centro de arena | `/arena_tp Arena_Principal` |
| `/arena_toggle <nombre>` | Activa/desactiva arena | `/arena_toggle Arena_Principal` |
| `/arena_stats` | Estadísticas de uso | `/arena_stats` |

## 📋 Instalación

### 1. Activar el Mod

Agregar a `server/config/luanti.conf`:

```ini
load_mod_pvp_arena = true
```

### 2. Privilegios de Administrador

Otorgar privilegio `arena_admin` a administradores:

```lua
/grant gabo arena_admin
/grant pepelomo arena_admin
```

### 3. Reiniciar el Servidor

```bash
docker-compose restart luanti-server
```

## 🎯 Funcionamiento

### Detección Automática

El mod verifica la posición de cada jugador **cada segundo**:

1. **Jugador entra a arena** → PvP activado + mensaje visual
2. **Jugador sale de arena** → PvP desactivado + mensaje de paz
3. **Verificación 3D** → Incluye altura y profundidad

### Mensajes Visuales

**Al entrar**:
```
╔═══════════════════════════════════╗
║  ⚔️  ENTRASTE A ARENA PRINCIPAL ⚔️ ║
║                                   ║
║  • El combate está habilitado     ║
║  • Sal cuando quieras para paz    ║
║  • /salir_arena para teleport     ║
╚═══════════════════════════════════╝
⚔️ PVP ACTIVADO ⚔️
```

**Al salir**:
```
✅ Has salido de la Arena PVP
🌱 Estás de vuelta en zona pacífica
```

### Sistema de Protección

El mod implementa protección **bidireccional**:

- ✅ **Ambos jugadores en arena** → Daño permitido
- ❌ **Uno fuera de arena** → Daño bloqueado con mensaje
- ✅ **Daño de mobs** → Siempre permitido

## 🗂️ Estructura de Archivos

```
server/mods/pvp_arena/
├── mod.conf          # Metadatos del mod
├── init.lua          # Lógica principal (detección, PvP toggle)
├── commands.lua      # Comandos de chat
└── README.md         # Esta documentación
```

## 💾 Archivo de Configuración

Las arenas se guardan en: `server/worlds/world/pvp_arenas.txt`

**Formato**:
```lua
return {name="Arena Principal", center={x=41,y=23,z=232}, radius=25, enabled=true, created_by="gabo", created_at=1728950400}
```

## 🔧 Configuración Avanzada

### Crear Arena Personalizada

1. **Posicionarte** en el centro deseado
2. **Ejecutar**: `/crear_arena NombreArena <radio>`
3. **Verificar**: `/arena_lista`

**Ejemplo**:
```
/crear_arena Arena_Evento 30
```

### Modificar Radio de Arena Existente

Editar manualmente `server/worlds/world/pvp_arenas.txt`:

```lua
return {name="Arena Principal", center={x=41,y=23,z=232}, radius=30, enabled=true, created_by="gabo", created_at=1728950400}
```

Luego reiniciar servidor.

## 🐛 Debugging

### Ver Jugadores en Arenas

```lua
/lua minetest.chat_send_all(dump(pvp_arena.players_in_arena))
```

### Forzar Recarga de Arenas

```lua
/lua pvp_arena.load_arenas()
```

### Ver Logs del Mod

```bash
docker-compose logs luanti-server | grep "PVP Arena"
```

## ❓ FAQ

**P: ¿Funciona en modo creativo?**
R: Sí, aunque el daño no reducirá vida infinita del creativo.

**P: ¿Puedo tener múltiples arenas?**
R: Sí, hasta 10 arenas simultáneamente.

**P: ¿Cómo deshabilito temporalmente una arena?**
R: Usar `/arena_toggle <nombre>` o editar el archivo y cambiar `enabled=false`.

**P: ¿Las arenas funcionan en 3D completo?**
R: Sí, el radio horizontal es de 25 bloques, y verticalmente ±50 bloques.

**P: ¿Qué pasa si un jugador se desconecta en arena?**
R: El estado se limpia automáticamente. Al reconectar, el sistema detecta su posición.

## 🔮 Próximas Versiones

### v1.1.0
- [ ] Sistema de estadísticas (kills, deaths, K/D ratio)
- [ ] Leaderboard persistente
- [ ] Zonas de espectadores

### v1.2.0
- [ ] Torneos automatizados
- [ ] Sistema de equipos (Team PvP)
- [ ] Rewards por victorias

## 🤝 Contribuciones

Pull requests bienvenidos! Para cambios mayores:

1. Abrir issue primero para discutir
2. Fork del repositorio
3. Crear branch de feature
4. Commit con mensajes descriptivos
5. Push y crear PR

## 📄 Licencia

MIT License - Libre para usar, modificar y distribuir

## 🙏 Créditos

- **Desarrollador**: Gabriel Pantoja (gabo)
- **Testing**: gabo, pepelomo
- **Servidor**: Wetlands 🌱 - `luanti.gabrielpantoja.cl:30000`
- **Repositorio**: github.com/gabrielpantoja-cl/luanti-voxelibre-server

---

**Última actualización**: 2025-10-12
**Estado**: ✅ Producción Ready
