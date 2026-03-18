#!/bin/bash
# ============================================
# SCRIPT DE SINCRONIZACIÓN VPS → LOCAL 🔄
# ============================================
# Sincroniza cambios del VPS de producción al repositorio local
# Uso: ./scripts/sync-from-vps.sh [--dry-run]

set -e

# Configuración
VPS_USER="gabriel"
VPS_HOST="${VPS_HOST}"
VPS_PATH="/home/gabriel/luanti-voxelibre-server"
TMP_DIR="/tmp/vps-sync-$(date +%s)"
DRY_RUN=false

# Colores para output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Parsear argumentos
if [[ "$1" == "--dry-run" ]]; then
    DRY_RUN=true
    echo -e "${YELLOW}🔍 Modo dry-run activado - no se aplicarán cambios${NC}"
fi

# Banner
echo -e "${BLUE}╔══════════════════════════════════════════════╗${NC}"
echo -e "${BLUE}║   🔄 VPS → Local Sync - Vegan Wetlands 🌱   ║${NC}"
echo -e "${BLUE}╚══════════════════════════════════════════════╝${NC}"
echo ""

# Función: Verificar SSH conectividad
check_ssh() {
    echo -e "${BLUE}[1/6]${NC} Verificando conectividad SSH al VPS..."
    if ssh -q "$VPS_USER@$VPS_HOST" exit; then
        echo -e "${GREEN}✅ Conectado a VPS${NC}"
    else
        echo -e "${RED}❌ ERROR: No se puede conectar al VPS${NC}"
        exit 1
    fi
}

# Función: Verificar cambios en VPS
check_vps_drift() {
    echo -e "${BLUE}[2/6]${NC} Verificando si hay cambios en el VPS..."

    VPS_STATUS=$(ssh "$VPS_USER@$VPS_HOST" "cd $VPS_PATH && git status --porcelain")

    if [[ -z "$VPS_STATUS" ]]; then
        echo -e "${GREEN}✅ VPS sin cambios - repositorio limpio${NC}"
        echo -e "${YELLOW}No hay nada que sincronizar.${NC}"
        exit 0
    else
        echo -e "${YELLOW}⚠️  Cambios detectados en VPS:${NC}"
        echo "$VPS_STATUS" | while read line; do
            echo -e "   ${YELLOW}→${NC} $line"
        done
    fi
}

# Función: Crear directorio temporal
create_temp_dir() {
    echo -e "${BLUE}[3/6]${NC} Creando directorio temporal..."
    mkdir -p "$TMP_DIR"
    echo -e "${GREEN}✅ Directorio temporal: $TMP_DIR${NC}"
}

# Función: Descargar archivos modificados
download_modified_files() {
    echo -e "${BLUE}[4/6]${NC} Descargando archivos modificados del VPS..."

    # Obtener lista de archivos modificados
    MODIFIED_FILES=$(ssh "$VPS_USER@$VPS_HOST" "cd $VPS_PATH && git status --porcelain | awk '{print \$2}'")

    # Descargar cada archivo
    echo "$MODIFIED_FILES" | while read file; do
        if [[ -n "$file" ]]; then
            echo -e "   ${BLUE}→${NC} Descargando: $file"

            # Crear directorio padre si no existe
            mkdir -p "$TMP_DIR/$(dirname "$file")"

            # Descargar archivo
            scp -q "$VPS_USER@$VPS_HOST:$VPS_PATH/$file" "$TMP_DIR/$file" 2>/dev/null || {
                echo -e "   ${RED}✗${NC} Error descargando $file"
            }
        fi
    done

    echo -e "${GREEN}✅ Archivos descargados${NC}"
}

# Función: Comparar archivos
compare_files() {
    echo -e "${BLUE}[5/6]${NC} Comparando archivos VPS vs Local..."
    echo ""

    CHANGES_FOUND=false

    for vps_file in $(find "$TMP_DIR" -type f); do
        # Obtener ruta relativa
        rel_path="${vps_file#$TMP_DIR/}"
        local_file="$rel_path"

        if [[ -f "$local_file" ]]; then
            # Comparar archivos
            if ! diff -q "$local_file" "$vps_file" > /dev/null 2>&1; then
                CHANGES_FOUND=true
                echo -e "${YELLOW}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
                echo -e "${YELLOW}📄 Archivo: $rel_path${NC}"
                echo -e "${YELLOW}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
                diff -u "$local_file" "$vps_file" || true
                echo ""
            fi
        else
            CHANGES_FOUND=true
            echo -e "${GREEN}📄 Archivo nuevo: $rel_path${NC}"
        fi
    done

    if [[ "$CHANGES_FOUND" == false ]]; then
        echo -e "${GREEN}✅ No hay diferencias entre VPS y local${NC}"
        cleanup
        exit 0
    fi
}

# Función: Aplicar cambios
apply_changes() {
    echo -e "${BLUE}[6/6]${NC} Aplicando cambios al repositorio local..."

    if [[ "$DRY_RUN" == true ]]; then
        echo -e "${YELLOW}⚠️  Dry-run mode - no se aplicarán cambios${NC}"
        cleanup
        exit 0
    fi

    # Confirmar antes de aplicar
    echo -e "${YELLOW}¿Aplicar estos cambios al repositorio local? [y/N]${NC}"
    read -r response

    if [[ "$response" =~ ^[Yy]$ ]]; then
        # Copiar archivos
        for vps_file in $(find "$TMP_DIR" -type f); do
            rel_path="${vps_file#$TMP_DIR/}"
            echo -e "   ${BLUE}→${NC} Aplicando: $rel_path"
            cp "$vps_file" "$rel_path"
        done

        echo -e "${GREEN}✅ Cambios aplicados${NC}"
        echo ""
        echo -e "${BLUE}Siguiente paso:${NC}"
        echo -e "   1. Revisar cambios: ${YELLOW}git diff${NC}"
        echo -e "   2. Crear commit: ${YELLOW}git add . && git commit${NC}"
        echo -e "   3. Push a GitHub: ${YELLOW}git push origin main${NC}"
    else
        echo -e "${YELLOW}⚠️  Cambios no aplicados - abortado por usuario${NC}"
    fi
}

# Función: Limpiar archivos temporales
cleanup() {
    echo -e "${BLUE}Limpiando archivos temporales...${NC}"
    rm -rf "$TMP_DIR"
    echo -e "${GREEN}✅ Limpieza completada${NC}"
}

# Trap para limpiar en caso de error
trap cleanup EXIT

# Ejecutar workflow
main() {
    check_ssh
    check_vps_drift
    create_temp_dir
    download_modified_files
    compare_files
    apply_changes
}

# Ejecutar script
main

echo ""
echo -e "${GREEN}╔══════════════════════════════════════════════╗${NC}"
echo -e "${GREEN}║           ✅ Sincronización completa          ║${NC}"
echo -e "${GREEN}╚══════════════════════════════════════════════╝${NC}"
