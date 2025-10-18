# Comandos del Mod Halloween Ghost

## 🎃 Sistema de Fantasmas Actualizado

El mod de fantasmas de Halloween ahora incluye un sistema completo de spawn automático, límites de altura, y gestión de entities.

---

## 📍 Ubicación de Spawn

**Coordenadas fijas**: `(123, 25, -204)` - Misma ubicación que los zombies de Halloween
**Radio de spawn**: 15 bloques
**Temporada**: Solo activo en Octubre

---

## 🎮 Comandos Disponibles

### Para Administradores (requiere `server` privilege)

#### `/invocar_fantasma`
Invoca un fantasma amigable cerca de tu posición actual.

```
/invocar_fantasma
```

**Uso**: Spawn rápido de un solo fantasma para testing o eventos especiales.

---

#### `/invasion_fantasmas <cantidad>`
Inicia una invasión de fantasmas en la zona de spawn fija (123, 25, -204).

```
/invasion_fantasmas 5
```

**Parámetros**:
- `<cantidad>`: Número de fantasmas (1-8)

**Ejemplo**:
```
/invasion_fantasmas 8  # Invasión máxima
```

**Nota**: Los fantasmas aparecerán en la zona de spawn de Halloween, NO cerca del jugador.

---

#### `/limpiar_fantasmas`
Elimina **TODOS** los fantasmas activos del servidor.

```
/limpiar_fantasmas
```

**Uso**:
- Limpiar exceso de fantasmas
- Resetear sistema antes de eventos
- Troubleshooting de performance

**Resultado**: Muestra cuántos fantasmas fueron eliminados.

---

#### `/evento_halloween <cantidad>`
Comando legacy que spawns fantasmas cerca del jugador que ejecuta el comando.

```
/evento_halloween 5
```

**Nota**: Este comando spawn cerca del **jugador**, no en la zona fija. Recomendado usar `/invasion_fantasmas` en su lugar para eventos coordinados.

---

### Para Todos los Jugadores

#### `/estado_fantasmas`
Muestra información detallada sobre el sistema de fantasmas.

```
/estado_fantasmas
```

**Información mostrada**:
- Fantasmas activos / Máximo permitido
- Zona de spawn
- Radio de spawn
- Altura máxima
- Temporada Halloween (Activa/Inactiva)
- Intervalo entre spawns automáticos
- Tiempo de vida de los fantasmas

**Ejemplo de salida**:
```
👻 === Estado de Fantasmas de Halloween ===
Fantasmas activos: 5/8
Zona de spawn: (123,25,-204)
Radio de spawn: 15 bloques
Altura máxima: +50 bloques desde spawn
Temporada Halloween: ACTIVA (Octubre)
Tiempo entre spawns: 45 segundos
Tiempo de vida: 240 segundos (4 minutos)
```

---

## ⚙️ Configuración del Sistema

### Límites y Parámetros

| Parámetro | Valor | Descripción |
|-----------|-------|-------------|
| **MAX_GHOSTS** | 8 | Máximo de fantasmas simultáneos |
| **SPAWN_INTERVAL** | 45 segundos | Tiempo entre spawns automáticos |
| **GHOST_LIFETIME** | 240 segundos (4 min) | Tiempo antes de auto-despawn |
| **MAX_HEIGHT** | 50 bloques | Altura máxima sobre el spawn |
| **SPAWN_RADIUS** | 15 bloques | Radio de spawn desde punto central |

### Comportamiento Automático

**Spawn Automático**:
- ✅ Solo activo en Octubre (mes 10)
- ✅ Spawns cada 45 segundos
- ✅ Máximo 8 fantasmas simultáneos
- ✅ Ubicación fija en (123, 25, -204)

**Auto-Despawn**:
- ✅ Fantasmas desaparecen después de 4 minutos
- ✅ Efecto de partículas al desaparecer
- ✅ Contador actualizado automáticamente

**Límite de Altura**:
- ✅ Fantasmas no pueden subir más de 50 bloques
- ✅ Descenso automático si superan el límite
- ✅ Descenso gradual al 80% del límite (40 bloques)
- ✅ Previene sobrecarga del servidor

---

## 🎯 Casos de Uso

### Evento de Halloween Coordinado
```bash
# 1. Limpiar fantasmas existentes
/limpiar_fantasmas

# 2. Iniciar invasión máxima
/invasion_fantasmas 8

# 3. Anunciar el evento
# (El comando ya anuncia automáticamente)
```

### Troubleshooting de Performance
```bash
# Ver cuántos fantasmas hay
/estado_fantasmas

# Si hay demasiados, limpiar
/limpiar_fantasmas
```

### Testing de Mecánicas
```bash
# Spawn individual cerca de ti
/invocar_fantasma

# Ver estado del sistema
/estado_fantasmas
```

---

## 🎮 Mecánicas de Gameplay

### Interacción con Fantasmas

**Al golpear un fantasma**:
- 🍎 Suelta un item aleatorio (manzana, zanahoria, papa)
- 💬 Muestra mensaje amigable
- ✨ Efecto de partículas
- 👻 El fantasma desaparece

**Movimiento**:
- Flotan suavemente arriba y abajo
- Movimiento horizontal aleatorio cada 3 segundos
- Brillo constante (glow = 8) para visibilidad nocturna
- Rotan automáticamente

**Premios**:
- `mcl_core:apple`
- `mcl_farming:carrot_item`
- `mcl_farming:potato_item`

---

## 📊 Comparación con Zombies

| Característica | Fantasmas | Zombies |
|----------------|-----------|---------|
| **Máximo** | 8 | 10 |
| **Intervalo spawn** | 45s | 30s |
| **Tiempo de vida** | 240s (4min) | 300s (5min) |
| **Límite altura** | +50 bloques | N/A (terrestres) |
| **Ubicación spawn** | (123, 25, -204) | (123, 25, -204) |
| **Movimiento** | Flotante 3D | Terrestre 2D |

**Ambos mods comparten la misma zona de Halloween**: `(123, 25, -204)`

---

## 🐛 Troubleshooting

### Problema: "Demasiados fantasmas en el servidor"
**Solución**:
```bash
/limpiar_fantasmas
```

### Problema: "Fantasmas no aparecen automáticamente"
**Verificar**:
1. ¿Estamos en Octubre? (Temporada Halloween)
2. ¿Se alcanzó el límite de 8 fantasmas?
3. Revisar con `/estado_fantasmas`

### Problema: "Fantasmas suben demasiado alto"
**Respuesta**: El sistema ahora limita la altura a +50 bloques automáticamente.

### Problema: "Quiero más/menos fantasmas simultáneos"
**Solución**: Editar `MAX_GHOSTS` en `init.lua` (requiere reinicio del servidor)

---

## 📝 Notas Técnicas

- Los fantasmas son **inmortales** (armor group: immortal = 1)
- No tienen física (physical = false)
- No colisionan con objetos (collide_with_objects = false)
- Contador de entities activos independiente de zombies
- Compatible con sistema de zombies (ambos en misma ubicación)

---

**Versión del mod**: 2.0 (Octubre 2025)
**Autor**: Wetlands Team
**Servidor**: Wetlands - Servidor Educativo y Compasivo
**URL**: luanti.gabrielpantoja.cl:30000
