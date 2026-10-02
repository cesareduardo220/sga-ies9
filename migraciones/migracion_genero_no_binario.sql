-- ================================================================
-- Migracion 7.8: genero no binario
-- ================================================================
-- Ademas de M (masculino) y F (femenino), el genero acepta X (no binario),
-- la misma letra que usa el DNI argentino. Vacio (NULL) sigue significando
-- "sin especificar". X y vacio dan la forma neutra de la etiqueta del rol
-- (Coordinacion, Preceptoria, Administracion, Docente).
--
-- Correr una sola vez, con un respaldo previo de la base:
--   psql -h 127.0.0.1 -U sgauser -d ies9_gestion -f migraciones/migracion_genero_no_binario.sql
-- ================================================================

\set ON_ERROR_STOP on
BEGIN;

ALTER TABLE usuarios DROP CONSTRAINT usuarios_genero_check;
ALTER TABLE usuarios ADD CONSTRAINT usuarios_genero_check CHECK (genero IN ('M', 'F', 'X'));

ALTER TABLE profesores DROP CONSTRAINT profesores_genero_check;
ALTER TABLE profesores ADD CONSTRAINT profesores_genero_check CHECK (genero IN ('M', 'F', 'X'));

COMMIT;
