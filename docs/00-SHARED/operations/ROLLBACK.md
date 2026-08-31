# Rollback (registro y reversion de acciones)

Estado al 2026-08-31.

| Mundo | Puerto | `enable_rollback_recording` | `wetlands_rollback_flush` |
|-------|--------|-----------------------------|---------------------------|
| Wetlands (`original`) | 30000 | `true` (desde 2026-06-07) | en config, **inerte hasta el proximo reinicio** |
| Valdivia | 30001 | `false` | no |
| GAELSIN | 30002 | `true` (desde 2026-08-31) | **si** |
| CTF | 30003 | `false` (mapa efimero) | no |
| Mineclonia | 30004 | `false` | no |

## El motor no vuelca a disco solo

Esta es la trampa que hizo inutil el registro de Wetlands entre el 2026-08-11 y
el 2026-08-26. En Luanti 5.16.1 (`src/server/rollback.cpp`):

```cpp
void RollbackManager::addAction(const RollbackAction & action)
{
        action_todisk_buffer.push_back(action);
        action_latest_buffer.push_back(action);

        // Flush to disk sometimes
        if (action_todisk_buffer.size() >= 500) {
                flush();
        }
        ...
}
```

`flush()` es lo unico que escribe en `rollback.sqlite`, y solo se llama:

1. cuando el buffer en RAM llega a **500 acciones**;
2. desde `getNodeActors()` / `getRevertActions()`, es decir cuando alguien
   ejecuta `/rollback_check` o `/rollback`;
3. desde el destructor `~RollbackManager()`, o sea en un **apagado limpio**.

**No hay ningun temporizador.** Si el proceso muere sin ejecutar el destructor
—`docker stop` agota su plazo por defecto de 10 s en un mundo grande y Docker
manda `SIGKILL`— se pierden hasta 499 acciones **sin un solo error en el log**.
Ese es el peor modo de fallo posible: un registro que parece activo y no lo es.

`server/mods/wetlands_rollback_flush/` cierra el agujero: cada 60 s llama a
`core.rollback_get_node_actions()` con una consulta minima, que internamente
hace `flush()`. Tambien expone `/rollback_flush` (priv `server`) para forzarlo
en el acto, util al verificar.

**Regla:** activar `enable_rollback_recording = true` sin cargar
`wetlands_rollback_flush` da un registro que falla en silencio. Van juntos.

## Privilegios

- `/rollback_check` y `/rollback` exigen **ambos** el privilegio `rollback`
  (`builtin/game/chat.lua`). **`rollback_check` no es un privilegio**; ponerlo
  en una lista de privs no otorga nada.
- `admin_privs` **no es una opcion de Luanti** (no aparece en
  `builtin/settingtypes.txt`). Las lineas `admin_privs = ...` de los `.conf` de
  este repo son documentacion, no configuracion. Quien recibe todos los
  privilegios es el jugador nombrado en `name = ` (`builtin/game/auth.lua`,
  rama "For the admin, give everything").
- Ambos comandos comprueban `enable_rollback_recording` en tiempo de ejecucion
  y responden "Rollback functions are disabled." si esta en `false`.

## Verificar que graba de verdad

No basta con que exista el archivo. En el juego, con el admin conectado:

```
/rollback_flush                 # fuerza el volcado del buffer
```

Y en el VPS:

```bash
DB=/home/gabriel/luanti-voxelibre-server/server/worlds/gaelsin/rollback.sqlite
sudo sqlite3 "$DB" "SELECT COUNT(*) FROM action;"
sudo sqlite3 "$DB" "
  SELECT datetime(a.timestamp,'unixepoch','localtime') t, ac.name, a.type,
         n1.name AS antes, n2.name AS despues
  FROM action a
  LEFT JOIN actor ac ON ac.id = a.actor
  LEFT JOIN node n1 ON n1.id = a.oldNode
  LEFT JOIN node n2 ON n2.id = a.newNode
  ORDER BY a.id DESC LIMIT 10;"
```

`type = 1` es `TYPE_SET_NODE` (romper/poner bloque). `type = 2` es
`TYPE_MODIFY_INVENTORY_STACK` (mover items dentro o fuera de un cofre) — este
es el que importa para investigar robos.

Sin flush forzado, una prueba de un solo bloque **no aparece** en la base
aunque el registro funcione: sigue en el buffer. Un conteo en cero justo
despues de romper un bloque no prueba nada.

## Retencion

Luanti nunca limpia esta base (`settingtypes.txt`: *"Luanti will not
automatically clean old entries from the rollback database"*).

Medicion real de Wetlands: **21 944 acciones = 2,2 MB en 44 dias** de actividad
baja, es decir ~100 bytes por accion y ~50 KB/dia. GAELSIN acumula del orden de
6,5x mas horas jugadas, asi que la estimacion es **~325 KB/dia ≈ 30 MB en 90
dias ≈ 120 MB/ano**.

**Retencion elegida: 90 dias.** El saqueo del 2026-08-28 se detecto a los pocos
dias; 90 dias cubre con holgura una ausencia larga (vacaciones, un mes sin
revisar el servidor) y aun asi el archivo se queda en ~30 MB, despreciable
frente a los 132 GB libres del VPS. Retenciones mas cortas ahorran un espacio
que no hace falta y arriesgan perder la evidencia de un robo antiguo.

**Umbral de alerta: 200 MB** (unas 2 000 000 de acciones). Por encima de eso
conviene bajar la retencion a 30 dias.

Poda:

```bash
./scripts/prune-rollback.sh gaelsin 90 --dry-run   # ver que borraria
./scripts/prune-rollback.sh gaelsin 90
```

El script **detiene el contenedor** antes de tocar la base. No es prudencia
excesiva: `RollbackManager::flush()` hace `BEGIN` + `INSERT` sin manejar
`SQLITE_BUSY`, y la macro `SQLRES` lanza `FileNotGoodException` ante cualquier
resultado inesperado. Podar en caliente puede tumbar el servidor. Detenerlo
ademas dispara el destructor, que vuelca el buffer: no se pierde nada.

Cron mensual sugerido en el **host** (no en el sidecar `backup-cron`, que no
tiene el socket de Docker):

```cron
0 5 1 * * /home/gabriel/luanti-voxelibre-server/scripts/prune-rollback.sh gaelsin 90 >> /home/gabriel/rollback-prune.log 2>&1
```

## Lo que rollback NO resuelve

Rollback es forense y correctivo: sirve para saber quien se llevo que y para
revertirlo. **No impide el robo.** Mientras `disallow_empty_password` siga en
`false` y las bases del spawn no esten protegidas, el resultado sera un
registro muy detallado de robos que se repiten. Ver `ROADMAP.md` de GAELSIN.
