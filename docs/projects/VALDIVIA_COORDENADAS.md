# Valdivia 2.0 - Coordenadas del Mundo

**Servidor:** `luanti.gabrielpantoja.cl:30001`
**Mundo:** v4 (5.8 x 7.7 km, 112 MB)
**Bbox real:** -39.862,-73.285,-39.810,-73.195

## Coordenadas clave

| Lugar | Comando teleport | Coords reales (lat, lng) | Notas |
|-------|-----------------|--------------------------|-------|
| **Colegio Planeta Azul** (spawn) | `/teleport 2389,-55,-2887` | -39.835957, -73.257018 | Spawn del servidor |
| **Plaza estacionamiento Colegio** | `/teleport 2343,-56,-3148` | ~-39.838, -73.257 | Donde nos estacionamos para ir al colegio |
| **Av Pedro Montt / Circunvalacion** | `/teleport 4517,-48,-3885` | ~-39.845, -73.233 | Cruce de avenidas |
| **Supermercado Trebol** | `/teleport 3358,-42,-3537` | ~-39.842, -73.246 | Av Simpson / Circunvalacion |
| **Plaza Civica Guacamayo** | `/teleport 2715,-47,-4381` | ~-39.849, -73.253 | |
| **Casa Gabriel (Barrio Santa Elena)** | `/teleport 5798,-45,-1222` | -39.850988, -73.216807 | Pendiente verificar Y |
| **Circunvalacion / San Luis** | `/teleport 5473,-53.5,-3842` | | Cruce Circunvalacion con San Luis |
| **Schneider / Circunvalacion** | `/teleport 5747,-44,-4000` | | Cruce Schneider con Circunvalacion |
| **Sede Junta de Vecinos Bº Santa Elena** | `/teleport 6189,-49,-4424` | | Junta de vecinos Barrio Santa Elena |
| **Pasaje Argelia** | `/teleport 5810,-51,-4551` | | Barrio Santa Elena |
| **Los Fundadores** | `/teleport 4360,-51,-4211` | | |
| **Plaza Londres (Huachocopihue)** | `/teleport 3761,-43,-3170` | | |
| **Colegio Windsor** | `/teleport 3727,-44,-2619` | | Francia / Simpson |
| **Puente Pedro de Valdivia** | `/teleport 3111,-50,-176` | | Cruza el Rio Valdivia |

## Lugares por descubrir

Estas son coordenadas estimadas, pendientes de verificar en el juego:

| Lugar | Comando teleport estimado | Coords reales |
|-------|--------------------------|---------------|
| Rio Valdivia (centro) | `/teleport 2000,-50,-2000` | ~-39.840, -73.262 |
| Miraflores | `/teleport 4000,-45,-2500` | ~-39.830, -73.240 |
| Torobayo | `/teleport 1000,-45,-1500` | ~-39.825, -73.270 |
| Consorcio Maderero | `/teleport 1500,-45,-3500` | ~-39.848, -73.268 |

## Como calcular coordenadas

Para convertir coordenadas reales (lat, lng) a coordenadas del juego:

```
Bbox: min_lat=-39.862, min_lng=-73.285, max_lat=-39.810, max_lng=-73.195
Tamano: 5772m (N-S) x 7651m (E-O)

X = ((-73.285) - lng) / ((-73.285) - (-73.195)) * 7651
Z = -((-39.862) - lat) / ((-39.862) - (-39.810)) * 5772
Y = probar entre -30 y -55 (depende de elevacion del terreno)
```

## Hallazgos del jugador

*(Actualizar a medida que se explora el mundo)*

---

*Documento vivo - Actualizar con cada nueva ubicacion descubierta*
*Ultima actualizacion: 22 marzo 2026*
