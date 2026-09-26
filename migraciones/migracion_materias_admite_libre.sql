-- ================================================================
-- Migracion 7.7: examen libre por materia (Profesorados)
-- ================================================================
-- En los Profesorados solo las materias marcadas con (*) en la resolucion
-- admiten alumnos en condicion de libre; las demas se recursan. Las
-- materias que ya existen quedan admitiendo libre (como hasta ahora).
--
-- Correr una sola vez, con un respaldo previo de la base:
--   psql -h 127.0.0.1 -U sgauser -d ies9_gestion -f migraciones/migracion_materias_admite_libre.sql
-- ================================================================

\set ON_ERROR_STOP on
BEGIN;

ALTER TABLE materias ADD COLUMN admite_libre BOOLEAN NOT NULL DEFAULT TRUE;

COMMIT;
