# Privilegios en Valdivia

**Última actualización**: 2026-06-30

---

## Privilegios de jugadores nuevos

| Privilegio | Nuevo jugador | gabo (admin) |
|---|---|---|
| `interact` | ✅ | ✅ |
| `shout` | ✅ | ✅ |
| `creative` | ✅ | ✅ |
| `fast` | ✅ | ✅ |
| `spawn` | ✅ | ✅ |
| `teleport` | ✅ | ✅ |
| `fly` | ❌ | ✅ |
| `noclip` | ❌ | ✅ |
| `give` | ❌ | ✅ |
| `server`, `privs`, `ban`, … | ❌ | ✅ |

**Filosofía**: Valdivia es un mundo de exploración urbana. Sin `fly` y sin `noclip` los jugadores recorren las calles a nivel de suelo, lo que es más inmersivo para una recreación de ciudad real. `fast` compensa el tamaño del mapa (9.5 km de largo). El daño está habilitado (`enable_damage = true`).

> ⚠️ **Pitfall crítico**: aunque el privilegio `fly` controla quién puede volar, si `creative_mode = true` está activo en el servidor, **todos los jugadores pueden volar sin importar sus privilegios**. Para que `fly` funcione como control, `creative_mode` debe estar en `false`.

---

## Inventario creativo — cómo funciona en VoxeLibre

> ⚠️ **Pitfall VoxeLibre**: con `creative_mode = false`, el privilegio `creative` de Luanti NO da acceso al inventario creativo. VoxeLibre sobreescribe `minetest.is_creative_enabled()` para usar su propio sistema de gamemode por jugador (metadata `gamemode = "creative"` en el jugador). El `mod valdivia_newplayer` setea esta metadata en `register_on_joinplayer` para todos los jugadores al conectarse.

**Resumen de la lógica**:
- VoxeLibre con `creative_mode = true` → todos tienen inventario creativo (y vuelo global)
- VoxeLibre con `creative_mode = false` + metadata `gamemode = "creative"` por jugador → inventario creativo sin vuelo global
- Privilegio `creative` de Luanti solo es relevante para drops de bloques, no para el inventario

---

## ⚠️ El conflicto fly ↔ inventario creativo (pitfall crítico resuelto 30-jun-2026)

Este es el bug más enredado del mundo Valdivia. Cadena de causas:

1. Para tener inventario creativo sin vuelo global, seteamos `creative_mode = false` + metadata `gamemode = "creative"` por jugador.
2. **Pero** `mcl_privs/init.lua` de VoxeLibre tiene su propio `register_on_joinplayer` que hace:
   ```lua
   if meta:get_int("mcl_privs:fly_changed") == 1 then return end
   if minetest.is_creative_enabled(name) then fly = true end  -- ¡otorga fly!
   minetest.set_player_privs(name, player_privs)
   ```
   Como `gamemode = "creative"` hace que `is_creative_enabled()` devuelva `true`, **mcl_privs le otorga `fly` a todos los jugadores en modo creativo** al conectarse.
3. La flag `mcl_privs:fly_changed = 1` desactiva ese auto-grant — pero **solo si se setea ANTES de que corra el callback de mcl_privs**. El orden de los callbacks de join no es garantizado entre mods, así que setear la flag desde otro `register_on_joinplayer` es una carrera que se puede perder.

**Solución robusta** (en `valdivia_newplayer`): imponer el estado deseado con `minetest.after(0)`, que difiere la lógica al siguiente game step — **después** de que todos los callbacks de join síncronos (incluido mcl_privs) terminaron. Así el `set_player_privs` de valdivia_newplayer es siempre el último en escribirse y gana. Además se impone **en cada join** (no solo en jugadores nuevos), lo que lo hace auto-reparable: aunque la DB tenga un `fly` viejo, el próximo join lo limpia.

---

## Cómo se otorgan los privilegios

VoxeLibre **ignora** el setting `default_privs` de `minetest.conf` — no hay que tocarlo para cambiar los privs de nuevos jugadores. La **fuente de verdad** es el mod `valdivia_newplayer`.

### Mod `valdivia_newplayer` (fuente de verdad)

`server/mods/valdivia_newplayer/init.lua` — se carga **solo en Valdivia** (`luanti-valdivia.conf` + `world.mt`).

Impone en **cada join** (vía `register_on_joinplayer` + `minetest.after(0)`):
- metadata `gamemode = "creative"` → inventario creativo por jugador
- metadata `mcl_privs:fly_changed = 1` → desactiva el auto-grant de fly de mcl_privs
- para no-admin: el set exacto de `PRIVS` (sin fly, sin noclip, sin give)
- para `gabo` (admin): no toca los privilegios (conserva todo, incluido fly)

