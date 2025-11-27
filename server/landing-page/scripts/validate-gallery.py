#!/usr/bin/env python3
"""
Script de validacion para gallery-data.json
Verifica que el JSON sea valido y que todas las imagenes existan
"""

import json
import os
import sys
from pathlib import Path
from collections import Counter

# Colores ANSI
RED = '\033[0;31m'
GREEN = '\033[0;32m'
YELLOW = '\033[1;33m'
BLUE = '\033[0;34m'
NC = '\033[0m'  # No Color

def print_color(text, color):
    print(f"{color}{text}{NC}")

def print_success(text):
    print_color(f"✅ {text}", GREEN)

def print_error(text):
    print_color(f"❌ {text}", RED)

def print_warning(text):
    print_color(f"⚠️  {text}", YELLOW)

def print_info(text):
    print_color(f"ℹ️  {text}", BLUE)

def validate_gallery():
    # Paths
    script_dir = Path(__file__).parent
    landing_dir = script_dir.parent
    json_file = landing_dir / 'assets' / 'data' / 'gallery-data.json'
    images_dir = landing_dir / 'assets' / 'images'

    print("🔍 Validando galeria de Wetlands...\n")

    # Verificar que JSON existe
    if not json_file.exists():
        print_error(f"gallery-data.json no encontrado")
        print(f"Ruta esperada: {json_file}")
        return False

    # Cargar y validar JSON
    print("📝 Validando sintaxis JSON...")
    try:
        with open(json_file, 'r', encoding='utf-8') as f:
            data = json.load(f)
        print_success("Sintaxis JSON correcta")
    except json.JSONDecodeError as e:
        print_error(f"JSON mal formado: {e}")
        print("Usa https://jsonlint.com/ para validar el JSON")
        return False

    print()

    # Extraer informacion
    images = data.get('images', [])
    total_images = len(images)
    print(f"📊 Total de imagenes en JSON: {total_images}\n")

    # Verificar que todas las imagenes existen
    print("🖼️  Verificando existencia de imagenes...")
    missing_images = 0
    large_images = []

    for image in images:
        filename = image.get('filename', '')
        image_path = images_dir / filename

        if not image_path.exists():
            print_error(f"Imagen no encontrada: {filename}")
            missing_images += 1
        else:
            # Verificar tamaño
            size_bytes = image_path.stat().st_size
            size_mb = size_bytes / (1024 * 1024)
            size_str = f"{size_mb:.2f}MB" if size_mb >= 1 else f"{size_bytes / 1024:.2f}KB"

            if size_mb > 2:
                print_warning(f"{filename} es grande ({size_str}) - considera optimizar")
                large_images.append((filename, size_str))
            else:
                print_success(f"{filename} ({size_str})")

    print()

    if missing_images > 0:
        print_error(f"{missing_images} imagenes no encontradas")
        return False

    # Verificar duplicados de IDs
    print("🔍 Verificando IDs duplicados...")
    ids = [img.get('id', '') for img in images]
    id_counts = Counter(ids)
    duplicates = [id for id, count in id_counts.items() if count > 1]

    if duplicates:
        print_error(f"IDs duplicados encontrados: {', '.join(duplicates)}")
        return False
    print_success("No hay IDs duplicados")
    print()

    # Verificar prioridades
    print("🔢 Verificando prioridades...")
    priorities = [img.get('priority', 0) for img in images]
    print(f"Prioridades actuales: {sorted(priorities)}")

    priority_counts = Counter(priorities)
    duplicate_priorities = [p for p, count in priority_counts.items() if count > 1]

    if duplicate_priorities:
        print_warning(f"Prioridades duplicadas: {duplicate_priorities}")
        print("Esto puede causar orden inesperado")

    # Verificar que primera imagen tenga featured: true
    sorted_images = sorted(images, key=lambda x: x.get('priority', 999))
    if sorted_images:
        first_image = sorted_images[0]
        if not first_image.get('featured', False):
            print_warning("La imagen con priority 1 no tiene featured: true")

    print()

    # Verificar categorias validas
    print("📂 Verificando categorias...")
    valid_categories = ['updates', 'gameplay', 'community']
    invalid_categories = []

    for image in images:
        category = image.get('category', '')
        if category not in valid_categories:
            invalid_categories.append(category)
            print_error(f"Categoria invalida: {category}")

    if not invalid_categories:
        print_success("Todas las categorias son validas")
    else:
        print_error(f"{len(invalid_categories)} categorias invalidas")
        print(f"Categorias validas: {', '.join(valid_categories)}")
        return False

    print()

    # Verificar campos requeridos
    print("🔎 Verificando campos requeridos...")
    required_fields = ['id', 'filename', 'title', 'emoji', 'description',
                      'date', 'dateLabel', 'category', 'featured', 'priority']

    incomplete_images = []
    for i, image in enumerate(images):
        missing = [field for field in required_fields if field not in image]
        if missing:
            incomplete_images.append((i + 1, image.get('id', 'sin-id'), missing))

    if incomplete_images:
        print_warning("Imagenes con campos faltantes:")
        for idx, img_id, missing in incomplete_images:
            print(f"  Imagen #{idx} ({img_id}): falta {', '.join(missing)}")
    else:
        print_success("Todas las imagenes tienen campos requeridos")

    print()

    # Estadisticas finales
    print("📊 Estadisticas de la galeria:")
    print("━" * 50)

    updates_count = sum(1 for img in images if img.get('category') == 'updates')
    gameplay_count = sum(1 for img in images if img.get('category') == 'gameplay')
    community_count = sum(1 for img in images if img.get('category') == 'community')
    featured_count = sum(1 for img in images if img.get('featured'))
    with_badge = sum(1 for img in images if img.get('badge') is not None)

    print(f"Total imagenes: {total_images}")
    print(f"  - Updates: {updates_count}")
    print(f"  - Gameplay: {gameplay_count}")
    print(f"  - Community: {community_count}")
    print(f"Destacadas: {featured_count}")
    print(f"Con badge: {with_badge}")

    last_updated = data.get('lastUpdated', 'N/A')
    version = data.get('version', 'N/A')
    print(f"Version: {version}")
    print(f"Ultima actualizacion: {last_updated}")

    print("━" * 50)
    print()

    # Warnings finales
    if large_images:
        print_warning(f"{len(large_images)} imagenes grandes detectadas:")
        for filename, size in large_images:
            print(f"  - {filename}: {size}")
        print("Considera optimizar con: convert imagen.png -quality 85 imagen.png")
        print()

    print_success("Validacion completada exitosamente!")
    print()
    print("La galeria esta lista para deployment.")
    print("Ejecuta: ./scripts/deploy-landing.sh")

    return True

if __name__ == '__main__':
    success = validate_gallery()
    sys.exit(0 if success else 1)
