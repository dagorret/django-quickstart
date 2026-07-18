#!/bin/bash
# Este script se encarga de empaquetar tu imagen base de Alpine e instalar las dependencias de Python del requirements.txt.
# Forzar a que el script se detenga si hay algún error
set -e

echo "🐳 Construyendo entorno de desarrollo para FaroEd (dapp)..."
docker compose -f docker-compose.dev.yml build

echo "✅ ¡Imagen construida con éxito!"
