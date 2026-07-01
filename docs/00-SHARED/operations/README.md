# 🔧 operations/ — Operaciones y mantenimiento

Índice completo en [`../README.md`](../README.md). Documentos de esta carpeta:

| Archivo | Descripción |
|---------|-------------|
| [BACKUP_STATUS.md](BACKUP_STATUS.md) | Estado y plan del sistema de backups (sidecar `backup-cron`) |
| [clonar-mundo-produccion-local.md](clonar-mundo-produccion-local.md) | Descargar un backup del VPS y correrlo localmente para pruebas/LAN |
| [MCP_SERVERS.md](MCP_SERVERS.md) | Servidores MCP disponibles |

## 🔒 Operaciones sensibles (repo privado)

Deploy detallado, recuperación de texturas, sync con VPS, credenciales y troubleshooting profundo
viven en el **repo privado** `infra/privado/luanti/operations/`. Los comandos de deploy y las
convenciones de `git pull` en el VPS también están en el [`AGENTS.md`](../../../AGENTS.md) raíz.

## Comandos rápidos

```bash
docker compose ps                          # estado de contenedores
docker compose logs -f luanti-server       # logs (usar --since en el VPS para evitar ruido)
docker compose restart luanti-<mundo>      # reinicio de un mundo
```

## Bugs de operación por mundo

- [Servidor duplicado en la lista pública de Luanti](../../02-VALDIVIA-30001/operaciones/SERVER_LIST_DUPLICATE_BUG.md)
  — la imagen `linuxserver/luanti` hardcodea `--port 30000`; afecta a cualquier mundo con puerto ≠ 30000.
