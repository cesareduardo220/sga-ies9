-- Anonimización de preinscripciones rechazadas
BEGIN;

ALTER TABLE preinscripciones
    ADD COLUMN IF NOT EXISTS anonimizado_en timestamp;

INSERT INTO configuracion (clave, valor, descripcion)
SELECT 'preinscripciones_anonimizar_dias', '300',
       'Días después del rechazo en que se borran los datos personales de la preinscripción'
WHERE NOT EXISTS (
    SELECT 1 FROM configuracion WHERE clave = 'preinscripciones_anonimizar_dias'
);

COMMIT;
