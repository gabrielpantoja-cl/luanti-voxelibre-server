# 📋 Server Rules - Sistema de Reglas y Bienvenida

**Versión**: 2.0  
**Autor**: gabo (Wetlands Team)  
**Compatibilidad**: VoxeLibre v0.90.1

## 📖 Descripción

Sistema completo de reglas, bienvenida y filosofía compasiva para el servidor Wetlands. Proporciona comandos para mostrar reglas, filosofía del servidor, información sobre santuarios de animales, y mensajes de bienvenida automáticos.

## 🎯 Propósito

Este mod es fundamental para:
- **Educar jugadores** sobre las reglas del servidor
- **Transmitir la filosofía** compasiva de Wetlands
- **Bienvenida automática** a nuevos jugadores
- **Información sobre cuidado animal** y santuarios

## 🚀 Características

### Comandos Disponibles

| Comando | Descripción | Uso |
|---------|-------------|-----|
| `/reglas` | Muestra todas las reglas del servidor | `/reglas` |
| `/r` | Reglas rápidas (versión corta) | `/r` |
| `/filosofia` | Muestra la filosofía y misión de Wetlands | `/filosofia` |
| `/santuario` | Información sobre cuidado de animales en santuarios | `/santuario` |
| `/info` | Información completa del servidor (reglas, filosofía, comandos) | `/info` |
| `/discord` | Información del servidor Discord de Wetlands | `/discord` |

### Bienvenida Automática

Al conectarse, todos los jugadores reciben automáticamente:
- Mensaje de bienvenida personalizado
- Reglas básicas importantes
- Información sobre comandos útiles
- Link a la página web del servidor

## 📝 Reglas del Servidor

Las reglas se muestran con el comando `/reglas`:

1. **🚫 NO MOLESTAR A OTROS JUGADORES**
   - No destruir construcciones ajenas
   - No seguir o acosar a otros jugadores
   - Respetar el espacio personal

2. **👤 USA UN NOMBRE APROPIADO**
   - Nada de nombres random como 'player123'
   - Elige un nombre que te represente
   - Sin palabras ofensivas

3. **🤝 NO ECHAR A OTROS JUGADORES SIN RAZÓN**
   - Este es un espacio para todos
   - Reporta problemas a moderadores
   - Sé amable y tolerante

4. **💬 CHAT RESPETUOSO**
   - Usa lenguaje apropiado (niños 7+)
   - No spam ni mensajes repetitivos
   - Ayuda a crear un ambiente positivo

5. **🌱 ESPÍRITU COMPASIVO**
   - Cuida a los animales del servidor
   - Comparte y ayuda a otros jugadores
   - Disfruta construyendo juntos

### Consecuencias

- 1ra vez: Advertencia
- 2da vez: Silencio temporal (mute)
- 3ra vez: Expulsión temporal (kick)
- 4ta vez: Baneo permanente

## 🔧 Configuración

### Dependencias

```lua
depends =
optional_depends = mcl_core
supported_games = mineclone2
```

### Habilitar el Mod

Agregar en `server/config/luanti.conf`:
```ini
load_mod_server_rules = true
```

O en `server/worlds/world/world.mt`:
```ini
load_mod_server_rules = true
```

## 📚 Filosofía del Servidor

La filosofía de Wetlands se muestra con `/filosofia`:

> "Nuestra filosofía es simple: aprender, crear y explorar con respeto por todos los seres vivos y nuestro planeta. Fomentamos la compasión, la curiosidad y la colaboración. ¡Construyamos un mundo mejor juntos!"

## 🐾 Santuarios de Animales

El comando `/santuario` proporciona información sobre:
- Cómo cuidar animales en santuarios
- Alimentación compasiva
- Protección de animales
- Construcción de santuarios

## 🌐 Integración con Otros Mods

Este mod es independiente pero complementa:
- **`education_blocks`**: Proporciona contexto educativo
- **`voxelibre_protection`**: Información sobre protección de áreas
- **`creative_force`**: Mensajes de bienvenida coordinados

## 🔄 Actualizaciones

### v2.0 (Actual)
- Sistema completo de reglas
- Bienvenida automática mejorada
- Comandos `/info` y `/discord` agregados
- Compatibilidad con VoxeLibre v0.90.1

### v1.0
- Versión inicial con comandos básicos

## 🐛 Troubleshooting

### Los comandos no funcionan

1. Verificar que el mod está habilitado:
   ```bash
   docker-compose exec -T luanti-server cat /config/.minetest/worlds/world/world.mt | grep server_rules
   ```

2. Verificar logs:
   ```bash
   docker-compose logs luanti-server | grep server_rules
   ```

3. Reiniciar servidor:
   ```bash
   docker-compose restart luanti-server
   ```

### Mensajes de bienvenida no aparecen

- Verificar que el jugador es nuevo (primera conexión)
- Los mensajes aparecen después de 3 segundos de conexión
- Verificar logs para errores

## 📞 Soporte

Para problemas o sugerencias:
- Revisar logs del servidor
- Consultar documentación general en `docs/mods/README.md`
- Contactar administradores del servidor

---

**Última actualización**: Diciembre 7, 2025  
**Mantenedor**: Equipo Wetlands  
**Licencia**: GPL-3.0

