"""
================================================================
RESET ADMIN — SGA IES N° 9 "Juana Azurduy"
================================================================
Restablece el acceso del administrador.

Sirve para dos casos:
  1. El admin olvidó su contraseña.
  2. Instalación nueva sin ningún administrador cargado.

Cómo usarlo:
  1. Abrir CMD en la carpeta "Sistema Alumnos IES 9"
  2. Escribir: python reset_admin.py
  3. Entrar con usuario: admin / contraseña: Admin1234
  4. El sistema pide cambiar la contraseña en el primer ingreso

Las credenciales de la base se leen del archivo .env
(no están escritas acá, para poder publicar el código).
================================================================
"""

import sys
import psycopg2
from pathlib import Path
from werkzeug.security import generate_password_hash

PASSWORD_INICIAL = 'Admin1234'


def cargar_env():
    """Lee el .env de la raíz del proyecto y devuelve los datos de conexión."""
    ruta = Path(__file__).resolve().parent / '.env'
    if not ruta.exists():
        print()
        print(' ❌ No se encontró el archivo .env')
        print('    Copiá .env.example como .env y completá DB_PASSWORD.')
        print()
        input(' Presioná Enter para cerrar...')
        sys.exit(1)

    valores = {}
    for linea in ruta.read_text(encoding='utf-8').splitlines():
        linea = linea.strip()
        if not linea or linea.startswith('#') or '=' not in linea:
            continue
        clave, valor = linea.split('=', 1)
        valores[clave.strip()] = valor.strip()

    return {
        'dbname':   valores.get('DB_NAME', 'ies9_gestion'),
        'user':     valores.get('DB_USER', 'postgres'),
        'password': valores.get('DB_PASSWORD', ''),
        'host':     valores.get('DB_HOST', 'localhost'),
        'port':     valores.get('DB_PORT', '5432'),
    }


def reset_admin():
    print()
    print('================================================================')
    print(' RESET ADMIN — SGA IES N° 9 "Juana Azurduy"')
    print('================================================================')
    print()
    print(' Restablece el acceso del administrador.')
    print(f' Contraseña que va a quedar: {PASSWORD_INICIAL}')
    print(' El sistema pedirá cambiarla en el primer ingreso.')
    print()

    if input(' ¿Confirmar? (s/n): ').strip().lower() != 's':
        print('\n Operación cancelada.\n')
        input(' Presioná Enter para cerrar...')
        return

    try:
        conn = psycopg2.connect(**cargar_env())
        cur  = conn.cursor()

        # La contraseña se guarda hasheada: el login usa
        # check_password_hash y rechaza cualquier texto plano.
        hash_password = generate_password_hash(PASSWORD_INICIAL)

        cur.execute("""
            UPDATE usuarios
            SET password_hash = %s, debe_cambiar_password = TRUE, activo = TRUE
            WHERE usuario = 'admin' AND rol = 'admin'
            RETURNING id
        """, (hash_password,))
        resultado = cur.fetchone()

        if resultado:
            accion = 'reseteada'
        else:
            # No existe ningún admin: instalación nueva → se crea.
            # El DNI queda en NULL a propósito, para que el sistema
            # dispare el asistente de configuración inicial.
            cur.execute("""
                INSERT INTO usuarios
                    (usuario, password_hash, rol, nombre, apellido, debe_cambiar_password)
                VALUES ('admin', %s, 'admin', 'Administrador', 'General', TRUE)
            """, (hash_password,))
            accion = 'creada'

        conn.commit()
        cur.close()
        conn.close()

        print()
        print(f' ✅ Cuenta de administrador {accion} correctamente.')
        print()
        print('    Usuario:    admin')
        print(f'    Contraseña: {PASSWORD_INICIAL}')
        print()

    except psycopg2.OperationalError as e:
        print()
        print(' ❌ No se pudo conectar a la base de datos.')
        print(f'    {e}')
        print()
        print(' Verificá que PostgreSQL esté corriendo y que los datos')
        print(' del archivo .env sean correctos.')

    except Exception as e:
        print()
        print(f' ❌ Error inesperado: {e}')

    print()
    input(' Presioná Enter para cerrar...')


if __name__ == '__main__':
    reset_admin()
