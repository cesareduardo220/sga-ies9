-- Agrega N° de legajo opcional y único a alumnos (13/09/2026)
ALTER TABLE alumnos ADD COLUMN legajo VARCHAR(20) UNIQUE;
