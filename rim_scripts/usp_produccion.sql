SELECT * FROM SidUsuario
SELECT * FROM SidProduccion
SELECT * FROM SidDetProduccion


ALTER PROCEDURE spu_Sid_Produccion_ContarActividadSemanaActual
(
	@userName VARCHAR(55)
)
AS
BEGIN
	
	DECLARE @tmp_produccion TABLE
	(
		id INT IDENTITY(1, 1),
		fecha DATE,
		dia INT,
		contarActividad INT
	)

	DECLARE @countDay INT = 1,
			@countActividadByDay INT,
			@todayOfWeekNumber INT,
			@firstDayOfWeekDate DATE


	SET @todayOfWeekNumber = DATEPART(WEEKDAY, GETDATE()) - 2
	SET @firstDayOfWeekDate = DATEADD(DAY, -@todayOfWeekNumber, GETDATE())

	WHILE @countDay <= 5
	BEGIN 
	
		DECLARE @dateInsideLoop DATE = DATEADD(DAY, @countDay - 1, @firstDayOfWeekDate)
		SET @countActividadByDay = (
						SELECT COUNT(1) FROM SidProduccion sp
						JOIN SidUsuario su ON sp.uIdUsuario = su.uIdUsuario
						WHERE sp.dFechaRegistro = @dateInsideLoop
						AND su.sLogin = @userName
					)

		INSERT 
			INTO @tmp_produccion(dia, contarActividad, fecha)
			VALUES (@countDay, @countActividadByDay, @dateInsideLoop)

		SET @countDay = @countDay + 1
	END

	SELECT * FROM @tmp_produccion
END

/*» TEST...*/
EXEC spu_Sid_Produccion_ContarActividadSemanaActual 'rguevarav'

SELECT * FROM SidProduccion

UPDATE SidProduccion
	SET dFechaRegistro = DATEADD(DAY, -1, dFechaRegistro)
	WHERE nIdProduccion = 2
SELECT * FROM SidProduccion
/*-----------------------------------------------------------------------------------------------------------------------------------*/

/*» */
/*-----------------------------------------------------------------------------------------------------------------------------------*/
ALTER PROCEDURE spu_Sid_Rpt_ActividadSemanal
(
	@refDate DATE
)
AS
BEGIN
	DECLARE @todayOfWeekNumber INT,
			@firstDayOfWeekDate DATE,
			@lastDayOfWeekDate DATE

	SET @todayOfWeekNumber  = DATEPART(WEEKDAY, @refDate) - 2
	SET @firstDayOfWeekDate = DATEADD(DAY, - @todayOfWeekNumber, @refDate)
	SET @lastDayOfWeekDate  = DATEADD(DAY, 4, @firstDayOfWeekDate)

	;WITH tmp_produccion
	AS
	(
		SELECT
			(sp.dFechaRegistro)dFechaRegistro,
			(su.sNombres)nombres,
			(su.sDni)dni,
			(su.sCargo)cargo,
			FLOOR((sp.nGradoAvanceDiarioEjecutado * 100))gradoAvanceDiarioEjecutado,
			(su.sRegimenLaboral)regimenLaboral,
			'- ' + STRING_AGG(sdp.sDescripcionActividad, CHAR(10) + '- ')descripcionActividad,
			'- ' + STRING_AGG(sdp.sAccionDesarrollada, CHAR(10) + '- ')accionDesarrollada
		FROM SidProduccion sp
		JOIN SidUsuario su ON sp.uIdUsuario = su.uIdUsuario
		JOIN SidDetProduccion sdp ON sp.nIdProduccion = sdp.nIdProduccion
		WHERE 
			sp.dFechaRegistro BETWEEN @firstDayOfWeekDate AND @lastDayOfWeekDate
		GROUP BY
			(sp.dFechaRegistro),
			su.sNombres,
			su.sDni,
			su.sCargo,
			sp.nGradoAvanceDiarioEjecutado,
			su.sRegimenLaboral
	)

	SELECT 
		ROW_NUMBER() OVER(ORDER BY tmp_2.nombres ASC) AS id,
		tmp_2.*
	FROM
	(
		SELECT
			tmp.nombres,
			tmp.dni,
			tmp.cargo,
			SUM(tmp.gradoAvanceDiarioEjecutado)gradoAvanceDiarioEjecutado,
			tmp.regimenLaboral,
			STRING_AGG(tmp.descripcionActividad, '')descripcionActividad,
			STRING_AGG(tmp.accionDesarrollada, '')accionDesarrollada
		FROM tmp_produccion tmp
		GROUP BY
				tmp.nombres,
				tmp.dni,
				tmp.cargo,
				tmp.regimenLaboral
	) tmp_2

END

/*» TEST... */
EXEC spu_Sid_Rpt_ActividadSemanal '20210520'
/*-----------------------------------------------------------------------------------------------------------------------------------*/

-- ===================================================================================================================================
-- usp_Rim_Admin_Rpt_Produccion
-- ===================================================================================================================================
USE [BDSidtefim-Test]
GO

