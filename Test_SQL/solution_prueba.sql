/****** 1. Inserte el tipo de servicio OCIO. ******/

INSERT INTO dbo.Tipo_Servicio (NombreServicio)
VALUES ('OCIO');

/****** 2. Realice una reserva de la habitación 101 para el cliente 12345 para las noches del 2 al 4 de julio de 2020.  ******/

INSERT INTO dbo.Reserva_Habitacion (CodCliente, CodHabitacion, FechaEntrada, FechaSalida, Iva) 
VALUES (12345, 101, '2020-07-02', '2020-07-04', 0.08);

/****** 3. Actualice el teléfono del cliente 12345. Su nuevo número es 123456789.  ******/

UPDATE dbo.Clientes 
SET Telefono = 123456789
WHERE Identificacion = 12345

/****** 4. Actualice el precio de los servicios incrementándolos en un 2%.  ******/

UPDATE dbo.Servicios
SET Precio = Precio * 1.02

/****** 5. Crear una vista que devuelva los clientes cuyo apellido incluya la sílaba “Pe” ordenados por su 
identificador. ******/

ALTER VIEW Cliente_Pe AS
SELECT Nombre, Apellido1, Apellido2, Identificacion
FROM dbo.Clientes
WHERE Apellido1 LIKE '%Pe%' OR Apellido2 LIKE '%Pe%'

SELECT * 
FROM Cliente_Pe
ORDER BY Identificacion;

/****** 6. Crea una vista que devuelva los clientes, ordenados por su primer apellido, que tengan alguna observación 
anotada. ******/

CREATE VIEW Cliente_Observacion AS
SELECT Nombre, Apellido1, Apellido2, Observaciones
FROM dbo.Clientes
WHERE Observaciones IS NOT NULL

SELECT * 
FROM Cliente_Observacion
ORDER BY Apellido1;

/****** 7. Crea una vista que devuelva los servicios cuyo precio supere los 5 USD ordenados por su código de 
servicio. ******/

CREATE VIEW Servicio_5usd AS
SELECT CodServicios, CodTipoServicio, Descripcion, Precio
FROM dbo.Servicios
WHERE Precio > 5

SELECT * 
FROM Servicio_5usd;

/****** 8. Cree una consulta que devuelva las habitaciones reservadas para el día 16 de febrero de 2019. ******/

SELECT * 
FROM dbo.Reserva_Habitacion
WHERE FechaEntrada = '2019-02-16';

/****** 9. Cree una consulta que devuelva el precio del servicio más caro y del más barato ******/

SELECT
    p.Pais AS Pais,
    c.Nombre,
    c.Apellido1,
    c.Apellido2,
    c.Telefono,
    rh.CodReserva,
    h.NumHabitacion AS NumeroHabitacion,
    rh.FechaEntrada,
    rh.FechaSalida,
    ph.Precio + (ph.Precio * rh.Iva) AS PrecioHabitacionConIva,
    ts.NombreServicio AS ServicioConsumido,
    SUM(ISNULL(g.Cantidad * g.Precio, 0)) AS TotalGastos,
    ph.Precio + (ph.Precio * rh.Iva) + SUM(ISNULL(g.Cantidad * g.Precio, 0)) AS TotalPagar,
    th.Categoria AS TipoHabitacion,
    t.Tipo AS Temporada
FROM dbo.Reserva_Habitacion rh
INNER JOIN dbo.Clientes c
    ON rh.CodCliente = c.CodClientes
INNER JOIN dbo.Paises p
    ON c.CodPais = p.CodPais
INNER JOIN dbo.Habitaciones h
    ON rh.CodHabitacion = h.NumHabitacion
INNER JOIN dbo.Tipo_Habitacion th
    ON h.CodCategoria = th.Categoria
INNER JOIN dbo.Temporada t
    ON rh.FechaEntrada BETWEEN t.FechaInicio AND t.FechaFin
INNER JOIN dbo.Precio_Habitacion ph
    ON ph.Tipo_Habitacion = th.Categoria
   AND ph.CodTemporada = t.CodTemporada
LEFT JOIN dbo.Gastos g
    ON rh.CodReserva = g.CodReserva
LEFT JOIN dbo.Servicios s
    ON g.CodServicios = s.CodServicios
LEFT JOIN dbo.Tipo_Servicio ts
    ON s.CodTipoServicio = ts.CodTipoServicio
GROUP BY
    p.Pais,
    c.Nombre,
    c.Apellido1,
    c.Apellido2,
    c.Telefono,
    rh.CodReserva,
    h.NumHabitacion,
    rh.FechaEntrada,
    rh.FechaSalida,
    ph.Precio,
    rh.Iva,
    ts.NombreServicio,
    th.Categoria,
    t.Tipo;

/******  11. Realice una consulta en donde se liste el último servicio solicitado por los clientes (tabla de referencia es 
gastos con la columna Fecha y la tabla servicios). Restricción: Se debe realizar la consulta sin hacer uso del 
filtro fecha y la clausula TOP Ejm: where Fecha:’xxxxx’ o select top 1. El resultado de la consulta deber el 
siguiente:  ******/
 
 /****** 11. Liste el último servicio solicitado por los clientes. ******/

SELECT
    s.Descripcion AS Servicio,
    g.Fecha
FROM dbo.Gastos g
INNER JOIN dbo.Servicios s
    ON g.CodServicios = s.CodServicios
WHERE g.Fecha = (
    SELECT MAX(Fecha)
    FROM dbo.Gastos
);
 
  
