--
-- ================================================================
-- SISTEMA DE GESTION ACADEMICA (SGA)
-- IES N 9 "Juana Azurduy" - San Pedro de Jujuy
-- Practicas Profesionalizantes III
--
-- Version: 7.2  (24/09/2026)
-- Generado con pg_dump --schema-only --no-owner --no-privileges
-- desde la base real. Refleja la estructura completa (26 tablas).
--
-- CAMBIOS EN 7.2
--   + usuarios.genero y profesores.genero (char(1): M, F o NULL)
--     para las etiquetas de rol segun el genero
--   + se incorporan 5 tablas que existian en la base pero faltaban
--     en este archivo: alumnos_carrera, localidades,
--     preinscripciones, preinscripcion_materias, tokens_inscripcion
--   * sin OWNER TO ni GRANT: queda a nombre del usuario que instala
--
-- CAMBIOS EN 7.1
--   + usuarios.sesion_token (text) para la sesion unica por usuario
--   + tabla usuario_carrera: una preceptora puede trabajar en varias carreras
--   + tabla profesor_carrera: cada carrera ve y gestiona solo sus profesores
--
-- CAMBIOS RESPECTO DE v6
--   + cursadas.promocion_provisoria (boolean NOT NULL DEFAULT false)
--   + indice parcial idx_cursadas_promocion_provisoria
--   Ya NO hace falta correr migracion_promocion_provisoria.sql;
--   esa migracion sigue existiendo solo para bases creadas con v6.
--
-- USO: crear la base vacia y ejecutar este script.
--      createdb ies9_gestion
--      psql -d ies9_gestion -f sga_ies9_v7.sql
--
-- Solo contiene la ESTRUCTURA, no los datos.
-- ================================================================

--
-- PostgreSQL database dump
--

\restrict vhxcy37QUFQhEcug6CekcEiQsJkQCgUCowwBueAWgQbWlLF1OAXpqPXjDqlDzbj

-- Dumped from database version 18.6 (Ubuntu 18.6-0ubuntu0.26.04.1)
-- Dumped by pg_dump version 18.6 (Ubuntu 18.6-0ubuntu0.26.04.1)

SET statement_timeout = 0;
SET lock_timeout = 0;
SET idle_in_transaction_session_timeout = 0;
SET transaction_timeout = 0;
SET client_encoding = 'UTF8';
SET standard_conforming_strings = on;
SELECT pg_catalog.set_config('search_path', '', false);
SET check_function_bodies = false;
SET xmloption = content;
SET client_min_messages = warning;
SET row_security = off;

SET default_tablespace = '';

SET default_table_access_method = heap;

--
-- Name: alumnos; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.alumnos (
    id integer NOT NULL,
    dni character varying(15) NOT NULL,
    nombre character varying(100) NOT NULL,
    apellido character varying(100) NOT NULL,
    fecha_nacimiento date,
    celular character varying(20),
    telefono character varying(20),
    email character varying(150),
    carrera_id integer NOT NULL,
    anio_ingreso integer NOT NULL,
    activo boolean DEFAULT true NOT NULL,
    contacto_emergencia_nombre character varying(150),
    contacto_emergencia_vinculo character varying(50),
    creado_en timestamp without time zone DEFAULT now() NOT NULL,
    direccion character varying(200),
    localidad character varying(150),
    contacto_emergencia_telefono character varying(30),
    cuil character varying(11),
    plan_id integer,
    tipo_documento character varying(10) DEFAULT 'DNI'::character varying NOT NULL,
    provincia character varying(50) DEFAULT NULL::character varying,
    legajo character varying(20),
    localidad_id integer,
    departamento character varying(150),
    CONSTRAINT alumnos_tipo_documento_check CHECK (((tipo_documento)::text = ANY (ARRAY[('DNI'::character varying)::text, ('DNI_EXT'::character varying)::text, ('PAS'::character varying)::text, ('CI'::character varying)::text])))
);


--
-- Name: COLUMN alumnos.cuil; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.alumnos.cuil IS 'CUIL/CUIT del alumno (11 dígitos sin guiones). Opcional. Validado con dígito verificador AFIP.';


--
-- Name: COLUMN alumnos.tipo_documento; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.alumnos.tipo_documento IS 'Tipo de documento: DNI/DNI_EXT (argentino, 7-8 dígitos) | PAS/CI (alfanumérico, 5-20 caracteres)';


--
-- Name: COLUMN alumnos.provincia; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.alumnos.provincia IS 'Provincia/jurisdicción argentina del alumno (opcional). 24 jurisdicciones válidas.';


--
-- Name: COLUMN alumnos.localidad_id; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.alumnos.localidad_id IS 'FK a localidades. NULL si se cargó texto libre.';


--
-- Name: COLUMN alumnos.departamento; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.alumnos.departamento IS 'Departamento de la localidad (se completa al elegir de la lista).';


--
-- Name: alumnos_carrera; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.alumnos_carrera (
    id integer CONSTRAINT alumnos_carrera_id_not_null1 NOT NULL,
    carrera_id integer NOT NULL,
    plan_id integer,
    anio_ingreso integer NOT NULL,
    activo boolean DEFAULT true NOT NULL,
    apellido character varying(100) NOT NULL,
    nombre character varying(100) NOT NULL,
    dni character varying(15) NOT NULL,
    tipo_documento character varying(10) DEFAULT 'DNI'::character varying NOT NULL,
    cuil character varying(11),
    fecha_nacimiento date,
    legajo character varying(20),
    email character varying(150),
    celular character varying(20),
    telefono character varying(20),
    direccion character varying(200),
    localidad character varying(150),
    localidad_id integer,
    provincia character varying(50),
    departamento character varying(150),
    contacto_emergencia_nombre character varying(150),
    contacto_emergencia_vinculo character varying(50),
    contacto_emergencia_telefono character varying(30),
    creado_en timestamp without time zone DEFAULT now() NOT NULL,
    CONSTRAINT alumnos_carrera_tipo_documento_check CHECK (((tipo_documento)::text = ANY (ARRAY[('DNI'::character varying)::text, ('DNI_EXT'::character varying)::text, ('PAS'::character varying)::text, ('CI'::character varying)::text])))
);


--
-- Name: alumnos_carrera_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.alumnos_carrera_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: alumnos_carrera_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.alumnos_carrera_id_seq OWNED BY public.alumnos_carrera.id;


--
-- Name: alumnos_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.alumnos_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: alumnos_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.alumnos_id_seq OWNED BY public.alumnos.id;


--
-- Name: carreras; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.carreras (
    id integer NOT NULL,
    nombre character varying(150) NOT NULL,
    nombre_corto character varying(40),
    activa boolean DEFAULT true NOT NULL,
    creada_en timestamp without time zone DEFAULT now() NOT NULL
);


--
-- Name: carreras_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.carreras_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: carreras_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.carreras_id_seq OWNED BY public.carreras.id;


--
-- Name: configuracion; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.configuracion (
    id integer NOT NULL,
    clave character varying(100) NOT NULL,
    valor character varying(255) NOT NULL,
    descripcion character varying(255)
);


--
-- Name: configuracion_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.configuracion_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: configuracion_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.configuracion_id_seq OWNED BY public.configuracion.id;


--
-- Name: correlatividades; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.correlatividades (
    id integer NOT NULL,
    materia_id integer NOT NULL,
    requiere_materia_id integer NOT NULL,
    tipo character varying(20) NOT NULL,
    CONSTRAINT correlatividades_tipo_check CHECK (((tipo)::text = ANY (ARRAY[('cursada'::character varying)::text, ('aprobada'::character varying)::text])))
);


--
-- Name: correlatividades_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.correlatividades_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: correlatividades_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.correlatividades_id_seq OWNED BY public.correlatividades.id;


