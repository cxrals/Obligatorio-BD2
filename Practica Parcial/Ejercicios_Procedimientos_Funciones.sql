--==========================================================================================
-- Parcial 2022-06-22 N3C
--==========================================================================================
/*
Paciente(pac_ID,pac_nombre,pac_apellido,pac_FchNacim,pac_Mail,pac_Tel)
Salas(sala_ID, sala_piso, sala_tipo, sala_capacidad)
Funcionarios(func_ID,func_nombre,func_apellido,func_tipo,func_FchIngreso)
Intervenciones(pac_ID,func_ID,int_tipo,int_fechaHora,sala_ID)
Auditoria(AuditID, AuditFch, AuditTabla, AuditCampo, AuditAnt, AuditAct, AuditObs)

Hacer un procedimiento almacenado que permita dar de alta un paciente si el mismo no existe y o modificar
su datos si ya existe, además al realizar una modificación se debe verificar que el paciente no tenga
intervenciones previas.
*/
create or alter procedure alta_paciente @pac_nombre varchar(50), @pac_apellido varchar(50), @pac_FchNacim datetime, @pac_Mail varchar(50), @pac_Tel varchar(50) 
AS
begin
	declare @pacID int, @cantIntervenciones int
	set @pacID = 0
	set @cantIntervenciones = 0

	select @pacID = pac_ID from Paciente where pac_nombre = @pac_nombre and pac_apellido = @pac_apellido and pac_FchNacim = @pac_FchNacim
	
	if @pacID > 0
	begin
		select @cantIntervenciones = count(1) from Intervenciones where pac_ID=@pacID
		if @cantIntervenciones = 0
		begin
			UPDATE Paciente
			set pac_nombre=@pac_nombre, pac_apellido= @pac_apellido, pac_FchNacim=@pac_FchNacim, pac_Mail = @pac_Mail, pac_Tel = @pac_Tel
			where pac_ID=@pacID
		end
		else
		begin
			print 'El paciente tiene intervenciones previas, no se puede modificar'
		end
	end
	else
	begin
		insert into Paciente (pac_nombre,pac_apellido,pac_FchNacim,pac_Mail,pac_Tel) 
		values (@pac_nombre, @pac_apellido, @pac_FchNacim, @pac_Mail, @pac_Tel)
	end
end
go
/*
Hacer una función que dado un paciente y un año retorne la o las intervenciones que dicho paciente se 
realizó en el año ingresado.
*/
create function intervencionesXPaciente(@pacId int, @anio int) returns table 
as
return
	(select *
	from Intervenciones
	where pac_ID = @pacID
	and year(int_fechaHora) = @anio)
go
--==========================================================================================
-- Parcial 2022-06-23 M3A
--==========================================================================================
/*
Clientes (CliId, CliNom, CliMail)
Vehiculos(VehMatr, VehMarca, VehMod, VehAño, VehCliId)
Mecanicos(MecId, MecNom, MecCed)
Servicios(SrvId, SrvFch, VehMatr, SrvTipo, SrvPrecio, MecId)
Pagos(SrvId, FchPago, Importe)

Implementar una función que devuelva la mejor marca de vehículos siendo esta la que solo 
ha tenido servicios de tipo garantía y que tiene servicios desde hace más de 3 años. 
Si hay más de una marca en estas condiciones devolver la que corresponda al vehículo/s con 
más antigüedad
*/
Create Function FN_Ej2 () returns varchar(100)	
as
begin
   declare @marca varchar(100);

   select @marca =  V.VehMarca
   from Vehiculos V
   where not Exists(select S.* from Servicios S where S.VehMatr = V.VehMatr and S.TipoSrv <> 'GARANTIA' ) and 
         Exists (select S.* from Servicios S where S.VehMatr = V.VehMatr and datediff ( YY,Year(S.SrvFch), getdate()) > 3) 
   order by V.VehAño asc;
		 
   return @marca;
end
/*
Implementar un procedimiento que dada la cedula de un mecánico y un rango de fechas 
devuelva: la cantidad de servicios que ha realizado, la cantidad de vehículos y clientes 
que ha atendido con esos servicios, en el periodo de fechas indicado. Tambien devolver la 
fecha del último servicio que ha realizado
*/
create procedure SP_Ej3 @mecCed char(11), @f1 date, @f2 date, @cntSrv int output, @cntVeh int output, @cntCli int output, @fUltSrv date output
as
begin
    select @cntSrv = count(*) , @cntveh = count(distinct S.VehMatr), @cntCli = count(distinct V.VehCliId) 
	from Mecanico M, Servicios S, Vehiculos V
	where M.MecId = S.MecId 
	and S.VehMatr = V.VehMatr 
	and M.MecCed = @mecCed 
	and (S.SrvFch between @f1 and @f2) ;

	select @fUltSrv = Max(S.SrvFch)
	from Servicios S, Mecanico M
	where M.MecId = S.MecId 
	and M.MecCed = @mecCed 
