-- Modelo por carrera del SGA - IES N 9 "Juana Azurduy"
-- Cada carrera es duena de la ficha completa de sus alumnos.
-- Ningun dato personal se comparte entre carreras: lo que carga la
-- preceptora de una carrera no modifica ni condiciona lo de otra.
--
-- Unicidad: DNI, CUIL, email y legajo son unicos DENTRO de cada carrera,
-- no en todo el instituto. Asi una persona puede cursar dos carreras a la
-- vez, y cada una lleva su propio registro.

\set ON_ERROR_STOP on

BEGIN;

-- Ficha del alumno en una carrera. Una fila por alumno-carrera.
CREATE TABLE alumnos_carrera (
    id                            SERIAL PRIMARY KEY,
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
    CONSTRAINT alumnos_carrera_carrera_dni_key    UNIQUE (carrera_id, dni),
    CONSTRAINT alumnos_carrera_carrera_cuil_key   UNIQUE (carrera_id, cuil),
    CONSTRAINT alumnos_carrera_carrera_email_key  UNIQUE (carrera_id, email),
    CONSTRAINT alumnos_carrera_carrera_legajo_key UNIQUE (carrera_id, legajo),
    CONSTRAINT alumnos_carrera_tipo_documento_check
        CHECK (tipo_documento::text = ANY (ARRAY['DNI'::character varying::text,
                                                 'DNI_EXT'::character varying::text,
                                                 'PAS'::character varying::text,
                                                 'CI'::character varying::text])),
    CONSTRAINT alumnos_carrera_carrera_id_fkey
        FOREIGN KEY (carrera_id) REFERENCES carreras(id) ON DELETE RESTRICT,
    CONSTRAINT alumnos_carrera_plan_id_fkey
        FOREIGN KEY (plan_id) REFERENCES planes_estudio(id) ON DELETE SET NULL,
    CONSTRAINT alumnos_carrera_localidad_id_fkey
        FOREIGN KEY (localidad_id) REFERENCES localidades(id)
);

CREATE INDEX idx_alumnos_carrera_carrera  ON alumnos_carrera (carrera_id);
CREATE INDEX idx_alumnos_carrera_apellido ON alumnos_carrera (apellido, nombre);

-- Las 8 tablas que referencian al alumno lo hacen por alumnos_carrera.id,
-- es decir por su inscripcion en UNA carrera, no por la persona.
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

COMMIT;
