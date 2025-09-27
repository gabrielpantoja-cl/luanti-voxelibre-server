# VoxeLibre Server Settings - Configuración desde Interfaz

## Acceso a Server Settings

Los administradores con privilegios pueden acceder a la configuración del servidor directamente desde la interfaz de VoxeLibre:

1. **Abrir inventario**: Presionar tecla `I`
2. **Acceder a Server Settings**: Click en el ícono "Server Settings" (configuración)
3. **Navegar pestañas**: "Game Rules" y "Settings"

## Game Rules (Reglas del Juego)

Las Game Rules controlan aspectos fundamentales del comportamiento del servidor y la experiencia de juego.

### Configuraciones Visibles

#### `gamerule:announceAdvancements` (Default: true)
- **Descripción**: Whether advancements should be announced in chat
- **Español**: Si los logros deben anunciarse en el chat
- **Impacto**: Controla si los jugadores ven notificaciones cuando otros obtienen logros
- **Recomendado para Wetlands**: ✅ `true` (motiva a los jugadores y crea comunidad)

#### `gamerule:disableRaids` (Default: false)
- **Descripción**: Whether raids are disabled
- **Español**: Si las incursiones están deshabilitadas
- **Impacto**: Las incursiones son eventos violentos donde aldeanos son atacados
- **Recomendado para Wetlands**: ✅ `true` (sin violencia, servidor compasivo)

#### `gamerule:doDaylightCycle` (Default: true)
- **Descripción**: Whether the daylight cycle and moon phases progress
- **Español**: Si el ciclo día/noche y las fases lunares progresan
- **Impacto**: Controla si el tiempo avanza naturalmente
- **Recomendado para Wetlands**: ✅ `true` (ciclo natural para educación)

#### `gamerule:doFireTick` (Default: true)
- **Descripción**: Whether fire should spread and naturally extinguish
- **Español**: Si el fuego debe propagarse y extinguirse naturalmente
- **Impacto**: Controla comportamiento realista del fuego
- **Recomendado para Wetlands**: ⚠️ Evaluar - puede ser educativo pero peligroso para construcciones

#### `gamerule:doMobLoot` (Default: true)
- **Descripción**: Whether mobs should drop items and experience orbs
- **Español**: Si los mobs deben soltar objetos y orbes de experiencia
- **Impacto**: Controla si las criaturas dan recompensas al morir
- **Recomendado para Wetlands**: ❌ `false` (no incentivar muerte de animales)

#### `gamerule:doMobSpawning` (Default: false)
- **Descripción**: Whether mobs should spawn naturally or via global spawning logic
- **Español**: Si los mobs deben aparecer naturalmente o mediante lógica global
- **Detalles**: No afecta spawners especiales, monstruos, raids o iron golems
- **Recomendado para Wetlands**: ✅ `false` (sin monstruos para ambiente seguro)

#### `gamerule:doVinesSpread` (Default: true)
- **Descripción**: Whether vines can spread to other blocks
- **Español**: Si las enredaderas pueden extenderse a otros bloques
- **Detalles**: Cave vines, weeping vines y twisting vines no se ven afectadas
- **Recomendado para Wetlands**: ✅ `true` (crecimiento natural de plantas)

#### `gamerule:doWeatherCycle` (Default: true)
- **Descripción**: Whether the weather can change naturally
- **Español**: Si el clima puede cambiar naturalmente
- **Nota**: El comando /weather aún puede cambiar el clima manualmente
- **Recomendado para Wetlands**: ✅ `true` (experiencia natural y educativa)

#### `gamerule:drowningDamage` (Default: true)
- **Descripción**: Whether drowning damage should be applied
- **Español**: Si debe aplicarse daño por ahogamiento
- **Impacto**: Controla si los jugadores se ahogan bajo el agua
- **Recomendado para Wetlands**: ❌ `false` (servidor sin daño)

#### `gamerule:fallDamage` (Default: true)
- **Descripción**: Whether fall damage should be applied
- **Español**: Si debe aplicarse daño por caída
- **Impacto**: Controla si los jugadores se lastiman al caer
- **Recomendado para Wetlands**: ❌ `false` (servidor sin daño)

## Configuración Recomendada para Wetlands

### Filosofía del Servidor
- **Sin violencia**: Desactivar todo daño y mecánicas violentas
- **Educativo**: Mantener ciclos naturales para aprendizaje
- **Compasivo**: No incentivar muerte de animales
- **Seguro**: Ambiente protegido para niños 7+

### Game Rules Sugeridas
```
gamerule:announceAdvancements = true    # Comunidad y motivación
gamerule:disableRaids = true           # Sin violencia
gamerule:doDaylightCycle = true        # Educación sobre ciclos naturales
gamerule:doFireTick = false            # Protección de construcciones
gamerule:doMobLoot = false            # No incentivar muerte de animales
gamerule:doMobSpawning = false        # Sin monstruos hostiles
gamerule:doVinesSpread = true         # Crecimiento natural de plantas
gamerule:doWeatherCycle = true        # Experiencia climática natural
gamerule:drowningDamage = false       # Sin daño por ahogamiento
gamerule:fallDamage = false           # Sin daño por caída
```

## Aplicación de Cambios

### Desde la Interfaz
1. Modificar configuraciones en "Server Settings"
2. Los cambios se aplican inmediatamente
3. Algunos cambios requieren reinicio del servidor

### Desde Archivos de Configuración
- Las configuraciones también pueden establecerse en `server/config/luanti.conf`
- Format: `default_game_settings = {"gamerule:setting":"value"}`

## Privilegios Requeridos

Para acceder a Server Settings, el usuario necesita:
- Privilegio `server` (administración del servidor)
- Privilegio `privs` (gestión de privilegios)

### Verificar Privilegios
```bash
# En el contenedor
sqlite3 /config/.minetest/worlds/world/auth.sqlite "SELECT privilege FROM user_privileges WHERE id=(SELECT id FROM auth WHERE name='gabo');"
```

## Notas Importantes

- ⚠️ **Backup antes de cambios**: Siempre respaldar mundo antes de modificar configuraciones críticas
- 🔄 **Reinicio puede ser necesario**: Algunos cambios requieren reiniciar el servidor
- 📝 **Documentar cambios**: Registrar modificaciones para troubleshooting futuro
- 🎯 **Probar en local**: Validar configuraciones en ambiente de desarrollo primero

## Próximos Pasos

1. **Documentar pestaña "Settings"**: Explorar configuraciones adicionales
2. **Crear script de configuración**: Automatizar aplicación de settings recomendados
3. **Validar configuraciones actuales**: Revisar estado actual del servidor
4. **Guía de troubleshooting**: Documentar problemas comunes y soluciones