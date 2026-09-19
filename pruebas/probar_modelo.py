import os, sys, psycopg2
from dotenv import load_dotenv
load_dotenv(os.path.join(os.getcwd(), '.env'))

conn = psycopg2.connect(
    host=os.getenv('DB_HOST'), port=os.getenv('DB_PORT'),
    dbname=os.getenv('DB_NAME'), user=os.getenv('DB_USER'),
    password=os.getenv('DB_PASSWORD'))
cur = conn.cursor()

ok = True
def check(n, esperado, obtenido):
    global ok
    bien = esperado == obtenido
    ok = ok and bien
    print('%-46s %s  (esperado %r, obtenido %r)' % (n, 'OK ' if bien else 'MAL', esperado, obtenido))

def falla(n, sql, datos, texto_esperado):
    """Verifica que la base RECHACE algo que no debe permitir."""
    global ok
    cur.execute('SAVEPOINT sp')
    try:
        cur.execute(sql, datos)
        cur.execute('RELEASE SAVEPOINT sp')
        ok = False
        print('%-46s MAL  (se esperaba rechazo y lo acepto)' % n)
    except psycopg2.Error as e:
        cur.execute('ROLLBACK TO SAVEPOINT sp')
        bien = texto_esperado in str(e)
        ok = ok and bien
        print('%-46s %s  (rechazado por %s)' % (n, 'OK ' if bien else 'MAL', texto_esperado))

ALTA = """
INSERT INTO alumnos_carrera (
    carrera_id, apellido, nombre, dni, tipo_documento, cuil,
    email, celular, fecha_nacimiento, direccion, localidad, provincia,
    contacto_emergencia_nombre, contacto_emergencia_telefono,
    anio_ingreso, legajo, localidad_id, departamento
) VALUES (%s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s)
RETURNING id
"""

try:
    cur.execute("INSERT INTO carreras (nombre, nombre_corto) VALUES ('ZZ Matematica', 'ZZMAT') RETURNING id")
    c1 = cur.fetchone()[0]
    cur.execute("INSERT INTO carreras (nombre, nombre_corto) VALUES ('ZZ Fisica', 'ZZFIS') RETURNING id")
    c2 = cur.fetchone()[0]
    print('carreras de prueba: %d y %d\n' % (c1, c2))

    base = ('Gomez', 'Juan', '30111222', 'DNI', '20301112223',
            'juan@mail.com', '3884111111', '2004-03-12', 'San Martin 100',
            'San Pedro', 'Jujuy', 'Ana Gomez', '3884222222',
            2026, 'L-100', None, 'San Pedro')

    cur.execute(ALTA, (c1,) + base)
    a1 = cur.fetchone()[0]
    check('1. alta de alumno en la carrera 1', True, isinstance(a1, int))

    falla('2. mismo DNI en la misma carrera', ALTA, (c1,) + base, 'carrera_dni_key')

    otro_dni = ('Perez', 'Luis', '30999888', 'DNI', None,
                'juan@mail.com', None, None, None, None, None, None, None,
                2026, 'L-101', None, None)
    falla('3. mismo email en la misma carrera', ALTA, (c1,) + otro_dni, 'carrera_email_key')

    otro_mail = ('Perez', 'Luis', '30999888', 'DNI', None,
                 'luis2@mail.com', None, None, None, None, None, None, None,
                 2026, 'L-100', None, None)
    falla('4. mismo legajo en la misma carrera', ALTA, (c1,) + otro_mail, 'carrera_legajo_key')

    mismo_cuil = ('Perez', 'Luis', '30999888', 'DNI', '20301112223',
                  'luis3@mail.com', None, None, None, None, None, None, None,
                  2026, 'L-102', None, None)
    falla('5. mismo CUIL en la misma carrera', ALTA, (c1,) + mismo_cuil, 'carrera_cuil_key')

    cur.execute(ALTA, (c2,) + base)
    a2 = cur.fetchone()[0]
    check('6. MISMO DNI en otra carrera (el objetivo)', True, isinstance(a2, int) and a2 != a1)

    cur.execute("""
        SELECT id, apellido, nombre, dni, email, celular,
               fecha_nacimiento, direccion, localidad,
               contacto_emergencia_nombre, contacto_emergencia_telefono,
               activo, anio_ingreso, tipo_documento, cuil, provincia, legajo
          FROM alumnos_carrera
         WHERE carrera_id = %s
         ORDER BY apellido, nombre
    """, (c1,))
    filas = cur.fetchall()
    check('7. el listado devuelve 1 fila de esa carrera', 1, len(filas))
    check('8. la columna 16 sigue siendo el legajo', 'L-100', filas[0][16])
    check('9. la columna 11 sigue siendo activo', True, filas[0][11])

    cur.execute("SELECT count(*) FROM alumnos_carrera WHERE carrera_id = %s", (c2,))
    check('10. la otra carrera tiene su propia ficha', 1, cur.fetchone()[0])

    cur.execute("UPDATE alumnos_carrera SET apellido = 'Gomes' WHERE id = %s", (a2,))
    cur.execute("SELECT apellido FROM alumnos_carrera WHERE id = %s", (a1,))
    check('11. editar en una carrera NO toca la otra', 'Gomez', cur.fetchone()[0])

finally:
    conn.rollback()
    cur.close()
    conn.close()

print('\n%s' % ('TODO OK - el modelo aguanta' if ok else 'HAY FALLAS - revisar arriba'))
print('ROLLBACK hecho: no quedo nada en la base')