--
-- Name: cursadas; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.cursadas (
    id integer NOT NULL,
    inscripcion_id integer NOT NULL,
    nota_cursada numeric(4,2),
    porcentaje_asistencia numeric(5,2),
    condicion character varying(20),
    cerrada boolean DEFAULT false NOT NULL,
    observaciones text,
    cargado_en timestamp without time zone DEFAULT now() NOT NULL,
    porcentaje_tp numeric(5,2),
    libro character varying(20),
    folio character varying(20),
    promocion_provisoria boolean DEFAULT false NOT NULL,
    CONSTRAINT cursadas_condicion_check CHECK (((condicion)::text = ANY (ARRAY[('regular'::character varying)::text, ('libre'::character varying)::text, ('promocionado'::character varying)::text, ('ausente'::character varying)::text, ('aprobado'::character varying)::text]))),
    CONSTRAINT cursadas_nota_cursada_check CHECK (((nota_cursada >= (1)::numeric) AND (nota_cursada <= (10)::numeric))),
    CONSTRAINT cursadas_porcentaje_asistencia_check CHECK (((porcentaje_asistencia >= (0)::numeric) AND (porcentaje_asistencia <= (100)::numeric))),
    CONSTRAINT cursadas_porcentaje_tp_check CHECK (((porcentaje_tp >= (0)::numeric) AND (porcentaje_tp <= (100)::numeric)))
);


--
-- Name: COLUMN cursadas.promocion_provisoria; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.cursadas.promocion_provisoria IS 'Promocion sujeta a que el alumno apruebe el final de su correlativa antes de la fecha limite del ciclo lectivo.';


--
-- Name: cursadas_auditoria; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.cursadas_auditoria (
    id integer NOT NULL,
    cursada_id integer NOT NULL,
    campo character varying(50) NOT NULL,
    valor_anterior text,
    valor_nuevo text,
    modificado_por_id integer,
    motivo text NOT NULL,
    modificado_en timestamp without time zone DEFAULT now() NOT NULL
);


--
-- Name: cursadas_auditoria_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.cursadas_auditoria_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: cursadas_auditoria_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.cursadas_auditoria_id_seq OWNED BY public.cursadas_auditoria.id;


--
-- Name: cursadas_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.cursadas_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: cursadas_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.cursadas_id_seq OWNED BY public.cursadas.id;


--
-- Name: equivalencias_plan; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.equivalencias_plan (
    id integer NOT NULL,
    plan_nuevo_id integer NOT NULL,
    materia_nueva_id integer NOT NULL,
    materia_vieja_id integer NOT NULL,
    automatica boolean DEFAULT false NOT NULL,
    creado_en timestamp without time zone DEFAULT now() NOT NULL
);


--
-- Name: equivalencias_plan_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.equivalencias_plan_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: equivalencias_plan_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.equivalencias_plan_id_seq OWNED BY public.equivalencias_plan.id;


--
-- Name: examenes; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.examenes (
    id integer NOT NULL,
    alumno_id integer NOT NULL,
    materia_id integer NOT NULL,
    anio_lectivo integer NOT NULL,
    fecha_mesa date NOT NULL,
    nota numeric(4,2),
    resultado character varying(20),
    observaciones text,
    CONSTRAINT examenes_nota_check CHECK (((nota >= (1)::numeric) AND (nota <= (10)::numeric))),
    CONSTRAINT examenes_resultado_check CHECK (((resultado)::text = ANY (ARRAY[('aprobado'::character varying)::text, ('desaprobado'::character varying)::text, ('ausente'::character varying)::text])))
);


--
-- Name: examenes_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.examenes_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: examenes_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.examenes_id_seq OWNED BY public.examenes.id;


--
-- Name: historial_plan_alumno; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.historial_plan_alumno (
    id integer NOT NULL,
    alumno_id integer NOT NULL,
    plan_viejo_id integer,
    plan_nuevo_id integer NOT NULL,
    motivo character varying(50) NOT NULL,
    registrado_por integer,
    registrado_en timestamp without time zone DEFAULT now() NOT NULL,
    CONSTRAINT historial_plan_alumno_motivo_check CHECK (((motivo)::text = ANY (ARRAY[('ingreso'::character varying)::text, ('vencimiento'::character varying)::text, ('automatico'::character varying)::text, ('manual'::character varying)::text])))
);


--
-- Name: historial_plan_alumno_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.historial_plan_alumno_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: historial_plan_alumno_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.historial_plan_alumno_id_seq OWNED BY public.historial_plan_alumno.id;


--
-- Name: inscripciones; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.inscripciones (
    id integer NOT NULL,
    alumno_id integer NOT NULL,
    materia_id integer NOT NULL,
    anio_lectivo integer NOT NULL,
    fecha date DEFAULT CURRENT_DATE NOT NULL
);


--
-- Name: inscripciones_auditoria; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.inscripciones_auditoria (
    id integer NOT NULL,
    alumno_id integer,
    coordinador_id integer NOT NULL,
    accion character varying(40) NOT NULL,
    motivo text NOT NULL,
    detalle jsonb,
    fecha timestamp without time zone DEFAULT now() NOT NULL,
    anio_lectivo integer NOT NULL
);


--
-- Name: TABLE inscripciones_auditoria; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON TABLE public.inscripciones_auditoria IS 'Registro de toda modificación coordinador-autorizada sobre inscripciones';


--
-- Name: inscripciones_auditoria_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.inscripciones_auditoria_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: inscripciones_auditoria_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.inscripciones_auditoria_id_seq OWNED BY public.inscripciones_auditoria.id;


--
-- Name: inscripciones_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.inscripciones_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: inscripciones_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.inscripciones_id_seq OWNED BY public.inscripciones.id;


--
-- Name: inscripciones_mesa; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.inscripciones_mesa (
    id integer NOT NULL,
    mesa_id integer NOT NULL,
    alumno_id integer NOT NULL,
    resultado character varying(20),
    nota_escrita numeric(4,2),
    nota_oral numeric(4,2),
    nota_final numeric(4,2),
    CONSTRAINT inscripciones_mesa_nota_escrita_check CHECK (((nota_escrita >= (1)::numeric) AND (nota_escrita <= (10)::numeric))),
    CONSTRAINT inscripciones_mesa_nota_final_check CHECK (((nota_final >= (1)::numeric) AND (nota_final <= (10)::numeric))),
    CONSTRAINT inscripciones_mesa_nota_oral_check CHECK (((nota_oral >= (1)::numeric) AND (nota_oral <= (10)::numeric))),
    CONSTRAINT inscripciones_mesa_resultado_check CHECK (((resultado)::text = ANY (ARRAY[('aprobado'::character varying)::text, ('desaprobado'::character varying)::text, ('ausente'::character varying)::text])))
);


--
-- Name: inscripciones_mesa_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.inscripciones_mesa_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: inscripciones_mesa_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.inscripciones_mesa_id_seq OWNED BY public.inscripciones_mesa.id;


--
-- Name: localidades; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.localidades (
    id integer NOT NULL,
    nombre character varying(150) NOT NULL,
    departamento character varying(150),
    provincia character varying(100) NOT NULL
);


--
-- Name: localidades_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.localidades_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: localidades_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.localidades_id_seq OWNED BY public.localidades.id;


--
-- Name: materia_profesor; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.materia_profesor (
    id integer NOT NULL,
    materia_id integer NOT NULL,
    profesor_id integer NOT NULL,
    anio_lectivo integer NOT NULL
);


--
-- Name: materia_profesor_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.materia_profesor_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: materia_profesor_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.materia_profesor_id_seq OWNED BY public.materia_profesor.id;


--
-- Name: materias; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.materias (
    id integer NOT NULL,
    carrera_id integer NOT NULL,
    nombre character varying(150) NOT NULL,
    anio integer NOT NULL,
    orden integer NOT NULL,
    regimen character varying(50),
    regimen_aprobacion character varying(100),
    activa boolean DEFAULT true NOT NULL,
    plan_id integer,
    CONSTRAINT materias_anio_check CHECK (((anio >= 1) AND (anio <= 6)))
);


