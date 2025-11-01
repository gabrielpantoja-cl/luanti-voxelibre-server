# Sistema de Scoring - PVP Arena v1.2.0

**Autor**: Gabriel Pantoja (gabo)
**Fecha**: Octubre 2025
**Versión**: 1.2.0

## 📊 Descripción General

El sistema de scoring es una característica adictiva del mod PVP Arena que rastrea automáticamente las estadísticas de combate de cada jugador en tiempo real. Los jugadores compiten por el primer lugar en el scoreboard, creando una experiencia competitiva y emocionante.

## ⭐ Características Principales

### 1. **Tracking Automático de Estadísticas**
Cada vez que entras a una arena, el sistema comienza a rastrear automáticamente:
- **Kills**: Número de jugadores eliminados
- **Deaths**: Número de veces que moriste
- **K/D Ratio**: Proporción de kills/deaths (indicador de habilidad)
- **Current Streak**: Kills consecutivas actuales
- **Best Streak**: Mejor racha de kills consecutivas

### 2. **Scoreboard en Tiempo Real**
- Se muestra automáticamente después de cada kill
- Tabla ordenada por número de kills
- Top 3 destacado con medallas (🥇🥈🥉)
- Colores diferenciados por posición (oro, plata, bronce)
- Actualización instantánea en el chat

### 3. **Killstreaks con Mensajes Especiales**
El sistema anuncia logros especiales cuando alcanzas rachas de kills:

| Kills | Mensaje | Color |
|-------|---------|-------|
| 3 | ¡TRIPLE KILL! | 🔶 Naranja |
| 5 | ¡KILLING SPREE! | 🔸 Naranja oscuro |
| 7 | ¡RAMPAGE! | 🔥 Rojo claro |
| 10 | ¡UNSTOPPABLE! | 🔴 Rojo |
| 15 | ¡GODLIKE! | ⭐ Rojo intenso |
| 20 | ¡LEGENDARY! | 💀 Rojo oscuro |

### 4. **Anuncios de Kills**
Cada kill se anuncia a todos los jugadores en arenas con el formato:
```
💀 NombreKiller eliminó a NombreVíctima [3 kills seguidas]
```

### 5. **Detección de Muertes Accidentales**
El sistema diferencia entre:
- **Kills por combate**: Muerte causada por otro jugador
- **Muertes accidentales**: Caídas, lava, ahogamiento (se anuncian como "accidente")

## 🎮 Comandos de Usuario

### `/arena_score`
**Descripción**: Muestra el scoreboard completo con el Top 10 de jugadores.

**Formato del Scoreboard**:
```
╔═══════════════════════════════════════════════╗
║     🏆 SCOREBOARD - ARENA PVP 🏆         ║
╠═══════════════════════════════════════════════╣
║ #  Jugador          K    D    K/D   Streak   ║
╠═══════════════════════════════════════════════╣
║ 🥇 PlayerOne       12   3   4.00    5     ║
║ 🥈 PlayerTwo       10   4   2.50    2     ║
║ 🥉 PlayerThree      8   2   4.00    8     ║
║    PlayerFour       5   6   0.83    0     ║
╚═══════════════════════════════════════════════╝
```

**Columnas**:
- **#**: Posición con medalla para Top 3
- **Jugador**: Nombre del jugador (máximo 14 caracteres)
- **K**: Kills totales
- **D**: Deaths totales
- **K/D**: Ratio kills/deaths (mayor = mejor)
- **Streak**: Racha de kills actual

### `/mis_stats`
**Descripción**: Muestra tus estadísticas personales detalladas.

**Formato**:
```
╔═══════════════════════════════════╗
║   📊 TUS ESTADÍSTICAS PVP 📊   ║
╠═══════════════════════════════════╣
║ Kills:              12             ║
║ Deaths:              3             ║
║ K/D Ratio:        4.00             ║
║ Racha actual:        5             ║
║ Mejor racha:        10             ║
╚═══════════════════════════════════╝
```

## 🔧 Implementación Técnica

### Arquitectura del Sistema

```
pvp_arena/
├── init.lua           # Hooks de combate y muerte
├── scoring.lua        # Lógica principal del scoring
├── commands.lua       # Comandos de usuario
└── docs/
    └── SCORING_SYSTEM.md
```

### Flujo de Datos

1. **Entrada a Arena** → Inicialización de estadísticas
2. **Combate** → Tracking del último atacante (`last_attacker`)
3. **Muerte del jugador** → Verificación de atacante (últimos 10 segundos)
4. **Registro de Kill** → Actualización de estadísticas + anuncios
5. **Verificación de Killstreak** → Anuncio especial si aplica
6. **Mostrar Scoreboard** → Display automático 1s después de kill

