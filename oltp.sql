CREATE DATABASE FerreteriaInventario;
GO

USE FerreteriaInventario;
GO

CREATE TABLE Proveedores (
    CodigoProveedor INT PRIMARY KEY IDENTITY(1,1),
    RazonSocial NVARCHAR(100) NOT NULL,
    RUC VARCHAR(15) NOT NULL,
    Direccion NVARCHAR(120) NOT NULL,
    Telefono VARCHAR(20),
    Correo VARCHAR(80)
);

CREATE TABLE Productos (
    CodigoProducto INT PRIMARY KEY IDENTITY(1,1),
    NombreProducto NVARCHAR(100) NOT NULL,
    Descripcion NVARCHAR(200),
    Categoria NVARCHAR(50),
    Marca NVARCHAR(50),
    PrecioVenta DECIMAL(10,2) NOT NULL,
    StockActual INT,
    StockMinimo INT,
    CodigoProveedor INT
);

CREATE TABLE Usuarios (
    CodigoUsuario INT PRIMARY KEY IDENTITY(1,1),
    NombreUsuario NVARCHAR(50) NOT NULL,
    Clave NVARCHAR(100) NOT NULL,
    Rol NVARCHAR(30) NOT NULL
);

CREATE TABLE Empleados (
    CodigoEmpleado INT PRIMARY KEY IDENTITY(1,1),
    Nombres NVARCHAR(50) NOT NULL,
    Apellidos NVARCHAR(50) NOT NULL,
    Genero VARCHAR(10),
    Direccion NVARCHAR(100),
    Telefono NVARCHAR(20),
    FechaInicio DATETIME,
    FechaNacimiento DATETIME
);

CREATE TABLE Ventas (
    CodigoVenta INT PRIMARY KEY IDENTITY(1,1),
    FechaVenta DATETIME DEFAULT GETDATE(),
    TotalVenta DECIMAL(10,2) NOT NULL,
    CodigoUsuario INT NOT NULL,
    TipoComprobante NVARCHAR(20)
);

CREATE TABLE DetalleVenta (
    CodigoDetalle INT PRIMARY KEY IDENTITY(1,1),
    CodigoVenta INT NOT NULL,
    CodigoProducto INT NOT NULL,
    Cantidad INT NOT NULL,
    PrecioUnitario DECIMAL(10,2) NOT NULL,
    SubTotal DECIMAL(10,2) NOT NULL
);

INSERT INTO Proveedores
(RazonSocial, RUC, Direccion, Telefono, Correo)
VALUES
('Distribuidora Perú SAC', '20123456789', 'Lima', '987654321', 'ventas@distribuidora.com'),
('FerreTools SAC', '20987654321', 'Arequipa', '912345678', 'contacto@ferretools.com');

INSERT INTO Productos
(NombreProducto, Descripcion, Categoria, Marca, PrecioVenta, StockActual, StockMinimo, CodigoProveedor)
VALUES
('Martillo', 'Martillo de acero', 'Herramientas', 'Truper', 25.50, 50, 10, 1),
('Taladro', 'Taladro eléctrico', 'Herramientas eléctricas', 'Bosch', 180.00, 20, 5, 2),
('Pintura Blanca', 'Galón de pintura blanca', 'Pinturas', 'CPP', 45.00, 30, 8, 1);

INSERT INTO Usuarios
(NombreUsuario, Clave, Rol)
VALUES
('admin', 'admin123', 'Administrador'),
('vendedor1', 'ventas123', 'Vendedor'),
('almacen1', 'almacen123', 'Almacen');

INSERT INTO Empleados
(Nombres, Apellidos, Genero, Direccion, Telefono, FechaInicio, FechaNacimiento)
VALUES
('Josue Daniel', 'Nascimento Rivera', 'M', 'Lima', '999888777', GETDATE(), '2004-05-15'),
('Larry', 'Henostroza Flores', 'M', 'Lima', '988777666', GETDATE(), '2003-08-20');

INSERT INTO Ventas
(TotalVenta, CodigoUsuario, TipoComprobante)
VALUES
(361.00, 1, 'Boleta');

INSERT INTO DetalleVenta
(CodigoVenta, CodigoProducto, Cantidad, PrecioUnitario, SubTotal)
VALUES
(1, 2, 2, 180.50, 361.00);

INSERT INTO Productos
(NombreProducto, Descripcion, Categoria, Marca, PrecioVenta, StockActual, StockMinimo, CodigoProveedor)
VALUES
('Cemento', 'Bolsa de cemento 50kg', 'Construcción', 'Sol', 32.50, 100, 20, 1);

UPDATE Productos
SET PrecioVenta = 35.00,
    StockActual = 120
WHERE CodigoProducto = 1;

DELETE FROM Productos
WHERE CodigoProducto = 3;


SELECT *
FROM Productos
WHERE Categoria = 'Herramientas';



SELECT *
FROM Productos
WHERE StockActual <= StockMinimo;

CREATE OR ALTER TRIGGER TR_ActualizarStockVenta
ON DetalleVenta
AFTER INSERT
AS
BEGIN

    UPDATE Productos
    SET StockActual = StockActual - I.Cantidad
    FROM Productos P
    INNER JOIN inserted I
        ON P.CodigoProducto = I.CodigoProducto;

END;
GO

