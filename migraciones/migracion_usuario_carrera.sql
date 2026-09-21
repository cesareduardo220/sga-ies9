-- ============================================================
-- MIGRACION: usuario_carrera
-- Fecha: 20/09/2026
--
-- Separa la identidad (usuarios: DNI y contrasena, una fila por
-- persona) del vinculo con carreras. Permite que una preceptora
-- atienda varias carreras con una sola credencial. El activo es
-- por vinculo: desactivarla en una carrera no afecta a la otra.
-- ============================================================

CREATE TABLE IF NOT EXISTS public.usuario_carrera (
    usuario_id integer NOT NULL REFERENCES public.usuarios(id) ON DELETE CASCADE,
    carrera_id integer NOT NULL REFERENCES public.carreras(id) ON DELETE CASCADE,
    activo boolean NOT NULL DEFAULT true,
    creado_en timestamp without time zone NOT NULL DEFAULT now(),
    PRIMARY KEY (usuario_id, carrera_id)
);

INSERT INTO public.usuario_carrera (usuario_id, carrera_id)
SELECT id, carrera_id FROM public.usuarios
WHERE rol IN ('coordinador', 'preceptora') AND carrera_id IS NOT NULL
ON CONFLICT DO NOTHING;
