# 👨‍💼 admin/ — Administración

Índice completo en [`../README.md`](../README.md). Documentos de esta carpeta (aplican a **todos los
mundos** salvo que se indique):

| Archivo | Descripción |
|---------|-------------|
| [comandos-admin.md](comandos-admin.md) | Comandos administrativos de Luanti/VoxeLibre |
| [VOXELIBRE_SERVER_SETTINGS.md](VOXELIBRE_SERVER_SETTINGS.md) | Configuración del servidor desde la interfaz del cliente |
| [QUICK_ADD_SKINS.md](QUICK_ADD_SKINS.md) | Workflow rápido para agregar skins |
| [SKINS_INVENTORY.md](SKINS_INVENTORY.md) | Catálogo de skins disponibles |
| [TROUBLESHOOTING_MCL_POTIONS_BUG.md](TROUBLESHOOTING_MCL_POTIONS_BUG.md) | Bug de `mcl_potions` de VoxeLibre y su fix |
| [agentes-claude.md](agentes-claude.md) | Agentes especializados de Claude para este repositorio |

## ⚠️ Acceso requerido

Para comandos administrativos necesitas acceso SSH al VPS, privilegios de admin en el servidor
Luanti (el admin es `gabo`) y, para editar privilegios, saber consultar la `auth.sqlite` del mundo.

## 🔒 Documentación sensible (repo privado)

Análisis de usuarios, IPs bloqueadas, coordenadas privadas, credenciales del VPS y config DNS viven
en el **repo privado** `infra/privado/luanti/` — nunca en este repo público.

## Ver también

- Privilegios por mundo: cada carpeta de mundo (ej. [`../../02-VALDIVIA-30001/operaciones/PRIVILEGIOS.md`](../../02-VALDIVIA-30001/operaciones/PRIVILEGIOS.md)).
- Gestión del inventario creativo de Wetlands: [`../../01-ORIGINAL-30000/admin/CREATIVE_INVENTORY_MANAGEMENT.md`](../../01-ORIGINAL-30000/admin/CREATIVE_INVENTORY_MANAGEMENT.md).
