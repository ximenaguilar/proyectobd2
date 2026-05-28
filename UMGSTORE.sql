CREATE DATABASE UMGSTORE;
GO

USE UMGSTORE;
GO

CREATE TABLE Rol (
    id_rol INT PRIMARY KEY IDENTITY(1,1),
    nombre_rol VARCHAR(50) UNIQUE NOT NULL
);
CREATE TABLE Usuario (
    id_usuario INT PRIMARY KEY IDENTITY(1,1),
    nombre VARCHAR(100) NOT NULL,
    usuario VARCHAR(50) UNIQUE NOT NULL,
    contrasena VARCHAR(100) NOT NULL,
    id_rol INT,
    
    FOREIGN KEY (id_rol)
    REFERENCES Rol(id_rol)
);

CREATE TABLE Cliente (
    id_cliente INT PRIMARY KEY IDENTITY(1,1),
    nombre VARCHAR(100) NOT NULL,
    telefono VARCHAR(20),
    correo VARCHAR(100) UNIQUE,
    direccion VARCHAR(200)
);


CREATE TABLE Proveedor (
    id_proveedor INT PRIMARY KEY IDENTITY(1,1),
    nombre VARCHAR(100) NOT NULL,
    telefono VARCHAR(20),
    correo VARCHAR(100)
);

CREATE TABLE Categoria (
    id_categoria INT PRIMARY KEY IDENTITY(1,1),
    nombre_categoria VARCHAR(100) UNIQUE NOT NULL
);

CREATE TABLE Producto (
    id_producto INT PRIMARY KEY IDENTITY(1,1),
    nombre_producto VARCHAR(100) NOT NULL,
    precio DECIMAL(10,2),
    id_categoria INT,
    id_proveedor INT,

    FOREIGN KEY (id_categoria)
    REFERENCES Categoria(id_categoria),

    FOREIGN KEY (id_proveedor)
    REFERENCES Proveedor(id_proveedor)
);

CREATE TABLE Inventario (
    id_inventario INT PRIMARY KEY IDENTITY(1,1),
    id_producto INT,
    stock INT NOT NULL,

    FOREIGN KEY (id_producto)
    REFERENCES Producto(id_producto)
);
CREATE TABLE Venta (
    id_venta INT PRIMARY KEY IDENTITY(1,1),
    fecha DATETIME DEFAULT GETDATE(),
    total DECIMAL(10,2),
    id_cliente INT,
    id_usuario INT,

    FOREIGN KEY (id_cliente)
    REFERENCES Cliente(id_cliente),

    FOREIGN KEY (id_usuario)
    REFERENCES Usuario(id_usuario)
);
CREATE TABLE Detalle_Venta (
    id_detalle_venta INT PRIMARY KEY IDENTITY(1,1),
    id_venta INT,
    id_producto INT,
    cantidad INT,
    subtotal DECIMAL(10,2),

    FOREIGN KEY (id_venta)
    REFERENCES Venta(id_venta),

    FOREIGN KEY (id_producto)
    REFERENCES Producto(id_producto)
);
CREATE TABLE Compra (
    id_compra INT PRIMARY KEY IDENTITY(1,1),
    fecha DATETIME DEFAULT GETDATE(),
    total DECIMAL(10,2),
    id_proveedor INT,
    id_usuario INT,

    FOREIGN KEY (id_proveedor)
    REFERENCES Proveedor(id_proveedor),

    FOREIGN KEY (id_usuario)
    REFERENCES Usuario(id_usuario)
);
CREATE TABLE Detalle_Compra (
    id_detalle_compra INT PRIMARY KEY IDENTITY(1,1),
    id_compra INT,
    id_producto INT,
    cantidad INT,
    subtotal DECIMAL(10,2),

    FOREIGN KEY (id_compra)
    REFERENCES Compra(id_compra),

    FOREIGN KEY (id_producto)
    REFERENCES Producto(id_producto)
);
CREATE TABLE Pago (
    id_pago INT PRIMARY KEY IDENTITY(1,1),
    id_venta INT,
    metodo_pago VARCHAR(50),
    monto DECIMAL(10,2),

    FOREIGN KEY (id_venta)
    REFERENCES Venta(id_venta)
);
CREATE TABLE Auditoria (
    id_auditoria INT PRIMARY KEY IDENTITY(1,1),
    usuario_bd VARCHAR(100),
    fecha DATETIME,
    operacion VARCHAR(50),
    tabla_afectada VARCHAR(100)
);

