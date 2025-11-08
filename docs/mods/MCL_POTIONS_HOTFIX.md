
# 🩹 MCL Potions Hotfix - Documentación Técnica

**Mod**: `mcl_potions_hotfix`
**Fecha**: 8 de Noviembre, 2025
**Autor**: Equipo de Wetlands (gabo)
**Versión**: 1.0.0

---

## 📋 Índice

1.  [Propósito del Mod](#-propósito-del-mod)
2.  [El Problema: Crash por Pociones de Invisibilidad](#-el-problema-crash-por-pociones-de-invisibilidad)
3.  [La Solución Implementada](#-la-solución-implementada)
    *   [1. Ocultar Pociones del Inventario](#1-ocultar-pociones-del-inventario)
    *   [2. Parchear la Función `make_invisible`](#2-parchear-la-función-make_invisible)
    *   [3. Limpieza de Entidades Existentes](#3-limpieza-de-entidades-existentes)
    *   [4. Notificación a Administradores](#4-notificación-a-administradores)
4.  [Dependencias y Carga](#-dependencias-y-carga)
5.  [Cómo Verificar que el Mod Funciona](#-cómo-verificar-que-el-mod-funciona)
6.  [Consideraciones a Futuro](#-consideraciones-a-futuro)

---

## 🚨 Propósito del Mod

El mod `mcl_potions_hotfix` es un parche de emergencia diseñado para solucionar un **crash crítico** del servidor relacionado con las **pociones de invisibilidad** del mod `mcl_potions` en la versión 0.90.1 de VoxeLibre.

Su única función es estabilizar el servidor previniendo la causa raíz del error, sin añadir nuevas características.

## 🐛 El Problema: Crash por Pociones de Invisibilidad

En la versión `0.90.1` de VoxeLibre, el uso o la interacción con cualquier poción de invisibilidad (normal, arrojadiza, persistente, etc.) causa un crash irrecuperable del servidor.

El log de errores muestra el siguiente mensaje:
```
ERROR: ... attempt to index local 'luaentity' (a nil value) in functions.lua:1717
```

Esto ocurre porque la función `mcl_potions.make_invisible` intenta acceder a una propiedad de un objeto que es nulo (`nil`) bajo ciertas condiciones, deteniendo abruptamente el servidor.

## 🛠️ La Solución Implementada

El hotfix ataca el problema desde cuatro ángulos para asegurar la estabilidad del servidor.

### 1. Ocultar Pociones del Inventario

Para prevenir que los jugadores obtengan y usen estas pociones, el mod las elimina del inventario creativo.

*   **Acción**: Añade el grupo `not_in_creative_inventory = 1` a todas las variantes de pociones de invisibilidad.
*   **Pociones Afectadas**:
    *   `mcl_potions:invisibility`
    *   `mcl_potions:invisibility_plus`
    *   `mcl_potions:invisibility_splash`
    *   `mcl_potions:invisibility_plus_splash`
    *   `mcl_potions:invisibility_lingering`
    *   `mcl_potions:invisibility_plus_lingering`
    *   `mcl_potions:invisibility_arrow`
*   **Feedback Visual**: El mod también añade el sufijo `[DESHABILITADA - Bug conocido]` a la descripción de cada poción.

### 2. Parchear la Función `make_invisible`

Este es el núcleo del hotfix. El mod sobrescribe la función original `mcl_potions.make_invisible` con una versión "nil-safe".

*   **Lógica del Parche**:
    1.  Guarda una referencia a la función original.
    2.  Crea una nueva función que, antes de hacer nada, valida que el objeto (`obj`) y su `luaentity` no sean nulos.
    3.  Si alguna validación falla, registra un `warning` en el log y detiene la ejecución de forma segura.
    4.  Si todas las validaciones pasan, llama a la función original con los parámetros correctos.

*   **Resultado**: Incluso si una poción de invisibilidad lograra ser activada, el parche evitaría el crash del servidor.

### 3. Limpieza de Entidades Existentes

Para solucionar el problema de pociones que ya existían en el mundo antes de activar el mod, se implementó un limpiador global.

*   **Acción**: Un `globalstep` se ejecuta periódicamente y escanea todos los objetos del mundo en un radio de 32,000 bloques.
*   **Lógica**: Si encuentra una entidad cuyo nombre contiene la palabra `"invisibility"`, la elimina inmediatamente (`obj:remove()`) y registra un `warning` en el log.
*   **Impacto**: Previene que pociones "abandonadas" en el mundo puedan ser recogidas o activadas por accidente.

### 4. Notificación a Administradores

Para asegurar que los administradores estén al tanto de la situación, el mod envía un mensaje de advertencia en el chat al unirse al servidor.

*   **Condición**: El mensaje solo se envía a jugadores con el privilegio `server`.
*   **Mensaje**: `⚠️ [Hotfix Activo] Pociones de invisibilidad deshabilitadas por bug conocido de VoxeLibre`
*   **Propósito**: Informar sobre el estado del parche y por qué ciertas pociones no están disponibles.

---

## ⚙️ Dependencias y Carga

*   **Nombre del Mod**: `mcl_potions_hotfix`
*   **Dependencias**: `mcl_potions`
*   **Carga**: Este mod debe cargarse **después** de `mcl_potions` para poder sobrescribir su funcionalidad correctamente. El sistema de dependencias de Luanti se encarga de esto automáticamente.

---

## ✅ Cómo Verificar que el Mod Funciona

1.  **Revisar el Log del Servidor**: Al iniciar, el log debe mostrar mensajes de `[mcl_potions_hotfix]`, como "Poción ocultada" y "Función make_invisible parcheada exitosamente".
2.  **Buscar en el Inventario Creativo**: Abre el inventario en modo creativo y busca "invisibility" o "invisibilidad". No debería aparecer ninguna poción.
3.  **Mensaje de Admin**: Si tienes privilegios de `server`, deberías ver el mensaje de advertencia en el chat al conectarte.

---

## 🔮 Consideraciones a Futuro

*   **Monitoreo de Actualizaciones**: Este hotfix es una medida temporal. Se debe monitorear cada nueva versión de VoxeLibre o `mcl_potions` para ver si el bug original ha sido resuelto.
*   **Desactivación del Mod**: Si una futura actualización de VoxeLibre corrige el bug, este mod debería ser **desactivado y eliminado** para restaurar la funcionalidad completa de las pociones de invisibilidad.
*   **No Extender**: Este mod no debe ser modificado para añadir nuevas funcionalidades. Su propósito es únicamente ser un parche.