end
--==========================================================================================
-- Parcial 2019-06-25 N3A
--==========================================================================================
/*
Tecnicos(idTec, nomTec, sueldoTec, horasTec, stsTec)
Vehiculos(idVehic, marcaVehic, modeloVehic)
Equipos(idEq, dscEq, costoHoraEq, horasAcumEq)
Alinean(idAlin, idTec, idVehic, fchAlin, horasAlin, idEq)
Auditoria(idAudit, fecha, tabla, campo, anterior, actual, clave)

Programar un procedimiento almacenado que reciba como parámetro un identificador de técnico 
y cargue en el campo horasTec el total de horas que lleva trabajadas, si dicho total supera 
las 72 horas, debe además poner en el campo stsTec el valor ‘A’ si no supera las 72 horas 
debe poner ‘P’.
*/
CREATE PROCEDURE Ejer_1
@idTec int
AS
BEGIN
	DECLARE @horasTec int

	SELECT @horasTec=SUM(T.horasAlin)
	FROM Alinean A
	WHERE A.idTec=@idTec

	IF @horasTec > 72
		UPDATE Tecnicos
		SET horasTec=@HorasTec,stsTec='A'
		WHERE idTec=@idTec
	ELSE
		UPDATE Tecnicos
		SET horasTec=@HorasTec,stsTec='P'
		WHERE idTec=@idTec
END
/*
Programar una función que reciba como parámetro un identificador de equipo y retorne el costo 
total de horas trabajadas por dicho equipo, debe además realizar una consulta que muestre el 
identificador del equipo, su marca, modelo y dicho total utilizando la función creada.
*/
CREATE FUNCTION Ejer_2(@idEq int)
RETURNS int
AS
BEGIN
	DECLARE @retorno int

	SELECT @retorno=SUM(horasAlin)
	FROM Alinean
	WHERE idEq=@idEq

	RETURN @retorno
END

SELECT E.idEq,E.dscEq,dbo.Ejer_2(E.idEq) as TotalHoras
FROM Equipos E
--==========================================================================================
-- Parcial 2019-06-25 M3B
--==========================================================================================
/*
PERSONA (Pasaporte, Nacionalidad, Nombre, CI)
AVION (AviMod, AviNro, AviFchFab, AviAsi, AviCntVue)
AEREOPUERTOS (APid, APNombre, Pais)
VUELO (VueId, AviMod, AviNro, CapPasaporte, VueFch, APId_S, APId_L, VueMillas)
PASAJE (PasjNro, Pasaporte, VueId, Clase, NroAsi, Precio, Descuento)
VIAJE (ViajeId, VueId, Pasaporte, Motivo)

Implementar una función que dado un aereopuerto, una persona y una fecha devuelva
un indicador de si la persona ha pasado por el areopuerto en la fecha indicada
*/

Create Function Ej1(@APId int, @Pasap char(10), @Fch date) returns char(1)
as
begin
	declare @paso char(1);
	set @paso = 'N'

	if Exists( select * from Vuelo V, Pasaje P
	where P.VueId = V.vueId and V.VueFch = @Fch and
	P.pasaporte = @Pasap and
	(V.ApId_S = @ApId or V.ApId_L = @ApId )
	)
	set @paso = 'S'
	end
	return @paso
end;
go

/*
Implementar una función que dado la CI de un capitán y un país devuelva la cantidad de veces que 
el capitán a pasado por ese país, como capitán de vuelos.
*/
Create Function Ej2(@ciCap char(11), @pais varchar(20)) returns int
as
begin
	declare @cant int;
	declare @cantLlegSal int;
	-- cant de veces que paso como capitan de vuelos que SALIAN/LLEGABAN del pais
	select @cant = count(*)
	from Persona P, Vuelo V, Aereopuerto A
	where P.pasaporte = V.CapPasaporte and P.ci = @ciCap and A.Pais = @pais
	and (V.APId_S = A.APId or V.APId_L = A.APId )
	-- cant. de vuelos locales(pais de llegada igual al de salida), de ese pais
	-- en estos casos se deberia contar una sola vez, en la consulta anterior se -- contaron dos veces
	select @cantLlegSal = count(*)
	from Persona P, Vuelo V, Aereopuerto APS , Aeropuerto APL
	where P.pasaporte = V.CapPasaporte and V.APId_L = APS.APId and
	V.APId_L = APL.APId and P.ci = @ciCap and APS.Pais = APL.Pais
	and APS.Pais = @pais
	return @cant - @cantLlegSal
