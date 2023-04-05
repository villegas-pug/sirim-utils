USE [BDSidtefim-Test]
GO

/*» dbo.usp_Rim_Procedimiento_ListarTablaDinamicaPorRangos ... */
/*-----------------------------------------------------------------------------------------------------------------------*/
CREATE OR ALTER PROCEDURE dbo.usp_Rim_Procedimiento_ListarTablaDinamicaPorRangos
(
	@idAsigGrupo INT,
	@rIni INT,
	@rFin INT
)
AS
BEGIN
	-- Dep's ...
	DECLARE @sql NVARCHAR(MAX) = '',
			@restSql NVARCHAR(MAX) = '',
			@nombreTabla VARCHAR(55) = '',
			@fechaAsignacion DATE = '',
			@TotalRecords SMALLINT = '',
			-- @currentDate DATE = GETDATE(),
			@currentDate DATE = '2022-09-24',
			--@workStartTime TINYINT = 8,
			@workStartTime TINYINT = 19,
			@workHoursPerDay TINYINT = 8,
			@currentHour SMALLINT = 0,
			@recordsPerHour SMALLINT = 0

	-- Initialize dep's ...
	SET @TotalRecords = (@rFin - @rIni) + 1
	SET @currentHour = CONVERT(SMALLINT, CONVERT(CHAR(2), GETDATE(), 8))
	SET @recordsPerHour = @TotalRecords / @workHoursPerDay

	SELECT 
		@nombreTabla = rt.sNombre,
		-- @fechaAsignacion = CONVERT(DATE, ra.dFechaAsignacion)
		@fechaAsignacion = '2022-09-25'
	FROM RimTablaDinamica rt
	JOIN RimGrupoCamposAnalisis rg ON rt.nIdTabla = rg.nIdTabla
	JOIN RimAsigGrupoCamposAnalisis ra ON rg.nIdGrupo = ra.nIdGrupo
	WHERE 
		ra.nIdAsigGrupo = @idAsigGrupo

	SET @restSql = CONCAT(N' * FROM ', @nombreTabla, ' WHERE nId BETWEEN ', @rIni, ' AND ', @rFin)

	IF (@fechaAsignacion = @currentDate)
		--IF(@currentHour >= 13)-- After or equal break time ...
		IF(@currentHour >= 20)-- After or equal break time ...
			SET @sql = CONCAT(N'SELECT TOP ', ((@currentHour - @workStartTime)) * @recordsPerHour, @restSql)
		ELSE
			SET @sql = CONCAT(N'SELECT TOP ', ((@currentHour - @workStartTime) + 1) * @recordsPerHour, @restSql)
	ELSE
		SET @sql = CONCAT(N'SELECT ', @restSql)

	-- ...
	BEGIN TRY
		BEGIN TRAN
		EXEC SP_EXECUTESQL @sql
		COMMIT TRAN
	END TRY
	BEGIN CATCH
		ROLLBACK TRAN
		PRINT ERROR_MESSAGE()
	END CATCH
END


/*» Test ...*/
EXEC dbo.usp_Rim_Procedimiento_ListarTablaDinamicaPorRangos @idAsigGrupo = 127, @rIni = 1, @rFin = 140

/*-----------------------------------------------------------------------------------------------------------------------*/