SELECT * FROM INFORMATION_SCHEMA.TABLES;

INSERT INTO Rol(nombre_rol)
VALUES
('rol_admin'),
('rol_operador'),
('rol_consulta');

INSERT INTO Usuario(nombre, usuario, contrasena, id_rol)
VALUES
('Administrador', 'admin', '1234', 1),
('Operador', 'operador', '1234', 2),
('Consulta', 'consulta', '1234', 3);

INSERT INTO Categoria(nombre_categoria)
VALUES
('Laptops'),
('Monitores'),
('Accesorios');

SELECT * FROM Rol;
SELECT * FROM Usuario;
SELECT * FROM Categoria;

CREATE PROCEDURE sp_RegistrarCliente
    @nombre VARCHAR(100),
    @telefono VARCHAR(20),
    @correo VARCHAR(100),
    @direccion VARCHAR(200)
AS
BEGIN

    SET NOCOUNT ON;
    SET TRANSACTION ISOLATION LEVEL READ COMMITTED;

    BEGIN TRY

        BEGIN TRANSACTION;

        SAVE TRANSACTION SaveCliente;

        INSERT INTO Cliente(nombre, telefono, correo, direccion)
        VALUES(@nombre, @telefono, @correo, @direccion);

        INSERT INTO Auditoria(usuario_bd, fecha, operacion, tabla_afectada)
        VALUES(SUSER_NAME(), GETDATE(), 'INSERT', 'Cliente');

        COMMIT TRANSACTION;

        PRINT 'Cliente registrado correctamente';

    END TRY

    BEGIN CATCH

        ROLLBACK TRANSACTION;

        PRINT 'Error al registrar cliente';
        PRINT ERROR_MESSAGE();

    END CATCH

END;
CREATE PROCEDURE sp_RegistrarProveedor
    @nombre VARCHAR(100),
    @telefono VARCHAR(20),
    @correo VARCHAR(100)
AS
BEGIN

    SET TRANSACTION ISOLATION LEVEL READ COMMITTED;

    BEGIN TRY

        BEGIN TRANSACTION;

        INSERT INTO Proveedor(nombre, telefono, correo)
        VALUES(@nombre, @telefono, @correo);

        INSERT INTO Auditoria(usuario_bd, fecha, operacion, tabla_afectada)
        VALUES(SUSER_NAME(), GETDATE(), 'INSERT', 'Proveedor');

        COMMIT TRANSACTION;

    END TRY

    BEGIN CATCH

        ROLLBACK TRANSACTION;

        PRINT ERROR_MESSAGE();

    END CATCH

END;

CREATE PROCEDURE sp_RegistrarCategoria
    @nombre_categoria VARCHAR(100)
AS
BEGIN

    BEGIN TRY

        BEGIN TRANSACTION;

        INSERT INTO Categoria(nombre_categoria)
        VALUES(@nombre_categoria);

        INSERT INTO Auditoria(usuario_bd, fecha, operacion, tabla_afectada)
        VALUES(SUSER_NAME(), GETDATE(), 'INSERT', 'Categoria');

        COMMIT TRANSACTION;

    END TRY

    BEGIN CATCH

        ROLLBACK TRANSACTION;

        PRINT ERROR_MESSAGE();

    END CATCH

END;

CREATE PROCEDURE sp_RegistrarProducto
    @nombre_producto VARCHAR(100),
    @precio DECIMAL(10,2),
    @id_categoria INT,
    @id_proveedor INT
AS
BEGIN

    BEGIN TRY

        BEGIN TRANSACTION;

        INSERT INTO Producto(nombre_producto, precio, id_categoria, id_proveedor)
        VALUES(@nombre_producto, @precio, @id_categoria, @id_proveedor);

        INSERT INTO Auditoria(usuario_bd, fecha, operacion, tabla_afectada)
        VALUES(SUSER_NAME(), GETDATE(), 'INSERT', 'Producto');

        COMMIT TRANSACTION;

    END TRY

    BEGIN CATCH

        ROLLBACK TRANSACTION;

        PRINT ERROR_MESSAGE();

    END CATCH

END;

CREATE PROCEDURE sp_AgregarInventario
    @id_producto INT,
    @stock INT
AS
BEGIN

    BEGIN TRY

        BEGIN TRANSACTION;

        INSERT INTO Inventario(id_producto, stock)
        VALUES(@id_producto, @stock);

        INSERT INTO Auditoria(usuario_bd, fecha, operacion, tabla_afectada)
        VALUES(SUSER_NAME(), GETDATE(), 'INSERT', 'Inventario');

        COMMIT TRANSACTION;

    END TRY

    BEGIN CATCH

        ROLLBACK TRANSACTION;

        PRINT ERROR_MESSAGE();

    END CATCH

