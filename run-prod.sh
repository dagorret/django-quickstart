#!/bin/bash
# Este comando levanta la base de datos y la aplicación en segundo plano (-d). Además, ejecuta las migraciones de Django de forma automática antes de que uWSGI empiece a recibir tráfico, asegurando que la base de datos siempre esté al día.
set -e

echo "🚀 Lanzando entorno de PRODUCCIÓN para dapp..."
# 1. Levantar los servicios en segundo plano
docker compose -f docker-compose.prod.yml up -d

echo "🗄️ Ejecutando migraciones de la base de datos..."
# 2. Correr las migraciones en caliente sobre el contenedor ya activo
docker compose -f docker-compose.prod.yml exec app python manage.py migrate --noinput

echo "✨ ¡dapp está corriendo en producción en el puerto 8000!"
