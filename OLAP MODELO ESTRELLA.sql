
CREATE DATABASE FerreteriaOLAP;
GO

USE FerreteriaOLAP;
GO

CREATE TABLE DimProducto (

    IdProducto INT PRIMARY KEY IDENTITY(1,1),

    CodigoProducto INT,
    NombreProducto NVARCHAR(100),
    Categoria NVARCHAR(50),
    Marca NVARCHAR(50),

    PrecioVenta DECIMAL(10,2)

);

CREATE TABLE DimEmpleado (

    IdEmpleado INT PRIMARY KEY IDENTITY(1,1),

    CodigoEmpleado INT,

    Nombres NVARCHAR(50),
    Apellidos NVARCHAR(50),

    Genero VARCHAR(10),

    Direccion NVARCHAR(100)

);

CREATE TABLE DimProveedor (

    IdProveedor INT PRIMARY KEY IDENTITY(1,1),

    CodigoProveedor INT,

    RazonSocial NVARCHAR(100),

    Direccion NVARCHAR(100)

);

CREATE TABLE DimTiempo (

    IdTiempo INT PRIMARY KEY IDENTITY(1,1),

    Fecha DATE,

    Dia INT,
    Mes INT,
    Año INT,

    NombreMes NVARCHAR(20)

);

CREATE TABLE HechoVentas (

    IdVenta INT PRIMARY KEY IDENTITY(1,1),

    IdProducto INT,
    IdEmpleado INT,
    IdProveedor INT,
    IdTiempo INT,

    CantidadVendida INT,

    PrecioUnitario DECIMAL(10,2),

    TotalVenta DECIMAL(10,2)

);

INSERT INTO DimProducto
(CodigoProducto, NombreProducto, Categoria, Marca, PrecioVenta)
VALUES

(1, 'Martillo', 'Herramientas', 'Truper', 25.50),

(2, 'Taladro', 'Herramientas eléctricas', 'Bosch', 180.00),

(3, 'Pintura Blanca', 'Pinturas', 'CPP', 45.00),

(4, 'Cemento Sol', 'Construcción', 'Sol', 31.50),

(5, 'Cable Eléctrico', 'Electricidad', 'Indeco', 55.00);

INSERT INTO DimEmpleado
(CodigoEmpleado, Nombres, Apellidos, Genero, Direccion)
VALUES

(1, 'Josue Daniel', 'Nascimento Rivera', 'M', 'Lima'),

(2, 'Larry', 'Henostroza Flores', 'M', 'Lima'),

(3, 'Maria Fernanda', 'Lopez Diaz', 'F', 'Cusco');

INSERT INTO DimProveedor
(CodigoProveedor, RazonSocial, Direccion)
VALUES

(1, 'Distribuidora Perú SAC', 'Lima'),

(2, 'FerreTools SAC', 'Arequipa'),

(3, 'Importadora Andina SAC', 'Cusco');

INSERT INTO DimTiempo
(Fecha, Dia, Mes, Año, NombreMes)
VALUES

('2026-05-01', 1, 5, 2026, 'Mayo'),

('2026-05-02', 2, 5, 2026, 'Mayo'),

('2026-05-03', 3, 5, 2026, 'Mayo'),

('2026-05-04', 4, 5, 2026, 'Mayo'),

('2026-05-05', 5, 5, 2026, 'Mayo');

INSERT INTO HechoVentas
(IdProducto, IdEmpleado, IdProveedor, IdTiempo,
CantidadVendida, PrecioUnitario, TotalVenta)
VALUES

(1, 1, 1, 1, 2, 25.50, 51.00),

(2, 2, 2, 2, 1, 180.00, 180.00),

(3, 1, 1, 3, 3, 45.00, 135.00),

(4, 3, 3, 4, 5, 31.50, 157.50),

(5, 2, 2, 5, 2, 55.00, 110.00);

SELECT
    P.NombreProducto,
    SUM(H.TotalVenta) AS TotalVendido

FROM HechoVentas H

INNER JOIN DimProducto P
ON H.IdProducto = P.IdProducto

GROUP BY P.NombreProducto;

SELECT
    T.NombreMes,
    SUM(H.TotalVenta) AS TotalVentas

FROM HechoVentas H

INNER JOIN DimTiempo T
ON H.IdTiempo = T.IdTiempo

GROUP BY T.NombreMes;

SELECT
    E.Nombres,
    E.Apellidos,
    SUM(H.TotalVenta) AS TotalVentas

FROM HechoVentas H

INNER JOIN DimEmpleado E
ON H.IdEmpleado = E.IdEmpleado

GROUP BY E.Nombres, E.Apellidos;


SELECT TOP 1
    P.NombreProducto,
    SUM(H.CantidadVendida) AS TotalCantidad

FROM HechoVentas H

INNER JOIN DimProducto P
ON H.IdProducto = P.IdProducto

GROUP BY P.NombreProducto

ORDER BY TotalCantidad DESC;

ALTER TABLE HechoVentas
ADD CONSTRAINT FK_Producto
FOREIGN KEY (IdProducto)
REFERENCES DimProducto(IdProducto);

ALTER TABLE HechoVentas
ADD CONSTRAINT FK_Empleado
FOREIGN KEY (IdEmpleado)
REFERENCES DimEmpleado(IdEmpleado);

ALTER TABLE HechoVentas
ADD CONSTRAINT FK_Proveedor
FOREIGN KEY (IdProveedor)
REFERENCES DimProveedor(IdProveedor);

ALTER TABLE HechoVentas
ADD CONSTRAINT FK_Tiempo
FOREIGN KEY (IdTiempo)
REFERENCES DimTiempo(IdTiempo);