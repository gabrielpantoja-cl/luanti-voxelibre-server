# Guía de Deployment de Mods - Vegan Wetlands

## 📋 Flujo de Trabajo Correcto

### 🚀 Proceso Recomendado (Git-First)
```
1. Desarrollo Local → 2. Commit/Push → 3. Pull VPS → 4. Habilitar Mod → 5. Restart
```

**✅ Ventajas del flujo Git-First:**
- Control de versiones completo
- Posibilidad de rollback
- Sincronización garantizada entre desarrollo y producción
- Colaboración segura
- Historial de cambios documentado

### ❌ Flujo No Recomendado (Rsync Directo)
```
1. Desarrollo Local → 2. Rsync VPS → 3. ¿Commit después?
```
**Problemas:**
- Desincronización entre repo y producción
- Sin historial de cambios
- Riesgo de pérdida de código
- Conflictos al hacer pull posteriormente

## 🛠️ Pasos Detallados

### 1️⃣ Desarrollo Local
```bash
# Crear o modificar mod en carpeta local
cd /home/gabriel/Documentos/Vegan-Wetlands/server/mods/
# Editar archivos del mod
# Probar sintaxis localmente si es posible
```

### 2️⃣ Commit y Push
```bash
# Agregar archivos al staging
git add server/mods/nombre_mod/

# Crear commit descriptivo
git commit -m "✨ Implementar mod nombre_mod v1.0 - Descripción de funcionalidades

🎯 Características:
• Funcionalidad 1
• Funcionalidad 2

🛡️ Seguridad:
• Compatible con VoxeLibre
• Sin modificaciones a archivos del core

🤖 Generated with [Claude Code](https://claude.ai/code)

Co-Authored-By: Claude <noreply@anthropic.com>"

# Push al repositorio remoto
git push origin main
```

### 3️⃣ Pull desde VPS
```bash
# Conectar al VPS
ssh gabriel@<VPS_IP>

# Navegar al directorio del proyecto
cd /home/gabriel/Vegan-Wetlands

# Pull oficial desde GitHub
git pull origin main

# Si hay conflictos locales, usar reset (con precaución)
# git reset --hard origin/main
```

### 4️⃣ Habilitar Mod en world.mt
```bash
# Agregar línea de habilitación
docker-compose exec -T luanti-server sh -c 'echo "load_mod_NOMBRE_MOD = true" >> /config/.minetest/worlds/world/world.mt'

# Verificar que se agregó correctamente
docker-compose exec -T luanti-server cat /config/.minetest/worlds/world/world.mt
```

### 5️⃣ Reiniciar Servidor
```bash
# Reiniciar contenedor para cargar mod
docker-compose restart luanti-server

# Verificar que inició correctamente
sleep 15
docker-compose logs --tail=20 luanti-server

# Verificar estado del servicio
docker-compose ps
```

## 🗂️ Estructura de Archivos

### 📁 Ubicaciones Importantes
```
Vegan-Wetlands/
├── server/mods/                    # Mods del repositorio
│   ├── server_rules/
│   ├── back_to_spawn/
│   └── otros_mods/
├── server/config/
│   ├── world.mt                    # ✨ NUEVO: Backup de configuración
│   └── luanti.conf
└── docs/mods/                      # Documentación de mods
    ├── SERVER_RULES_MOD_V2.md
    └── MOD_DEPLOYMENT_GUIDE.md     # Este archivo
```

### 🐳 Mapeo Docker
```
Host                        →  Container
./server/mods/             →  /config/.minetest/mods/
./server/config/           →  /config/.minetest/
./server/worlds/           →  /config/.minetest/worlds/
```

## 📋 Archivo world.mt

### 🎯 Propósito
El archivo `world.mt` controla qué mods están activos en el mundo específico. Sin entrada en este archivo, el mod **NO se carga**.

### 📍 Ubicación
- **En contenedor**: `/config/.minetest/worlds/world/world.mt`
- **En host**: `server/worlds/world/world.mt` (no sincronizado con repo)
- **Backup repo**: `server/config/world.mt` (nueva ubicación para respaldo)

### 📄 Formato
```ini
# Configuración del mundo
enable_damage = true
creative_mode = false
mod_storage_backend = sqlite3
auth_backend = sqlite3
player_backend = sqlite3
backend = sqlite3
gameid = mineclone2
world_name = world

# Mods habilitados
load_mod_mcl_back_to_spawn = true
load_mod_server_rules = true
# Agregar nuevos mods aquí:
# load_mod_nuevo_mod = true
```