--
-- Name: materias_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.materias_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: materias_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.materias_id_seq OWNED BY public.materias.id;


--
-- Name: mesas_examen; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.mesas_examen (
    id integer NOT NULL,
    carrera_id integer NOT NULL,
    materia_id integer NOT NULL,
    tipo character varying(10) NOT NULL,
    fecha_mesa date NOT NULL,
    turno character varying(20) DEFAULT 'Tarde'::character varying NOT NULL,
    anio_lectivo integer NOT NULL,
    numero_acta integer NOT NULL,
    cerrada boolean DEFAULT false NOT NULL,
    creada_en timestamp without time zone DEFAULT now() NOT NULL,
    motivo_cierre text,
    CONSTRAINT mesas_examen_tipo_check CHECK (((tipo)::text = ANY (ARRAY[('regular'::character varying)::text, ('libre'::character varying)::text])))
);


--
-- Name: mesas_examen_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.mesas_examen_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: mesas_examen_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.mesas_examen_id_seq OWNED BY public.mesas_examen.id;


--
-- Name: planes_estudio; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.planes_estudio (
    id integer NOT NULL,
    carrera_id integer NOT NULL,
    nombre character varying(150) NOT NULL,
    resolucion character varying(100),
    fecha_vigencia date NOT NULL,
    fecha_cierre date,
    politica_migracion character varying(30) DEFAULT 'exactas'::character varying NOT NULL,
    activo boolean DEFAULT true NOT NULL,
    creado_en timestamp without time zone DEFAULT now() NOT NULL,
    CONSTRAINT planes_estudio_politica_migracion_check CHECK (((politica_migracion)::text = ANY (ARRAY[('ninguna'::character varying)::text, ('exactas'::character varying)::text, ('similares'::character varying)::text, ('personalizado'::character varying)::text])))
);


--
-- Name: planes_estudio_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.planes_estudio_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: planes_estudio_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.planes_estudio_id_seq OWNED BY public.planes_estudio.id;


--
-- Name: preinscripcion_materias; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.preinscripcion_materias (
    id integer NOT NULL,
    preinscripcion_id integer NOT NULL,
    materia_id integer NOT NULL
);


--
-- Name: TABLE preinscripcion_materias; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON TABLE public.preinscripcion_materias IS 'Materias elegidas por el alumno en la reinscripción en línea. Se vuelcan a inscripciones al aprobar la preinscripción.';


--
-- Name: preinscripcion_materias_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.preinscripcion_materias_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: preinscripcion_materias_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.preinscripcion_materias_id_seq OWNED BY public.preinscripcion_materias.id;


--
-- Name: preinscripciones; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.preinscripciones (
    id integer NOT NULL,
    token_id integer NOT NULL,
    ciclo_lectivo integer NOT NULL,
    tipo_documento character varying(10) DEFAULT 'DNI'::character varying NOT NULL,
    dni character varying(15) NOT NULL,
    cuil character varying(11),
    apellido character varying(100) NOT NULL,
    nombre character varying(100) NOT NULL,
    fecha_nacimiento date,
    email character varying(150),
    celular character varying(20),
    telefono character varying(20),
    direccion character varying(200),
    localidad_id integer,
    localidad character varying(150),
    departamento character varying(150),
    provincia character varying(50),
    contacto_emergencia_nombre character varying(150),
    contacto_emergencia_vinculo character varying(50),
    contacto_emergencia_telefono character varying(30),
    carrera_id integer NOT NULL,
    plan_id integer,
    estado character varying(15) DEFAULT 'pendiente'::character varying NOT NULL,
    observaciones text,
    revisado_por integer,
    revisado_en timestamp without time zone,
    alumno_id integer,
    creado_en timestamp without time zone DEFAULT now() NOT NULL,
    anio_ingreso integer,
    anonimizado_en timestamp without time zone,
    CONSTRAINT preinscripciones_anio_ingreso_check CHECK (((anio_ingreso IS NULL) OR ((anio_ingreso >= 1990) AND (anio_ingreso <= 2100)))),
    CONSTRAINT preinscripciones_estado_check CHECK (((estado)::text = ANY ((ARRAY['pendiente'::character varying, 'aprobada'::character varying, 'rechazada'::character varying])::text[]))),
    CONSTRAINT preinscripciones_rechazo_con_motivo CHECK ((((estado)::text <> 'rechazada'::text) OR ((observaciones IS NOT NULL) AND (length(TRIM(BOTH FROM observaciones)) > 0)))),
    CONSTRAINT preinscripciones_tipo_documento_check CHECK (((tipo_documento)::text = ANY ((ARRAY['DNI'::character varying, 'DNI_EXT'::character varying, 'PAS'::character varying, 'CI'::character varying])::text[])))
);


--
-- Name: TABLE preinscripciones; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON TABLE public.preinscripciones IS 'Cola de revisión: lo que carga el alumno desde el formulario público. Al aprobarse se vuelca a alumnos.';


--
-- Name: COLUMN preinscripciones.token_id; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.preinscripciones.token_id IS 'Token que habilitó esta carga. UNIQUE: un token genera una sola preinscripción.';


--
-- Name: COLUMN preinscripciones.localidad_id; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.preinscripciones.localidad_id IS 'FK a localidades. NULL si se cargó texto libre.';


--
-- Name: COLUMN preinscripciones.estado; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.preinscripciones.estado IS 'pendiente = esperando revisión | aprobada = ya volcada a alumnos | rechazada = descartada con motivo en observaciones.';


--
-- Name: COLUMN preinscripciones.observaciones; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.preinscripciones.observaciones IS 'Motivo del rechazo (obligatorio si estado = rechazada).';


--
-- Name: COLUMN preinscripciones.alumno_id; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.preinscripciones.alumno_id IS 'Se completa al aprobar: el registro de alumnos que se creó o actualizó a partir de esta preinscripción.';


--
-- Name: COLUMN preinscripciones.anio_ingreso; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.preinscripciones.anio_ingreso IS 'Solo en altas: año en que el alumno empezó la carrera. En ingresantes queda NULL (se toma el ciclo de la preinscripción).';


--
-- Name: preinscripciones_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.preinscripciones_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: preinscripciones_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.preinscripciones_id_seq OWNED BY public.preinscripciones.id;


--
-- Name: profesor_carrera; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.profesor_carrera (
    profesor_id integer NOT NULL,
    carrera_id integer NOT NULL,
    creado_en timestamp without time zone DEFAULT now() NOT NULL
);


--
-- Name: profesores; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.profesores (
    id integer NOT NULL,
    nombre character varying(100) NOT NULL,
    apellido character varying(100) NOT NULL,
    dni character varying(15) NOT NULL,
    celular character varying(20),
    telefono character varying(20),
    email character varying(150),
    titulo character varying(200),
    activo boolean DEFAULT true NOT NULL,
    genero character(1),
    CONSTRAINT profesores_genero_check CHECK ((genero = ANY (ARRAY['M'::bpchar, 'F'::bpchar])))
);


--
-- Name: profesores_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.profesores_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: profesores_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.profesores_id_seq OWNED BY public.profesores.id;


--
-- Name: reconocimientos_alumno; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.reconocimientos_alumno (
    id integer NOT NULL,
    alumno_id integer NOT NULL,
    equivalencia_id integer NOT NULL,
    reconocida boolean DEFAULT true NOT NULL,
    motivo text,
    registrado_por integer,
    registrado_en timestamp without time zone DEFAULT now() NOT NULL
);


--
-- Name: reconocimientos_alumno_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.reconocimientos_alumno_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: reconocimientos_alumno_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.reconocimientos_alumno_id_seq OWNED BY public.reconocimientos_alumno.id;


