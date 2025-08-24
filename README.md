# 🌱 Vegan Wetlands

> **Servidor Luanti vegano para niños**: Un mundo creativo, educativo y libre de violencia animal

[![Deploy Status](https://github.com/gabrielpantoja-cl/Vegan-Wetlands/workflows/Deploy%20Vegan%20Wetlands%20Server/badge.svg)](https://github.com/gabrielpantoja-cl/Vegan-Wetlands/actions)
[![Server Status](https://img.shields.io/badge/Server-Online-brightgreen)](http://luanti.gabrielpantoja.cl:30000)

## 🎮 ¡Conéctate y Juega!

**Servidor público**: `luanti.gabrielpantoja.cl:30000`

- 🌱 **100% vegano** - Sin violencia animal  
- 🎨 **Modo creativo** - Libertad total para construir
- 👶 **Para niños 7+** - Entorno seguro y educativo
- 🐮 **Santuarios** - Cuida y protege animales
- 📚 **Educativo** - Aprende sobre veganismo jugando

## 🚀 Instalación y Configuración

### Requisitos
- Docker y Docker Compose instalados
- Puerto 30000/UDP disponible
- Mínimo 2GB RAM recomendado

### Instalación Local

1. **Clona el repositorio**:
   ```bash
   git clone https://github.com/gabrielpantoja-cl/Vegan-Wetlands.git
   cd Vegan-Wetlands
   ```

2. **Inicia el servidor**:
   ```bash
   chmod +x scripts/start.sh
   ./scripts/start.sh
   ```
   
   O manualmente:
   ```bash
   docker-compose up -d
   ```

3. **Conecta desde Luanti**:
   - Servidor: `localhost:30000` (local) o `luanti.gabrielpantoja.cl:30000` (oficial)
   - Modo: Creativo
   - Nombre: el que prefieras

## 🏗️ Estructura del Proyecto

```
Vegan-Wetlands/
├── docker-compose.yml          # Configuración de contenedores
├── server/
│   ├── config/luanti.conf     # Configuración del servidor
│   ├── mods/                  # Mods veganos custom
│   ├── worlds/                # Mundos persistentes  
│   └── backups/               # Backups automáticos
├── scripts/                   # Scripts de mantenimiento
├── .github/workflows/         # CI/CD con GitHub Actions
└── docs/                      # Documentación adicional
```

## 🎮 Mods Veganos Incluidos

### 🐮 Animal Sanctuary (Santuario de Animales)
- **Propósito**: Reemplaza mecánicas violentas con cuidado animal
- **Elementos**:
  - 🚪 Puerta del Santuario: Entrada especial con mensaje de bienvenida
  - 🥕 Comedero Animal: Para alimentar animales con comida vegana
  - 🏠 Refugio Animal: Protección y comodidad para animales
  - 🧽 Cepillo Animal: Herramienta para mimar animales (reemplaza armas)
  - 🏥 Kit Médico: Para curar animales heridos
- **Comandos**: `/santuario` - información del mod

### 🥗 Vegan Foods (Comida Vegana)
- **Propósito**: Alimentación 100% vegetal nutritiva
- **Alimentos**:
  - 🍔 Hamburguesa Vegana
  - 🥛 Leche de Avena  
  - 🧀 Queso Vegano
  - 🍕 Pizza Vegana
- **Dependencias**: `default`, `farming`

### 📚 Education Blocks (Bloques Educativos)
- **Propósito**: Enseñar sobre veganismo de forma interactiva
- **Bloques**:
  - 📋 Cartel Vegano: Datos sobre veganismo
  - 🥗 Bloque Nutricional: Información nutricional vegana
  - 🐰 Datos de Animales: Curiosidades sobre animales
- **Comando**: `/veganismo` - información educativa

## 🔧 Gestión del Servidor

### Comandos Básicos
```bash
# Iniciar servidor
./scripts/start.sh

# Ver logs en tiempo real
docker-compose logs -f luanti-server

# Reiniciar servidor
docker-compose restart luanti-server

# Detener servidor
docker-compose down

# Backup manual
./scripts/backup.sh
```

### 💾 Sistema de Backups

- **Frecuencia**: Automático cada 6 horas
- **Ubicación**: `server/backups/`
- **Retención**: Últimos 10 backups
- **Formato**: `vegan_wetlands_backup_YYYYMMDD-HHMMSS.tar.gz`

### 📊 Monitoreo

El servidor incluye:
- Health checks automáticos cada 30 segundos
- Logs centralizados con Docker Compose
- Reinicio automático en caso de fallos

## 🚀 Despliegue en Producción

### 🤖 CI/CD Automático

Cada `git push` a `main` automáticamente:
1. Hace backup del mundo actual
2. Descarga código actualizado
3. Reinicia el servidor
4. Verifica que esté funcionando

## 📖 Documentación Adicional

- **[🤖 Integración n8n](docs/n8n-integration.md)** - Automatización y notificaciones

## 🏗️ Arquitectura

- **🐳 Docker**: Imagen oficial de Luanti
- **🔄 CI/CD**: GitHub Actions para despliegue automático
- **💾 Backups**: Automáticos cada 6 horas
- **🛡️ Monitoring**: Health checks y logs centralizados

## 🎯 Características Únicas

### 🐮 Santuarios de Animales
- Refugios y comederos para animales
- Herramientas de cuidado (cepillos, kits médicos)
- Prevención automática de daño animal

### 📚 Educación Vegana
- Bloques interactivos con datos sobre veganismo
- Información nutricional y curiosidades de animales
- Comandos educativos (`/veganismo`, `/santuario`)

### 🥗 Alimentación Vegana
- Comidas 100% vegetales
- Recetas creativas sin productos animales
- Sistema nutricional educativo

## 🤝 Contribuir

¿Tienes ideas para mejorar Vegan Wetlands? ¡Nos encantaría tu ayuda!

1. Fork del repositorio
2. Crea una rama para tu feature (`git checkout -b feature/nueva-feature`)
3. Commit de cambios (`git commit -m 'Agregar nueva feature vegana'`)
4. Push a la rama (`git push origin feature/nueva-feature`)
5. Abre un Pull Request

## 📞 Soporte

- 🐛 **Bugs**: [GitHub Issues](https://github.com/gabrielpantoja-cl/Vegan-Wetlands/issues)
- 💬 **Discord**: [Comunidad Vegana Gaming] (próximamente)
- 📧 **Email**: gabriel@pantoja.cl

## 📄 Licencia

Este proyecto está bajo licencia MIT. Ver archivo `LICENSE` para más detalles.

---

🌱 **Hecho con ❤️ por la comunidad vegana** | [gabrielpantoja.cl](https://gabrielpantoja.cl)