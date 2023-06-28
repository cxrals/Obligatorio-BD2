use DBCARGAS;
SET DATEFORMAT DMY;

-- SE PIDE 5
-------------------------------------------------------------------------------------------------------------
-------------------------------------------------------------------------------------------------------------
--a
GO
CREATE PROCEDURE buscarAvion @fechaInicio date, @fechaFin date, @idDelAvion char(10) OUTPUT, @nombreDelCliente varchar(30) OUTPUT
AS
BEGIN
	SELECT @idDelAvion = A.ii
	FROM (SELECT TOP 1 CARGA.avionID ii, SUM(CARGA.cargaKilos) totalKilosCargadosPorAvion
		FROM CARGA
		WHERE CARGA.cargaFch BETWEEN @fechaInicio AND @fechaFin
		GROUP BY CARGA.avionID
		ORDER BY totalKilosCargadosPorAvion DESC
	) A

	SELECT @nombreDelCliente = C.ii
	FROM (SELECT TOP 1 CLIENTE.cliNom ii, SUM(CARGA.cargaKilos) totalKilosCargadosPorCliente
		FROM CARGA
		JOIN CLIENTE ON CLIENTE.cliID = CARGA.cliID
		WHERE CARGA.cargaFch BETWEEN @fechaInicio AND @fechaFin
		GROUP BY CLIENTE.cliNom
		ORDER BY totalKilosCargadosPorCliente DESC
	) C
END
GO
Declare @fi date
Set @fi = '01-01-2022'
Declare @ff date
Set @ff = '01-09-2023'
Declare @resultadoAvion char(10)
Declare @resultadoCliente varchar(30)
EXEC buscarAvion @fi, @ff, @resultadoAvion OUTPUT,  @resultadoCliente OUTPUT
PRINT 'Avión que cargó más kilos: ' + @resultadoAvion + ' Cliente que cargó más kilos: ' + @resultadoCliente
-------------------------------------------------------------------------------------------------------------
-------------------------------------------------------------------------------------------------------------
--b
GO
CREATE PROCEDURE buscarContenedores(@largo decimal, @ancho decimal, @alto decimal) 
AS
BEGIN
	 IF EXISTS(SELECT Dcontainer.dContID FROM Dcontainer WHERE Dcontainer.dContLargo = @largo AND Dcontainer.dContAncho = @ancho AND Dcontainer.dcontAlto = @alto)
	 BEGIN
		SELECT Dcontainer.dContID,Dcontainer.dContLargo,Dcontainer.dContAncho,Dcontainer.dcontAlto
		FROM Dcontainer 
		WHERE Dcontainer.dContLargo = @largo 
		AND Dcontainer.dContAncho = @ancho 
		AND Dcontainer.dcontAlto = @alto
	 END
	 ELSE
	 BEGIN
		PRINT 'No existe ningun contenedor con esas medidas'
	 END
END
GO
Declare @largo decimal
Set @largo = 2
Declare @ancho decimal
Set @ancho = 2
Declare @alto decimal
Set @alto = 2
--Declare @resultado TABLE(col1 char(3))
EXEC buscarContenedores @largo, @ancho, @alto
-------------------------------------------------------------------------------------------------------------
-------------------------------------------------------------------------------------------------------------
--c
GO
CREATE FUNCTION calcularKilosDeCarga(@codIATA char(3)) RETURNS int
AS
BEGIN
	Declare @resultado int;
	SELECT @resultado = SUM(CARGA.cargaKilos) FROM CARGA WHERE CARGA.aeroDestino = @codIATA;
	RETURN @resultado;
END
GO
Declare @codAeropuerto char(3)
Set @codAeropuerto = 'UYU'
Declare @res int
SET @res = dbo.calcularKilosDeCarga(@codAeropuerto)
PRINT 'Kilos de carga: ' + convert(varchar(10), @res)
GO
-------------------------------------------------------------------------------------------------------------
-------------------------------------------------------------------------------------------------------------
--d
--Hacer una función que, para un cliente dado, retorne la cantidad total de kilos transportados por dicho cliente a aeropuertos de diferente país.
GO
CREATE FUNCTION calcularKilosDeCliente(@cliID int) RETURNS TABLE
AS
RETURN(
	SELECT A.aeroPais, SUM(C.cargaKilos) AS 'Total de kilos'
	FROM Carga C, Aeropuerto A
	WHERE C.cliID = @cliID
	AND A.codIATA = C.aeroDestino
	GROUP BY A.aeroPais
)
GO
SELECT *
FROM dbo.calcularKilosDeCliente(1)

