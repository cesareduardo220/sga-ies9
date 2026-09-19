import os, sys, psycopg2
sys.path.insert(0, os.getcwd())

from dotenv import load_dotenv
load_dotenv()

from app.routes import reservar_documento, liberar_documento, traspasar_documento

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
    print('%-42s %s  (esperado %r, obtenido %r)' % (n, 'OK ' if bien else 'MAL', esperado, obtenido))

try:
    cur.execute("INSERT INTO carreras (nombre, nombre_corto) VALUES ('ZZ Prueba Helpers', 'ZZTEST') RETURNING id")
    cid = cur.fetchone()[0]
    print('carrera de prueba id=%d\n' % cid)

    check('1. reservar documento libre',
          None, reservar_documento(cur, cid, '30111222', 'preinscripcion', 1))

    check('2. reservar el mismo desde otro origen',
          'preinscripcion', reservar_documento(cur, cid, '30111222', 'profesor', 9))

    check('3. reservar otro documento en la misma carrera',
          None, reservar_documento(cur, cid, '30333444', 'alumno', 2))

    check('4. traspasar preinscripcion -> alumno',
          1, traspasar_documento(cur, cid, '30111222', 'alumno', 77))

    cur.execute("SELECT origen, referencia_id FROM documentos_carrera WHERE carrera_id=%s AND dni='30111222'", (cid,))
    check('5. el traspaso quedo guardado',
          ('alumno', 77), cur.fetchone())

    check('6. liberar por origen+referencia',
          1, liberar_documento(cur, origen='alumno', referencia_id=77))

    check('7. liberar por carrera+dni',
          1, liberar_documento(cur, carrera_id=cid, dni='30333444'))

    cur.execute("SELECT count(*) FROM documentos_carrera WHERE carrera_id=%s", (cid,))
    check('8. no quedo ninguna reserva',
          0, cur.fetchone()[0])

    try:
        liberar_documento(cur)
        check('9. liberar sin datos lanza error', 'ValueError', 'no lanzo nada')
    except ValueError:
        check('9. liberar sin datos lanza error', 'ValueError', 'ValueError')

finally:
    conn.rollback()
    cur.close()
    conn.close()

print('\n%s' % ('TODO OK - los helpers funcionan' if ok else 'HAY FALLAS - revisar arriba'))
print('ROLLBACK hecho: no quedo nada en la base')
