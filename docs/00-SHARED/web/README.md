# 🌐 web/ — Landing page e infraestructura web

La presencia web del servidor (`luanti.gabrielpantoja.cl`) cubre **todos los mundos**. Índice
completo en [`../README.md`](../README.md).

| Archivo | Descripción |
|---------|-------------|
| [landing-page.md](landing-page.md) | Arquitectura y deploy de la landing page |
| [api-docs.md](api-docs.md) | Documentación de futuras APIs del servidor |
| [nginx/luanti.gabrielpantoja.cl.conf](nginx/luanti.gabrielpantoja.cl.conf) | Config nginx de referencia (el servicio nginx real lo gestiona el repo `infra/vps-oracle`) |

## Arquitectura

- **Fuente**: `server/landing-page/` (HTML5 + CSS3 + JavaScript vanilla, responsive, child-friendly).
- **Deploy**: script con `rsync` al VPS.
- **nginx**: el archivo aquí es una **copia de referencia**. La configuración del sistema nginx (SSL,
  virtualhost) vive en el repo de infraestructura `infra/vps-oracle`, no en este repo.

```bash
# Editar y desplegar
# (ver docs/00-SHARED/web/landing-page.md para el script exacto)
curl -I https://luanti.gabrielpantoja.cl   # verificar despliegue
```
