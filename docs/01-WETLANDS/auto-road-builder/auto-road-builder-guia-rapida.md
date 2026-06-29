# 🛣️ Auto Road Builder - Guía Rápida

**Fecha de creación:** 27 de Noviembre, 2025
**Versión del mod:** 1.0.0

## ⚡ Inicio Rápido

### Comando Básico (Lo Más Simple)

Desde tu ubicación actual hasta Expansión Oeste:

```bash
/build_road_here -1770 3 902
```

**¡LISTO!** Carretera de 1700 bloques construida en ~5 segundos ⚡

---

## 🎯 Caso de Uso: Conectar Ciudad Principal con Expansión Oeste

### Situación Actual
- **Estás en:** -124, 30, 73 (Ciudad Principal)
- **Destino:** -1770, 3, 902 (Expansión Oeste)
- **Distancia:** ~1750 bloques
- **Método anterior (WorldEdit):** ~3 horas ❌
- **Método nuevo (Auto Road Builder):** ~5 segundos ✅

### Comando para Ejecutar

```bash
/build_road -124 30 73 -1770 3 902 10 mcl_stairs:slab_concrete_grey
```

**Parámetros:**
- `-124 30 73` - Inicio (donde estás)
- `-1770 3 902` - Fin (Expansión Oeste)
- `10` - Ancho de 10 bloques
- `mcl_stairs:slab_concrete_grey` - Losas de hormigón gris

---

## 📋 Los 3 Comandos Principales

### 1. `/build_road` - Construcción Total

**Uso:** Entre dos puntos específicos

```bash
/build_road <x1> <y1> <z1> <x2> <y2> <z2> [ancho] [material]
```

**Ejemplo:**
```bash
/build_road -77 24 71 -1770 3 902 10 mcl_stairs:slab_concrete_grey
```

---

### 2. `/build_road_here` - Desde Tu Posición

**Uso:** Desde donde estás parado hasta un destino

```bash
/build_road_here <x2> <y2> <z2> [ancho] [material]
```

**Ejemplo:**
```bash
/build_road_here -1770 3 902 10
```

---

### 3. `/road_continue` - Continuar Carretera

**Uso:** Extender la última carretera construida

```bash
/road_continue <distancia> [ancho] [material]
```

**Ejemplo:**
```bash
# Construir primer tramo
/build_road -77 24 71 -277 30 71 10

# Continuar 200 bloques más en la misma dirección
/road_continue 200
```

---

## 🧱 Materiales Recomendados

### Para Carreteras Modernas
```bash
mcl_stairs:slab_concrete_grey    # ✅ RECOMENDADO (por defecto)
mcl_stairs:slab_concrete_white   # Blanco
mcl_stairs:slab_concrete_black   # Negro
```

### Para Caminos Rústicos
```bash
mcl_stairs:slab_stone            # Piedra
mcl_stairs:slab_cobble           # Adoquines
mcl_stairs:slab_stone_smooth     # Piedra lisa
```

### Para Senderos Naturales
```bash
mcl_stairs:slab_wood             # Madera
mcl_stairs:slab_andesite         # Andesita
mcl_stairs:slab_granite          # Granito
```

---

## 📐 Anchos Recomendados

| Tipo | Ancho | Uso |
|------|-------|-----|
| Sendero | 3-5 bloques | Caminar solamente |
| Carretera | 7-10 bloques | Tráfico normal ✅ |
| Autopista | 12-15 bloques | Multi-carril |
| Boulevard | 20+ bloques | Avenidas principales |

---

## 🚀 Flujo de Trabajo Recomendado

### Paso 1: Planificar Ruta
```bash
# Teleportarte al inicio
/teleport gabo -124 30 73

# Teleportarte al destino para verificar
/teleport gabo -1770 3 902

# Anotar coordenadas
```

### Paso 2: Construir Carretera
```bash
# Volver al inicio
/teleport gabo -124 30 73

# Construir
/build_road_here -1770 3 902 10 mcl_stairs:slab_concrete_grey
```

### Paso 3: Verificar
```bash
# Teleportarse a puntos intermedios para revisar
/teleport gabo -500 20 400    # Punto medio
/teleport gabo -1000 15 650   # 3/4 del camino
/teleport gabo -1770 3 902    # Destino final
```

---

## ⚠️ Solución de Problemas

### Error: "Invalid material"
**Problema:** El material no existe
**Solución:** Usa `mcl_stairs:slab_stone` como alternativa

