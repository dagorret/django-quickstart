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

## El peligro del "Dueño" en la carpeta compartida (`/var/www/staticfiles`)

Este es el verdadero problema oculto. En tu `docker-compose.prod.yml` pusiste este mapeo: `- /var/www/staticfiles:/app/staticfiles`

¿Qué pasa tras bambalinas?

1. Durante el `build`, el `Dockerfile.prod` ejecuta `collectstatic` como usuario `root` dentro de la imagen.

2. Al levantar el contenedor, Docker mapea esa carpeta al disco real del servidor base.

3. Si la carpeta `/var/www/staticfiles` en el servidor real no existe, **Docker la va a crear automáticamente**, pero la creará con el dueño `root:root`.

**El problema:** Si más adelante tu proxy reverso (Nginx o Apache) corre en el servidor real bajo su propio usuario estándar (como `www-data` o `nginx`), cuando intente leer los archivos CSS dentro de `/var/www/staticfiles` para mostrárselos al público, dará un error **403 Forbidden** porque `root` bloquea el acceso.

- **La solución en el servidor real:** Antes de darle el primer `run-prod.sh`, el SysAdmin (o tú) debe asegurarse de que la carpeta exista y que el usuario del servidor web pueda leerla. Normalmente se soluciona ejecutando esto **una sola vez en el servidor real**:

Bash

```bash
# 1. Crear la carpeta a mano en el servidor real si no existe
sudo mkdir -p /var/www/staticfiles

# 2. Darle la propiedad al usuario del servidor web (ejemplo habitual: www-data)
sudo chown -R www-data:www-data /var/www/staticfiles

# 3. Asegurar permisos de lectura (755) para que todos puedan leer los CSS/JS
sudo chmod -R 755 /var/www/staticfiles
```

## 🔑 Comandos Administrativos Manuales en Producción

Estos comandos **no se incluyen en scripts automáticos** ya que requieren interacción de consola o se ejecutan una única vez al montar el servidor real por primera vez:

- **Aplicar las tablas iniciales con el contenedor aún apagado:**

Bash

```
docker compose -f docker-compose.prod.yml run --rm app python manage.py migrate
```

- **Crear la cuenta del Administrador / Dueño de la plataforma en producción:**

Bash

```
docker compose -f docker-compose.prod.yml run --rm app python manage.py createsuperuser
```

- **Ver los logs en tiempo real para diagnosticar errores en producción:**

Bash

```
docker compose -f docker-compose.prod.yml logs -f app
```

#### 1. Las credenciales viejas quedaron en el volumen 😈

Si antes de que pusiéramos `dapp/dapp` en el `docker-compose.dev.yml` habías levantado el contenedor con **otras credenciales** (o vacío con los valores por defecto de Postgres), la base de datos ya se inicializó con la contraseña vieja. Cambiar el `.yml` no actualiza la contraseña de un volumen que ya existe.

**La solución rápida (Borrón y cuenta nueva local):** Como estás en desarrollo y quieres que tome las credenciales definitivas del script, vamos a destruir el volumen de datos local y recrearlo en limpio:

Bash

```
# 1. Apaga el entorno y destruye el volumen viejo
docker compose -f docker-compose.dev.yml down -v

# 2. Vuelve a levantar (esto creará la base de datos de cero con user y pass "dapp")
./run-devel.sh
```

### 2. El orden de los factores en Adminer

A veces, al cambiar el desplegable de *MySQL* a *PostgreSQL* en la pantalla de Adminer, el navegador te vuelve a autocompletar los campos con datos guardados viejos.

Asegúrate de que quede exactamente así antes de dar clic:

- **Motor:** `PostgreSQL`

- **Servidor:** `db`

- **Usuario:** `dapp`

- **Contraseña:** `dapp`

- **Base de datos:** `dapp`

🤖🤖🤖🤖🤖🤖🤖🤖🤖🤖🤖🤖🤖🤖🤖🤖🤖🤖🤖🤖🤖🤖🤖🤖🤖🤖🤖🤖🤖🤖🤖🤖🤖🤖🤖🤖🤖🤖🤖🤖

