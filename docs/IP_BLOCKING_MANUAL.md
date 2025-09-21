# 🚫 MANUAL DE BLOQUEO DE IP - SERVIDOR VEGAN WETLANDS

**Fecha de creación**: 20 de Septiembre, 2025
**Última actualización**: 21 de Septiembre, 2025
**Servidor**: luanti.gabrielpantoja.cl:30000
**Versión**: 1.1

---

## 📋 RESUMEN EJECUTIVO

Este manual documenta los métodos y procedimientos para **bloquear direcciones IP** en el servidor Luanti de Vegan Wetlands. Incluye múltiples niveles de bloqueo, desde restricciones a nivel de aplicación hasta bloqueo completo del sistema.

---

## 🎯 MÉTODOS DE BLOQUEO DISPONIBLES

### 1. 🟢 **MÉTODO RECOMENDADO: Luanti ipban.txt (Nivel Aplicación)**

**Ventajas:**
- ✅ Fácil implementación
- ✅ No requiere privilegios root
- ✅ Específico para el servidor de juego
- ✅ Persiste entre reinicios del contenedor
- ✅ Inmediatamente efectivo

**Desventajas:**
- ⚠️ Solo bloquea el juego, no otros servicios
- ⚠️ Dependiente de la configuración del contenedor

#### **Procedimiento Paso a Paso:**

```bash
# PASO 1: Conectar al VPS
ssh gabriel@167.172.251.27

# PASO 2: Navegar al directorio del proyecto
cd /home/gabriel/Vegan-Wetlands

# PASO 3: Verificar estado del servidor
docker-compose ps luanti-server

# PASO 4: Añadir IP al archivo de ban (MÉTODO RECOMENDADO)
docker-compose exec -T luanti-server sh -c 'echo "IP_A_BLOQUEAR" >> /config/.minetest/worlds/world/ipban.txt'

# PASO 5: Verificar que la IP fue añadida
docker-compose exec -T luanti-server cat /config/.minetest/worlds/world/ipban.txt

# PASO 6: Reiniciar servidor para aplicar cambios (OPCIONAL)
docker-compose restart luanti-server
```

#### **Ejemplo Práctico:**
```bash
# Bloquear IP 200.83.160.80 (HAKER)
ssh gabriel@167.172.251.27 "cd /home/gabriel/Vegan-Wetlands && docker-compose exec -T luanti-server sh -c 'echo \"200.83.160.80\" >> /config/.minetest/worlds/world/ipban.txt'"

# Verificar bloqueo
ssh gabriel@167.172.251.27 "cd /home/gabriel/Vegan-Wetlands && docker-compose exec -T luanti-server cat /config/.minetest/worlds/world/ipban.txt"
```

#### **Ubicación del Archivo:**
```
Contenedor: /config/.minetest/worlds/world/ipban.txt
Host VPS: /home/gabriel/Vegan-Wetlands/server/worlds/world/ipban.txt
```

---

### 2. 🟢 **MÉTODO ALTERNATIVO: Luanti deny_access en luanti.conf (Nivel Configuración)**

**Ventajas:**
- ✅ Configuración persistente en archivo de configuración
- ✅ No requiere acceso al contenedor en tiempo de ejecución
- ✅ Permite comentarios descriptivos
- ✅ Fácil de versionar con Git
- ✅ Aplicado automáticamente al reiniciar servidor

**Desventajas:**
- ⚠️ Requiere reinicio del servidor para aplicar cambios
- ⚠️ Formato específico que debe respetarse estrictamente

#### **Procedimiento Paso a Paso:**

```bash
# PASO 1: Conectar al VPS
ssh gabriel@167.172.251.27

# PASO 2: Navegar al directorio del proyecto
cd /home/gabriel/Vegan-Wetlands

# PASO 3: Crear backup de configuración
cp server/config/luanti.conf server/config/luanti.conf.backup

# PASO 4: Añadir línea de bloqueo al archivo de configuración
echo "deny_access.IP_A_BLOQUEAR = Descripción del bloqueo" >> server/config/luanti.conf

# PASO 5: Verificar formato correcto
tail -5 server/config/luanti.conf

# PASO 6: Reiniciar servidor para aplicar cambios
docker-compose restart luanti-server
```

