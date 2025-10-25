#!/bin/bash

# Script simple para enviar notificación de prueba
# Uso: ./send-discord-test.sh "Mensaje de prueba"

# Leer webhook del .env
WEBHOOK_URL=$(grep "DISCORD_WEBHOOK_URL=" .env | cut -d'=' -f2)

if [ -z "$WEBHOOK_URL" ]; then
    echo "Error: No se encontró DISCORD_WEBHOOK_URL en .env"
    exit 1
fi

MESSAGE="${1:-🧪 Test de notificaciones del servidor Vegan Wetlands 🌱}"

echo "Enviando notificación a Discord..."
RESPONSE=$(curl -s -o /dev/null -w "%{http_code}" \
    -H "Content-Type: application/json" \
    -d "{\"content\":\"$MESSAGE\"}" \
    "$WEBHOOK_URL")

if [ "$RESPONSE" = "204" ] || [ "$RESPONSE" = "200" ]; then
    echo "✅ Notificación enviada exitosamente"
else
    echo "❌ Error al enviar (HTTP $RESPONSE)"
fi
