# Plan: avisos por WhatsApp para el administrador

> **Decisión 2026-09-10 — WhatsApp descartado.** La Cloud API de WhatsApp
> exige alta en Meta, plantillas de pago fuera de la ventana de 24 h y sacar el
> número secundario de la app, lo que es desproporcionado para un canal de
> avisos. Se reemplazó por **Telegram (bot) o Discord (webhook)**, a los que el
> mod envía **directo**, sin puente privado:
>
> ```text
> Jugador -> /gabo (wetlands_contact) -> HTTPS -> Telegram / Discord -> celular de gabo
> ```
>
> Las fases 1 (alta en Meta) y 2 (puente privado) quedan **canceladas**. Los
> límites, filtros y protección infantil de las fases 3–4 se mantienen en el
> mod. Configuración vigente: `server/mods/wetlands_contact/README.md`. El resto
> del documento se conserva como historia de la decisión.

## Objetivo del piloto

Permitir que un jugador de **Wetlands (puerto 30000)** envíe un aviso breve
desde Luanti y que este llegue al WhatsApp personal de `gabo`, sin revelar su
número de teléfono.

El piloto es un canal de avisos unidireccional, no un chat privado ni un canal
para emergencias.

```text
Jugador -> mod wetlands_contact -> puente privado -> WhatsApp Business API -> gabo
```

## Roles de los dos números

| Número | Uso |
|---|---|
| Secundario de gabo | Remitente dedicado de WhatsApp Business: “Wetlands Avisos”. |
| Personal de gabo | Destinatario privado de las alertas. No se expone a jugadores. |

El número Business se usará mediante la API oficial de WhatsApp Business Cloud
API. El segundo teléfono no tiene que permanecer encendido una vez completado
el alta: los mensajes salen desde la infraestructura de Meta.

La entrega es **directa**: Meta envía el mensaje desde el número Business al
WhatsApp personal de gabo. No hay reenvío manual ni automático desde el
teléfono secundario; ese teléfono solo se usa para verificar el número al
registrarlo.

## Experiencia del jugador

*(Actualizado 2026-09-10: se reemplazó el formulario `/avisar` con categorías
por un comando de una línea, a pedido de gabo.)*

- Comando `/gabo <mensaje>`, de hasta 300 caracteres; se envía al instante y el
  jugador recibe confirmación o un error claro en el chat.
- `/gabo` sin texto muestra el uso y el recordatorio de no compartir datos
  personales.
- Anuncio temporal en el HUD, abajo a la derecha, parpadeando en
  amarillo/naranjo durante 60 s al entrar: *"Need help? Type /gabo <message> to
  write directly to the admin"*.
- Textos en **inglés** (Wetlands recibe jugadores de unos 35 países), con
  traducción automática al español para clientes en español.

Ejemplo de notificación recibida por el administrador:

```text
🌿 Wetlands — mensaje para gabo
Jugador: NombreJugador
Mensaje: Necesito ayuda en mi construcción.
```

El aviso no incluirá IP, contraseña, identificadores del cliente, coordenadas
precisas ni datos personales.

## Arquitectura y límites de repositorio

### Este repositorio (`luanti-voxelibre-server`)

- Mod Lua `server/mods/wetlands_contact/`.
- Habilitación del mod para el piloto Wetlands en la configuración versionada.
- Documentación pública y sanitizada.
- Pruebas locales de formulario, límites y fallos del endpoint.

### Repositorio privado de infraestructura

- Servicio puente que recibe y valida avisos.
- Registro del número secundario en WhatsApp Business Platform.
- Token de Meta, identificadores de cuenta/número, número personal de gabo y
  demás secretos.
- Red privada, autenticación, cola de reintentos, monitoreo y retención de
  logs.
- Runbook de despliegue y recuperación no público.

Nunca se guardarán números de teléfono, tokens, códigos QR de sesión, URLs con
credenciales ni archivos `.env` en este repositorio.

## Fases

### 1. Alta de WhatsApp Business

1. Registrar el número secundario como “Wetlands Avisos” en Meta.
2. Configurar el número personal de gabo como destinatario con consentimiento.
3. Crear y aprobar una plantilla de utilidad para alertas iniciadas por el
   sistema. Es necesaria fuera de la ventana de conversación de 24 horas.
4. Enviar un mensaje de prueba al número personal.

