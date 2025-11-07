# 🎨 WORLDEDIT TUTORIALS - CONSTRUCCIONES ESPECIALES

**Última actualización**: 7 de Noviembre, 2025
**Mod**: WorldEdit Commands
**Server**: Wetlands Luanti/VoxeLibre

Este documento contiene tutoriales paso a paso para crear construcciones especiales usando comandos de WorldEdit.

---

## 📋 Índice

1. [Árbol de Navidad Gigante](#árbol-de-navidad-gigante)
2. [Sintaxis General de Comandos](#sintaxis-general-de-comandos)
3. [Tips y Trucos](#tips-y-trucos)

---

## 🎄 Árbol de Navidad Gigante

### **Descripción**
Construcción de un árbol de Navidad gigante del porte de un edificio de 6 pisos (~48 bloques de altura) usando comandos de WorldEdit.

### **Materiales**
- **Tronco**: `mcl_core:sprucetree` (Tronco de Abeto)
- **Copa**: `mcl_core:spruceleaves` (Hojas de Abeto - verde oscuro navideño)

### **Dimensiones Finales**
- **Altura total**: ~48 bloques (equivalente a 6-7 pisos)
- **Tronco**: Radio 3 bloques, 18 bloques de alto
- **Copa**: Radio base 12 bloques, radio punta 1 bloque, 30 bloques de alto
- **Ancho total en base**: ~24 bloques de diámetro

### **Requisitos Previos**
1. Privilegio `worldedit` activado
2. Espacio libre mínimo: 50 bloques de alto x 25 bloques de ancho
3. Modo vuelo activado: `/fly`
4. Anotar coordenadas de inicio (opcional pero recomendado)

---

## 🛠️ Proceso de Construcción Paso a Paso

### **Paso 1: Preparación**

1. Párate en el lugar donde quieres la base del árbol (centro)
2. Activa modo vuelo si no lo tienes:
   ```
   /fly
   ```
3. Anota tus coordenadas actuales (opcional):
   ```
   /whereami
   ```

### **Paso 2: Crear el TRONCO**

1. Marca el punto base (centro inferior del tronco):
   ```
   //pos1
   ```

2. Crea el cilindro del tronco:
   ```
   //cylinder y 18 3 mcl_core:sprucetree
   ```

   **Desglose del comando**:
   - `//cylinder` = Comando para crear cilindro
   - `y` = Eje vertical (hacia arriba)
   - `18` = Altura del cilindro (bloques)
   - `3` = Radio del cilindro (bloques)
   - `mcl_core:sprucetree` = Material (tronco de abeto)

3. **Resultado**: Tronco de 3 bloques de radio x 18 bloques de alto

### **Paso 3: Posicionarse para la Copa**

1. Vuela hacia arriba hasta la cima del tronco (18 bloques desde la base)
2. Colócate justo encima del centro del tronco

### **Paso 4: Crear la COPA (Cónica)**

1. Marca el nuevo punto base (base de la copa):
   ```
   //pos1
   ```

2. Crea el cono de hojas:
   ```
   //cylinder y 30 12 1 mcl_core:spruceleaves
   ```

   **Desglose del comando**:
   - `//cylinder` = Comando para crear cilindro/cono
   - `y` = Eje vertical (hacia arriba)
   - `30` = Altura del cono (bloques)
   - `12` = Radio en la BASE (bloques) - la parte más ancha
   - `1` = Radio en la PUNTA (bloques) - la parte superior
   - `mcl_core:spruceleaves` = Material (hojas de abeto)

3. **Resultado**: Copa cónica de 12 bloques de radio base → 1 bloque de radio punta, 30 bloques de alto

### **Paso 5: Decoración Opcional**

#### **Opción A: Agregar "Luces" (Bloques Luminosos)**

Selecciona el área de la copa y reemplaza un porcentaje de hojas con piedra luminosa:

```
//pos1
//pos2
//replace mcl_core:spruceleaves 5% mcl_core:glowstone
```

Esto reemplazará el 5% de las hojas con piedra luminosa (efecto de luces navideñas).

#### **Opción B: Estrella en la Punta**

1. Vuela hasta la punta del árbol
2. Coloca un bloque de oro manualmente:
   ```
   /giveme mcl_core:goldblock 1
   ```
3. Coloca el bloque de oro en la cima

#### **Opción C: Decoraciones con Lana de Colores**

Agrega "adornos" de colores manualmente o con WorldEdit:

```
/giveme mcl_wool:red 64
/giveme mcl_wool:yellow 64
/giveme mcl_wool:blue 64
```

Coloca bloques de lana de colores estratégicamente en la copa.

---

## 🎯 Comando Completo Resumido

**Secuencia rápida**:
```
1. //pos1
2. //cylinder y 18 3 mcl_core:sprucetree
3. (vuela 18 bloques arriba)
4. //pos1
5. //cylinder y 30 12 1 mcl_core:spruceleaves
```

**Tiempo estimado**: 1-2 minutos

---

## 📐 Sintaxis General de Comandos

### **//cylinder (Cilindro / Cono)**

**Sintaxis completa**:
```
//cylinder <eje> <altura> <radio_base> [radio_punta] <nodo>
```

**Parámetros**:
- `<eje>`: `x`, `y`, `z`, o `?` (auto-detecta)
  - `x` = horizontal (este-oeste)
  - `y` = vertical (arriba-abajo) ← **Recomendado para árboles**
  - `z` = horizontal (norte-sur)
  - `?` = según la dirección donde mires

- `<altura>`: Número de bloques de altura

- `<radio_base>`: Radio en la base del cilindro

- `[radio_punta]`: (Opcional) Radio en la punta
  - Si se omite, crea cilindro perfecto (mismo radio arriba y abajo)
  - Si se especifica diferente, crea cono

- `<nodo>`: Nombre del bloque VoxeLibre (e.g., `mcl_core:sprucetree`)

**Ejemplos**:

```bash
# Cilindro perfecto de piedra (radio 5, altura 10)
//cylinder y 10 5 mcl_core:stone

# Cono de hojas (base radio 15, punta radio 2, altura 25)
//cylinder y 25 15 2 mcl_core:leaves

# Cilindro horizontal de madera (eje X)
//cylinder x 20 3 mcl_core:wood
```

### **//pyramid (Pirámide)**

**Sintaxis completa**:
```
//pyramid <eje> <altura> <nodo>
```

**Parámetros**:
- `<eje>`: `x`, `y`, `z`, o `?`
- `<altura>`: Altura de la pirámide
- `<nodo>`: Material de construcción

**Ejemplo**:
```bash
# Pirámide de ladrillos de 20 bloques de alto
//pyramid y 20 mcl_core:brick_block
```

### **//hollowcylinder (Cilindro Hueco)**

**Sintaxis**:
```
//hollowcylinder <eje> <altura> <radio_base> [radio_punta] <nodo>
```

**Útil para**: Torres, chimeneas, tubos

**Ejemplo**:
```bash
# Torre hueca de piedra (radio 5, altura 30)
//hollowcylinder y 30 5 mcl_core:cobble
```

---

## 💡 Tips y Trucos

### **1. Deshacer Errores**

Si algo sale mal, siempre puedes deshacer:
```
//undo
```

Y rehacer:
```
//rehacer
```

### **2. Verificar Posiciones Antes de Construir**

Marca tus posiciones y verifica:
```
//pos1    # Marca primera posición
//pos2    # Marca segunda posición (para cuboides)
//volume  # Muestra el volumen seleccionado
```

### **3. Altura Recomendada para Construcciones**

Para evitar obstrucciones:
- **Superficie**: Y = 10-20 (nivel del suelo normal)
- **Aérea**: Y = 80-100 (construcciones flotantes)
- **Subterránea**: Y = -10 a -50

### **4. Calcular Altura para Volar**

Si necesitas volar X bloques arriba desde la base:
1. Anota tu Y actual: `/whereami`
2. Suma la altura deseada
3. Teleportate: `/teleport <nombre> <x> <y_nuevo> <z>`

**Ejemplo**:
```
# Estás en Y=15, necesitas ir a Y=33 (15+18)
/teleport gabo 100 33 200
```

### **5. Materiales de Hojas en VoxeLibre**

**Nombres correctos de hojas**:
- `mcl_core:leaves` → Hojas de roble (verde claro)
- `mcl_core:spruceleaves` → Hojas de abeto (verde oscuro) ✅ **Recomendado para Navidad**
- `mcl_core:darkleaves` → Hojas de roble oscuro (verde muy oscuro)
- `mcl_core:jungleleaves` → Hojas de jungla (verde brillante)
- `mcl_core:acacialeaves` → Hojas de acacia (verde amarillento)
- `mcl_core:birchleaves` → Hojas de abedul (verde claro)

### **6. Materiales de Troncos en VoxeLibre**

**Nombres correctos de troncos**:
- `mcl_core:tree` → Tronco de roble
- `mcl_core:sprucetree` → Tronco de abeto ✅ **Recomendado para Navidad**
- `mcl_core:darktree` → Tronco de roble oscuro
- `mcl_core:jungletree` → Tronco de jungla
- `mcl_core:acaciatree` → Tronco de acacia
- `mcl_core:birchtree` → Tronco de abedul

### **7. Variaciones del Árbol de Navidad**

**Árbol Pequeño** (3 pisos):
```
//pos1
//cylinder y 9 2 mcl_core:sprucetree       # Tronco
(vuela 9 bloques arriba)
//pos1
//cylinder y 15 6 1 mcl_core:spruceleaves # Copa
```

**Árbol Mediano** (4-5 pisos):
```
//pos1
//cylinder y 12 2 mcl_core:sprucetree     # Tronco
(vuela 12 bloques arriba)
//pos1
//cylinder y 20 8 1 mcl_core:spruceleaves # Copa
```

**Árbol GIGANTE** (10 pisos):
```
//pos1
//cylinder y 30 5 mcl_core:sprucetree      # Tronco
(vuela 30 bloques arriba)
//pos1
//cylinder y 50 20 2 mcl_core:spruceleaves # Copa
```

### **8. Prevenir Errores Comunes**

❌ **Error**: "invalid node name"
✅ **Solución**: Verificar el nombre exacto del bloque
- Usa Tab para autocompletar en el chat
- Revisa logs del servidor cuando colocas bloques manualmente
- Prefijos comunes: `mcl_core:`, `mcl_farming:`, `mcl_wool:`

❌ **Error**: "invalid usage"
✅ **Solución**: Verificar el orden de parámetros
- El EJE siempre va primero en `//cylinder` y `//pyramid`
- Usa `//help <comando>` para ver sintaxis

❌ **Error**: "position 1 not set"
✅ **Solución**: Marcar posición antes de construir
```
//pos1
```

### **9. Construcciones Avanzadas**

**Torre con Base Ancha y Punta Estrecha**:
```
//pos1
//cylinder y 40 8 3 mcl_core:stonebrick
```

**Pirámide Escalonada**:
Crea múltiples pirámides una encima de otra con alturas decrecientes.

**Árbol con Múltiples Copas**:
Crea varias capas de copa con diferentes radios.

---

## 🎄 Galería de Construcciones

### **Árbol de Navidad Gigante - Configuración Confirmada**

**Especificaciones**:
- **Fecha de prueba**: 7 de Noviembre, 2025
- **Testeado por**: gabo
- **Resultado**: ✅ **ÉXITO CONFIRMADO**

**Comandos usados**:
```bash
//pos1
//cylinder y 18 3 mcl_core:sprucetree
# (volar 18 bloques arriba)
//pos1
//cylinder y 30 12 1 mcl_core:spruceleaves
```

**Dimensiones resultantes**:
- Altura total: ~48 bloques
- Tronco: 6 bloques de diámetro x 18 de alto
- Copa: 24 bloques de diámetro base → 2 bloques punta, 30 de alto
- Forma: Cono perfecto con proporción navideña

**Tiempo de construcción**: ~1 minuto
**Bloques generados**: ~4,000+ bloques

---

## 📚 Recursos Adicionales

### **Documentación Relacionada**
- [WORLDEDIT_SYSTEM.md](./WORLDEDIT_SYSTEM.md) - Sistema completo de WorldEdit
- [PVP_ARENA_WORLDEDIT_GUIDE.md](./PVP_ARENA_WORLDEDIT_GUIDE.md) - Uso de WorldEdit para arenas
- [MODDING_GUIDE.md](./MODDING_GUIDE.md) - Guía general de modding

### **Comandos de Ayuda en el Servidor**
```bash
//help              # Lista todos los comandos de WorldEdit
//help cylinder     # Ayuda específica del comando cylinder
//help pyramid      # Ayuda específica del comando pyramid
//about             # Información sobre WorldEdit instalado
```

### **Privilegios Necesarios**
Para usar WorldEdit necesitas el privilegio `worldedit`:
```bash
/privs <nombre>    # Ver privilegios actuales
```

Si no tienes el privilegio, pídelo a un administrador.

---

## 🚨 Troubleshooting

### **Problema: "You don't have permission to run this command"**
**Solución**: Necesitas privilegio `worldedit`. Pídelo a un admin.

### **Problema: "Position 1 not set"**
**Solución**: Siempre usa `//pos1` antes de construir.

### **Problema: "Invalid node name: mcl_core:leaves_dark_oak"**
**Solución**: El nombre correcto es `mcl_core:darkleaves` (sin guiones bajos intermedios).

### **Problema: El árbol quedó muy grande/pequeño**
**Solución**: Usa `//undo` y ajusta los valores de radio y altura.

### **Problema: El cono no se forma, queda como cilindro**
**Solución**: Asegúrate de especificar DOS radios diferentes:
```bash
//cylinder y 30 12 1 mcl_core:spruceleaves
                ^^  ^
              base punta
```

### **Problema: La construcción está en el lugar equivocado**
**Solución**:
1. Deshacer: `//undo`
2. Volar al lugar correcto
3. Marcar nueva posición: `//pos1`
4. Repetir construcción

---

## 📝 Notas Finales

- **Performance**: Construcciones muy grandes pueden causar lag temporal durante la generación
- **Servidor en producción**: Avisa a otros jugadores antes de construcciones masivas
- **Backup**: Para construcciones importantes, considera hacer backup del mundo primero
- **Creatividad**: Experimenta con diferentes materiales y proporciones

---

**Autor**: Gabriel Pantoja
**Servidor**: Wetlands Luanti/VoxeLibre
**Versión**: 1.0
**Última revisión**: 7 de Noviembre, 2025

¡Feliz construcción! 🎄✨