#### **Ejemplo Práctico:**
```bash
# Bloquear IP 200.83.160.80 usando luanti.conf
ssh gabriel@167.172.251.27 "cd /home/gabriel/Vegan-Wetlands && echo 'deny_access.200.83.160.80 = IP bloqueada por actividad maliciosa' >> server/config/luanti.conf"

# Reiniciar servidor
ssh gabriel@167.172.251.27 "cd /home/gabriel/Vegan-Wetlands && docker-compose restart luanti-server"
```

#### **⚠️ PROBLEMA COMÚN: Formato Mal Formateado**

**Síntoma detectado el 21/09/2025:**
```bash
# INCORRECTO (línea mal formateada):
admin_privs = server,privs,ban,kick,teleport,give,settime,worldedit,fly,fast,noclip,debug,password,rollback_checkdeny_access.200.83.160.80

# CORRECTO (líneas separadas):
admin_privs = server,privs,ban,kick,teleport,give,settime,worldedit,fly,fast,noclip,debug,password,rollback_check
deny_access.200.83.160.80 = IP bloqueada por actividad maliciosa
```

**Solución aplicada:**
```bash
# Arreglar formato mal formateado
ssh gabriel@167.172.251.27 "cd /home/gabriel/Vegan-Wetlands && sed -i 's/rollback_checkdeny_access.200.83.160.80/rollback_check\ndeny_access.200.83.160.80 = IP bloqueada por actividad maliciosa/' server/config/luanti.conf"

# Reiniciar servidor
ssh gabriel@167.172.251.27 "cd /home/gabriel/Vegan-Wetlands && docker-compose restart luanti-server"
```

#### **Ubicación del Archivo:**
```
Host VPS: /home/gabriel/Vegan-Wetlands/server/config/luanti.conf
Contenedor: /config/.minetest/minetest.conf
```

#### **Verificación del Formato:**
```bash
# Verificar que el formato es correcto
ssh gabriel@167.172.251.27 "cd /home/gabriel/Vegan-Wetlands && cat server/config/luanti.conf | grep -A1 -B1 'deny_access'"
```

---

### 3. 🟡 **MÉTODO AVANZADO: Firewall iptables (Nivel Sistema)**

**Ventajas:**
- ✅ Bloqueo completo de toda comunicación
- ✅ Afecta todos los servicios del VPS
- ✅ Más difícil de evadir
- ✅ Bloqueo bidireccional (entrada y salida)

**Desventajas:**
- ⚠️ Requiere privilegios root/sudo
- ⚠️ Puede afectar otros servicios
- ⚠️ Más complejo de gestionar

#### **Procedimiento:**

```bash
# REQUIERE ACCESO SUDO - Solo para casos extremos

# BLOQUEO DE ENTRADA (INPUT)
sudo iptables -A INPUT -s IP_A_BLOQUEAR -j DROP

# BLOQUEO DE SALIDA (OUTPUT) - OPCIONAL
sudo iptables -A OUTPUT -d IP_A_BLOQUEAR -j DROP

# BLOQUEO ESPECÍFICO PUERTO 30000
sudo iptables -A INPUT -s IP_A_BLOQUEAR -p udp --dport 30000 -j DROP

# HACER PERMANENTE
sudo iptables-save > /etc/iptables/rules.v4

# VERIFICAR REGLAS
sudo iptables -L -n | grep IP_A_BLOQUEAR
```

#### **Ejemplo:**
```bash
# Bloquear 200.83.160.80 en firewall
sudo iptables -A INPUT -s 200.83.160.80 -p udp --dport 30000 -j DROP
sudo iptables -L -n | grep 200.83.160.80
```

---

### 3. 🟠 **MÉTODO DOCKER: Network Restrictions (Nivel Contenedor)**

**Ventajas:**
- ✅ Aislamiento específico del contenedor
- ✅ No afecta otros servicios del VPS
- ✅ Configuración persistente

**Desventajas:**
- ⚠️ Requiere modificación docker-compose.yml
- ⚠️ Más complejo de implementar
- ⚠️ Necesita reinicio del contenedor

#### **Implementación en docker-compose.yml:**

```yaml
services:
  luanti-server:
    # ... configuración existente ...
    networks:
      luanti-network:
        ipv4_address: 172.20.0.10
    extra_hosts:
      - "200.83.160.80:127.0.0.1"  # Redirige a localhost (inaccesible)

networks:
  luanti-network:
    driver: bridge
    ipam:
      config:
        - subnet: 172.20.0.0/16
```

---

