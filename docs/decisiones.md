# Decisiones de diseño del SGA

Este documento reúne las decisiones de diseño del Sistema de Gestión Académica
(SGA) del Instituto de Educación Superior (IES) N° 9 "Juana Azurduy" de San
Pedro de Jujuy. Para cada una se indica qué se decidió, por qué y, cuando
corresponde, qué alternativa se descartó. El objetivo es que cualquier persona
que tome el sistema pueda entender el criterio detrás de su funcionamiento, y no
solo el funcionamiento.

Las decisiones se agrupan por tema: arquitectura, modelo de datos, roles,
acceso y seguridad, reglas académicas, plan de estudios, cambio de plan,
inscripciones, documentos y, al final, lo que se decidió no hacer.

---

## 1. Arquitectura y tecnología

**Aplicación web con Flask, PostgreSQL y JavaScript sin framework.**
El servidor está escrito en Python con Flask, los datos viven en PostgreSQL y la
interfaz es una aplicación de página única (SPA, *Single Page Application*) en
HTML, CSS y JavaScript sin frameworks. Se eligió así para que el sistema corra
en un equipo modesto, sin pasos de compilación ni dependencias pesadas, y para
que el código pueda leerse y modificarse sin conocer un framework de interfaz.

**Se mantiene PostgreSQL y no se migra a MySQL.**
Se evaluó migrar a MySQL porque es el motor que el grupo conoce de la cursada.
Se descartó: el sistema ya estaba construido y probado sobre PostgreSQL, y
migrar implicaba reescribir consultas y volver a probar todo. En su lugar se
armó material de equivalencias entre ambos motores para que el grupo pueda
responder consultas SQL en la defensa.

**Servidor propio con Ubuntu Server, publicado por Tailscale Funnel.**
El sistema corre en una PC de escritorio con Ubuntu Server: Gunicorn ejecuta la
aplicación como servicio de systemd y nginx actúa como proxy inverso. Para
acceder desde Internet se usa Tailscale Funnel, que da una dirección fija con
HTTPS (protocolo seguro de transferencia de hipertexto) sin costo y sin comprar
un dominio. Se descartaron el alojamiento pago, la compra de un dominio y
Cloudflare Tunnel con URL (dirección web) fija.

**Cinco procesos para atender pedidos simultáneos.**
Gunicorn corre con 5 procesos de trabajo (*workers*), la cantidad recomendada
para un procesador de 2 núcleos: el doble de núcleos más uno. Más procesos no
aumentarían la capacidad, porque competirían por los mismos núcleos; con 5, el
servidor atiende a decenas de usuarios conectados a la vez. Las tareas
automáticas se coordinan a través de la base de datos para que dos procesos no
las ejecuten dos veces.

**Vigilancia automática del acceso público.**
Un temporizador de systemd revisa cada 2 minutos que el Funnel responda y, si
no, lo vuelve a publicar. Su limitación conocida es que la verificación se hace
desde el propio servidor, por la red interna de Tailscale, y no desde Internet.
Se decidió dejarlo así: su consumo es despreciable y resuelve las caídas más
probables, como un reinicio del servidor o una reconexión de Tailscale.

**Navegación con el historial del navegador.**
Las secciones se recorren con los botones Atrás y Adelante del navegador, sin
botones internos de "Volver". La pantalla inicial no agrega una entrada al
historial, porque no es una navegación del usuario.

**Interfaz usable desde el celular, modificaciones solo desde computadora.**
Todas las pantallas se adaptan al celular, pero el servidor rechaza cualquier
modificación que llegue desde uno, salvo el ingreso al sistema, el cambio de
contraseña, la configuración inicial y el formulario público de inscripción. El
celular sirve para consultar; las cargas se hacen en una computadora, donde es
más difícil equivocarse.

---

## 2. Modelo de datos

**Pensado para varias carreras.**
El IES N° 9 tiene 19 carreras. El sistema permite que se sume cualquiera de
ellas, cada una con su propia interfaz, sus coordinadores, preceptoras,
profesores y alumnos.

