# Proyecto LLANURA CTF — Mundo plano para captura la bandera

Cuarto mundo del servidor Wetlands: una llanura **100% plana de pura tierra** (sin ríos, árboles
ni decoración) pensada para jugar **captura la bandera** entre dos equipos. Modo creativo, sobre
VoxeLibre. No usa el juego "Capture The Flag" de rubenwardy (es un engine aparte incompatible con
VoxeLibre): la mecánica de banderas es un mod casero (`wetlands_ctf`) y el terreno lo genera otro
mod casero (`wetlands_flatworld`).

## Resumen

| Item | Valor |
|---|---|
| Puerto público | **30003/UDP** |
| Container | `luanti-ctf-server` |
| Config | `server/config/luanti-ctf.conf` |
| Mundo | `server/worlds/ctf/` (gitignored, se crea en el VPS — no se clona de nada) |
| Mapgen | `singlenode` + mod `wetlands_flatworld` (genera tierra bajo demanda) |
| Combate | Modpack `ctf_guns` (mismo set de armas que Infierno) |
| Notifier Discord | `discord-notifier-ctf` (label `Llanura CTF ⚔️`) |

## Cómo funciona el terreno (`wetlands_flatworld`)

- `mg_name = singlenode`: el motor no genera nada por sí solo.
- `minetest.register_on_generated` rellena cada chunk emergido:
  - `y <= 0` → `mcl_core:dirt` (pura tierra, sin pasto arriba ni piedra abajo)
  - `y > 0` → aire
- La superficie pisable queda en **y=0**; el `static_spawnpoint` del mundo es `0,2,0`.
- La tierra hacia abajo **se materializa bajo demanda** cuando alguien cava, hasta el límite del
  motor (~ -31000). No se pre-genera el mundo entero: la superficie es instantánea y liviana, y solo
  crece en disco si los jugadores excavan hondo.
- Archivo: `server/mods/wetlands_flatworld/init.lua`. Para cambiar la altura de la superficie, editar
  `SURFACE_Y` (y ajustar `static_spawnpoint` en consecuencia).

## Cómo funciona la captura la bandera (`wetlands_ctf`)

- Dos equipos: **rojo** y **azul**. Una bandera por equipo en su base (nodo luminoso e
  indestructible, `diggable = false`, anti-grief).
- Comandos `/ctf`:
  - `/ctf entrar [rojo|azul]` — te une a un equipo (auto-balancea si no indicas color) y te lleva a tu base.
  - `/ctf salir` — sales del juego (si llevabas una bandera, vuelve a su base).
  - `/ctf base` — te teletransporta a tu base.
  - `/ctf marcador` — muestra el puntaje.
  - `/ctf reset` — reinicia la ronda (requiere privilegio `server`).
- Mecánica: tocas (clic derecho) la bandera enemiga en su base → la llevas (marcador visual sobre
  tu cabeza) → la dejas en tu base **con tu bandera en casa** = **+1 punto**. Si mueres o te
  desconectas mientras la llevas, la bandera vuelve a su base.
- Marcador en HUD, respawn por equipo, victoria a **3 capturas** (`ctf.WIN_SCORE`) con reinicio
  automático en 5 segundos.
- Coordenadas de bases y spawns: tabla `ctf.teams` en `server/mods/wetlands_ctf/init.lua`
  (rojo en `-60,_,0`; azul en `60,_,0`). Editar ahí para mover las bases.

## Estado actual

### ✅ Hecho (en este repo, código local)

- `server/mods/wetlands_flatworld/` (`mod.conf` + `init.lua`) — generador del terreno plano.
- `server/mods/wetlands_ctf/` (`mod.conf` + `init.lua`) — juego de captura la bandera.
- `server/config/luanti-ctf.conf` — config del 4º mundo (creativo, singlenode, sin mobs, spawn
  `0,2,0`, mods mínimos + flatworld + ctf + `ctf_guns`).
- `docker-compose.yml` — servicios `luanti-ctf` (30003) y `discord-notifier-ctf`.
- `CLAUDE.md` — tabla "Multi-world architecture" actualizada a 4 mundos.

### ⏳ Pendiente (deploy + Oracle Cloud)

1. **Probar local** (cuando Docker quede disponible tras reinicio de Windows, en Git Bash):
   ```bash
   docker compose up -d luanti-ctf
   docker compose logs --since=2m luanti-ctf-server | grep -iE "error|warning|flatworld|wetlands_ctf"
   ```
2. **Deploy a VPS** (ver sección siguiente).
3. **Abrir 30003/UDP en Oracle Cloud** (paso manual en la consola web — ver abajo).

## Deploy (primera vez)

### 1. Push del código local
```bash
git add docker-compose.yml server/config/luanti-ctf.conf \
        server/mods/wetlands_flatworld server/mods/wetlands_ctf \
        CLAUDE.md docs/projects/mundo-4-puerto-30003-ctf-llanura.md
git commit -m "feat(ctf): add flat capture-the-flag world on port 30003"
git push origin main
```

### 2. Pull en VPS y crear el mundo

