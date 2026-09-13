-- Plan de Estudios: Tecnicatura Superior en Higiene y Seguridad en el Trabajo
-- IES N 9 'Juana Azurduy' - generado el 13/09/2026
-- OJO: completar el numero de resolucion y la fecha de vigencia reales antes de ejecutar.

BEGIN;

-- 1) Carrera
INSERT INTO carreras (nombre, nombre_corto)
VALUES ('Tecnicatura Superior en Higiene y Seguridad en el Trabajo', 'HyS')
ON CONFLICT (nombre) DO NOTHING;

-- 2) Plan de estudios
INSERT INTO planes_estudio (carrera_id, nombre, resolucion, fecha_vigencia, politica_migracion)
SELECT c.id, 'Plan de Estudios 2026', NULL, DATE '2026-01-01', 'exactas'
FROM carreras c WHERE c.nombre = 'Tecnicatura Superior en Higiene y Seguridad en el Trabajo';

-- 3) Materias (26 espacios curriculares)
INSERT INTO materias (carrera_id, plan_id, nombre, anio, orden, regimen, regimen_aprobacion)
SELECT c.id, p.id, v.nombre, v.anio, v.orden, v.regimen, v.regimen_aprobacion
FROM (VALUES
    (1, 1, 'Física', 'Anual', 'Promoción / Examen Final'),
    (1, 2, 'Química Aplicada', 'Anual', 'Promoción / Examen Final'),
    (1, 3, 'Matemática', 'Anual', 'Promoción / Examen Final'),
    (1, 4, 'Informática', '1° C', 'Promoción / Examen Final'),
    (1, 5, 'Organización en el Trabajo', 'Anual', 'Promoción / Examen Final'),
    (1, 6, 'Legislación en el Trabajo', 'Anual', 'Examen Final'),
    (1, 7, 'Higiene en el Trabajo I', 'Anual', 'Examen Final'),
    (1, 8, 'Seguridad en el Trabajo I', 'Anual', 'Examen Final'),
    (1, 9, 'Práctica Profesionalizante I', '2° C', 'Promoción'),
    (2, 10, 'Psicología Laboral y Relaciones Humanas', 'Anual', 'Promoción / Examen Final'),
    (2, 11, 'Inglés Técnico', 'Anual', 'Promoción / Examen Final'),
    (2, 12, 'Seguridad en el Trabajo II', 'Anual', 'Examen Final'),
    (2, 13, 'Higiene en el Trabajo II', 'Anual', 'Examen Final'),
    (2, 14, 'Higiene y Seguridad en Contextos Particulares', 'Anual', 'Examen Final'),
    (2, 15, 'Estudio del Trabajo y Ergonomía', 'Anual', 'Examen Final'),
    (2, 16, 'Probabilidad y Estadística', '2° C', 'Promoción / Examen Final'),
    (2, 17, 'Práctica Profesionalizante II', 'Anual', 'Promoción / Examen Final'),
    (2, 18, 'EDI I', 'Anual', 'Promoción'),
    (3, 19, 'Capacitación Laboral', 'Anual', 'Promoción / Examen Final'),
    (3, 20, 'Gestión Integrada', 'Anual', 'Examen Final'),
    (3, 21, 'Medicina del Trabajo', 'Anual', 'Examen Final'),
    (3, 22, 'Sistemas de Representación', 'Anual', 'Promoción / Examen Final'),
    (3, 23, 'Ética y Deontología Profesional', 'Anual', 'Promoción / Examen Final'),
    (3, 24, 'EDI II', 'Anual', 'Promoción'),
    (3, 25, 'Formulación y Elaboración de Proyecto', 'Anual', 'Promoción / Examen Final'),
    (3, 26, 'Práctica Profesionalizante III', 'Anual', 'Promoción')
) AS v(anio, orden, nombre, regimen, regimen_aprobacion)
CROSS JOIN carreras c
JOIN planes_estudio p ON p.carrera_id = c.id
WHERE c.nombre = 'Tecnicatura Superior en Higiene y Seguridad en el Trabajo' AND p.nombre = 'Plan de Estudios 2026';

