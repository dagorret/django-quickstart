#!/bin/bash
# Este script apaga todos los contenedores de desarrollo (dapp_app_dev, dapp_db_dev, etc.) 
# de forma segura, deteniendo los procesos sin borrar tu base de datos ni tocar tus archivos locales.

echo "🛑 Apagando el ecosistema de desarrollo de FaroEd (dapp)..."
docker compose -f docker-compose.dev.yml down

echo "💤 Todos los servicios se han detenido correctamente. ¡Buen descanso!"
