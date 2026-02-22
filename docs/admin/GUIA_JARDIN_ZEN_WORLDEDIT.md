# Guia: Jardin Zen Japones con WorldEdit

Instrucciones paso a paso para construir un jardin zen japones en la zona ex-Halloween usando WorldEdit.

**Requisitos:** Privilegios `worldedit` y modo creativo activo.

**Tip general:** Usa `//1` (golpe izq.) y `//2` (golpe der.) para marcar esquinas de seleccion. Siempre verifica tu seleccion con `//mark` antes de ejecutar.

---

## Paso 1: Limpieza de la zona

La zona esta quemada y con crateres de TNT. Hay que limpiar todo primero.

### 1.1 Apagar fuego
```
//1  (esquina inferior de toda la zona)
//2  (esquina superior, incluyendo altura del fuego)
//replace fire:basic_flame air
//replace fire:permanent_flame air
```

### 1.2 Quitar bloques rotos y escombros
```
//replace mcl_core:cobble air
//replace mcl_core:gravel air
//replace mcl_nether:netherrack air
```

### 1.3 Rellenar crateres
Selecciona la zona de crateres (desde nivel del suelo hacia abajo):
```
//1  (esquina del crater, nivel suelo)
//2  (esquina opuesta, fondo del crater)
//set mcl_core:dirt
```

---

## Paso 2: Terreno base - Nivelar con pasto

Crea una superficie plana de pasto para todo el jardin.

### 2.1 Capa superior de pasto
Selecciona toda el area del jardin, 1 bloque de alto al nivel deseado:
```
//1  (esquina A, nivel del suelo)
//2  (esquina B, mismo nivel Y)
//set mcl_core:dirt_with_grass
```

### 2.2 Relleno de tierra debajo
Si hay huecos debajo del pasto, selecciona desde 1 bloque abajo hasta la profundidad necesaria:
```
//1  (esquina A, 1 bloque bajo el pasto)
//2  (esquina B, 4-5 bloques bajo el pasto)
//set mcl_core:dirt
```

---

## Paso 3: Estanque de agua

Un estanque rectangular en el centro del jardin.

### 3.1 Excavar el estanque
Marca el area del estanque (ej: 12x8 bloques, 3 de profundidad):
```
//1  (esquina del estanque, nivel del suelo)
//2  (esquina opuesta, 3 bloques hacia abajo)
//set air
```

### 3.2 Piso del estanque
Selecciona solo el fondo (1 bloque de alto, el mas profundo):
```
//1  (esquina fondo)
//2  (esquina opuesta fondo, misma Y)
//set mcl_core:stone_smooth
```

### 3.3 Llenar con agua
Selecciona el volumen interior del estanque (sin incluir el piso):
```
//1  (esquina interior, 1 bloque sobre el piso)
//2  (esquina opuesta interior, nivel del suelo - 1)
//set mcl_core:water_source
```

**Tip:** Si el agua se ve rara, usa `//set air` y vuelve a poner `//set mcl_core:water_source`. El agua necesita bloques source en cada posicion para verse bien.

---

## Paso 4: Caminos de piedra

Caminos de losas que rodean el estanque y cruzan el jardin.

### 4.1 Camino principal (losas de andesita)
Marca tiras de 2 bloques de ancho al nivel del suelo:
```
//1  (inicio del camino)
//2  (fin del camino, misma Y, 2 bloques de ancho)
//set mcl_stairs:slab_andesite_smooth_top
```

**Nota:** Usa `_top` para que la losa quede a nivel del pasto. Si prefieres camino hundido, usa `mcl_stairs:slab_andesite_smooth` (losa inferior).

### 4.2 Variacion: Piedras individuales (stepping stones)
Para un look mas natural, coloca manualmente bloques individuales de:
- `mcl_core:stone_smooth` - piedra lisa
- `mcl_core:andesite_smooth` - andesita pulida

Alterna entre ambos cada 1-2 bloques de distancia.

---

## Paso 5: Muros bajos perimetrales

Un muro de piedra de 2 bloques de alto alrededor del jardin.

### 5.1 Muro norte (ejemplo)
```
//1  (esquina noroeste, nivel suelo)
//2  (esquina noreste, 1 bloque arriba = 2 de alto)
//set mcl_core:stonebrick
```

### 5.2 Repetir para cada lado
Repite para los muros sur, este y oeste. Deja huecos de 3 bloques para las entradas.

### 5.3 Tope decorativo
Sobre el muro, agrega una capa de losas:
```
//1  (esquina del muro, 1 bloque sobre el muro)
//2  (esquina opuesta, misma Y)
//set mcl_stairs:slab_stonebrickmossy
```

Esto da un efecto de muro antiguo con musgo arriba.

---

## Paso 6: Puente de madera sobre el estanque

Un puente de madera de abeto (spruce) cruzando el estanque.

### 6.1 Pilares del puente
Coloca manualmente 2 columnas de `mcl_core:sprucetree` en cada extremo del puente (dentro del agua). 2 bloques de alto cada pilar.

### 6.2 Base del puente
Marca una franja de 3 bloques de ancho cruzando el estanque:
```
//1  (inicio del puente, 1 bloque sobre el agua)
//2  (fin del puente, misma Y, 3 bloques de ancho)
//set mcl_core:sprucewood
```

