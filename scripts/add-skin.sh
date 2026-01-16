#!/bin/bash
# Script para agregar skins al servidor Wetlands
# Convierte automáticamente de 64x64 a 64x32 si es necesario

set -euo pipefail

# Colores para output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Directorios
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(dirname "$SCRIPT_DIR")"
TEXTURES_DIR="$PROJECT_ROOT/server/worlds/world/_world_folder_media/textures"
SKINS_CONFIG="$PROJECT_ROOT/server/worlds/world/skins.txt"

# Funciones de utilidad
log_info() {
    echo -e "${BLUE}[INFO]${NC} $1"
}

log_success() {
    echo -e "${GREEN}[✓]${NC} $1"
}

log_warning() {
    echo -e "${YELLOW}[⚠]${NC} $1"
}

log_error() {
    echo -e "${RED}[✗]${NC} $1"
}

# Verificar dependencias
check_dependencies() {
    local missing_deps=()

    if ! command -v identify &> /dev/null; then
        missing_deps+=("imagemagick")
    fi

    if ! command -v convert &> /dev/null; then
        missing_deps+=("imagemagick")
    fi

    if [ ${#missing_deps[@]} -ne 0 ]; then
        log_error "Dependencias faltantes: ${missing_deps[*]}"
        log_info "Instalar con: sudo apt install imagemagick"
        exit 1
    fi
}

# Mostrar ayuda
show_help() {
    cat << EOF
🎨 Wetlands Skin Manager

Uso: $0 <archivo_skin.png> [nombre_limpio] [genero]

Parámetros:
  archivo_skin.png    - Ruta al archivo del skin (puede ser 64x64 o 64x32)
  nombre_limpio       - (Opcional) Nombre simple sin espacios ni guiones
                        Si no se proporciona, se genera automáticamente
  genero              - (Opcional) male o female (por defecto: male)

Ejemplos:
  # Agregar skin zombie con nombre automático
  $0 ~/Downloads/zombie-23794589.png

  # Agregar skin con nombre personalizado
  $0 ~/Downloads/zombie-23794589.png zombie_verde male

  # Agregar skin femenino
  $0 ~/Downloads/veterinaria.png veterinaria female

El script automáticamente:
  ✓ Verifica el tamaño del skin
  ✓ Convierte de 64x64 a 64x32 si es necesario
  ✓ Renombra el archivo a un nombre válido
  ✓ Copia a la carpeta de texturas
  ✓ Actualiza skins.txt

Skins temáticas recomendadas para Wetlands:
  ✅ Cuidadores de animales
  ✅ Veterinarios/as
  ✅ Granjeros veganos
  ✅ Rescatistas de vida silvestre
  ✅ Jardineros y botanistas

EOF
}

# Limpiar nombre de archivo
clean_filename() {
    local filename="$1"
    # Remover extensión
    filename="${filename%.png}"
    # Convertir a minúsculas
    filename=$(echo "$filename" | tr '[:upper:]' '[:lower:]')
    # Reemplazar caracteres especiales con guiones bajos
    filename=$(echo "$filename" | sed 's/[^a-z0-9]/_/g')
    # Remover guiones bajos múltiples
    filename=$(echo "$filename" | sed 's/__*/_/g')
    # Remover guiones bajos al inicio y final
    filename=$(echo "$filename" | sed 's/^_//; s/_$//')
    echo "$filename"
}

# Convertir skin de 64x64 a 64x32
convert_skin() {
    local input_file="$1"
    local output_file="$2"

    log_info "Convirtiendo skin de 64x64 a 64x32..."

    # Usar ImageMagick para copiar solo la mitad superior
    convert "$input_file" -crop 64x32+0+0 +repage "$output_file"

    if [ $? -eq 0 ]; then
        log_success "Conversión exitosa"
    else
        log_error "Error al convertir el skin"
        exit 1
    fi
}

# Agregar entrada a skins.txt
add_to_skins_config() {
    local texture_name="$1"
    local gender="${2:-male}"

    log_info "Actualizando skins.txt..."

    # Verificar si el archivo existe
    if [ ! -f "$SKINS_CONFIG" ]; then
        log_error "Archivo skins.txt no encontrado: $SKINS_CONFIG"
        exit 1
    fi

    # Verificar si la skin ya está registrada
    if grep -q "texture = \"$texture_name\"" "$SKINS_CONFIG"; then
        log_warning "La skin '$texture_name' ya está registrada en skins.txt"
        return 0
    fi

    # Crear backup
    cp "$SKINS_CONFIG" "${SKINS_CONFIG}.backup"

    # Agregar nueva entrada antes del último }
    sed -i '/^}$/i\  {\n    texture = "'"$texture_name"'",\n    gender = "'"$gender"'"\n  },' "$SKINS_CONFIG"

    log_success "Skin '$texture_name' agregada a skins.txt (género: $gender)"
    log_info "Backup guardado en: ${SKINS_CONFIG}.backup"
}

# Función principal
main() {
    # Verificar argumentos
    if [ $# -lt 1 ]; then
        show_help
        exit 1
    fi

    if [ "$1" == "-h" ] || [ "$1" == "--help" ]; then
        show_help
        exit 0
    fi

    # Verificar dependencias
    check_dependencies

    local input_file="$1"
    local clean_name="${2:-}"
    local gender="${3:-male}"

    # Verificar que el archivo existe
    if [ ! -f "$input_file" ]; then
        log_error "Archivo no encontrado: $input_file"
        exit 1
    fi

    # Obtener nombre base del archivo
    local basename=$(basename "$input_file")

    # Limpiar nombre si no se proporciona
    if [ -z "$clean_name" ]; then
        clean_name=$(clean_filename "$basename")
        log_info "Nombre automático generado: $clean_name"
    else
        clean_name=$(clean_filename "$clean_name")
        log_info "Usando nombre limpio: $clean_name"
    fi

    # Validar género
    if [ "$gender" != "male" ] && [ "$gender" != "female" ]; then
        log_error "Género inválido: $gender (debe ser 'male' o 'female')"
        exit 1
    fi

    # Archivo de salida
    local output_file="$TEXTURES_DIR/${clean_name}.png"

    # Verificar dimensiones del skin
    local dimensions=$(identify -format '%wx%h' "$input_file")
    log_info "Dimensiones del skin: $dimensions"

    case "$dimensions" in
        "64x32")
            log_success "El skin ya está en formato correcto (64x32)"
            cp "$input_file" "$output_file"
            ;;
        "64x64")
            log_warning "El skin es 64x64, convirtiendo a 64x32..."
            convert_skin "$input_file" "$output_file"
            ;;
        *)
            log_error "Dimensiones inválidas: $dimensions"
            log_error "Los skins deben ser 64x32 o 64x64"
            exit 1
            ;;
    esac

    # Verificar que el archivo se copió correctamente
    if [ ! -f "$output_file" ]; then
        log_error "Error al copiar el skin a: $output_file"
        exit 1
    fi

    log_success "Skin copiado a: $output_file"

    # Actualizar skins.txt
    add_to_skins_config "$clean_name" "$gender"

    # Resumen
    echo ""
    log_success "✨ Skin agregado exitosamente!"
    echo ""
    echo "📋 Resumen:"
    echo "  • Archivo: $output_file"
    echo "  • Nombre en juego: $clean_name"
    echo "  • Género: $gender"
    echo "  • Dimensiones: 64x32 ✓"
    echo ""
    echo "🚀 Próximos pasos:"
    echo "  1. Revisar skins.txt: $SKINS_CONFIG"
    echo "  2. Reiniciar el servidor: cd $PROJECT_ROOT && docker-compose restart luanti-server"
    echo "  3. En el juego, usar: /skin"
    echo ""
}

# Ejecutar script
main "$@"
