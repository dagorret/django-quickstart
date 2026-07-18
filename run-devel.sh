#!/bin/bash
# Este script levanta el entorno de desarrollo local completo (DB, Django, Adminer, Mailpit)
# e inmediatamente aplica las migraciones estructurales pendientes.
set -e

echo "⚡ Encendiendo motores de dapp en modo desarrollo..."
# 1. Descarga/Construye e inicia los servicios en segundo plano
docker compose -f docker-compose.dev.yml up -d

echo "🗄️ Sincronizando base de datos local..."
# 2. Corre las migraciones en caliente sobre el contenedor de desarrollo
docker compose -f docker-compose.dev.yml exec app python manage.py migrate

echo "✨ ¡Entorno listo! Acceso disponible en:"
echo "   - App Django: http://localhost:8000"
echo "   - Adminer:    http://localhost:8080"
echo "   - Mailpit:    http://localhost:8025"
echo "📊 Conectando con los logs de la aplicación (Ctrl+C para salir)..."

# 3. Te pega a los logs para que veas los errores de código en tiempo real
docker compose -f docker-compose.dev.yml logs -f app
