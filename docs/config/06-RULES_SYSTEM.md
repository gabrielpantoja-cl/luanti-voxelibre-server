# Sistema de Reglas del Servidor Wetlands

## 📋 Resumen

Este documento describe el sistema completo de reglas implementado en el servidor **Wetlands**, incluyendo las reglas básicas, comandos disponibles, sistema de moderación y consecuencias por incumplimiento.

## 🌱 Reglas Básicas del Servidor

### **5 Reglas Fundamentales:**

1. **🚫 NO MOLESTAR A OTROS JUGADORES**
   - No destruir construcciones ajenas
   - No seguir o acosar a otros jugadores
   - Respetar el espacio personal de cada uno

2. **👤 USAR UN NOMBRE APROPIADO**
   - Evitar nombres random como "player123" o "guest456"
   - Elegir un nombre que represente al jugador
   - Sin palabras ofensivas o inapropiadas

3. **🤝 NO ECHAR A OTROS JUGADORES SIN RAZÓN**
   - Este es un espacio para todos
   - Reportar problemas a los moderadores
   - Ser amable y tolerante

4. **💬 CHAT RESPETUOSO**
   - Usar lenguaje apropiado (audiencia: niños 7+)
   - No spam ni mensajes repetitivos
   - Ayudar a crear un ambiente positivo

5. **🌱 ESPÍRITU COMPASIVO**
   - Cuidar a los animales del servidor
   - Compartir y ayudar a otros jugadores
   - Disfrutar construyendo juntos

## ⚖️ Sistema de Consecuencias

### **Escalado de Sanciones:**

| Incidencia | Consecuencia | Duración | Acción |
|------------|--------------|----------|---------|
| **1ra vez** | Advertencia | Permanente | Recordatorio de reglas |
| **2da vez** | Silencio temporal (mute) | 30-60 minutos | Sin chat |
| **3ra vez** | Expulsión temporal (kick) | 24 horas | Desconexión forzada |
| **4ta vez** | Baneo permanente | Indefinido | Acceso bloqueado |

### **Infracciones Graves (Baneo Inmediato):**
- Lenguaje extremadamente ofensivo
- Acoso persistente
- Griefing masivo
- Uso de nombres altamente inapropiados

## 🎮 Comandos del Sistema de Reglas

### **Para Jugadores:**

| Comando | Descripción | Ejemplo |
|---------|-------------|---------|
| `/reglas` | Muestra todas las reglas completas | `/reglas` |
| `/r` | Reglas rápidas resumidas | `/r` |
| `/filosofia` | Misión y filosofía del servidor | `/filosofia` |
| `/santuario` | Información sobre cuidado animal | `/santuario` |

### **Para Moderadores/Admins:**

| Comando | Descripción | Sintaxis |
|---------|-------------|----------|
| `/mute <jugador> <tiempo>` | Silenciar jugador | `/mute player123 60` |
| `/unmute <jugador>` | Quitar silencio | `/unmute player123` |
| `/kick <jugador> <razón>` | Expulsar jugador | `/kick player123 spam` |
| `/ban <jugador> <razón>` | Banear jugador | `/ban player123 griefing` |
| `/unban <jugador>` | Quitar baneo | `/unban player123` |
| `/privs <jugador>` | Ver privilegios | `/privs player123` |

## 🤖 Funciones Automáticas

### **Mensajes Automáticos:**

1. **Al Conectarse**: Mensaje de bienvenida con reglas básicas
2. **Nuevos Jugadores**:
   - Bienvenida personalizada (3 segundos después de conectar)
   - Explicación de comandos útiles
   - Guía de filosofía del servidor
3. **Recordatorios Periódicos**: Cada 15 minutos, recordatorio amigable de reglas

### **Detección Automática:**
- **Spam**: Más de 5 mensajes idénticos en 60 segundos
- **Nombres inapropiados**: Filtros automáticos para nombres ofensivos
- **Comportamiento sospechoso**: Monitoreo de acciones destructivas

