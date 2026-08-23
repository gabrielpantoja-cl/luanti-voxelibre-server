#!/usr/bin/env bash
set -euo pipefail

# The Arnis worldmod is generated outside Git, but this idempotent, versioned
# migration keeps its runtime spawn aligned with the tracked server config.
WORLD_MOD="server/worlds/valdivia/worldmods/arnis_mapgen/init.lua"
OLD_SPAWN='local SPAWN = {x=3766, y=-4, z=-3249}'
NEW_SPAWN='local SPAWN = {x=3669.5, y=-8.5, z=-3055.5}'

if [ ! -f "$WORLD_MOD" ]; then
    echo "ERROR: no se encontró $WORLD_MOD" >&2
    exit 1
fi

if grep -Fq "$NEW_SPAWN" "$WORLD_MOD"; then
    echo "Spawn de Plaza Chile ya está aplicado en $WORLD_MOD"
    exit 0
fi

if ! grep -Fq "$OLD_SPAWN" "$WORLD_MOD"; then
    echo "ERROR: no se encontró el spawn antiguo esperado; no se modifica nada" >&2
    exit 1
fi

BACKUP="${WORLD_MOD}.bak-$(date +%Y%m%d-%H%M%S)"
cp -p "$WORLD_MOD" "$BACKUP"
sed -i "s|$OLD_SPAWN|$NEW_SPAWN|" "$WORLD_MOD"

if ! grep -Fq "$NEW_SPAWN" "$WORLD_MOD"; then
    echo "ERROR: la migración no pudo verificarse; conserva el backup $BACKUP" >&2
    exit 1
fi

echo "Spawn actualizado a Plaza Chile en $WORLD_MOD"
echo "Backup del worldmod: $BACKUP"