```lua
local ADMIN = "gabo"
local PRIVS = {
    interact = true, shout = true, creative = true,
    fast = true,     spawn = true,  teleport = true,
}

local function enforce_state(name)
    local p = minetest.get_player_by_name(name)
    if not p then return end
    local meta = p:get_meta()
    meta:set_string("gamemode", "creative")
    meta:set_int("mcl_privs:fly_changed", 1)
    if name == ADMIN then return end
    minetest.set_player_privs(name, PRIVS)
end

minetest.register_on_joinplayer(function(player)
    local name = player:get_player_name()
    minetest.after(0, function() enforce_state(name) end)
end)
```

> **Por qué `minetest.after(0)`**: difiere la lógica al siguiente game step, ya después de que corrieron todos los callbacks de join síncronos (engine `default_privs`, mcl_privs auto-grant de fly, etc.). Nuestro `set_player_privs` es el último en escribirse y siempre gana.

> **Por qué en cada join (no solo jugadores nuevos)**: auto-reparación. Si un jugador quedó con `fly` viejo en la DB, el próximo join se lo quita sin intervención manual.

---

## Cambiar los privilegios de los jugadores

Editar `PRIVS` (o `ADMIN`) en `server/mods/valdivia_newplayer/init.lua`. Luego:

```bash
git add -A && git commit -m "..." && git push
ssh gabriel@VPS "cd ~/luanti-voxelibre-server && git pull && docker compose restart luanti-valdivia"
```

Como el estado se impone en cada join, el cambio aplica a **todos** los jugadores (nuevos y existentes) la próxima vez que se conecten. No hace falta SQL manual salvo para casos puntuales (ver abajo).

---

## Modificar privilegios de jugadores existentes

### Ver todos los jugadores y sus privilegios

```bash
sudo sqlite3 server/worlds/valdivia/auth.sqlite \
  'SELECT a.name, group_concat(p.privilege, ", ")
   FROM auth a LEFT JOIN user_privileges p ON a.id = p.id
   GROUP BY a.name ORDER BY a.name;'
```

### Quitar un privilegio a todos excepto gabo

```bash
sudo sqlite3 server/worlds/valdivia/auth.sqlite \
  "DELETE FROM user_privileges
   WHERE privilege = 'fly'
   AND id != (SELECT id FROM auth WHERE name='gabo');"
```

> ⚠️ **Si hay jugadores conectados al hacer el DELETE**: Luanti mantiene los privilegios en memoria y los escribe de vuelta a la DB cuando el jugador se desconecta, pisando el cambio SQL. Para evitarlo, detener el server antes (`docker compose stop luanti-valdivia`), hacer el DELETE, y reiniciar.

### Dar un privilegio a un jugador específico

```bash
sudo sqlite3 server/worlds/valdivia/auth.sqlite \
  "INSERT OR IGNORE INTO user_privileges (id, privilege)
   VALUES ((SELECT id FROM auth WHERE name='nombre'), 'fly');"
```

> **Nota de permisos**: `auth.sqlite` es propiedad de `opc:opc` (el usuario del container). Necesita `sudo` para escribir. Para leer basta con `sqlite3` normal.

> **Nota de seguridad**: estas queries funcionan con el servidor corriendo para lecturas. Para escrituras, es más seguro detener el container primero (`docker compose stop luanti-valdivia`) y reiniciarlo después.

---

## Historial de cambios

| Fecha | Cambio |
|---|---|
| 2026-06-30 | Privs iniciales (mismo set que Wetlands): fly, fast, noclip, give, creative, interact, shout, spawn, teleport |
| 2026-06-30 | Creado `valdivia_newplayer`; quitados fly, noclip, give. Deshabilitado `wetlands_newplayer` en Valdivia |
| 2026-06-30 | Fix: `default_privs` también actualizado para que coincida; `minetest.after(0)` para correr post-engine |
| 2026-06-30 | Fix inventario creativo: VoxeLibre ignora privilegio `creative` con `creative_mode=false`; usar metadata `gamemode=creative` en `register_on_joinplayer` |
| 2026-06-30 | Fix definitivo fly: `mcl_privs` auto-otorgaba fly a jugadores creativos (carrera de callbacks). `valdivia_newplayer` ahora impone privs en cada join con `minetest.after(0)` (gana siempre) + `mcl_privs:fly_changed=1`. Solo `gabo` conserva fly. Auto-reparable. |
