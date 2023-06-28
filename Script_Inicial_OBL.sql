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


-- SE PIDE 1
--Restricciones en tabla Clientes
ALTER TABLE Cliente ADD CONSTRAINT PK_Cliente PRIMARY KEY(cliID);
ALTER TABLE Cliente ADD CONSTRAINT CS_cliMail UNIQUE(cliMail);
--Restricciones en tabla Avion
ALTER TABLE Avion ADD CONSTRAINT PK_Avion PRIMARY KEY(avionID);
ALTER TABLE Avion ADD CONSTRAINT CS_avionCapacidad CHECK(avionCapacidad <= 150);
--Restricciones en tabla Dcontainer
ALTER TABLE Dcontainer ADD dDescripcion VARCHAR(30);
ALTER TABLE Dcontainer ALTER COLUMN dContID CHAR(6) NOT NULL;
ALTER TABLE Dcontainer ALTER COLUMN dContLargo decimal(18,2);
ALTER TABLE Dcontainer ALTER COLUMN dContAncho decimal(18,2);
ALTER TABLE Dcontainer ALTER COLUMN dcontAlto decimal(18,2);
ALTER TABLE Dcontainer ADD CONSTRAINT PK_Dcontainer PRIMARY KEY(dContID);
ALTER TABLE Dcontainer ADD CONSTRAINT CS_dContID CHECK(dContID like '[A-Z][A-Z][A-Z][0-9][0-9][0-9]');
ALTER TABLE Dcontainer ADD CONSTRAINT CS_dContLargo CHECK(dContLargo <= 2.5);
ALTER TABLE Dcontainer ADD CONSTRAINT CS_dContAncho CHECK(dContAncho <= 3.5);
ALTER TABLE Dcontainer ADD CONSTRAINT CS_dcontAlto CHECK(dcontAlto <= 2.5);
ALTER TABLE Dcontainer ADD CONSTRAINT CS_dcontCapacidad CHECK(dcontCapacidad <= 7);
--Agregar columna dContID a la tabla AuditContainer
ALTER TABLE AuditContainer ADD dContID CHAR(6) NOT NULL;
--Restricciones en tabla Aeropuerto
ALTER TABLE Aeropuerto ADD CONSTRAINT PK_Aeropuerto PRIMARY KEY(codIATA);
--Restricciones en tabla Carga
ALTER TABLE Carga ALTER COLUMN dContID CHAR(6) NOT NULL;
ALTER TABLE Carga ALTER COLUMN cargaFch date NOT NULL;
ALTER TABLE Carga ALTER COLUMN cargaStatus VARCHAR(30);
ALTER TABLE Carga ADD CONSTRAINT PK_Carga PRIMARY KEY(avionID, dContID, cargaFch);
ALTER TABLE Carga ADD CONSTRAINT FK_avionID FOREIGN KEY(avionID) REFERENCES Avion(avionID);
ALTER TABLE Carga ADD CONSTRAINT FK_dContID FOREIGN KEY(dContID) REFERENCES Dcontainer(dContID);
ALTER TABLE Carga ADD CONSTRAINT FK_cliID FOREIGN KEY(cliID) REFERENCES Cliente(cliID);
ALTER TABLE Carga ADD CONSTRAINT FK_aeroOrigen FOREIGN KEY(aeroOrigen) REFERENCES Aeropuerto(codIATA);
ALTER TABLE Carga ADD CONSTRAINT FK_aeroDestino FOREIGN KEY(aeroDestino) REFERENCES Aeropuerto(codIATA);
ALTER TABLE Carga ADD CONSTRAINT CS_cargaStatus CHECK(cargaStatus in ('Reservado', 'Cargado', 'Transito', 'Descargado', 'Entregado'));
--SELECT * FROM INFORMATION_SCHEMA.CHECK_CONSTRAINTS

-------------------------------------------------------------------------------------------------------------
-------------------------------------------------------------------------------------------------------------
-- SE PIDE 2
CREATE INDEX I1 ON Carga(dContID);
CREATE INDEX I2 ON Carga(cliID);
CREATE INDEX I3 ON Carga(aeroOrigen);
CREATE INDEX I4 ON Carga(aeroDestino);

