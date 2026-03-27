# 📚 Documentación Wetlands Valdivia

Documentación técnica completa del servidor Luanti educativo y compasivo para niños 7+ años.

## 🚀 Inicio Rápido

### Para Nuevos Jugadores
- **[Conexión Básica](quickstart/conexion-basica.md)** - Cómo descargar Luanti y conectarse
- **[Primeros Pasos](quickstart/primeros-pasos.md)** - Tutorial completo para comenzar

### Para Administradores
- **[Guía de Administración](admin/usuarios-y-privilegios.md)** - Gestión de usuarios y privilegios
- **[Comandos de Admin](admin/comandos-admin.md)** - Comandos administrativos disponibles
- **[Modos Mixtos (Creativo + Supervivencia)](config/MIXED_GAMEMODE_CONFIGURATION.md)** - Sistema de coexistencia de modos de juego
- **[Sistema de Skins](admin/QUICK_ADD_SKINS.md)** - Agregar skins personalizadas rápidamente

### Para Desarrolladores
- **[Sistema de Mods](mods/README.md)** - Desarrollo y documentación de mods
- **[Deploy y CI/CD](operations/deploy.md)** - Procedimientos de despliegue

## 📁 Estructura de Documentación

### 🚀 [quickstart/](quickstart/)
Guías para nuevos jugadores y conexión inicial
- **[Conexión Básica](quickstart/conexion-basica.md)** - Descargar Luanti y conectarse al servidor
- **[Primeros Pasos](quickstart/primeros-pasos.md)** - Tutorial inicial para nuevos jugadores

### 👨‍💼 [admin/](admin/)
Documentación de administración del servidor
- **[Usuarios y Privilegios](admin/USER_PRIVILEGES.md)** - Gestión de cuentas y permisos
- **[Comandos de Admin](admin/comandos-admin.md)** - Comandos administrativos disponibles
- **[Ubicaciones y Coordenadas](admin/ubicaciones-coordenadas.md)** - Puntos importantes del servidor
- **[Cárcel de Baneo](admin/CARCEL_DE_BANEO.md)** - Sistema de moderación y bans
- **[Quick Add Skins](admin/QUICK_ADD_SKINS.md)** - Workflow rápido para agregar skins
- **[Inventario de Skins](admin/SKINS_INVENTORY.md)** - Catálogo completo de skins disponibles

### ⚙️ [config/](config/)
Configuraciones específicas del servidor
- **[Nuclear Config](config/nuclear-config.md)** - Configuraciones críticas anti-spawning de monstruos
- **[Sistema de Reglas](config/sistema-reglas.md)** - Configuración del sistema automático de reglas
- **[Protección de Bloques](config/proteccion-bloques.md)** - Sistema de protección anti-griefing
- **[Sistema VoxeLibre](config/voxelibre-system.md)** - Configuración específica del motor de juego
- **[Modos Mixtos](config/MIXED_GAMEMODE_CONFIGURATION.md)** - Creativo + Supervivencia coexistiendo
- **[Configuración de Skins](config/CUSTOM_SKINS_SETUP.md)** - Setup inicial del sistema de skins

### 🎮 [mods/](mods/)
Desarrollo y documentación de mods personalizados
- **[Education Blocks](mods/EDUCATION_BLOCKS_MOD.md)** - Bloques educativos interactivos
- **[Server Rules](mods/SERVER_RULES_MOD.md)** - Sistema automático de reglas
- **[PVP Arena System](mods/PVP_ARENA_SETUP.md)** - Sistema completo de arenas PVP
- **[Desarrollo de Mods](mods/README.md)** - Guía para crear nuevos mods

