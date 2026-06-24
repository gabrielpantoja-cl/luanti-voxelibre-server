#!/bin/bash
# =============================================
# SETUP GAELSIN WORLD - Mundo nuevo desde seed
# =============================================
# Crea el directorio del mundo GAELSIN (puerto 30002) con un world.mt fresco.
# NO clona ningun mundo: VoxeLibre genera el mapa al primer arranque usando
# fixed_map_seed = GAELSIN (mapgen v7) definido en luanti-gaelsin.conf.
#
# Uso (ejecutar EN EL VPS, como gabriel con sudo):
#   sudo ./scripts/setup-gaelsin-world.sh
#
# Idempotente: si gaelsin/ ya existe, aborta para no sobreescribir.

set -euo pipefail

REPO_ROOT="/home/gabriel/luanti-voxelibre-server"
DST_WORLD="${REPO_ROOT}/server/worlds/gaelsin"
CONTAINER_UID=1000

# Verificaciones previas
if [ "$EUID" -ne 0 ]; then
    echo "ERROR: Este script requiere sudo (necesita escribir en server/worlds/)."
    exit 1
fi

if [ -d "${DST_WORLD}" ]; then
    echo "ERROR: ${DST_WORLD} ya existe."
    echo "Si quieres regenerarlo desde cero, primero ejecuta:"
    echo "  sudo ./scripts/reset-gaelsin.sh"
    exit 1
fi

echo ">>> Creando ${DST_WORLD}"
mkdir -p "${DST_WORLD}"

# world.mt especifico para GAELSIN (gate primario de mods - debe coincidir con
# el set minimo de luanti-gaelsin.conf). El mapa se genera desde el seed.
echo ">>> Escribiendo world.mt (supervivencia, set minimo de mods)"
cat > "${DST_WORLD}/world.mt" <<'EOF'
enable_damage = true
enable_pvp = true
enable_fire = true
enable_tnt = true
creative_mode = false
mod_storage_backend = sqlite3
auth_backend = sqlite3
player_backend = sqlite3
backend = sqlite3
gameid = mineclone2
world_name = gaelsin

# === Mods - set minimo (supervivencia + admin) ===
load_mod_wetlands_gaelsin_newplayer = true
load_mod_server_rules = true
load_mod_wetlands_lastpos = true
load_mod_mcl_potions_hotfix = true

# Creepers bloqueados
load_mod_wetlands_no_creeper = true

# Skins
load_mod__world_folder_media = true
load_mod_mcl_custom_world_skins = true

# WorldEdit (admin)
load_mod_worldedit = true
load_mod_worldedit_commands = true
load_mod_worldedit_shortcommands = true
EOF

# Permisos para el container (UID 1000)
echo ">>> Ajustando permisos (chown ${CONTAINER_UID}:${CONTAINER_UID})"
chown -R ${CONTAINER_UID}:${CONTAINER_UID} "${DST_WORLD}"

# Resumen
echo ""
echo "=============================================="
echo "GAELSIN listo en ${DST_WORLD}"
echo "=============================================="
echo "El mapa se generara desde seed=GAELSIN (v7) al primer arranque."
echo ""
echo "Siguiente paso (en el VPS, usuario gabriel):"
echo "  cd ${REPO_ROOT}"
echo "  docker compose up -d luanti-gaelsin discord-notifier-gaelsin"
echo ""
echo "Si UDP 30002 no estuviera abierto en Oracle Cloud security list e iptables host:"
echo "  sudo iptables -I INPUT -p udp --dport 30002 -j ACCEPT"
echo "  sudo netfilter-persistent save  # o equivalente segun distro"
