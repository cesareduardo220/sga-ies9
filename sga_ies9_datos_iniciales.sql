-- ================================================================
-- SGA - IES N 9 "Juana Azurduy"
-- DATOS INICIALES  (seed)
--
-- Ejecutar UNA sola vez, DESPUES de crear la estructura con
-- sga_ies9_v6.sql, sobre una base nueva y vacia.
--
-- Deja el sistema listo para el primer ingreso:
--   Usuario:    admin
--   Contrasena: Admin1234
--
-- Al entrar, el sistema pide completar los datos del
-- administrador y definir una contrasena propia.
--
-- NO ejecutar sobre una base con datos: los INSERT de
-- configuracion fallarian por clave duplicada.
-- ================================================================

-- ── Parametros globales que el sistema necesita para funcionar ──
INSERT INTO configuracion (clave, valor, descripcion) VALUES
    ('anio_lectivo_actual', '2026', 'Anio lectivo vigente, lo cambia solo el admin'),
    ('nombre_sistema',      'SGA - IES N 9', 'Nombre del sistema'),
    ('nombre_instituto',    'IES N 9 "Juana Azurduy"', 'Nombre del instituto');

-- ── Administrador inicial ──────────────────────────────────────
-- La contrasena va hasheada (el login usa check_password_hash).
-- El DNI queda NULL a proposito: es lo que dispara el asistente
-- de configuracion inicial en el primer ingreso.
INSERT INTO usuarios (usuario, password_hash, rol, nombre, apellido, debe_cambiar_password)
VALUES ('admin',
        'scrypt:32768:8:1$bX4k6IIcG6tiNQ0j$1ed5ebd101f0223014f6bf1b6e4eb6609318d88e9610731a1fc13ff3c6b8413a43ce6ce2884a7182d87856d41b2e6feee895beef192021d4ab0456b3c7e81bd1',
        'admin', 'Administrador', 'General', TRUE);

-- ── Verificacion ───────────────────────────────────────────────
SELECT 'Usuarios creados:' AS control, COUNT(*)::text AS cantidad FROM usuarios
UNION ALL
SELECT 'Parametros creados:', COUNT(*)::text FROM configuracion;
