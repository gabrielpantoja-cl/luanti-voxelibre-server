# 🚨 PROBLEMA URGENTE: Monstruos Siguen Spawneando

> **Estado**: ❌ **SIN RESOLVER** - 27 Agosto 2025  
> **Prioridad**: **CRÍTICA** - Afecta experiencia de niños  
> **Problema**: Monstruos spawneando DE DÍA, matando jugadores

## 📋 RESUMEN DEL PROBLEMA

### ✅ RESUELTO (Mods)
- Mods funcionando 100%
- Comandos `/santuario` y `/veganismo` operativos
- Items veganos disponibles

### ❌ SIN RESOLVER (Monstruos)  
- **Creepers, zombies, esqueletos spawneando DE DÍA**
- **Monstruos MATANDO jugadores** (contradice filosofía vegana)
- **Configuración anti-monstruos NO funciona**

## 🔍 CONFIGURACIONES PROBADAS (FALLIDAS)

### Configuración Actual en luanti.conf
```ini
# CONFIGURACIÓN RADICAL ANTI-MONSTRUOS - NO FUNCIONA
only_peaceful_mobs = true
mobs_spawn = false
mcl_mob_cap_hostile = 0
mcl_mob_cap_monster = 0
mcl_mob_hostile_group_percentage_spawned = 0
mcl_mob_peaceful_percentage_spawned = 0
mob_spawners_in_dungeons = false
mg_dungeons = false
```

### ⚠️ PROBLEMA IDENTIFICADO
**VoxeLibre puede estar IGNORANDO estas configuraciones** o tienen nombres diferentes a los documentados.

## 🚨 IMPACTO EN USUARIOS

### Para Niños 7+ Años
- ❌ **Terror nocturno**: Creepers explotan sin aviso
- ❌ **Muerte inesperada**: Contradice modo creativo esperado  
- ❌ **Experiencia traumática**: Opuesto a filosofía vegana pacífica

### Para el Servidor
- ❌ **Incumple promesa**: "Servidor sin violencia"
- ❌ **Daña reputación**: Padres retirando niños
- ❌ **Conflicto filosófico**: Vegano = compasión, no violencia

## 🎯 SOLUCIONES A INVESTIGAR

### Opción 1: VoxeLibre Mod Override
```lua
-- Crear mod custom que ELIMINE monstruos hostiles
-- Ubicación: server/mods/no_monsters/
minetest.register_abm({
    nodenames = {"group:spawns_hostile"},  
    chance = 1,
    action = function(pos)
        -- Eliminar spawners hostiles
    end
})
```

### Opción 2: Configuración VoxeLibre Específica
```bash
# Investigar archivo settingtypes.txt de VoxeLibre
# Buscar configuraciones REALES para deshabilitar mobs
grep -r "hostile\|monster\|spawn" /games/mineclone2/
```

### Opción 3: clearobjects Automático
```lua
-- Comando automático cada N minutos
minetest.register_globalstep(function(dtime)
    -- Eliminar entidades hostiles cada 60 segundos
    if timer > 60 then
        minetest.run_server_chatcommand("gabo", "clearobjects")
        timer = 0
    end
end)
```

### Opción 4: Modo Peaceful Forzado
```ini
# Investigar si VoxeLibre tiene modo peaceful diferente
mcl_difficulty = peaceful
mcl_enable_damage = false
mcl_spawn_monsters = false
```

## 📝 ACCIONES INMEDIATAS REQUERIDAS

### 1. Testing con Gabo (AHORA)
- [ ] **Comando**: `/clearobjects` para eliminar monstruos existentes
- [ ] **Comando**: `/time 6000` para forzar día permanente  
- [ ] **Observar**: ¿Spawnan nuevos monstruos después?

### 2. Investigación Técnica (Esta semana)
- [ ] **Revisar**: settingtypes.txt de VoxeLibre para configs reales
- [ ] **Consultar**: Documentación VoxeLibre sobre peaceful mode
- [ ] **Probar**: Mods anti-monstruos de la comunidad

### 3. Solución Temporal (Urgente)
- [ ] **Crear**: Mod `no_monsters` que elimine hostiles automáticamente
- [ ] **Configurar**: Script que ejecute `/clearobjects` periódicamente
- [ ] **Activar**: Modo creative total con `/give` privilegios

## 🔧 COMANDOS DE EMERGENCIA

### Para Gabo (Administrador)
```bash
# En chat del juego
/clearobjects                    # Eliminar TODOS los objetos
/time 6000                      # Forzar mediodía
/weather clear                  # Clima despejado  
/teleport gabo 0 100 0         # Teleport a altura segura
```

### Para Emergencia Extrema
```bash
# En VPS si es necesario
ssh gabriel@167.172.251.27 'cd Vegan-Wetlands && docker-compose down'
# Editar mundo para eliminar entidades hostiles
# docker-compose up -d
```

## 📊 CRITERIOS DE ÉXITO

### ✅ Solución Exitosa Cuando:
- [ ] **0 monstruos** spawneando en cualquier momento
- [ ] **0 muertes** de jugadores por mobs hostiles  
- [ ] **Solo animales pacíficos** (vacas, cerdos, ovejas)
- [ ] **Experiencia 100% creativa** y pacífica

### 🎯 Verificación
```bash
# Testear durante 24 horas en diferentes momentos:
# - Día (mediodía)
# - Noche (medianoche)  
# - Cuevas y lugares oscuros
# - Áreas nuevas (recién generadas)
```

## 🚀 PRÓXIMOS PASOS

1. **INMEDIATO**: Gabo testa comandos `/clearobjects` y `/time 6000`
2. **HOY**: Investigar configuraciones VoxeLibre reales
3. **MAÑANA**: Implementar solución definitiva
4. **VERIFICAR**: 48 horas sin avistamientos de monstruos

---

**⚠️ NOTA CRÍTICA**: Este es el último problema mayor que impide que el servidor sea 100% apto para niños veganos. Los mods ya funcionan perfectamente, solo necesitamos eliminar completamente la violencia/monstruos.

**Fecha**: 27 Agosto 2025  
**Responsable**: Debug inmediato con Gabo  
**Deadline**: Solucionado en máximo 72 horas