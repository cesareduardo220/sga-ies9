-- ================================================================
-- Migracion 7.6: correlativa "aprobada para cursar" (Profesorados)
-- ================================================================
-- Los planes de los Profesorados piden, para cursar algunas materias,
-- correlativas APROBADAS (no alcanza con regularizarlas). Se agrega el
-- tipo 'aprobada_cursar' a correlatividades:
--   'cursada'         = regularizadas para cursar  (frena la inscripcion)
--   'aprobada_cursar' = aprobadas para cursar      (frena la inscripcion)
--   'aprobada'        = aprobadas para rendir o promocionar (frena la mesa
--                       y deja la promocion como provisoria)
--
-- Correr una sola vez, con un respaldo previo de la base:
--   psql -h 127.0.0.1 -U sgauser -d ies9_gestion -f migraciones/migracion_correlativa_aprobada_cursar.sql
-- ================================================================

\set ON_ERROR_STOP on
BEGIN;

ALTER TABLE correlatividades DROP CONSTRAINT correlatividades_tipo_check;
ALTER TABLE correlatividades ADD CONSTRAINT correlatividades_tipo_check
    CHECK (tipo IN ('cursada', 'aprobada', 'aprobada_cursar'));

COMMIT;
