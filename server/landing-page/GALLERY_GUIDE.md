# Guia de Mantenimiento de la Galeria de Wetlands

## Sistema Centralizado de Galeria

La galeria de Wetlands usa un sistema centralizado basado en JSON que:
- Una sola fuente de datos (`assets/data/gallery-data.json`)
- Renderizado dinamico en ambas paginas (index.html y galeria.html)
- Facil de mantener y escalar
- Consistencia garantizada entre paginas

## Como Agregar una Nueva Imagen

### Paso 1: Preparar la Imagen

1. **Tomar screenshot en Luanti**:
   - Presiona `F12` en el juego para capturar pantalla
   - O usa el boton de captura en tu sistema operativo

2. **Mover imagen a la carpeta correcta**:
   ```bash
   mv ~/Pictures/nueva-captura.png server/landing-page/assets/images/
   ```

3. **Optimizar imagen** (opcional pero recomendado):
   ```bash
   cd server/landing-page/assets/images/

   # Redimensionar si es muy grande (max 1920x1080)
   convert nueva-captura.png -resize 1920x1080 nueva-captura.png

   # Optimizar calidad (85% es un buen balance)
   convert nueva-captura.png -quality 85 nueva-captura.png

   # Verificar tamaño (idealmente < 1MB)
   du -h nueva-captura.png
   ```

4. **Renombrar con nombre descriptivo** (opcional):
   ```bash
   mv nueva-captura.png mod-bicicletas-2025.png
   ```

### Paso 2: Agregar Entrada al JSON

Edita `server/landing-page/assets/data/gallery-data.json`:

```json
{
  "version": "1.0.0",
  "lastUpdated": "2025-11-26",
  "images": [
    {
      "id": "unique-id-2025-12",
      "filename": "mod-bicicletas-2025.png",
      "title": "Titulo Descriptivo",
      "emoji": "🚴",
      "description": "Descripcion child-friendly de 1-2 lineas explicando la novedad",
      "date": "2025-12",
      "dateLabel": "Diciembre 2025",
      "badge": {
        "text": "NUEVA ACTUALIZACION!",
        "emoji": "🆕",
        "type": "new"
      },
      "category": "updates",
      "featured": false,
      "priority": 1
    },
    ... imagenes existentes ...
  ]
}
```

### Paso 3: Ajustar Prioridades

**IMPORTANTE**: El campo `priority` determina el orden de visualizacion.
- `priority: 1` = Primera imagen (mas reciente)
- `priority: 2` = Segunda imagen
- etc.

**Cuando agregas una nueva imagen**:
1. Dale `priority: 1` a la nueva imagen
2. Incrementa en 1 la prioridad de TODAS las imagenes existentes
3. Esto asegura que la nueva imagen aparezca primero

**Ejemplo**:
```json
// ANTES (imagenes existentes):
{"id": "vehicles", "priority": 1}
{"id": "bathroom", "priority": 2}
{"id": "halloween", "priority": 3}

// DESPUES (nueva imagen agregada):
{"id": "nueva-bicicletas", "priority": 1}  // <- NUEVA
{"id": "vehicles", "priority": 2}           // <- Incrementado
{"id": "bathroom", "priority": 3}           // <- Incrementado
{"id": "halloween", "priority": 4}          // <- Incrementado
```

### Paso 4: Configurar Metadata

#### Campo `id` (requerido)
- Identificador unico
- Formato sugerido: `nombre-descriptivo-año-mes`
- Ejemplo: `mod-bicicletas-2025-12`

#### Campo `filename` (requerido)
- Nombre exacto del archivo en `assets/images/`
- Incluir extension (.png, .jpeg, .jpg)
- Ejemplo: `mod-bicicletas-2025.png`

#### Campo `title` (requerido)
- Titulo corto y descriptivo
- Sin emojis (se agregan automaticamente)
- Ejemplo: `Bicicletas Disponibles`

#### Campo `emoji` (requerido)
- Un emoji relevante
- Ejemplos: 🚴 🏠 🎃 🛡️ 📺 👥 🏞️

#### Campo `description` (requerido)
- 1-2 lineas de descripcion
- Lenguaje child-friendly (7+ años)
- Entusiasta y positivo
- Ejemplo: `Ahora puedes andar en bicicleta por Wetlands! Pedalea por caminos, salta rampas y diviertete explorando en dos ruedas.`

#### Campo `date` (requerido)
- Formato: `YYYY-MM` o `YYYY-MM-DD`
- Usado para ordenamiento
- Ejemplo: `2025-12` o `2025-12-15`

