# MCP Servers - Configuracion para Claude Code

**Ultima actualizacion**: 2026-02-11

## Resumen

Este proyecto usa 4 MCP servers configurados en scope **local** (solo en `~/.claude.json`, no commiteados al repo).

| Server | Paquete | Estado | Credenciales |
|--------|---------|--------|-------------|
| **context7** | `@upstash/context7-mcp` | Listo | No requiere |
| **playwright** | `@playwright/mcp` | Listo | No requiere |
| **github** | `@modelcontextprotocol/server-github` | Necesita token | `GITHUB_PERSONAL_ACCESS_TOKEN` |
| **google-analytics** | `mcp-server-google-analytics` | Necesita credenciales | Service Account + GA4 Property ID |

## Configuracion rapida (nuevo equipo)

### 1. Context7 (documentacion actualizada)
```bash
claude mcp add-json --scope local context7 '{"type":"stdio","command":"cmd","args":["/c","npx","-y","@upstash/context7-mcp@latest"],"env":{}}'
```

### 2. Playwright (browser automation)
```bash
claude mcp add-json --scope local playwright '{"type":"stdio","command":"cmd","args":["/c","npx","-y","@playwright/mcp@latest"],"env":{}}'
```

### 3. GitHub (repo integration)
```bash
claude mcp add-json --scope local github '{"type":"stdio","command":"cmd","args":["/c","npx","-y","@modelcontextprotocol/server-github@latest"],"env":{"GITHUB_PERSONAL_ACCESS_TOKEN":"TU_TOKEN_AQUI"}}'
```

Para obtener el token:
1. Ve a https://github.com/settings/tokens
2. Generate new token (classic) o Fine-grained token
3. Permisos minimos: `repo`, `read:org`
4. Copia el token y reemplaza `TU_TOKEN_AQUI`

### 4. Google Analytics 4
Ver guia completa: [GA4_MCP_SETUP.md](./GA4_MCP_SETUP.md)

## Diferencias Windows vs Linux

En **Windows**, los servidores stdio con npx requieren el wrapper `cmd /c`:

```json
// Windows
{"command": "cmd", "args": ["/c", "npx", "-y", "package"]}

// Linux
{"command": "npx", "args": ["-y", "package"]}
```

**IMPORTANTE**: Usar `claude mcp add -- cmd /c npx ...` en Windows causa un bug donde `/c` se interpreta como `C:/`. Siempre usar `claude mcp add-json` en Windows.

## Verificacion

```bash
# Listar todos los MCP servers y su estado
claude mcp list

# Ver detalles de uno especifico
claude mcp get context7

# Desde dentro de Claude Code
/mcp
```

## Scopes de MCP

| Scope | Archivo | Compartido en git | Uso |
|-------|---------|-------------------|-----|
| `local` (actual) | `~/.claude.json` | No | Personal, con credenciales |
| `project` | `.mcp.json` (raiz repo) | Si | Compartido con equipo |
| `user` | `~/.claude.json` (global) | No | Todos los proyectos |

Este proyecto usa **local** porque los servers tienen credenciales personales.

## Troubleshooting

### "Failed to connect"
1. Verificar que `node` y `npx` estan instalados: `where npx`
2. En Windows, verificar que se usa el wrapper `cmd /c`
3. Probar el comando manualmente: `cmd /c npx -y @upstash/context7-mcp@latest`

### GitHub MCP: "Bad credentials"
1. Verificar que el token no ha expirado
2. Regenerar token en https://github.com/settings/tokens
3. Actualizar: `claude mcp remove --scope local github` y re-agregar

### GA4 MCP: "Permission denied"
1. Verificar que el service account tiene acceso de Viewer en GA4
2. Verificar que la Google Analytics Data API esta habilitada
3. Ver guia completa: [GA4_MCP_SETUP.md](./GA4_MCP_SETUP.md)

---
**Mantenedor**: Gabriel Pantoja