-- 4) Correlatividades
INSERT INTO correlatividades (materia_id, requiere_materia_id, tipo)
SELECT m.id, r.id, v.tipo
FROM (VALUES
    (12, 1, 'cursada'),
    (12, 2, 'cursada'),
    (12, 8, 'cursada'),
    (12, 1, 'aprobada'),
    (12, 2, 'aprobada'),
    (12, 8, 'aprobada'),
    (12, 9, 'aprobada'),
    (13, 1, 'cursada'),
    (13, 2, 'cursada'),
    (13, 7, 'cursada'),
    (13, 1, 'aprobada'),
    (13, 2, 'aprobada'),
    (13, 7, 'aprobada'),
    (13, 9, 'aprobada'),
    (14, 7, 'cursada'),
    (14, 8, 'cursada'),
    (14, 9, 'cursada'),
    (14, 7, 'aprobada'),
    (14, 8, 'aprobada'),
    (14, 9, 'aprobada'),
    (15, 1, 'cursada'),
    (15, 2, 'cursada'),
    (15, 5, 'cursada'),
    (15, 7, 'cursada'),
    (15, 8, 'cursada'),
    (15, 1, 'aprobada'),
    (15, 2, 'aprobada'),
    (15, 5, 'aprobada'),
    (15, 7, 'aprobada'),
    (15, 8, 'aprobada'),
    (15, 9, 'aprobada'),
    (16, 1, 'cursada'),
    (16, 2, 'cursada'),
    (16, 3, 'cursada'),
    (16, 1, 'aprobada'),
    (16, 2, 'aprobada'),
    (16, 3, 'aprobada'),
    (17, 7, 'cursada'),
    (17, 8, 'cursada'),
    (17, 9, 'cursada'),
    (17, 7, 'aprobada'),
    (17, 8, 'aprobada'),
    (17, 9, 'aprobada'),
    (19, 10, 'cursada'),
    (19, 10, 'aprobada'),
    (20, 12, 'cursada'),
    (20, 13, 'cursada'),
    (20, 14, 'cursada'),
    (20, 15, 'cursada'),
    (20, 17, 'cursada'),
    (20, 12, 'aprobada'),
    (20, 13, 'aprobada'),
    (20, 14, 'aprobada'),
    (20, 15, 'aprobada'),
    (20, 17, 'aprobada'),
    (21, 6, 'cursada'),
    (21, 10, 'cursada'),
    (21, 12, 'cursada'),
    (21, 13, 'cursada'),
    (21, 15, 'cursada'),
    (21, 6, 'aprobada'),
    (21, 10, 'aprobada'),
    (21, 12, 'aprobada'),
    (21, 13, 'aprobada'),
    (21, 15, 'aprobada'),
    (22, 4, 'cursada'),
    (22, 4, 'aprobada'),
    (23, 10, 'cursada'),
    (23, 10, 'aprobada'),
    (24, 18, 'aprobada'),
    (25, 5, 'cursada'),
    (25, 10, 'cursada'),
    (25, 18, 'cursada'),
    (25, 5, 'aprobada'),
    (25, 10, 'aprobada'),
    (25, 18, 'aprobada'),
    (26, 12, 'cursada'),
    (26, 13, 'cursada'),
    (26, 14, 'cursada'),
    (26, 15, 'cursada'),
    (26, 17, 'cursada'),
    (26, 12, 'aprobada'),
    (26, 13, 'aprobada'),
    (26, 14, 'aprobada'),
    (26, 15, 'aprobada'),
    (26, 17, 'aprobada')
) AS v(orden_materia, orden_requiere, tipo)
JOIN carreras c ON c.nombre = 'Tecnicatura Superior en Higiene y Seguridad en el Trabajo'
JOIN materias m ON m.carrera_id = c.id AND m.orden = v.orden_materia
JOIN materias r ON r.carrera_id = c.id AND r.orden = v.orden_requiere;

COMMIT;
