USE [BDSidtefim-Test]
GO

/*► dbo.usp_Rim_Procedimiento_DynamicJoinStatement ...*/
/*-----------------------------------------------------------------------------------------------------------------------*/
CREATE OR ALTER PROCEDURE dbo.usp_Rim_Procedimiento_DynamicSelectStatement
(
	@queryString NVARCHAR(MAX)
)
AS
BEGIN
	EXEC SP_EXECUTESQL @queryString
END

/*► Test ...*/
--SimMovMigra
EXEC dbo.usp_Rim_Procedimiento_DynamicSelectStatement 'SELECT * FROM SidInterpol'
/*-----------------------------------------------------------------------------------------------------------------------*/

USE [BDSidtefim-Test]
GO

SELECT * FROM RimGrupoCamposAnalisis
UPDATE RimGrupoCamposAnalisis
SET bObligatorio = 0

SELECT TOP 50000 * FROM RimTipoLogico

SELECT TOP 10 * FROM Rim_Test_2022

SELECT * FROM RimProduccionAnalisis