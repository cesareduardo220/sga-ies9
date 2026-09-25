-- ================================================================
-- Migracion 7.4: politica de migracion simplificada
-- ================================================================
-- Antes: ninguna | exactas | similares | personalizado
-- Ahora: ninguna | equivalencias | personalizado
-- "equivalencias" = se reconoce segun la tabla de equivalencias que el
-- coordinador revisa al cargar el plan nuevo. Los planes con "exactas" o
-- "similares" pasan a "equivalencias".
--
-- Correr una sola vez, con un respaldo previo de la base:
--   psql -h 127.0.0.1 -U sgauser -d ies9_gestion -f migraciones/migracion_politica_equivalencias.sql
-- ================================================================

\set ON_ERROR_STOP on
BEGIN;

ALTER TABLE planes_estudio DROP CONSTRAINT planes_estudio_politica_migracion_check;

UPDATE planes_estudio SET politica_migracion = 'equivalencias'
WHERE politica_migracion IN ('exactas', 'similares');

ALTER TABLE planes_estudio ALTER COLUMN politica_migracion SET DEFAULT 'equivalencias';

ALTER TABLE planes_estudio
    ADD CONSTRAINT planes_estudio_politica_migracion_check
    CHECK (politica_migracion IN ('ninguna', 'equivalencias', 'personalizado'));

COMMIT;
