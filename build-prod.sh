#!/bin/bash
# Este script compila la imagen de Docker usando el Dockerfile.prod. 
# Es el que se encarga de empaquetar tu código de forma inmutable y correr el collectstatic dentro del contenedor.
set -e

echo "📦 Construyendo imagen de PRODUCCIÓN para dapp..."
docker compose -f docker-compose.prod.yml build --no-cache

echo "✅ ¡Imagen de producción compilada con éxito!"
