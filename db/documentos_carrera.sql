\set ON_ERROR_STOP on

BEGIN;

-- Registro de documentos ocupados dentro de cada carrera.
-- Cruza alumnos, profesores, usuarios y preinscripciones pendientes.
-- referencia_id NO es clave foranea: apunta a distintas tablas segun el origen.
CREATE TABLE documentos_carrera (
    id             SERIAL PRIMARY KEY,
    carrera_id     integer NOT NULL,
    dni            character varying(15) NOT NULL,
    origen         character varying(20) NOT NULL,
    referencia_id  integer,
    creado_en      timestamp without time zone NOT NULL DEFAULT now(),
    CONSTRAINT documentos_carrera_carrera_dni_key UNIQUE (carrera_id, dni),
    CONSTRAINT documentos_carrera_origen_check
        CHECK (origen::text = ANY (ARRAY['alumno'::character varying::text,
                                         'profesor'::character varying::text,
                                         'usuario'::character varying::text,
                                         'preinscripcion'::character varying::text])),
    CONSTRAINT documentos_carrera_carrera_id_fkey
        FOREIGN KEY (carrera_id) REFERENCES carreras(id) ON DELETE CASCADE
);

CREATE INDEX idx_documentos_carrera_ref ON documentos_carrera (origen, referencia_id);

SELECT 'documentos_carrera' AS tabla, count(*) FROM documentos_carrera;

COMMIT;
