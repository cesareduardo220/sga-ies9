-- ================================================================
-- Migracion 7.3: materias unicas por plan de estudios
-- ================================================================
-- Antes: UNIQUE (carrera_id, anio, orden) -> una sola "1° anio, orden 1"
-- por carrera, lo que impedia que dos planes convivieran durante un
-- cambio de plan.
-- Ahora: UNIQUE NULLS NOT DISTINCT (carrera_id, plan_id, anio, orden) ->
-- una por plan. Las materias sin plan (si las hubiera) siguen sin poder
-- repetirse dentro de su carrera.
--
-- Correr una sola vez, con un respaldo previo de la base:
--   psql -h 127.0.0.1 -U sgauser -d ies9_gestion -f migraciones/migracion_materias_por_plan.sql
-- ================================================================

\set ON_ERROR_STOP on
BEGIN;

ALTER TABLE materias DROP CONSTRAINT materias_carrera_id_anio_orden_key;

ALTER TABLE materias
    ADD CONSTRAINT materias_carrera_plan_anio_orden_key
    UNIQUE NULLS NOT DISTINCT (carrera_id, plan_id, anio, orden);

COMMIT;
