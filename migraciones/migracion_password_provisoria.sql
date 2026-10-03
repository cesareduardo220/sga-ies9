-- ================================================================
-- Migracion 7.9: contrasena provisoria al azar y con vencimiento
-- ================================================================
-- Las cuentas nuevas y las reseteadas reciben una contrasena provisoria al
-- azar en lugar del DNI. Esta columna guarda hasta cuando sirve; vacia = sin
-- vencimiento (las cuentas pendientes que ya existian, con el DNI).
--
-- Correr una sola vez, con un respaldo previo de la base:
--   psql -h 127.0.0.1 -U sgauser -d ies9_gestion -f migraciones/migracion_password_provisoria.sql
-- ================================================================

\set ON_ERROR_STOP on
BEGIN;

ALTER TABLE usuarios ADD COLUMN password_provisoria_vence TIMESTAMP WITH TIME ZONE;

COMMIT;
