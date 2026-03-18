# 🔒 Documentación Administrativa Privada

**⚠️ ADVERTENCIA: Este directorio contiene información sensible y NO debe versionarse en Git.**

---

## 📋 Contenido de Este Directorio

Este directorio (`docs/admin/PRIVATE/`) está diseñado para almacenar documentación administrativa que contiene:

- 🔐 **IPs de usuarios** (para análisis de seguridad)
- 👥 **Nombres de usuario reales** (información personal)
- 📍 **Coordenadas exactas** de construcciones (prevención de grief)
- 🛡️ **Incidentes de seguridad** con datos forenses
- 🔑 **Configuraciones de VPS** con rutas y detalles de infraestructura
- 🌐 **Configuración DNS** (información sensible de red)

---

## 🚫 Protección en Git

**Este directorio completo está ignorado en `.gitignore`:**

```gitignore
# Documentación administrativa privada (información sensible)
docs/admin/PRIVATE/
```

**✅ Archivos permitidos:**
- Este README.md (documentación de estructura)
- `.gitkeep` (para mantener el directorio en Git)

**❌ Archivos NO versionados:**
- Todo lo demás (reportes, análisis, logs, incidentes)

---

## 📁 Estructura Recomendada

```
docs/admin/PRIVATE/
├── README.md                          # Este archivo (público)
├── .gitkeep                           # Mantiene directorio en Git
├── usuarios/                          # Análisis de usuarios
│   ├── estado-usuarios-YYYY-MM-DD.md
│   ├── analisis-30-dias.md
│   └── privilegios-audit.md
├── seguridad/                         # Incidentes y seguridad
│   ├── incidente-YYYY-MM-DD.md
│   ├── ips-bloqueadas.md
│   └── forensic-reports/
├── ubicaciones/                       # Coordenadas sensibles
│   ├── construcciones-importantes.md
│   ├── areas-protegidas-detalle.md
│   └── spawn-zones.md
└── infraestructura/                   # Configuración de servidor
    ├── vps-config-actual.md
    ├── dns-setup.md
    └── backup-procedures.md
```

---

## 🔄 Migración de Archivos Existentes

**Archivos a mover aquí desde `docs/admin/`:**

```bash
# Análisis de usuarios (contiene nombres, IPs)
mv docs/admin/estado-usuarios-actual.md docs/admin/PRIVATE/usuarios/
mv docs/admin/analisis-usuarios-30-dias.md docs/admin/PRIVATE/usuarios/

# Seguridad (IPs de atacantes, cuentas bloqueadas)
mv docs/admin/seguridad-y-bloqueos.md docs/admin/PRIVATE/seguridad/

# Ubicaciones (coordenadas exactas)
mv docs/admin/ubicaciones-coordenadas.md docs/admin/PRIVATE/ubicaciones/

# Infraestructura (configuración VPS)
mv docs/admin/SISTEMA_ACTUAL_VPS_2025-10-11.md docs/admin/PRIVATE/infraestructura/
mv docs/admin/DNS_CONFIG.md docs/admin/PRIVATE/infraestructura/
```

---

## 📝 Buenas Prácticas

### ✅ SÍ Versionar en Git (docs/admin/)

Documentación técnica **sin datos sensibles**:
- Guías de administración generales
- Comandos de ejemplo (sin IPs reales)
- Troubleshooting de mods
- Tutoriales de configuración
- Arquitectura del servidor (sin credenciales)

### ❌ NO Versionar (docs/admin/PRIVATE/)

Documentación con **datos sensibles**:
- Nombres de usuario reales
- IPs de jugadores o atacantes
- Coordenadas exactas de construcciones
- Configuraciones con credenciales
- Reportes forenses de incidentes
- Logs con información personal

---

## 🛡️ Backup de Archivos Privados

**Estos archivos deben respaldarse por separado del repositorio Git:**

```bash
# Backup local (fuera del repo)
cp -r docs/admin/PRIVATE/ ~/backups/wetlands-private-docs-$(date +%Y%m%d)/

# Backup en VPS (si es necesario)
scp -r docs/admin/PRIVATE/ gabriel@<IP_VPS_ANTERIOR>:~/wetlands-private-backups/
```

**⚠️ NUNCA hacer commit de archivos de `PRIVATE/` excepto este README.**

---

## 🔍 Verificación de Seguridad

**Antes de cada commit, verificar:**

```bash
# Ver qué archivos se van a commitear
git status

# Verificar que no hay archivos de PRIVATE/
git diff --cached --name-only | grep PRIVATE

# Si aparece algo, usar:
git reset HEAD docs/admin/PRIVATE/archivo-sensible.md
```

---

## 📞 Contacto

Si necesitas acceso a documentación privada:
- **Administrador:** Gabriel Pantoja
- **Ubicación física:** VPS <IP_VPS_ANTERIOR> (solo SSH)
- **Backup local:** ~/Documentos/luanti-voxelibre-server/docs/admin/PRIVATE/

---

**🔒 Principio fundamental: La seguridad de los usuarios es primero. Protege su información.**