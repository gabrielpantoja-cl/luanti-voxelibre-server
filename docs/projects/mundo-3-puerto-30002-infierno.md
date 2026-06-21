# Proyecto INFIERNO — Mundo caos destructible

Tercer mundo del servidor Wetlands, copia destructible del mundo principal (puerto 30000) para que los jugadores puedan destruir libremente sin afectar al original. Nombre sugerido por el hijo de Gabriel.

## Resumen

| Item | Valor |
|---|---|
| Puerto público | **30002/UDP** |
| Container | `luanti-infierno-server` |
| Config | `server/config/luanti-infierno.conf` |
| Mundo | `server/worlds/infierno/` (gitignored, ~880 MB clonados de `world/`) |
| Origen | Snapshot del mundo Wetlands (puerto 30000) via `sqlite3 .backup` |
| Reset | `scripts/reset-infierno.sh` cuando el caos llega muy lejos |

## Diferencias clave vs Wetlands

| Setting | Wetlands (30000) | Infierno (30002) |
|---|---|---|
| `enable_pvp` | false (solo en arena) | **true** (todo el mundo) |
| `enable_fire` | false | **true** |
| `enable_tnt` | false | **true** |
| `mobs_griefing` | false | **true** |
| `wetlands_no_creeper` | true (sin creepers) | **false** (creepers ON) |
| `pvp_arena` mod | true | **false** (no hace falta) |
| `voxelibre_protection` | true | **false** |
| ctf_guns | true | **true** (mismo set) |

## Deploy (primera vez)

Pre-requisitos:
- Mundo Wetlands corriendo en VPS (puerto 30000) con CTF guns ya cargado
- VPS tiene `sqlite3` instalado (`sudo apt install sqlite3` si falta)
- Acceso root/sudo en el VPS

### 1. Push del código local
```bash
git add docker-compose.yml server/config/luanti-infierno.conf \
        scripts/setup-infierno-world.sh scripts/reset-infierno.sh \
        .gitignore docs/projects/mundo-3-puerto-30002-infierno.md
git commit -m "feat(infierno): add chaos world on port 30002 — copy of Wetlands for destruction"
git push origin main
```

### 2. Pull en VPS y seed del mundo
```bash
ssh gabriel@<VPS_IP> "cd /home/gabriel/luanti-voxelibre-server && \
    git pull origin main && \
    chmod +x scripts/setup-infierno-world.sh scripts/reset-infierno.sh"

# El setup hace hot-copy del mundo principal SIN parar el container 30000
ssh gabriel@<VPS_IP> "cd /home/gabriel/luanti-voxelibre-server && \
    sudo ./scripts/setup-infierno-world.sh"
```

### 3. Abrir puerto UDP 30002 en el firewall

**a) Oracle Cloud Security List** (consola web — paso manual):
- Networking → Virtual Cloud Networks → tu VCN → Security Lists
- Agregar Ingress Rule:
  - Source: `0.0.0.0/0`
  - IP Protocol: `UDP`
  - Destination Port Range: `30002`

**b) iptables del host VPS**:
```bash
ssh gabriel@<VPS_IP> "sudo iptables -I INPUT -p udp --dport 30002 -j ACCEPT && \
    sudo netfilter-persistent save 2>&1 || sudo iptables-save | sudo tee /etc/iptables/rules.v4"
```

(En Oracle Linux puede ser `firewall-cmd --add-port=30002/udp --permanent && firewall-cmd --reload`.)

### 4. Levantar containers
```bash
ssh gabriel@<VPS_IP> "cd /home/gabriel/luanti-voxelibre-server && \
    docker compose up -d luanti-infierno discord-notifier-infierno"
```

### 5. Verificar
```bash
# Logs sin errores
ssh gabriel@<VPS_IP> "docker logs --since=2m luanti-infierno-server 2>&1 | \
    grep -iE 'error|warning|listening|ctf'"

# Probar conexion
nc -uv luanti.gabrielpantoja.cl 30002
```

Conectarse en cliente Luanti a `luanti.gabrielpantoja.cl:30002`.

## Operación

### Reset cuando se pasa el caos
```bash
ssh gabriel@<VPS_IP> "cd /home/gabriel/luanti-voxelibre-server && \
    sudo ./scripts/reset-infierno.sh"
```
Esto:
1. Detiene el container `luanti-infierno`
2. Mueve `infierno/` a `infierno_DESTROYED_<timestamp>/` (backup)
3. Re-clona desde el mundo principal vía `setup-infierno-world.sh`
4. Re-arranca el container

Tiempo: ~10-30s. Los jugadores reciben kick durante la operación.

### Limpieza de backups antiguos (>7 días)
```bash
sudo find /home/gabriel/luanti-voxelibre-server/server/worlds \
    -maxdepth 1 -type d -name 'infierno_DESTROYED_*' -mtime +7 \
    -exec rm -rf {} +
```

### Logs en vivo
```bash
ssh gabriel@<VPS_IP> "docker logs -f luanti-infierno-server"
```

## Recursos esperados (medición Apr 2026)

VPS Oracle ARM (24 GB RAM total):
- Wetlands (30000): 328 MB RAM, 2.9% CPU
- Valdivia (30001): 287 MB RAM, 0.31% CPU
- Infierno (30002): estimado ~350 MB RAM idle, hasta ~600 MB con jugadores activos

Total estimado: ~1 GB RAM combinada con los 3 mundos. Headroom: 23 GB.

Disco: cada reset deja un `infierno_DESTROYED_*` de ~880 MB. Limpiar periódicamente.

## Recordatorios de seguridad

- **Auth aislada**: Infierno tiene su propio `auth.sqlite` clonado del original al momento del setup. Cambios de password posteriores en uno **NO** se propagan al otro.
- **Player progress aislado**: muertes en Infierno no afectan al mundo principal.
- **Banner explícito en MOTD**: jugadores ven "Aquí PUEDES destruir" al conectar — diseñado para evitar confusión con el mundo principal.
- **Edad recomendada**: este mundo permite PvP pleno. El landing page debería marcarlo como "10+" o similar para diferenciarlo del mundo familiar 7+ del puerto 30000.
