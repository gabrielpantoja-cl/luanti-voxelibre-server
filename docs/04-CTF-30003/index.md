# Proyecto CTF — Capture The Flag (rubenwardy)

Cuarto mundo del servidor Wetlands: el juego **Capture The Flag** de rubenwardy
(`MT-CTF/capturetheflag`). **No usa VoxeLibre** — es un juego independiente de Luanti con
su propio mapa, armas, mecánicas de banderas y rondas. Swords, guns, grenades,_capture the flag.

## Resumen

| Item | Valor |
|---|---|
| Puerto público | **30003/UDP** |
| Container | `luanti-ctf-server` |
| Config | `server/config/luanti-ctf.conf` |
| Juego | `server/games/capturetheflag/` (clonado desde GitHub con `--recursive`) |
| Mundo | `server/worlds/ctf/` (gitignored, se crea en el VPS) |
| Mapgen | `singlenode` + `backend = dummy` (recomendado para servidores públicos) |
| Fuente | https://github.com/MT-CTF/capturetheflag |
| Notifier Discord | `discord-notifier-ctf` (label `CTF ⚔️`) |

## Instalación del juego

El juego se clona desde GitHub con submodules:

```bash
git clone --recursive https://github.com/MT-CTF/capturetheflag.git server/games/capturetheflag
```

> ⚠️ El `--recursive` es obligatorio: el juego usa submodules. Sin eso faltan mods internos.

También se puede descargar desde ContentDB (`content.luanti.org/packages/rubenwardy/capturetheflag`),
pero la versión git siempre está más actualizada.

## Cómo funciona

- Mapa generado con `singlenode` (sin terreno por defecto); el juego genera su propio terreno.
- `backend = dummy` — no escribe mapa a disco (recomendado para servidores públicos, más rápido).
- `enable_damage = true`, `creative_mode = false`.
- Rondas automáticas: cuando todos los jugadores entran, empieza una ronda.
- Armas incluidas: swords, guns, grenades, y más.
- Dos equipos capturan la bandera del otro.

## Configuración del mundo

### `world.mt`

```
gameid = capturetheflag
backend = dummy
```

### `luanti-ctf.conf`

```conf
gameid = capturetheflag
mg_name = singlenode
enable_damage = true
creative_mode = false
```

## Deploy (primera vez)

### 1. Clonar el juego en el VPS

```bash
ssh gabriel@<VPS_IP> "cd /home/gabriel/luanti-voxelibre-server && \
    git clone --recursive https://github.com/MT-CTF/capturetheflag.git \
    server/games/capturetheflag"
```

### 2. Crear el mundo

```bash
ssh gabriel@<VPS_IP> "mkdir -p /home/gabriel/luanti-voxelibre-server/server/worlds/ctf && \
cat > /home/gabriel/luanti-voxelibre-server/server/worlds/ctf/world.mt <<'EOF'
gameid = capturetheflag
backend = dummy
EOF"

ssh gabriel@<VPS_IP> "sudo chown -R 1000:1000 /home/gabriel/luanti-voxelibre-server/server/worlds/ctf"
```

### 3. Puerto 30003/UDP

**a) Oracle Cloud Security List** (consola web):
- Source CIDR: `0.0.0.0/0`
- IP Protocol: `UDP`
- Destination Port Range: `30003`
- Description: `Luanti CTF`

**b) Firewall del host:**
```bash
ssh gabriel@<VPS_IP> "sudo ufw allow 30003/udp"
```

### 4. Levantar containers

```bash
ssh gabriel@<VPS_IP> "cd /home/gabriel/luanti-voxelibre-server && \
    docker compose up -d luanti-ctf discord-notifier-ctf"
```

### 5. Verificar

```bash
ssh gabriel@<VPS_IP> "docker logs --since=2m luanti-ctf-server 2>&1 | \
    grep -iE 'error|warning|listening|capturetheflag'"
```

Conectarse a `luanti.gabrielpantoja.cl:30003`. Debería empezar una ronda automáticamente.

## Archivos del proyecto

| Archivo | Rol |
|---|---|
| `server/games/capturetheflag/` | Juego CTF de rubenwardy (clonado con `--recursive`) |
| `server/config/luanti-ctf.conf` | Config del mundo |
| `docker-compose.yml` | Servicios `luanti-ctf` + `discord-notifier-ctf` |
| `server/worlds/ctf/world.mt` | Compuerta del mundo (se crea en el VPS) |
