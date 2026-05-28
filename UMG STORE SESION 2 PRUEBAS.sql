USE UMGSTORE;
--SIMULACION PARA DIRTY READ
BEGIN TRANSACTION;

UPDATE Usuario
SET contrasena = 5000
WHERE id_rol = 1;

ROLLBACK;

--SIMULACION DE DIRTY READ
SET TRANSACTION ISOLATION LEVEL READ COMMITTED;

BEGIN TRANSACTION;

SELECT contrasena
FROM Usuario
WHERE id_rol = 1;

UPDATE Usuario
SET contrasena = 9999
WHERE id_rol = 1;

COMMIT;

--simulacion para denegado de permisos con login de operador
SELECT * FROM Cliente;

ROLLBACK;