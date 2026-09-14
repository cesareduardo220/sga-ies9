-- ============================================================
-- Módulo de autoinscripción por Internet
-- Tablas: tokens_inscripcion y preinscripciones
-- ============================================================
 
-- ------------------------------------------------------------
-- Tokens de acceso al formulario público
-- ------------------------------------------------------------
CREATE TABLE IF NOT EXISTS tokens_inscripcion (
    id              SERIAL PRIMARY KEY,
    token           VARCHAR(9)  NOT NULL UNIQUE,
    tipo            VARCHAR(15) NOT NULL,
    alumno_id       INTEGER     REFERENCES alumnos(id) ON DELETE CASCADE,
    carrera_id      INTEGER     NOT NULL REFERENCES carreras(id) ON DELETE RESTRICT,
    ciclo_lectivo   INTEGER     NOT NULL,
    estado          VARCHAR(15) NOT NULL DEFAULT 'disponible',
    vence_el        DATE        NOT NULL,
    generado_por    INTEGER     REFERENCES usuarios(id) ON DELETE SET NULL,
    generado_en     TIMESTAMP   NOT NULL DEFAULT now(),
    usado_en        TIMESTAMP,
    anulado_en      TIMESTAMP,
    anulado_por     INTEGER     REFERENCES usuarios(id) ON DELETE SET NULL,
 
    CONSTRAINT tokens_inscripcion_tipo_check
        CHECK (tipo IN ('ingresante', 'reinscripcion')),
 
    CONSTRAINT tokens_inscripcion_estado_check
        CHECK (estado IN ('disponible', 'usado', 'anulado')),
 
    -- Un token de reinscripción SIEMPRE apunta a un alumno existente.
    -- Uno de ingresante NUNCA, porque el alumno todavía no está en la base.
    CONSTRAINT tokens_inscripcion_alumno_coherente
        CHECK (
            (tipo = 'reinscripcion' AND alumno_id IS NOT NULL)
            OR
            (tipo = 'ingresante'    AND alumno_id IS NULL)
        )
);
 
-- Un alumno no puede tener dos tokens de reinscripción vivos en el mismo ciclo
CREATE UNIQUE INDEX IF NOT EXISTS idx_tokens_alumno_ciclo_vivo
    ON tokens_inscripcion (alumno_id, ciclo_lectivo)
    WHERE alumno_id IS NOT NULL AND estado = 'disponible';
 
CREATE INDEX IF NOT EXISTS idx_tokens_estado   ON tokens_inscripcion (estado);
CREATE INDEX IF NOT EXISTS idx_tokens_ciclo    ON tokens_inscripcion (ciclo_lectivo);
CREATE INDEX IF NOT EXISTS idx_tokens_carrera  ON tokens_inscripcion (carrera_id);
 
