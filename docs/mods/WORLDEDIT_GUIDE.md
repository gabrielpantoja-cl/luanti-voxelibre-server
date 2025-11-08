
# 🛠️ WorldEdit Guide - Guía Completa para Wetlands

**Servidor**: Wetlands 🌱 Luanti/VoxeLibre
**Fecha de Unificación**: 8 de Noviembre 2025
**Autor**: Gabriel Pantoja (gabo)
**Versión**: 2.0.0

---

Este documento es la guía maestra para el uso de **WorldEdit** en el servidor de Wetlands. Unifica la documentación técnica, guías de comandos y tutoriales prácticos en un solo lugar para facilitar la consulta y el mantenimiento.

---

## 📋 Índice

1.  [Arquitectura del Sistema WorldEdit](#-arquitectura-del-sistema-worldedit)
2.  [Guía de Comandos Esenciales](#-guía-de-comandos-esenciales)
3.  [Tutoriales Prácticos](#-tutoriales-prácticos)
    *   [Árbol de Navidad Gigante](#-árbol-de-navidad-gigante)
4.  [Configuración del Servidor](#-configuración-del-servidor)
5.  [Troubleshooting y Errores Comunes](#-troubleshooting-y-errores-comunes)
6.  [Bloques Comunes de VoxeLibre](#-bloques-comunes-de-voxelibre)
7.  [Referencias](#-referencias)

---

## 🏗️ Arquitectura del Sistema WorldEdit

WorldEdit está compuesto por **5 mods modulares** que trabajan en conjunto para proporcionar una potente suite de edición de mundos.

```
worldedit (mod base)
    ├── worldedit_commands (comandos de chat)
    │   ├── worldedit_shortcommands (atajos)
    │   └── worldedit_gui (interfaz gráfica)
    └── worldedit_brush (pinceles)
```

### 1. `worldedit` - Mod Base (Core API)

*   **Responsabilidad**: Proporciona la API central, manipulación de regiones, sistema de selección, funciones geométricas, y el sistema de deshacer/rehacer.
*   **Ubicación**: `server/mods/worldedit/`
*   **Dependencias**: Ninguna.

### 2. `worldedit_commands` - Comandos de Chat

*   **Responsabilidad**: Implementa todos los comandos de chat (`//pos1`, `//set`, etc.).
*   **Ubicación**: `server/mods/worldedit_commands/`
*   **Dependencias**: `worldedit`.

### 3. `worldedit_shortcommands` - Atajos de Comandos

*   **Responsabilidad**: Proporciona atajos más cortos para comandos frecuentes (e.g., `/1` en vez de `//pos1`).
*   **Ubicación**: `server/mods/worldedit_shortcommands/`
*   **Dependencias**: `worldedit_commands`.
*   **✅ IMPORTANTE**: En Wetlands usamos `worldedit_shortcommands`, por lo tanto los comandos llevan **una sola barra** (`/`) en vez de doble (`//`).

### 4. `worldedit_gui` - Interfaz Gráfica

*   **Responsabilidad**: Proporciona una interfaz gráfica para WorldEdit.
*   **Ubicación**: `server/mods/worldedit_gui/`
*   **Estado en Wetlands**: ❌ **Deshabilitado**, ya que no es necesario para un servidor.

### 5. `worldedit_brush` - Pinceles de Edición

*   **Responsabilidad**: Herramientas de pincel para editar el mundo (esferas, cilindros, etc.).
*   **Ubicación**: `server/mods/worldedit_brush/`
*   **Dependencias**: `worldedit`, `worldedit_commands`.

### Flujo de Ejecución de un Comando

Un comando como `/set mcl_core:sandstone` sigue este flujo:
1.  El jugador ejecuta el comando.
2.  `worldedit_shortcommands` lo intercepta y traduce a `//set mcl_core:sandstone`.
3.  `worldedit_commands` procesa el comando `//set`.
4.  La API de `worldedit` es llamada para modificar los bloques en el mundo.
5.  La operación se guarda en el historial para poder usar `/undo`.
6.  El jugador recibe una confirmación.

---

## 🎯 Guía de Comandos Esenciales

### Sintaxis General

Gracias a `worldedit_shortcommands`, la sintaxis en Wetlands es simple:
`/comando <parámetros>`

### Comandos de Selección

| Comando | Descripción | Ejemplo |
| :--- | :--- | :--- |
| `/1` | Marcar posición 1 (donde estás parado). | `/1` |
| `/2` | Marcar posición 2 (donde estás parado). | `/2` |
| `/1 <x,y,z>` | Marcar posición 1 en coordenadas específicas. | `/1 41,22,232` |
| `/2 <x,y,z>` | Marcar posición 2 en coordenadas específicas. | `/2 66,22,257` |
| `/volume` | Ver el volumen de la región seleccionada. | `/volume` |

### Comandos de Modificación

| Comando | Descripción | Ejemplo |
| :--- | :--- | :--- |
| `/set <nodo>` | Rellenar la región seleccionada con un bloque. | `/set mcl_core:sandstone` |
| `/replace <viejo> <nuevo>` | Reemplazar un tipo de bloque por otro. | `/replace mcl_core:stone mcl_core:cobble` |
| `/set air` | Vaciar la región (eliminar todos los bloques). | `/set air` |

### Comandos de Formas Geométricas

| Comando | Descripción | Sintaxis |
| :--- | :--- | :--- |
| `/cylinder` | Cilindro sólido o cono. | `/cylinder <eje> <altura> <radio_base> [radio_punta] <nodo>` |
| `/hollowcylinder` | Cilindro hueco o cono hueco. | `/hollowcylinder <eje> <altura> <radio_base> [radio_punta] <nodo>` |
| `/sphere` | Esfera sólida. | `/sphere <radio> <nodo>` |
| `/hollowsphere` | Esfera hueca. | `/hollowsphere <radio> <nodo>` |
| `/pyramid` | Pirámide sólida. | `/pyramid <eje> <altura> <nodo>` |

**Ejes válidos**: `x`, `y`, `z`. El más común es `y` para construcciones verticales.

### Comandos de Utilidades

| Comando | Descripción |
| :--- | :--- |
| `/undo` | Deshacer la última operación de WorldEdit. |
| `/redo` | Rehacer una operación deshecha. |
| `/clearhistory` | Limpiar el historial de cambios. |

---

## 🎨 Tutoriales Prácticos

### 🎄 Árbol de Navidad Gigante

Este tutorial te guiará para construir un árbol de Navidad de aproximadamente 48 bloques de altura.

**Materiales**:
*   **Tronco**: `mcl_core:sprucetree` (Tronco de Abeto)
*   **Copa**: `mcl_core:spruceleaves` (Hojas de Abeto)

#### Paso 1: Preparación
1.  Ve al lugar donde quieres la base del árbol.
2.  Activa el modo vuelo: `/fly`.

#### Paso 2: Crear el Tronco
1.  Marca el punto central de la base:
    ```bash
    /1
    ```
2.  Crea el cilindro del tronco (18 bloques de alto, 3 de radio):
    ```bash
    /cylinder y 18 3 mcl_core:sprucetree
    ```

#### Paso 3: Crear la Copa Cónica
1.  Vuela hasta la cima del tronco que acabas de crear (18 bloques hacia arriba).
2.  Párate justo en el centro y marca la nueva posición base para la copa:
    ```bash
    /1
    ```
3.  Crea el cono de hojas (30 de alto, radio base 12, radio punta 1):
    ```bash
    /cylinder y 30 12 1 mcl_core:spruceleaves
    ```

¡Listo! Ahora tienes un árbol de Navidad gigante. Si cometes un error, simplemente usa `/undo`.

#### Decoración Opcional
*   **Añadir luces**: Reemplaza un pequeño porcentaje de hojas por bloques luminosos.
    ```bash
    # Selecciona el área de la copa con /1 y /2
    /replace mcl_core:spruceleaves 5% mcl_core:glowstone
    ```
*   **Estrella en la punta**: Vuela a la cima y coloca manualmente un `mcl_core:goldblock`.

---

## 🔧 Configuración del Servidor

La configuración de WorldEdit se gestiona en `server/config/luanti.conf`.

```ini
# Asegúrate de que los mods de WorldEdit estén habilitados
load_mod_worldedit = true
load_mod_worldedit_commands = true
load_mod_worldedit_shortcommands = true
load_mod_worldedit_brush = true
# load_mod_worldedit_gui = false # Deshabilitado para el servidor

# Tamaño del historial de deshacer/rehacer
worldedit_history_size = 50

# Mods confiables (necesario para ciertas operaciones)
secure.trusted_mods = worldedit

# Privilegios de administrador (debe incluir worldedit)
admin_privs = server,privs,ban,kick,teleport,give,settime,worldedit,fly,fast,noclip,debug,password,rollback_check
```

---

## 🐛 Troubleshooting y Errores Comunes

| Problema | Síntoma / Mensaje | Causa | Solución |
| :--- | :--- | :--- | :--- |
| **Comando no reconocido** | `Unknown command: /1` | `worldedit_shortcommands` no está cargado. | Usa la sintaxis con doble barra (`//pos1`) o verifica la configuración del servidor. |
| **Sin permisos** | `You don't have permission...` | Tu usuario no tiene el privilegio `worldedit`. | Pide a un administrador que te otorgue el privilegio con `/grant <nombre> worldedit`. |
| **Región no seleccionada** | `No region selected` | No has marcado una posición con `/1` (y `/2` si es necesario). | Usa `/1` para marcar la primera posición antes de ejecutar comandos de forma. |
| **Bloque no existe** | `Invalid node name: default:sandstone` | Estás usando un nombre de bloque de Minetest vanilla. | Usa el nombre de bloque equivalente de VoxeLibre (`mcl_core:sandstone`). |
| **Operación muy lenta** | El servidor se congela por varios segundos. | La operación es demasiado grande (ej: >100,000 bloques). | Divide la operación en partes más pequeñas o espera a que termine. |
| **El cono no se forma** | La forma es un cilindro en lugar de un cono. | Solo especificaste un radio en el comando `/cylinder`. | Asegúrate de especificar dos radios diferentes: `... <radio_base> <radio_punta> ...`. |

---

## 📚 Bloques Comunes de VoxeLibre

| Categoría | Bloques de Ejemplo |
| :--- | :--- |
| **Construcción** | `mcl_core:stone`, `mcl_core:cobble`, `mcl_core:stonebrick`, `mcl_core:sandstone` |
| **Maderas** | `mcl_core:tree` (roble), `mcl_core:sprucetree` (abeto), `mcl_core:birchtree` (abedul) |
| **Hojas** | `mcl_core:leaves` (roble), `mcl_core:spruceleaves` (abeto), `mcl_core:birchleaves` (abedul) |
| **Vallas** | `mcl_fences:fence` (madera), `mcl_fences:nether_brick_fence` (ladrillo del Nether) |
| **Iluminación** | `mcl_torches:torch`, `mcl_lanterns:lantern_floor`, `mcl_core:glowstone` |
| **Vidrio** | `mcl_core:glass`, `mcl_core:glass_red`, `mcl_core:glass_black` |
| **Utilidades** | `air` (para eliminar bloques) |

---

## 📖 Referencias

*   **WorldEdit GitHub**: [https://github.com/Uberi/Minetest-WorldEdit](https://github.com/Uberi/Minetest-WorldEdit)
*   **WorldEdit Wiki**: [https://github.com/Uberi/Minetest-WorldEdit/wiki](https://github.com/Uberi/Minetest-WorldEdit/wiki)
*   **VoxeLibre en ContentDB**: [https://content.luanti.org/packages/Wuzzy/mineclone2/](https://content.luanti.org/packages/Wuzzy/mineclone2/)
*   **Ayuda en el juego**: Usa `/help` o `/help <comando>` para obtener ayuda directamente en el servidor.
