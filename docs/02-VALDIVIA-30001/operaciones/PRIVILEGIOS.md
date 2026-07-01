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

**Filosofía**: Valdivia es un mundo de exploración urbana. Sin `fly` y sin `noclip` los jugadores recorren las calles a nivel de suelo, lo que es más inmersivo para una recreación de ciudad real. `fast` compensa el tamaño del mapa (9.5 km de largo).

---

## Cómo se otorgan los privilegios

VoxeLibre **ignora** el setting `default_privs` de `minetest.conf` — no hay que tocarlo para cambiar los privs de nuevos jugadores. El mecanismo real tiene dos capas:

### 1. `default_privs` en `luanti-valdivia.conf` (fallback del engine)

```
default_privs = interact,shout,fast,creative,spawn,teleport
```

Luanti aplica esto al crear la cuenta del jugador. **Debe coincidir** con los privs del mod (ver abajo) para evitar conflictos — si `default_privs` incluye `fly` y el mod intenta quitarlo, el engine lo vuelve a agregar.

### 2. Mod `valdivia_newplayer` (fuente de verdad)

`server/mods/valdivia_newplayer/init.lua` — se carga **solo en Valdivia** (`luanti-valdivia.conf` + `world.mt`).

Usa `minetest.after(0)` para ejecutarse **después** de que el engine aplique `default_privs`, garantizando que el conjunto final de privs sea exactamente el definido en el mod:

```lua
local PRIVS = {
    interact = true, shout = true, creative = true,
    fast = true,     spawn = true,  teleport = true,
}

minetest.register_on_newplayer(function(player)
    local name = player:get_player_name()
    minetest.after(0, function()
        minetest.set_player_privs(name, PRIVS)
    end)
end)
```

> **Por qué `minetest.after(0)`**: el engine aplica `default_privs` al crear la cuenta, y los callbacks de `register_on_newplayer` corren antes de eso. Sin el `after(0)`, el engine sobreescribe lo que el mod pone. Con `after(0)` el mod corre en el siguiente game step, ya después del engine.

---

## Cambiar los privilegios de nuevos jugadores

Editar `PRIVS` en `server/mods/valdivia_newplayer/init.lua` **y** actualizar `default_privs` en `server/config/luanti-valdivia.conf` para que coincidan. Luego:

```bash
git add -A && git commit -m "..." && git push
ssh gabriel@VPS "cd ~/luanti-voxelibre-server && git pull && docker compose restart luanti-valdivia"
```

Los cambios solo aplican a jugadores **nuevos**. Para modificar jugadores existentes, usar SQL (ver sección siguiente).

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
