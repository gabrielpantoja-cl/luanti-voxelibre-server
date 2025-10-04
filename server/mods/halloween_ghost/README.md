# 👻 Halloween Ghost Mod - Fantasma de Halloween

Mod experimental de fantasma amigable para eventos de Halloween en el servidor Wetlands.

## 🎃 Características

- **Fantasma Pacífico**: Mob completamente amigable que flota y se mueve suavemente
- **Sistema de Premios**: Al tocar el fantasma, suelta dulces y desaparece
- **Efectos Visuales**: Partículas místicas y brillo en la oscuridad
- **Calabazas Mágicas**: Bloques decorativos que pueden soltar fantasmas o dulces
- **Comandos de Evento**: Sistema para admins de crear eventos de Halloween

## 🎮 Comandos (Solo Admin)

### `/invocar_fantasma`
Invoca un único fantasma amigable cerca del jugador.
```
/invocar_fantasma
```

### `/evento_halloween <cantidad>`
Inicia un evento de Halloween con múltiples fantasmas (1-20).
```
/evento_halloween 10
```

## 🏗️ Bloques

### Calabaza Mágica de Halloween
- **Nombre**: `halloween_ghost:magic_pumpkin`
- **Obtención**: `/give @s halloween_ghost:magic_pumpkin`
- **Efecto**: Al romperla, 50% probabilidad de invocar fantasma o soltar dulces

## 🎨 Características del Fantasma

- **Apariencia**: Cubo blanco flotante con cara amigable
- **Comportamiento**: Se mueve lentamente y flota suavemente arriba y abajo
- **Interacción**: Al tocarlo/golpearlo:
  - Suelta 1 item (manzana, zanahoria o papa)
  - Muestra mensaje amigable en chat
  - Crea efecto de partículas
  - Desaparece mágicamente

- **Efectos Visuales**:
  - Brilla en la oscuridad (glow level 8)
  - Partículas místicas flotantes
  - Explosión de partículas al tocarlo

## 📋 Requisitos

- **Luanti/Minetest**: 5.0+
- **VoxeLibre**: Compatible
- **Dependencias opcionales**: mcl_core, mcl_farming, mcl_mobs

## 🚀 Instalación

1. Copiar carpeta `halloween_ghost/` a `server/mods/`
2. Agregar a `luanti.conf`:
   ```
   load_mod_halloween_ghost = true
   ```
3. Reiniciar servidor

## 🎯 Uso Sugerido para Eventos

### Evento Básico (5-10 minutos)
```bash
/evento_halloween 5
# Los jugadores buscan y tocan fantasmas para obtener premios
```

### Evento Avanzado
1. Colocar calabazas mágicas por el mapa
2. Los jugadores las rompen para encontrar fantasmas
3. Tocar fantasmas para obtener dulces

### Caza de Fantasmas
```bash
/evento_halloween 15
# Crear competencia: quien toque más fantasmas gana
```

## 🎓 Aspectos Educativos

Este mod se alinea con los valores del servidor Wetlands:
- **No violencia**: El fantasma no ataca, es completamente amigable
- **Interacción positiva**: Los jugadores obtienen premios por interactuar
- **Diversión sana**: Evento festivo apropiado para niños 7+
- **Cooperación**: Los eventos pueden ser en equipo

## 🐛 Troubleshooting

**Fantasma no aparece**:
- Verificar que el mod esté cargado: `/mods` en el servidor
- Revisar logs: `docker-compose logs luanti-server | grep halloween`

**Texturas incorrectas**:
- Verificar que existan todas las texturas en `textures/`
- Las texturas son PNG de 16x16 píxeles

**Comandos no funcionan**:
- Requieren privilegio `server` (admin)
- Usar `/grant <jugador> server` para otorgar permisos

## 📝 Notas de Desarrollo

- **Versión**: 1.0.0 (Octubre 2025)
- **Estado**: Experimental
- **Apropiado para**: Niños 7+ años
- **Tipo**: Evento temporal/estacional

## 🎃 Ideas Futuras

- [ ] Sonidos fantasmales personalizados
- [ ] Más tipos de premios (items especiales de Halloween)
- [ ] Sistema de puntuación para eventos
- [ ] Diferentes tipos de fantasmas (colores)
- [ ] Casa embrujada generada automáticamente
- [ ] Música de evento de Halloween

---

**Creado para Wetlands** - Servidor educativo y compasivo de Luanti/VoxeLibre