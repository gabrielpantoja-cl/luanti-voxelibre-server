# Bug: Servidor Duplicado en la Lista Pública de Luanti

**Última actualización**: 2026-06-30
**Severidad**: Media (cosmético, no afecta conectividad)
**Estado**: ✅ Resuelto — override elimina la duplicación activa; entrada fantasma del VPS anterior expiró sola a los 5 minutos de que ese servidor dejó de anunciar

---

## Resumen

El contenedor `linuxserver/luanti:latest` hardcodea `--port 30000` en su script de
inicio (`/etc/s6-overlay/s6-rc.d/svc-luanti/run`) ANTES de inyectar `CLI_ARGS`. Cuando
se pasa `--port 30001` en `CLI_ARGS`, Luanti interpreta ambos flags y abre **dos
puertos UDP simultáneamente** (30000 y 30001), anunciándose en ambos a
`servers.luanti.org`. Resultado: el mismo servidor aparece **dos veces** en la
lista pública de Luanti, una en `:30000` y otra en `:30001`.

El bug solo es visible cuando el contenedor se configura con un puerto distinto al
30000. Para Wetlands (que SÍ usa 30000) el problema es invisible porque el puerto
hardcodeado coincide con `CLI_ARGS`.

---

## El bug en detalle

### Script original del image (NO MODIFICAR)

```bash
# /etc/s6-overlay/s6-rc.d/svc-luanti/run (dentro del contenedor)
#!/usr/bin/with-contenv bash

exec \
    s6-notifyoncheck -d -n 300 -w 1000 -c "nc -zu localhost 30000" \
        s6-setuidgid abc luantiserver --port 30000 \
        --config /config/.minetest/main-config/minetest.conf ${CLI_ARGS}
```

Observaciones:
1. `--port 30000` aparece **fijo** en el comando del servidor.
2. El healthcheck (`nc -zu localhost 30000`) valida que ese puerto responda.
3. `CLI_ARGS` se concatena al final con `${CLI_ARGS}`.

### Qué pasa con `CLI_ARGS=--worldname valdivia --port 30001`

El comando final queda:

```bash
luantiserver --port 30000 \
    --config /config/.minetest/main-config/minetest.conf \
    --worldname valdivia \
    --port 30001
```

Luanti interpreta ambos `--port` y abre sockets UDP en los dos puertos. El server
se anuncia a `servers.luanti.org` desde cada uno de ellos.

### Cómo verificar el bug

En el VPS, dentro del contenedor:

```bash
# 1. Ver el comando del proceso
docker exec luanti-<servicio>-server ps aux | grep luantiserver | grep -v grep
# Resultado problemático:
#   abc  NNN  ...  luantiserver --port 30000 --config ... --worldname valdivia --port 30001
# Resultado correcto (post-fix):
#   abc  NNN  ...  luantiserver --config ... --worldname valdivia --port 30001

# 2. Ver los sockets UDP abiertos
docker exec luanti-<servicio>-server cat /proc/net/udp6
# Resultado problemático:
#   :::7530 = [::]:30000  ← extra
#   :::7531 = [::]:30001
# Resultado correcto (post-fix):
#   :::7531 = [::]:30001  ← solo este

# 3. Verificar duplicación en el listado público
curl -s https://servers.luanti.org/list | python3 -c "
import sys, json
for s in json.load(sys.stdin).get('list', []):
    if 'gabrielpantoja' in s.get('address',''):
        print(f'{s[\"name\"]} -> {s[\"address\"]}:{s[\"port\"]} v={s[\"version\"]}')
"
# Resultado problemático: dos entradas del mismo server
# Resultado correcto: una sola entrada
```

### Falsa alarma: caché obsoleto

`servers.luanti.org` mantiene entradas obsoletas durante horas. Si `server_announce`
se apaga, la entrada tarda **hasta varias horas** en expirar. Esto NO es el bug de
duplicación: es solo caché.

Para distinguir:

| Estado | Evidencia |
|--------|-----------|
| **Anuncio actual duplicado** | Dos entradas con `uptime` similar (reciente) y misma `version` (la actual del server) |
| **Caché obsoleto** | Una entrada con `uptime` viejo (muchas horas) y `version` antigua (ej. 5.13.0) |

Verificación adicional con `tcpdump` en el VPS:

