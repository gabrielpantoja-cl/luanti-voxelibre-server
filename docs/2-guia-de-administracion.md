# 🛠️ Guía de Administración del Servidor

Este documento es el manual de operaciones para los administradores de Vegan Wetlands. Contiene todos los procedimientos y comandos necesarios para la gestión, el mantenimiento y la solución de problemas del servidor.

---

## 1. Gestión de Jugadores

La gestión de jugadores se realiza principalmente a través de comandos en el juego, pero también es posible acceder a la base de datos de jugadores directamente en caso de emergencia.

### 1.1. Listar Todos los Jugadores Registrados

Para obtener una lista completa de todos los usuarios que alguna vez se han registrado, ejecuta el siguiente comando en la terminal del VPS, desde la carpeta raíz del proyecto:

```bash
docker-compose exec luanti-server sh -c 'cat /config/.minetest/worlds/vegan_wetlands/auth.txt | cut -d: -f1'
```
Esto te dará una lista limpia de nombres de usuario.

### 1.2. Gestión de Privilegios

La forma más segura de gestionar los privilegios es mediante comandos en el juego.

*   **Otorgar privilegio:** `/grant <jugador> <privilegio>`
*   **Revocar privilegio:** `/revoke <jugador> <privilegio>`
*   **Ver privilegios:** `/privs <jugador>`

**Privilegios Comunes:**
*   `creative`: Activa el modo creativo.
*   `fly`: Permite volar.
*   `fast`: Permite moverse rápido.
*   `noclip`: Permite atravesar paredes.
*   `teleport`: Permite usar el comando `/teleport`.
*   `server`: Acceso a todos los comandos de administrador.

### 1.3. Edición Manual de `auth.txt` (Emergencia)

Si un administrador pierde sus privilegios o no puede acceder al juego, se pueden editar manualmente. **ADVERTENCIA:** Un error aquí puede dañar el archivo de jugadores.

1.  **Detén el servidor:** `docker-compose down`
2.  **Edita el archivo:** `server/worlds/vegan_wetlands/auth.txt`
3.  **Modifica la línea del jugador:** El formato es `nombre:hash:priv1,priv2`.
4.  **Reinicia el servidor:** `docker-compose up -d`

---

## 2. Sistema de Backups y Recuperación

El servidor cuenta con un **sistema de backups automatizado** robusto.

*   **Frecuencia:** Se crea un backup completo del mundo **cada 6 horas**.
*   **Ubicación:** Los archivos `.tar.gz` se guardan en `server/backups/`.
*   **Retención:** Se conservan los 10 backups más recientes.

### 2.1. Verificar el Estado de los Backups

Conéctate al VPS, navega a la carpeta del proyecto y ejecuta:
```bash
ls -lh server/backups/
```
Deberías ver una lista de backups, con el más reciente teniendo menos de 6 horas de antigüedad.

### 2.2. Procedimiento de Restauración

1.  **Detén el servidor:** `docker-compose down`
2.  **Respalda el mundo dañado:** `mv server/worlds/vegan_wetlands server/worlds/vegan_wetlands_DAÑADO`
3.  **Crea una carpeta nueva:** `mkdir server/worlds/vegan_wetlands`
4.  **Descomprime el backup:** `tar -xzf server/backups/NOMBRE_DEL_BACKUP.tar.gz -C server/worlds/vegan_wetlands/`
5.  **Reinicia el servidor:** `docker-compose up -d`

---

## 3. Comandos de Administración Esenciales

Aquí tienes una lista consolidada de los comandos más útiles.

| Comando | Descripción | Ejemplo |
|---|---|---|
| `/teleport <jugador> <x,y,z>` | Teletransporta a un jugador a coordenadas. | `/tp gabo 0 100 0` |
| `/bring <jugador>` | Trae un jugador a tu posición. | `/bring pepito` |
| `/time <0-24000>` | Cambia la hora del servidor. | `/time 6000` (mediodía) |
| `/weather <clear/rain>` | Cambia el clima. | `/weather clear` |
| `/clearobjects` | Elimina todos los objetos sueltos (items en el suelo). Útil para reducir el lag. | `/clearobjects` |
| `/shutdown` | Apaga el servidor. | `/shutdown` |
| `/kick <jugador> [razón]` | Expulsa a un jugador. | `/kick troll_1 Por molestar` |
| `/ban <jugador>` | Banea permanentemente a un jugador. | `/ban troll_1` |
| `/unban <jugador>` | Desbanea a un jugador. | `/unban troll_1` |
| `/mute <jugador>` | Silencia a un jugador en el chat. | `/mute spammer` |

---

## 4. Solución de Problemas Comunes

### 4.1. Problema: Monstruos aparecen en el servidor

*   **Contexto Histórico:** En el pasado, VoxeLibre a veces ignoraba las configuraciones `peaceful_mode` o `mobs_spawn = false` en `luanti.conf`.
*   **Síntoma:** Aparecen Creepers, Zombies, etc., contradiciendo la filosofía del servidor.
*   **Solución Inmediata (Comandos en el juego):**
    1.  **Forzar el día:** `/time 6000` (reduce el spawn de monstruos).
    2.  **Eliminar entidades existentes:** `/clearobjects` (esto elimina mobs hostiles que ya hayan aparecido).
*   **Solución Permanente (Configuración):**
    La configuración correcta en `luanti.conf` para deshabilitar monstruos en VoxeLibre es una combinación de varias claves. Asegúrate de que las siguientes estén presentes y activadas:
    ```ini
    # Configuración Anti-Monstruos para VoxeLibre
    only_peaceful_mobs = true
    mobs_spawn = false
    mcl_mob_cap_hostile = 0
    mcl_mob_cap_monster = 0
    mcl_spawn_monsters = false
    enable_damage = false
    ```
    Si el problema persiste, puede ser necesario crear un mod simple que elimine activamente las entidades hostiles como un seguro adicional.