### 6.3 Barandas
En los bordes laterales del puente, coloca manualmente:
- `mcl_fences:spruce_fence` - cercas de abeto como barandas
- 1 bloque de alto a cada lado del puente

---

## Paso 7: Arboles decorativos

Coloca arboles manualmente para control total del aspecto.

### 7.1 Troncos
Apila 4-6 bloques de `mcl_core:sprucetree` verticalmente. Coloca 2-3 arboles alrededor del estanque.

### 7.2 Copa de hojas
Alrededor de la parte superior del tronco, coloca `mcl_core:spruceleaves` manualmente en forma de esfera o cono.

**Tip con WorldEdit:** Para una copa rapida, selecciona un cubo de 5x4x5 centrado en la punta del tronco:
```
//1  (2 bloques al lado y 1 abajo de la punta)
//2  (2 bloques al lado opuesto y 2 arriba de la punta)
//set mcl_core:spruceleaves
```
Luego quita las esquinas manualmente para que se vea natural.

### 7.3 Arbol de cerezo (opcional)
Si quieres un toque de color rosa, usa:
- Tronco: `mcl_cherry_blossom:cherrytree`
- Hojas: `mcl_cherry_blossom:cherryleaves`

---

## Paso 8: Iluminacion

Linternas de piso para iluminar sin romper la estetica.

### 8.1 Linternas de suelo
Coloca manualmente `mcl_lanterns:lantern_floor` cada 4-5 bloques a lo largo de los caminos.

### 8.2 Linternas en el puente
Coloca 1 linterna en cada esquina del puente.

### 8.3 Alternativa: Velas
Para un ambiente mas zen, usa `mcl_candles:candle` (velas) agrupadas en las esquinas.

---

## Paso 9: Detalles finales

### 9.1 Arena zen
Crea un area de arena al lado del estanque (ej: 6x6 bloques):
```
//1  (esquina del area de arena)
//2  (esquina opuesta, misma Y)
//set mcl_core:sand
```

### 9.2 Flores
Desde el inventario creativo, coloca manualmente:
- `mcl_flowers:tulip_red` - Tulipanes rojos
- `mcl_flowers:tulip_white` - Tulipanes blancos
- `mcl_flowers:allium` - Allium (morado)
- `mcl_flowers:blue_orchid` - Orquidea azul
- `mcl_flowers:oxeye_daisy` - Margaritas
- `mcl_flowers:lily_of_the_valley` - Lirio del valle

Distribuyelas de forma natural, no en lineas rectas.

### 9.3 Bancas
Coloca `mcl_stairs:stair_sprucewood` como bancas mirando al estanque. Pon 2-3 bancas en puntos panoramicos.

### 9.4 Lirios de agua
Sobre el estanque, coloca manualmente `mcl_flowers:waterlily` (lirios acuaticos) en la superficie del agua.

### 9.5 Piedras decorativas
Coloca bloques sueltos de `mcl_core:stone` y `mcl_walls:cobble` alrededor del estanque para un look natural.

---

## Referencia rapida de bloques

| Elemento | Bloque VoxeLibre |
|----------|-----------------|
| Pasto | `mcl_core:dirt_with_grass` |
| Tierra | `mcl_core:dirt` |
| Agua | `mcl_core:water_source` |
| Piedra lisa | `mcl_core:stone_smooth` |
| Andesita pulida | `mcl_core:andesite_smooth` |
| Losa andesita | `mcl_stairs:slab_andesite_smooth` |
| Ladrillo piedra | `mcl_core:stonebrick` |
| Losa ladrillo musgoso | `mcl_stairs:slab_stonebrickmossy` |
| Madera abeto | `mcl_core:sprucewood` |
| Tronco abeto | `mcl_core:sprucetree` |
| Losa madera abeto | `mcl_stairs:slab_sprucewood` |
| Hojas abeto | `mcl_core:spruceleaves` |
| Cereza (tronco) | `mcl_cherry_blossom:cherrytree` |
| Cereza (hojas) | `mcl_cherry_blossom:cherryleaves` |
| Arena | `mcl_core:sand` |
| Linterna piso | `mcl_lanterns:lantern_floor` |
| Cerca abeto | `mcl_fences:spruce_fence` |
| Escalera abeto | `mcl_stairs:stair_sprucewood` |
| Lirio acuatico | `mcl_flowers:waterlily` |
| Muro cobble | `mcl_walls:cobble` |

## Comandos WorldEdit esenciales

| Comando | Funcion |
|---------|---------|
| `//1` | Marcar posicion 1 (golpe izq. con varita) |
| `//2` | Marcar posicion 2 (golpe der. con varita) |
| `//set <bloque>` | Rellenar seleccion con bloque |
| `//replace <viejo> <nuevo>` | Reemplazar un bloque por otro |
| `//mark` | Mostrar seleccion actual |
| `//pos1` | Fijar pos1 en tu ubicacion actual |
| `//pos2` | Fijar pos2 en tu ubicacion actual |
| `//volume` | Ver tamano de la seleccion |
| `//undo` | Deshacer ultimo cambio |
