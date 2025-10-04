# Sistema de Protección de Áreas - Servidor Wetlands

**Última actualización:** 2025-10-03 21:00 UTC
**Estado del sistema:** ✅ ACTIVO - Todos los usuarios habilitados

---

## 🎯 Estado Actual del Sistema

### ✅ Configuración de Protección Completada

**Fecha de implementación:** 2025-10-03
**Sistema de protección:** VoxeLibre Protection + Areas Mod

**Privilegios otorgados a TODOS los usuarios:**
- ✅ `areas` - Crear y gestionar áreas protegidas
- ✅ `areas_high_limit` - Límite ampliado de áreas

**Nuevos usuarios:**
- ✅ Reciben privilegios automáticamente al registrarse
- ✅ Configurado en `luanti.conf` línea 27

---

## 📊 Estado de Áreas Protegidas

### Áreas Actualmente Protegidas

**Total de áreas protegidas:** 0

**Estado:** ❌ No hay áreas protegidas todavía

**Motivo:** Los privilegios se acaban de otorgar. Los usuarios aún no han creado áreas protegidas.

**Próximos pasos:**
1. Informar a los usuarios sobre los nuevos comandos disponibles
2. Crear tutorial en el juego con `/ayuda_proteccion`
3. Proteger áreas críticas como el spawn

---

## 🛡️ Comandos Disponibles para Usuarios

### Comandos Básicos de Protección

Todos los usuarios pueden usar estos comandos:

```bash
# Marcar área para protección
/area_pos1          # Marcar esquina 1 (donde estás parado)
/area_pos2          # Marcar esquina 2 (donde estás parado)

# Crear protección
/protect <nombre>   # Proteger área entre pos1 y pos2
/protect mi_casa    # Ejemplo: proteger tu casa

# Gestionar áreas
/list_areas         # Ver todas tus áreas protegidas
/area_open <id>     # Abrir área para que otros puedan interactuar
/area_close <id>    # Cerrar área (solo tú puedes modificar)

# Gestionar permisos
/add_owner <id> <usuario>     # Añadir co-propietario
/remove_owner <id> <usuario>  # Remover co-propietario
```

### Comandos Alternativos (VoxeLibre Protection)

Para usuarios con privilegio `server` (admin):

```bash
# Marcar posiciones
/pos1               # Marcar esquina 1
/pos2               # Marcar esquina 2

# Protección avanzada
/protect_area <nombre>              # Proteger área entre pos1 y pos2
/protect_here <radio> <nombre>      # Proteger área circular alrededor
/protect_here 50 spawn_principal    # Proteger 50 bloques alrededor

# Gestión
/list_areas         # Listar todas las áreas
/unprotect_area <nombre>  # Eliminar protección
```

---

## 📝 Tutorial: Cómo Proteger Tu Casa

### Método 1: Protección Manual (Recomendado para áreas irregulares)

**Paso 1: Ir a una esquina de tu construcción**
```
Párate en una esquina de tu casa, en el suelo
```

**Paso 2: Marcar primera posición**
```
/area_pos1
```
Verás un mensaje: "Posición 1 establecida en (X, Y, Z)"

**Paso 3: Ir a la esquina opuesta**
```
Camina a la esquina diagonal opuesta de tu casa
Incluye toda la altura (desde el suelo hasta el techo)
```

**Paso 4: Marcar segunda posición**
```
/area_pos2
```
Verás un mensaje: "Posición 2 establecida en (X, Y, Z)"

**Paso 5: Crear la protección**
```
/protect mi_casa
```
Verás un mensaje: "Área 'mi_casa' protegida con éxito"

**Paso 6: Verificar**
```
/list_areas
```
Deberías ver tu área listada con su ID, nombre y tamaño

### Método 2: Protección Rápida (Solo Admin)

**Para administradores con privilegio `server`:**

```bash
# Ir al centro de tu construcción
/protect_here 20 mi_casa_principal
```

Esto protegerá un área de 20 bloques de radio alrededor de donde estás parado.

---

## 🔍 Ejemplos de Uso

### Ejemplo 1: Proteger una Casa Pequeña

```bash
# Usuario se para en esquina suroeste de su casa
/area_pos1
# Mensaje: Posición 1: (100, 64, 200)

# Usuario camina a esquina noreste, incluyendo techo
/area_pos2
# Mensaje: Posición 2: (110, 70, 210)

# Usuario crea la protección
/protect casa_lulu
# Mensaje: Área 'casa_lulu' protegida (ID: 1, Tamaño: 10x6x10)

# Verificar
/list_areas
# Mensaje: ID 1: casa_lulu - (100,64,200) a (110,70,210)
```

### Ejemplo 2: Proteger una Granja

```bash
/area_pos1
# En esquina de la granja

/area_pos2
# En esquina opuesta

/protect granja_trigo
# Área protegida exitosamente
```

### Ejemplo 3: Compartir Área con Amigos

```bash
# Listar tus áreas para ver el ID
/list_areas
# Mensaje: ID 1: casa_lulu - (100,64,200) a (110,70,210)

# Añadir amigo como co-propietario
/add_owner 1 jutaro
# Mensaje: jutaro añadido como propietario del área 1

# Ahora jutaro también puede modificar bloques en el área
```

