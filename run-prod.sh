#!/bin/bash
# Este comando levanta la base de datos y la aplicación en segundo plano (-d). 
# Además, ejecuta las migraciones de Django en caliente sobre el contenedor 
# ya activo, asegurando que la base de datos se actualice sin detener el servicio.
set -e

echo "🚀 Lanzando entorno de PRODUCCIÓN para dapp..."
# 1. Levantar los servicios en segundo plano (uWSGI se enciende aquí)
docker compose -f docker-compose.prod.yml up -d

echo "🗄️ Ejecutando migraciones de la base de datos..."
# 2. Correr las migraciones en caliente sobre el contenedor ya activo
docker compose -f docker-compose.prod.yml exec app python manage.py migrate --noinput

echo "✨ ¡dapp está corriendo en producción en el puerto 8000!"

💡 Una alternativa por si "DE VERDAD" quieres que corra antes:

Si en tu arquitectura de producción es un requisito crítico que las migraciones terminen antes de que uWSGI abra sus puertas al tráfico, no puedes usar exec (que actúa sobre algo ya vivo). Tendrías que usar run antes del up -d, así:
Bash

# Alternativa si quisieras que corra ANTES de encender el servidor:
docker compose -f docker-compose.prod.yml run --rm app python manage.py migrate --noinput
docker compose -f docker-compose.prod.yml up -d

Pero si prefieres la estrategia de actualizar en caliente con el contenedor ya arriba (que es perfectamente válida para evitar caídas temporales), el primer bloque con el comentario corregido ("en caliente / contenedor ya activo") es el tuyo.
