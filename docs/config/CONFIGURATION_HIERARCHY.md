# 🔧 Jerarquía de Configuración de Luanti - Vegan Wetlands

## 📋 Resumen Ejecutivo

El servidor Vegan Wetlands utiliza una **jerarquía de configuración en cascada** donde diferentes archivos tienen distintos niveles de autoridad. Entender esta jerarquía es **crítico** para administrar correctamente el servidor.

## 🏗️ Jerarquía de Autoridad (Mayor a Menor)

### 1. **`luanti.conf`** - **AUTORIDAD MÁXIMA** 🎯
**Ubicación**: `/home/gabriel/Vegan-Wetlands/server/config/luanti.conf`
**Docker**: `/config/.minetest/minetest.conf`

**Características**:
- ✅ **Configuración del servidor** - Controla comportamiento global
- ✅ **Sobrescribe todas las demás configuraciones**
- ✅ **Se aplica a todos los mundos**
- ✅ **Configuración de red, privilegios por defecto, modo de juego**

### 2. **`world.mt`** - **Configuración de Mundo** 🌍
**Ubicación**: `/home/gabriel/Vegan-Wetlands/server/worlds/world/world.mt`
**Docker**: `/config/.minetest/worlds/world/world.mt`

**Características**:
- ⚠️ **Configuración específica del mundo**
- ⚠️ **Sobrescrita por luanti.conf en configuraciones conflictivas**
- ✅ **Controla qué mods cargar**
- ✅ **Configuración de backend de datos**

### 3. **Variables de entorno Docker** - **Configuración de Contenedor** 🐳
**Ubicación**: `docker-compose.yml`

**Características**:
- ⚠️ **Solo algunas configuraciones específicas**
- ⚠️ **Puede ser sobrescrita por archivos de configuración**
- ✅ **Configuración de puertos y volúmenes**

## 📊 Matriz de Configuraciones Críticas

| Configuración | luanti.conf | world.mt | Docker | **Resultado Final** |
|---------------|-------------|----------|--------|-------------------|
| `creative_mode` | `true` ✅ | `false` | - | **CREATIVE** ✅ |
| `enable_damage` | `false` ✅ | `true` | - | **NO DAMAGE** ✅ |
| `gameid` | - | `mineclone2` ✅ | - | **VoxeLibre** ✅ |
| `default_privs` | `interact,shout,creative,give,fly` ✅ | - | - | **Creative Privs** ✅ |
| Puerto servidor | - | - | `30000:30000` ✅ | **Puerto 30000** ✅ |

## 🎯 Casos de Uso Prácticos

### Caso 1: Cambiar Modo de Juego
**Objetivo**: Cambiar de creativo a supervivencia

**❌ INCORRECTO**:
```bash
# Editar solo world.mt
echo "creative_mode = false" >> server/worlds/world/world.mt
```

**✅ CORRECTO**:
```bash
# Editar luanti.conf (autoridad final)
sed -i 's/creative_mode = true/creative_mode = false/' server/config/luanti.conf
sed -i 's/enable_damage = false/enable_damage = true/' server/config/luanti.conf
# Actualizar privilegios por defecto
sed -i 's/default_privs = interact,shout,creative,give,fly,fast,noclip,home/default_privs = interact,shout,home/' server/config/luanti.conf
```

### Caso 2: Habilitar Nuevo Mod
**Objetivo**: Activar mod `new_animals`

**✅ PASO 1** - Configurar carga del mod:
```bash
# En world.mt (configuración de mundo)
echo "load_mod_new_animals = true" >> server/worlds/world/world.mt
```

**✅ PASO 2** - Verificar dependencias en luanti.conf:
```bash
# Si el mod requiere privilegios especiales
echo "# Privilegios para new_animals mod" >> server/config/luanti.conf
```

### Caso 3: Debugging de Configuración Conflictiva
**Problema**: El servidor no está en modo creativo a pesar de configurar `world.mt`

**🔍 DIAGNÓSTICO**:
```bash
# Paso 1: Ver configuración del mundo
cat server/worlds/world/world.mt | grep creative
# Output: creative_mode = true

# Paso 2: Ver configuración del servidor (AUTORIDAD FINAL)
cat server/config/luanti.conf | grep creative
# Output: creative_mode = false  <-- ¡AQUÍ ESTÁ EL CONFLICTO!

# Paso 3: Ver resultado en el servidor
ssh gabriel@167.172.251.27 "cd /home/gabriel/Vegan-Wetlands && docker-compose logs luanti-server | grep creative"
```