--
-- Name: tokens_inscripcion; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.tokens_inscripcion (
    id integer NOT NULL,
    token character varying(9) NOT NULL,
    tipo character varying(15) NOT NULL,
    alumno_id integer,
    carrera_id integer NOT NULL,
    ciclo_lectivo integer NOT NULL,
    estado character varying(15) DEFAULT 'disponible'::character varying NOT NULL,
    vence_el date NOT NULL,
    generado_por integer,
    generado_en timestamp without time zone DEFAULT now() NOT NULL,
    usado_en timestamp without time zone,
    anulado_en timestamp without time zone,
    anulado_por integer,
    email_destino character varying(150),
    email_estado character varying(15),
    email_error text,
    email_solicitado_en timestamp without time zone,
    email_enviado_en timestamp without time zone,
    CONSTRAINT tokens_inscripcion_alumno_coherente CHECK (((((tipo)::text = 'reinscripcion'::text) AND (alumno_id IS NOT NULL)) OR (((tipo)::text = ANY ((ARRAY['ingresante'::character varying, 'alta'::character varying])::text[])) AND (alumno_id IS NULL)))),
    CONSTRAINT tokens_inscripcion_email_estado_check CHECK (((email_estado IS NULL) OR ((email_estado)::text = ANY ((ARRAY['pendiente'::character varying, 'enviado'::character varying, 'error'::character varying])::text[])))),
    CONSTRAINT tokens_inscripcion_estado_check CHECK (((estado)::text = ANY ((ARRAY['disponible'::character varying, 'usado'::character varying, 'anulado'::character varying])::text[]))),
    CONSTRAINT tokens_inscripcion_tipo_check CHECK (((tipo)::text = ANY ((ARRAY['ingresante'::character varying, 'reinscripcion'::character varying, 'alta'::character varying])::text[])))
);


--
-- Name: TABLE tokens_inscripcion; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON TABLE public.tokens_inscripcion IS 'Tokens de un solo uso que habilitan el formulario público de inscripción. La preceptora los entrega después del control de documentación.';


--
-- Name: COLUMN tokens_inscripcion.token; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.tokens_inscripcion.token IS 'Formato XXXX-XXXX, sin caracteres ambiguos (0/O, 1/I/L). Se dicta o se escribe a mano.';


--
-- Name: COLUMN tokens_inscripcion.tipo; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.tokens_inscripcion.tipo IS 'Define qué pantalla ve el alumno: ingresante (formulario en blanco), alta (formulario en blanco para quien ya cursa, con año de ingreso) o reinscripcion (datos precargados).';


--
-- Name: COLUMN tokens_inscripcion.alumno_id; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.tokens_inscripcion.alumno_id IS 'Solo en tokens de reinscripción. NULL en ingresantes y altas.';


--
-- Name: COLUMN tokens_inscripcion.estado; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.tokens_inscripcion.estado IS 'disponible = sin usar | usado = ya generó una preinscripción | anulado = dado de baja a mano.';


--
-- Name: COLUMN tokens_inscripcion.email_destino; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.tokens_inscripcion.email_destino IS 'Correo al que se envió el token (el del legajo en reinscripción, el que cargó preceptoría en ingresante y alta).';


--
-- Name: COLUMN tokens_inscripcion.email_estado; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.tokens_inscripcion.email_estado IS 'Resultado del último envío: pendiente, enviado o error. NULL si nunca se envió.';


--
-- Name: tokens_inscripcion_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.tokens_inscripcion_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: tokens_inscripcion_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.tokens_inscripcion_id_seq OWNED BY public.tokens_inscripcion.id;


--
-- Name: usuario_carrera; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.usuario_carrera (
    usuario_id integer NOT NULL,
    carrera_id integer NOT NULL,
    activo boolean DEFAULT true NOT NULL,
    creado_en timestamp without time zone DEFAULT now() NOT NULL
);


--
-- Name: usuarios; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.usuarios (
    id integer NOT NULL,
    usuario character varying(20) NOT NULL,
    password_hash character varying(255) NOT NULL,
    rol character varying(20) NOT NULL,
    nombre character varying(100) NOT NULL,
    apellido character varying(100) NOT NULL,
    dni character varying(15),
    celular character varying(20),
    telefono character varying(20),
    email character varying(150),
    carrera_id integer,
    activo boolean DEFAULT true NOT NULL,
    debe_cambiar_password boolean DEFAULT false NOT NULL,
    creado_en timestamp without time zone DEFAULT now() NOT NULL,
    domicilio character varying(255),
    sesion_token text,
    genero character(1),
    CONSTRAINT usuarios_genero_check CHECK ((genero = ANY (ARRAY['M'::bpchar, 'F'::bpchar]))),
    CONSTRAINT usuarios_rol_check CHECK (((rol)::text = ANY (ARRAY[('admin'::character varying)::text, ('coordinador'::character varying)::text, ('preceptora'::character varying)::text, ('sys'::character varying)::text])))
);


--
-- Name: usuarios_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.usuarios_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: usuarios_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.usuarios_id_seq OWNED BY public.usuarios.id;


--
-- Name: v_correlatividades; Type: VIEW; Schema: public; Owner: -
--

CREATE VIEW public.v_correlatividades AS
 SELECT m.nombre AS materia,
    m.anio AS anio_materia,
    m.orden AS orden_materia,
    r.nombre AS requiere,
    r.orden AS orden_requiere,
    co.tipo
   FROM ((public.correlatividades co
     JOIN public.materias m ON ((m.id = co.materia_id)))
     JOIN public.materias r ON ((r.id = co.requiere_materia_id)));


--
-- Name: v_estado_alumnos; Type: VIEW; Schema: public; Owner: -
--

CREATE VIEW public.v_estado_alumnos AS
 SELECT a.dni,
    (((a.apellido)::text || ', '::text) || (a.nombre)::text) AS alumno,
    c.nombre AS carrera,
    m.nombre AS materia,
    m.anio,
    m.orden,
    m.regimen,
    i.anio_lectivo,
    cu.nota_cursada,
    cu.porcentaje_asistencia,
    cu.condicion,
    cu.cerrada
   FROM ((((public.inscripciones i
     JOIN public.alumnos a ON ((a.id = i.alumno_id)))
     JOIN public.materias m ON ((m.id = i.materia_id)))
     JOIN public.carreras c ON ((c.id = m.carrera_id)))
     LEFT JOIN public.cursadas cu ON ((cu.inscripcion_id = i.id)));


--
-- Name: v_examenes; Type: VIEW; Schema: public; Owner: -
--

CREATE VIEW public.v_examenes AS
 SELECT a.dni,
    (((a.apellido)::text || ', '::text) || (a.nombre)::text) AS alumno,
    m.nombre AS materia,
    c.nombre AS carrera,
    e.anio_lectivo,
    e.fecha_mesa,
    e.nota,
    e.resultado
   FROM (((public.examenes e
     JOIN public.alumnos a ON ((a.id = e.alumno_id)))
     JOIN public.materias m ON ((m.id = e.materia_id)))
     JOIN public.carreras c ON ((c.id = m.carrera_id)));


--
-- Name: v_usuarios; Type: VIEW; Schema: public; Owner: -
--

CREATE VIEW public.v_usuarios AS
 SELECT u.id,
    u.usuario,
    u.rol,
    (((u.apellido)::text || ', '::text) || (u.nombre)::text) AS nombre_completo,
    u.dni,
    u.email,
    u.celular,
    c.nombre AS carrera,
    u.activo,
    u.debe_cambiar_password
   FROM (public.usuarios u
     LEFT JOIN public.carreras c ON ((c.id = u.carrera_id)));


--
-- Name: alumnos id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.alumnos ALTER COLUMN id SET DEFAULT nextval('public.alumnos_id_seq'::regclass);


--
-- Name: alumnos_carrera id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.alumnos_carrera ALTER COLUMN id SET DEFAULT nextval('public.alumnos_carrera_id_seq'::regclass);


--
-- Name: carreras id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.carreras ALTER COLUMN id SET DEFAULT nextval('public.carreras_id_seq'::regclass);


