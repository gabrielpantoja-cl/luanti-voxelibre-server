# GEMINI.md

Este archivo proporciona orientación específica a Google Gemini cuando trabaja con código en este repositorio.

## Información del Proyecto

Vegan Wetlands es un **servidor de juego Luanti (anteriormente Minetest)** diseñado como un entorno compasivo, educativo y creativo para niños de 7+ años. El servidor cuenta con mods personalizados que promueven el cuidado animal, la educación compasiva y el juego no violento a través de santuarios de animales.

**IMPORTANTE**: Este repositorio (`https://github.com/gabrielpantoja-cl/luanti-voxelibre-server.git`) contiene **TODO** el código específico de Luanti, configuración y lógica de despliegue. Es completamente independiente del repositorio administrativo VPS (`vps-do.git`).

## 🚨 REGLAS CRÍTICAS DE SEGURIDAD DE TEXTURAS

### **⚠️ NUNCA HAGAS ESTO - CAUSA CORRUPCIÓN TOTAL:**

1. **🚫 NUNCA modifiques `docker-compose.yml` para mapear mods**
   ```yaml
   # ❌ ESTO CORROMPE TEXTURAS:
   volumes:
     - ./server/mods/nuevo_mod:/config/.minetest/games/mineclone2/mods/MISC/nuevo_mod
   ```
   
2. **🚫 NUNCA instales mods con dependencias de texturas**
   - `motorboat`, `biofuel`, `mobkit` causan corrupción completa
   - VoxeLibre tiene un sistema de texturas frágil
   - Los conflictos de ID de textura son cascada y persistentes

3. **🚫 NUNCA hagas cambios sin backup del mundo**

### **✅ PROTOCOLO DE EMERGENCIA PARA CORRUPCIÓN DE TEXTURAS**

**Síntomas de Corrupción:**
- Todos los bloques muestran la misma textura incorrecta
- Texturas faltantes (tablero rosa/negro)
- Errores de carga de texturas en logs
- Jugadores reportan fallas visuales

**PASOS DE RECUPERACIÓN INMEDIATA:**

```bash
# PASO 1: BACKUP DE EMERGENCIA DEL MUNDO (¡CRÍTICO!)
ssh gabriel@167.172.251.27 "cd /home/gabriel/luanti-voxelibre-server && du -sh server/worlds/* && cp -r server/worlds server/worlds_EMERGENCY_BACKUP_$(date +%Y%m%d_%H%M%S)"

# PASO 2: REVERTIR CAMBIOS PROBLEMÁTICOS
ssh gabriel@167.172.251.27 "cd /home/gabriel/luanti-voxelibre-server && git reset --hard HEAD~1"

# PASO 3: LIMPIAR ESTADO DEL CONTENEDOR
ssh gabriel@167.172.251.27 "cd /home/gabriel/luanti-voxelibre-server && docker-compose down && docker system prune -f"

# PASO 4: REMOVER VOXELIBRE CORROMPIDO
ssh gabriel@167.172.251.27 "cd /home/gabriel/luanti-voxelibre-server && rm -rf server/games/mineclone2 && rm -f voxelibre.zip"

# PASO 5: DESCARGAR VOXELIBRE FRESCO (56MB)
ssh gabriel@167.172.251.27 "cd /home/gabriel/luanti-voxelibre-server && wget https://content.luanti.org/packages/Wuzzy/mineclone2/releases/32301/download/ -O voxelibre.zip && unzip voxelibre.zip -d server/games/ && mv server/games/mineclone2-* server/games/mineclone2"

# PASO 6: REINICIAR CON ESTADO LIMPIO
ssh gabriel@167.172.251.27 "cd /home/gabriel/luanti-voxelibre-server && docker-compose up -d"

# PASO 7: VERIFICAR RECUPERACIÓN
ssh gabriel@167.172.251.27 "cd /home/gabriel/luanti-voxelibre-server && sleep 10 && docker-compose ps && du -sh server/worlds/world"
```

## Acceso al Servidor

```bash
# Acceso SSH al servidor de producción
ssh gabriel@167.172.251.27
```

## Comandos Esenciales

### Gestión del Servidor
```bash
# Iniciar el servidor (recomendado)
./scripts/start.sh

# O iniciar manualmente
docker-compose up -d

# Ver logs del servidor
docker-compose logs -f luanti-server

# Reiniciar servidor
docker-compose restart luanti-server

# Detener servidor
docker-compose down

# Monitorear estado del servidor
docker-compose ps
```

### Operaciones de Backup
```bash
# Backup manual
./scripts/backup.sh

# Los backups automáticos corren cada 6 horas vía contenedor cron
# Ubicación: server/backups/
# Retención: 10 backups más recientes
```