end
/*
Implementar un procedimiento que dado un avión devuelva el promedio de millas que ha volado, y el 
año que ha volado más veces, si hay más de un año en estas condiciones devolver cualquiera de ellos.
*/
Create Procedure Ej3 @avMod char(10), @avNro int, @cantMi int output,
@mejorAño int output
as
begin
	select @cantMi = avg(V.VueMillas)
	from Vuelo V where V.aviMod = @avMod and V.aviNro = @avNro ;
	Select @mejorAño = year(V.VueFch)
	from Vuelo V where V.aviMod = @avMod and V.aviNro = @avNro
	group by year(V.VueFch)
	order by count(*) asc;
end;
/*
Implementar una función o procedimiento que reciba como parámetros un rango de fechas y devuelva la 
cantidad de aviones con antigüedad mayor a 10 años, y que han realizado más de 50 vuelos largos en 
el rango de fechas indicado. Un vuelo largo es aquel de más de 2000 millas
*/
Create Procedure Ej4 @f1 date, @f2 date, @cntAvi int output
as
begin
	select @cntAvi = count(*)
	from Avion A
	where A.AviFchFab < year(getdate()) - 10 
	and (select count(*) from Vuelo V 
		where V.aviMod = A.aviMod
		and V.aviNro = A.aviNro and V.vueFch >= @f1 
		and V.vueFch <= @f2
		and V.vueMillas > 2000
	) > 50
end;
--==========================================================================================
-- Parcial 2019-06-24 N3B
--==========================================================================================
/*
Empleados(idEmp, nomEmp, sueldoEmp, horasEmp, stsEmp)
Obras(idObra, dscObra, dirObra)
Maquinas(idMaq, dscMaq, costoHoraMaq, horasAcumMaq)
Trabajan(idTrab, idEmp, idObra, fchTrab, horasTrab, idMaq)
Auditoria(idAudit, fecha, tabla, campo, anterior, actual, clave)


Programar un procedimiento almacenado que reciba como parámetro un
identificador de empleado y cargue en el campo horasEmp el total de horas
que lleva trabajadas, si dicho total supera las 48 horas, debe además poner en el
campo stsEmp el valor ‘Activo’ si no supera las 48 horas debe poner ‘Prueba’.
*/
CREATE PROCEDURE Ejer_1
@idEmp int
AS
BEGIN
	DECLARE @horasEmp int
	SELECT @horasEmp=SUM(T.horasTrab)
	FROM Trabajan T
	WHERE T.idEmp=@idEmp

	IF @horasEmp > 48
		UPDATE Empleados
		SET horasEmp=@HorasEmp,stsEmp='Activo'
		WHERE idEmp=@idEmp
	ELSE
		UPDATE Empleados
		SET horasEmp=@HorasEmp,stsEmp='Prueba'
		WHERE idEmp=@idEmp
END
/*
Programar una función que reciba como parámetro un identificador de máquina y
retorne el costo total de horas trabajadas por dicha máquina,
debe además realizar una consulta que muestre el identificador de la máquina, su
descripción y dicho total utilizando la función creada.
*/
CREATE FUNCTION Ejer_2(@idMaq int)
RETURNS int
AS
BEGIN
	DECLARE @retorno int

	SELECT @retorno=SUM(horasTrab)
	FROM Trabajan
	WHERE idMaq=@idMaq

	RETURN @retorno
END
--==========================================================================================
-- Parcial 2018-11-29 N3A
--==========================================================================================
/*
EMPRESAS (idEmp, nombreEmp, RubroEmp)
ENCUESTAS (idEnc, añoEnc, idEmpresaEnc)
CIUDADANOS (Ci, Nom, Sexo, cantEncuestado)
ENCUESTACIU (idEnc, ci, ciEncuestador, fecha)
RESIDENCIAS (idEnc, ci, Departamento, cantHab, situacionRes)
TRABAJOS (idEnc, ci, idEmp, distancia, sueldo)

Implementar una función que dado un ciudadano devuelva la cantidad de empresas distintas en 
las que ha trabajado según las encuestas realizadas en los últimos 5 años
*/
Create Function Func_Ej1(@datCI varchar(11)) returns int
as
begin
	declare @cant int;

	select @cant= count( distinct T.idEmp) 
	from Trabajos T, Encuestas E
	where T.idEnc = E.idEnc 
	and T.ci =@datCI 
	and E.añoEnc >= Year(getdate()) - 5;
	
	return @cant;