--
-- Name: configuracion id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.configuracion ALTER COLUMN id SET DEFAULT nextval('public.configuracion_id_seq'::regclass);


--
-- Name: correlatividades id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.correlatividades ALTER COLUMN id SET DEFAULT nextval('public.correlatividades_id_seq'::regclass);


--
-- Name: cursadas id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.cursadas ALTER COLUMN id SET DEFAULT nextval('public.cursadas_id_seq'::regclass);


--
-- Name: cursadas_auditoria id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.cursadas_auditoria ALTER COLUMN id SET DEFAULT nextval('public.cursadas_auditoria_id_seq'::regclass);


--
-- Name: equivalencias_plan id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.equivalencias_plan ALTER COLUMN id SET DEFAULT nextval('public.equivalencias_plan_id_seq'::regclass);


--
-- Name: examenes id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.examenes ALTER COLUMN id SET DEFAULT nextval('public.examenes_id_seq'::regclass);


--
-- Name: historial_plan_alumno id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.historial_plan_alumno ALTER COLUMN id SET DEFAULT nextval('public.historial_plan_alumno_id_seq'::regclass);


--
-- Name: inscripciones id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.inscripciones ALTER COLUMN id SET DEFAULT nextval('public.inscripciones_id_seq'::regclass);


--
-- Name: inscripciones_auditoria id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.inscripciones_auditoria ALTER COLUMN id SET DEFAULT nextval('public.inscripciones_auditoria_id_seq'::regclass);


--
-- Name: inscripciones_mesa id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.inscripciones_mesa ALTER COLUMN id SET DEFAULT nextval('public.inscripciones_mesa_id_seq'::regclass);


--
-- Name: localidades id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.localidades ALTER COLUMN id SET DEFAULT nextval('public.localidades_id_seq'::regclass);


--
-- Name: materia_profesor id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.materia_profesor ALTER COLUMN id SET DEFAULT nextval('public.materia_profesor_id_seq'::regclass);


--
-- Name: materias id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.materias ALTER COLUMN id SET DEFAULT nextval('public.materias_id_seq'::regclass);


--
-- Name: mesas_examen id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.mesas_examen ALTER COLUMN id SET DEFAULT nextval('public.mesas_examen_id_seq'::regclass);


--
-- Name: planes_estudio id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.planes_estudio ALTER COLUMN id SET DEFAULT nextval('public.planes_estudio_id_seq'::regclass);


--
-- Name: preinscripcion_materias id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.preinscripcion_materias ALTER COLUMN id SET DEFAULT nextval('public.preinscripcion_materias_id_seq'::regclass);


--
-- Name: preinscripciones id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.preinscripciones ALTER COLUMN id SET DEFAULT nextval('public.preinscripciones_id_seq'::regclass);


--
-- Name: profesores id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.profesores ALTER COLUMN id SET DEFAULT nextval('public.profesores_id_seq'::regclass);


--
-- Name: reconocimientos_alumno id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.reconocimientos_alumno ALTER COLUMN id SET DEFAULT nextval('public.reconocimientos_alumno_id_seq'::regclass);


--
-- Name: tokens_inscripcion id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.tokens_inscripcion ALTER COLUMN id SET DEFAULT nextval('public.tokens_inscripcion_id_seq'::regclass);


--
-- Name: usuarios id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.usuarios ALTER COLUMN id SET DEFAULT nextval('public.usuarios_id_seq'::regclass);


--
-- Name: alumnos_carrera alumnos_carrera_carrera_cuil_key; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.alumnos_carrera
    ADD CONSTRAINT alumnos_carrera_carrera_cuil_key UNIQUE (carrera_id, cuil);


--
-- Name: alumnos_carrera alumnos_carrera_carrera_dni_key; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.alumnos_carrera
    ADD CONSTRAINT alumnos_carrera_carrera_dni_key UNIQUE (carrera_id, dni);


--
-- Name: alumnos_carrera alumnos_carrera_carrera_email_key; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.alumnos_carrera
    ADD CONSTRAINT alumnos_carrera_carrera_email_key UNIQUE (carrera_id, email);


--
-- Name: alumnos_carrera alumnos_carrera_carrera_legajo_key; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.alumnos_carrera
    ADD CONSTRAINT alumnos_carrera_carrera_legajo_key UNIQUE (carrera_id, legajo);


--
-- Name: alumnos_carrera alumnos_carrera_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.alumnos_carrera
    ADD CONSTRAINT alumnos_carrera_pkey PRIMARY KEY (id);


--
-- Name: alumnos alumnos_cuil_key; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.alumnos
    ADD CONSTRAINT alumnos_cuil_key UNIQUE (cuil);


--
-- Name: alumnos alumnos_dni_key; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.alumnos
    ADD CONSTRAINT alumnos_dni_key UNIQUE (dni);


--
-- Name: alumnos alumnos_legajo_key; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.alumnos
    ADD CONSTRAINT alumnos_legajo_key UNIQUE (legajo);


--
-- Name: alumnos alumnos_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.alumnos
    ADD CONSTRAINT alumnos_pkey PRIMARY KEY (id);


--
-- Name: carreras carreras_nombre_key; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.carreras
    ADD CONSTRAINT carreras_nombre_key UNIQUE (nombre);


--
-- Name: carreras carreras_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.carreras
    ADD CONSTRAINT carreras_pkey PRIMARY KEY (id);


--
-- Name: configuracion configuracion_clave_key; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.configuracion
    ADD CONSTRAINT configuracion_clave_key UNIQUE (clave);


--
-- Name: configuracion configuracion_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.configuracion
    ADD CONSTRAINT configuracion_pkey PRIMARY KEY (id);


--
-- Name: correlatividades correlatividades_materia_id_requiere_materia_id_tipo_key; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.correlatividades
    ADD CONSTRAINT correlatividades_materia_id_requiere_materia_id_tipo_key UNIQUE (materia_id, requiere_materia_id, tipo);


--
-- Name: correlatividades correlatividades_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.correlatividades
    ADD CONSTRAINT correlatividades_pkey PRIMARY KEY (id);


--
-- Name: cursadas_auditoria cursadas_auditoria_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.cursadas_auditoria
    ADD CONSTRAINT cursadas_auditoria_pkey PRIMARY KEY (id);


--
-- Name: cursadas cursadas_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.cursadas
    ADD CONSTRAINT cursadas_pkey PRIMARY KEY (id);


--
-- Name: equivalencias_plan equivalencias_plan_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.equivalencias_plan
    ADD CONSTRAINT equivalencias_plan_pkey PRIMARY KEY (id);


--
-- Name: equivalencias_plan equivalencias_plan_plan_nuevo_id_materia_nueva_id_materia_v_key; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.equivalencias_plan
    ADD CONSTRAINT equivalencias_plan_plan_nuevo_id_materia_nueva_id_materia_v_key UNIQUE (plan_nuevo_id, materia_nueva_id, materia_vieja_id);


--
-- Name: examenes examenes_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.examenes
    ADD CONSTRAINT examenes_pkey PRIMARY KEY (id);


--
-- Name: examenes examenes_unique; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.examenes
    ADD CONSTRAINT examenes_unique UNIQUE (alumno_id, materia_id, anio_lectivo, fecha_mesa);


--
-- Name: historial_plan_alumno historial_plan_alumno_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.historial_plan_alumno
    ADD CONSTRAINT historial_plan_alumno_pkey PRIMARY KEY (id);


--
-- Name: inscripciones inscripciones_alumno_id_materia_id_anio_lectivo_key; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.inscripciones
    ADD CONSTRAINT inscripciones_alumno_id_materia_id_anio_lectivo_key UNIQUE (alumno_id, materia_id, anio_lectivo);


--
-- Name: inscripciones_auditoria inscripciones_auditoria_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.inscripciones_auditoria
    ADD CONSTRAINT inscripciones_auditoria_pkey PRIMARY KEY (id);