CREATE OR ALTER PROCEDURE usp_Rim_Rpt_S10_DRCM_FR001_Produccion
(
	@nombreTabla VARCHAR(100),
	@fecIni DATE,
	@fecFin DATE,
	@isRoot BIT,
	@idAsig INT = 0
)
AS
BEGIN
	-- Dep's ...
	DECLARE @sql NVARCHAR(MAX) = N'SELECT tmp.*, ',
			@totalfieldFromA FLOAT = (SELECT COUNT(1) FROM INFORMATION_SCHEMA.COLUMNS s 
										WHERE 
											s.TABLE_NAME = @nombreTabla
											AND s.COLUMN_NAME LIKE '%[_]a')

	IF (@isRoot = 1)
	BEGIN
		SET @sql = @sql + N'
							[Analisista] = ua.sNombres,
							[Fecha Analisis] = CONVERT(VARCHAR, p.dFechaFin, 103),
							[Base] = t.sNombre, 
							[Control calidad] = IIF(p.bRevisado = 1, ''Si'', ''-'')'
	END
	ELSE
	BEGIN
		SET @sql = @sql + N'
							[Control_calidad_qc] = IIF(p.bRevisado = 1, ''Si'', ''-''),
							[criterios_errados_qc] = (SELECT COUNT([value]) FROM STRING_SPLIT(p.sMetaFieldIdErrorCsv, '','')),
							[Detalle_error_qc] = ISNULL(p.sMetaFieldIdErrorCsv, ''-''),
							[%_error_qc] = (
												SELECT 
													IIF(COUNT([value]) = 0, NULL, ROUND(COUNT([value]) / @totalfieldFromA, 2))
												FROM STRING_SPLIT(p.sMetaFieldIdErrorCsv, '','')
									)'
	END

	SET @sql = @sql + N' FROM RimTablaDinamica t
						JOIN RimGrupoCamposAnalisis g ON t.nIdTabla = g.nIdTabla
						JOIN RimAsigGrupoCamposAnalisis a ON g.nIdGrupo = a.nIdGrupo
						JOIN RimProduccionAnalisis p ON a.nIdAsigGrupo = p.nIdAsigGrupo
						JOIN SidUsuario ua ON a.uIdUsrAnalista = ua.uIdUsuario
						JOIN ' + @nombreTabla + ' tmp ON p.nIdRegistroAnalisis = tmp.nId
						WHERE
							t.sNombre = ''' + @nombreTabla + ''''
							
	IF (@isRoot = 0) -- Consulta de `Analista`
	BEGIN
		SET @sql = CONCAT(@sql, N' AND a.nIdAsigGrupo = ', @idAsig)
	END

	SET @sql = CONCAT(@sql, ' AND CONVERT(DATE, p.dFechaFin) BETWEEN ''', @fecIni, ''' AND ''', @fecFin, '''')
	SET @sql = CONCAT(@sql, ' ORDER BY tmp.nId')

	BEGIN TRY
		EXEC SP_EXECUTESQL @sql, N'@totalfieldFromA FLOAT', @totalfieldFromA = @totalfieldFromA
	END TRY
	BEGIN CATCH
		SELECT 
			[err_message] = ERROR_MESSAGE(),
			[err_procedure] = ERROR_PROCEDURE(),
			[err_line] = ERROR_LINE()
	END CATCH

END

-- Test ...
SELECT * FROM RimAsigGrupoCamposAnalisis
EXEC usp_Rim_Rpt_S10_DRCM_FR001_Produccion 'Dni_vinculado_3_4', '2022-10-27', '2022-10-27', 1, 489

SELECT * FROM SidUsuario
SELECT * FROM RimTablaDinamica
SELECT * FROM RimAsigGrupoCamposAnalisis
SELECT * FROM RimCtrlCalCamposAnalisis

SELECT * FROM RimProduccionAnalisis p
WHERE p.bRevisado = 1

SELECT CONVERT(NUMERIC(10,2), (5 / 10))
SELECT ROUND(2/20.0, 2) * 100

SELECT * FROM RimTablaDinamica
SELECT * FROM RimGrupoCamposAnalisis g WHERE g.nIdTabla = 22

UPDATE SidUsuario
	SET sGrupo = 'DEPURACION'
WHERE sLogin = 'rguevarav'

SELECT * FROM RimProduccionAnalisis p
WHERE
	p.nIdRegistroAnalisis = 8376

SELECT 
	*, 
	[Control_calidad_qc] = IIF(p.bRevisado = 1, 'Si', '-'), 
	[criterios_errados_qc] = (SELECT COUNT([value]) FROM STRING_SPLIT(p.sMetaFieldIdErrorCsv, ',')), 
	[Detalle_error_qc] = ISNULL(p.sMetaFieldIdErrorCsv, '-'), 
	[%_error_qc] = (SELECT IIF(COUNT([value]) = 0, NULL, ROUND(COUNT([value]) / 15, 2)) FROM STRING_SPLIT(p.sMetaFieldIdErrorCsv, ',')) 
	FROM Dni_vinculado_3_4 t  
	JOIN RimProduccionAnalisis p ON t.nId = p.nIdRegistroAnalisis  
	WHERE 
		p.nIdAsigGrupo = 503 
		AND nId IN (9507,9508,9509,9510,9511,9512,9513,9514,9515,9516,9517,9518,9519,9520,9521,9522,9523,9524,9525,9526,9527,9528,9529,9530,9531,9532,9533,9534,9535,9536,9537,9538,9539,9540,9541,9542,9543,9544,9545,9546,9547,9548,9549,9550,9551,9552,9553,9554,9555,9556,9557,9558,9559,9560,9561,9562,9563,9564,9565,9566,9567,9568,9569,9570,9571,9572,9573,9574,9575,9576)

-- ===================================================================================================================================

USE [BDSidtefim-Test]
GO

SELECT * FROM RimGrupoCamposAnalisis

-- STEP-01: ...
UPDATE RimGrupoCamposAnalisis
	SET sMetaFieldsCsv = REPLACE(sMetaFieldsCsv, ',', ' | true,')
WHERE nIdGrupo != 27

-- STEP-02: ...
UPDATE RimGrupoCamposAnalisis
	SET sMetaFieldsCsv = CONCAT(sMetaFieldsCsv, ' | true')
WHERE nIdGrupo != 27
