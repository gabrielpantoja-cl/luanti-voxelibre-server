# Issue: Puerto 30001 - Servidor Valdivia 2.0 no acepta conexiones externas

**Estado:** RESUELTO
**Fecha:** 21 marzo 2026
**Afecta:** Servidor Valdivia 2.0 (puerto 30001)

## Sintoma

Los jugadores no podian conectarse a `luanti.gabrielpantoja.cl:30001` desde el cliente Luanti.
El servidor Wetlands en puerto 30000 funcionaba sin problemas.
El cliente reportaba "Connection timed out".

## Causa raiz

El archivo `auth.sqlite` del mundo Valdivia estaba **vacio (0 bytes)** — existia pero sin tablas SQLite.

Cuando un jugador intentaba conectarse, el callback `on_prejoinplayer` ejecutaba:
```
SELECT id, name, password, last_login FROM auth WHERE name = ?
```
Esto fallaba con `no such table: auth`, causando un crash silencioso del handler de conexion. El servidor seguia corriendo y escuchando UDP, pero no podia completar el handshake con ningun cliente.

```
ERROR[Main]: ServerError: AsyncErr: Lua: Runtime error from mod '*builtin*'
  in callback on_prejoinplayer():
  "Failed to prepare query ... no such table: auth"
```

## Por que fue dificil de diagnosticar

1. El contenedor aparecia como `Up` en `docker ps`
2. El servidor escuchaba en `[::]:30000` y respondia a paquetes UDP basicos
3. `nc -u` con protocolo Luanti obtenia respuesta del handshake inicial
4. tcpdump confirmaba paquetes de ida y vuelta
5. El error solo ocurria en el paso de autenticacion (despues del handshake UDP), invisible sin revisar logs completos

## Solucion

```bash
# 1. Eliminar auth.sqlite vacio
sudo rm ~/luanti-voxelibre-server/server/worlds/valdivia/auth.sqlite

# 2. Reiniciar el contenedor
docker restart luanti-valdivia-server

# Luanti crea automaticamente un auth.sqlite nuevo con las tablas correctas
# cuando el primer jugador se conecta
```

## Acciones adicionales tomadas durante diagnostico

- Regla iptables para UDP 30001 agregada a `ufw-user-input` y persistida en `/etc/ufw/user.rules`
- Force-recreate del contenedor Valdivia
- Swap test confirmando que el problema era del container/config, no del puerto

## Leccion aprendida

- Un `auth.sqlite` de 0 bytes no es lo mismo que ausencia del archivo. Luanti crea las tablas si el archivo no existe, pero falla si existe vacio.
- Los errores de `on_prejoinplayer` no impiden que el servidor escuche UDP ni responda al handshake inicial — solo fallan al autenticar, haciendo que el cliente vea "Connection timed out".
- Siempre revisar los logs completos (`docker logs`) buscando `ERROR` antes de diagnosticar red/firewall.

---

*Resuelto: 21 marzo 2026*
