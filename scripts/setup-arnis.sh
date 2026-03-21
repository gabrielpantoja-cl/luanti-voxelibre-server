#!/bin/bash
# =============================================
# SETUP ARNIS - Generador de ciudades reales
# =============================================
# Instala Rust y compila Arnis con soporte Luanti (PR #808)
# Ejecutar en PC local (x86_64), NO en VPS ARM

set -e

ARNIS_DIR="$HOME/arnis"
SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
PROJECT_DIR="$(dirname "$SCRIPT_DIR")"

echo "=== Setup Arnis - Generador de ciudades reales ==="
echo ""

# Verificar arquitectura
ARCH=$(uname -m)
if [ "$ARCH" != "x86_64" ]; then
    echo "ADVERTENCIA: Arnis esta optimizado para x86_64. Tu arquitectura es $ARCH."
    echo "La compilacion puede funcionar pero no esta garantizada."
    read -p "Continuar? (s/n): " -n 1 -r
    echo
    if [[ ! $REPLY =~ ^[Ss]$ ]]; then
        exit 1
    fi
fi

# Paso 1: Instalar Rust si no existe
if ! command -v rustc &>/dev/null; then
    echo "[1/4] Instalando Rust..."
    curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh -s -- -y
    source "$HOME/.cargo/env"
    echo "Rust instalado: $(rustc --version)"
else
    echo "[1/4] Rust ya instalado: $(rustc --version)"
fi

# Paso 2: Clonar Arnis
if [ -d "$ARNIS_DIR" ]; then
    echo "[2/4] Arnis ya existe en $ARNIS_DIR, actualizando..."
    cd "$ARNIS_DIR"
    git fetch origin
else
    echo "[2/4] Clonando Arnis..."
    git clone https://github.com/louis-e/arnis "$ARNIS_DIR"
    cd "$ARNIS_DIR"
fi

# Paso 3: Intentar usar soporte Luanti nativo
echo "[3/4] Verificando soporte Luanti..."

# Verificar si PR #808 ya fue mergeado en main
if git log --oneline main 2>/dev/null | grep -qi "luanti"; then
    echo "Soporte Luanti detectado en main!"
    git checkout main
    git pull origin main
else
    # Intentar checkout del branch del PR #808
    echo "Intentando branch del PR #808 (soporte Luanti)..."
    if git fetch origin pull/808/head:luanti-support 2>/dev/null; then
        git checkout luanti-support
        echo "Branch luanti-support listo."
    else
        echo "PR #808 no disponible. Usando main (generara formato Minecraft)."
        echo "Necesitaras MC2MT para convertir despues."
        git checkout main
        git pull origin main
    fi
fi

# Paso 4: Compilar
echo "[4/4] Compilando Arnis (esto puede tardar unos minutos)..."
cargo build --release

echo ""
echo "=== Arnis compilado exitosamente ==="
echo "Binario: $ARNIS_DIR/target/release/arnis"
echo ""
echo "Para generar el MVP de Valdivia:"
echo "  $ARNIS_DIR/target/release/arnis \\"
echo "    --luanti \\"
echo "    --luanti-game mineclonia \\"
echo "    --terrain \\"
echo '    --bbox="-39.825,-73.255,-39.810,-73.235"'
echo ""
echo "Si --luanti no esta disponible (PR no mergeado), usa formato Minecraft:"
echo "  $ARNIS_DIR/target/release/arnis \\"
echo "    --terrain \\"
echo '    --path="/tmp/valdivia-mc/saves/valdivia" \\'
echo '    --bbox="-39.825,-73.255,-39.810,-73.235"'