### Error: "Permission denied"
**Problema:** No tienes privilegio `server`
**Solución:** Pide al admin que ejecute:
```bash
/grant gabo server
```

### Carretera aparece en lugar incorrecto
**Problema:** Coordenadas incorrectas
**Solución:** Verifica coordenadas con F5 en el juego

### Carretera muy lenta de construir
**Problema:** Esto NO debería pasar - reporta bug
**Solución temporal:** Construir en segmentos más pequeños

---

## 📊 Comparación de Métodos

| Método | Tiempo | Bloques/seg | Dificultad | Recomendación |
|--------|--------|-------------|------------|---------------|
| **Manual** | 3+ horas | 0.2 | Muy alta | ❌ No usar |
| **WorldEdit** | 30-60 min | 1-2 | Alta | ❌ Muy lento |
| **Auto Road Builder** | 5-10 seg | 500+ | Baja | ✅✅✅ USAR |

---

## 🎓 Ejemplos Prácticos

### Ejemplo 1: Carretera Principal Completa
```bash
/build_road -124 30 73 -1770 3 902 10 mcl_stairs:slab_concrete_grey
```
**Resultado:** 1750 bloques en 5 segundos

---

### Ejemplo 2: Construir por Segmentos (terreno irregular)
```bash
# Segmento 1: Subida del cerro
/build_road -77 24 71 -124 30 73 10 mcl_stairs:slab_concrete_grey

# Segmento 2: Meseta
/build_road -124 30 73 -500 30 400 10 mcl_stairs:slab_concrete_grey

# Segmento 3: Bajada
/build_road -500 30 400 -1770 3 902 10 mcl_stairs:slab_concrete_grey
```

---

### Ejemplo 3: Sendero Rápido entre Casas
```bash
# Sendero estrecho de 5 bloques
/build_road -50 15 80 -150 18 120 5 mcl_stairs:slab_wood
```

---

## 🔥 Tips Pro

### 1. Usar `/build_road_here` para Máxima Rapidez
En lugar de escribir tus coordenadas actuales:
```bash
# ❌ Lento (tienes que anotar dónde estás)
/build_road -124 30 73 -1770 3 902 10

# ✅ Rápido (usa tu posición automáticamente)
/build_road_here -1770 3 902 10
```

### 2. Continuar Carreteras con `/road_continue`
```bash
# Primera sección
/build_road -77 24 71 -177 30 71 10

# Continuar fácilmente
/road_continue 100   # 100 bloques más
/road_continue 150   # 150 bloques más
```

### 3. Probar Materiales con Tramos Cortos
```bash
# Test de 20 bloques para ver cómo se ve
/build_road -100 30 70 -120 30 70 10 mcl_stairs:slab_andesite
```

### 4. Combinar con `/fly` para Inspección
```bash
/fly                              # Activar vuelo
/build_road_here -1770 3 902 10   # Construir
# Volar sobre la carretera para inspeccionar
```

---

## 📦 Instalación (Para Admins)

### Paso 1: Verificar Mod está Instalado
```bash
ls -la server/mods/auto_road_builder/
```

Deberías ver:
- `init.lua`
- `mod.conf`
- `README.md`

### Paso 2: Verificar Configuración
```bash
grep "auto_road_builder" server/config/luanti-original.conf
```

Debe mostrar:
```
load_mod_auto_road_builder = true
```

### Paso 3: Reiniciar Servidor
```bash
docker-compose restart luanti-server
```

### Paso 4: Verificar Carga del Mod
En el chat del juego:
```bash
/help build_road
```

Debe mostrar la ayuda del comando.

---

## 🎯 Próximos Pasos

Ahora que tienes el mod instalado:

1. ✅ **Completa la Carretera Principal**
   ```bash
   /build_road_here -1770 3 902 10
   ```

2. 🏘️ **Conecta las Otras Ciudades**
   - Ciudad Principal → Aldea (57, 33, -3082)
   - Ciudad Principal → Tercera Aldea (888, 13, 90)
   - Ciudad Principal → Refugio Nieve (38, 99, 1695)

3. 🌳 **Añade Decoración**
   - Plantas a los lados de la carretera
   - Carteles indicadores
   - Farolas cada 50 bloques

4. 🗺️ **Documenta en Mapa**
   - Actualizar `ubicaciones-coordenadas.md`
   - Añadir rutas de carreteras

---

**¿Listo para construir?** ¡Ejecuta tu primer comando y disfruta de la construcción automatizada! 🚀
