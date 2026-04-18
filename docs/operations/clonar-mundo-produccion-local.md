# Clonar el mundo de producción para jugar en local

Guía para sacar una copia del mundo Wetlands (puerto 30000) desde el VPS y levantarla en tu PC, sin riesgo para el servidor oficial. Útil para pruebas destructivas, experimentos con mods, o partidas LAN con amigos.

## Prerrequisitos

- Acceso SSH al VPS (`<VPS_USER>@<VPS_IP>`)
- Docker + Docker Compose v2 instalados localmente (`docker compose`, con espacio)
- Permisos de `sudo` si necesitas arrancar el daemon de Docker o abrir firewall
- ~2 GB libres en disco (el tar pesa ~1.5 GB, el mundo extraído ~900 MB)

## Por qué usar un backup y no copiar el mundo activo

Si haces `tar` del mundo mientras el servidor corre, SQLite va a estar escribiendo y vas a obtener:

```
tar: world/map.sqlite: file changed as we read it
tar: Exiting with failure status due to previous errors
```

Los backups automáticos del VPS (`./scripts/backup.sh` vía `backup-cron`) corren cada 12h y capturan un estado consistente desde el volumen de solo lectura. **Siempre usa uno de esos en vez de tarear el mundo en vivo.**

## Paso 1 — Elegir el backup más reciente

Los backups viven en dos lugares dentro del VPS (mismo volumen Docker):

- Host: `/home/<VPS_USER>/luanti-voxelibre-server/server/backups/`
- Contenedor: `/backups/` (dentro de `luanti-voxelibre-server`)

```bash
ssh <VPS_USER>@<VPS_IP> "ls -lht /home/<VPS_USER>/luanti-voxelibre-server/server/backups/ | head -10"
```

Toma el más reciente (formato `vegan_wetlands_backup_YYYYMMDD-HHMMSS.tar.gz`).

## Paso 2 — Descargar el backup al repo local

```bash
cd ~/Developer/personal/luanti-voxelibre-server

scp <VPS_USER>@<VPS_IP>:/home/<VPS_USER>/luanti-voxelibre-server/server/backups/vegan_wetlands_backup_YYYYMMDD-HHMMSS.tar.gz \
    server/backups/
```

Verifica integridad comparando SHA256 contra el VPS:

```bash
sha256sum server/backups/vegan_wetlands_backup_*.tar.gz
ssh <VPS_USER>@<VPS_IP> "sha256sum /home/<VPS_USER>/luanti-voxelibre-server/server/backups/vegan_wetlands_backup_*.tar.gz"
```

Ambos hashes deben coincidir.

## Paso 3 — Respaldar el mundo local actual

El repo ya tiene un `server/worlds/world/` (copia de referencia, gitignored). No lo borres — renómbralo fuera de `worlds/` por si quieres volver.

```bash
cd server/worlds
mv world "world_BEFORE_PROD_COPY_$(date +%Y%m%d_%H%M%S)"
```

Luego **muévelo fuera** del directorio `worlds/` (ver Paso 5).

## Paso 4 — Extraer el backup

El tar de `backup.sh` contiene `./world/` (y a veces otros `world_BACKUP_*/` que haya en el VPS en ese momento — el script usa `tar -C /worlds .`).

```bash
cd ~/Developer/personal/luanti-voxelibre-server/server/worlds
tar -xzf ../backups/vegan_wetlands_backup_YYYYMMDD-HHMMSS.tar.gz
ls
```

Deberías ver `world/` (el de producción) y posiblemente otros `world_BACKUP_*/`.

## Paso 5 — CRÍTICO: Sacar cualquier directorio `world_*` del camino

**Luanti hace matching fuzzy** con `--worldname`: si hay varios directorios que empiezan con `world` dentro de `worlds/`, puede cargar el equivocado. Síntoma: la bandera dice `--worldname world` pero los logs muestran `World at [...worlds/world_BACKUP_XXX]`.

Mueve todos los `world_BACKUP_*` y `world_BEFORE_PROD_COPY_*` fuera:

```bash
cd ~/Developer/personal/luanti-voxelibre-server
mkdir -p server/worlds_archive
mv server/worlds/world_BACKUP_* server/worlds/world_BEFORE_PROD_COPY_* server/worlds_archive/ 2>/dev/null
ls server/worlds/
# Debe mostrar SOLO: valdivia  world
```

