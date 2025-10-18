# 👨‍💼 Documentación de Administración

Guías para administradores del servidor Wetlands Valdivia sobre gestión de usuarios, seguridad y operaciones.

## 📋 Contenido

- **[Usuarios y Privilegios](usuarios-y-privilegios.md)** - Gestión de cuentas de usuario y permisos
- **[Comandos de Admin](comandos-admin.md)** - Comandos administrativos disponibles
- **[Seguridad y Bloqueos](seguridad-y-bloqueos.md)** - Protección contra usuarios problemáticos
- **[Ubicaciones y Coordenadas](ubicaciones-coordenadas.md)** - Puntos importantes del servidor

## ⚠️ Acceso Requerido

Para ejecutar comandos administrativos necesitas:
- Acceso SSH al VPS: `ssh gabriel@<VPS_HOST_IP>`
- Privilegios de administrador en el servidor Luanti
- Conocimiento de la base de datos SQLite del servidor

## 🚨 Procedimientos de Emergencia

En caso de problemas graves del servidor:
1. Consultar [Operations/Troubleshooting](../operations/troubleshooting.md)
2. Revisar [Backup System](../operations/backups.md) para recuperación
3. Aplicar medidas de seguridad si es necesario

## 🔒 Archivos Privados (No Versionados)

Los siguientes archivos contienen información sensible y están excluidos del repositorio Git mediante `.gitignore`:

### Información de Usuarios
- `analisis-usuarios-30-dias.md` - Análisis de actividad con nombres de usuario y posibles IPs
- `estado-usuarios-actual.md` - Estado actual de cuentas con datos personales

### Información de Seguridad
- `seguridad-y-bloqueos.md` - IPs bloqueadas y medidas de seguridad
- `ubicaciones-coordenadas.md` - Coordenadas exactas (grief prevention)

### Configuración de Infraestructura
- `SISTEMA_ACTUAL_VPS_2025-10-11.md` - Configuración del VPS con credenciales
- `DNS_CONFIG.md` - Configuración DNS completa del dominio gabrielpantoja.cl

**⚠️ Importante**: Estos archivos existen localmente pero **NO deben ser commiteados** a GitHub. Si necesitas compartir información, crea versiones sanitizadas sin datos sensibles.