CREATE OR ALTER TRIGGER TR_VerificarStock
ON DetalleVenta
INSTEAD OF INSERT
AS
BEGIN

    DECLARE @StockActual INT;
    DECLARE @CantidadVendida INT;
    DECLARE @CodigoProducto INT;

    SELECT
        @CodigoProducto = CodigoProducto,
        @CantidadVendida = Cantidad
    FROM inserted;

    SELECT
        @StockActual = StockActual
    FROM Productos
    WHERE CodigoProducto = @CodigoProducto;

    IF(@CantidadVendida > @StockActual)
    BEGIN
        PRINT 'No hay suficiente stock disponible';
    END

    ELSE
    BEGIN

        INSERT INTO DetalleVenta
        (CodigoVenta, CodigoProducto, Cantidad, PrecioUnitario, SubTotal)
        SELECT
            CodigoVenta,
            CodigoProducto,
            Cantidad,
            PrecioUnitario,
            SubTotal
        FROM inserted;

    END

END;
GO

INSERT INTO Proveedores
(RazonSocial, RUC, Direccion, Telefono, Correo)
VALUES
('Importadora Andina SAC', '20456789123', 'Cusco', '955444333', 'ventas@andina.com'),
('MegaFerreteria Perú', '20789123456', 'Trujillo', '966555444', 'contacto@megaferreteria.com'),
('Distribuciones El Constructor', '20555111222', 'Piura', '977888999', 'info@constructor.com');

INSERT INTO Productos
(NombreProducto, Descripcion, Categoria, Marca, PrecioVenta, StockActual, StockMinimo, CodigoProveedor)
VALUES
('Cemento Sol', 'Bolsa de cemento 42.5kg', 'Construcción', 'Sol', 31.50, 120, 25, 3),

('Destornillador', 'Destornillador estrella', 'Herramientas', 'Stanley', 12.00, 60, 15, 2),

('Llave Inglesa', 'Llave ajustable de acero', 'Herramientas', 'Truper', 28.00, 45, 10, 1),

('Cable Eléctrico', 'Cable eléctrico 10 metros', 'Electricidad', 'Indeco', 55.00, 70, 20, 4),

('Foco LED', 'Foco LED 18W', 'Iluminación', 'Philips', 14.50, 100, 30, 4),

('Tubo PVC', 'Tubo PVC 2 pulgadas', 'Plomería', 'Pavco', 18.00, 90, 20, 5),

('Brocha', 'Brocha profesional 4 pulgadas', 'Pinturas', 'CPP', 9.50, 75, 15, 1),

('Sierra Circular', 'Sierra circular industrial', 'Herramientas eléctricas', 'Makita', 450.00, 10, 3, 2),

('Taladro Percutor', 'Taladro percutor profesional', 'Herramientas eléctricas', 'DeWalt', 520.00, 8, 2, 2),

('Cinta Aislante', 'Cinta aislante negra', 'Electricidad', '3M', 6.00, 200, 50, 4);

INSERT INTO Usuarios
(NombreUsuario, Clave, Rol)
VALUES
('supervisor1', 'super123', 'Supervisor'),
('cajero1', 'caja123', 'Cajero'),
('gerente1', 'gerente123', 'Gerente');

INSERT INTO Empleados
(Nombres, Apellidos, Genero, Direccion, Telefono, FechaInicio, FechaNacimiento)
VALUES
('Carlos Alberto', 'Ramirez Torres', 'M', 'Arequipa', '955111222', GETDATE(), '1998-03-12'),

('Maria Fernanda', 'Lopez Diaz', 'F', 'Cusco', '966222333', GETDATE(), '2000-07-25'),

('Luis Enrique', 'Soto Perez', 'M', 'Piura', '977333444', GETDATE(), '1997-11-05'),

('Andrea Lucia', 'Martinez Cruz', 'F', 'Lima', '988444555', GETDATE(), '2001-01-18'),

('Jorge Luis', 'Vargas Salas', 'M', 'Tacna', '977555666', GETDATE(), '1995-09-30');

INSERT INTO Ventas
(TotalVenta, CodigoUsuario, TipoComprobante)
VALUES
(63.00, 2, 'Factura'),

(145.00, 3, 'Boleta'),

(478.00, 1, 'Factura'),

(95.00, 4, 'Boleta'),

(540.00, 5, 'Factura');

INSERT INTO DetalleVenta
(CodigoVenta, CodigoProducto, Cantidad, PrecioUnitario, SubTotal)
VALUES
(2, 4, 2, 31.50, 63.00),

(3, 7, 1, 55.00, 55.00),
(3, 8, 5, 18.00, 90.00),

(4, 10, 1, 450.00, 450.00),
(4, 9, 2, 14.00, 28.00),

(5, 5, 5, 19.00, 95.00),

(6, 11, 1, 520.00, 520.00),
(6, 12, 2, 10.00, 20.00);

SELECT *
FROM Productos
WHERE PrecioVenta > 100;

SELECT *
FROM Productos
WHERE StockActual <= StockMinimo;

INSERT INTO DetalleVenta
(CodigoVenta, CodigoProducto, Cantidad, PrecioUnitario, SubTotal)
VALUES
(1, 1, 2, 25.50, 51.00);

SELECT * FROM Proveedores;

SELECT * FROM Productos;

SELECT * FROM Usuarios;

SELECT * FROM Empleados;

SELECT * FROM Ventas;

SELECT * FROM DetalleVenta;