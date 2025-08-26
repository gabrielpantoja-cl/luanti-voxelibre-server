# 📚 Plan de Desarrollo de Mods - Vegan Wetlands

> **Servidor Luanti educativo, vegano y sin violencia para niños 7+ años**

## 🎯 Objetivos del Proyecto

### Filosofía Principal
- **100% Vegano**: No violencia hacia animales, enfoque en cuidado y protección
- **Educativo**: Enseñar programación, compasión animal y sostenibilidad
- **Pacífico**: Eliminar mecánicas violentas, reemplazar con cooperación
- **Inclusivo**: Contenido apropiado para niños de 7+ años en español

---

## 📦 Estado Actual de Mods (Implementados)

### 1. 🐾 **animal_sanctuary** (v1.0.0)
**Estado**: ✅ Funcional - Núcleo del servidor vegano

**Características implementadas:**
- **Herramientas de Cuidado**:
  - `animal_brush`: Cepillo para mimar animales (reemplaza armas)
  - `animal_medkit`: Kit médico para curar animales
  - `vegan_animal_food`: Comida vegana para animales

- **Infraestructura del Santuario**:
  - `sanctuary_gate`: Puerta de entrada con mensaje de bienvenida
  - `animal_feeder`: Comedero para alimentar animales
  - `animal_shelter`: Refugios para proteger animales

- **Mecánicas Anti-Violencia**:
  - Prevención de daño entre jugadores
  - Sistema de partículas (corazones) al cuidar animales
  - Sonidos de animales felices

- **Comandos Educativos**:
  - `/santuario`: Información del santuario
  - `/veganismo`: Educación sobre veganismo

- **Sistema de Bienvenida**:
  - Kit inicial para nuevos jugadores
  - Mensajes educativos automáticos

### 2. 🍎 **vegan_foods** (v1.0.0)
**Estado**: ✅ Funcional - Alternativas alimentarias

**Características implementadas:**
- **Alimentos Veganos**:
  - `vegan_burger`: Hamburguesa vegana (8 puntos de comida)
  - `oat_milk`: Leche de avena (4 puntos de comida)
  - `vegan_cheese`: Queso vegano (6 puntos de comida)
  - `vegan_pizza`: Pizza vegana (12 puntos de comida)

- **Sistema de Recetas**:
  - Recipes usando ingredientes base de VoxeLibre
  - Dependencia del mod `farming` para ingredientes

### 3. 📚 **education_blocks** (v1.0.0)
**Estado**: ✅ Funcional - Bloques educativos interactivos

**Características implementadas:**
- **Bloques Educativos**:
  - `vegan_sign`: Cartel con datos sobre veganismo
  - `nutrition_block`: Información nutricional vegana
  - `animal_facts`: Datos curiosos sobre animales

- **Sistema Interactivo**:
  - Mensajes aleatorios educativos al hacer clic derecho
  - Datos sobre inteligencia animal y nutrición vegana

### 4. 🛡️ **protector** (Mod externo)
**Estado**: ✅ Funcional - Protección anti-griefing

**Características**:
- Sistema de protección de terrenos
- Anti-griefing automático
- Herramientas de administración

---

## 🚀 Plan de Desarrollo Futuro

### Fase 1: **Expansión Vegana** (Prioridad Alta) 🌱

#### 1.1 **animal_sanctuary_v2** - Sistema Avanzado de Santuarios
```lua
-- Nuevas características:
- Sistema de rescate de animales heridos
- Adopción virtual de animales con nombres
- Registro de bienestar animal individual  
- Centro de rehabilitación
- Veterinario NPC con diálogos educativos
```

**Implementaciones:**
- **Animal Tracking System**: Cada animal tiene ID único, nombre, salud, felicidad
- **Rescue Missions**: Animales aparecen "heridos" que necesitan ser rescatados
- **Adoption Center**: Jugadores pueden adoptar mascotas virtuales
- **Veterinary Clinic**: Building con herramientas médicas avanzadas
- **Animal Behavior AI**: Animales responden diferente según cuidado recibido

#### 1.2 **compassion_system** - Sistema de Puntos de Compasión
```lua
-- Mecánica de recompensas:
- Puntos por cuidar animales (+10)
- Puntos por rescatar animales (+25) 
- Puntos por plantar árboles (+5)
- Puntos por enseñar a otros (+15)
- Rangos: Amigo → Cuidador → Guardián → Protector
```

**Recompensas por Nivel:**
- **Amigo Animal** (100 pts): Acceso a más herramientas de cuidado
- **Cuidador Vegano** (500 pts): Habilidad de construir santuarios especiales
- **Guardián de la Vida** (1000 pts): NPCs buscan tu ayuda para rescates
- **Protector de los Animales** (2500 pts): Poderes especiales de curación

