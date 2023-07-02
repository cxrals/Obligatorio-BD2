--==========================================================================================
-- Parcial 2022-06-22 N3C
--==========================================================================================
/*
Paciente(pac_ID,pac_nombre,pac_apellido,pac_FchNacim,pac_Mail,pac_Tel)
Salas(sala_ID, sala_piso, sala_tipo, sala_capacidad)
Funcionarios(func_ID,func_nombre,func_apellido,func_tipo,func_FchIngreso)
Intervenciones(pac_ID,func_ID,int_tipo,int_fechaHora,sala_ID)
Auditoria(AuditID, AuditFch, AuditTabla, AuditCampo, AuditAnt, AuditAct, AuditObs)

Hacer un disparador que no permita ingresar funcionario si el mismo ya existe 
(func_nombre, func_apellido y func_tipo) y que al insertar un nuevo funcionario 
cargue la fecha de ingreso con la fecha del día.
*/
create or alter trigger trg_control_funcionarios on Funcionarios
after insert as
begin
	declare @funcionario int, @funcId int, @func_tipo varchar(50), @funNombre varchar(50), @funcApellido varchar(50), @funcTipo varchar(20)
	select @funcId = func_Id, @funNombre = func_nombre, @funcApellido = func_apellido, @funcTipo = func_tipo from inserted
	select @funcionario = count(1) from Funcionarios where @funNombre = func_nombre and @funcApellido = func_apellido and @funcTipo = func_tipo
	
	if @funcionario = 1 --si da mayor a 1 registro, es porque se acaba de insertar un registro identico por lo que realizo el rollback
	begin
		update Funcionarios set func_FchIngreso = getdate() where func_Id = @funcId
	end
	else
	begin
		print 'No se puede ingresar el funcionario porque ya existe en el sistema'
		rollback
	end
end
go
/*
Hacer un disparador que no permita ingresar una intervención de tipo 'Operacion' 
si el tipo de funcionario no es ‘Cirujano’ y el tipo de sala no es un ‘Quirofano'.
*/
create or alter trigger trg_control_intervencion on Intervenciones
after insert as
begin
	declare @funcID int, @funcTipo varchar(20), @salaID int, @salaTipo varchar(20), @intTipo varchar(20)
	select @funcID=func_id, @salaID=sala_ID, @intTipo=int_tipo from inserted
	select @funcTipo = func_tipo from Funcionarios where func_id = @funcID
	select @salaTipo = sala_tipo from Salas where sala_ID = @salaID
	
	if @intTipo='Operacion' and (@funcTipo != 'Cirujano' or @salaTipo != 'Quirofano')
	begin
		rollback
		print 'No se permita ingresar una intervención de tipo ‘Operacion’ si el tipo de funcionario no es ‘Cirujano’ o el tipo de sala no es un ‘Quirofano’'
	end
end
go
/*
Hacer un disparador que ante la modificación de la sala de una intervención deje 
un registro en la tabla de auditoría cargando todos los campos de dicha tabla.
*/
create or alter trigger trg_control_sala_intervencion on Intervenciones
after update as
begin
	if update(sala_ID)
	begin
		insert into Auditoria select getdate(),'Intervenciones','sala_ID',deleted.sala_ID, inserted.sala_ID, 'Update campo sala_id'
		from inserted,deleted
		where inserted.pac_ID=deleted.pac_ID
		and inserted.func_ID=deleted.func_ID
		and inserted.int_tipo=deleted.int_tipo
		and inserted.int_fechaHora=deleted.int_fechaHora
		print 'Se deja registro de auditoria'
	end
end
go
--==========================================================================================
-- Parcial 2022-06-23 M3A
--==========================================================================================
/*
Clientes (CliId, CliNom, CliMail)
Vehiculos(VehMatr, VehMarca, VehMod, VehAño, VehCliId)
Mecanicos(MecId, MecNom, MecCed)
Servicios(SrvId, SrvFch, VehMatr, SrvTipo, SrvPrecio, MecId)
Pagos(SrvId, FchPago, Importe) => clientes pueden ir realizando pagos parciales hasta completar el pago del servicio

Implementar un trigger que controle que solo se puedan modificar los datos de servicios 
que no esté finalizado su pago. Considerar múltiples registros. Implementar una solución 
que afecte los registros que cumplen e ignore los que no cumplan la condición a controlar.
*/
Create Trigger TR_Ej4 ON Servicios
Instead Of Update
as
Begin
   update Servicios
   Set SrvFch = I.SrvFch , VehMatr = I.VehMatr , TipoSrv = I.TipoSrv , srvPrecio = I.SrvPRecio , MecId = I.MecId 
   From Servicios S, Inserted I
   Where S.SrvId = I.SrvId 
   and (select sum(P.Importe) from Pagos P where P.SrvId = S.SrvId) < S.PrecioSrv
