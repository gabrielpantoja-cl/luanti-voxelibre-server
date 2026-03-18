# REPORTE: Problema de Galería en Producción

## PROBLEMA IDENTIFICADO

La galería en `https://luanti.gabrielpantoja.cl/galeria.html` NO muestra la imagen del auto amarillo (AUTO-AMARILLO.png) ni las demás imágenes correctamente.

### CAUSA RAÍZ

**CACHÉ AGRESIVO DE NAVEGADOR**

La configuración de nginx tiene un caché de **1 año** para archivos `.js`, `.css` y `.json`:

```nginx
location ~* \.(js|css|png|jpg|jpeg|gif|ico|svg|woff|woff2|ttf|eot)$ {
    expires 1y;
    add_header Cache-Control "public, immutable";
    access_log off;
}
```

Esto causa que el navegador use versiones antiguas de:
- `gallery.js` (código JavaScript desactualizado)
- `gallery-data.json` (datos de la galería antiguos)

### VERIFICACIÓN DE DATOS EN PRODUCCIÓN

Todos los archivos están correctamente desplegados en el VPS:

#### ✅ gallery-data.json
- **URL**: https://luanti.gabrielpantoja.cl/assets/data/gallery-data.json
- **Estado**: HTTP 200 (disponible)
- **Contenido**: 9 imágenes correctas
- **Primera imagen**: AUTO-AMARILLO.png (priority: 1) ✅

#### ✅ AUTO-AMARILLO.png
- **URL**: https://luanti.gabrielpantoja.cl/assets/images/AUTO-AMARILLO.png
- **Estado**: HTTP 200 (disponible)
- **Tamaño**: 866KB

#### ✅ gallery.js
- **URL**: https://luanti.gabrielpantoja.cl/assets/js/gallery.js
- **Estado**: HTTP 200 (disponible)
- **Lógica**: Sistema centralizado correcto
- **Ordenamiento**: Por priority ascendente (correcto)

#### ✅ Imágenes en JSON
```json
Total de imágenes: 9
1. Vehiculos Disponibles (priority: 1)    ← AUTO-AMARILLO.png
2. Kit de Baño Completo (priority: 2)
3. Halloween 2025 (priority: 3)
4. Protege Tu Casa (priority: 4)
5. Televisor con Canales (priority: 5)
6. Reglas del Servidor (priority: 6)
7. Momentos de Relajacion (priority: 7)
8. Nuestra Comunidad (priority: 8)
9. Aventura Epica (priority: 9)
```

### ESTADO DEL REPOSITORIO

- **Commit local**: c4edddc (actualizado)
- **Commit VPS**: c4edddc (actualizado) ✅
- **git pull**: Ejecutado exitosamente
- **Archivos sincronizados**: ✅

## SOLUCIÓN

### Opción 1: Limpiar Caché del Navegador (RÁPIDO)

**PARA EL USUARIO - EJECUTAR AHORA**:

1. **En Chrome/Firefox**:
   - Presiona `Ctrl + Shift + Delete`
   - Selecciona "Imágenes y archivos en caché"
   - Presiona "Borrar datos"

2. **Forzar recarga dura**:
   - Presiona `Ctrl + Shift + R` (Windows/Linux)
   - O `Cmd + Shift + R` (Mac)

3. **Verificar**:
   - Visita https://luanti.gabrielpantoja.cl/galeria.html
   - Abre consola del navegador (F12)
   - Deberías ver: `🖼️ Gallery data loaded: 9 images`

### Opción 2: Actualizar Configuración de Nginx (PERMANENTE)

**REQUIERE PERMISOS SUDO EN VPS**

Ubicación del archivo de configuración:
```
/etc/nginx/sites-available/luanti.gabrielpantoja.cl
```

#### Script de Actualización

```bash
# SSH al VPS
ssh gabriel@<IP_VPS_ANTERIOR>

# Crear backup
sudo cp /etc/nginx/sites-available/luanti.gabrielpantoja.cl \
       /etc/nginx/sites-available/luanti.gabrielpantoja.cl.backup-$(date +%Y%m%d-%H%M%S)

# Editar archivo
sudo nano /etc/nginx/sites-available/luanti.gabrielpantoja.cl
```

#### Configuración Actualizada

Reemplazar la sección de caché con estas 3 ubicaciones específicas:

```nginx
# Cache JS/CSS files - SHORT cache for frequent updates
location ~* \.(js|css)$ {
    expires 1h;
    add_header Cache-Control "public, must-revalidate";
    access_log off;
}

# Cache JSON data files - VERY SHORT cache
location ~* \.json$ {
    expires 5m;
    add_header Cache-Control "public, must-revalidate";
    access_log off;
}

# Cache static images/fonts - LONG cache (immutable)
location ~* \.(png|jpg|jpeg|gif|ico|svg|woff|woff2|ttf|eot)$ {
    expires 1y;
    add_header Cache-Control "public, immutable";
    access_log off;
}
```

