## 📁 Árbol de Directorios Estándar

Plaintext

```
src/
├── config/
├── entrypoints/
│   ├── web/
│   ├── api/
│   └── cli/
├── core/
└── apps/
    ├── personas/
    ├── permisos/
    └── roles/
```

## 🛠️ Justificación de cada Directorio

### 1. `src/config/`

- **Qué es:** El cerebro y núcleo de configuración del framework.

- **Por qué existe:** Centraliza los archivos nativos de Django generados por `startproject` (`settings.py`, `urls.py` global, `wsgi.py`).

- **Regla de oro:** Aquí **no se escribe lógica de negocio**. Solo se registran las aplicaciones, se configuran las variables de entorno, la conexión a Postgres y las rutas globales que redirigen el tráfico a los `entrypoints`.

### 2. `src/entrypoints/` (Puntos de Entrada)

- **Qué es:** La capa perimetral. Controla **por dónde** entra el usuario o el sistema a interactuar con nuestra aplicación.

- **Por qué se divide en subcarpetas:** Desacopla el mecanismo de entrega de la lógica comercial. Al negocio no le importa si lo llaman desde una pantalla web, una app mobile o un comando de consola.
  
  - **`web/`**: Contiene los controladores e integraciones para la interfaz de usuario. Al implementar **Inertia.js**, esta app se convierte en un motor híbrido: sirve la primera carga en HTML y las siguientes peticiones las resuelve enviando JSON directamente a los componentes de **Vue 3**. Centraliza las vistas del Dashboard personalizado.
  
  - **`api/`**: Reservada exclusivamente para la API REST pública o de integraciones externas (usando Django REST Framework). Devuelve JSON puro y maneja autenticación por tokens (JWT). No se mezcla con las rutas de la web.
  
  - **`cli/`**: Aloja los comandos de terminal personalizados de Django (`management/commands/`). Ideal para scripts de mantenimiento, tareas cron, o poblar la base de datos desde Docker sin tocar código HTTP.

### 3. `src/core/`

- **Qué es:** El tejido conectivo transversal del sistema.

- **Por qué existe:** Para evitar duplicar código. Aquí van las clases abstractas, Mixins de Django, decoradores de seguridad personalizados, middlewares globales y funciones utilitarias que tanto las `apps` como los `entrypoints` necesitan compartir. Si algo es usado por todo el proyecto pero no define al negocio, vive en `core`.

### 4. `src/apps/` (El Corazón del Negocio)

- **Qué es:** La capa de datos y dominio del sistema. Está dividida en módulos independientes.

- **Por qué se separa por módulos (`personas`, `permisos`, `roles`):** Para destruir el antipatrón de tener un único archivo `models.py` de miles de líneas.
  
  - Cada carpeta representa un concepto aislado del negocio y contiene su propio `models.py` nativo de Django.
  
  - **`personas/`**: Maneja la tabla de usuarios, sus datos biográficos y métodos específicos (ej. `persona.tiene_permiso()`).
  
  - **`permisos/`**: Define las acciones del sistema (ej. `crear_producto`, `eliminar_usuario`).
  
  - **`roles/`**: Configura las agrupaciones de permisos (ej. `Administrador`, `Editor`) y gestiona la relación intermedia de muchos a muchos (`ManyToManyField`).

- **Regla de oro:** Estas carpetas no saben qué framework visual usas. Se encargan puramente de hablar con Postgres a través del ORM, validar las reglas de consistencia de los datos y procesar la lógica interna.

## 🔄 Flujo de una Petición en el #MapaCaos3

Para entender la arquitectura en acción, así viaja la información cuando un usuario entra al Dashboard a ver el listado de personas:

1. El cliente interactúa con el Dashboard en **Vue 3** (`entrypoints/web/`).

2. La vista de Inertia intercepta la acción y le pide los datos a la ruta configurada en `entrypoints/web/views.py`.

3. El controlador en `views.py` invoca al modelo de datos alojado en `apps/personas/models.py`.

4. El modelo del ORM consulta de forma ultra eficiente a **Postgres** (visible en Adminer).

5. El modelo devuelve los registros a la vista de `web/`.

6. Inertia empaqueta esos datos en un JSON limpio y se los inyecta como `props` al componente de Vue, actualizando el Dashboard al instante sin recargar la pantalla.

