# SGA — Sistema de Gestión Académica

Sistema de gestión académica desarrollado para el **IES N° 9 "Juana Azurduy"**
de San Pedro de Jujuy, Argentina.

Proyecto de **Prácticas Profesionalizantes III** — Tecnicatura Superior en
Soporte de Infraestructura de Tecnología de la Información.

---

## Qué hace

Administra el recorrido académico de los alumnos de las carreras de nivel
superior del instituto, Tecnicaturas y Profesorados, aplicando las reglas del
plan de estudios oficial de cada una:

- **Carreras y usuarios** — cada carrera con su coordinador y sus preceptoras;
  cada persona ingresa con su DNI y una única contraseña
- **Plan de estudios** — importación desde planilla Excel con revisión previa
  (correlatividades, régimen de aprobación, examen libre y sugerencias de
  escritura), corrección puntual de materias y versionado de planes
- **Cambio de plan** — transición entre planes con tabla de equivalencias,
  reconocimiento de materias aprobadas y regulares, prórrogas y migración de
  alumnos
- **Inscripciones** — a materias, con validación de correlatividades y ventana
  configurable; inscripción por Internet con un código que entrega la
  preceptora y revisión antes de aprobarla
- **Notas** — carga manual o importación desde la planilla del profesor, con
  sugerencia automática de condición y cierre de cursada
- **Mesas de examen** — convocatoria, inscripción, carga de resultados y
  generación del acta en PDF
- **Reportes** — constancias, estado académico, promedios y plan de estudios
  en PDF

### Reglas académicas implementadas

El sistema no permite operaciones que contradigan el plan de estudios:

- Hay tres tipos de correlatividad: **regularizada para cursar**, **aprobada
  para cursar** (propia de los Profesorados) y **aprobada para rendir o
  promocionar**
- Para inscribirse en materias de un año hay que tener al menos una materia
  regularizada o aprobada del año anterior; primer año está siempre disponible
- La regularidad vence a los **2 años** de cargada la nota, o al agotarse
  los **3 intentos** en mesa de examen — lo que ocurra primero
- Las materias cuyo régimen es sólo *Examen Final* no admiten promoción
- Las materias cuyo régimen es sólo *Promoción* no se rinden en mesa
- El examen libre solo se admite en las materias que el plan habilita (las
  marcadas con (\*) en la resolución)
- Una promoción con una correlativa adeudada queda **provisoria** hasta el
  31 de diciembre del año lectivo; si para entonces no se aprobó la
  correlativa, la materia pasa a regular y se rinde el final
- Una materia aprobada, o con la regularidad vigente, no se vuelve a cursar

Las reglas se leen de la base de datos, no están escritas en el código: si
cambia el plan de estudios, se importa el nuevo y el sistema se adapta.

Las decisiones de diseño, con sus motivos y lo que se descartó, están en
[`docs/decisiones.md`](docs/decisiones.md).

---

## Tecnologías

| Capa | Herramienta |
|---|---|
| Backend | Python 3 · Flask |
| Base de datos | PostgreSQL 18 |
| Frontend | HTML · CSS · JavaScript (sin framework) |
| Reportes | ReportLab (PDF) · openpyxl (Excel) |
| Servidor | Ubuntu Server · Gunicorn · nginx |
| Publicación | Tailscale Funnel (HTTPS) |

---

## Instalación

### Requisitos

- Python 3.10 o superior
- PostgreSQL 18

### Pasos

**1. Clonar el repositorio**

```bash
git clone https://github.com/cesareduardo220/sga-ies9.git
cd sga-ies9
```

**2. Instalar las dependencias**

```bash
pip install -r requirements.txt
```

**3. Crear la base de datos**

```bash
createdb ies9_gestion
psql -d ies9_gestion -f sga_ies9_v7.sql
psql -d ies9_gestion -f sga_ies9_datos_iniciales.sql
```

El primer script crea la estructura completa; el segundo carga los
parámetros del sistema, el administrador inicial y las localidades del país
(para el formulario de inscripción). No hace falta correr ninguna migración.

**4. Configurar las credenciales**

Copiar `.env.example` como `.env` y completar:

- `DB_PASSWORD`: la contraseña de PostgreSQL (y `DB_USER`, si no es `postgres`)
- `SECRET_KEY`: una clave secreta para las sesiones, que se genera con
  `python -c "import secrets; print(secrets.token_hex(32))"`
- `SMTP_…`: la cuenta de Gmail del instituto, con una contraseña de
  aplicación, para enviar por correo los códigos de inscripción

El archivo `.env` no se versiona: cada instalación tiene el suyo.

**5. Iniciar el sistema**

```bash
python run.py
```

Abrir `http://127.0.0.1:5000` en el navegador.

En el servidor, el sistema corre como servicio con Gunicorn (5 procesos de
trabajo para un procesador de 2 núcleos) detrás de nginx.

### Primer ingreso

| Usuario | Contraseña |
|---|---|
| `admin` | `Admin1234` |

El sistema pide completar los datos del administrador y definir una
contraseña nueva antes de continuar.

Los demás usuarios ingresan con su DNI como usuario y como contraseña
provisoria, y el sistema les pide cambiarla antes de dejarlos usar
cualquier otra pantalla.

Si en algún momento se pierde el acceso, `python reset_admin.py` restablece
la cuenta del administrador.

---

## Estructura

```
sga-ies9/
├── app/
│   ├── __init__.py
│   ├── database.py                   conexión a PostgreSQL
│   ├── routes.py                     rutas y lógica del sistema
│   ├── static/
│   └── templates/                    pantallas (panel, ingreso, formulario público)
├── docs/
│   └── decisiones.md                 decisiones de diseño y sus motivos
├── migraciones/                      historial de cambios de la estructura de la base
├── db/                               diseño del modelo por carrera (ya incluido en el esquema)
├── pruebas/                          prueba del modelo de datos
├── systemd/                          tarea diaria que anonimiza las preinscripciones rechazadas
├── run.py                            punto de entrada
├── reset_admin.py                    restablece el acceso del administrador
├── anonimizar_preinscripciones.py    borra los datos personales de preinscripciones viejas
├── sga_ies9_v7.sql                   estructura de la base
├── sga_ies9_datos_iniciales.sql      parámetros del sistema y administrador inicial
├── requirements.txt
├── .env.example
└── .gitignore
```

---

## Alcance

El sistema cubre la gestión académica del recorrido del alumno. Quedan
fuera de esta versión, identificados para una implementación futura:

- Gestión de convocatorias a mesas extraordinarias
- Penalización del alumno ausente para el llamado siguiente

---

## Datos de prueba

Los datos de alumnos y profesores incluidos en el entorno de desarrollo son
**ficticios**, generados únicamente para probar el sistema.