## 📊 GESTIÓN DE LISTA DE IPs BLOQUEADAS

### **Ver IPs Bloqueadas Actualmente:**

```bash
# Ver lista completa de IPs bloqueadas
ssh gabriel@167.172.251.27 "cd /home/gabriel/Vegan-Wetlands && docker-compose exec -T luanti-server cat /config/.minetest/worlds/world/ipban.txt"

# Contar número de IPs bloqueadas
ssh gabriel@167.172.251.27 "cd /home/gabriel/Vegan-Wetlands && docker-compose exec -T luanti-server wc -l /config/.minetest/worlds/world/ipban.txt"
```

### **Añadir Múltiples IPs:**

```bash
# Añadir múltiples IPs de una vez
docker-compose exec -T luanti-server sh -c 'cat << EOF >> /config/.minetest/worlds/world/ipban.txt
192.168.1.100
10.0.0.50
203.45.67.89
EOF'
```

### **Remover IP Específica:**

```bash
# Remover IP específica del ban list
IP_TO_REMOVE="200.83.160.80"
docker-compose exec -T luanti-server sh -c "grep -v '$IP_TO_REMOVE' /config/.minetest/worlds/world/ipban.txt > /tmp/ipban_temp && mv /tmp/ipban_temp /config/.minetest/worlds/world/ipban.txt"
```

### **Backup de Lista de IPs:**

```bash
# Crear backup de lista de IPs bloqueadas
ssh gabriel@167.172.251.27 "cd /home/gabriel/Vegan-Wetlands && docker-compose exec -T luanti-server cp /config/.minetest/worlds/world/ipban.txt /config/.minetest/worlds/world/ipban.txt.backup.$(date +%Y%m%d_%H%M%S)"
```

---

## 🔍 VERIFICACIÓN Y TESTING

### **Verificar que el Bloqueo Funciona:**

```bash
# MÉTODO 1: Revisar logs del servidor
docker-compose logs --tail=50 luanti-server | grep "refused\|blocked\|denied"

# MÉTODO 2: Simular conexión (desde máquina externa)
# Desde la IP bloqueada, intentar conectar con cliente Luanti
# Debe aparecer mensaje de "Connection refused" o timeout

# MÉTODO 3: Verificar con netstat en el contenedor
docker-compose exec luanti-server netstat -tulpn | grep :30000
```

### **Logs de Conexiones Rechazadas:**

```bash
# Ver intentos de conexión bloqueados
docker-compose logs luanti-server | grep -i "connection.*refused\|denied"

# Monitoreo en tiempo real
docker-compose logs -f luanti-server | grep -E "(refused|denied|blocked)"
```

---

## ⚠️ CASOS DE EMERGENCIA

### **Bloqueo Inmediato de IP en Situación de Crisis:**

```bash
#!/bin/bash
# Script: emergency_ip_block.sh

IP_MALICIOSA="$1"

if [ -z "$IP_MALICIOSA" ]; then
    echo "Uso: $0 <IP_A_BLOQUEAR>"
    exit 1
fi

echo "🚨 BLOQUEANDO IP MALICIOSA: $IP_MALICIOSA"

# PASO 1: Bloqueo inmediato en Luanti
ssh gabriel@167.172.251.27 "cd /home/gabriel/Vegan-Wetlands && docker-compose exec -T luanti-server sh -c 'echo \"$IP_MALICIOSA\" >> /config/.minetest/worlds/world/ipban.txt'"

# PASO 2: Reinicio rápido del servidor
ssh gabriel@167.172.251.27 "cd /home/gabriel/Vegan-Wetlands && docker-compose restart luanti-server"

# PASO 3: Verificación
ssh gabriel@167.172.251.27 "cd /home/gabriel/Vegan-Wetlands && docker-compose exec -T luanti-server cat /config/.minetest/worlds/world/ipban.txt | tail -5"

echo "✅ IP $IP_MALICIOSA BLOQUEADA EXITOSAMENTE"
```

### **Desbloquear IP en Caso de Error:**