**✅ SOLUCIÓN**:
```bash
# Cambiar la autoridad final (luanti.conf)
sed -i 's/creative_mode = false/creative_mode = true/' server/config/luanti.conf
docker-compose restart luanti-server
```

### Caso 4: Configuración de Seguridad
**Objetivo**: Deshabilitar TNT y explosiones

**✅ CONFIGURACIÓN CORRECTA**:
```bash
# En luanti.conf (autoridad final)
echo "enable_tnt = false" >> server/config/luanti.conf
echo "enable_fire = false" >> server/config/luanti.conf

# Para VoxeLibre específicamente
echo "mcl_enable_creative_mode = true" >> server/config/luanti.conf
echo "mcl_creative_is_survival_like = false" >> server/config/luanti.conf
```

## 🚨 Problemas Comunes y Soluciones

### Problema 1: "Configuré algo pero no funciona"
**Causa**: Editaste un archivo de menor autoridad
**Solución**: Siempre edita `luanti.conf` primero

### Problema 2: "Los jugadores no tienen privilegios creativos"
**Causa**: `default_privs` en `luanti.conf` no incluye `creative`
**Solución**:
```bash
# Verificar privilegios actuales
grep default_privs server/config/luanti.conf
# Agregar creative si falta
sed -i 's/default_privs = interact,shout/default_privs = interact,shout,creative,give/' server/config/luanti.conf
```

### Problema 3: "Los mods no cargan"
**Causa**: No están declarados en `world.mt`
**Solución**:
```bash
# Agregar mod a world.mt
echo "load_mod_nombre_del_mod = true" >> server/worlds/world/world.mt
```

## 📝 Comandos de Verificación

### Verificar Estado Actual del Servidor
```bash
# Conectar al VPS y ver configuración activa
ssh gabriel@167.172.251.27 "cd /home/gabriel/Vegan-Wetlands && cat server/config/luanti.conf | grep -E '(creative|damage|default_privs)'"

# Ver qué mods están cargados
ssh gabriel@167.172.251.27 "cd /home/gabriel/Vegan-Wetlands && cat server/worlds/world/world.mt | grep load_mod"

# Ver logs del servidor para errores de configuración
ssh gabriel@167.172.251.27 "cd /home/gabriel/Vegan-Wetlands && docker-compose logs --tail=50 luanti-server | grep -i error"
```

### Aplicar Cambios de Configuración
```bash
# Después de editar luanti.conf
docker-compose restart luanti-server

# Después de editar world.mt (requiere reinicio completo)
docker-compose down
docker-compose up -d
```

## 🎯 Mejores Prácticas

### ✅ DO (Hacer)
1. **Siempre edita `luanti.conf` para configuraciones de servidor**
2. **Usa `world.mt` solo para configuración de mods**
3. **Haz backup antes de cambios de configuración**
4. **Testa cambios localmente antes de aplicar en producción**
5. **Documenta cambios en este archivo**

### ❌ DON'T (No Hacer)
1. **No edites configuraciones directamente en el VPS**
2. **No asumas que `world.mt` tiene autoridad final**
3. **No olvides reiniciar el servidor después de cambios**
4. **No mezcles configuraciones de desarrollo y producción**

## 🔄 Flujo de Trabajo Recomendado

### Para Cambios de Configuración:
1. **Desarrollo Local** - Edita archivos de configuración
2. **Test Local** - `./scripts/start.sh`
3. **Commit & Push** - Control de versiones
4. **Deploy** - CI/CD automático al VPS
5. **Verificación** - Comprobar que funciona en producción

### Para Debugging:
1. **Identifica el problema** - ¿Qué no funciona como esperabas?
2. **Revisa jerarquía** - ¿Qué archivo tiene autoridad?
3. **Compara configuraciones** - Local vs Producción
4. **Aplica fix** - En el archivo correcto
5. **Valida solución** - Reinicia y testa

---

**Última actualización**: Septiembre 25, 2025
**Estado del servidor**: Producción estable en modo creativo
**Configuración crítica**: ✅ creative_mode=true, enable_damage=false