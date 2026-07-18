#!/bin/bash
# Levanta todo el ecosistema (dapp_app_dev, dapp_db_dev, dapp_webdb_dev, dapp_webmail_dev) 
# en segundo plano y te muestra los logs en tiempo real para que veas qué pasa en Django.

echo "⚡ Encendiendo motores de FaroEd en modo desarrollo..."
# Levanta en segundo plano (-d)
docker compose -f docker-compose.dev.yml up -d

echo "📊 Conectando a los logs de la aplicación (Ctrl+C para salir, el contenedor seguirá corriendo)..."
docker compose -f docker-compose.dev.yml logs -f app
