# Roadmap - Landing Page Wetlands

Propuestas de mejora para la landing page de Wetlands.

**Estado actual**: Landing page funcional con sistema de galeria centralizado JSON, 11 imagenes, 2 paginas (index + galeria).

---

## Prioridad Alta (bajo esfuerzo, alto impacto)

### Lazy Loading Nativo

Agregar `loading="lazy"` a las imagenes de galeria para que solo carguen al hacer scroll.

```javascript
// En gallery.js, agregar al crear <img>
<img src="..." loading="lazy" alt="...">
```

### Conversion a WebP

Convertir imagenes PNG/JPEG a WebP para reducir tamaño 30-50%.

```bash
for img in server/landing-page/assets/images/*.png; do
    cwebp -q 85 "$img" -o "${img%.png}.webp"
done
```

Usar `<picture>` con fallback:
```html
<picture>
    <source srcset="imagen.webp" type="image/webp">
    <img src="imagen.png" alt="...">
</picture>
```

### Thumbnails Automaticos

Generar thumbnails de 400x225px para el grid. Cargar imagen full-size solo en el modal.

```bash
convert imagen.png -resize 400x225 -quality 85 thumbs/imagen-thumb.png
```

### Fullscreen en Modal

Agregar boton de pantalla completa al modal de imagen.

```javascript
function openFullscreen() {
    document.getElementById('gallery-modal').requestFullscreen();
}
```

### Cloudflare CDN

Activar proxy de Cloudflare para cache global, proteccion DDoS y analytics sin Google Analytics. El dominio ya esta en Cloudflare, solo requiere activar "Proxied" en el DNS record.

---

## Prioridad Media

### URLs Dedicadas por Imagen

Permitir compartir links directos a una imagen especifica de la galeria:

```
https://luanti.gabrielpantoja.cl/galeria.html?image=vehicles-2025-11
```

Leer query param al cargar y abrir modal automaticamente.

### Sistema de Busqueda

Buscador en tiempo real para filtrar imagenes por titulo/descripcion. Util cuando la galeria tenga 50+ imagenes.

### Integracion con Discord

Auto-postear nuevas imagenes al canal de Discord via webhook cuando se agregan a la galeria.

### Dark Mode

Soporte para modo oscuro usando `prefers-color-scheme` media query.

### Critical CSS Inline

Inline CSS critico para above-the-fold, cargar el resto async. Mejora First Contentful Paint.

### Paginas Estaticas por Imagen

Generar HTML estatico por cada imagen para mejor SEO y Open Graph tags (previews en Discord/Twitter).

---

## Prioridad Baja

### Migracion a Cloudflare R2

Mover imagenes a Cloudflare R2 (S3-compatible, sin costos de egreso). Actualmente las imagenes ocupan ~15MB en el VPS, bien dentro de limites. Considerar cuando el espacio sea problema.

### Service Worker / PWA

Soporte offline y app instalable. Overkill para el tamaño actual del sitio.

### Timeline Interactivo

Vista cronologica de actualizaciones. Considerar cuando la galeria tenga 50+ imagenes.

### API REST para Galeria

Endpoint `/api/gallery` publico para integracion con bots y otras apps.

### Analytics de Galeria

Trackear imagenes mas vistas usando Plausible Analytics o Cloudflare Web Analytics (privacy-friendly).

---

## Cuando implementar mejoras

| Condicion | Mejoras a implementar |
|-----------|-----------------------|
| 50+ imagenes | Thumbnails, busqueda, lazy loading obligatorio |
| 1000+ visitas/mes | Cloudflare CDN, analytics |
| 50+ jugadores activos | Discord integration, API REST |
| Espacio VPS < 10GB | Migrar imagenes a R2 |

---

**Ultima actualizacion**: 2026-02-04