### Tracking de Atacantes

El sistema usa una tabla temporal `pvp_arena.last_attacker` que almacena:
```lua
{
    [victim_name] = {
        name = attacker_name,
        time = os.time()
    }
}
```

**Ventana de tiempo**: 10 segundos
**Razón**: Permite atribuir la kill al último atacante incluso si hay delay por efectos (veneno, fuego, caída después de golpe)

### Formato de Estadísticas

```lua
pvp_arena.scores[player_name] = {
    kills = 0,              -- Total de kills
    deaths = 0,             -- Total de deaths
    current_streak = 0,     -- Racha actual
    best_streak = 0,        -- Mejor racha histórica
    last_kill_time = 0      -- Timestamp de última kill
}
```

## 🎯 Ejemplos de Uso

### Escenario 1: Primera Kill
```
PlayerA golpea a PlayerB → PlayerB muere

Anuncio en chat:
💀 PlayerA eliminó a PlayerB

Scoreboard automático (1s después):
╔═══════════════════════════════════════════════╗
║ 🥇 PlayerA          1   0   1.00    1     ║
║    PlayerB          0   1   0.00    0     ║
╚═══════════════════════════════════════════════╝
```

### Escenario 2: Triple Kill
```
PlayerA mata a PlayerB (1 kill)
PlayerA mata a PlayerC (2 kills)
PlayerA mata a PlayerD (3 kills)

Anuncio en chat:
💀 PlayerA eliminó a PlayerD [3 kills seguidas]
🔥 ¡TRIPLE KILL! 🔥 PlayerA tiene 3 kills seguidas!

Scoreboard actualizado
```

### Escenario 3: Muerte Accidental
```
PlayerB cae de una altura y muere

Anuncio en chat:
PlayerB murió (accidente)

Stats actualizadas:
- PlayerB.deaths += 1
- PlayerB.current_streak = 0 (se resetea)
```

## 📈 Futuras Mejoras (Roadmap)

### Fase 2 - HUD Persistente
- [ ] Scoreboard en HUD permanente (esquina superior derecha)
- [ ] Actualización en tiempo real sin comandos
- [ ] Indicador visual de tu posición actual

### Fase 3 - Persistencia de Datos
- [ ] Guardar estadísticas entre sesiones del servidor
- [ ] Archivo de scores históricos
- [ ] Ranking all-time con mejores jugadores

### Fase 4 - Premios y Logros
- [ ] Sistema de achievements (Primera sangre, Imparable, etc.)
- [ ] Premios in-game por logros (items especiales)
- [ ] Títulos especiales para top players

### Fase 5 - Estadísticas Avanzadas
- [ ] Accuracy (% de golpes acertados)
- [ ] Damage dealt/received
- [ ] Tiempo promedio de supervivencia
- [ ] Arma favorita

## 🐛 Troubleshooting

### Problema: El scoreboard no se muestra después de una kill
**Solución**: Verifica que `scoring.lua` esté cargado correctamente:
```bash
docker compose logs luanti-server | grep scoring
```

### Problema: Las estadísticas no se guardan entre desconexiones
**Comportamiento esperado**: En v1.2.0, las estadísticas se resetean al desconectar. Esto cambiará en Fase 3.

### Problema: Un jugador tiene K/D infinito
**Explicación**: Si un jugador tiene kills pero 0 deaths, el K/D se muestra como número de kills (división por cero manejada).

## 💡 Tips para Competir

1. **Mantén tu streak**: Evita riesgos innecesarios cuando tengas una buena racha
2. **Controla el K/D ratio**: Mejor 5 kills / 1 death que 10 kills / 8 deaths
3. **Usa `/mis_stats`**: Revisa tus estadísticas para medir mejora
4. **Estudia el scoreboard**: Aprende de los mejores jugadores
5. **Triple Kill = Game Changer**: Alcanzar 3+ kills seguidas te destaca

## 📊 Métricas de Éxito

El sistema está diseñado para ser **adictivo** mediante:
- ✅ **Feedback inmediato**: Anuncios instantáneos de kills
- ✅ **Reconocimiento social**: Tu nombre en el scoreboard público
- ✅ **Metas claras**: Alcanzar killstreaks específicos
- ✅ **Competencia sana**: Ranking visual con medallas
- ✅ **Progresión visible**: Ver mejora en K/D ratio con el tiempo

## 🤝 Contribuciones

Si tienes ideas para mejorar el sistema de scoring, contacta a **gabo** (Gabriel Pantoja) o abre un issue en el repositorio del servidor.

---

**¡Que comience la competencia! 🏆⚔️**
