\set ON_ERROR_STOP on

BEGIN;

-- Las dos tablas estan vacias. El CASCADE se lleva las 8 claves foraneas
-- que apuntan a alumnos_carrera; se vuelven a crear mas abajo.
DROP TABLE IF EXISTS alumnos_carrera CASCADE;
DROP TABLE IF EXISTS personas CASCADE;

-- Identidad: solo lo que precarga el formulario. No es fuente de verdad.
CREATE TABLE personas (
    id                SERIAL PRIMARY KEY,
    dni               character varying(15)  NOT NULL,
    tipo_documento    character varying(10)  NOT NULL DEFAULT 'DNI',
    cuil              character varying(11),
    apellido          character varying(100) NOT NULL,
    nombre            character varying(100) NOT NULL,
    fecha_nacimiento  date,
    creado_en         timestamp without time zone NOT NULL DEFAULT now(),
    CONSTRAINT personas_dni_key  UNIQUE (dni),
    CONSTRAINT personas_cuil_key UNIQUE (cuil),
    CONSTRAINT personas_tipo_documento_check
        CHECK (tipo_documento::text = ANY (ARRAY['DNI'::character varying::text,
                                                 'DNI_EXT'::character varying::text,
                                                 'PAS'::character varying::text,
                                                 'CI'::character varying::text]))
);

-- Ficha completa del alumno EN ESA CARRERA. Cada carrera es duena de la suya.
CREATE TABLE alumnos_carrera (
    id                            SERIAL PRIMARY KEY,
    persona_id                    integer NOT NULL,
    carrera_id                    integer NOT NULL,
    plan_id                       integer,
    anio_ingreso                  integer NOT NULL,
    activo                        boolean NOT NULL DEFAULT true,
    apellido                      character varying(100) NOT NULL,
    nombre                        character varying(100) NOT NULL,
    dni                           character varying(15)  NOT NULL,
    tipo_documento                character varying(10)  NOT NULL DEFAULT 'DNI',
    cuil                          character varying(11),
    fecha_nacimiento              date,
    legajo                        character varying(20),
    email                         character varying(150),
    celular                       character varying(20),
    telefono                      character varying(20),
    direccion                     character varying(200),
    localidad                     character varying(150),
    localidad_id                  integer,
    provincia                     character varying(50),
    departamento                  character varying(150),
    contacto_emergencia_nombre    character varying(150),
    contacto_emergencia_vinculo   character varying(50),
    contacto_emergencia_telefono  character varying(30),
    creado_en                     timestamp without time zone NOT NULL DEFAULT now(),
    CONSTRAINT alumnos_carrera_persona_carrera_key UNIQUE (persona_id, carrera_id),
    CONSTRAINT alumnos_carrera_carrera_dni_key    UNIQUE (carrera_id, dni),
    CONSTRAINT alumnos_carrera_carrera_cuil_key   UNIQUE (carrera_id, cuil),
    CONSTRAINT alumnos_carrera_carrera_email_key  UNIQUE (carrera_id, email),
    CONSTRAINT alumnos_carrera_carrera_legajo_key UNIQUE (carrera_id, legajo),
    CONSTRAINT alumnos_carrera_tipo_documento_check
        CHECK (tipo_documento::text = ANY (ARRAY['DNI'::character varying::text,
                                                 'DNI_EXT'::character varying::text,
                                                 'PAS'::character varying::text,
                                                 'CI'::character varying::text])),
    CONSTRAINT alumnos_carrera_persona_id_fkey
        FOREIGN KEY (persona_id) REFERENCES personas(id) ON DELETE RESTRICT,
    CONSTRAINT alumnos_carrera_carrera_id_fkey
        FOREIGN KEY (carrera_id) REFERENCES carreras(id) ON DELETE RESTRICT,
    CONSTRAINT alumnos_carrera_plan_id_fkey
        FOREIGN KEY (plan_id) REFERENCES planes_estudio(id) ON DELETE SET NULL,
    CONSTRAINT alumnos_carrera_localidad_id_fkey
        FOREIGN KEY (localidad_id) REFERENCES localidades(id)
);

CREATE INDEX idx_alumnos_carrera_carrera  ON alumnos_carrera (carrera_id);
CREATE INDEX idx_alumnos_carrera_apellido ON alumnos_carrera (apellido, nombre);

-- Las 8 claves foraneas que el CASCADE se llevo
ALTER TABLE examenes ADD CONSTRAINT examenes_alumno_id_fkey
    FOREIGN KEY (alumno_id) REFERENCES alumnos_carrera(id) ON DELETE CASCADE;
ALTER TABLE historial_plan_alumno ADD CONSTRAINT historial_plan_alumno_alumno_id_fkey
    FOREIGN KEY (alumno_id) REFERENCES alumnos_carrera(id) ON DELETE CASCADE;
ALTER TABLE inscripciones ADD CONSTRAINT inscripciones_alumno_id_fkey
    FOREIGN KEY (alumno_id) REFERENCES alumnos_carrera(id) ON DELETE CASCADE;
ALTER TABLE inscripciones_auditoria ADD CONSTRAINT inscripciones_auditoria_alumno_id_fkey
    FOREIGN KEY (alumno_id) REFERENCES alumnos_carrera(id) ON DELETE CASCADE;
ALTER TABLE inscripciones_mesa ADD CONSTRAINT inscripciones_mesa_alumno_id_fkey
    FOREIGN KEY (alumno_id) REFERENCES alumnos_carrera(id) ON DELETE CASCADE;
ALTER TABLE preinscripciones ADD CONSTRAINT preinscripciones_alumno_id_fkey
    FOREIGN KEY (alumno_id) REFERENCES alumnos_carrera(id) ON DELETE SET NULL;
ALTER TABLE reconocimientos_alumno ADD CONSTRAINT reconocimientos_alumno_alumno_id_fkey
    FOREIGN KEY (alumno_id) REFERENCES alumnos_carrera(id) ON DELETE CASCADE;
ALTER TABLE tokens_inscripcion ADD CONSTRAINT tokens_inscripcion_alumno_id_fkey
    FOREIGN KEY (alumno_id) REFERENCES alumnos_carrera(id) ON DELETE CASCADE;

-- Control
SELECT conrelid::regclass AS tabla, conname AS restriccion
  FROM pg_constraint
 WHERE contype = 'f' AND confrelid = 'alumnos_carrera'::regclass
 ORDER BY 1;

COMMIT;