End;
go
/*
Implementar un trigger que cada vez que se modifiquen o eliminen pagos registre en una tabla 
de auditoria los datos necesarios para saber cuál fue la operación, quien, y cuando la realizo, 
y los datos antes y después. Considerar múltiples registros. El esquema de la tabla TblAuditoria 
lo define el alumno, no es necesario crear la tabla.
*/
Auditoria(operacion, usuario, fecha, idServ, FechaPago, importeAnterior, ImporteNuevo)

Create Trigger TR_Ej5 ON Pagos
After Update, Delete
as
begin
    if not Exists(Select * from Inserted ) and Exists (select * from Deleted)
	   Insert inTo  TblAuditoria select 'INS', USER_NAME, getdate(), D.SrvId, D.FchPago, D.Importe, 0 from Deleted D I
    
	if Exists(Select * from Inserted ) and Exists (select * from Deleted)
	   Insert inTo  TblAuditoria select 'UPD', USER_NAME, getdate(), I.SrvId, I.FchPago, D.Importe, I.Importe 
								 from Inserted I, Deleted D
								 where I.SrvId = D.SrvId and I.FchPago = D.FchPago
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

Implementar un disparador que luego de ingresada una alineación acumule las
horas del técnico y las horas del equipo utilizado.
*/
CREATE TRIGGER Ejer_3 ON Alinean
AFTER insert
AS
BEGIN
	UPDATE Tecnicos
	SET horasTec=horasTec+(SELECT SUM(horasAlin)
	FROM inserted
	WHERE inserted.idTec=Tecnicos.idTec)
	WHERE Tecnicos.idTec IN (SELECT idTec
	FROM inserted)

	UPDATE Equipos
	SET horasAcumEq=horasAcumEq+(SELECT SUM(horasAlin)
	FROM inserted
	WHERE inserted.idEq=Equipos.idEq)
	WHERE Equipos.idEq IN (SELECT idEq
	FROM inserted)