--
-- Name: inscripciones_mesa inscripciones_mesa_mesa_id_alumno_id_key; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.inscripciones_mesa
    ADD CONSTRAINT inscripciones_mesa_mesa_id_alumno_id_key UNIQUE (mesa_id, alumno_id);


--
-- Name: inscripciones_mesa inscripciones_mesa_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.inscripciones_mesa
    ADD CONSTRAINT inscripciones_mesa_pkey PRIMARY KEY (id);


--
-- Name: inscripciones inscripciones_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.inscripciones
    ADD CONSTRAINT inscripciones_pkey PRIMARY KEY (id);


--
-- Name: localidades localidades_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.localidades
    ADD CONSTRAINT localidades_pkey PRIMARY KEY (id);


--
-- Name: materia_profesor materia_profesor_materia_id_profesor_id_anio_lectivo_key; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.materia_profesor
    ADD CONSTRAINT materia_profesor_materia_id_profesor_id_anio_lectivo_key UNIQUE (materia_id, profesor_id, anio_lectivo);


--
-- Name: materia_profesor materia_profesor_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.materia_profesor
    ADD CONSTRAINT materia_profesor_pkey PRIMARY KEY (id);


--
-- Name: materias materias_carrera_id_anio_orden_key; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.materias
    ADD CONSTRAINT materias_carrera_id_anio_orden_key UNIQUE (carrera_id, anio, orden);


--
-- Name: materias materias_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.materias
    ADD CONSTRAINT materias_pkey PRIMARY KEY (id);


--
-- Name: mesas_examen mesas_examen_carrera_id_numero_acta_key; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.mesas_examen
    ADD CONSTRAINT mesas_examen_carrera_id_numero_acta_key UNIQUE (carrera_id, numero_acta);


--
-- Name: mesas_examen mesas_examen_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.mesas_examen
    ADD CONSTRAINT mesas_examen_pkey PRIMARY KEY (id);


--
-- Name: planes_estudio planes_estudio_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.planes_estudio
    ADD CONSTRAINT planes_estudio_pkey PRIMARY KEY (id);


--
-- Name: preinscripcion_materias preinscripcion_materias_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.preinscripcion_materias
    ADD CONSTRAINT preinscripcion_materias_pkey PRIMARY KEY (id);


--
-- Name: preinscripcion_materias preinscripcion_materias_unica; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.preinscripcion_materias
    ADD CONSTRAINT preinscripcion_materias_unica UNIQUE (preinscripcion_id, materia_id);


--
-- Name: preinscripciones preinscripciones_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.preinscripciones
    ADD CONSTRAINT preinscripciones_pkey PRIMARY KEY (id);


--
-- Name: preinscripciones preinscripciones_token_id_key; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.preinscripciones
    ADD CONSTRAINT preinscripciones_token_id_key UNIQUE (token_id);


--
-- Name: profesor_carrera profesor_carrera_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.profesor_carrera
    ADD CONSTRAINT profesor_carrera_pkey PRIMARY KEY (profesor_id, carrera_id);


--
-- Name: profesores profesores_dni_key; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.profesores
    ADD CONSTRAINT profesores_dni_key UNIQUE (dni);


--
-- Name: profesores profesores_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.profesores
    ADD CONSTRAINT profesores_pkey PRIMARY KEY (id);


--
-- Name: reconocimientos_alumno reconocimientos_alumno_alumno_id_equivalencia_id_key; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.reconocimientos_alumno
    ADD CONSTRAINT reconocimientos_alumno_alumno_id_equivalencia_id_key UNIQUE (alumno_id, equivalencia_id);


--
-- Name: reconocimientos_alumno reconocimientos_alumno_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.reconocimientos_alumno
    ADD CONSTRAINT reconocimientos_alumno_pkey PRIMARY KEY (id);


--
-- Name: tokens_inscripcion tokens_inscripcion_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.tokens_inscripcion
    ADD CONSTRAINT tokens_inscripcion_pkey PRIMARY KEY (id);


--
-- Name: tokens_inscripcion tokens_inscripcion_token_key; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.tokens_inscripcion
    ADD CONSTRAINT tokens_inscripcion_token_key UNIQUE (token);


--
-- Name: usuario_carrera usuario_carrera_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.usuario_carrera
    ADD CONSTRAINT usuario_carrera_pkey PRIMARY KEY (usuario_id, carrera_id);


--
-- Name: usuarios usuarios_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.usuarios
    ADD CONSTRAINT usuarios_pkey PRIMARY KEY (id);


--
-- Name: usuarios usuarios_usuario_key; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.usuarios
    ADD CONSTRAINT usuarios_usuario_key UNIQUE (usuario);


--
-- Name: idx_alumnos_carrera_apellido; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_alumnos_carrera_apellido ON public.alumnos_carrera USING btree (apellido, nombre);


--
-- Name: idx_alumnos_carrera_carrera; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_alumnos_carrera_carrera ON public.alumnos_carrera USING btree (carrera_id);


--
-- Name: idx_alumnos_cuil; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_alumnos_cuil ON public.alumnos USING btree (cuil) WHERE (cuil IS NOT NULL);


--
-- Name: idx_auditoria_cursada; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_auditoria_cursada ON public.cursadas_auditoria USING btree (cursada_id);


--
-- Name: idx_cursadas_promocion_provisoria; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_cursadas_promocion_provisoria ON public.cursadas USING btree (promocion_provisoria) WHERE promocion_provisoria;


--
-- Name: idx_equiv_mat_nueva; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_equiv_mat_nueva ON public.equivalencias_plan USING btree (materia_nueva_id);


--
-- Name: idx_equiv_mat_vieja; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_equiv_mat_vieja ON public.equivalencias_plan USING btree (materia_vieja_id);


--
-- Name: idx_equiv_plan_nuevo; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_equiv_plan_nuevo ON public.equivalencias_plan USING btree (plan_nuevo_id);


--
-- Name: idx_hist_plan_alumno; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_hist_plan_alumno ON public.historial_plan_alumno USING btree (alumno_id);


--
-- Name: idx_inscripciones_aud_alumno; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_inscripciones_aud_alumno ON public.inscripciones_auditoria USING btree (alumno_id, anio_lectivo);


--
-- Name: idx_inscripciones_aud_fecha; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_inscripciones_aud_fecha ON public.inscripciones_auditoria USING btree (fecha DESC);


--
-- Name: idx_localidades_nombre; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_localidades_nombre ON public.localidades USING btree (lower((nombre)::text));


--
-- Name: idx_localidades_provincia; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_localidades_provincia ON public.localidades USING btree (provincia);


--
-- Name: idx_localidades_unica; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX idx_localidades_unica ON public.localidades USING btree (lower((nombre)::text), COALESCE(departamento, ''::character varying), provincia);


--
-- Name: idx_planes_carrera; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_planes_carrera ON public.planes_estudio USING btree (carrera_id);


--
-- Name: idx_preinscripcion_materias_materia; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_preinscripcion_materias_materia ON public.preinscripcion_materias USING btree (materia_id);


--
-- Name: idx_preinscripciones_carrera; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_preinscripciones_carrera ON public.preinscripciones USING btree (carrera_id);


--
-- Name: idx_preinscripciones_ciclo; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_preinscripciones_ciclo ON public.preinscripciones USING btree (ciclo_lectivo);


--
-- Name: idx_preinscripciones_estado; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_preinscripciones_estado ON public.preinscripciones USING btree (estado);


--
-- Name: idx_reconoc_alumno; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_reconoc_alumno ON public.reconocimientos_alumno USING btree (alumno_id);


--
-- Name: idx_tokens_alumno_ciclo_vivo; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX idx_tokens_alumno_ciclo_vivo ON public.tokens_inscripcion USING btree (alumno_id, ciclo_lectivo) WHERE ((alumno_id IS NOT NULL) AND ((estado)::text = 'disponible'::text));


--
-- Name: idx_tokens_carrera; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_tokens_carrera ON public.tokens_inscripcion USING btree (carrera_id);


