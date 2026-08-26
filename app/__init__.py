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

    return app