END
/*
Implementar un disparador que no permita el ingreso de alineaciones para
técnicos que tienen menos de 5 vehículos diferentes alineados en el año
corriente,
se debe dejar un registro en la tabla auditoria los casos rechazados.
*/
CREATE TRIGGER Ejer_4 ON Alinean
INSTEAD OF insert
AS
BEGIN
		INSERT INTO Auditoria SELECT getdate(),'Alinean','','',inserted.idTec
		FROM inserted,Alinean
		WHERE inserted.idTec=Alinean.idTec and
		YEAR(fchTrab)=YEAR(getdate()
		GROUP BY getdate(),'Alinean','','',inserted.idTec
		HAVING COUNT(DISTINCT(idVehic)) < 5
	ELSE
		INSERT INTO Alinean SELECT idTec, idVehic, fchAlin, horasAlin, idEq
		FROM inserted,Alinean
		WHERE inserted.idTec=Alinean.idTec 
		and YEAR(fchAlin=YEAR(getdate()
		GROUP BY idTec, idVehic, fchAlin, horasAlin, idEq
		HAVING COUNT(DISTINCT(idVehic)) >= 5
END
/*
Mediante un disparador, permitir que se borre un vehiculo.
*/
CREATE TRIGGER Ejer_5 ON Vehiculos
INSTEAD OF delete
AS
BEGIN
	DELETE
	FROM Alinean
	WHERE Alinean.idVehic IN (SELECT idVehic
							FROM deleted)

	DELETE
	FROM Vehiculos
	WHERE idVehic IN (SELECT idVehic
					FROM deleted)
END
/*
Si se modifica el sueldo de un técnico, se debe dejar constancia en la tabla
auditoria dicho cambio.
*/
CREATE TRIGGER Ejer_6 ON Tecnicos
AFTER update
AS
BEGIN
	IF UPDATE(sueldoTec)
		INSERT INTO Auditoria SELECT getdate(),'Tecnicos','sueldoTec',deleted.sueldoTec,inserted.sueldoTec,inserted.idTec
		FROM inserted,deleted
		WHERE inserted.idTec=deleted.idTec
END
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

Implementar un disparador que controle que para un vuelo el capitán no puede ser pasajero 
(es pasajero si tiene pasaje para ese vuelo). Considerar tanto inserciones como 
modificaciones. Considerar Múltiples registros, y de tal forma que debe afecte los 
registros que cumplan la condición.
*/
Create Trigger Ej5 on Vuelo
Instead Of Insert, Update
as
begin
	if Exists(select * from Inserted ) and Not Exists(select * from Deleted)
	begin --operacion disparadora Insert
		insert into Vuelo select I.* from Inserted I
		where not exists(select * from Pasaje P where P.vueId = I.vueId
		and I.capPasaporte = P.Pasaporte)
	end
	Else -- operacion disparadora Update
	begin
		update Vuelo
		set AviMod = I.AviMod, AviNro = I.AviNro ,
		capPasaporte = I.capPasaporte, vueFch = I.VueFch,
		APId_S = I.APId_S, APId_L = I.APId_L,
		vueMillas = I.vueMillas
		from vuelo V, Inserted I
		where V.vueId = I.VueId and
		not exists(select * from Pasaje P where P.vueId = I.vueId
		and I.capPasaporte = P.Pasaporte)
	end
end;
/*
Implementar un disparador que cada vez que se cambie el descuento o el precio de un pasaje 
registre en la tabla LogCtrlPasajes los datos correspondientes 
LOGCTRLPASAJES(fecha, usuario, Pasaje, PrecioAnt, PrecioNue, DescuentoAnt, DescuentoNue)
Considerar Múltiples registros.
*/
Create Trigger Ej6 on Pasaje
After Update
as
begin
	insert into LogCtrlPasajes
	select getdate(), user, I.PasjNro, D.Precio, I.Precio, D.Descuento, I.Descuento 
	from Inserted I, Deleted D 
	where I.PasjNro = D.PasjNro 
	and (I.Descuento <> D.Descuento or I.Precio <> D.Precio )
End
/*
Implementar un disparador que cada vez que se agregue o elimine un vuelo actualice la 
cantidad de vuelos que ha realizado el avión. Considerar Múltiples registros.
*/
create Trigger Ej7 on Vuelo
After Insert, Delete
as
begin
	if Exists(select * from Inserted) and Not exists(select * from Deleted)
	begin --operacion disparadora es insert
		update avion set AviCntVue = AviCntVue + 1
		from Avion A, Inserted I
		where A.aviNro = I.AviNro and A.aviMod = I.AviMod
	end
	else -- operacion disparadora es delete
	begin
		update avion set AviCntVue = AviCntVue - 1
		from Avion A, Inserted I
		where A.aviNro = I.AviNro and A.aviMod = I.AviMod
	end
end
--==========================================================================================
-- Parcial 2019-06-24 N3B
--==========================================================================================
/*
Empleados(idEmp, nomEmp, sueldoEmp, horasEmp, stsEmp)
Obras(idObra, dscObra, dirObra)
Maquinas(idMaq, dscMaq, costoHoraMaq, horasAcumMaq)
Trabajan(idTrab, idEmp, idObra, fchTrab, horasTrab, idMaq)
Auditoria(idAudit, fecha, tabla, campo, anterior, actual, clave)

Implementar un disparador que luego de ingresado un trabajo acumule las horas
trabajadas del empleado y las horas trabajadas de la máquina
*/
CREATE TRIGGER Ejer_3 ON Trabajan
AFTER insert
AS
BEGIN
	UPDATE Empleados
	SET horasEmp=horasEmp+(SELECT SUM(horasTrab)
	FROM inserted
	WHERE inserted.idEmp=Empleados.idEmp)
	WHERE empleados.idEmp IN (SELECT idEmp
	FROM inserted)

	UPDATE Maquinas
	SET horasAcumMaq=horasAcumMaq+(SELECT SUM(horasTrab)
	FROM inserted
	WHERE inserted.idMaq=Maquinas.idMaq)
	WHERE maquinas.idMaq IN (SELECT idMaq
	FROM inserted)
END
/*
Implementar un disparador que no permita el ingreso de trabajos para empleados que tienen 
más de 10 obras diferentes en el año corriente, se debe dejar un registro en la tabla 
auditoria los casos rechazados
*/
CREATE TRIGGER Ejer_4 ON Trabajan
INSTEAD OF insert
AS
BEGIN
	INSERT INTO Auditoria SELECT getdate(),'Trabajan','','',inserted.idEmp
	FROM inserted,trabajan
	WHERE inserted.idEmp=trabajan.idEmp and
	YEAR(fchTrab)=YEAR(getdate()
	GROUP BY getdate
	(),'Trabajan','','',inserted.idEmp
	HAVING COUNT(DISTINCT(idObra)) > 10

	ELSE

	INSERT INTO Trabajan SELECT idEmp, idObra, fchTrab, horasTrab, idMaq
	FROM inserted,trabajan
	WHERE inserted.idEmp=trabajan.idEmp and
	YEAR(fchTrab)=YEAR(getdate()
	GROUP BY idEmp, idObra, fchTrab, horasTrab, idMaq
	HAVING COUNT(DISTINCT(idObra)) <= 10
END
/*
Mediante un disparador, permitir que se borre un empleado.
*/
CREATE TRIGGER Ejer_5 ON Empleados
INSTEAD OF delete
AS
BEGIN
	DELETE
	FROM Trabajan
	WHERE Trabajan.idEmp IN (SELECT idEmp
	FROM deleted)

	DELETE
	FROM Empleados
	WHERE idEmp IN (SELECT idEmp
	FROM deleted)
END
/*
Si se modifica el sueldo de un empleado, se debe dejar constancia en la tabla
auditoria dicho cambio.
*/
CREATE TRIGGER Ejer_6 ON Empleados
AFTER update
AS
BEGIN
	IF UPDATE(sueldoEmp)
	BEGIN
		INSERT INTO Auditoria SELECT getdate
		(),'Empleados','sueldoEmp',deleted.sueldoEmp,inserted.sueldoEmp,inserted.idEmp
		FROM inserted,deleted
		WHERE inserted.idEmp=deleted.idEmp
	END
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

Implementar un disparador que cada vez que agreguen o eliminen ciudadanos a una encuesta 
actualice el dato de "cantidad de veces que el ciudadano fue encuestado" de la tabla 
Ciudadanos. Considere múltiples registros.
*/
Create Trigger Trg_Ej5 On EncuestaCiu
After insert, delete
As
Begin
	if Exists(select * from Inserted)
	begin
		update Ciudadanos set cantEncuestado = cantEncuestado + 1
		from Ciudadanos C, Inserted I where C.ci = I.ci;
	end
	else
	if Exists(select * from Deleted)
	begin
		update Ciudadanos set cantEncuestado = cantEncuestado - 1
		from Ciudadanos C, Deleted D where C.ci = D.ci;
	end
End
/*
Implementar un disparador que controle las encuestas asegurando que una empresa no puede 
realizar encuestas en dos ocasiones consecutivas. Considerar solo las inserciones de encuestas. 
Asegurar que solo se podrán agregar de a una encuesta por vez.
*/
Create Trigger Trg_Ej6 On Encuestas
Instead of Insert
As
Begin
	declare @idEmpresaNueva int;
	declare @idEmpresaUltima int;
	declare @añoEncNuevo int;

	if (select count(*) from Inserted ) = 1
	begin
		select @añoEncNuevo = añoEnc, @idEmpresaNueva = idEmpresaEnc from Inserted I;
		select @idEmpresaUltima = idEmpresaEnc from Encuestas order by idEnc asc;
		if @idEmpresaNueva <> @idEmpresaUltima
		begin
			insert into Encuestas(añoEnc, idEmpresaEnc)
			values (@añoEncNuevo, @idEmpresaNueva)
		end;
	end
End
/*
Implementar un disparador que solo permita eliminar encuestas de ciudadanos que correspondan 
a la encuesta del año actual. Se deben eliminar los datos asociados. Considere múltiples 
registros.
*/
Create Trigger Trg_Ej7 On EncuestaCui
Instead Of Delete
As
Begin
	Delete from Trabajos
	where IdEnc in (select IdEmp from Deleted) and
	IdEnc in (select idEnc from Encuestas where añoEnc = year(getdate()));

	Delete from Residencias
	where IdEnc in (select IdEmp from Deleted) and
	IdEnc in (select idEnc from Encuestas where añoEnc = year(getdate()));

	Delete from EncuestaCui
	where IdEnc in (select IdEmp from Deleted) and
	IdEnc in (select idEnc from Encuestas where añoEnc = year(getdate()));
End
/*
Crear una vista que muestre los departamentos con menos residentes Propietarios según 
los datos de la última encuesta realizada
*/
Create View Vista_Ej8
as
(
select R.Departamento
from Residencias R
where R.situacionRes = 'PROPIA' and
R.idEnc = (select Max(IdEnc) from Encuentas)
group by R.Departamento
having count(*) <= ALL (select count(*)
from Residencias
where situacionRes = 'PROPIA'
group by Departamento
)
/*
Crear una vista que devuelva para cada ciudadano (ci, nombre) que ha sido encuestador más 
de 2 veces, la primer y última encuesta (identificadores) en que fue encuestador.
*/
Create View Vista_Ej9
as
(
select C.ci, c.Nom, min(EC.idEnc) as 'primerEnc', max(EC.idEnc)as 'ultimaEnc'
from Ciudadanos C, EncuestasCiu EC
where C.CI = EC.ciEncuestador
group by C.CI, c.Nom
having count(distinct EC.idEnc) > 2 ))
--==========================================================================================
-- Parcial 2018-06-28 N3C
--==========================================================================================
/*
Clientes(CI, Nombre, Mail, Telefono)
Cuentas(NumCta, TipoCta, MonedaCta, SaldoCta, CI)
Movimientos(IDMovim, FchMovim, NumCta, ImporteMovim, TipoMovim)
Auditoria(IDAudit, Fecha, Tabla, Campo, Anterior, Actual, Observaciones)

Hacer un Disparador que no permita ingresar un retiro si la cuenta no tiene saldo suficiente para cubrir el
importe de dicho retiro (los retiros se hacen con inserciones simples).
*/
CREATE TRIGGER ControlSaldo ON Movimientos
INSTEAD OF insert
AS
BEGIN
	/* Inserciones SIMPLES */
	IF (SELECT TipoMovim
	FROM inserted)='RET'
		IF (SELECT SaldoCuenta
		FROM Cuentas,inserted
		WHERE Cuentas.NumCta=inserted.NumCta) >= (SELECT ImporteMovim
		FROM inserted)
			INSERT INTO Movimientos SELECT * FROM inserted
END
/*
Hacer un disparador que ante la modificación del saldo de una cuenta guarde un registro de auditoría con
todos los datos necesarios (incluir el nombre del cliente y los datos de la cuenta en observaciones), las
modificaciones pueden ser múltiples.
*/
CREATE TRIGGER ModificaSaldo ON Cuentas
AFTER UPDATE
AS
BEGIN
	IF UPDATE(SaldoCta)
		INSERT INTO Auditoria SELECT getdate(),'Cuentas','SaldoCta',deleted.SaldoCta,inserted.SaldoCta,'Cliente
		'+clientes.nombre
		FROM inserted,deleted,clientes
		WHERE inserted.NumCta=deleted.NumCta and
		inserted.ci=clientes.ci
END
/*
Hacer un disparador que permita el borrado de uno o más clientes, los que sean borrados deben quedar
registrados en la tabla auditoria.
*/
CREATE TRIGGER BorroCliente ON Clientes
INSTEAD OF delete
AS
BEGIN
	/* borro los movimientos de las cuentas de los clientes */
	DELETE
	FROM Movimientos
	WHERE NumCta IN (SELECT NumCta
	FROM Cuentas
	WHERE ci IN (SELECT ci
	FROM deleted))

	/* borro las cuentas de los clientes */
	DELETE
	FROM Cuentas
	WHERE ci IN (SELECT ci
	FROM deleted)

	/* borro los clientes */
	DELETE
	FROM Clientes
	WHERE ci IN (SELECT ci
	FROM deleted)

	/* dejo registro en auditoria */
	INSERT INTO Auditoria SELECT getdate(),'Clientes','Todos',deleted.ci,'','Se borra el cliente '+deleted.ci
	FROM deleted
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

Hacer un disparador que no permita ingresar inscripciones de alumnos a grupos si el alumno 
está inscripto en más de 5 grupos diferentes.
*/
CREATE TRIGGER noInscribir ON Inscripto
INSTEAD OF insert
AS
BEGIN
	INSERT INTO Inscripto SELECT *
	FROM inserted
	WHERE inserted.EstID not in (SELECT EstID
	FROM Inscripto
	GROUP BY EstID
	HAVING COUNT(DISTINCT(GrpID)) > 5)
END
/*
Hacer un disparador que ante la modificación del importe de una inscripción, se deje un 
registro de auditoría.
*/
CREATE TRIGGER ModificaImporte ON Inscripto
AFTER UPDATE
AS
BEGIN
	IF UPDATE(Importe)
		INSERT INTO Auditoria SELECT getdate(),'Inscripto','Importe',deleted.importe,inserted.importe,
		'Alumno '+EstID+ ' Grupo '+GrpID
		FROM inserted,deleted
		WHERE inserted.EstID=deleted.EstID and
		inserted.GrpID=deleted.GrpID and
		inserted.fchInscripto=deleted.fchInscripto
END
/*
Implementar un disparador que luego de ingresada una inscripción actualice la cantidad de 
alumnos del Grupo.
*/
CREATE TRIGGER ActualizarAlumnos ON Inscripto
AFTER insert
AS
BEGIN
	UPDATE Grupos
	SET GrpCantidad = GrpCantidad + (SELECT count(*)
		FROM inserted
		WHERE inserted.GrpId=Grupos.GrpID)
	WHERE GrpID in (SELECT GrpID
	FROM inserted)
END