#### Campo `dateLabel` (requerido)
- Fecha legible para humanos
- Se muestra en la interfaz
- Formato: `[Mes] YYYY` o `[Mes Abreviado] YYYY`
- Ejemplos: `Diciembre 2025`, `Dic 2025`, `Oct 2025`

#### Campo `badge` (opcional)
- Si es `null`, no se muestra badge
- Si existe, debe tener:
  - `text`: Texto del badge
  - `emoji`: Emoji del badge
  - `type`: Tipo de badge (`new`, `event`, `update`)

**Ejemplos de badges**:
```json
// Nueva actualizacion
"badge": {
  "text": "NUEVA ACTUALIZACION!",
  "emoji": "🆕",
  "type": "new"
}

// Evento especial
"badge": {
  "text": "EVENTO ACTIVO!",
  "emoji": "👻",
  "type": "event"
}

// Actualizacion reciente (no tan nueva)
"badge": {
  "text": "ACTUALIZACION RECIENTE",
  "emoji": "🔥",
  "type": "new"
}

// Sin badge
"badge": null
```

#### Campo `category` (requerido)
- Categorias disponibles:
  - `updates`: Actualizaciones, nuevos mods, features
  - `gameplay`: Capturas de gameplay, construcciones
  - `community`: Fotos de jugadores, eventos comunitarios

#### Campo `featured` (requerido)
- `true`: Se muestra con estilo destacado (solo para primera imagen)
- `false`: Estilo normal
- **Recomendacion**: Solo la imagen con `priority: 1` debe tener `featured: true`

#### Campo `priority` (requerido)
- Numero entero que determina orden de visualizacion
- Menor numero = mayor prioridad (aparece primero)
- Ejemplo: `1, 2, 3, 4, ...`

## Ejemplo Completo: Agregar Mod de Bicicletas

### 1. Preparar Imagen
```bash
# Mover screenshot
mv ~/Pictures/bicicleta-mod.png server/landing-page/assets/images/mod-bicicletas-2025.png

# Optimizar
cd server/landing-page/assets/images/
convert mod-bicicletas-2025.png -resize 1920x1080 -quality 85 mod-bicicletas-2025.png
du -h mod-bicicletas-2025.png  # Verificar tamaño
```

### 2. Editar JSON
Abrir `server/landing-page/assets/data/gallery-data.json` y:

1. Agregar nueva entrada al inicio del array `images`:
```json
{
  "id": "mod-bicicletas-2025-12",
  "filename": "mod-bicicletas-2025.png",
  "title": "Bicicletas Disponibles",
  "emoji": "🚴",
  "description": "Ahora puedes andar en bicicleta por Wetlands! Pedalea por caminos, salta rampas y diviertete explorando en dos ruedas.",
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

2. Actualizar `featured` de la imagen anterior:
```json
// Cambiar la imagen que tenia featured: true
{
  "id": "vehicles-2025-11",
  "featured": false,  // <- Cambiar a false
  "priority": 2       // <- Incrementar prioridad
}
```

3. Incrementar `priority` de TODAS las demas imagenes en +1

4. Actualizar `lastUpdated`:
```json
{
  "version": "1.0.0",
  "lastUpdated": "2025-12-15",  // <- Fecha actual
  "images": [ ... ]
}
```

### 3. Verificar Localmente
```bash
# Abrir en navegador local
cd server/landing-page
xdg-open index.html
xdg-open galeria.html
```

Verificar:
- ✅ Imagen nueva aparece primero en index.html
- ✅ Imagen nueva aparece primero en galeria.html
- ✅ Modal funciona al hacer click
- ✅ Badge se muestra correctamente
- ✅ Descripcion es legible y child-friendly

### 4. Commit y Deploy
```bash
cd /home/gabriel/Documentos/luanti-voxelibre-server

# Agregar cambios
git add server/landing-page/assets/data/gallery-data.json
git add server/landing-page/assets/images/mod-bicicletas-2025.png

# Commit descriptivo
git commit -m "Agregar anuncio de mod de bicicletas en galeria

- Nueva imagen: mod-bicicletas-2025.png
- Actualizar gallery-data.json con entrada de bicicletas
- Ajustar prioridades de imagenes existentes
- Fecha: Diciembre 2025"

# Push
git push origin main

# Deploy a produccion
./scripts/deploy-landing.sh
```

### 5. Verificar en Produccion
```bash
# Test HTTP status
curl -I https://luanti.gabrielpantoja.cl

