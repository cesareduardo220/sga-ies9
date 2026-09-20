-- ============================================================
-- MIGRACION: sesion_token en usuarios
-- Fecha: 20/09/2026
--
-- Agrega la columna que sostiene la sesion unica por usuario.
-- Al iniciar sesion se guarda aca un token aleatorio que tambien
-- viaja en la cookie. Si no coinciden, la sesion se cierra: asi
-- un segundo ingreso con el mismo usuario desplaza al anterior.
--
-- NO hace falta correr esta migracion despues de instalar con
-- sga_ies9_v7.sql, que ya incluye la columna. Sirve solo para
-- bases creadas antes del 20/09/2026.
-- ============================================================

ALTER TABLE public.usuarios ADD COLUMN IF NOT EXISTS sesion_token text;
