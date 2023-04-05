--BEGIN TRANSACTION
--ROLLBACK TRANSACTION
--COMMIT TRANSACTION
INSERT INTO SidDependencia(sNombre, bActivo) VALUES('LIMA', 1)
INSERT INTO SidDependencia(sNombre, bActivo) VALUES('ANCON', 1)
INSERT INTO SidDependencia(sNombre, bActivo) VALUES('ATE', 1)
INSERT INTO SidDependencia(sNombre, bActivo) VALUES('BARRANCO', 1)
INSERT INTO SidDependencia(sNombre, bActivo) VALUES('BREÑA', 1)
INSERT INTO SidDependencia(sNombre, bActivo) VALUES('CARABAYLLO', 1)
INSERT INTO SidDependencia(sNombre, bActivo) VALUES('CHACLACAYO', 1)
INSERT INTO SidDependencia(sNombre, bActivo) VALUES('CHORRILLOS', 1)
INSERT INTO SidDependencia(sNombre, bActivo) VALUES('CIENEGUILLA', 1)
INSERT INTO SidDependencia(sNombre, bActivo) VALUES('COMAS', 1)
INSERT INTO SidDependencia(sNombre, bActivo) VALUES('EL AGUSTINO', 1)
INSERT INTO SidDependencia(sNombre, bActivo) VALUES('INDEPENDENCIA', 1)
INSERT INTO SidDependencia(sNombre, bActivo) VALUES('JESUS MARIA', 1)
INSERT INTO SidDependencia(sNombre, bActivo) VALUES('LA MOLINA', 1)
INSERT INTO SidDependencia(sNombre, bActivo) VALUES('LA VICTORIA', 1)
INSERT INTO SidDependencia(sNombre, bActivo) VALUES('LINCE', 1)
INSERT INTO SidDependencia(sNombre, bActivo) VALUES('LOS OLIVOS', 1)
INSERT INTO SidDependencia(sNombre, bActivo) VALUES('LURIGANCHO', 1)
INSERT INTO SidDependencia(sNombre, bActivo) VALUES('LURIN', 1)
INSERT INTO SidDependencia(sNombre, bActivo) VALUES('MAGDALENA DEL MAR', 1)
INSERT INTO SidDependencia(sNombre, bActivo) VALUES('PUEBLO LIBRE (MAGDALENA VIEJA)', 1)
INSERT INTO SidDependencia(sNombre, bActivo) VALUES('MIRAFLORES', 1)
INSERT INTO SidDependencia(sNombre, bActivo) VALUES('PACHACAMAC', 1)
INSERT INTO SidDependencia(sNombre, bActivo) VALUES('PUCUSANA', 1)
INSERT INTO SidDependencia(sNombre, bActivo) VALUES('PUENTE PIEDRA', 1)
INSERT INTO SidDependencia(sNombre, bActivo) VALUES('PUNTA HERMOSA', 1)
INSERT INTO SidDependencia(sNombre, bActivo) VALUES('PUNTA NEGRA', 1)
INSERT INTO SidDependencia(sNombre, bActivo) VALUES('RIMAC', 1)
INSERT INTO SidDependencia(sNombre, bActivo) VALUES('SAN BARTOLO', 1)
INSERT INTO SidDependencia(sNombre, bActivo) VALUES('SAN BORJA', 1)
INSERT INTO SidDependencia(sNombre, bActivo) VALUES('SAN ISIDRO', 1)
INSERT INTO SidDependencia(sNombre, bActivo) VALUES('SAN JUAN DE LURIGANCHO', 1)
INSERT INTO SidDependencia(sNombre, bActivo) VALUES('SAN JUAN DE MIRAFLORES', 1)
INSERT INTO SidDependencia(sNombre, bActivo) VALUES('SAN LUIS', 1)
INSERT INTO SidDependencia(sNombre, bActivo) VALUES('SAN MARTIN DE PORRES', 1)
INSERT INTO SidDependencia(sNombre, bActivo) VALUES('SAN MIGUEL', 1)
INSERT INTO SidDependencia(sNombre, bActivo) VALUES('SANTA ANITA', 1)
INSERT INTO SidDependencia(sNombre, bActivo) VALUES('SANTA MARIA DEL MAR', 1)
INSERT INTO SidDependencia(sNombre, bActivo) VALUES('SANTA ROSA', 1)
INSERT INTO SidDependencia(sNombre, bActivo) VALUES('SANTIAGO DE SURCO', 1)
INSERT INTO SidDependencia(sNombre, bActivo) VALUES('SURQUILLO', 1)
INSERT INTO SidDependencia(sNombre, bActivo) VALUES('VILLA EL SALVADOR', 1)
INSERT INTO SidDependencia(sNombre, bActivo) VALUES('VILLA MARIA DEL TRIUNFO', 1)
INSERT INTO SidDependencia(sNombre, bActivo) VALUES('BARRANCO', 1)
INSERT INTO SidDependencia(sNombre, bActivo) VALUES('ASIA', 1)
INSERT INTO SidDependencia(sNombre, bActivo) VALUES('CERRO AZUL', 1)
INSERT INTO SidDependencia(sNombre, bActivo) VALUES('CALLAO', 1)
INSERT INTO SidDependencia(sNombre, bActivo) VALUES('CERCADO DE LIMA', 1)


/*» Alter Table: SidOperativo ...*/
EXEC sp_rename 'SidOperativo.nIdDistrito', 'nIdDependencia'

/*» Alter Table: SidDependencia ...*/
EXEC sp_rename 'SidDependencia.sIdDependencia', 'nIdDependencia'

/*» Remove Column: SidOperativo.nEdad ...*/
ALTER TABLE SidDetOperativo
	DROP COLUMN nEdad

/*» Alter Column: SidOperativo[sNumeroInforme] ...*/
ALTER TABLE SidOperativo
	ALTER COLUMN sNumeroInforme VARCHAR(55) NULL

/*» Alter Column: SidOperativo[sAlertaMigratoria] ...*/
ALTER TABLE SidDetOperativo
	ALTER COLUMN sAlertaMigratoria VARCHAR(40) NULL

/*» Update SidUsuario: SidUsuario[nIdDependencia]*/
UPDATE SidUsuario SET nIdDependencia = 1

/*» Update SidDetOperativo: SidDetOperativo[sSexo]*/
UPDATE SidDetOperativo SET sSexo= 'FEMENINO'
	WHERE sSexo = 'F'
UPDATE SidDetOperativo SET sSexo= 'MASCULINO'
	WHERE sSexo = 'M'
	

SELECT * FROM SidOperativo WHERE nIdOperativo = 148
SELECT * FROM SidDetOperativo WHERE nIdOperativo = 148
UPDATE SidDetOperativo SET sInfraccion = 'SI'
	WHERE nIdDetOperativo = 17170
SELECT so.sSexo, COUNT(nIdOperativo) FROM SidDetOperativo so GROUP BY so.sSexo
SELECT * FROM SidDependencia WHERE sNombre = 'LIma'
SELECT * FROM SidUsuario