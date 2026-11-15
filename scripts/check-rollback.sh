#!/usr/bin/env bash
# ============================================
# VERIFICACION DEL REGISTRO DE ROLLBACK
# ============================================
# Comprueba que rollback.sqlite de un mundo existe y esta recibiendo acciones
# de verdad, separando los dos tipos que importan:
#   type 1 = TYPE_SET_NODE                 -> romper / poner bloques
#   type 2 = TYPE_MODIFY_INVENTORY_STACK   -> mover items dentro/fuera de cofres
#
# OJO: el motor solo escribe a disco cada 500 acciones, al ejecutar
# /rollback_check o /rollback, o en apagado limpio (que en estos contenedores
# nunca ocurre: docker stop siempre acaba en SIGKILL). Con el mod
# wetlands_rollback_flush cargado el volcado es cada 60 s; si quieres el
# resultado en el acto, ejecuta /rollback_flush en el juego antes de correr
# este script.
#
# USO: ./scripts/check-rollback.sh [mundo]     (por defecto: gaelsin)

set -euo pipefail

WORLD="${1:-gaelsin}"
REPO_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
DB="$REPO_DIR/server/worlds/$WORLD/rollback.sqlite"

case "$WORLD" in
    original)   CONTAINER="luanti-voxelibre-server" ;;
    valdivia)   CONTAINER="luanti-valdivia-server" ;;
    gaelsin)    CONTAINER="luanti-gaelsin-server" ;;
    ctf)        CONTAINER="luanti-ctf-server" ;;
    mineclonia) CONTAINER="luanti-mineclonia-server" ;;
    *) echo "ERROR: mundo desconocido '$WORLD'" >&2; exit 1 ;;
esac

echo "== Mundo: $WORLD ($CONTAINER) =="

echo
echo "-- 1. enable_rollback_recording en el config que lee el proceso --"
docker exec "$CONTAINER" grep -n 'enable_rollback_recording' \
    /config/.minetest/main-config/minetest.conf || echo "  NO DEFINIDO (por defecto: false)"

echo
echo "-- 2. mod de volcado cargado --"
docker logs "$CONTAINER" 2>&1 | grep 'wetlands_rollback_flush' | tail -2 \
    || echo "  AVISO: wetlands_rollback_flush no aparece en el log"

echo
echo "-- 3. rollback.sqlite --"
if ! sudo test -f "$DB"; then
    echo "  NO EXISTE $DB -> el registro NO esta activo"
    exit 1
fi
sudo ls -la "$DB"

echo
echo "-- 4. acciones registradas por tipo --"
sudo sqlite3 -header -column "$DB" "
  SELECT CASE type
           WHEN 1 THEN '1 = bloques (dig/place)'
           WHEN 2 THEN '2 = inventario (cofres)'
           ELSE 'type ' || type END AS tipo,
         COUNT(*) AS total,
         datetime(MIN(timestamp),'unixepoch','localtime') AS primera,
         datetime(MAX(timestamp),'unixepoch','localtime') AS ultima
  FROM action GROUP BY type;"

TOTAL=$(sudo sqlite3 "$DB" "SELECT COUNT(*) FROM action;")
INV=$(sudo sqlite3 "$DB" "SELECT COUNT(*) FROM action WHERE type = 2;")

echo
echo "-- 5. ultimas 15 acciones --"
sudo sqlite3 -header -column "$DB" "
  SELECT datetime(a.timestamp,'unixepoch','localtime') AS hora,
         ac.name AS actor, a.type AS t,
         a.x || ',' || a.y || ',' || a.z AS pos,
         COALESCE(n1.name,'') AS antes, COALESCE(n2.name,'') AS despues,
         COALESCE(ns.name,'') AS item, COALESCE(a.stackQuantity,'') AS cant
  FROM action a
  LEFT JOIN actor ac ON ac.id = a.actor
  LEFT JOIN node n1 ON n1.id = a.oldNode
  LEFT JOIN node n2 ON n2.id = a.newNode
  LEFT JOIN node ns ON ns.id = a.stackNode
  ORDER BY a.id DESC LIMIT 15;"

echo
echo "-- Resumen --"
echo "  Total acciones:            $TOTAL"
echo "  Acciones de inventario:    $INV"
if [ "$TOTAL" -eq 0 ]; then
    echo "  VEREDICTO: sin datos. Si acabas de jugar, ejecuta /rollback_flush"
    echo "             en el juego y vuelve a correr este script."
elif [ "$INV" -eq 0 ]; then
    echo "  VEREDICTO: se registran bloques pero NINGUNA accion de inventario."
    echo "             El caso del saqueo de cofres NO esta cubierto."
else
    echo "  VEREDICTO: OK, se registran bloques e inventario."
fi
