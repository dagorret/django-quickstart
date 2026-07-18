#!/bin/bash
# Para apagar los servicios de manera ordenada en el servidor sin perder, por supuesto, los datos persistidos en el volumen de Postgres.

echo "🛑 Deteniendo servicios de PRODUCCIÓN para dapp..."
docker compose -f docker-compose.prod.yml down

echo "💤 Entorno de producción apagado."