### 🔄 Sincronización Manual
Como `world.mt` se modifica en el VPS y no se sincroniza automáticamente, mantener backup:

```bash
# Hacer backup desde VPS al repo local
ssh gabriel@<VPS_IP> "cd /home/gabriel/Vegan-Wetlands && docker-compose exec -T luanti-server cat /config/.minetest/worlds/world/world.mt" > server/config/world.mt

# Commitear backup
git add server/config/world.mt
git commit -m "📦 Backup world.mt configuration"
git push origin main
```

## 🔍 Troubleshooting

### ❌ Mod no aparece después del deployment

**Diagnóstico:**
```bash
# 1. Verificar que el mod esté en el contenedor
docker-compose exec -T luanti-server ls -la /config/.minetest/mods/nombre_mod/

# 2. Verificar que esté habilitado en world.mt
docker-compose exec -T luanti-server cat /config/.minetest/worlds/world/world.mt | grep nombre_mod

# 3. Revisar logs de errores
docker-compose logs luanti-server | grep -i error
```

**Soluciones comunes:**
1. **Mod no habilitado**: Agregar `load_mod_nombre_mod = true` a world.mt
2. **Error de sintaxis**: Revisar archivos .lua del mod
3. **Dependencias faltantes**: Verificar mod.conf y dependencias

### ❌ Conflictos durante git pull

**Error típico:**
```
error: Your local changes to the following files would be overwritten by merge:
    server/mods/nombre_mod/init.lua
Please commit your changes or stash them before you merge.
```

**Solución:**
```bash
# Opción 1: Reset fuerte (si cambios locales no son importantes)
git reset --hard origin/main

# Opción 2: Stash temporal (si quieres revisar diferencias)
git stash
git pull origin main
git stash pop
```

## 📊 Mods Funcionando Actualmente

### ✅ Mods Exitosos
| Mod | Estado | Comandos | Descripción |
|-----|--------|----------|-------------|
| `mcl_back_to_spawn` | ✅ Funcionando | `/back_to_spawn` | Teleportación a spawn personal |
| `server_rules` v2.0 | ✅ Funcionando | `/reglas`, `/filosofia`, `/santuario`, `/r` | Sistema completo de reglas |

### 🔧 Configuración world.mt Actual
```ini
load_mod_mcl_back_to_spawn = true
load_mod_server_rules = true
```

## 🎯 Mejores Prácticas

### ✅ DO (Recomendado)
- **Siempre commit primero**, luego deploy
- **Usar mensajes de commit descriptivos** con emojis
- **Hacer backup de world.mt** después de cambios
- **Probar en local** cuando sea posible
- **Documentar cada mod** en `docs/mods/`
- **Seguir patrón de mods exitosos** (como back_to_spawn)

### ❌ DON'T (Evitar)
- **No usar rsync directo** a producción sin commit
- **No modificar archivos de VoxeLibre** directamente
- **No olvidar habilitar mods** en world.mt
- **No hacer múltiples cambios** sin testing
- **No usar dependencias complejas** (preferir optional_depends)

## 🔮 Automatización Futura

### 💡 Posibles Mejoras
1. **Script de deployment** automatizado
2. **Validación de sintaxis** pre-commit
3. **Backup automático** de world.mt
4. **Testing automatizado** de mods
5. **CI/CD pipeline** con GitHub Actions

### 📋 Template de Deployment Script
```bash
#!/bin/bash
# deploy-mod.sh - Script automatizado de deployment

MOD_NAME=$1
if [ -z "$MOD_NAME" ]; then
    echo "Uso: $0 nombre_mod"
    exit 1
fi

echo "🚀 Deploying mod: $MOD_NAME"

# 1. Commit y push
git add server/mods/$MOD_NAME/
git commit -m "🛠️ Deploy mod $MOD_NAME"
git push origin main

# 2. Deploy en VPS
ssh gabriel@<VPS_IP> "cd /home/gabriel/Vegan-Wetlands && git pull origin main"

# 3. Habilitar mod
ssh gabriel@<VPS_IP> "cd /home/gabriel/Vegan-Wetlands && docker-compose exec -T luanti-server sh -c 'echo \"load_mod_$MOD_NAME = true\" >> /config/.minetest/worlds/world/world.mt'"

# 4. Reiniciar servidor
ssh gabriel@<VPS_IP> "cd /home/gabriel/Vegan-Wetlands && docker-compose restart luanti-server"

echo "✅ Deployment completed for $MOD_NAME"
```

---

**Documentado**: Septiembre 25, 2025
**Última actualización**: Deployment server_rules v2.0
**Próxima revisión**: Al agregar nuevos mods