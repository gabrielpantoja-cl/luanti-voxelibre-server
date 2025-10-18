# Contribuir a Wetlands - Servidor Luanti/VoxeLibre

¡Bienvenido! Wetlands es un servidor educativo y compasivo para niños 7+ años. Agradecemos contribuciones que mantengan esta filosofía.

## 🌱 Filosofía del Proyecto

Wetlands promueve:
- **Educación compasiva** sobre cuidado animal y alimentación consciente
- **Creatividad sin violencia** - modo creativo, sin PvP
- **Comunidad inclusiva** - ambiente seguro para todas las edades
- **Código abierto** - transparencia y colaboración

## 🤝 Cómo Contribuir

### 1. Reportar Bugs

Usa GitHub Issues con la plantilla:
```markdown
**Descripción del bug:**
**Pasos para reproducir:**
**Comportamiento esperado:**
**Versión de Luanti/VoxeLibre:**
**Logs relevantes:**
```

### 2. Proponer Nuevas Características

Antes de implementar:
1. Abre un Issue para discutir la idea
2. Asegúrate que se alinea con la filosofía del servidor
3. Espera aprobación del mantenedor

### 3. Desarrollar Mods

Ver `/docs/mods/MOD_DEVELOPMENT.md` para guía completa.

**Principios para mods:**
- ✅ Educativos, creativos, compasivos
- ❌ Violentos, competitivos, dañinos
- ✅ Compatible con VoxeLibre
- ✅ Código comentado en español
- ✅ Sin dependencias externas innecesarias

### 4. Mejorar Documentación

Documentación pública está en `/docs` (excluyendo archivos privados en `.gitignore`).

**Estructura:**
- `/docs/quickstart/` - Guías para jugadores
- `/docs/mods/` - Documentación de mods
- `/docs/config/` - Configuración del servidor
- `/docs/operations/` - Operaciones y mantenimiento
- `/docs/web/` - Landing page y web

## 📋 Proceso de Pull Request

1. **Fork** el repositorio
2. **Crea rama** descriptiva: `git checkout -b feature/nueva-caracteristica`
3. **Commits claros** con mensajes en español
4. **Prueba localmente** antes de enviar PR
5. **Actualiza documentación** si es necesario
6. **Abre PR** con descripción detallada

### Ejemplo de Commit

```bash
git commit -m "feat(mod): Agregar sistema de reciclaje educativo

Implementa mod que enseña sobre reciclaje y compostaje.
Compatible con VoxeLibre, texturizado y traducido al español.

Cierra #42"
```

## 🧪 Testing

Antes de enviar PR:

```bash
# Iniciar servidor local
./scripts/start.sh

# Conectar cliente Luanti a localhost:30000
# Probar funcionalidad completamente
# Verificar logs sin errores
docker-compose logs luanti-server
```

## 📝 Estilo de Código

### Lua (Mods)
```lua
-- Comentarios en español
-- Variables descriptivas en snake_case
-- Funciones documentadas

local function proteger_area(player, area_name)
    -- Validar parámetros
    if not player or not area_name then
        return false, "Parámetros inválidos"
    end

    -- Lógica clara y legible
    -- ...
end
```

### Markdown (Documentación)
- Títulos claros y jerárquicos
- Código en bloques con sintaxis highlight
- Ejemplos prácticos
- Links relativos dentro del repo

## 🔒 Seguridad

**NO incluir en PRs:**
- Datos de usuarios (nombres, IPs)
- Coordenadas exactas de construcciones
- Credenciales o tokens
- Información privada del VPS

Ver `/docs/.gitignore` para archivos excluidos.

## 🌍 Comunidad

- **Servidor:** luanti.gabrielpantoja.cl:30000
- **Issues:** GitHub Issues
- **Discusiones:** GitHub Discussions
- **Idioma principal:** Español (documentación y código)

## 📄 Licencia

Wetlands es GPL v3. Todas las contribuciones se licencian bajo los mismos términos.

Al contribuir aceptas que tu código sea:
- De código abierto
- Modificable por la comunidad
- Usado para fines educativos

## 🙏 Agradecimientos

Gracias por ayudar a crear un espacio seguro, educativo y compasivo para niños.

¡Tu contribución hace la diferencia! 🌱