**Una ficha por carrera.**
Cada carrera guarda su propia ficha del alumno: los datos no se comparten ni se
precargan desde otra carrera. Así, una misma persona puede cursar dos carreras,
y lo que se edita en una no modifica la otra. El número de legajo se guarda en
la ficha de cada carrera y no puede repetirse dentro de ella.

**El DNI (Documento Nacional de Identidad) es el usuario de todo el sistema.**
Cada persona tiene una sola credencial. Una preceptora puede atender varias
carreras con la misma contraseña y elige la carrera desde la cabecera; ese
selector aparece solo si tiene más de una. No se contempla que un coordinador
coordine dos carreras, porque no ocurre en el instituto. Todas las contraseñas
se guardan como *hash*, un resumen que no se puede revertir, y nunca en texto
legible.

**Las reglas académicas están en la base de datos, no en el código.**
Las correlatividades, el régimen de aprobación y el examen libre de cada materia
se cargan con el plan de estudios. Si cambia el plan, se carga el nuevo y el
sistema se adapta sin tocar el programa.

**Planes de estudio versionados.**
Cada carrera tiene un plan vigente a la vez, pero puede convivir con planes
anteriores durante una transición, y cada alumno queda asociado al plan que le
corresponde.

---

## 3. Roles

**Administrador: estructura del sistema.**
Crea carreras, usuarios y gestiona el año lectivo. La interfaz no le ofrece los
datos académicos de las carreras: actúa como responsable de la estructura, no de
la gestión académica.

**Coordinador: el plan y las correcciones.**
Carga el plan de estudios, conduce el cambio de plan, gestiona profesores y
preceptoras, y es el único que puede corregir una nota ya cerrada, siempre con
un motivo que queda registrado.

**Preceptora: la tarea diaria.**
Inscribe alumnos, carga notas y atiende las inscripciones por Internet.

**Profesores y alumnos no ingresan al sistema.**
El alumno solo usa el formulario público de inscripción, al que accede con un
código de acceso ("token") que le entrega la preceptora.

**Un único ingreso e interfaz para todos los roles.**
No hay pantallas de ingreso ni paneles separados por rol: cada usuario ve lo que
su rol le permite dentro de la misma interfaz.

---

## 4. Acceso y seguridad

**La contraseña provisoria es al azar y vence.**
Al crear o resetear una cuenta, el sistema genera una contraseña provisoria de
ocho caracteres al azar, que se muestra una sola vez a quien la generó para que
la entregue, y que vence a las 72 horas si no se usa. Al principio se usaba el
DNI, pero el DNI no es un secreto: aparece en listas y documentos, y quien lo
conociera podía entrar antes que el titular y ponerle su propia contraseña.

**El cambio de la contraseña provisoria es obligatorio y lo controla el
servidor.**
Hasta que la persona la cambie, el servidor solo le permite la
pantalla de cambio de contraseña o salir: cualquier otra dirección, incluida la
vuelta atrás con el navegador, la devuelve a esa pantalla, y los pedidos de
datos se rechazan. El control se hace en cada pedido consultando la base, así
que también alcanza a una contraseña reseteada mientras la persona está
conectada. En un principio la obligación era solo una redirección después del
ingreso; una prueba mostró que, volviendo atrás, se entraba al sistema con la
contraseña provisoria, y el control pasó al servidor.

**Una sola sesión por cuenta.**
Un nuevo ingreso con la misma cuenta cierra la sesión anterior, que se entera en
su siguiente acción. Así una cuenta no puede usarse en dos lugares a la vez sin
que su dueño lo note.

**Cierre por inactividad.**
La sesión se cierra después de 60 minutos sin actividad, y una vez cerrada el
navegador no permite volver a las pantallas anteriores con la flecha Atrás.

---

## 5. Reglas académicas

**Tres tipos de correlatividad.**
- *Regularizada para cursar*: la materia previa tiene que estar al menos
  regularizada para inscribirse.
- *Aprobada para cursar*: propia de los Profesorados; la materia previa tiene
  que estar aprobada para inscribirse.
