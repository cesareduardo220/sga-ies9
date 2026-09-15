-- ============================================================
-- Autoinscripción: antigüedad máxima del año de ingreso en un alta
-- Un alumno que se da de alta con token de tipo "alta" declara el
-- año en que empezó la carrera. Solo se aceptan los últimos N años
-- (por defecto 6). Si empezó antes, se resuelve en preceptoría.
-- ============================================================

INSERT INTO configuracion (clave, valor, descripcion)
VALUES
    ('autoinscripcion_antiguedad_max', '6',
     'Anios hacia atras que se aceptan como anio de ingreso en un alta de alumno que ya cursa')
ON CONFLICT (clave) DO NOTHING;