## Arquitectura del Repositorio

### 🎮 Este Repositorio (luanti-voxelibre-server.git)
**Responsabilidad**: Implementación completa del servidor Luanti
- Configuración Docker Compose para Luanti
- Mods personalizados (animal_sanctuary, vegan_food, education_blocks)
- Archivos de configuración del servidor
- Datos del mundo y backups
- **Desarrollo de página de inicio** (HTML/CSS/JS para luanti.gabrielpantoja.cl)
- Pipeline CI/CD específico de Luanti
- Lógica y mecánicas del juego

### 🏗️ Repositorio Administrativo VPS (vps-do.git)
**Responsabilidad**: Infraestructura general VPS
- Proxy inverso nginx
- Automatización n8n
- Gestión de contenedores Portainer
- Coordinación de servicios generales VPS
- **NO contiene archivos específicos de Luanti**

## Configuración del Servidor

- **Modo**: Creativo (sin daño, sin PvP, sin TNT)
- **Idioma**: Español (es)
- **Jugadores Máximos**: 20
- **Privilegios Predeterminados**: `interact,shout,home,spawn,creative`
- **Generación de Mundo**: v7 con cuevas, mazmorras, biomas
- **Punto de Spawn**: 0,15,0 (estático)

## Sistema de Autenticación Moderno

### Base de Datos SQLite (Luanti 5.13+)
**Ubicación**: `server/worlds/world/auth.sqlite`

**Comandos Útiles**:
```bash
# Listar todos los usuarios registrados
docker-compose exec -T luanti-server sqlite3 /config/.minetest/worlds/world/auth.sqlite 'SELECT name FROM auth;'

# Ver privilegios de un usuario
docker-compose exec -T luanti-server sqlite3 /config/.minetest/worlds/world/auth.sqlite 'SELECT * FROM user_privileges WHERE id=1;'

# Obtener ID de usuario
docker-compose exec -T luanti-server sqlite3 /config/.minetest/worlds/world/auth.sqlite 'SELECT id FROM auth WHERE name="usuario";'
```

## Comandos del Juego

### Comandos En-Juego Disponibles
- `/santuario`: Información sobre características del santuario de animales
- `/filosofia`: Contenido educativo sobre la filosofía del juego
- `/sit`: Sentarse cómodamente en la posición actual
- `/lay`: Acostarse y relajarse en prados de césped o flores

### Comandos Administrativos Básicos de VoxeLibre
- `/tp <jugador>`: Teletransportarse a un jugador (requiere privilegios)
- Usar **camas** para establecer punto de respawn automáticamente
- **Sistema de camas**: Dormir en una cama establece automáticamente tu punto de respawn

## Métricas de Recuperación Exitosa (Última: 9 Sep 2025)
- ✅ Datos del mundo preservados (174MB intactos)
- ✅ Todos los bloques muestran texturas correctas
- ✅ Servidor estable en puerto 30000
- ✅ Sin errores de dependencias en logs
- ✅ Jugadores pueden conectarse normalmente
- **Tiempo de Recuperación**: ~3 minutos
- **Pérdida de Datos**: Cero (mundo completamente preservado)

## Contenido de Terceros

### 🌱 Mod de Comida Vegana
**Fuente**: [Mod vegan_food por Daenvil](https://content.luanti.org/packages/Daenvil/vegan_food/)
**Licencia**: GPL v3.0 (código) / CC BY-SA 4.0 (texturas)
**Integración**: Proporciona comidas a base de plantas profesionales para el kit inicial

## Restricciones del Proyecto

- **Sin package.json**: No es un proyecto Node.js
- **Sin sistema de compilación tradicional**: Usa Docker Compose y Lua
- **Sin pruebas unitarias**: Testing manual mediante juego
- **Configuración vía archivos .conf**: No JSON/YAML
- **Scripting basado en Lua**: Toda la lógica de mods en Lua

---

## Proceso de Descubrimiento Histórico: Sistema de Autenticación

### Contexto
Este documento anteriormente detallaba el proceso de investigación realizado por Gemini para resolver la discrepancia en la gestión de usuarios del servidor.

### Descubrimiento Clave
- **Problema**: Los usuarios no aparecían en `auth.txt`
- **Solución**: El servidor usa **base de datos SQLite** (`auth.sqlite`) en lugar de archivos de texto
- **Fuente**: Documentación en `docs/NUCLEAR_CONFIG_OVERRIDE.md`
- **Resultado**: Sistema de autenticación moderno con SQLite correctamente identificado

Este conocimiento histórico ha sido integrado en la documentación principal arriba.