#### 1.3 **vegan_education_center** - Centro Educativo Interactivo
```lua
-- Espacios educativos:
- Biblioteca vegana con libros interactivos
- Laboratorio de nutrición con experimentos
- Cinema para documentales cortos
- Aula con pizarra y presentaciones
```

### Fase 2: **Modo Educativo Programación** (Prioridad Alta) 💻

#### 2.1 **coding_blocks** - Programación Visual para Niños
```lua
-- Inspirado en Scratch/Blockly:
- Bloques de código visual que se conectan
- Algoritmos simples: if/then, loops, functions
- Control de NPCs y máquinas con código
- Debugging visual con luces y señales
```

**Conceptos a Enseñar:**
- **Variables**: Cajas que guardan números/texto
- **Condicionales**: Si esto, entonces eso
- **Bucles**: Repetir acciones
- **Funciones**: Crear comandos personalizados
- **Eventos**: Responder a acciones del jugador

#### 2.2 **robot_companion** - Robot Mascota Programable
```lua
-- Robot que sigue al jugador:
- Se programa con coding_blocks
- Puede plantar, construir, recolectar
- Enseña conceptos de automatización
- Evoluciona con mejor programación
```

**Actividades del Robot:**
- **Granja Automática**: Programa robot para cosechar
- **Constructor**: Robot construye estructuras siguiendo algoritmos
- **Explorador**: Robot mapea áreas y reporta hallazgos
- **Asistente**: Robot ayuda en tareas del santuario

#### 2.3 **logic_circuits** - Circuitos Lógicos Educativos
```lua
-- Redstone educativo:
- Puertas lógicas: AND, OR, NOT
- Displays de 7 segmentos para números
- Calculadoras simples
- Sistemas de automatización
```

### Fase 3: **Contenido Educativo Avanzado** (Prioridad Media) 🎓

#### 3.1 **climate_science** - Ciencias del Clima
```lua
-- Educación ambiental:
- Simulador de efecto invernadero
- Comparación huella carbono: dietas veganas vs omnívoras  
- Sistema de weather con explicaciones científicas
- Experimentos con energías renovables
```

#### 3.2 **sustainable_farming** - Agricultura Sostenible
```lua
-- Permacultura y sostenibilidad:
- Sistemas de compostaje funcionales
- Rotación de cultivos con beneficios reales
- Agricultura vertical y hidropónica
- Biomas de policultivo vs monocultivo
```

#### 3.3 **nutrition_lab** - Laboratorio de Nutrición
```lua
-- Experimentos nutricionales:
- Microscopio para examinar células vegetales
- Análisis proteico de alimentos veganos
- Comparación nutricional interactiva
- Recetas balanceadas con calculadora nutricional
```

### Fase 4: **Mecánicas de Juego Cooperativo** (Prioridad Media) 🤝

#### 4.1 **community_projects** - Proyectos Comunitarios
```lua
-- Construcciones cooperativas:
- Gran Santuario Comunitario (requiere múltiples jugadores)
- Biblioteca de código compartido
- Jardín botánico colaborativo
- Red de transporte vegano
```

#### 4.2 **mentorship_system** - Sistema de Mentores
```lua
-- Jugadores experimentados enseñan nuevos:
- Sistema de "buddy" automático
- Rewards por enseñar conceptos
- Seguimiento de progreso de estudiantes
- Certificados digitales por habilidades
```

### Fase 5: **Contenido Avanzado** (Prioridad Baja) 🏆

#### 5.1 **research_station** - Estación de Investigación
```lua
-- Simulación científica:
- Investigación de alternativas veganas
- Desarrollo de nuevos alimentos vegetales
- Estudios de comportamiento animal
- Publicación de "papers" en el juego
```

#### 5.2 **virtual_reality_experiences** - Experiencias Inmersivas
```lua
-- Mini-mundos educativos:
- Visita virtual a santuarios reales
- Experiencia "desde los ojos de un animal"
- Viaje por el sistema digestivo con comida vegana
- Exploración de ecosistemas
```

---

## 📋 Cronograma de Implementación

### **Q1 2025** (Enero - Marzo)
- ✅ **animal_sanctuary_v2**: Sistema avanzado de rescate y adopción
- ✅ **compassion_system**: Puntos y rangos por actos compasivos
- 🔄 **coding_blocks v1**: Programación visual básica

### **Q2 2025** (Abril - Junio)  
- 🔄 **robot_companion**: Robot programable
- 🔄 **vegan_education_center**: Centro educativo interactivo
- 📅 **logic_circuits**: Circuitos lógicos básicos

