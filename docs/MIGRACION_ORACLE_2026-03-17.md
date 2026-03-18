# Migracion Luanti: DigitalOcean -> Oracle Cloud

> **Fecha**: 2026-03-17
> **Estado**: COMPLETADO
> **Downtime**: ~30 segundos (para backup limpio del mundo)

## Resumen

El servidor Luanti (Wetlands) fue migrado de DigitalOcean ($33/mes) a Oracle Cloud Free Tier ($0/mes) el 17 de marzo de 2026. La migracion fue exitosa sin perdida de datos.

## Antes y despues

| Campo | DigitalOcean (antes) | Oracle Cloud (ahora) |
|-------|---------------------|---------------------|
| IP | 167.172.251.27 | **159.112.138.229** |
| CPU | 2 vCPU x86 AMD | 4 OCPU ARM Ampere A1 |
| RAM | 4 GB (compartida) | 24 GB (compartida) |
| Disco | 80 GB SSD | 200 GB block storage |
| Arquitectura | x86_64 | **aarch64 (ARM)** |
| OS | Ubuntu | Ubuntu 24.04 ARM |
| Costo | $33.32 USD/mes | $0 USD/mes |
| Docker | Docker Compose v2 | Docker 29.3.0 + Compose 5.1.0 |
| Region | NYC (DigitalOcean) | sa-santiago-1 (Chile) |

## Que se migro

| Componente | Tamano | Estado |
|-----------|--------|--------|
| Mundo (server/worlds/) | 1.8 GB | OK - todas las construcciones intactas |
| Mods (server/mods/) | 77 MB | OK - 36 mods cargando |
| Games (server/games/) | 98 MB | OK - VoxeLibre v0.90.1 |
| Config (server/config/) | 80 KB | OK - luanti.conf preservado |
| Discord notifier | - | OK - webhook funcionando |
| Backup cron | - | OK - cada 12h |

## Cambios en infraestructura

### Docker
- La imagen `linuxserver/luanti:latest` soporta arm64 nativamente - no requirio cambios
- Los 3 containers (server, backup-cron, discord-notifier) funcionan identico en ARM

### Red
- Puerto 30000/UDP abierto en **dos capas**: OCI Security List + UFW
- Oracle tiene iptables restrictivas por defecto que fueron limpiadas

### DNS
- `luanti.gabrielpantoja.cl` -> 159.112.138.229 (Cloudflare, DNS only, TTL auto)
- DNS only (nube gris) es necesario porque Cloudflare proxy no soporta UDP

### SSL
- Let's Encrypt via certbot para landing page HTTPS
- Certificado: luanti.gabrielpantoja.cl (expira 2026-06-15)
- Auto-renovacion configurada via certbot timer

## Proceso de migracion

1. Verificar que no hay jugadores conectados (logs: ultimo jugador salio 2026-03-16 17:01)
2. Parar Luanti en DO (30s)
3. Crear backup: `tar czf` de worlds+mods+games+config (1.1 GB)
4. Reiniciar Luanti en DO inmediatamente
5. Transferir backup: DO -> PC local -> Oracle (DO no tenia SSH key de Oracle)
6. Clonar repo en Oracle: `git clone`
7. Extraer backup en el repo
8. Crear `.env` con DISCORD_WEBHOOK_URL
9. `docker compose up -d`
10. Verificar conexion directa por IP
11. Actualizar DNS en Cloudflare
12. Configurar SSL con certbot
13. Apagar Luanti en DO: `docker compose down`
14. Test final: conexion por dominio exitosa

## Conexion SSH al servidor

```bash
# Como gabriel (usuario admin)
ssh -i ~/.ssh/id_ed25519 gabriel@159.112.138.229

# Directorio del servidor
cd /home/gabriel/luanti-voxelibre-server

# Ver containers
docker ps

# Ver logs del servidor
docker logs -f luanti-voxelibre-server

# Reiniciar servidor
docker compose restart luanti-server
```

## Pendientes post-migracion

- [ ] Hardening docker-compose (read_only, cap_drop, no-new-privileges)
- [ ] Configurar landing page custom en nginx (actualmente sirve default nginx)
- [ ] Migrar DNS de pitutito.cl a Oracle
- [ ] Verificar que backups automaticos (cada 12h) funcionan correctamente
- [ ] Monitorear rendimiento ARM vs x86 las primeras semanas

## Rollback

Si algo falla, los datos originales siguen en DO:
1. Cambiar DNS en Cloudflare: luanti.gabrielpantoja.cl -> 167.172.251.27
2. En DO: `cd /home/gabriel/luanti-voxelibre-server && docker compose up -d`
3. Los datos del mundo no fueron eliminados de DO
