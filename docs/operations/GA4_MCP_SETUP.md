# Google Analytics 4 (GA4) - MCP Server Setup

**Fecha**: 2026-02-11
**Proposito**: Monitorear analytics de la landing page `luanti.gabrielpantoja.cl` desde Claude Code

## Estado Actual

- MCP server configurado: `google-analytics` (scope local en `~/.claude.json`)
- Paquete: `mcp-server-google-analytics` (npm)
- Credenciales: **PENDIENTES** (placeholders configurados)

## Prerequisitos

Antes de que el MCP funcione, necesitas completar estos pasos manuales:

### Paso 1: Crear proyecto en Google Cloud Console

1. Ve a https://console.cloud.google.com/
2. Crea un proyecto o selecciona uno existente
3. Navega a **APIs & Services > Library**
4. Busca **"Google Analytics Data API"** y habilitala

### Paso 2: Crear Service Account

1. Ve a **IAM & Admin > Service Accounts**
2. Click **"Create Service Account"**
3. Nombre: `ga4-mcp-server` (o el que prefieras)
4. Skip role assignment, click **Done**
5. Click en la cuenta creada > **Manage Keys**
6. **Add Key > Create New Key > JSON**
7. Descarga el archivo JSON (contiene `client_email` y `private_key`)

### Paso 3: Dar acceso en Google Analytics

1. Abre Google Analytics (https://analytics.google.com/)
2. Ve a **Admin > Property Access Management**
3. Click **"+"** > Add users
4. Usa el `client_email` del JSON descargado (ej: `ga4-mcp-server@proyecto.iam.gserviceaccount.com`)
5. Asigna rol **"Viewer"** (solo lectura)

### Paso 4: Obtener GA4 Property ID

1. En Google Analytics, ve a **Admin > Property Settings**
2. Copia el **Property ID** (numero, ej: `123456789`)

### Paso 5: Actualizar credenciales en MCP

Ejecuta este comando reemplazando los valores:

```bash
claude mcp remove --scope local google-analytics

claude mcp add-json --scope local google-analytics '{
  "type": "stdio",
  "command": "cmd",
  "args": ["/c", "npx", "-y", "mcp-server-google-analytics"],
  "env": {
    "GOOGLE_CLIENT_EMAIL": "tu-service-account@proyecto.iam.gserviceaccount.com",
    "GOOGLE_PRIVATE_KEY": "-----BEGIN PRIVATE KEY-----\nTU_CLAVE_PRIVADA\n-----END PRIVATE KEY-----\n",
    "GA_PROPERTY_ID": "123456789"
  }
}'
```

**IMPORTANTE en Windows**: Si la private key tiene `\n`, reemplazalos con saltos de linea reales o usa la notacion `\\n`.

## Verificacion

```bash
# Verificar conexion
claude mcp list

# Debe mostrar:
# google-analytics: cmd /c npx -y mcp-server-google-analytics - Connected
```

## Configuracion Actual en ~/.claude.json

La configuracion queda en la seccion `projects > "C:/Users/gabri/Developer/luanti-voxelibre-server" > mcpServers`:

```json
{
  "google-analytics": {
    "type": "stdio",
    "command": "cmd",
    "args": ["/c", "npx", "-y", "mcp-server-google-analytics"],
    "env": {
      "GOOGLE_CLIENT_EMAIL": "service-account@project.iam.gserviceaccount.com",
      "GOOGLE_PRIVATE_KEY": "private-key-here",
      "GA_PROPERTY_ID": "property-id"
    }
  }
}
```

## Que puede hacer Claude Code con GA4

Una vez configurado, podras pedirle a Claude Code:

- "Cuantas visitas tuvo la landing page esta semana?"
- "Cual es la tasa de rebote de luanti.gabrielpantoja.cl?"
- "De que paises vienen los visitantes?"
- "Cuales son las paginas mas visitadas?"
- "Compara el trafico de esta semana vs la anterior"
- "Que dispositivos usan los visitantes (mobile vs desktop)?"

## Seguridad

- Las credenciales van SOLO en `~/.claude.json` (local, nunca se commitea)
- El service account tiene permisos de solo lectura (Viewer)
- NUNCA commitear el archivo JSON de credenciales al repo
- Agregar `*-credentials.json` al `.gitignore` por seguridad

## Paquete npm

- **Nombre**: `mcp-server-google-analytics`
- **npm**: https://www.npmjs.com/package/mcp-server-google-analytics
- **GitHub**: https://github.com/ruchernchong/mcp-server-google-analytics

## Alternativas

| Paquete | Tipo | Notas |
|---------|------|-------|
| `mcp-server-google-analytics` (actual) | npm/npx | Facil setup, TypeScript |
| `analytics-mcp` (oficial Google) | Python/pipx | Requiere pipx, mas completo |
| `mcp-ga4-admin` | npm | Mas enfocado en admin de propiedades |

---
**Mantenedor**: Gabriel Pantoja
**Ultima actualizacion**: 2026-02-11
