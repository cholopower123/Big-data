USE FerreteriaOLAP;
GO

DELETE FROM HechoVentas;
DELETE FROM DimTiempo;
DELETE FROM DimProveedor;
DELETE FROM DimEmpleado;
DELETE FROM DimProducto;
GO

DBCC CHECKIDENT ('HechoVentas', RESEED, 0);
DBCC CHECKIDENT ('DimTiempo', RESEED, 0);
DBCC CHECKIDENT ('DimProveedor', RESEED, 0);
DBCC CHECKIDENT ('DimEmpleado', RESEED, 0);
DBCC CHECKIDENT ('DimProducto', RESEED, 0);
GO


INSERT INTO DimProducto
(
    CodigoProducto,
    NombreProducto,
    Categoria,
    Marca,
    PrecioVenta
)
SELECT
    P.CodigoProducto,
    P.NombreProducto,
    ISNULL(P.Categoria, 'Sin categoría') AS Categoria,
    ISNULL(P.Marca, 'Sin marca') AS Marca,
    P.PrecioVenta
FROM FerreteriaInventario.dbo.Productos P;
GO

INSERT INTO DimProveedor
(
    CodigoProveedor,
    RazonSocial,
    Direccion
)
SELECT
    PR.CodigoProveedor,
    PR.RazonSocial,
    PR.Direccion
FROM FerreteriaInventario.dbo.Proveedores PR;
GO

INSERT INTO DimEmpleado
(
    CodigoEmpleado,
    Nombres,
    Apellidos,
    Genero,
    Direccion
)
SELECT
    E.CodigoEmpleado,
    E.Nombres,
    E.Apellidos,
    ISNULL(E.Genero, 'N/E') AS Genero,
    ISNULL(E.Direccion, 'Sin dirección') AS Direccion
FROM FerreteriaInventario.dbo.Empleados E;
GO

INSERT INTO DimTiempo
(
    Fecha,
    Dia,
    Mes,
    Año,
    NombreMes
)
SELECT DISTINCT
    CONVERT(DATE, V.FechaVenta) AS Fecha,
    DAY(V.FechaVenta) AS Dia,
    MONTH(V.FechaVenta) AS Mes,
    YEAR(V.FechaVenta) AS Año,
    CASE MONTH(V.FechaVenta)
        WHEN 1 THEN 'Enero'
        WHEN 2 THEN 'Febrero'
        WHEN 3 THEN 'Marzo'
        WHEN 4 THEN 'Abril'
        WHEN 5 THEN 'Mayo'
        WHEN 6 THEN 'Junio'
        WHEN 7 THEN 'Julio'
        WHEN 8 THEN 'Agosto'
        WHEN 9 THEN 'Septiembre'
        WHEN 10 THEN 'Octubre'
        WHEN 11 THEN 'Noviembre'
        WHEN 12 THEN 'Diciembre'
    END AS NombreMes
FROM FerreteriaInventario.dbo.Ventas V;
GO

INSERT INTO HechoVentas
(
    IdProducto,
    IdEmpleado,
    IdProveedor,
    IdTiempo,
    CantidadVendida,
    PrecioUnitario,
    TotalVenta
)
SELECT
    DP.IdProducto,
    DE.IdEmpleado,
    DPR.IdProveedor,
    DT.IdTiempo,
    DV.Cantidad AS CantidadVendida,
    DV.PrecioUnitario,
    DV.SubTotal AS TotalVenta
FROM FerreteriaInventario.dbo.DetalleVenta DV
INNER JOIN FerreteriaInventario.dbo.Ventas V
    ON DV.CodigoVenta = V.CodigoVenta
INNER JOIN FerreteriaInventario.dbo.Productos P
    ON DV.CodigoProducto = P.CodigoProducto
INNER JOIN DimProducto DP
    ON P.CodigoProducto = DP.CodigoProducto
LEFT JOIN DimProveedor DPR
    ON P.CodigoProveedor = DPR.CodigoProveedor
LEFT JOIN DimEmpleado DE
    ON V.CodigoUsuario = DE.CodigoEmpleado
INNER JOIN DimTiempo DT
    ON CONVERT(DATE, V.FechaVenta) = DT.Fecha;
GO

SELECT 'DimProducto' AS Tabla, COUNT(*) AS Registros FROM DimProducto
UNION ALL
SELECT 'DimProveedor', COUNT(*) FROM DimProveedor
UNION ALL
SELECT 'DimEmpleado', COUNT(*) FROM DimEmpleado
UNION ALL
SELECT 'DimTiempo', COUNT(*) FROM DimTiempo
UNION ALL
SELECT 'HechoVentas', COUNT(*) FROM HechoVentas;
GO

SELECT
    P.NombreProducto,
    SUM(H.CantidadVendida) AS CantidadVendida,
    SUM(H.TotalVenta) AS TotalVendido
FROM HechoVentas H
INNER JOIN DimProducto P
    ON H.IdProducto = P.IdProducto
GROUP BY P.NombreProducto
ORDER BY TotalVendido DESC;
GO

SELECT
    P.Categoria,
    SUM(H.CantidadVendida) AS CantidadVendida,
    SUM(H.TotalVenta) AS TotalVendido
FROM HechoVentas H
INNER JOIN DimProducto P
    ON H.IdProducto = P.IdProducto
GROUP BY P.Categoria
ORDER BY TotalVendido DESC;
GO

SELECT
    T.Año,
    T.NombreMes,
    SUM(H.TotalVenta) AS TotalVendido
FROM HechoVentas H
INNER JOIN DimTiempo T
    ON H.IdTiempo = T.IdTiempo
GROUP BY T.Año, T.Mes, T.NombreMes
ORDER BY T.Año, T.Mes;
GO

SELECT
    PR.RazonSocial,
    SUM(H.TotalVenta) AS TotalVendido
FROM HechoVentas H
LEFT JOIN DimProveedor PR
    ON H.IdProveedor = PR.IdProveedor
GROUP BY PR.RazonSocial
ORDER BY TotalVendido DESC;
GO
