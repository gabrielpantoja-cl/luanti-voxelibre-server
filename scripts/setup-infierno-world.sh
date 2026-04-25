#!/bin/bash
# =============================================
# SETUP INFIERNO WORLD - Hot-clone de Wetlands
# =============================================
# Copia el mundo principal (puerto 30000) a un nuevo directorio para el
# servidor INFIERNO (puerto 30002). Usa sqlite3 .backup para snapshot en
# vivo de las DBs sin tener que detener el contenedor principal.
#
# Uso (ejecutar EN EL VPS, como gabriel con sudo):
#   sudo ./scripts/setup-infierno-world.sh
#
# Idempotente: si infierno/ ya existe, aborta para no sobreescribir.

set -euo pipefail

REPO_ROOT="/home/gabriel/luanti-voxelibre-server"
SRC_WORLD="${REPO_ROOT}/server/worlds/world"
DST_WORLD="${REPO_ROOT}/server/worlds/infierno"
CONTAINER_UID=1000

# Verificaciones previas
if [ "$EUID" -ne 0 ]; then
    echo "ERROR: Este script requiere sudo (necesita escribir en server/worlds/)."
    exit 1
fi

if [ -d "${DST_WORLD}" ]; then
    echo "ERROR: ${DST_WORLD} ya existe."
    echo "Si quieres regenerarlo desde cero, primero ejecuta:"
    echo "  sudo ./scripts/reset-infierno.sh"
    exit 1
fi

if [ ! -d "${SRC_WORLD}" ]; then
    echo "ERROR: mundo origen ${SRC_WORLD} no encontrado."
    exit 1
fi

if ! command -v sqlite3 >/dev/null 2>&1; then
    echo "ERROR: sqlite3 no instalado. Instalar con: sudo apt install sqlite3"
    exit 1
fi

echo ">>> Creando ${DST_WORLD}"
mkdir -p "${DST_WORLD}"

# Hot-copy de DBs sqlite via online backup (no requiere parar el server)
SQLITE_DBS=(
    map.sqlite
    auth.sqlite
    players.sqlite
    mod_storage.sqlite
    player_metadata.sqlite
    world.sqlite
)

for db in "${SQLITE_DBS[@]}"; do
    if [ -f "${SRC_WORLD}/${db}" ]; then
        echo ">>> Hot-copy ${db}..."
        sqlite3 "${SRC_WORLD}/${db}" ".backup '${DST_WORLD}/${db}'"
    fi
done

# Copia archivos de texto/metadatos
TEXT_FILES=(
    env_meta.txt
    map_meta.txt
    force_loaded.txt
    awards.txt
    doc.mt
    server_commands.txt
    skins.txt
)

for f in "${TEXT_FILES[@]}"; do
    if [ -f "${SRC_WORLD}/${f}" ]; then
        cp "${SRC_WORLD}/${f}" "${DST_WORLD}/${f}"
    fi
done

# Carpetas auxiliares (skins, mapas in-game, mesecons)
SUBDIRS=(
    _world_folder_media
    mcl_maps
    mesecon_actionqueue
)

for d in "${SUBDIRS[@]}"; do
    if [ -d "${SRC_WORLD}/${d}" ]; then
        echo ">>> Copia carpeta ${d}/..."
        cp -r "${SRC_WORLD}/${d}" "${DST_WORLD}/${d}"
    fi
done

# NO copiamos: ipban.txt (start fresh), pvp_arenas.txt (no arenas en infierno),
# *.backup.* (innecesarios). world.mt se escribe a continuacion.

# world.mt especifico para infierno
echo ">>> Escribiendo world.mt (chaos config)"
cat > "${DST_WORLD}/world.mt" <<'EOF'
enable_damage = true
enable_pvp = true
enable_fire = true
enable_tnt = true
creative_mode = true
mod_storage_backend = sqlite3
auth_backend = sqlite3
player_backend = sqlite3
backend = sqlite3
gameid = mineclone2
world_name = infierno

# === Mods - mismo set que Wetlands con overrides de chaos ===
load_mod_wetlands_newplayer = true
load_mod_server_rules = true
load_mod_mcl_back_to_spawn = true

# NPCs/decoracion (heredados del snapshot)
load_mod_wetlands_npcs = true
load_mod_wetlands_music = true
load_mod_mypark = true

# CHAOS overrides
load_mod_wetlands_no_creeper = false
load_mod_pvp_arena = false
load_mod_voxelibre_protection = false

# Skins
load_mod__world_folder_media = true
load_mod_mcl_custom_world_skins = true

# Vehiculos
load_mod_automobiles_lib = true
load_mod_automobiles_vespa = true
load_mod_automobiles_beetle = true
load_mod_automobiles_motorcycle = true
load_mod_automobiles_buggy = true

# WorldEdit (admin)
load_mod_worldedit = true
load_mod_worldedit_commands = true
load_mod_worldedit_shortcommands = true

# Halloween + extras
load_mod_halloween_ghost = true
load_mod_halloween_zombies = true
load_mod_broom_racing = true
load_mod_celevator = true
load_mod_chess = true
load_mod_voxelibre_tv = true
load_mod_auto_road_builder = true

# CTF GUNS - el sentido del infierno
load_mod_controls = true
load_mod_ctf_core = true
load_mod_rawf = true
load_mod_grenades = true
load_mod_ctf_ranged = true
EOF

# Permisos para el container (UID 1000)
echo ">>> Ajustando permisos (chown ${CONTAINER_UID}:${CONTAINER_UID})"
chown -R ${CONTAINER_UID}:${CONTAINER_UID} "${DST_WORLD}"

# Resumen
echo ""
echo "=============================================="
echo "INFIERNO listo en ${DST_WORLD}"
echo "=============================================="
du -sh "${DST_WORLD}"
echo ""
echo "Siguiente paso (en el VPS, usuario gabriel):"
echo "  cd ${REPO_ROOT}"
echo "  docker compose up -d luanti-infierno discord-notifier-infierno"
echo ""
echo "Despues abrir UDP 30002 en Oracle Cloud security list e iptables host:"
echo "  sudo iptables -I INPUT -p udp --dport 30002 -j ACCEPT"
echo "  sudo netfilter-persistent save  # o equivalente segun distro"
