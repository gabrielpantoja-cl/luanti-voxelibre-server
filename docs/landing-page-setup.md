# 🌱 Guía de Configuración de la Landing Page - Vegan Wetlands

Este documento detalla el plan actualizado para configurar una página de bienvenida (landing page) moderna para el servidor de Luanti. La documentación ha sido corregida para reflejar la arquitectura real del VPS.

## 🎯 Objetivo

-   **URL Principal (`luanti.gabrielpantoja.cl`):** Mostrar una landing page estática moderna y amigable para niños 7+ años
-   **Acceso al Juego:** La misma URL funciona para conectarse desde el cliente de Luanti (puerto 30000/UDP)
-   **Servicio n8n:** Accessible en `n8n.gabrielpantoja.cl` (ya configurado)
-   **Arquitectura:** nginx como reverse proxy (no Traefik)

## 🏗️ Arquitectura Real del VPS

### Estado Actual Verificado
- **Reverse Proxy:** nginx (container `nginx-proxy` en vps-do.git)
- **Configuración:** `/home/gabriel/vps-do/nginx/conf.d/`
- **Problema:** `luanti.gabrielpantoja.cl` actualmente muestra n8n
- **Solución:** Crear configuración nginx específica para landing page

### Separación de Responsabilidades
- **Este repo (Vegan-Wetlands.git):** Desarrollo del contenido HTML/CSS/JS
- **Repo VPS (vps-do.git):** Configuración nginx y despliegue
- **Sincronización:** Scripts de CI/CD copian archivos entre repos

## 📋 Plan de Implementación Corregido

### Paso 1: Crear Landing Page en Este Repositorio

1. **Crear estructura de archivos:**
   ```
   server/landing-page/
   ├── index.html          # Página principal
   ├── assets/
   │   ├── css/style.css   # Estilos modernos
   │   ├── js/main.js      # Interactividad
   │   └── images/         # Logos e íconos
   └── deploy.sh           # Script de despliegue al VPS
   ```

2. **Diseño orientado a niños 7+ años:**
   - Colores vibrantes y naturales
   - Tipografía clara y grande
   - Animaciones sutiles
   - Responsive design
   - Botones grandes y fáciles de usar

### Paso 2: Configurar nginx en VPS

1. **Crear configuración en vps-do.git:**
   ```nginx
   # /home/gabriel/vps-do/nginx/conf.d/luanti-landing.conf
   server {
       listen 80;
       server_name luanti.gabrielpantoja.cl;
       
       root /var/www/luanti-landing;
       index index.html;
       
       location / {
           try_files $uri $uri/ =404;
       }
       
       # Cache static assets
       location ~* \.(js|css|png|jpg|jpeg|gif|ico|svg)$ {
           expires 1y;
           add_header Cache-Control "public, immutable";
       }
   }
   ```

2. **Modificar docker-compose.yml en vps-do:**
   ```yaml
   nginx-proxy:
     volumes:
       - ./nginx/www/luanti-landing:/var/www/luanti-landing:ro
   ```

### Paso 3: Script de Despliegue

1. **Crear script de sincronización:**
   ```bash
   #!/bin/bash
   # scripts/deploy-landing.sh
   
   # Copiar archivos al VPS
   scp -r server/landing-page/* gabriel@<VPS_IP>:/home/gabriel/vps-do/nginx/www/luanti-landing/
   
   # Recargar nginx
   ssh gabriel@<VPS_IP> "cd /home/gabriel/vps-do && docker-compose exec nginx-proxy nginx -s reload"
   ```

### Paso 4: Actualizar n8n Configuration

1. **En vps-do.git, modificar n8n.conf:**
   - Cambiar `server_name` de `luanti.gabrielpantoja.cl` a `n8n.gabrielpantoja.cl`
   - Ya está configurado correctamente según verificación

### Paso 5: Verificación y Testing

1. **Local:** Verificar diseño responsive en diferentes dispositivos
2. **Staging:** Probar archivos estáticos en servidor de desarrollo
3. **Production:** Verificar que `luanti.gabrielpantoja.cl` muestre landing page
4. **Game connectivity:** Confirmar que puerto 30000/UDP sigue funcionando
