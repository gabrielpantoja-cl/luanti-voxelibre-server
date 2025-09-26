# 🚀 Guía de Despliegue e Infraestructura

Este documento es la guía técnica para la infraestructura del servidor Vegan Wetlands. Cubre el despliegue, la configuración de Docker, el pipeline de CI/CD con GitHub Actions y la gestión del VPS.

---

## 1. Arquitectura General

El proyecto se ejecuta en un **VPS de DigitalOcean** y está completamente **orquestado con Docker Compose**. Esto asegura un entorno de despliegue consistente y fácil de gestionar.

*   **Repositorio Principal (`Vegan-Wetlands`):** Contiene todo el código del juego: mods, configuración de Luanti, landing page, etc.
*   **VPS:** Ubuntu 24.04.3 LTS.
*   **Orquestación:** Docker y Docker Compose.

---

## 2. Configuración de Docker (`docker-compose.yml`)

El archivo `docker-compose.yml` define dos servicios principales:

1.  **`luanti-server`:** El contenedor del servidor de juego Luanti.
2.  **`backup-cron`:** Un contenedor auxiliar que ejecuta el script de backups automáticamente cada 6 horas.

### 2.1. Volúmenes Clave

La sección de volúmenes es crítica para la persistencia de datos y la carga de mods.

```yaml
services:
  luanti-server:
    image: linuxserver/luanti:latest
    container_name: vegan-wetlands-server
    restart: unless-stopped
    ports:
      - "30000:30000/udp"
    volumes:
      # Configuración y datos del servidor
      - ./server/config/luanti.conf:/config/.minetest/minetest.conf
      - ./server/worlds:/config/.minetest/worlds
      - ./server/games:/config/.minetest/games
      - ./server/backups:/backups

      # Mapeo de mods a sus categorías correctas en VoxeLibre (¡MUY IMPORTANTE!)
      - ./server/mods/vegan_foods:/config/.minetest/games/mineclone2/mods/ITEMS/vegan_foods
      - ./server/mods/animal_sanctuary:/config/.minetest/games/mineclone2/mods/ENTITIES/animal_sanctuary
      - ./server/mods/education_blocks:/config/.minetest/games/mineclone2/mods/HELP/education_blocks
```

### 2.2. Servicio de Backups

El servicio `backup-cron` es muy simple: monta los directorios de mundos y backups, y ejecuta un `crond` que llama a `scripts/backup.sh` cada 6 horas. Es un sistema de "configúralo y olvídalo".

---

## 3. Despliegue Continuo con GitHub Actions

El despliegue en el VPS está automatizado. Cada `git push` a la rama `main` dispara un workflow de GitHub Actions que actualiza el servidor.

### 3.1. Configuración de Secrets

Para que el workflow funcione, el repositorio de GitHub necesita los siguientes "Secrets" (en `Settings > Secrets and variables > Actions`):

| Secret | Valor de Ejemplo | Descripción |
|---|---|---|
| `VPS_HOST` | `<VPS_HOST_IP>` | La IP de tu VPS. |
| `VPS_USER` | `gabriel` | El usuario con el que se conectará por SSH. |
| `VPS_SSH_KEY`| (Tu clave SSH privada) | La clave SSH privada para acceder al VPS sin contraseña. |

### 3.2. ¿Qué Hace el Workflow?

El archivo `.github/workflows/deploy.yml` define los siguientes pasos:

1.  **Se activa** con un `push` a `main`.
2.  **Se conecta al VPS** usando los secrets configurados.
3.  **Navega** al directorio del proyecto.
4.  **Ejecuta `git pull`** para descargar los últimos cambios.
5.  **Ejecuta `docker-compose restart`** para reiniciar los servicios y aplicar los cambios.

---

## 4. Configuración de la Landing Page (Nginx)

La página de bienvenida (`luanti.gabrielpantoja.cl`) no es servida por el contenedor de Luanti, sino por un **proxy inverso Nginx** que se ejecuta en el VPS.

*   **Contenido:** El HTML/CSS/JS de la landing page vive en `server/landing-page/` en este repositorio.
*   **Servidor Web:** Un contenedor Nginx separado (gestionado idealmente en otro repo de infraestructura para mantener la separación de conceptos) monta esta carpeta.
*   **Actualización:** Para actualizar la landing page, simplemente haz `push` de los cambios a este repositorio. El `git pull` del workflow de despliegue actualizará los archivos en el VPS, y Nginx los servirá automáticamente.

---

## 5. Setup Inicial de un Servidor desde Cero

Si necesitaras recrear el servidor en un nuevo VPS, los pasos serían:

1.  **Preparar el VPS:** Instalar Docker y Docker Compose.
2.  **Clonar el Repositorio:** `git clone https://github.com/gabrielpantoja-cl/Vegan-Wetlands.git`
3.  **Configurar el Juego Base (VoxeLibre):** Asegurarse de que el juego `mineclone2` esté presente en la carpeta `server/games/`.
4.  **Configurar `luanti.conf`:** Revisar la configuración del servidor en `server/config/luanti.conf`.
5.  **Iniciar por Primera Vez:** Ejecutar `docker-compose up -d`.

---

## 6. Integración con n8n (Planes a Futuro)

Se planea una futura integración con n8n para automatizar notificaciones y monitoreo.

*   **Notificaciones de Backup:** El script `backup.sh` tiene una sección comentada para llamar a un webhook de n8n y notificar a Discord/Telegram cada vez que un backup se completa.
*   **Monitoreo de Actividad:** Se pueden crear workflows que alerten si el servidor se cae o que envíen reportes diarios de actividad.
