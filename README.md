# SGA — Sistema de Gestión Académica

Sistema de gestión académica desarrollado para el **IES N° 9 "Juana Azurduy"**
de San Pedro de Jujuy, Argentina.

Proyecto de **Prácticas Profesionalizantes III** — Tecnicatura Superior en
Soporte de Infraestructura de Tecnología de la Información.

---

## Qué hace

Administra el recorrido académico de los alumnos de una carrera de nivel
superior, aplicando las reglas del plan de estudios oficial:

- **Alumnos** — legajo, datos de contacto, historial académico completo
- **Plan de estudios** — importación desde planilla, correlatividades y
  régimen de aprobación por materia, versionado de planes
- **Inscripciones** — a materias, con validación de correlatividades y
  ventana de inscripción configurable
- **Notas** — carga manual o importación desde la planilla del profesor,
  con sugerencia automática de condición y cierre de cursada
- **Mesas de examen** — convocatoria, inscripción, carga de resultados y
  generación del acta en PDF
- **Reportes** — constancias, estado académico y promedios en PDF

### Reglas académicas implementadas

El sistema no permite operaciones que contradigan el plan de estudios:

- La regularidad vence a los **2 años** de cargada la nota, o al agotarse
  los **3 intentos** en mesa de examen — lo que ocurra primero
- Para rendir el final hay que tener aprobadas las correlativas que el plan
  exige; para cursar, alcanza con tenerlas regularizadas
- Las materias cuyo régimen es sólo *Examen Final* no admiten promoción
- Las materias cuyo régimen es sólo *Promoción* no se rinden en mesa
- Una promoción sin la correlativa aprobada queda registrada como
  **condicionada** hasta que el alumno apruebe la materia previa

Las reglas se leen de la base de datos, no están escritas en el código: si
cambia el plan de estudios, se importa el nuevo y el sistema se adapta.

---

## Tecnologías

| Capa | Herramienta |
|---|---|
| Backend | Python 3 · Flask |
| Base de datos | PostgreSQL 18 |
| Frontend | HTML · CSS · JavaScript (sin framework) |
| Reportes | ReportLab (PDF) · openpyxl (Excel) |

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
pip install flask psycopg2-binary werkzeug openpyxl reportlab
```

**3. Crear la base de datos**

```bash
createdb ies9_gestion
psql -d ies9_gestion -f sga_ies9_v6.sql
psql -d ies9_gestion -f sga_ies9_datos_iniciales.sql
```

El primer script crea la estructura; el segundo carga los parámetros del
sistema y el administrador inicial.

**4. Configurar las credenciales**

Copiar `.env.example` como `.env` y completar la contraseña de PostgreSQL:

```
DB_HOST=localhost
DB_PORT=5432
DB_NAME=ies9_gestion
DB_USER=postgres
DB_PASSWORD=tu_contraseña
```

El archivo `.env` no se versiona: cada instalación tiene el suyo.

**5. Iniciar el sistema**

```bash
python run.py
```

Abrir `http://127.0.0.1:5000` en el navegador.

### Primer ingreso

| Usuario | Contraseña |
|---|---|
| `admin` | `Admin1234` |

El sistema pide completar los datos del administrador y definir una
contraseña nueva antes de continuar.

Si en algún momento se pierde el acceso, `python reset_admin.py` restablece
la cuenta.

---

## Estructura

```
sga-ies9/
├── app/
│   ├── __init__.py
│   ├── database.py           conexión a PostgreSQL
│   ├── routes.py             rutas y lógica del sistema
│   ├── static/
│   └── templates/
├── run.py                    punto de entrada
├── reset_admin.py            restablece el acceso del administrador
├── sga_ies9_v6.sql           estructura de la base (19 tablas)
├── sga_ies9_datos_iniciales.sql
├── .env.example
└── .gitignore
```

---

## Alcance

El sistema cubre la gestión académica del recorrido del alumno. Quedan
fuera de esta versión, identificados para una implementación futura:

- Gestión de convocatorias a mesas extraordinarias
- Penalización del alumno ausente para el llamado siguiente
- Autogestión de inscripciones por parte del alumno
- Publicación del sistema en internet con certificado SSL

---

## Datos de prueba

Los datos de alumnos y profesores incluidos en el entorno de desarrollo son
**ficticios**, generados únicamente para probar el sistema.
