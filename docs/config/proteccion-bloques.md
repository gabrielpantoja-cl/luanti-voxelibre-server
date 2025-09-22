# 🛡️ Guía Completa: Sistema de Protección de Bloques en Vegan Wetlands

## 📋 Índice
1. [¿Qué es el Sistema de Protección?](#qué-es-el-sistema-de-protección)
2. [Cómo Obtener Bloques Protectores](#cómo-obtener-bloques-protectores)
3. [Tipos de Bloques Protectores](#tipos-de-bloques-protectores)
4. [Colocación y Configuración](#colocación-y-configuración)
5. [Gestión de Miembros](#gestión-de-miembros)
6. [Comandos de Chat](#comandos-de-chat)
7. [Área de Protección](#área-de-protección)
8. [Elementos Protegidos Especiales](#elementos-protegidos-especiales)
9. [Privilegios de Administrador](#privilegios-de-administrador)
10. [Resolución de Problemas](#resolución-de-problemas)
11. [Consejos y Mejores Prácticas](#consejos-y-mejores-prácticas)

---

## 🔒 ¿Qué es el Sistema de Protección?

El **Sistema de Protección de Bloques** en Vegan Wetlands permite a los jugadores proteger sus construcciones y áreas específicas contra modificaciones no autorizadas. Es ideal para:

- 🏠 Proteger casas y construcciones
- 🌱 Asegurar granjas y jardines
- 🐾 Proteger santuarios de animales
- 🎨 Preservar obras de arte y monumentos
- 📚 Crear áreas educativas seguras

### ✅ Beneficios del Sistema
- **Seguridad Total**: Nadie puede modificar tu área protegida
- **Control Granular**: Decides quién puede acceder
- **Fácil de Usar**: Interfaz simple y comandos intuitivos
- **Múltiples Áreas**: Puedes tener varios protectores
- **Compatibilidad**: Funciona con todos los elementos de VoxeLibre

---

## 📦 Cómo Obtener Bloques Protectores

### 🎮 En Modo Creativo (Recomendado)

**Paso 1: Abrir Inventario Creativo**
- Presiona `E` (o tu tecla de inventario configurada)
- Asegúrate de estar en modo creativo

**Paso 2: Buscar Bloques Protectores**
- En la barra de búsqueda, escribe: `protection`
- También puedes navegar por las categorías de bloques

**Bloques Disponibles:**
```
📦 Protection Block - Bloque protector principal (cubo sólido)
📦 Protection Logo - Logo protector (placa decorativa)
```

### ⚒️ Creación Manual (Modo Supervivencia)

Si el servidor estuviera en modo supervivencia, la receta sería:

```
[Piedra] [Piedra] [Piedra]
[Piedra] [Oro]    [Piedra]
[Piedra] [Piedra] [Piedra]
```

**Materiales VoxeLibre:**
- 8x `Cobblestone` (mcl_core:stone)
- 1x `Gold Ingot` (mcl_core:gold_ingot)

### 💻 Comando de Administrador

Los administradores pueden usar:
```bash
/give <usuario> protector:protect <cantidad>
/give <usuario> protector:protect2 <cantidad>
```

**Ejemplo:**
```bash
/give gabo protector:protect 10     # 10 bloques protectores
/give pepelomo protector:protect2 5 # 5 logos protectores
```

---

## 🧱 Tipos de Bloques Protectores

### 1. 📦 Protection Block (`protector:protect`)

**Características:**
- ✅ **Apariencia**: Bloque sólido con textura de piedra y logo protector
- ✅ **Funcionalidad**: Protección completa del área
- ✅ **Visibilidad**: Claramente visible como estructura protectora
- ✅ **Uso**: Ideal para marcar claramente áreas protegidas

**Cuándo Usar:**
- Construcciones grandes donde la visibilidad del protector es importante
- Áreas públicas que necesitan protección visible
- Cuando quieres que otros sepan que el área está protegida

### 2. 🏷️ Protection Logo (`protector:protect2`)

**Características:**
- ✅ **Apariencia**: Logo decorativo que se coloca en paredes
- ✅ **Funcionalidad**: Misma protección que el bloque principal
- ✅ **Discreto**: Menos invasivo visualmente
- ✅ **Versátil**: Se puede colocar en paredes, techos, suelos

**Cuándo Usar:**
- Construcciones donde la estética es importante
- Protección discreta sin alterar el diseño
- Espacios interiores donde un bloque sólido sería molesto

### 🔄 Conversión entre Tipos

Puedes convertir fácilmente entre ambos tipos:

```
Protection Block → Protection Logo (crafting)
Protection Logo → Protection Block (crafting)
```

Simplemente coloca uno en la mesa de crafting para obtener el otro tipo.

---

## 🎯 Colocación y Configuración

### 📍 Paso 1: Seleccionar Ubicación

**Consideraciones Importantes:**
- ✅ **Centro del área**: Coloca el protector en el centro de lo que quieres proteger
- ✅ **Radio de 5 bloques**: El área protegida será de 11x11x11 bloques
- ✅ **No superposición**: No puedes colocar protectores que se solapen
- ✅ **Distancia de spawn**: Respeta la distancia del área de spawn protegida

### 📍 Paso 2: Colocar el Protector

1. **Selecciona el bloque** en tu hotbar
2. **Apunta al lugar** donde quieres colocarlo
3. **Clic derecho** para colocar
4. **Visualización temporal**: El área protegida se mostrará brevemente

### ⚙️ Paso 3: Configuración Inicial

**Automático al Colocar:**
- ✅ Tu nombre se registra como propietario
- ✅ Solo tú puedes romper este protector
- ✅ La protección se activa inmediatamente
- ✅ Se muestra mensaje de confirmación

### 🔧 Paso 4: Acceder al Menú de Configuración

**Cómo Abrir:**
- **Clic derecho** en TU bloque protector
- Se abre un menú de configuración

**Opciones Disponibles:**
- 👥 **Gestionar Miembros**: Añadir/quitar usuarios autorizados
- ℹ️ **Ver Información**: Propietario actual y lista de miembros
- 🔄 **Actualizar Configuración**: Cambios en permisos

---

## 👥 Gestión de Miembros

### ➕ Añadir Miembros

**Método 1: Interfaz Gráfica**
1. Clic derecho en tu protector
2. Escribir nombre del usuario en el campo "Add Member"
3. Clic en el botón "+" o presionar Enter

**Método 2: Comando de Chat**
```bash
/protector_add_member <nombre_usuario>
```

**Ejemplo:**
```bash
/protector_add_member pepelomo
/protector_add_member maria_123
```

### ➖ Remover Miembros

**Método 1: Interfaz Gráfica**
1. Clic derecho en tu protector
2. Buscar el nombre en la lista de miembros
3. Clic en el botón "-" junto al nombre

**Método 2: Comando de Chat**
```bash
/protector_del_member <nombre_usuario>
```

**Ejemplo:**
```bash
/protector_del_member pepelomo
```

### 📊 Limitaciones de Miembros

- **Máximo**: 12 usuarios compartidos por protector
- **Solo propietario**: Puede añadir/quitar miembros
- **Miembros**: Tienen acceso completo al área protegida
- **Automático**: Los cambios se aplican inmediatamente

### 👤 Permisos de Miembros

**Los miembros autorizados pueden:**
- ✅ Romper y colocar bloques en el área
- ✅ Usar herramientas y items
- ✅ Abrir cofres y puertas protegidas
- ✅ Interactuar con todo el contenido del área
- ❌ **NO pueden**: Añadir/quitar otros miembros
- ❌ **NO pueden**: Romper el bloque protector

---

## 💬 Comandos de Chat

### 🎮 Comandos para Usuarios Normales

```bash
# Gestión de miembros
/protector_add_member <usuario>    # Añadir usuario a TU protector
/protector_del_member <usuario>    # Quitar usuario de TU protector

# Información (si está disponible)
/protector_show                    # Mostrar información de protecciones cercanas
```

### 🔧 Comandos de Administrador

Los administradores con privilegios especiales pueden usar:

```bash
# Gestión avanzada
/protector_remove <x,y,z>          # Eliminar protector en coordenadas específicas
/protector_show_area <x,y,z>       # Mostrar área protegida en coordenadas
/protector_replace <viejo> <nuevo> # Cambiar propietario de protectores

# Ejemplos de uso
/protector_remove 100,65,200       # Elimina protector en esas coordenadas
/protector_replace juan_viejo pedro # Cambia propietario de juan_viejo a pedro
```

### 🎯 Consejos para Comandos

- **Nombres exactos**: Los nombres de usuario deben ser exactos (case-sensitive)
- **Usuarios online**: Es recomendable que los usuarios estén conectados
- **Confirmación**: El servidor enviará mensajes de confirmación
- **Errores**: Si hay errores, el servidor explicará el problema

---

## 📏 Área de Protección

### 📐 Dimensiones

**Radio de Protección: 5 bloques**
- **Área total**: 11x11x11 bloques
- **Centro**: El bloque protector
- **Forma**: Cubo perfecto centrado en el protector

### 📊 Visualización del Área

**Al Colocar el Protector:**
- ✅ El área se muestra temporalmente con bloques semi-transparentes
- ✅ Duración: Aproximadamente 5 segundos
- ✅ Color: Generalmente verde o azul claro

**Verificar Área Existente:**
- Usa el "Protection Logo" como herramienta
- Clic derecho en cualquier bloque para verificar protección
- El sistema te dirá si está protegido y por quién

### 🗺️ Coordenadas de Ejemplo

Si colocas un protector en las coordenadas (100, 65, 200):

```
Área Protegida:
- X: desde 95 hasta 105 (100 ± 5)
- Y: desde 60 hasta 70  (65 ± 5)
- Z: desde 195 hasta 205 (200 ± 5)
```

### 🚫 Restricciones de Colocación

**No puedes colocar protectores:**
- ❌ Que se superpongan con otros protectores existentes
- ❌ Demasiado cerca del spawn protegido del servidor
- ❌ En áreas ya protegidas por otros jugadores

**Mensaje de Error:**
Si intentas colocar en área inválida, recibirás un mensaje explicando el problema.

---

## 🏠 Elementos Protegidos Especiales

### 📦 Cofres Protegidos

**Características:**
- **Disponibles**: Cofres específicamente protegidos
- **Funcionalidad**: Solo tú y tus miembros pueden abrirlos
- **Ubicación**: Se pueden colocar en cualquier lugar, no solo en áreas protegidas
- **Seguridad**: Doble protección (cofre + área)

### 🚪 Puertas Protegidas

**Tipos Disponibles:**
- Puertas de madera protegidas
- Puertas de acero protegidas
- Compuertas protegidas

**Funcionamiento:**
- Solo propietario y miembros pueden abrir/cerrar
- Se pueden colocar en áreas protegidas o independientemente
- Mantienen la funcionalidad normal de las puertas

### 🔒 Otros Elementos

El mod protector también puede incluir:
- **Hornos protegidos**
- **Cofres con nombres personalizados**
- **Elementos decorativos protegidos**

---

## 👑 Privilegios de Administrador

### 🔑 Privilegio `protection_bypass`

**Usuario "gabo" tiene este privilegio**, lo que significa:

- ✅ **Acceso total**: Puede modificar cualquier área protegida
- ✅ **Romper protectores**: Puede eliminar cualquier protector
- ✅ **Gestión completa**: Puede modificar propiedades de cualquier protección
- ✅ **Sin restricciones**: No está limitado por ninguna protección

### 🛠️ Herramientas de Administrador

**Comandos Administrativos:**
```bash
# Eliminar protector problemático
/protector_remove <x,y,z>

# Cambiar propietario (útil si un jugador se va)
/protector_replace <antiguo_usuario> <nuevo_usuario>

# Mostrar información detallada
/protector_show_area <x,y,z>
```

### 🚨 Uso Responsable

**Recomendaciones para Administradores:**
- 🎯 **Comunicación**: Avisa antes de modificar protecciones de otros
- 🎯 **Justificación**: Solo modifica cuando sea necesario
- 🎯 **Backup**: Considera hacer backup antes de cambios importantes
- 🎯 **Documentación**: Mantén registro de cambios administrativos

---

## 🔧 Resolución de Problemas

### ❓ Problema: "No encuentro los bloques protectores en el inventario"

**Soluciones:**
1. **Verificar modo creativo**: Asegúrate de estar en modo creativo
2. **Buscar correctamente**: Usa la búsqueda con "protection"
3. **Reiniciar cliente**: Cierra y abre Luanti
4. **Comando alternativo**: Usa `/give` si eres admin

### ❓ Problema: "No puedo colocar protector"

**Causas Posibles:**
- ❌ **Superposición**: Hay otro protector cerca
- ❌ **Spawn protegido**: Estás muy cerca del spawn
- ❌ **Área ocupada**: Otro jugador ya protege esa zona

**Solución:**
- Busca otra ubicación más alejada
- Verifica con el comando de verificación de área

### ❓ Problema: "El protector no funciona"

**Verificaciones:**
1. **Mod cargado**: Confirma que el mod está activo
2. **Propietario correcto**: Verifica que eres el propietario
3. **Área correcta**: Confirma que estás dentro del radio de 5 bloques
4. **Permisos**: Verifica los privilegios del usuario

### ❓ Problema: "No puedo añadir miembros"

**Posibles Causas:**
- ❌ **Límite alcanzado**: Ya tienes 12 miembros
- ❌ **Nombre incorrecto**: El usuario no existe o nombre mal escrito
- ❌ **No eres propietario**: Solo el propietario puede añadir miembros

### ❓ Problema: "Los miembros no pueden acceder"

**Verificaciones:**
1. **Lista de miembros**: Confirma que están añadidos correctamente
2. **Área correcta**: Verifica que están en el área protegida
3. **Reinicio**: A veces es necesario que el miembro se desconecte y reconecte

---

## 💡 Consejos y Mejores Prácticas

### 🎯 Planificación de Áreas

**Antes de colocar protectores:**
1. **Diseña tu construcción**: Planifica el tamaño total
2. **Calcula protectores necesarios**: Área 11x11x11 por protector
3. **Considera expansion**: Deja espacio para crecimiento futuro
4. **Ubicación estratégica**: Coloca en centros de áreas importantes

### 🏗️ Construcciones Grandes

**Para proteger áreas extensas:**
- **Múltiples protectores**: Coloca varios protectores separados
- **Patrón de rejilla**: Distribuye uniformemente
- **Superposición mínima**: Evita desperdiciar cobertura
- **Accesos controlados**: Planifica entradas y salidas

### 👥 Gestión de Equipos

**Para proyectos colaborativos:**
- **Comunicación clara**: Establece reglas de construcción
- **Roles definidos**: Decide quién puede añadir miembros
- **Áreas personales**: Cada miembro puede tener su área privada
- **Áreas comunes**: Protectores compartidos para espacios comunes

### 🎨 Estética y Diseño

**Integración visual:**
- **Protection Logo**: Usa el logo para protección discreta
- **Decoración**: Incorpora protectores en el diseño arquitectónico
- **Materiales coherentes**: Los protectores usan textura de piedra
- **Ubicación estratégica**: Coloca donde no interrumpan la vista

### 🔄 Mantenimiento

**Rutinas recomendadas:**
- **Revisión periódica**: Verifica que las protecciones sigan activas
- **Actualización de miembros**: Mantén las listas actualizadas
- **Limpieza**: Remueve protectores innecesarios
- **Backup**: Los admins pueden hacer backup de configuraciones

### 🌟 Casos de Uso Específicos

**Para Vegan Wetlands:**

1. **Santuarios de Animales:**
   - Protege áreas de animales pacíficos
   - Permite acceso a cuidadores específicos
   - Evita modificaciones accidentales

2. **Granjas Educativas:**
   - Protege cultivos de plantas educativas
   - Controla acceso para aprendizaje guiado
   - Preserva diseños educativos

3. **Construcciones Comunitarias:**
   - Protege estatuas y monumentos
   - Controla modificaciones en áreas públicas
   - Mantiene integridad de espacios educativos

4. **Áreas de Spawn Personal:**
   - Protege casas de jugadores
   - Crea espacios seguros para nuevos jugadores
   - Preserva construcciones personales

---

## 📚 Resumen Ejecutivo

### ✅ Puntos Clave

1. **Fácil Acceso**: Bloques disponibles directamente en inventario creativo
2. **Protección Completa**: Área de 11x11x11 bloques protegida totalmente
3. **Control Granular**: Hasta 12 miembros por protector
4. **Múltiples Tipos**: Bloque sólido y logo decorativo
5. **Administración Simple**: Comandos intuitivos y menú gráfico
6. **Sin Restricciones para Admins**: `protection_bypass` para administradores

### 🎯 Para Empezar Rápidamente

1. **Abre inventario** (`E`)
2. **Busca "protection"**
3. **Coloca protector** en centro de tu área
4. **Clic derecho** para configurar
5. **Añade miembros** según necesidad

### 📞 Soporte

**Si necesitas ayuda:**
- Pregunta a otros jugadores en el chat
- Contacta a los administradores
- Consulta esta documentación
- Experimenta en área segura primero

---

**🌱 ¡Protege tus construcciones y crea espacios seguros para toda la comunidad Vegan Wetlands!**

*Documentación actualizada para servidor Vegan Wetlands - Septiembre 2025*