# Proyecto FÚTBOL ⚽ — Mundo de fútbol en Luanti (puerto 30004)

Quinto mundo del servidor: un campo de fútbol (soccer) funcional en Luanti. Diferentes
mecánicas posibles según el mod/API que se use como base. Este documento investiga
las opciones disponibles.

## Resumen

| Item | Valor |
|------|-------|
| Puerto | **30004/UDP** (propuesto) |
| Container | `luanti-futbol-server` (propuesto) |
| Base game | **Minetest Game** (`minetest_game`) — juego base oficial de Luanti |
| Config | `server/config/luanti-futbol.conf` |
| Mundo | `server/worlds/futbol/` |
| Mapgen | `singlenode` — mundo vacío, se construye la cancha manualmente |

## Opciones de mods de fútbol

### Opción 1: `kaeza/minetest-soccer` (mod básico)

[GitHub: kaeza/minetest-soccer](https://github.com/kaeza/minetest-soccer)

- **Estado**: Beta / incompleto (último commit 2019)
- **Licencia**: BSD-2-Clause
- **Qué provee**: Pelota de fútbol (`soccer:ball_item`) + nodos de arco (sin funcionalidad de gol)
- **Mecánica**: La pelota se patea con Shift (agacharse), se empuja al pararse cerca, se coloca con clic derecho
- **Scoring**: No implementado nativamente — requiere Mesecons + pressure plates manual
- **Dependencias**: Ninguna declarada
- **Veredicto**: Funcionalidad mínima. Habría que desarrollar nosotros el marcador, detección de goles y rondas

### Opción 2: `DEES BALLZ!` (mod de bolas con física)

[ContentDB: Soundwavez/dees_balls](https://content.luanti.org/packages/Soundwavez/dees_balls/)

- **Estado**: Beta (última actualización 2024)
- **Licencia**: MIT para código, CC-BY-SA-3.0 para media
- **Qué provee**: Pelotas con física realista (rebotes, impulso). Incluye pelota de fútbol (socker), basketball, hockey
- **Mecánica**: Las pelotas rebotan, se empujan al acercarse, se golpean al punch, se recogen con clic derecho
- **Scoring**: El mod no incluye arcos ni detección de goles — solo las pelotas
- **Compatibilidad**: Funciona con cualquier juego, sin dependencias obligatorias
- **Veredicto**: Buena física pero sin lógica de fútbol. Habría que agregar arcos, scoring y rondas

### Opción 3: `Ball Physics API` (API de física)

[ContentDB: TomCon/ball_physics](https://content.luanti.org/packages/TomCon/ball_physics/)

- **Estado**: Mantenido (2026), versión 1.0.0
- **Licencia**: MIT
- **Qué provee**: API para agregar pelotas con física de movimiento
- **Veredicto**: Es un API, no un mod de fútbol. Útil si queremos desarrollar nuestro propio mod desde cero

### Opción 4: Desarrollar un mod propio

Basado en `arena_lib` (librería de minijuegos) + una pelota con física:

- **arena_lib**: [GitLab: zughy-friends-minetest/arena_lib](https://gitlab.com/zughy-friends-minetest/arena_lib)
  - Framework para minijuegos: arenas, equipos, rondas, editor, marcador
  - Usado por mods como Block League, Skywars, Murder
  - Proporciona sistema de equipos, respawn, puntuación, gestión de rondas
  - El mod de fútbol se desarrolla como "minijuego" de arena_lib
- Pelota: Podemos usar la de `kaeza/minetest-soccer` o la de `DEES BALLZ!` como base, o crear una propia

## Recomendación

**Opción 4 (mod propio con arena_lib)** es la más sólida a largo plazo, pero requiere
desarrollo. **Opción 2 (DEES BALLZ!)** es la más rápida de poner en marcha, pero sin
marcador ni detección de goles.

Fases propuestas:

1. **Fase 1 (inmediata)**: Instalar Minetest Game + DEES BALLZ! + crear cancha manualmente. Pelota funcional, goles manuales (los jugadores avisan cuando anotan).
2. **Fase 2 (desarrollo)**: Agregar mod `wetlands_soccer` con arcos funcionales + detección de goles + marcador en HUD.
3. **Fase 3 (avanzada)**: Migrar a sistema de rondas con arena_lib (equipos, auto-respawn, estadísticas).

## Minetest Game (base)

El juego base oficial de Luanti. Ligero, diseñado para modding. Sin mobs hostiles,
sin objetivos — solo sandbox puro con herramientas, minerales, agricultura básica y
creatividad.

- ContentDB: https://content.luanti.org/packages/Luanti/minetest_game/
- GitHub: https://github.com/luanti-org/minetest_game
- Última versión: 2026-06-03 (rolling release)
- Licencia: LGPL-2.1-or-later (código), CC-BY-SA-3.0 (media)
- Mapgen: `v7` (por defecto), pero usaremos `singlenode`

## Instalación del juego base

```bash
# Clonar Minetest Game
git clone https://github.com/luanti-org/minetest_game.git server/games/minetest_game
```

## Instalación de mods (Fase 1)

```bash
# DEES BALLZ!
git clone https://github.com/Soundwavez/dees_balls.git server/mods/dees_balls

# O alternativamente, kaeza/minetest-soccer
git clone https://github.com/kaeza/minetest-soccer.git server/mods/soccer
```

## Configuración del mundo

### `luanti-futbol.conf`

```conf
server_name = Wetlands Futbol ⚽
server_description = Campo de futbol en Luanti. Cancha, pelota, diversion!
motd = Bienvenid@ al campo de futbol! Patea la pelota con Shift. Diviertete!
server_address = luanti.gabrielpantoja.cl
server_url = https://gabrielpantoja.cl
world_name = futbol
worldname = futbol

server_announce = false

bind_address = 0.0.0.0
port = 30000
max_users = 20

creative_mode = true
enable_damage = false
enable_pvp = false
enable_fire = false
enable_tnt = false

default_game = minetest_game
mg_name = singlenode

static_spawnpoint = 0,2,0
respawn_auto = true

disallow_empty_password = false
secure.enable_security = true
disable_escape_sequences = true

default_language = es
chat_message_format = <@name> @message

dedicated_server_step = 0.09

name = gabo
admin_name = gabo
admin_privs = server,privs,ban,kick,teleport,give,settime,worldedit,fly,fast

default_privs = interact,shout,fly,fast

# Mods
load_mod_dees_balls = true
```

### `world.mt`

```
gameid = minetest_game
backend = sqlite3
player_backend = sqlite3
auth_backend = sqlite3
```

## Deploy (primera vez)

### 1. Clonar el juego base

```bash
ssh gabriel@<VPS_IP> "cd /home/gabriel/luanti-voxelibre-server && \
    git clone https://github.com/luanti-org/minetest_game.git \
    server/games/minetest_game"
```

### 2. Clonar mods

```bash
ssh gabriel@<VPS_IP> "cd /home/gabriel/luanti-voxelibre-server && \
    git clone https://github.com/Soundwavez/dees_balls.git \
    server/mods/dees_balls"
```

### 3. Crear el mundo

```bash
ssh gabriel@<VPS_IP> "sudo mkdir -p /home/gabriel/luanti-voxelibre-server/server/worlds/futbol && \
cat > /tmp/world.mt <<'EOF'
gameid = minetest_game
backend = sqlite3
player_backend = sqlite3
auth_backend = sqlite3
EOF
sudo mv /tmp/world.mt /home/gabriel/luanti-voxelibre-server/server/worlds/futbol/world.mt && \
sudo chown -R 1000:1000 /home/gabriel/luanti-voxelibre-server/server/worlds/futbol"
```

### 4. Abrir puerto UDP 30004

**Oracle Cloud Security List** (consola web):
- Source CIDR: `0.0.0.0/0`
- IP Protocol: `UDP`
- Destination Port Range: `30004`
- Description: `Luanti Futbol`

**Firewall del host:**
```bash
ssh gabriel@<VPS_IP> "sudo ufw allow 30004/udp"
```

### 5. Agregar servicio a `docker-compose.yml`

```yaml
  luanti-futbol:
    image: linuxserver/luanti:latest
    container_name: luanti-futbol-server
    restart: unless-stopped
    ports:
      - "30004:30000/udp"
    volumes:
      - ./server/config/luanti-futbol.conf:/config/.minetest/main-config/minetest.conf
      - ./server/mods:/config/.minetest/mods
      - ./server/worlds/futbol:/config/.minetest/worlds/futbol
      - ./server/games:/config/.minetest/games
    environment:
      - PUID=1000
      - PGID=1000
      - TZ=America/Santiago
      - CLI_ARGS=--worldname futbol
    depends_on:
      - luanti-server
    networks:
      - luanti-network
```

### 6. Levantar

```bash
ssh gabriel@<VPS_IP> "cd /home/gabriel/luanti-voxelibre-server && \
    docker compose up -d luanti-futbol"
```

### 7. Verificar

```bash
ssh gabriel@<VPS_IP> "docker logs --since=2m luanti-futbol-server 2>&1 | \
    grep -iE 'error|warning|listening|dees_balls|minetest_game'"
```

## Construcción de la cancha

Una vez el servidor esté arriba, un admin construye la cancha con WorldEdit:

1. Entrar al mundo con privilegios `worldedit`
2. Construir campo de fútbol:
   - Césped verde (`default:dirt_with_grass` o `wool:green`)
   - Líneas con lana blanca (`wool:white`)
   - Arcos: usar nodos de `soccer:goal` (si usamos kaeza/minetest-soccer) o construir con nodos cualquiera
   - Valla perimetral (`default:fence_wood`)
3. Usar `//copy`, `//move`, `//stack` para agilizar

## Archivos del proyecto

| Archivo | Rol |
|---|---|
| `server/games/minetest_game/` | Juego base oficial de Luanti |
| `server/mods/dees_balls/` | Mod de pelotas con física (Fase 1) |
| `server/config/luanti-futbol.conf` | Config del mundo |
| `docker-compose.yml` | Servicio `luanti-futbol` |
| `server/worlds/futbol/world.mt` | Compuerta del mundo |
