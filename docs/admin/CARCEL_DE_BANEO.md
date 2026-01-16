# 🔒 Carcel de Baneo - Sistema de Castigo Wetlands

## 📍 Ubicación de la Cárcel

**Coordenadas Base**: `293.7, 23.8, -35.6`

- **Centro de la celda**: X=294, Y=24, Z=-36
- **Área total**: 5x5x4 bloques
- **Interior útil**: 3x3x2 bloques
- **Material**: Bedrock indestructible

---

## 🏗️ Fase 1: Construcción de la Cárcel

### **Paso 1: Ir a la ubicación base**
```
/teleport 293 23 -36
```

### **Paso 2: Definir esquina inferior (pos1)**
```
//pos1
```
*Marca la primera esquina en 293, 23, -36*

### **Paso 3: Definir esquina superior (pos2)**
```
/teleport 297 26 -32
```
```
//pos2
```
*Marca la segunda esquina - define un cubo de 5x5x4*

### **Paso 4: Crear paredes de bedrock**
```
//walls mcl_core:bedrock
```
*Crea paredes indestructibles alrededor del perímetro*

### **Paso 5: Crear piso de bedrock**
```
/teleport 293 23 -36
```
```
//pos1
```
```
/teleport 297 23 -32
```
```
//pos2
```
```
//set mcl_core:bedrock
```
*Sella el piso completamente*

### **Paso 6: Crear techo de bedrock**
```
/teleport 293 26 -36
```
```
//pos1
```
```
/teleport 297 26 -32
```
```
//pos2
```
```
//set mcl_core:bedrock
```
*Sella el techo completamente*

### **Paso 7: Limpiar interior de la celda**
```
/teleport 294 24 -35
```
```
//pos1
```
```
/teleport 296 25 -33
```
```
//pos2
```
```
//set air
```
*Vacía el interior dejando un espacio habitable de 3x3x2*

### **Paso 8: Ir al centro de la celda**
```
/teleport 294 24 -35
```

### **Paso 9: Proteger el área con VoxeLibre Protection**
```
/protect
```
*Esto evita que jugadores sin privilegios destruyan bloques en el área*

### **Paso 10: Verificación visual**
```
/teleport 294 30 -35
```
*Vuela encima de la celda para verificar que esté sellada correctamente*

---

## 🚨 Fase 2: Enviar Jugador a la Cárcel

### **Ejemplo: Castigar al jugador "gaelsin"**

#### **Paso 1: Revocar privilegio de volar**
```
/revoke gaelsin fly
```

#### **Paso 2: Revocar privilegio de noclip**
```
/revoke gaelsin noclip
```

#### **Paso 3: Revocar privilegio de velocidad**
```
/revoke gaelsin fast
```

#### **Paso 4: Revocar privilegio de teleport**
```
/revoke gaelsin teleport
```

#### **Paso 5: Revocar privilegio de home**
```
/revoke gaelsin home
```

#### **Paso 6: Teletransportar a la celda**
```
/teleport gaelsin 294 24 -35
```

#### **Paso 7: Notificar al jugador**
```
/msg gaelsin Has sido enviado a la cárcel por violar las reglas del servidor. Tiempo de castigo: [DURACIÓN]. Reflexiona sobre tu comportamiento.
```

#### **Paso 8: Verificar estado del jugador**
```
/privs gaelsin
```
*Debería mostrar solo: interact, shout*

```
/whois gaelsin
```
*Debería mostrar coordenadas cerca de 294, 24, -35*

---

## ✅ Comandos Rápidos - Aplicar Castigo Completo

**Copiar y pegar en el chat del juego:**

```
/revoke gaelsin fly
/revoke gaelsin noclip
/revoke gaelsin fast
/revoke gaelsin teleport
/revoke gaelsin home
/teleport gaelsin 294 24 -35
/msg gaelsin Has sido enviado a la cárcel por violar las reglas del servidor. Reflexiona sobre tu comportamiento.
```

---

## 🔓 Fase 3: Liberar al Jugador

### **Ejemplo: Liberar al jugador "gaelsin"**

#### **Paso 1: Restaurar privilegio de volar**
```
/grant gaelsin fly
```

#### **Paso 2: Restaurar privilegio de noclip**
```
/grant gaelsin noclip
```

#### **Paso 3: Restaurar privilegio de velocidad**
```
/grant gaelsin fast
```

#### **Paso 4: Restaurar privilegio de teleport**
```
/grant gaelsin teleport
```

#### **Paso 5: Restaurar privilegio de home**
```
/grant gaelsin home
```

#### **Paso 6: Teletransportar al spawn**
```
/teleport gaelsin 0 15 0
```

#### **Paso 7: Notificar liberación**
```
/msg gaelsin Has sido liberado de la cárcel. Por favor, respeta las reglas del servidor en el futuro.
```

---

## ✅ Comandos Rápidos - Liberar Completamente

**Copiar y pegar en el chat del juego:**

```
/grant gaelsin fly
/grant gaelsin noclip
/grant gaelsin fast
/grant gaelsin teleport
/grant gaelsin home
/teleport gaelsin 0 15 0
/msg gaelsin Has sido liberado de la cárcel. Por favor, respeta las reglas del servidor en el futuro.
```

---

## 📊 Plantillas para Otros Jugadores

### **Castigar a cualquier jugador (reemplazar NOMBRE)**

```
/revoke NOMBRE fly
/revoke NOMBRE noclip
/revoke NOMBRE fast
/revoke NOMBRE teleport
/revoke NOMBRE home
/teleport NOMBRE 294 24 -35
/msg NOMBRE Has sido enviado a la cárcel por violar las reglas del servidor. Reflexiona sobre tu comportamiento.
```

