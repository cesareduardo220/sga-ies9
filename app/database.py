import os
import psycopg2
from pathlib import Path


def _cargar_env():
    """
    Lee el archivo .env de la raíz del proyecto y carga sus valores
    como variables de entorno.

    El .env NO se sube al repositorio (está en .gitignore): cada
    instalación tiene el suyo con sus propias credenciales. Así el
    código puede ser público sin exponer contraseñas.
    """
    ruta = Path(__file__).resolve().parent.parent / '.env'
    if not ruta.exists():
        return
    for linea in ruta.read_text(encoding='utf-8').splitlines():
        linea = linea.strip()
        if not linea or linea.startswith('#') or '=' not in linea:
            continue
        clave, valor = linea.split('=', 1)
        os.environ.setdefault(clave.strip(), valor.strip())


_cargar_env()


def get_db():
    """Conexión a PostgreSQL. Los datos salen del .env."""
    password = os.environ.get('DB_PASSWORD')
    if not password:
        raise RuntimeError(
            "Falta la contraseña de la base de datos.\n"
            "Copiá el archivo .env.example como .env y completá DB_PASSWORD.\n"
            "Ver instrucciones en el README."
        )

    return psycopg2.connect(
        host     = os.environ.get('DB_HOST', 'localhost'),
        port     = os.environ.get('DB_PORT', '5432'),
        database = os.environ.get('DB_NAME', 'ies9_gestion'),
        user     = os.environ.get('DB_USER', 'postgres'),
        password = password
    )