- *Aprobada para rendir o promocionar*: la materia previa tiene que estar
  aprobada para rendir el final o para que la promoción quede firme.

Los dos primeros tipos frenan la inscripción; el tercero frena la mesa de
examen. Un requisito como "1° Año" en la resolución se carga como todas las
materias de ese año.

**Año habilitado.**
Para inscribirse en materias de un año hay que tener al menos una materia
regularizada o aprobada del año anterior; primer año está siempre disponible.
Es la regla del instituto para todas las carreras, Tecnicaturas y Profesorados.

**Vencimiento de la regularidad.**
La regularidad vence a los 2 años de cargada la nota o al agotarse 3 intentos en
mesa de examen, lo que ocurra primero. Solo cuenta para las mesas de alumnos
regulares.

**Promoción provisoria.**
Si un alumno promociona una materia adeudando el final de una correlativa, la
promoción no se bloquea: queda provisoria hasta una fecha límite configurable
(el 31 de diciembre del año lectivo). Si para entonces no aprobó la correlativa,
la materia pasa a regular y debe rendir el final. Una promoción que se cayó no
se restituye aunque la correlativa se apruebe después. Una promoción provisoria
no cuenta como aprobada para la ficha del alumno ni para la constancia.

**Régimen de aprobación.**
Las materias de solo "Examen Final" no admiten promoción, y las de solo
"Promoción" (por ejemplo, las Prácticas) no van a mesa: si el alumno no
promociona, recursa.

**Examen libre por materia.**
En los Profesorados solo las materias marcadas con (\*) en la resolución admiten
alumnos libres; en el resto, quien queda libre recursa. El sistema no permite
armar una mesa libre de una materia que no lo admite. Si el plan no marca
ninguna, todas admiten examen libre, como en las Tecnicaturas.

**Lo aprobado y lo regular vigente no se vuelven a cursar.**
Una materia aprobada, o con la regularidad vigente, no se puede inscribir de
nuevo. El servidor vuelve a validar cada inscripción con la misma regla que la
pantalla, así que no alcanza con habilitar una casilla para saltearla.

---

## 6. Plan de estudios

**El plan se carga solo desde Excel.**
Se evaluó importarlo directamente desde las resoluciones en PDF (formato de
documento portátil). Se descartó al probar el reconocimiento óptico de
caracteres (OCR, *Optical Character Recognition*) sobre las resoluciones reales,
que son hojas escaneadas: confundía justo los números de las correlatividades
(un 6 por un 8, un 15 por un 16), lo que hubiera cargado requisitos equivocados
sin que se notara. El coordinador tendría que revisar cada celda contra el
papel, que es casi el mismo trabajo que tipearlo.

**La planilla se lee por el nombre de las columnas.**
Así sirve tanto la plantilla actual como la anterior. Lo que no se entiende, un
número de orden inexistente o una correlativa de un año posterior se muestran
como aviso en la revisión, en lugar de descartarse en silencio. Un número de
orden repetido rechaza el archivo, porque las correlatividades se refieren a él.

**El (\*) de la resolución se copia tal cual.**
Para marcar el examen libre, el coordinador transcribe los nombres como figuran
en la resolución. El sistema reconoce la marca, la saca del nombre y la guarda
aparte. Se descartó una columna Sí/No, que obligaba a completar casi todas las
filas de un Profesorado.

**Sugerencias de escritura: el sistema propone, el coordinador decide.**
En la revisión, el sistema señala los nombres que parecen mal escritos (todo en
mayúscula o minúscula, tildes que faltan) y propone la corrección, pero no la
aplica sola. Las siglas y los números romanos hacen que ninguna regla acierte
siempre, y un nombre mal escrito se propaga a actas, analíticos y constancias.

**Editar o eliminar una materia solo si no tiene historia.**
Se puede corregir o quitar una materia mientras no tenga inscripciones,
exámenes, mesas ni preinscripciones. Si ya las tiene, el cambio se hace con un
plan nuevo, para no alterar la historia académica.

