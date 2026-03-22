# Issue: Puerto 30001 - Servidor Valdivia 2.0 no acepta conexiones externas

**Estado:** EN INVESTIGACION
**Fecha:** 21 marzo 2026
**Afecta:** Servidor Valdivia 2.0 (puerto 30001)
**No afecta:** Servidor Wetlands (puerto 30000, funciona correctamente)

## Sintoma

Los jugadores no pueden conectarse a `luanti.gabrielpantoja.cl:30001` desde el cliente Luanti.
El servidor Wetlands en puerto 30000 funciona sin problemas.
El servidor Valdivia SI funciono brevemente (usuario gabo7 se conecto exitosamente a las 19:57 UTC del 21 marzo).

## Lo que funciona

- El contenedor Docker esta corriendo (`docker ps` muestra `Up`, puerto `0.0.0.0:30001->30000/udp`)
- El servidor Luanti dentro del contenedor esta listening (`Server for gameid="mineclone2" listening on [::]:30000`)
- Oracle Cloud Security List tiene regla UDP 30001 con source 0.0.0.0/0
- Los paquetes UDP llegan al VPS (confirmado con tcpdump en `enp0s6`)
- El DNAT funciona (paquetes se reenvian de 30001 a 172.18.0.x:30000 dentro del bridge Docker)
- Los paquetes llegan al contenedor (confirmado con tcpdump en bridge y veth)

## Lo que NO funciona

- El servidor Luanti dentro del contenedor **no responde** a los paquetes UDP
- tcpdump muestra paquetes entrantes pero ningun paquete de respuesta

## Diagnostico detallado

### 1. Comparacion Wetlands vs Valdivia

| Aspecto | Wetlands (funciona) | Valdivia (no funciona) |
|---------|--------------------|-----------------------|
| Puerto host | 30000 | 30001 |
| Puerto interno | 30000 | 30000 |
| bind_address config | comentado (default) | comentado (default) |
| Listening socket | `udp :::30000` | `udp :::30000` |
| Config file usado | `/config/.minetest/main-config/minetest.conf` | `/config/.minetest/main-config/minetest.conf` |
| Proceso | `luantiserver --port 30000 --worldname world` | `luantiserver --port 30000 --worldname valdivia` |
| world.mt gameid | mineclone2 | mineclone2 |

### 2. Red / Firewall

```
# iptables INPUT: ACCEPT para UDP 30001 (regla 1)
# nftables: DNAT de 30001 a container_ip:30000
# Docker FORWARD: ACCEPT para container_ip:30000
# Oracle Cloud Security List: UDP 30001 from 0.0.0.0/0
```

### 3. Paquetes capturados (tcpdump)

```
# Paquete llega al VPS:
enp0s6 In  IP client.port > vps.30001: UDP, length 5

# Se reenvía al bridge Docker:
br-xxxxx Out IP 172.18.0.1.port > 172.18.0.x.30000: UDP, length 5

# Sale por el veth al contenedor:
vethxxxx Out IP 172.18.0.1.port > 172.18.0.x.30000: UDP, length 5

# NO HAY PAQUETE DE RESPUESTA
```

### 4. Hallazgo: bind_address

- Con `bind_address = 0.0.0.0` el servidor escucha en `udp 0.0.0.0:30000` (IPv4 only)
- Sin bind_address (default) escucha en `udp :::30000` (IPv6 + IPv4, dual stack)
- Wetlands no tiene bind_address configurado y funciona
- Valdivia se cambio a default pero sigue sin funcionar

### 5. Config del contenedor linuxserver/luanti

El contenedor `linuxserver/luanti:latest` tiene un comportamiento particular:
- No usa directamente el archivo montado en `/config/.minetest/minetest.conf`
- Copia la config a `/config/.minetest/main-config/minetest.conf` en el primer inicio
- El proceso luantiserver usa `--config /config/.minetest/main-config/minetest.conf`
- Cambios en el archivo montado NO se reflejan automaticamente, hay que copiar manualmente

## Acciones tomadas

1. Verificar Oracle Cloud Security List - OK (UDP 30001 desde 0.0.0.0/0)
2. Agregar regla iptables INPUT UDP 30001 - Hecho
3. Agregar regla ufw-user-input UDP 30001 - Hecho
4. Reiniciar Docker daemon - Hecho
5. docker compose down/up completo - Hecho (red recreada)
6. Copiar config a main-config/ - Hecho
7. Comentar bind_address para usar default - Hecho
8. Verificar con tcpdump que paquetes llegan - Confirmado
9. Restaurar mundo v3 (que funcionaba) - Probado, mismo problema

## Hipotesis pendientes

1. **El contenedor necesita ser recreado con `docker compose up --force-recreate`** despues del cambio de config
2. **Conflicto de puertos internos**: ambos contenedores usan puerto 30000 internamente, podria haber conflicto a nivel de respuesta UDP (source port)
3. **El minetest.conf montado (volume bind) esta sobreescribiendo main-config en cada restart** con la version vieja que tenia bind_address
4. **Problema de MTU o fragmentacion UDP** especifico al puerto 30001 pero no al 30000
5. **Rate limiting o conntrack** de Oracle Cloud que descarta UDP en puertos no-standard

## Proximos pasos

1. Probar `docker compose up --force-recreate luanti-valdivia`
2. Probar cambiar el puerto de Valdivia a 30002 o 30010 (descartar problema especifico del 30001)
3. Probar sin el volumen de config montado (dejar que el contenedor use su config default)
4. Revisar si hay conntrack rules que bloquean
5. Probar exponer Valdivia en puerto 30000 temporalmente (apagando Wetlands) para confirmar que el contenedor funciona

## Workaround temporal

Si el problema persiste, se puede usar el servidor Valdivia localmente:
- `docker compose up -d luanti-valdivia` en PC local
- Conectar via `localhost:30001`
- Los ninos no podran acceder remotamente hasta resolver el issue

---

*Documento de troubleshooting - 21 marzo 2026*
