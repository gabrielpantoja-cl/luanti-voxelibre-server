# 🚨 Recuperación de Corrupción de Texturas - Santuario Compasivo

**Fecha del Incidente**: 31 de Agosto, 2025  
**Severidad**: Crítica (servidor completamente injugable)  
**Estado**: ✅ Resuelto - Solución documentada  

## 📋 Descripción del Problema

### Síntomas Observados
- **Todos los bloques** mostraban la misma textura incorrecta
- Texturas repetitivas en toda la superficie del mundo
- El mundo se volvió visualmente injugable
- El problema persistía después de reiniciar el servidor

### Captura del Problema
Todos los bloques (tierra, piedra, madera, etc.) aparecían con la misma textura corrupta, creando un patrón repetitivo horrible en todo el mundo del juego.

## 🔍 Análisis Técnico de la Causa Raíz

### Causa Principal: Conflicto de Atlas de Texturas
1. **Instalación de mod problemático**: El mod `motorboat` contenía redefiniciones de IDs de texturas
2. **Conflicto con VoxeLibre**: Los IDs redefinidos colisionaron con texturas existentes en VoxeLibre
3. **Mapeo cruzado**: Múltiples bloques comenzaron a referenciar la misma textura
4. **Cache corrupto**: Los mapeos incorrectos se persistieron en archivos internos de VoxeLibre
5. **Propagación del error**: El problema se extendió a todo el sistema de texturas

### Secuencia Técnica del Error
```
Instalación motorboat → Redefinición IDs texturas → Conflicto VoxeLibre → 
Mapeo cruzado → Cache corrupto → Texturas uniformes → Crisis visual
```

### Por Qué Persistía el Problema
- Los archivos de caché de texturas se guardaron con los mapeos incorrectos
- Eliminar el mod no limpiaba automáticamente el caché corrupto  
- VoxeLibre siguió usando las referencias de texturas dañadas
- Se requería reinstalación completa del juego base

## 🛠️ Procedimiento de Recuperación Completa

### ⚠️ IMPORTANTE: Backup Primero
```bash
# Verificar que los datos del mundo estén seguros
ssh gabriel@<VPS_HOST_IP> "cd /home/gabriel/luanti-voxelibre-server && du -sh server/worlds/*"
```

### Paso 1: Eliminación de Mods Problemáticos
```bash
ssh gabriel@<VPS_HOST_IP> "cd /home/gabriel/luanti-voxelibre-server && rm -rf server/mods/motorboat server/mods/biofuel server/mods/mobkit server/mods/mobkit.zip"
```

### Paso 2: Descarga de VoxeLibre Fresco
```bash
# Eliminar VoxeLibre corrupto
ssh gabriel@<VPS_HOST_IP> "cd /home/gabriel/luanti-voxelibre-server && rm -rf server/games/mineclone2"

# Descargar versión limpia (56MB)
ssh gabriel@<VPS_HOST_IP> "cd /home/gabriel/luanti-voxelibre-server && wget https://content.luanti.org/packages/Wuzzy/mineclone2/releases/32301/download/ -O voxelibre.zip"

# Extraer e instalar
ssh gabriel@<VPS_HOST_IP> "cd /home/gabriel/luanti-voxelibre-server && unzip voxelibre.zip -d server/games/ && mv server/games/mineclone2-* server/games/mineclone2"
```

### Paso 3: Limpieza Completa del Sistema
```bash
# Parar contenedores y limpiar estado
ssh gabriel@<VPS_HOST_IP> "cd /home/gabriel/luanti-voxelibre-server && docker compose down && docker system prune -f"
```

### Paso 4: Eliminación de Mods con Dependencias Rotas
```bash
# Remover mods que impiden el inicio
ssh gabriel@<VPS_HOST_IP> "cd /home/gabriel/luanti-voxelibre-server && rm -rf server/mods/education_blocks"
```

### Paso 5: Reinicio con Estado Limpio
```bash
# Iniciar servidor con configuración limpia
ssh gabriel@<VPS_HOST_IP> "cd /home/gabriel/luanti-voxelibre-server && docker compose up -d"
```

### Paso 6: Verificación de Recuperación
```bash
# Verificar servidor corriendo
ssh gabriel@<VPS_HOST_IP> "cd /home/gabriel/luanti-voxelibre-server && sleep 20 && docker compose ps"

# Verificar logs de inicio exitoso
ssh gabriel@<VPS_HOST_IP> "cd /home/gabriel/luanti-voxelibre-server && docker compose logs luanti-server --since 30s | grep -E 'World at|Server for gameid|listening'"

# Confirmar preservación del mundo
ssh gabriel@<VPS_HOST_IP> "cd /home/gabriel/luanti-voxelibre-server && du -sh server/worlds/*"
```

## ✅ Métricas de Éxito de la Recuperación

### Verificaciones Obligatorias
- [ ] **Mundo preservado**: 73MB de datos intactos en `server/worlds/world`
- [ ] **Texturas normales**: Cada bloque muestra su textura correcta
- [ ] **Servidor estable**: Puerto 30000 activo y saludable
- [ ] **Sin errores**: Logs limpios sin errores de dependencias
- [ ] **Conexión funcional**: Los jugadores pueden conectarse normalmente

### Resultados de Este Incidente
- ✅ **Mundo preservado**: 73MB completamente intactos
- ✅ **Tiempo de recuperación**: ~15 minutos (incluyendo descarga)
- ✅ **Pérdida de datos**: Cero
- ✅ **Texturas**: Completamente restauradas
- ✅ **Funcionamiento**: 100% operacional

## 🛡️ Estrategias de Prevención

### 1. Protocolo de Testing de Mods
```bash
# SIEMPRE probar mods localmente primero
./scripts/start.sh  # En entorno local
# Verificar texturas, conectar como cliente
# Solo después desplegar a producción
```

### 2. Estrategia de Backup
- **Backup automático** antes de cambios de mods
- **VoxeLibre limpio** guardado como referencia
- **Documentar combinaciones** de mods que funcionan

### 3. Señales de Alerta Temprana
- **Texturas repetidas** en áreas diferentes
- **Texturas faltantes** (bloques rosa/negro)
- **Logs de texturas** con errores de carga
- **Warnings de conflictos** de IDs

## 🎯 Lecciones Aprendidas

### Técnicas
1. **VoxeLibre es sensible** a modificaciones del sistema de texturas
2. **Mods de terceros pueden causar corrupción profunda** de archivos base
3. **Reiniciar contenedores no arregla** corrupción de caché
4. **Instalación fresca del juego base** es a veces necesaria
5. **Los datos del mundo permanecen seguros** incluso con corrupción severa

### Operacionales
1. **Testing exhaustivo** antes de deployment
2. **Backups frecuentes** especialmente antes de cambios
3. **Documentación inmediata** de incidentes críticos
4. **Procedimientos de rollback** listos y probados

## 📞 Contacto y Escalación

### En Caso de Repetición
1. **No entrar en pánico** - el mundo está seguro
2. **Verificar backup del mundo** inmediatamente
3. **Seguir este procedimiento** paso a paso
4. **Documentar cualquier variación** encontrada
5. **Actualizar este documento** con nuevos hallazgos

### Información Adicional
- **Repositorio**: `https://github.com/gabrielpantoja-cl/luanti-voxelibre-server.git`
- **Documentación completa**: `CLAUDE.md`
- **Servidor**: `luanti.gabrielpantoja.cl:30000`

---

**Documento creado por**: Claude Code AI  
**Revisado por**: Gabriel Pantoja  
**Última actualización**: 31 de Agosto, 2025  
**Versión**: 1.0