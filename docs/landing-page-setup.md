# Guía de Configuración de la Landing Page

Este documento detalla el plan para configurar una página de bienvenida (landing page) para el servidor de Luanti en la URL `luanti.gabrielpantoja.cl`, que actualmente redirige al servicio n8n.

## Objetivo

-   **URL Principal (`luanti.gabrielpantoja.cl`):** Debe mostrar una página web estática (la landing page) que sirva como portal de bienvenida para el servidor del juego.
-   **Acceso al Juego:** La misma URL (`luanti.gabrielpantoja.cl`) debe seguir funcionando como la dirección del servidor para conectarse desde el cliente de Luanti/Minetest.
-   **Servicio n8n:** Debe ser accesible a través de un nuevo subdominio: `n8n.gabrielpantoja.cl`.

## Plan de Ejecución

### Paso 1: Configuración de DNS en Cloudflare

Antes de tocar la configuración del servidor, es necesario preparar el nuevo subdominio para n8n.

1.  **Acción:** Acceder al panel de control de Cloudflare para el dominio `gabrielpantoja.cl`.
2.  **Crear Registro A:** Añadir un nuevo registro de tipo `A` con la siguiente configuración:
    -   **Tipo:** `A`
    -   **Nombre:** `n8n` (Cloudflare autocompletará a `n8n.gabrielpantoja.cl`).
    -   **Contenido (Dirección IPv4):** La misma dirección IP de tu VPS en Digital Ocean.
    -   **Proxy status:** Habilitado (nube naranja), para que Cloudflare gestione el SSL.

### Paso 2: Crear el Contenido de la Landing Page

Crearemos un directorio y un archivo HTML simple para la página de bienvenida.

1.  **Acción:** Crear un nuevo directorio en `server/landing-page`.
2.  **Crear Archivo:** Dentro de ese directorio, crear un archivo `index.html` con contenido básico.

    ```html
    <!DOCTYPE html>
    <html lang="es">
    <head>
        <meta charset="UTF-g">
        <meta name="viewport" content="width=device-width, initial-scale=1.0">
        <title>Bienvenido a Vegan Wetlands</title>
        <style>
            body { font-family: sans-serif; background-color: #282a36; color: #f8f8f2; display: flex; justify-content: center; align-items: center; height: 100vh; margin: 0; }
            .container { text-align: center; padding: 40px; background-color: #44475a; border-radius: 10px; box-shadow: 0 4px 8px rgba(0,0,0,0.3); }
            h1 { color: #50fa7b; }
            p { font-size: 1.2em; }
            code { background-color: #282a36; padding: 5px 10px; border-radius: 5px; }
        </style>
    </head>
    <body>
        <div class="container">
            <h1>Bienvenido a Vegan Wetlands</h1>
            <p>Nuestro servidor de Luanti ya está en línea.</p>
            <p>Para unirte, usa la siguiente dirección en el cliente del juego:</p>
            <p><code>luanti.gabrielpantoja.cl</code></p>
        </div>
    </body>
    </html>
    ```

### Paso 3: Modificar `docker-compose.yml`

Este es el paso principal. Editaremos el `docker-compose.yml` para añadir el servidor de la landing page y redirigir el tráfico correctamente. **Se asumirá que se está usando Traefik como reverse proxy, basándonos en configuraciones comunes. Si es otro, los "labels" cambiarán.**

1.  **Añadir el servicio de la Landing Page:** Agregaremos un nuevo servicio que use una imagen de `nginx` para servir los archivos HTML.

    ```yaml
    # ... (otros servicios)

    services:
      # ... (tu servicio de traefik, n8n, etc.)

      landing-page:
        image: nginx:alpine
        container_name: landing-page
        restart: unless-stopped
        volumes:
          - ./server/landing-page:/usr/share/nginx/html:ro
        labels:
          - "traefik.enable=true"
          - "traefik.http.routers.landing-page.rule=Host(`luanti.gabrielpantoja.cl`)"
          - "traefik.http.routers.landing-page.entrypoints=websecure"
          - "traefik.http.services.landing-page.loadbalancer.server.port=80"
          - "traefik.http.routers.landing-page.tls.certresolver=myresolver" # Reemplazar 'myresolver' con el nombre de tu certresolver de Traefik

    # ... (resto de servicios)
    ```

2.  **Actualizar el servicio de n8n:** Modificaremos la regla (`rule`) en los `labels` del servicio `n8n` para que responda al nuevo subdominio.

    ```yaml
    # En la definición del servicio de n8n:
    labels:
      # ... (otras labels de traefik)
      - "traefik.http.routers.n8n.rule=Host(`n8n.gabrielpantoja.cl`)" # <-- ESTA LÍNEA CAMBIA
      # ... (resto de labels)
    ```

### Paso 4: Aplicar los Cambios

Una vez guardados los cambios en `docker-compose.yml`, reiniciaremos la pila de contenedores para que se aplique la nueva configuración.

1.  **Acción:** Ejecutar el siguiente comando en la raíz del proyecto (donde está `docker-compose.yml`).
    ```bash
    docker-compose up -d
    ```
    Este comando recreará los contenedores que han cambiado (landing-page y n8n) sin afectar a los demás.

### Paso 5: Verificación Final

1.  Abre un navegador y visita `https://luanti.gabrielpantoja.cl`. Deberías ver la nueva landing page.
2.  Visita `https://n8n.gabrielpantoja.cl`. Deberías ver la página de login de n8n.
3.  Inicia el cliente de Luanti y conéctate al servidor `luanti.gabrielpantoja.cl`. La conexión debería funcionar como antes.
