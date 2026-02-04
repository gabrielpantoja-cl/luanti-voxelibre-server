# Sistema de Galeria - Wetlands Landing Page

Guia completa para mantener la galeria de imagenes de la landing page de Wetlands.

## Inicio Rapido: Agregar Nueva Imagen

### 1. Copiar imagen a la carpeta

```bash
cp screenshot.png server/landing-page/assets/images/nombre-descriptivo.png
```

- Nombres sin espacios, usar guiones
- Formatos: PNG o JPEG
- Tamaño recomendado: < 1MB (idealmente < 500KB)
- Resolucion maxima: 1920x1080

### 2. Editar gallery-data.json

Abrir `server/landing-page/assets/data/gallery-data.json` y:

1. Agregar nueva entrada al **inicio** del array `images` con `priority: 1`
2. Incrementar `priority` de **todas** las imagenes existentes en +1
3. Cambiar `featured: false` en la imagen que tenia `featured: true`
4. Poner `featured: true` en la nueva imagen
5. Actualizar `lastUpdated` con la fecha actual

```json
{
  "id": "nombre-descriptivo-2026-02",
  "filename": "nombre-descriptivo.png",
  "title": "Titulo Corto",
  "emoji": "🎮",
  "description": "Descripcion child-friendly de 1-2 lineas.",
  "date": "2026-02",
  "dateLabel": "Febrero 2026",
  "badge": {
    "text": "NUEVA ACTUALIZACION!",
    "emoji": "🆕",
    "type": "new"
  },
  "category": "updates",
  "featured": true,
  "priority": 1
}
```

### 3. Validar y deploy

```bash
# Validar JSON y verificar imagenes
python3 server/landing-page/scripts/validate-gallery.py

# Commit y push
git add server/landing-page/assets/data/gallery-data.json
git add server/landing-page/assets/images/nombre-descriptivo.png
git commit -m "Agregar [descripcion] en galeria"
git push origin main

# Actualizar VPS (nginx sirve desde este repo via docker volume)
ssh gabriel@167.172.251.27 "cd /home/gabriel/luanti-voxelibre-server && git fetch origin main && git reset --hard origin/main"
```

> **Nota**: nginx cachea JSON por 5 minutos. Los cambios se veran en produccion despues de ese periodo.

---

## Estructura de Archivos

```
server/landing-page/
├── assets/
│   ├── data/
│   │   └── gallery-data.json        # Fuente unica de datos
│   ├── images/
│   │   └── *.png / *.jpeg           # 11 imagenes (Feb 2026)
│   └── js/
│       └── gallery.js               # Renderizado dinamico
├── scripts/
│   ├── validate-gallery.py          # Validacion Python
│   └── validate-gallery.sh          # Validacion Shell
├── index.html                       # Homepage (ultimas 4 imagenes)
├── galeria.html                     # Galeria completa con filtros
└── docs/
    └── GALLERY_SYSTEM.md            # Este archivo
```

### Como funciona

- `gallery-data.json` es la **fuente unica de verdad** para toda la galeria
- `gallery.js` lee el JSON y renderiza las tarjetas dinamicamente
- `index.html` muestra las ultimas 4 imagenes (por prioridad)
- `galeria.html` muestra todas las imagenes con filtros por categoria

---

## Referencia de Campos

| Campo | Tipo | Requerido | Descripcion |
|-------|------|-----------|-------------|
| `id` | string | Si | Identificador unico. Formato: `nombre-descriptivo-YYYY-MM` |
| `filename` | string | Si | Nombre exacto del archivo en `assets/images/` |
| `title` | string | Si | Titulo corto y descriptivo (sin emojis, se agregan automaticamente) |
| `emoji` | string | Si | Un emoji relevante al contenido |
| `description` | string | Si | 1-2 lineas, lenguaje child-friendly (7+ años) |
| `date` | string | Si | Formato `YYYY-MM` o `YYYY-MM-DD` (para ordenamiento) |
| `dateLabel` | string | Si | Fecha legible: `"Febrero 2026"`, `"24 Enero 2026"`, `"Oct 2025"` |
| `badge` | object/null | Si | Badge destacado o `null` si no aplica |
| `category` | string | Si | `"updates"`, `"gameplay"`, o `"community"` |
| `featured` | boolean | Si | `true` solo para la imagen con `priority: 1` |
| `priority` | number | Si | Entero positivo. `1` = mas reciente, aparece primero |