```bash
# Capturar 60s y filtrar anuncios a servers.luanti.org
sudo timeout 60 tcpdump -i any -nn udp dst host servers.luanti.org 2>&1 | head
# Si NO hay paquetes: el server NO está anunciando (es solo caché)
```

---

## Solución: override del script `run`

Sobreescribimos el script del contenedor con un bind mount que elimina el
`--port 30000` hardcodeado y deja el puerto controlado solo por `--port` en
`CLI_ARGS`.

### 1. Crear el script override (en el repo)

Archivo: `server/container-overrides/svc-luanti/run`

```bash
#!/usr/bin/with-contenv bash
# shellcheck shell=bash
#
# Override del script /etc/s6-overlay/s6-rc.d/svc-luanti/run del image linuxserver/luanti.
# Elimina el `--port 30000` hardcodeado que causa el bug de duplicación.
# Este es el documento canónico. Mantener aquí siempre.

PORT=""
PREV=""
for arg in ${CLI_ARGS}; do
    if [ "$PREV" = "--port" ]; then
        PORT="$arg"
        break
    fi
    PREV="$arg"
done
[ -z "$PORT" ] && PORT=30000

exec \
    s6-notifyoncheck -d -n 300 -w 1000 -c "nc -zu localhost ${PORT}" \
        s6-setuidgid abc luantiserver \
        --config /config/.minetest/main-config/minetest.conf ${CLI_ARGS}
```

Hacerlo ejecutable (importante, sino s6 lo ignora):

```bash
chmod +x server/container-overrides/svc-luanti/run
```

### 2. Montar como bind en `docker-compose.yml`

Para cada contenedor con puerto distinto al 30000, agregar el bind mount:

```yaml
services:
  luanti-valdivia:
    image: linuxserver/luanti:latest
    container_name: luanti-valdivia-server
    ports:
      - "30001:30001/udp"
    volumes:
      # Override del script run (elimina --port 30000 hardcodeado del image)
      - ./server/container-overrides/svc-luanti/run:/etc/s6-overlay/s6-rc.d/svc-luanti/run:ro
      # ... resto de volumes ...
    environment:
      - CLI_ARGS=--worldname valdivia --port 30001
    # ...
```

### 3. Recrear el contenedor (importante: `restart` no aplica el cambio)

`docker compose restart` **NO** aplica cambios de volúmenes ni de `CLI_ARGS`.
Es necesario recrear el contenedor:

```bash
cd /home/gabriel/luanti-voxelibre-server
git pull origin main
docker compose up -d --force-recreate --no-deps luanti-valdivia
```

`--force-recreate` fuerza al Docker Compose a destruir el contenedor y crear uno
nuevo con la nueva configuración.

### 4. Verificar

```bash
# Proceso del server: NO debe tener --port 30000 antes de CLI_ARGS
docker exec luanti-valdivia-server ps aux | grep luantiserver | grep -v grep
# Esperado: luantiserver --config ... --worldname valdivia --port 30001

# Sockets UDP: solo debe escuchar en 30001
docker exec luanti-valdivia-server cat /proc/net/udp6
# Esperado: una sola línea :::7531 = [::]:30001

# Lista pública: una sola entrada para Valdivia
curl -s https://servers.luanti.org/list | python3 -c "
import sys, json
valdivia = [s for s in json.load(sys.stdin).get('list', [])
            if 'gabrielpantoja' in s.get('address','') and 'valdivia' in s.get('name','').lower()]
print(f'Entradas Valdivia: {len(valdivia)}')
for s in valdivia:
    print(f'  {s[\"name\"]} -> {s[\"address\"]}:{s[\"port\"]}')
"
# Esperado: "Entradas Valdivia: 1"
```

---

## Diagnóstico en VPS: checklist completo

Si ves un duplicado en `servers.luanti.org`, sigue estos pasos para confirmar
que es el bug (y no caché):

### Paso 1: identificar la versión y uptime de la entrada duplicada

```bash
curl -s https://servers.luanti.org/list | python3 -c "
import sys, json
for s in json.load(sys.stdin).get('list', []):
    if 'gabrielpantoja' in s.get('address',''):
        print(f'{s[\"name\"]} -> {s[\"address\"]}:{s[\"port\"]} v={s[\"version\"]} uptime={s[\"uptime\"]}')
"
```

- **Misma `version`, `uptime` reciente**: bug real, server anunciándose en dos puertos.
- **Una entrada con `version` vieja y `uptime` de horas**: caché obsoleto, no es bug.

