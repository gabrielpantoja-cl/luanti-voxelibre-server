# Proyecto: Merge de Mundos - Wetlands 3.0

## Vision

Unificar el mundo original Wetlands (creativo/educativo) con la ciudad de Valdivia (generada por Arnis desde OpenStreetMap) en un **unico mundo** con un portal de teleport entre ambos. Resultado: un solo servidor, un solo puerto (30000), inventario compartido, experiencia seamless para los jugadores.

## Estado actual

| Mundo | Puerto | Contenido | map.sqlite |
|-------|--------|-----------|------------|
| Wetlands | 30000 | Spawn, NPCs, arenas PvP, construcciones de jugadores | ~VPS produccion |
| Valdivia v4 | 30001 | Ciudad de Valdivia recreada desde OSM (5.8 x 7.7 km) | ~112 MB local |

## Estrategia: Merge SQLite + Portal Teleport

### Concepto

1. Copiar los mapblocks de Valdivia al mundo Wetlands con un **offset de coordenadas** (ej. +20000 en X) para evitar colisiones con lo construido
2. Colocar un **portal de teleport** cerca del spawn de Wetlands que lleve a la ciudad de Valdivia
3. Colocar un **portal de retorno** en Valdivia que lleve de vuelta al spawn
4. Resultado: mundo Wetlands 3.0 todo-en-uno

### Offset propuesto

```
Wetlands original: spawn en (0, 15, 0), construcciones alrededor
Valdivia insertada: offset +20000 en X

Valdivia actual:    X: 0 a 7695,  Y: -64 a 63,  Z: -5792 a -1
Valdivia con offset: X: 20000 a 27695, Y: -64 a 63, Z: -5792 a -1

Distancia spawn -> Valdivia: ~20 km (inalcanzable caminando, solo por portal)
```

## Prerequisitos (antes de ejecutar)

- [ ] Fixlight de Valdivia completado (correccion de iluminacion post-Arnis)
- [ ] Remap de nodos completado (todos los bloques "no texture" corregidos)
- [ ] Texturas verificadas en recorrido completo de Valdivia
- [ ] Backup de ambos mundos de produccion descargados a local
- [ ] Prueba exitosa del merge en entorno local

## Plan de ejecucion

### Fase 1: Preparacion (local)

```bash
# 1. Descargar backup del mundo Wetlands de produccion
scp -i ~/.ssh/id_rsa gabriel@<VPS_IP>:/home/gabriel/luanti-voxelibre-server/server/worlds/world/map.sqlite \
  server/worlds/world/map.sqlite

# 2. Descargar auth.sqlite (jugadores y privilegios)
scp -i ~/.ssh/id_rsa gabriel@<VPS_IP>:/home/gabriel/luanti-voxelibre-server/server/worlds/world/auth.sqlite \
  server/worlds/world/auth.sqlite

# 3. Verificar que Valdivia local ya tiene fixlight + remap aplicados
# (el map.sqlite local en server/worlds/valdivia/map.sqlite)

# 4. Hacer backup de seguridad de ambos
cp server/worlds/world/map.sqlite server/worlds/world/map.sqlite.backup-pre-merge
cp server/worlds/valdivia/map.sqlite server/worlds/valdivia/map.sqlite.backup-pre-merge
```

### Fase 2: Script de merge (crear)

Crear `scripts/merge-worlds.py` que:

1. Abra el map.sqlite de Valdivia (fuente)
2. Abra el map.sqlite de Wetlands (destino)
3. Para cada mapblock en Valdivia:
   - Decodifique la posicion (x, y, z)
   - Aplique el offset (+20000 en X, es decir +1250 mapblocks)
   - Re-encode la posicion
   - Inserte el mapblock en Wetlands
4. Reporte estadisticas

```
Pseudocodigo:

OFFSET_X = 1250  # mapblocks (1250 * 16 = 20000 nodos)

for pos, data in valdivia.blocks:
    x, y, z = decode_pos(pos)
    new_pos = encode_pos(x + OFFSET_X, y, z)
    wetlands.insert(new_pos, data)
```

**Nota:** La posicion de mapblock en Luanti es un int64 codificado:
```python
def decode_pos(pos):
    x = pos % 4096; x = x - 4096 if x > 2047 else x
    r = (pos - x) // 4096
    y = r % 4096; y = y - 4096 if y > 2047 else y
    z = ((r - y) // 4096) % 4096; z = z - 4096 if z > 2047 else z
    return x, y, z

def encode_pos(x, y, z):
    return (z * 4096 + y) * 4096 + x
```

### Fase 3: Portal de teleport (mod)

Crear nodo portal en el mod `wetlands_npcs` o un nuevo mod `wetlands_portal`:

