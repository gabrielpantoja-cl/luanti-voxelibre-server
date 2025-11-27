# Sistema de Galeria Centralizado - Wetlands

## Inicio Rapido

### Agregar Nueva Imagen (3 Pasos)

1. **Agregar imagen a carpeta**:
   ```bash
   cp screenshot.png server/landing-page/assets/images/nueva-imagen.png
   ```

2. **Editar JSON** (`assets/data/gallery-data.json`):
   - Agregar nueva entrada al inicio del array `images`
   - Incrementar `priority` de imagenes existentes en +1
   - Actualizar `lastUpdated`

3. **Validar y Deploy**:
   ```bash
   # Validar localmente
   python3 server/landing-page/scripts/validate-gallery.py

   # Deploy a produccion
   ./scripts/deploy-landing.sh
   ```

## Ejemplo Rapido

```json
{
  "id": "nueva-feature-2025-12",
  "filename": "nueva-imagen.png",
  "title": "Titulo Corto",
  "emoji": "🎮",
  "description": "Descripcion child-friendly de 1-2 lineas",
  "date": "2025-12",
  "dateLabel": "Diciembre 2025",
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

## Estructura del Sistema

```
server/landing-page/
├── assets/
│   ├── data/
│   │   └── gallery-data.json        # Fuente unica de datos
│   ├── images/
│   │   └── *.png                    # Imagenes de la galeria
│   └── js/
│       └── gallery.js               # Renderizado dinamico
├── index.html                       # Muestra ultimas 4 imagenes
├── galeria.html                     # Muestra todas las imagenes
├── scripts/
│   └── validate-gallery.py          # Validacion antes de deploy
├── GALLERY_GUIDE.md                 # Guia completa detallada
└── GALLERY_README.md                # Este archivo (inicio rapido)
```

## Campos Requeridos

- `id`: Identificador unico
- `filename`: Nombre del archivo en assets/images/
- `title`: Titulo descriptivo
- `emoji`: Un emoji relevante
- `description`: 1-2 lineas child-friendly
- `date`: Formato YYYY-MM
- `dateLabel`: Fecha legible (ej: "Diciembre 2025")
- `badge`: Objeto con badge info o `null`
- `category`: "updates", "gameplay", o "community"
- `featured`: `true` solo para priority 1, `false` para el resto
- `priority`: Numero entero (1 = mas reciente)

## Categorias

- `updates`: Mods nuevos, features, actualizaciones
- `gameplay`: Capturas de jugadores, construcciones
- `community`: Fotos de comunidad, eventos

## Badges Disponibles

```json
// Nueva actualizacion
"badge": {"text": "NUEVA ACTUALIZACION!", "emoji": "🆕", "type": "new"}

// Evento especial
"badge": {"text": "EVENTO ACTIVO!", "emoji": "👻", "type": "event"}

// Actualizacion reciente
"badge": {"text": "ACTUALIZACION RECIENTE", "emoji": "🔥", "type": "new"}

// Sin badge
"badge": null
```

## Validacion Local

```bash
# Validar JSON y verificar imagenes
python3 server/landing-page/scripts/validate-gallery.py

# Abrir en navegador local
xdg-open server/landing-page/index.html
xdg-open server/landing-page/galeria.html
```

## Deployment

```bash
# Deploy a produccion
./scripts/deploy-landing.sh

# Verificar en produccion
curl -I https://luanti.gabrielpantoja.cl
xdg-open https://luanti.gabrielpantoja.cl
```

## Troubleshooting

### Imagen no aparece
- Verificar nombre de archivo en JSON coincide con archivo real
- Validar JSON con: `python3 scripts/validate-gallery.py`
- Revisar consola del navegador (F12) para errores

### Orden incorrecto
- Verificar campo `priority` (1 = primero)
- Asegurar que no hay duplicados de priority

### Modal no funciona
- Abrir DevTools (F12) y revisar errores en consola
- Verificar que gallery.js esta cargado

## Recursos

- **Guia Completa**: `GALLERY_GUIDE.md`
- **Validador JSON**: https://jsonlint.com/
- **Optimizador de Imagenes**: https://tinypng.com/
- **Produccion**: https://luanti.gabrielpantoja.cl

## Mejores Practicas

- ✅ Imagenes < 1MB (idealmente < 500KB)
- ✅ Nombres descriptivos sin espacios
- ✅ Descripciones child-friendly (7+ años)
- ✅ Validar antes de deploy
- ✅ Una sola imagen con `featured: true`

---

**Version**: 1.0.0
**Fecha**: 2025-11-26
