# Sistema de Layout Compartido - Wetlands Landing Page

## Descripción

Sistema para mantener consistencia visual entre todas las páginas de la landing page de Wetlands. Permite compartir componentes comunes (footer, header) sin duplicar código HTML.

## Archivos Clave

```
landing-page/
├── assets/
│   ├── components/
│   │   └── footer.html          # Plantilla de footer compartida
│   └── js/
│       ├── shared-layout.js      # Sistema de carga de componentes
│       ├── components/
│       │   ├── header.js         # Componente header (futuro)
│       │   └── footer.js         # Componente footer (alternativa)
│       └── pages/
│           ├── home.js           # Lógica página home (futuro)
│           └── gallery.js        # Lógica página gallery (existente)
├── index.html                    # Página principal
├── galeria.html                  # Página de galería
└── LAYOUT_SYSTEM.md              # Esta documentación
```

## Estado Actual (Octubre 2025)

### ✅ Implementación Actual
- **Footer sincronizado** en `index.html` y `galeria.html` (ambos tienen el mismo footer correcto)
- **Footer template** creado en `assets/components/footer.html`
- **Script de carga** `shared-layout.js` disponible para futuras páginas
- **Comandos actualizados** con protección de áreas (`/area_pos1`, `/area_pos2`, `/protect`)

### 📋 Páginas Actuales
1. **index.html** - Footer inline actualizado ✅
2. **galeria.html** - Footer inline actualizado ✅

## Cómo Usar en Nuevas Páginas

### Opción 1: Footer Inline (Recomendado para pocas páginas)

Simplemente copia el footer de `index.html` o `galeria.html`:

```html
<!-- Footer -->
<footer class="footer">
    <div class="container">
        <!-- ... contenido del footer ... -->
    </div>
</footer>
```

**Ventajas:**
- SEO-friendly (contenido estático)
- Sin dependencias JavaScript
- Funciona sin servidor local

**Desventajas:**
- Duplicación de código
- Requiere actualizar manualmente cada página

### Opción 2: Footer Dinámico con JavaScript (Futuro)

Para nuevas páginas, usa el sistema de carga dinámica:

```html
<!DOCTYPE html>
<html lang="es">
<head>
    <!-- ... meta tags y estilos ... -->
</head>
<body>
    <!-- Tu contenido aquí -->

    <!-- Footer placeholder -->
    <div id="footer-placeholder"></div>

    <!-- Scripts -->
    <script src="assets/js/shared-layout.js"></script>
    <script src="assets/js/main.js"></script>
</body>
</html>
```

**Ventajas:**
- Un solo lugar para actualizar el footer
- Menos duplicación de código
- Consistencia garantizada

**Desventajas:**
- Requiere servidor local para desarrollo (fetch API)
- Pequeño retraso de carga (imperceptible)

## Actualizar el Footer Compartido

### Si usas Footer Inline (Estado Actual)

1. Edita `assets/components/footer.html` (plantilla de referencia)
2. Copia y pega el contenido en:
   - `index.html` (línea 305-345)
   - `galeria.html` (línea 236-276)

### Si usas Footer Dinámico (Futuro)

1. Edita solo `assets/components/footer.html`
2. Los cambios se reflejan automáticamente en todas las páginas

## Comandos del Footer

El footer actual incluye estos comandos mágicos:

```
⚡ Comandos Mágicos:
/back_to_spawn     - Volver al inicio 🏠
/area_pos1         - Marcar esquina 1 🛡️
/area_pos2         - Marcar esquina 2 🛡️
/protect [nombre]  - Proteger área 🔒
/reglas            - Ver reglas importantes 📋
/sit               - Sentarse cómodamente 🪑
/santuario         - Cuidar animalitos 🐾
/filosofia         - Conocer nuestra misión 🌟
/lay               - Recostarse en pasto 🌱
/?                 - Ver todos los comandos ✨
```

## Desarrollo Local

### Con Footer Inline (Actual)
Abre directamente los archivos HTML en el navegador:

