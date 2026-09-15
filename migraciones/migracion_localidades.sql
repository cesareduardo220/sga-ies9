-- Tabla de localidades de Argentina
CREATE TABLE IF NOT EXISTS localidades (
    id            SERIAL PRIMARY KEY,
    nombre        VARCHAR(150) NOT NULL,
    departamento  VARCHAR(150),
    provincia     VARCHAR(50)  NOT NULL
);

CREATE INDEX IF NOT EXISTS idx_localidades_provincia ON localidades(provincia);
CREATE INDEX IF NOT EXISTS idx_localidades_nombre    ON localidades(lower(nombre));

-- Columnas nuevas en alumnos
ALTER TABLE alumnos ADD COLUMN IF NOT EXISTS localidad_id  INTEGER REFERENCES localidades(id);
ALTER TABLE alumnos ADD COLUMN IF NOT EXISTS departamento  VARCHAR(150);

-- La localidad actual es VARCHAR(100) y algunos nombres del país son más largos
ALTER TABLE alumnos ALTER COLUMN localidad TYPE VARCHAR(150);

COMMENT ON COLUMN alumnos.localidad_id IS 'FK a localidades. NULL si se cargó texto libre.';
COMMENT ON COLUMN alumnos.departamento IS 'Departamento de la localidad (se completa al elegir de la lista).';

-- Georef expone algunas cabeceras de departamento dos veces (como localidad
-- y como municipio). Este índice impide que vuelvan a entrar duplicadas.
CREATE UNIQUE INDEX IF NOT EXISTS idx_localidades_unica
    ON localidades (lower(nombre), coalesce(departamento,''), provincia);
