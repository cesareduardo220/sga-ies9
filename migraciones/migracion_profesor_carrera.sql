-- ============================================================
-- MIGRACION: profesor_carrera
-- Fecha: 20/09/2026
--
-- Un profesor es una sola persona (profesores, UNIQUE dni), pero
-- cada carrera ve y gestiona solo a los que tiene vinculados.
-- Quitar un profesor de una carrera borra el vinculo y sus
-- asignaciones en esa carrera; no toca las otras carreras.
-- ============================================================

CREATE TABLE IF NOT EXISTS public.profesor_carrera (
    profesor_id integer NOT NULL REFERENCES public.profesores(id) ON DELETE CASCADE,
    carrera_id integer NOT NULL REFERENCES public.carreras(id) ON DELETE CASCADE,
    creado_en timestamp without time zone NOT NULL DEFAULT now(),
    PRIMARY KEY (profesor_id, carrera_id)
);

INSERT INTO public.profesor_carrera (profesor_id, carrera_id)
SELECT DISTINCT mp.profesor_id, m.carrera_id
FROM public.materia_profesor mp
JOIN public.materias m ON m.id = mp.materia_id
ON CONFLICT DO NOTHING;
