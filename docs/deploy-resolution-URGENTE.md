# 🚨 RESOLUCIÓN CRÍTICA DE DEPLOY - URGENTE TESTEAR 🚨

> **⚠️ ADVERTENCIA CRÍTICA**: Esta configuración fue implementada el 26/08/2025 y **REQUIERE TESTING INMEDIATO**. 
> El servidor puede estar funcionando parcialmente. **VERIFICAR ANTES DE PRODUCCIÓN**.

## 🔥 Problema Crítico Resuelto

El deployment falló debido a una **configuración incorrecta de nginx** que referenciaba un contenedor inexistente `vegan-wetlands` en el puerto 3000.

## ✅ Solución Implementada

### 1. Configuración de nginx Corregida
- **Eliminada**: Referencia a contenedor `vegan-wetlands:3000` inexistente
- **Implementado**: Servidor por defecto para acceso por IP
- **Mantenido**: Configuración específica para `luanti.gabrielpantoja.cl`

### 2. Volume Mapping Configurado
```bash
# nginx container montando landing page desde este repositorio
-v /home/gabriel/Vegan-Wetlands/server/landing-page:/var/www/luanti-landing:ro
```

### 3. Arquitectura Confirmada
- **Este repo (Vegan-Wetlands)**: Landing page development + archivos estáticos
- **VPS repo (vps-do)**: nginx configuration + serving

## 🧪 TESTS URGENTES REQUERIDOS

### Test 1: Landing Page
```bash
curl -H "Host: luanti.gabrielpantoja.cl" http://167.172.251.27/
# Debe retornar: HTML de la landing page
```

### Test 2: Acceso por IP
```bash
curl http://167.172.251.27/
# Debe retornar: "Vegan Wetlands Server - Use luanti.gabrielpantoja.cl for the landing page"
```

### Test 3: Servidor Luanti
```bash
# Conectar cliente Luanti a: luanti.gabrielpantoja.cl:30000
# Debe conectar exitosamente al servidor de juego
```

### Test 4: Verificación de Archivos
```bash
ssh gabriel@167.172.251.27 'docker exec nginx-proxy ls -la /var/www/luanti-landing/'
# Debe mostrar: index.html y carpeta assets/
```

## 🔧 Configuración Técnica Implementada

### nginx Container (Manual)
```bash
docker run -d --name nginx-proxy --restart unless-stopped \
  -p 80:80 -p 443:443 --network vps-do_vps_network \
  -v /home/gabriel/vps-do/nginx/nginx.conf:/etc/nginx/nginx.conf:ro \
  -v /home/gabriel/vps-do/nginx/conf.d:/etc/nginx/conf.d:ro \
  -v /home/gabriel/vps-do/nginx/ssl:/etc/nginx/ssl:ro \
  -v /home/gabriel/vps-do/nginx/www:/var/www/certbot:ro \
  -v /home/gabriel/Vegan-Wetlands/server/landing-page:/var/www/luanti-landing:ro \
  nginx:alpine
```

### docker-compose.yml actualizado
```yaml
# Agregado en /home/gabriel/vps-do/docker-compose.yml
volumes:
  - /home/gabriel/Vegan-Wetlands/server/landing-page:/var/www/luanti-landing:ro
```

## 🚨 PROBLEMAS POTENCIALES DETECTADOS

### 1. Docker Compose Issues
- **Error**: `'ContainerConfig' KeyError` en docker-compose
- **Workaround**: nginx ejecutándose manualmente con `docker run`
- **Acción requerida**: Investigar y arreglar docker-compose.yml

### 2. Permisos
- **Problema**: directorio `landing-page` tenía ownership root
- **Solucionado**: Recreado con permisos gabriel:gabriel
- **Vigilar**: Posibles problemas futuros de permisos

### 3. Script de Deploy
- **Estado**: `deploy-landing.sh` existe pero falla por permisos
- **Alternativa**: rsync manual implementado
- **Pendiente**: Arreglar script para deployments futuros

## 📋 Próximos Pasos Críticos

### Inmediatos (Próximas 2 horas)
1. **Ejecutar todos los tests listados arriba**
2. **Verificar conectividad desde múltiples ubicaciones**
3. **Confirmar que no hay downtime del juego**

### Corto Plazo (Esta semana)
1. **Arreglar docker-compose.yml** para evitar comandos manuales
2. **Reparar script deploy-landing.sh** para deployments automáticos
3. **Implementar monitoring** de ambos servicios

### Mediano Plazo
1. **SSL/HTTPS setup** para la landing page
2. **Backup strategy** para configuraciones de nginx
3. **Documentation update** en CLAUDE.md

## 🔄 Comandos de Rollback (En caso de fallo)

### Restaurar nginx backup
```bash
ssh gabriel@167.172.251.27 'cd /home/gabriel/vps-do && cp nginx.conf.backup nginx/nginx.conf'
ssh gabriel@167.172.251.27 'docker restart nginx-proxy'
```

### Restaurar docker-compose backup
```bash
ssh gabriel@167.172.251.27 'cd /home/gabriel/vps-do && cp docker-compose.yml.backup docker-compose.yml'
```

## 📊 Estado de Servicios (26/08/2025 - 08:25 UTC)

| Servicio | Estado | Puerto | Notas |
|----------|--------|--------|--------|
| nginx-proxy | ✅ Running | 80, 443 | Manual container |
| Landing Page | ✅ Working | HTTP | Via nginx |
| Luanti Server | ✅ Running | 30000/UDP | Independiente |
| Portainer | ❓ Issues | 9443 | ContainerConfig error |

---

**⚠️ RECORDATORIO FINAL**: Esta configuración fue implementada bajo presión para resolver un deployment fallido. 
**TESTING EXHAUSTIVO REQUERIDO** antes de considerar el deployment completo y estable.

**🔗 Referencias**:
- CLAUDE.md: Arquitectura y comandos
- scripts/deploy-landing.sh: Script de deploy (necesita reparación)
- VPS: 167.172.251.27 (usuario: gabriel)