END;

CREATE PROCEDURE sp_ActualizarStock
    @id_producto INT,
    @cantidad INT
AS
BEGIN

    BEGIN TRY

        BEGIN TRANSACTION;

        UPDATE Inventario
        SET stock = stock + @cantidad
        WHERE id_producto = @id_producto;

        INSERT INTO Auditoria(usuario_bd, fecha, operacion, tabla_afectada)
        VALUES(SUSER_NAME(), GETDATE(), 'UPDATE', 'Inventario');

        COMMIT TRANSACTION;

    END TRY

    BEGIN CATCH

        ROLLBACK TRANSACTION;

        PRINT ERROR_MESSAGE();

    END CATCH

END;

CREATE PROCEDURE sp_RegistrarVenta
    @total DECIMAL(10,2),
    @id_cliente INT,
    @id_usuario INT
AS
BEGIN

    BEGIN TRY

        BEGIN TRANSACTION;

        INSERT INTO Venta(total, id_cliente, id_usuario)
        VALUES(@total, @id_cliente, @id_usuario);

        INSERT INTO Auditoria(usuario_bd, fecha, operacion, tabla_afectada)
        VALUES(SUSER_NAME(), GETDATE(), 'INSERT', 'Venta');

        COMMIT TRANSACTION;

    END TRY

    BEGIN CATCH

        ROLLBACK TRANSACTION;

        PRINT ERROR_MESSAGE();

    END CATCH

END;

CREATE PROCEDURE sp_DetalleVenta
    @id_venta INT,
    @id_producto INT,
    @cantidad INT,
    @subtotal DECIMAL(10,2)
AS
BEGIN

    DECLARE @stock_actual INT;

    BEGIN TRY

        BEGIN TRANSACTION;

        SAVE TRANSACTION SaveDetalle;

        SELECT @stock_actual = stock
        FROM Inventario WITH (UPDLOCK, ROWLOCK)
        WHERE id_producto = @id_producto;

        IF @stock_actual < @cantidad
        BEGIN
            RAISERROR('Stock insuficiente',16,1);
        END

        INSERT INTO Detalle_Venta(id_venta, id_producto, cantidad, subtotal)
        VALUES(@id_venta, @id_producto, @cantidad, @subtotal);

        UPDATE Inventario
        SET stock = stock - @cantidad
        WHERE id_producto = @id_producto;

        INSERT INTO Auditoria(usuario_bd, fecha, operacion, tabla_afectada)
        VALUES(SUSER_NAME(), GETDATE(), 'INSERT', 'Detalle_Venta');

        COMMIT TRANSACTION;

    END TRY

    BEGIN CATCH

        ROLLBACK TRANSACTION;

        PRINT ERROR_MESSAGE();

    END CATCH

END;

CREATE PROCEDURE sp_RegistrarCompra
    @total DECIMAL(10,2),
    @id_proveedor INT,
    @id_usuario INT
AS
BEGIN

    BEGIN TRY

        BEGIN TRANSACTION;

        INSERT INTO Compra(total, id_proveedor, id_usuario)
        VALUES(@total, @id_proveedor, @id_usuario);

        INSERT INTO Auditoria(usuario_bd, fecha, operacion, tabla_afectada)
        VALUES(SUSER_NAME(), GETDATE(), 'INSERT', 'Compra');

        COMMIT TRANSACTION;

    END TRY

    BEGIN CATCH

        ROLLBACK TRANSACTION;

        PRINT ERROR_MESSAGE();

    END CATCH

END;

CREATE PROCEDURE sp_RegistrarPago
    @id_venta INT,
    @metodo_pago VARCHAR(50),
    @monto DECIMAL(10,2)
AS
BEGIN

    BEGIN TRY

        BEGIN TRANSACTION;

        INSERT INTO Pago(id_venta, metodo_pago, monto)
        VALUES(@id_venta, @metodo_pago, @monto);

        INSERT INTO Auditoria(usuario_bd, fecha, operacion, tabla_afectada)
        VALUES(SUSER_NAME(), GETDATE(), 'INSERT', 'Pago');

        COMMIT TRANSACTION;

    END TRY

    BEGIN CATCH

        ROLLBACK TRANSACTION;

        PRINT ERROR_MESSAGE();

    END CATCH

