# Bug: Servidor Duplicado en la Lista Pública de Luanti

**Última actualización**: 2026-06-29
**Severidad**: Media (cosmético, no afecta conectividad)
**Estado**: ✅ Resuelto vía override del script `svc-luanti/run`

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