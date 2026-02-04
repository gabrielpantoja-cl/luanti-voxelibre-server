# Sistema de Layout - Wetlands Landing Page

Documentacion del layout y componentes compartidos entre las paginas de la landing page.

## Paginas

| Archivo | Descripcion |
|---------|-------------|
| `index.html` | Homepage con hero section y ultimas 4 imagenes de galeria |
| `galeria.html` | Galeria completa con filtros por categoria y modal de imagen |

Ambas paginas comparten la misma estructura visual: header con logo y navegacion, contenido principal, y footer con informacion del servidor.

## Footer

El footer esta **hardcoded inline** en cada archivo HTML. No se carga dinamicamente.

### Archivos relacionados

| Archivo | Estado | Proposito |
|---------|--------|-----------|
| `index.html` (footer section) | Activo | Footer inline en homepage |
| `galeria.html` (footer section) | Activo | Footer inline en galeria |
| `assets/components/footer.html` | Referencia | Plantilla de referencia (no se usa en runtime) |
| `assets/js/shared-layout.js` | Inactivo | Loader dinamico preparado pero no usado |
| `assets/js/components/footer.js` | Inactivo | Componente JS preparado pero no usado |
| `assets/js/components/header.js` | Inactivo | Componente JS preparado pero no usado |

### Actualizar el footer

Al modificar el footer, editar manualmente en ambos archivos HTML:

1. Editar `assets/components/footer.html` (como plantilla de referencia)
2. Copiar el contenido actualizado a `index.html`
3. Copiar el contenido actualizado a `galeria.html`
4. Verificar que ambos footers sean identicos

### Contenido actual del footer

El footer incluye estos comandos del servidor:

```
/back_to_spawn     - Volver al inicio
/area_pos1         - Marcar esquina 1
/area_pos2         - Marcar esquina 2
/protect [nombre]  - Proteger area
/reglas            - Ver reglas importantes
/sit               - Sentarse
/santuario         - Cuidar animalitos
/filosofia         - Conocer nuestra mision
/lay               - Recostarse en pasto
/?                 - Ver todos los comandos
```

## JavaScript

| Archivo | Proposito |
|---------|-----------|
| `assets/js/main.js` | Logica principal de index.html (hero, animaciones, carga de galeria preview) |
| `assets/js/gallery.js` | Renderizado de galeria, filtros por categoria, modal de imagen |
| `assets/js/mobile-nav.js` | Navegacion responsive para moviles |

## Desarrollo Local

Abrir directamente los archivos HTML en el navegador:

```bash
cd /home/gabriel/Documentos/luanti-voxelibre-server/server/landing-page
firefox index.html
firefox galeria.html
```

Para probar con un servidor HTTP local (necesario si se activa el footer dinamico en el futuro):

```bash
cd /home/gabriel/Documentos/luanti-voxelibre-server/server/landing-page
python3 -m http.server 8000
# Abrir http://localhost:8000
```

---

**Ultima actualizacion**: 2026-02-04