## 📁 Implementación Técnica

### **Archivos del Sistema:**

```
server/
├── config/
│   └── luanti-original.conf              # Configuración principal con reglas en MOTD
├── mods/
│   └── server_rules/            # Mod de reglas
│       ├── mod.conf             # Metadatos del mod
│       └── init.lua             # Lógica de comandos y mensajes
└── reglas_servidor.txt          # Archivo de texto con reglas completas
```

### **Configuración del Mod:**

```lua
-- Activación en luanti-original.conf
load_mod_server_rules = true

-- MOTD con reglas básicas
motd = ¡Bienvenid@ a Wetlands! 🌱\nREGLAS: 1)No molestar 2)Nombre apropiado 3)Respeto 4)Ser compasivo\nComandos útiles: /reglas /filosofia /santuario
```

## 📞 Procedimiento de Reportes

### **Para Jugadores:**

1. **Reporte en Chat**: Mencionar `@admin` o `@moderador`
2. **Comando Directo**: `/msg admin [descripción del problema]`
3. **Información Requerida**:
   - Nombre del jugador problemático
   - Descripción de la infracción
   - Hora aproximada del incidente

### **Para Moderadores:**

1. **Investigación**: Revisar logs del chat y acciones del jugador
2. **Aplicación de Sanción**: Según escalado de consecuencias
3. **Documentación**: Registrar incidente y acción tomada
4. **Seguimiento**: Monitorear comportamiento post-sanción

## 🛡️ Moderación y Administración

### **Privilegios de Moderación:**

```bash
# Privilegios completos para administradores
admin_privs = server,privs,ban,kick,teleport,give,settime,worldedit,fly,fast,noclip,debug,password,rollback_check

# Privilegios básicos para jugadores
default_privs = interact,shout,creative,give,fly,fast,noclip,home
```

### **Herramientas de Moderación:**

- **Rollback**: `enable_rollback_recording = true` para revertir griefing
- **Protección**: Sistema de áreas protegidas con mod `protector`
- **Logs**: Registro completo de chat y acciones de jugadores
- **Backups**: Respaldos automáticos cada 6 horas para recuperación

## 🔄 Mantenimiento del Sistema

### **Revisión Periódica:**
- **Semanal**: Revisar logs de incidentes y efectividad de reglas
- **Mensual**: Actualizar reglas según feedback de la comunidad
- **Según necesidad**: Ajustar filtros automáticos y consecuencias

### **Actualización de Reglas:**

1. **Modificar**: `server/mods/server_rules/init.lua`
2. **Actualizar**: `server/reglas_servidor.txt`
3. **Configurar**: `server/config/luanti-original.conf` si es necesario
4. **Reiniciar**: Servidor para aplicar cambios
5. **Comunicar**: Cambios a la comunidad

## 📊 Métricas y Seguimiento

### **Indicadores de Éxito:**
- Reducción en reportes de problemas
- Aumento en tiempo de permanencia de jugadores
- Feedback positivo de la comunidad
- Disminución en sanciones repetidas

### **Datos a Monitorear:**
- Número de infracciones por tipo
- Efectividad de advertencias vs. sanciones
- Tiempo promedio antes de reincidencia
- Satisfacción general de los jugadores

---

## 🌱 Filosofía del Sistema

El sistema de reglas de **Wetlands** está diseñado para:

- **Educar antes que castigar**: Priorizar la educación y el diálogo
- **Crear un ambiente seguro**: Especialmente para niños de 7+ años
- **Fomentar la compasión**: Alineado con la filosofía del servidor
- **Ser claro y justo**: Reglas comprensibles y consecuencias proporcionales
- **Evolucionar**: Adaptarse según las necesidades de la comunidad

> "En Wetlands, creamos un espacio donde la diversión, el respeto y la compasión van de la mano" 🎮💚