---

## 7. Cambio de plan de estudios

**Al confirmar el plan nuevo no se migra a nadie.**
Los alumnos en curso conservan su plan; los ingresantes entran con el nuevo
desde su fecha de vigencia.

**La tabla de equivalencias la completa el coordinador.**
Para cada materia del plan nuevo se indica qué materias del plan anterior la
reconocen. Viene precargada por coincidencia de nombre, pero todo se puede
cambiar con la resolución a la vista.

**Qué se reconoce.**
Si todas las materias del grupo están aprobadas, la nueva se reconoce como
aprobada. Si todas están al menos regulares y vigentes, la nueva queda regular:
conserva el vencimiento de la original y los intentos ya usados, y el alumno
rinde el final de la materia nueva.

**El reconocimiento se calcula en el momento.**
No se guarda: se calcula cada vez a partir del historial. Solo se guardan las
excepciones de la política "personalizada", en la que el coordinador puede no
reconocer una materia puntual a un alumno, con motivo, antes de migrarlo.

**La migración es manual y con fecha límite.**
Se hace desde la pantalla "Cerrar plan", recién cuando el plan nuevo rige. Los
egresados no se migran, y los alumnos con cursadas del plan anterior abiertas
esperan a cerrarlas. El sistema sugiere prórroga cuando al alumno le falta menos
en el plan anterior que en el nuevo.

**Prórrogas con motivo.**
Se otorgan por alumno, con motivo obligatorio, fecha y disposición opcional.
Una prórroga vigente tiene prioridad sobre las cursadas abiertas. Al vencer, el
alumno vuelve a quedar para migrar.

**Aviso al coordinador.**
Desde 30 días antes de la fecha límite, una barra le avisa al coordinador cuántos
alumnos quedan por resolver, o que el plan anterior ya se puede cerrar.

---

## 8. Inscripciones por Internet

**El token certifica que los papeles están en orden.**
La preceptora controla la documentación en persona y recién entonces entrega el
token. Se descartó que el coordinador cargue de antemano una lista de DNI
habilitados, por ser trabajo duplicado.

**Un solo formulario, tres tipos de token.**
El tipo de token define qué ve el alumno: el formulario del ingresante, la
reinscripción del alumno que ya cursa (con las materias filtradas según su
historial) o el alta de un alumno avanzado que todavía no está en el sistema.

**El token se envía por correo.**
Es el único uso del correo del sistema. Se quitaron las opciones de WhatsApp,
copiar e imprimir, porque abrían cuentas personales o requerían impresora. El
correo y el celular son obligatorios en el formulario, y se aceptan solo
proveedores de correo conocidos, según una lista configurable.

**Ventanas separadas.**
La ventana del formulario público y la de inscripción a materias son
independientes, y la preceptora revisa cada inscripción antes de aprobarla.

---

## 9. Documentos

**La constancia de alumno regular sale en blanco.**
Replica el formulario original del instituto y se completa a mano. El sistema
solo verifica que el alumno esté en condiciones de recibirla.

**Nombre oficial en los documentos.**
En pantalla se usa un nombre corto de la carrera; en los PDF (plan de estudios,
actas, constancias) se mantiene el nombre oficial completo.

**Actas fieles al formato del instituto.**
El acta de mesa de examen reproduce el formato en papel del IES N° 9.

---

## 10. Lo que se decidió no hacer

- **Importar el plan desde PDF o foto**: el reconocimiento de escaneos no es
  confiable en los datos críticos (ver sección 6).
- **Migrar a MySQL**: ver sección 1.
- **Avisar por correo la prórroga o emitir su constancia**: la prórroga ya se
  comunica por la vía formal del instituto, con su disposición.
- **Registrar en el sistema la resolución que autoriza la carrera**: su único
  uso previsto era la constancia, que quedó en blanco.
- **Importar alumnos desde Google Sheets**: la inscripción por Internet la
  reemplaza.
- **Mejorar la vigilancia del acceso público**: no hubo caídas desde que se
  cambió el cable de red del servidor.