--
-- Name: idx_tokens_ciclo; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_tokens_ciclo ON public.tokens_inscripcion USING btree (ciclo_lectivo);


--
-- Name: idx_tokens_email_destino; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_tokens_email_destino ON public.tokens_inscripcion USING btree (lower((email_destino)::text));


--
-- Name: idx_tokens_estado; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_tokens_estado ON public.tokens_inscripcion USING btree (estado);


--
-- Name: preinscripciones_dni_ciclo_activa; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX preinscripciones_dni_ciclo_activa ON public.preinscripciones USING btree (carrera_id, dni, ciclo_lectivo) WHERE (((estado)::text = 'pendiente'::text) OR (((estado)::text = 'aprobada'::text) AND (anio_ingreso IS NULL)));


--
-- Name: usuarios_carrera_dni_key; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX usuarios_carrera_dni_key ON public.usuarios USING btree (carrera_id, dni);


--
-- Name: usuarios_dni_sin_carrera_key; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX usuarios_dni_sin_carrera_key ON public.usuarios USING btree (dni) WHERE (carrera_id IS NULL);


--
-- Name: alumnos_carrera alumnos_carrera_carrera_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.alumnos_carrera
    ADD CONSTRAINT alumnos_carrera_carrera_id_fkey FOREIGN KEY (carrera_id) REFERENCES public.carreras(id) ON DELETE RESTRICT;


--
-- Name: alumnos alumnos_carrera_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.alumnos
    ADD CONSTRAINT alumnos_carrera_id_fkey FOREIGN KEY (carrera_id) REFERENCES public.carreras(id) ON DELETE RESTRICT;


--
-- Name: alumnos_carrera alumnos_carrera_localidad_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.alumnos_carrera
    ADD CONSTRAINT alumnos_carrera_localidad_id_fkey FOREIGN KEY (localidad_id) REFERENCES public.localidades(id);


--
-- Name: alumnos_carrera alumnos_carrera_plan_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.alumnos_carrera
    ADD CONSTRAINT alumnos_carrera_plan_id_fkey FOREIGN KEY (plan_id) REFERENCES public.planes_estudio(id) ON DELETE SET NULL;


--
-- Name: alumnos alumnos_localidad_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.alumnos
    ADD CONSTRAINT alumnos_localidad_id_fkey FOREIGN KEY (localidad_id) REFERENCES public.localidades(id);


--
-- Name: alumnos alumnos_plan_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.alumnos
    ADD CONSTRAINT alumnos_plan_id_fkey FOREIGN KEY (plan_id) REFERENCES public.planes_estudio(id) ON DELETE SET NULL;


--
-- Name: correlatividades correlatividades_materia_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.correlatividades
    ADD CONSTRAINT correlatividades_materia_id_fkey FOREIGN KEY (materia_id) REFERENCES public.materias(id) ON DELETE CASCADE;


--
-- Name: correlatividades correlatividades_requiere_materia_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.correlatividades
    ADD CONSTRAINT correlatividades_requiere_materia_id_fkey FOREIGN KEY (requiere_materia_id) REFERENCES public.materias(id) ON DELETE CASCADE;


--
-- Name: cursadas_auditoria cursadas_auditoria_cursada_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.cursadas_auditoria
    ADD CONSTRAINT cursadas_auditoria_cursada_id_fkey FOREIGN KEY (cursada_id) REFERENCES public.cursadas(id) ON DELETE CASCADE;


--
-- Name: cursadas_auditoria cursadas_auditoria_modificado_por_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.cursadas_auditoria
    ADD CONSTRAINT cursadas_auditoria_modificado_por_id_fkey FOREIGN KEY (modificado_por_id) REFERENCES public.usuarios(id) ON DELETE SET NULL;


--
-- Name: cursadas cursadas_inscripcion_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.cursadas
    ADD CONSTRAINT cursadas_inscripcion_id_fkey FOREIGN KEY (inscripcion_id) REFERENCES public.inscripciones(id) ON DELETE CASCADE;


--
-- Name: equivalencias_plan equivalencias_plan_materia_nueva_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.equivalencias_plan
    ADD CONSTRAINT equivalencias_plan_materia_nueva_id_fkey FOREIGN KEY (materia_nueva_id) REFERENCES public.materias(id) ON DELETE CASCADE;


--
-- Name: equivalencias_plan equivalencias_plan_materia_vieja_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.equivalencias_plan
    ADD CONSTRAINT equivalencias_plan_materia_vieja_id_fkey FOREIGN KEY (materia_vieja_id) REFERENCES public.materias(id) ON DELETE CASCADE;


--
-- Name: equivalencias_plan equivalencias_plan_plan_nuevo_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.equivalencias_plan
    ADD CONSTRAINT equivalencias_plan_plan_nuevo_id_fkey FOREIGN KEY (plan_nuevo_id) REFERENCES public.planes_estudio(id) ON DELETE CASCADE;


--
-- Name: examenes examenes_alumno_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.examenes
    ADD CONSTRAINT examenes_alumno_id_fkey FOREIGN KEY (alumno_id) REFERENCES public.alumnos_carrera(id) ON DELETE CASCADE;


--
-- Name: examenes examenes_materia_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.examenes
    ADD CONSTRAINT examenes_materia_id_fkey FOREIGN KEY (materia_id) REFERENCES public.materias(id) ON DELETE CASCADE;


--
-- Name: historial_plan_alumno historial_plan_alumno_alumno_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.historial_plan_alumno
    ADD CONSTRAINT historial_plan_alumno_alumno_id_fkey FOREIGN KEY (alumno_id) REFERENCES public.alumnos_carrera(id) ON DELETE CASCADE;


--
-- Name: historial_plan_alumno historial_plan_alumno_plan_nuevo_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.historial_plan_alumno
    ADD CONSTRAINT historial_plan_alumno_plan_nuevo_id_fkey FOREIGN KEY (plan_nuevo_id) REFERENCES public.planes_estudio(id) ON DELETE CASCADE;


--
-- Name: historial_plan_alumno historial_plan_alumno_plan_viejo_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.historial_plan_alumno
    ADD CONSTRAINT historial_plan_alumno_plan_viejo_id_fkey FOREIGN KEY (plan_viejo_id) REFERENCES public.planes_estudio(id) ON DELETE SET NULL;


--
-- Name: historial_plan_alumno historial_plan_alumno_registrado_por_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.historial_plan_alumno
    ADD CONSTRAINT historial_plan_alumno_registrado_por_fkey FOREIGN KEY (registrado_por) REFERENCES public.usuarios(id) ON DELETE SET NULL;


--
-- Name: inscripciones inscripciones_alumno_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.inscripciones
    ADD CONSTRAINT inscripciones_alumno_id_fkey FOREIGN KEY (alumno_id) REFERENCES public.alumnos_carrera(id) ON DELETE CASCADE;


--
-- Name: inscripciones_auditoria inscripciones_auditoria_alumno_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.inscripciones_auditoria
    ADD CONSTRAINT inscripciones_auditoria_alumno_id_fkey FOREIGN KEY (alumno_id) REFERENCES public.alumnos_carrera(id) ON DELETE CASCADE;


--
-- Name: inscripciones_auditoria inscripciones_auditoria_coordinador_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.inscripciones_auditoria
    ADD CONSTRAINT inscripciones_auditoria_coordinador_id_fkey FOREIGN KEY (coordinador_id) REFERENCES public.usuarios(id);


--
-- Name: inscripciones inscripciones_materia_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.inscripciones
    ADD CONSTRAINT inscripciones_materia_id_fkey FOREIGN KEY (materia_id) REFERENCES public.materias(id) ON DELETE CASCADE;


--
-- Name: inscripciones_mesa inscripciones_mesa_alumno_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.inscripciones_mesa
    ADD CONSTRAINT inscripciones_mesa_alumno_id_fkey FOREIGN KEY (alumno_id) REFERENCES public.alumnos_carrera(id) ON DELETE CASCADE;


