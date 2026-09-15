-- ============================================================
-- Autoinscripción: materias elegidas en la reinscripción en línea
-- Cada fila es una materia que el alumno tildó en el formulario.
-- Quedan pendientes junto con la preinscripción y recién pasan a
-- `inscripciones` cuando preceptoría la aprueba.
-- ============================================================

BEGIN;

CREATE TABLE IF NOT EXISTS preinscripcion_materias (
    id                 SERIAL  PRIMARY KEY,
    preinscripcion_id  INTEGER NOT NULL
        REFERENCES preinscripciones(id) ON DELETE CASCADE,
    materia_id         INTEGER NOT NULL
        REFERENCES materias(id) ON DELETE RESTRICT,
    CONSTRAINT preinscripcion_materias_unica
        UNIQUE (preinscripcion_id, materia_id)
);

CREATE INDEX IF NOT EXISTS idx_preinscripcion_materias_materia
    ON preinscripcion_materias (materia_id);

COMMENT ON TABLE preinscripcion_materias IS
    'Materias elegidas por el alumno en la reinscripción en línea. Se vuelcan a inscripciones al aprobar la preinscripción.';

COMMIT;
