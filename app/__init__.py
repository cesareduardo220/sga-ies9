import os
from dotenv import load_dotenv
load_dotenv()
from flask import Flask
from .database import get_db
from datetime import timedelta

def create_app():
    app = Flask(__name__)
    app.secret_key = os.environ.get('SECRET_KEY')
    if not app.secret_key:
        raise RuntimeError('Falta SECRET_KEY en el .env')
    # Sesión expira por inactividad después de 60 minutos
    app.config['PERMANENT_SESSION_LIFETIME'] = timedelta(minutes=60)

    from .routes import auth
    app.register_blueprint(auth)
    
    # Evita que el navegador guarde las paginas privadas en cache.
    # Sin esto, el boton Atras muestra la interfaz despues de cerrar sesion.
    @app.after_request
    def no_cachear(respuesta):
        respuesta.headers['Cache-Control'] = 'no-store, no-cache, must-revalidate, max-age=0'
        respuesta.headers['Pragma'] = 'no-cache'
        respuesta.headers['Expires'] = '0'
        return respuesta

    return app
