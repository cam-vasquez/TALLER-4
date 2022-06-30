/* USE DB_CLINICA;

GO
CREATE OR ALTER PROCEDURE registro_cita
--Declaración de parámetros
@id_clinica INT,
@id_cliente INT,
@fecha VARCHAR(32)
AS  
BEGIN 
    --conteo de ID existentes para autogenerar ID próximo
    DECLARE @n_citas INT;
    SELECT @n_citas = COUNT(id)
    FROM CITA;

    INSERT INTO CITA (id, id_clinica, id_cliente, fecha) VALUES (@n_citas +1, @id_clinica, @id_cliente, CONVERT(DATETIME, @fecha, 103));
END;
GO

EXECUTE registro_cita
    @id_clinica = 1,
    @id_cliente = 3,
    @fecha = '20-05-2022 09:00:00.000';
GO

DROP PROCEDURE registro_cita;
GO


---------------------------------------------------------------

CREATE OR ALTER TRIGGER CHECK_CITAS
ON CITA
AFTER INSERT 
AS BEGIN
    --Declaración de variables
    DECLARE @id_clinica INT;
    DECLARE @fecha DATETIME;
    DECLARE @n_citas INT;
    DECLARE @n_consultorios INT;
    DECLARE @n_doctores INT;

    --conteo y almacenamiento del número de citas por clinica
    SELECT @id_clinica = I.id_clinica, @fecha = I.fecha  FROM INSERTED I;
    SELECT @n_citas = COUNT(CI.id)
    FROM CITA CI
    WHERE CI.id_clinica = @id_clinica AND CI.fecha = @fecha;

    --conteo y almacenamiento del número de consultorios por clinica
    SELECT @n_consultorios = COUNT(CN.id)
    FROM CONSULTORIO CN
    INNER JOIN CLINICA CL
    ON CN.id_clinica = CL.id
    WHERE CL.id = @id_clinica;

    --conteo y almacenamiento de número de doctores por clinica
    SELECT @n_doctores = COUNT(CO.id)
    FROM CONTRATO CO
    WHERE CO.id_clinica = @id_clinica AND CAST(@FECHA AS TIME) BETWEEN CAST(SUBSTRING(horario, 0,8) AS TIME) AND CAST(SUBSTRING(horario,11,17) AS TIME);

    --validación de número de citas a consultorio
    IF(@n_citas <= @n_consultorios)
    BEGIN

        --validación de número de citas a dodctores
        IF(@n_citas <= @n_doctores)
            PRINT 'CITA ALMACENADA CORRECTAMENTE';
        ELSE
        BEGIN
            PRINT 'NO SE HA PODIDO GUARDAR EL REGISTRO DE LA CITA, NÚMERO INSUFICIENTE DE DOCTORES'; 
            ROLLBACK TRANSACTION;
        END;
    END;
    ELSE
    BEGIN
        PRINT 'NO SE HA PODIDO GUARDAR EL REGISTRO DE LA CITA, NÚMERO INSUFICIENTE DE CONSULTORIOS'; 
        ROLLBACK TRANSACTION;
    END;

END;
GO

DROP TRIGGER CHECK_CITAS
GO

--PRUEBA 01 SE EJECUTA Y GUARDA

 */