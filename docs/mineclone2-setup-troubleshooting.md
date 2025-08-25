# MineClone2/VoxeLibre Setup y Troubleshooting

## Resumen del Problema

Durante la configuración del servidor Vegan Wetlands, encontramos varios desafíos para cambiar del juego por defecto `devtest` a `mineclone2` (VoxeLibre).

## Problema Principal

El servidor Luanti persistía en cargar `devtest` a pesar de tener `default_game = mineclone2` configurado en `luanti.conf`.

## Causas Identificadas

### 1. Persistencia de Mundos Existentes
- Los mundos en Luanti/Minetest tienen su propio archivo `world.mt` que define qué juego utilizan
- Una vez creado un mundo con un juego específico, ignora la configuración `default_game` del servidor
- **Ubicación del archivo**: `/config/.minetest/worlds/world/world.mt`

### 2. Juegos No Instalados
- El contenedor `linuxserver/luanti:latest` solo incluye `devtest` por defecto
- Los juegos adicionales como MineClone2/VoxeLibre deben instalarse manualmente
- Los juegos no persisten automáticamente al reiniciar contenedores sin volúmenes mapeados

### 3. Configuración de Docker Compose
- Los volúmenes nombrados no utilizados en `docker-compose.yml` pueden causar conflictos
- El mapeo directo de directorios locales es más predecible que volúmenes nombrados

## Soluciones Aplicadas

### Paso 1: Limpieza Completa
```bash
# Detener todos los servicios
docker compose down

# Eliminar volúmenes persistentes
docker volume rm vegan-wetlands_luanti-worlds
docker volume rm vegan-wetlands_luanti-config

# Limpiar sistema Docker
docker system prune -f

# Eliminar directorios locales de mundos
rm -rf server/worlds
```

### Paso 2: Instalación Manual de MineClone2
```bash
# Entrar al contenedor
docker compose exec luanti-server /bin/bash

# Navegar al directorio de juegos
cd /config/.minetest/games/

# Descargar MineClone2 desde ContentDB oficial
wget -O mineclone2.zip https://content.luanti.org/packages/Wuzzy/mineclone2/releases/32301/download/

# Extraer y configurar
unzip mineclone2.zip
# El archivo se extrae como directorio 'mineclone2' directamente

# Limpiar archivos temporales
rm mineclone2.zip
```

### Paso 3: Configuración del Mundo
```bash
# Editar el archivo world.mt del mundo existente
sed -i 's/gameid = devtest/gameid = mineclone2/' /config/.minetest/worlds/world/world.mt

# O crear un mundo completamente nuevo eliminando el directorio
rm -rf /config/.minetest/worlds/world
```

### Paso 4: Optimización de Docker Compose
Eliminar sección de volúmenes nombrados no utilizados:

```yaml
# ELIMINAR esta sección si no se usa:
# volumes:
#   luanti-config:
#   luanti-mods:
#   luanti-worlds:
#   luanti-backups:
```

## Comandos de Verificación

### Verificar Juegos Instalados
```bash
docker compose exec luanti-server ls -la /config/.minetest/games/
```

### Verificar Configuración del Mundo
```bash
docker compose exec luanti-server cat /config/.minetest/worlds/world/world.mt
```

### Verificar Logs del Servidor
```bash
docker compose logs -f luanti-server
```

## Señales de Éxito

### Antes (Problema):
```
2025-08-25 00:08:56: ACTION[Main]: [log] modpath="/config/.minetest/games/devtest/mods/log"
2025-08-25 00:08:56: ACTION[Main]: Server for gameid="devtest" listening on [::]:30000.
```

### Durante Transición:
```
2025-08-25 00:33:11: ERROR[Main]: Game [] could not be found.
```

### Después (Éxito esperado):
```
2025-08-25 XX:XX:XX: ACTION[Main]: Server for gameid="mineclone2" listening on [::]:30000.
```

## Lecciones Aprendidas

1. **Persistencia de Mundos**: Los mundos existentes mantienen su configuración de juego independientemente de la configuración del servidor
2. **Instalación Manual Necesaria**: Los juegos adicionales requieren instalación manual en el contenedor
3. **ContentDB es Preferible**: Usar la ContentDB oficial de Luanti es más confiable que GitHub
4. **Limpieza Completa**: Para cambios de juego, es mejor empezar completamente limpio
5. **Verificación Paso a Paso**: Verificar cada componente (configuración, juegos instalados, archivos de mundo) por separado

## URLs de Referencia

- **MineClone2 en ContentDB**: https://content.luanti.org/packages/Wuzzy/mineclone2/
- **Descarga Directa**: https://content.luanti.org/packages/Wuzzy/mineclone2/releases/32301/download/
- **Documentación Luanti**: https://luanti.org/
- **Docker LinuxServer**: https://hub.docker.com/r/linuxserver/luanti

## Configuración Final Recomendada

```yaml
# docker-compose.yml (sección volumes del servicio)
volumes:
  - ./server/config/luanti.conf:/config/.minetest/minetest.conf
  - ./server/mods:/config/.minetest/mods
  - ./server/worlds:/config/.minetest/worlds
  - ./server/backups:/backups
  - ./server/games:/config/.minetest/games  # AGREGAR para persistir juegos
```

Agregar el mapeo de games para evitar tener que reinstalar MineClone2 en cada reinicio del contenedor.