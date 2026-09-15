-- ============================================================
-- Autoinscripción: cola de revisión de preinscripciones
-- 1) Un DNI no puede tener dos preinscripciones activas en el mismo
--    ciclo. No cuentan las rechazadas (puede volver a intentar con un
--    token nuevo) ni las altas aprobadas (después del alta, el alumno
--    se reinscribe para elegir materias). Solo las altas guardan
--    anio_ingreso, por eso se usa esa columna para distinguirlas.
-- 2) Todo rechazo tiene que dejar asentado el motivo.
-- ============================================================

BEGIN;

ALTER TABLE preinscripciones
    DROP CONSTRAINT IF EXISTS preinscripciones_dni_ciclo_unico;
DROP INDEX IF EXISTS preinscripciones_dni_ciclo_vigente;

CREATE UNIQUE INDEX IF NOT EXISTS preinscripciones_dni_ciclo_activa
    ON preinscripciones (dni, ciclo_lectivo)
    WHERE estado = 'pendiente'
       OR (estado = 'aprobada' AND anio_ingreso IS NULL);

ALTER TABLE preinscripciones
    DROP CONSTRAINT IF EXISTS preinscripciones_rechazo_con_motivo;
ALTER TABLE preinscripciones
    ADD CONSTRAINT preinscripciones_rechazo_con_motivo
    CHECK (estado <> 'rechazada'
           OR (observaciones IS NOT NULL AND length(trim(observaciones)) > 0));

COMMENT ON COLUMN preinscripciones.observaciones IS
    'Motivo del rechazo (obligatorio si estado = rechazada).';

COMMIT;