### 🔧 [operations/](operations/)
Operaciones diarias y mantenimiento del servidor
- **[Backups](operations/backups.md)** - Sistema completo de respaldos y recuperación
- **[Deploy](operations/deploy.md)** - Procedimientos de despliegue y CI/CD
- **[Troubleshooting](operations/troubleshooting.md)** - Solución de problemas comunes
- **[Texture Recovery](operations/texture-recovery.md)** - Recuperación de corrupción de texturas
- **[VPS Sync Workflow](operations/VPS_SYNC_WORKFLOW.md)** - Sincronización de cambios VPS ↔ Repositorio
- **[Migracion Oracle Cloud](operations/MIGRACION_ORACLE_2026-03-17.md)** - Migracion de VPS a Oracle Cloud ARM
- **[Playwright MCP Setup](operations/PLAYWRIGHT_MCP_SETUP.md)** - Configuración de herramientas de testing

### 🗺️ [projects/](projects/)
Proyectos especiales y expansiones del servidor
- **[Proyecto Valdivia](projects/proyecto-valdivia-luanti.md)** - Recreacion de Valdivia desde OpenStreetMap con Arnis (EN PRODUCCION, puerto 30001)

### 🌐 [web/](web/)
Frontend y desarrollo web
- **[Landing Page](web/landing-page.md)** - Desarrollo y despliegue de la página web
- **[API Docs](web/api-docs.md)** - Documentación para futuras APIs del servidor

### 📜 [legacy/](legacy/)
Documentación histórica y archivos reorganizados
- **[Guía Original del Servidor](legacy/1-guia-del-servidor.md)** - Documentación inicial del proyecto
- **[Usuarios Registrados](legacy/usuarios-registrados.md)** - Registro histórico de usuarios

## 🎯 Información del Proyecto

### Servidores en Vivo

| Servidor | Direccion | Descripcion |
|----------|-----------|-------------|
| **Wetlands** | `luanti.gabrielpantoja.cl:30000` | Mundo principal creativo/educativo con NPCs, arenas PVP, mods |
| **Valdivia 2.0** | `luanti.gabrielpantoja.cl:30001` | Recreacion real de Valdivia, Chile desde OpenStreetMap (Arnis) |

- **Landing Page**: https://luanti.gabrielpantoja.cl
- **Modo Wetlands**: Modos mixtos (Creativo + Supervivencia coexistiendo)
- **Modo Valdivia**: Creativo puro, sin mobs, vuelo libre
- **Publico**: Ninos de 7+ anos
- **Idioma**: Espanol
- **Capacidad**: Hasta 20 jugadores por servidor

### Repositorio y Arquitectura
- **Repo principal**: https://github.com/gabrielpantoja-cl/Wetlands-Valdivia.git
- **Referencia técnica**: [CLAUDE.md](../CLAUDE.md) (archivo principal para Claude Code)
- **Tecnologías**: Docker Compose + Luanti + VoxeLibre
- **VPS**: Oracle Cloud Free Tier (<VPS_IP>, ARM aarch64)

### Filosofía del Proyecto
🌱 **Compasión**: Sin violencia hacia animales ni jugadores
🎓 **Educación**: Enseñanza de valores éticos y sostenibilidad
🤝 **Cooperación**: Mecánicas de ayuda mutua y colaboración
🛡️ **Seguridad**: Ambiente protegido y apropiado para menores

## 🔍 Navegación por Necesidad

### 🆘 Emergencias y Problemas Críticos
1. **[Texture Recovery](operations/texture-recovery.md)** - Corrupción de texturas VoxeLibre
2. **[Troubleshooting](operations/troubleshooting.md)** - Problemas generales del servidor
3. **[Backups](operations/backups.md)** - Recuperación de datos del mundo
4. **[Seguridad](admin/seguridad-y-bloqueos.md)** - Bloqueo de usuarios problemáticos

### 🎮 Para Jugadores y Padres
1. **[Conexión Básica](quickstart/conexion-basica.md)** - Cómo empezar a jugar
2. **[Primeros Pasos](quickstart/primeros-pasos.md)** - Tutorial para niños
3. **[Landing Page](web/landing-page.md)** - Información web del servidor

### 👨‍💻 Para Desarrolladores
1. **[Sistema de Mods](mods/README.md)** - Desarrollo de mods VoxeLibre
2. **[Deploy](operations/deploy.md)** - CI/CD y despliegue automatizado
3. **[API Docs](web/api-docs.md)** - Futuras implementaciones web