/*» dbo.usp_Rim_Procedimiento_ListarTablaDinamicaPorRangos v2 ... */
/*-----------------------------------------------------------------------------------------------------------------------*/
CREATE OR ALTER PROCEDURE dbo.usp_Rim_Procedimiento_ListarTablaDinamicaPorRangos
(
	@idAsigGrupo INT,
	@rIni INT,
	@rFin INT
)
AS
BEGIN

	-- Dep's ...
	DECLARE @sql NVARCHAR(MAX) = '',
			@nombreTabla VARCHAR(55) = ''

	SELECT 
		@nombreTabla = rt.sNombre
	FROM RimTablaDinamica rt
	JOIN RimGrupoCamposAnalisis rg ON rt.nIdTabla = rg.nIdTabla
	JOIN RimAsigGrupoCamposAnalisis ra ON rg.nIdGrupo = ra.nIdGrupo
	WHERE 
		ra.nIdAsigGrupo = @idAsigGrupo

	SET @sql = 'SELECT * FROM ('
	SET @sql = CONCAT(@sql, ' SELECT * FROM ', @nombreTabla)
	SET @sql = CONCAT(@sql, ' WHERE nId BETWEEN ', @rIni, ' AND ', @rFin)
	SET @sql = CONCAT(@sql, ' UNION ALL ')
	SET @sql = CONCAT(@sql, ' SELECT * FROM ', @nombreTabla)
	SET @sql = CONCAT(@sql, ' WHERE nSubId BETWEEN ', @rIni, ' AND ', @rFin)
	SET @sql = CONCAT(@sql, ') AS td')
	SET @sql = CONCAT(@sql, ' ORDER BY CASE WHEN td.nSubId >= 1 THEN td.nSubId ELSE td.nId END')

	EXEC SP_EXECUTESQL @sql

	-- SET @sql = CONCAT(@sql, ' ORDER BY CASE WHEN nSubId >= 1 THEN nSubId ELSE nId END')

END

/*» Test ...*/
SELECT * FROM (
	SELECT * FROM RimTablaDinamica
) AS td
ORDER BY td.sNombre

EXEC dbo.usp_Rim_Procedimiento_ListarTablaDinamicaPorRangos @idAsigGrupo = 127, @rIni = 1, @rFin = 100
/*-----------------------------------------------------------------------------------------------------------------------*/

/*» dbo.usp_Rim_Procedimiento_Analisis_NuevoRegistroVinculado ... */
/*-----------------------------------------------------------------------------------------------------------------------*/
CREATE OR ALTER PROCEDURE dbo.usp_Rim_Procedimiento_Analisis_NuevoRegistroVinculado
(
	@nombreTabla VARCHAR(100),
	@id INT
)
AS
BEGIN

	-- Dep's ...
	DECLARE @fields VARCHAR(MAX),
			@sql NVARCHAR(MAX)

	SET @fields = (SELECT STRING_AGG(isc.COLUMN_NAME, ',') FROM INFORMATION_SCHEMA.COLUMNS isc
					WHERE 
						isc.TABLE_NAME = @nombreTabla
						AND isc.COLUMN_NAME != 'nId')

	BEGIN TRY

		BEGIN TRAN
		-- Insert new record ...
		SET @sql = CONCAT('INSERT INTO ', @nombreTabla, '(', @fields, ') ')
		SET @sql = CONCAT(@sql, 'SELECT ', @fields, ' FROM ', @nombreTabla, ' WHERE nId = ', @id)
		EXEC SP_EXECUTESQL @sql

		-- Update main record ...
		SET @sql = CONCAT(' UPDATE ', @nombreTabla)
		SET @sql = CONCAT(@sql, ' SET nSubId = ', @id)
		SET @sql = CONCAT(@sql, ' WHERE nId = ', @@IDENTITY)
		EXEC SP_EXECUTESQL @sql

		COMMIT TRAN

	END TRY
	BEGIN CATCH
		PRINT ERROR_MESSAGE()
		ROLLBACK TRAN
	END CATCH

END

USE [BDSidtefim-Test]

-- Test ...
SELECT * FROM Rim_Test_2022
UPDATE Rim_Test_2022
	SET nSubId = 0

EXEC dbo.usp_Rim_Procedimiento_Analisis_NuevoRegistroVinculado 'Rim_Test_2022', 1

SELECT * FROM Rim_Test_2022

USE [BDSidtefim-Test]
GO

SELECT COUNT(1) FROM RimPasaporte


/*-----------------------------------------------------------------------------------------------------------------------*/