```lua
-- Portal Wetlands -> Valdivia
minetest.register_node("wetlands_portal:valdivia", {
    description = "Portal a Valdivia",
    tiles = {"wetlands_portal_valdivia.png"},
    on_rightclick = function(pos, node, player)
        -- Teleport al centro de Valdivia (con offset)
        -- Coords originales Colegio Planeta Azul: 2389,-55,-2887
        -- Con offset: 22389,-55,-2887
        player:set_pos({x = 22389, y = -50, z = -2887})
        minetest.chat_send_player(player:get_player_name(),
            "Bienvenido a Valdivia!")
    end,
})

-- Portal Valdivia -> Wetlands
minetest.register_node("wetlands_portal:spawn", {
    description = "Portal al Spawn",
    tiles = {"wetlands_portal_spawn.png"},
    on_rightclick = function(pos, node, player)
        player:set_pos({x = 0, y = 15, z = 0})
        minetest.chat_send_player(player:get_player_name(),
            "Bienvenido de vuelta a Wetlands!")
    end,
})
```

### Fase 4: Testing local

```bash
# 1. Ejecutar merge
python3 scripts/merge-worlds.py \
  --source server/worlds/valdivia/map.sqlite \
  --dest server/worlds/world/map.sqlite \
  --offset-x 20000

# 2. Iniciar servidor local con el mundo mergeado
./scripts/start.sh

# 3. Verificar en el juego:
#    - Spawn original funciona normalmente
#    - /teleport 22389,-50,-2887 lleva a Valdivia
#    - NPCs y construcciones de Wetlands intactos
#    - Iluminacion de Valdivia correcta
#    - Portales funcionan en ambas direcciones

# 4. Si algo sale mal, restaurar backup:
cp server/worlds/world/map.sqlite.backup-pre-merge server/worlds/world/map.sqlite
```

### Fase 5: Deploy a produccion

```bash
# 1. Subir mundo mergeado al VPS
scp -i ~/.ssh/id_rsa server/worlds/world/map.sqlite \
  gabriel@<VPS_IP>:/tmp/wetlands_merged.sqlite

# 2. Detener ambos servidores
ssh gabriel@<VPS_IP> \
  "cd /home/gabriel/luanti-voxelibre-server && docker compose down"

# 3. Backup del mundo actual en VPS
ssh gabriel@<VPS_IP> \
  "cp /home/gabriel/luanti-voxelibre-server/server/worlds/world/map.sqlite \
      /home/gabriel/luanti-voxelibre-server/server/worlds/world/map.sqlite.backup-pre-merge-$(date +%Y%m%d)"

# 4. Reemplazar mundo
ssh gabriel@<VPS_IP> \
  "sudo cp /tmp/wetlands_merged.sqlite \
      /home/gabriel/luanti-voxelibre-server/server/worlds/world/map.sqlite && \
   sudo chown 911:911 /home/gabriel/luanti-voxelibre-server/server/worlds/world/map.sqlite"

# 5. Colocar portales en el juego (coordenadas exactas TBD)
# 6. Iniciar solo Wetlands (Valdivia ya no necesita su propio contenedor)
ssh gabriel@<VPS_IP> \
  "cd /home/gabriel/luanti-voxelibre-server && docker compose up -d luanti-server"

# 7. Verificar y anunciar a jugadores
```

## Post-merge

### Cambios en infraestructura
- **docker-compose.yml**: el contenedor `luanti-valdivia` puede deshabilitarse o eliminarse
- **Puerto 30001**: ya no necesario, liberar en firewall
- **luanti-valdivia.conf**: mantener como referencia historica
- **wetlands_fixlight**: ejecutar una vez mas en el mundo mergeado (la zona de Valdivia insertada ya tendra luz corregida, pero verificar bordes)

### Coordenadas de referencia post-merge

Todas las coordenadas de Valdivia suman +20000 en X:

| Lugar | Coords originales | Coords post-merge |
|-------|-------------------|-------------------|
| Spawn Wetlands | 0, 15, 0 | 0, 15, 0 (sin cambio) |
| Colegio Planeta Azul | 2389, -55, -2887 | 22389, -55, -2887 |
| Circunvalacion / San Luis | 5473, -53.5, -3842 | 25473, -53.5, -3842 |
| Casa Gabriel | 5798, -45, -1222 | 25798, -45, -1222 |

### Riesgos y mitigacion

| Riesgo | Mitigacion |
|--------|------------|
| Colision de mapblocks | Offset de 20000 nodos, imposible que colisione |
| Perdida de datos de jugadores | auth.sqlite no se modifica, solo map.sqlite |
| Corrupcion durante merge | Backups pre-merge, testing local completo |
| Performance con mundo mas grande | Luanti carga solo mapblocks cercanos al jugador, no deberia afectar |
| Rollback necesario | Backup en VPS antes de reemplazar |

## Estimacion de complejidad

- **Script merge-worlds.py**: ~80 lineas Python (similar a remap-mineclonia-to-voxelibre.py)
- **Mod portal**: ~50 lineas Lua
- **Testing**: 1-2 horas de verificacion manual en local
- **Deploy**: 30 minutos

## Dependencias

Este proyecto depende de:
1. Completar fixlight de Valdivia (en progreso, ~12 horas)
2. Verificar que no hay mas texturas corruptas en Valdivia
3. Backup actualizado del mundo Wetlands de produccion

---

*Documento creado: 22 marzo 2026*
*Estado: PLANIFICACION - No ejecutar hasta completar prerequisitos*
