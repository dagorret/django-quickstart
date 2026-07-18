# Instrucciones

1) Clonar el respositorio
3) chmod +x build-devel.sh init-devel.sh run-devel.sh
4) chmod +x stop-devel.sh
5) chmod +x build-prod.sh run-prod.sh stop-prod.sh
6) chmod +x *-devel.sh *-prod.sh (todos) 🤠

## 🛠️ Scripts de Desarrollo (`devel`)

### `init-devel.sh`

- **Descripción:** Se usa una sola vez al iniciar el proyecto desde cero. Levanta un contenedor temporal para ejecutar el comando nativo de Django que crea la estructura inicial de carpetas y archivos base dentro de tu directorio local.

- **Comando Docker puro:**



```bash
docker compose -f docker-compose.dev.yml run --rm app django-admin startproject backend .
```

### `build-devel.sh`

- **Descripción:** Descarga las imágenes base y construye localmente la imagen de desarrollo instalando las librerías del `requirements.txt`. No copia código porque en desarrollo se usa un volumen vivo.

- **Comando Docker puro:**



```bash
docker compose -f docker-compose.dev.yml build
```

### `run-devel.sh`

- **Descripción:** Enciende el entorno local (Base de datos, Django con servidor de desarrollo autorecargable, Adminer, etc.) y ejecuta de forma automática las migraciones pendientes en tu base de datos local.

- **Comandos Docker puros:**



```bash
docker compose -f docker-compose.dev.yml up -d
docker compose -f docker-compose.dev.yml exec app python manage.py migrate
```

### `stop-devel.sh`

- **Descripción:** Apaga y destruye los contenedores de desarrollo locales, liberando los puertos de tu máquina pero manteniendo a salvo tus datos de prueba.

- **Comando Docker puro:**



```bash
docker compose -f docker-compose.dev.yml down
```

## 🚀 Scripts de Producción (`prod`)

### `build-prod.sh`

- **Descripción:** Compila la imagen definitiva para producción usando `Dockerfile.prod`. Inyecta el código completo dentro de la imagen de forma inmutable y ejecuta el empaquetado de todos los archivos estáticos en la carpeta interna de la app.

- **Comando Docker puro:**



```bash
docker compose -f docker-compose.prod.yml build --no-cache
```

### `run-prod.sh`

- **Descripción:** Enciende la base de datos y la aplicación (bajo uWSGI) en segundo plano dentro del servidor de producción, aplicando inmediatamente las migraciones pendientes sobre la base de datos activa.

- **Comandos Docker puros:**



```bash
docker compose -f docker-compose.prod.yml up -d
docker compose -f docker-compose.prod.yml exec app python manage.py migrate --noinput
```

### `stop-prod.sh`

- **Descripción:** Detiene de manera limpia los servicios en producción (uWSGI y Postgres) sin alterar los volúmenes donde se guardan los datos reales de los usuarios.

- **Comando Docker puro:**



```bash
docker compose -f docker-compose.prod.yml down
```

## 🔑 Comandos Especiales de "Primer Lanzamiento" (Manuales)

Estos no van dentro de los scripts diarios automatizados porque requieren interacción del usuario o se corren una única vez al configurar el servidor real por primera vez:

- **Crear las tablas iniciales en limpio (Antes de encender la web):**

```bash
docker compose -f docker-compose.prod.yml run --rm app python manage.py migrate
```

- **Crear el usuario Administrador/Dueño de la plataforma en producción:**

```bash
docker compose -f docker-compose.prod.yml run --rm app python manage.py createsuperuser
```

