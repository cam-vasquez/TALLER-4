USE DB_CLINICA;

/*   

                        ------------       CONSULTA 1      ----------------------------

El procedimiento almacenado debe verificar cuántas citas se han realizado en la clínica y hora especificadas en los parámetros de entrada, una vez realizada esta acción, el procedimiento debe definir si la clínica aún cuenta con más consultorios disponibles para poder registrar citas en la misma fecha y hora. Si la clínica no cuenta con consultorio disponible entonces el procedimiento almacenado imprimirá un error explicando la situación. Por otro lado, si existen consultorios disponibles, el procedimiento deberá realizar la segunda validación.
*/

/*
            
                        ---------------          CONSULTA 2      ---------------


Cada clínica cuenta con una cantidad determinada de médicos, el equipo de médicos no es necesariamente igual a la cantidad de consultorios de la clínica, por lo tanto, el procedimiento almacenado deberá definir si existen médicos disponibles a la hora especificada. Esta validación dependerá de la cantidad de médicos de la clínica y el horario de trabajo de cada uno. Si la clínica no cuenta con un médico disponible entonces el procedimiento almacenado imprimirá un error explicando la situación. Por otro lado, si existen médicos disponibles, el procedimiento almacenará la cita en la tabla CITA y mostrará un mensaje de que la reserva ha sido exitosa. Nota: la segunda validación debe tomar en cuenta no solo la cantidad de médicos disponibles de un clínica, si no también el horario de trabajo de cada médico, por ejemplo, no se pueden realizar citas a las 7:00am porque ninguna clínica tiene un médico trabajando a esa hora. Cada cita debe reservarse dentro del horario de trabajo de los médicos disponibles. */