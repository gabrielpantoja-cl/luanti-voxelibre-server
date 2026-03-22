# Landing Page Recovery - 2026-03-22

## Problema

La landing page https://luanti.gabrielpantoja.cl estaba caida despues de la migracion de DigitalOcean a Oracle Cloud (2026-03-17).

## Diagnostico

### Estado inicial del VPS (<VPS_IP>)

| Componente | Estado | Detalle |
|-----------|--------|---------|
| SSH | OK | Conectado como gabriel |
| DNS | OK | luanti.gabrielpantoja.cl -> <VPS_IP> |
| Nginx | Instalado y corriendo | v1.24.0, activo desde 2026-03-17 |
| Certbot | Instalado | v2.9.0 |
| Certificado SSL | Valido | Expira 2026-06-15 |
| Puertos 80/443 | Escuchando | Confirmado via ss -tlnp |
| Repo en VPS | Presente | /home/gabriel/luanti-voxelibre-server/ |
| Archivos landing page | Presentes | server/landing-page/index.html etc |

### Causa raiz

**El archivo `/etc/nginx/sites-available/default` tenia un bloque para `luanti.gabrielpantoja.cl` generado por Certbot, pero apuntaba a `/var/www/html` en lugar del directorio real del repo.**

Ademas, NO existia un archivo de configuracion dedicado en `sites-available/luanti.gabrielpantoja.cl` ni el symlink en `sites-enabled/`.

Habia un segundo problema de permisos: `/home/gabriel` tenia permisos `0750`, bloqueando al usuario `www-data` (nginx) para traversar el directorio.

## Solucion aplicada

### 1. Crear configuracion nginx dedicada

```bash
sudo tee /etc/nginx/sites-available/luanti.gabrielpantoja.cl > /dev/null << 'EOF'
# (ver docs/web/nginx/luanti.gabrielpantoja.cl.conf)
EOF
```

Root correcto: `/home/gabriel/luanti-voxelibre-server/server/landing-page`

### 2. Habilitar sitio con symlink

```bash
sudo ln -sf /etc/nginx/sites-available/luanti.gabrielpantoja.cl \
    /etc/nginx/sites-enabled/luanti.gabrielpantoja.cl
```

### 3. Limpiar conflicto en archivo default

El archivo `/etc/nginx/sites-available/default` tenia dos server blocks para `luanti.gabrielpantoja.cl` (agregados por Certbot). Fueron eliminados, dejando solo el server block default para `_`.

Backup guardado en: `/etc/nginx/sites-available/default.bak`

### 4. Corregir permisos del directorio home

```bash
sudo chmod o+x /home/gabriel
# /home/gabriel: 0750 -> 0751
```

Esto permite a www-data traversar el directorio para acceder a los archivos de la landing page.

### 5. Recargar nginx

```bash
sudo nginx -t        # Verificar sintaxis
sudo systemctl reload nginx
```

## Verificacion

```bash
# HTTP 200 OK
curl -I https://luanti.gabrielpantoja.cl/
# HTTP 301 Redirect a HTTPS
curl -I http://luanti.gabrielpantoja.cl/
# Assets OK
curl -s -o /dev/null -w "%{http_code}" https://luanti.gabrielpantoja.cl/assets/css/style.css
curl -s -o /dev/null -w "%{http_code}" https://luanti.gabrielpantoja.cl/galeria.html
curl -s -o /dev/null -w "%{http_code}" https://luanti.gabrielpantoja.cl/assets/data/gallery-data.json
```

Todos retornaron 200.

## Configuracion nginx resultante en VPS

- `/etc/nginx/sites-available/luanti.gabrielpantoja.cl` - config dedicada (ver docs/web/nginx/)
- `/etc/nginx/sites-enabled/luanti.gabrielpantoja.cl` - symlink activo
- `/etc/nginx/sites-available/default` - limpio, solo bloque default para `_`

## Cache headers configurados

| Tipo de archivo | Cache | Razon |
|----------------|-------|-------|
| JS, CSS | 1 hora | Actualizaciones frecuentes |
| JSON (gallery-data.json) | 5 minutos | Galeria visible rapidamente |
| PNG, JPG, SVG, WOFF | 1 año | Assets estaticos |

## Como restaurar si se pierde la config

```bash
# En el VPS:
sudo cp /home/gabriel/luanti-voxelibre-server/docs/web/nginx/luanti.gabrielpantoja.cl.conf \
    /etc/nginx/sites-available/luanti.gabrielpantoja.cl
sudo ln -sf /etc/nginx/sites-available/luanti.gabrielpantoja.cl \
    /etc/nginx/sites-enabled/luanti.gabrielpantoja.cl
sudo chmod o+x /home/gabriel
sudo nginx -t && sudo systemctl reload nginx
```
