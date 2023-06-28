use DBCARGAS;
SET DATEFORMAT DMY;

-- SE PIDE 6
-------------------------------------------------------------------------------------------------------------
-------------------------------------------------------------------------------------------------------------
--a
--Realizar un disparador que lleve un mantenimiento de la cantidad de cargas acumuladas de un cliente, este disparador debe controlar tanto los ingresos de cargas como el borrado de cargas.
GO
CREATE TRIGGER Trg_CargasAcumuladasPorCliente ON Carga
AFTER INSERT, DELETE
AS
BEGIN
	IF EXISTS(SELECT * FROM INSERTED) AND NOT EXISTS(SELECT * FROM DELETED)
	-- la operacion disparadora fue un INSERT
	BEGIN
		UPDATE Cliente
		SET cliCantCargas = cliCantCargas + 1
		FROM Cliente C, Inserted I
		WHERE C.cliID = I.cliID
	END

	ELSE IF EXISTS(SELECT * FROM DELETED) AND NOT EXISTS(SELECT * FROM INSERTED)
	-- la operacion disparadora fue un DELETE
	BEGIN
		UPDATE Cliente
		SET cliCantCargas = cliCantCargas - 1
		FROM Cliente C, Deleted D
		WHERE C.cliID = D.cliID
	END
END
-------------------------------------------------------------------------------------------------------------
-------------------------------------------------------------------------------------------------------------
--b
GO
CREATE TRIGGER Trg_AuditContainer ON Dcontainer
AFTER UPDATE
AS
BEGIN
	IF UPDATE(dContLargo) OR UPDATE(dContAncho) OR UPDATE(dcontAlto) OR UPDATE(dcontCapacidad)
	BEGIN	
		INSERT INTO AuditContainer(AuditFecha,AuditHost,LargoAnterior,AnchoAnterior,AltoAnterior,CapAnterior,LargoActual,AnchoActual,AltoActual,CapActual,dContID)
		SELECT GETDATE(), HOST_NAME(), D.dContLargo, D.dContAncho, D.dcontAlto, D.dcontCapacidad, I.dContLargo, I.dContAncho, I.dcontAlto, I.dcontCapacidad, D.dContID
		FROM DELETED D, INSERTED I
		WHERE D.dContID = I.dContID
	END
END
-------------------------------------------------------------------------------------------------------------
-------------------------------------------------------------------------------------------------------------
--c
GO
CREATE TRIGGER Trg_ValidarCapacidadEnAvion ON Carga 
INSTEAD OF INSERT
AS
BEGIN
	Declare @capacidadMaxDeAvion decimal;
	SET @capacidadMaxDeAvion = 0;
	SELECT @capacidadMaxDeAvion = avionCapacidad 
	FROM Avion
	WHERE avionID = (SELECT I.avionID FROM Inserted I)

	Declare @cargaTotalActual decimal;
	SET @cargaTotalActual = 0;
	SELECT @cargaTotalActual = SUM(C.cargaKilos) 
	FROM Carga C
	WHERE C.avionID = (SELECT I.avionID FROM Inserted I)
	AND C.cargaFch = (SELECT I.cargaFch FROM Inserted I)
	GROUP BY  C.avionID

	Declare @cargaAInsertar decimal 
	SET @cargaAInsertar = 0;
	SELECT @cargaAInsertar = I.cargaKilos FROM Inserted I
		
	IF (@capacidadMaxDeAvion - @cargaTotalActual >= @cargaAInsertar)
	BEGIN
		INSERT INTO Carga(avionID,dContID,cargaFch,cargaKilos,cliID,aeroOrigen,aeroDestino,cargaStatus)
		SELECT avionID,dContID,cargaFch,cargaKilos,cliID,aeroOrigen,aeroDestino,cargaStatus 
		FROM Inserted
	END
	ELSE
	BEGIN
		PRINT 'El avion no cuenta con capacidad suficiente'
	END
END
-------------------------------------------------------------------------------------------------------------
-------------------------------------------------------------------------------------------------------------
--Test a
insert into Carga values ('AVION00003', 'GGG001', '03-04-2022', 4.0, 3, 'ESP', 'UYU', 'Entregado'),
						 ('AVION00003', 'PPP001', '03-04-2022', 4.0, 2, 'ESP', 'UYU', 'Entregado')
SELECT * FROM CLIENTE
DELETE FROM Carga WHERE cargaFch = '03-04-2022' AND cliID=3
SELECT * FROM CLIENTE

--Test b
insert into DContainer(dContID,dContLargo,dContAncho,dContAlto,dContCapacidad, dDescripcion) values ('MMM002', 2.0, 2.0, 2.0, 4.0, 'Mediano 2');
UPDATE DContainer SET dContAncho = 3.0 WHERE dContID = 'MMM002';
SELECT * FROM DContainer
SELECT * FROM AuditContainer

--Test c
--AVION00001 CAPACIDAD MAXIMA 50
insert into Carga(avionID,dContID,cargaFch,cargaKilos,cliID,aeroOrigen,aeroDestino,cargaStatus) values ('AVION00001', 'GGG001', '04-04-2022', 49, 2, 'UYU', 'ARG','Reservado')
insert into Carga(avionID,dContID,cargaFch,cargaKilos,cliID,aeroOrigen,aeroDestino,cargaStatus) values('AVION00001', 'MMM001', '04-04-2022', 7, 2, 'UYU', 'ARG','Reservado')
SELECT * FROM Carga WHERE cargaFch =  '04-04-2022'
DELETE FROM Carga WHERE cargaFch =  '04-04-2022'