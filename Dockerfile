FROM python:3.11-alpine

# Dependencias necesarias en Alpine para compilar psycopg2 y herramientas del sistema
RUN apk add --no-cache gcc musl-dev postgresql-dev libffi-dev

WORKDIR /app

RUN python -m pip install --upgrade pip

COPY requirements.txt .
RUN python -m pip install --no-cache-dir -r requirements.txt

# En desarrollo no hacemos COPY . . ni collectstatic aquí, 
# porque todo se manejará vivo a través del volumen del Compose.
