# Mod server_rules v2.0 - Sistema Completo de Reglas

## 📋 Descripción

El mod `server_rules` v2.0 es un sistema integral de bienvenida, reglas y filosofía educativa para el servidor Wetlands. Diseñado específicamente para niños 7+ años con enfoque en compasión animal y educación consciente.

## ✨ Características Principales

### 🎯 Sistema de Bienvenida Automática
- **Bienvenida personalizada** para todos los jugadores al conectarse (3 segundos)
- **Mensaje especial** para jugadores nuevos (8 segundos adicionales)
- **Información educativa** sobre servidor compasivo y modo pacífico

### 🤖 Comandos Implementados
- `/reglas` - Reglas completas del servidor con consecuencias claras
- `/r` - Versión rápida de reglas esenciales
- `/filosofia` - Misión y valores del servidor
- `/santuario` - Educación sobre cuidado animal compasivo

### 📢 Sistema de Recordatorios
- **Mensajes periódicos** cada 20 minutos (anteriormente 15 minutos)
- **5 mensajes rotativos** educativos sobre comandos y filosofía
- **Enfoque positivo** en construcción y compasión

## 🎨 Diseño Educativo

### 👶 Lenguaje Apropiado para Niños
- **Términos neutrales**: "alimentos a base de plantas" (evita "vegano/vegana")
- **Emojis educativos** para hacer más atractivos los mensajes
- **Tono positivo** sin ser predicativo
- **Mensajes claros** sobre consecuencias y moderación

### 🌱 Filosofía Compasiva
- **Respeto hacia animales** como compañeros de aventuras
- **Educación a través del juego** como método principal
- **Construcción de comunidad** familiar y segura
- **Creatividad sin límites** en ambiente pacífico

## 🛠️ Implementación Técnica

### 📁 Estructura del Mod
```
server/mods/server_rules/
├── mod.conf          # Configuración del mod
└── init.lua          # Lógica principal
```

### ⚙️ Configuración (mod.conf)
```ini
name = server_rules
title = Reglas Vegan Wetlands
description = Sistema completo de reglas y bienvenida para servidor compasivo
author = gabo
version = 2.0
depends =
optional_depends = mcl_core
supported_games = mineclone2
```

### 🧩 Compatibilidad VoxeLibre
- **Patrón exitoso**: Basado en `back_to_spawn` mod que funciona correctamente
- **Sin dependencias críticas**: Solo `mcl_core` como opcional
- **Supported games**: Específicamente para `mineclone2` (VoxeLibre)

## 🚀 Proceso de Deployment

### 📋 Checklist de Deployment
1. ✅ **Desarrollo local** con testing
2. ✅ **Commit y push** al repositorio GitHub
3. ✅ **Pull desde VPS** para deployment oficial
4. ✅ **Habilitar en world.mt** (`load_mod_server_rules = true`)
5. ✅ **Reiniciar servidor** para cargar el mod
6. ✅ **Verificar funcionamiento** con conexión real

### ⚠️ Problema Crítico Resuelto
**Síntoma**: Mod no se cargaba a pesar de estar en la ubicación correcta
**Causa**: Falta de habilitación en `/config/.minetest/worlds/world/world.mt`
**Solución**: Agregar `load_mod_server_rules = true` al archivo de configuración del mundo

## 🎯 Comandos Detallados

### `/reglas` - Reglas Completas
Muestra sistema completo de reglas con:
- **5 reglas básicas** obligatorias
- **Sistema de consecuencias** escalado (advertencia → mute → kick → ban)
- **Información de contacto** para reportar problemas
- **Descripción del servidor** educativo y compasivo

### `/filosofia` - Filosofía del Servidor
Presenta la misión y valores:
- **Objetivo educativo** sobre compasión animal
- **Valores fundamentales** de respeto y creatividad
- **Concepto de santuarios** virtuales
- **Alimentación consciente** con plantas
- **Comunidad familiar** segura

### `/santuario` - Educación Animal
Información específica sobre:
- **Definición de santuarios** como espacios libres
- **Animales del mundo** (vacas, cerdos, gallinas, cabras)
- **Cuidado compasivo** práctico
- **Alimentación a base de plantas** (tofu, seitan, leche de avena)

### `/r` - Reglas Rápidas
Versión condensada para referencia rápida

## 📊 Mensajes de Bienvenida

### 🌟 Bienvenida General (3 segundos)
```
🌈 ════════════════════════════════════ 🌈
🌱 ¡Bienvenid@ a Wetlands, [NOMBRE]! 🌱
🏠 Servidor Educativo y Compasivo (7+ años)
🕊️ Modo Pacífico: Solo diversión, sin violencia
🌈 ════════════════════════════════════ 🌈

📋 REGLAS BÁSICAS IMPORTANTES:
1) 🚫 No molestes a otros jugadores
2) 👤 Usa un nombre apropiado y respetuoso
3) 🤝 Respeta a todos por igual
4) 💬 Chat limpio (ambiente familiar)
5) 🌱 Cuida y respeta a los animales

⚡ COMANDOS PRINCIPALES:
• /reglas - Ver reglas completas
• /filosofia - Conocer nuestra filosofía
• /santuario - Aprende sobre santuarios
• /back_to_spawn - Volver a tu spawn

🎮 ¡Construye, explora y aprende con compasión! 💚
```

