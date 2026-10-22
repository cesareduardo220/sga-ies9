import os
from dotenv import load_dotenv
load_dotenv()
from flask import Flask, request, abort
from .database import get_db
from datetime import timedelta

# Rutas del módulo de inscripción por Internet: formulario público, tokens,
# ventana del formulario y cola de revisión de preinscripciones.
# Ojo: /api/inscripciones (en plural) es la inscripción a materias que hace la
# preceptora y NO forma parte del módulo.
RUTAS_AUTOINSCRIPCION = (
    '/inscripcion',
    '/api/inscripcion',
    '/api/tokens',
    '/api/autoinscripcion',
    '/api/preinscripciones',
)


def es_ruta_autoinscripcion(ruta):
    ruta = ruta.rstrip('/') or '/'
    return any(ruta == r or ruta.startswith(r + '/') for r in RUTAS_AUTOINSCRIPCION)


def create_app():
    app = Flask(__name__)
    app.secret_key = os.environ.get('SECRET_KEY')
    if not app.secret_key:
        raise RuntimeError('Falta SECRET_KEY en el .env')
    # Sesión expira por inactividad después de 60 minutos
    app.config['PERMANENT_SESSION_LIFETIME'] = timedelta(minutes=60)

    # Inscripción por Internet (tokens, formulario público, cola de revisión y
    # envío de correos). Depende de cómo está instalado el servidor, no de una
    # decisión académica: en una instalación solo de red local, sin salida a
    # Internet, se apaga con AUTOINSCRIPCION_ONLINE=0 en el .env. Si la variable
    # no está, queda encendida, como estuvo siempre.
    app.config['AUTOINSCRIPCION_ONLINE'] = (
        os.environ.get('AUTOINSCRIPCION_ONLINE', '1').strip().lower()
        not in ('0', 'false', 'no', 'off')
    )

    from .routes import auth
    app.register_blueprint(auth)

    # Con el módulo apagado, sus rutas no existen: ocultar el menú no alcanza,
    # porque cualquiera en la red que conozca la dirección podría entrar igual.
    @app.before_request
    def bloquear_autoinscripcion_apagada():
        if not app.config['AUTOINSCRIPCION_ONLINE'] and es_ruta_autoinscripcion(request.path):
            abort(404)

    # Las plantillas saben si el módulo está encendido, para no mostrarlo.
    @app.context_processor
    def datos_de_instalacion():
        return {'autoinscripcion_online': app.config['AUTOINSCRIPCION_ONLINE']}

    # Evita que el navegador guarde las paginas privadas en cache.
    # Sin esto, el boton Atras muestra la interfaz despues de cerrar sesion.
    @app.after_request
    def no_cachear(respuesta):
        respuesta.headers['Cache-Control'] = 'no-store, no-cache, must-revalidate, max-age=0'
        respuesta.headers['Pragma'] = 'no-cache'
        respuesta.headers['Expires'] = '0'
        # Ninguna página puede mostrar el SGA dentro de un marco (iframe):
        # protege del clickjacking. El clásico y el moderno, para todo navegador.
        respuesta.headers['X-Frame-Options'] = 'DENY'
        respuesta.headers['Content-Security-Policy'] = "frame-ancestors 'none'"
        return respuesta

    return app
