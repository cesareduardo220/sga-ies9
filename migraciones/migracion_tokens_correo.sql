-- ============================================================
-- Tokens de inscripción: envío por correo
-- Cada token guarda a qué correo se mandó y cómo salió el envío.
--   email_estado: NULL (nunca se envió) | pendiente | enviado | error
-- ============================================================

BEGIN;

ALTER TABLE tokens_inscripcion
    ADD COLUMN IF NOT EXISTS email_destino       VARCHAR(150),
    ADD COLUMN IF NOT EXISTS email_estado        VARCHAR(15),
    ADD COLUMN IF NOT EXISTS email_error         TEXT,
    ADD COLUMN IF NOT EXISTS email_solicitado_en TIMESTAMP,
    ADD COLUMN IF NOT EXISTS email_enviado_en    TIMESTAMP;

ALTER TABLE tokens_inscripcion
    DROP CONSTRAINT IF EXISTS tokens_inscripcion_email_estado_check;
ALTER TABLE tokens_inscripcion
    ADD CONSTRAINT tokens_inscripcion_email_estado_check
    CHECK (email_estado IS NULL OR email_estado IN ('pendiente', 'enviado', 'error'));

CREATE INDEX IF NOT EXISTS idx_tokens_email_destino
    ON tokens_inscripcion (lower(email_destino));

COMMENT ON COLUMN tokens_inscripcion.email_destino IS
    'Correo al que se envió el token (el del legajo en reinscripción, el que cargó preceptoría en ingresante y alta).';
COMMENT ON COLUMN tokens_inscripcion.email_estado IS
    'Resultado del último envío: pendiente, enviado o error. NULL si nunca se envió.';

COMMIT;
