"""
Envío de correos del SGA: tokens de inscripción en línea.

La configuración sale del .env (ver .env.example):
    SMTP_HOST, SMTP_PUERTO, SMTP_SEGURIDAD, SMTP_USUARIO,
    SMTP_CONTRASENA, SMTP_REMITENTE, SMTP_NOMBRE

Los envíos corren en un hilo aparte para que la pantalla no quede
esperando. El resultado de cada envío queda guardado en el token
(email_estado, email_error, email_enviado_en).
"""
import os
import smtplib
import ssl
import threading
import logging
from html import escape
from email.message import EmailMessage
from email.utils import formatdate, make_msgid
from email.utils import formataddr

from .database import get_db

log = logging.getLogger(__name__)

_QUE_ES = {
    'ingresante':    'tu inscripción',
    'alta':          'tu registro como alumno',
    'reinscripcion': 'tu reinscripción',
}


def correo_configurado():
    return bool(os.environ.get('SMTP_REMITENTE') or os.environ.get('SMTP_USUARIO'))


def _conectar():
    host      = os.environ.get('SMTP_HOST', 'smtp.gmail.com')
    puerto    = int(os.environ.get('SMTP_PUERTO', '587'))
    seguridad = os.environ.get('SMTP_SEGURIDAD', 'starttls').lower()
    usuario   = os.environ.get('SMTP_USUARIO', '')
    clave     = os.environ.get('SMTP_CONTRASENA', '').replace(' ', '')

    if seguridad == 'ssl':
        servidor = smtplib.SMTP_SSL(host, puerto, timeout=20,
                                    context=ssl.create_default_context())
    else:
        servidor = smtplib.SMTP(host, puerto, timeout=20)
        if seguridad == 'starttls':
            servidor.starttls(context=ssl.create_default_context())
    if usuario:
        servidor.login(usuario, clave)
    return servidor


def _armar_mensaje(destino, token, tipo, vence, nombre, url_publica, instituto):
    remitente = os.environ.get('SMTP_REMITENTE') or os.environ.get('SMTP_USUARIO')
    nombre_remitente = os.environ.get('SMTP_NOMBRE') or instituto
    enlace = url_publica.rstrip('/') + '/inscripcion'
    vence_txt = vence.strftime('%d/%m/%Y') if vence else ''
    que = _QUE_ES.get(tipo, 'tu inscripción')
    saludo = f'Hola {nombre}:' if nombre else 'Hola:'

    msg = EmailMessage()
    msg['Subject'] = f'Tu código para la inscripción en línea - {instituto}'
    msg['From'] = formataddr((nombre_remitente, remitente))
    msg['To'] = destino
    msg['Date'] = formatdate(localtime=True)
    msg['Message-ID'] = make_msgid(domain=remitente.split('@')[-1])
    msg['Content-Language'] = 'es'

    msg.set_content(
        f"{saludo}\n\n"
        f"Este es tu código para completar {que} en línea en {instituto}:\n\n"
        f"    {token}\n\n"
        f"Ingresá en: {enlace}\n\n"
        f"Podés usarlo mientras esté abierto el período de inscripción de tu carrera (actualmente, hasta el {vence_txt}). Sirve para una sola inscripción. "
        f"Es personal: no lo compartas.\n\n"
        f"Si no pediste este código, podés ignorar este correo.\n"
    )
    msg.add_alternative(f"""<!DOCTYPE html>
<html lang="es"><body style="margin:0; padding:24px; background:#F4F2EC; font-family:Arial, sans-serif; color:#1f2a24;">
  <div style="max-width:520px; margin:0 auto; background:#ffffff; border-radius:14px; padding:28px;">
    <p style="margin:0 0 6px; font-size:12px; letter-spacing:1px; text-transform:uppercase; color:#1B5E3F;">
      {escape(instituto)}</p>
    <h2 style="margin:0 0 16px; font-size:20px;">Inscripción en línea</h2>
    <p style="margin:0 0 14px;">{escape(saludo)}</p>
    <p style="margin:0 0 18px;">Este es tu código para completar {escape(que)} en línea:</p>
    <p style="margin:0 0 22px; font-family:'Courier New', monospace; font-size:26px; font-weight:bold; white-space:nowrap;
              letter-spacing:2px; text-align:center; background:#EEF6F0; border-radius:10px; padding:14px 8px;">
      {escape(token)}</p>
    <p style="text-align:center; margin:0 0 22px;">
      <a href="{escape(enlace)}" style="background:#1B5E3F; color:#ffffff; text-decoration:none;
         padding:12px 22px; border-radius:10px; font-weight:bold; display:inline-block;">Ir a la inscripción</a></p>
    <p style="margin:0 0 8px; font-size:14px;">Podés usarlo mientras esté abierto el período de inscripción
      de tu carrera (actualmente, hasta el <strong>{escape(vence_txt)}</strong>).
      Sirve para una sola inscripción. Es personal: no lo compartas.</p>
    <p style="margin:0; font-size:12px; color:#6B7280;">Si el botón no funciona, copiá este enlace en el navegador:
      {escape(enlace)}<br>Si no pediste este código, podés ignorar este correo.</p>
  </div>
</body></html>""", subtype='html')
    return msg