## Paso 6 — Arrancar Docker (si está apagado)

```bash
sudo systemctl start docker
systemctl is-active docker   # debe decir "active"
```

## Paso 7 — Levantar SOLO el contenedor de Wetlands

No uses `./scripts/start.sh` (levanta todo: Valdivia, Discord, backup-cron). Lanza solo el servicio que necesitas:

```bash
cd ~/Developer/personal/luanti-voxelibre-server
docker compose up -d luanti-server
```

Verifica:

```bash
docker ps --filter "name=luanti-voxelibre-server" --format "{{.Names}}: {{.Status}}"
docker logs luanti-voxelibre-server 2>&1 | grep -E "World at|listening on"
```

Debe mostrar:

```
World at [/config/.minetest/worlds/world]
Server for gameid="mineclone2" listening on [::]:30000.
```

Si dice `World at [...worlds/world_BACKUP_...]`, vuelve al Paso 5.

## Paso 8 — Conectarse

### Tú (misma máquina que el servidor)

- Dirección: `localhost` o `127.0.0.1`
- Puerto: `30000`

### Amigo en la misma WiFi/LAN

- Dirección: IP LAN de tu PC (averígualo con `ip addr | grep 'inet '` — típicamente `192.168.x.y`)
- Puerto: `30000`
- Nada más que configurar si tu PC no tiene firewall activo

Si el firewall bloquea, permite UDP 30000 en la LAN:

```bash
sudo ufw allow from 192.168.0.0/16 to any port 30000 proto udp
```

### Amigo por internet (fuera de tu red)

1. Port forwarding en tu router: `UDP 30000 → <IP_LAN_de_tu_PC>:30000`
2. Firewall local: `sudo ufw allow 30000/udp`
3. Tu amigo conecta a `<tu_IP_pública>:30000` (`curl ifconfig.me`)
4. Si tu ISP usa **CGNAT** (IP WAN del router en `100.64.0.0/10`), el port forwarding no sirve. Alternativas: **Tailscale**, **ZeroTier** o **Playit.gg** (túnel UDP gratis).

## Cuentas de usuario

El `auth.sqlite` del backup trae todos los usuarios de producción con sus privilegios. Consecuencias:

- Tu cuenta de admin funciona tal cual en local.
- Tu amigo puede usar su cuenta existente (si ya jugó en el servidor oficial).
- Si nunca jugó, puede crear una cuenta nueva al conectarse.
- **Nada de lo que hagan acá afecta al servidor oficial del VPS.**

## Volver al mundo local original

Cuando termines de jugar/destruir:

```bash
cd ~/Developer/personal/luanti-voxelibre-server
docker compose stop luanti-server

# Elimina la copia de producción
rm -rf server/worlds/world

# Restaura el mundo local anterior
mv server/worlds_archive/world_BEFORE_PROD_COPY_* server/worlds/world
```

## Limpiar

Cuando ya no necesites la copia:

```bash
# El tarball original (si no lo quieres guardar)
rm server/backups/vegan_wetlands_backup_YYYYMMDD-HHMMSS.tar.gz

# Mundos archivados
rm -rf server/worlds_archive/
```

## Pitfalls documentados

| Síntoma | Causa | Solución |
|---------|-------|----------|
| `tar: file changed as we read it` | Hiciste tar del mundo en vivo | Usa un backup de `/backups`, no copies en caliente |
| Carga `world_BACKUP_XXX` en vez de `world` | Luanti fuzzy-matcheó `--worldname world` | Mueve todos los `world_*` fuera de `worlds/` (Paso 5) |
| `docker-compose: command not found` | Tienes Docker v2 (comando es `docker compose` con espacio) | Usa `docker compose` en vez de `docker-compose` |
| Se conecta Valdivia/Discord solo | `./scripts/start.sh` levanta todo | Usa `docker compose up -d luanti-server` |
| Amigo no puede entrar por IP pública | CGNAT del ISP | Tailscale / ZeroTier / Playit.gg |

## Referencia cruzada

- `docs/config/01-CONFIGURATION_HIERARCHY.md` — cómo interactúan `luanti.conf` y `world.mt`
- `docs/operations/BACKUP_STATUS.md` — estado del sistema automático de backups
- `scripts/backup.sh` — script que genera los tarballs en el VPS
- `scripts/sync-from-vps.sh` — sync selectivo VPS→local para archivos git-trackeados (otro caso de uso)