-------------------------------------------------------------------------------------------------------------
-------------------------------------------------------------------------------------------------------------
-- SE PIDE 3
insert into Cliente(cliNom, cliMail, cliCantCargas) values ('Rogelio Aguas', 'ra@obligatorio.com', 0);
insert into Cliente(cliNom, cliMail, cliCantCargas) values ('Roberto Planta', 'rp@obligatorio.com', 0);
insert into Cliente(cliNom, cliMail, cliCantCargas) values ('Fiona Manzana', 'fm@obligatorio.com', 0);
insert into Cliente(cliNom, cliMail, cliCantCargas) values ('Franco Océano', 'fo@obligatorio.com', 0);
insert into Cliente(cliNom, cliMail, cliCantCargas) values ('Jacobo Blanco', 'jb@obligatorio.com', 0);

insert into Avion(avionID,avionMAT,avionMarca,avionModelo,avionCapacidad) values ('AVION00001', '100100', 'GOL', 'G01', 50);
insert into Avion(avionID,avionMAT,avionMarca,avionModelo,avionCapacidad) values ('AVION00002', '100200', 'AA', 'AA01', 100);
insert into Avion(avionID,avionMAT,avionMarca,avionModelo,avionCapacidad) values ('AVION00003', '100300', 'IBERIA', 'IB01', 150);

insert into DContainer(dContID,dContLargo,dContAncho,dContAlto,dContCapacidad, dDescripcion) values ('XXP001', 0.5, 0.5, 0.5, 1.0, 'Extra Pequeño');
insert into DContainer(dContID,dContLargo,dContAncho,dContAlto,dContCapacidad, dDescripcion) values ('PPP001', 1.0, 1.0, 1.0, 2.0, 'Pequeño');
insert into DContainer(dContID,dContLargo,dContAncho,dContAlto,dContCapacidad, dDescripcion) values ('MMM001', 2.0, 2.0, 2.0, 4.0, 'Mediano');
insert into DContainer(dContID,dContLargo,dContAncho,dContAlto,dContCapacidad, dDescripcion) values ('GGG001', 2.5, 3.5, 2.5, 7.0, 'Grande');

insert into Aeropuerto(codIATA,aeroNombre,aeroPais) values ('UYU', 'Uruguay', 'Uruguay');
insert into Aeropuerto(codIATA,aeroNombre,aeroPais) values ('ARG', 'Argentina', 'Argentina');
insert into Aeropuerto(codIATA,aeroNombre,aeroPais) values ('USA', 'USA', 'USA');
insert into Aeropuerto(codIATA,aeroNombre,aeroPais) values ('ESP', 'España', 'España');