end
/*
Implementar un procedimiento que reciba los parámetros que considere necesario para 
actualizar los datos de la empresa si esta ya existe, y si no existe la agregue 
a la base de datos.
*/
Create Procedure Proc_Ej2 @datIdEmp int, @datNom varchar(50), @datRubro varchar(20)
as
begin
	if Exists(select * from Empresas where idEmp = @datIdEmp)
	begin
		Update Empresas set nombreEmp = @datNom ,rubroEmp = @datRubro
		where IdEmp = @datIdEmp;
	end
	else
		begin
		Insert into Empresas(nombreEmp, rubroEmp) values (@datNom, @datRubro);
	end
end
/*
Implementar una función que dado un rango de fecha (año) devuelva el nombre de 
la empresa que pago mayor sueldo en ese periodo de tiempo, devolver la información 
más reciente posible. Si hay más de una empresa que cumpla la condición devolver una cualquiera.
*/
Create Function Func_Ej3(@añoDesde int, @añoHasta int) returns varchar(50)
as
begin
	declare @empMaxSueldo int;
	declare @nomEmpMaxSueldo varchar(50);

	select @empMaxSueldo = T.idEmp from Encuestas E, Trabajos T
	where E.idEnc = T.idEnc and E.añoEnc >= @añoDesde and E.añoEnc <= @añoHasta
	order by T.sueldo, E.añoEnc asc;

	select @nomEmpMaxSueldo = nombreEmp from Empresas where idEmp = @empMaxSueldo;

	return @nomEmpMaxSueldo;
end
/*
Implementar un procedimiento que dado un ciudadano y una encuesta, devuelva un indicador si el 
ciudadano fue encuestado en esa encuesta, la situación que tenía con su residencia 
(propietario, inquilino u otro), el ingreso total por sueldos que tenía en ese momento, y la 
distancia al trabajo más cercano.
*/
create procedure Proc_Ej4 @datCI varchar(11), @datIdEnc int, @fueEnc char(2) output, @situacion varchar(20) output,
@sumaSueldos money output, @distanciaMin int output
as
begin
	if not Exists(select * from EncuestaCiu where idEnc = @datIdEnc and ci = @datCI)
	begin
		set @fueEnc = 'NO';
		set @situacion = '';
		set @sumaSueldos= 0;
		set @distanciaMin = 0
	end
	else
	begin
		set @fueEnc = 'SI';
		select @situacion = R.SituacionRes from Residencias R
		where R.ci = @datCI and R.idEnc = @datIdEnc;
		select @sumaSueldos = sum(T.Sueldo), @distanciaMin = Min(T.distancia)
		from Trabajos T where T.ci = @datCI and T.idEnc = @datIdEnc;
	end
end
--==========================================================================================
-- Parcial 2018-06-28 N3C
--==========================================================================================
/*
Clientes(CI, Nombre, Mail, Telefono)
Cuentas(NumCta, TipoCta, MonedaCta, SaldoCta, CI)
Movimientos(IDMovim, FchMovim, NumCta, ImporteMovim, TipoMovim)
Auditoria(IDAudit, Fecha, Tabla, Campo, Anterior, Actual, Observaciones)

Hacer un procedimiento almacenado que dado un número de cuenta ajuste su saldo de acuerdo a los
movimientos, se sabe que los depósitos son del tipo DEP y los retiros del tipo RET
*/
CREATE PROCEDURE AjusteSaldo
@NumCta int
AS
BEGIN
	DECLARE @debe money,@haber money
	SELECT @debe=SUM(ImporteMovim)
	FROM Movimientos
	WHERE NumCta=@NumCta and
	TipoMovim='RET'

	SELECT @haber=SUM(ImporteMovim)
	FROM Movimientos
	WHERE NumCta=@NumCta and
	TipoMovim='DEP'

	UPDATE Cuentas
	SET SaldoCta=@haber-@debe
	WHERE NumCta=@NumCta