# Abrir en navegador
xdg-open https://luanti.gabrielpantoja.cl
xdg-open https://luanti.gabrielpantoja.cl/galeria.html
```

## Troubleshooting

### Problema: Imagen no aparece en galeria

**Posibles causas**:
1. **Nombre de archivo incorrecto**:
   - Verificar que `filename` en JSON coincida exactamente con el archivo
   - Revisar mayusculas/minusculas
   - Revisar espacios en el nombre

2. **JSON mal formado**:
   - Usar validador JSON online: https://jsonlint.com/
   - Verificar comas, comillas, brackets

3. **Imagen no subida al servidor**:
   - Verificar con `git status` que imagen esta staged
   - Verificar que deployment se ejecuto correctamente

**Solucion**:
```bash
# Verificar nombre de archivo
ls -la server/landing-page/assets/images/ | grep bicicleta

# Validar JSON
cat server/landing-page/assets/data/gallery-data.json | python3 -m json.tool

# Verificar git status
git status
```

### Problema: Orden de imagenes incorrecto

**Causa**: Campo `priority` mal configurado

**Solucion**:
1. Revisar valores de `priority` en JSON
2. Asegurar que no hay duplicados
3. Verificar que nueva imagen tiene `priority: 1`
4. Asegurar que valores son consecutivos (1, 2, 3, 4, ...)

### Problema: Badge no se muestra

**Causa**: Campo `badge` mal configurado

**Solucion**:
```json
// Correcto (con badge)
"badge": {
  "text": "NUEVA ACTUALIZACION!",
  "emoji": "🆕",
  "type": "new"
}

// Correcto (sin badge)
"badge": null

// INCORRECTO
"badge": {}  // <- No usar objeto vacio
```

### Problema: Modal no funciona al hacer click

**Causa**: JavaScript no cargado o error en consola

**Solucion**:
1. Abrir DevTools (F12)
2. Revisar consola de errores
3. Verificar que `gallery.js` esta cargado
4. Verificar que no hay errores en JSON

### Problema: Imagen muy pesada (tarda en cargar)

**Solucion**: Optimizar imagen
```bash
# Reducir calidad
convert imagen.png -quality 75 imagen.png

# Convertir a WebP (mejor compresion)
cwebp -q 85 imagen.png -o imagen.webp

# Redimensionar
convert imagen.png -resize 1920x1080 imagen.png
```

## Mejores Practicas

### Imagenes
- ✅ Tamaño maximo: 1920x1080
- ✅ Peso maximo: 1MB (idealmente < 500KB)
- ✅ Formato: PNG o JPEG
- ✅ Nombres descriptivos sin espacios (usar guiones)
- ✅ Capturas de buena calidad y bien iluminadas

### Descripciones
- ✅ Lenguaje child-friendly (7+ años)
- ✅ Entusiasta y positivo
- ✅ 1-2 lineas maximo
- ✅ Explicar que es la novedad
- ✅ Evitar jerga tecnica compleja

### Orden de Prioridad
- `priority: 1-3`: Novedades mas recientes (ultimas 1-2 semanas)
- `priority: 4-6`: Actualizaciones recientes (ultimo mes)
- `priority: 7+`: Contenido mas antiguo

### Badges
- 🆕 `NUEVA ACTUALIZACION!`: Novedades de esta semana
- 🔥 `ACTUALIZACION RECIENTE`: Novedades del ultimo mes
- 👻 `EVENTO ACTIVO!`: Eventos especiales temporales
- Sin badge: Contenido mas antiguo o gameplay general

### Categorias
- `updates`: Mods nuevos, features, actualizaciones del servidor
- `gameplay`: Capturas de jugadores jugando, construcciones
- `community`: Fotos de la comunidad, eventos sociales

## Automatizacion Futura

### Script de Ayuda (Planeado)
```bash
# Script para agregar imagen facilmente
./scripts/add-gallery-image.sh \
  --image="nueva-imagen.png" \
  --title="Titulo" \
  --emoji="🎮" \
  --description="Descripcion" \
  --category="updates" \
  --badge="new"
```

Este script:
- Optimizaria imagen automaticamente
- Agregaria entrada al JSON
- Ajustaria prioridades automaticamente
- Crearia commit y haria deploy

## Soporte

Si tienes problemas:
1. Revisar esta guia
2. Verificar ejemplos en `gallery-data.json`
3. Consultar consola del navegador (F12)
4. Revisar logs de deployment

## Recursos

- Validador JSON: https://jsonlint.com/
- Optimizador de imagenes online: https://tinypng.com/
- Emojis: https://emojipedia.org/
- Landing page: https://luanti.gabrielpantoja.cl

---

**Ultima actualizacion**: 2025-11-26
**Mantenido por**: Gabriel Pantoja
**Proposito**: Guia completa para mantener la galeria de Wetlands