### **Liberar a cualquier jugador (reemplazar NOMBRE)**

```
/grant NOMBRE fly
/grant NOMBRE noclip
/grant NOMBRE fast
/grant NOMBRE teleport
/grant NOMBRE home
/teleport NOMBRE 0 15 0
/msg NOMBRE Has sido liberado de la cárcel. Por favor, respeta las reglas del servidor en el futuro.
```

---

## 🎯 Sistema de Castigos Recomendado

### **Niveles de Castigo por Gravedad**

| Ofensa | Duración | Acción |
|--------|----------|--------|
| **1ra ofensa leve** | 5 minutos | Cárcel + advertencia verbal |
| **2da ofensa leve** | 15 minutos | Cárcel + advertencia escrita |
| **1ra ofensa grave** | 30 minutos | Cárcel + advertencia final |
| **2da ofensa grave** | 1 hora | Cárcel + suspensión temporal |
| **3ra ofensa grave** | Permanente | Ban del servidor |

### **Ejemplos de Ofensas**

**Leves:**
- Spam en chat
- Lenguaje inapropiado menor
- Construcciones molestas cerca de otros jugadores

**Graves:**
- Griefing intencional
- Acoso a otros jugadores
- Uso de exploits o hacks
- Violación de reglas educativas/compasivas del servidor

---

## 🔧 Verificación y Mantenimiento

### **Verificar integridad de la cárcel**
```
/teleport 294 30 -35
```
*Vuela encima y verifica que todas las paredes, piso y techo estén intactos*

### **Verificar protección del área**
```
/teleport 294 24 -35
/protect
```
*Confirma que el área esté protegida correctamente*

### **Listar todos los jugadores en la cárcel**
```
/status
```
*Busca jugadores con coordenadas cercanas a 294, 24, -35*

### **Ver todos los jugadores conectados y sus privilegios**
```
/privs
```
*Revisa quién tiene privilegios revocados*

---

## 📝 Registro de Castigos (Plantilla)

Mantén un registro manual de los castigos aplicados:

| Fecha | Jugador | Razón | Duración | Admin | Notas |
|-------|---------|-------|----------|-------|-------|
| 2025-01-15 | gaelsin | Spam en chat | 5 min | gabriel | Primera advertencia |
| 2025-01-16 | player2 | Griefing | 30 min | gabriel | Destruyó construcción ajena |

---

## ⚠️ Notas Importantes

1. **Privilegios Requeridos**: Necesitas `server`, `privs`, `teleport`, `worldedit`, y `ban` para ejecutar todos estos comandos.

2. **Construcción Única**: Solo necesitas construir la cárcel **una vez**. Después, usa solo los comandos de castigo/liberación.

3. **Bedrock Indestructible**: Ni siquiera en modo creativo se puede destruir bedrock, garantizando que nadie escape.

4. **Múltiples Celdas**: Si necesitas más celdas, puedes construir adicionales en:
   - Celda 2: 300, 24, -36
   - Celda 3: 307, 24, -36
   - Etc.

5. **Alternativa Extrema**: Para casos extremos, usa `/ban NOMBRE` para baneo permanente.

6. **Comunicación Clara**: Siempre explica al jugador:
   - Por qué fue enviado a la cárcel
   - Cuánto tiempo estará castigado
   - Qué debe hacer para evitar futuras sanciones

---

## 🆘 Solución de Problemas

### **Problema: El jugador escapó de la cárcel**
**Solución:**
```
/teleport gaelsin 294 24 -35
/revoke gaelsin teleport
/revoke gaelsin noclip
```

### **Problema: El jugador destruyó bloques de bedrock**
**Solución:**
- Esto no debería ser posible si la protección está activa
- Verifica que `/protect` esté funcionando
- Reconstruye la celda si es necesario (repetir Fase 1)

### **Problema: El jugador sigue teniendo privilegios**
**Solución:**
```
/privs gaelsin
```
*Revoca manualmente cada privilegio que aparezca*

### **Problema: No puedo usar comandos de WorldEdit**
**Solución:**
```
/grant TU_NOMBRE worldedit
/grant TU_NOMBRE worldedit_commands
```

---

## 📚 Referencias

- **WorldEdit Commands**: `/help worldedit`
- **Protection System**: `/help protect`
- **Privilege Management**: `/help privs`
- **Teleport Commands**: `/help teleport`

---

## 🎨 Mejoras Opcionales

### **Agregar letrero informativo dentro de la celda**

```
/teleport 294 25 -33
/giveme mcl_signs:wall_sign
```
*Coloca el letrero manualmente en la pared norte y escribe:*

```
=== CÁRCEL DE WETLANDS ===
Has violado las reglas del servidor
Tiempo de castigo: [DURACIÓN]
Reflexiona sobre tu comportamiento
Contacta a un admin si tienes dudas
Respeta las reglas compasivas
```

### **Agregar antorcha para iluminación**

```
/teleport 294 25 -35
/giveme mcl_torches:torch
```
*Coloca la antorcha en la pared para que la celda tenga luz*

---

## 🔐 Seguridad Adicional

### **Verificar que el jugador no tenga items peligrosos**
```
/clearinv gaelsin
```
*Vacía el inventario del jugador (opcional, según gravedad)*

### **Silenciar al jugador temporalmente**
```
/revoke gaelsin shout
```
*Evita que use el chat público (opcional)*

```
/grant gaelsin shout
```
*Restaura el privilegio de chat cuando termine el castigo*

---

**Documento creado**: 2025-01-29
**Ubicación de la cárcel**: 294, 24, -35
**Servidor**: Wetlands (luanti.gabrielpantoja.cl:30000)
**Sistema**: VoxeLibre + WorldEdit + VoxeLibre Protection
