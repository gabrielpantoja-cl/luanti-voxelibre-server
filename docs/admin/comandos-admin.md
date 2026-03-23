# Comandos de Administración - Wetlands Valdivia

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

## 🏗️ Comandos de WorldEdit

**Requiere**: privilegio `worldedit`

### Obtener Herramientas
```
/giveme worldedit:wand
```
**Hacha de WorldEdit**: Click izquierdo = pos1, Click derecho = pos2

### Selección de Área

#### Seleccionar Manualmente
```
//pos1
//pos2
```
Selecciona tu posición actual como esquina 1 o 2.

#### Expandir/Contraer Selección
```
//expand <cantidad> <dirección>
//contract <cantidad> <dirección>
```
**Direcciones**: `up`, `down`, `north`, `south`, `east`, `west`, `front`, `back`

**Ejemplos**:
- `//expand 10 up` - Expande 10 bloques hacia arriba
- `//contract 5 down` - Contrae 5 bloques hacia abajo

#### Seleccionar Todo un Chunk
```
//chunk
```

### Operaciones Básicas

#### Llenar Área
```
//set <bloque>
```
**Ejemplos**:
- `//set mcl_core:stone` - Llenar con piedra
- `//set air` - Vaciar área (crear hueco)
- `//set mcl_core:water_source` - Llenar con agua

#### Reemplazar Bloques
```
//replace <bloque_viejo> <bloque_nuevo>
```
**Ejemplos**:
- `//replace mcl_core:dirt mcl_core:grass_block`
- `//replace air mcl_core:stone` - Llenar solo espacios vacíos

### Formas Geométricas

#### Esfera
```
//sphere <bloque> <radio> [hueca]
```
**Ejemplos**:
- `//sphere mcl_core:stone 5` - Esfera sólida de piedra, radio 5
- `//sphere mcl_core:glass 10 true` - Esfera hueca de vidrio, radio 10

#### Cilindro
```
//cylinder <bloque> <radio> <altura> [hueco]
```
**Ejemplos**:
- `//cylinder mcl_core:stone 3 10` - Cilindro sólido
- `//cylinder mcl_core:cobblestone 5 8 true` - Cilindro hueco

#### Pirámide
```
//pyramid <bloque> <altura>
```

### Copiar y Pegar

#### Copiar Selección
```
//copy
```
Copia la selección actual.

#### Cortar Selección
```
//cut
```
Copia y borra la selección original.

#### Pegar
```
//paste
```
Pega en tu posición actual.

### Movimiento y Rotación

#### Mover Selección
```
//move <distancia> <dirección> [dejar_copia]
```
**Ejemplos**:
- `//move 10 up` - Mover 10 bloques hacia arriba
- `//move 5 north true` - Mover y dejar copia original

#### Apilar (Duplicar)
```
//stack <cantidad> <dirección>
```
**Ejemplo**: `//stack 5 east` - Crear 5 copias hacia el este

### Generación de Terreno

#### Generar Terreno Natural
```
//generate <expresión> <tamaño_bloque>
```
**Ejemplo**: `//generate stone 16` - Generar terreno de piedra

### Deshacer y Rehacer

#### Deshacer Última Acción
```
//undo [pasos]
```
**Ejemplos**:
- `//undo` - Deshacer último cambio
- `//undo 3` - Deshacer últimos 3 cambios

#### Rehacer
```
//redo [pasos]
```

### Utilidades

#### Ver Tamaño de Selección
```
//size
```

#### Limpiar Historial
```
//clearhistory
```

#### Información de Bloque
```
//inspect
```
Obtén información del bloque que tocas.

### Comandos Avanzados

#### Drenar Líquidos
```
//drain <radio>
```
Elimina agua y lava en el radio especificado.

#### Rellenar Huecos
```
//fillr <bloque> <radio>
```
Rellena espacios vacíos con el bloque especificado.

#### Fijar Área (Proteger)
```
//fixedpos set1 <x> <y> <z>
//fixedpos set2 <x> <y> <z>
```

### Bloques Comunes de VoxeLibre

```
mcl_core:stone          - Piedra
mcl_core:dirt           - Tierra
mcl_core:grass_block    - Bloque de hierba
mcl_core:cobblestone    - Adoquín
mcl_core:wood           - Madera
mcl_core:leaves         - Hojas
mcl_core:glass          - Vidrio
mcl_core:water_source   - Agua
mcl_core:lava_source    - Lava
air                     - Aire (vacío)
```

### ⚠️ Consejos de WorldEdit

1. **Siempre haz backup** antes de operaciones grandes
2. **Usa `//undo`** si algo sale mal
3. **Selecciones grandes** pueden causar lag - úsalas con cuidado
4. **Prueba primero** en áreas pequeñas
5. **El comando `//size`** te ayuda a verificar el tamaño antes de ejecutar

## Invocar Entidades (Mobs/Bosses)

### Invocar mob o entidad
```
/summon <nombre_entidad>
```
Spawnea la entidad en tu posicion actual.

**Ejemplos**:
- `/summon mobs_mc:enderdragon` - Ender Dragon (invocar en el End)
- `/summon mobs_mc:wither` - Wither
- `/summon mobs_mc:enderman` - Enderman
- `/summon mobs_mc:pig` - Cerdo
- `/summon mobs_mc:cow` - Vaca

**Nota sobre el Ender Dragon:** El dragon NO spawnea automaticamente si el End fue generado con `only_peaceful_mobs = true` activo (config nuclear). En ese caso hay que invocarlo manualmente con `/summon mobs_mc:enderdragon` estando en el End.

**Coordenadas del End:** `/teleport 0,-27003,0` (isla central con torretas y portal de salida)

## Comandos de Depuracion (Admin)

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

## 📸 Screenshots (F12)

Dentro de Luanti, presionar **F12** para capturar pantalla. Las capturas se guardan en:

```
C:\Users\gabri\Saved Games\luanti-5.15.0-win64\luanti-5.15.0-win64\screenshots\
```

> **Nota**: La tecla ImpPt (Print Screen) de Windows puede no funcionar dentro del juego. Usar F12 (nativo de Luanti) o Win+ImpPt.

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