### Categorias

| Valor | Uso |
|-------|-----|
| `updates` | Mods nuevos, features, actualizaciones del servidor |
| `gameplay` | Capturas de jugadores, construcciones, momentos de juego |
| `community` | Fotos de la comunidad, eventos sociales |

### Badges

```json
// Novedad reciente
"badge": {"text": "NUEVA ACTUALIZACION!", "emoji": "🆕", "type": "new"}

// Evento temporal activo
"badge": {"text": "EVENTO ACTIVO!", "emoji": "👻", "type": "event"}

// Actualizacion de hace poco
"badge": {"text": "ACTUALIZACION RECIENTE", "emoji": "🔥", "type": "new"}

// Sin badge (contenido antiguo o gameplay general)
"badge": null
```

> No usar `"badge": {}` (objeto vacio). Usar siempre `null` cuando no hay badge.

### Prioridades

- `priority: 1` = Primera imagen, mas reciente
- Al agregar una nueva imagen con `priority: 1`, incrementar todas las demas en +1
- Los valores deben ser consecutivos: 1, 2, 3, 4...
- No debe haber duplicados

---

## Deployment a Produccion

La landing page se sirve desde el repositorio git en el VPS via un docker volume mount de nginx:

```
VPS: /home/gabriel/luanti-voxelibre-server/server/landing-page
     └── montado como volumen read-only en nginx
         └── /var/www/luanti-landing:ro
```

### Proceso de deployment

1. Hacer commit y push a `main`
2. Actualizar el repo en VPS:
   ```bash
   ssh gabriel@167.172.251.27 "cd /home/gabriel/luanti-voxelibre-server && git fetch origin main && git reset --hard origin/main"
   ```
3. Esperar ~5 minutos para que expire el cache de nginx (JSON)

### Cache de nginx

| Recurso | Duracion cache |
|---------|---------------|
| JSON (gallery-data.json) | 5 minutos |
| JS / CSS | 1 hora |
| Imagenes | 1 año |

### Verificar en produccion

```bash
curl -I https://luanti.gabrielpantoja.cl
```

- https://luanti.gabrielpantoja.cl (homepage)
- https://luanti.gabrielpantoja.cl/galeria.html (galeria completa)

---

## Troubleshooting

### Imagen no aparece

1. Verificar que `filename` en JSON coincida exactamente con el archivo (case-sensitive)
2. Validar JSON: `python3 server/landing-page/scripts/validate-gallery.py`
3. Revisar consola del navegador (F12) para errores de carga
4. Verificar que la imagen fue incluida en el commit: `git status`

### Orden incorrecto de imagenes

1. Verificar campo `priority` (1 = primero, sin duplicados)
2. Asegurar valores consecutivos: 1, 2, 3, 4...

### Modal no funciona al hacer click

1. Abrir DevTools (F12) y revisar errores en consola
2. Verificar que `gallery.js` esta cargado
3. Validar que el JSON no tiene errores de sintaxis

### Cambios no visibles en produccion

1. Verificar que el push a GitHub se completo
2. Confirmar que el repo en VPS esta actualizado: `ssh gabriel@167.172.251.27 "cd /home/gabriel/luanti-voxelibre-server && git log -1 --oneline"`
3. Esperar 5 minutos por cache de JSON en nginx
4. Forzar recarga en navegador: Ctrl+Shift+R

### Imagen muy pesada

```bash
# Redimensionar
convert imagen.png -resize 1920x1080 imagen.png

# Reducir calidad
convert imagen.png -quality 85 imagen.png

# Verificar tamaño
du -h imagen.png
```

---

## Mejores Practicas

- Imagenes < 1MB, idealmente < 500KB
- Nombres descriptivos sin espacios (usar guiones)
- Descripciones en lenguaje child-friendly (7+ años), entusiastas y positivas
- Solo una imagen con `featured: true` (la de `priority: 1`)
- Validar JSON antes de cada deploy
- Remover badges de posts antiguos (poner `null`)

---

**Ultima actualizacion**: 2026-02-04