**Salida:** el servicio Business entrega una alerta de prueba a gabo.

### 2. Servicio puente privado

1. Crear una API interna de recepción de avisos.
2. Autenticar solicitudes del mod y aceptar únicamente la red del servidor.
3. Validar esquema, categoría, longitud y texto antes de llamar a Meta.
4. Crear una cola limitada con deduplicación y reintentos ante fallos
   transitorios.
5. Registrar el estado de entrega sin conservar mensajes más tiempo del
   necesario para moderación.

**Salida:** una solicitud válida produce una notificación o un fallo trazable.

### 3. Mod de Luanti

1. Implementar `/gabo` en `wetlands_contact`.
2. Obtener la API HTTP de Luanti durante la carga del mod y usar solicitudes
   asíncronas.
3. Autorizar exclusivamente el mod en `secure.http_mods`. El nombre del mod no
   es secreto y va en `luanti-original.conf`; el endpoint y el token del puente
   van en `worlds/original/wetlands_contact.conf`, fuera de git y gestionado por
   operaciones.
4. Persistir el control de frecuencia con `mod_storage`.
5. Devolver al jugador un resultado comprensible sin exponer detalles internos.

**Salida:** el mod puede enviar un aviso de prueba al puente desde Wetlands.

### 4. Seguridad y protección infantil

- Máximo un aviso por jugador cada 10 minutos.
- Límite global inicial: 30 avisos por hora.
- Rechazo de mensajes vacíos, enlaces y repetición excesiva.
- Texto visible: no compartir nombre real, teléfono, dirección, contraseñas ni
  información personal.
- Capacidad operativa de desactivar el envío inmediatamente si hay abuso.
- No prometer disponibilidad de emergencias; se trata de soporte del juego.

### 5. Pruebas y piloto

1. Pruebas locales contra un endpoint simulado.
2. Prueba integrada con número y plantilla de prueba.
3. Activación inicial solo para `gabo`.
4. Piloto limitado en Wetlands.
5. Revisión de entrega, spam, costos y falsos positivos durante una semana.
6. Apertura general en Wetlands únicamente si el piloto cumple los criterios.

## Estado de avance

| Fase | Estado |
|---|---|
| 1. Alta de WhatsApp Business | **Cancelada** (se usa Telegram/Discord) |
| 2. Servicio puente privado | **Cancelada** (el mod envía directo) |
| 3. Mod de Luanti | **Hecho** (2026-09-10): `/gabo`, destinos Telegram y Discord, límites persistentes, filtros, `/gabo_admin`, anuncio HUD, traducción es |
| 4. Seguridad y protección infantil | **Hecho en el mod**: 1 mensaje/10 min por jugador, 30/h global, rechazo de enlaces, teléfonos, correos y repeticiones, bloqueo de `@everyone`, pausa en caliente |
| 5.1 Pruebas contra endpoint simulado | **Hecho**: `scripts/mock-telegram-discord.py`; probado en Luanti 5.17 con seguridad de mods activa, ambos destinos, incluyendo reinicio (los límites persisten) |
| 5.2+ Prueba real y piloto | Pendiente de configurar el bot/webhook en el VPS |

El mod arranca en modo `piloto` (solo privilegio `avisar`, que el admin tiene
por defecto). Sin `wetlands_contact.conf` en el mundo, `/gabo` responde "not
available" y no rompe nada.

## Criterios de aceptación del piloto

- El número personal de gabo nunca es visible ni está en Git.
- Los avisos legítimos llegan con mundo, categoría y nombre de jugador.
- El envío no bloquea el hilo del servidor Luanti.
- Los límites sobreviven a un reinicio del servidor.
- Un fallo de Meta o del puente no afecta el juego y se comunica sin secretos.
- El administrador puede pausar la función sin editar el mod en producción.

## Despliegue

Los cambios seguirán el flujo versionado del proyecto:

```text
Desarrollo local -> commit -> push -> despliegue automatizado
```

La habilitación del mod en el `world.mt` del mundo `original` será una operación
idempotente gestionada por el despliegue, comprobando antes entradas duplicadas.
No se copiarán archivos ni se editará producción manualmente.

## Fuera de alcance inicial

- Reenviar respuestas de WhatsApp hacia el juego.
- Habilitar el sistema en otros mundos.
- Automatización no oficial de WhatsApp Web.
- Mensajes sin límite o comunicación de emergencia.