```bash
# Navegar al directorio
cd /home/gabriel/Documentos/luanti-voxelibre-server/server/landing-page

# Abrir en navegador
firefox index.html
firefox galeria.html
```

### Con Footer Dinámico (Futuro)
Requiere un servidor HTTP local:

```bash
# Opción 1: Python SimpleHTTPServer
cd /home/gabriel/Documentos/luanti-voxelibre-server/server/landing-page
python3 -m http.server 8000

# Opción 2: Node.js http-server
npx http-server -p 8000

# Luego abrir: http://localhost:8000
```

## Testing

### Verificar Footer Correcto

1. Abrir `index.html` en navegador
2. Scrollear hasta el footer
3. Verificar que aparezcan estos comandos:
   - ✅ `/area_pos1`, `/area_pos2`, `/protect`
   - ✅ `/santuario`, `/filosofia`, `/lay`
   - ❌ NO deben aparecer: `/home`, `/sethome`

4. Abrir `galeria.html`
5. Verificar que el footer sea idéntico al de `index.html`

## Migración Futura (Opcional)

Si decides migrar a footer dinámico:

### Paso 1: Actualizar HTML

**Antes:**
```html
<footer class="footer">
    <!-- 40+ líneas de HTML -->
</footer>
```

**Después:**
```html
<div id="footer-placeholder"></div>
```

### Paso 2: Agregar Script

```html
<script src="assets/js/shared-layout.js"></script>
```

### Paso 3: Probar

```bash
python3 -m http.server 8000
# Abrir http://localhost:8000
```

## Buenas Prácticas

1. **Actualiza siempre la plantilla primero**
   - Edita `assets/components/footer.html`
   - Luego sincroniza a páginas HTML

2. **Mantén consistencia visual**
   - Usa las mismas clases CSS
   - Respeta la estructura HTML existente

3. **Documenta cambios**
   - Actualiza este README si cambias la estructura
   - Anota nuevos comandos en la sección "Comandos del Footer"

4. **Prueba en todas las páginas**
   - Verifica `index.html` y `galeria.html`
   - Revisa responsiveness móvil

## Deployment

Al hacer deployment con `./scripts/deploy-landing.sh`:

```bash
# El script copia todo el directorio landing-page
# Incluyendo:
rsync -avz server/landing-page/ gabriel@167.172.251.27:/home/gabriel/vps-do/nginx/www/luanti-landing/
```

Los cambios en el footer se reflejan automáticamente en:
- https://luanti.gabrielpantoja.cl
- https://luanti.gabrielpantoja.cl/galeria.html

## Troubleshooting

### Footer no carga en página dinámica
- Verifica que estés usando un servidor HTTP local
- Revisa la consola del navegador (F12)
- Confirma que `assets/components/footer.html` existe

### Footer diferente entre páginas
- Verifica que hayas actualizado ambos archivos HTML
- Compara manualmente el HTML del footer
- Usa el footer de `index.html` como referencia

### Comandos obsoletos aparecen
- Edita el archivo HTML correspondiente
- Busca la sección `<h4>⚡ Comandos Mágicos</h4>`
- Reemplaza con contenido de `assets/components/footer.html`

## Historial de Cambios

### 2025-10-12
- ✅ Footer sincronizado entre `index.html` y `galeria.html`
- ✅ Comandos actualizados con protección de áreas
- ✅ Creado sistema de componentes compartidos
- ✅ Documentación completa del sistema

### 2025-09-27 (Estado Anterior)
- ⚠️ Footer desincronizado entre páginas
- ⚠️ `galeria.html` tenía comandos obsoletos (`/home`, `/sethome`)
- ⚠️ Faltaba `/area_pos1`, `/area_pos2`, `/protect`

## Referencias

- **index.html**: Líneas 305-345 (footer correcto)
- **galeria.html**: Líneas 236-276 (footer actualizado)
- **Plantilla**: `assets/components/footer.html`
- **Script loader**: `assets/js/shared-layout.js`
- **Deployment**: `scripts/deploy-landing.sh`

---

**Última actualización**: 2025-10-12
**Autor**: Gabriel Pantoja
**Proyecto**: Wetlands Landing Page
