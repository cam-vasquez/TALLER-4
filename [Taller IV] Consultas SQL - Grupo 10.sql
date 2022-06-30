USE DB_CLINICA;
GO

/*   

Crear un procedimiento almacenado que se encargue de almacenar nuevas citas en la tabla CITA. El procedimiento tendrá 3 parámetros de entrada: id válido de una clínica (INT). id válido de un cliente (INT). fecha (VARCHAR 32) compatible con el formato DATETIME con el estilo: ‘dd/mm/yyyy hh:mm:ss:000’.

Distintos clientes pueden realizar varias citas en una clínica específica, ya que cada clínica dispone de los servicios de varios médicos, además cada clínica cuenta con una serie de consultorios en donde podrán realizarse las consultas. Por lo tanto, para poder almacenar una cita, es necesario realizar dos validaciones generales:

1. El procedimiento almacenado debe verificar cuantas citas se han realizado en la clínica y hora especificadas en los parámetros de entrada, una vez realizada esta acción, el procedimiento debe definir si la clínica aún cuenta con más consultorios disponibles para poder registrar citas en la misma fecha y hora. Si la clínica no cuenta con consultorio disponible entonces el procedimiento almacenado imprimirá un error explicando la situación. Por otro lado, si existen consultorios disponibles, el procedimiento deberá realizar la segunda validación.*/

---*********************************


CREATE OR ALTER PROCEDURE BOOKING
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
*/
--- ***************************************

-- Ejecutando procedimiento almacenado

EXEC BOOKING 1, 3,'20-05-2022 09:00:00.000';
GO
EXEC BOOKING 1, 6, '20-05-2022 09:00:00.000';
GO
EXEC BOOKING 6, 6,'21-05-2022 09:00:00.000';
GO
---***************************************

/* 2. Cada clínica cuenta con una cantidad determinada de médicos, el equipo de médicos no es necesariamente igual a la cantidad de consultorios de la clínica, por lo tanto, el procedimiento almacenado deberá definir si existen médicos disponibles a la hora especificada. Esta validación dependerá de la cantidad de médicos de la clínica y el horario de trabajo de cada uno. Si la clínica no cuenta con un médico disponible entonces el procedimiento almacenado imprimirá un error explicando la situación. Por otro lado, si existen médicos disponibles, el procedimiento almacenará la cita en la tabla CITA y mostrará un mensaje de que la reserva ha sido exitosa. Nota: la segunda validación debe tomar en cuenta no solo la cantidad de médicos disponibles de un clínica, si no también el horario de trabajo de cada médico, por ejemplo, no se pueden realizar citas a las 7:00am porque ninguna clínica tiene un médico trabajando a esa hora. Cada cita debe reservarse dentro del horario de trabajo de los médicos disponibles. 

1 - Validación de citas registradas actualmente
2 - Validación de consultorios disponibles
3 - Validación de médicos disponibles
 */


CREATE OR ALTER TRIGGER CHECK_BOOKING ON CITA AFTER INSERT
AS BEGIN
	-- Declarando Variables
	DECLARE @id_clinica INT;
	DECLARE @id_cliente INT;
	DECLARE @id_cita INT;
	DECLARE @fecha VARCHAR(32);
	
-- * Validando Num de citas por clinica
	DECLARE @num_cita INT;	
	SELECT @id_cita = i.id, @id_clinica = i.id_clinica, @id_cliente = i.id_cliente, @fecha = i.fecha FROM inserted i;
	SELECT @num_cita = COUNT(ct.id) FROM CITA ct
	INNER JOIN CLINICA cl
		ON cl.id = ct.id_clinica
	WHERE ct.id_clinica = @id_clinica AND ct.fecha = @fecha;

	-- Validando num de consultorio
	DECLARE @num_consultorio INT;
	SELECT @num_consultorio = COUNT(cl.id) FROM CLINICA cl
	INNER JOIN CONSULTORIO csl
		ON cl.id = csl.id_clinica
	WHERE cl.id = @id_clinica;

	-- Validando num de medicos
	DECLARE @num_med INT;
	SELECT @num_med = COUNT(md.id) 
	FROM MEDICO md
	INNER JOIN CONTRATO con
		ON con.id_medico = md.id
	INNER JOIN CLINICA cl
		ON cl.id = con.id_clinica
	WHERE con.id_clinica = @id_clinica AND CAST(@fecha AS TIME) BETWEEN CAST(SUBSTRING(horario, 0,8) AS TIME) AND CAST(SUBSTRING(horario,11,17) AS TIME);

	--* Validando
	IF(@num_cita <= @num_consultorio)
		BEGIN
				IF(@num_cita <= @num_med)
			BEGIN
				PRINT 'La cita ha sido almacendad exitosamente';	
			END;
				ELSE
			BEGIN
				PRINT 'ERROR: No es posible registrar la cita porque no hay medicos disponibles';
				ROLLBACK TRANSACTION;
			END;
		END;
		ELSE
    		BEGIN
				PRINT 'ERROR: No es posible registrar la cita porque no hay consultorios disponibles';
       			ROLLBACK TRANSACTION;
    		END;
END; 
GO






/* 
---******************************
CONSULTAS CON JOINS 
-- * Num de citas por clinica
SELECT cl.id, cl.nombre, COUNT(ct.id) 'num de citas'
FROM CITA ct
INNER JOIN CLINICA cl
	ON cl.id = ct.id_clinica
GROUP BY cl.id, cl.nombre;
GO
-- sa
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
*/