### Paso 2: contar procesos `luantiserver` en el VPS

```bash
ps aux | grep luantiserver | grep -v grep
# Cada servidor debe ser UN SOLO proceso. Si ves uno por puerto en el mismo world = bug.
```

### Paso 3: contar sockets UDP escuchando

```bash
cat /proc/net/udp6 | grep -E '7530|7531|7532|7533'
# Cada servidor debe ser UN SOLO socket en su puerto público.
```

### Paso 4: capturar tráfico de anuncios

```bash
# Ejecutar por 60+ segundos. Si hay paquetes a servers.luanti.org:30000 = bug.
sudo timeout 90 tcpdump -i any -nn udp dst host servers.luanti.org 2>&1 | head -20
```

### Paso 5: confirmar el comando del proceso

```bash
docker exec luanti-<servicio>-server ps aux | grep luantiserver | grep -v grep
# Si aparece "--port 30000" antes de CLI_ARGS con otro puerto = bug.
```

---

## Por qué no funciona `restart` (sutileza importante)

Un error común es aplicar el fix al `docker-compose.yml` y solo hacer
`docker compose restart`. Esto **no aplica el cambio** porque:

1. `restart` solo reinicia el proceso dentro del contenedor existente.
2. Los volúmenes bind-mount se aplican en la **creación** del contenedor.
3. `CLI_ARGS` también se aplica al crear el contenedor (vía `env`).

Para que un cambio en `docker-compose.yml` tome efecto, **siempre** hay que
recrear el contenedor:

```bash
docker compose up -d --force-recreate --no-deps <servicio>
```

`--no-deps` evita que se reinicien otros servicios dependientes. `--force-recreate`
ignora la caché y destruye el contenedor aunque la "config" parezca igual.

---

## ¿Por qué no afectaba a Wetlands (puerto 30000)?

El bug solo aparece cuando el puerto deseado difiere del hardcodeado (30000).
Wetlands usa exactamente 30000, así que `--port 30000 --worldname original`
no genera duplicación: solo se abre un puerto, el 30000.

Además, `server_announce = false` en Wetlands previene que se anuncie, así
que aunque el bug existiera, no se vería en la lista pública.

Valdivia (30001) y cualquier servidor futuro con puerto distinto al 30000
**sí** ven el bug.

---

## Alternativa rechazada: swap de puertos

Se consideró intercambiar los mundos (Valdivia al 30000, Wetlands al 30001)
como último recurso. **Rechazado** porque:

1. El puerto 30000 está documentado y comunicado como "Wetlands" en AGENTS.md,
   landing page, y la documentación por mundos (`docs/01-ORIGINAL-30000/`).
2. El puerto 30001 está documentado como "Valdivia" en `docs/02-VALDIVIA-30001/`.
3. Intercambiar requiere reescribir toda la documentación y notificar a usuarios.
4. El override del script es una solución limpia, contenida y reversible.

---

## Entrada fantasma del VPS anterior (DigitalOcean)

Aunque el override soluciona la duplicación activa, **persiste una entrada
fantasma** en `servers.luanti.org` que no podemos eliminar desde el VPS actual.

### Causa raíz: migración de VPS con cambio de IP

| VPS | IP pública | Período | Puerto Valdivia |
|-----|-----------|---------|-----------------|
| DigitalOcean (anterior) | `IP_DO` (distinta) | Antes del fix | `:30000` y `:30001` (bug activo) |
| Oracle (actual) | `159.112.138.229` | Post-fix | Solo `:30001` |

Cuando el servidor **aún estaba en DigitalOcean** y corría v5.13.0 con el bug
del doble puerto, anunciaba Valdivia tanto en `:30000` como en `:30001`.
La entrada en `:30000` quedó almacenada en `servers.luanti.org` con llave
primaria `(IP_DO, 30000)`.

Al migrar a Oracle (cambiando la IP pública), el servidor actual anuncia
Valdivia en `:30001` y la entrada se guarda con llave `(159.112.138.229, 30001)`.
La entrada vieja en `(IP_DO, 30000)` quedó huérfana.

### Por qué no podemos borrarla vía API

El servidor list (`server.py` del repo `luanti-org/serverlist`) almacena cada
entrada con `remote_addr` (IP del request HTTP) como parte de la llave primaria:

```python
@app.post("/announce")
def announce():
    ip = request.remote_addr
    # ...
    old = serverList.get(ip, req["port"])

def getWithIndex(self, ip, port):
    for i, server in enumerate(self.list):
        if server.ip == ip and server.port == port:
            return (i, server)
    return (None, None)
```