### 🎆 Mensaje para Nuevos Jugadores (+8 segundos)
```
🎆 ¡Jugador Nuevo Detectado! 🎆
🌱 Bienvenido a tu primer día en Wetlands

🎯 QUÉ HACE ESPECIAL A NUESTRO SERVIDOR:
• 🕊️ Mundo pacífico: Sin monstruos ni violencia
• 🌱 Educación compasiva sobre animales
• 🌈 Comunidad amigable para familias
• 🏠 Santuarios virtuales para animales

🚀 TU AVENTURA COMIENZA:
1. 👾 Explora y observa a los animales felices
2. 🏠 Construye refugios cómodos para ellos
3. 🌾 Planta cultivos y crea jardines bonitos
4. 🥗 Prueba alimentos a base de plantas deliciosos
5. 🤝 Haz amigos y construyan proyectos juntos

💚 ¡Disfruta tu aventura compasiva!
```

## 🔄 Sistema de Recordatorios (20 minutos)
Mensajes rotativos aleatorios:
1. "🌱 Recordatorio: Usa /reglas para las reglas completas"
2. "🐾 ¿Sabías que puedes usar /santuario para aprender sobre animales?"
3. "💚 Descubre nuestra filosofía con /filosofia"
4. "🏠 Construye refugios bonitos para los animales"
5. "🌾 Prueba deliciosos alimentos a base de plantas"

## 🛡️ Seguridad y Compatibilidad

### ✅ Ventajas del Mod Personalizado vs Configuración Nuclear
- **No modifica archivos de VoxeLibre** (evita corrupción de texturas)
- **Independiente de actualizaciones** de la base del juego
- **Fácil mantenimiento** y modificaciones futuras
- **Sin riesgo de conflictos** con sistema de texturas
- **Persistente** ante reinicios y actualizaciones

### 🔧 Patrón de Implementación Exitoso
Basado en el mod `mcl_back_to_spawn` que funciona correctamente:
- Estructura de archivos estándar
- Configuración compatible con VoxeLibre
- Sistema de dependencias mínimas
- Habilitación manual en world.mt

## 📈 Métricas de Éxito

### ✅ Funcionamiento Verificado
- **Servidor**: luanti.gabrielpantoja.cl:30000
- **Estado**: ✅ FUNCIONANDO PERFECTAMENTE
- **Usuario de prueba**: pepelomo (confirmado)
- **Comandos probados**: /reglas, /filosofia, /santuario
- **Bienvenida automática**: ✅ Funcionando

### 🎯 Impacto Educativo
- **Jugadores registrados**: 5 (Gapi, gabo, gaelsin, pepelomo, veight)
- **Mensajes por conexión**: 20+ líneas educativas
- **Recordatorios por hora**: 3 mensajes educativos
- **Comandos disponibles**: 4 comandos informativos

## 🚨 Troubleshooting

### Problema: Mod no aparece
**Síntomas**: Comandos no funcionan, sin bienvenida automática
**Diagnóstico**: Verificar `world.mt`
```bash
docker-compose exec -T luanti-server cat /config/.minetest/worlds/world/world.mt | grep server_rules
```
**Solución**: Agregar `load_mod_server_rules = true` al archivo

### Problema: Mensajes no aparecen
**Causa**: Error de sintaxis en init.lua
**Diagnóstico**: Revisar logs del servidor
```bash
docker-compose logs luanti-server | grep -i error
```

### Problema: Conflicto de mods
**Síntomas**: Warnings sobre "Mod name conflict"
**Solución**: El mod de usuario tiene prioridad sobre VoxeLibre (comportamiento esperado)

## 🔄 Mantenimiento Futuro

### 📝 Modificaciones Comunes
- **Actualizar reglas**: Editar arrays de texto en init.lua
- **Cambiar tiempos**: Modificar valores en minetest.after()
- **Nuevos comandos**: Agregar minetest.register_chatcommand()
- **Traducción**: Implementar sistema S() para multiidioma

### 🎯 Mejoras Planificadas
- **Sistema de puntos** por buen comportamiento
- **Estadísticas de juego** compasivo
- **Eventos educativos** programados
- **Integración con mods** de santuarios

---

## 📚 Referencias

- **Repositorio**: https://github.com/gabrielpantoja-cl/Vegan-Wetlands
- **Documentación VoxeLibre**: Mod compatibility guide
- **Patrón de referencia**: mcl_back_to_spawn mod
- **Deployment**: Sep 25, 2025 - v2.0 exitoso