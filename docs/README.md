# 🌱 Vegan Wetlands - Servidor Luanti Vegano

¡Bienvenid@ a **Vegan Wetlands**! Un servidor de Luanti (antes Minetest) creado especialmente para niños veganos de 7 años en adelante.

## 🎯 Filosofía del Servidor

- **Sin violencia animal**: No matamos ni lastimamos animales
- **Santuarios veganos**: Cuidamos y protegemos a los animales en refugios
- **Educación divertida**: Aprendemos sobre veganismo jugando
- **Espacio seguro**: Moderación y protección para una experiencia positiva
- **Modo creativo**: Libertad total para construir sin límites

## 🚀 Inicio Rápido

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
└── docs/                      # Documentación
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

### Configuración VPS (DigitalOcean)

1. **Configurar secrets en GitHub**:
   ```
   VPS_HOST: tu-servidor.com
   VPS_USER: usuario-ssh
   VPS_SSH_KEY: clave-privada-ssh
   VPS_PORT: 22 (opcional)
   ```

2. **Preparar VPS**:
   ```bash
   # En el VPS, crear directorio del proyecto
   sudo mkdir -p /opt/vegan-wetlands
   sudo chown $USER:$USER /opt/vegan-wetlands
   
   # Clonar repo
   cd /opt/vegan-wetlands
   git clone https://github.com/gabrielpantoja-cl/Vegan-Wetlands.git .
   ```

3. **Configurar dominio**:
   - Apuntar `luanti.gabrielpantoja.cl` al IP del VPS
   - Puerto 30000/UDP debe estar abierto en firewall

### 🤖 CI/CD Automático

Cada `git push` a `main` automáticamente:
1. Hace backup del mundo actual
2. Descarga código actualizado
3. Reinicia el servidor
4. Verifica que esté funcionando

## 🛠️ Desarrollo y Contribuciones

### Agregar Nuevos Mods

1. Crear directorio en `server/mods/tu_mod/`
2. Incluir `mod.conf` e `init.lua`
3. Agregar dependencias en `luanti.conf`
4. Probar localmente antes de hacer push

### Filosofía de Desarrollo

- **Educativo**: Todo debe enseñar sobre veganismo
- **Inclusivo**: Apropiado para niños de 7+ años
- **Sin violencia**: No mecánicas que lastimen animales
- **Divertido**: Mantener la diversión sin comprometer valores

## 🆘 Solución de Problemas

### El servidor no inicia
```bash
# Verificar logs
docker-compose logs luanti-server

# Verificar puertos
ss -tulpn | grep :30000

# Reiniciar servicios
docker-compose restart
```

### No aparece en la lista pública
- Verificar `server_announce = true` en `luanti.conf`
- Confirmar que puerto 30000/UDP esté abierto
- Verificar conectividad externa al servidor

### Problemas con mods
```bash
# Ver logs específicos del servidor
docker-compose exec luanti-server tail -f /var/lib/luanti/.luanti/debug.txt
```

## 📞 Soporte y Comunidad

- **Issues**: [GitHub Issues](https://github.com/gabrielpantoja-cl/Vegan-Wetlands/issues)
- **Servidor oficial**: `luanti.gabrielpantoja.cl:30000`
- **Contacto**: Gabriel Pantoja

---

🌱 **¡Gracias por ser parte de Vegan Wetlands!** Juntos creamos un mundo más compasivo y divertido para todos.
