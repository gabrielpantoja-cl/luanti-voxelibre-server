# 🎭 Playwright MCP Server - Instalación en Claude Code

**Fecha de instalación**: 2025-12-07
**Sistema**: Linux Mint
**Propósito**: Permitir que Claude Code controle navegadores para automatizar tareas web

## ✅ Instalación Completada

### 1. Servidor MCP Instalado
```bash
claude mcp add playwright npx @playwright/mcp@latest
```

**Resultado**:
- ✅ Servidor configurado en `~/.claude.json`
- ✅ Versión instalada: `@playwright/mcp@0.0.50`
- ✅ Claude Code puede ahora controlar navegadores

### 2. Configuración en ~/.claude.json
```json
{
  "playwright": {
    "type": "stdio",
    "command": "npx",
    "args": ["@playwright/mcp@latest"],
    "env": {}
  }
}
```

## ⚠️ Pendiente: Dependencias del Sistema

Para que los navegadores funcionen correctamente, **debes ejecutar manualmente** (requiere contraseña de administrador):

```bash
sudo npx playwright install-deps
```

Este comando instala:
- Bibliotecas de sistema para Chromium
- Bibliotecas de sistema para Firefox
- Bibliotecas de sistema para WebKit
- Dependencias de audio/video
- Fuentes del sistema

## 🎯 Capacidades de Claude Code con Playwright

Una vez instaladas las dependencias del sistema, Claude Code podrá:

### Navegación Web Automatizada
- Abrir navegadores (Chromium, Firefox, WebKit)
- Navegar a URLs específicas
- Hacer clic en elementos de la página
- Llenar formularios automáticamente
- Extraer información de páginas web

### Capturas y Testing
- Tomar screenshots de páginas completas
- Tomar screenshots de elementos específicos
- Generar PDFs de páginas web
- Realizar tests de interfaz de usuario
- Validar responsive design

### Casos de Uso para Wetlands

#### 1. Descargar Skins de Minecraft
```
Usuario: "Descarga esta skin de MinecraftSkins.com: [URL]"
Claude Code:
- Abre navegador
- Navega a la página
- Encuentra el botón de descarga
- Descarga el archivo PNG
- Lo guarda en la ubicación correcta
```

#### 2. Verificar Landing Page
```
Usuario: "Verifica que la landing page se vea bien en móvil"
Claude Code:
- Abre navegador en modo móvil
- Navega a luanti.gabrielpantoja.cl
- Toma screenshots en diferentes resoluciones
- Reporta problemas visuales
```

#### 3. Buscar Recursos
```
Usuario: "Busca texturas de vegetales para VoxeLibre"
Claude Code:
- Abre navegador
- Busca en Google/DuckDuckGo
- Navega a resultados relevantes
- Descarga recursos apropiados
- Organiza archivos
```

## 🚀 Comandos de Verificación

### Verificar instalación MCP
```bash
npx @playwright/mcp@latest --version
```

### Ver configuración
```bash
cat ~/.claude.json | grep -A 5 playwright
```

### Instalar navegadores manualmente (si es necesario)
```bash
npx playwright install chromium
npx playwright install firefox
npx playwright install webkit
```

## 🛠️ Troubleshooting

### Error: "browserType.launch: Executable doesn't exist"
**Solución**: Instalar dependencias del sistema
```bash
sudo npx playwright install-deps
npx playwright install
```

### Error: "EACCES: permission denied"
**Solución**: El directorio de cache de Playwright necesita permisos
```bash
sudo chown -R $USER:$USER ~/.cache/ms-playwright
```

### Navegadores no se abren
**Solución**: Verificar que se instalaron los navegadores
```bash
npx playwright install --with-deps
```

## 📚 Documentación Oficial

- **Playwright MCP**: https://github.com/playwright/playwright-mcp
- **Playwright Docs**: https://playwright.dev/
- **Claude Code MCP**: https://github.com/anthropics/claude-code/blob/main/docs/mcp.md

## 🔒 Seguridad y Limitaciones

### Hosts Permitidos
Por defecto, el servidor MCP solo acepta conexiones del host local. Para cambiar esto:
```bash
claude mcp configure playwright
# Agregar --allowed-hosts '*' si es necesario
```

### Orígenes Bloqueados
Puedes bloquear dominios específicos para evitar accesos no deseados:
```bash
# Configurar en ~/.claude.json manualmente
"args": [
  "@playwright/mcp@latest",
  "--blocked-origins",
  "malware.com;phishing.net"
]
```

## 💡 Tips de Uso

1. **Siempre específica el navegador**: "Usa Chromium para..." es más claro
2. **Capturas de pantalla útiles**: Pide screenshots cuando algo no funcione
3. **Modo headless**: Por defecto se ejecuta sin interfaz visual (más rápido)
4. **Modo con cabeza**: Útil para debugging: "Abre Firefox con interfaz visual"

## 🌱 Casos de Uso Específicos para Wetlands

### Descargar Skins desde MinecraftSkins.com
```
Tarea: "Ve a MinecraftSkins.com, busca 'farmer', descarga la primera skin
y conviértela a formato VoxeLibre"
```

### Verificar Deployment de Landing Page
```
Tarea: "Abre luanti.gabrielpantoja.cl, toma screenshot completo,
verifica que el servidor aparezca como 'Online'"
```

### Buscar Recursos de ContentDB
```
Tarea: "Busca en content.luanti.org mods de animales compatibles con
VoxeLibre, descarga los top 3"
```

---
**Instalado por**: Claude Code
**Mantenedor**: Gabriel Pantoja
**Última actualización**: 2025-12-07
