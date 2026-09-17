#!/usr/bin/env python3
"""
Anonimiza las preinscripciones rechazadas hace más de N días.
N sale de configuracion (clave preinscripciones_anonimizar_dias).
Conserva: número, tipo, ciclo, fechas, estado, motivo, DNI, apellido y nombre.
Borra: CUIL, fecha de nacimiento, contacto, domicilio y contacto de emergencia.

Uso:
  python anonimizar_preinscripciones.py            -> usa el plazo configurado
  python anonimizar_preinscripciones.py --prueba   -> solo muestra qué haría
  python anonimizar_preinscripciones.py --dias N   -> usa N días en lugar del configurado
"""
import os
import sys

BASE = os.path.dirname(os.path.abspath(__file__))
sys.path.insert(0, BASE)

from dotenv import load_dotenv
load_dotenv(os.path.join(BASE, '.env'))

from app.database import get_db

DIAS_DEFECTO = 300
DIAS_MINIMO = 30

CONDICION = """
    estado = 'rechazada'
    AND anonimizado_en IS NULL
    AND COALESCE(revisado_en, creado_en) < now() - make_interval(days => %s)
"""


def leer_dias(cur):
    cur.execute("SELECT valor FROM configuracion WHERE clave = %s",
                ('preinscripciones_anonimizar_dias',))
    fila = cur.fetchone()
    try:
        dias = int(fila[0]) if fila else DIAS_DEFECTO
    except (TypeError, ValueError):
        dias = DIAS_DEFECTO
    if dias < DIAS_MINIMO:
        print(f"Plazo configurado ({dias}) menor al mínimo; se usa {DIAS_DEFECTO}.")
        dias = DIAS_DEFECTO
    return dias


def main():
    prueba = '--prueba' in sys.argv
    dias_manual = None
    if '--dias' in sys.argv:
        dias_manual = int(sys.argv[sys.argv.index('--dias') + 1])

    conn = get_db()
    cur = conn.cursor()
    try:
        dias = dias_manual if dias_manual is not None else leer_dias(cur)

        cur.execute("SELECT id FROM preinscripciones WHERE" + CONDICION + "ORDER BY id",
                    (dias,))
        ids = [r[0] for r in cur.fetchall()]

        if prueba:
            print(f"[PRUEBA] Plazo: {dias} días. Se anonimizarían {len(ids)}: {ids}")
            return

        if not ids:
            print(f"Plazo: {dias} días. No hay preinscripciones para anonimizar.")
            return

        cur.execute("""
            UPDATE preinscripciones SET
                cuil = NULL, fecha_nacimiento = NULL,
                email = NULL, celular = NULL, telefono = NULL,
                direccion = NULL, localidad_id = NULL, localidad = NULL,
                departamento = NULL, provincia = NULL,
                contacto_emergencia_nombre = NULL,
                contacto_emergencia_vinculo = NULL,
                contacto_emergencia_telefono = NULL,
                anonimizado_en = now()
            WHERE id = ANY(%s) AND""" + CONDICION, (ids, dias))
        cantidad = cur.rowcount
        conn.commit()
        print(f"Plazo: {dias} días. Anonimizadas: {cantidad} {ids}")
    finally:
        cur.close()
        conn.close()


if __name__ == '__main__':
    main()
