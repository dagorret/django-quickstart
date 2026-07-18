# 1 👹

Lo bueno de Alpine es que solo usamos postgresql-dev para compilar la rueda (wheel). Una vez instalado el driver, ese paquete se puede limpiar si quisiéramos achicar la imagen, pero dejarlo ahí te asegura que cualquier comando de Django que interactúe con la base de datos tenga las librerías nativas de C que necesita para volar.