### 👨‍💼 Para Administradores
1. **[Usuarios y Privilegios](admin/usuarios-y-privilegios.md)** - Gestión de cuentas SQLite
2. **[Comandos Admin](admin/comandos-admin.md)** - Herramientas administrativas
3. **[Nuclear Config](config/nuclear-config.md)** - Configuraciones críticas del servidor

## 🚨 Comandos de Emergencia Rápida

```bash
# Estado del servidor
docker-compose ps
docker-compose logs -f luanti-server

# Backup de emergencia
./scripts/backup.sh

# Reinicio del servidor
docker-compose restart luanti-server

# Acceso SSH al VPS
ssh -i ~/.ssh/id_ed25519 gabriel@<VPS_IP>
```

## 📊 Métricas del Proyecto

### Sistema de Backups
- **Frecuencia**: Cada 6 horas automáticamente
- **Retención**: 10 backups más recientes
- **Ubicación**: `server/backups/`
- **Tiempo de recuperación**: ~3 minutos

### Performance del Servidor
- **Uptime objetivo**: 99.5%
- **Capacidad**: 20 jugadores simultáneos
- **Modo**: Modos mixtos configurable (Creativo por defecto, Supervivencia opcional)
- **Mundo**: VoxeLibre (MineClone2) v0.90.1

### Desarrollo Activo
- **Mods personalizados**: 3 (education_blocks, server_rules, alimentacion_consciente integrado)
- **Configuraciones críticas**: Sistema nuclear anti-monstruos
- **Landing page**: Moderna, responsiva, child-friendly
- **CI/CD**: Automatizado con GitHub Actions

## 🔄 Historial de Actualizaciones

### Enero 2026 - Sistema de Modos Mixtos
- ✅ **Modos mixtos**: Creativo y supervivencia coexistiendo en el mismo mundo
- ✅ **Mensajes inclusivos**: Redacción neutral para omnívoros y veganos
- ✅ **Sistema de excepciones**: Lista configurable `survival_players` en mods
- ✅ **Documentación completa**: `MIXED_GAMEMODE_CONFIGURATION.md` con guías detalladas

### Septiembre 2025 - Reorganización Completa
- ✅ **Nueva estructura** de documentación por categorías
- ✅ **Migración** de archivos a subcarpetas organizadas
- ✅ **Mejora** de navegación y referencias cruzadas
- ✅ **Documentación** completa de procedimientos de emergencia

### Agosto 2025 - Funcionalidades Core
- ✅ Sistema de mods educativos funcionando
- ✅ Configuración nuclear anti-monstruos
- ✅ Landing page desplegada
- ✅ Sistema de backups automatizado

## 📞 Soporte y Escalación

### Niveles de Soporte
1. **Auto-servicio**: Consultar documentación relevante en esta estructura
2. **Troubleshooting**: Seguir guías de [Operations](operations/)
3. **Emergencias**: Aplicar procedimientos de emergencia documentados
4. **Escalación crítica**: Contactar administradores con información específica

### Contribuciones
- **Guía de Contribución**: Ver [CONTRIBUTING.md](../CONTRIBUTING.md) en la raíz del repositorio
- **Pull Requests**: Seguir las guías de desarrollo en [mods/](mods/)
- **Issues**: Reportar en el repositorio GitHub
- **Documentación**: Mantener actualizada después de cambios importantes

### Estructura del Equipo
- **Administrador del Servidor**: gabriel (acceso SSH completo)
- **Desarrollo**: Equipo colaborativo via GitHub
- **Moderación**: Sistema automático + supervisión manual

---

**📅 Ultima actualizacion**: 21 de Marzo, 2026
**👥 Mantenido por**: Equipo Wetlands
**📊 Version**: 3.0 (Dual World: Wetlands + Valdivia 2.0)
**🔗 Repositorio**: https://github.com/gabrielpantoja-cl/luanti-voxelibre-server.git