-- ============================================================
-- Autoinscripción: tercer tipo de token "alta"
-- Para alumnos que YA cursan la carrera pero todavía no están
-- cargados en el sistema (carga inicial cuando el instituto
-- empieza a usar el SGA). Cargan sus datos como un ingresante,
-- pero al aprobarse NO se inscriben a 1° año: primero se carga
-- su historial académico.
-- ============================================================

BEGIN;

-- 1) Nuevo tipo de token
ALTER TABLE tokens_inscripcion
    DROP CONSTRAINT IF EXISTS tokens_inscripcion_tipo_check;
ALTER TABLE tokens_inscripcion
    ADD CONSTRAINT tokens_inscripcion_tipo_check
    CHECK (tipo IN ('ingresante', 'reinscripcion', 'alta'));

-- 2) El alta, igual que el ingresante, no apunta a un alumno existente
ALTER TABLE tokens_inscripcion
    DROP CONSTRAINT IF EXISTS tokens_inscripcion_alumno_coherente;
ALTER TABLE tokens_inscripcion
    ADD CONSTRAINT tokens_inscripcion_alumno_coherente
    CHECK (
        (tipo = 'reinscripcion'          AND alumno_id IS NOT NULL)
        OR
        (tipo IN ('ingresante', 'alta')  AND alumno_id IS NULL)
    );

COMMENT ON COLUMN tokens_inscripcion.tipo IS
    'Define qué pantalla ve el alumno: ingresante (formulario en blanco), alta (formulario en blanco para quien ya cursa, con año de ingreso) o reinscripcion (datos precargados).';
COMMENT ON COLUMN tokens_inscripcion.alumno_id IS
    'Solo en tokens de reinscripción. NULL en ingresantes y altas.';

-- 3) Año de ingreso declarado por el alumno en un alta
ALTER TABLE preinscripciones
    ADD COLUMN IF NOT EXISTS anio_ingreso INTEGER;
ALTER TABLE preinscripciones
    DROP CONSTRAINT IF EXISTS preinscripciones_anio_ingreso_check;
ALTER TABLE preinscripciones
    ADD CONSTRAINT preinscripciones_anio_ingreso_check
    CHECK (anio_ingreso IS NULL OR anio_ingreso BETWEEN 1990 AND 2100);

COMMENT ON COLUMN preinscripciones.anio_ingreso IS
    'Solo en altas: año en que el alumno empezó la carrera. En ingresantes queda NULL (se toma el ciclo de la preinscripción).';

COMMIT;