END;

--SIMULACION DE DIRTY READ
--EN OTRA SESION TENEMOS 
--BEGIN TRANSACTION;

--UPDATE Usuario
--SET contraseña = 5000
--WHERE id_rol = 1;
--EN ESTA SESION USAREMOS

SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED;

SELECT * FROM Usuario
WHERE id_rol = 1;

--SIMULACION DE LECTURA NO REPETIBLE 
--EN LA OTRA SESION TENEMOS 
--SET TRANSACTION ISOLATION LEVEL READ COMMITTED;

--BEGIN TRANSACTION;

--SELECT contrasena
--FROM Usuario
--WHERE id_rol = 1;

--EN ESTE SESION USAREMOS
UPDATE Usuario
SET contrasena = 9999
WHERE id_rol = 1;

COMMIT;
--indices clustered que ya teniamos con nuestras tablas con pk
EXEC sp_helpindex 'Cliente';
EXEC sp_helpindex 'Producto';
EXEC sp_helpindex 'Proveedor';
EXEC sp_helpindex 'Categoria';
EXEC sp_helpindex 'Usuario';

--indices no-clustered
CREATE NONCLUSTERED INDEX IX_Cliente_Nombre
ON Cliente(nombre);
CREATE NONCLUSTERED INDEX IX_Cliente_Correo
ON Cliente(correo);
CREATE NONCLUSTERED INDEX IX_Producto_Id
ON Producto(id_producto);
CREATE NONCLUSTERED INDEX IX_Producto_Precio
ON Producto(precio);
CREATE NONCLUSTERED INDEX IX_Producto_Nombre
ON Producto(nombre_producto);
CREATE NONCLUSTERED INDEX IX_Proveedor_Nombre
ON Proveedor(nombre);
CREATE NONCLUSTERED INDEX IX_Categoria_Nombre
ON Categoria(nombre_categoria);

--compuestos
CREATE NONCLUSTERED INDEX IX_Producto_NombrePrecio
ON Producto(nombre_producto, precio);
CREATE NONCLUSTERED INDEX IX_Cliente_NombreCorreo
ON Cliente(nombre, correo);

--antes y despues de indice
SELECT *
FROM Categoria
WHERE nombre_categoria = 'Laptops';
SET STATISTICS TIME ON;
SET STATISTICS IO ON;

--DESPUES
CREATE NONCLUSTERED INDEX IX_Categoria_Nombre_Test
ON Categoria(nombre_categoria);

SELECT *
FROM Categoria
WHERE nombre_categoria = 'Laptops';

--CREEACION DE LOGINS
CREATE LOGIN admin_umg
WITH PASSWORD = 'Admin123*';    
CREATE LOGIN operador_umg
WITH PASSWORD = 'Operador123*';
CREATE LOGIN consulta_umg
WITH PASSWORD = 'Consulta123*';

--USUARIOWS
CREATE USER usuario_admin
FOR LOGIN admin_umg;
GO

CREATE USER usuario_operador
FOR LOGIN operador_umg;
GO

CREATE USER usuario_consulta
FOR LOGIN consulta_umg;
GO

--CREQACION DE ROLES
CREATE ROLE rol_admin;
GO

CREATE ROLE rol_operador;
GO

CREATE ROLE rol_consulta;
GO
--ASIGNAR USUARIOS A ROLES
ALTER ROLE rol_admin
ADD MEMBER usuario_admin;
GO

ALTER ROLE rol_operador
ADD MEMBER usuario_operador;
GO

ALTER ROLE rol_consulta
ADD MEMBER usuario_consulta;
GO

--ASIGNAR PERMISOS
GRANT CONTROL ON DATABASE::UMGSTORE
TO rol_admin;
GRANT SELECT
ON Cliente
TO rol_operador;

GRANT SELECT
ON Producto
TO rol_operador;
GRANT INSERT
ON Cliente
TO rol_operador;

GRANT INSERT
ON Producto
TO rol_operador;


GRANT SELECT
ON Cliente
TO rol_consulta;

GRANT SELECT
ON Producto
TO rol_consulta;

GRANT SELECT
ON Proveedor
TO rol_consulta;
--VERIFICAR PERMISOS
SELECT
    dp.name AS Usuario,
    rp.name AS Rol
FROM sys.database_role_members drm
JOIN sys.database_principals rp
    ON drm.role_principal_id = rp.principal_id
JOIN sys.database_principals dp
    ON drm.member_principal_id = dp.principal_id;

    --VER PERMISOS
    SELECT *