def _marcar(cur, token_id, estado, error=None):
    cur.execute("""
        UPDATE tokens_inscripcion
        SET email_estado = %s,
            email_error = %s,
            email_enviado_en = CASE WHEN %s = 'enviado' THEN now() ELSE email_enviado_en END
        WHERE id = %s
    """, (estado, error, estado, token_id))


def _motivo(e):
    if isinstance(e, smtplib.SMTPAuthenticationError):
        return 'El servidor de correo rechazó el usuario o la contraseña de aplicación.'
    if isinstance(e, smtplib.SMTPRecipientsRefused):
        return 'El servidor de correo rechazó la dirección del alumno.'
    return f'No se pudo enviar el correo ({type(e).__name__}).'


def enviar_tokens(token_ids, url_publica, instituto):
    """Envía los tokens indicados y deja el resultado guardado en cada uno."""
    conn = get_db()
    cur = conn.cursor()
    servidor = None
    try:
        cur.execute("""
            SELECT t.id, t.token, t.tipo, t.vence_el, t.email_destino, a.nombre
            FROM tokens_inscripcion t
            LEFT JOIN alumnos a ON a.id = t.alumno_id
            WHERE t.id = ANY(%s)
            ORDER BY t.id
        """, (list(token_ids),))
        filas = cur.fetchall()

        error_general = None
        if not correo_configurado():
            error_general = 'El envío de correos todavía no está configurado en el servidor.'
        else:
            try:
                servidor = _conectar()
            except Exception as e:
                log.warning('No se pudo conectar al servidor de correo: %s', e)
                error_general = _motivo(e) if isinstance(e, smtplib.SMTPAuthenticationError) \
                    else 'No se pudo conectar con el servidor de correo.'

        for tid, token, tipo, vence, destino, nombre in filas:
            if not destino:
                _marcar(cur, tid, 'error', 'No hay un correo para enviarlo.')
            elif error_general:
                _marcar(cur, tid, 'error', error_general)
            else:
                mensaje = _armar_mensaje(destino, token, tipo, vence, (nombre or '').split(' ')[0],
                                         url_publica, instituto)
                try:
                    servidor.send_message(mensaje)
                    _marcar(cur, tid, 'enviado')
                except smtplib.SMTPServerDisconnected:
                    # Gmail corta la conexión cada tantos envíos: se reconecta una vez
                    try:
                        servidor = _conectar()
                        servidor.send_message(mensaje)
                        _marcar(cur, tid, 'enviado')
                    except Exception as e:
                        _marcar(cur, tid, 'error', _motivo(e))
                except Exception as e:
                    log.warning('Falló el envío del token %s: %s', tid, e)
                    _marcar(cur, tid, 'error', _motivo(e))
            conn.commit()
    except Exception:
        log.exception('Error general enviando tokens')
        conn.rollback()
    finally:
        if servidor is not None:
            try:
                servidor.quit()
            except Exception:
                pass
        cur.close()
        conn.close()


def despachar(token_ids, url_publica, instituto):
    """Lanza el envío en segundo plano."""
    ids = [int(x) for x in token_ids]
    if ids:
        threading.Thread(target=enviar_tokens, args=(ids, url_publica, instituto),
                         daemon=True).start()
