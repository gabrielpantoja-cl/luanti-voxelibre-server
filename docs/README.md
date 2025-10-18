# 📚 Documentación Wetlands Valdivia

Documentación técnica completa del servidor Luanti educativo y compasivo para niños 7+ años.

## 🚀 Inicio Rápido

### Para Nuevos Jugadores
- **[Conexión Básica](quickstart/conexion-basica.md)** - Cómo descargar Luanti y conectarse
- **[Primeros Pasos](quickstart/primeros-pasos.md)** - Tutorial completo para comenzar

### Para Administradores
- **[Guía de Administración](admin/usuarios-y-privilegios.md)** - Gestión de usuarios y privilegios
- **[Comandos de Admin](admin/comandos-admin.md)** - Comandos administrativos disponibles

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
- **[Usuarios y Privilegios](admin/usuarios-y-privilegios.md)** - Gestión de cuentas y permisos
- **[Comandos de Admin](admin/comandos-admin.md)** - Comandos administrativos disponibles
- **[Seguridad y Bloqueos](admin/seguridad-y-bloqueos.md)** - Protección contra usuarios problemáticos
- **[Ubicaciones y Coordenadas](admin/ubicaciones-coordenadas.md)** - Puntos importantes del servidor

### ⚙️ [config/](config/)
Configuraciones específicas del servidor
- **[Nuclear Config](config/nuclear-config.md)** - Configuraciones críticas anti-spawning de monstruos
- **[Sistema de Reglas](config/sistema-reglas.md)** - Configuración del sistema automático de reglas
- **[Protección de Bloques](config/proteccion-bloques.md)** - Sistema de protección anti-griefing
- **[Sistema VoxeLibre](config/voxelibre-system.md)** - Configuración específica del motor de juego

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

### 🌐 [web/](web/)
Frontend y desarrollo web
- **[Landing Page](web/landing-page.md)** - Desarrollo y despliegue de la página web
- **[API Docs](web/api-docs.md)** - Documentación para futuras APIs del servidor

### 📜 [legacy/](legacy/)
Documentación histórica y archivos reorganizados
- **[Guía Original del Servidor](legacy/1-guia-del-servidor.md)** - Documentación inicial del proyecto
- **[Usuarios Registrados](legacy/usuarios-registrados.md)** - Registro histórico de usuarios

## 🎯 Información del Proyecto

### Servidor en Vivo
- **URL**: `luanti.gabrielpantoja.cl:30000`
- **Landing Page**: https://luanti.gabrielpantoja.cl
- **Modo**: Creativo, sin violencia, educativo
- **Público**: Niños de 7+ años
- **Idioma**: Español
- **Capacidad**: Hasta 20 jugadores

### Repositorio y Arquitectura
- **Repo principal**: https://github.com/gabrielpantoja-cl/Wetlands-Valdivia.git
- **Referencia técnica**: [CLAUDE.md](../CLAUDE.md) (archivo principal para Claude Code)
- **Tecnologías**: Docker Compose + Luanti + VoxeLibre
- **VPS**: DigitalOcean (<VPS_HOST_IP>)

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
ssh gabriel@<VPS_HOST_IP>
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
- **Modo**: Creativo (sin PvP, sin daño)
- **Mundo**: VoxeLibre (MineClone2) v0.90.1

### Desarrollo Activo
- **Mods personalizados**: 3 (education_blocks, server_rules, alimentacion_consciente integrado)
- **Configuraciones críticas**: Sistema nuclear anti-monstruos
- **Landing page**: Moderna, responsiva, child-friendly
- **CI/CD**: Automatizado con GitHub Actions

## 🔄 Historial de Actualizaciones

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

**📅 Última actualización**: 21 de Septiembre, 2025
**👥 Mantenido por**: Equipo Wetlands Valdivia
**📊 Versión**: 2.0 (Documentación Reorganizada y Optimizada)
**🔗 Repositorio**: https://github.com/gabrielpantoja-cl/Wetlands-Valdivia.git