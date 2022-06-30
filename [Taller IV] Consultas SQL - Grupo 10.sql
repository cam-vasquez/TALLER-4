USE DB_CLINICA;
GO
-- **************************************

-- **************************************
/*   

Crear un procedimiento almacenado que se encargue de almacenar nuevas citas en la tabla CITA. El procedimiento tendrá 3 parámetros de entrada: id válido de una clínica (INT). id válido de un cliente (INT). fecha (VARCHAR 32) compatible con el formato DATETIME con el estilo: ‘dd/mm/yyyy hh:mm:ss:000’.

Distintos clientes pueden realizar varias citas en una clínica específica, ya que cada clínica dispone de los servicios de varios médicos, además cada clínica cuenta con una serie de consultorios en donde podrán realizarse las consultas. Por lo tanto, para poder almacenar una cita, es necesario realizar dos validaciones generales:

1. El procedimiento almacenado debe verificar cuantas citas se han realizado en la clínica y hora especificadas en los parámetros de entrada, una vez realizada esta acción, el procedimiento debe definir si la clínica aún cuenta con más consultorios disponibles para poder registrar citas en la misma fecha y hora. Si la clínica no cuenta con consultorio disponible entonces el procedimiento almacenado imprimirá un error explicando la situación. Por otro lado, si existen consultorios disponibles, el procedimiento deberá realizar la segunda validación.

2. Cada clínica cuenta con una cantidad determinada de médicos, el equipo de médicos no es necesariamente igual a la cantidad de consultorios de la clínica, por lo tanto, el procedimiento almacenado deberá definir si existen médicos disponibles a la hora especificada. Esta validación dependerá de la cantidad de médicos de la clínica y el horario de trabajo de cada uno. Si la clínica no cuenta con un médico disponible entonces el procedimiento almacenado imprimirá un error explicando la situación. Por otro lado, si existen médicos disponibles, el procedimiento almacenará la cita en la tabla CITA y mostrará un mensaje de que la reserva ha sido exitosa. Nota: la segunda validación debe tomar en cuenta no solo la cantidad de médicos disponibles de un clínica, si no también el horario de trabajo de cada médico, por ejemplo, no se pueden realizar citas a las 7:00am porque ninguna clínica tiene un médico trabajando a esa hora. Cada cita debe reservarse dentro del horario de trabajo de los médicos disponibles. 
1 - Validación de citas registradas actualmente
2 - Validación de consultorios disponibles
3 - Validación de médicos disponibles

*/

SELECT * FROM CLINICA;
GO


-- * Num de citas por clinica
SELECT cl.id, cl.nombre, COUNT(ct.id) 'num de citas'
FROM CITA ct
INNER JOIN CLINICA cl
	ON cl.id = ct.id_clinica
GROUP BY cl.id, cl.nombre;
GO

--*  Num de consultorios por clinica
SELECT cl.id 'Id Clinica', cl.nombre, COUNT(cl.id) 'Num de consultorio'
FROM CLINICA cl
INNER JOIN CONSULTORIO csl
	ON cl.id = csl.id_clinica
GROUP BY cl.id, cl.nombre;
GO

-- * Num de doctores por clinica
SELECT cl.id, cl.nombre, COUNT(md.id) 'num de doctores'
FROM MEDICO md
INNER JOIN CONTRATO con
	ON con.id_medico = md.id
INNER JOIN CLINICA cl
	ON cl.id = con.id_clinica
GROUP BY cl.id, cl.nombre;
GO

SELECT * FROM MEDICO;
GO

--------------------------------------------

CREATE OR ALTER PROCEDURE VERIFYING_AVAILABILITY
	@id_clinica INT,
	@id_cliente INT,
	@fecha VARCHAR(32)
AS 
BEGIN
	---* Validación de citas registradas actualmente
	DECLARE @num_cita INT;
	SELECT @num_cita = COUNT(id) FROM CITA;
	/* DECLARE @fecha_consulta datetime
	SET @fecha_consulta = GETDATE()
	SELECT CONVERT(varchar, @fecha_consulta, 21) */
BEGIN TRY
INSERT INTO CITA(id, id_clinica, id_cliente, fecha) VALUES(@num_cita +1, @id_clinica, @id_cliente, CONVERT(DATETIME, @fecha, 103))
	PRINT 'La cita ha sido almacendad exitosamente';
END TRY
BEGIN CATCH
		PRINT ERROR_MESSAGE();
	END CATCH;
END;
GO

EXEC VERIFYING_AVAILABILITY 1,3,'20-05-2022 09:00:00.000';
GO

DROP PROCEDURE VERIFYING_AVAILABILITY;



-- 1.1.	Crear un procedimiento almacenado que permita registrar nuevas reservas
--		Como argumentos se reciben: el la fecha de checkin y checkout, el id del cliente
--		y el id de la habitacion.
--		NOTA: Validar que la nueva reserva no se solape con otras reservas

/* GO

https://github.com/DouglasHdezT/BDD_scripts_01_22/blob/master/2022%2006%2023/solution.sql

GO
CREATE OR ALTER PROCEDURE BOOKING 
	@id INT,
	@checkin VARCHAR(12),
	@checkout VARCHAR(12),
	@id_metodo_pago INT,
	@id_cliente INT,
	@id_habitacion INT
AS
BEGIN
	BEGIN TRY
		INSERT INTO RESERVA VALUES(@id,CONVERT(DATE, @checkin, 103),CONVERT(DATE, @checkout, 103),@id_metodo_pago,@id_cliente,@id_habitacion);		
	END TRY
	BEGIN CATCH
		PRINT ERROR_MESSAGE();
	END CATCH;
END;
GO

CREATE OR ALTER TRIGGER CHECK_BOOKING
ON RESERVA
AFTER INSERT
AS BEGIN
		--declarando variables
		DECLARE @checkin DATETIME;
		DECLARE @checkout DATETIME;
		DECLARE @id_habitacion INT;
		DECLARE @resultado INT;
		--obteniendo datos desde tabla inserted
		SELECT @id_habitacion=i.id_habitacion, @checkin=i.checkin, @checkout=i.checkout FROM inserted i;
		SELECT @resultado = COUNT(*) FROM RESERVA 
		WHERE 
			((@checkin < checkin AND (@checkout BETWEEN checkin AND checkout)) OR
			((@checkin BETWEEN checkin AND checkout) AND @checkout > checkout) OR
			(@checkin >= checkin AND @checkout <= checkout) OR
			(checkin >= @checkin AND checkout <= @checkout)) AND
			id_habitacion = @id_habitacion;
	IF @resultado > 1
	BEGIN 
		RAISERROR ('ERROR: Consulta invalida, la habitacion ya ha sido reservada en la fecha establecida...' ,11,1)
		ROLLBACK TRANSACTION
	END;
END;

-- Ejecutando procedimiento almacenado
-- DELETE FROM RESERVA WHERE id = 201 OR id = 202;
EXEC BOOKING 201, '01/07/2022', '05/07/2022',1,13,3; --funciona
EXEC BOOKING 202, '01/07/2022', '05/07/2022',2,9,3; 
EXEC BOOKING 202, '04/07/2022', '08/07/2022',2,9,3;
EXEC BOOKING 202, '29/06/2022', '02/07/2022',2,9,3;
EXEC BOOKING 202, '29/06/2022', '02/07/2022',2,9,5; -- Funciona

SELECT * FROM RESERVA WHERE id_habitacion = 3

*/