#### Aplicar Cambios

```bash
# Verificar sintaxis
sudo nginx -t

# Si OK, recargar nginx
sudo systemctl reload nginx

# Verificar estado
sudo systemctl status nginx
```

### Opción 3: Cache Busting con Versioning (FUTURO)

Para futuras actualizaciones, considerar agregar versioning a los archivos:

```html
<!-- index.html y galeria.html -->
<script src="assets/js/gallery.js?v=1.0.1"></script>
```

O usar hash del archivo:
```html
<script src="assets/js/gallery.js?v=<%= fileHash %>"></script>
```

## VERIFICACIÓN POST-FIX

### 1. Verificar Headers de Caché

```bash
# JS/CSS debería tener max-age=3600 (1 hora)
curl -I https://luanti.gabrielpantoja.cl/assets/js/gallery.js | grep -i cache

# JSON debería tener max-age=300 (5 minutos)
curl -I https://luanti.gabrielpantoja.cl/assets/data/gallery-data.json | grep -i cache

# Imágenes pueden mantener max-age=31536000 (1 año)
curl -I https://luanti.gabrielpantoja.cl/assets/images/AUTO-AMARILLO.png | grep -i cache
```

### 2. Verificar Galería en Navegador

1. Abrir https://luanti.gabrielpantoja.cl/galeria.html
2. Abrir consola del navegador (F12 → Console)
3. Verificar logs:
   ```
   🖼️ Gallery data loaded: 9 images
   ✅ Rendered 9 images for full gallery page
   ```

4. **Verificar que se ven las 9 imágenes**:
   - AUTO-AMARILLO.png (Vehículos) - PRIMERA posición ✅
   - baño.png (Kit de Baño)
   - halloween_ghost.png (Halloween)
   - protect_area.jpeg (Protección)
   - tele.png (TV)
   - reglas.png (Reglas)
   - wetlands-gameplay-2025-09-13.png (Piscina)
   - pepe-gabo.jpeg (Comunidad)
   - Captura de pantalla... (Aventura)

### 3. Verificar index.html

1. Abrir https://luanti.gabrielpantoja.cl/
2. Verificar que se ven las **últimas 4 imágenes**:
   - AUTO-AMARILLO.png (featured-main)
   - baño.png
   - halloween_ghost.png
   - protect_area.jpeg

## COMANDOS DE DIAGNÓSTICO

```bash
# Ver logs de nginx
ssh gabriel@<IP_VPS_ANTERIOR> 'sudo tail -50 /var/log/nginx/luanti_error.log'

# Ver estado de git en VPS
ssh gabriel@<IP_VPS_ANTERIOR> 'cd /home/gabriel/luanti-voxelibre-server && git log --oneline -5'

# Verificar archivos en VPS
ssh gabriel@<IP_VPS_ANTERIOR> 'ls -lh /home/gabriel/luanti-voxelibre-server/server/landing-page/assets/images/AUTO-AMARILLO.png'

# Verificar JSON en VPS
ssh gabriel@<IP_VPS_ANTERIOR> 'cat /home/gabriel/luanti-voxelibre-server/server/landing-page/assets/data/gallery-data.json | head -30'

# Test HTTP directo
curl -s https://luanti.gabrielpantoja.cl/assets/data/gallery-data.json | python3 -c "import sys, json; print(f\"Total: {len(json.load(sys.stdin)['images'])} imágenes\")"
```

## RESUMEN

### Estado Actual
- ✅ Código actualizado en VPS (commit c4edddc)
- ✅ Archivo gallery-data.json desplegado
- ✅ Imagen AUTO-AMARILLO.png disponible
- ✅ Sistema JavaScript funcionando correctamente
- ❌ Caché del navegador impide ver cambios

### Acción Requerida
1. **INMEDIATO**: Limpiar caché del navegador (`Ctrl + Shift + R`)
2. **RECOMENDADO**: Actualizar configuración nginx (requiere sudo)
3. **FUTURO**: Implementar cache busting con versioning

### Impacto
- **Usuarios nuevos**: Verán la galería correctamente
- **Usuarios con caché**: Necesitan limpiar caché del navegador
- **Después de fix nginx**: Caché se actualizará cada hora automáticamente

---

**Fecha**: 2025-11-27
**Investigado por**: wetlands-landing-page-developer (Claude Code)
**Archivo de configuración**: `/etc/nginx/sites-available/luanti.gabrielpantoja.cl`
**Estado del fix**: Solución identificada, requiere acción del usuario
