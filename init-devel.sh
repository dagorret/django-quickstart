#!/bin/bash
# Este es el corazón de tu Quickstart. 
# Se ejecuta una sola vez para crear la estructura de Django 
# en tu carpeta local y correr las migraciones iniciales en Postgres.
set -e

echo "🚀 Inicializando el andamiaje de Django (backend)..."
docker compose -f docker-compose.dev.yml run --rm app django-admin startproject backend .

echo "📦 Creando las tablas iniciales en la base de datos (dapp)..."
docker compose -f docker-compose.dev.yml run --rm app python manage.py migrate

echo "✨ ¡FaroEd inicializado correctamente! Listo para correr."
