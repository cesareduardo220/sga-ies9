-- ============================================================
-- Correos: dominios aceptados para los alumnos
-- Lista separada por comas. Una entrada que empieza con "*."
-- acepta cualquier dominio que termine así (por ejemplo *.edu.ar).
-- Se puede ampliar o achicar sin tocar código.
-- ============================================================

INSERT INTO configuracion (clave, valor, descripcion)
VALUES
    ('email_dominios_permitidos',
     'gmail.com, hotmail.com, hotmail.com.ar, outlook.com, outlook.com.ar, live.com, live.com.ar, msn.com, yahoo.com, yahoo.com.ar, icloud.com, me.com, proton.me, protonmail.com, *.edu.ar',
     'Dominios de correo aceptados para alumnos, separados por coma. *.dominio acepta subdominios')
ON CONFLICT (clave) DO NOTHING;