### Ejemplo 4: Abrir Área Temporalmente

```bash
# Abrir área para que todos puedan interactuar
/area_open 1
# Mensaje: Área 1 abierta al público

# Cerrar área de nuevo
/area_close 1
# Mensaje: Área 1 cerrada - solo propietarios pueden modificar
```

---

## ⚙️ Configuración del Sistema

### Límites de Protección por Usuario

**Límites actuales:**
- **Usuarios con `areas`**: Hasta 10 áreas protegidas
- **Usuarios con `areas_high_limit`**: Hasta 50 áreas protegidas
- **Tamaño máximo por área**: 64x64x64 bloques (configurable)
- **Tamaño total permitido**: Ilimitado (con `areas_high_limit`)

**Todos los usuarios actuales tienen `areas_high_limit` ✅**

### Privilegios Requeridos

| Comando | Privilegio Requerido | Todos los usuarios |
|---------|---------------------|-------------------|
| `/area_pos1`, `/area_pos2` | `areas` | ✅ Sí |
| `/protect` | `areas` | ✅ Sí |
| `/list_areas` | `areas` | ✅ Sí |
| `/add_owner`, `/remove_owner` | `areas` | ✅ Sí |
| `/area_open`, `/area_close` | `areas` | ✅ Sí |
| `/pos1`, `/pos2`, `/protect_area` | `server` | ❌ Solo admin |
| `/protect_here` | `server` | ❌ Solo admin |
| `/protection_bypass` | `protection_bypass` | ❌ Solo admin/especial |

---

## 🚨 Áreas Críticas que Requieren Protección

### Prioridad ALTA

#### 1. Spawn Principal
- **Ubicación:** (0, 15, 0)
- **Radio recomendado:** 50-100 bloques
- **Estado:** ❌ SIN PROTEGER
- **Comando sugerido (admin):**
  ```bash
  /spawn
  /protect_here 50 spawn_principal
  ```

#### 2. Estructuras Comunitarias
- **Edificios públicos:** Tutorial hall, marketplace
- **Caminos principales:** Rutas entre spawn y zonas de construcción
- **Estado:** ❌ SIN PROTEGER
- **Acción requerida:** Marcar y proteger con `/protect`

### Prioridad MEDIA

#### 3. Zonas de Recursos Compartidos
- **Granjas comunitarias:** Trigo, zanahoria, papa
- **Bosques replantados:** Áreas de tala sostenible
- **Estado:** ❌ SIN PROTEGER
- **Acción:** Configurar con `/area_open` para uso público

#### 4. Caminos y Rutas
- **Caminos principales:** Conexiones entre casas
- **Puentes y túneles:** Infraestructura compartida
- **Estado:** ❌ SIN PROTEGER

---

## 📊 Monitoreo y Estadísticas

### Estadísticas Actuales (2025-10-03)

**Protecciones por usuario:**
- gabo: 0 áreas
- pepelomo: 0 áreas
- veight: 0 áreas
- gaelsin: 0 áreas
- Gapi: 0 áreas
- pepelomoomomomo: 0 áreas
- lulu: 0 áreas
- lulululuo: 0 áreas
- jutaro2010: 0 áreas
- jutaro: 0 áreas
- lulululuo0000: 0 áreas

**Total de bloques protegidos:** 0
**Áreas públicas (abiertas):** 0
**Áreas privadas (cerradas):** 0

### Comandos de Monitoreo (Admin)

```bash
# Ver todas las áreas del servidor
ssh gabriel@<VPS_IP> "cd /home/gabriel/Vegan-Wetlands && docker compose exec -T luanti-server sqlite3 /config/.minetest/worlds/world/world.sqlite 'SELECT * FROM areas;'"

# Listar archivos de protección
ssh gabriel@<VPS_IP> "cd /home/gabriel/Vegan-Wetlands && docker compose exec -T luanti-server find /config/.minetest/worlds/world -name '*areas*' -o -name '*protect*'"
```

---

## 🔧 Troubleshooting

### Problemas Comunes

#### Error: "Unknown command 'area_pos1'"
**Causa:** Mod `areas` no está cargado correctamente
**Solución:**
```bash
# Verificar que el mod está activo
docker compose exec luanti-server grep -i "areas" /config/.minetest/debug.txt

# Verificar privilegios del usuario
/privs <usuario>
```

#### Error: "You don't have permission"
**Causa:** Usuario no tiene privilegio `areas`
**Solución (admin):**
```bash
/grant <usuario> areas
/grant <usuario> areas_high_limit
```

#### Error: "Area limit reached"
**Causa:** Usuario alcanzó límite de áreas (10 sin `areas_high_limit`)
**Solución (admin):**
```bash
/grant <usuario> areas_high_limit
```

#### No puedo proteger área grande
**Causa:** Límite de tamaño de área
**Solución:** Dividir en áreas más pequeñas o solicitar `areas_high_limit` al admin

### Verificación del Sistema

