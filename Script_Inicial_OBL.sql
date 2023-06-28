CREATE DATABASE DBCARGAS
GO
USE DBCARGAS
GO
/* Creacion de tablas SIN restricciones */
CREATE TABLE Cliente(cliID int identity not null,
                     cliNom varchar(30) not null,
					 cliMail varchar(50),
					 cliCantCargas int)
GO
--Agregar unique(cliMail)
--Agregar PK cliID
--cliCantCargas -> actualizar cuando AFTER INSERT de entidad Carga
CREATE TABLE Avion(avionID char(10) not null,
                   avionMAT varchar(20) not null,
				   avionMarca varchar(30) not null,
				   avionModelo varchar(30) not null,
				   avionCapacidad decimal)
GO
--Agregar avionCapacidad <= 150
--Agregar PK avionID
CREATE TABLE Dcontainer(dContID char(3) not null,
                       	dContLargo decimal,
						dContAncho decimal,
						dcontAlto decimal,
						dcontCapacidad decimal)
GO
--Modificar ID (3 letras y 3 num)
--Agregar field Descripcion
--Agregar dContLargo <= 2.5
--Agregar dContAncho <= 3.5
--Agregar dcontAlto <= 2.5
--Agregar dcontCapacidad <= 7
--Agregar PK dContID
CREATE TABLE Aeropuerto(codIATA char(3) not null,
                        aeroNombre varchar(30) not null,
						aeroPais varchar(30) not null)
GO
--Agregar PK codIATA
CREATE TABLE Carga(idCarga int identity not null,
                   avionID char(10) not null,
				   dContID char(3) not null,
				   cargaFch date,
				   cargaKilos decimal,
				   cliID int,
				   aeroOrigen char(3),
				   aeroDestino char(3),
				   cargaStatus char(1))
GO
--Agregar PK idCarga
--Agregar FK avionID references Avion
--Agregar FK dContID references Dcontainer
--Agregar FK cliID references Cliente
--Agregar FK aeroOrigen references Aeropuerto
--Agregar FK aeroDestino references Aeropuerto
--Agregar cargaStatus IN (Reservado, Cargado, Transito, Descargado, Entregado)
CREATE TABLE AuditContainer(AuditID int identity not null,
                            AuditFecha datetime,
							AuditHost varchar(30),
                       	    LargoAnterior decimal,
						    AnchoAnterior decimal,
						    AltoAnterior decimal,
						    CapAnterior decimal,
							LargoActual decimal,
						    AnchoActual decimal,
						    AltoActual decimal,
						    CapActual decimal)
GO			
--Agregar el Id del contenedor
			