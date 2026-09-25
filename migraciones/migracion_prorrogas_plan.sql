-- ================================================================
-- Migracion 7.5: prorrogas de alumnos en un plan de estudios que se cierra
-- ================================================================
-- Un alumno con prorroga sigue en el plan viejo hasta la fecha "hasta".
-- Motivo obligatorio y disposicion opcional; se guarda quien la registro.
-- Extender una prorroga agrega una fila nueva (queda el historial).
--
-- Correr una sola vez, con un respaldo previo de la base:
--   psql -h 127.0.0.1 -U sgauser -d ies9_gestion -f migraciones/migracion_prorrogas_plan.sql
-- ================================================================

\set ON_ERROR_STOP on
BEGIN;

CREATE TABLE prorrogas_plan (
    id             SERIAL PRIMARY KEY,
    alumno_id      INTEGER NOT NULL REFERENCES alumnos_carrera(id) ON DELETE CASCADE,
    plan_id        INTEGER NOT NULL REFERENCES planes_estudio(id) ON DELETE CASCADE,
    hasta          DATE NOT NULL,
    motivo         TEXT NOT NULL CHECK (length(trim(motivo)) >= 5),
    disposicion    VARCHAR(100),
    registrado_por INTEGER REFERENCES usuarios(id) ON DELETE SET NULL,
    registrado_en  TIMESTAMP NOT NULL DEFAULT now()
);

CREATE INDEX idx_prorrogas_plan_alumno ON prorrogas_plan (alumno_id, plan_id);

COMMIT;
