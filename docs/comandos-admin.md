# Comandos de Administración - Servidor Luanti Vegan Wetlands

Este documento contiene todos los comandos disponibles para administradores del servidor, con estado de verificación para mantener actualizada la documentación.

## Comandos de Gestión de Jugadores

### Privilegios y Permisos

- [ ] `/grant <jugador> <privilegio>` - Otorga un privilegio específico a un jugador
- [x] `/grant <jugador> creative` - Otorga modo creativo a un jugador **[VERIFICADO]**
- [ ] `/revoke <jugador> <privilegio>` - Revoca un privilegio específico de un jugador
- [x] `/revoke <jugador> creative` - Quita modo creativo a un jugador **[VERIFICADO]**
- [ ] `/privs <jugador>` - Muestra los privilegios de un jugador
- [ ] `/privs <jugador> +<privilegio>` - Añade un privilegio (sintaxis alternativa)
- [ ] `/privs <jugador> -<privilegio>` - Quita un privilegio (sintaxis alternativa)

### Modo de Juego

- [ ] `/gamemode creative <jugador>` - Cambia jugador a modo creativo
- [ ] `/gamemode survival <jugador>` - Cambia jugador a modo supervivencia
- [ ] `/gamemode spectator <jugador>` - Cambia jugador a modo espectador

### Gestión de Usuarios

- [ ] `/ban <jugador>` - Banea a un jugador del servidor
- [ ] `/unban <jugador>` - Desbanea a un jugador
- [ ] `/kick <jugador> [razón]` - Expulsa a un jugador temporalmente
- [ ] `/mute <jugador>` - Silencia a un jugador (no puede escribir en chat)
- [ ] `/unmute <jugador>` - Quita el silencio a un jugador

## Comandos de Mundo y Servidor

### Gestión del Tiempo

- [ ] `/time <valor>` - Establece la hora del día (0-24000)
- [ ] `/time 6000` - Establece mediodía
- [ ] `/time 18000` - Establece medianoche
- [ ] `/settime <valor>` - Comando alternativo para establecer tiempo

### Clima y Ambiente

- [ ] `/weather clear` - Establece clima despejado
- [ ] `/weather rain` - Establece lluvia
- [ ] `/weather storm` - Establece tormenta

### Teletransporte

- [ ] `/teleport <jugador> <x> <y> <z>` - Teletransporta jugador a coordenadas
- [ ] `/tp <jugador> <x> <y> <z>` - Comando corto de teletransporte
- [ ] `/bring <jugador>` - Trae un jugador hacia ti
- [ ] `/goto <jugador>` - Te teletransporta hacia un jugador

### Spawn y Hogar

- [ ] `/spawn` - Teletransporta al punto de aparición
- [ ] `/setspawn` - Establece punto de aparición global
- [ ] `/sethome` - Establece hogar personal
- [ ] `/home` - Teletransporta al hogar personal

## Comandos de Objetos y Construcción

### Dar Objetos

- [ ] `/give <jugador> <objeto> [cantidad]` - Da un objeto a un jugador
- [ ] `/give <jugador> default:wood 64` - Ejemplo: dar 64 bloques de madera
- [ ] `/giveme <objeto> [cantidad]` - Te da un objeto a ti mismo

### Construcción y Edición

- [ ] `/clearinv <jugador>` - Limpia el inventario de un jugador
- [ ] `/clearobjects` - Elimina objetos sueltos del mundo
- [ ] `/deleteblocks <área>` - Elimina bloques en un área

## Comandos de Información y Debug

### Estado del Servidor

- [ ] `/status` - Muestra estado del servidor
- [ ] `/shutdown [mensaje]` - Cierra el servidor con mensaje opcional
- [ ] `/debug` - Información de debug del servidor

### Información de Jugadores

- [ ] `/whois <jugador>` - Información detallada de un jugador
- [ ] `/last-login <jugador>` - Último login de un jugador
- [ ] `/players` - Lista jugadores conectados

## Comandos Específicos del Servidor Vegan Wetlands

### Comandos Educativos

- [x] `/santuario` - Información sobre características del santuario animal **[VERIFICADO]**
- [x] `/veganismo` - Contenido educativo sobre veganismo **[VERIFICADO]**

### Protección y Moderación

- [ ] `/protect <área>` - Protege un área específica
- [ ] `/unprotect <área>` - Desprotege un área
- [ ] `/rollback <jugador>` - Deshace cambios de un jugador

## Privilegios Disponibles en el Servidor

### Privilegios Básicos
- `interact` - Interactuar con el mundo
- `shout` - Escribir en chat público
- `creative` - Acceso a modo creativo
- `fly` - Capacidad de volar
- `fast` - Movimiento rápido
- `noclip` - Atravesar bloques

### Privilegios Administrativos
- `server` - Control total del servidor
- `privs` - Gestionar privilegios de otros
- `ban` - Banear jugadores
- `kick` - Expulsar jugadores
- `teleport` - Teletransporte
- `give` - Dar objetos
- `settime` - Cambiar hora del día
- `worldedit` - Usar WorldEdit (si está instalado)
- `home` - Usar comandos de hogar
- `spawn` - Usar comandos de spawn
- `rollback_check` - Ver historial de rollback
- `password` - Cambiar contraseñas de usuarios

## Configuración por Defecto del Servidor

### Privilegios por Defecto para Nuevos Jugadores
```
default_privs = interact,shout,home,spawn,creative
```

### Configuración Actual
- **Modo**: Creativo habilitado por defecto
- **Daño**: Deshabilitado (enable_damage = false)
- **PvP**: Deshabilitado
- **Idioma**: Español (es)
- **Jugadores Máximo**: 20

## Notas Importantes

1. **Base de Datos de Usuarios**: El servidor usa SQLite (`auth.sqlite`) para gestionar usuarios y privilegios
2. **Configuración de Privilegios**: Los privilegios se almacenan en la base de datos, no en archivos de texto
3. **Modo Supervivencia**: Los nuevos jugadores ingresan en modo supervivencia pero con privilegios creativos
4. **Comandos de Chat**: Los comandos se ejecutan escribiendo en el chat del juego precedidos por `/`

## Cómo Usar Este Documento

- **[ ]** = Comando no verificado aún
- **[x]** = Comando verificado y funcionando
- Actualizar estado después de probar cada comando
- Agregar nuevos comandos según se descubran

## Última Actualización

Fecha: 2024-12-XX
Estado: Documento creado, pendiente verificación de comandos

---

**Nota**: Este documento debe actualizarse regularmente. Cuando pruebes un comando, marca la casilla correspondiente como verificada.