### **Q3 2025** (Julio - Septiembre)
- 📅 **climate_science**: Simulaciones ambientales
- 📅 **sustainable_farming**: Agricultura sostenible
- 📅 **community_projects**: Proyectos colaborativos

### **Q4 2025** (Octubre - Diciembre)
- 📅 **mentorship_system**: Sistema de mentores
- 📅 **nutrition_lab**: Laboratorio avanzado
- 📅 **research_station**: Investigación científica

---

## 🛠️ Especificaciones Técnicas

### Dependencias Base
```lua
depends = default, farming
optional_depends = mcl_core, mcl_farming, mcl_sounds
```

### Estructura de Archivos Estándar
```
mod_name/
├── mod.conf              # Metadatos del mod
├── init.lua              # Archivo principal
├── locale/               # Traducciones
├── textures/            # Imágenes y texturas
├── sounds/              # Efectos de sonido
├── models/              # Modelos 3D (.obj)
├── docs/                # Documentación específica
└── tests/               # Tests automatizados
```

### Convenciones de Código
- **Idioma**: Comentarios y strings en español
- **Naming**: `snake_case` para variables, `PascalCase` para funciones importantes
- **Logging**: Usar `minetest.log("action", "[ModName] mensaje")`
- **Chat**: Prefijo con emoji identificador por mod

---

## 🎨 Assets Necesarios

### Texturas Prioritarias
- [ ] `animal_sanctuary_v2_*.png` - Nuevos bloques del santuario
- [ ] `coding_blocks_*.png` - Bloques de programación visual
- [ ] `robot_companion_*.png` - Texturas del robot
- [ ] `compassion_*.png` - Iconos del sistema de compasión

### Sonidos Necesarios
- [ ] `animal_happy.ogg` - Sonidos de animales contentos
- [ ] `rescue_success.ogg` - Sonido de rescate exitoso
- [ ] `code_success.ogg` - Sonido de código ejecutado correctamente
- [ ] `robot_beep.ogg` - Sonidos del robot

### Modelos 3D
- [ ] `robot_companion.obj` - Modelo del robot programable
- [ ] `sanctuary_structures.obj` - Estructuras avanzadas del santuario

---

## 🧪 Plan de Testing

### Testing Manual
1. **Funcionalidad Base**: Cada mod debe funcionar independientemente
2. **Integración**: Todos los mods deben coexistir sin conflictos
3. **Experiencia de Usuario**: Flujo educativo coherente
4. **Performance**: No lag con múltiples jugadores simultáneos

### Testing con Niños
1. **Grupo Focus**: Niños 7-12 años probando mecánicas
2. **Comprensión**: ¿Entienden los conceptos educativos?
3. **Diversión**: ¿Se mantienen enganchados al juego?
4. **Valores**: ¿Aprenden sobre compasión y veganismo?

---

## 📈 Métricas de Éxito

### KPIs Educativos
- **Retención**: Jugadores que regresan semanalmente
- **Progresión**: Jugadores que avanzan en rangos de compasión
- **Código**: Número de programas creados por jugadores
- **Cooperación**: Proyectos colaborativos completados

### KPIs Veganos
- **Interacciones Positivas**: Cuidados de animales por sesión
- **Rescates**: Animales rescatados por la comunidad
- **Educación**: Comandos educativos utilizados
- **Adopciones**: Animales virtuales adoptados

---

## 💡 Ideas Futuras (Brainstorm)

### Contenido Opcional
- **Huerto Escolar Virtual**: Cada jugador mantiene su parcela educativa
- **Museo de la Compasión**: Exhibiciones sobre historia de derechos animales  
- **Teatro de Marionetas**: Jugadores crean obras sobre veganismo
- **Simulador de Ecosistemas**: Cómo impacta la agricultura en la biodiversidad
- **AI Educativa**: NPCs que adaptan enseñanza al nivel de cada jugador

### Integraciones Externas
- **Mods de la Comunidad**: Compatibilidad con mods educativos existentes
- **APIs Externas**: Conexión con plataformas de aprendizaje
- **VR Support**: Experiencias inmersivas opcionales
- **Mobile Companion**: App complementaria para aprender fuera del juego

---

## 📞 Contacto y Contribuciones

**Equipo de Desarrollo**: Vegan Wetlands Team  
**Repositorio**: https://github.com/gabrielpantoja-cl/Vegan-Wetlands.git  
**Servidor**: luanti.gabrielpantoja.cl:30000  

### Cómo Contribuir
1. Fork del repositorio
2. Crear rama para feature específico
3. Implementar siguiendo convenciones establecidas
4. Testing exhaustivo
5. Pull Request con documentación

---

*Documento actualizado: Agosto 2025*  
*Próxima revisión: Septiembre 2025*