```bash
#!/bin/bash
# Script: emergency_ip_unblock.sh

IP_A_DESBLOQUEAR="$1"

if [ -z "$IP_A_DESBLOQUEAR" ]; then
    echo "Uso: $0 <IP_A_DESBLOQUEAR>"
    exit 1
fi

echo "🔄 DESBLOQUEANDO IP: $IP_A_DESBLOQUEAR"

# Crear backup antes de modificar
ssh gabriel@167.172.251.27 "cd /home/gabriel/Vegan-Wetlands && docker-compose exec -T luanti-server cp /config/.minetest/worlds/world/ipban.txt /config/.minetest/worlds/world/ipban.txt.backup.$(date +%Y%m%d_%H%M%S)"

# Remover IP del archivo
ssh gabriel@167.172.251.27 "cd /home/gabriel/Vegan-Wetlands && docker-compose exec -T luanti-server sh -c \"grep -v '$IP_A_DESBLOQUEAR' /config/.minetest/worlds/world/ipban.txt > /tmp/ipban_temp && mv /tmp/ipban_temp /config/.minetest/worlds/world/ipban.txt\""

# Reiniciar servidor
ssh gabriel@167.172.251.27 "cd /home/gabriel/Vegan-Wetlands && docker-compose restart luanti-server"

echo "✅ IP $IP_A_DESBLOQUEAR DESBLOQUEADA"
```

---

## 📝 REGISTRO DE IPs BLOQUEADAS

### **Formato de Documentación:**

Para cada IP bloqueada, documentar en `docs/`:

```markdown
## IP: XXX.XXX.XXX.XXX
- **Fecha de bloqueo**: YYYY-MM-DD HH:MM
- **Razón**: Descripción del incidente
- **Usuario(s) asociado(s)**: Nombres de cuentas
- **Actividad maliciosa**: Descripción específica
- **Método de bloqueo**: ipban.txt / iptables / docker
- **Estado**: ACTIVO / REMOVIDO
- **Notas adicionales**: Información relevante
```

### **IPs Actualmente Bloqueadas:**

| IP | Fecha Bloqueo | Usuario | Razón | Método | Estado |
|---|---|---|---|---|---|
| 200.83.160.80 | 2025-09-20 | HAKER, gdfgd, etc. | Evasión de bans, griefing | luanti.conf | 🔴 ACTIVO |

### **Historial de Incidentes:**

#### **21/09/2025 - Problema de Formato Solucionado**
- **Problema**: Configuración mal formateada en `luanti.conf` causaba que el bloqueo no funcionara
- **Síntoma**: `admin_privs` y `deny_access` en la misma línea
- **Solución**: Separación de líneas usando `sed` + reinicio del servidor
- **Verificación**: IP correctamente bloqueada y servidor funcionando
- **Tiempo de resolución**: ~5 minutos
- **Estado**: ✅ RESUELTO

---

## 🔄 AUTOMATIZACIÓN Y MONITOREO

### **Script de Monitoreo Automático:**

```bash
#!/bin/bash
# monitor_blocked_ips.sh

IPBAN_FILE="/config/.minetest/worlds/world/ipban.txt"
LOG_FILE="/var/log/vegan_wetlands_security.log"

# Verificar intentos de reconexión de IPs bloqueadas
docker-compose exec -T luanti-server cat "$IPBAN_FILE" | while read blocked_ip; do
    if [ ! -z "$blocked_ip" ]; then
        # Buscar la IP en logs recientes
        attempts=$(docker-compose logs --tail=100 luanti-server | grep "$blocked_ip" | wc -l)

        if [ $attempts -gt 0 ]; then
            echo "[$(date)] ALERTA: IP bloqueada $blocked_ip intentó reconectarse $attempts veces" >> "$LOG_FILE"
        fi
    fi
done
```

### **Integración con Alertas (Discord/Email):**

```bash
#!/bin/bash
# alert_blocked_ip_attempt.sh

WEBHOOK_URL="https://discord.com/api/webhooks/YOUR_WEBHOOK_HERE"
IP_DETECTADA="$1"

curl -X POST "$WEBHOOK_URL" \
     -H "Content-Type: application/json" \
     -d "{
         \"content\": \"🚨 **ALERTA VEGAN WETLANDS** 🚨\\n\\n**IP BLOQUEADA DETECTADA:** \`$IP_DETECTADA\`\\n**Servidor:** luanti.gabrielpantoja.cl:30000\\n**Timestamp:** $(date)\\n\\n*Verificar logs inmediatamente*\"
     }"
```

---

## 🛡️ MEJORES PRÁCTICAS DE SEGURIDAD

### **1. Principio de Defensa en Capas:**