--
-- Name: inscripciones_mesa inscripciones_mesa_mesa_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.inscripciones_mesa
    ADD CONSTRAINT inscripciones_mesa_mesa_id_fkey FOREIGN KEY (mesa_id) REFERENCES public.mesas_examen(id) ON DELETE CASCADE;


--
-- Name: materia_profesor materia_profesor_materia_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.materia_profesor
    ADD CONSTRAINT materia_profesor_materia_id_fkey FOREIGN KEY (materia_id) REFERENCES public.materias(id) ON DELETE CASCADE;


--
-- Name: materia_profesor materia_profesor_profesor_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.materia_profesor
    ADD CONSTRAINT materia_profesor_profesor_id_fkey FOREIGN KEY (profesor_id) REFERENCES public.profesores(id) ON DELETE CASCADE;


--
-- Name: materias materias_carrera_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.materias
    ADD CONSTRAINT materias_carrera_id_fkey FOREIGN KEY (carrera_id) REFERENCES public.carreras(id) ON DELETE CASCADE;


--
-- Name: materias materias_plan_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.materias
    ADD CONSTRAINT materias_plan_id_fkey FOREIGN KEY (plan_id) REFERENCES public.planes_estudio(id) ON DELETE SET NULL;


--
-- Name: mesas_examen mesas_examen_carrera_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.mesas_examen
    ADD CONSTRAINT mesas_examen_carrera_id_fkey FOREIGN KEY (carrera_id) REFERENCES public.carreras(id) ON DELETE CASCADE;


--
-- Name: mesas_examen mesas_examen_materia_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.mesas_examen
    ADD CONSTRAINT mesas_examen_materia_id_fkey FOREIGN KEY (materia_id) REFERENCES public.materias(id) ON DELETE CASCADE;


--
-- Name: planes_estudio planes_estudio_carrera_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.planes_estudio
    ADD CONSTRAINT planes_estudio_carrera_id_fkey FOREIGN KEY (carrera_id) REFERENCES public.carreras(id) ON DELETE CASCADE;


--
-- Name: preinscripcion_materias preinscripcion_materias_materia_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.preinscripcion_materias
    ADD CONSTRAINT preinscripcion_materias_materia_id_fkey FOREIGN KEY (materia_id) REFERENCES public.materias(id) ON DELETE RESTRICT;


--
-- Name: preinscripcion_materias preinscripcion_materias_preinscripcion_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.preinscripcion_materias
    ADD CONSTRAINT preinscripcion_materias_preinscripcion_id_fkey FOREIGN KEY (preinscripcion_id) REFERENCES public.preinscripciones(id) ON DELETE CASCADE;


--
-- Name: preinscripciones preinscripciones_alumno_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.preinscripciones
    ADD CONSTRAINT preinscripciones_alumno_id_fkey FOREIGN KEY (alumno_id) REFERENCES public.alumnos_carrera(id) ON DELETE SET NULL;


--
-- Name: preinscripciones preinscripciones_carrera_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.preinscripciones
    ADD CONSTRAINT preinscripciones_carrera_id_fkey FOREIGN KEY (carrera_id) REFERENCES public.carreras(id) ON DELETE RESTRICT;


--
-- Name: preinscripciones preinscripciones_localidad_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.preinscripciones
    ADD CONSTRAINT preinscripciones_localidad_id_fkey FOREIGN KEY (localidad_id) REFERENCES public.localidades(id);


--
-- Name: preinscripciones preinscripciones_plan_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.preinscripciones
    ADD CONSTRAINT preinscripciones_plan_id_fkey FOREIGN KEY (plan_id) REFERENCES public.planes_estudio(id) ON DELETE SET NULL;


--
-- Name: preinscripciones preinscripciones_revisado_por_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.preinscripciones
    ADD CONSTRAINT preinscripciones_revisado_por_fkey FOREIGN KEY (revisado_por) REFERENCES public.usuarios(id) ON DELETE SET NULL;


--
-- Name: preinscripciones preinscripciones_token_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.preinscripciones
    ADD CONSTRAINT preinscripciones_token_id_fkey FOREIGN KEY (token_id) REFERENCES public.tokens_inscripcion(id) ON DELETE RESTRICT;


--
-- Name: profesor_carrera profesor_carrera_carrera_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.profesor_carrera
    ADD CONSTRAINT profesor_carrera_carrera_id_fkey FOREIGN KEY (carrera_id) REFERENCES public.carreras(id) ON DELETE CASCADE;


--
-- Name: profesor_carrera profesor_carrera_profesor_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.profesor_carrera
    ADD CONSTRAINT profesor_carrera_profesor_id_fkey FOREIGN KEY (profesor_id) REFERENCES public.profesores(id) ON DELETE CASCADE;


--
-- Name: reconocimientos_alumno reconocimientos_alumno_alumno_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.reconocimientos_alumno
    ADD CONSTRAINT reconocimientos_alumno_alumno_id_fkey FOREIGN KEY (alumno_id) REFERENCES public.alumnos_carrera(id) ON DELETE CASCADE;


--
-- Name: reconocimientos_alumno reconocimientos_alumno_equivalencia_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.reconocimientos_alumno
    ADD CONSTRAINT reconocimientos_alumno_equivalencia_id_fkey FOREIGN KEY (equivalencia_id) REFERENCES public.equivalencias_plan(id) ON DELETE CASCADE;


--
-- Name: reconocimientos_alumno reconocimientos_alumno_registrado_por_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.reconocimientos_alumno
    ADD CONSTRAINT reconocimientos_alumno_registrado_por_fkey FOREIGN KEY (registrado_por) REFERENCES public.usuarios(id) ON DELETE SET NULL;


--
-- Name: tokens_inscripcion tokens_inscripcion_alumno_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.tokens_inscripcion
    ADD CONSTRAINT tokens_inscripcion_alumno_id_fkey FOREIGN KEY (alumno_id) REFERENCES public.alumnos_carrera(id) ON DELETE CASCADE;


--
-- Name: tokens_inscripcion tokens_inscripcion_anulado_por_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.tokens_inscripcion
    ADD CONSTRAINT tokens_inscripcion_anulado_por_fkey FOREIGN KEY (anulado_por) REFERENCES public.usuarios(id) ON DELETE SET NULL;


--
-- Name: tokens_inscripcion tokens_inscripcion_carrera_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.tokens_inscripcion
    ADD CONSTRAINT tokens_inscripcion_carrera_id_fkey FOREIGN KEY (carrera_id) REFERENCES public.carreras(id) ON DELETE RESTRICT;


--
-- Name: tokens_inscripcion tokens_inscripcion_generado_por_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.tokens_inscripcion
    ADD CONSTRAINT tokens_inscripcion_generado_por_fkey FOREIGN KEY (generado_por) REFERENCES public.usuarios(id) ON DELETE SET NULL;


--
-- Name: usuario_carrera usuario_carrera_carrera_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.usuario_carrera
    ADD CONSTRAINT usuario_carrera_carrera_id_fkey FOREIGN KEY (carrera_id) REFERENCES public.carreras(id) ON DELETE CASCADE;


--
-- Name: usuario_carrera usuario_carrera_usuario_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.usuario_carrera
    ADD CONSTRAINT usuario_carrera_usuario_id_fkey FOREIGN KEY (usuario_id) REFERENCES public.usuarios(id) ON DELETE CASCADE;


--
-- Name: usuarios usuarios_carrera_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.usuarios
    ADD CONSTRAINT usuarios_carrera_id_fkey FOREIGN KEY (carrera_id) REFERENCES public.carreras(id) ON DELETE SET NULL;


--
-- PostgreSQL database dump complete
--

\unrestrict vhxcy37QUFQhEcug6CekcEiQsJkQCgUCowwBueAWgQbWlLF1OAXpqPXjDqlDzbj

