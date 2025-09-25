# 🛡️ Registro de Incidentes de Seguridad - Vegan Wetlands

## 📋 Índice de Incidentes

| Fecha | Tipo | Severidad | Estado | Documento |
|-------|------|-----------|--------|-----------|
| 2025-09-20 | Desconexión Masiva Automática | ALTA | ✅ RESUELTO | [Incidente HAKER](2025-09-20_INCIDENTE_HAKER_DESCONEXION_MASIVA.md) |

## 📊 Estadísticas de Seguridad

### **Incidentes por Tipo**
- **Desconexiones Automáticas**: 1
- **Actividad Maliciosa**: 0
- **Corrupciones de Datos**: 0
- **Crashes del Servidor**: 0

### **Tiempo de Resolución**
- **Promedio**: 10 minutos
- **Más Rápido**: 10 minutos
- **Más Lento**: 10 minutos

### **Eficacia de Protecciones**
- **Prevención de Corrupción**: 100%
- **Preservación de Datos**: 100%
- **Tiempo de Actividad**: 99.99%

## 🎯 Lecciones Aprendidas

### **Principales Hallazgos**
1. **Los sistemas automáticos de Luanti son muy efectivos** para proteger la integridad de datos
2. **La investigación técnica profunda es esencial** antes de asumir actividad maliciosa
3. **Las configuraciones por defecto pueden ser restrictivas** para servidores con mods complejos
4. **Los logs automáticos son la mejor fuente de verdad** para diagnósticos

### **Mejores Prácticas Desarrolladas**
- Siempre verificar logs técnicos antes de asumir malicia
- Mantener configuraciones apropiadas para el set de mods utilizado
- Implementar monitoreo proactivo de métricas críticas
- Documentar completamente todos los incidentes para aprendizaje

## 🔄 Procedimiento Estándar de Respuesta a Incidentes

### **Fase 1: Detección y Evaluación Inicial** (0-5 minutos)
1. **Detectar anomalía** (desconexiones, errores, comportamiento extraño)
2. **Verificar estado del servidor** (`docker-compose ps`)
3. **Revisar logs inmediatos** (`docker-compose logs --tail=50 luanti-server`)
4. **Evaluar alcance** (¿cuántos jugadores afectados?)

### **Fase 2: Análisis Técnico** (5-15 minutos)
1. **Buscar errores específicos** en logs:
   ```bash
   # Buscar errores críticos
   docker-compose logs luanti-server | grep -i -E "(error|crash|objects detected|segfault)"

   # Verificar límites excedidos
   docker-compose logs luanti-server | grep -i "suspiciously large"

   # Revisar conexiones sospechosas
   docker-compose logs luanti-server | grep -i -E "(connect|disconnect|kick|ban)"
   ```

2. **Identificar coordenadas** si hay errores de objetos:
   - Multiplicar coordenadas del mapblock × 16 para obtener posición del mundo
   - Teleportarse al área para inspección visual

3. **Verificar configuraciones críticas**:
   ```conf
   max_objects_per_block = ?
   active_block_range = ?
   secure.enable_security = ?
   ```

### **Fase 3: Respuesta Proporcional** (15-30 minutos)
1. **Si es protección automática**: Ajustar configuración y reiniciar
2. **Si es actividad sospechosa**: Implementar bloqueos específicos
3. **Si es corrupción**: Restaurar desde backup
4. **Si es sobrecarga**: Optimizar configuraciones de rendimiento

### **Fase 4: Documentación y Aprendizaje** (30-60 minutos)
1. **Crear documento de incidente** con análisis completo
2. **Identificar mejoras** en configuración o procedimientos
3. **Actualizar medidas preventivas**
4. **Comunicar hallazgos** al equipo administrativo

## ⚡ Contactos de Emergencia

### **Administradores**
- **Gabriel (gabo)**: Administrador principal con todos los privilegios
- **Claude Code**: Análisis técnico y diagnósticos automatizados

### **Herramientas de Diagnóstico**
```bash
# Estado general del servidor
docker-compose ps && docker-compose logs --tail=20 luanti-server

# Verificar conectividad
ss -tulpn | grep :30000

# Monitoreo en tiempo real
docker-compose logs -f luanti-server

# Análisis de objetos por bloque
# (requiere acceso directo al contenedor para diagnóstico avanzado)
```

## 📈 Métricas de Monitoreo Continuo

### **Indicadores Clave de Salud**
- **Tiempo de Actividad**: Objetivo 99.9%
- **Tiempo de Respuesta**: <100ms promedio
- **Errores por Hora**: <1 error/hora
- **Jugadores Conectados**: Máximo 20

### **Alertas Automáticas Recomendadas**
- Error crítico en logs (ERROR, CRASH, SEGFAULT)
- Límite de objetos por bloque excedido
- Tiempo de inactividad >2 minutos
- Conexiones desde IPs previamente bloqueadas

---

**Documento mantenido por**: Gabriel (Admin) + Claude Code
**Última actualización**: 25 de septiembre de 2025
**Versión**: 1.0