```
Capa 1: Firewall VPS (iptables)           [🟡 Nivel Sistema]
Capa 2: Docker Network Restrictions       [🟠 Nivel Contenedor]
Capa 3: Luanti ipban.txt                  [🟢 Nivel Aplicación]
Capa 4: Privilege Management              [🔵 Nivel Usuario]
```

### **2. Protocolo de Respuesta Graduada:**

```yaml
Nivel_1_Sospecha:
  action: "Monitoreo intensivo + documentación"

Nivel_2_Confirmación:
  action: "Bloqueo ipban.txt + alerta administradores"

Nivel_3_Persistencia:
  action: "Bloqueo iptables + análisis forense"

Nivel_4_Escalación:
  action: "Bloqueo de rango + contacto ISP"
```

### **3. Backup y Recuperación:**

```bash
# Backup diario automático de configuración de seguridad
0 3 * * * /home/gabriel/scripts/backup_security_config.sh

# Contenido del script:
#!/bin/bash
BACKUP_DIR="/home/gabriel/Vegan-Wetlands/backups/security"
DATE=$(date +%Y%m%d)

# Backup ipban.txt
docker-compose exec -T luanti-server cat /config/.minetest/worlds/world/ipban.txt > "$BACKUP_DIR/ipban_$DATE.txt"

# Backup iptables rules
sudo iptables-save > "$BACKUP_DIR/iptables_$DATE.rules"

# Limpiar backups antiguos (mantener 30 días)
find "$BACKUP_DIR" -name "*.txt" -mtime +30 -delete
find "$BACKUP_DIR" -name "*.rules" -mtime +30 -delete
```

---

## 📞 CONTACTOS DE EMERGENCIA

### **Escalación Técnica:**
- **Administrador Principal**: gabo
- **VPS Provider**: DigitalOcean Support
- **Domain Provider**: Soporte dominio gabrielpantoja.cl

### **Escalación Legal:**
- **Policía de Investigaciones (PDI)**: cibercrimen@investigaciones.cl
- **CSIRT Chile**: incidentes@csirt.gob.cl

---

## 📚 REFERENCIAS Y DOCUMENTACIÓN ADICIONAL

### **Documentos Relacionados:**
- `SECURITY_INCIDENT_HAKER_20250920.md` - Caso específico HAKER
- `IP_TRACKING_REGISTER_200.83.160.80.md` - Análisis detallado IP hostil
- `SECURITY_ANALYSIS_PRIVILEGE_ESCALATION_20250920.md` - Análisis de privilegios
- `CLAUDE.md` - Configuración general del servidor

### **Enlaces Útiles:**
- [Luanti Security Documentation](https://wiki.minetest.net/Server_Security)
- [Docker Network Security](https://docs.docker.com/network/security/)
- [iptables Tutorial](https://www.netfilter.org/documentation/HOWTO/packet-filtering-HOWTO.html)

---

## ✅ CHECKLIST DE IMPLEMENTACIÓN

### **Para Bloquear Nueva IP:**

- [ ] **Paso 1**: Identificar IP específica del atacante
- [ ] **Paso 2**: Documentar razón del bloqueo
- [ ] **Paso 3**: Crear backup de configuración actual
- [ ] **Paso 4**: Añadir IP a `/config/.minetest/worlds/world/ipban.txt`
- [ ] **Paso 5**: Verificar IP fue añadida correctamente
- [ ] **Paso 6**: Reiniciar servidor Luanti (opcional)
- [ ] **Paso 7**: Probar que el bloqueo funciona
- [ ] **Paso 8**: Documentar en registro de IPs bloqueadas
- [ ] **Paso 9**: Configurar monitoreo de reconexión
- [ ] **Paso 10**: Notificar a otros administradores

### **Para Casos de Emergencia:**

- [ ] **Ejecutar script de bloqueo de emergencia**
- [ ] **Activar monitoreo intensivo**
- [ ] **Notificar inmediatamente a administradores**
- [ ] **Documentar todo el incidente**
- [ ] **Evaluar necesidad de escalación**

---

**DOCUMENTO TÉCNICO OFICIAL**
**Servidor**: Vegan Wetlands (luanti.gabrielpantoja.cl:30000)
**Versión**: 1.1
**Generado**: 2025-09-20
**Actualizado**: 2025-09-21
**Próxima revisión**: 2025-10-20

---

*Este manual debe actualizarse cada vez que se implementen nuevos métodos de bloqueo o se modifique la arquitectura de seguridad del servidor.*