END
/*
Hacer una función que dado un Cliente, una Moneda y un Tipo de cuenta retorne el saldo que tiene dicho
cliente para esa moneda y tipo (tener en cuenta que un cliente puede tener muchas cuentas)
*/
CREATE FUNCTION SaldoCuenta(@CI int, @Moneda char(3), @Tipo char(3))
RETURNS money
AS
BEGIN
	DECLARE @retorno money
	SELECT @retorno=SUM(SaldoCta)
	FROM Cuentas
	WHERE CI=@ci and MonedaCta=@moneda and TipoCuenta=@tipo
	RETURN @retono
END
/*
Hacer un procedimiento almacenado que permita emitir un detalle del movimientos de una cuenta en un
rango de fechas, el procedimiento debe recibir el número de cuenta, el rango y debe retornar las
siguientes columnas ordenadas por fecha :
a. Nombre Cliente
b. Número de Cuenta
c. Moneda
d. Fecha
e. Tipo de Movimiento
f. Importe
g. Saldo del Cliente (utilizar la función del punto 2)
*/
CREATE PROCEDURE DetalleMovimientos
@NumCta int, @desde char(10), @hasta char(10)
AS
BEGIN
	SELECT Clientes.Nombre,Cuentas.NumCuenta,Cuentas.MonedaCuenta,Movimientos.fchMovim,
	Movimientos.TipoMovim,Movimientos.ImporteMovim,dbo.SaldoCuenta(Cuentas.ci,Cuentas.MonedaCta,Cuentas.
	TipoCuenta) as Saldo
	FROM Clientes,Cuentas,Movimientos
	WHERE Clientes.ci=Cuentas.ci and Cuentas.NumCta=Movimientos.NumCta and Movimientos.numCta=@NumCta and
	Movimientos.fchMovim >= @desde and Movimientos.fchMovim <= @hasta
	ORDER BY fchMovim
END
--==========================================================================================
-- Parcial 2018-06-26 N3A
--==========================================================================================
/*
Estudiantes(EstID, EstNombre, EstMail, EstTel, EstFchNacim, EstSaldo)
Grupos(GrpID, GrpDescrip, GrpSemestre, GrpCantidad)
Salones(SalID, SalPiso, SalDescrip, SalCapacidad)
Inscripto(EstID,GrpID,fchInscripto,SalID,Importe)
Auditoria(AuditID, AuditFch, AuditTabla, AuditCampo, AuditAnt, AuditAct, AuditObs)

Hacer un procedimiento almacenado que permita dar de alta una inscripción si la misma no 
existe o modificar un salón de una inscripción ya existente, tanto el alta como la modificación 
deben verificar que la capacidad del salón sea suficiente, si no lo es debe mostrar un mensaje.
*/
CREATE PROCEDURE AltaInscripcion
@EstID int,@GrpID char(5),@fchInscripto char(10),@SalID int,@Importe money
AS
BEGIN
	/* Verifico que el salon tenga capacidad */
	IF (SELECT salCapacidad
	FROM Salones
	WHERE salID=@SalID) > (SELECT COUNT(*)
	FROM Inscripto
	WHERE salID=@SalID and grpID=@grpID)
	BEGIN
		IF EXISTS (SELECT * FROM Inscripto WHERE EstID=@EstID and GrpID=@GrpID and fchInscripto=@fchInscripto)
		/* es ina modificacion */
		UPDATE Inscripto
		SET SalID=@SalID,Importe=@Importe
		WHERE EstID=@EstID and GrpID=@GrpID and fchInscripto=@fchInscripto
	ELSE
		/* es un ingreso */
		INSERT INTO Inscripto VALUES(@EstID,@GrpID,@fchInscripto,@SalID,@Importe)
	END
END
/*
Hacer una función que dado un estudiante retorne la cantidad a pagar que tiene de acuerdo a los 
grupos en los que está inscripto.
*/
CREATE FUNCTION TotalPagar(@EstID int)
RETURNS money
AS
BEGIN
	DECLARE @retorno money
	SELECT @retorno=SUM(Importe)
	FROM Inscripto
	WHERE EstID=@EstID
	RETURN @retorno
END
/*
Hacer un procedimiento almacenado que actualice el saldo a pagar de un estudiante dado utilizando 
la función del punto 2, si el estudiante queda con saldo a favor se debe poner un mensaje de aviso.
*/
CREATE PROCEDURE ActualizarSaldo
@EstID int
AS
BEGIN
	UPDATE Estudiantes
	SET EstSaldo=EstSaldo - dbo.TotalPagar(@EstID)
	WHERE EstID=@EstID
	IF (SELECT EstSaldo FROM Estudiantes WHERE EstID=@EstID) > 0
	PRINT 'El estudiante ' + ltrim(str(@EstID)) + ' tiene saldo a favor'
END