La carpeta `server/worlds/ctf/` no está en git (igual que los otros mundos). Hay que crearla con su
`world.mt`, que es **la compuerta real**: un mod carga solo si `world.mt` lo habilita (ver
`docs/config/01-CONFIGURATION_HIERARCHY.md`).

```bash
ssh gabriel@<VPS_IP> "cd /home/gabriel/luanti-voxelibre-server && git pull origin main"

# Crear el world.mt del mundo nuevo con los mods habilitados:
ssh gabriel@<VPS_IP> "mkdir -p /home/gabriel/luanti-voxelibre-server/server/worlds/ctf && \
cat > /home/gabriel/luanti-voxelibre-server/server/worlds/ctf/world.mt <<'EOF'
gameid = mineclone2
backend = sqlite3
player_backend = sqlite3
auth_backend = sqlite3
load_mod_wetlands_flatworld = true
load_mod_wetlands_ctf = true
load_mod_wetlands_newplayer = true
load_mod_server_rules = true
load_mod_wetlands_fixlight = true
load_mod__world_folder_media = true
load_mod_mcl_custom_world_skins = true
load_mod_worldedit = true
load_mod_worldedit_commands = true
load_mod_worldedit_shortcommands = true
load_mod_controls = true
load_mod_ctf_core = true
load_mod_rawf = true
load_mod_grenades = true
load_mod_ctf_ranged = true
EOF"

# El container escribe como UID 1000 — dar esa propiedad a la carpeta del mundo:
ssh gabriel@<VPS_IP> "sudo chown -R 1000:1000 /home/gabriel/luanti-voxelibre-server/server/worlds/ctf"
```

### 3. Abrir puerto UDP 30003 en el firewall

**a) Oracle Cloud Security List** (consola web — PASO MANUAL, lo hace Gabriel):
- Networking → Virtual Cloud Networks → tu VCN → Security Lists → la security list de la subnet
- Add Ingress Rule:
  - Source CIDR: `0.0.0.0/0`
  - IP Protocol: `UDP`
  - Destination Port Range: `30003`
  - Description: `Luanti Llanura CTF`

**b) Firewall del host VPS** (Oracle Linux usa firewalld):
```bash
ssh gabriel@<VPS_IP> "sudo firewall-cmd --add-port=30003/udp --permanent && sudo firewall-cmd --reload"
```
(Si el host usara iptables en vez de firewalld:
`sudo iptables -I INPUT -p udp --dport 30003 -j ACCEPT && sudo iptables-save | sudo tee /etc/iptables/rules.v4`.)

> ⚠️ Sin el paso (a) en la consola de Oracle, el puerto queda bloqueado en la nube aunque el
> container esté arriba y el firewall del host abierto. Es el olvido más común al sumar un mundo.

### 4. Levantar containers
```bash
ssh gabriel@<VPS_IP> "cd /home/gabriel/luanti-voxelibre-server && \
    docker compose up -d luanti-ctf discord-notifier-ctf"
```

### 5. Verificar
```bash
# Logs: confirmar que cargan los mods y no hay errores
ssh gabriel@<VPS_IP> "docker logs --since=2m luanti-ctf-server 2>&1 | \
    grep -iE 'error|warning|listening|flatworld|wetlands_ctf'"

# Probar puerto desde fuera
nc -uv luanti.gabrielpantoja.cl 30003
```
Conectarse en el cliente Luanti a `luanti.gabrielpantoja.cl:30003`. Probar:
- Superficie totalmente plana de tierra; cavar y ver tierra maciza; sin árboles/agua.
- `/ctf entrar` une a un equipo y teletransporta a la base; las dos banderas están colocadas.

## Notas

- **Sin `map.sqlite` que clonar**: a diferencia de Valdivia/Infierno, este mundo nace vacío y el
  terreno se genera solo con `wetlands_flatworld`. La primera conexión genera la zona de spawn.
- **`world.mt` es obligatorio**: omitir el paso 2 es la causa #1 de "los mods existen pero los ítems
  salen como desconocidos / el comando `/ctf` no existe".
- **Profundidad**: la tierra maciza hacia abajo crece en disco solo con exploración; en un mundo de
  construcción/combate la mayoría queda cerca de la superficie, así que es manejable.
- **Recursos esperados**: similar a Valdivia/Infierno idle (~300 MB RAM); con el modpack de armas
  y jugadores activos, estimado hasta ~600 MB. Headroom amplio en el VPS Oracle ARM (24 GB).
- **Edad recomendada**: hay PvP y armas (`ctf_guns`); marcarlo en el landing como "10+" igual que
  Infierno, distinto del mundo familiar 7+ del puerto 30000.

## Archivos del proyecto

| Archivo | Rol |
|---|---|
| `server/mods/wetlands_flatworld/init.lua` | Generación del terreno plano de tierra |
| `server/mods/wetlands_ctf/init.lua` | Juego captura la bandera (equipos, banderas, marcador) |
| `server/config/luanti-ctf.conf` | Config del mundo (kill-switch de mods) |
| `docker-compose.yml` | Servicios `luanti-ctf` + `discord-notifier-ctf` |
| `server/worlds/ctf/world.mt` | Compuerta de mods (se crea en el VPS, no en git) |