FROM fn_my_permissions(NULL, 'DATABASE');

--SEGURIDAD LOGICA
--DENEGAR ACCESOS A OPERADOR
DENY SELECT
ON Cliente
TO rol_operador;

DENY SELECT
ON Producto
TO rol_operador;

DENY SELECT
ON Proveedor
TO rol_operador;

DENY SELECT
ON Categoria
TO rol_operador;

DENY INSERT
ON Cliente
TO rol_operador;

DENY INSERT
ON Producto
TO rol_operador;

DENY UPDATE
ON Cliente
TO rol_operador;

DENY UPDATE
ON Producto
TO rol_operador;
DENY DELETE
ON Cliente
TO rol_operador;

DENY DELETE
ON Producto
TO rol_operador;

--PERMITIR SOLO SP


GRANT EXECUTE
ON sp_RegistrarVenta
TO rol_operador;

--triggers de auditoria 
GO
CREATE TRIGGER trg_Auditoria_Cliente
ON Cliente
AFTER INSERT, UPDATE, DELETE
AS
BEGIN

    SET NOCOUNT ON;

    DECLARE @Operacion VARCHAR(50);

    IF EXISTS (SELECT * FROM inserted)
       AND EXISTS (SELECT * FROM deleted)
        SET @Operacion = 'UPDATE';

    ELSE IF EXISTS (SELECT * FROM inserted)
        SET @Operacion = 'INSERT';

    ELSE IF EXISTS (SELECT * FROM deleted)
        SET @Operacion = 'DELETE';

    INSERT INTO Auditoria
    (
        usuario_bd,
        fecha,
        operacion,
        tabla_afectada
    )
    VALUES
    (
        SYSTEM_USER,
        GETDATE(),
        @Operacion,
        'Cliente'
    );

END;
GO

CREATE TRIGGER trg_Auditoria_Producto
ON Producto
AFTER INSERT, UPDATE, DELETE
AS
BEGIN

    SET NOCOUNT ON;

    DECLARE @Operacion VARCHAR(50);

    IF EXISTS (SELECT * FROM inserted)
       AND EXISTS (SELECT * FROM deleted)
        SET @Operacion = 'UPDATE';

    ELSE IF EXISTS (SELECT * FROM inserted)
        SET @Operacion = 'INSERT';

    ELSE IF EXISTS (SELECT * FROM deleted)
        SET @Operacion = 'DELETE';

    INSERT INTO Auditoria
    (
        usuario_bd,
        fecha,
        operacion,
        tabla_afectada
    )
    VALUES
    (
        SYSTEM_USER,
        GETDATE(),
        @Operacion,
        'Producto'
    );

END;
GO

--PRUEBAS DE TRIGGERS
INSERT INTO Cliente(nombre, telefono, correo, direccion)
VALUES
(
    'Juan Perez',
    '5555-5555',
    'juan@gmail.com',
    'Zona 1'
);

UPDATE Cliente
SET telefono = '9999-9999'
WHERE id_cliente = 1;

DELETE FROM Cliente
WHERE id_cliente = 2;

SELECT * FROM Auditoria;

--BACKUPS
--FULL
BACKUP DATABASE UMGSTORE
TO DISK = 'C:\BackupsSQL\UMGSTORE_FULL.bak'
WITH FORMAT,
MEDIANAME = 'BackupFull',
NAME = 'Backup Completo UMGSTORE';

--DIFFERENCIAL
BACKUP DATABASE UMGSTORE
TO DISK = 'C:\BackupsSQL\UMGSTORE_DIFF.bak'
WITH DIFFERENTIAL;

--LOGS
BACKUP DATABASE UMGSTORE
TO DISK = 'C:\BackupsSQL\UMGSTORE_DIFF.bak'
WITH DIFFERENTIAL;

SELECT name, recovery_model_desc
FROM sys.databases
WHERE name = 'UMGSTORE';
--vista analitica group by
CREATE VIEW vw_AnalisisVentas1
AS
SELECT
    c.nombre AS Cliente,
    COUNT(v.id_venta) AS TotalVentas,
    SUM(dv.cantidad) AS ProductosVendidos,
    SUM(dv.subtotal) AS TotalFacturado
FROM Venta v
INNER JOIN Cliente c
    ON v.id_cliente = c.id_cliente
INNER JOIN Detalle_Venta dv
    ON v.id_venta = dv.id_venta
GROUP BY c.nombre;
GO

SELECT * FROM vw_AnalisisVentas1;