```bash
# Verificar que el mod areas está cargado
docker compose logs luanti-server | grep -i "areas"

# Ver configuración de luanti.conf
grep -i "areas\|protect" server/config/luanti.conf

# Listar mods activos relacionados con protección
docker compose exec luanti-server ls -la /config/.minetest/mods/ | grep -E "areas|protect"
```

---

## 🎯 Próximos Pasos Recomendados

### Acciones Inmediatas (Esta Semana)

1. **✅ COMPLETADO: Otorgar privilegios**
   - Todos los usuarios tienen `areas` y `areas_high_limit`
   - Configuración por defecto actualizada en `luanti.conf`

2. **🎯 URGENTE: Proteger spawn**
   ```bash
   # Admin debe ejecutar:
   /spawn
   /protect_here 50 spawn_principal
   ```

3. **📢 COMUNICAR a los jugadores**
   - Anunciar nuevos comandos disponibles
   - Explicar cómo proteger sus casas
   - Compartir tutorial en el chat del servidor

### Acciones de Mediano Plazo (Próximas 2 Semanas)

4. **📝 Crear tutorial en el juego**
   - Comando `/ayuda_proteccion` con guía paso a paso
   - Carteles en el spawn con instrucciones visuales
   - Ejemplos prácticos en área de tutorial

5. **🗺️ Mapear áreas públicas**
   - Identificar zonas comunitarias
   - Proteger infraestructura compartida
   - Configurar permisos apropiados

6. **📊 Monitoreo inicial**
   - Revisar qué áreas se están creando
   - Detectar conflictos entre usuarios
   - Ajustar límites si es necesario

### Acciones de Largo Plazo (Próximo Mes)

7. **🔒 Establecer políticas de protección**
   - Definir límites claros de tamaño de áreas
   - Crear zonas designadas para construcción
   - Documentar reglas de protección

8. **🤝 Sistema de permisos avanzado**
   - Grupos de construcción colaborativa
   - Áreas semi-públicas (lectura pública, escritura privada)
   - Integración con sistema de roles

9. **📈 Análisis y optimización**
   - Revisar uso de áreas protegidas
   - Identificar áreas abandonadas
   - Limpiar protecciones inactivas (>90 días sin actividad)

---

## 📚 Referencias y Documentación

### Documentación Relacionada

- **Estado de Usuarios:** `docs/admin/estado-usuarios-actual.md`
- **Comandos de Admin:** `docs/admin/comandos-admin.md`
- **Manual de Administración:** `docs/admin/manual-administracion.md`
- **Sistema VoxeLibre:** `docs/admin/VOXELIBRE_SERVER_SETTINGS.md`

### Comandos Útiles de Referencia Rápida

```bash
# Para usuarios
/area_pos1              # Marcar esquina 1
/area_pos2              # Marcar esquina 2
/protect <nombre>       # Crear protección
/list_areas             # Ver tus áreas

# Para admin (chat)
/grant <usuario> areas                # Otorgar privilegio
/grant <usuario> areas,areas_high_limit  # Otorgar ambos

# Para admin (SSH)
# Ver usuarios
ssh gabriel@<VPS_IP> "cd /home/gabriel/Vegan-Wetlands && docker compose exec -T luanti-server sqlite3 /config/.minetest/worlds/world/auth.sqlite 'SELECT name FROM auth;'"

# Ver privilegios
ssh gabriel@<VPS_IP> "cd /home/gabriel/Vegan-Wetlands && docker compose exec -T luanti-server sqlite3 /config/.minetest/worlds/world/auth.sqlite 'SELECT auth.name, GROUP_CONCAT(privilege) FROM auth LEFT JOIN user_privileges ON auth.id=user_privileges.id WHERE auth.name=\"<usuario>\" GROUP BY auth.id;'"
```

---

## 🎓 Guía para Nuevos Jugadores

### Bienvenido a Wetlands - Tu Casa Segura

**¿Qué son las áreas protegidas?**
Las áreas protegidas son zonas donde solo tú (y tus amigos autorizados) pueden colocar o romper bloques. Nadie más puede modificar tu construcción.

**¿Cómo protejo mi casa?**

1. **Construye tu casa** primero
2. **Márcala** con `/area_pos1` en una esquina y `/area_pos2` en la esquina opuesta
3. **Protégela** con `/protect mi_casa`
4. **¡Listo!** Tu casa está segura

**¿Puedo compartir mi casa con amigos?**

Sí, usa `/add_owner <id_area> <nombre_amigo>` para que tu amigo también pueda construir en tu área.

**¿Cuántas áreas puedo proteger?**

Puedes proteger hasta 50 áreas diferentes, cada una de hasta 64x64x64 bloques. ¡Es más que suficiente para todas tus construcciones!

**¿Necesito ayuda?**

Pregunta en el chat o contacta a un administrador con `/msg gabo <mensaje>`

---

**Documento generado automáticamente**
**Fuente de datos:** Sistema de protección VoxeLibre + Areas Mod
**Servidor:** luanti.gabrielpantoja.cl:30000
**Estado:** ✅ SISTEMA ACTIVO - Todos los usuarios habilitados
**Áreas protegidas actuales:** 0 (sistema recién implementado)