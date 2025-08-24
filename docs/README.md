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

## Mods

Este servidor cuenta con los siguientes mods personalizados:

### Animal Sanctuary (Santuario de Animales)

*   **Descripción**: Un mod para crear santuarios veganos donde cuidar y proteger animales en lugar de lastimarlos.
*   **Autor**: Vegan Wetlands Team

### Education Blocks (Bloques Educativos)

*   **Descripción**: Bloques educativos sobre veganismo y cuidado animal para Vegan Wetlands.
*   **Autor**: Vegan Wetlands Team

### Vegan Foods (Comida Vegana)

*   **Descripción**: Alimentos 100% vegetales deliciosos y nutritivos para el servidor Vegan Wetlands.
*   **Dependencias**: `default`, `farming`
*   **Autor**: Vegan Wetlands Team

## Backups

El servidor está configurado para realizar backups automáticos cada 6 horas. Los backups se guardan en la carpeta `server/backups`. Este proceso es gestionado por un contenedor separado que utiliza `cron` para programar las copias de seguridad.

## Contribuciones

¡Las contribuciones son bienvenidas! Si tienes ideas para nuevos mods, mejoras en los existentes o cualquier otra sugerencia, no dudes en abrir un "issue" o enviar un "pull request" en el repositorio de GitHub.