Para hacer `DELETE` de una entrada, la API busca por `(IP_del_request, puerto)`.
Como hoy enviamos requests desde Oracle (`159.112.138.229`), la API no encuentra
la entrada guardada con `IP_DO`:

```bash
# ✅ Podemos crear y borrar entradas desde nuestra IP actual
curl -X POST https://servers.luanti.org/announce \
  -d 'json={"action":"start","port":30000,"clients":0,"clients_max":20,"uptime":1,"game_time":60,"version":"5.16.1","proto_min":40,"proto_max":43,"gameid":"mineclone2","name":"Valdivia [Chile]","description":"test"}'
# → "Request has been filed." (202)

curl -X POST https://servers.luanti.org/announce \
  -d 'json={"action":"delete","port":30000}'
# → "Removed from server list." (200)

# ❌ Pero la entrada vieja (v=5.13.0, IP_DO) sigue ahí
#    porque tiene otra llave primaria
```

### Por qué la uptime aumenta en tiempo real

La entrada fantasma muestra `uptime` incrementándose al mismo ritmo que el
tiempo real (~300s cada 5 minutos). Esto ocurre porque `servers.luanti.org`
re-pingea periódicamente la entrada para verificar que el servidor sigue vivo
(el ping va a `luanti.gabrielpantoja.cl:30000`, que hoy responde con Wetlands).
Aunque el ping solo mide latencia, el servidor list **actualiza `updateTime`**
de la entrada, y el uptime reportado es el que el servidor (Wetlands) devuelve
al responder — de ahí que avance sincronizado.

### Solución: esperar expiración automática (5 minutos)

Confirmado por `sfan5` (mantenedor de `servers.luanti.org`) vía
[issue #75](https://github.com/luanti-org/serverlist/issues/75):

> *"Server entries that aren't updated every 5 minutes automatically disappear,
> so all you need to do is stop the old Luanti server."*

El servidor list purga entradas viejas según la configuración `PURGE_TIME`:

```python
def purgeOld(self):
    cutoff = int(time.time()) - app.config["PURGE_TIME"]
    self.list = [server for server in self.list if cutoff <= server.updateTime]
```

En producción `PURGE_TIME = 5 minutos`. Una vez que el VPS anterior
(DigitalOcean) dejó de correr y de enviar anuncios, la entrada fantasma
expiró automáticamente en ~5 minutos. No fue necesaria intervención manual.

**Estado**: resuelto en 2026-06-29 al dejar de correr el VPS anterior.

---

## Contactar a mantenedores de `servers.luanti.org`

~~Si la entrada fantasma no expira en 48h, abrir un issue.~~ **Ya no necesario.**

Contactamos a los mantenedores en
[luanti-org/serverlist#75](https://github.com/luanti-org/serverlist/issues/75)
y confirmaron que `PURGE_TIME = 5 minutos`. La entrada expiró automáticamente.

---

## Archivos relacionados

- `docker-compose.yml` — bind mount del script override + `CLI_ARGS` por servicio
- `server/container-overrides/svc-luanti/run` — script override
- `docs/02-VALDIVIA-30001/current.md` — métricas y configuración de Valdivia
- `AGENTS.md` — jerarquía de configuración (sección "Configuration Hierarchy")

---

## Historial

| Fecha | Cambio |
|-------|--------|
| 2026-06-29 | Diagnóstico del bug vía SSH + tcpdump en el VPS |
| 2026-06-29 | Creación del script override + bind mount en docker-compose.yml |
| 2026-06-29 | `--force-recreate` del contenedor Valdivia + verificación post-fix |
| 2026-06-29 | Documentación de este bug (este archivo) |
| 2026-06-29 | Diagnóstico SSH avanzado: se descubre que la entrada fantasma `:30000` v=5.13.0 fue creada desde la IP del VPS anterior (DigitalOcean). No se puede borrar desde Oracle porque la API usa `request.remote_addr` como llave primaria. Se agrega sección de contacto a mantenedores. |
| 2026-06-29 | Confirmado por `sfan5` (mantenedor) en [issue #75](https://github.com/luanti-org/serverlist/issues/75): `PURGE_TIME = 5 minutos`. La entrada fantasma expiró sola al dejar de anunciar el VPS anterior. Bug completamente resuelto. |