COMMENT ON TABLE  tokens_inscripcion IS 'Tokens de un solo uso que habilitan el formulario público de inscripción. La preceptora los entrega después del control de documentación.';
COMMENT ON COLUMN tokens_inscripcion.token IS 'Formato XXXX-XXXX, sin caracteres ambiguos (0/O, 1/I/L). Se dicta o se escribe a mano.';
COMMENT ON COLUMN tokens_inscripcion.tipo IS 'Define qué pantalla ve el alumno: formulario en blanco (ingresante) o reinscripción con datos precargados.';
COMMENT ON COLUMN tokens_inscripcion.alumno_id IS 'Solo en tokens de reinscripción. NULL en ingresantes.';
COMMENT ON COLUMN tokens_inscripcion.estado IS 'disponible = sin usar | usado = ya generó una preinscripción | anulado = dado de baja a mano.';
 
 
-- ------------------------------------------------------------
-- Datos que carga el alumno desde el formulario público.
-- Espeja los campos reales de alumnos para que aprobar sea un
-- INSERT directo, sin traducir nada a mano.
-- ------------------------------------------------------------
CREATE TABLE IF NOT EXISTS preinscripciones (
    id                            SERIAL PRIMARY KEY,
    token_id                      INTEGER NOT NULL UNIQUE
                                      REFERENCES tokens_inscripcion(id) ON DELETE RESTRICT,
    ciclo_lectivo                 INTEGER NOT NULL,
 
    -- Identificación
    tipo_documento                VARCHAR(10)  NOT NULL DEFAULT 'DNI',
    dni                           VARCHAR(15)  NOT NULL,
    cuil                          VARCHAR(11),
    apellido                      VARCHAR(100) NOT NULL,
    nombre                        VARCHAR(100) NOT NULL,
    fecha_nacimiento              DATE,
 
    -- Contacto
    email                         VARCHAR(150),
    celular                       VARCHAR(20),
    telefono                      VARCHAR(20),
 
    -- Domicilio
    direccion                     VARCHAR(200),
    localidad_id                  INTEGER REFERENCES localidades(id),
    localidad                     VARCHAR(150),
    departamento                  VARCHAR(150),
    provincia                     VARCHAR(50),
 
    -- Contacto de emergencia
    contacto_emergencia_nombre    VARCHAR(150),
    contacto_emergencia_vinculo   VARCHAR(50),
    contacto_emergencia_telefono  VARCHAR(30),
 
    -- Carrera a la que se inscribe
    carrera_id                    INTEGER NOT NULL REFERENCES carreras(id) ON DELETE RESTRICT,
    plan_id                       INTEGER REFERENCES planes_estudio(id) ON DELETE SET NULL,
 
    -- Revisión de la preceptora
    estado                        VARCHAR(15) NOT NULL DEFAULT 'pendiente',
    observaciones                 TEXT,
    revisado_por                  INTEGER REFERENCES usuarios(id) ON DELETE SET NULL,
    revisado_en                   TIMESTAMP,
    alumno_id                     INTEGER REFERENCES alumnos(id) ON DELETE SET NULL,
 
    creado_en                     TIMESTAMP NOT NULL DEFAULT now(),
 
    CONSTRAINT preinscripciones_tipo_documento_check
        CHECK (tipo_documento IN ('DNI', 'DNI_EXT', 'PAS', 'CI')),
 
    CONSTRAINT preinscripciones_estado_check
        CHECK (estado IN ('pendiente', 'aprobada', 'rechazada')),
 
    -- Un mismo documento no se preinscribe dos veces en el mismo ciclo
    CONSTRAINT preinscripciones_dni_ciclo_unico
        UNIQUE (dni, ciclo_lectivo)
);
 
CREATE INDEX IF NOT EXISTS idx_preinscripciones_estado  ON preinscripciones (estado);
CREATE INDEX IF NOT EXISTS idx_preinscripciones_ciclo   ON preinscripciones (ciclo_lectivo);
CREATE INDEX IF NOT EXISTS idx_preinscripciones_carrera ON preinscripciones (carrera_id);
 
COMMENT ON TABLE  preinscripciones IS 'Cola de revisión: lo que carga el alumno desde el formulario público. Al aprobarse se vuelca a alumnos.';
COMMENT ON COLUMN preinscripciones.token_id IS 'Token que habilitó esta carga. UNIQUE: un token genera una sola preinscripción.';
COMMENT ON COLUMN preinscripciones.localidad_id IS 'FK a localidades. NULL si se cargó texto libre.';
COMMENT ON COLUMN preinscripciones.estado IS 'pendiente = esperando revisión | aprobada = ya volcada a alumnos | rechazada = descartada con motivo en observaciones.';
COMMENT ON COLUMN preinscripciones.observaciones IS 'Motivo del rechazo o nota interna de la preceptora.';
COMMENT ON COLUMN preinscripciones.alumno_id IS 'Se completa al aprobar: el registro de alumnos que se creó o actualizó a partir de esta preinscripción.';
 
 
-- ------------------------------------------------------------
-- Parámetros de configuración del módulo
-- ------------------------------------------------------------
INSERT INTO configuracion (clave, valor, descripcion)
VALUES
    ('autoinscripcion_habilitada', 'false',
     'Interruptor general del formulario publico de inscripcion (true/false)'),
    ('autoinscripcion_vigencia_dias', '15',
     'Dias de validez de un token desde que se genera'),
    ('autoinscripcion_fecha_inicio', '',
     'Inicio del periodo de autoinscripcion online (YYYY-MM-DD)'),
    ('autoinscripcion_fecha_fin', '',
     'Fin del periodo de autoinscripcion online (YYYY-MM-DD)')
ON CONFLICT (clave) DO NOTHING;
 

