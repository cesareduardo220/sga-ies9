from flask import Flask
from .database import get_db
from datetime import timedelta

def create_app():
    app = Flask(__name__)
    app.secret_key = 'ies9_secret_2026'

    # Sesión expira por inactividad después de 60 minutos
    app.config['PERMANENT_SESSION_LIFETIME'] = timedelta(minutes=60)

    from .routes import auth
    app.register_blueprint(auth)

    return app
