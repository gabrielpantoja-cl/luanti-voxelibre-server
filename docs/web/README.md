# 🌐 Frontend y Landing Page

Documentación sobre el desarrollo web del servidor, incluyendo la landing page y futuras APIs.

## 📋 Contenido

- **[Landing Page](landing-page.md)** - Desarrollo y despliegue de la página web
- **[API Docs](api-docs.md)** - Documentación para futuras APIs del servidor

## 🎨 Arquitectura Web

### Landing Page (Activa)
- **URL**: https://luanti.gabrielpantoja.cl
- **Tecnologías**: HTML5, CSS3, JavaScript vanilla
- **Diseño**: Responsivo, child-friendly
- **Deploy**: Script automatizado con rsync

### Futuras Implementaciones
- API de estadísticas del servidor
- Sistema de registro web
- Galería de construcciones de jugadores

## 🚀 Desarrollo Local

```bash
# Editar archivos en server/landing-page/
nano server/landing-page/index.html

# Desplegar cambios
./scripts/deploy-landing.sh

# Verificar despliegue
curl -I https://luanti.gabrielpantoja.cl
```

## 🎯 Objetivos de Diseño

- **Simplicidad**: Interface intuitiva para niños de 7+ años
- **Accesibilidad**: Compatible con lectores de pantalla
- **Performance**: Carga rápida y optimizada
- **Seguridad**: Headers de seguridad apropiados