# Server Rules Mod - Documentación

## 📋 Información General

- **Nombre**: `server_rules`
- **Versión**: 1.0
- **Autor**: gabo
- **Propósito**: Sistema de reglas automático y comandos para el servidor Wetlands
- **Ubicación**: `server/mods/server_rules/`

## 🎯 Funcionalidades

### Comandos Disponibles

#### `/reglas`
- **Descripción**: Muestra las reglas completas del servidor
- **Contenido**: 5 reglas básicas obligatorias con consecuencias
- **Formato**: Mensaje estructurado con emojis
- **Uso**: Cualquier jugador puede ejecutarlo

#### `/r`
- **Descripción**: Versión rápida de las reglas
- **Contenido**: Resumen de las 5 reglas en formato compacto
- **Propósito**: Para consulta rápida
- **Formato**: Reglas condensadas en pocas líneas

#### `/santuario`
- **Descripción**: Información sobre cuidado de animales en santuarios
- **Contenido**:
  - Qué es un santuario
  - Animales en nuestro mundo
  - Cómo cuidarlos
  - Alimentación compasiva
- **Enfoque**: Educativo y compasivo

### Sistema de Reglas Automáticas

#### Para TODOS los Usuarios (joinplayer)
Al conectarse cualquier jugador recibe:
```
🌱 ¡Bienvenid@ a Wetlands, [nombre]!

📋 REGLAS BÁSICAS:
1) 🚫 No molestar a otros jugadores
2) 👤 Usa un nombre apropiado
3) 🤝 Respeta a todos
4) 💬 Chat limpio (niños 7+)
5) 🌱 Sé compasivo con los animales

⚡ COMANDOS ÚTILES:
• /reglas - Ver reglas completas
• /filosofia - Conocer nuestra misión
• /santuario - Info sobre cuidado animal

🎮 ¡Disfruta construyendo en nuestro mundo compasivo!
```

#### Para Jugadores Nuevos (newplayer)
Mensaje adicional después de 8 segundos:
```
🌟 ¡Eres nuevo en Wetlands! 🌟
Este es un servidor educativo y compasivo.
Aquí aprendemos sobre respeto hacia los animales
y disfrutamos construyendo sin violencia.

🎯 Consejos para comenzar:
• Explora y observa los animales con respeto
• Construye refugios bonitos para ellos
• Prueba alimentos veganos como tofu y seitan
• Haz amigos y construyan juntos
```

### Recordatorios Automáticos
- **Frecuencia**: Cada 15 minutos (900 segundos)
- **Mensaje**: Recordatorio sobre usar /reglas y mantener ambiente compasivo
- **Propósito**: Reforzar las reglas periódicamente

## 🛠️ Implementación Técnica

### Estructura de Archivos
```
server/mods/server_rules/
├── mod.conf    # Configuración del mod
└── init.lua    # Lógica principal
```

### mod.conf
```ini
name = server_rules
title = Reglas del Servidor
description = Muestra las reglas del servidor Vegan Wetlands
author = gabo
version = 1.0
depends =
optional_depends =
```

### APIs Utilizadas
- `minetest.register_chatcommand()` - Registro de comandos
- `minetest.register_on_joinplayer()` - Evento conexión usuarios
- `minetest.register_on_newplayer()` - Evento jugadores nuevos
- `minetest.register_globalstep()` - Timer para recordatorios
- `minetest.chat_send_player()` - Envío de mensajes
- `minetest.after()` - Retrasos en mensajes

### Compatibilidad
- ✅ **VoxeLibre**: Totalmente compatible
- ✅ **Luanti 5.13+**: Compatible
- ✅ **Sin dependencias**: No requiere otros mods

## 📝 Reglas del Servidor

### Reglas Básicas Obligatorias

1. **🚫 NO MOLESTAR A OTROS JUGADORES**
   - No destruir construcciones ajenas
   - No seguir o acosar a otros jugadores
   - Respeta el espacio personal

2. **👤 USA UN NOMBRE APROPIADO**
   - Nada de nombres random como 'player123'
   - Elige un nombre que te represente
   - Sin palabras ofensivas

3. **🤝 NO ECHAR A OTROS SIN RAZÓN**
   - Este es un espacio para todos
   - Reporta problemas a moderadores
   - Sé amable y tolerante

4. **💬 CHAT RESPETUOSO**
   - Lenguaje apropiado (niños 7+)
   - No spam ni mensajes repetitivos
   - Ayuda a crear ambiente positivo

5. **🌱 ESPÍRITU COMPASIVO**
   - Cuida a los animales del servidor
   - Comparte y ayuda a otros
   - Disfruta construyendo juntos

### Sistema de Consecuencias
1. **1ra vez**: Advertencia
2. **2da vez**: Silencio temporal
3. **3ra vez**: Expulsión temporal
4. **4ta vez**: Baneo permanente

## 🧪 Testing y Verificación

### Comandos de Prueba
```bash
# En el juego, probar cada comando:
/reglas      # Debe mostrar reglas completas
/r           # Debe mostrar reglas rápidas
/santuario   # Debe mostrar info de cuidado animal
```

### Verificar Sistema Automático
1. **Conectarse al servidor** → Debe aparecer mensaje de bienvenida con reglas
2. **Crear usuario nuevo** → Debe recibir mensaje adicional de bienvenida
3. **Esperar 15 minutos** → Debe aparecer recordatorio automático

### Logs de Verificación
```bash
# Verificar que el mod se carga sin errores
docker compose logs luanti-server | grep -i "server_rules\|error"
```

## 🔧 Mantenimiento

### Modificar Reglas
Editar el array `reglas` en `init.lua`:
```lua
local reglas = {
    "🌱 REGLAS DE WETLANDS 🌱",
    "",
    "📝 REGLAS BÁSICAS (OBLIGATORIAS):",
    -- Agregar/modificar reglas aquí
}
```

### Cambiar Frecuencia de Recordatorios
Modificar la variable `timer` en `init.lua`:
```lua
if timer >= 900 then -- 900 segundos = 15 minutos
```

### Personalizar Mensajes de Bienvenida
Editar las funciones `register_on_joinplayer` y `register_on_newplayer`

## 🚨 Troubleshooting

Ver también: [Operations/Troubleshooting](../operations/troubleshooting.md) para problemas generales del servidor.

### Problema: Comandos no funcionan
**Síntomas**: `/reglas` muestra "comando inválido"
**Solución**:
1. Verificar que el mod esté en `/config/.minetest/mods/server_rules/`
2. Verificar que no hay archivos `.disabled`
3. Reiniciar servidor

### Problema: Reglas no aparecen automáticamente
**Síntomas**: Los jugadores no reciben reglas al conectarse
**Solución**:
1. Verificar que el mod está cargándose (revisar logs)
2. Comprobar que no hay errores en `init.lua`
3. Verificar sintaxis de Lua

### Problema: Recordatorios muy frecuentes
**Síntomas**: Mensajes cada pocos minutos
**Solución**: Ajustar valor del timer en `register_globalstep`

## 📊 Estadísticas de Uso

El mod registra automáticamente:
- Jugadores que usan comandos
- Conexiones de usuarios nuevos vs. existentes
- Frecuencia de recordatorios

## 🔮 Futuras Mejoras

- [ ] Sistema de reputación por seguimiento de reglas
- [ ] Reglas personalizables por admin
- [ ] Integración con sistema de moderación
- [ ] Estadísticas de uso de comandos
- [ ] Reglas multiidioma

---
**Última actualización**: 2025-09-21
**Estado**: Funcionando correctamente
**Próxima revisión**: Al modificar reglas del servidor