insert into Carga(avionID,dContID,cargaFch,cargaKilos,cliID,aeroOrigen,aeroDestino,cargaStatus) values ('AVION00001', 'XXP001', '01-08-2023', 1.0, 2, 'UYU', 'ARG','Reservado');
insert into Carga(avionID,dContID,cargaFch,cargaKilos,cliID,aeroOrigen,aeroDestino,cargaStatus) values ('AVION00001', 'PPP001', '01-08-2023', 2.0, 3, 'UYU', 'ARG','Reservado');
insert into Carga(avionID,dContID,cargaFch,cargaKilos,cliID,aeroOrigen,aeroDestino,cargaStatus) values ('AVION00001', 'GGG001', '01-08-2023', 7.0, 4, 'UYU', 'ARG','Reservado');
insert into Carga(avionID,dContID,cargaFch,cargaKilos,cliID,aeroOrigen,aeroDestino,cargaStatus) values ('AVION00001', 'MMM001', '01-08-2023', 4.0, 5, 'UYU', 'ARG','Reservado');
insert into Carga(avionID,dContID,cargaFch,cargaKilos,cliID,aeroOrigen,aeroDestino,cargaStatus) values ('AVION00003', 'GGG001', '01-07-2023', 6.0, 3, 'UYU', 'ESP','Cargado');
insert into Carga(avionID,dContID,cargaFch,cargaKilos,cliID,aeroOrigen,aeroDestino,cargaStatus) values ('AVION00003', 'MMM001', '01-07-2023', 4.0, 4, 'UYU', 'ESP','Cargado');
insert into Carga(avionID,dContID,cargaFch,cargaKilos,cliID,aeroOrigen,aeroDestino,cargaStatus) values ('AVION00003', 'PPP001', '01-07-2023', 4.0, 5, 'UYU', 'ESP','Cargado');
insert into Carga(avionID,dContID,cargaFch,cargaKilos,cliID,aeroOrigen,aeroDestino,cargaStatus) values ('AVION00003', 'XXP001', '01-07-2023', 1.0, 2, 'UYU', 'ESP','Cargado');
insert into Carga(avionID,dContID,cargaFch,cargaKilos,cliID,aeroOrigen,aeroDestino,cargaStatus) values ('AVION00001', 'PPP001', '01-06-2023', 2.0, 1, 'UYU', 'ARG','Transito');
insert into Carga(avionID,dContID,cargaFch,cargaKilos,cliID,aeroOrigen,aeroDestino,cargaStatus) values ('AVION00001', 'GGG001', '01-06-2023', 7.0, 2, 'UYU', 'ARG','Transito');
insert into Carga(avionID,dContID,cargaFch,cargaKilos,cliID,aeroOrigen,aeroDestino,cargaStatus) values ('AVION00001', 'MMM001', '01-06-2023', 4.0, 3, 'UYU', 'ARG','Transito');
insert into Carga(avionID,dContID,cargaFch,cargaKilos,cliID,aeroOrigen,aeroDestino,cargaStatus) values ('AVION00001', 'XXP001', '01-06-2023', 1.0, 4, 'UYU', 'ARG','Transito');
insert into Carga(avionID,dContID,cargaFch,cargaKilos,cliID,aeroOrigen,aeroDestino,cargaStatus) values ('AVION00002', 'MMM001', '01-05-2023', 4.0, 1, 'UYU', 'USA','Descargado');
insert into Carga(avionID,dContID,cargaFch,cargaKilos,cliID,aeroOrigen,aeroDestino,cargaStatus) values ('AVION00002', 'GGG001', '01-05-2023', 7.0, 2, 'UYU', 'USA','Descargado');
insert into Carga(avionID,dContID,cargaFch,cargaKilos,cliID,aeroOrigen,aeroDestino,cargaStatus) values ('AVION00002', 'PPP001', '01-05-2023', 2.0, 3, 'UYU', 'USA','Descargado');
insert into Carga(avionID,dContID,cargaFch,cargaKilos,cliID,aeroOrigen,aeroDestino,cargaStatus) values ('AVION00002', 'XXP001', '01-05-2023', 1.0, 4, 'UYU', 'USA','Descargado');
insert into Carga(avionID,dContID,cargaFch,cargaKilos,cliID,aeroOrigen,aeroDestino,cargaStatus) values ('AVION00003', 'GGG001', '01-04-2023', 6.0, 1, 'UYU', 'ESP','Entregado');
insert into Carga(avionID,dContID,cargaFch,cargaKilos,cliID,aeroOrigen,aeroDestino,cargaStatus) values ('AVION00003', 'MMM001', '01-04-2023', 4.0, 2, 'UYU', 'ESP','Entregado');
insert into Carga(avionID,dContID,cargaFch,cargaKilos,cliID,aeroOrigen,aeroDestino,cargaStatus) values ('AVION00003', 'PPP001', '01-04-2023', 4.0, 3, 'UYU', 'ESP','Entregado');
insert into Carga(avionID,dContID,cargaFch,cargaKilos,cliID,aeroOrigen,aeroDestino,cargaStatus) values ('AVION00003', 'XXP001', '01-04-2023', 1.0, 4, 'UYU', 'ESP','Entregado');
--2022
insert into Carga(avionID,dContID,cargaFch,cargaKilos,cliID,aeroOrigen,aeroDestino,cargaStatus) values ('AVION00001', 'PPP001', '01-08-2022', 2.0, 3, 'ARG', 'UYU','Entregado');
insert into Carga(avionID,dContID,cargaFch,cargaKilos,cliID,aeroOrigen,aeroDestino,cargaStatus) values ('AVION00001', 'GGG001', '01-08-2022', 7.0, 4, 'ARG', 'UYU','Entregado');
insert into Carga(avionID,dContID,cargaFch,cargaKilos,cliID,aeroOrigen,aeroDestino,cargaStatus) values ('AVION00001', 'MMM001', '01-08-2022', 4.0, 5, 'ARG', 'UYU','Entregado');
insert into Carga(avionID,dContID,cargaFch,cargaKilos,cliID,aeroOrigen,aeroDestino,cargaStatus) values ('AVION00003', 'GGG001', '01-07-2022', 6.0, 3, 'ESP', 'UYU', 'Entregado');
insert into Carga(avionID,dContID,cargaFch,cargaKilos,cliID,aeroOrigen,aeroDestino,cargaStatus) values ('AVION00003', 'MMM001', '01-07-2022', 4.0, 4, 'ESP', 'UYU', 'Entregado');
insert into Carga(avionID,dContID,cargaFch,cargaKilos,cliID,aeroOrigen,aeroDestino,cargaStatus) values ('AVION00003', 'PPP001', '01-07-2022', 4.0, 5, 'ESP', 'UYU', 'Entregado');
insert into Carga(avionID,dContID,cargaFch,cargaKilos,cliID,aeroOrigen,aeroDestino,cargaStatus) values ('AVION00001', 'PPP001', '01-06-2022', 2.0, 1, 'ARG', 'UYU', 'Entregado');
insert into Carga(avionID,dContID,cargaFch,cargaKilos,cliID,aeroOrigen,aeroDestino,cargaStatus) values ('AVION00001', 'GGG001', '01-06-2022', 7.0, 2, 'ARG', 'UYU', 'Entregado');
insert into Carga(avionID,dContID,cargaFch,cargaKilos,cliID,aeroOrigen,aeroDestino,cargaStatus) values ('AVION00001', 'MMM001', '01-06-2022', 4.0, 3, 'ARG', 'UYU', 'Entregado');
insert into Carga(avionID,dContID,cargaFch,cargaKilos,cliID,aeroOrigen,aeroDestino,cargaStatus) values ('AVION00002', 'MMM001', '01-05-2022', 4.0, 1, 'USA', 'UYU', 'Entregado');
insert into Carga(avionID,dContID,cargaFch,cargaKilos,cliID,aeroOrigen,aeroDestino,cargaStatus) values ('AVION00002', 'GGG001', '01-05-2022', 7.0, 2, 'USA', 'UYU', 'Entregado');
insert into Carga(avionID,dContID,cargaFch,cargaKilos,cliID,aeroOrigen,aeroDestino,cargaStatus) values ('AVION00002', 'PPP001', '01-05-2022', 2.0, 3, 'USA', 'UYU', 'Entregado');
insert into Carga(avionID,dContID,cargaFch,cargaKilos,cliID,aeroOrigen,aeroDestino,cargaStatus) values ('AVION00003', 'GGG001', '01-04-2022', 6.0, 1, 'ESP', 'UYU', 'Entregado');
insert into Carga(avionID,dContID,cargaFch,cargaKilos,cliID,aeroOrigen,aeroDestino,cargaStatus) values ('AVION00003', 'MMM001', '01-04-2022', 4.0, 2, 'ESP', 'UYU', 'Entregado');
insert into Carga(avionID,dContID,cargaFch,cargaKilos,cliID,aeroOrigen,aeroDestino,cargaStatus) values ('AVION00003', 'PPP001', '01-04-2022', 4.0, 3, 'ESP', 'UYU', 'Entregado');
			