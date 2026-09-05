-- ================================================================
-- SGA - IES N 9 "Juana Azurduy"
-- MIGRACION: promocion provisoria por correlativa adeudada
--
-- Ejecutar UNA sola vez en DBeaver sobre la base ies9_gestion.
-- Es una migracion aditiva: no borra ni modifica datos existentes.
-- ================================================================

-- ── 1) Marca de promocion provisoria en cursadas ────────────────
-- TRUE  = el alumno promociono pero adeuda el final de una
--         correlativa. La promocion todavia no esta firme.
-- FALSE = promocion firme, o la condicion no es promocionado.
ALTER TABLE public.cursadas
    ADD COLUMN IF NOT EXISTS promocion_provisoria boolean NOT NULL DEFAULT false;

COMMENT ON COLUMN public.cursadas.promocion_provisoria IS
    'Promocion sujeta a que el alumno apruebe el final de su correlativa antes de la fecha limite del ciclo lectivo.';

-- Indice parcial: las consultas siempre buscan las provisorias,
-- que son pocas frente al total de cursadas.
CREATE INDEX IF NOT EXISTS idx_cursadas_promocion_provisoria
    ON public.cursadas (promocion_provisoria)
    WHERE promocion_provisoria;

-- ── 2) Parametros de configuracion ──────────────────────────────
-- fecha_limite_promocion: dia y mes (DD-MM) hasta el cual el alumno
--   puede aprobar el final de la correlativa. Pasada esa fecha, la
--   promocion provisoria baja a regular. Se aplica sobre el anio
--   lectivo de cada cursada, no sobre el anio configurado como vigente.
INSERT INTO configuracion (clave, valor, descripcion) VALUES
    ('fecha_limite_promocion', '31-12',
     'Fecha limite (DD-MM) para aprobar el final de la correlativa y confirmar la promocion')
ON CONFLICT (clave) DO NOTHING;

-- ── 3) Verificacion ─────────────────────────────────────────────
SELECT 'Columna creada:' AS control,
       COUNT(*)::text AS cantidad
FROM information_schema.columns
WHERE table_name = 'cursadas' AND column_name = 'promocion_provisoria'
UNION ALL
SELECT 'Parametro presente:', COUNT(*)::text
FROM configuracion
WHERE clave = 'fecha_limite_promocion';
