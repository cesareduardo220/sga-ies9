from dotenv import load_dotenv
load_dotenv()
import subprocess
import sys


def instalar_dependencias():
    dependencias = [
        'Flask==3.1.3',
        'openpyxl==3.1.5',
        'Pillow==12.2.0',
        'psycopg2-binary==2.9.12',
        'reportlab',
    ]
    for paquete in dependencias:
        nombre = paquete.split('==')[0].lower().replace('-', '_')
        # Mapeo especial para imports
        import_name = {'pillow': 'PIL', 'psycopg2_binary': 'psycopg2', 'flask': 'flask', 'openpyxl': 'openpyxl', 'reportlab': 'reportlab'}.get(nombre, nombre)
        try:
            __import__(import_name)
        except ImportError:
            print(f"Instalando {paquete}...")
            subprocess.check_call([sys.executable, '-m', 'pip', 'install', paquete])
            print(f"{paquete} instalado correctamente.")


instalar_dependencias()

from app import create_app

app = create_app()

if __name__ == '__main__':
    app.run(host='0.0.0.0', port=5000, debug=True)
